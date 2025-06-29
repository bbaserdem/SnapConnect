#! /usr/bin/env nix-shell
#! nix-shell -i bash -p python311 python311Packages.virtualenv

cd "$(dirname "$0")"
rm -rf venv
python3.11 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
deactivate
firebase deploy --only functions:auto_tag_image
