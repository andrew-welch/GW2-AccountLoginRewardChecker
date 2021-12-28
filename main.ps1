. .\get-accountLaurels.ps1
. .\Invoke-Parallel.ps1

$AccountList = Import-Csv .\api-keys.csv

$funcdef = ${Function:Get-AccountLaurels}.ToString()


$accountlist | Invoke-Parallel -ImportModules -ImportVariables -ScriptBlock {  
    ${Function:Get-AccountLaurels} = $using:funcdef
    $return = Get-AccountLaurels($_.KEY)
    if ($return -ge 36) {
        Write-Host ($_.ID,": ",$return) -ForegroundColor Green
    }
    else {
        Write-Host ($_.ID,": ",$return)
    }
}
