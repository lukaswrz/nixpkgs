{
  lib,
  stdenv,
  appimageTools,
  fetchurl,
  makeWrapper,
  _7zz,
}:

let
  pname = "joplin-desktop";
  version = "3.1.24";

  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  suffix =
    {
      x86_64-linux = ".AppImage";
      x86_64-darwin = ".dmg";
      aarch64-darwin = "-arm64.dmg";
    }
    .${system} or throwSystem;

  src = fetchurl {
    url = "https://github.com/laurent22/joplin/releases/download/v${version}/Joplin-${version}${suffix}";
    sha256 =
      {
        x86_64-linux = "sha256-ImFB4KwJ/vAHtZUbLAdnIRpd+o2ZaXKy9luw/jnPLSE=";
        x86_64-darwin = "sha256-Of6VXX40tCis+ou26LtJKOZm/87P3rsTHtnvSDwF8VY=";
        aarch64-darwin = "sha256-HtHuZQhIkiI8GrhB9nCOTAN1hOs+9POJFRIsRUNikYs=";
      }
      .${system} or throwSystem;
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };

  meta = with lib; {
    description = "Open source note taking and to-do application with synchronisation capabilities";
    mainProgram = "joplin-desktop";
    longDescription = ''
      Joplin is a free, open source note taking and to-do application, which can
      handle a large number of notes organised into notebooks. The notes are
      searchable, can be copied, tagged and modified either from the
      applications directly or from your own text editor. The notes are in
      Markdown format.
    '';
    homepage = "https://joplinapp.org";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [
      hugoreeves
      qjoly
      yajo
    ];
    platforms = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };

  linux = appimageTools.wrapType2 {
    inherit
      pname
      version
      src
      meta
      ;
    nativeBuildInputs = [ makeWrapper ];

    profile = ''
      export LC_ALL=C.UTF-8
    '';

    extraInstallCommands = ''
      wrapProgram $out/bin/joplin-desktop \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"
      install -Dm644 ${appimageContents}/@joplinapp-desktop.desktop $out/share/applications/joplin.desktop
      install -Dm644 ${appimageContents}/@joplinapp-desktop.png $out/share/pixmaps/joplin.png
      substituteInPlace $out/share/applications/joplin.desktop \
        --replace-fail 'Exec=AppRun' 'Exec=joplin-desktop'
    '';
  };

  darwin = stdenv.mkDerivation {
    inherit
      pname
      version
      src
      meta
      ;

    nativeBuildInputs = [ _7zz ];

    unpackPhase = ''
      runHook preUnpack
      7zz x -x'!Joplin ${version}/Applications' $src
      runHook postUnpack
    '';

    sourceRoot = if stdenv.hostPlatform.isx86_64 then "Joplin ${version}" else ".";

    installPhase = ''
      runHook preInstall
      mkdir -p $out/Applications
      cp -R Joplin.app $out/Applications
      runHook postInstall
    '';
  };
in
if stdenv.hostPlatform.isDarwin then darwin else linux
