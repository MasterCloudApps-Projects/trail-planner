output "alb_address" {
  value = aws_alb.alb.dns_name
}

output "security_groups" {
  value = {
    db-sg = aws_security_group.db-sg
    task-sg = aws_security_group.task-sg
    alb-sg = aws_security_group.alb-sg
    pre_build-sg = aws_security_group.pre_build-sg
  }
}

output "aws_subnet" {
  value = {
    public = aws_subnet.public
    private = aws_subnet.private
  }
}

output "aws_vpc_id" {
  value = aws_vpc.main.id
}

output "aws_alb_target_id" {
  value = aws_alb_target_group.trgp.id
}





