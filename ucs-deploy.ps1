$ucsm = "172.22.251.170"
$ucsm_user = "admin"
$ucsm_pass = "Nbv12345"

Import-Module -Name Cisco.UCSManager

$credentials = new-object -typename System.Management.Automation.PSCredential -argumentlist $ucsm_user,$(convertto-securestring -Force -AsPlainText $ucsm_pass)

Connect-Ucs -Name $ucsm -Credential $credentials

Start-UcsTransaction
Get-UcsOrg -Name root | Add-UcsOrg -Name ESX-PROD -Descr "ESX Production" -ModifyPresent
Complete-UcsTransaction

Start-UcsTransaction
$UcsLogicalStorageDiskGroupConfigPolicy = Get-UcsOrg -Name ESX-PROD | Add-UcsLogicalStorageDiskGroupConfigPolicy -ModifyPresent  -Descr "ESX HOST 2 HDD RAID 1" -Name "ESX-HOST-2DSK-HD" -RaidLevel "mirror"
$UcsLogicalStorageDiskGroupConfigPolicy | Add-UcsLogicalStorageDiskGroupQualifier -ModifyPresent -DriveType "HDD" -NumDrives "2" -UseRemainingDisks "no" -XtraProperty @{UseJbodDisks="yes"; }
$UcsLogicalStorageDiskGroupConfigPolicy | Set-UcsLogicalStorageVirtualDriveDef -AccessPolicy "platform-default" -DriveCache "platform-default" -IoPolicy "platform-default" -ReadPolicy "platform-default" -StripSize "platform-default" -WriteCachePolicy "platform-default" -XtraProperty @{Security="no"; } -Force
Complete-UcsTransaction

Start-UcsTransaction
$UcsLogicalStorageProfile = Get-UcsOrg -Name ESX-PROD | Add-UcsLogicalStorageProfile -ModifyPresent  -Descr "ESX HOST 2 DISK HDD" -Name "ESX-COMP-STP"
$UcsLogicalStorageProfile | Add-UcsLogicalStorageDasScsiLun -ModifyPresent -AutoDeploy "auto-deploy" -ExpandToAvail "no" -LocalDiskPolicyName "ESX-HOST-2DSK-HD" -Name "boot" -Size "30"
$UcsLogicalStorageProfile | Add-UcsLogicalStorageDasScsiLun -ModifyPresent -AutoDeploy "auto-deploy" -ExpandToAvail "yes" -LocalDiskPolicyName "ESX-HOST-2DSK-HD" -Name "datastore" -Size "245"
Complete-UcsTransaction

Start-UcsTransaction
$UcsLogicalStorageDiskGroupConfigPolicy = Get-UcsOrg -Name ESX-PROD | Add-UcsLogicalStorageDiskGroupConfigPolicy -ModifyPresent -Descr "ESX HOST 2 HDD RAID 1" -Name "ESX-MGMT-D01-R1" -RaidLevel "mirror"
$UcsLogicalStorageDiskGroupConfigPolicy | Add-UcsLogicalStorageDiskGroupQualifier -ModifyPresent -DriveType "HDD" -NumDrives "2" -UseRemainingDisks "no" -XtraProperty @{UseJbodDisks="yes"; }
$UcsLogicalStorageDiskGroupConfigPolicy | Set-UcsLogicalStorageVirtualDriveDef -AccessPolicy "platform-default" -DriveCache "platform-default" -IoPolicy "platform-default" -ReadPolicy "platform-default" -StripSize "platform-default" -WriteCachePolicy "platform-default" -XtraProperty @{Security="no"; } -Force

$UcsLogicalStorageDiskGroupConfigPolicy = Get-UcsOrg -Name ESX-PROD | Add-UcsLogicalStorageDiskGroupConfigPolicy -ModifyPresent -Descr "ESX HOST 2 HDD RAID 1" -Name "ESX-MGMT-D02-R1" -RaidLevel "mirror"
$UcsLogicalStorageDiskGroupConfigPolicy | Add-UcsLogicalStorageDiskGroupQualifier -ModifyPresent -DriveType "HDD" -NumDrives "2" -UseRemainingDisks "no" -XtraProperty @{UseJbodDisks="yes"; }
$UcsLogicalStorageDiskGroupConfigPolicy | Set-UcsLogicalStorageVirtualDriveDef -AccessPolicy "platform-default" -DriveCache "platform-default" -IoPolicy "platform-default" -ReadPolicy "platform-default" -StripSize "platform-default" -WriteCachePolicy "platform-default" -XtraProperty @{Security="no"; } -Force
Complete-UcsTransaction

