{pkgs}: let
  cudaPackages = pkgs.cudaPackages_12_4; # Use CUDA 12.4 as recommended
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
      numpy
      pillow
      opencv4
      pkgs.ffmpeg
      aiohttp
      tqdm
      pygobject3
      pyyaml
      gitpython
    ]);
}
