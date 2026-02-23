terragrunt-bootstrap-homelab:
	cd terragrunt/160927904381/ap-southeast-1/production/shared/vpc/ && terragrunt apply -auto-approve
	cd terragrunt/160927904381/ap-southeast-1/production/shared/security-groups/ && terragrunt apply -auto-approve
	cd terragrunt/160927904381/ap-southeast-1/production/shared/ec2/ && terragrunt apply -auto-approve

terragrunt-code-format:
	cd terragrunt && terragrunt hcl fmt && terraform fmt -recursive .

ansible-sync:
	@./scripts/sync-ansible.sh

ansible-run:
	@cd ansible && ansible-playbook playbook.yaml --tags k8s,k8s-init,k8s-join-worker