Start-UcsTransaction
$UcsLogicalStorageProfile = Get-UcsOrg -Name ESX-PROD | Add-UcsLogicalStorageProfile -ModifyPresent  -Descr "ESX MGMT 4 DISK HDD" -Name "ESX-MGMT-STP"
$UcsLogicalStorageProfile | Add-UcsLogicalStorageDasScsiLun -ModifyPresent -AutoDeploy "auto-deploy" -ExpandToAvail "yes" -LocalDiskPolicyName "ESX-MGMT-D01-R1" -Name "D01" -Size "1"
$UcsLogicalStorageProfile | Add-UcsLogicalStorageDasScsiLun -ModifyPresent -AutoDeploy "auto-deploy" -ExpandToAvail "yes" -LocalDiskPolicyName "ESX-MGMT-D02-R1" -Name "D02" -Size "1"
Complete-UcsTransaction

Start-UcsTransaction
$mo = Get-UcsOrg -Name ESX-PROD | Add-UcsVmediaPolicy -ModifyPresent  -Descr "" -Name "ESXi-6.5a-LD" -PolicyOwner "local" -RetryOnMountFail "yes"
$mo | Add-UcsVmediaMountEntry -ModifyPresent -AuthOption "none" -Description "" -DeviceType "cdd" -ImageFileNam "Vmware-ESXi-6.5a.0-4887370-Custom-Cisco-6.5.0.2-LD.iso" -ImageNameVariable "none" -ImagePath "/" -MappingName "ESXi-6.5a-LD" -MountProtocol "http" -Password "" -RemoteIpAddress "172.22.250.163" -RemotePort 80 -UserId "" -XtraProperty @{RemapOnEject="no"; }
$mo = Get-UcsOrg -Name ESX-PROD | Add-UcsVmediaPolicy -ModifyPresent  -Descr "" -Name "ESXi-6.5a-FF" -PolicyOwner "local" -RetryOnMountFail "yes"
$mo | Add-UcsVmediaMountEntry -ModifyPresent -AuthOption "none" -Description "" -DeviceType "cdd" -ImageFileNam "Vmware-ESXi-6.5a.0-4887370-Custom-Cisco-6.5.0.2-FF.iso" -ImageNameVariable "none" -ImagePath "/" -MappingName "ESXi-6.5a-FF" -MountProtocol "http" -Password "" -RemoteIpAddress "172.22.250.163" -RemotePort 80 -UserId "" -XtraProperty @{RemapOnEject="no"; }

Complete-UcsTransaction

Start-UcsTransaction
Get-UcsOrg -Name ESX-PROD | Add-UcsMacPool -Name "ESX-COMP-MAC-POOL" -AssignmentOrder sequential -Descr "ESX COMP MAC POOL" -ModifyPresent | Add-UcsMacMemberBlock -From 00:25:B5:14:02:80 -To 00:25:B5:14:02:FF -ModifyPresent
Get-UcsOrg -Name ESX-PROD | Add-UcsMacPool -Name "ESX-MGMT-MAC-POOL" -AssignmentOrder sequential -Descr "ESX MGMT MAC POOL" -ModifyPresent | Add-UcsMacMemberBlock -From 00:25:B5:14:02:01 -To 00:25:B5:14:02:7F -ModifyPresent
Complete-UcsTransaction

Start-UcsTransaction
Get-UcsOrg -Name ESX-PROD | Add-UcsNetworkControlPolicy -Name "CDP-ENABLE" -Cdp enabled -Descr "ENABLE CDP" -ModifyPresent
Complete-UcsTransaction

