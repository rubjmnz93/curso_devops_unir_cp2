.PHONY: get-key

help:
	@echo "Available Makefile tasks:"
	@echo "	get-key-tf 	-> Extracts the private key from Terraform and saves it to ssh/id_rsa"
	@echo "	help		-> Shows this help message"

set-azure-account-id:
	@echo "subscription_id = \"$$(az account show --query id -o tsv)\"" > terraform/terraform.tfvars

tf-deploy: set-azure-account-id
	cd terraform && terraform apply -var-file="terraform.tfvars" --auto-approve

tf-destroy: set-azure-account-id
	cd terraform && terraform destroy -var-file="terraform.tfvars" --auto-approve

get-key-tf:
	@mkdir -p ssh
	cd terraform && terraform output -raw vm_private_key > ../ssh/id_rsa
	@chmod 600 ssh/id_rsa
	@echo "Private key saved in ssh/id_rsa"