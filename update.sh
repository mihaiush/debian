#!/bin/bash -e

cd $(dirname $0)

if [ -z "$1" ] ; then
    echo $(basename $0) DEB_FOLDER
    exit 2
fi

. $1/config

git pull

ls -1 $1/*.deb | while read D ; do
    P=$(basename $D|awk -F'_' '{print $1}')
    rm -fv dists/$DIST/main/binary-all/${P}_*
    cp -v $D dists/$DIST/main/binary-all/
done

./make-repo.sh

git add .
git commit -a -m "Update from ${1}"
git push

