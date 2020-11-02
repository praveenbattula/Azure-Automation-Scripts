# PowerShell
#Install-Module -Name Az -Force -AllowClobber -Verbose

$random = $(Get-Random -Minimum 10000 -Maximum 99999)
$context="appservicedemo2"
$rgName=$context+"-rg"
$resourceLocation="WestUS2"

$appServicePlan=$context + "-plan"
$appServiceName=$context

$storageAccountName=$context+$random
$storageContainer=$context + "backup"
$backupname="appbackup"
$expiryInMonths = 1

# 0. Incase if you are running outside of cloud shell then make sure you are logged in to authenticate the requests.
#Connect-AzAccount

# 1. Create a resource group.
New-AzResourceGroup -Name $rgName -Location $resourceLocation

# 2. Create an App Service plan in Standard tier (one backup per day)
New-AzAppServicePlan -ResourceGroupName $rgName -Name $appServicePlan -Location $resourceLocation -Tier Standard

# 3. Create a web application
New-AzWebApp -ResourceGroupName $rgName -Name $appServiceName -Location $resourceLocation -AppServicePlan $appServicePlan

# 4. Create a Storage Account
$storage = New-AzStorageAccount -ResourceGroupName $rgName -Name $storageAccountName -SkuName Standard_LRS -Location $resourceLocation

# 5. Create a storage container
New-AzStorageContainer -Name $storageContainer  -Context $storage.Context

# 6. Generates an SAS token for the storage container, valid for one month.
# 7. URL for SAS is fixed format. So below will give you the fully qulified url
$sasUrl = New-AzStorageContainerSASToken -Name $storageContainer -Permission rwdl -Context $storage.Context -ExpiryTime (Get-Date).AddMonths($expiryInMonths) -FullUri

# 8. Create backup, We are in Standard SKU (one backup per day)
Edit-AzWebAppBackupConfiguration -ResourceGroupName $rgName -Name $appServiceName -StorageAccountUrl $sasUrl -FrequencyInterval 1 -FrequencyUnit Day -KeepAtLeastOneBackup -RetentionPeriodInDays 10

# 9. List statuses of all backups that are complete or currently executing.
Get-AzWebAppBackupList -ResourceGroupName $rgName -Name $appServiceName

# 10. Delete resource group (Uncomment and run below line, once all test is completed to avoid billing.)
#Remove-AzResourceGroup -Name $rgName -Force


