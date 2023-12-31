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
if find dists -mindepth 3 -maxdepth 3 -type d | grep -v '/main/binary-all' ; then
    echo ' ---   only main/all suported'
    exit 1
else
    echo " ---   ok"
fi 

for P in $(find dists -mindepth 3 -maxdepth 3 -type d) ; do 
    echo " --- path $P"
    DIST=$(echo $P | awk -F'/' '{print $2}')
    echo " ---   dist $DIST"
    echo " ---   packages"
    dpkg-scanpackages $P >$P/Packages
    I="dists/$DIST/InRelease"
    echo " ---   in-release $I"
    echo "Suite: $DIST" >$I
    echo "Components: main" >>$I
    echo "Architectures: all" >>$I
    echo "Date: $DATE" >>$I
    echo "SHA256:" >>$I
    S=$(stat -c'%s' $P/Packages)
    H=$(sha256sum $P/Packages | awk '{print $1}')
    echo " $H $S main/binary-all/Packages" >>$I 
    cd $(dirname $I)
    ln -s InRelease Release
    cd -
done


