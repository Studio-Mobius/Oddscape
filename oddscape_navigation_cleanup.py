#!/usr/bin/env python3
from pathlib import Path
import re
import shutil

ROOT = Path.cwd()
INDEX = ROOT / "index.html"

if not INDEX.exists():
    raise SystemExit("Run this from ~/Oddscape/GitHub/oddscape")

backup = ROOT / "index_before_navigation_cleanup.html"
if not backup.exists():
    shutil.copy2(INDEX, backup)

html = INDEX.read_text(encoding="utf-8")

html = re.sub(
    r'\s*<a\b[^>]*class="[^"]*\boddscape-lower-cta\b[^"]*"[^>]*>\s*Browse Archive\s*</a>',
    '', html, count=1, flags=re.I
)
html = re.sub(
    r'\s*<a\b[^>]*class="[^"]*\boddscape-lower-cta\b[^"]*"[^>]*>\s*Start a Project\s*</a>',
    '', html, count=1, flags=re.I
)

nav_css = r'''
/* Oddscape navigation cleanup */
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
  nav{grid-template-columns:repeat(2,minmax(0,1fr)) !important;}
}
'''
if "Oddscape navigation cleanup" not in html:
    pos = html.find("</style>")
    if pos == -1:
        raise SystemExit("Could not find </style> in index.html")
    html = html[:pos] + nav_css + "\n" + html[pos:]

explore_css = r'''
.oddscape-final-invite{
  max-width:760px;
  margin:54px auto 42px;
  padding:30px 24px;
  text-align:center;
  border-top:1px solid rgba(217,188,130,.22);
  border-bottom:1px solid rgba(217,188,130,.22);
}
.oddscape-final-invite p{
  margin:5px 0;
  color:rgba(238,244,248,.82);
  font-size:clamp(1rem,2.2vw,1.22rem);
}
.oddscape-final-invite strong{
  display:block;
  margin-top:16px;
  color:var(--gold);
  font-size:clamp(1.25rem,3vw,1.8rem);
  letter-spacing:.03em;
}
'''
if ".oddscape-final-invite{" not in html:
    pos = html.find("</style>")
    html = html[:pos] + explore_css + "\n" + html[pos:]

explore_block = r'''
<section class="oddscape-final-invite" aria-label="Explore Oddscape">
  <p>Here's the terrain.</p>
  <p>Here's what we do.</p>
  <p>Here's how to commission us.</p>
  <strong>Now, go and explore.</strong>
</section>
'''
if 'class="oddscape-final-invite"' not in html:
    footer_pos = html.find("<footer")
    if footer_pos == -1:
        footer_pos = html.rfind("</body>")
    if footer_pos == -1:
        raise SystemExit("Could not find footer or </body>")
    html = html[:footer_pos] + explore_block + "\n" + html[footer_pos:]

INDEX.write_text(html, encoding="utf-8")

print("Oddscape navigation cleanup installed.")
print("Backup:", backup)
print("Changed:")
print(" - top navigation restored to four equal items")
print(" - duplicated lower Browse Archive button removed")
print(" - duplicated lower Start a Project button removed")
print(" - final 'Now, go and explore.' invitation added")
