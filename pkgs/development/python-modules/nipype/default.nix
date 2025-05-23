{
  lib,
  stdenv,
  buildPythonPackage,
  fetchPypi,
  pythonOlder,
  # python dependencies
  click,
  python-dateutil,
  etelemetry,
  filelock,
  funcsigs,
  future,
  looseversion,
  mock,
  networkx,
  nibabel,
  numpy,
  packaging,
  prov,
  psutil,
  pybids,
  pydot,
  pytest,
  pytest-xdist,
  pytest-forked,
  rdflib,
  scipy,
  simplejson,
  traits,
  xvfbwrapper,
  # other dependencies
  which,
  bash,
  glibcLocales,
  # causes Python packaging conflict with any package requiring rdflib,
  # so use the unpatched rdflib by default (disables Nipype provenance tracking);
  # see https://github.com/nipy/nipype/issues/2888:
  useNeurdflib ? false,
}:

buildPythonPackage rec {
  pname = "nipype";
  version = "1.10.0";
  disabled = pythonOlder "3.7";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-GeXWzvpwmXGY94vGZe9NPTy1MyW1uYpy5Rrvra9rPg4=";
  };

  postPatch = ''
    substituteInPlace nipype/interfaces/base/tests/test_core.py \
      --replace "/usr/bin/env bash" "${bash}/bin/bash"
  '';

  pythonRelaxDeps = [ "traits" ];

  propagatedBuildInputs = [
    click
    python-dateutil
    etelemetry
    filelock
    funcsigs
    future
    looseversion
    networkx
    nibabel
    numpy
    packaging
    prov
    psutil
    pydot
    rdflib
    scipy
    simplejson
    traits
    xvfbwrapper
  ];

  nativeCheckInputs = [
    pybids
    glibcLocales
    mock
    pytest
    pytest-forked
    pytest-xdist
    which
  ];

  # checks on darwin inspect memory which doesn't work in build environment
  doCheck = !stdenv.hostPlatform.isDarwin;
  # ignore tests which incorrect fail to detect xvfb
  checkPhase = ''
    pytest nipype/tests -k 'not display and not test_no_et_multiproc'
  '';
  pythonImportsCheck = [ "nipype" ];

  meta = with lib; {
    homepage = "https://nipy.org/nipype/";
    description = "Neuroimaging in Python: Pipelines and Interfaces";
    mainProgram = "nipypecli";
    license = licenses.bsd3;
    maintainers = with maintainers; [ ashgillman ];
  };
}
