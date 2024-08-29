$targetSiteUrl = ""
$templateFolderPath = ".\Templates"

Connect-PnPOnline -Url $targetSiteUrl -Interactive

$xmlFiles = Get-ChildItem -Path $templateFolderPath -Filter *.xml | Where-Object { $_.Name -ne "*_items.json" }

$dependencies = @{}
$importedLists = @()

function Get-LookupDependencies {
    param($xmlContent)
    $lookupFields = Select-String -InputObject $xmlContent -Pattern '<Field Type="Lookup" List="{listid:([^}]*)}"' -AllMatches
    return $lookupFields.Matches | ForEach-Object { $_.Groups[1].Value }
}

foreach ($file in $xmlFiles) {
    $xmlContent = Get-Content -Path $file.FullName -Raw
    $dependentLists = Get-LookupDependencies -xmlContent $xmlContent

    if ($dependentLists.Count -eq 0) {
        $dependencies[$file.Name] = @()
    } else {
        $dependencies[$file.Name] = $dependentLists
    }
}

function Import-List {
    param($listFile)
    try {
        Invoke-PnPSiteTemplate -Path $listFile.FullName -Handlers All
        Write-Host "Importação bem-sucedida: $listFile"
        $importedLists += $listFile.Name
        return $true
    } catch {
        Write-Host "Erro ao importar $list.File: $_"
        return $false
    }
}

function Resolve-Dependencies {
    param($dependencies)
    $pendingImports = $dependencies.Keys

    while ($pendingImports.Count -gt 0) {

        foreach ($listName in @($pendingImports)) {
            $dependentLists = $dependencies[$listName]
            $allDependenciesImported = $true
            
            foreach ($dependency in $dependentLists) {
                if (-not ($importedLists -contains "$dependency.xml")) {
                    $allDependenciesImported = $false
                    break
                }
            }

            if ($allDependenciesImported) {
                $file = $xmlFiles | Where-Object { $_.Name -eq $listName }
                if (Import-List -listFile $file) {
                    $pendingImports = $pendingImports | Where-Object { $_ -ne $listName }
                }
            }
        }
    }
}

Resolve-Dependencies -dependencies $dependencies

#$jsonFiles = Get-ChildItem -Path $templateFolderPath -Filter *_items.json
#foreach ($file in $jsonFiles) {
#    $listTitle = ($file.Name -replace "_items.json", "")
#    $items = Get-Content -Path $file.FullName | ConvertFrom-Json

#    foreach ($item in $items) {
#        try {
#            Add-PnPListItem -List $listTitle -Values $item
#            Write-Host "Item adicionado com sucesso na lista $listTitle"
#        } catch {
#            Write-Host "Erro ao adicionar item na lista $list.Title: $_"
#        }
#    }
#}

Disconnect-PnPOnline
