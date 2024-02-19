{ lib, stdenv, fetchurl, runCommand, autoPatchelfHook, dpkg, libusb, libz, ffmpeg_4, python310Packages }:
let
  version = "4.0.0.116";

  spinnakerSrcTar = fetchurl {
    url = "https://flir.netx.net/file/asset/59503/original/attachment";
    sha256 = "sha256-wji9Z1Suxz/oeImIv5tEiJoX9zcsh/XB4jk+1/qYAjU=";
  };

  spinnakerPythonSrcTar = fetchurl {
    url = "https://flir.netx.net/file/asset/59509/original/attachment";
    sha256 = "sha256-ZpueM1KHDM7W3mV2nEhOuXpBVM+pCzbd6X0xWmxIdrs=";
  };

  # The debian files, unpacked to a folder
  unpackedSpinnakerSrc = runCommand "unpack-spinnaker" { } ''
    tar -xvf ${spinnakerSrcTar} -C .

    mkdir -p $out
    folder=$(ls | grep spinnaker)
    cp -r $folder/* $out
  '';

  # The python SDK (wheel file, examples, etc), unpacked to a folder
  unpackedSpinnakerPythonSrc = runCommand "unpack-spinnaker-python" { } ''
    mkdir -p $out
    tar -xvf ${spinnakerPythonSrcTar} -C $out
    ls $out
  '';

  buildSdkDeb = { libname, name, extraDeps ? [ ] }: stdenv.mkDerivation
    rec {
      # Required fields for a derivation
      inherit name;

      src = unpackedSpinnakerSrc;

      nativeBuildInputs = [
        autoPatchelfHook
      ];

      buildInputs = [
        dpkg

        # Libs to patch to
        stdenv.cc.cc.lib
        libusb
        libz
        ffmpeg_4
      ] ++ extraDeps;

      dontConfigure = true;
      dontBuild = true;

      # Copy all files to relevant $out directories, mainly /lib
      installPhase = ''
        runHook preInstall

        debfile=$(ls | grep ${libname}_)
        echo Unpacking $debfile

        dpkg-deb -x $debfile .

        mkdir -p $out
        mkdir -p $out/lib

        cp -R usr/share opt $out/
        cp opt/spinnaker/lib/* $out/lib/

        runHook postInstall
      '';
    };

  spinnaker = buildSdkDeb {
    libname = "libspinnaker";
    name = "spinnaker";
  };

  spin-update = buildSdkDeb {
    libname = "spinupdate";
    name = "spinUpdate";
  };

  spin-video = buildSdkDeb {
    libname = "libspinvideo";
    name = "spinVideo";
    extraDeps = [
      spinnaker
    ];
  };

  # Extract the cti file from the deb
  spinnaker-cti = stdenv.mkDerivation
    rec {
      name = "spinnaker-cti";

      src = unpackedSpinnakerSrc;

      buildInputs = [ dpkg ];

      dontConfigure = true;
      dontBuild = true;

      # Copy all files to relevant $out directories, mainly /lib
      installPhase = ''
        runHook preInstall

        debfile=$(ls | grep libgentl_)
        echo Unpacking $debfile

        dpkg-deb -x $debfile libgentl

        mkdir -p $out
        mkdir -p $out/lib

        cp libgentl/opt/spinnaker/lib/spinnaker-gentl/* $out/

        runHook postInstall
      '';
    };

  # Build the python module
  spinnaker-python = stdenv.mkDerivation {
    pname = "spinnaker-python";
    inherit version;

    src = unpackedSpinnakerPythonSrc;

    nativeBuildInputs = [
      autoPatchelfHook
    ];

    buildInputs = [
      python310Packages.wheel
      spinnaker
      spin-update
      spin-video
    ];

    dontBuild = true;
    dontConfigure = true;

    installPhase = ''
      runHook preInstall

      wheelfile=$(ls | grep ".whl")

      wheel unpack $wheelfile -d .
      unpackeddir=$(ls -d */ | grep spinnaker_python)

      # Python packages in nixos are installed to $out/lib/$python/site-packages
      sitePackagesDir=$out/lib/python3.10/site-packages/
      mkdir -p $sitePackagesDir

      cp -r $unpackeddir/* $sitePackagesDir
      ls $sitePackagesDir

      runHook postInstall
    '';
  };
in
rec {
  inherit spinnaker spin-update spin-video spinnaker-cti spinnaker-python310;

  spinnaker-cti-path = "${spinnaker-cti}/Spinnaker_GenTL.cti";
}
