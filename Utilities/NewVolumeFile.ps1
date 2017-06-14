<#
.SYNOPSIS
  Script to generate CSV gas volume file for upload.

.DESCRIPTION
  This script generates a CSV volume file for upload, the structure of the CSV is predefined.

  Gas Volume file structure:
  ==> <Deal number>; <Start date>; <End date>; <Volume type>; <Volume>

.INPUTS
  None. You cannot pipe objects to this command.

.OUTPUTS
  None. This command does not output any objects to be piped.

.LINK
  https://github.com/lokeshkumarbalu

.NOTES
  Author: Lokesh Kumar Balu
  Date: June 12, 2017
  Copyright @ Zealag 2017. All rights reserved.
#>

#Requires -Version 3.0

[CmdletBinding()]
Param
(
	[Parameter(
		Mandatory = $true, 
		Position = 1, 
		HelpMessage = "The deal for which volume file must be generated.")]
	[string]$DealNumber,

	[Parameter(
		Mandatory = $true, 
		Position = 2, 
		HelpMessage = "The volume type that is to be updated.")]
	[ValidateSet("Trading", "Planned", "Optimized", "Metered", "Allocated")]
	[string]$VolumeType,

	[Parameter(
		Mandatory = $true, 
		Position = 3, 
		HelpMessage = "Start date (inclusive) from which the volume must be updated.")]
	[DateTime]$StartDate,

	[Parameter(
		Mandatory = $true, 
		Position = 4, 
		HelpMessage = "End date (inclusive) till which the volume must be updated.")]
	[DateTime]$EndDate,

	[Parameter(
		Mandatory = $true, 
		Position = 5, 
		HelpMessage = "Volume quantity (daily volume) to be updated for the time period specified.")]
	[String]$Quantity
)

$line = "";
$FileName = $(".\") + $DealNumber + $("_") +$VolumeType +$(".csv");
$volumeTypeId = 2;

if ($(Test-Path -Path $FileName -PathType Leaf) -eq $false)
{
	$header = "deal_id,param_seq_num,schedule_date,volume_type_id,quantity";
	$header >> $FileName;
}


Switch($VolumeType)
{
	"Trading"	{$volumeTypeId = 2 }
	"Metered"	{$volumeTypeId = 7 }
	"Allocated"	{$volumeTypeId = 8 }
	"Planned"	{$volumeTypeId = 19}
	"Optimized"	{$volumeTypeId = 22}
}

for (;$StartDate -le $EndDate; $StartDate = $StartDate.AddDays(1))
{
	$DealNumber + $(",1,") + `
	$StartDate.ToString("yyyy-MM-dd") + $(",") + `
	$volumeTypeId + $(",") + `
	$Quantity >> $FileName;
}
