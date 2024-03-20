{ lib, toliman, stdenv, writeShellScriptBin, python310Packages, ... }:
with python310Packages;
buildPythonApplication {
  pname = "spinnaker-acquisition";
  version = "1.0";

  propagatedBuildInputs = [
    toliman.spinnaker.spinnaker
    toliman.spinnaker.spinnaker-python310

    numpy
  ];


  makeWrapperArgs = [ "--set" "SPINNAKER_GENTL64_CTI" "${toliman.spinnaker.spinnaker-cti-path}" ];

  src = ./src;
}
