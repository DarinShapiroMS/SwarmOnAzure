
param (
    [Parameter(Mandatory=$true)][string]$user,
    [Parameter(Mandatory=$true)][string]$pwd,
    [Parameter(Mandatory=$true)][string]$coordinatorIp  
)

Add-Type -AssemblyName System.Xml.Linq

 # ALL THIS HAS TO BE IDEMPOTENT

# 1. get the zip file with all the swarm binaries & unzip to proper location
    $swarmrootdirectory = 'c:\swarm'
    $swarmurl = 'https://swarmdiag.blob.core.windows.net/vm-config-files/SwarmAgent.zip'
    $tempzipfile = "$swarmrootdirectory\SwarmBinaries.zip"
    if(![System.IO.Directory]::Exists($swarmrootdirectory)){
        New-Item -Path $swarmrootdirectory -ItemType Directory
    }

    (New-Object Net.WebClient).DownloadFile($swarmurl,$tempzipfile);
    (new-object -com shell.application).namespace($swarmrootdirectory).CopyHere((new-object -com shell.application).namespace($tempzipfile).Items(),16)
    Remove-Item -Path $tempzipfile


# 2. add logical processor count to config & coordinator IP so Swarm will use them all
    # logical processor count
    $logicalproccessorcount = [Environment]::ProcessorCount.ToString();
    $element = [System.Xml.Linq.XElement]::Load("$swarmrootdirectory\Swarm Agent\SwarmAgent.DeveloperOptions.xml");
    $element.SetElementValue("RemoteJobsDefaultProcessorCount", $logicalproccessorcount)
    $element.Save("$swarmrootdirectory\Swarm Agent\SwarmAgent.DeveloperOptions.xml")
    
    # coordinator IP
    $element = [System.Xml.Linq.XElement]::Load("$swarmrootdirectory\Swarm Agent\SwarmAgent.Options.xml");
    $element.SetElementValue("CoordinatorRemotingHost", $coordinatorIp)
    $element.Save("$swarmrootdirectory\Swarm Agent\SwarmAgent.Options.xml")



# 3 .add scheduled task at startup or login to run
    $ItemPath = "$swarmrootdirectory\Swarm Agent\swarmagent.exe"
    $Destination =  "$env:ALLUSERSPROFILE\Microsoft\Windows\Start Menu\Programs\StartUp\Swarm.lnk"
    if(![System.IO.Directory]::Exists($Destination)){
        $WshShell = New-Object -comObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($Destination)
        $Shortcut.TargetPath = $ItemPath
        $Shortcut.Save()
    }

# 4 set auto run for admin user
    
    $RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"

    #setting registry values
    Set-ItemProperty $RegPath "AutoAdminLogon" -Value "1" -type String  
    Set-ItemProperty $RegPath "DefaultUsername" -Value "$user" -type String  
    Set-ItemProperty $RegPath "DefaultPassword" -Value "$pwd" -type String

#5 All done, restart and auto login should take care of the rest. 
Restart-Computer





