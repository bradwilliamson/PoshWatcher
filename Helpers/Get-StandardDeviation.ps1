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

Export-ModuleMember -Function Get-StandardDeviation
