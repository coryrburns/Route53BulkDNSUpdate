# ROUTE 53 BULK HOSTED ZONE UPDATER
#### By Cory Burns

This is a collection of scripts designed to bulk update Route 53 hosted zones (i.e. bulk update DNS in AWS)

There are two parts to the script:
* A Powershell script that takes in a CSV file and exports JSON
* A batch script, which is what the user executes and handles the AWS portion and kicks off the Powershell script

You also need to create the CSV file (example included) and be logged into your AWS account via CMD

## The CSV

The CSV file has 5 columns, all of which are required.  The column headers are also required

* Domain
 * This is the name of the hosted zone in AWS.  For example foo.bar.  If you have a delegated subdomain (sub.foo.bar) as it's own hosted zone, you would use that name as well
* Subdomain
 * This is the actual record that you want to update.  Put JUST the subdomain.  For example if you want to update www.foo.bar, just put www (no punctuation).  If you want to update the top level domain (i.e. foo.bar) use @
* Action
 * This is the AWS action that you want to perform on the hosted zone.  They are case sensitive.  These are
  * CREATE
   * Creates a new record set.  Will fail if one already exists
  * DELETE
   * Deletes a record set
  * UPSERT
   * Adds a new record set, or overwrites a record set if one already exists
* RecordType
  * The record type for the new entry.  A, CNAME, etc.
* RecordData
  * The value for the new record set.  The IP address, TXT record, etc

## Using The Script

* Download both the Powershell and Batch file to the same directory as your CSV.
* Open a command prompt
* Log into AWS using AWS Configure or set your profile (set AWS_PROFILE=profilename) if you have one saved
* Run the batch script bulkroute53.bat
* It will ask you for the name of the CSV file.  If you don't specify a full path it will assume current working directory
* It will ask you for a location to store the JSON files.  I recommend somewhere simple such as C:\Temp.  No trailing slash required
* The script will then do it's magic.  It will create the JSON files and then attempt to update each record.  It will either provide a successful JSON output, or it will display an error
* Typically it takes a few minutes for the change command to propagate in AWS.  Each successful change has an ID.  You can run the command aws route53 get-change --id ID# where ID# is the ID of the change (If your change ID is /chiange/CY39JX9641T3C your command would be aws route53 get-change --id CY39JX9641T3C)
* The created JSON is not automatically deleted.  This is for record keeping purposes.  Once the script runs you can delete the JSON if you want, or store in some location for tracking purposes

## Caveats and Known Issues

This script currently only handles Basic DNS.  It does not handle Aliases, Weighted DNS, Latency, Failover, or any other special Route53 features.

This script can only handle one change per top level domain at a time, due to how the JSON files are written.  This is something that I would like to fix in a future update.  For now, if you need to update multiple foo.bar records, you will need to do so manually or create multiple CSV files

I have not tested the script for file paths with spaces in them, so keep that in mind

# AWS Syntax

If you want to make changes to this script (to allow for special DNS, etc) the AWS CLI commands used can be found [here](https://docs.aws.amazon.com/cli/latest/reference/route53/change-resource-record-sets.html)
