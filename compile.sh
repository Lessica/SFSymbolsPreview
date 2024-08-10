#!/bin/sh

set -e

cd "$(dirname "$0")"

rm -rf build || true
mkdir -p build/Payload
mkdir -p packages

xcodebuild clean build archive \
    -scheme SFSymbolsPreview \
    -workspace SFSymbolsPreview.xcworkspace \
    -sdk iphoneos \
    -destination 'generic/platform=iOS' \
    -archivePath SFSymbolsPreview \
    CODE_SIGNING_ALLOWED=NO \
    | xcbeautify

cd SFSymbolsPreview.xcarchive/Products/Applications
codesign --remove-signature SF\ Symbols.app
cd -
cd SFSymbolsPreview.xcarchive/Products
mv Applications Payload
zip -qr SFSymbolsPreview_Havoc.tipa Payload
7z a -tzip -mm=LZMA SFSymbolsPreview.tipa Payload
cd -
mkdir -p packages

mv SFSymbolsPreview.xcarchive/Products/SFSymbolsPreview_Havoc.tipa packages/SFSymbolsPreview_Havoc.tipa
mv SFSymbolsPreview.xcarchive/Products/SFSymbolsPreview.tipa packages/SFSymbolsPreview.tipa
