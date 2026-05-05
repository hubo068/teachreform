Add-Type -AssemblyName System.Speech
$text = Get-Content -LiteralPath "narration.txt" -Raw -Encoding UTF8
$s = New-Object System.Speech.Synthesis.SpeechSynthesizer
$s.SelectVoice("Microsoft Huihui Desktop")
$s.Rate = 0
$s.Volume = 100
$out = (Resolve-Path "assets").Path + "\narration.wav"
$s.SetOutputToWaveFile($out)
$s.Speak($text)
$s.Dispose()
Get-Item $out | Select-Object FullName, Length
