<#
.SYNOPSIS
  Script to remove simple C style comments.

.DESCRIPTION
  This script helps the user to remove C style comments for formatting purpose.

.INPUTS
  None. You cannot pipe objects to this command.

.OUTPUTS
  None. This command does not output any objects to be piped.

.PARAMETER Filter
  Specifies a filter in the provider's format or language. The value of this parameter qualifies the Path parameter.

.PARAMETER Destination
  Specifies a path to destination location. Wildcards are permitted. The default location is the current directory (.).

.LINK
  https://github.com/lokeshkumarbalu

.NOTES
  Author: Lokesh Kumar Balu
  Date: December 14, 2016
  Copyright @ Zealag 2016. All rights reserved.
#>

#Requires -Version 3.0
[CmdletBinding()]
Param
(
	[Parameter(
		Position = 1,
		Mandatory = $true)]
	[ValidateScript({Test-Path $PSItem -PathType "Leaf"})]
	[string]$Filter,

	[Parameter(
		Position = 2)]
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
			$line | Out-File -FilePath $outFile -Encoding utf8 -Append;
			$foundEmptyLine = $FALSE;
		}

		Write-Progress -Activity "Removing comments" `
			-Status "$processed/$lineCount lines complete:" `
			-PercentComplete $(($processed/$lineCount)*100);
	}
}

#Call Main function here.
Main;