Start-UcsTransaction
$mo = Get-UcsOrg -Name ESX-PROD | Add-UcsVnicTemplate -ModifyPresent  -IdentPoolName "ESX-COMP-MAC-POOL" -Mtu 1500 -Name "comp_vnic-a" -PeerRedundancyTemplName "comp_vnic-b" -RedundancyPairType "primary" -SwitchId "A" -Target "adaptor" -TemplType "updating-template" -NwCtrlPolicyName CDP-ENABLE
$mo | Add-UcsVnicInterface -ModifyPresent -DefaultNet "no" -Name "default"
$mo | Add-UcsVnicInterface -ModifyPresent -DefaultNet "yes" -Name "vlan248"
$mo = Get-UcsOrg -Name ESX-PROD | Add-UcsVnicTemplate -ModifyPresent  -IdentPoolName "ESX-COMP-MAC-POOL" -Mtu 1500 -Name "comp_vnic-b" -PeerRedundancyTemplName "comp_vnic-a" -RedundancyPairType "secondary" -SwitchId "B" -Target "adaptor" -TemplType "updating-template" -NwCtrlPolicyName CDP-ENABLE
$mo | Add-UcsVnicInterface -ModifyPresent -DefaultNet "no" -Name "default"
$mo | Add-UcsVnicInterface -ModifyPresent -DefaultNet "yes" -Name "vlan248"
$mo = Get-UcsOrg -Name ESX-PROD | Add-UcsVnicTemplate -ModifyPresent  -IdentPoolName "ESX-MGMT-MAC-POOL" -Mtu 1500 -Name "mgmt_vnic-a" -PeerRedundancyTemplName "mgmt_vnic-b" -RedundancyPairType "primary" -SwitchId "A" -Target "adaptor" -TemplType "updating-template" -NwCtrlPolicyName CDP-ENABLE
$mo | Add-UcsVnicInterface -ModifyPresent -DefaultNet "no" -Name "default"
$mo | Add-UcsVnicInterface -ModifyPresent -DefaultNet "yes" -Name "vlan248"
$mo = Get-UcsOrg -Name ESX-PROD | Add-UcsVnicTemplate -ModifyPresent  -IdentPoolName "ESX-MGMT-MAC-POOL" -Mtu 1500 -Name "mgmt_vnic-b" -PeerRedundancyTemplName "mgmt_vnic-a" -RedundancyPairType "secondary" -SwitchId "B" -Target "adaptor" -TemplType "updating-template" -NwCtrlPolicyName CDP-ENABLE
$mo | Add-UcsVnicInterface -ModifyPresent -DefaultNet "no" -Name "default"
$mo | Add-UcsVnicInterface -ModifyPresent -DefaultNet "yes" -Name "vlan248"
Complete-UcsTransaction

Start-UcsTransaction
Get-UcsOrg -Name ESX-PROD | Add-UcsUuidSuffixPool -Name "ESX-HOST-UUID-POOL" -AssignmentOrder sequential -Descr "ESX COMPUTE and MGMT UUID POOL" -Prefix 00000000-0000-FFFF -ModifyPresent | Add-UcsUuidSuffixBlock -From 0000-00FF00000001 -To 0000-00FF00000160 -ModifyPresent
Get-UcsOrg -Name ESX-PROD | Add-UcsScrubPolicy -ModifyPresent  -BiosSettingsScrub "no" -Descr "DISK SCRUB FF NO" -DiskScrub "yes" -FlexFlashScrub "no" -Name "DISK-SCRUB-NO-FF"
Get-UcsOrg -Name ESX-PROD | Add-UcsScrubPolicy -ModifyPresent  -BiosSettingsScrub "no" -Descr "DISK SCRUB FF YES" -DiskScrub "yes" -FlexFlashScrub "yes" -Name "DISK-SCRUB-FF"
Complete-UcsTransaction

Start-UcsTransaction
Get-UcsOrg -Name ESX-PROD | Add-UcsLocalDiskConfigPolicy -ModifyPresent  -Descr "LOCAL DISK ANY CONFIG NO FF" -FlexFlashRAIDReportingState "disable" -FlexFlashState "disable" -Mode "any-configuration" -Name "LD-ANY-NO-FF" -ProtectConfig "yes"
Get-UcsOrg -Name ESX-PROD | Add-UcsLocalDiskConfigPolicy -ModifyPresent  -Descr "LOCAL DISK ANY CONFIG FF" -FlexFlashRAIDReportingState "disable" -FlexFlashState "enable" -Mode "any-configuration" -Name "LD-ANY-FF" -ProtectConfig "yes"
Complete-UcsTransaction

Start-UcsTransaction
$mo = Get-UcsOrg -Name ESX-PROD | Add-UcsBootPolicy -ModifyPresent  -BootMode "legacy" -Descr "BOOT FF/CD/DVD" -EnforceVnicName "yes" -Name "BOOT-FF-CDDVD" -RebootOnUpdate "yes"
$mo | Add-UcsLsbootStorage -ModifyPresent -Order 1 | Add-UcsLsbootLocalStorage -ModifyPresent | Add-UcsLsbootUsbFlashStorageImage -ModifyPresent -Order 1
$mo | Add-UcsLsbootVirtualMedia -ModifyPresent -Access "read-only" -LunId "0" -Order 2
$mo | Add-UcsLsbootVirtualMedia -ModifyPresent -Access "read-only-remote-cimc" -LunId "0" -Order 3
Complete-UcsTransaction

