#!/usr/bin/env python3
from pathlib import Path
import re
import shutil

ROOT = Path.cwd()
INDEX = ROOT / "index.html"

if not INDEX.exists():
    raise SystemExit("Run this from ~/Oddscape/GitHub/oddscape")

backup = ROOT / "index_before_nav_and_invite_fix.html"
if not backup.exists():
    shutil.copy2(INDEX, backup)

html = INDEX.read_text(encoding="utf-8")

nav_match = re.search(r'(<nav\b[^>]*>)(.*?)(</nav>)', html, flags=re.I | re.S)
if not nav_match:
    raise SystemExit("Could not find the top navigation.")

nav_open, nav_body, nav_close = nav_match.groups()

if not re.search(r'>\s*Start a Project\s*</a>', nav_body, flags=re.I):
    start_link = '\n  <a href="start.html">Start a Project</a>'
    faq_match = re.search(r'<a\b[^>]*>\s*FAQ\s*</a>', nav_body, flags=re.I)
    if faq_match:
        nav_body = nav_body[:faq_match.start()] + start_link + '\n  ' + nav_body[faq_match.start():]
    else:
        nav_body = nav_body.rstrip() + start_link + '\n'

new_nav = nav_open + nav_body + nav_close
html = html[:nav_match.start()] + new_nav + html[nav_match.end():]

nav_match = re.search(r'(<nav\b[^>]*>.*?</nav>)', html, flags=re.I | re.S)
nav_html = nav_match.group(1)
before_nav = html[:nav_match.start()]
after_nav = html[nav_match.end():]

after_nav = re.sub(
    r'\s*<a\b[^>]*>\s*Start a Project\s*</a>',
    '',
    after_nav,
    flags=re.I
)

html = before_nav + nav_html + after_nav

invite_match = re.search(
    r'\s*<section\b[^>]*class="[^"]*\boddscape-final-invite\b[^"]*"[^>]*>.*?</section>',
    html,
    flags=re.I | re.S
)

if invite_match:
    invite_html = invite_match.group(0).strip()
    html = html[:invite_match.start()] + html[invite_match.end():]
else:
    invite_html = '''<section class="oddscape-final-invite" aria-label="Explore Oddscape">
  <p>Here's the terrain.</p>
  <p>Here's what we do.</p>
  <p>Here's how to commission us.</p>
  <strong>Now, go and explore.</strong>
</section>'''

commission_text = re.search(r'Commission a Terrain Study', html, flags=re.I)
if not commission_text:
    raise SystemExit("Could not find the Commission a Terrain Study block.")

def find_enclosing_block_end(source: str, pos: int):
    candidates = []
    for tag in ("section", "article", "div"):
        for match in re.finditer(rf'<{tag}\b[^>]*>', source[:pos], flags=re.I):
            candidates.append((match.start(), tag))
    if not candidates:
        return None

    start, tag = max(candidates, key=lambda item: item[0])
    token_re = re.compile(rf'</?{tag}\b[^>]*>', flags=re.I)
    depth = 0

    for token in token_re.finditer(source, start):
        if token.group(0).startswith("</"):
            depth -= 1
            if depth == 0:
                return token.end()
        else:
            depth += 1
    return None

block_end = find_enclosing_block_end(html, commission_text.start())
if block_end is None:
    raise SystemExit("Could not locate the end of the commission block.")

html = html[:block_end] + "\n\n" + invite_html + "\n" + html[block_end:]

css = '''
/* Navigation and invitation placement fix */
nav{
  display:grid !important;
  grid-template-columns:repeat(4,minmax(0,1fr)) !important;
  align-items:stretch !important;
}
nav a{
  display:flex !important;
  align-items:center !important;
  justify-content:center !important;
  min-width:0 !important;
  padding:18px 10px !important;
  text-align:center !important;
  line-height:1.25 !important;
}
@media (max-width:640px){
  nav{
    grid-template-columns:repeat(2,minmax(0,1fr)) !important;
  }
}
.oddscape-final-invite{
  margin-top:34px !important;
  margin-bottom:34px !important;
}
'''

if "Navigation and invitation placement fix" not in html:
    style_end = html.find("</style>")
    if style_end == -1:
        raise SystemExit("Could not find </style> in index.html")
    html = html[:style_end] + css + "\n" + html[style_end:]

INDEX.write_text(html, encoding="utf-8")

print("Navigation and invitation placement fixed.")
print("Backup:", backup)
print("Changed:")
print(" - Start a Project restored to the top navigation")
print(" - duplicate standalone Start a Project button removed")
print(" - final invitation moved directly after Commission a Terrain Study")
