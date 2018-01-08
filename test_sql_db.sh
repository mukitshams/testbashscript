#!/bin/bash

# Set an admin login and password for your database
export adminlogin=dbadmin
export password=Test123%$
export dbname=mmukittestdb
export rsgroupname=myDBRsGrp
export azlocation=westeurope
export vaultname=mukitvault
# The logical server name has to be unique in the system
export servername=server-$RANDOM
# The ip address range that you want to allow to access your DB
export startip=137.108.4.1
export endip=137.108.5.100

# Create a resource group
az group create \
	--name $rsgroupname \
	--location $azlocation
# Create a key vault
azure provider register Microsoft.KeyVault
azure keyvault create --vault-name $vaultname --resource-group $rsgroupname --location $azlocation
azure keyvault secret set --vault-name $vaultname --secret-name $adminlogin --value $password

# Create a logical server in the resource group
az sql server create \
	--name $servername \
	--resource-group $rsgroupname \
	--location $azlocation  \
	--admin-user $adminlogin \
	--admin-password $password

# Configure a firewall rule for the server
az sql server firewall-rule create \
	--resource-group $rsgroupname \
	--server $servername \
	-n AllowYourIp \
	--start-ip-address $startip \
	--end-ip-address $endip

# Create a database in the server
az sql db create \
	--resource-group $rsgroupname \
	--server $servername \
	--name $dbname \
	--service-objective S0

# Add the Admin account to the SQl instance
az sql server ad-admin create  \
--display-name mds457 \
--object-id 50d8f708-8642-4aaa-8290-6c426bc53a27 \
--resource-group $rsgroupname \
--server-name $servername