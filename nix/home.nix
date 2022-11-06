{config, pkgs, ... }:
{
    programs = {
      zsh = {
        enable = true;
        enableCompletion = false; # enabled in oh-my-zsh
        initExtra = ''
          test -f ~/.dir_colors && eval $(dircolors ~/.dir_colors)
          source ~/.my-setup/nix/extra.sh
          source ~/.my-setup/shell/zsh.sh
        '';
        shellAliases = {
          ne = "nix-env";
          ni = "nix-env -iA";
          no = "nixops";
          ns = "nix-shell --pure";
          please = "sudo";
          cls = "clear";
        };
        zplug = {
          enable = true;
          plugins = [
            { name = "zsh-users/zsh-autosuggestions"; }
            { name = "zsh-users/zsh-syntax-highlighting"; }
            { name = "zdharma-continuum/fast-syntax-highlighting"; }
            { name = "marlonrichert/zsh-autocomplete"; tags = [ depth:1 ]; }
          ];
        };
        oh-my-zsh = {
          enable = true;
          plugins = [ "git" "python" "vscode" "docker" ];
          theme = "agnoster";
        };
      };
    };
  home.username = "xpert";
  home.homeDirectory = "/home/xpert";

  home.stateVersion = "22.05";

  programs.home-manager.enable = true;
}
