# Suppress verbose output
$VerbosePreference = 'SilentlyContinue'

function Write-Log {
    param (
        [string]$Message
    )
    Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message"
}

function Get-LatestSpotifyVersion {
    Write-Log "Getting data from rg-adguard..."
    
    # Setting up a session
    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36"

    # Request parameters
    $url = "https://store.rg-adguard.net/api/GetFiles"
    $body = "type=url&url=https://apps.microsoft.com/detail/9ncbcszsjrsb&gl=US&ring=RP&lang=en"
    $headers = @{
        "authority"          = "store.rg-adguard.net"
        "method"             = "POST"
        "path"               = "/api/GetFiles"
        "scheme"             = "https"
        "accept"             = "*/*"
        "accept-language"    = "ru,ru-RU;q=0.9,en;q=0.8"
        "dnt"                = "1"
        "origin"             = "https://store.rg-adguard.net"
        "priority"           = "u=1, i"
        "referer"            = "https://store.rg-adguard.net/"
        "sec-ch-ua"          = '"Google Chrome";v="129", "Not=A?Brand";v="8", "Chromium";v="129"'
        "sec-ch-ua-mobile"   = "?0"
        "sec-ch-ua-platform" = '"Windows"'
        "sec-fetch-dest"     = "empty"
        "sec-fetch-mode"     = "cors"
        "sec-fetch-site"     = "same-origin"
    }

    $ProgressPreference = 'SilentlyContinue'

    try {
        $response = Invoke-WebRequest -Uri $url -Method "POST" -Body $body -WebSession $session -Headers $headers -UseBasicParsing
        $html = $response.Content
    }
    catch {
        Write-Log "Error executing request: $_"
        if ($_.Exception.Response) {
            Write-Log "Error code: $($_.Exception.Response.StatusCode.value__)"
        }
        Write-Log "Error message: $($_.Exception.Message)"
        return $null
    }

    $trContents = [regex]::Matches($html, '(?s)<tr.*?>(.*?)</tr>') | ForEach-Object { $_.Groups[1].Value }
    $results = @()
    foreach ($trContent in $trContents) {
        if ($trContent -match '<a href="(http://tlu\.dl\.delivery\.mp\.microsoft\.com[^"]+)"[^>]*>([^<]+)</a>') {
            $url = $matches[1]
            $fileName = $matches[2]
        }
        if ($trContent -match '>(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} GMT)<') {
            $dateTime = [DateTime]::ParseExact($matches[1], "yyyy-MM-dd HH:mm:ss 'GMT'", $null)
        }
        if ($trContent -match '>(\d+(?:\.\d+)?)\s*MB<') {
            $size = $matches[1] + " MB"
        }
        $results += [PSCustomObject]@{
            FileName = $fileName
            DateTime = $dateTime
            Size     = $size
            Url      = $url
        }
    }

    $filteredResults = $results | Where-Object { $_.FileName -match 'SpotifyAB\.SpotifyMusic_.+x86.+\.appx' }
    $latestFile = $filteredResults | Sort-Object -Property DateTime -Descending | Select-Object -First 1
    Write-Log "Found: $($latestFile.FileName)"
    return $latestFile
}

function Download-SpotifyAppx {
    param ($downloadUrl, $filePath)
    Write-Log "Downloading appx file..."
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $downloadUrl -OutFile $filePath
}

function Extract-SpotifyAppx {
    param ($filePath, $extractPath)
    Write-Log "Extracting files from archive..."
    Add-Type -AssemblyName "System.IO.Compression.FileSystem"
    try {
        $zip = [System.IO.Compression.ZipFile]::OpenRead($filePath)
        $zip.Entries | Where-Object { $_.FullName -notlike '*/*' } | ForEach-Object {
            $destPath = Join-Path $extractPath $_.Name
            [System.IO.Compression.ZipFileExtensions]::ExtractToFile($_, $destPath, $true)
        }
    }
    finally {
        if ($zip -ne $null) {
            $zip.Dispose()
        }
    }
}

function Get-SpotifyExeVersion {
    param ($spotifyExePath)
    Write-Log "Getting version from file $([System.IO.Path]::GetFileName($spotifyExePath))..."
    $exeContent = Get-Content -Path $spotifyExePath -Raw
    $regex = '(?<![\w\-])(\d+)\.(\d+)\.(\d+)\.(\d+)(\.g[0-9a-f]{8})(?![\w\-])'
    if ($exeContent -match $regex) {
        Write-Log "Version received successfully: $($matches[0])"
        return $matches[0]
    }
    Write-Log "Version not found in file $([System.IO.Path]::GetFileName($spotifyExePath))"
    return $null
}

function Compare-SpotifyVersions {
    param ($version, $jsonUrl)
    Write-Log "Comparison of versions..."
    $ProgressPreference = 'SilentlyContinue'
    $jsonContent = Invoke-WebRequest -Uri $jsonUrl | ConvertFrom-Json
    $jsonContent."1.2.47.366".fullversion = "1.2.48.366.g0d3bd570"
    foreach ($jsonVersion in $jsonContent.PSObject.Properties) {
        if ($jsonVersion.Value.fullversion -eq $version) {
            Write-Log "New version not found"
            return $true
        }
    }
    Write-Log "New version found"
    return $false
}

function Trigger-GitAction {
    param (
        [string]$v,
        [string]$s
    )

    $apiUrl = "https://api.github.com/repos/amd64fox/LoaderSpot/dispatches"

    $payload = @{
        event_type     = "webhook-event"
        client_payload = @{
            v = $v
            s = $s
        }
    } | ConvertTo-Json

    $headers = @{
        "Accept"        = "application/vnd.github.everest-preview+json"
        "Authorization" = "Bearer " + $env:Token
        "Content-Type"  = "application/json"
    }

    Invoke-RestMethod -Uri $apiUrl -Method Post -Headers $headers -Body $payload
}

# Main
$tempPath = [System.IO.Path]::GetTempPath()
$spotifyTempDir = Join-Path $tempPath "Spotify"
New-Item -Path $spotifyTempDir -ItemType Directory -Force | Out-Null

$latestFile = Get-LatestSpotifyVersion
$filePath = Join-Path $spotifyTempDir $latestFile.FileName
Download-SpotifyAppx -downloadUrl $latestFile.Url -filePath $filePath
Extract-SpotifyAppx -filePath $filePath -extractPath $spotifyTempDir

$spotifyExePath = Get-ChildItem -Path $spotifyTempDir -Filter "Spotify.exe" -Recurse | Select-Object -First 1
if ($spotifyExePath) {
    $version = Get-SpotifyExeVersion -spotifyExePath $spotifyExePath.FullName
    if ($version) {
        $jsonUrl = "https://raw.githubusercontent.com/amd64fox/LoaderSpot/refs/heads/main/versions.json"
        $versionExists = Compare-SpotifyVersions -version $version -jsonUrl $jsonUrl
        if (-not $versionExists) {
            Trigger-GitAction -v $version -s "[Microsoft Store](https://apps.microsoft.com/detail/9ncbcszsjrsb)"
            Write-Log "Sent for search and processing in GAS"
        }
    }
    else {
        Write-Log "Version not found in Spotify.exe"
    }
}
else {
    Write-Log "Spotify.exe not found"
}