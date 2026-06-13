{
  programs.firefox = {
    enable = true;
    # Pin to legacy path; 26.05 default is $XDG_CONFIG_HOME/mozilla/firefox.
    # Switching means moving ~/.mozilla/firefox by hand.
    configPath = ".mozilla/firefox";
    # Profiles, extensions, prefs can be declared here later.
    # See: https://nix-community.github.io/home-manager/options.xhtml#opt-programs.firefox
    profiles = {
      kida = {
        id = 0;
        isDefault = true;
        bookmarks = {
          force = true;
          settings = [
            {
              name = "My Bookmarks Toolbar";
              toolbar = true;
              bookmarks = [
                {
                  name = "NixOS";
                  url = "https://nixos.org";
                }
                {
                  name = "Home Manager";
                  url = "https://nix-community.github.io/home-manager/";
                }
              ];
            }
            {
              name = "GitHub";
              url = "https://github.com";
            }
          ];
        };
      };
    };
  };
}
