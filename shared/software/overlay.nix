final: prev: {
  spinnaker = final.callPackage ./spinnaker { };
  spinnaker-acquisition = final.callPackage ./spinnaker-acquisition { };
}
