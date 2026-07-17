#!/usr/bin/env bash
set -euo pipefail

python3 <<'PY'
from pathlib import Path
from datetime import datetime
import re
import shutil

root = Path.home() / "Oddscape/GitHub/oddscape"
stamp = datetime.now().strftime("%Y%m%d_%H%M%S")

targets = [
    "index.html",
    "archive.html",
    "commissions.html",
    "start.html",
    "faq.html",
    "licence.html",

    "birsaybay.html",
    "brodgar.html",
    "ring-of-brodgar.html",
    "llyn-llydaw_crib-goch.html",
    "norwich_central.html",
    "orfordness.html",
    "river-clyde-tinto-foothills.html",
    "skara_brae.html",
    "sutton_hoo.html",
    "wookey-hole.html",
    "wookey.html",
]

cta_html = """
<section class="studio-work-cta" aria-labelledby="studio-work-cta-title">
  <div class="studio-work-cta-kicker">Studio Oddscape</div>

  <h2 id="studio-work-cta-title">Explore the Creative Studio</h2>

  <p>
    Discover terrain-derived prints, cartographic compositions and visual
    studies developed from LiDAR, elevation data, bathymetry and landscape
    interpretation.
  </p>

  <a class="studio-work-cta-button" href="studio-work.html">
    Browse Studio Work
  </a>
</section>
""".strip()

cta_css = """
/* STUDIO WORK FOOTER CTA — BEGIN */
.studio-work-cta{
  max-width:860px;
  margin:64px auto 0;
  padding:44px 38px;
  text-align:center;
  border-top:1px solid rgba(217,188,130,.22);
  border-bottom:1px solid rgba(217,188,130,.22);
  background:rgba(0,0,0,.10)
}

.studio-work-cta-kicker{
  margin-bottom:14px;
  color:var(--muted);
  font-size:11px;
  font-weight:650;
  letter-spacing:3px;
  text-transform:uppercase
}

.studio-work-cta h2{
  color:var(--gold);
  font-size:clamp(28px,4vw,40px);
  line-height:1.15
}

.studio-work-cta p{
  max-width:680px;
  margin:18px auto 0;
  color:rgba(220,226,230,.82);
  font-size:16px;
  line-height:1.7
}

.studio-work-cta-button{
  display:inline-block;
  margin-top:26px;
  padding:14px 25px;
  border:1px solid rgba(217,188,130,.42);
  color:var(--gold);
  background:rgba(0,0,0,.10);
  font-size:11px;
  letter-spacing:2.5px;
  text-decoration:none;
  text-transform:uppercase
}

.studio-work-cta-button:hover{
  background:rgba(217,188,130,.08)
}

@media(max-width:700px){
  .studio-work-cta{
    margin-top:48px;
    padding:36px 24px
  }

  .studio-work-cta p{
    font-size:15px
  }
}
/* STUDIO WORK FOOTER CTA — END */
""".strip()

css_pattern = re.compile(
    r"/\* STUDIO WORK FOOTER CTA — BEGIN \*/.*?"
    r"/\* STUDIO WORK FOOTER CTA — END \*/",
    flags=re.DOTALL
)

# Finds a Studio Work link inside navigation and removes it.
studio_nav_link = re.compile(
    r"\s*<a\b[^>]*href=[\"']studio-work\.html[\"'][^>]*>"
    r".*?</a>\s*",
    flags=re.DOTALL | re.IGNORECASE
)

updated = 0
skipped = 0

for filename in targets:
    path = root / filename

    if not path.exists():
        print(f"SKIPPED: {filename} not found")
        skipped += 1
        continue

    original = path.read_text(encoding="utf-8")
    text = original

    # Remove Studio Work only from the top navigation.
    nav_match = re.search(
        r"<nav\b[^>]*>.*?</nav>",
        text,
        flags=re.DOTALL | re.IGNORECASE
    )

    if nav_match:
        old_nav = nav_match.group(0)
        new_nav = studio_nav_link.sub("\n", old_nav)
        text = text.replace(old_nav, new_nav, 1)

    # Replace an existing CTA, or insert a new one before the footer.
    if re.search(
        r"<section\b[^>]*class=[\"'][^\"']*studio-work-cta[^\"']*[\"']",
        text,
        flags=re.IGNORECASE
    ):
        text = re.sub(
            r"<section\b[^>]*class=[\"'][^\"']*studio-work-cta[^\"']*[\"']"
            r".*?</section>",
            cta_html,
            text,
            count=1,
            flags=re.DOTALL | re.IGNORECASE
        )
    else:
        text, footer_count = re.subn(
            r"<footer\b",
            cta_html + "\n<footer",
            text,
            count=1,
            flags=re.IGNORECASE
        )

        if footer_count == 0:
            print(f"SKIPPED: {filename} has no footer")
            skipped += 1
            continue

    # Replace previous CTA CSS or append it before </style>.
    if css_pattern.search(text):
        text = css_pattern.sub(cta_css, text)
    else:
        text, style_count = re.subn(
            r"</style>",
            cta_css + "\n</style>",
            text,
            count=1,
            flags=re.IGNORECASE
        )

        if style_count == 0:
            print(f"SKIPPED: {filename} has no </style> tag")
            skipped += 1
            continue

    if text == original:
        print(f"UNCHANGED: {filename}")
        continue

    backup = path.with_name(
        f"{path.name}.before_studio_cta_{stamp}.bak"
    )

    shutil.copy2(path, backup)
    path.write_text(text, encoding="utf-8")

    print(f"UPDATED: {filename}")
    print(f"  Backup: {backup.name}")
    updated += 1

print()
print(f"Updated: {updated}")
print(f"Skipped: {skipped}")
print("Nothing has been committed or pushed.")
PY
