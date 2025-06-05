
Write-Host ""
Write-Host "what would you like to do?"

Write-Host ""
Write-Host "   A) Collect new Baseline?"
Write-Host "   B) Begin monitoring files with saved Baseline?"
Write-Host ""

$response = Read-Host -Prompt "please enter 'A' or 'B'"
Write-Host ""

Function Calculate-File-Hash($filepath) {
    $filehash = Get-FileHash -Path $filepath -Algorithm SHA512
    return $filehash
}

Function Erase-Baseline-If-Already-Exists() {
    $baselineExists = Test-Path -Path "C:\Users\tj_ju\OneDrive\Documents\Cybersecurity Program\FILE INTEGRITY MONITORING LAB\Files\baseline.txt"

    if ($baselineExists) {
        # Delete it
        Remove-item -Path "C:\Users\tj_ju\OneDrive\Documents\Cybersecurity Program\FILE INTEGRITY MONITORING LAB\Files\baseline.txt"
    }
}


if ($response -eq "A".ToUpper()) {
    #Delete baseline.txt if it already exists
    Erase-Baseline-If-Already-Exists

    # Calculate Hash from the target files and store in baseline.txt
    
    # Collect all files in a target folder
    $files = Get-ChildItem -Path "C:\Users\tj_ju\OneDrive\Documents\Cybersecurity Program\FILE INTEGRITY MONITORING LAB\Files"

    # For File, calculate the hash, and write it to baseline.txt
    foreach ($f in $files) {
        $hash = Calculate-File-Hash $f.Fullname
        "$($hash.Path)|$($hash.Hash)" | Out-File -FilePath "C:\Users\tj_ju\OneDrive\Documents\Cybersecurity Program\FILE INTEGRITY MONITORING LAB\Files\baseline.txt" -Append
    }

}
elseif ($response -eq "B".ToUpper()) {
    
    $fileHashDictionary = @{}
    
    # Load file|hash from baseline.txt and store them in a dictionary
    $filesPathsAndHashes = Get-Content -Path "C:\Users\tj_ju\OneDrive\Documents\Cybersecurity Program\FILE INTEGRITY MONITORING LAB\Files\baseline.txt"
    
    foreach ($f in $filesPathsAndHashes) {
       $fileHashDictionary.add($f.Split("|")[0],$f.Split("|")[1])
    }

   # To check for values or keys, use code $fileHashDictionary.Values

    # Begin (continuosly) monitoring files with saved Baseline  
    while ($true) {
        Start-Sleep -Seconds 1 
        
        $files = Get-ChildItem -Path "C:\Users\tj_ju\OneDrive\Documents\Cybersecurity Program\FILE INTEGRITY MONITORING LAB\Files"

    # For File, calculate the hash, and write it to baseline.txt
    foreach ($f in $files) {
        $hash = Calculate-File-Hash $f.Fullname
        # "$($hash.Path)|$($hash.Hash)" | Out-File -FilePath "C:\Users\tj_ju\OneDrive\Documents\Cybersecurity Program\FILE INTEGRITY MONITORING LAB\Files\baseline.txt" -Append


        # Notify if a new file has been created
        if ($fileHashDictionary[$hash.Path] -eq $null) {
            # A new file has been created! 
            Write-Host "$($hash.Path) has been created!" -ForegroundColor Green
         }
         else {
            
                  #Notify if a new file has been changed
                if ($fileHashDictionary[$hash.Path] -eq $hash.Hash) {
                 # The file has not changed
               }
                else {  
                # File has been compromised!, notify the user
                Write-Host "$($hash.Path) has changed!!!" -ForegroundColor Yellow
               }
          }
         
       }
         foreach ($key in $fileHashDictionary.keys) {
            $baselineFileStillExists = Test-Path -Path $key
            if (-Not $baselineFileStillExists) {
               #one of the baseline files must have been deleted, notify the user
               Write-Host "$($key) has been deleted!" -ForegroundColor DarkRed
            }
        }
       
    }


}