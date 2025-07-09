#!/bin/bash

git clone -b anyong https://code.anyong.com.tw/ay/v4/quick-start/kde-env/cli.git

cd cli
sudo ./install.sh
cd ..
rm -rf cli
