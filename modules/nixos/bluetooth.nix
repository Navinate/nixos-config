{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        JustWorksRepairing = "always";
      };
    };
  };

  hardware.xpadneo.enable = true;

  services.blueman.enable = true;
}
