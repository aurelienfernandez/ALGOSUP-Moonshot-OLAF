# Check if .ssh directory exists in user's home directory, create if it doesn't
$sshDir = Join-Path $env:USERPROFILE ".ssh"
if (-not (Test-Path $sshDir)) {
    New-Item -Path $sshDir -ItemType Directory | Out-Null
}

# Check if id_rsa and id_rsa.pub exist in the current directory
$currentDir = Get-Location
$idRsaPath = Join-Path $currentDir "id_rsa"
$idRsaPubPath = Join-Path $currentDir "id_rsa.pub"

if (-not (Test-Path $idRsaPath) -or -not (Test-Path $idRsaPubPath)) {
    Write-Host "Error: id_rsa and/or id_rsa.pub files not found in current directory." -ForegroundColor Red
    exit 1
}

# Copy the SSH key files to the .ssh directory
Copy-Item -Path $idRsaPath -Destination $sshDir
Copy-Item -Path $idRsaPubPath -Destination $sshDir

# Set appropriate permissions on the private key
$acl = Get-Acl -Path (Join-Path $sshDir "id_rsa")
$acl.SetAccessRuleProtection($true, $false)
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule($env:USERNAME, "FullControl", "Allow")
$acl.AddAccessRule($rule)
Set-Acl -Path (Join-Path $sshDir "id_rsa") -AclObject $acl

Write-Host "SSH keys have been copied to $sshDir"
$piUser = "aurelienfernandez"
$piHost = "192.168.1.198"

# Language selection
function Get-LanguageChoice {
    $choice = ""
    while ($choice -ne "1" -and $choice -ne "2") {
        $choice = Read-Host -Prompt "(1) English`n(2) French`nSelect your language/Choisissez votre langue"
        if ($choice -ne "1" -and $choice -ne "2") {
            Write-Host "Please select 1 or 2. / Veuillez sélectionner 1 ou 2."
        }
    }
    return $choice
}

$languageChoice = Get-LanguageChoice

# Set up translations
$prompts = @{}
if ($languageChoice -eq "1") {
    # English prompts
    $prompts.email = "Enter your email address"
    $prompts.plantName = "Enter the name of your plant"
    $prompts.potName = "Enter the name of the pot"
    $prompts.ssid = "Enter your WiFi network name (SSID)"
    $prompts.password = "Enter your WiFi password"
    $prompts.copying = "Copying configuration to Raspberry Pi..."
    $prompts.wifiUpdated = "Wi-Fi configuration updated! If you changed networks, you may lose your SSH connection."
    $prompts.userInfoSaved = "User information has been saved on the Raspberry Pi."
} else {
    # French prompts
    $prompts.email = "Entrez votre adresse email"
    $prompts.plantName = "Entrez le nom de votre plante"
    $prompts.potName = "Entrez le nom du pot"
    $prompts.ssid = "Entrez le nom de votre réseau WiFi (SSID)"
    $prompts.password = "Entrez votre mot de passe WiFi"
    $prompts.copying = "Copie de la configuration vers le Raspberry Pi..."
    $prompts.wifiUpdated = "Configuration WiFi mise à jour ! Si vous avez changé de réseau, vous pourriez perdre votre connexion SSH."
    $prompts.userInfoSaved = "Les informations utilisateur ont été enregistrées sur le Raspberry Pi."
}

# Prompt for user's email
$email = Read-Host -Prompt $prompts.email

# Prompt for plant and pot names
$potName = Read-Host -Prompt $prompts.potName
$plantName = Read-Host -Prompt $prompts.plantName

# Prompt the user for WiFi credentials
$ssid = Read-Host -Prompt $prompts.ssid
$psk = Read-Host -Prompt $prompts.password -AsSecureString

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

Write-Host $prompts.copying

