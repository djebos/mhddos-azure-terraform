#!/bin/bash

set -e
mkdir -p logs
export TF_IN_AUTOMATION=true
inputArgs=("$@")
regions=('koreacentral')
if (( ${#inputArgs[@]} > 0)); then
    regions=(${inputArgs[*]})
fi
#validate input regions
availableRegions=$(az provider list --query "[?namespace=='Microsoft.Resources'].[resourceTypes[?resourceType=='resourceGroups'].locations[]][][]" | sed '1d;$d' | tr '[:upper:]' '[:lower:]' | tr -d " \t\",")

for region in "${regions[@]}"; do
  if ! grep -q "^$region$" <<< $availableRegions; then
    echo -e "\u001b[1m\u001b[31;1mNot Supported region '$region'. Check supported regions listed below:\u001b[0m"
    echo "$availableRegions"
    exit 1
  fi
done

terraform init -input=false
declare -A pidsByRegion

for region in "${regions[@]}"; do
    echo "Starting VM destroy in region '$region'"
    terraform plan -destroy -out="${region}TfPlan" -refresh=true -state="$region.tfstate" -no-color -input=false -detailed-exitcode -var="location=$region" -var="resource_group_name=mhddos${region^}" |& tee "logs/${region}Destroy.log" &> /dev/null &&
    terraform apply -destroy -state="$region.tfstate" -no-color -input=false "${region}TfPlan" |& tee -a "logs/${region}Destroy.log" &> /dev/null &
    pidsByRegion[${region}]=$!
done

for region in "${!pidsByRegion[@]}"; do
  echo "Waiting for '$region' VMs destroy, PID ${pidsByRegion[$region]}"
  wait ${pidsByRegion[$region]}
     if grep -q "Apply complete!" "logs/${region}Destroy.log" ; then
       echo -e "\u001b[1m\u001b[32;1m$region VMs destroy finished, exit code $?. You can find terraform logs here logs/${region}Destroy.log\u001b[0m"
     else
       echo -e "\u001b[1m\u001b[31;1m'$region' VMs destroy failed, exit code $?.\u001b[0m"
       cat "logs/${region}Destroy.log"
     fi
done




