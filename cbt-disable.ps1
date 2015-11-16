<#
.DESCRIPTION
  	This script copies searches for VM's that have CBT enabled and have virtual disks greater then 120GB and resets CBT to false.
	This was created in response to the CBT bug referenced in http://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=2090639
	Most backup products will automatically enable CBT when a job is run, other wise it shoudl be re-enabled to allow the 'incremental' functionality to be used.
	Requires PowerCLI. 
.NOTES
  	Version:        1.0
  	Author:         Brett Sinclair
  	Github:         http://www.github.com/brett-sinclair
  	Twitter:        @Pragmatic_IO
  	Website:        http://www.pragmaticio.com
#>
#define the target VM's. Change to Get-DataCenter/Get-CLuster etc depending on the scope required.
$targetvms=get-vm | where {$_.ExtensionData.Config.ChangeTrackingEnabled -eq $true -AND $_.HardDisks.CapacityGB -gt 120}
$vmspec = New-Object VMware.Vim.VirtualMachineConfigSpec 
$vmspec.ChangeTrackingEnabled = $false
foreach($vm in $targetvms){ 
	$vm.ExtensionData.ReconfigVM($vmspec) 
	$snap=$vm | New-Snapshot -Name 'CBT reset kb2090639' 
	$snap | Remove-Snapshot -confirm:$false}
