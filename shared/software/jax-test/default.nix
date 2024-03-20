{ lib, stdenv, writeShellScriptBin, python310Packages, ... }:
with python310Packages;
buildPythonApplication {
  pname = "jax-test";
  version = "1.0";

  propagatedBuildInputs = with pkgs; [
    jax
    jaxlibWithCuda
  ];


  # makeWrapperArgs = [ "--set" "SPINNAKER_GENTL64_CTI" "${spinnaker.spinnaker-cti-path}" ];

  src = ./src;
}
