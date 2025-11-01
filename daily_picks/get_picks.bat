@echo off
REM Daily Picks Generator - Quick Run Script
REM Generates today's NCAA basketball betting recommendations

echo ========================================
echo   NCAA Basketball Daily Picks Generator
echo ========================================
echo.

python generate_picks.py

echo.
echo Done! Check daily_picks.csv for your picks.
echo.
pause
