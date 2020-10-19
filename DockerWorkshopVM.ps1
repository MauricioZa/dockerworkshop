# Credential
$VMLocalAdminUser = "dockeradmin"
$VMLocalAdminSecurePassword = ConvertTo-SecureString "@DockerWorkshop2020!!" -AsPlainText -Force

# VM name and location
$LocationName           = "east us 2"
$ResourceGroupName      = "rg-DockerLab-$(Get-Random)"
$ComputerName           = "vm-docker"
$VMName                 = "vm-docker"
$VMSize                 = "Standard_D8s_v3"

# Networking
$DNSNameLabel           = "vm-docker-$(Get-Random)" # mydnsname.eastus2.cloudapp.azure.com
$NetworkName            = "vn-Docker"
$NICName                = "nic-Docker"
$PublicIPAddressName    = "pip-Docker"
$SubnetName             = "sn-Docker"
$SubnetAddressPrefix    = "10.0.0.0/24"
$VnetAddressPrefix      = "10.0.0.0/16"

# Create resource group
New-AzResourceGroup -name $ResourceGroupName -Location $LocationName

# Build network
$SingleSubnet           = New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetAddressPrefix
$Vnet                   = New-AzVirtualNetwork -Name $NetworkName -ResourceGroupName $ResourceGroupName -Location $LocationName -AddressPrefix $VnetAddressPrefix -Subnet $SingleSubnet
$PIP                    = New-AzPublicIpAddress -Name $PublicIPAddressName -DomainNameLabel $DNSNameLabel -ResourceGroupName $ResourceGroupName -Location $LocationName -AllocationMethod Dynamic
$NIC                    = New-AzNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroupName -Location $LocationName -SubnetId $Vnet.Subnets[0].Id -PublicIpAddressId $PIP.Id

# Setup VM
$Credential             = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword);
$VirtualMachine         = New-AzVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine         = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $ComputerName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine         = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id
$VirtualMachine         = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName "MicrosoftWindowsDesktop" -Offer "Windows-10" -Skus "20h1-pro"  -version "19041.508.2009070256"

# Create VM
New-AzVM -ResourceGroupName $ResourceGroupName -Location $LocationName -VM $VirtualMachine -Verbose

# Publish information

$pip = get-azpublicipaddress -resourcegroupname $resourcegroupname
write-host "The public IP is        :   [$($pip.ipaddress)]" -foregroundcolor green
write-host "The username is         :   dockeradmin" -foregroundcolor green
write-host "The password is         :   @DockerWorkshop2020!!" -foregroundcolor green
write-host "The resource group is   :   [$ResourceGroupName]" -foregroundcolor green
