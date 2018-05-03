@echo off
setlocal EnableDelayedExpansion

REM AWS Route 53 Bulk Record Importer
REM Part 1 - Powershell Executor and AWS CLI Executor
REM Created by Cory Burns
REM
REM This script is designed to update Route 53 hosted zones in bulk.
REM This batch script handles the bulk of the work, with a secondary Powershell script designed to read a CSV and exporting JSON
REM Please see the github or gitlab README.md file for usage


REM Create the JSON Records for AWS
set /p CSVPATH="Enter file name for the CSV of record changes: "
set /p JSONPATH="Enter full path to JSON Directory: "

REM Set the path for the JSON creating powershell
set ThisScriptsDirectory=%~dp0
set PowerShellScriptPath=%ThisScriptsDirectory%bulkroute53.ps1

REM Create the JSON files containing the DNS changes per domain
Powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& '%PowerShellScriptPath%' -csv_path '%CSVPATH%' -json_path '%JSONPATH%'"

REM Move into the JSON Directory.  This removes the absolute path of the file when doing the for loop, so we don't have to do any funky string cutting
cd %JSONPATH%

for %%a in (*.json) do (
	REM Get the current JSON file and cut the ".json" off it
	set FILENAME=%%~a
	set DOMAIN=!FILENAME:~,-5!

	REM Get the AWS ID of the domain in question
	echo Updating DNS for !DOMAIN!
	for /f %%b in ('aws route53 list-hosted-zones-by-name --dns-name !DOMAIN! --output text --query HostedZones[0].Id') do set RAW_DOMAIN_ID=%%b

	REM cut /hostedzone/ from the domain ID
	set DOMAIN_ID=!RAW_DOMAIN_ID:~12!
	
	REM update the Route53 hosted zone
	aws route53 change-resource-record-sets --hosted-zone-id !DOMAIN_ID! --change-batch file://!JSONPATH!\!FILENAME!
)

REM Stop where we started
cd %ThisScriptsDirectory%