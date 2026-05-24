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

  boot.kernelParams = [ "bluetooth.disable_ertm=1" ];

  services.blueman.enable = true;
}
