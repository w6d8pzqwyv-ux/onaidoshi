# generate-age-pages.ps1 — SEO用「年齢別 名作一覧」ページを books-data.js から自動生成（日本語）
# 出力: age/<n>.html (15..75) + age/index.html(ハブ) + sitemap-age.xml
# 使い方: powershell -ExecutionPolicy Bypass -File generate-age-pages.ps1

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$base = "https://w6d8pzqwyv-ux.github.io/onaidoshi"
$amazonTag = "onaidoshi05-22"
$gaId = "G-1ZSQ9QJRHX"

# --- books-data.js を読み込んでJSON部分を取り出す ---
$raw = Get-Content "$root\books-data.js" -Raw -Encoding UTF8
$jsonStart = $raw.IndexOf("{")
$jsonEnd = $raw.LastIndexOf("}")
$json = $raw.Substring($jsonStart, $jsonEnd - $jsonStart + 1)
$data = $json | ConvertFrom-Json

$ageDir = "$root\age"
if (-not (Test-Path $ageDir)) { New-Item -ItemType Directory -Path $ageDir | Out-Null }

function Esc($s) {
  if ($null -eq $s) { return "" }
  return $s.Replace("&", "&amp;").Replace("<", "&lt;").Replace(">", "&gt;").Replace('"', "&quot;")
}

