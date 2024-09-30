#!/usr/bin/env bash
set -Eeo pipefail

source "$(which docker-entrypoint.sh)"

### assumption: "$@" starts with mysqld followed by options (see docker run below)

mysql_note "Entrypoint script for MySQL Server ${MYSQL_VERSION} started."

mysql_check_config "$@"
# Load various environment variables
docker_setup_env "$@"
docker_create_db_directories "$@"

##### this section might be problematic if the custom script isn't designed to be restarted from the beginning
## it will just work fine with this short script but may cause issues if you have more setup above
# If container is started as root user, restart as dedicated mysql user
if [ "$(id -u)" = "0" ]; then
	mysql_note "Switching to dedicated user 'mysql'"
	exec gosu mysql "$BASH_SOURCE" "$@"
fi
#####

# there's no database, so it needs to be initialized
if [ -z "$DATABASE_ALREADY_EXISTS" ]; then
	docker_verify_minimum_env
	docker_init_database_dir "$@"

	mysql_note "Starting temporary server"
	docker_temp_server_start "$@"
	mysql_note "Temporary server started."

	docker_setup_db
	docker_process_init_files /docker-entrypoint-initdb.d/*

	mysql_expire_root_user

	mysql_note "Stopping temporary server"
	docker_temp_server_stop
	mysql_note "Temporary server stopped"

	echo
	mysql_note "MySQL init process done. Ready for start up."
	echo
fi
