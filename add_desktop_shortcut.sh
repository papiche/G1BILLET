#!/bin/bash
################################################################################
# Author: Fred (support@qo-op.com)
# Version: 0.1
# License: AGPL-3.0 (https://choosealicense.com/licenses/agpl-3.0/)
################################################################################
MY_PATH="`dirname \"$0\"`"              # relative
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized
ME="${0##*/}"

[[ -d ~/Bureau ]] && sed "s/_USER_/$USER/g" ${MY_PATH}/g1billet.desktop > ~/Bureau/g1billet.desktop && chmod +x ~/Bureau/g1billet.desktop
[[ -d ~/Desktop ]] && sed "s/_USER_/$USER/g" ${MY_PATH}/g1billet.desktop > ~/Desktop/g1billet.desktop && chmod +x ~/Desktop/g1billet.desktop
