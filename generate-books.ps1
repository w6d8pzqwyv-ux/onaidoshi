# onaidoshi - pre-generate book data (v3: range-split bulk fetch, multi-language)
# Fetch famous literary works split by fame ranges (small batches = stable),
# group by age locally, keep literary types only. Save to books-data.js / books-data-en.js.
# Usage:
#   powershell -ExecutionPolicy Bypass -File generate-books.ps1            (Japanese, default)
#   powershell -ExecutionPolicy Bypass -File generate-books.ps1 -Lang en   (English)
#   powershell -ExecutionPolicy Bypass -File generate-books.ps1 -Lang es   (Spanish)
#   powershell -ExecutionPolicy Bypass -File generate-books.ps1 -Lang pt   (Portuguese)
#   powershell -ExecutionPolicy Bypass -File generate-books.ps1 -Lang fr   (French)

param([string]$Lang = "ja")

$ErrorActionPreference = "Stop"
$UA = "onaidoshi/1.0 (https://w6d8pzqwyv-ux.github.io/onaidoshi/)"

# language-dependent settings
$wikiLang  = $Lang                                              # ja / en / es -> ja/en/es.wikipedia
$labelLang = if ($Lang -eq "en") { "en" } elseif ($Lang -eq "es") { "es,en" } elseif ($Lang -eq "pt") { "pt,en" } elseif ($Lang -eq "fr") { "fr,en" } else { "ja,en" }
$varName   = if ($Lang -eq "en") { "BOOKS_DATA_EN" } elseif ($Lang -eq "es") { "BOOKS_DATA_ES" } elseif ($Lang -eq "pt") { "BOOKS_DATA_PT" } elseif ($Lang -eq "fr") { "BOOKS_DATA_FR" } else { "BOOKS_DATA" }
$OUT       = if ($Lang -eq "en") { "$PSScriptRoot\books-data-en.js" } elseif ($Lang -eq "es") { "$PSScriptRoot\books-data-es.js" } elseif ($Lang -eq "pt") { "$PSScriptRoot\books-data-pt.js" } elseif ($Lang -eq "fr") { "$PSScriptRoot\books-data-fr.js" } else { "$PSScriptRoot\books-data.js" }

function Invoke-WDQS($query, $timeout) {
  $url = "https://query.wikidata.org/sparql?format=json&query=" + [uri]::EscapeDataString($query)
  try {
    $r = Invoke-WebRequest -Uri $url -Headers @{ "Accept"="application/sparql-results+json"; "User-Agent"=$UA } -UseBasicParsing -TimeoutSec $timeout
    $text = [System.Text.Encoding]::UTF8.GetString($r.Content)
    return @{ ok=$true; data=($text | ConvertFrom-Json) }
  } catch { return @{ ok=$false; err=$_.Exception.Message } }
}
function Get-WDQS($query) {
  for ($i = 1; $i -le 4; $i++) {
    $r = Invoke-WDQS $query 80
    if ($r.ok) { return $r }
    Start-Sleep -Seconds ($i * 5)
  }
  return $r
}
function Qid($uri) { return ($uri -split "/")[-1] }

# literary types to keep
$allow = @{}
"Q8261","Q149537","Q49084","Q7725634","Q47461344","Q5185279","Q25379","Q179959","Q699","Q35760","Q4184","Q1318295","Q1372064","Q12106333","Q7727","Q34620","Q25372","Q5292","Q1209283" | ForEach-Object { $allow[$_] = $true }
# types to exclude (manga, game, comic, graphic novel, anime, document, scientific article)
$deny = @{}
"Q8274","Q7889","Q1004","Q838795","Q1760610","Q1107","Q21198342","Q1233720","Q11424","Q13442814","Q49757","Q1153574","Q725377","Q2831984","Q3297186","Q1004280" | ForEach-Object { $deny[$_] = $true }
# exclude specific works by QID (hate/propaganda - never list with a buy link)
$excludeQid = @{}
"Q48244","Q1323886","Q1669919","Q1678947","Q17124728","Q125020971","Q139876069","Q26193","Q36393","Q105095422","Q123244145","Q486292","Q4366335","Q126687624","Q126687634" | ForEach-Object { $excludeQid[$_] = $true }

$AGE_MIN = 15
$AGE_MAX = 75
$PER_AGE = 40

# fame ranges down to 20. Lower ranges are split finely to keep each batch small.
$ranges = @(
  @(250, 100000),
  @(150, 250),
  @(110, 150),
  @(90, 110),
  @(75, 90),
  @(63, 75),
  @(54, 63),
  @(47, 54),
  @(41, 47),
  @(36, 41),
  @(31, 36),
  @(27, 31),
  @(24, 27),
  @(20, 24)
)

$result = [ordered]@{}

function Save-Data {
  $json = $result | ConvertTo-Json -Depth 6 -Compress
  $text = "window.$varName = $json;`r`n"
  Set-Content -Path $OUT -Value $text -Encoding UTF8
}

Write-Output "Generating for language: $Lang (wiki=$wikiLang, out=$OUT)"

