##!/bin/bash

# ASTM requires rounding numbers even. This bash script can be used as a function inside other larger 
# mathematical scripts to round numbers to even, i,e. 0.5 = 0 , 0.15 = 0.2 etc.

        prune1=$(echo "scale=$2+1;$1/1" | bc )
        last2dig=$(echo $prune1 | sed -e 's/\(^.*\)\(..$\)/\2/')
	div=$(echo "scale=$2+1;5/10^($2+1)" | bc )
	mod=$(echo "$1%$div" | bc )

  if [ "$last2dig" == ".5" ];
  then
  last2dig=$(echo "$1*10" | bc | cut -d "." -f1 | sed -e 's/\(^.*\)\(..$\)/\2/' )
    if [ $last2dig == 5 ]
	then
	last2dig="05"
    fi
  fi

  echo "prune1=$prune1 last2dig=$last2dig mod=$mod div=$div"
  if [ "$last2dig" == 05 ] || [ "$last2dig" == 25 ] || [ "$last2dig" == 45 ] || [ "$last2dig" == 65 ] || [ "$last2dig" == 85 ] && [ "$mod" == 0 ];
  then
  echo $(echo "scale=$2;$1/1" | bc );
  else
  echo $(echo "scale=$2;(((10^$2)*$1)+0.5)/(10^$2)" | bc );
  fi
