#!/usr/bin/env bash
set -euo pipefail

python3 <<'PY'
from pathlib import Path
from datetime import datetime
import re
import shutil

root = Path.home() / "Oddscape/GitHub/oddscape"
master_path = root / "studio-work.html"

if not master_path.exists():
    raise SystemExit(
        "ERROR: studio-work.html was not found in "
        "~/Oddscape/GitHub/oddscape"
    )

master_text = master_path.read_text(encoding="utf-8")

# Copy the exact header HTML from Studio Work.
header_match = re.search(
    r"<header\b[^>]*>.*?</header>",
    master_text,
    flags=re.DOTALL | re.IGNORECASE
)

if not header_match:
    raise SystemExit(
        "ERROR: No <header>...</header> block found "
        "in studio-work.html"
    )

master_header = header_match.group(0)

# Shared Studio Oddscape header, HUD and navigation styling.
master_css = """
/* ODDSCAPE MASTER HEADER — BEGIN */
header{
  text-align:center;
  padding:40px 32px 24px
}

.logo{
  display:block;
  font-size:clamp(44px,7vw,78px);
  font-weight:800;
  color:var(--gold);
  line-height:.95;
  letter-spacing:-2px;
  text-decoration:none;
  text-shadow:0 2px 18px rgba(0,0,0,.45)
}

.subtitle{
  margin-top:16px;
  font-size:12px;
  letter-spacing:5px;
  color:rgba(220,226,230,.68);
  text-transform:uppercase
}

.hud{
  width:520px;
  max-width:80%;
  height:24px;
  margin:22px auto 0;
  position:relative
}

.hud:before,
.hud:after{
  content:"";
  position:absolute;
  top:50%;
  width:calc(50% - 24px);
  height:1px
}

.hud:before{
  left:0;
  background:linear-gradient(
    90deg,
    transparent,
    rgba(217,188,130,.55)
  )
}

.hud:after{
  right:0;
  background:linear-gradient(
    90deg,
    rgba(217,188,130,.55),
    transparent
  )
}

.hud-marker{
  position:absolute;
  left:50%;
  top:50%;
  width:22px;
  height:22px;
  transform:translate(-50%,-50%)
}

.hud-marker svg{
  width:100%;
  height:100%;
  fill:none;
  stroke:var(--gold);
  stroke-width:1.4;
  stroke-linecap:round
}

nav{
  display:flex;
  justify-content:center;
  align-items:stretch;
  flex-wrap:nowrap;
  width:100%;
  border-top:1px solid rgba(217,188,130,.28);
  border-bottom:1px solid rgba(217,188,130,.28);
  background:rgba(0,0,0,.10)
}

nav a{
  text-decoration:none;
  color:var(--text);
  padding:17px 34px;
  font-size:13px;
  letter-spacing:1.8px;
  text-transform:uppercase;
  text-align:center;
  white-space:nowrap;
  border-right:1px solid var(--line)
}

nav a:last-child{
  border-right:none
}

nav a:hover,
nav a.nav-current{
  color:var(--gold);
  background:rgba(217,188,130,.035)
}

@media(max-width:820px){
  header{
    padding:30px 20px 20px
  }

  .logo{
    font-size:clamp(44px,9vw,64px)
  }

  .subtitle{
    font-size:10px;
    letter-spacing:3px
  }

  nav a{
    padding:13px 16px;
    font-size:11px
  }
}

@media(max-width:520px){
  header{
    padding-left:16px;
    padding-right:16px
  }

  nav a{
    flex:1 1 0;
    min-width:0;
    padding:13px 4px;
    font-size:clamp(8px,2.5vw,10px);
    letter-spacing:.5px
  }
}
/* ODDSCAPE MASTER HEADER — END */
""".strip()

old_standard_block = re.compile(
    r"/\* ODDSCAPE STANDARD HEADER — BEGIN \*/.*?"
    r"/\* ODDSCAPE STANDARD HEADER — END \*/",
    flags=re.DOTALL
)

old_master_block = re.compile(
    r"/\* ODDSCAPE MASTER HEADER — BEGIN \*/.*?"
    r"/\* ODDSCAPE MASTER HEADER — END \*/",
    flags=re.DOTALL
)

stamp = datetime.now().strftime("%Y%m%d_%H%M%S")

targets = []

for path in sorted(root.glob("*.html")):
    name = path.name

    if name == "studio-work.html":
        continue

    if name.startswith("index_before_"):
        continue

    targets.append(path)

print("Pages selected:")
for path in targets:
    print(f"  {path.name}")

print()

updated_count = 0
skipped_count = 0

for path in targets:
    original = path.read_text(encoding="utf-8")
    text = original

    # Only update pages that contain an existing header.
    text, header_count = re.subn(
        r"<header\b[^>]*>.*?</header>",
        master_header,
        text,
        count=1,
        flags=re.DOTALL | re.IGNORECASE
    )

    if header_count == 0:
        print(f"SKIPPED: {path.name} — no <header> block found")
        skipped_count += 1
        continue

    # Replace a previous shared block, or append the master block
    # at the end of the existing <style> section.
    if old_master_block.search(text):
        text = old_master_block.sub(master_css, text)

    elif old_standard_block.search(text):
        text = old_standard_block.sub(master_css, text)

    else:
        text, style_count = re.subn(
            r"</style>",
            master_css + "\n</style>",
            text,
            count=1,
            flags=re.IGNORECASE
        )

        if style_count == 0:
            print(f"SKIPPED: {path.name} — no </style> tag found")
            skipped_count += 1
            continue

    if text == original:
        print(f"UNCHANGED: {path.name}")
        continue

    backup = path.with_name(
        f"{path.name}.before_all_headers_{stamp}.bak"
    )

    shutil.copy2(path, backup)
    path.write_text(text, encoding="utf-8")

    print(f"UPDATED: {path.name}")
    print(f"  Backup: {backup.name}")
    updated_count += 1

print()
print(f"Updated: {updated_count}")
print(f"Skipped: {skipped_count}")
print("Nothing has been committed or pushed.")
PY
