{
  lib,
  buildPythonPackage,
  fetchPypi,
  cryptography,
  flit-core,
}:

buildPythonPackage rec {
  pname = "cryptography-vectors";
  # The test vectors must have the same version as the cryptography package
  inherit (cryptography) version;
  pyproject = true;

  src = fetchPypi {
    pname = "cryptography_vectors";
    inherit version;
    hash = "sha256-+7BAjfj/LSs9vSkovFt/7r/dNvsJL6h5DVd4qbmh+e8=";
  };

  build-system = [ flit-core ];

  # No tests included
  doCheck = false;

  pythonImportsCheck = [ "cryptography_vectors" ];

  meta = with lib; {
    description = "Test vectors for the cryptography package";
    homepage = "https://cryptography.io/en/latest/development/test-vectors/";
    downloadPage = "https://github.com/pyca/cryptography/tree/master/vectors";
    license = with licenses; [
      asl20
      bsd3
    ];
    maintainers = with maintainers; [ SuperSandro2000 ];
  };
}
