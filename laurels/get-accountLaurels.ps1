
Function Get-AccountLaurels {

    [CmdletBinding()]
	param(
        [Parameter(Mandatory)]
        [string]$APIKey 
    )

    # Initialise
    $SearchResults = @()
    $totalLaurels = [Int] 0
    $ItemArray = Import-Csv .\laurels\item-data.csv

    #Validate API String
    if ($apikey -notmatch "([0-z]){8}-(([0-z]){4}-){3}([0-z]){20}-(([0-z]){4}-){3}([0-z]){12}") {
        Return "Invalid API Key."
    }

    # Check Permissions, Requires Account Characters, Wallet, Inventories
    $Params_Perms = @{
        Method = "Get"
        Uri = "https://api.guildwars2.com/v2/tokeninfo?access_token=" + $apikey
        Body = $Body
    }

    $Result_Perms = Invoke-RestMethod @Params_Perms
    $Requiredperms = @("Account", "Characters", "Wallet", "Inventories")
    $Requiredperms | ForEach-Object {
        if ($Result_perms.Permissions -inotcontains $_) {
            Return "API Key Permission missing. Requires: Characters, Wallet, Inventories"
            }
    }

    # Get the Laurels from the account wallet
    $Params_Wallet = @{
        Method = "Get"
        Uri = "https://api.guildwars2.com/v2/account/wallet?access_token=" + $apikey
        Body = $Body
        Headers = @{ "Cache-Control" ="no-cache" }
    }

    $Result_Wallet = Invoke-RestMethod @Params_Wallet
    $totalLaurels += $Result_Wallet | Where-Object { $_.id -eq 3 } | ForEach-Object {$_.value}


    # Get Character Names
    $Params_CharNames = @{
        Method = "Get"
        Uri = "https://api.guildwars2.com/v2/characters?access_token=" + $apikey
        Body = $Body
    }

    $Result_CharNames = Invoke-RestMethod @Params_CharNames

    # For Each Character
    foreach ($char in $Result_CharNames) {

        # Get Bag contents
        $Params_Inventory = @{
            Method = "Get"
            Uri = "https://api.guildwars2.com/v2/characters/" + $char + "/inventory?access_token=" + $apikey
            Body = $Body
            Headers = @{ "Cache-Control" ="no-cache" }
        }
        $Result_Inventory = Invoke-RestMethod @Params_Inventory

        # Search each bag and add to results list
        foreach ($searchbag in $Result_Inventory.bags) {

            $Itemfind = $searchbag.inventory | Where-Object {$_.id -in $ItemArray.ID}
            $SearchResults += $itemfind
        }

        # Is this character or account? Subtract toal bag space from total items in the bags.

        #total bag space 
        # ($Result_Inventory.bags.size | measure-object -sum).sum

        # Bags filled slots 
        # ($Result_Inventory.Bags[0].inventory | Where-Object {$_ -ne $null}).count



    }




    #Add unclaimed Laurels from items to total
    Foreach ($item in $Searchresults) {
        $totalLaurels += ($item.count)*([int]($ItemArray | Where-Object {$_.ID -eq $item.ID} | ForEach-Object {$_.value}))

    }

    Return $totalLaurels
}
