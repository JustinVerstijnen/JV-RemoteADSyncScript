# Parameters
$adconnectserver = "server.local"
$adconnectadmin = "DOMAIN\user"

# Get Credentials
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "Please fill in password..."
$form.Size = New-Object System.Drawing.Size(400,180)
$form.StartPosition = "CenterScreen"

$labelUser = New-Object System.Windows.Forms.Label
$labelUser.Text = "Username:"
$labelUser.Location = New-Object System.Drawing.Point(10,20)
$labelUser.Size = New-Object System.Drawing.Size(100,20)
$form.Controls.Add($labelUser)

$textUser = New-Object System.Windows.Forms.TextBox
$textUser.Text = "$adconnectadmin"
$textUser.Location = New-Object System.Drawing.Point(120,20)
$textUser.Size = New-Object System.Drawing.Size(250,20)
$form.Controls.Add($textUser)

$labelPass = New-Object System.Windows.Forms.Label
$labelPass.Text = "Password:"
$labelPass.Location = New-Object System.Drawing.Point(10,60)
$labelPass.Size = New-Object System.Drawing.Size(100,20)
$form.Controls.Add($labelPass)

$textPass = New-Object System.Windows.Forms.TextBox
$textPass.UseSystemPasswordChar = $true
$textPass.Location = New-Object System.Drawing.Point(120,60)
$textPass.Size = New-Object System.Drawing.Size(250,20)
$form.Controls.Add($textPass)

$okButton = New-Object System.Windows.Forms.Button
$okButton.Text = "Let's sync"
$okButton.Location = New-Object System.Drawing.Point(280,100)
$okButton.Add_Click({ $form.Close() })
$form.Controls.Add($okButton)

$form.Topmost = $true
$form.Add_Shown({ $form.Activate() })
$form.ShowDialog() | Out-Null

# Performing the action
$securePassword = $textPass.Text | ConvertTo-SecureString -AsPlainText -Force
$credentials = New-Object System.Management.Automation.PSCredential ($textUser.Text, $securePassword)

try {
    $ADSyncResults = Invoke-Command -ComputerName "$adconnectserver" -Credential $credentials -ScriptBlock {
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

