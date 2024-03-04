final: prev: {
  spinnaker = final.callPackage ./spinnaker { };
  spinnaker-acquisition = final.callPackage ./spinnaker-acquisition { };
  jax-test = final.callPackage ./jax-test { };
  cudaPackagesGoogle = nvidia-jetpack.cudaPackages;
}
