<#	
	.SYNOPSIS
	Get-VMwareversion
	
	.DESCRIPTION
		Displays version Information on installed VMware version
	
	.EXAMPLE
		PS C:\> Get-VMwareversion
	
	.NOTES
		requires VMXtoolkit loaded
#>
function Get-VMwareVersion
 {
	[CmdletBinding()]
	param ()
begin {}
process {
    $object = New-Object -TypeName psobject
    $object | Add-Member -MemberType NoteProperty -Name Version -Value ([string]($vmwareversion))
    $object | Add-Member -MemberType NoteProperty -Name Major -Value ($vmwaremajor)
    $object | Add-Member -MemberType NoteProperty -Name Minor -Value ($vmwareminor)
    $object | Add-Member -MemberType NoteProperty -Name Build -Value ($vmwarebuild)
    }
end {
    Write-Output $object
    }
} # end get-vmxvesrion

function Get-VMXHWVersion
{
		[CmdletBinding(DefaultParametersetName = "2")]
	param (
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]	
	[Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME')]$VMXName,
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$config,
	[Parameter(ParameterSetName = "3", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$vmxconfig
	)
	begin
	{
	}
	process
	{
		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{ $vmxconfig = Get-VMXConfig -VMXName $VMXname }
			"2"
			{ $vmxconfig = Get-VMXConfig -config $config }
		}
		$ObjectType = "HWversion"
		$ErrorActionPreference = "silentlyContinue"
		Write-Verbose -Message "getting $ObjectType"
		$patterntype = "virtualHW.version"
		$Value = Search-VMXPattern -Pattern "$patterntype" -vmxconfig $vmxconfig -value "HWVersion" -patterntype $patterntype
		$object = New-Object -TypeName psobject
		$Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
		$object | Add-Member -MemberType NoteProperty -Name $ObjectType -Value $Value.HWVersion
		Write-Output $Object
	}
	end { }

}#end get-vmxHWversion

function Get-VMXConfigVersion
{
		[CmdletBinding(DefaultParametersetName = "2")]
	param (
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]	
	[Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME')]$VMXName,
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$config,
	[Parameter(ParameterSetName = "3", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$vmxconfig
	)
	begin
	{
	}
	process
	{
		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{ $vmxconfig = Get-VMXConfig -VMXName $VMXname }
			"2"
			{ $vmxconfig = Get-VMXConfig -config $config }
		}
		$ObjectType = "ConfigVersion"
		$ErrorActionPreference = "silentlyContinue"
		Write-Verbose -Message "getting $ObjectType"
		$patterntype = "config.version"
		$Value = Search-VMXPattern -Pattern "$patterntype" -vmxconfig $vmxconfig -value "Config" -patterntype $patterntype
		$object = New-Object -TypeName psobject
		$Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
		$object | Add-Member -MemberType NoteProperty -Name $ObjectType -Value $Value.config
		Write-Output $Object
	}
	end { }

}#end get-vmxConfigVersion

<#	
	.SYNOPSIS
	    Get-VMXInfo
	
	.DESCRIPTION
		Displays Information on Virtual machines
	
	.EXAMPLE
		PS C:\> Get-VMXinfo
    .EXAMPLE
        Memory Consumption
        Memory: the Amount of Memory configured in .vmx for the Virtual Machine
        PhysicalMemory(WorkingSet) :The amount of physical memory, in bytes, allocated for the associated process
        VirtualMemory: The amount of virtual memory, in bytes, allocated for the associated process
        Privatememory: The amount of memory, in bytes, allocated for the associated process that cannot be shared with other processes
        NonpagedMemory: (perfmon: Nonpaged Bytes )The amount of system memory, in bytes, allocated for the associated process that cannot be written to the virtual memory paging file
        Pagedmemory: The amount of memory, in bytes, allocated in the virtual memory paging file for the associated process
        Privatememory: The amount of memory, in bytes, allocated for the associated process that cannot be shared with other processes
        PagedsystemMemory: The amount of system memory, in bytes, allocated for the associated process that can be written to the virtual memory paging file
	.NOTES
		requires VMXtoolkit loaded
#>

function Get-VMXInfo {
	[CmdletBinding(DefaultParametersetName = "2")]
	param (
		
		[Parameter(ParameterSetName = "2", Mandatory = $true,ValueFromPipelineByPropertyName = $true)][Alias('NAME')]$VMXName,
		[Parameter(ParameterSetName = "2", Mandatory = $true, ValueFromPipelineByPropertyName = $true)][ValidateScript({ Test-Path -Path $_ })]$Path = "$vmxdir\$VMXName",
		[Parameter(ParameterSetName = "2", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]$config
	#	[Parameter(ParameterSetName = "3", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$vmxconfig

	)
	Begin
	{

	}
	process
	{
		switch ($PsCmdlet.ParameterSetName)
		{
		"1"
			{ $vmxconfig = Get-VMXConfig -VMXName $VMXname -Path $Path }
		
		"2"
			{ $vmxconfig = Get-VMXConfig -config $config }
		}
		if ($vmxconfig)
		{
		$ErrorActionPreference ="silentlyContinue"
		write-verbose "processing $vmxname"
        write-verbose $config
        $Processes = ""
		[bool]$ismyvmx = $false
		[uint64]$SizeOnDiskinMB = ""
		$Processes = get-process -id (Get-WmiObject -Class win32_process | where commandline -match $vmxname).handle
			foreach ($Process in $Processes)
			{
				if ($Process.ProcessName -ne "vmware")
				{
					write-verbose "processing objects for $vmxname"
					$vmxconfig = Get-VMXConfig -config $config
					$object = New-Object psobject
					$object | Add-Member VMXName ([string]$vmxname)
					$object | Add-Member DisplayName (Get-VMXDisplayName -vmxconfig $vmxconfig).DisplayName
					$object | Add-Member GuestOS (Get-VMXGuestOS -vmxconfig $vmxconfig).GuestOs
					$object | Add-Member Processor (Get-VMXProcessor -vmxconfig $vmxconfig).Processor
					$object | Add-Member Memory (Get-VMXmemory -vmxconfig $vmxconfig).Memory
					$object | Add-Member State $state
					if ($Processes)
					{
						$object | Add-Member ProcessName ([string]$Process.ProcessName)
						$object | Add-Member VirtualMemory ([uint64]($Process.VirtualMemorySize64 / 1MB))
                        $object | Add-Member PhysicaldMemory ([uint64]($Process.WorkingSet64 / 1MB))
						$object | Add-Member PrivateMemory ([uint64]($Process.PrivateMemorySize64 / 1MB))
                        $object | Add-Member PagedMemory ([uint64]($Process.PagedMemorySize64 / 1MB))
                        $object | Add-Member PagedsystemMemory ([uint64]($Process.PagedSystemMemorySize64 / 1MB))
                        $object | Add-Member PeakPagedMemory ([uint64]($Process.PeakPagedMemorySize64 / 1MB))
                        $object | Add-Member PeakPhysicalMemory ([uint64]($Process.PeakWorkingSet64 / 1MB))
                        $object | Add-Member NonPagedMemory ([uint64]($Process.NonpagedSystemMemorySize64 / 1MB))
                        $object | Add-Member CPUtime ($Process.CPU)
					}
					$object | Add-Member NetWork (Get-VMXNetwork -vmxconfig $vmxconfig).network
					$object | Add-Member NIC (Get-VMXNetworkAdapter -vmxconfig $vmxconfig | select Adapter,type )
					$object | Add-Member NetworkConnection -Value (Get-VMXNetworkConnection -vmxconfig $vmxconfig).NetworkConnection
					
					$object | Add-Member Configfile $config
					$object | Add-Member ScsiController (Get-VMXScsiController -vmxconfig $vmxconfig).ScsiController
					$object | Add-Member -MemberType NoteProperty -Name ScsiDisk -Value (Get-VMXScsiDisk -vmxconfig $vmxconfig | select SCSIAddress, Disk)
					<#foreach ($myvmx in $VMXlist)
					{
						Write-Verbose -Message "Comparing $Name with $myvmx"
						Write-Verbose -Message $myvmxNAME
						Write-Verbose -Message $Name
						if ($myvmx -match $Name)
						{
							$ismyvmx = $true
							$SizeOnDiskinMB = ((Get-ChildItem -Path $vmxdir\$Name -Filter "Master*.vmdk").Length /1MB)
						}#end-if myvmx
					} #end foreach myvmx #>
					#$object | Add-Member "Is$Myself" ([bool]$ismyvmx)
					# $object | Add-Member SizeOnDiskinMB ([uint64]$SizeOnDiskinMB)
					# [array]$VMXinfo += $object
					Write-Output $object
					
				} #end if $Process.ProcessName -ne "vmware"
			} #  end foreach process
		}# end if $VMXconfig
	} # endprocess
	# 
} # end get-VMXinfo


<#	
	.SYNOPSIS
		A brief description of the Get-VMXmemory function.
	
	.DESCRIPTION
		A detailed description of the Get-VMXmemory function.
	
	.PARAMETER config
		A description of the config parameter.
	
	.PARAMETER Name
		A description of the VMXname parameter.
	
	.PARAMETER vmxconfig
		A description of the vmxconfig parameter.
	
	.EXAMPLE
		PS C:\> Get-VMXmemory -config $value1 -Name $value2
	
	.NOTES
		Additional information about the function.
#>
function Get-VMXmemory {
	[CmdletBinding(DefaultParametersetName = "2")]
	param (
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]	
	[Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME')]$VMXName,
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$config,
	[Parameter(ParameterSetName = "3", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$vmxconfig
	)
	begin
	{
	}
	process
	{
		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{ $vmxconfig = Get-VMXConfig -VMXName $VMXname }
			"2"
			{ $vmxconfig = Get-VMXConfig -config $config }
		}
		$ObjectType = "Memory"
		$ErrorActionPreference = "silentlyContinue"
		Write-Verbose -Message "getting $ObjectType"
		#$vmxconfig = Get-VMXConfig -VMXName $VMXname
		$patterntype = "memsize"
		$Value = Search-VMXPattern -Pattern "$patterntype" -vmxconfig $vmxconfig -value "Memory" -patterntype $patterntype
		$object = New-Object -TypeName psobject
		$Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
		$object | Add-Member -MemberType NoteProperty -Name $ObjectType -Value $Value.memory
		Write-Output $Object
	}
	end { }
} #end get-vmxmemory

<#	
	.SYNOPSIS
		A brief description of the Get-VMXProcessor function.
	
	.DESCRIPTION
		A detailed description of the Get-VMXProcessor function.
	
	.PARAMETER config
		A description of the config parameter.
	
	.PARAMETER Name
		A description of the VMXname parameter.
	
	.PARAMETER vmxconfig
		A description of the vmxconfig parameter.
	
	.EXAMPLE
		PS C:\> Get-VMXProcessor -config $value1 -Name $value2
	
	.NOTES
		Additional information about the function.
#>
function Get-VMXProcessor {
	
	#
	[CmdletBinding(DefaultParametersetName = "2")]
	param (
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]	
	[Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME')]$VMXName,
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$config,
	[Parameter(ParameterSetName = "3", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$vmxconfig
	)
	begin
	{
	}
	process
	{
		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{ $vmxconfig = Get-VMXConfig -VMXName $VMXname }
			"2"
			{ $vmxconfig = Get-VMXConfig -config $config }
		}	$ErrorActionPreference = "silentlyContinue"
		$Objecttype = "Processor"
		Write-Verbose -Message "getting $ObjectType"
		$patterntype = "numvcpus"
		$Value = Search-VMXPattern -Pattern "$patterntype" -vmxconfig $vmxconfig -value $patterntype -patterntype $patterntype
		# $vmxconfig = Get-VMXConfig -VMXName $VMXname
		$object = New-Object -TypeName psobject
		$Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
		$object | Add-Member -MemberType NoteProperty -Name $ObjectType -Value $Value.numvcpus
		Write-Output $Object
	}
	end { }
	
} #end Get-VMXProcessor

<#	
	.SYNOPSIS
		A brief description of the Get-VMXScsiDisk function.
	
	.DESCRIPTION
		A detailed description of the Get-VMXScsiDisk function.
	
	.PARAMETER config
		A description of the config parameter.
	
	.PARAMETER Name
		A description of the VMXname parameter.
	
	.PARAMETER vmxconfig
		A description of the vmxconfig parameter.
	
	.EXAMPLE
		PS C:\> Get-VMXScsiDisk -config $value1 -Name $value2
	
	.NOTES
		Additional information about the function.
#>
function Get-VMXScsiDisk{
	
	#
	[CmdletBinding(DefaultParametersetName = "2")]
	param (
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]	
	[Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME')]$VMXName,
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$config,
	[Parameter(ParameterSetName = "3", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$vmxconfig
	)
	begin
	{
	}
	process
	{
		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{ $vmxconfig = Get-VMXConfig -VMXName $VMXname }
			"2"
			{ $vmxconfig = Get-VMXConfig -config $config }
		}
		

		$Patterntype = ".fileName"
		$ObjectType = "SCSIDisk"
		
		$ErrorActionPreference = "silentlyContinue"
		Write-Verbose -Message $ObjectType
		$Value = Search-VMXPattern -Pattern "scsi\d{1,2}:\d{1,2}.fileName" -vmxconfig $vmxconfig -name "SCSIAddress" -value "Disk" -patterntype $Patterntype
		foreach ($Disk in $value)
		{
			$object = New-Object -TypeName psobject
			$object | Add-Member -MemberType NoteProperty -Name VMXname -Value $VMXname
			$object | Add-Member -MemberType NoteProperty -Name SCSIAddress -Value $Disk.ScsiAddress
			$object | Add-Member -MemberType NoteProperty -Name Disk -Value $Disk.disk
			Write-Output $Object
		}
	}
	end { }
} #end Get-VMXScsiDisk

<#	
	.SYNOPSIS
		A brief description of the Get-VMXScsiController function.
	
	.DESCRIPTION
		A detailed description of the Get-VMXScsiController function.
	
	.PARAMETER config
		A description of the config parameter.
	
	.PARAMETER Name
		A description of the VMXname parameter.
	
	.PARAMETER vmxconfig
		A description of the vmxconfig parameter.
	
	.EXAMPLE
		PS C:\> Get-VMXScsiController -config $value1 -Name $value2
	
	.NOTES
		Additional information about the function.
#>
function Get-VMXScsiController {

	#
	[CmdletBinding(DefaultParametersetName = "2")]
param (
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]	
	[Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME')]$VMXName,
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$config,
	[Parameter(ParameterSetName = "3", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$vmxconfig
	)
	begin
	{
	}
	process
		{
			switch ($PsCmdlet.ParameterSetName)
			{
				"1"
				{ $vmxconfig = Get-VMXConfig -VMXName $VMXname }
				"2"
				{ $vmxconfig = Get-VMXConfig -config $config }
			}
		
		$ObjectType = "SCSIController"
		$patterntype = ".virtualDev"
		$ErrorActionPreference = "silentlyContinue"
		Write-Verbose -Message "getting $ObjectType"
		$Value = Search-VMXPattern -Pattern "scsi\d{1,2}$patterntype" -vmxconfig $vmxconfig -name "Controller" -value "Type" -patterntype $patterntype
		$object = New-Object -TypeName psobject
		$Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXname
		$object | Add-Member -MemberType NoteProperty -Name $ObjectType -Value $Value
		Write-Output $Object
	}
	end
	{
	}
}#end Get-VMXScsiController

<#	
	.SYNOPSIS
		A brief description of the Get-VMXideDisk function.
	
	.DESCRIPTION
		A detailed description of the Get-VMXideDisk function.
	
	.PARAMETER config
		A description of the config parameter.
	
	.PARAMETER Name
		A description of the VMXname parameter.
	
	.PARAMETER vmxconfig
		A description of the vmxconfig parameter.
	
	.EXAMPLE
		PS C:\> Get-VMXideDisk -config $value1 -Name $value2
	
	.NOTES
		Additional information about the function.
#>
function Get-VMXideDisk{
	[CmdletBinding(DefaultParametersetName = "2")]
	param (
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]	
	[Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME')]$VMXName,
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$config,
	[Parameter(ParameterSetName = "3", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$vmxconfig
	)
	begin
	{
	}
	process
	{
		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{ $vmxconfig = Get-VMXConfig -VMXName $VMXname }
			"2"
			{ $vmxconfig = Get-VMXConfig -config $config }
		}
		$ObjectType = "IDEDisk"
		$Patterntype = ".fileName"
		$ErrorActionPreference = "silentlyContinue"
		Write-Verbose -Message "getting $ObjectType"
		$Value = Search-VMXPattern -Pattern "ide\d{1,2}:\d{1,2}$Patterntype" -vmxconfig $vmxconfig -name "IDEAddress" -value "Disk" -patterntype $Patterntype
		$object = New-Object -TypeName psobject
		$Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
		$object | Add-Member -MemberType NoteProperty -Name $ObjectType -Value $Value
		Write-Output $Object
	}
	end { }
}#end Get-VMXIDEDisk

<#	
	.SYNOPSIS
		A brief description of the Search-VMXPattern function.
	
	.DESCRIPTION
		A detailed description of the Search-VMXPattern function.
	
	.PARAMETER name
		A description of the VMXname parameter.
	
	.PARAMETER pattern
		A description of the pattern parameter.
	
	.PARAMETER patterntype
		A description of the patterntype parameter.
	
	.PARAMETER value
		A description of the value parameter.
	
	.PARAMETER vmxconfig
		A description of the vmxconfig parameter.
	
	.EXAMPLE
		PS C:\> Search-VMXPattern -name $value1 -pattern $value2
	
	.NOTES
		Additional information about the function.
#>
function Search-VMXPattern  {
param($pattern,$vmxconfig,$name,$value,$patterntype,[switch]$nospace)
#[array]$mypattern
$getpattern = $vmxconfig| where {$_ -match $pattern}
Write-Verbose "Patterncount : $getpattern.count"
Write-Verbose "Patterntype : $patterntype"
	foreach ($returnpattern in $getpattern)
	{
		Write-Verbose "returnpattern : $returnpattern"
		$returnpattern = $returnpattern.Replace('"', '')
		if ($nospace.IsPresent)
		{
			Write-Verbose "Clearing Spaces"
			$returnpattern = $returnpattern.Replace(' ', '')#
			$returnpattern = $returnpattern.split("=")
		}
		else
		{
			$returnpattern = $returnpattern.split(" = ")
		}
		Write-Verbose "returnpattern: $returnpattern"
		Write-Verbose $returnpattern.count
$nameobject = $returnpattern[0]
Write-Verbose "nameobject fro returnpattern $nameobject "
$nameobject = $nameobject.Replace($patterntype,"")
$valueobject  = ($returnpattern[$returnpattern.count-1])
Write-Verbose "Search returned Nameobject: $nameobject"
Write-Verbose "Search returned Valueobject: $valueobject"
# If ($getpattern.count -gt 1) {
$object = New-Object psobject
$object | Add-Member -MemberType NoteProperty -Name $name -Value $nameobject
$object | Add-Member -MemberType NoteProperty -Name $value -Value $valueobject
Write-Output $object
# }
# else
# { Write-Output $valueobject
# }
}#end foreach
# return $mypattern
}#end search-pattern

<#	
	.SYNOPSIS
		A brief description of the Get-VMXConfig function.
	
	.DESCRIPTION
		A detailed description of the Get-VMXConfig function.
	
	.PARAMETER config
		A description of the config parameter.
	
	.PARAMETER Name
		A description of the VMXname parameter.
	
	.EXAMPLE
		PS C:\> Get-VMXConfig -config $value1 -Name $value2
	
	.NOTES
		Additional information about the function.
#>
function Get-VMXConfig{
	[CmdletBinding(DefaultParametersetName = "2")]
param
(

	[Parameter(ParameterSetName = "1", Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME')]$VMXName,
#	[Parameter(ParameterSetName = "2", Mandatory = $false, Position = 1,  ValueFromPipelineByPropertyName = $True)][Alias('NAME')]$VMXName,
	[Parameter(ParameterSetName = "1", Mandatory = $true, ValueFromPipelineByPropertyName = $true)][ValidateScript({ Test-Path -Path $_ })]$Path,
	[Parameter(ParameterSetName = "2", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]$config
#	[Parameter(ParameterSetName = "2", Mandatory = $true, Position = 2, ValueFromPipelineByPropertyName = $True)]$config

)
	begin
	{
		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{ $config = "$path\$VMXname.vmx" }
		}
	}
	process
{
$vmxconfig = Get-Content $config
Write-Output $vmxconfig
}
end{}
}#end get-vmxconfig

<#	
	.SYNOPSIS
		A brief description of the Get-VMXNetworkAdapter function.
	
	.DESCRIPTION
		A detailed description of the Get-VMXNetworkAdapter function.
	
	.PARAMETER config
		A description of the config parameter.
	
	.PARAMETER Name
		A description of the Name parameter.
	
	.PARAMETER vmxconfig
		A description of the vmxconfig parameter.
	
	.EXAMPLE
		PS C:\> Get-VMXNetworkAdapter -config $value1 -Name $value2
	
	.NOTES
		Additional information about the function.
#>
function Get-VMXNetworkAdapter{
	
	#
	[CmdletBinding(DefaultParametersetName = "2")]
	param (
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]	
	[Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME')]$VMXName,
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$config,
	[Parameter(ParameterSetName = "3", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$vmxconfig
	)
	begin
	{
	}
	process
	{
		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{ $vmxconfig = Get-VMXConfig -VMXName $VMXName }
			"2"
			{ $vmxconfig = Get-VMXConfig -config $config }
		}	
		$ObjectType = "NetworkAdapter"
		$patterntype = ".virtualDev"
		$ErrorActionPreference = "silentlyContinue"
		Write-Verbose -Message "getting $ObjectType"
		$Value = Search-VMXPattern -Pattern "ethernet\d{1,2}.virtualdev" -vmxconfig $vmxconfig -name "Adapter" -value "Type" -patterntype $patterntype
		foreach ($Adapter in $value)
		{
			$object = New-Object -TypeName psobject
			$object | Add-Member -MemberType NoteProperty -Name VMXname -Value $VMXname
			$object | Add-Member -MemberType NoteProperty -Name Adapter -Value $Adapter.Adapter
			$object | Add-Member -MemberType NoteProperty -Name Type -Value $Adapter.type
			Write-Output $Object
		}
	}
	end { }
}#end Get-VMXNetworkAdapter

<#	
	.SYNOPSIS
		A brief description of the Get-VMXNetwork function.
	
	.DESCRIPTION
		A detailed description of the Get-VMXNetwork function.
	
	.PARAMETER config
		A description of the config parameter.
	
	.PARAMETER Name
		A description of the VMXname parameter.
	
	.PARAMETER vmxconfig
		A description of the vmxconfig parameter.
	
	.EXAMPLE
		PS C:\> Get-VMXNetwork -config $value1 -Name $value2
	
	.NOTES
		Additional information about the function.
#>
function Get-VMXNetwork
{
	[CmdletBinding(DefaultParametersetName = "2")]
param (
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]	
	[Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME')]$VMXName,
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$config,
	[Parameter(ParameterSetName = "3", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$vmxconfig
)
begin
{
}
process
{
	switch ($PsCmdlet.ParameterSetName)
	{
		"1"
		{ $vmxconfig = Get-VMXConfig -VMXName $VMXName }
		"2"
		{ $vmxconfig = Get-VMXConfig -config $config }
	}
	$patterntype = ".vnet"
	$ObjectType = "Network"
	$ErrorActionPreference = "silentlyContinue"
	Write-Verbose -Message "getting Network Controller"
	$Valuelist = Search-VMXPattern -Pattern "ethernet\d{1,2}$patterntype" -vmxconfig $vmxconfig -name "Adapter" -value "Network" -patterntype $patterntype
		foreach ($Value in $Valuelist)
		{
			$object = New-Object -TypeName psobject
			$Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
			$object | Add-Member -MemberType NoteProperty -Name Network -Value $Value.Network
			$object | Add-Member -MemberType NoteProperty -Name Adapter -Value $Value.Adapter
			
			Write-Output $Object
		}
	}
	end { }
}#end Get-VMXNetwork

function Get-VMXNetworkConnection{
	
	#
	[CmdletBinding(DefaultParametersetName = "2")]
	param (
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]	
	[Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME')]$VMXName,
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$config,
	[Parameter(ParameterSetName = "3", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$vmxconfig
	)
	begin
	{
	}
	process
	{
		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{ $vmxconfig = Get-VMXConfig -VMXName $VMXname }
			"2"
			{ $vmxconfig = Get-VMXConfig -config $config }
		}
		$ObjectType = "NetworkConnection"
		$ErrorActionPreference = "silentlyContinue"
		Write-Verbose -Message "getting $ObjectType"
		$patterntype = ".connectionType"
		$value = Search-VMXPattern -Pattern "ethernet\d{1,2}$patterntype" -vmxconfig $vmxconfig -name "Adapter" -value "ConnectionType" -patterntype $patterntype
		$object = New-Object -TypeName psobject
		$Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
		$object | Add-Member -MemberType NoteProperty -Name $ObjectType -Value $Value
		Write-Output $Object
		
	}
	end { }
}#end Get-VMXNetwork

<#	
	.SYNOPSIS
		A brief description of the Get-VMXGuestOS function.
	
	.DESCRIPTION
		A detailed description of the Get-VMXGuestOS function.
	
	.PARAMETER config
		A description of the config parameter.
	
	.PARAMETER Name
		A description of the VMXname parameter.
	
	.PARAMETER vmxconfig
		A description of the vmxconfig parameter.
	
	.EXAMPLE
		PS C:\> Get-VMXGuestOS -config $value1 -Name $value2
	
	.NOTES
		Additional information about the function.
#>
function Get-VMXGuestOS{
	[CmdletBinding(DefaultParametersetName = "2")]
	param (
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]	
	[Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME')]$VMXName,
	[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$config,
	[Parameter(ParameterSetName = "3", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$vmxconfig
	)
	begin
	{
	}
	process
	{
		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{ $vmxconfig = Get-VMXConfig -VMXName $VMXname }
			"2"
			{ $vmxconfig = Get-VMXConfig -config $config }
		}
		$objectType = "GuestOS"
		$ErrorActionPreference = "silentlyContinue"
		Write-Verbose -Message "getting GuestOS"
		$patterntype = "GuestOS"
		$Value = Search-VMXPattern -Pattern "$patterntype" -vmxconfig $vmxconfig -value "GuestOS" -patterntype $patterntype
		$object = New-Object -TypeName psobject
		$Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
		$object | Add-Member -MemberType NoteProperty -Name $ObjectType -Value $Value.Guestos
		Write-Output $Object
	}
	
	end { }
}#end Get-VMXNetwork

<#	
	.SYNOPSIS
		A brief description of the Get-VMXDisplayName function.
	
	.DESCRIPTION
		A detailed description of the Get-VMXDisplayName function.
	
	.PARAMETER config
		A description of the config parameter.
	
	.PARAMETER Name
		A description of the VMXname parameter.
	
	.PARAMETER vmxconfig
		A description of the vmxconfig parameter.
	
	.EXAMPLE
		PS C:\> Get-VMXDisplayName -config $value1 -Name $value2
	
	.NOTES
		Additional information about the function.
#>
function Get-VMXDisplayName
{
	[CmdletBinding(DefaultParametersetName = "2")]
	param (
		[Parameter(ParameterSetName = "1", Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $True)][Alias('NAME')]$VMXName,
		[Parameter(ParameterSetName = "1", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]
		[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$config,
		[Parameter(ParameterSetName = "3", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$vmxconfig
	)
	begin
	{
	}
	process
	{
		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{ $vmxconfig = Get-VMXConfig -VMXName $VMXname $config }
			"2"
			{ $vmxconfig = Get-VMXConfig -config $config }
		}	$ObjectType = "Displayname"
		$ErrorActionPreference = "silentlyContinue"
		Write-Verbose -Message "getting $ObjectType"
		$patterntype = "displayname"
		$Value = Search-VMXPattern -Pattern "$patterntype" -vmxconfig $vmxconfig -value $patterntype -patterntype $patterntype
		$object = New-Object -TypeName psobject
		# $Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
		$object | Add-Member -MemberType NoteProperty -Name $ObjectType -Value $Value.displayname
		$object | Add-Member -MemberType NoteProperty -Name Config -Value (Get-ChildItem -Path $Config)
		
		Write-Output $Object
	}
	end { }
	}#end Get-VMXDisplayName


<#
	.SYNOPSIS
		A brief description of the Set-VMXDisplayName function.

	.DESCRIPTION
		Sets the VMX Friendly DisplayName

	.PARAMETER  config
		Please Specify Valid Config File

	.EXAMPLE
		PS C:\> Set-VMXDisplayName -config $value1
		'This is the output'
		This example shows how to call the Set-VMXDisplayName function with named parameters.

	.NOTES
		Additional information about the function or script.

#>
function Set-VMXDisplayName
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true,
				   ValueFromPipelineByPropertyName = $true,
				   Position = 1,
				   HelpMessage = 'Please Specify Valid Config File')]
		$config,
		[Parameter(Mandatory = $true,
				   ValueFromPipelineByPropertyName = $true,
				   Position = 2,
				   HelpMessage = 'Please Specify New Value for DisplayName')]
		$Value
	)
	
	Begin
	{
		
		
	}
	Process
	{
		$Content = Get-Content $config | where { $_ -ne "" }
		$Content = $content = $content | where { $_ -NotMatch "DisplayName" }
		$content += 'DisplayName = "' + $value + '"'
		Set-Content -Path $config -Value $content -Force
		$object = New-Object -TypeName psobject
		$Object | Add-Member -MemberType NoteProperty -Name Config -Value $config
		$object | Add-Member -MemberType NoteProperty -Name DisplayName -Value $Value
		# Write-Output $Object
		
	}
	End
	{
		
	}
}


function Get-VMXUUID
{
	[CmdletBinding(DefaultParametersetName = "2")]
	param (
		[Parameter(ParameterSetName = "1", Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $True)]
		[Parameter(ParameterSetName = "2", Mandatory = $false, Position = 1, ValueFromPipelineByPropertyName = $True)][Alias('NAME')]$VMXName,
		[Parameter(ParameterSetName = "2", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]$config,
		[Parameter(ParameterSetName = "3", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]$vmxconfig
	)
	begin
	{
	}
	process
	{
		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{ $vmxconfig = Get-VMXConfig -VMXName $VMXname }
			"2"
			{ $vmxconfig = Get-VMXConfig -config $config }
		}
		$ObjectType = "UUID"
		$ErrorActionPreference = "silentlyContinue"
		Write-Verbose -Message "getting $ObjectType"
		$patterntype = ".bios"
		$Value = Search-VMXPattern  -Pattern "uuid.bios" -vmxconfig $vmxconfig -Name "Type" -value $ObjectType -patterntype $patterntype -nospace
		# $Value = Search-VMXPattern -Pattern "ethernet\d{1,2}.virtualdev" -vmxconfig $vmxconfig -name "Adapter" -value "Type" -patterntype $patterntype
		$object = New-Object -TypeName psobject
		$Object | Add-Member -MemberType NoteProperty -Name VMXName -Value $VMXName
		$object | Add-Member -MemberType NoteProperty -Name $ObjectType -Value $Value.uuid
		Write-Output $Object
	}
	end { }
}#end Get-UUID




<#	
	.SYNOPSIS
		A brief description of the Get-VMXRun function.
	
	.DESCRIPTION
		A detailed description of the Get-VMXRun function.
	
	.EXAMPLE
		PS C:\> Get-VMXRun
	
	.NOTES
		Additional information about the function.
#>
function Get-VMXRun{
	$runvms = @()
	# param ($Name)
	
	$Origin = $MyInvocation.MyCommand
	do
	{
		(($cmdresult = &$vmrun List) 2>&1 | Out-Null)
		write-verbose "$origin $cmdresult"
	}
	until ($VMrunErrorCondition -notcontains $cmdresult)
	write-verbose "$origin $cmdresult"
	foreach ($runvm in $cmdresult)
	{
		if ($runvm -notmatch "Total running VMs")
		{
			$runvm = split-path $runvm -leaf -resolve
			$runvm = $runvm.TrimEnd(".vmx")
			$runvms += $runvm
			# Shell opject will be cretaed in next version containing name, vmpath , status
		}# end if
	}#end foreach
	return, $runvms
} #end get-vmxrun


<#	
	.SYNOPSIS
		A brief description of the get-VMX function.
	
	.DESCRIPTION
		A detailed description of the get-VMX function.
	
	.PARAMETER Name
		Please specify an optional VM Name
	
	.PARAMETER Path
		Please enter an optional root Path to you VMs (default is vmxdir)
	
	.EXAMPLE
		PS C:\> Get-VMX -VMXName $value1 -Path $value2
	
	.NOTES
		Additional information about the function.
#>
function Get-VMX 
{
	[CmdletBinding()]
	param (
		[Parameter(ParameterSetName = "1",HelpMessage = "Please specify an optional VM Name", Position = 1, Mandatory = $false)]$VMXName,
		[Parameter(ParameterSetName = "1",HelpMessage = "Please enter an optional root Path to you VMs (default is vmxdir)",Mandatory = $false)]
		[ValidateScript({ Test-Path -Path $_ })]$Path = $vmxdir,
		[Parameter(ParameterSetName = "1",Mandatory = $false)]$UUID
	
		

)
	$vmxrun = Get-VMXRun
    $Configfiles = Get-ChildItem -Path $path -Recurse -File -Filter "$VMXName*.vmx" -Exclude "*.vmxf" -ErrorAction SilentlyContinue
	#$Configfiles = Get-ChildItem -Path $path -Recurse -File -Filter "$VMXName*.vmx" -Exclude "*master*", "*.vmxf" -ErrorAction SilentlyContinue
    $VMX = @()
	foreach ($Config in $Configfiles)
	{
		Write-Verbose $config
		if ($Config.Extension -eq ".vmx"){
		# if ((Get-VMXTemplate -config $config).template -ne $true) {
		
			if ($UUID)
			{
				Write-Verbose $UUID
				$VMXUUID = Get-VMXUUID -config $Config.fullname
				If ($VMXUUID.uuid -eq $UUID) {
					$object = New-Object -TypeName psobject
					$object | Add-Member -MemberType NoteProperty -Name VMXName -Value ([string]($Config.BaseName))
					$object | Add-Member -MemberType NoteProperty -Name Config -Value ([string]($Config.FullName))
					$object | Add-Member -MemberType NoteProperty -Name Path -Value ([string]($Config.Directory))
					$object | Add-Member -MemberType NoteProperty -Name UUID -Value (Get-VMXUUID -config $Config.FullName).uuid
					$object | Add-Member -MemberType NoteProperty -Name Template -Value (Get-VMXTemplate -config $Config).template
                    $object | Add-Member -MemberType NoteProperty -Name ActivationPreference -Value (Get-VMXActivationPreference -config $Config -VMXName $Config.BaseName).ActivationPreference
					$object | Add-Member -MemberType NoteProperty -Name Scenario -Value (Get-VMXscenario -config $Config -VMXName $Config.BaseName) #.Scenario

                    if ($vmxrun -contains $config.basename)
					{
						$object | Add-Member State ("running")
					}
					elseif (Get-ChildItem -Filter *.vmss -Path ($config.DirectoryName))
					{
						$object | Add-Member State ("suspended")
					}
					else
					{
						$object | Add-Member State ("stopped")
					}
					Write-Output $object
				}# end if
				
			}#end-if uuid
			if (!($UUID))
			{				
				$object = New-Object -TypeName psobject
				$object | Add-Member -MemberType NoteProperty -Name VMXName -Value ([string]($Config.BaseName))
				$object | Add-Member -MemberType NoteProperty -Name Config -Value ([string]($Config.FullName))
				$object | Add-Member -MemberType NoteProperty -Name Path -Value ([string]($Config.Directory))
				$object | Add-Member -MemberType NoteProperty -Name UUID -Value (Get-VMXUUID -config $Config.FullName).uuid
				$object | Add-Member -MemberType NoteProperty -Name Template -Value (Get-VMXTemplate -Config $Config).template
                $object | Add-Member -MemberType NoteProperty -Name ActivationPreference -Value (Get-VMXActivationPreference -config $Config -VMXName $Config.BaseName).ActivationPreference
                $object | Add-Member -MemberType NoteProperty -Name Scenario -Value (Get-VMXscenario -config $Config -VMXName $Config.BaseName | Select-Object scenario, scenarioname)# .Scenario
				if ($vmxrun -contains $config.basename)
				{
					$object | Add-Member State ("running")
				}
				elseif (Get-ChildItem -Filter *.vmss -Path ($config.DirectoryName))
				{
					$object | Add-Member State ("suspended")
				}
				else
				{
					$object | Add-Member State ("stopped")
				}
				
				Write-Output $object
			}
			#}#end template
		}# end if
		     
	}
	# return $VMX
}# end get-vmx

### new-*

<#	
	.SYNOPSIS
		A brief description of the New-VMXsnap function.
	
	.DESCRIPTION
		A detailed description of the New-VMXsnap function.
	
	.EXAMPLE
		PS C:\> New-VMXsnap
	
	.NOTES
		Additional information about the function.
#>
function New-VMXbasesnap{

# Setting Base Snapshot upon First Run
do {($Snapshots = &$vmrun listSnapshots $MasterVMX ) 2>&1 | Out-Null 
write-log "$origin listSnapshots $MasterVMX $Snapshots"
}
until ($VMrunErrorCondition -notcontains $Snapshots)
write-log "$origin listSnapshots $MasterVMX $Snapshots"

if ($Snapshots -eq "Total snapshots: 0") 
{
do {($cmdresult = &$vmrun snapshot $MasterVMX Base ) 2>&1 | Out-Null 
write-log "$origin snapshot $MasterVMXX $cmdresult"
}
until ($VMrunErrorCondition -notcontains $cmdresult)
}
write-log "$origin snapshot $MasterVMX $cmdresult"

if (Get-ChildItem $CloneVMX -ErrorAction SilentlyContinue ) {write-host "VM $Nodename Already exists, nothing to do here"
return $false
}

else
{
$Displayname = 'displayname = "'+$Nodename+'@'+$Domainname+'"'
Write-Host -ForegroundColor Gray "Creating Linked Clone $CloneVMX from $MasterVMX, VMsize is $Size"
# while (!(Get-ChildItem $MasterVMX)) {
# write-Host "Try Snapshot"

do {($cmdresult = &$vmrun clone $MasterVMX $CloneVMX linked Base )
write-log "$origin clone $MasterVMX $CloneVMX linked Base $cmdresult"
}
until ($VMrunErrorCondition -notcontains $cmdresult)
write-log "$origin clone $MasterVMX $CloneVMX linked Base $cmdresult"
}
}

<#
	.SYNOPSIS
		A brief description of the New-VMXSnapshot function.

	.DESCRIPTION
		Creates a new Snapshot for the Specified VM(s)

	.PARAMETER  Name
		VM name for Snapshot

	.PARAMETER  SnapshotName
		Name of the Snapshot

	.EXAMPLE
		PS C:\> New-VMXSnapshot -Name 'Value1' -SnapshotName 'Value2'
		'This is the output'
		This example shows how to call the New-VMXSnapshot function with named parameters.

	.NOTES
		Additional information about the function or script.

#>
function New-VMXSnapshot
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $True)][Alias('NAME')][string]$VMXName,
		[Parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $True)][string]$Path = "$Global:vmxdir",
		[Parameter(Mandatory = $false)][string]$SnapshotName = (Get-Date -Format "MM-dd-yyyy_HH-mm-ss")
	)
	Begin
	{
		
	}
	Process
	{
		if ($getconfig = Get-VMX -VMXName $VMXName -Path $Path)
		{
			foreach ($config in $getconfig)
				{
				do
				{
					# $VerbosePreference = [System.Management.Automation.ActionPreference]::Continue
					Write-Verbose "Creating Snapshot $Snapshotname for $vmxname"
					($cmdresult = &$vmrun snapshot $config.config $SnapshotName) 2>&1 | Out-Null
					#write-log "$origin snapshot  $cmdresult"
					# $VerbosePreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
				}
				until ($VMrunErrorCondition -notcontains $cmdresult)
				$object = New-Object psobject
				$object | Add-Member -MemberType 'NoteProperty' -Name VMXname -Value $VMXname
				$object | Add-Member -MemberType 'NoteProperty' -Name Snapshot -Value $SnapshotName
				Write-Output $Object
			}
		}
	}
	End
	{
		
	}
}
<#
	.SYNOPSIS
		Synopsis

	.DESCRIPTION
		Description

	.PARAMETER  BaseSnapshot
		Based Snapshot to Link from

	.PARAMETER  CloneName
		A description of the CloneName parameter.

	.EXAMPLE
		PS C:\> New-VMXLinkedClone -BaseSnapshot $value1 -CloneName $value2
		'This is the output'
		This example shows how to call the New-VMXLinkedClone function with named parameters.

	.OUTPUTS
		psobject

	.NOTES
		Additional information about the function or script.

#>
function New-VMXLinkedClone
{
	[CmdletBinding(DefaultParameterSetName = '1')]
	[OutputType([psobject])]
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
		[Alias('Snapshot')]
		$BaseSnapshot,
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
		$Config,
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
		$CloneName,
		[Parameter(Mandatory = $false)][ValidateScript({ Test-Path -Path $_ })]$Clonepath,
		[Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]$Path
		
	
		
	)
	<#
	clone                    Path to vmx file     Create a copy of the VM
                         Path to destination vmx file
                         full|linked
                         [-snapshot=Snapshot Name]
                         [-cloneName=Name]
	#>
	Begin
	{
		
	}
	Process
	{
		#foreach ($config in $getconfig)
		if (!$Clonepath) { $Clonepath = Split-Path -Path $Path -Parent }
		Write-Verbose $ClonePath
		
		$CloneConfig = "$Clonepath\$Clonename\$CloneName.vmx"
		Write-Verbose $CloneConfig
			do
			{
			
			# $VerbosePreference = [System.Management.Automation.ActionPreference]::Continue
				Write-Verbose "Creating Linked Clone  $Clonename for $Basesnapshot in $Cloneconfig"
			($cmdresult = &$vmrun clone $config  $Cloneconfig linked $BaseSnapshot $Clonename) # 2>&1 | Out-Null
			#  &$vmrun clone $MasterVMX $CloneVMX linked Base
				#write-log "$origin snapshot  $cmdresult"
				# $VerbosePreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
			}
		until ($VMrunErrorCondition -notcontains $cmdresult)
		Set-VMXDisplayName -config $CloneConfig -Value $CloneName
			$object = New-Object psobject
			$object | Add-Member -MemberType 'NoteProperty' -Name CloneName -Value $Clonename
			$object | Add-Member -MemberType 'NoteProperty' -Name Config -Value $Cloneconfig
			$object | Add-Member -MemberType 'NoteProperty' -Name Path -Value "$Clonepath\$Clonename"
		
			Write-Output $Object
             
		}	
	End
	{
		
	}
}

#>
function New-VMXClone
{
	[CmdletBinding(DefaultParameterSetName = '1')]
	[OutputType([psobject])]
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
		[Alias('Snapshot')]
		$BaseSnapshot,
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
		$Config,
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
		$CloneName,
		[Parameter(Mandatory = $false)][ValidateScript({ Test-Path -Path $_ })]$Clonepath,
		[Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]$Path
		
	
		
	)
	<#
	clone                    Path to vmx file     Create a copy of the VM
                         Path to destination vmx file
                         full|linked
                         [-snapshot=Snapshot Name]
                         [-cloneName=Name]
	#>
	Begin
	{
		
	}
	Process
	{
		#foreach ($config in $getconfig)
		if (!$Clonepath) { $Clonepath = Split-Path -Path $Path -Parent }
		Write-Verbose $ClonePath
		
		$CloneConfig = "$Clonepath\$Clonename\$CloneName.vmx"
		Write-Verbose $CloneConfig
			do
			{
			
			# $VerbosePreference = [System.Management.Automation.ActionPreference]::Continue
				Write-Verbose "Creating Linked Clone  $Clonename for $Basesnapshot in $Cloneconfig"
			($cmdresult = &$vmrun clone $config  $Cloneconfig full $BaseSnapshot $Clonename) # 2>&1 | Out-Null
			#  &$vmrun clone $MasterVMX $CloneVMX linked Base
				#write-log "$origin snapshot  $cmdresult"
				# $VerbosePreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
			}
		until ($VMrunErrorCondition -notcontains $cmdresult)
		Set-VMXDisplayName -config $CloneConfig -Value $CloneName
			$object = New-Object psobject
			$object | Add-Member -MemberType 'NoteProperty' -Name CloneName -Value $Clonename
			$object | Add-Member -MemberType 'NoteProperty' -Name Config -Value $Cloneconfig
			$object | Add-Member -MemberType 'NoteProperty' -Name Path -Value "$Clonepath\$Clonename"
		
			Write-Output $Object
             
		}	
	End
	{
		
	}
}


function Get-VMXSnapshot
{
	[CmdletBinding(DefaultParametersetName = "2" )]
	param
	(
		[Parameter(Mandatory = $true, ParameterSetName = 1, ValueFromPipelineByPropertyName = $True)]
		[Parameter(Mandatory = $false, ParameterSetName = 2, ValueFromPipelineByPropertyName = $True)][Alias('TemplateName')][string]$VMXName,
		[Parameter(Mandatory = $false, ParameterSetName = 1, ValueFromPipelineByPropertyName = $True)][string]$Path = "$Global:vmxdir",
		[Parameter(Mandatory = $true, ParameterSetName = 2, ValueFromPipelineByPropertyName = $True)][string]$config
	)
	
	
	Begin
	{
		
		
	}
	Process
	{
		
		
		
		switch ($PsCmdlet.ParameterSetName)
		{
			"1"
			{ $config = Get-VMX -VMXName $VMXname -Path $Path }
			"2"
			{
				#$snapconfig = $config
				}
		}
		
		
		if ($config)
		{
			do
				{
				($cmdresult = &$vmrun listsnapshots $config) 2>&1 | Out-Null
				}
				
			until ($VMrunErrorCondition -notcontains $cmdresult)
			Write-Verbose $cmdresult[0]
			Write-Verbose $cmdresult[1]
			Write-Verbose $cmdresult.count
				If ($cmdresult.count -gt 1)
				{
					$Snaphots = $cmdresult[1..($cmdresult.count)]
					foreach ($Snap in $Snaphots)
					{
					
						$object = New-Object psobject
						$object | Add-Member -Type 'NoteProperty' -Name VMXname -Value (Get-ChildItem -Path $Config).Basename
						$object | Add-Member -Type 'NoteProperty' -Name Snapshot -Value $Snap
					$object | Add-Member -Type 'NoteProperty' -Name Config -Value $Config
					$object | Add-Member -MemberType NoteProperty -Name Path -Value (Get-ChildItem -Path $Config).Directory
						
						Write-Output $object
					}
				}
		}
	}
	End
	{
		
	}
}
<#
	.SYNOPSIS
		A brief description of the Remove-VMXSnaphot function.

	.DESCRIPTION
		deleteSnapshot           Path to vmx file     Remove a snapshot from a VM
		                         Snapshot name
		                         [andDeleteChildren]

	.PARAMETER  Snaphot
		A description of the Snaphot parameter.

	.PARAMETER  VMXName
		A description of the VMXName parameter.

	.PARAMETER  Children
		A description of the Children parameter.

	.EXAMPLE
		PS C:\> Remove-VMXSnaphot -Snaphot $value1 -VMXName $value2
		'This is the output'
		This example shows how to call the Remove-VMXSnaphot function with named parameters.

	.NOTES
		Additional information about the function or script.

#>
function Remove-VMXSnaphot
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $True)][Alias('Snapshot.snapshot')]$Snapshot,
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $True)][Alias('snaphot.vmxname')][string]$VMXName,
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $True)][string]$Path,
		[Parameter(Mandatory = $false)][switch]$Children
	)
	
	Begin
	{
	}
	Process
	{
		Write-Verbose "Snapshot in Process: $Snapshot"
		Write-Verbose "VMXName in Process: $VMXName"
		if ($config = Get-VMX -VMXName $VMXName -Path $Path)
		{
				do
				{
					Write-Verbose $config.config
					Write-Verbose $Snapshot
					($cmdresult = &$vmrun deleteSnapshot $config.config $snapshot $parameter) # 2>&1 | Out-Null
					#write-log "$origin snapshot  $cmdresult"
				}
				until ($VMrunErrorCondition -notcontains $cmdresult)
			$object = New-Object psobject
			$object | Add-Member -Type 'NoteProperty' -Name VMXname -Value $VMXname
			$object | Add-Member -Type 'NoteProperty' -Name Snapshot -Value $Snapshot
			$object | Add-Member -Type 'NoteProperty' -Name SnapshotState -Value "removed"
			Write-Output $object
		}
	}
	End
	{
		
	}
}


### start-*

<#	
	.SYNOPSIS
		A brief description of the start-vmx function.
	
	.DESCRIPTION
		A detailed description of the start-vmx function.
	
	.PARAMETER Name
		A description of the Name parameter.
	
	.EXAMPLE
		PS C:\> start-vmx -Name 'vmname'
	
	.NOTES
		Additional information about the function.
#>
function Start-VMX
{
	[CmdletBinding(DefaultParameterSetName = '2')]
	param (
		[Parameter(ParameterSetName = "1", Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $True)]
		[Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]
		[Alias('Clonename')][string]$VMXName,
		[Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $True)][Alias('VMXUUID')][string]$UUID,
		[Parameter(ParameterSetName = "2", Mandatory = $true, Position = 2, ValueFromPipelineByPropertyName = $True)]$Path
		
	)
	begin
	{
	
	}
	
	process
	{
		
			switch ($PsCmdlet.ParameterSetName)
			{
				"1"
				{ $vmx = Get-VMX -VMXName $VMXname -UUID $UUID }
				
				"2"
				{ $vmx = Get-VMX -Path $path
                }
				
			}
		
		
		
		Write-Verbose "Testing VM $VMXname Exists and stopped or suspended"
		if (($vmx) -and ($vmx.state -ne "running"))
		{
            [int]$vmxhwversion = (Get-VMXHWVersion -config $vmx.config).hwversion
            if ($vmxHWversion -le $vmwaremajor)
            {
                Write-Verbose "Checking State for $vmxname : $($vmx.vmxname)  : $($vmx.state)"
                Write-Verbose "Creating Backup of $($vmx.config)"
                Copy-Item -Path $vmx.config -Destination "$($vmx.config).bak" 
	    		Write-Verbose -Message "Setting Startparameters for $vmxname"
	    		$VMXStarttime = Get-Date -Format "MM.dd.yyyy hh:mm:ss"
	    		$content = Get-Content $vmx.config | where { $_ -ne "" }
	    		$content = $content | where { $_ -NotMatch "guestinfo.hypervisor" }
	    		$content += 'guestinfo.hypervisor = "' + $env:COMPUTERNAME + '"'
	    		$content = $content | where { $_ -NotMatch "guestinfo.powerontime" }
	    		$content += 'guestinfo.powerontime = "' + $VMXStarttime + '"'
                $content = $content |where { $_ -NotMatch "guestinfo.vmwareversion" }
                $content += 'guestinfo.vmwareversion = "' + $Global:vmwareversion + '"'
                $content = $content |where { $_ -NotMatch "guestinfo.vmwaremajor" }
                $content += 'guestinfo.vmwaremajor = "' + $Global:vmwaremajor + '"'
                $content = $content |where { $_ -NotMatch "guestinfo.vmwareminor" }
                $content += 'guestinfo.vmwareminor = "' + $Global:vmwareminor + '"'
                $content = $content |where { $_ -NotMatch "guestinfo.vmwarebuild" }
                $content += 'guestinfo.vmwarebuild = "' + $Global:vmwarebuild + '"'
	    		set-Content -Path $vmx.config -Value $content -Force
		    	Write-Verbose "Starting VM $vmxname"
		    	do
		    	{
		    		
		    		($cmdresult = &$vmrun start $vmx.config)  2>&1 | Out-Null
		    	}
    			until ($VMrunErrorCondition -notcontains $cmdresult)
                if ($LASTEXITCODE -eq 0) {
	    		$object = New-Object psobject
	    		$object | Add-Member -Type 'NoteProperty' -Name VMXname -Value $VMX.VMXname
	    		$object | Add-Member -Type 'NoteProperty' -Name Status -Value "Started"
                $object | Add-Member -Type 'NoteProperty' -Name Starttime -Value $VMXStarttime
	    		Write-Output $object }
		    }
            else { Write-Error "Vmware version does not match, need version $vmxhwversion "	}
		}
		elseif ($vmx.state -eq "running") { Write-Verbose "VM $VMXname already running" } # end elseif
		
		else { Write-Verbose "VM $VMXname not found" } # end if-vmx
		
	}# end process
	end { }
}#end start-vmx

<#	
	.SYNOPSIS
		A brief description of the Stop-VMX function.
	
	.DESCRIPTION
		A detailed description of the Stop-VMX function.
	
	.PARAMETER Mode
		Valid modes are Soft ( shutdown ) or Stop (Poweroff)
	
	.PARAMETER Name
		A description of the Name parameter.
	
	.EXAMPLE
		PS C:\> Stop-VMX -Mode $value1 -Name 'Value2'
	
	.NOTES
		Additional information about the function.
#>
function Stop-VMX{
	[CmdletBinding(DefaultParameterSetName = '2')]
	param (
		[Parameter(ParameterSetName = "1", Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $True)]
        [Parameter(ParameterSetName = "2", Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $True)][Alias('NAME')][string]$VMXName,
		[Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $True)][Alias('VMXUUID')][string]$UUID,
		# [Parameter(ParameterSetName = "3", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]
		[Parameter(ParameterSetName = "2", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]$config,
		[Parameter(ParameterSetName = "2", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]$state,
		[Parameter(HelpMessage = "Valid modes are Soft ( shutdown ) or Stop (Poweroff)", Mandatory = $false)]
		[ValidateSet('Soft', 'Hard')]$Mode
		)
		begin
		{
			
		}
		
		process
		{
			
			switch ($PsCmdlet.ParameterSetName)
			{
				"1"
				{ $vmx = Get-VMX -VMXName $VMXname -UUID $UUID  -Path $Path
				$state = $VMX.state
				$config = $VMX.config
            	}
				
				"2"
				{
                
                }
				
			}
			

	if ($state -eq "running")
	{
    Write-Verbose "State for $($VMXname) : $State"
    $Origin = $MyInvocation.MyCommand
	do{
	
		($cmdresult = &$vmrun stop $config $Mode) 2>&1 | Out-Null
		Write-Verbose "$Origin $vmxname $cmdresult"
	}
		until ($VMrunErrorCondition -notcontains $cmdresult)
		$object = New-Object psobject
		$object | Add-Member -Type 'NoteProperty' -Name VMXname -Value $VMXname
		$object | Add-Member -Type 'NoteProperty' -Name Status -Value "Stopped $Mode"
		Write-Output $object
} # end if-vmx
else {Write-Verbose "VM $vmxname not found or running"} # end if-vmx
#}#end foreach
} # end process
} # end stop-vmx
<#
	.SYNOPSIS
		A brief description of the Suspend-VMX function.

	.DESCRIPTION
		A detailed description of the Suspend-VMX function.

	.PARAMETER  name
		Name of the VM

	.EXAMPLE
		PS C:\> Suspend-VMX -name 'Value1'
		'This is the output'
		This example shows how to call the Suspend-VMX function with named parameters.

	.NOTES
		Additional information about the function or script.

#>
function Suspend-VMX
{
	[CmdletBinding(DefaultParameterSetName = '2')]
	param
	(


		[Parameter(ParameterSetName = "1", Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $True)][Alias('NAME')][string]$VMXName,
		[Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $True)][Alias('VMXUUID')][string]$UUID,
		[Parameter(ParameterSetName = "3", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]
		[Parameter(ParameterSetName = "2", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]$Path



<#

		[Parameter(Mandatory = $true,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   HelpMessage = 'Specify name for the VM to Suspend',
				   ParameterSetName = '1')]
		[Alias('Name')]
		[string]$VMXname
#>
	)
	
	Begin
	{
			
	}
	Process
	{
			if (($vmx = Get-VMX -Path $Path ) -and ($vmx.state -eq "running"))
			{
				Write-Verbose "Checking State for $($vmx.vmxname)  : $($vmx.state)"
				$Origin = $MyInvocation.MyCommand
				do
				{
					($cmdresult = &$vmrun suspend $vmx.config 2>&1 | Out-Null)
					write-verbose "$Origin suspend $VMXname $cmdresult"
				}
				until ($VMrunErrorCondition -notcontains $cmdresult)
	    		$VMXSuspendtime = Get-Date -Format "MM.dd.yyyy hh:mm:ss"
	    		$content = Get-Content $vmx.config | where { $_ -ne "" }
	    		$content = $content | where { $_ -NotMatch "guestinfo.suspendtime" }
	    		$content += 'guestinfo.suspendtime = "' + $VMXSuspendtime + '"'
	    		set-Content -Path $vmx.config -Value $content -Force
				$object = New-Object psobject
				$object | Add-Member -Type 'NoteProperty' -Name VMXname -Value $VMX.VMXname
				$object | Add-Member -Type 'NoteProperty' -Name Status -Value "Suspended"
                $object | Add-Member -Type 'NoteProperty' -Name Suspendtime -Value $VMXSuspendtime
                Write-Output $object
			}
		

		
	}#end process
}#end function


<#
	.SYNOPSIS
		A brief description of the Set-vmxtemplate function.

	.DESCRIPTION
		A detailed description of the Set-vmxtemplate function.

	.PARAMETER  vmxname
		A description of the vmxname parameter.

	.PARAMETER  config
		A description of the config parameter.

	.EXAMPLE
		PS C:\> Set-vmxtemplate -vmxname $value1 -config $value2
		'This is the output'
		This example shows how to call the Set-vmxtemplate function with named parameters.

	.NOTES
		Additional information about the function or script.

#>
function Set-VMXTemplate
{
	[CmdletBinding()]
	param (
		[Parameter( Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('vmxconfig')]$config
		# [Parameter(ParameterSetName = "2", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$config
	)
	begin
	{	 }
	
	process
	
		{
			
			if (Test-Path $config)
			{
			Write-verbose $config
			$content = Get-Content -Path $config | where { $_ -ne "" }
				$content = $content | where { $_ -NotMatch "templateVM" }
				$content += 'templateVM = "TRUE"'
				set-Content -Path $config -Value $content -Force
				$object = New-Object psobject
				$object | Add-Member -Type 'NoteProperty' -Name VMXconfig -Value $config
				$object | Add-Member -Type 'NoteProperty' -Name Template -Value $True
				Write-Output $object
			}
	}
		
		
	
	End
	{
		
	}
}<#
	.SYNOPSIS
		A brief description of the Get-VMXTemplate function.

	.DESCRIPTION
		Gets Template VM(s) for Rapid Cloning

	.PARAMETER  TemplateName
		Please Specify Template Name

	.PARAMETER  VMXUUID
		A description of the VMXUUID parameter.

	.PARAMETER  ConfigPath
		A description of the ConfigPath parameter.

	.EXAMPLE
		PS C:\> Get-VMXTemplate -TemplateName $value1 -VMXUUID $value2
		'This is the output'
		This example shows how to call the Get-VMXTemplate function with named parameters.

	.OUTPUTS
		psobject

	.NOTES
		Additional information about the function or script.

#>
function Get-VMXTemplate
{
	[CmdletBinding(DefaultParameterSetName = '1')]
	[OutputType([psobject])]
	param
	(
		[Parameter(ParameterSetName = "1", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]$config
	)
	begin
{	
		
	}
	process
	{

		$Content = Get-Content $config | where { $_ -ne '' }
		if ($content -match 'templateVM = "TRUE"')
		{
		$object = New-Object -TypeName psobject
		$Object | Add-Member -MemberType NoteProperty -Name TemplateName -Value (Get-ChildItem $config).basename
		$object | Add-Member -MemberType NoteProperty -Name GuestOS -Value (Get-VMXGuestOS -config $config).GuestOS
		$object | Add-Member -MemberType NoteProperty -Name UUID -Value (Get-VMXUUID -config $config).uuid
		$object | Add-Member -MemberType NoteProperty -Name Config -Value $config
		$object | Add-Member -MemberType NoteProperty -Name Template -Value $true
		}
	
	Write-Output $object

	}
	end { }
	
	
}

<#
	.SYNOPSIS
		synopsis

	.DESCRIPTION
		description

	.PARAMETER  config
		A description of the config parameter.

	.EXAMPLE
		PS C:\> Set-VMXNetworkAdapter -config $value1
		'This is the output'
		This example shows how to call the Set-VMXNetworkAdapter function with named parameters.

	.NOTES
		Additional information about the function or script.

#>
function Set-VMXNetworkAdapter
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
		$config,
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][ValidateRange(0, 9)][int]$Adapter,
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][ValidateSet('nat', 'bridged','custom','hostonly')]$ConnectionType,
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][ValidateSet('e1000e','vmxnet3','e1000')]$AdapterType
	)
	
	Begin
	{
		
	}
	Process
	{
		$PCISlot = ((1+$Adapter) * 64)
		$Content = Get-Content -Path $config
		Write-verbose "ethernet$Adapter.present"
		if (!($Content -match "ethernet$Adapter.present")) { write-error "Adapter not present " }
		$Content = $Content -notmatch "ethernet$Adapter"
		# Set-Content -Path $config -Value $Content
        $Addnic = @('ethernet'+$Adapter+'.present = "TRUE"')
        $Addnic += @('ethernet'+$Adapter+'.connectionType = "'+$ConnectionType+'"')
        $Addnic += @('ethernet'+$Adapter+'.wakeOnPcktRcv = "FALSE"')
        $Addnic += @('ethernet'+$Adapter+'.pciSlotNumber = "'+$PCISlot+'"')
        $Addnic += @('ethernet'+$Adapter+'.virtualDev = "'+$AdapterType+'"')
        $Content += $Addnic
        $Content | Set-Content -Path $config
		
	}
	End
	{
		
	}
}



