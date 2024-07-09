$root = $PSScriptRoot
$startFolder = $root + "\src"
$dateF = Get-Date -Format "dd-MMM-yyyy-HH-mm"
$projectOutput=$root+"\Deploy\Release_"+$dateF
$startFolder = $projectOutput + "\_PublishedWebsites"
#Your Path to MSBild below
$msBuildExe = "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin\MSBuild.exe"

Remove-Item $projectOutput -Recurse

Write-Host "Building started AQR.Helix.sln" -foregroundcolor green
& "$($msBuildExe)" AQR.Helix.sln /t:clean,build /p:OutputPath=$projectOutput /v:m /p:Configuration=Release /p:BuildNumber=1 

Write-Host "Building AQR.Helix.sln - Completed!" -foregroundcolor green

# binary
$binItems = Get-ChildItem $projectOutput -Recurse -Exclude Sitecore*.dll,system*.dll,Glass*.dll,Antlr3.Runtime.dll,Castle.Core.dll,WebGrease.dll,Newtonsoft.Json.dll | Where-Object {$_.Name -like "*.dll" }

$outputFolder = $projectOutput + "\bin"

Write-Host $outputFolder red
New-Item -ItemType Directory -Force -Path $outputFolder | Out-Null # create, if not exist

foreach ($b in $binItems)
{
    $target = Join-Path $outputFolder $b.Name

    $exist = Test-Path $target

    if ($exist -eq $false)
    {
        Write-Host $b.Name
        Copy-Item  $b.FullName -Destination $target
    }
}
Write-Host "Copied DLLs" -foregroundcolor green

# views
$viewsItems = Get-ChildItem $startFolder -Recurse | Where-Object { $_.PSIsContainer -eq $True } | Where-Object { $_.Name -like "Views" }

$outputFolder = $projectOutput + "\Views"
New-Item -ItemType Directory -Force -Path $outputFolder | Out-Null # create, if not exist

foreach ($i in $viewsItems)
{
    $childFolders = (Get-ChildItem $i.FullName | Where-Object { $_.PSIsContainer -eq $true } ) 
    foreach ($c in $childFolders)
    {
        Write-Host $c.FullName
        Copy-Item $c.FullName -Destination $outputFolder -Recurse -Force
    }
}
Write-Host "Copied views" -foregroundcolor green

# App_config
$configItems = Get-ChildItem $startFolder -Recurse | Where-Object { $_.PSIsContainer -eq $True } | Where-Object { $_.Name -like "App_Config" }

$outputFolder = $projectOutput + "\App_Config"
New-Item -ItemType Directory -Force -Path $outputFolder | Out-Null # create, if not exist

foreach ($configItem in $configItems)
{
    $childFolders = (Get-ChildItem $configItem.FullName | Where-Object { $_.PSIsContainer -eq $true } ) 
    foreach ($childFolder in $childFolders)
    {
        Write-Host $childFolder.FullName
        Copy-Item $childFolder.FullName -Destination $outputFolder -Recurse -Force
    }
}
Write-Host "Copied App_config" -foregroundcolor green

Remove-Item $startFolder -Recurse
Remove-Item –path "$projectOutput\*" -include *.*
Write-Host "Cleaned up release folder" -foregroundcolor green

$outputFolder = $projectOutput + "\SitecorePackage"
New-Item -ItemType Directory -Force -Path $outputFolder | Out-Null # create, if not exist

Write-Host "Copying assets..." -foregroundcolor green
Copy-Item "$root\static\assets" -Destination $projectOutput -Recurse -Force

Write-Host "Release Created - $projectOutput" -foregroundcolor green