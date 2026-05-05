{ ... }:
{
  # Pipewire replaces PulseAudio and JACK. The compatibility shims mean
  # apps written for either still work.
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };

  # rtkit lets pipewire run with realtime priority for low-latency audio.
  security.rtkit.enable = true;
}
