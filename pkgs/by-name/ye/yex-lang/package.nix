{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage {
  pname = "yex-lang";
  version = "0.pre+date=2022-05-10";

  src = fetchFromGitHub {
    owner = "nonamescm";
    repo = "yex-lang";
    rev = "866c4decbb9340f5af687b145e2c4f47fcbee786";
    hash = "sha256-sxzkZ2Rhn3HvZIfjnJ6Z2au/l/jV5705ecs/X3Iah6k=";
  };

  cargoHash = "sha256-Kz/7BFBmTK8h6nO+jrSYh2p0GMlT1E0icmLXC+mJVmg=";

  meta = with lib; {
    homepage = "https://github.com/nonamescm/yex-lang";
    description = "Functional scripting language written in rust";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "yex";
    platforms = platforms.unix;
  };
}
