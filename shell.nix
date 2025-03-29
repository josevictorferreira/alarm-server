{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    ruby_3_4
    sqlite
    libffi
    openssl
    libxml2
    libxslt
    zlib
    wget
    curl
    gnumake
    libyaml
  ];

  shellHook = ''
    export BUNDLE_PATH=$PWD/.bundle
    export GEM_HOME=$PWD/.bundle
    export PATH=$PWD/.bundle/bin:$PATH
    export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath (with pkgs; [ curl ])};
    export RUBY_YJIT_ENABLE=1;
    export TMPDIR=/tmp
  '';
}
