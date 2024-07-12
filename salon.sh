#! /bin/bash

# CONSTANTS
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

C_MAIN_MENU="Welcome to My Salon, how can I help you?\n" 

# Mark the variable as readonly to make it a constant
readonly C_MAIN_MENU

echo -e "\n~~~~ MY SALON ~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    #echo -e "Welcome to My Salon, how can I help you?\n" 
    echo -e $C_MAIN_MENU
  fi


  echo -e "1) Cut-Dry\n2) Cut-Wet\n3) Shave"
  read SERVICE_ID_SELECTED

 case $SERVICE_ID_SELECTED in
    1) CUT_DRY_MENU ;;
    2) CUT_WET_MENU ;;
    3) SHAVE_MENU;;
    *) MAIN_MENU "I could not find that service. What would you like today?" ;;
  esac
}

CUT_DRY_MENU() {
  APPOINTMENT_HANDLING "Cut-Dry"
}

CUT_WET_MENU() {
  APPOINTMENT_HANDLING "Cut-Wet"
  }

SHAVE_MENU() {
  APPOINTMENT_HANDLING "Shave"
  }

APPOINTMENT_HANDLING()
{
  # print argument
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo -e "Invalid selection. Return to Main menu\n"
    MAIN_MENU
  fi

  # get phone number
  echo -e "\nWhat's your phone number?"

  # read customer phone number and check if it is a valid input
  while true; do
    read CUSTOMER_PHONE

    if [[ $CUSTOMER_PHONE =~ [a-zA-Z] ]] 
    then
      echo "$CUSTOMER_PHONE is not a valid phone number. It contains letters. Please enter a correct phone number:"
    elif [[ -z $CUSTOMER_PHONE  ]] 
    then
      echo "Your input was empty. Please enter your phone number:"
    else
      break
    fi
  done
  


  # search database for phone number.
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  # if customer doesn't exist
  if [[ -z $CUSTOMER_NAME ]]
  then
    # get the new customer name
    echo -e "\nI don't have a record for that phone number, what's your name?"

    # read customer name and check if it is a valid input
    while true; do
      read CUSTOMER_NAME

      if [[ -z $CUSTOMER_NAME ]] 
      then
        echo "Your input was empty. Please enter your name:"
      else
        break
      fi
    done

    # insert new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
  fi

  # for further name printing, we format the customer name, so it does not have leading blanks
  CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')

  # get customer id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name = '$CUSTOMER_NAME_FORMATTED';")

  # get service id
  SERVICE_ID_SELECTED=$($PSQL "SELECT service_id FROM services WHERE name = '$1';")

  # get the service time
  echo -e "\nWhat time would you like your $1, $CUSTOMER_NAME_FORMATTED?"
 

  # read service time and check if input is valid
  while true; do
    read SERVICE_TIME

    if [[ -z $SERVICE_TIME ]] 
    then
      echo "Your input was empty. Please enter a time:"
    else
      break
    fi
  done

  # add new appointment to appointments
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')") 
  
  # Print the appointment information
  echo -e "\nI have put you down for a $1 at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
}


# call main menu by default
MAIN_MENU