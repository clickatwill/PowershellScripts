cls

$allItems = Get-ChildItem -Path 'master://sitecore/media library/[YOUR DESIRED ROOT]' -Recurse

$goodCount = 0
$badCount = 0
$badItems = ""
$allItems | ForEach-Object {

    if($_.TemplateName -ne "Media folder" -and $_.TemplateName -ne "Node" -and $_.TemplateName -ne "Theme" -and $_.TemplateName -ne "Scripts")
    {
        $item = $_
        try
        {
	 
            $mediaItem = [Sitecore.Data.Items.MediaItem]$item
            $blobField = $mediaItem.InnerItem.Fields["blob"]
            $blobStream = $blobField.GetBlobStream()
            if($blobStream -eq $null)
            {
                Write-Host $item.Paths.FullPath
                $badItems = $badItems + $item.Paths.FullPath + [Environment]::NewLine
                $badCount = $badCount + 1
                #$item | Remove-Item

            }
            else
            {   
                $blobStream.close()
                $goodCount = $goodCount + 1
                Write-Host $goodCount 
            }
            #$image = [System.Drawing.Image]::FromStream($blobStream)
 
        }
        catch
        {
            Write-Host $item.Paths.FullPath
            $badItems = $badItems + $item.Paths.FullPath + [Environment]::NewLine
            $badCount = $badCount + 1
       }

    }

}
"Done"
$goodCount
$badCount
$badItems | Out-Download