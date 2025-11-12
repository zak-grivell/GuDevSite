{
  description = "GuDevSite Jekyll development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            name = "jekyll-dev-shell";

            buildInputs = [
              pkgs.ruby_3_3
              pkgs.jekyll
              pkgs.clang
              pkgs.cmake
              pkgs.pkg-config
              pkgs.zlib
              pkgs.libffi
              pkgs.openssl
            ];

            shellHook = ''
              export GEM_HOME=$PWD/.gems
              export PATH="$GEM_HOME/bin:$PATH"
              echo "💎 Jekyll shell ready for ${system}"
              bundle install
            '';
          };
        }
      );

      apps = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          # This defines what `nix run` will execute
          default = {
            type = "app";
            program = toString (
              pkgs.writeShellScript "run-jekyll" ''
                export GEM_HOME=$PWD/.gems
                export PATH="$GEM_HOME/bin:$PATH"
                echo "🚀 Starting Jekyll development server..."
                ${pkgs.jekyll}/bin/jekyll serve --livereload
              ''
            );
          };
        }
      );
    };
}