# Test SSH connection first to see if Pi is reachable
try {
    $testOutput = & ssh -o ConnectTimeout=10 "$piUser@$piHost" "echo CONNECTION_OK" 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        throw "Test de connexion SSH échoué: $testOutput"
    }
} catch {
    Write-Host "Erreur lors du test de connexion SSH: $_" -ForegroundColor Red
    Write-Host "Vérifiez que:" -ForegroundColor Yellow
    Write-Host " - Le Raspberry Pi est allumé et connecté au réseau" -ForegroundColor Yellow
    Write-Host " - L'adresse IP (${piHost}) est correcte" -ForegroundColor Yellow
    Write-Host " - La clé SSH est correctement installée" -ForegroundColor Yellow
    Write-Host " - Le nom d'utilisateur ($piUser) est correct" -ForegroundColor Yellow
    Remove-Item $tempFile.FullName
    
    # Add prompt to press Enter before closing
    Write-Host $prompts.pressEnter
    Read-Host | Out-Null
    exit 1
}

# Copy the file to the Pi's /tmp directory
try {
    & scp $tempFile.FullName "$piUser@${piHost}:/tmp/wpa_supplicant.conf" | Out-Null
    
    if ($LASTEXITCODE -ne 0) {
        throw "Échec de copie du fichier de configuration WiFi"
    }
} catch {
    Write-Host "Error: Failed to copy Wi-Fi configuration to Raspberry Pi. $_" -ForegroundColor Red
    Remove-Item $tempFile.FullName
    
    # Add prompt to press Enter before closing
    Write-Host $prompts.pressEnter
    Read-Host | Out-Null
    exit 1
}

# Create a JSON object with user information
$userInfo = @{
    email = $email
    plant_name = $plantName
    pot_name = $potName
}

# Convert to JSON and save to a temporary file
$userInfoFile = New-TemporaryFile
$userInfo | ConvertTo-Json | Set-Content $userInfoFile.FullName

# Copy the user info JSON file to the Pi
try {
    & scp $userInfoFile.FullName "$piUser@${piHost}:/tmp/user_info.json" | Out-Null
    
    if ($LASTEXITCODE -ne 0) {
        throw "Échec de copie des informations utilisateur"
    }
} catch {
    Write-Host "Error: Failed to copy user information to Raspberry Pi. $_" -ForegroundColor Red
    Remove-Item $tempFile.FullName
    Remove-Item $userInfoFile.FullName
    
    # Add prompt to press Enter before closing
    Write-Host $prompts.pressEnter
    Read-Host | Out-Null
    exit 1
}

# Move the files into place and reconfigure Wi-Fi 
try {
    $sshCommand = "sudo mv /tmp/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf && sudo wpa_cli -i wlan0 reconfigure && sudo mv /tmp/user_info.json /home/$piUser/user_info.json"
    ssh "$piUser@$piHost" $sshCommand | Out-Null
    
    if ($LASTEXITCODE -ne 0) {
        throw "SSH command failed with exit code $LASTEXITCODE"
    }
    Write-Host "Configuration réussie!" -ForegroundColor Green
} catch {
    Write-Host "Error: Failed to configure Raspberry Pi. $_" -ForegroundColor Red
    Remove-Item $tempFile.FullName
    Remove-Item $userInfoFile.FullName
    
    # Add prompt to press Enter before closing
    Write-Host $prompts.pressEnter
    Read-Host | Out-Null
    exit 1
}
# Add prompt to press Enter to continue
if ($languageChoice -eq "1") {
    $prompts.pressEnter = "Press Enter to close..."
} else {
    $prompts.pressEnter = "Appuyez sur Entree pour fermer..."
}

Write-Host $prompts.pressEnter
Read-Host | Out-Null
# Clean up the temp files
Remove-Item $tempFile.FullName
Remove-Item $userInfoFile.FullName

Write-Host $prompts.wifiUpdated
Write-Host $prompts.userInfoSaved

Write-Host $prompts.wifiUpdated
Write-Host $prompts.userInfoSaved
