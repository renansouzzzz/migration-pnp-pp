$rootFolderPath = "C:\Users\Tnend\Downloads\Confluence-space-export-121121-184.html\sciencedmz"

$attachmentsFolder = Join-Path -Path $rootFolderPath -ChildPath "attachments"
$imagesFolder = Join-Path -Path $rootFolderPath -ChildPath "images"
$stylesFolder = Join-Path -Path $rootFolderPath -ChildPath "styles"

$outputFolder = Join-Path -Path $rootFolderPath -ChildPath "ASPX_Export"
if (-not (Test-Path -Path $outputFolder)) {
    New-Item -Path $outputFolder -ItemType Directory
}

$cssFilePath = Join-Path -Path $stylesFolder -ChildPath "site.css"

$htmlFiles = Get-ChildItem -Path $rootFolderPath -Filter *.html

foreach ($htmlFile in $htmlFiles) {
    $htmlContent = Get-Content -Path $htmlFile.FullName -Raw

    $htmlContent = $htmlContent -replace 'src="attachments/', 'src="/attachments/'
    $htmlContent = $htmlContent -replace 'src="images/', 'src="/images/'

    $htmlContent = "<link rel='stylesheet' type='text/css' href='/styles/site.css' />`n" + $htmlContent

    # Criar o conteúdo básico ASPX
    $aspxContent = @"
<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Register TagPrefix="SharePoint" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<asp:Content ContentPlaceHolderId="PlaceHolderMain" runat="server">
    $htmlContent
</asp:Content>
"@

    # Definir o nome do arquivo de saída .aspx
    $aspxFileName = [System.IO.Path]::ChangeExtension($htmlFile.Name, ".aspx")
    $aspxFilePath = Join-Path -Path $outputFolder -ChildPath $aspxFileName

    # Salvar o conteúdo ASPX no arquivo de saída
    Set-Content -Path $aspxFilePath -Value $aspxContent -Force

    Write-Output "Página convertida: $aspxFilePath"
}

Write-Output "Conversão de páginas HTML para ASPX concluída."
