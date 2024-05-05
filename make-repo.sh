#!/bin/bash

cd $(dirname $0)

DATE=$(date -R -u)

echo " --- Delete old packages"
find dists -name 'Packages*' -type f -print -delete
echo

echo " --- Delete old releases"
find dists -name '*Release*' -print -delete
echo


echo " --- Distributions"

echo " ---   check folder structure"
if find dists -mindepth 3 -maxdepth 3 -type d | grep -vE '/main/binary-(amd64|armhf)' ; then
    echo ' ---   only main/(amd64|armhf) suported'
    exit 1
else
    echo " ---   ok"
fi 

for P in $(find dists -mindepth 3 -maxdepth 3 -type d) ; do 
    echo " --- path $P"
    DIST=$(echo $P | awk -F'/' '{print $2}')
    ARCH=$(echo $P | awk -F'/' '{print $4}')
    echo " ---   dist $DIST"
    echo " ---   arch $ARCH"
    echo " ---   packages"
    dpkg-scanpackages $P >$P/Packages
    I="dists/$DIST/InRelease"
    if [ ! -f "$I" ] ; then
        echo " --- in-release $I"
        echo "Suite: $DIST" >$I
        echo "Components: main" >>$I
        echo "Architectures: amd64 arhhf" >>$I
        echo "Date: $DATE" >>$I
        echo "SHA256:" >>$I
        cd $(dirname $I)
        ln -s InRelease Release
        cd - >/dev/null
    fi
    S=$(stat -c'%s' $P/Packages)
    H=$(sha256sum $P/Packages | awk '{print $1}')
    echo " $H $S main/${ARCH}/Packages" >>$I 
done


