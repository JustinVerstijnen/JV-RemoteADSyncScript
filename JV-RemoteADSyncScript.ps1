# Parameters
$adconnectserver = "JV-DC-SRV01.justinverstijnen.nl"

try {
    $ADSyncResults = Invoke-Command -ComputerName "$adconnectserver" -ScriptBlock {
        Start-ADSyncSyncCycle -PolicyType Delta
    }

    # Print results
    Write-Host "Synchronization results from remote server:`n" -ForegroundColor Cyan
    $ADSyncResults | Format-List *

    # Checking the status
    if ($ADSyncResults.Result -eq "Success") {
        Write-Host "Synchronization performed successfully." -ForegroundColor Green
    }
    else {
        Write-Error "Synchronization performed, but error message is $($ADSyncResults.Result)"
    }
}
catch {
    Write-Error "Error during synchronization: $_"
}

Start-Sleep -Seconds 15
