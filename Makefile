TERRAGRUNT_SHARED = terragrunt-aws/160927904381/ap-southeast-1/production/shared

init:
	@echo "→ Terragrunt AWS bootstrapping..."
	cd $(TERRAGRUNT_SHARED)/vpc/ && terragrunt apply -auto-approve
	cd $(TERRAGRUNT_SHARED)/security-groups/ && terragrunt apply -auto-approve
	cd $(TERRAGRUNT_SHARED)/ec2/ && terragrunt apply -auto-approve
	echo "→ Sync Terragrunt output to Ansible"
	bash scripts/sync-ansible.sh
	@echo "→ Run Ansible playbook"
	cd ansible && ansible-playbook playbook.yaml --tags k8s,k8s-init,k8s-join-worker
	@echo "✓ Deployment complete"

terragrunt-destroy:
	cd $(TERRAGRUNT_SHARED)/ec2/ && terragrunt destroy -auto-approve
	cd $(TERRAGRUNT_SHARED)/security-groups/ && terragrunt destroy -auto-approve
	cd $(TERRAGRUNT_SHARED)/vpc/ && terragrunt destroy -auto-approve

terragrunt-code-format:
	@echo "→ Terragrunt and Terraform code is being format..."
	cd terragrunt-aws && terragrunt hcl fmt && terraform fmt -recursive .
