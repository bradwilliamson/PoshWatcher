# PoshWatcher

PoshWatcher is a PowerShell module which started out as a simple tool for monitoring network latency, packet loss, standard deviation and jitter with ongoing disputes with my  Internet Service Provider. It provides real-time statistics on response times, packet loss, and jitter to help you analyze the quality of your network connection. It is now being rewritten as a powershell monitoring platform for monitoring all things possible on systems, and network connecitivity. With the end goal of exporting that data into InfluxDB or other data sources for Grafana

## Prerequisites 

To use the PoshWatcher module, you will need:

- PowerShell 5.1 or later
- Administrator privileges to run the module

## Features

- Monitor ping response times for a target host or IP address
- Real-time statistics on lowest, highest, and average ping response times
- Calculate packet loss percentage
- Calculate jitter and average jitter
- Retrieve your Internet Service Provider (ISP) name
- Calculate the standard deviation of an array of numbers
- Benchmark your local disks with temporary files with sizes of 1MB, 10MB, and 100MB. Default is 10MB
- Run a continious trace route to a target by default and review the latency per hop, and get displayed output per iteration of which hop has the highest latency. To quickly identify routing issues. Timed out requests will result in a 0ms latency instead of * * * from regular command prompt tracert. 
- New wrapper configuration script called PoshWatcherConfig.ps1 to launch all the functions with the module and define which ones to toggle off and on. This will launch each function as a background task to run. You can still import the module, and run each function manually and interactively to display the output real time. 

- InfluxDB integration is being worked on and might be available in a future edition. This would allow sending monitoring data to InfluxDB for visualization in Grafana.
- Exploring implementing pester testing with this module and as a requirement for pull request. As of now all testing is being manually done on Windows 10, 11, and Windows 2019/2022 Server packer images

Monitoring system resources on the local PC is actively being developed. Local disk benchmarking is now available along with other resources in planning. 
## Installation

1. Clone the repository or download the source code:

    ```bash
    git clone https://github.com/yourusername/poshwatcher.git
    ```

2. Change to the `poshwatcher` directory and import the module:

    ```powershell
    cd poswatcher
    Import-Module .\poshwatcher.psd1
    ```

## Interactive Usage

### Start-PoshWatcherPing

To start continuous ping monitoring for a target host or IP address, use the `Start-PoshWatcherPing` function:

```powershell
Start-PoshWatcherPing -Target "8.8.8.8"
  ```
By default, the interval between ping requests is 1 second. You can change the interval by specifying the -IntervalInSeconds parameter:

```powershell
Start-PoshWatcherPing -Target "8.8.8.8" -IntervalInSeconds 5
  ```
This command will continuously output statistics

To stop the ping monitoring, press CTRL+C.

The Start-PoshWatcherPing function has the following parameters:

    -Target: Mandatory parameter, the hostname or IP address of the target system you want to monitor.
    -IntervalInSeconds: Optional parameter, the interval between ping requests in seconds. Default is 1 second.

### Start-PoshWatcherRoute

To start monitoring the route to a target host or IP address, use the `Start-PoshWatcherRoute` function. This function runs a traceroute to the specified target and displays the hop count, IP address, and latency for each hop in the route. The `Start-PoshWatcherRoute` function supports continuous traceroute execution and displays the hop with the highest latency after each iteration. By default, the traceroute runs indefinitely, but you can configure the number of iterations and the interval between them.


```powershell
Start-PoshWatcherRoute -Target "8.8.8.8"
  ```
This command will output a table

Output:

The function outputs a table showing the hop number, IP address, and latency for each hop in the traceroute. After each iteration, it also displays the hop number and IP address with the highest latency and lists the latency response time. To change the number of iterations or the interval between runs, you can modify the -IterationCount and -IntervalSeconds parameters:

```powershell
Start-PoshWatcherRoute -Target "8.8.8.8" -IterationCount 10 -IntervalSeconds 5
 ```
This example will run the traceroute 10 times, with a 5-second interval between each run.

### Start-PoshWatcherDiskBench

To start benchmarking a single or multiple drives using friendlynames C:, D: etc type `Start-PoshWatcherDiskBench` function:

```powershell
Start-PoshWatcherDiskBench -FileSize 100MB
Supply values for the following parameters:
Disks[0]: C:
Disks[1]: D:
  ```

You can also customize the number of iterations for the disk benchmark:
```powershell
Start-PoshWatcherDiskBench -FileSize 10MB -Iterations 5
Supply values for the following parameters:
Disks[0]: C:
 ```

### Get-ISP

To get the ISP associated with your public IP `Get-ISP` function:

```powershell
Get-ISP
  ```
### Get-StandardDeviation
```powershell
$numbers = @(5, 10, 15, 20, 25)
Get-StandardDeviation -Numbers $numbers
 ```

## Configurable PoshWatcherConfig.ps1 background job launcher

Running the Configuration Launcher Script

To run the updated configuration launcher script, which starts all functions as background tasks, execute the following command:
```powershell
.\PoshWatcherConfig.ps1
 ```

The script will start all enabled functions as background tasks based on the settings specified in the script. To retrieve the status of these background jobs, 
use Get-Job in powershell to retrieve them. You can also set them certain functions to not run. 
```powershell
Get-Job
 ```

### Running Functions Manually and Interactively

You can run each function manually and interactively by calling the function directly from Powershell. This allows you to monitor the output directly and stop the function when needed by pressing Ctrl+C. Please refer to the individual function sections in this README above for instructions on how to run each function.

### Differences Between Running as Background Tasks and Interactively

Running functions as background tasks allows you to start multiple functions simultaneously and retrieve the output or status of these tasks as needed. This is especially useful for running long-term monitoring tasks without needing to monitor the output continuously.

Running functions interactively allows you to see the output of each function in real-time and provides the flexibility to stop the function by pressing Ctrl+C when needed. This is ideal for short-term monitoring or troubleshooting purposes.

For detailed instructions on how to run each function, please refer to the sections above explaining it.  

### More details on PoshWatcherConfig.ps1
See the comments in the PoshWatcherConfig.ps1 for more details on how to customize and configure it.
