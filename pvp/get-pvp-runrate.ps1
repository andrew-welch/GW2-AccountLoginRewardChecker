Function Get-PVPRate {
    [CmdletBinding()]
	param(
        [Parameter(Mandatory)]
        [string]$APIKey
    )

    # Get the current PVP season

    $iterate = 0
    do {
        
        $Params_Season = @{
            Method = "Get"
            Uri = "https://api.guildwars2.com/v2/pvp/seasons"
            Body = $Body
            Headers = @{ "Cache-Control" ="no-cache" }
        }

        $Result_Season = Invoke-RestMethod @Params_Season

        $Season_UID = $Result_season | Select-object -Last 1 -Skip $iterate

        # Get the current season details
        # TODO: Should really check all seasons for active from the bottom.

        $Params_SeasonDetails = @{
            Method = "Get"
            Uri = "https://api.guildwars2.com/v2/pvp/seasons/" + $Season_UID
            Body = $Body
            Headers = @{ "Cache-Control" ="no-cache" }
        }

        $Result_SeasonDetails = Invoke-RestMethod @Params_SeasonDetails
        $iterate ++

        if ($iterate -ge 6) {
            Write-Host("No active season")
            break
        }

    } while (!$Result_SeasonDetails.active)
    #  check if $Result_seasondetails.active is true

    $Season_Endtime = [DateTime] $Result_SeasonDetails.end

    $Season_Maxpoints = $Result_SeasonDetails.divisions.tiers.points | Measure-Object -sum

    # For the correct season id, return the current.total_points value

    

    $Params_Standings = @{
        Method = "Get"
        Uri = "https://api.guildwars2.com/v2/pvp/standings?access_token=" + $APIKey
        Body = $Body
        Headers = @{ "Cache-Control" ="no-cache" }
    }

    $Result_Standings = Invoke-RestMethod @Params_Standings

    $current_points = $Result_Standings | Where-Object { $_.season_id -eq $Season_UID} | ForEach-Object {$_.current.total_points}

    # Time left in season
    $Time_now_local = Get-Date
    $Compare = $season_endtime - $time_now_local.ToUniversalTime()

    # Calculation arguments
    $calc_Rank = 0 # 4 if you are in Legendary rank, 2 if you are in Platinum rank, or 0 if you are in any other rank.
    $calc_Winrate = 0.49 # Your win rate. A 60% win rate is 0.60 in this formula.
    $calc_topstats = 0.65 # Your top stats rate. If you get a top stats reward in 75% of games, this number is 0.75.
    $calc_nearvictory = 0.03 # Your near victory rate. If 3% of your games are a near victory that awards bonus pips, then this number is 0.03.

    $season_maxpips = $season_maxpoints.Sum
    $Pips_Remaining = ($season_maxpips-$current_points)
    $Pips_Perc = 1- ($Pips_Remaining/$season_maxpips)
    $Matches_remaining = $Pips_Remaining/($calc_Rank+(7*$calc_Winrate)+$calc_topstats+(2*$calc_nearvictory)+3)
    $Matches_perday = $Matches_remaining/$Compare.TotalDays
    
    Write-Host ("`n")
    Write-Host ("Normal Track") -ForegroundColor Yellow
    Write-Host ("Pips completed:    ",$current_points,"/",$season_maxpips," (",$Pips_Perc.ToString("0.###"),"% )")
    Write-Host ("Matches remaining: ",$Matches_remaining.ToString("0.###"))
    Write-Host ("Days remaining:    ",$Compare.TotalDays.ToString("0.###"))
    Write-Host ("Matches per day:   ",$Matches_perday.ToString("0.###"))
    Write-Host ("`n")

    $season_maxpips = $season_maxpoints.Sum + 180
    $Pips_Remaining = ($season_maxpips-$current_points)
    $Pips_Perc = 1- ($Pips_Remaining/$season_maxpips)
    $Matches_remaining = $Pips_Remaining/($calc_Rank+(7*$calc_Winrate)+$calc_topstats+(2*$calc_nearvictory)+3)
    $Matches_perday = $Matches_remaining/$Compare.TotalDays

    Write-Host ("1x Extra Track")
    Write-Host ("Pips completed:    ",$current_points,"/",$season_maxpips," (",$Pips_Perc.ToString("0.###"),"% )")
    Write-Host ("Matches remaining: ",$Matches_remaining.ToString("0.###"))
    Write-Host ("Days remaining:    ",$Compare.TotalDays.ToString("0.###"))
    Write-Host ("Matches per day:   ",$Matches_perday.ToString("0.###"))
    Write-Host ("`n`n")
}

