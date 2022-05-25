function AskYESorNO() {
while true; do
read -e -p "По умолчанию [Y/y] или вручную [N/n] ..? " rsn
  case $rsn in
    [Yy]* ) RUN_COMMAND ;;
    [Nn]* ) break ;;
  esac
done
}
AskYESorNO
