$sourceSiteUrl = ""
$templateFolderPath = ".\PowerAppsTemplates"

Connect-PnPOnline -Url $sourceSiteUrl -Interactive

if (-not (Test-Path -Path $templateFolderPath)) {
    New-Item -Path $templateFolderPath -ItemType Directory
}

$powerApps = Get-PnPPowerApp

foreach ($app in $powerApps) {
    $appId = $app.AppId
    $appTitle = $app.DisplayName -replace ' ', '_'
    $powerAppExportPath = "$templateFolderPath\$appTitle-PowerApp.zip"

    Export-PnPPowerApp -AppId $appId -Path $powerAppExportPath
    Write-Host "PowerApp $appId exportado para $powerAppExportPath"
}

Disconnect-PnPOnline
