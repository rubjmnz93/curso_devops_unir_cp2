.PHONY: get-key

help:
	@echo "Available Makefile tasks:"
	@echo "	get-key-tf 	-> Extracts the private key from Terraform and saves it to ssh/id_rsa"
	@echo "	help		-> Shows this help message"

get-key-tf:
	@mkdir -p ssh
	cd terraform && terraform output -raw vm_private_key > ../ssh/id_rsa
	@chmod 600 ssh/id_rsa
	@echo "Private key saved in ssh/id_rsa"