#!/bin/bash

declare -A menuChild
declare -A menuChildItems
declare -A menuChildActions

actionYes() {
    echo "Action Yes"
    echo -n "Press enter to continue ... "
    read response

    return 1
}

actionNo() {
    echo "Action kafka"
    echo -n "Press enter to continue ... "
    read response

    return 1
}

actionX() {
    return 0
}

menuChildItems=(
    [0]="yes "
    [1]="no "
)

menuChildActions=(
    [0]=actionYes
    [1]=actionNo
)

menuChild[menuHeaderText]=""
menuChild[menuFooterText]=""
menuChild[menuBorderText]=""
menuChild[menuTitle]=" Design your dev enviroment"
menuChild[menuFooter]=" Resource accept (v)"
menuChild[menuTop]=2
menuChild[menuLeft]=25
menuChild[menuWidth]=60
menuChild[menuMargin]=4
menuChild[menuColour]=$DRAW_COL_WHITE
menuChild[menuHighlight]=$DRAW_COL_GREEN          
menuChild[menuItemCount]=${#menuChildItems[@]}
menuChild[menuLastItem]=$((${#menuChildItems[@]}-1))


################################
# Initialise Menu
################################
menuChildInit() {
    # Ensure header and footer are padded appropriately
    menuChild[menuHeaderText]=`printf "%-${menuChild[menuWidth]}s" "${menuChild[menuTitle]}"`
    menuChild[menuFooterText]=`printf "%-${menuChild[menuWidth]}s" "${menuChild[menuFooter]}"`

    # Menu (side) borders
    local marginSpaces=$((menuChild[menuMargin]-1))
    local menuSpaces=$((menuChild[menuWidth]-2))
    local leftGap=`printf "%${marginSpaces}s" ""`
    local midGap=`printf "%${menuSpaces}s" ""`
    menuChild[menuBorderText]="${leftGap}x${midGap}x"
}
