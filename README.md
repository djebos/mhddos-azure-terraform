#Getting started  
1. Initialize terraform
```shell
terraform init
```
2. Select target and type of attack by changing in cloud-init.yaml the `runcmd` attribute
3. Deploy to the specified azure region (you must be logged in through `az login`):  
```shell
terraform apply -state india.tfstate -var="location=southindia" -var="resource_group_name=mhddosIndia"
terraform apply -state korea.tfstate -var="location=koreacentral" -var="resource_group_name=mhddosKorea"
terraform apply -state japan.tfstate -var="location=japaneast" -var="resource_group_name=mhddosJapan"
```