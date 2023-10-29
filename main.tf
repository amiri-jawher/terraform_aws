########################Installation d'un serveur Tomcat sur aws avec Terraform#######################

# 1- D'abord installer l'outil aws mode CLI sur votre terminal
# 2- Avec aws configure sur le terminal mettez votre cle d'acces,
#    votre cle secrete ainsi que votre region 
# 3- Récupérer le projet sur github 
# 4- Installer terraform via les source (voir le site officiel de Terraform) 
# 5- Creer un projet puis copier main.tf et devops_j2ee_2023.sh dans le dossier du projet
# 6- Pour lancer le projet taper : terraform init puis terraform apply --auto-approve 
# 7- N'oublier pas d'effacer le la vm avant de sortir avec terraform destroy 

provider "aws" {
  region = "eu-west-3"  # ICI c'est la region parisienne
}

resource "aws_instance" "ubuntu_vm" {
# count         = var.instance_count  
  ami           = "ami-008bcc0a51a849165"  # Ubuntu 20.04 LTS AMI
  instance_type = "t2.small"             # Choose an instance type
  user_data     =  file("devops_j2ee_2023.sh")       # execution post_install
  tags = {
    Name = "MyTomcatVM"
  
  }

  key_name = "cleRSI2023"  # mettez le nom de votre paire de clefs (aws)

 # Créer un groupe de sécurité pour autoriser tout le trafic réseau
  security_groups = [aws_security_group.all_access.name]
}

resource "aws_security_group" "all_access" {
  name        = "all_access"
  description = "Allow  traffic"

  # Règle permettant tout le trafic entrant
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# Créez une variable locale contenant un message personnalisé
locals {
  custom_message = "Attendez un peu, puis Dans le navigateur aller sur http://${aws_instance.ubuntu_vm.public_ip}:8080/webapp"
}

# Affichez le message personnalisé dans une sortie
output "custom_message" {
  value = local.custom_message
}
output "public_ip" {
  value = aws_instance.ubuntu_vm.public_ip
}