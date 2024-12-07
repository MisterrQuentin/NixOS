{pkgs}: let
  # For CUDA support
  cudaEnv = {
    CUDA_PATH = "${pkgs.cudaPackages.cudatoolkit}";
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
      "${pkgs.cudaPackages.cudatoolkit}/lib"
      "${pkgs.cudaPackages.cudnn}/lib"
    ];
  };
in {
  basePython = pkgs.python312.withPackages (ps:
    with ps; [
      # LSP and development tools
      pip
      python-lsp-server
      pylint
      black

      # Additional development tools
      pytest

      # Common libraries
      requests
      python-dateutil

      # Qt-related packages
      pyqt5
      pyqtwebengine
    ]);

  qtodotxtPython = pkgs.python312.withPackages (ps:
    with ps; [
      pyqt5
      python-dateutil
      pyqtwebengine
    ]);

  comfyuiPython = pkgs.python311.withPackages (ps:
    with ps; [
      pip
      virtualenv
      # Basic requirements
      numpy
      pillow
      opencv4
      aiohttp
      tqdm
      # Add gcc and other system libraries
      pkgs.stdenv.cc.cc.lib
    ]);
}
