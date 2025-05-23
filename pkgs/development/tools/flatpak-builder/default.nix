{
  lib,
  stdenv,
  fetchurl,
  replaceVars,
  nixosTests,

  docbook_xml_dtd_45,
  docbook_xsl,
  gettext,
  libxml2,
  libxslt,
  pkg-config,
  xmlto,
  meson,
  ninja,

  acl,
  appstream,
  breezy,
  binutils,
  bzip2,
  coreutils,
  cpio,
  curl,
  debugedit,
  elfutils,
  flatpak,
  gitMinimal,
  glib,
  glibcLocales,
  gnumake,
  gnupg,
  gnutar,
  json-glib,
  libcap,
  libyaml,
  ostree,
  patch,
  rpm,
  unzip,
  attr,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "flatpak-builder";
  version = "1.4.4";

  outputs = [
    "out"
    "doc"
    "man"
    "installedTests"
  ];

  # fetchFromGitHub fetches an archive which does not contain the full source (https://github.com/flatpak/flatpak-builder/issues/558)
  src = fetchurl {
    url = "https://github.com/flatpak/flatpak-builder/releases/download/${finalAttrs.version}/flatpak-builder-${finalAttrs.version}.tar.xz";
    hash = "sha256-3CcVk5S6qiy1I/Uvh0Ry/1DRYZgyMyZMoqIuhQdB7Ho=";
  };

  patches = [
    # patch taken from gtk_doc
    ./respect-xml-catalog-files-var.patch

    # Hardcode paths
    (replaceVars ./fix-paths.patch {
      brz = "${breezy}/bin/brz";
      cp = "${coreutils}/bin/cp";
      patch = "${patch}/bin/patch";
      tar = "${gnutar}/bin/tar";
      unzip = "${unzip}/bin/unzip";
      rpm2cpio = "${rpm}/bin/rpm2cpio";
      cpio = "${cpio}/bin/cpio";
      git = "${gitMinimal}/bin/git";
      rofilesfuse = "${ostree}/bin/rofiles-fuse";
      strip = "${binutils}/bin/strip";
      eustrip = "${elfutils}/bin/eu-strip";
      euelfcompress = "${elfutils}/bin/eu-elfcompress";
    })

    (replaceVars ./fix-test-paths.patch {
      inherit glibcLocales;
    })
    ./fix-test-prefix.patch
  ];

  nativeBuildInputs = [
    meson
    ninja
    docbook_xml_dtd_45
    docbook_xsl
    gettext
    libxml2
    libxslt
    pkg-config
    xmlto
  ];

  buildInputs = [
    acl
    appstream
    bzip2
    curl
    debugedit
    elfutils
    flatpak
    glib
    json-glib
    libcap
    libxml2
    libyaml
    ostree
  ];

  mesonFlags = [
    "-Dinstalled_tests=true"
    "-Dinstalled_test_prefix=${placeholder "installedTests"}"
  ];

  # Some scripts used by tests  need to use shebangs that are available in Flatpak runtimes.
  dontPatchShebangs = true;

  enableParallelBuilding = true;

  # Installed tests
  postFixup =
    let
      installed_testdir = "${placeholder "installedTests"}/libexec/installed-tests/flatpak-builder";
    in
    ''
      for file in ${installed_testdir}/{test-builder.sh,test-builder-python.sh,test-builder-deprecated.sh}; do
        patchShebangs $file
      done
    '';

  passthru = {
    installedTestsDependencies = [
      gnupg
      ostree
      gnumake
      attr
      libxml2
      appstream
    ];

    tests = {
      installedTests = nixosTests.installed-tests.flatpak-builder;
    };
  };

  meta = with lib; {
    description = "Tool to build flatpaks from source";
    mainProgram = "flatpak-builder";
    homepage = "https://github.com/flatpak/flatpak-builder";
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [ arthsmn ];
    platforms = platforms.linux;
  };
})
