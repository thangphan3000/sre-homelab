#!/bin/bash

set -eof pipefail

echo "Syncing Terraform outputs to Ansible..."

# Get project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "→ Exporting SSH private key..."
cd "${PROJECT_ROOT}/terragrunt/160927904381/ap-southeast-1/production/shared/ec2"
terragrunt output -raw ssh_private_key > "${PROJECT_ROOT}/ansible/private-key.pem"
chmod 600 "${PROJECT_ROOT}/ansible/private-key.pem"

echo "→ Fetching instance public IPs..."
MASTER_IP=$(terragrunt output -json instance_public_ips | jq -r '.["production-k8s-control-plane-1"]')
WORKER_IP=$(terragrunt output -json instance_public_ips | jq -r '.["production-k8s-worker-1"]')

echo "→ Updating inventory file..."
cat > "${PROJECT_ROOT}/ansible/inventory/hosts.ini" <<EOF
master1                ansible_host=${MASTER_IP}  ansible_user=ubuntu
worker1                ansible_host=${WORKER_IP}   ansible_user=ubuntu

[masters]
master1

[workers]
worker1
EOF

echo "✓ SSH key saved to ansible/private-key.pem"
echo "✓ Inventory updated at ansible/inventory/hosts.ini"
echo ""
echo "Master IP: ${MASTER_IP}"
echo "Worker IP: ${WORKER_IP}"
