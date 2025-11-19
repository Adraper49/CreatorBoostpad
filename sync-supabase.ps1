# Set up paths
$projectPath = "C:\KB\Apps\CreatorBoostpad"
$migrationsPath = "$projectPath\supabase\migrations"
$logPath = "$projectPath\logs"
$logFile = "$logPath\sync-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

# Create log directory if it doesn't exist
if (!(Test-Path -Path $logPath)) {
    New-Item -ItemType Directory -Path $logPath | Out-Null
}

Start-Transcript -Path $logFile -Append
Set-Location $projectPath

Write-Host "`n🟦 Starting Supabase schema sync..." -ForegroundColor Cyan

# --- ENVIRONMENT CHECKS ---
docker info > $null 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "`n❌ Docker is not running. Please start Docker Desktop." -ForegroundColor Red
    Stop-Transcript
    exit 1
}

git --version > $null 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "`n❌ Git is not installed or not in PATH." -ForegroundColor Red
    Stop-Transcript
    exit 1
}

supabase --version > $null 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "`n❌ Supabase CLI is not installed or not in PATH." -ForegroundColor Red
    Stop-Transcript
    exit 1
}

# --- SCHEMA PULL ---
supabase db pull
if ($LASTEXITCODE -ne 0) {
    Write-Host "`n❌ supabase db pull failed. Aborting." -ForegroundColor Red
    Stop-Transcript
    exit 1
}

# --- GIT STAGING ---
git add $migrationsPath
$diff = git diff --cached --name-only

if ($diff) {
    Write-Host "`n📰 New migration changes detected:" -ForegroundColor Yellow
    Write-Host $diff

    # --- COMMIT ---
    git commit -m "sync: pulled latest schema from remote"
    Write-Host "`n✅ Git commit completed." -ForegroundColor Green

    # --- PUSH TO REMOTE ---
    git push
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n🚀 Git push successful." -ForegroundColor Green
    } else {
        Write-Host "`n⚠️ Git push failed. Please check remote configuration." -ForegroundColor Red
    }

    # --- CREATE TAG ---
    $latestMigration = Get-ChildItem -Path $migrationsPath -Filter "*_remote_schema.sql" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($latestMigration) {
        $timestamp = ($latestMigration.BaseName -split "_")[0]
        $tag = "migration-$timestamp"

        git tag $tag
        git push origin $tag
        if ($LASTEXITCODE -eq 0) {
            Write-Host "`n🏷️ Git tag '$tag' created and pushed." -ForegroundColor Cyan
        } else {
            Write-Host "`n⚠️ Git tag creation or push failed." -ForegroundColor DarkYellow
        }
    }

} else {
    Write-Host "`n📂 No new migration changes to commit." -ForegroundColor Gray
}

# --- DB PUSH TO SUPABASE ---
supabase db push
if ($LASTEXITCODE -eq 0) {
    Write-Host "`n🚀 Supabase DB is up to date." -ForegroundColor Green
} else {
    Write-Host "`n❌ supabase db push failed." -ForegroundColor Red
}

Stop-Transcript
