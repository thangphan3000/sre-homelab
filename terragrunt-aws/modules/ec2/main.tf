#------------------------------------------------------------------------------
# SSH Key Pair
#------------------------------------------------------------------------------

resource "tls_private_key" "this" {
  count     = anytrue([for k, v in var.instances : lookup(v, "create_ssh_key", true)]) ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  count      = anytrue([for k, v in var.instances : lookup(v, "create_ssh_key", true)]) ? 1 : 0
  key_name   = "${var.environment}-ec2-key"
  public_key = tls_private_key.this[0].public_key_openssh
}

#------------------------------------------------------------------------------
# IAM Role for SSM
#------------------------------------------------------------------------------

resource "aws_iam_role" "ssm" {
  name = "${var.environment}-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.ssm.name
}

resource "aws_iam_instance_profile" "ssm" {
  name = "${var.environment}-ec2-ssm-profile"
  role = aws_iam_role.ssm.name
}

#------------------------------------------------------------------------------
# EC2 Instances
#------------------------------------------------------------------------------

resource "aws_instance" "this" {
  for_each = var.instances

  ami                         = each.value.ami
  associate_public_ip_address = lookup(each.value, "associate_public_ip_address", false)
  iam_instance_profile        = aws_iam_instance_profile.ssm.name
  instance_type               = each.value.instance_type
  key_name                    = each.value.create_ssh_key ? aws_key_pair.this[0].key_name : lookup(each.value, "key_name", null)
  subnet_id                   = each.value.subnet_id
  vpc_security_group_ids      = lookup(each.value, "security_group_ids", [])
  user_data                   = lookup(each.value, "user_data", null)

  root_block_device {
    delete_on_termination = lookup(each.value.root_block_device, "delete_on_termination", true)
    encrypted             = lookup(each.value.root_block_device, "encrypted", true)
    volume_size           = lookup(each.value.root_block_device, "volume_size", 50)
    volume_type           = lookup(each.value.root_block_device, "volume_type", "gp3")
  }

  tags = { Name = each.key }
}
