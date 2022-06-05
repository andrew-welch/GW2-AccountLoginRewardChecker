. .\logins-online\login-reward-offset.ps1
. .\Invoke-Parallel.ps1

$AccountList = Import-Csv .\api-keys.csv

$funcdef = ${Function:Get-LoginOffset}.ToString()

$out = $accountlist | Invoke-Parallel -Throttle 10 -LogFile 'c:\temp\gw2parallel.log' -ScriptBlock {  
    ${Function:Get-LoginOffset} = $using:funcdef
    $return = Get-LoginOffset -APIKey $_.KEY -Offset $_.Offset

    switch ($return) 
    {
        {$PSItem -eq 0} # Ready
        {
            $colour = "Green"            
        }
        {$PSItem -eq 26} # Almost ready
        {
            $colour = "DarkYellow"
        }
        {$PSItem -eq 27} # Almost ready!!
        {
            $colour = "Yellow"
        }
        {($PSItem -lt 5) -and ($PSItem -gt 0)} # Recently completed
        {
            $colour = "Cyan"
        }
        default 
        {
            $colour = "White"
        }

    }

    Write-Host ($_.ID,": ",$return) -ForegroundColor $colour
    @{$_.ID = [int]$return}
    
}
