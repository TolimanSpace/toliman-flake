final: prev: rec {
  toliman = {
    spinnaker = final.callPackage ./spinnaker { };
    spinnaker-acquisition = final.callPackage ./spinnaker-acquisition { };
    jax-test = final.callPackage ./jax-test { };
  };

  cudaPackages =
    final.nvidia-jetpack.cudaPackages // {
      backendStdenv = final.stdenv // {
        nixpkgsCompatibleLibstdcxx = final.buildPackages.gcc.cc.lib;
      };
      autoAddOpenGLRunpathHook = prev.cudaPackages_11_4.autoAddOpenGLRunpathHook;
      cudaFlags = prev.cudaPackages_11_4.cudaFlags;

      cudaVersion = final.nvidia-jetpack.cudaVersion;

      cudatoolkit = final.nvidia-jetpack.cudaPackages.cudatoolkit // {
        out = final.nvidia-jetpack.cudaPackages.cudatoolkit;
        lib = final.nvidia-jetpack.cudaPackages.cudatoolkit;
      };

      cuda_nvcc = final.nvidia-jetpack.cudaPackages.cuda_nvcc // {
        out = final.nvidia-jetpack.cudaPackages.cuda_nvcc;
        lib = final.nvidia-jetpack.cudaPackages.cuda_nvcc;
        dev = final.nvidia-jetpack.cudaPackages.cuda_nvcc;
      };

      nccl = prev.cudaPackages_11_4.nccl.override {
        inherit cudaPackages;
      };
    };

  cudaPackagesGoogle = cudaPackages;
}
