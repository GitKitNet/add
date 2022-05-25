#!/bin/bash

mkdir -p "$(pwd)/bash"
wget -O Shttps://raw.githubusercontent.com/numbnet/WebPanel/master/snipets/setup_dev_tool/index.sh

# Ensure we are running under bash
if [ "$BASH_SOURCE" = "" ]; then
    /bin/bash "$0"
    exit 0
fi

#
# Load bash-menu script
#
# NOTE: Ensure this is done before using
#       or overriding menu functions/variables.
#
wget "$(pwd)/bash/bash-menu.sh" "https://raw.githubusercontent.com/numbnet/WebPanel/master/snipets/setup_dev_tool/bash/bash-menu.sh"
chmod +x $(echo "$(pwd)/bash/"*.sh )
. "$(pwd)/bash/bash-menu.sh"

################################
## Run Menu
################################
menuMainInit
menuLoop menuMain menuMainItems menuMainActions

exit 0
