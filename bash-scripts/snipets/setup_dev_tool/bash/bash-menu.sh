#!/bin/bash

# Ensure we are running under bash (will not work under sh or dash etc)
if [ "$BASH_SOURCE" = "" ]; then
    echo "ERROR: bash-menu requires to be running under bash"
    exit 1
fi

# Load terminal drawing functions
mkdir -p "$(pwd)/bash"
wget -O "$(pwd)/bash/bash-draw.sh" "https://raw.githubusercontent.com/numbnet/WebPanel/master/snipets/setup_dev_tool/bash/bash-draw.sh"
wget -O "$(pwd)/bash/menuMain.sh" "https://raw.githubusercontent.com/numbnet/WebPanel/master/snipets/setup_dev_tool/bash/menuMain.sh"
chmod +x $(echo "$(pwd)/bash/"*.sh )

. "$(pwd)/bash/bash-draw.sh"
. "$(pwd)/bash/menuMain.sh"


################################
# Show Menu
################################
menuDisplay() {
    local -n menuD=$1
    local -n menuItemsD=$2
    local menuSize=$((menuD[menuItemCount]+2))
    local menuEnd=$((menuSize+menuD[menuTop]+1))

    drawClear
    drawColour ${menuD[menuColour]} ${menuD[menuHighlight]}

    # Menu header
    drawHighlightAt ${menuD[menuTop]} ${menuD[menuMargin]} "${menuD[menuHeaderText]}" 1

    # Menu (side) borders
    for row in $(seq 1 $menuSize); do
        drawSpecial "${menuD[menuBorderText]}" 1
    done

    # Menu footer
    drawHighlightAt $menuEnd ${menuD[menuMargin]} "${menuD[menuFooterText]}" 1

    # Menu items
    for index in $(seq 0 ${menuD[menuLastItem]}); do
        local top=$((menuD[menuTop]+index+2))
        local menuText=${menuItemsD[$index]}

        drawPlainAt $top ${menuD[menuLeft]} "$menuText"
    done
}

# Highlight menu item
menuHighlightItem() {
    local item=$1
    local topHL=$2
    local menuTextHL=$3
    local menuLeftHL=$4

    topHL=$((topHL+item+2))
    drawHighlightAt $topHL $menuLeftHL "$menuTextHL"
}

################################
# Wait for and process user input
################################
menuHandleInput() {
    local -n menuHI=$1
    local -n menuItemsHI=$2
    local choiceHI=$3
    local beforeHI=$4

    # Clear highlight old menu item
    if [[ $beforeHI -ne -1 ]]; then
        local topBefore=$((menuHI[menuTop]+beforeHI+2))
        local menuText=${menuItemsHI[$beforeHI]}

        drawPlainAt $topBefore ${menuHI[menuLeft]} "$menuText"
    fi

    # Highlight current menu item
    menuHighlightItem $choiceHI ${menuHI[menuTop]} "${menuItemsHI[$choiceHI]}" ${menuHI[menuLeft]}

    # Get keyboard input
    local key=""
    read -s -n1 key 2> /dev/null >&2

    # Handle known keys
    local escKey=`echo -en "\033"`

    if [[ ${#key} -eq 1 ]]; then
        # See if we wanrt to jump to a menu item
        # by entering the first character
        for index in $(seq 0 ${menuHI[menuLastItem]}); do
            local item=${menuItemsHI[$index]}
            local startChar=${item:0:1}
            if [[ "$key" = "$startChar" ]]; then
                # Jumping possibly more than 1 (next/prev) item
                local top=$((menuHI[menuTop]+index+2))
                local menuText=${menuItemsHI[$index]}

                drawPlainAt $top ${menuHI[menuLeft]} "$menuText"
                return $index
            fi
        done
    fi

    if [[ "$key" = "" ]]; then
        # Notify that Enter key was pressed
        return 255
    fi

    return $choiceHI
}


################################
# Main Menu Loop
################################
menuLoop() {
    local -n menu=$1
    local -n menuItems=$2
    local -n menuActions=$3
    local choice=0
    local running=1
    local before=-1

    menuDisplay menu menuItems
    
    while [[ $running -eq 1 ]]; do
        # Enable case insensitive matching
        local caseMatch=`shopt -p nocasematch`
        shopt -s nocasematch

        menuHandleInput menu menuItems $choice $before
        local newChoice=$?

        # Revert to previous case matching
        $caseMatch

        if [[ $newChoice -eq 255 ]]; then
            # Enter pressed - run menu action
            drawClear
            action=${menuActions[$choice]}
            $action
            running=$?

            # Back from action
            # If we are still running, redraw menu
            [[ $running -eq 1 ]] && menuDisplay menu menuItems

        elif [[ $newChoice -lt ${menu[menuItemCount]} ]]; then
            # Update selected menu item
            before=$choice
            choice=$newChoice
        fi
    done

    # Cleanup screen
    drawClear
}

# Override actionMongo
actionMongo() {
    if [ -z "${listRun[mongo]}" ]; then
        listRun[mongo]="-f docker-compose/mongodb/docker-compose.yml"
        menuMainItems[0]="1. MongoDB  [X] "
        memReq=$((memReq+300))
    else
        unset listRun[mongo]
        menuMainItems[0]="1. MongoDB  [_] "
        memReq=$((memReq-300))
    fi
    return 1
}

# Override actionKafka
actionKafka() {
    if [ -z "${listRun[kafka]}" ]; then
        listRun[kafka]="-f docker-compose/kafka/docker-compose.yml"
        menuMainItems[1]="2. Kafka    [X] "
        memReq=$((memReq+400))
    else
        unset listRun[kafka]
        menuMainItems[1]="2. Kafka    [_] "
        memReq=$((memReq-400))
    fi
    return 1
}

# Override actionRedis
actionRedis() {
    if [ -z "${listRun[redis]}" ]; then
        listRun[redis]="-f docker-compose/redis/docker-compose.yml"
        menuMainItems[2]="3. Redis    [X] "
        memReq=$((memReq+200))
    else
        unset listRun[redis]
        menuMainItems[2]="3. Redis    [_] "
        memReq=$((memReq-200))
    fi
    return 1
}
