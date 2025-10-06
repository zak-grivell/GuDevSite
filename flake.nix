{
  description = "GuDevSite Jekyll development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs = {nixpkgs, ...}: let
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    devShells = forAllSystems (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in {
        default = pkgs.mkShell {
          name = "jekyll-dev-shell";

          packages = with pkgs; [
            ruby_3_3
            bundler
            jekyll

            clang
            cmake
            pkg-config
            zlib
            libffi
            openssl

            superhtml
          ];

          shellHook = ''
            export GEM_HOME="$PWD/.gems"
            export GEM_PATH="$GEM_HOME"
            export BUNDLE_PATH="$GEM_HOME"
            export PATH="$GEM_HOME/bin:$PATH"

            echo "💎 Jekyll shell ready for ${system}"

            if [ -f Gemfile ]; then
              bundle install
            fi
          '';
        };
      }
    );

    apps = forAllSystems (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in {
        default = {
          type = "app";
          program = toString (
            pkgs.writeShellScript "run-jekyll" ''
              export GEM_HOME="$PWD/.gems"
              export GEM_PATH="$GEM_HOME"
              export BUNDLE_PATH="$GEM_HOME"
              export PATH="$GEM_HOME/bin:$PATH"

              echo "🚀 Starting Jekyll development server..."

              if [ -f Gemfile ]; then
                ${pkgs.bundler}/bin/bundle exec jekyll serve --livereload
              else
                ${pkgs.jekyll}/bin/jekyll serve --livereload
              fi
            ''
          );
        };
      }
    );
  };
}
