# 検索対象のディレクトリのリスト
$txtFile = $args[0]

# 存在するディレクトリのリスト
$outputFile = "found.txt"

# 存在しないディレクトリのリスト
$notFoundFile = "notfound.txt"

# ファイルの存在を確認
if (-not (Test-Path $txtFile)) {
    Write-Host "File not found: $txtFile"
    exit
}

# バッチファイルが実行されているディレクトリを取得
$baseDir = Split-Path -Parent $txtFile

# 存在しないディレクトリのリストを初期化
$notFoundDirs = @()

Write-Host "Starting process..."

# テキストファイルの各行を読み込み、指定されたフォルダがサブディレクトリとして存在するかチェック
Get-Content $txtFile | ForEach-Object {
    $folderName = $_
    $found = $false
    Write-Host "Searching: [$folderName]..."
    Get-ChildItem -Path $baseDir -Recurse -Depth 4 -Directory | Where-Object {
        $_.Name -eq $folderName
    } | ForEach-Object {
        Write-Host "Folder found: $($_.FullName)"
        # フォルダのパスを出力ファイルに追加
        Add-Content -Path $outputFile -Value $_.FullName
        $found = $true
    }
    if (-not $found) {
        $notFoundDirs += $folderName
    }
}

Write-Host "Process completed. Repositories found are listed in $outputFile"

# 存在しないディレクトリをリストに出力
if ($notFoundDirs.Count -gt 0) {
    Write-Host "Some directories were not found. Listing them in $notFoundFile"
    $notFoundDirs | ForEach-Object {
        Add-Content -Path $notFoundFile -Value $_
    }
} else {
    Write-Host "All directories were found."
}
