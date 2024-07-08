function HasReference {
    param(
        $Item
    )
    
    $linkDb = [Sitecore.Globals]::LinkDatabase
    $linkDb.GetReferrerCount($Item) -gt 0
}

function Get-MediaItemWithReference {
    $items = Get-ChildItem -Path "master:\sitecore\media library" -Recurse | 
        Where-Object { $_.TemplateID -eq "{0603F166-35B8-469F-8123-E8D87BEDC171}" }
    
    foreach($item in $items) {
        if((HasReference($item))) {
            $item
        }
    }
}

$props = @{
    InfoTitle = "Used PDF items"
    InfoDescription = "Lists all PDF items linked to other items."
    PageSize = 25
}

Get-MediaItemWithReference |
    Show-ListView @props -Property @{Label="Name"; Expression={$_.DisplayName} },
        @{Label="Updated"; Expression={$_.__Updated} },
        @{Label="Updated by"; Expression={$_."__Updated by"} },
        @{Label="Created"; Expression={$_.__Created} },
        @{Label="Created by"; Expression={$_."__Created by"} },
        @{Label="Path"; Expression={$_.ItemPath} }