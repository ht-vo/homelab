# Set the environment variables values in .env file
include .env
export

update_ovh_dynhost:
	./scripts/update_ovh_dynhost.sh