Start-UcsTransaction
$mo = Get-UcsOrg -Name ESX-PROD | Add-UcsBootPolicy -ModifyPresent  -BootMode "legacy" -Descr "BOOT LD/CD/DVD" -EnforceVnicName "yes" -Name "BOOT-LD-CDDVD" -RebootOnUpdate "yes"
$mo | Add-UcsLsbootStorage -ModifyPresent -Order 1 | Add-UcsLsbootLocalStorage -ModifyPresent | Add-UcsLsbootLocalDiskImage -ModifyPresent -Order 1
$mo | Add-UcsLsbootVirtualMedia -ModifyPresent -Access "read-only" -LunId "0" -Order 2
$mo | Add-UcsLsbootVirtualMedia -ModifyPresent -Access "read-only-remote-cimc" -LunId "0" -Order 3
Complete-UcsTransaction

Start-UcsTransaction
$mo = Get-UcsOrg -Name ESX-PROD | Add-UcsServerPool -ModifyPresent  -Descr "ESX MGMT HOSTS" -Name "ESX-MGMT-HOST"
$mo | Add-UcsComputePooledRackUnit -ModifyPresent -Id 1

$mo = Get-UcsOrg -Name ESX-PROD | Add-UcsServerPool -ModifyPresent  -Descr "ESX COMP HOSTS" -Name "ESX-COMP-HOST"
$mo | Add-UcsComputePooledSlot -ModifyPresent -ChassisId "2" -SlotId 7
$mo | Add-UcsComputePooledSlot -ModifyPresent -ChassisId "2" -SlotId 8
Complete-UcsTransaction

Start-UcsTransaction
$mo = Get-UcsOrg -Name "ESX-PROD" | Add-UcsServiceProfile -ModifyPresent -Name "ESX-MGMT" -BootPolicyName "BOOT-FF-CDDVD" -ExtIPPoolName "ext-mgmt" -ExtIPState "none" -IdentPoolName "ESX-HOST-UUID-POOL" -LocalDiskPolicyName "LD-ANY-FF" -ScrubPolicyName "DISK-SCRUB-FF" -Type "updating-template" -VmediaPolicyName "ESXi-6.5a-FF"
$mo | Add-UcsServerPoolAssignment -ModifyPresent -Name "ESX-MGMT-HOST" -RestrictMigration "no"
$mo | Add-UcsVnic -Name eth0 -NwTemplName mgmt_vnic-a -Order 1 -ModifyPresent
$mo | Add-UcsVnic -Name eth1 -NwTemplName mgmt_vnic-b -Order 2 -ModifyPresent
$mo | Set-UcsServerPower -State "up" -Force
$mo | Add-UcsLogicalStorageProfileBinding -ModifyPresent -StorageProfileName "ESX-MGMT-STP"

$mo = Get-UcsOrg -Name "ESX-PROD" | Add-UcsServiceProfile -ModifyPresent -Name "ESX-COMP" -BootPolicyName "BOOT-LD-CDDVD" -ExtIPPoolName "ext-mgmt" -ExtIPState "none" -IdentPoolName "ESX-HOST-UUID-POOL" -LocalDiskPolicyName "LD-ANY-NO-FF" -ScrubPolicyName "DISK-SCRUB-NO-FF" -Type "updating-template" -VmediaPolicyName "ESXi-6.5a-LD"
$mo | Add-UcsServerPoolAssignment -ModifyPresent -Name "ESX-COMP-HOST" -RestrictMigration "no"
$mo | Add-UcsVnic -Name eth0 -NwTemplName comp_vnic-a -Order 1 -ModifyPresent
$mo | Add-UcsVnic -Name eth1 -NwTemplName comp_vnic-b -Order 2 -ModifyPresent
$mo | Set-UcsServerPower -State "up" -Force
$mo | Add-UcsLogicalStorageProfileBinding -ModifyPresent -StorageProfileName "ESX-COMP-STP"
Complete-UcsTransaction

Get-UcsOrg -Name ESX-PROD | Get-UcsServiceProfile -Name ESX-COMP | Add-UcsServiceProfileFromTemplate -DestinationOrg ESX-PROD -Prefix ESX-COMP-0 -Count 2
Get-UcsOrg -Name ESX-PROD | Get-UcsServiceProfile -Name ESX-MGMT | Add-UcsServiceProfileFromTemplate -DestinationOrg ESX-PROD -Prefix ESX-MGMT-0 -Count 1

Disconnect-Ucs