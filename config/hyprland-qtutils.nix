{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, qt6
, hyprland
, pciutils
}:

stdenv.mkDerivation rec {
  pname = "hyprland-qtutils";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "hyprwm";
    repo = "hyprland-qtutils";
    rev = "main";
    sha256 = "sha256-TnuKsa8OHrSJEmHm3TLGOWbPNA1gRjmZLsRzKrCqOsg=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtsvg
    qt6.qtwayland
    pciutils
  ];

  meta = with lib; {
    description = "Hyprland QT/qml utility apps";
    homepage = "https://github.com/hyprwm/hyprland-qtutils";
    license = licenses.bsd3;
    platforms = platforms.linux;
    mainProgram = "hyprland-qtutils";
  };
}

