function ASKOS() {
  if grep -qs "ubuntu" "/etc/os-release"; then
    os="ubuntu" && echo "${os}";
  else
    echo "ather ${os}";
  fi;
}

ASKOS
