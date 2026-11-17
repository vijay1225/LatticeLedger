$line = (Get-Content "C:\Users\Vijay\.gemini\antigravity\brain\824b44a9-25f6-4ab3-978c-1edfb0458d87\.system_generated\logs\transcript.jsonl" | Select-Object -Index 13576)
Write-Output $line.Substring(0, [Math]::Min(1000, $line.Length))
