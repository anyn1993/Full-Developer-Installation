@echo off
echo ================================================
echo   Developer Tools Stack
echo ================================================
echo.

REM Check if Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo [X] Docker is not running. Please start Docker Desktop first.
    pause
    exit /b 1
)

echo [OK] Docker is running
echo.

REM Check for .env file
if not exist ".env" (
    echo [*] Creating .env file from template...
    copy env.example .env
    echo     Edit .env to customize your configuration
    echo.
)

REM Initialize Harbor certificates
if exist "harbor\init.sh" (
    echo [*] Note: Run harbor/init.sh in Git Bash or WSL before first start
    echo.
)

echo.
echo [*] Starting services...
echo.

docker compose up -d

if errorlevel 0 (
    echo.
    echo ================================================
    echo   Services started successfully!
    echo ================================================
    echo.
    echo Service URLs (add to hosts file for localhost):
    echo    Dashboard:    https://localhost
    echo    GitLab:       https://gitlab.localhost
    echo    Jenkins:      https://jenkins.localhost
    echo    Portainer:    https://portainer.localhost
    echo    Harbor:       https://harbor.localhost
    echo    Nextcloud:    https://nextcloud.localhost
    echo    n8n:          https://n8n.localhost
    echo    Homarr:       https://homarr.localhost
    echo.
    echo Default Credentials:
    echo    GitLab:     root / ChangeThisPassword123!
    echo    Harbor:     admin / Harbor12345!
    echo    Nextcloud:  admin / NextcloudAdmin123!
    echo    n8n:        admin / n8nAdmin123!
    echo    Others:     Set up on first access
    echo.
    echo IMPORTANT: Change default passwords after first login!
    echo.
    echo Notes:
    echo    - GitLab may take 3-5 minutes to fully start
    echo    - Harbor may take 1-2 minutes to fully start
    echo    - All data is persisted in Docker volumes
    echo    - Run 'docker compose logs -f' to view logs
    echo    - Run 'stop.bat' to stop services
    echo.
) else (
    echo.
    echo [X] Failed to start services. Check errors above.
    echo     Run 'docker compose logs' for details.
)

pause