# 共通のhead(GA・OG)
function Head($title, $desc, $canonical) {
  return @"
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>$title</title>
<meta name="description" content="$desc">
<link rel="canonical" href="$canonical">
<meta property="og:title" content="$title">
<meta property="og:description" content="$desc">
<meta property="og:url" content="$canonical">
<meta property="og:type" content="article">
<meta property="og:image" content="$base/og-image-2.png">
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:image" content="$base/og-image-2.png">
<script async src="https://www.googletagmanager.com/gtag/js?id=$gaId"></script>
<script>window.dataLayer=window.dataLayer||[];function gtag(){dataLayer.push(arguments);}gtag('js',new Date());gtag('config','$gaId');</script>
<style>
  :root{--bg:#faf7f2;--card:#fff;--ink:#2b2622;--sub:#8a8178;--accent:#b3541e;--line:#ece5da;}
  *{box-sizing:border-box;}
  body{margin:0;font-family:Georgia,"Times New Roman",serif;background:var(--bg);color:var(--ink);line-height:1.8;}
  .wrap{max-width:720px;margin:0 auto;padding:40px 20px 70px;}
  h1{font-size:24px;margin:0 0 6px;}
  .lead{color:var(--sub);font-size:15px;margin:0 0 24px;}
  .cta{display:inline-block;background:var(--accent);color:#fff;padding:11px 20px;border-radius:10px;text-decoration:none;font-size:15px;margin:6px 0 26px;}
  .book{background:var(--card);border:1px solid var(--line);border-radius:12px;padding:14px 18px;margin-bottom:12px;}
  .book .t{font-size:18px;margin:0 0 3px;}
  .book .m{font-size:14px;color:var(--sub);margin:0 0 8px;}
  .book a{color:var(--accent);text-decoration:none;font-size:14px;}
  .nav{display:flex;justify-content:space-between;margin:30px 0;font-size:14px;}
  .nav a{color:var(--accent);text-decoration:none;}
  .grid{display:flex;flex-wrap:wrap;gap:8px;margin-top:10px;}
  .grid a{display:inline-block;border:1px solid var(--line);border-radius:8px;padding:7px 12px;color:var(--ink);text-decoration:none;font-size:14px;background:#fff;}
  .note{font-size:12px;color:var(--sub);margin-top:36px;text-align:center;}
  footer{margin-top:30px;padding-top:20px;border-top:1px solid var(--line);font-size:13px;color:var(--sub);text-align:center;}
  footer a{color:var(--sub);}
</style>
</head>
<body>
<div class="wrap">
"@
}

function Foot() {
  return @"
<footer>
<p>当サイトはAmazonアソシエイト・プログラムおよび楽天アフィリエイトの参加者です。リンクを通じた購入により収益を得る場合があります。</p>
<p><a href="../">トップへ戻る</a> ・ <a href="../privacy.html">プライバシーポリシー</a></p>
</footer>
</div>
</body>
</html>
"@
}

$ages = @()
for ($n = 15; $n -le 75; $n++) {
  $key = "$n"
  $books = $data.$key
  if (-not $books -or $books.Count -eq 0) { continue }
  $ages += $n

  $title = "${n}歳で書かれた世界の名作｜同い年の名作"
  $names = ($books | Select-Object -First 3 | ForEach-Object { $_.a }) -join "・"
  $desc = "${n}歳のときに世界の作家が書いた名作の一覧。$names など、${n}歳で書かれた名作と著者・出版年がわかります。"
  $canonical = "$base/age/$n.html"

  $sb = New-Object System.Text.StringBuilder
  [void]$sb.Append((Head (Esc $title) (Esc $desc) $canonical))
  [void]$sb.Append("<h1>${n}歳で書かれた世界の名作</h1>`r`n")
  [void]$sb.Append("<p class=""lead"">${n}歳のときに、世界の作家たちはどんな名作を書いたのか。$($books.Count)作品を一覧にしました。</p>`r`n")
  [void]$sb.Append("<a class=""cta"" href=""../"">▶ あなたと同い年の名作を調べる</a>`r`n")

  foreach ($b in $books) {
    $t = Esc $b.t; $a = Esc $b.a; $y = $b.y
    $q = [uri]::EscapeDataString(($b.t + " " + $b.a))
    $az = "https://www.amazon.co.jp/s?tag=$amazonTag&k=$q"
    $rk = "https://search.rakuten.co.jp/search/mall/?sitem=$q"
    $yr = if ($y) { "（${y}年）" } else { "" }
    [void]$sb.Append("<div class=""book""><p class=""t"">$t$yr</p><p class=""m"">$a</p><a href=""$az"" target=""_blank"" rel=""noopener nofollow"">Amazonで探す →</a> ・ <a href=""$rk"" target=""_blank"" rel=""noopener nofollow"">楽天で探す →</a></div>`r`n")
  }

  # 前後の年齢ナビ
  $prev = $n - 1; $next = $n + 1
  $nav = "<div class=""nav"">"
  if ($prev -ge 15) { $nav += "<a href=""$prev.html"">← ${prev}歳の名作</a>" } else { $nav += "<span></span>" }
  if ($next -le 75) { $nav += "<a href=""$next.html"">${next}歳の名作 →</a>" } else { $nav += "<span></span>" }
  $nav += "</div>"
  [void]$sb.Append("$nav`r`n")
  [void]$sb.Append("<p><a href=""index.html"">▶ 年齢別 名作一覧（すべての年齢）</a></p>`r`n")
  [void]$sb.Append((Foot))

  Set-Content -Path "$ageDir\$n.html" -Value $sb.ToString() -Encoding UTF8
}

# --- ハブページ age/index.html ---
$hubTitle = "年齢別 名作一覧｜同い年の名作"
$hubDesc = "15歳から75歳まで、各年齢で世界の作家が書いた名作を一覧できます。あなたと同い年の名作を探してみましょう。"
$hub = New-Object System.Text.StringBuilder
[void]$hub.Append((Head (Esc $hubTitle) (Esc $hubDesc) "$base/age/"))
[void]$hub.Append("<h1>年齢別 名作一覧</h1>`r`n")
[void]$hub.Append("<p class=""lead"">各年齢のときに世界の作家が書いた名作を一覧できます。気になる年齢を選んでください。</p>`r`n")
[void]$hub.Append("<a class=""cta"" href=""../"">▶ あなたと同い年の名作を調べる</a>`r`n")
[void]$hub.Append("<div class=""grid"">`r`n")
foreach ($n in $ages) { [void]$hub.Append("<a href=""$n.html"">${n}歳</a>`r`n") }
[void]$hub.Append("</div>`r`n")
[void]$hub.Append((Foot))
Set-Content -Path "$ageDir\index.html" -Value $hub.ToString() -Encoding UTF8

# --- sitemap-age.xml ---
$today = Get-Date -Format "yyyy-MM-dd"
$sm = New-Object System.Text.StringBuilder
[void]$sm.Append("<?xml version=""1.0"" encoding=""UTF-8""?>`r`n<urlset xmlns=""http://www.sitemaps.org/schemas/sitemap/0.9"">`r`n")
[void]$sm.Append("  <url><loc>$base/age/</loc><lastmod>$today</lastmod><changefreq>monthly</changefreq><priority>0.7</priority></url>`r`n")
foreach ($n in $ages) {
  [void]$sm.Append("  <url><loc>$base/age/$n.html</loc><lastmod>$today</lastmod><changefreq>monthly</changefreq><priority>0.6</priority></url>`r`n")
}
[void]$sm.Append("</urlset>`r`n")
Set-Content -Path "$root\sitemap-age.xml" -Value $sm.ToString() -Encoding UTF8

Write-Output "DONE. generated $($ages.Count) age pages + index + sitemap-age.xml"
