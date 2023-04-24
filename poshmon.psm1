function Get-ISP {
    [CmdletBinding()]
    param ()

    begin {}

    process {
        $publicIP = (Invoke-WebRequest -Uri "http://ipinfo.io/ip" -UseBasicParsing).Content.Trim()
        $ispInfo = Invoke-RestMethod -Uri "http://ip-api.com/json/$publicIP"

        return $ispInfo.isp
    }

    end {}
}

function Get-StandardDeviation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [double[]]$Numbers
    )

    begin {}

    process {
        $mean = $Numbers | Measure-Object -Average | Select-Object -ExpandProperty Average
        $squareDifferences = $Numbers | ForEach-Object { [math]::Pow(($_ - $mean), 2) }
        $variance = ($squareDifferences | Measure-Object -Sum | Select-Object -ExpandProperty Sum) / $Numbers.Count

        return [math]::Sqrt($variance)
    }

    end {}
}

function Start-PingMonitor {
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

                $PacketLoss = (($PingAttempts - $PingCount) / $PingAttempts) * 100
                $StandardDeviation = Get-StandardDeviation $PingTimes
                $AverageJitter = $TotalJitter / ($PingCount - 1)

                Write-Host "Final Statistics:"
                Write-Host "Target: $Target"
                Write-Host "Lowest Ping: $($LowestPing)ms"
                Write-Host "Highest Ping: $($HighestPing)ms"
                Write-Host "Average Ping: $($AveragePing)ms"
                Write-Host "Standard Deviation: $($StandardDeviation)ms"
                Write-Host "Packet Loss: $($PacketLoss)%"
                Write-Host "Average Jitter: $($AverageJitter)ms"
                Write-Host "Lowest Jitter: $($LowestJitter)ms"
                Write-Host "Highest Jitter: $($HighestJitter)ms"
            }
            else {
                throw $_
            }
        }
    }
}