function Set-VMXVnet
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
		$config,
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][ValidateRange(0, 9)][int]$Adapter,
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][ValidateSet('vmnet1', 'vmnet2')]$vnet
	)
	
	Begin
	{
		
	}
	Process
	{
		$Content = Get-Content -Path $config
		Write-verbose "ethernet$Adapter.present"
		if (!($Content -match "ethernet$Adapter.present")) { write-error "Adapter not present " }
		$Content = ($Content -notmatch "ethernet$Adapter.vnet")
		$Content = ($Content -notmatch "ethernet$Adapter.connectionType")
		
		Set-Content -Path $config -Value $Content
		$Addcontent = 'ethernet' + $Adapter + '.vnet = "' + $vnet + '"'
		
		#, 'ethernet' + $Adapter + '.connectionType = "custom"', 'ethernet' + $Adapter + '.wakeOnPcktRcv = "FALSE"', 'ethernet' + $Adapter + '.pciSlotNumber = "' + $PCISlot + '"', 'ethernet' + $Adapter + '.virtualDev = "e1000e"')
		Write-Verbose "Setting $Addcontent"
		$Addcontent | Add-Content -Path $config
		$AddContent = 'Ethernet'+$Adapter+'.connectionType = "custom"'
		Write-Verbose "Setting $Addcontent"
		$Addcontent | Add-Content -Path $config
	}
	End
	{
		
	}
}
<#
	.SYNOPSIS
		A brief description of the Set-VMXserial function.

	.DESCRIPTION
		A detailed description of the Set-VMXserial function.

	.PARAMETER  config
		A description of the config parameter.

	.PARAMETER  VMXname
		A description of the VMXname parameter.

	.EXAMPLE
		PS C:\> Set-VMXserial -config $value1 -VMXname $value2
		'This is the output'
		This example shows how to call the Set-VMXserial function with named parameters.

	.NOTES
		Additional information about the function or script.

