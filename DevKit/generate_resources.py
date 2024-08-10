#!/usr/bin/env python3

import os
import pathlib

# chdir to parent dir
parent_path = pathlib.Path(__file__).parent.parent
os.chdir(parent_path)

# generate resources
src_app_path = "/Applications/SF\\ Symbols.app/Contents"

# copy and convert version.plist to xml1
src_version_plist_path = f"{src_app_path}/version.plist"
dst_version_plist_path = f"{parent_path}/SFSymbolsPreview/Resources/version.plist"
os.system(f"cp {src_version_plist_path} {dst_version_plist_path}")
os.system(f"plutil -convert xml1 {dst_version_plist_path}")

src_metadata_path = "/Applications/SF\\ Symbols.app/Contents/Resources/Metadata"

# copy and convert categories.plist to xml1
src_categories_plist_path = f"{src_metadata_path}/categories.plist"
dst_categories_plist_path = f"{parent_path}/SFSymbolsPreview/Resources/categories.plist"
os.system(f"cp {src_categories_plist_path} {dst_categories_plist_path}")
os.system(f"plutil -convert xml1 {dst_categories_plist_path}")
