#!/bin/sh

BIN=/usr/bin
CONFIGS=/etc/noobzvpns
SYSTEMD=/etc/systemd/system
SYSTEMCTL=$(which systemctl)
RESOURCES=`$(which dirname) "$0"`
MACHINE=`$(which uname) "-m"`
BINARY_ARCH=""

if [ `id -u` != "0" ]; then
    echo "Error at installation, please run installer as root"
    exit 1
fi

case $MACHINE in
    "x86_64")
        BINARY_ARCH="noobzvpns.x86_64"
        ;;
    *)
        echo "Error at installation, unsuported cpu-arch $MACHINE"
        exit 1
        ;;
esac

echo "CPU-Arch: $MACHINE, Binary: $BINARY_ARCH"

if [ ! -d $SYSTEMD ]; then
    echo "Error at installation, no systemd directory found. make sure your distro using systemd as default init"
    exit 1
fi

if [ ! -f $SYSTEMCTL ]; then
    echo "Error at installation, no systemctl binary found. make sure your distro using systemd as default init"
    exit 1
fi

echo "Preparing upgrade/install..."
if [ -f $SYSTEMD/noobzvpns.service ]; then
    $SYSTEMCTL daemon-reload
    $SYSTEMCTL stop noobzvpns.service
    $SYSTEMCTL disable noobzvpns.service
    rm $SYSTEMD/noobzvpns.service
fi
if [ -f $BIN/noobzvpns ]; then
    rm $BIN/noobzvpns
fi
if [ -f $CONFIGS/cert.pem ]; then
    rm $CONFIGS/cert.pem
fi
if [ -f $CONFIGS/key.pem ]; then
    rm $CONFIGS/key.pem
fi

echo "Copying binary files..."
if [ ! -d $CONFIGS ]; then
    mkdir $CONFIGS
fi
cp $RESOURCES/$BINARY_ARCH $BIN/noobzvpns
cp $RESOURCES/cert.pem $CONFIGS/cert.pem
cp $RESOURCES/key.pem $CONFIGS/key.pem
cp $RESOURCES/noobzvpns.service $SYSTEMD/noobzvpns.service
if [ ! -f $CONFIGS/config.json ]; then
    cp $RESOURCES/config.json $CONFIGS/config.json
fi

echo "Setting files permission..."
chmod 700 $BIN/noobzvpns
chmod 600 $CONFIGS/cert.pem
chmod 600 $CONFIGS/config.json
chmod 600 $CONFIGS/key.pem
chmod 600 $SYSTEMD/noobzvpns.service

echo "Finishing upgrade/install..."
$SYSTEMCTL daemon-reload
$SYSTEMCTL start noobzvpns.service
$SYSTEMCTL enable noobzvpns.service

echo "Install Noobzvpns Completed."