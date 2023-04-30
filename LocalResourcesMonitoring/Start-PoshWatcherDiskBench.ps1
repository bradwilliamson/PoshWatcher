function Start-PoshWatcherDiskBench {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidatePattern("^[A-Za-z]:$")]
        [string[]]$Disks,

        [Parameter(Mandatory=$false)]
        [int]$Iterations = 5,

        [Parameter(Mandatory=$false)]
        [ValidateSet("1MB", "10MB", "100MB")]
        [string]$FileSize = "10MB"
    )

    try {
        $results = foreach ($disk in $Disks) {
            for ($i = 1; $i -le $Iterations; $i++) {
                $tempFile = [System.IO.Path]::GetTempFileName()
                $sw = [Diagnostics.Stopwatch]::StartNew()
                $fileSizeInBytes = [int]($fileSize -replace 'MB','') * 1024 * 1024
                $null = New-Object -TypeName Byte[] -ArgumentList $fileSizeInBytes
                $sw.Stop()
                $diskUsage = Get-PhysicalDisk -FriendlyName $disk | Select-Object Size, MediaType, OperationalStatus
                $diskThroughput = [math]::Round(($FileSize / $sw.Elapsed.TotalSeconds) / 1MB, 2)
                $diskIO = Get-PhysicalDisk -FriendlyName $disk | Select-Object AvgDiskReadQueueLength, AvgDiskWriteQueueLength
                $diskLatency = Get-PhysicalDisk -FriendlyName $disk | Select-Object AvgDiskSecPerRead, AvgDiskSecPerWrite
                $diskErrors = Get-PhysicalDisk -FriendlyName $disk | Select-Object ReadErrorsTotal, WriteErrorsTotal
                [PSCustomObject]@{
                    Disk = $disk
                    FileSize = $fileSize
                    ElapsedTime = $sw.Elapsed.TotalSeconds
                    DiskUsage = $diskUsage
                    DiskThroughput = $diskThroughput
                    DiskIO = $diskIO
                    DiskLatency = $diskLatency
                    DiskErrors = $diskErrors
                }
                Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
            }
        }
        return $results
    }
    catch {
        Write-Error "An error occurred while benchmarking disks: $($_.Exception.Message)"
    }

}

Export-ModuleMember -Function Start-PoshWatcherDiskBench
