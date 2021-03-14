#!/usr/bin/with-contenv bashio
# ==============================================================================
# Configures Meross service
# ==============================================================================

CONFIG_PATH=/data/options.json
DB_PATH=/data/database.db
DB_SCHEMA_PATH=/opt/meross_api/schema.sql

# If the user has asked to reinit the db, remove it
REINIT_DB=$(jq "if .resetdb then .resetdb else 0 end" $CONFIG_PATH)
if [[ $REINIT_DB -eq 1 ]]; then
  if [[ -f $DB_PATH ]]; then
    bashio::log.warning "User configuration requires DB reinitialization. Removing previous DB data."
    rm $DB_PATH
  fi
fi


# Initializing DB
pushd /opt/meross_api >/dev/null

ADMIN_EMAIL=$(jq --raw-output ".email" $CONFIG_PATH)
ADMIN_PASSWORD=$(jq --raw-output ".password" $CONFIG_PATH)

bashio::log.info "Setting up the database in $DB_PATH"
python3 db_setup.py --email "$ADMIN_EMAIL" --password "$ADMIN_PASSWORD"
if [[ $? -ne 0 ]]; then
  bashio::log.error "Error when setting up the database file. Aborting."
  exit 1
else
  bashio::log.info "DB setup finished"
fi
popd >/dev/null