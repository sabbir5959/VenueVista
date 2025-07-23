# PowerShell script to update all font sizes in Flutter project
# Font size mapping based on requirements:
# Heading text: 20-24 
# Sub-heading: 16-18  
# Body text: 14-16
# Small text/Caption: 12-14

$projectPath = "e:\Flutter\venuevista\lib"

# Files to update (excluding test files)
$dartFiles = Get-ChildItem -Path $projectPath -Recurse -Filter "*.dart" | Where-Object { $_.FullName -notlike "*test*" }

foreach ($file in $dartFiles) {
    $content = Get-Content $file.FullName -Raw
    
    # Add import if not exists and if file contains fontSize
    if ($content -match "fontSize:" -and $content -notmatch "import.*text_styles.dart") {
        # Find the right place to add import
        if ($content -match "import 'package:flutter/material.dart';") {
            $content = $content -replace "(import 'package:flutter/material\.dart';)", "`$1`nimport '../constants/text_styles.dart';"
        }
    }
    
    # Replace font sizes with AppTextStyles
    # Large headings (48, 28, 24) -> headingLarge (24)
    $content = $content -replace "fontSize:\s*48", "// fontSize: 48 -> AppTextStyles.headingLarge"
    $content = $content -replace "fontSize:\s*28", "// fontSize: 28 -> AppTextStyles.headingLarge" 
    $content = $content -replace "fontSize:\s*24", "// fontSize: 24 -> AppTextStyles.heading"
    
    # Medium headings (20, 22) -> headingMedium (20)
    $content = $content -replace "fontSize:\s*22", "// fontSize: 22 -> AppTextStyles.headingMedium"
    $content = $content -replace "fontSize:\s*20", "// fontSize: 20 -> AppTextStyles.headingMedium"
    
    # Sub-headings (18, 16) -> subHeading (18) or subHeadingSmall (16)
    $content = $content -replace "fontSize:\s*18", "// fontSize: 18 -> AppTextStyles.subHeading"
    $content = $content -replace "fontSize:\s*16", "// fontSize: 16 -> AppTextStyles.body"
    
    # Body text (15, 14) -> body (16) or bodySmall (14)
    $content = $content -replace "fontSize:\s*15", "// fontSize: 15 -> AppTextStyles.bodyMedium"
    $content = $content -replace "fontSize:\s*14", "// fontSize: 14 -> AppTextStyles.bodySmall"
    
    # Small text/Caption (13, 12, 11, 10, 9) -> captionSmall (12)
    $content = $content -replace "fontSize:\s*13", "// fontSize: 13 -> AppTextStyles.captionSmall"
    $content = $content -replace "fontSize:\s*12", "// fontSize: 12 -> AppTextStyles.captionSmall"
    $content = $content -replace "fontSize:\s*11", "// fontSize: 11 -> AppTextStyles.captionSmall"
    $content = $content -replace "fontSize:\s*10", "// fontSize: 10 -> AppTextStyles.captionSmall"
    $content = $content -replace "fontSize:\s*9", "// fontSize: 9 -> AppTextStyles.captionSmall"
    
    Set-Content -Path $file.FullName -Value $content
    Write-Host "Updated: $($file.Name)"
}

Write-Host "Font size update completed!"
