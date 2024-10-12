#!/bin/bash
################################################################################
# Author: Fred (support@qo-op.com)
# Version: 0.1
# License: AGPL-3.0 (https://choosealicense.com/licenses/agpl-3.0/)
################################################################################
MY_PATH="`dirname \"$0\"`"              # relative
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized
ME="${0##*/}"

echo "#############################################"
echo ">>>>>>>>>>> SYSTEMD SETUP  "
echo "#############################################"

echo "CREATE SYSTEMD g1billet SERVICE >>>>>>>>>>>>>>>>>>"
cat > /tmp/g1billet.service <<EOF
[Unit]
Description=G1BILLET API
After=network.target
Requires=network.target

[Service]
Type=simple
User=_USER_
RestartSec=1
Restart=always
ExecStart=_MYPATH_/G1BILLETS.sh daemon

[Install]
WantedBy=multi-user.target
EOF

sudo cp -f /tmp/g1billet.service /etc/systemd/system/
sudo sed -i "s~_USER_~${USER}~g" /etc/systemd/system/g1billet.service
sudo sed -i "s~_MYPATH_~${MY_PATH}~g" /etc/systemd/system/g1billet.service

sudo systemctl daemon-reload
sudo systemctl enable g1billet
sudo systemctl restart g1billet

