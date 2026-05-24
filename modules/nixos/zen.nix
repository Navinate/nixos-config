{
  # System-wide Zen browser policies (extensions, etc.)
  # Zen reads from /etc/zen/policies/policies.json just like Firefox does.
  environment.etc."zen/policies/policies.json".text = builtins.toJSON {
    policies = {
      ExtensionSettings = {
        # uBlock Origin
        "uBlock0@raymondhill.net" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
        };
      };
    };
  };
}
