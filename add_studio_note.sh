#!/usr/bin/env bash
set -euo pipefail

python3 <<'PY'
from pathlib import Path
from datetime import datetime
import re
import shutil

path = Path("studio-work.html")

if not path.exists():
    raise SystemExit("ERROR: studio-work.html was not found")

text = path.read_text(encoding="utf-8")
stamp = datetime.now().strftime("%Y%m%d_%H%M%S")

backup = Path(
    f"studio-work.html.before_studio_note_{stamp}.bak"
)
shutil.copy2(path, backup)

css = r'''
/* STUDIO NOTE — BEGIN */
.studio-note-link{
  display:flex;
  justify-content:center;
  margin:12px auto 42px
}

.studio-note-button{
  border:0;
  border-bottom:1px solid rgba(217,188,130,.45);
  padding:8px 3px;
  color:var(--gold);
  background:transparent;
  font:inherit;
  font-size:11px;
  letter-spacing:3px;
  text-transform:uppercase;
  cursor:pointer
}

.studio-note-button:hover{
  color:#f0d9a5;
  border-bottom-color:var(--gold)
}

.studio-note-modal{
  position:fixed;
  inset:0;
  z-index:9999;
  display:none;
  align-items:center;
  justify-content:center;
  padding:24px;
  background:rgba(0,0,0,.82);
  backdrop-filter:blur(6px)
}

.studio-note-modal.is-open{
  display:flex
}

.studio-note-panel{
  position:relative;
  width:min(760px,100%);
  max-height:88vh;
  overflow-y:auto;
  padding:48px 52px;
  border:1px solid rgba(217,188,130,.38);
  border-radius:14px;
  background:
    radial-gradient(
      circle at top,
      #223746 0%,
      #10212c 48%,
      #071018 100%
    );
  box-shadow:0 24px 90px rgba(0,0,0,.75)
}

.studio-note-close{
  position:absolute;
  top:18px;
  right:20px;
  width:38px;
  height:38px;
  border:1px solid rgba(217,188,130,.28);
  border-radius:50%;
  color:var(--gold);
  background:rgba(0,0,0,.15);
  font-size:22px;
  line-height:1;
  cursor:pointer
}

.studio-note-close:hover{
  background:rgba(217,188,130,.08)
}

.studio-note-kicker{
  color:var(--muted);
  font-size:11px;
  letter-spacing:3px;
  text-transform:uppercase
}

.studio-note-panel h2{
  margin:12px 0 28px;
  color:var(--gold);
  font-size:clamp(32px,5vw,48px);
  line-height:1.05
}

.studio-note-panel p{
  margin:0 0 20px;
  color:rgba(220,226,230,.88);
  font-size:17px;
  line-height:1.75
}

.studio-note-panel blockquote{
  margin:28px 0;
  padding:22px 26px;
  border-left:2px solid var(--gold);
  color:#f0dfbd;
  background:rgba(217,188,130,.05);
  font-size:19px;
  font-weight:650;
  line-height:1.65
}

.studio-note-list{
  margin:25px 0;
  color:rgba(220,226,230,.9);
  font-size:18px;
  line-height:2
}

.studio-note-signature{
  margin-top:34px;
  color:var(--gold)
}

body.studio-note-open{
  overflow:hidden
}

@media(max-width:620px){
  .studio-note-modal{
    padding:12px
  }

  .studio-note-panel{
    max-height:92vh;
    padding:42px 26px 34px
  }

  .studio-note-panel p{
    font-size:16px
  }

  .studio-note-panel blockquote{
    padding:18px;
    font-size:17px
  }
}
/* STUDIO NOTE — END */
'''.strip()

