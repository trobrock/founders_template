resource "aws_security_group" "sshable" {
  name        = "sshable-${var.name}"
  description = "Enable SSH to the world, please do not use unless you know what you are doing"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "sshable" {
  key_name   = var.name
  public_key = var.key_pair_public_key
}
