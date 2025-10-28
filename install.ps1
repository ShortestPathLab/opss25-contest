# ===============================
# Configuration
# ===============================
$envName = "opss25"
$packagesDir = "$HOME\$envName\packages"
$planvizRepo = "https://github.com/MAPF-Competition/PlanViz"
$scriptsRepo = "https://github.com/ShortestPathLab/opss25-contest-setup"  # replace with actual URL
$pythonVersion = "3.11"

# ===============================
# Helper functions
# ===============================

function Add-ToUserPath {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FolderPath
    )

    # Get the current user PATH
    $currentUserPath = [Environment]::GetEnvironmentVariable("Path", "User")

    # Check if the folder is already in PATH
    if (-not $currentUserPath.Split(';') -contains $FolderPath) {
        # Append the folder to the PATH
        $newUserPath = "$currentUserPath;$FolderPath"

        # Set the new PATH permanently for the current user
        [Environment]::SetEnvironmentVariable("Path", $newUserPath, "User")

        Write-Output "Added '$FolderPath' to user PATH."
    } else {
        Write-Output "'$FolderPath' is already in PATH."
    }
}


function Install-IfMissing {
    param(
        [string]$Command,
        [ScriptBlock]$InstallAction
    )

    if (-not (Get-Command $Command -ErrorAction SilentlyContinue)) {
        Write-Host "❌ $Command not found. Installing..."
        & $InstallAction
    } else {
        Write-Host "✅ $Command already installed."
    }
}

function Ensure-CondaEnv {
    param(
        [string]$EnvName,
        [string]$PythonVersion
    )
    
    conda init powershell
    $envs = & conda env list
    if (-not ($envs -match "^\s*$EnvName\s")) {
        Write-Host "❌ Conda environment '$EnvName' not found. Creating..."
        conda create -y -n $EnvName python=$PythonVersion
    } else {
        Write-Host "✅ Conda environment '$EnvName' already exists."
    }
}

function Clone-IfMissing {
    param(
        [string]$RepoUrl,
        [string]$TargetDir,
        [ScriptBlock]$SetupAction
    )

    if (-not (Test-Path $TargetDir)) {
        Write-Host "❌ $TargetDir not found. Cloning from $RepoUrl..."
        git clone $RepoUrl $TargetDir
    } else {
        Write-Host "✅ $TargetDir already exists, skipping clone."
    }
    
    Write-Host "🔄 Running setup commands for $TargetDir..."
    Push-Location $TargetDir
    & $SetupAction
    Pop-Location
    Write-Host "✅ Finished setup for $TargetDir."
}

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ===============================
# 1. Check/install Git
# ===============================
Install-IfMissing "git" {
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        choco install git -y
    } elseif (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install --id Git.Git -e --source winget
    } else {
        Write-Warning "⚠️ Please install Git manually."
        exit 1
    }
}

# ===============================
# 2. Check/install Docker
# ===============================
Install-IfMissing "docker" {
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        choco install docker-desktop -y
    } elseif (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install --id Docker.DockerDesktop -e --source winget
    } else {
        Write-Warning "⚠️ Please install Docker manually."
        exit 1
    }
}

# ===============================
# 3. Check/install Conda
# ===============================
Install-IfMissing "conda" {
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        choco install miniconda3 -y
    } elseif (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install --id Anaconda.Miniconda3 -e --source winget
    } else {
        Write-Warning "⚠️ Please install Miniconda manually."
        exit 1
    }
    $env:Path = "$HOME/miniconda3/Scripts;$env:Path"
    Add-ToUserPath "$HOME/miniconda3/Scripts"
}

# ===============================
# 4. Ensure opss25 environment
# ===============================
Ensure-CondaEnv -EnvName $envName -PythonVersion $pythonVersion

# ===============================
# 5. Activate opss25 environment
# ===============================
Write-Host "🔄 Activating conda environment '$envName'..."
conda activate $envName

# ===============================
# 6. PlanViz setup
# ===============================
$planvizDir = "$packagesDir\PlanViz"
if (-not (Get-Command planviz -ErrorAction SilentlyContinue)) {
    Clone-IfMissing -RepoUrl $planvizRepo -TargetDir $planvizDir -SetupAction {
        Write-Host "Installing PlanViz..."
        pip install -r requirements.txt
    }
} else {
    Write-Host "✅ planviz already in PATH."
}

# ===============================
# 7. Lifelong scripts setup
# ===============================
$scriptsDir = "$packagesDir\setup"
$scriptsSubDir = "$scriptsDir\scripts"
if (-not (Get-Command opss25-uninstall -ErrorAction SilentlyContinue)) {
    Clone-IfMissing -RepoUrl $scriptsRepo -TargetDir $scriptsDir -SetupAction {
        Write-Host "Adding scripts to PATH..."
        Add-ToUserPath -FolderPath "$scriptsSubDir"
    }
} else {
    Write-Host "✅ scripts already in PATH."
}

# ===============================
# Done
# ===============================
Write-Host ""
Write-Host "🎉 Setup complete!"
Write-Host "👉 You may need to restart your PowerShell session."
Write-Host "👉 And activate your environment: conda activate $envName"
Write-Host ""
Write-Host "Available scripts:"
Write-Host " - opss25-planviz : Launch PlanViz tool"
Write-Host " - opss25-lifelong : Run lifelong planning with the League of Robot Runners Start Kit"
Write-Host " - opss25-uninstall : Uninstall opss25 environment and delete files"
