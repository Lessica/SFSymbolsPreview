#!/usr/bin/env python3

import os
import pathlib

# chdir to parent dir
os.chdir(pathlib.Path(__file__).parent)

# generate resources
src_app_path = "/Applications/SF Symbols.app/Contents"

# copy version.plist
src_version_plist_path = f"{src_app_path}/version.plist"
dst_version_plist_path = f"SFSymbolsPreview/Resources/version.plist"