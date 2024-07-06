$event_name = 'power_change_event'
$consumer_name = 'power_change_consumer'
$default_exec_path = "$PSScriptRoot\execute_on_change.ps1"
$default_exec_path = '"{0}"' -f $default_exec_path

function Get-Power-Change-Event {
  $p = @{
    Namespace = "Root/Subscription"
    ClassName = "__EventFilter"
    filter = "name = '$event_name'"}
  Get-CimInstance @p
}

function Get-Power-Change-Consumer {
  $p = @{
    Namespace = "Root/Subscription"
    ClassName = "CommandLineEventConsumer"
    filter = "name = '$consumer_name'"}
  Get-CimInstance @p
}

function Get-Power-Change-Binding {
  $p = @{
    Namespace = "Root/Subscription"
    ClassName = "__FilterToConsumerBinding"}
  Get-CimInstance @p | Where-Object {$_.Filter.Name -like $event_name}
}

function Add-Power-Change {
  param (
    $Path = $default_exec_path
  )

  Write-Verbose "Using '$Path' as script to execute"
  
  # Event
  $cim_event = Get-Power-Change-Event
  if (-not $cim_event) {
    $cmi = @{
      ClassName = "__EventFilter"
      Namespace = "Root/Subscription"
      Property = @{
	    Name = $event_name
	    EventNameSpace = "Root/CIMV2"
	    QueryLanguage = "WQL"
	    Query = "SELECT * FROM Win32_PowerManagementEvent WHERE EventType = 10"
      }
    }
    $cim_event = New-CimInstance @cmi
  }
  else {
    Write-Verbose "Power-Change-Event already exists"
  }

  # Consumer  
  $cim_consumer = Get-Power-Change-Consumer
  if (-not $cim_consumer) {
    $cmi = @{
      ClassName = "CommandLineEventConsumer"
      Namespace = "Root/Subscription"
      Property =  @{
	    Name = $consumer_name
	    CommandLineTemplate = "powershell.exe -file $path"
      }
    }
    $cim_consumer = New-CimInstance @cmi
  }
  else {
    Write-Verbose "Power-Change-Consumer already exists"
  }

  # Binding
  $cim_binding = Get-Power-Change-Binding
  if (-not $cim_binding) {
    $cmi = @{
      ClassName = "__FilterToConsumerBinding"
      Namespace = "Root/Subscription"
      Property =  @{
        Filter = [Ref]$cim_event
	    Consumer = [Ref]$cim_consumer
      }
    }
    $cim_binding = New-CimInstance @cmi
  }
  else {
    Write-Verbose "Power-Change-Binding already exists"
  }

  return
}

function Remove-Power-Change {
  Get-Power-Change-Event | Remove-CimInstance
  Get-Power-Change-Consumer | Remove-CimInstance
  Get-Power-Change-Binding | Remove-CimInstance
}

Export-ModuleMember -Function @(
  'Get-Power-Change-Event',
  'Get-Power-Change-Consumer',
  'Get-Power-Change-Binding',
  'Add-Power-Change',
  'Remove-Power-Change')
