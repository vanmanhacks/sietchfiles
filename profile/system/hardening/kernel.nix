{ ... }:

{
  #security.lockKernelModules = true;
  security.protectKernelImage = true;

  #security.allowSimultaneousMultithreading = false;

  security.forcePageTableIsolation = true;

  # This is required by podman to run containers in rootless mode.
  #security.unprivilegedUsernsClone = config.virtualisation.containers.enable;

  security.virtualisation.flushL1DataCache = "always";

  #security.apparmor.enable = true;
  #security.apparmor.killUnconfinedConfinables = true;

  boot.kernelParams = [
    # Overwrite free'd pages
    "page_poison=1"
    # make it harder to influence slab cache layout
    "slab_nomerge"
    # enables zeroing of memory during allocation and free time
    # helps mitigate use-after-free vulnerabilaties
    "init_on_alloc=1"
    "init_on_free=1"
    # randomizes page allocator freelist, improving security by
    # making page allocations less predictable
    "page_alloc.shuffle=1"
    # enables Kernel Page Table Isolation, which mitigates Meltdown and
    # prevents some KASLR bypasses
    "pti=on"
    # randomizes the kernel stack offset on each syscall
    # making attacks that rely on a deterministic stack layout difficult
    "randomize_kstack_offset=on"
    # disables vsyscalls, they've been replaced with vDSO
    "vsyscall=none"
    # disables debugfs, which exposes sensitive info about the kernel
    "debugfs=off"
    # certain exploits cause an "oops", this makes the kernel panic if an "oops" occurs
    "oops=panic"
    # only alows kernel modules that have been signed with a valid key to be loaded
    # making it harder to load malicious kernel modules
    # can make VirtualBox or Nvidia drivers unusable
    "module.sig_enforce=1"
    # prevents user space code excalation
    #"lockdown=confidentiality"
    # "rd.udev.log_level=3"
    # "udev.log_priority=3"
  ];

  boot.blacklistedKernelModules = [

    "dccp"
    "sctp"
    "rds"
    "tipc"

    # Obscure network protocols
    "ax25"
    "netrom"
    "rose"

    # Old or rare or insufficiently audited filesystems
    "adfs"
    "affs"
    "bfs"
    "befs"
    "cramfs"
    "efs"
    "erofs"
    "exofs"
    "freevxfs"
    "f2fs"
    "hfs"
    "hpfs"
    "jfs"
    "minix"
    "nilfs2"
    "ntfs"
    "omfs"
    "qnx4"
    "qnx6"
    "sysv"
    "ufs"
  ];

  boot.kernel.sysctl = {
    "net.ipv4.tcp_syncookies" = 1;
    "net.ipv6.conf.all.use_tempaddr" = 2;
    # "net.ipv6.conf.default.use_tempaddr" = 2;
    "fs.protected_fifos" = 2;
    "fs.protected_regular" = 2;
    "fs.suid_dumpable" = false;
    "kernel.unprivileged_bpf_disabled" = true;
    "net.core.bpf_jit_harden" = 2;

    # prevent pointer leaks
    "kernel.kptr_restrict" = 2;
    # restrict kernel log to CAP_SYSLOG capability
    "kernel.dmesg_restrict" = 1;
    # Note: certian container runtimes or browser sandboxes might rely on the following
    # restrict eBPF to the CAP_BPF capability
    #"kernel.unprivileged_bpf_disabled" = 1;
    # should be enabled along with bpf above
    # "net.core.bpf_jit_harden" = 2;
    # restrict loading TTY line disciplines to the CAP_SYS_MODULE
    "dev.tty.ldisk_autoload" = 0;
    # prevent exploit of use-after-free flaws
    "vm.unprivileged_userfaultfd" = 0;
    # kexec is used to boot another kernel during runtime and can be abused
    "kernel.kexec_load_disabled" = 1;
    # Kernel self-protection
    # SysRq exposes a lot of potentially dangerous debugging functionality to unprivileged users
    # 4 makes it so a user can only use the secure attention key. A value of 0 would disable completely
    "kernel.sysrq" = 4;
    # disable unprivileged user namespaces, Note: Docker, NH, and other apps may need this
    # "kernel.unprivileged_userns_clone" = 0; # commented out because it makes NH and other programs fail
    # restrict all usage of performance events to the CAP_PERFMON capability
    "kernel.perf_event_paranoid" = 3;

    # Userspace
    # restrict usage of ptrace
    "kernel.yama.ptrace_scope" = 2;

    # ASLR memory protection (64-bit systems)
    "vm.mmap_rnd_bits" = 32;
    "vm.mmap_rnd_compat_bits" = 16;

    # only permit symlinks to be followed when outside of a world-writable sticky directory
    "fs.protected_symlinks" = 1;
    "fs.protected_hardlinks" = 1;

    # Randomize memory
    "kernel.randomize_va_space" = 2;
    # Exec Shield (Stack protection)
    "kernel.exec-shield" = 1;

    ## TCP optimization
    # TCP Fast Open is a TCP extension that reduces network latency by packing
    # data in the sender’s initial TCP SYN. Setting 3 = enable TCP Fast Open for
    # both incoming and outgoing connections:
    "net.ipv4.tcp_fastopen" = 3;
    # Bufferbloat mitigations + slight improvement in throughput & latency
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "cake";

    # Mullvad WireGuard requires loose rp_filter (2) because packets arrive on
    # the WG interface but the return route may exit via the physical interface.
    # Strict mode (1) would drop these valid return-path packets.
    # Revert to strict (1) if Mullvad WG is removed or single-interface setup.
    "net.ipv4.conf.all.rp_filter" = "2";
    "net.ipv4.conf.default.rp_filter" = "2";
    "net.ipv6.conf.all.rp_filter" = "2";
    "net.ipv6.conf.default.rp_filter" = "2";

    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
  };

  # Disable ftrace debugging
  boot.kernel.sysctl."kernel.ftrace_enabled" = false;

  # Enable strict reverse path filtering (that is, do not attempt to route
  # packets that "obviously" do not belong to the iface's network; dropped
  # packets are logged as martians).
  boot.kernel.sysctl."net.ipv4.conf.all.log_martians" = true;
  # boot.kernel.sysctl."net.ipv4.conf.all.rp_filter" = "1";
  boot.kernel.sysctl."net.ipv4.conf.default.log_martians" = true;
  # boot.kernel.sysctl."net.ipv4.conf.default.rp_filter" = "1";

  # Ignore broadcast ICMP (mitigate SMURF)
  boot.kernel.sysctl."net.ipv4.icmp_echo_ignore_broadcasts" = true;

  # Ignore incoming ICMP redirects (note: default is needed to ensure that the
  # setting is applied to interfaces added after the sysctls are set)
  # boot.kernel.sysctl."net.ipv4.conf.all.accept_redirects" = false;
  boot.kernel.sysctl."net.ipv4.conf.all.secure_redirects" = false;
  # boot.kernel.sysctl."net.ipv4.conf.default.accept_redirects" = false;
  boot.kernel.sysctl."net.ipv4.conf.default.secure_redirects" = false;
  # boot.kernel.sysctl."net.ipv6.conf.all.accept_redirects" = false;
  # boot.kernel.sysctl."net.ipv6.conf.default.accept_redirects" = false;

  # Ignore outgoing ICMP redirects (this is ipv4 only)
  boot.kernel.sysctl."net.ipv4.conf.all.send_redirects" = false;
  boot.kernel.sysctl."net.ipv4.conf.default.send_redirects" = false;
}
