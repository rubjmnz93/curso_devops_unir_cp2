.PHONY: get-key

get-key-tf-vm:
	@mkdir -p ssh
	cd terraform && terraform output -raw vm_private_key > ../ssh/id_rsa
	@chmod 600 ssh/id_rsa
	@echo "Private key saved in ssh/id_rsa"