html = r'''
<div class="studio-note-link">
  <button
    class="studio-note-button"
    type="button"
    id="openStudioNote"
    aria-haspopup="dialog"
    aria-controls="studioNoteModal">
    Studio Note
  </button>
</div>

<div
  class="studio-note-modal"
  id="studioNoteModal"
  role="dialog"
  aria-modal="true"
  aria-labelledby="studioNoteTitle"
  aria-hidden="true">

  <article class="studio-note-panel">
    <button
      class="studio-note-close"
      type="button"
      id="closeStudioNote"
      aria-label="Close Studio Note">
      &times;
    </button>

    <div class="studio-note-kicker">
      Studio Oddscape
    </div>

    <h2 id="studioNoteTitle">Studio Note</h2>

    <p>
      Oddscape is a terrain interpretation platform.
    </p>

    <p>
      It combines LiDAR, elevation data, bathymetry and
      digital landscape analysis to help reveal the character
      and structure of place.
    </p>

    <p>
      Studio Oddscape is something different.
    </p>

    <p>
      It is where some of those terrain studies continue their
      journey beyond analysis. Here, landscapes become finished
      visual work—prints, compositions and interpretations
      developed from the same terrain models that support
      research, heritage, planning and education.
    </p>

    <p>
      People occasionally ask whether the work is art.
    </p>

    <p>
      That is not for us to declare.
    </p>

    <p>
      We are simply making things.
    </p>

    <blockquote>
      “It’s stuff. Stick it on your wall. Enjoy it. It might be
      expensive stuff, but it’s still just stuff. Collect it if
      you want—I’ll be making more.”
    </blockquote>

    <p>
      The same terrain model may help explain an archaeological
      landscape, support environmental interpretation, become
      part of an educational resource, or evolve into a finished
      visual composition. The process is the same; only the
      destination changes.
    </p>

    <p>
      Like a camera, Oddscape is a tool. It records and
      interprets the landscape. What follows depends upon
      purpose, curiosity and imagination.
    </p>

    <div class="studio-note-list">
      Some visitors will see science.<br>
      Some will see cartography.<br>
      Some will see design.<br>
      Some may see art.
    </div>

    <p>
      That judgement belongs to the viewer.
    </p>

    <p>
      Studio Oddscape’s role is simply to reveal the landscape
      and allow others to see it differently.
    </p>

    <div class="studio-note-signature">
      <strong>Duncan Fraser</strong><br>
      Founder, Studio Oddscape
    </div>
  </article>
</div>
'''.strip()

javascript = r'''
<script id="studioNoteScript">
(function(){
  const modal = document.getElementById("studioNoteModal");
  const openButton = document.getElementById("openStudioNote");
  const closeButton = document.getElementById("closeStudioNote");

  if (!modal || !openButton || !closeButton) return;

  function openNote(){
    modal.classList.add("is-open");
    modal.setAttribute("aria-hidden", "false");
    document.body.classList.add("studio-note-open");
    closeButton.focus();
  }

  function closeNote(){
    modal.classList.remove("is-open");
    modal.setAttribute("aria-hidden", "true");
    document.body.classList.remove("studio-note-open");
    openButton.focus();
  }

  openButton.addEventListener("click", openNote);
  closeButton.addEventListener("click", closeNote);

  modal.addEventListener("click", function(event){
    if (event.target === modal) closeNote();
  });

  document.addEventListener("keydown", function(event){
    if (
      event.key === "Escape" &&
      modal.classList.contains("is-open")
    ){
      closeNote();
    }
  });
})();
</script>
'''.strip()

css_pattern = re.compile(
    r"/\* STUDIO NOTE — BEGIN \*/.*?"
    r"/\* STUDIO NOTE — END \*/",
    re.DOTALL
)

html_pattern = re.compile(
    r'<div class="studio-note-link">.*?'
    r'<div\s+class="studio-note-modal".*?</div>\s*</div>',
    re.DOTALL
)

script_pattern = re.compile(
    r'<script id="studioNoteScript">.*?</script>',
    re.DOTALL
)

# Add or replace the CSS.
if css_pattern.search(text):
    text = css_pattern.sub(css, text)
else:
    text, count = re.subn(
        r"</style>",
        css + "\n</style>",
        text,
        count=1,
        flags=re.IGNORECASE
    )
    if count == 0:
        raise SystemExit("ERROR: No </style> tag found")

# Add or replace the modal immediately before the footer.
if 'id="studioNoteModal"' in text:
    text = html_pattern.sub(html, text, count=1)
else:
    text, count = re.subn(
        r"<footer\b",
        html + "\n<footer",
        text,
        count=1,
        flags=re.IGNORECASE
    )
    if count == 0:
        raise SystemExit("ERROR: No <footer> tag found")

# Add or replace the JavaScript before </body>.
if script_pattern.search(text):
    text = script_pattern.sub(javascript, text)
else:
    text, count = re.subn(
        r"</body>",
        javascript + "\n</body>",
        text,
        count=1,
        flags=re.IGNORECASE
    )
    if count == 0:
        raise SystemExit("ERROR: No </body> tag found")

path.write_text(text, encoding="utf-8")

print("Studio Note added to studio-work.html")
print(f"Backup created: {backup.name}")
print("Nothing has been committed or pushed.")
PY
