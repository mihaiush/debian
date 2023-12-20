#!/bin/bash

cd $(dirname $0)

DATE=$(date -R -u)

echo " --- Delete old packages"
find dists -name 'Packages*' -type f -print -delete
echo

echo " --- Delete old releases"
find dists -name '*Release*' -type f -print -delete
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
    R=$P/Release
    echo " ---   release $R"
    echo "Suite: $DIST" >$R
    echo "Components: main" >>$R
    echo "Architectures: all" >>$R
    echo "Date: $DATE" >>$R
    I="dists/$DIST/InRelease"
    echo " ---   in-release $I"
    cp $R $I
    echo "SHA256:" >>$I
    S=$(stat -c'%s' $R)
    H=$(sha256sum $R | awk '{print $1}')
    echo " $H $S main/binary-all/Release" >>$I
    S=$(stat -c'%s' $P/Packages)
    H=$(sha256sum $P/Packages | awk '{print $1}')
    echo " $H $S main/binary-all/Packages" >>$I
done


