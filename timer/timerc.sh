function TIMER() {
  T="5";
  SE="\033[0K\r";
  E="$((1 * ${T}))";
  if [[ "$1" =~ ^[[:digit:]]+$ ]]; then
    T="$1";
  fi;

  while [ $E -gt 0 ]; do
    echo -en " Please wait: ${RED}$E$SE${NC}";
    sleep 1;
    : $((E--));
  done;
};

TIMER 10     # 
# or
TIMER        # Defaults (5s)

