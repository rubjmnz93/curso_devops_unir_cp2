SHELL := /bin/bash

.PHONY: get-key


help:
	@echo "Available commands:"
	@echo ""
	@echo "  set-azure-account-id       -> Set the current Azure subscription ID into terraform/terraform.tfvars"
	@echo "  tf-deploy                  -> Deploy infrastructure using Terraform"
	@echo "  tf-destroy                 -> Destroy infrastructure using Terraform"
	@echo "  get-key-tf                 -> Extract private key from Terraform outputs and save to ssh/id_rsa"
	@echo "  connect-ssh-vm             -> SSH into the VM using the private key from get-key-tf"
	@echo "  run-ansible-playbook       -> Run Ansible playbook to configure resources"

full-deploy: ansible-set-vault-pass create-python-env tf-deploy ansible-run-playbook

create-python-env:
	python3 -m venv .venv
	. .venv/bin/activate && pip install -r requirements.txt

ansible-set-vault-pass:
	@if [ ! -f ansible/.vault_pass ]; then \
		read -s -p "Enter Ansible vault password: " vault_pass; \
		echo; \
		echo $$vault_pass > ansible/.vault_pass; \
		chmod 600 ansible/.vault_pass; \
	fi

tf-set-azure-account-id:
	@echo "subscription_id = \"$$(az account show --query id -o tsv)\"" > terraform/terraform.tfvars

tf-init:
	cd terraform && terraform init

tf-deploy: tf-set-azure-account-id tf-init
	cd terraform && terraform apply -var-file="terraform.tfvars" --auto-approve

tf-destroy: tf-set-azure-account-id
	cd terraform && terraform destroy -var-file="terraform.tfvars" --auto-approve

get-key-tf:
	@mkdir -p ssh
	cd terraform && terraform output -raw vm_private_key > ../ssh/id_rsa
	@chmod 600 ssh/id_rsa
	@echo "Private key saved in ssh/id_rsa"

connect-ssh-vm: get-key-tf
	cd terraform && \
	vm_username=$$(terraform output -raw vm_username) && \
	vm_ip=$$(terraform output -raw vm_ip) && \
	ssh -i ../ssh/id_rsa $${vm_username}@$${vm_ip}

ansible-run-playbook: get-key-tf
	cd ansible && \
	ansible-playbook playbook.yml --vault-password-file .vault_pass
