Add-Type -Path "C:\PS\itextsharp.dll"
$path = "C:\PDF\
$pdfs = Get-ChildItem $path *.pdf -Recurse
$export = "C:\PS\export.csv"
$results = @()
$keywords = @('word1','word2')
foreach($pdf in $pdfs) {

    Write-Host "processing -" $pdf.FullName

    # prepare the pdf
    $reader = New-Object iTextSharp.text.pdf.pdfreader -ArgumentList $pdf.FullName

    # for each page
    for($page = 1; $page -le $reader.NumberOfPages; $page++) {
    
        # set the page text
        $pageText = [iTextSharp.text.pdf.parser.PdfTextExtractor]::GetTextFromPage($reader,$page).Split([char]0x000A)

        # if the page text contains any of the keywords we're evaluating
        foreach($keyword in $keywords) {
            if($pageText -match $keyword) {
                $response = @{
                    keyword = $keyword
                    file = $pdf.FullName
                    page = $page
                }
                $results += New-Object PSObject -Property $response
            }
        }
    }
    $reader.Close()
}

Write-Host ""
Write-Host "done"

$results | epcsv $export -NoTypeInformation
