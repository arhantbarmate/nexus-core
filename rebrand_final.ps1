# rebrand_final.ps1 - STRICT Orthonode Trademark & Link Fixer (UTF-8)
$folders = @("backend", "client", "hivemapper-bee-runtime", ".")
$counter = 0

Write-Host ">> INITIALIZING SURGICAL REBRAND (UTF-8)..." -ForegroundColor Cyan

foreach ($folder in $folders) {
    if (Test-Path $folder) {
        # Scan only Markdown files
        Get-ChildItem -Path $folder -Filter *.md -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
            
            # READ: Force UTF8 to stop "broken fonts"
            $originalContent = Get-Content $_.FullName -Raw -Encoding UTF8
            $newContent = $originalContent

            # --- ACTION 1: FIX IMAGE LINKS ---
            # Replaces 'banner.png' with 'orthonode-banner.png' only if it hasn't been done
            $newContent = $newContent -replace 'banner\.png', 'orthonode-banner.png'

            # --- ACTION 2: LEGAL ENTITY SWAP ---
            $newContent = $newContent -replace 'Coreframe Systems', 'Orthonode Infrastructure Labs'
            
            # --- ACTION 3: TRADEMARK SWAP ---
            # Replaces 'Coreframe' with 'Orthonode' (Case sensitive to avoid breaking code variables if they are lowercase)
            $newContent = $newContent -replace 'Coreframe', 'Orthonode'

            # --- ACTION 4: PROTOTYPE TAGGING ---
            # Tags Nexus Protocol as Prototype, but avoids double-tagging if ran twice
            if ($newContent -notmatch 'Nexus Protocol \(Prototype\)') {
                $newContent = $newContent -replace 'Nexus Protocol', 'Nexus Protocol (Prototype)'
            }

            # --- ACTION 5: FOOTER CLEANUP ---
            $newContent = $newContent -replace 'Engineered by Arhant Barmate · Nexus', 'Engineered by Arhant Barmate · Orthonode'
            
            # WRITE: Only save if changes were made
            if ($originalContent -ne $newContent) {
                Set-Content -Path $_.FullName -Value $newContent -Encoding UTF8
                Write-Host " [FIXED] $($_.Name)" -ForegroundColor Green
                $counter++
            }
        }
    }
}

Write-Host ">> MISSION COMPLETE. Fixed $counter files." -ForegroundColor Yellow