<#
.SYNOPSIS
    Requirement script to check for software updates
.DESCRIPTION
    Requirement script will check to see if <APPNAME> is installed and if it is, mark the device applicable for the latest software update.
.PARAMETER
    N/A
.INPUTS
    N/A
.OUTPUTS

    N/A
.NOTES
    Version: 1.0
    Author:
    Creation Date: 
.EXAMPLE
    N/A
#>
#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$ScriptVersion = "1.0"

#Execution Variables
$EA = 'silentlycontinue'
$Result = 'Applicable'
$App = ''
$Architecture = ''
$ExpectedDisplayVersion = ''
$Logfile = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\Argonne-SoftwareUpdateDetection.log"

if( $Architecture -eq 'x64'){
    $RegInstallLocation = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
} Else {
    $RegInstallLocation = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
}

$RegInstallLocationCustom = ""

#-----------------------------------------------------------[Functions]------------------------------------------------------------

function Write-Log {
    Param (
		[Parameter(Mandatory=$false)]
		$Message,
 
		[Parameter(Mandatory=$false)]
		$ErrorMessage,
 
		[Parameter(Mandatory=$false)]
		$Component,
 
		[Parameter(Mandatory=$false)]
		[int]$Type,
		
		[Parameter(Mandatory=$true)]
		$LogFile
	)
<#
Type: 1 = Normal, 2 = Warning (yellow), 3 = Error (red)
#>
	$Time = Get-Date -Format "HH:mm:ss.ffffff"
	$Date = Get-Date -Format "MM-dd-yyyy"
 
	if ($ErrorMessage -ne $null) {$Type = 3}
	if ($Component -eq $null) {$Component = " "}
	if ($Type -eq $null) {$Type = 1}
 
	$LogMessage = "<![LOG[$Message $ErrorMessage" + "]LOG]!><time=`"$Time`" date=`"$Date`" component=`"$Component`" context=`"`" type=`"$Type`" thread=`"`" file=`"`">"
	$LogMessage | Out-File -Append -Encoding UTF8 -FilePath $LogFile
}

#Execution

if(Test-Path C:\ProgramData\Microsoft\IntuneManagementExtension\Logs){

} Else {

    New-Item -ItemType Directory -Path C:\ProgramData\Microsoft\IntuneManagementExtension\Logs

}

try{

    $InstalledPackage = get-ChildItem -Path $RegInstallLocation -ea SilentlyContinue|
    Get-ItemProperty | 
    Where-Object {$_.DisplayName -eq $App}
    
    $InstalledDisplayName = $InstalledPackage.DisplayName
    $InstalledDisplayVersion = $InstalledPackage.DisplayVersion
    $InstalledPath = $InstalledPackage.PSParentPath

    If($InstalledDisplayName){

        if([Version]$InstalledDisplayVersion -lt [Version]$ExpectedDisplayVersion){
    
        Write-Log -Message "$($App) $($ExpectedDisplayVersion) - Found:True - PurposeRequirement:Current DisplayVersion is $($InstalledDisplayVersion)" -Type 1 -LogFile $LogFile
        Write-output $Result
    
        } Else {

        Write-Log -Message "$($App) $($ExpectedDisplayVersion) - Found:False - PurposeRequirement:Current DisplayVersion is $($InstalledDisplayVersion)" -Type 2 -LogFile $LogFile

        }

    }Else{

        Write-Log -Message "$($App) $($ExpectedDisplayVersion) - Found:False - PurposeRequirement:Application does not exist and therefore cannot be updated" -Type 2 -LogFile $LogFile
    }

} Catch {

    Write-Log -Message "An error occurred:" -Type 3 -LogFile $Logfile
    Write-Log -Message $_ -Type 3 -LogFile $Logfile

}