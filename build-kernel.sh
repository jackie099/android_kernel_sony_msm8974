#!/bin/bash

#    Copyleft (C) 2013  Louis Teboul (a.k.a Androguide)
#
#    admin@pimpmyrom.org  || louisteboul@gmail.com
#    http://pimpmyrom.org || http://androguide.fr
#    71 quai Clémenceau, 69300 Caluire-et-Cuire, FRANCE.
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License along
#    with this program; if not, write to the Free Software Foundation, Inc.,
#    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


####################################################
## Example: ./build-kernel.sh --honami --f2fs -j9 ##
####################################################
CYAN="\\033[1;36m"
GREEN="\\033[1;32m"
YELLOW="\\E[33;44m"
RED="\\033[1;31m"
RESET="\\e[0m"
DEVICE="honami"
THREADS="9"
FS="ext4"
DATE=`date +%Y%m%d_%H%M`

set -e

# Device selection
if [ -z "$1" ]
  then
    echo -n -e "\n${RED}You can specify the device to build for with an argument (e.g: ./build-kernel.sh --honami)${RESET}\n\n"
    echo -n -e "${CYAN}Please input the codename of the device you're building for ${YELLOW}(honami / amami)${RESET}${CYAN} : ${RESET}\n"
    read device
    DEVICE=${device}
else
    DEVICE=$1
    DEVICE=${DEVICE:2}
    echo -n -e "${GREEN}Building for ${YELLOW}${DEVICE}${RESET}\n"
fi

# File-system selection
if [ -z "$2" ]
  then
    echo -n -e "\n${RED}You can specify the file-system to use with an argument (e.g: ./build-kernel.sh --ext4)${RESET}\n\n"
    echo -n -e "${CYAN}Which file-system to use ? ${YELLOW}(ext4 / f2fs)${RESET}${CYAN} : ${RESET}\n"
    read fs
    FS=${fs} 
else
    FS=$2
    FS=${FS:2}
    echo -n -e "${GREEN}Building with the ${YELLOW}${FS}${RESET}${GREEN} file-system...${RESET}\n"
fi

# Amount of CPU threads to build with
if [ -z "$3" ]
  then
    echo -n -e "\n${RED}You can specify the amount of CPU threads to use with an argument (e.g: ./build-kernel.sh -j8)${RESET}\n\n"
    echo -n -e "${CYAN}How many CPU threads to use ?${RESET}\n"
    read threads
    THREADS=${threads}
else
    THREADS=$3
    echo -n -e "${GREEN}Building with ${YELLOW}${THREADS:2}${RESET}${GREEN} CPU threads...${RESET}\n"
fi


# Use the right fstab depending on the file-system selection
rm -f ../../../device/sony/rhine-common/rootdir/fstab.qcom
cp -f ../../../device/sony/rhine-common/rootdir/fstab.qcom.${FS} ../../../device/sony/rhine-common/rootdir/fstab.qcom

# Build the kernel
cd ../../../
. build/envsetup.sh
lunch cm_${DEVICE}-userdebug
mka bootimage -j${threads}

# Add boot.img and wlan.ko to the flashable zip
mkdir -p tmp-dir/system/lib/modules
cp -f ${OUT_DIR_COMMON_BASE}/${PWD##*/}/target/product/${DEVICE}/boot.img tmp-dir/boot.img
cp -f ${OUT_DIR_COMMON_BASE}/${PWD##*/}/target/product/${DEVICE}/system/lib/modules/wlan.ko tmp-dir/system/lib/modules/wlan.ko
cp -f kernel/sony/msm8974/placeholder.zip tmp-dir/placeholder.zip
cd tmp-dir
zip -u placeholder.zip boot.img
zip -u placeholder.zip system/lib/modules/wlan.ko
cd ../
mv -f tmp-dir/placeholder.zip ${OUT_DIR_COMMON_BASE}/${PWD##*/}/target/product/${DEVICE}/Pimped-Kernel-${DEVICE}-${FS}-${DATE}.zip

# Clean-up
rm -rf tmp-dir
cd kernel/sony/msm8974

echo -n -e "${GREEN}Made flashable package:${RESET} ${YELLOW}Pimped-Kernel-${DEVICE}-${FS}-${DATE}.zip${RESET}\n"

