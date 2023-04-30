function Start-PoshWatcherRoute {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Target,
        [Parameter(Mandatory = $false)]
        [int]$Count = -1
    )

    $iteration = 0

    while ($iteration -ne $Count) {
        $tracerouteResult = (Test-NetConnection -ComputerName $Target -TraceRoute).TraceRoute

        $hopCount = 1
        $results = @()
        foreach ($hop in $tracerouteResult) {
            $hopIP = $hop

            try {
                $pingResult = Test-NetConnection -ComputerName $hopIP -ErrorAction Stop
                $hopLatency = if ($pingResult.PingSucceeded) { $pingResult.PingReplyDetails.RoundtripTime } else { 0 }
            }
            catch {
                $hopLatency = "TimedOut"
            }

            $results += [PSCustomObject]@{
                'Hop'      = $hopCount
                'HopIP'    = $hopIP
                'Latency'  = $hopLatency
            }

            $hopCount++
        }

        $results | Format-Table -AutoSize

        $highestLatency = $results | Sort-Object -Descending -Property Latency | Select-Object -First 1

        Write-Host "Hop with highest latency: $($highestLatency.Hop) - $($highestLatency.HopIP) - $($highestLatency.Latency) ms" -ForegroundColor Green

        if ($iteration -eq $Count - 1) {
            break
        }

        $iteration++
    }
}

Export-ModuleMember -Function Start-PoshWatcherRoute
