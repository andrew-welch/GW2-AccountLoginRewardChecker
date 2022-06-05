. .\login-reward-offset.ps1


#$AccountList = Import-Csv .\api-keys.csv
$AccountListz = Import-Csv .\api-keys-saved.csv

$AccountList_Length = [INT] $AccountList.length

# $return = Get-LoginOffset -APIKey $input.KEY -Offset $input.offset

for ($i=0; $i -lt $AccountList_Length; $i++) {

    $APIKey = $AccountList[$i].KEY

    $Params_Age = @{
        Method = "Get"
        Uri = "https://api.guildwars2.com/v2/account?access_token=" + $APIKey
        Body = $Body
        Headers = @{ "Cache-Control" ="no-cache" }
    }

    $Result_Age = Invoke-RestMethod @Params_Age

    $Create_Date = [Datetime]$Result_Age.created.substring(0,10)

    $accountList[$i].CreateDate = $Create_Date

}



$accountList | Export-Csv -path api-keys-saved.csv -NoTypeInformation
