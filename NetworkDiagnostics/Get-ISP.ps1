# The Get-ISP function retrieves the Internet Service Provider (ISP) information
# for the system running the script. It does this by first obtaining the public IP
# address of the system and then using the ip-api.com API to fetch the ISP information.
function Get-ISP {
    [CmdletBinding()]
    param ()

    begin {}

    process {
        # Obtain the public IP address by sending a request to ipinfo.io
        $publicIP = (Invoke-WebRequest -Uri "http://ipinfo.io/ip" -UseBasicParsing).Content.Trim()
        
        # Query ip-api.com with the public IP address to get ISP information
        # Invoke-RestMethod sends an HTTP request to the specified URI and parses
        # the response as a JSON object, which can be easily accessed in PowerShell.
        $ispInfo = Invoke-RestMethod -Uri "http://ip-api.com/json/$publicIP"

        # Return the ISP name from the JSON object (property: 'isp')
        # This will be the output of the Get-ISP function.
        return $ispInfo.isp
    }

    end {}
}

# Export-ModuleMember makes the Get-ISP function available to other scripts when
# they import the PoshMon module. It essentially "exports" the function, making
# it accessible as part of the module's public API.
Export-ModuleMember -Function Get-ISP
