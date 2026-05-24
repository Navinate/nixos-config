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

  services.blueman.enable = true;
}
