{ lib, spinnaker, stdenv, writeShellScriptBin, python310Packages, ... }:
with python310Packages;
buildPythonApplication {
  pname = "spinnaker-acquisition";
  version = "1.0";

  propagatedBuildInputs = [
    spinnaker.spinnaker
    spinnaker.spinnaker-python310
  ];

  makeWrapperArgs = ["--set SPINNAKER_GENTL64_CTI ${spinnaker.spinnaker-cti-path}"];

  src = ./src;
}
