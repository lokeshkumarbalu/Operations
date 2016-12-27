#requires -version 2
<#
.SYNOPSIS
  Script to remove simple C style comments.

.DESCRIPTION
  This script helps the user to remove C style comments for formatting purpose.

.NOTES
  Copyright © Zealag 2016. All rights reserved.
#>

[CmdletBinding()]
Param
(
	[Parameter(Mandatory = $true, Position = 1)]
	[ValidateScript({Test-Path $PSItem -PathType "Leaf"})]
	[string]$FileName,

	[Parameter(Position = 2)]
	[ValidateScript({Test-Path $PSItem -PathType "Container"})]
	[string]$Destination = ".\"
)

$SourceFile = Get-ChildItem $FileName;
$outFile = $($(Resolve-Path $Destination).ToString());
$outFile = $($outFile + "\Out_" + $SourceFile.BaseName + $SourceFile.Extension);

$content = Get-Content $(Resolve-Path $FileName);
$foundMultiLineComment = $FALSE;
$lineCount = $content.Length;
$processed = 0;

Write-Verbose -Message "Working on the file $(Resolve-Path $FileName)";
Write-Verbose -Message "Destination path: $(Resolve-Path $Destination)";
Write-Verbose -Message "Output file: $outFile";

ForEach ($line in $content)
{
	$processed = $processed + 1;
	if ($($line.Length) -eq 0)
	{
		$line >> $outFile;
		Write-Progress -Activity "Removing comments" `
			-Status "$processed/$lineCount lines complete:" `
			-PercentComplete $(($processed/$lineCount)*100);
		continue;
	}

	if ($foundMultiLineComment -eq $FALSE)
	{
		$line = $line -replace '\/\*.*\*\/' , '';
		$line = $line -replace '\/\/.*', '';
		if ($line -match '\/\*.*' -eq $TRUE)
		{
			$foundMultiLineComment = $TRUE;
			$line = $line -replace '\/\*.*', '';
		}
		$line = $line.Trim();
	}
	else
	{
		if($line -match '.*\*\/' -eq $TRUE)
		{
			$line = $line -replace '.*\*\/' , '';
			$line = $line -replace '\/\/.*', '';
			$line = $line.Trim();
			$foundMultiLineComment = $FALSE;
		}
		else
		{
			$line = $line -replace '.*' , '';
		}
	}
	
	if ($($line.Length) -ne 0)
	{
		$line >> $outFile;
	}

	Write-Progress -Activity "Removing comments" `
		-Status "$processed/$lineCount lines complete:" `
		-PercentComplete $(($processed/$lineCount)*100);
}






