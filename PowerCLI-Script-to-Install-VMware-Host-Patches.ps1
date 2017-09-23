########################################
#
# PowerCLI Script to Patch Hosts
# Created by BLiebowitz on 3/4/2016
#
########################################

# Load PowerCLI Modules
if ( !(Get-Module -Name VMware.VimAutomation.Core -ErrorAction SilentlyContinue) ) {
. ?C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1?
}
 
# Select which vCenter you want to connect to
# If you don't have multiple vCenters, you can comment this section out and activate this line:
# $vcenter = "vc01"
Write-host "Select which vCenter to connect to:"
Write-Host ""
Write-Host "1. vc01"
Write-Host "2. vc02"
Write-Host "3. vc03"
Write-Host "4. vc04"
Write-Host "5. vc05"
 
$Ivcenter = read-host ?Select a vCenter Server. Enter Number ?
 
if ($Ivcenter ?eq 1) {
$vcenter = "vc01"
} elseif ($Ivcenter -eq 2) {
$vcenter = "vc02"
} elseif ($Ivcenter -eq 3) {
$vcenter = "vc03"
} elseif ($Ivcenter -eq 4) {
$vcenter = "vc04"
} else {
$vcenter = "vc05"
}
 
write-host ""
Write-Host "You Picked: "$vcenter
write-host ""
start-sleep -s 3
 
# connect to selected vCenter
connect-viserver $vcenter
 
# List hosts to select
write-host ""
Write-host "Choose which vSphere host to Deploy Patches to:"
write-host "(it may take a few seconds to build the list)"
write-host ""
$IHOST = Get-VMhost | Select Name | Sort-object Name
$i = 1
$IHOST | %{Write-Host $i":" $_.Name; $i++}
$DSHost = Read-host "Enter the number for the host to Patch."
$SHOST = $IHOST[$DSHost -1].Name
write-host "you have selected" $SHOST"."
 
# Scan selected host
Scan-inventory -entity $SHOST
 
# Place selected host into Maintenance mode
write-host "Placing host in Maintenance Mode"
Get-VMHost -Name $SHOST | set-vmhost -State Maintenance
 
# Remediate selected host for Host Patches
write-host "Deploying VMware Host Critical & Non Critical Patches"
get-baseline -name *critical* | remediate-inventory -entity $SHOST -confirm:$false
 
# Remediate selected host for an extension or 2nd baseline
# Uncomment if you want to use this section.  I used it to upgrade OMSA.
# write-host "Deploying OMSA 8.2"
# get-baseline -name "OMSA 8.2" | remediate-inventory -entity $SHOST -confirm:$false
 
# Remove selected host from Maintenance mode
write-host "Removing host from Maintenance Mode"
Get-VMHost -Name $SHOST | set-vmhost -State Connected
 
# Display Popup when finished.
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[System.Windows.Forms.MessageBox]::Show("The Patching for " + $SHOST + " is now complete..")