# 2. Deploy Azure Function
# Get resource group and location and random string
$resourceGroupName = "serverless-fullstack-bus-app"
$resourceGroup = Get-AzResourceGroup | Where ResourceGroupName -like $resourceGroupName
# $uniqueID = Get-Random -Minimum 100000 -Maximum 1000000
$uniqueID = 834169
$location = $resourceGroup.Location
# Azure function name
$azureFunctionName = $("azfunc$($uniqueID)")
# Get storage account name
$storageAccountName = (Get-AzStorageAccount -ResourceGroup $resourceGroupName).StorageAccountName

if (!$storageAccountName) {
  $storageAccountName = "storageaccount$($uniqueID)"
  $storageAccount = New-AzStorageAccount -ResourceGroupName $resourceGroupName -AccountName $storageAccountName -Location $location -SkuName Standard_GRS
}


# Uncomment ro deploy Azure Function for dotnet
<#
$functionApp = New-AzFunctionApp -Name $azureFunctionName `
    -ResourceGroupName $resourceGroupName -StorageAccount $storageAccountName `
    -FunctionsVersion 3 -RuntimeVersion 3 -Runtime dotnet -Location $location
#>

# Uncomment to deploy Azure Function for python
# <#
$functionApp = New-AzFunctionApp -Name $azureFunctionName `
    -ResourceGroupName $resourceGroupName -StorageAccount $storageAccountName `
    -FunctionsVersion 4 -RuntimeVersion 3.9 -Runtime python -Location $location -OsType Linux
#>

# Uncomment to deploy Azure Function for node
<#
$functionApp = New-AzFunctionApp -Name $azureFunctionName `
    -ResourceGroupName $resourceGroupName -StorageAccount $storageAccountName `
    -FunctionsVersion 3 -RunTimeVersion 12 -Runtime node -Location $location
#>


# cd azure-function\python
# pip install -r requirements.txt
