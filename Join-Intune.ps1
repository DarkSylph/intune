<#
.Synopsis
    Join Intune.

.Description
    Joins the workstation to Intune.

.Example
    .\Join-Intune.ps1

.Outputs
    Log files stored in C:\Logs\Intune.

.Notes
    Author: Chrysi
    Link:   https://github.com/DarkSylph/intune
    Date:   01/24/2022
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Requires -Version 5.1

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script version
$ScriptVersion = "v3.2.3"
#Script name.
$App = "Join Intune"
#Today's date
$Date = Get-Date -Format "MM-dd-yyyy-HH-mm-ss"
#Destination to store logs
$LogFilePath = "C:\Logs\Intune\" + $date + "-Join-Logs.log"
#Path to the Intune package
$Pkg = "C:\Deploy\Intune\client.ppkg"

#-----------------------------------------------------------[Functions]------------------------------------------------------------

function Set-Task {
    process {
        try {
            $TS = New-TimeSpan -Minutes 2
            $Time = (Get-Date) + $TS
            $path = "C:\Deploy\Intune\Migrate-Profiles.ps1"
            $trigger = New-JobTrigger -Once -At $Time
            Register-ScheduledJob -Name "Migrate Profiles" -FilePath $path -Trigger $trigger
            Write-Host "$(Get-Date): Scheduled task to execute migration of profiles to Azure AD 2 minutes from now..."
        }
        catch {
            Throw "There was an unrecoverable error: $($_.Exception.Message) Unable to register task."
        }
    }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

#Sets up a destination for the logs
if (-Not (Test-Path -Path "C:\Logs")) {
    Write-Host "$(Get-Date): Creating new log folder."
    New-Item -ItemType Directory -Force -Path C:\Logs | Out-Null
}
if (-Not (Test-Path -Path "C:\Logs\Intune")) {
    Write-Host "$(Get-Date): Creating new log folder."
    New-Item -ItemType Directory -Force -Path C:\Logs\Intune | Out-Null
}
#Begins the logging process to capture all output
Start-Transcript -Path $logfilepath -Force
Write-Host "$(Get-Date): Successfully started $app install script $ScriptVersion on $env:computername"
#Sets the task to migrate profiles1
Set-Task
#Installs the client specific Intune provisioning package
Write-Host "$(Get-Date): Installing provisioning package now..."
Install-ProvisioningPackage -PackagePath $Pkg -QuietInstall -ForceInstall
#Ends the logging process.
Stop-Transcript
#Terminates the script.
exit