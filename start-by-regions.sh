#!/bin/bash

set -e
export TF_IN_AUTOMATION=true
defaultVmSize=Standard_F1s
mkdir -p logs
inputArgs=("$@")
regions=('koreacentral')
if ((${#inputArgs[@]} > 0)); then
  regions=(${inputArgs[*]})
fi
#validate input regions
availableRegions=$(az provider list --query "[?namespace=='Microsoft.Resources'].[resourceTypes[?resourceType=='resourceGroups'].locations[]][][]" | sed '1d;$d' | tr '[:upper:]' '[:lower:]' | tr -d " \t\",")
for region in "${regions[@]}"; do
  if ! grep -q "^$region$" <<<$availableRegions; then
    echo -e "\u001b[1m\u001b[31;1m Not Supported region $region. Check supported regions listed below:\u001b[0m"
    echo "$availableRegions"
    exit 1
  fi
  echo -n "Validate VM sku for region: $region"
  availableVmSizes=$(az vm list-skus --location $region --resource-type virtualMachines --query "[].name" | sed '1d;$d' | tr -d " \t\",")
  if ! grep -q "^$defaultVmSize$" <<<$availableVmSizes; then
    echo -e "\u001b[1m\u001b[31;1m - ERROR region doesn't support $defaultVmSize vm size. Try choosing another region from the list below:\u001b[0m"
    echo "$availableRegions"
    exit 1
  fi
    echo -e "\u001b[1m\u001b[32;1m - OK\u001b[0m"
done

terraform init -input=false
terraformRegions=("${regions[@]/%/\"}")
terraformRegions=("${terraformRegions[@]/#/\"}")
regionsParam=$(
  IFS=$','
  echo "${terraformRegions[*]}"
)
echo "Starting VM creation in regions ${regions[*]}"
terraform plan -out="plan" -no-color -input=false -detailed-exitcode -var="locations=[$regionsParam]" |& tee "logs/all.log" &>/dev/null &&
  terraform apply -no-color -input=false "plan" |& tee -a "logs/all.log" &>/dev/null &

echo "Waiting for VMs creation, PID $!"
wait $!
if grep -q "Apply complete!" "logs/all.log"; then
  echo -e "\u001b[1m\u001b[32;1m VMs creation finished, exit code $?. You can find terraform logs here logs/all.log\u001b[0m"
else
  echo -e "\u001b[1m\u001b[31;1m VMs creation failed, exit code $?. Check full log here logs/all.log\u001b[0m"
fi
