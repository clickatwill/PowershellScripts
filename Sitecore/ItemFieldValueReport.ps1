#Report on specific field values

function Get-ItemUrl {
    param(
        [item]$Item,
        [Sitecore.Sites.SiteContext]$SiteContext
    )
    
    $result = New-UsingBlock(New-Object Sitecore.Sites.SiteContextSwitcher $siteContext) {
        New-UsingBlock(New-Object Sitecore.Data.DatabaseSwitcher $item.Database) {
            [Sitecore.Links.LinkManager]::GetItemUrl($item)
        }
    }
    
    $result[0][0]
}

$siteContext = [Sitecore.Sites.SiteContext]::GetSite("[DESIRED TARGET SITE NAME]")
$reportItems = @()

$TemplateId = [Sitecore.Data.ID]::Parse("DESIRED TEMPLATE ID");
$database = "master"
$contentRoot =  Get-Item -Path "master:\sitecore\content\[PATH TO DESIRED ROOT]"
filter Where-InheritsTemplate {
    param(
        [Parameter(Mandatory = $true,ValueFromPipeline = $true)]
        [Sitecore.Data.Items.Item]$item
    )
    if ($item) {
        $itemTemplate = [Sitecore.Data.Managers.TemplateManager]::GetTemplate($item)
        if ($itemTemplate -ne $null -and $itemTemplate.DescendsFromOrEquals($TemplateId)) {
            $Item
        }
    }
}
$allItems = Get-ChildItem -Path $contentRoot.FullPath | Where-InheritsTemplate


$allItems | ForEach-Object {
    [Sitecore.Xml.Xsl.LinkUrl]$fieldLink = New-Object -TypeName 'Sitecore.Xml.Xsl.LinkUrl'
    $Url = $fieldLink.GetUrl($_, "[FIELD NAME OF URL FIELD]")    
    
    $reportItem = [PSCustomObject]@{
                "H1"=$_["Hero Title"]
                "Breadcrumb"=$_["NavigationTitle"]              
                "URL"= Get-ItemUrl -SiteContext $siteContext -Item $_               
                }
                 $reportItems += $reportItem
}

$reportItems | Show-ListView