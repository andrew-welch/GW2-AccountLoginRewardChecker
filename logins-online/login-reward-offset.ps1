

# For an account add up the following:
# 1. Account Age (days)
# 2. offset


Function Get-LoginOffset {
    [CmdletBinding()]
	param(
        [Parameter(Mandatory)]
        [string]$APIKey,
        [int]$Offset = 0
    )

    $Params_Age = @{
        Method = "Get"
        Uri = "https://api.guildwars2.com/v2/account?access_token=" + $APIKey
        Body = $Body
        Headers = @{ "Cache-Control" ="no-cache" }
    }

    $Result_Age = Invoke-RestMethod @Params_Age

    $Create_Date = [Datetime]$Result_Age.created.substring(0,10)

    $Time_now_local = Get-Date

    $Compare = $time_now_local.ToUniversalTime() - $Create_Date

    Return ( $Compare.days + $offset ) % 28

}





