<#
.DESCRIPTION
This is a PoshWatcher configuration script currently in beta testing. Use this script to customize the PoshWatcher module's behavior, including
enabling or disabling specific functions and specifying their targets and other parameters. You can modify the configuration to your liking. This
is a bare bones example of how to use each function within the module. If you do not want to use a certain function set the Enabled = $true to Enabled = $false 
in the below configuration section. 

.EXAMPLE
.\PoshWatcherConfig.ps1

This example runs the script with the settings specified in the script.

.MANAGING BACKGROUND TASKS
1. Retrieve the status of background jobs:

Get-Job

This command will list all background jobs, their names, and their current status (e.g., Running, Completed, Failed).

2. Retrieve the output of a completed background job:

Receive-Job -Name <JobName>

Replace <JobName> with the name of the job you want to retrieve the output from. For example:

Receive-Job -Name "Start-PoshWatcherPing"

This command will display the output of the specified job.

3. Stop a running background job:

Stop-Job -Name <JobName>

Replace <JobName> with the name of the job you want to stop. For example:

Stop-Job -Name "Start-PoshWatcherPing"

This command will stop the specified job.
#>

# Import the PoshWatcher module
Import-Module ".\PoshWatcher.psd1" -Force

# User Configuration
$targets = @(
    "8.8.8.8",
    "8.8.4.4"
)

$disks = @(
    "C:",
    "D:"
)

# Ping function settings
$pingSettings = @{
    Enabled = $true
}

# Route function settings
$routeSettings = @{
    Enabled = $true
    HopLimit = 30
}

# Disk bench function settings
$diskBenchSettings = @{
    Enabled = $true
    Iterations = 5
    FileSize = "10MB"
}

# Define functions to run continuously
$functionsToRun = @(
    @{
        Name = "Start-PoshWatcherPing"
        Enabled = $pingSettings.Enabled
        Parameters = @{
            Target = $targets[0]
        }
    },
    @{
        Name = "Start-PoshWatcherRoute"
        Enabled = $routeSettings.Enabled
        Parameters = @{
            Target = $targets[1]
            HopLimit = $routeSettings.HopLimit
        }
    },
    @{
        Name = "Start-PoshWatcherDiskBench"
        Enabled = $diskBenchSettings.Enabled
        Parameters = @{
            Disks = $disks
            Iterations = $diskBenchSettings.Iterations
            FileSize = $diskBenchSettings.FileSize
        }
    }
)

# Start functions as background jobs
foreach ($function in $functionsToRun) {
    if ($function.Enabled) {
        $name = $function.Name
        $params = $function.Parameters
        $block = [ScriptBlock]::Create("$name $(&{$args}@params)")

        # Start the function as a background job
        Start-Job -Name $name -ScriptBlock $block
    }
}
