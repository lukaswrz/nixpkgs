{
  lib,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
  pkg-config,
  cmake,
}:

rustPlatform.buildRustPackage rec {
  pname = "rmpc";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "mierak";
    repo = "rmpc";
    rev = "v${version}";
    hash = "sha256-6hs0neoQf1h5IORJZp8R3ELLvYBXMr1iqc7ErSsGnUQ=";
  };

  cargoHash = "sha256-xXH/MRQgT/Je/aOCZ26vdC3PtlosXLIrjbOHtnvf9os=";

  checkFlags = [
    # Test currently broken, needs to be removed. See https://github.com/mierak/rmpc/issues/254
    "--skip=core::scheduler::tests::interleaves_repeated_and_scheduled_jobs"
  ];

  nativeBuildInputs = [
    installShellFiles
    pkg-config
    cmake
  ];

  env.VERGEN_GIT_DESCRIBE = version;

  postInstall = ''
    installManPage target/man/rmpc.1

    installShellCompletion --cmd rmpc \
      --bash target/completions/rmpc.bash \
      --fish target/completions/rmpc.fish \
      --zsh target/completions/_rmpc
  '';

  meta = {
    changelog = "https://github.com/mierak/rmpc/releases/tag/${src.rev}";
    description = "TUI music player client for MPD with album art support via kitty image protocol";
    homepage = "https://mierak.github.io/rmpc/";
    license = lib.licenses.bsd3;
    longDescription = ''
      Rusty Music Player Client is a beautiful, modern and configurable terminal-based Music Player
      Daemon client. It was inspired by ncmpcpp and aims to provide an alternative with support for
      album art through kitty image protocol without any ugly hacks. It also features ranger/lf
      inspired browsing of songs and other goodies.
    '';
    maintainers = with lib.maintainers; [
      donovanglover
      bloxx12
    ];
    mainProgram = "rmpc";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
