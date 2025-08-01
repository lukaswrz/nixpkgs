{
  lib,
  buildPythonPackage,
  fetchPypi,
  ddt,
  iso8601,
  keystoneauth1,
  openssl,
  openstackdocstheme,
  oslo-i18n,
  oslo-serialization,
  pbr,
  prettytable,
  pythonOlder,
  requests-mock,
  setuptools,
  sphinxcontrib-apidoc,
  sphinxHook,
  stestr,
  testscenarios,
}:

buildPythonPackage rec {
  pname = "python-novaclient";
  version = "18.10.0";
  pyproject = true;

  disabled = pythonOlder "3.9";

  src = fetchPypi {
    pname = "python_novaclient";
    inherit version;
    hash = "sha256-LwZqAQYe6t0c6G+/4CZ6HQ0Yi2TBZBNh9yXEJ39nqWs=";
  };

  nativeBuildInputs = [
    openstackdocstheme
    sphinxcontrib-apidoc
    sphinxHook
  ];

  sphinxBuilders = [ "man" ];

  build-system = [ setuptools ];

  dependencies = [
    iso8601
    keystoneauth1
    oslo-i18n
    oslo-serialization
    pbr
    prettytable
  ];

  nativeCheckInputs = [
    ddt
    openssl
    requests-mock
    stestr
    testscenarios
  ];

  checkPhase = ''
    runHook preCheck
    stestr run -e <(echo "
    novaclient.tests.unit.test_shell.ParserTest.test_ambiguous_option
    novaclient.tests.unit.test_shell.ParserTest.test_not_really_ambiguous_option
    novaclient.tests.unit.test_shell.ShellTest.test_osprofiler
    novaclient.tests.unit.test_shell.ShellTestKeystoneV3.test_osprofiler
    ")
    runHook postCheck
  '';

  pythonImportsCheck = [ "novaclient" ];

  meta = with lib; {
    description = "Client library for OpenStack Compute API";
    mainProgram = "nova";
    homepage = "https://github.com/openstack/python-novaclient";
    license = licenses.asl20;
    teams = [ teams.openstack ];
  };
}
