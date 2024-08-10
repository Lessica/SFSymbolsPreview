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

# copy and convert symbol_search.plist to xml1
src_symbol_search_plist_path = f"{src_metadata_path}/symbol_search.plist"
dst_symbol_search_plist_path = f"{parent_path}/SFSymbolsPreview/Resources/symbol_search.plist"
os.system(f"cp {src_symbol_search_plist_path} {dst_symbol_search_plist_path}")
os.system(f"plutil -convert xml1 {dst_symbol_search_plist_path}")

# copy and convert layerset_availability.plist to xml1
src_layerset_availability_plist_path = f"{src_metadata_path}/layerset_availability.plist"
dst_layerset_availability_plist_path = f"{parent_path}/SFSymbolsPreview/Resources/layerset_availability.plist"
os.system(f"cp {src_layerset_availability_plist_path} {dst_layerset_availability_plist_path}")
os.system(f"plutil -convert xml1 {dst_layerset_availability_plist_path}")

# copy and convert name_availability.plist to xml1
src_name_availability_plist_path = f"{src_metadata_path}/name_availability.plist"
dst_name_availability_plist_path = f"{parent_path}/SFSymbolsPreview/Resources/name_availability.plist"
os.system(f"cp {src_name_availability_plist_path} {dst_name_availability_plist_path}")
os.system(f"plutil -convert xml1 {dst_name_availability_plist_path}")