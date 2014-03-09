#!/bin/bash
set -ex
#
VERS=`defaults read "$BUILT_PRODUCTS_DIR/$PROJECT_NAME.app/Contents/Info" CFBundleVersion`
/usr/bin/curl --ftp-pasv -u reservoi-wil:frack666 -T "{\
$BUILT_PRODUCTS_DIR"/"$PROJECT_NAME"_www/"$PROJECT_NAME"_"$VERS"/"$VERS".html",\
$BUILT_PRODUCTS_DIR"/"$PROJECT_NAME"_www/"$PROJECT_NAME"_"$VERS"/rnotes.css"\
}" \
ftp://ftp.wills-portal.com/apps/$PROJECT_NAME/archives/
exit 0
