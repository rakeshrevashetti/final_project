output "vpc_id_reference" {
    value = aws_vpc.devops_vpc.id
}

output "public_subnet_ID" {
    value = [ aws_subnet.devops_public_subnet1.id,aws_subnet.devops_public_subnet2.id ]
}

output "private_subnet_ID" {
    value = [ aws_subnet.devops_private_subnet1.id,aws_subnet.devops_private_subnet2.id]
}