$piUser = "aurelienfernandez"
$piHost = "plant-pot"

# Prompt for user's email
$email = Read-Host -Prompt "Enter your email address"

# Prompt the user for WiFi credentials
$ssid = Read-Host -Prompt "Enter your WiFi network name (SSID)"
$psk = Read-Host -Prompt "Enter your WiFi password" -AsSecureString

# Convert secure string to plain text (needed for the configuration)
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($psk)
$plainPsk = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

# Create a temporary file for the new wpa_supplicant.conf
$tempFile = New-TemporaryFile

# Write the new Wi-Fi config to the temp file FIRST
@"
network={
    ssid="$ssid"
    psk="$plainPsk"
}
"@ | Set-Content $tempFile.FullName

Write-Host "Copying configuration to Raspberry Pi..."

# Copy the file to the Pi's /tmp directory
& scp $tempFile.FullName "$piUser@${piHost}:/tmp/wpa_supplicant.conf"

# Create a temporary file for the user email
$emailFile = New-TemporaryFile
$email | Set-Content $emailFile.FullName

# Copy the email file to the Pi
& scp $emailFile.FullName "$piUser@${piHost}:/tmp/user.txt"

# Move the files into place and reconfigure Wi-Fi (requires Pi password)
$sshCommand = "sudo mv /tmp/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf && sudo wpa_cli -i wlan0 reconfigure && sudo mv /tmp/user.txt /home/$piUser/user"
ssh "$piUser@$piHost" $sshCommand

# Clean up the temp files
Remove-Item $tempFile.FullName
Remove-Item $emailFile.FullName

Write-Host "Wi-Fi configuration updated! If you changed networks, you may lose your SSH connection."
Write-Host "User email has been saved on the Raspberry Pi."