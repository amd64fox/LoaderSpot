do { $version_spoti = Read-Host -Prompt "Enter the Spotify version, for example 1.1.68.632.g2b11de83" }
while ($version_spoti -notmatch '^\d.\d.\d{1,2}.\d{1,5}.[a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z][0-9a-z]$')

do { $before_enter = Read-Host -Prompt "Enter the number to stop at (e.g. 99)" }
while ($before_enter -notmatch '^\d{1,4}$')
 
$numbers = 0

"Search..."
While ($numbers -le $before_enter) {
    
    $_URL = "https://upgrade.scdn.co/upgrade/client/win32-x86/spotify_installer-$version_spoti-$numbers.exe"
        

    try {
        $request = [System.Net.WebRequest]::Create($_URL)
        $response = $request.getResponse()

        if ($response.StatusCode -eq "200") {
            $response.ResponseUri.OriginalString
            $find_url += [System.Environment]::NewLine + $response.ResponseUri.OriginalString
            $response.Close()
        }
            
    }
    catch {
        $numbers
    }
        
    $numbers++
}

write-host "`n"
"Search completed"
write-host "`n"
if ($find_url) {
    "Found links :"
    $find_url
}
if (!($find_url)) {
    "Nothing found, please increase your search range."
}
write-host "`n"
pause
exit
