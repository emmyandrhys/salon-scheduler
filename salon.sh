#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

#Opening Screen
echo -e "\n~~~~~ LuLu's FurFrou Pet Salon ~~~~~"

MAIN_MENU(){
#check if argument for function
if [[ $1 ]]
then
  echo -e "\n$1"
#no argument on the MAIN_MENU call
else
  echo -e "\nWelcome to LuLu's FurFrou, how can I help you?"
fi
#get services to display
MAIN_MENU_CHOICES=$($PSQL "SELECT service_id, name FROM services")
echo "$MAIN_MENU_CHOICES" | while read SERVICE_ID BREAK SERVICE_NAME
do
  #SERVICE_NAME=$(echo $SERVICE_NAME | sed -r 's/^ *| *$//g')
  echo "$SERVICE_ID) $SERVICE_NAME"
done
#get service selection
read SERVICE_ID_SELECTED
#check is service selected is a valid service
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
if [[ -z $SERVICE_NAME ]]
then
  MAIN_MENU "Please enter a valid service number to request an appointment"
#get customer phone number
else
  echo -e "\nWhat is your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  #if phone number not found, add customer
  if [[ -z $CUSTOMER_NAME ]]
  then 
    echo -e "\nIt is a pleasure to meet you!  What is your name?"
    read CUSTOMER_NAME
    CUSTOMER_NAME_RESULT=$($PSQL "INSERT INTO customers(name,phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi
  #get customer_id and name
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  #get requested appointment time
  echo -e "\nWhat time would you like your$SERVICE_NAME,$CUSTOMER_NAME?"
  read SERVICE_TIME
  #confirm selected service, time and name
  APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
  echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME,$CUSTOMER_NAME.\n"
fi
}

MAIN_MENU