# ---- stage 1: candidates per fame range (age computed & filtered server-side) ----
$cand = @{}   # qid -> @{ title; author; sl; py; by; age }
foreach ($rg in $ranges) {
  $lo = $rg[0]; $hi = $rg[1]
  $q = @"
SELECT ?work ?workLabel ?authorLabel ?pubYear ?birthYear ?age ?sitelinks WHERE {
  ?work wdt:P50 ?author ;
        wdt:P577 ?pubDate ;
        wikibase:sitelinks ?sitelinks .
  ?author wdt:P569 ?birthDate .
  FILTER(?sitelinks >= $lo && ?sitelinks < $hi)
  BIND(YEAR(?pubDate) AS ?pubYear)
  BIND(YEAR(?birthDate) AS ?birthYear)
  BIND(?pubYear - ?birthYear AS ?age)
  FILTER(?age >= $AGE_MIN && ?age <= $AGE_MAX)
  SERVICE wikibase:label { bd:serviceParam wikibase:language "$labelLang". }
} LIMIT 2000
"@
  $r = Get-WDQS $q
  if (-not $r.ok) { Write-Output "range $lo-$hi : FAILED"; continue }
  $n = 0
  foreach ($b in $r.data.results.bindings) {
    $qid = Qid $b.work.value
    $title = $b.workLabel.value
    if ($title -match "^Q[0-9]+$") { continue }
    if ($excludeQid.Contains($qid)) { continue }
    $py = [int]$b.pubYear.value
    $by = [int]$b.birthYear.value
    $age = [int]$b.age.value
    if (-not $cand.Contains($qid)) {
      $cand[$qid] = @{ title=$title; author=$b.authorLabel.value; sl=[int]$b.sitelinks.value; py=$py; by=$by; age=$age }
    } elseif ($py -lt $cand[$qid].py) {
      $cand[$qid].py = $py; $cand[$qid].age = $age
    }
    $n++
  }
  Write-Output "range $lo-$hi : $n rows, total $($cand.Count)"
  Start-Sleep -Seconds 1
}
Write-Output "STAGE1 DONE. candidates: $($cand.Count)"

# ---- stage 2: types + wikipedia article (batches of 120) ----
$types = @{}; $articles = @{}
$ids = @($cand.Keys)
for ($i = 0; $i -lt $ids.Count; $i += 120) {
  $batch = $ids[$i..([Math]::Min($i+119, $ids.Count-1))]
  $values = ($batch | ForEach-Object { "wd:$_" }) -join " "
  $q2 = @"
SELECT ?work ?type ?article WHERE {
  VALUES ?work { $values }
  ?work wdt:P31 ?type .
  OPTIONAL { ?a schema:about ?work ; schema:isPartOf <https://$wikiLang.wikipedia.org/> ; schema:name ?article . }
}
"@
  $r2 = Get-WDQS $q2
  if (-not $r2.ok) { Write-Output "type batch $i : FAILED"; continue }
  foreach ($b in $r2.data.results.bindings) {
    $qid = Qid $b.work.value
    $t = Qid $b.type.value
    if (-not $types.Contains($qid)) { $types[$qid] = @{} }
    $types[$qid][$t] = $true
    if ($b.article -and -not $articles.Contains($qid)) { $articles[$qid] = $b.article.value }
  }
  Write-Output "type batch $i done"
  Start-Sleep -Seconds 1
}
Write-Output "STAGE2 DONE."

# ---- filter literary + group by age ----
$byAge = @{}
foreach ($qid in $cand.Keys) {
  $tset = $types[$qid]
  if (-not $tset) { continue }
  $den = $false; foreach ($t in $tset.Keys) { if ($deny.Contains($t)) { $den = $true; break } }
  if ($den) { continue }
  $lit = $false; foreach ($t in $tset.Keys) { if ($allow.Contains($t)) { $lit = $true; break } }
  if (-not $lit) { continue }
  $c = $cand[$qid]
  $art = ""; if ($articles.Contains($qid)) { $art = $articles[$qid] }
  $a = "$($c.age)"
  if (-not $byAge.Contains($a)) { $byAge[$a] = @() }
  $byAge[$a] += @{ t=$c.title; a=$c.author; y="$($c.py)"; by="$($c.by)"; art=$art; sl=$c.sl }
}

# ---- build ordered result: top PER_AGE per age, deduped by title+author ----
$result = [ordered]@{}
for ($age = $AGE_MIN; $age -le $AGE_MAX; $age++) {
  $a = "$age"
  if (-not $byAge.Contains($a)) { $result[$a] = @(); continue }
  $sorted = $byAge[$a] | Sort-Object -Property @{Expression={[int]$_.sl}; Descending=$true}
  $seen = @{}; $picked = @()
  foreach ($bk in $sorted) {
    $key = $bk.t + "|" + $bk.a
    if ($seen.Contains($key)) { continue }
    $seen[$key] = $true
    $picked += [ordered]@{ t=$bk.t; a=$bk.a; y=$bk.y; by=$bk.by; art=$bk.art }
    if ($picked.Count -ge $PER_AGE) { break }
  }
  $result[$a] = @($picked)
}

$json = $result | ConvertTo-Json -Depth 6 -Compress
$text = "window.$varName = $json;`r`n"
Set-Content -Path $OUT -Value $text -Encoding UTF8

$withData = 0; foreach ($k in $result.Keys) { if ($result[$k].Count -gt 0) { $withData++ } }
Write-Output "DONE. lang=$Lang ages with data: $withData / $($result.Count). saved to $OUT"
