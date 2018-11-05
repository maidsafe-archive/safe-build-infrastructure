choco install -y msys2 --params="/InstallDir:c:\msys64"

set PATH=%PATH%;c:\msys64\mingw64\bin;c:\msys64\usr\bin
setx PATH "%PATH%;c:\msys64\mingw64\bin;c:\msys64\usr\bin"

pacman -S --noconfirm --needed mingw-w64-x86_64-gcc
pacman -S --noconfirm git
