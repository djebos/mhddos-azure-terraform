# Configure the Microsoft Azure Provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}
locals {
  resource_group_name = "common"
  location = "eastus"
  sub_id = data.azurerm_subscription.current.subscription_id
  rgInstancesComb = [for rg, instance in var.vmNamesByResourceGroups : setproduct([rg], instance)]
  instanceDiagrams = flatten([for tupl in local.rgInstancesComb : [ for subtupl in tupl:
    {
    rg: subtupl[0]
    instance: subtupl[1]
  }
  ]
])

  template = [ for i in range(length(local.instanceDiagrams)): [
    {
      key : "${local.instanceDiagrams[i].rg}${local.instanceDiagrams[i].instance}Cpu"
      value : {
        position : {
          "x" : 0,
          "y" : i*4,
          "colSpan" : 6,
          "rowSpan" : 4
        },
        metadata : {
          "inputs" : [
            {
              "name" : "sharedTimeRange",
              "isOptional" : true
            },
            {
              "name" : "options",
              "value" : {
                "chart" : {
                  "metrics" : [
                    {
                      "resourceMetadata" : {
                        "id" : "/subscriptions/${local.sub_id}/resourceGroups/${local.instanceDiagrams[i].rg}/providers/Microsoft.Compute/virtualMachines/${local.instanceDiagrams[i].instance}"
                      },
                      "name" : "Percentage CPU",
                      "aggregationType" : 4,
                      "metricVisualization" : {
                        "displayName" : "Percentage CPU",
                        "resourceDisplayName" : "${local.instanceDiagrams[i].instance}"
                      }
                    }
                  ],
                  "title" : "CPU (average)",
                  "titleKind" : 2,
                  "visualization" : {
                    "chartType" : 2
                  },
                  "openBladeOnClick" : {
                    "openBlade" : true
                  }
                }
              },
              "isOptional" : true
            }
          ],
          "type" : "Extension/HubsExtension/PartType/MonitorChartPart",
          "settings" : {
            "content" : {
              "options" : {
                "chart" : {
                  "metrics" : [
                    {
                      "resourceMetadata" : {
                        "id" : "/subscriptions/${local.sub_id}/resourceGroups/${local.instanceDiagrams[i].rg}/providers/Microsoft.Compute/virtualMachines/${local.instanceDiagrams[i].instance}"
                      },
                      "name" : "Percentage CPU",
                      "aggregationType" : 4,
                      "metricVisualization" : {
                        "displayName" : "Percentage CPU",
                        "resourceDisplayName" : "${local.instanceDiagrams[i].instance}"
                      }
                    }
                  ],
                  "title" : "CPU (average) ${local.instanceDiagrams[i].rg}",
                  "titleKind" : 2,
                  "visualization" : {
                    "chartType" : 2,
                    "disablePinning" : true
                  },
                  "openBladeOnClick" : {
                    "openBlade" : true
                  }
                }
              }
            }
          },
          "filters" : {
            "MsPortalFx_TimeRange" : {
              "model" : {
                "format" : "local",
                "granularity" : "auto",
                "relative" : "60m"
              }
            }
          }
        }
      }
    },
    {
      key: "${local.instanceDiagrams[i].rg}${local.instanceDiagrams[i].instance}Net"
      value: {
      "position" : {
        "x" : 6,
        "y" : i*4,
        "colSpan" : 6,
        "rowSpan" : 4
      },
      "metadata" : {
        "inputs" : [
          {
            "name" : "sharedTimeRange",
            "isOptional" : true
          },
          {
            "name" : "options",
            "value" : {
              "chart" : {
                "metrics" : [
                  {
                    "resourceMetadata" : {
                      "id" : "/subscriptions/${local.sub_id}/resourceGroups/${local.instanceDiagrams[i].rg}/providers/Microsoft.Compute/virtualMachines/${local.instanceDiagrams[i].instance}"
                    },
                    "name" : "Network In Total",
                    "aggregationType" : 1,
                    "metricVisualization" : {
                      "displayName" : "Network In Total",
                      "resourceDisplayName" : "${local.instanceDiagrams[i].instance}"
                    }
                  },
                  {
                    "resourceMetadata" : {
                      "id" : "/subscriptions/${local.sub_id}/resourceGroups/${local.instanceDiagrams[i].rg}/providers/Microsoft.Compute/virtualMachines/${local.instanceDiagrams[i].instance}"
                    },
                    "name" : "Network Out Total",
                    "aggregationType" : 1,
                    "metricVisualization" : {
                      "displayName" : "Network Out Total",
                      "resourceDisplayName" : "${local.instanceDiagrams[i].instance}"
                    }
                  }
                ],
                "title" : "Network (total)",
                "titleKind" : 2,
                "visualization" : {
                  "chartType" : 2
                },
                "openBladeOnClick" : {
                  "openBlade" : true
                }
              }
            },
            "isOptional" : true
          }
        ],
        "type" : "Extension/HubsExtension/PartType/MonitorChartPart",
        "settings" : {
          "content" : {
            "options" : {
              "chart" : {
                "metrics" : [
                  {
                    "resourceMetadata" : {
                      "id" : "/subscriptions/${local.sub_id}/resourceGroups/${local.instanceDiagrams[i].rg}/providers/Microsoft.Compute/virtualMachines/${local.instanceDiagrams[i].instance}"
                    },
                    "name" : "Network In Total",
                    "aggregationType" : 1,
                    "metricVisualization" : {
                      "displayName" : "Network In Total",
                      "resourceDisplayName" : "${local.instanceDiagrams[i].instance}"
                    }
                  },
                  {
                    "resourceMetadata" : {
                      "id" : "/subscriptions/${local.sub_id}/resourceGroups/${local.instanceDiagrams[i].rg}/providers/Microsoft.Compute/virtualMachines/${local.instanceDiagrams[i].instance}"
                    },
                    "name" : "Network Out Total",
                    "aggregationType" : 1,
                    "metricVisualization" : {
                      "displayName" : "Network Out Total",
                      "resourceDisplayName" : "${local.instanceDiagrams[i].instance}"
                    }
                  }
                ],
                "title" : "Network (total) ${local.instanceDiagrams[i].rg}",
                "titleKind" : 2,
                "visualization" : {
                  "chartType" : 2,
                  "disablePinning" : true
                },
                "openBladeOnClick" : {
                  "openBlade" : true
                }
              }
            }
          }
        }
      }
    }
  }
  ]]

  dashboard_template = templatefile("./modules/dashboard/dashboard.tftpl", {
    parts = {for i in flatten(local.template): i.key => i.value}
    location = local.location
  })
}

data "azurerm_subscription" "current" {}

output "rl" {
  value = local.dashboard_template
}

resource "azurerm_resource_group" "dashboard_group" {
  name     = local.resource_group_name
  location = local.location

  tags = var.tags
}

resource "azurerm_dashboard" "utilization_dashboard" {
  name                = "utilization"
  resource_group_name = local.resource_group_name
  location            = local.location
  tags = var.tags
  dashboard_properties = local.dashboard_template
}