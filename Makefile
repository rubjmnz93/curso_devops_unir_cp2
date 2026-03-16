SHELL := /bin/bash

.PHONY: get-key


help:
	@echo "Available commands:"
	@echo ""
	@echo "  help                       -> Show this help message"
	@echo "  full-deploy                -> Complete deployment: set vault pass, create env, deploy TF, run Ansible"
	@echo "  create-python-env          -> Create Python virtual environment and install requirements"
	@echo "  ansible-set-vault-pass     -> Set Ansible vault password if not already set"
	@echo "  tf-set-azure-account-id    -> Set the current Azure subscription ID into terraform/terraform.tfvars"
	@echo "  tf-init                    -> Initialize Terraform"
	@echo "  tf-deploy                  -> Deploy infrastructure using Terraform"
	@echo "  tf-destroy                 -> Destroy infrastructure using Terraform"
	@echo "  get-key-tf                 -> Extract private key from Terraform outputs and save to ssh/id_rsa"
	@echo "  connect-ssh-vm             -> SSH into the VM using the private key from get-key-tf"
	@echo "  ansible-run-playbook       -> Run Ansible playbook to configure resources"
	@echo "  get-nginx-url              -> Get the URL for the Nginx service deployed on the VM"
	@echo "  get-wordpress-url          -> Get the URL for the WordPress service deployed on AKS"
	@echo ""

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

get-nginx-url:
	@cd terraform && \
	vm_ip=$$(terraform output -raw vm_ip) && \
	echo "Nginx URL: http://$$vm_ip:8080"

get-wordpress-url:
	@az aks get-credentials --resource-group cp2-rg --name cp2-aks --overwrite-existing && \
	wordpress_ip=$$(kubectl get service wordpress -n casopractico2 -o jsonpath='{.status.loadBalancer.ingress[0].ip}') && \
	echo "WordPress URL: http://$$wordpress_ip"
