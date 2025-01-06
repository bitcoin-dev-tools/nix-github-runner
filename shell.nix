{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = [ pkgs.nixfmt ];

  shellHook = ''
    echo "nixfmt shell: run 'format-nix' to format all .nix files"
    format-nix() {
      find . -name "*.nix" -type f -exec nixfmt {} \;
    }
  '';
}
