#!/bin/bash

declare -A menuMain
declare -A menuMainItems
declare -A menuMainActions
declare -A listRun
memReq=0

actionMongo() {
    echo "Action mongo"
    echo -n "Press enter to continue ... "
    read response

    return 1
}

actionKafka() {
    echo "Action kafka"
    echo -n "Press enter to continue ... "
    read response

    return 1
}

actionRedis() {
    echo "Action redis"
    echo -n "Press enter to continue ... "
    read response

    return 1
}

actionRun() {
    echo "Action run"
    echo -n "Press y/n to continue ... "
    local key=""
    read -s -n1 key 2> /dev/null >&2
    if [[ ${#key} -eq 1 ]]; then
        if [[ "$key" = "y" ]]; then
            if [[ -z "${listRun[@]}" ]]; then
                return 1
            else
                local finalPath=""
                for path in "${listRun[@]}"; do
                    finalPath="${finalPath}  ${path}"
                done
                docker-compose $finalPath up -d
                return 0
            fi
        elif [[ "$key" = "n" ]]; then
            return 1
        fi
    fi
}

actionStop() {
    echo "Action stop"
    echo -n "Press y/n to continue ... "
    local key=""
    read -s -n1 key 2> /dev/null >&2
    if [[ ${#key} -eq 1 ]]; then
        if [[ "$key" = "y" ]]; then
            if [[ -z "${listRun[@]}" ]]; then
                return 1
            else
                local finalPath=""
                for path in "${listRun[@]}"; do
                    finalPath="${finalPath}  ${path}"
                done
                docker-compose $finalPath down -v
                return 0
            fi
        elif [[ "$key" = "n" ]]; then
            return 1
        fi
    fi
}

actionX() {
    return 0
}

actionR() {
    FREE_BLOCKS=$(vm_stat | grep free | awk '{ print $3 }' | sed 's/\.//')
    INACTIVE_BLOCKS=$(vm_stat | grep inactive | awk '{ print $3 }' | sed 's/\.//')
    SPECULATIVE_BLOCKS=$(vm_stat | grep speculative | awk '{ print $3 }' | sed 's/\.//')

    FREE=$((($FREE_BLOCKS+SPECULATIVE_BLOCKS)*4096/1048576))
    INACTIVE=$(($INACTIVE_BLOCKS*4096/1048576))
    TOTAL=$((($FREE+$INACTIVE)))
    echo Total free:   $TOTAL  MB
    echo Your Mem Req: $memReq MB
    read response
    return 1
}

menuMainItems=(
    [0]="1. MongoDB  [_] "
    [1]="2. Kafka    [_] "
    [2]="3. Redis    [_] "
    [3]="4. Run docker-compose "
    [4]="5. Stop docker-compose "
    [5]="M. Check Memory"
    [6]="Q. Exit"
)

menuMainActions=(
    [0]=actionMongo
    [1]=actionKafka
    [2]=actionRedis
    [3]=actionRun
    [4]=actionStop
    [5]=actionR
    [6]=actionX
)

menuMain[menuHeaderText]=""
menuMain[menuFooterText]=""
menuMain[menuBorderText]=""
menuMain[menuTitle]=" Design your dev enviroment, type y/n/c:"
menuMain[menuFooter]=" Resource accept (v)"
menuMain[menuTop]=2
menuMain[menuLeft]=15
menuMain[menuWidth]=80
menuMain[menuMargin]=4
menuMain[menuColour]=$DRAW_COL_WHITE
menuMain[menuHighlight]=$DRAW_COL_GREEN          
menuMain[menuItemCount]=${#menuMainItems[@]}
menuMain[menuLastItem]=$((${#menuMainItems[@]}-1))

################################
# Initialise Menu
################################
menuMainInit() {
    # Ensure header and footer are padded appropriately
    menuMain[menuHeaderText]=`printf "%-${menuMain[menuWidth]}s" "${menuMain[menuTitle]}"`
    menuMain[menuFooterText]=`printf "%-${menuMain[menuWidth]}s" "${menuMain[menuFooter]}"`

    # Menu (side) borders
    local marginSpaces=$((menuMain[menuMargin]-1))
    local menuSpaces=$((menuMain[menuWidth]-2))
    local leftGap=`printf "%${marginSpaces}s" ""`
    local midGap=`printf "%${menuSpaces}s" ""`
    menuMain[menuBorderText]="${leftGap}x${midGap}x"
}
