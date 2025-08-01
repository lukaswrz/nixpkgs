{
  lib,
  fetchCrate,
  rustPlatform,
  openssl,
  pkg-config,
}:

rustPlatform.buildRustPackage rec {
  pname = "apkeep";
  version = "0.17.0";

  src = fetchCrate {
    inherit pname version;
    hash = "sha256-YjGfnYK22RIVa8D8CWnAxHGDqXENGAPIeQQ606Q3JW8=";
  };

  cargoHash = "sha256-CwucGAwAvxePNQu5p1OWx9o9xsvpzX1abH6HyF43nEE=";

  prePatch = ''
    rm .cargo/config.toml
  '';

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  meta = {
    description = "Command-line tool for downloading APK files from various sources";
    homepage = "https://github.com/EFForg/apkeep";
    changelog = "https://github.com/EFForg/apkeep/blob/${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "apkeep";
  };
}
