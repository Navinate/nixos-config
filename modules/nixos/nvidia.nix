{ config, ... }:
{
	hardware.graphics.enable = true;
	services.xserver.videoDrivers = [ "nvidia" ];

	hardware.nvidia = {
		modesetting.enable = true;
		open = true;
		nvidiaSettings = true;
		package = config.boot.kernelPackages.nvidiaPackages.stable;
		powerManagement.enable = false; # flip to true if post-suspend corruption occurs
	};
}
