# AWS Route 53 Bulk Record Importer
# Part 2 - JSON Creator
# Created by Cory Burns
#
# This script is launched from the bulkroute53.bat file and will load in a CSV and create the appropriate JSON
# These JSON files will be used by the original batch script to update Route 53 hosted zones
# Please see the github or gitlab README.md file for usage (typically you will not run this file manually)

# The required paths will be passed from the Batch script
# Default variables presented for sanity
param([string]$csv_path = "domains.csv", [string]$json_path = "C:\Temp")

$domains = @()

Write-Host "Creating the JSON files..."
Import-Csv $csv_path | ForEach-Object {
		# Grab the variables by the header information
        $domain     = $_.Domain
		$subdomain  = $_.Subdomain
        $action     = $_.Action
        $recordType = $_.RecordType
        $recordData = $_.RecordData

        # Save the domain
		$domains += $domain

		# Write the json file
		$json = @"
{{
	"Changes": [
	{{
		"Action": "{2}",
		"ResourceRecordSet": {{
			"Name": "{1}.{0}.",
			"Type": "{3}",
			"TTL": 300,
			"ResourceRecords": [
			{{
				"Value": "{4}"
			}}
			]
		}}
	}}
	]
}}
"@ -f $domain, $subdomain, $action, $recordType, $recordData
		# Create the JSON file at the path specified
		$saved_json = "$json_path\$domain.json"
		$json | Out-File $saved_json -Encoding ascii
	}