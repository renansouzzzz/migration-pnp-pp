## EXPORTAÇÃO
 
$sourceSiteUrl = ""
$templateFolderPath = ".\Templates"

Connect-PnPOnline -Url $sourceSiteUrl -Interactive

$sourceLists = Get-PnPList

if (-not (Test-Path -Path $templateFolderPath)) {
    New-Item -Path $templateFolderPath -ItemType Directory
}

foreach ($list in $sourceLists) {
    $listTitle = $list.Title
    $listTemplatePath = "$templateFolderPath\$($listTitle)_template.xml"
    
    Export-PnPListToSiteTemplate -List $listTitle -Out $listTemplatePath -Force
}

Disconnect-PnPOnline
