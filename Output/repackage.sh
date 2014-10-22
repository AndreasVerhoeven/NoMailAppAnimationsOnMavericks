#!/bin/sh


#based on http://blog.coolaj86.com/articles/how-to-unpackage-and-repackage-pkg-osx.html

CWD=$(pwd)

echo "Unpacking"
rm -r /tmp/Package.unpkg 2> /dev/null
pkgutil --expand Source/Template.pkg /tmp/Package.unpkg

echo "Extracting"
rm -r /tmp/Package-inner.pkg 2> /dev/null
mkdir /tmp/Package-inner.pkg
cd /tmp/Package-inner.pkg/
cat /tmp/Package.unpkg/avenoanimationsinmailplugin.pkg/Payload | gzip -d | cpio -id

# copying files
echo "Copying files"
cp -r $CWD/AveNoAnimationsInMailPlugin.mailbundle /tmp/Package-inner.pkg/

rm /tmp/Package.unpkg/avenoanimationsinmailplugin.pkg/Payload
rm /tmp/Package.unpkg/avenoanimationsinmailplugin.pkg/Bom

echo "Recreating Payload and BOM"
find . | cpio -o --format odc | gzip -c > /tmp/Package.unpkg/avenoanimationsinmailplugin.pkg/Payload
mkbom /tmp/Package-inner.pkg/ /tmp/Package.unpkg/avenoanimationsinmailplugin.pkg/Bom

echo "\nCounting filesize and files"
NUMKBYTES=$(du -sk /tmp/Package-inner.pkg/ | tr -d ' ' | cut -f1)
NUMFILES=$(find /tmp/Package-inner.pkg/ | wc -l | tr -d ' ')

find /tmp/Package-inner.pkg/ | wc -l
echo "$NUMFILES files, $NUMKBYTES kb"

sed -i '' -e 's/installKBytes="[-0-9]*"/installKBytes="'$NUMKBYTES'"/' /tmp/Package.unpkg/avenoanimationsinmailplugin.pkg/PackageInfo
sed -i '' -e 's/numberOfFiles="[-0-9]*"/numberOfFiles="'$NUMFILES'"/' /tmp/Package.unpkg/avenoanimationsinmailplugin.pkg/PackageInfo

pkgutil --flatten /tmp/Package.unpkg/ $CWD/DisableMailAnimationsForOSX.pkg

rm -r /tmp/Package.unpkg 2> /dev/null
rm -r /tmp/Package-inner.pkg 2> /dev/null

echo "repackaged"
