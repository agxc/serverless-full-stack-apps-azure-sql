# 1. Deploy database 
$adminSqlLogin = "cloudadmin"
$password = Read-Host "Your username is 'cloudadmin'. Please enter a password for your Azure SQL Database server that meets the password requirements"
# Prompt for local ip address
# $ipAddress = Read-Host "Disconnect your VPN, open PowerShell on your machine and run '(Invoke-WebRequest -Uri "https://ipinfo.io/ip").Content'. Please enter the value (include periods) next to 'Address': "

# $ipAddress = (Invoke-WebRequest -Uri "https://ipinfo.io/ip").Content
$ipAddress = "203.219.214.117"
# Get resource group and location and random string
$resourceGroupName = "serverless-fullstack-bus-app"
$resourceGroup = Get-AzResourceGroup | Where ResourceGroupName -like $resourceGroupName
# $uniqueID = Get-Random -Minimum 100000 -Maximum 1000000
$uniqueID = 834169
$location = $resourceGroup.Location
# The logical server name has to be unique in the system
$serverName = "bus-server$($uniqueID)"
# The sample database name
$databaseName = "bus-db"
# Create a new server with a system wide unique server name
$server = New-AzSqlServer -ResourceGroupName $resourceGroupName `
    -ServerName $serverName `
    -Location $location `
    -SqlAdministratorCredentials $(New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $adminSqlLogin, $(ConvertTo-SecureString -String $password -AsPlainText -Force))
# Create a server firewall rule that allows access from the specified IP range and all Azure services
$serverFirewallRule = New-AzSqlServerFirewallRule `
    -ResourceGroupName $resourceGroupName `
    -ServerName $serverName `
    -FirewallRuleName "AllowedIPs" `
    -StartIpAddress $ipAddress -EndIpAddress $ipAddress 
$allowAzureIpsRule = New-AzSqlServerFirewallRule `
    -ResourceGroupName $resourceGroupName `
    -ServerName $serverName `
    -AllowAllAzureIPs
# Create a database
$database = New-AzSqlDatabase  -ResourceGroupName $resourceGroupName `
    -ServerName $serverName `
    -DatabaseName $databaseName `
    -Edition "GeneralPurpose" -Vcore 4 -ComputeGeneration "Gen5" `
    -ComputeModel Serverless -MinimumCapacity 0.5



# In the azure cloud, run the following command
<#
TERM=dumb
sqlcmd -S <server-name>.database.windows.net -P <password> -U cloudadmin -d bus-db
#>


# In sqlcmd to the right, copy and paste the following script to import the flat file of routes data. For more details on what is done here, you can optionally review the previous module in the associated learning path.

<#
ALTER DATABASE SCOPED CREDENTIAL AzureBlobCredentials
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = 'sp=r&st=2021-03-12T00:47:24Z&se=2025-03-11T07:47:24Z&spr=https&sv=2020-02-10&sr=c&sig=BmuxFevKhWgbvo%2Bj8TlLYObjbB7gbvWzQaAgvGcg50c%3D';
DROP EXTERNAL DATA SOURCE RouteData;
CREATE EXTERNAL DATA SOURCE RouteData
WITH (
    TYPE = blob_storage,
    LOCATION = 'https://azuresqlworkshopsa.blob.core.windows.net/bus',
    CREDENTIAL = AzureBlobCredentials
);
DELETE FROM dbo.[Routes];
INSERT INTO dbo.[Routes]
([Id], [AgencyId], [ShortName], [Description], [Type])
SELECT 
[Id], [AgencyId], [ShortName], [Description], [Type]
FROM
openrowset
(
    bulk 'routes.txt', 
    data_source = 'RouteData', 
    formatfile = 'routes.fmt', 
    formatfile_data_source = 'RouteData', 
    firstrow=2,
    format='csv'
) t;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
INSERT INTO dbo.[GeoFences] 
    ([Name], [GeoFence]) 
VALUES
    ('Crossroads', 'POLYGON ((-122.14797019958493 47.6330073774962,-122.1187877655029 47.63289169873832,-122.11861610412595 47.61518983198667,-122.14891433715819 47.61542126760543,-122.14797019958493 47.6330073774962))');
INSERT INTO dbo.[MonitoredRoutes] (RouteId) VALUES (100113);
INSERT INTO dbo.[MonitoredRoutes] (RouteId) VALUES (100136);
GO
#>

# Finally, select Ctrl+C to exit sqlcmd and run pwsh to switch back to PowerShell.

