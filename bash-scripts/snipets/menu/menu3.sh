#!/bin/bash

# Storyline: Menu for admin, VPN, and Security functions

function invalid_opt() {

	echo ""
	echo "Invalid Option"
	echo ""
	sleep 2

}

function main() {

	# Clears the screen
	clear
	
	echo "[A]dmin Menu"
	echo "[S]ecurity Menu"
	echo "[E]xit"
	read -p "Please enter a choice above: " choice
	
	case "$choice" in
	
		A|a) admin_menu
		;;
		S|s) security_menu
		;;
		E|e) exit 0
		;;
		*) invalid_opt
		;;
	esac
	
main	
}

function admin_menu() {

	clear
	echo "[L]ist Running Processes"
	echo "[N]etwork Sockets"
	echo "[V]PN Menu"
	echo "[B}ack to Main Menu"
	echo "[E]xit"
	read -p "Please enter a choice above: " choice

	case "$choice" in
	
		L|l) ps -ef | less
		;;
		N|n) netstat -an --inet | less
		;;
		V|v) vpn_menu
		;;
		B|b) main
		;;
		E|e) exit 0
		;;
		*) invalid_opt
		;;
	esac
	
admin_menu
}

function vpn_menu() {

	clear
	echo "[A}dd A Peer"
	echo "[D]elete A Peer"
	echo "[B]ack To Admin Menu"
	echo "[M]ain Menu"
	echo "[E]xit"
	read -p "Please enter a choice above: " choice
	
	case "$choice" in
	
		A|a) 
			bash peer.bash
			tail -6 wg0.conf | less
		;;
		D|d) 
			# Create a prompt for the user 
			# Call the manage-user.bash and pass the proper switches
			# to delete the user
		;;
		B|b) admin_menu
		;;
		M|m) menu
		;;
		E|e) exit 0
		;;
		*) invalid_opt
		;;
	
	esac

vpn_menu
}

function security_menu() {

	clear
	echo "[L]ist Open Network Sockets"
	echo "[W]ho Has UID Of 0"
	echo "[P]revious 10 Logged In Users"
	echo "[C]urrently Logged In Users"
	echo "[B]lock List Menu"
	echo "[M]ain Menu"
	echo "[E]xit"
	read -p "Please enter a choice above: " choice
	
	case "$choice" in
		
		# Unsure if this is what you want for listing open ports
		L|l) ss -l | less
		;;
		W|\w) 
			# Print users and their UID if their UID = 0 and aren't named root
			awk -F: '($3 == 0 && $1 != "root") { printf "%s:%s\n",$1,$3 }' /etc/passwd | less
		;;
		P|p) last | head | less
		;;
		C|c) w | less
		;;
		B|b) block_menu
		;;
		M|m) main
		;;
		E|e) exit 0
		;;
		*) invalid_opt
		;;
		
	esac
	
security_menu
}

function block_menu() {
	clear
	echo "[C]isco blocklist generator"
	echo "[D]omain URL blocklist generator"
	echo "[N]etscreen Blocklist generator"
	echo "[W]indows blocklist generator"
	echo "[M]ac OS X blocklist generator"
	echo "[I]ptables blocklist generator"
	echo "[S]ecurity Menu"
	echo "[E]xit"
	
	read -p "Please enter a choice above: " choice
	
	case "$choice" in
	
		c|C) $(bash parse-threat.bash -c)
		;;
		d|D) $(bash parse-threat.bash -d)
		;;
		n|N) $(bash parse-threat.bash -n)
		;;
		\w|W) $(bash parse-threat.bash -w)
		;;
		m|M) $(bash parse-threat.bash -m)
		;;
		i|I) $(bash parse-threat.bash -i)
		;;
		s|S) security_menu
		;;
		e|E) exit 0
		;;
		*) invalid_opt
		;;
	esac

block_menu
}

# Invoke the main function
main
