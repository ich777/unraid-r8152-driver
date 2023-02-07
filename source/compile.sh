# Clone repository and get latest commit
git clone https://github.com/wget/realtek-r8152-linux
cd ${DATA_DIR}/realtek-r8152-linux
PLUGIN_VERSION="$(git log -1 --format="%cs" | sed 's/-//g')"
git checkout master

# Compile Kernel Module and move it to a temporary directory
make -j$(nproc --all)
mkdir -p /r8152/lib/modules/${UNAME}/kernel/drivers/net/usb/
cp ${DATA_DIR}/realtek-r8152-linux/r8152.ko /r8152/lib/modules/${UNAME}/kernel/drivers/net/usb/

# Compress module
while read -r line
do
  xz --check=crc32 --lzma2 $line
done < <(find /r8152/lib/modules/${UNAME}/kernel/drivers/net/usb/ -name "*.ko")

# Create Slackware package
PLUGIN_NAME="r8152"
BASE_DIR="/r8152"
TMP_DIR="/tmp/${PLUGIN_NAME}_"$(echo $RANDOM)""
VERSION="$(date +'%Y.%m.%d')"

mkdir -p $TMP_DIR/$VERSION
cd $TMP_DIR/$VERSION
cp -R $BASE_DIR/* $TMP_DIR/$VERSION/
mkdir $TMP_DIR/$VERSION/install
tee $TMP_DIR/$VERSION/install/slack-desc <<EOF
       |-----handy-ruler------------------------------------------------------|
$PLUGIN_NAME: $PLUGIN_NAME OOT driver built from latest branch
$PLUGIN_NAME:
$PLUGIN_NAME: Source: https://github.com/wget/realtek-r8152-linux
$PLUGIN_NAME:
$PLUGIN_NAME: Custom $PLUGIN_NAME driver package for Unraid Kernel v${UNAME%%-*} by ich777
$PLUGIN_NAME:
EOF
${DATA_DIR}/bzroot-extracted-$UNAME/sbin/makepkg -l n -c n $TMP_DIR/$PLUGIN_NAME-$PLUGIN_VERSION-$UNAME-1.txz
md5sum $TMP_DIR/$PLUGIN_NAME-$PLUGIN_VERSION-$UNAME-1.txz | awk '{print $1}' > $TMP_DIR/$PLUGIN_NAME-$PLUGIN_VERSION-$UNAME-1.txz.md5