#>



function Remove-VMXserial
{
	[CmdletBinding()]
	param
	(
		[Parameter(ValueFromPipelineByPropertyName = $true, Mandatory = $true)]
		$config,
		[Parameter(ValueFromPipelineByPropertyName = $true, Mandatory = $true)]
		[Alias('Clonename')]
		$VMXname,
		[Parameter(ValueFromPipelineByPropertyName = $true, Mandatory = $true)]
		$Path
	)
	
	
	
	
	
	begin { }
	process
	{
		
		$content = Get-Content -Path $config | where { $_ -Notmatch "serial0" }
		#	$AddSerial = @('serial0.present = "True"', 'serial0.fileType = "pipe"', 'serial0.fileName = "\\.\pipe\\console"', 'serial0.tryNoRxLoss = "TRUE"')
		Set-Content -Path $config -Value $Content
		#	$AddSerial | Add-Content -Path $config
		$object = New-Object psobject
		$object | Add-Member -MemberType 'NoteProperty' -Name CloneName -Value $VMXname
		$object | Add-Member -MemberType 'NoteProperty' -Name Config -Value $config
		$object | Add-Member -MemberType 'NoteProperty' -Name Path -Value $Path
		
		Write-Output $Object
	}
	end { }
}

function Set-VMXserialPipe
{
	[CmdletBinding()]
	param
	(
	[Parameter(ValueFromPipelineByPropertyName = $true, Mandatory = $true)]
	$config,
	[Parameter(ValueFromPipelineByPropertyName = $true, Mandatory = $true)]
	[Alias('Clonename')]
	$VMXname,
	[Parameter(ValueFromPipelineByPropertyName = $true, Mandatory = $true)]
	$Path
	)

begin {}
	process
	{
		
		$content = Get-Content -Path $config | where { $_ -Notmatch "serial0"}
		$AddSerial = @('serial0.present = "True"', 'serial0.fileType = "pipe"', 'serial0.fileName = "\\.\pipe\\console"', 'serial0.tryNoRxLoss = "TRUE"')
		Set-Content -Path $config -Value $Content
		$AddSerial | Add-Content -Path $config
		$object = New-Object psobject
		$object | Add-Member -MemberType 'NoteProperty' -Name CloneName -Value $VMXname
		$object | Add-Member -MemberType 'NoteProperty' -Name Config -Value $config
		$object | Add-Member -MemberType 'NoteProperty' -Name Path -Value $Path
		
		Write-Output $Object
	}
	end { }
}
function remove-vmx {
	<#
		.SYNOPSIS
			A brief description of the function.

		.DESCRIPTION
			A detailed description of the function.

		.PARAMETER  ParameterA
			The description of the ParameterA parameter.

		.PARAMETER  ParameterB
			The description of the ParameterB parameter.

		.EXAMPLE
			PS C:\> Get-Something -ParameterA 'One value' -ParameterB 32

		.EXAMPLE
			PS C:\> Get-Something 'One value' 32

		.INPUTS
			System.String,System.Int32

		.OUTPUTS
			System.String

		.NOTES
			Additional information about the function go here.

		.LINK
			about_functions_advanced

		.LINK
			about_comment_based_help

	#>


	[CmdletBinding(DefaultParametersetName = "2")]
	param (
#	[Parameter(ParameterSetName = "1", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]
	[Parameter(ParameterSetName = "2", Mandatory = $true, ValueFromPipelineByPropertyName = $True)][Alias('VMNAME')]$VMXName,	
	[Parameter(ParameterSetName = "2", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]$config,
	[Parameter(ParameterSetName = "2", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]$state

#	[Parameter(ParameterSetName = "3", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$vmxconfig
	)
	begin {$Origin = $MyInvocation.MyCommand}
	process {
	##
	switch ($PsCmdlet.ParameterSetName)
			{
				"1"
				{ $vmx = Get-VMX -VMXName $VMXname }# -UUID $UUID }
				
				"2"
				{ }
				
			}
		
		Write-Verbose "Testing VM $VMXname Exists and stopped or suspended"
		if (($state -eq "running"))
		{
			Write-Verbose "Checking State for $vmxname : $state"
			Write-Verbose $config
			Write-Verbose -Message "Stopping vm $vmxname"
			stop-vmx -config $config -VMXName $VMXName -state $state -mode hard
		}
		
	do
	{
		($cmdresult = &$vmrun deleteVM "$config" 2>&1 | Out-Null)
		write-verbose "$Origin deleteVM $vmname $cmdresult"
	}
	until ($VMrunErrorCondition -notcontains $cmdresult)
	$object = New-Object psobject
	$object | Add-Member -Type 'NoteProperty' -Name VMXname -Value $VMXname
	$object | Add-Member -Type 'NoteProperty' -Name Status -Value "removed"
	Write-Output $object
}#end process
	
	
	end{}
	} #end remove-vmx




function New-VMXScsiDisk
{
[CmdletBinding()]
param (
	[Parameter(ParameterSetName = "1", Mandatory = $true, ValueFromPipelineByPropertyName = $True)][INT64]$NewDiskSize,	
	[Parameter(ParameterSetName = "1", Mandatory = $true, ValueFromPipelineByPropertyName = $True)][string]$NewDiskname,
	[Parameter(ParameterSetName = "1", Mandatory = $false, ValueFromPipelineByPropertyName = $True)][Alias('NAME')]$VMXName,
	[Parameter(ParameterSetName = "1", Mandatory = $true, ValueFromPipelineByPropertyName = $True)]$Path
#	[Parameter(ParameterSetName = "3", Mandatory = $false, ValueFromPipelineByPropertyName = $True)]$vmxconfig



)
begin {


       }
process {
        
    $returncommand = & $vmwarepath\vmware-vdiskmanager.exe -c -s $NewDiskSize -t 0 $Path\$NewDiskname -a lsilogic # 2>&1 | Out-Null
    if (!$NewDiskname.EndsWith(".vmdk")) { $NewDiskname = $NewDiskname+".vmdk" }

    if ($LASTEXITCODE -eq 0)
    {

    $object = New-Object -TypeName psobject
    $object | Add-Member -MemberType NoteProperty -Name Disktype -Value "lsilogic"
    $object | Add-Member -MemberType NoteProperty -Name Filename -Value $NewDiskname
    $object | Add-Member -MemberType NoteProperty -Name Size -Value $NewDiskSize
    $object | Add-Member -MemberType NoteProperty -Name Path -Value $Path
    Write-Output $object
    # Write-Verbose $returncommand
    }
    else {  Write-Output $returncommand }
    break
    }
end {
    
    }
} # end new-vmxdisk


function Set-VMXscenario
{
	[CmdletBinding()]
	param
	(   [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $True)][string]$VMXName,
		[Parameter(ParameterSetName = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]$config,
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $true)]$path,
        [Parameter(ParameterSetName = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $false)][Validateset(1,2,3,4,5,6,7,8,9)][int]$Scenario,
		[Parameter(ParameterSetName = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $False)][Validatelength(1, 10)][string]$Scenarioname
		
	)
	
	Begin
	{

	}
	Process
	{
		Copy-Item -Path $config -Destination "$($config).bak"
        $Content = Get-Content -Path $config
		$Content = ($Content -notmatch "guestinfo.Scenario$Scenario")
        $content += 'guestinfo.scenario'+$Scenario+' = "'+$ScenarioName+'"'
		Set-Content -Path $config -Value $Content
        $object = New-Object -TypeName psobject
		$object | Add-Member -MemberType NoteProperty -Name VMXname -Value $VMX.VMXname
        $object | Add-Member -MemberType NoteProperty -Name Scenario -Value $Scenario
		$object | Add-Member -MemberType NoteProperty -Name Scenarioname -Value $scenarioname
		$object | Add-Member -MemberType NoteProperty -Name Config -Value $Config
        $object | Add-Member -MemberType NoteProperty -Name Path -Value $Path
        Write-Output $object
		# $content
	}
	End
	{}
}
		




