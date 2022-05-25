#!/usr/bin/ksh

#==============================================================================
# F U N C T I O N S . . .
#==============================================================================

ReadProps () {
  local list
  list=$(sed 's/#.*//' ${cvsprops} | \
         awk -F= '
            NF { count++;
                 printf "Uvar[%d]=%s; Uval[%d]=%s;", count, $1, count, $2;
                 printf "Uchoice[%d]=%s;", count, $0;
               }
            END { printf "Ucount=%d", count }'
        )
   eval ${list}
}

WriteProps () {
   local i var val
   i=1
   while (( i <= Ucount ))
   do
      var=${Uvar[$i]}
      val=${Uval[$i]}
      echo "${var}='${val}'"
      (( i+=1 ))
   done > ${cvsprops}
}

#==============================================================================
# M A I N . . . 
#==============================================================================

# Helps to change values using this menu driven script
cvsprops=FileA.props  


user_prompt='To Change Above Defaults Make A Selection:[n] '
PS3="${user_prompt}"

REDISPLAY=true  # Helps to exit from Menu.


while [ "$REDISPLAY" = "true" ]
do    
   ReadProps

   select line in "${Uchoice[@]}" REVIEW DONE
   do
        [ "$line" = "DONE" ] && REDISPLAY=false && break
        [ "$line" = "REVIEW" ] && break

        [ -z "$line" ] && echo " Invalid choice:[$REPLY]. Please make correct choice." && continue

        user_var=${Uvar[$REPLY]}
        user_value="${Uval[$REPLY]}"

        # if required variable is not set. Prompt user to set it.
        if [ -z "$user_value" ]; then
                echo "Set --> ${user_var} ?: \c"
        else
                echo "Change --> ${user_var}:[${user_value}] ?: \c"
        fi
        read user_value
        if [ -n "$user_value" ]; then
            Uval[$REPLY]="${user_value}"
            eval ${user_var}='${user_value}'
            WriteProps
            eval user_value=\$${user_var}
            echo "new value for ${user_var} --> $user_value" 
            break
        fi

   done # End of - select

done # End of while
# EOF
