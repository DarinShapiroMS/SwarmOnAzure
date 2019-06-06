
param (
    [Parameter(Mandatory=$true)][string]$user,
    [Parameter(Mandatory=$true)][string]$pwd,
    [Parameter(Mandatory=$true)][string]$coordinatorIp  
)

Add-Type -AssemblyName System.Xml.Linq

 # ALL THIS HAS TO BE IDEMPOTENT
 $swarmrootdirectory = 'c:\swarm'
 $swarmbootstrapperexe = "$swarmrootdirectory\Swarm Agent\swarmbootstrapper.exe"

Write-Output "Starting execution of vm configuration script."

# 1. get the zip file withthe swarm binaries and bootstrapper, then unzip to proper location
    
    $swarmurl = 'https://swarmdiag.blob.core.windows.net/vm-config-files/SwarmAgent.zip'
    $tempzipfile = "$swarmrootdirectory\SwarmBinaries.zip"
    if(![System.IO.Directory]::Exists($swarmrootdirectory)){
        New-Item -Path $swarmrootdirectory -ItemType Directory
    }

    (New-Object Net.WebClient).DownloadFile($swarmurl,$tempzipfile);
    (new-object -com shell.application).namespace($swarmrootdirectory).CopyHere((new-object -com shell.application).namespace($tempzipfile).Items(),16)
    Remove-Item -Path $tempzipfile

    $swarmPrereqsUrl = "https://swarmdiag.blob.core.windows.net/vm-config-files/UE4PrereqSetup_x64.exe"
    $tempzipfile = "$swarmrootdirectory\UE4PrereqSetup_x64.exe"
    (New-Object Net.WebClient).DownloadFile($swarmPrereqsUrl,$tempzipfile);

#2  Download swarm bootstrapper exe (shortcut to this placed in startup folder to auto run on auto login)
    $bootstrapperurl = 'https://swarmdiag.blob.core.windows.net/vm-config-files/SwarmBootstrapper.exe'    
    (New-Object Net.WebClient).DownloadFile($bootstrapperurl,$swarmbootstrapperexe);


#3. add coordinator IP, processor count is done by bootstrapper now   
    # coordinator IP
    $element = [System.Xml.Linq.XElement]::Load("$swarmrootdirectory\Swarm Agent\SwarmAgent.Options.xml");
    $element.SetElementValue("CoordinatorRemotingHost", $coordinatorIp)
    $element.Save("$swarmrootdirectory\Swarm Agent\SwarmAgent.Options.xml")

#4 add firewall rules to allow port 8008, 8009, & ICMP
    $rule8008 = Get-NetFirewallRule -DisplayName "SwarmInbound8008i"
    $rule8009 = Get-NetFirewallRule -DisplayName "SwarmInbound8009i"
    if($null -eq $rule8008){
        new-netfirewallrule -displayname "SwarmInbound8008i" -direction inbound -action allow -protocol tcp -LocalPort 8008
        new-netfirewallrule -displayname "SwarmInbound8008o" -direction Outbound -action allow -protocol tcp -LocalPort 8008
    }
    if($null -eq $rule8009){
        new-netfirewallrule -displayname "SwarmInbound8009i" -direction inbound -action allow -protocol tcp -LocalPort 8009
        new-netfirewallrule -displayname "SwarmInbound8009o" -direction Outbound -action allow -protocol tcp -LocalPort 8009
    }
    Set-NetFirewallRule -DisplayName “File and Printer Sharing (Echo Request - ICMPv4-In)” -enabled True

#5 Install .net pre-reqs for unreal pre-reqa
    Dism /online /enable-feature /featurename:NetFx3 /All

#6  Install Unreal Pre-reqs 
    c:\swarm\UE4PrereqSetup_x64.exe /install /quiet /norestart | Out-Null

#7 .add startup shortcut for any login to start the bootstrapper
    $Destination =  "$env:ALLUSERSPROFILE\Microsoft\Windows\Start Menu\Programs\StartUp\Swarm.lnk"
    if(![System.IO.Directory]::Exists($Destination)){
        $WshShell = New-Object -comObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($Destination)
        $Shortcut.TargetPath = $swarmbootstrapperexe
        $shortcut.Workingdirectory = "$swarmrootdirectory\Swarm Agent\"
        $Shortcut.Save()
    }

#8 set auto run for admin user    
    $RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    #setting registry values
    Set-ItemProperty $RegPath "AutoAdminLogon" -Value "1" -type String  
    Set-ItemProperty $RegPath "DefaultUsername" -Value "$user" -type String  
    Set-ItemProperty $RegPath "DefaultPassword" -Value "$pwd" -type String

Write-Output "Ending execution of vm config script and rebooting."
#9 All done, restart and auto login should take care of the rest. 
    Restart-Computer





