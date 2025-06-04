#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# Check if the database already exists
# The mysqladmin command will exit with 0 if the database exists, and non-zero otherwise.
# We redirect stdout and stderr to /dev/null to suppress output.
if mysqladmin ping -h"localhost" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; then
    echo "Database '$MYSQL_DATABASE' already exists or MySQL is already initialized."

    # Optionally, you could still try to apply the schema if it's idempotent
    # or if you want to ensure it's up-to-date, but be careful with existing data.
    # For this example, we assume if the DB exists, the schema is already applied.

else
    echo "Database '$MYSQL_DATABASE' does not exist or MySQL is not initialized."
    echo "Attempting to create database and import schema..."

    # The entrypoint script that comes with the mysql image will already create
    # MYSQL_DATABASE if it's set and the data directory is empty.
    # So, we just need to make sure we import our schema into that database.
    # The MYSQL_DATABASE is expected to be created by the parent Docker entrypoint script.
    # We then source the schema file into the created database.

    # Wait for MySQL to be ready
    # This loop tries to connect to MySQL. If it fails, it waits and tries again.
    # This is important because the server might not be fully up when this script runs.
    until mysql -h"localhost" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT 1;" &> /dev/null; do
      >&2 echo "MySQL is unavailable - sleeping"
      sleep 1
    done

    >&2 echo "MySQL is up - executing command"

    echo "Importing schema from /docker-entrypoint-initdb.d/schema.sql into database '$MYSQL_DATABASE'..."
    mysql -h"localhost" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" < /docker-entrypoint-initdb.d/schema.sql
    echo "Schema import complete."
fi

echo "init-db.sh script finished."
