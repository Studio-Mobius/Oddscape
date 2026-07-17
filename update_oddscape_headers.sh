#!/usr/bin/env bash
set -euo pipefail

python3 <<'PY'
from pathlib import Path
import re
import shutil
from datetime import datetime

root = Path.home() / "Oddscape/GitHub/oddscape"
stamp = datetime.now().strftime("%Y%m%d_%H%M%S")

pages = {
    "index.html": """
<nav>
  <a href="archive.html">Terrain Archive</a>
  <a href="commissions.html">Commissions</a>
  <a href="start.html">Start a Project</a>
  <a href="faq.html">FAQ</a>
</nav>
""",

    "archive.html": """
<nav>
  <a href="commissions.html">Commissions</a>
  <a href="start.html">Start a Project</a>
  <a href="faq.html">FAQ</a>
</nav>
""",

    "commissions.html": """
<nav>
  <a href="archive.html">Terrain Archive</a>
  <a href="start.html">Start a Project</a>
  <a href="faq.html">FAQ</a>
</nav>
""",

    "start.html": """
<nav>
  <a href="archive.html">Terrain Archive</a>
  <a href="commissions.html">Commissions</a>
  <a href="faq.html">FAQ</a>
</nav>
""",

    "faq.html": """
<nav>
  <a href="archive.html">Terrain Archive</a>
  <a href="commissions.html">Commissions</a>
  <a href="start.html">Start a Project</a>
</nav>
"""
}

header = """
<header>
  <a href="index.html" class="logo">Studio Oddscape</a>

  <div class="subtitle">
    Terrain Visualisation // Commissioned Landscape Interpretation
  </div>

  <div class="hud">
    <span class="hud-marker">
      <svg viewBox="0 0 24 24" aria-hidden="true">
        <circle cx="12" cy="12" r="7"/>
        <path d="M12 8v8"/>
        <path d="M8 12h8"/>
      </svg>
    </span>
  </div>
</header>
"""

css = """
/* ODDSCAPE STANDARD HEADER — BEGIN */
header {
  text-align: center;
  padding: 55px 40px 30px;
}

.logo {
  display: block;
  font-size: clamp(42px, 8vw, 74px);
  font-weight: 800;
  color: var(--gold);
  line-height: .95;
  text-decoration: none;
}

.subtitle {
  margin-top: 18px;
  font-size: 13px;
  letter-spacing: 6px;
  color: rgba(220, 226, 230, .75);
  text-transform: none;
}

.hud {
  width: 520px;
  max-width: 80%;
  height: 24px;
  margin: 22px auto;
  position: relative;
}

.hud::before,
.hud::after {
  content: "";
  position: absolute;
  top: 50%;
  width: calc(50% - 24px);
  height: 1px;
}

.hud::before {
  left: 0;
  background: linear-gradient(
    90deg,
    transparent,
    rgba(217, 188, 130, .55)
  );
}

.hud::after {
  right: 0;
  background: linear-gradient(
    90deg,
    rgba(217, 188, 130, .55),
    transparent
  );
}

.hud-marker {
  position: absolute;
  left: 50%;
  top: 50%;
  width: 22px;
  height: 22px;
  transform: translate(-50%, -50%);
}

.hud-marker svg {
  width: 100%;
  height: 100%;
  fill: none;
  stroke: var(--gold);
  stroke-width: 1.4;
  stroke-linecap: round;
}

nav {
  display: flex;
  justify-content: center;
  align-items: stretch;
  flex-wrap: nowrap;
  width: 100%;
  border-top: 1px solid rgba(255, 255, 255, .06);
  border-bottom: 1px solid rgba(255, 255, 255, .06);
}

nav a {
  flex: 1 1 0;
  max-width: 210px;
  min-width: 0;
  padding: 16px 8px;
  border-right: 1px solid var(--line);
  color: var(--text);
  text-align: center;
  text-decoration: none;
  white-space: nowrap;
  font-size: clamp(9px, 1.6vw, 14px);
}

nav a:last-child {
  border-right: none;
}

nav a:hover {
  color: var(--gold);
}

@media (max-width: 700px) {
  header {
    padding: 36px 20px 22px;
  }

  .logo {
    font-size: clamp(40px, 10vw, 58px);
  }

  .subtitle {
    font-size: 10px;
    letter-spacing: 3px;
  }

  .hud {
    margin: 20px auto;
  }

  nav a {
    padding: 14px 4px;
    font-size: clamp(9px, 2.5vw, 12px);
    letter-spacing: 0;
  }
}

@media (min-width: 701px) and (max-width: 900px) {
  .logo {
    font-size: 64px;
  }

  nav a {
    font-size: 13px;
    padding-left: 10px;
    padding-right: 10px;
  }
}
/* ODDSCAPE STANDARD HEADER — END */
"""

css_pattern = re.compile(
    r"/\* ODDSCAPE STANDARD HEADER — BEGIN \*/.*?"
    r"/\* ODDSCAPE STANDARD HEADER — END \*/",
    re.DOTALL
)

for filename, navigation in pages.items():
    path = root / filename

    if not path.exists():
        print(f"SKIPPED: {filename} was not found")
        continue

    original = path.read_text(encoding="utf-8")
    updated = original

    backup = path.with_name(f"{path.name}.before_header_{stamp}.bak")
    shutil.copy2(path, backup)

    updated, header_count = re.subn(
        r"<header\b[^>]*>.*?</header>",
        header.strip(),
        updated,
        count=1,
        flags=re.DOTALL | re.IGNORECASE
    )

    updated, nav_count = re.subn(
        r"<nav\b[^>]*>.*?</nav>",
        navigation.strip(),
        updated,
        count=1,
        flags=re.DOTALL | re.IGNORECASE
    )

    if css_pattern.search(updated):
        updated = css_pattern.sub(css.strip(), updated)
    else:
        updated, style_count = re.subn(
            r"</style>",
            css.strip() + "\n</style>",
            updated,
            count=1,
            flags=re.IGNORECASE
        )

        if style_count == 0:
            print(f"WARNING: no </style> found in {filename}")

    if header_count == 0:
        print(f"WARNING: no <header> block found in {filename}")

    if nav_count == 0:
        print(f"WARNING: no <nav> block found in {filename}")

    path.write_text(updated, encoding="utf-8")
    print(f"UPDATED: {filename}")
    print(f"BACKUP:  {backup.name}")

print("\nFinished. Nothing has been committed or uploaded.")
PY
