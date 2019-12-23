Param(
    [Parameter(Mandatory=$True, Position=1)]
    [string]$path,

    [Parameter(Mandatory=$True, Position=2)]
    [string]$principal,

    [Parameter(Mandatory=$True, Position=3)]
    [string]$permission,
	
    [Parameter(Mandatory=$True, Position=4)]
    [string]$townership,
	
    [Parameter(Mandatory=$True, Position=5)]
    [string]$reportfolder	
    )

# To Be able to catch exceptions
$ErrorActionPreference = "Stop"

function Set-AclRule {
	Param ($fpath, $principal, $permission, $action)
	$facl = Get-Acl $fpath
	$arule = New-Object  system.security.accesscontrol.filesystemaccessrule($principal, $permission, $action)
	$facl.SetAccessRule($arule)
	Set-Acl -Path $fpath -AclObject $facl
	$msg = "SA: $fpath, $principal, $permission, $action" 
	LogMsg $msg
	Write-Host $msg
}

function Set-OwnerRule {
	Param ($fpath, $new_owner)
	$GroupOwnerShip = New-Object System.Security.Principal.NTAccount($new_owner)
	$facl = Get-Acl $fpath
	$facl.SetOwner($GroupOwnerShip)
	Set-Acl -Path $fpath -AclObject $facl
	$msg = "SO: $fpath, $new_owner"
	LogMsg  $msg
	Write-Host $msg
}

$file_time_tag=Get-Date -Format "yyyyMMdd_HHmmss"
$report_file_path="$reportfolder\permission_processing_failures_$file_time_tag.log"
$outf=New-Object System.IO.StreamWriter "$report_file_path", $true

function LogMsg {
	Param([string]$msg)
	$outf.WriteLine($msg)
	$outf.Flush()
	Write-Host $msg
}

$InitialTimeStamp = Get-Date
$InitialTimeStamp_txt = Get-Date $InitialTimeStamp -Format "yyyy-MM-dd HH:mm K"

LogMsg $InitialTimeStamp_txt
LogMsg "---------------------------------------------"
LogMsg "Path:         ""$path"""
LogMsg "Principal:    ""$principal"""
LogMsg "Permission:   ""$permission"""
LogMsg "NewOwner:     ""$townership"""
LogMsg "ReportFolder: ""$reportfolder"""
LogMsg "---------------------------------------------"
get-childitem $path -recurse | foreach-object {
    $filesystem_item = $_

	$fi_path = $filesystem_item.fullname
	$fi_name = $filesystem_item.name
    $fi_acl = Get-Acl $fi_path
	$fi_owner = $fi_acl.Owner

    $apply_rule = $true
    foreach ($rule in $fi_acl.Access) {
        if ( $rule.IdentityReference -eq $principal ) {
            $rights = $rule.FileSystemRights.ToString()
            if ( $rights.Contains($permission) ) {
                $apply_rule = $false
            }
        }
    }

    if ($apply_rule) {
			try {
				Set-AclRule $fi_path $principal $permission "Allow"
			}
			Catch [System.InvalidOperationException], [Microsoft.PowerShell.Commands.SetAclCommand] {
				LogMsg "SA Failed: $fi_path"
				if ( $fi_owner.StartsWith("O:S-1-5-21-")) {
					Set-OwnerRule $fi_path $townership
					Set-AclRule $fi_path $principal $permission "Allow"
				}
			}
			finally {
			}
        } else {
            # LogMsg "Skip apply - owned by "$fi_acl.Owner"- "$fi_path 
        }

}

$FinalTimeStamp = Get-Date
$FinalTimeStamp_txt = Get-Date $FinalTimeStamp -Format "yyyy-MM-dd HH:mm K"
$interval = $FinalTimeStamp - $InitialTimeStamp 
LogMsg "$FinalTimeStamp_txt ---> $interval"
$outf.close()


