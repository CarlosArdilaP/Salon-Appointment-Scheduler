#!/bin/bash

# Definir el comando PSQL
PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

# Mostrar la lista de servicios
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo "Welcome to My Salon, how can I help you?"

# Listar servicios
SERVICES=$($PSQL "SELECT service_id, name FROM services;")
echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME; do
  echo "$SERVICE_ID) $SERVICE_NAME"
done

# Solicitar ID del servicio
while true; do
  echo -e "\nPlease select a service:"
  read SERVICE_ID_SELECTED

  # Validar que el servicio exista
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")

  if [[ -z $SERVICE_NAME ]]; then
    echo -e "\nI could not find that service. What would you like today?"
    echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME; do
      echo "$SERVICE_ID) $SERVICE_NAME"
    done
  else
    break
  fi
done

# Solicitar número de teléfono
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

# Buscar cliente en la base de datos
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")

if [[ -z $CUSTOMER_ID ]]; then
  # Si el cliente no existe, solicitar el nombre
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME

  # Insertar nuevo cliente
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
else
  # Obtener nombre del cliente existente
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")
fi

# Solicitar la hora de la cita
echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

# Insertar la cita en la base de datos
INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")

# Confirmar la cita
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