function Get-VMXscenario
{
	[CmdletBinding(DefaultParameterSetName = '1')]
	[OutputType([psobject])]
	param
	(
        [Parameter(ParameterSetName = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $True)][string]$VMXName,
        [Parameter(ParameterSetName = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $True)]$config,
        [Parameter(ParameterSetName = 1, Mandatory = $False, ValueFromPipelineByPropertyName = $True)]$Path
	)
	begin
{	
		
	}
	process
	{
        
  	    $vmxconfig = Get-VMXConfig -config $config
		$ObjectType = "Scenario"
		$patterntype = ".scenario\d{1,9}"
		$ErrorActionPreference = "silentlyContinue"
		Write-Verbose -Message "getting $ObjectType"
		$Value = Search-VMXPattern -Pattern "guestinfo.scenario\d{1,9}" -vmxconfig $vmxconfig -name "Scenario" -value "Scenarioname" -patterntype $patterntype
		foreach ($Scenarioset in $value)
		{
			$object = New-Object -TypeName psobject
			$object | Add-Member -MemberType NoteProperty -Name VMXname -Value $VMXname
            $object | Add-Member -MemberType NoteProperty -Name Scenario -Value $Scenarioset.Scenario.Trimstart("guestinfo.scenario")
			$object | Add-Member -MemberType NoteProperty -Name Scenarioname -Value $Scenarioset.scenarioname
			$object | Add-Member -MemberType NoteProperty -Name Config -Value $Config
            $object | Add-Member -MemberType NoteProperty -Name Path -Value $Path
			Write-Output $Object
		}
            
	}
	end { }
}
	
	
function Set-VMXActivationPreference
{
	[CmdletBinding()]
	param
	(   [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $True)][string]$VMXName,
		[Parameter(ParameterSetName = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]$config,
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $true)]$path,
        [Parameter(ParameterSetName = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $false)][Validateset(0,1,2,3,4,5,6,7,8,9)][int]$activationpreference
		
	)
	
	Begin
	{

	}
	Process
	{
		Copy-Item -Path $config -Destination "$($config).bak"
        $Content = Get-Content -Path $config
		$Content = ($Content -notmatch "guestinfo.activationpreference")
        $content += 'guestinfo.activationpreference = "' + $activationpreference + '"'
		Set-Content -Path $config -Value $Content
        $object = New-Object -TypeName psobject
		$object | Add-Member -MemberType NoteProperty -Name VMXname -Value $VMXname
        $object | Add-Member -MemberType NoteProperty -Name ActivationPreference -Value $activationpreference
		$object | Add-Member -MemberType NoteProperty -Name Config -Value $Config
        $object | Add-Member -MemberType NoteProperty -Name Path -Value $Path
        Write-Output $object
		# $content
	}
	End
	{}
}

