# /etc/nixos/aggregation.nix

{ config, pkgs, ... }:

let
  aggregateScript = pkgs.writers.writePython3Bin "aggregate-blocklists"
    {
      libraries = [ pkgs.python3Packages.urllib3 ];
    } ''
    import urllib.request
    import os
    import tempfile
    import subprocess


    # Configuration
    META_LISTS = [
        "https://gist.githubusercontent.com/sidward35/"
        "cea28bedd0ec0b1bceec8c2b22c163c4/raw/",
        "https://raw.githubusercontent.com/stevejenkins/"
        "pi-hole-lists/main/blocklists.txt"
    ]
    PERFLYST_BASE = (
        "https://raw.githubusercontent.com/Perflyst/"
        "PiHoleBlocklist/master/"
    )
    PERFLYST_FILES = [
        "AmazonFireTV.txt", "Android.txt", "BloodHound.txt",
        "Metrics.txt", "SmartTV.txt"
    ]

    FINAL_FILE = "/var/lib/adguard-blocklists/aggregated.txt"


    def fetch_url(url):
        try:
            headers = {'User-Agent': 'Mozilla/5.0'}
            req = urllib.request.Request(url, headers=headers)
            with urllib.request.urlopen(req, timeout=10) as response:
                return response.read().decode('utf-8').splitlines()
        except Exception as e:
            print(f"Failed to fetch {url}: {e}")
            return []


    def main():
        print("Starting blocklist aggregation...")
        urls_to_fetch = [PERFLYST_BASE + f for f in PERFLYST_FILES]

        # 1. Parse meta-lists for actual blocklist URLs
        for meta_url in META_LISTS:
            print(f"Parsing meta-list: {meta_url}")
            lines = fetch_url(meta_url)
            for line in lines:
                line = line.strip()
                if line.startswith("http"):
                    urls_to_fetch.append(line)

        # 2. Download all identified blocklists into a temporary file
        temp_fd, temp_path = tempfile.mkstemp()
        with os.fdopen(temp_fd, 'w') as out_file:
            # set() removes duplicate URLs
            for url in set(urls_to_fetch):
                print(f"Downloading blocklist: {url}")
                lines = fetch_url(url)
                for line in lines:
                    if line and not line.startswith('#'):
                        out_file.write(line + '\n')

        # 3. Atomic replace of the final file
        os.chmod(temp_path, 0o644)
        subprocess.call(['install', '-m', '644', temp_path, FINAL_FILE])
        os.unlink(temp_path)
        print(f"Successfully aggregated lists into {FINAL_FILE}")


    if __name__ == "__main__":
        main()
  '';

in
{
  systemd.services.update-adguard-blocklists = {
    description = "Aggregate AdGuard Home Blocklists";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${aggregateScript}/bin/aggregate-blocklists";
      StateDirectory = "adguard-blocklists";
      StateDirectoryMode = "0755";
      DynamicUser = true;
    };
  };

  systemd.timers.update-adguard-blocklists = {
    description = "Timer for AdGuard Home Blocklist Aggregation";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };
}
