{ pkgs, ... }:
{
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.configPackages = [
      # Bluetooth headset (Bose 700): keep the full bluez role set, but never
      # auto-switch into the HFP/HSP "headset" profile. HFP forces the headphones
      # into narrowband call mode with an always-on low-quality mic — the Linux
      # equivalent of disabling "Hands-Free Telephony" on Windows. The desktop
      # mic is the Scarlett Solo, so the headset never needs to capture.
      #
      # NB: do NOT restrict bluez5.roles to just A2DP to achieve this. The Bose
      # 700 only negotiates its high-quality `a2dp-sink` output profile when the
      # HFP roles are also present; dropping them leaves only the useless
      # `audio-gateway` profile and the headphones never appear as an output.
      # Disabling autoswitch-to-headset-profile is what actually keeps us on A2DP.
      (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/11-bluetooth-policy.conf" ''
        monitor.bluez.properties = {
          bluez5.roles = [ a2dp_sink a2dp_source bap_sink bap_source hsp_hs hsp_ag hfp_hf hfp_ag ]
        }
        wireplumber.settings = {
          bluetooth.autoswitch-to-headset-profile = false
        }
      '')
    ];
  };
}
