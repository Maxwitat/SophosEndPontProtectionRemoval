#Sophos Removal 
#Frank Maxwitat, 25.10.2022

function Write-log {

    [CmdletBinding()]
    Param(
          [parameter(Mandatory=$true)]
          [String]$Path,

          [parameter(Mandatory=$true)]
          [String]$Message,

          [parameter(Mandatory=$true)]
          [String]$Component,

          [Parameter(Mandatory=$true)]
          [ValidateSet("Info", "Warning", "Error")]
          [String]$Type
    )

    switch ($Type) {
        "Info" { [int]$Type = 1 }
        "Warning" { [int]$Type = 2 }
        "Error" { [int]$Type = 3 }
    }

    # Create a log entry
    $Content = "<![LOG[$Message]LOG]!>" +`
        "<time=`"$(Get-Date -Format "HH:mm:ss.ffffff")`" " +`
        "date=`"$(Get-Date -Format "M-d-yyyy")`" " +`
        "component=`"$Component`" " +`
        "context=`"$([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)`" " +`
        "type=`"$Type`" " +`
        "thread=`"$([Threading.Thread]::CurrentThread.ManagedThreadId)`" " +`
        "file=`"`">"

    # Write the line to the log file
    Add-Content -Path $Path -Value $Content
}

$SophosUninst = "C:\Program Files\Sophos\Sophos Endpoint Agent\uninstallcli.exe"
$LogFilePath = 'c:\windows\logs\RemoveSophosEP.log'
Write-Log -Path $LogFilePath -Message 'Starting Sophos removal, script version 1.0' -Component $MyInvocation.MyCommand.Name -Type Info

if(!(Test-Path($SophosUninst)))
{
    Write-Log -Path $LogFilePath -Message 'No uninstall file found' -Component $MyInvocation.MyCommand.Name -Type Info
}
else
{
    Write-Log -Path $LogFilePath -Message 'Starting uninstall' -Component $MyInvocation.MyCommand.Name -Type Info
    
    Try{
        Start-Process $SophosUninst -Wait -PassThru
    }
    Catch
    {
        Write-Error ($_ | Out-String)
        Write-Log -Path $LogFilePath -Message ($_ | Out-String) -Component $MyInvocation.MyCommand.Name -Type Error
    }

    $Services = Get-Service *Sophos*
    $count = 0
    Write-Log -Path $LogFilePath -Message 'Listing Sophos Services to check if any service is left' -Component $MyInvocation.MyCommand.Name -Type Info
    foreach($Service in $Services){
        Write-Log -Path $LogFilePath -Message ([string]$Service.DisplayName) -Component $MyInvocation.MyCommand.Name -Type Info
        $count++
    }
    if($Count > 0)
    {
        Write-Log -Path $LogFilePath -Message "It looks like Sophos hasn't been removed." -Component $MyInvocation.MyCommand.Name -Type Warning        
    }

    Write-Log -Path $LogFilePath -Message 'Sophos removal finished' -Component $MyInvocation.MyCommand.Name -Type Info
}