@echo off
echo ================================================
echo   Stopping Developer Tools Stack
echo ================================================
echo.

echo [*] Stopping services...
docker compose down

if errorlevel 0 (
    echo.
    echo [OK] All services stopped successfully!
    echo.
    echo Note: Your data is preserved in Docker volumes.
    echo       Run 'start.bat' to start services again.
    echo.
    echo WARNING: To remove all data and volumes, run:
    echo          docker compose down -v
    echo.
) else (
    echo.
    echo [X] Failed to stop services. Check errors above.
)

pause
