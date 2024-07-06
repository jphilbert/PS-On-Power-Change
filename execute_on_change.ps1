$timeStamp = (Get-Date).toString("yyyy-MM-dd HH:mm:ss")
$logFile = "$PSScriptRoot\on_change.log"
$display = Get-WmiObject -Namespace root/WMI -Class WmiMonitorBrightnessMethods
. "$PSScriptRoot\audio.ps1"

$batterystatus = (Get-CimInstance win32_battery).batterystatus

# -------------------------------- On Battery -------------------------------- #
if ($batterystatus -eq 1) {
  # Log
  Add-content $LogFile -value "$timeStamp - On Battery"

  # Lower Brightness
  $display.WmiSetBrightness(1, 80)

  # Mute Sound
  [Audio]::Mute = $true
}
# ------------------------------ Not on Battery ------------------------------ #
else {
  # Log
  Add-content $LogFile -value "$timeStamp - On AC"
  
  # Full Brightness
  $display.WmiSetBrightness(1, 100)

  # Unmute Sound
  [Audio]::Mute = $false
}
