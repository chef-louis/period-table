#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

FETCH_ELEMENT() {
  if [[ $1 ]]
  then
    REGEX_NUM='^[0-9]+$'
    REGEX_SYM='^[A-Z][a-zA-Z]?$'
    REGEX_NAME='^[A-Z][a-zA-Z]+$'
    SUCCESS=true
    if [[ $1 =~ $REGEX_NUM ]]
    then
      # echo -e "\nInput atomic number: $1"
      ATOMIC_NUMBER=$1
      ELEMENT_QUERY=$($PSQL "SELECT symbol, name FROM elements WHERE atomic_number=$ATOMIC_NUMBER")
      if [[ -z $ELEMENT_QUERY ]]
      then
        echo "I could not find that element in the database."
        SUCCESS=false
      else
        ELEMENT_SYMBOL=$(echo $ELEMENT_QUERY | awk '{split($0, a, " | "); print a[1]}')
        ELEMENT_NAME=$(echo $ELEMENT_QUERY | awk '{split($0, a, " | "); print a[3]}')
      fi
    elif [[ $1 =~ $REGEX_SYM ]]
    then
      # echo -e "\nInput element symbol: $1"
      ELEMENT_SYMBOL=$1
      ELEMENT_QUERY=$($PSQL "SELECT atomic_number, name FROM elements WHERE symbol='$ELEMENT_SYMBOL'")
      if [[ -z $ELEMENT_QUERY ]]
      then
        echo "I could not find that element in the database."
        SUCCESS=false
      else
        ATOMIC_NUMBER=$(echo $ELEMENT_QUERY | awk '{split($0, a, " | "); print a[1]}')
        ELEMENT_NAME=$(echo $ELEMENT_QUERY | awk '{split($0, a, " | "); print a[3]}')
      fi
    elif [[ $1 =~ $REGEX_NAME ]]
    then
      # echo -e "\nInput element name: $1"
      ELEMENT_NAME=$1
      ELEMENT_QUERY=$($PSQL "SELECT atomic_number, symbol FROM elements WHERE name='$ELEMENT_NAME'")
      if [[ -z $ELEMENT_QUERY ]]
      then
        echo "I could not find that element in the database."
        SUCCESS=false
      else
        ATOMIC_NUMBER=$(echo $ELEMENT_QUERY | awk '{split($0, a, " | "); print a[1]}')
        ELEMENT_SYMBOL=$(echo $ELEMENT_QUERY | awk '{split($0, a, " | "); print a[3]}')
      fi
    else
      echo "I could not find that element in the database."
      SUCCESS=false
    fi

    # echo -e "\n$ATOMIC_NUMBER >> $ELEMENT_SYMBOL >> $ELEMENT_NAME"
    if $SUCCESS
    then
      PROPERTIES_QUERY=$($PSQL "SELECT t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius FROM properties AS p JOIN types AS t ON p.type_id = t.type_id WHERE p.atomic_number=$ATOMIC_NUMBER")
    
      ELEMENT_TYPE=$(echo $PROPERTIES_QUERY | awk '{split($0, a, " | "); print a[1]}')
      ATOMIC_MASS=$(echo $PROPERTIES_QUERY | awk '{split($0, a, " | "); print a[3]}')
      MELTING_POINT=$(echo $PROPERTIES_QUERY | awk '{split($0, a, " | "); print a[5]}')
      BOILING_POINT=$(echo $PROPERTIES_QUERY | awk '{split($0, a, " | "); print a[7]}')

      echo "The element with atomic number $ATOMIC_NUMBER is $ELEMENT_NAME ($ELEMENT_SYMBOL). It's a $ELEMENT_TYPE, with a mass of $ATOMIC_MASS amu. $ELEMENT_NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
    fi
  else
    echo "Please provide an element as an argument."
  fi
}

FETCH_ELEMENT $1
