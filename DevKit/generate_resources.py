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

# copy and convert symbol_categories.plist to xml1
src_symbol_categories_plist_path = f"{src_metadata_path}/symbol_categories.plist"
dst_symbol_categories_plist_path = f"{parent_path}/SFSymbolsPreview/Resources/symbol_categories.plist"
os.system(f"cp {src_symbol_categories_plist_path} {dst_symbol_categories_plist_path}")
os.system(f"plutil -convert xml1 {dst_symbol_categories_plist_path}")

# copy legacy_aliases.strings to legacy_aliases_strings.txt
src_legacy_aliases_strings_path = f"{src_metadata_path}/legacy_aliases.strings"
dst_legacy_aliases_strings_path = f"{parent_path}/SFSymbolsPreview/Resources/legacy_aliases_strings.txt"
os.system(f"cp {src_legacy_aliases_strings_path} {dst_legacy_aliases_strings_path}")

# copy name_aliases.strings to name_aliases_strings.txt
src_name_aliases_strings_path = f"{src_metadata_path}/name_aliases.strings"
dst_name_aliases_strings_path = f"{parent_path}/SFSymbolsPreview/Resources/name_aliases_strings.txt"
os.system(f"cp {src_name_aliases_strings_path} {dst_name_aliases_strings_path}")

# copy colors.csv
src_colors_csv_path = f"{src_app_path}/Frameworks/SFSymbolsKit.framework/Versions/A/Frameworks/SFSymbolsShared.framework/Versions/A/Resources/colors.csv"
src_colors_csv_path = f"{src_app_path}/Frameworks/SFSymbolsKit.framework/Versions/A/Frameworks/SFSymbolsShared.framework/Versions/A/Resources/colors.csv"
dst_colors_csv_path = f"{parent_path}/SFSymbolsPreview/Resources/colors.csv"
os.system(f"cp {src_colors_csv_path} {dst_colors_csv_path}")

# copy SymbolVariantScripts.csv to symbol_variant_scripts.csv
src_symbol_variant_scripts_csv_path = f"{src_app_path}/Frameworks/SFSymbolsKit.framework/Versions/A/Frameworks/SFSymbolsShared.framework/Versions/A/Resources/SymbolVariantScripts.csv"
dst_symbol_variant_scripts_csv_path = f"{parent_path}/SFSymbolsPreview/Resources/symbol_variant_scripts.csv"
os.system(f"cp {src_symbol_variant_scripts_csv_path} {dst_symbol_variant_scripts_csv_path}")

# convert symbol_variant_scripts.csv to symbol_variant_scripts.json
# Script,Extension

# convert csv to json
import csv
import json

csv_file = open(dst_symbol_variant_scripts_csv_path, 'r')   
csv_reader = csv.DictReader(csv_file)

json_data = dict()
for row in csv_reader:
    json_data[row['Extension']] = row['Script']

json_file = open(f"{parent_path}/SFSymbolsPreview/Resources/symbol_variant_scripts.json", "w")
json.dump(json_data, json_file, indent=4, sort_keys=True)

# generate symbols.plist from symbol_categories.plist
import plistlib

with open(dst_symbol_categories_plist_path, 'rb') as dst_symbol_categories_plist_file:
    symbol_categories_plist = plistlib.loads(dst_symbol_categories_plist_file.read())

symbols_plist = list(symbol_categories_plist.keys())
dst_symbols_plist_path = f"{parent_path}/SFSymbolsPreview/Resources/symbols.plist"
with open(dst_symbols_plist_path, 'wb') as dst_symbols_plist_file:
    plistlib.dump(symbols_plist, dst_symbols_plist_file)
