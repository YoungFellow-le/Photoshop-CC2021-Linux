#!/bin/bash

echo -e "**************\nStarting PS installer...\n"
sleep 1

cameraraw=1
echo -e "**************\nWould you like to install Adobe Camera Raw at the end?"
read -p "(1 - Yes, 0 - No): " cameraraw
sleep 1

vdk3d=1
echo -e "**************\nWould you like to install vdk3d proton?"
read -p "(1 - Yes, 0 - No): " vdk3d
sleep 1

echo -e "**************\nMaking PS prefix...\n"
sleep 1
rm -rf $PWD/PS-Prefix
mkdir $PWD/PS-Prefix/
sleep 1

echo -e "**************\nDownloading winetricks and making executable if not already so...\n"
sleep 1
wget -nc https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
chmod +x winetricks
sleep 1

echo -e "**************\nDownloading Photoshop, CameraRaw, and allredist files if not already downloaded...\n"
sleep 1

mkdir installers

if ! [ -f installers/allredist.tar.xz ]; then
curl -L "https://drive.google.com/uc?export=download&id=1qcmyHzWerZ39OhW0y4VQ-hOy7639bJPO" > installers/allredist.tar.xz
else
echo -e "\nThe file allredist.tar.xz exists\n"
fi

if ! [ -f installers/AdobePhotoshop2021.tar.xz ]; then
curl -L "https://lulucloud.mywire.org/FileHosting/GithubProjects/AdobePhotoshop2021.tar.xz" > installers/AdobePhotoshop2021.tar.xz
else
echo -e "\nThe file AdobePhotoshop2021.tar.xz exists\n"
fi

if ! [ -f installers/CameraRaw_12_2_1.exe ]; then
curl -L "https://download.adobe.com/pub/adobe/photoshop/cameraraw/win/12.x/CameraRaw_12_2_1.exe" > installers/CameraRaw_12_2_1.exe
else
echo -e "\nThe file CameraRaw_12_2_1.exe exists\n"
fi
sleep 1


echo -e "**************\nExtracting files...\n"
sleep 1
rm -fr installers/allredist
rm -fr "installers/Adobe Photoshop 2021"
tar -xf installers/AdobePhotoshop2021.tar.xz
mkdir installers/allredist
tar -xf installers/allredist.tar.xz
sleep 1


echo -e "**************\nBooting & creating new prefix\n"
sleep 1
WINEPREFIX=$PWD/PS-Prefix/ wineboot
sleep 1

echo -e "**************\nSetting win version to win10\n"
sleep 1
WINEPREFIX=$PWD/PS-Prefix/ ./winetricks win10
sleep 1

echo -e "**************\nInstalling & configuring winetricks components...\n"
WINEPREFIX=$PWD/PS-Prefix/ ./winetricks fontsmooth=rgb gdiplus msxml3 msxml6 atmlib corefonts dxvk
sleep 1

echo -e "**************\nInstalling redist components...\n"
sleep 1
WINEPREFIX=$PWD/PS-Prefix/ wine installers/allredist/redist/2010/vcredist_x64.exe /q /norestart
WINEPREFIX=$PWD/PS-Prefix/ wine installers/allredist/redist/2010/vcredist_x86.exe /q /norestart
WINEPREFIX=$PWD/PS-Prefix/ wine installers/allredist/redist/2012/vcredist_x86.exe /install /quiet /norestart
WINEPREFIX=$PWD/PS-Prefix/ wine installers/allredist/redist/2012/vcredist_x64.exe /install /quiet /norestart
WINEPREFIX=$PWD/PS-Prefix/ wine installers/allredist/redist/2013/vcredist_x86.exe /install /quiet /norestart
WINEPREFIX=$PWD/PS-Prefix/ wine installers/allredist/redist/2013/vcredist_x64.exe /install /quiet /norestart
WINEPREFIX=$PWD/PS-Prefix/ wine installers/allredist/redist/2019/VC_redist.x64.exe /install /quiet /norestart
WINEPREFIX=$PWD/PS-Prefix/ wine installers/allredist/redist/2019/VC_redist.x86.exe /install /quiet /norestart
sleep 1


if [ $vdk3d = "1" ]
then
echo -e "**************\nInstalling vdk3d proton...\n"
sleep 1
WINEPREFIX=$PWD/PS-Prefix/ sh installers/allredist/setup_vkd3d_proton.sh install
sleep 1
fi

echo -e "**************\nMaking PS directory and copying files...\n"
sleep 1
mkdir $PWD/PS-Prefix/drive_c/Program\ Files/Adobe
cp installers/Adobe\ Photoshop\ 2021 $PWD/PS-Prefix/drive_c/Program\ Files/Adobe/Adobe\ Photoshop\ 2021
sleep 1

echo -e "**************\nCopying launcher files...\n"

sleep 1
prefix=$PWD/PS-Prefix
pwd=$PWD
cp installers/allredist/photoshop.png .photoshop.png
echo -e "#\!/bin/bash\ncd $PWD/PS-Prefix/drive_c\nWINEPREFIX=\"$prefix\" wine64 \"$pwd/PS-Prefix/drive_c/Program Files/Adobe/Adobe Photoshop 2021/photoshop.exe\"" >> .launcher.sh
chmod +x .launcher.sh
echo -e "[Desktop Entry]\nName=Photoshop CC\nExec=cd $PWD/PS-Prefix/drive_c && WINEPREFIX=\"$prefix\" wine64 \"$pwd/PS-Prefix/drive_c/Program Files/Adobe/Adobe Photoshop 2021/photoshop.exe\"\nType=Application\nComment=Photoshop CC 2021\nCategories=Graphics;2DGraphics;RasterGraphics;GTK;\nIcon=$PWD/.photoshop.png\nStartupWMClass=photoshop.exe\nMimeType=image/png;image/psd;image;" >> photoshop.desktop
chmod +x photoshop.desktop
mv photoshop.desktop ~/.local/share/applications/photoshop.desktop
rm -rf installers/allredist
sleep 1

if [ $cameraraw = "1" ]
then
echo -e "**************\nInstalling Adobe Camera Raw, please follow the instructions on the installer...\n"
sleep 1
WINEPREFIX=$PWD/PS-Prefix/ wine installers/CameraRaw_12_2_1.exe
sleep 1
fi

echo -e "**************\nAdobe Photoshop CC 2021 Installed!\n"
