{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  makeWrapper,
  cmake,
  pkg-config,
  xorg ? null,
  libGL ? null,
}:

rustPlatform.buildRustPackage rec {
  pname = "rx";
  version = "0.5.2";

  src = fetchFromGitHub {
    owner = "cloudhead";
    repo = "rx";
    rev = "v${version}";
    sha256 = "sha256-LTpaV/fgYUgA2M6Wz5qLHnTNywh13900g+umhgLvciM=";
  };

  cargoHash = "sha256-gRhjqQNL1Cu6/RpF2AeIGwbuDkFvyOf3gnpYt5Hlhfc=";

  nativeBuildInputs = [
    cmake
    pkg-config
    makeWrapper
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux (
    with xorg;
    [
      # glfw-sys dependencies:
      libX11
      libXrandr
      libXinerama
      libXcursor
      libXi
      libXext
    ]
  );

  # FIXME: GLFW (X11) requires DISPLAY env variable for all tests
  doCheck = false;

  postInstall = lib.optionalString stdenv.hostPlatform.isLinux ''
    mkdir -p $out/share/applications
    cp $src/rx.desktop $out/share/applications
    wrapProgram $out/bin/rx --prefix LD_LIBRARY_PATH : ${libGL}/lib
  '';

  meta = with lib; {
    description = "Modern and extensible pixel editor implemented in Rust";
    mainProgram = "rx";
    homepage = "https://rx.cloudhead.io/";
    license = licenses.gpl3;
    maintainers = with maintainers; [
      minijackson
      Br1ght0ne
    ];
    platforms = [ "x86_64-linux" ];
  };
}
