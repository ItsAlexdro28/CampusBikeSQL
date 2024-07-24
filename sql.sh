#!/bin/bash

# Database credentials
DB_HOST="localhost"
DB_PORT="3306"
DB_USER="campus2023"
DB_PASS="campus2023"
DB_NAME="Campusbike"

# Relative path to the DDL script
DDL_SCRIPT_PATH="./DDL.sql"

# Execute the DDL script
mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS < $DDL_SCRIPT_PATH

echo "DDL script has been executed successfully."
