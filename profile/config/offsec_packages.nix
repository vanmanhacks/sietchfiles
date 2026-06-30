{ lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    testdisk

    wordlists
    payloadsallthethings-unstable

    wafw00f
    tlsx
    sslscan

    whois
    dig
    dnslookup

    mubeng

    asnmap
    findomain
    amass
    subfinder
    gungnir
    assetfinder
    chaos

    dnsx
    alterx

    netcat
    chisel
    netexec

    nmap
    nmap-formatter
    smap
    rustscan
    fingerprintx

    xh
    httpx

    feroxbuster
    katana
    gau
    arjun
    xnlinkfinder
    waymore
    gowitness
    cewl
    cewler
    ffuf
    kiterunner

    hakrawler
    gospider

    nuclei
    nuclei-templates
    cent
    sqlmap
    dalfox
    jwt-hack
    apkleaks
    trufflehog

    aircrack-ng
  ];
}