function Get-VMXActivationPreference
{
	[CmdletBinding(DefaultParameterSetName = 1)]
	[OutputType([psobject])]
	param
	(
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $true)][string]$VMXName,
        [Parameter(ParameterSetName = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $True)]$config,
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $true)]$Path
  #      [Parameter(ParameterSetName = 3, Mandatory = $true, ValueFromPipelineByPropertyName = $True)]$vmxconfig
	)
	begin
    {	

	}
	process
	{
        $vmxconfig = Get-VMXConfig -config $config	    
		$ObjectType = "ActivationPreference"
		$patterntype = "ActivationPreference"
		$ErrorActionPreference = "silentlyContinue"
		Write-Verbose -Message "getting $ObjectType"
		$Value = Search-VMXPattern -Pattern $patterntype -vmxconfig $vmxconfig  -value $patterntype -patterntype $patterntype
		# foreach ($Scenarioset in $value)
		# {
			$object = New-Object -TypeName psobject
			$object | Add-Member -MemberType NoteProperty -Name VMXname -Value $VMXname
            $object | Add-Member -MemberType NoteProperty -Name $ObjectType -Value $Value.ActivationPreference
			$object | Add-Member -MemberType NoteProperty -Name Config -Value $Config
            $object | Add-Member -MemberType NoteProperty -Name Path -Value $Path
			Write-Output $Object
		#}
            
	}
	end { }
}


