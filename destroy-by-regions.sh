#!/bin/bash

set -e
export TF_IN_AUTOMATION=true
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
done

terraform init -input=false
terraformRegions=( "${regions[@]/%/\"}" )
terraformRegions=( "${terraformRegions[@]/#/\"}" )
regionsParam=$( IFS=$','; echo "${terraformRegions[*]}" )
echo "Starting VM destroy in regions ${regions[*]}"
terraform plan -destroy -refresh=true -out="plan" -no-color -input=false -detailed-exitcode -var="locations=[$regionsParam]" |& tee "logs/destroy.log" &>/dev/null &&
terraform apply -destroy -no-color -input=false "plan" |& tee -a "logs/destroy.log" &>/dev/null &

echo "Waiting for VMs destroy, PID $!"
wait $!
if grep -q "Apply complete!" "logs/destroy.log"; then
  echo -e "\u001b[1m\u001b[32;1m VMs destroy finished, exit code $?. You can find terraform logs here logs/destroy.log\u001b[0m"
else
  echo -e "\u001b[1m\u001b[31;1m VMs destroy failed, exit code $?. Check full log here logs/destroy.log\u001b[0m"
fi
