$mainPath = "/sitecore/[PATH TO DESIRED ROOT]"
 
function UnlockSiteCoreItems
{
    $mainChildren = Get-ChildItem -Path $mainPath
    
    foreach($mainItem in $mainChildren)
    {
        $sourcePath = $mainItem.Paths.FullPath
       $rootItem = Get-Item -Path $sourcePath
        $ChildItemsToUnlock = Get-ChildItem -Path $sourcePath -Recurse
        $items = $ChildItemsToUnlock + $rootItem
        Write-Host "Unlocking $($rootItem.Paths.FullPath)"
        foreach ($item in $items)
        {
            foreach ($version in $item.Versions.GetVersions($true))
            {
                if($version.Locking.IsLocked())
                {
                    $version.Editing.BeginEdit();
                    $version.Locking.Unlock();
                    $version.Editing.EndEdit();
                    Write-Host "Item Un-locked" $item.Name "for Language" $version.Language;
                }
            }
        }     
    }
    

}
$unlockedItemsDetails = UnlockSiteCoreItems