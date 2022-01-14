function Install-SSH {
    <#
    .SYNOPSIS
    Modified 7/15/2019
    -Taylor Lee
 
    .DESCRIPTION
    Use this function on a local or remote endpoint to enable openssh.
 
    Use PSRemoting to run the command on a remote endpoint.
 
    .Parameter InstallFromScript
    Specifies to install from a script
 
    .Parameter InstallAsFeature
    Specifies to install as a feature
 
    .Parameter Autoservices
    Sets ssh services automatic
 
    .Parameter StartServices
    Started the ssh services
 
    .EXAMPLE
    Enable-OpenSSH features but don't set the services to Automatic
 
    Install-OpenSSH
 
    .EXAMPLE
    Enable-OpenSSH features and set the services to Automatic
 
    Install-OpenSSH -AutoServices
 
    .Link
    https://www.powershellgallery.com/profiles/TaylorLee
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [Alias ('Install-OpenSSH')]

    Param (
        [Parameter(Mandatory = $true, ParameterSetName = 'InstallFromFile')]
        [switch]$InstallFromScript,
        [Parameter(Mandatory = $true, ParameterSetName = 'InstallAsFeature')]
        [switch]$InstallAsFeature,
        [Parameter(Mandatory = $false, ParameterSetName = 'InstallAsFeature')]
        [Parameter(Mandatory = $false, ParameterSetName = 'InstallFromFile')]
        [switch]$AutoServices,
        [Parameter(Mandatory = $false, ParameterSetName = 'InstallAsFeature')]
        [Parameter(Mandatory = $false, ParameterSetName = 'InstallFromFile')]
        [Parameter(Mandatory = $false, ParameterSetName = 'StartServices')]
        [switch]$StartServices
    )

    #Check For Admin Privleges
    Get-Elevation

    if ($InstallAsFeature) {
        # Install the OpenSSH Server
        Add-WindowsCapability -Online -Name OpenSSH.Server*
    }

    if ($InstallFromScript) {
        #Install winssh from github
        Write-Host "Installing from Github" -ForegroundColor Green
        $url = "https://github.com/PowerShell/Win32-OpenSSH/releases/download/v8.0.0.0p1-Beta/OpenSSH-Win32.zip"
        $zipfile = "c:\winssh.zip"
        $outpath = "c:\Winssh"
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12
        Invoke-WebRequest -Uri $url -OutFile $zipfile
        Invoke-Unzip $zipfile $outpath
        Remove-Item $zipfile -force
        . $outpath\OpenSSH-Win32\install-sshd.ps1
    }

    if ($StartServices) {
        #Enable the openssh server services
        Start-Service sshd
    }

    if ($AutoServices) {
        #Set services to start Automnatically
        Set-Service -Name sshd -StartupType 'Automatic'
    }



}
