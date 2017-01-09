#requires -version 3
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
	[Parameter(Position = 1, Mandatory = $true)]
	[ValidateScript({Test-Path $PSItem -PathType "Leaf"})]
	[string]$Filter,

	[Parameter(Position = 2)]
	[ValidateScript({Test-Path $PSItem -PathType "Container"})]
	[string]$Destination = ".\"
)

Write-Verbose -Message "Working with filter: $Filter";
Write-Verbose -Message "Destination path: $(Resolve-Path $Destination)";

Function Main()
{
	$fileList = Get-ChildItem $Filter -File;
	ForEach ($file in $fileList)
	{
		ProcessFile($file);
	}
}

Function ProcessFile($fileName) 
{
	$content = Get-Content $(Resolve-Path $fileName);
	$outFile = $($(Resolve-Path $Destination).ToString());
	$outFile = $($outFile + "\Out_" + $fileName.BaseName + $fileName.Extension);

	Write-Verbose -Message "Working on the file $(Resolve-Path $fileName)";
	Write-Verbose -Message "Output file: $outFile";

	$foundEmptyLine = $TRUE;
	$foundMultiLineComment = $FALSE;
	$lineCount = $content.Length;
	$processed = 0;

	ForEach ($line in $content)
	{
		$processed = $processed + 1;
		if ($($line.Length) -eq 0)
		{
			if ($foundEmptyLine -eq $FALSE)
			{
				$line >> $outFile;
				$foundEmptyLine = $TRUE;
			}
			
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
			$line = $line.TrimEnd();
		}
		else
		{
			if($line -match '.*\*\/' -eq $TRUE)
			{
				$line = $line -replace '.*\*\/' , '';
				$line = $line -replace '\/\/.*', '';
				$line = $line.TrimEnd();
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
			$foundEmptyLine = $FALSE;
		}

		Write-Progress -Activity "Removing comments" `
			-Status "$processed/$lineCount lines complete:" `
			-PercentComplete $(($processed/$lineCount)*100);
	}
}

#Call Main function here.
Main;



