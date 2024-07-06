

function padCenter {
  param (
    [string] $text,
    $length,
    [string] $padding
  )
  $text = $text.padLeft(($length + $text.length + 1)/2, $padding)
  $text.padRight($length, $padding)
}

function Write-Var {
  param (
    [string] $text,
    [string] $var
  )
  $format_str = "{0:25} `r`n    -> {1}"
  
  Write-Host ([string]::Format($format_str, $text, $var))
}


# This directory
$source = $PSScriptRoot

# Name of module
$moduleName = Split-Path $source -leaf
$moduleName = $moduleName.replace("PS-", "")

# Destination
$destination = "$Env:ProgramFiles\WindowsPowerShell\Modules\$moduleName\"

# Files not to copy
$exclude = "install.ps1"


Write-Host (padcenter " Installing Module: $moduleName " 80 '-')
Write-Var "Source Directory:" $source
Write-Var "Destination Directory:" $destination


# Make destination directory
if (-not (Test-Path $destination)) { mkdir $destination | Out-Null }

# Copy files
Write-Host "Copying:"
Get-item "$source\*" | 
  Where-Object {$_.Name -notin $exclude} | 
  Foreach-Object {
    Write-Host ("    -> $_".replace($source, "."))
    Copy-Item $_ -Destination $destination -Force -Recurse
  }
