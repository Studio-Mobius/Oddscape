#!/usr/bin/env bash
set -euo pipefail

python3 <<'PY'
from pathlib import Path
from datetime import datetime
import re
import shutil

root = Path.home() / "Oddscape/GitHub/oddscape"
master_path = root / "studio-work.html"

targets = [
    root / "index.html",
    root / "archive.html",
    root / "commissions.html",
    root / "start.html",
    root / "faq.html",
]

if not master_path.exists():
    raise SystemExit(
        "ERROR: studio-work.html was not found in "
        "~/Oddscape/GitHub/oddscape"
    )

master = master_path.read_text(encoding="utf-8")

# Extract the complete header HTML from Studio Work.
header_match = re.search(
    r"<header\b[^>]*>.*?</header>",
    master,
    flags=re.DOTALL | re.IGNORECASE
)

if not header_match:
    raise SystemExit("ERROR: Could not find the header in studio-work.html")

master_header = header_match.group(0)

# Exact Studio Work header/HUD/navigation CSS.
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
  flex-wrap:nowrap;
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
  nav a{
    padding:13px 10px;
    font-size:10px;
    letter-spacing:1px
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

for path in targets:
    if not path.exists():
        print(f"SKIPPED: {path.name} not found")
        continue

    text = path.read_text(encoding="utf-8")

    backup = path.with_name(
        f"{path.name}.before_hud_restore_{stamp}.bak"
    )
    shutil.copy2(path, backup)

    # Replace header HTML only. Navigation HTML remains untouched.
    text, header_count = re.subn(
        r"<header\b[^>]*>.*?</header>",
        master_header,
        text,
        count=1,
        flags=re.DOTALL | re.IGNORECASE
    )

    if header_count == 0:
        print(f"WARNING: no header found in {path.name}")

    # Replace the CSS block previously inserted by our scripts.
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
            print(f"WARNING: no </style> found in {path.name}")

    path.write_text(text, encoding="utf-8")

    print(f"UPDATED: {path.name}")
    print(f"BACKUP:  {backup.name}")

print()
print("Finished. Nothing has been committed or pushed.")
PY
