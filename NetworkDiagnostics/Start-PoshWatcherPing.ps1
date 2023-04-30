# The Start-PingMonitor function performs continuous ping monitoring of a target
# specified by IP address or hostname. It calculates various statistics, such as
# lowest, highest, and average ping time, packet loss, jitter, and standard deviation.
function Start-PoshWatcherPing {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias("IP", "HostName")]
        [string]$Target,

        [int]$IntervalInSeconds = 1
    )

    begin {
        $LowestJitter = [double]::MaxValue
        $HighestJitter = 0
        $TotalJitter = 0
        $LowestPing = [int]::MaxValue
        $HighestPing = 0
        $TotalPing = 0
        $PingCount = 0
        $PingAttempts = 0
        $RequestTimeouts = 0
        $PingTimes = @()
        $PreviousPing = $null

        $ISP = Get-ISP
        Write-Host "Your ISP: $ISP"
    }

    process {
        Write-Host "Monitoring ping to $Target. Press CTRL+C to stop."

        try {
            while ($true) {
                $PingAttempts++

                try {
                    $PingResult = Test-Connection -ComputerName $Target -Count 1 -ErrorAction Stop
                    $RoundTripTime = $PingResult.ResponseTime

                    if ($RoundTripTime -lt $LowestPing) {
                        $LowestPing = $RoundTripTime
                    }

                    if ($RoundTripTime -gt $HighestPing) {
                        $HighestPing = $RoundTripTime
                    }

                    if ($null -ne $PreviousPing) {
                        $Jitter = [math]::Abs($RoundTripTime - $PreviousPing)
                        $TotalJitter += $Jitter
                        
                        if ($Jitter -lt $LowestJitter) {
                            $LowestJitter = $Jitter
                        }

                        if ($Jitter -gt $HighestJitter) {
                            $HighestJitter = $Jitter
                        }
                    }
                    $PreviousPing = $RoundTripTime

                    $TotalPing += $RoundTripTime
                    $PingCount++
                    $PingTimes += $RoundTripTime
                    $AveragePing = $TotalPing / $PingCount
                    $PacketLoss = (($PingAttempts - $PingCount) / $PingAttempts) * 100
                    $StandardDeviation = Get-StandardDeviation $PingTimes
                    $AverageJitter = $TotalJitter / ($PingCount - 1)

                    Write-Host "Target: $Target | Current Ping: $($RoundTripTime)ms | Lowest Ping: $($LowestPing)ms | Highest Ping: $($HighestPing)ms | Average Ping: $($AveragePing)ms | Standard Deviation: $($StandardDeviation)ms | Packet Loss: $($PacketLoss)% | Jitter: $($Jitter)ms | Avg Jitter: $($AverageJitter)ms | Lowest Jitter: $($LowestJitter)ms | Highest Jitter: $($HighestJitter)ms | ISP: $ISP | Ping Attempt: $($PingAttempts) | Request Timeouts: $($RequestTimeouts)"
                }
                
                catch {
                    $RequestTimeouts++
                    Write-Host "Request timed out."
                }

                Start-Sleep -Seconds $IntervalInSeconds
            }
        }
        catch {
            if ($_.Exception -is [System.Management.Automation.PipelineStoppedException]) {
                Write-Host "Ping monitoring stopped."
            } else {
                Write-Error $_.Exception.Message
            }
        }
    }
}

# Export the Start-PingMonitor function to be accessible when the module is imported
Export-ModuleMember -Function Start-PoshWatcherPing
