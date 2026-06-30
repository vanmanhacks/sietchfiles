{ inputs, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gnumake
    cmake
    libgcc
    pkg-config
    alsa-lib
    clang
    libclang
    fontconfig
    xz
    sqlcipher
    sqlite
    wabt

    vim
    wget
    curl
    git
    moreutils
    toybox

    openssl
    sbctl
    usbguard

    broot
    fd
    bottom
    hyperfine
    gping
    procs

    wl-clipboard-rs

    doggo
    lazygit

    jq
    jq-zsh-plugin

    alacritty

    zsh
    starship
    eza
    bat
    ripgrep
    anewer
    btop
    zoxide
    dust
    ouch
    nushell

    neovim
    xclip

    fastfetch

    pandoc
    calibre

    magic-wormhole-rs

    openvpn
    openvpn3
    wireguard-tools

    ansible
    vagrant

    obsidian
    obsidian-export

    thumbs
    tmuxifier

    adguardhome
    adguardian

    bun
    wrangler

    python3
    uv

    claude-code

    signal-cli-unstable

    mosh

    iw
    tcpdump


    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.hermes-agent
    # inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.agent-browser
    inputs.codebase-memory-mcp.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # programs.claude-code.enable = true;
}
