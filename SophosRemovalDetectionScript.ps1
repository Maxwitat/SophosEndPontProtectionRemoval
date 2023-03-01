$SophosUninst = "C:\Program Files\Sophos\Sophos Endpoint Agent\uninstallcli.exe"
if ((Test-Path -Path $SophosUninst) -eq $true) {
    exit 1
}
else {
    $SophosUninstx86 = "C:\Program Files (x86)\Sophos\Sophos Endpoint Agent\uninstallcli.exe"
    if ((Test-Path -Path $SophosUninstx86) -eq $true) {
        exit 1
    }
    else {
       Write-Output 'No Sophos Endpoint found'
       exit 0
    }
}