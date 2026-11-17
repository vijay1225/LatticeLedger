$lines = Get-Content "C:\Users\Vijay\.gemini\antigravity\brain\824b44a9-25f6-4ab3-978c-1edfb0458d87\.system_generated\logs\transcript.jsonl"
$lastUser = $null
foreach ($l in $lines) {
    if ($l -match '"source":"USER_EXPLICIT"') {
        $lastUser = $l
    }
}
Write-Output $lastUser
