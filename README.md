
# nas-access-rules-ad
During my role of Storage Administrator for NAS appliances (DELL EMC / NetApp) got a request to apply read permissions for all files on NAS CIFS resources, those resources contains data with are more than 15 years old.

Applying such permissions using windows file explorer imidiatly proved to be unsuportable regarding several errors, but the most relevant were broken inheritances over file system tree.

Resolution was to come getting some crawler to check every file, every folder.

Then other errors arised.

### As a result I landed on
 - Using PowerShell 5.1 minimum
	 - script crawler (Get-ChildItem)
 - icacls applying permissions
	 - Proved to be complete against Set-Acl command from PowerShell
		 - Set-Acl presented issues regarding unicode
		 - set-Acl presented issue related to ownership  that I did not fully got the answer

### Scripts produced are
 - PermissionSetTOnwerShip_icacls.ps1
	- icacls version and more complete
- PermissionSetTOnwerShip.ps1
	- PowerShell only solution
    
### Invoking any of the scripts

Arguments:

    -path:         Path to inspect
    -principal:    Principal for permissions, can be group or user from Ad or local
    -permission:   Permission to grant/allow, which vary from icacls version for Set-Acl version
    -townership:   principal to apply as onwership for those cases where SID is not well translated
    -reportfolder: Folder to where simple log files are stored

### Paths specified as UNCs

Drive/local long path:
- '\\\\\?\C:\Very long path'

Network long path:
- '\\\\\?\UNC\127.0.0.1\c$\Very long path\'

### References
#### Usefull

https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/new-psdrive?view=powershell-5.1

https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/remove-psdrive?view=powershell-5.1

http://vcloud-lab.com/entries/windows-2016-server-r2/find-next-available-free-drive-letter-using-powershell-

#### Relevant
##### Long paths

https://stackoverflow.com/questions/46308030/handling-path-too-long-exception-with-new-psdrive/46309524

    Requirements are :    
	    Windows Management Framework 5.1
    	    .Net Framework 4.6.2 or more recent
    	    Windows 10 / Windows server 2016 (Build 1607 or newer)
    
    Policy for long paths can be enabled using the following snippet.
  	    #GPEdit location: Configuration>Administrative Templates>System>FileSystem
	    Set-ItemProperty 'HKLM:\System\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -value 1

    
That's all, have a nice NAS Sysadmin day.


