
variable "rg-name" {
    description = "Resource Group Name"
    default = "BGApp-Deployment"
}
variable "location" {
    description = "Project Location"
    default = "westeurope"
}
variable "ssh-rg-name" {
    description = "SSH Key Resource Group"
    default = "ssh-keys"
}
variable "ssh-key-name" {
    description = "SSH Key Name"
    default = "bgapp-ssh"
}