function Invoke-VMXPowerShell
{
	[CmdletBinding(DefaultParameterSetName = 1)]
	[OutputType([psobject])]
	param
	(
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $false)][string]$VMXName,
        [Parameter(ParameterSetName = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]$config,
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $false)]$ScriptPath,
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $false)]$Script, 
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $false)]$Parameter = "", 
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $false)][switch]$nowait, 
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $false)][switch]$interactive,
                [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $false)][switch]$activewindow, 
        [Parameter(ParameterSetName = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]$Guestuser, 
        [Parameter(ParameterSetName = 1, Mandatory = $false, ValueFromPipelineByPropertyName = $true)] $Guestpassword
         #      [Parameter(ParameterSetName = 3, Mandatory = $true, ValueFromPipelineByPropertyName = $True)]$vmxconfig
	)
	begin
    {	
    $Origin = $MyInvocation.MyCommand
	$nowait_parm = ""
	$interactive_parm = ""
	if ($nowait) { $nowait_parm = "-nowait" }
	if ($interactive) { $interactive_parm = "-interactive" }
	}


process
{	
	do
	{
		$cmdresult = (&$vmrun  -gu $Guestuser -gp $Guestpassword  runPrograminGuest $config -activewindow "$nowait_parm" $interactive_parm c:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe "$ScriptPath\$Script" "$Parameter")
#		$cmdresult = (&$vmrun  -gu $Guestuser -gp $Guestpassword  runPrograminGuest $config "$nowait_parm" $interactive_parm c:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe "$ScriptPath\$Script" "$Parameter")
		
write-verbose "$origin $cmdresult $Script"
	}
	until ($VMrunErrorCondition -notcontains $cmdresult)
	
}

end {}
}


