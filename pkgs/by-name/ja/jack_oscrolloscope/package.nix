{
  lib,
  stdenv,
  fetchurl,
  SDL,
  libjack2,
  libGLU,
  libGL,
  libX11,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "jack_oscrolloscope";
  version = "0.7";

  src = fetchurl {
    url = "http://das.nasophon.de/download/${pname}-${version}.tar.gz";
    sha256 = "1pl55in0sj7h5r06n1v91im7d18pplvhbjhjm1fdl39zwnyxiash";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    SDL
    libjack2
    libGLU
    libGL
    libX11
  ];

  installPhase = ''
    mkdir -p $out/bin
    mv jack_oscrolloscope $out/bin/
  '';

  meta = with lib; {
    description = "Simple waveform viewer for JACK";
    mainProgram = "jack_oscrolloscope";
    homepage = "http://das.nasophon.de/jack_oscrolloscope";
    license = licenses.gpl2;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
}
