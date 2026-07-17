#!/usr/bin/env bash
set -e

python3 <<'PY'
from pathlib import Path
import shutil
from datetime import datetime

page = Path("studio-work.html")

backup = page.with_name(
    f"studio-work_before_studionote_{datetime.now().strftime('%Y%m%d_%H%M%S')}.bak"
)

shutil.copy2(page, backup)

html = page.read_text()

css = """
<style id="studio-note-style">

.studio-note-button{
display:inline-block;
margin:40px auto;
padding:12px 24px;
background:none;
border:1px solid rgba(217,188,130,.45);
color:var(--gold);
letter-spacing:2px;
text-transform:uppercase;
cursor:pointer;
}

.studio-note-button:hover{
background:rgba(217,188,130,.08);
}

.studio-note-overlay{
display:none;
position:fixed;
left:0;
top:0;
width:100%;
height:100%;
background:rgba(0,0,0,.85);
z-index:9999;
}

.studio-note-window{
max-width:760px;
margin:5vh auto;
padding:40px;
background:#10212c;
border:1px solid rgba(217,188,130,.35);
max-height:90vh;
overflow:auto;
color:#dce3e8;
}

.studio-note-window h2{
color:var(--gold);
margin-bottom:20px;
}

.studio-note-window blockquote{
margin:30px;
padding-left:20px;
border-left:2px solid var(--gold);
font-style:italic;
color:#f0dfbd;
}

.close-note{
float:right;
cursor:pointer;
font-size:28px;
color:var(--gold);
}

</style>
"""

button = """
<div style="text-align:center">
<button class="studio-note-button" onclick="document.getElementById('studioNote').style.display='block'">
Studio Note
</button>
</div>

<div id="studioNote" class="studio-note-overlay">

<div class="studio-note-window">

<div class="close-note"
onclick="document.getElementById('studioNote').style.display='none'">
&times;
</div>

<h2>Studio Note 001</h2>

<p><strong>It's Stuff.</strong></p>

<p>People occasionally ask whether the work is art.</p>

<p>That is not for us to declare.</p>

<p>We are simply making things.</p>

<blockquote>

"It's stuff.

Stick it on your wall.

Enjoy it.

It might be expensive stuff,

but it's still just stuff.

Collect it if you want...

I'll be making more."

</blockquote>

<p>
Oddscape is a terrain interpretation platform.
Studio Oddscape is where some of those terrain
studies continue their journey beyond analysis.
</p>

<p>
Like a camera, Oddscape is a tool.
It records and interprets the landscape.
What follows depends upon purpose,
curiosity and imagination.
</p>

<p>

Some visitors will see science.<br>
Some will see cartography.<br>
Some will see design.<br>
Some may see art.

</p>

<p>

That judgement belongs to the viewer.

</p>

<hr>

<p>

<b>Duncan Fraser</b><br>

Founder<br>

Studio Oddscape

</p>

</div>

</div>
"""

if "studio-note-style" not in html:
    html = html.replace("</head>", css + "\n</head>")

if "Studio Note 001" not in html:
    html = html.replace("<footer>", button + "\n<footer>")

page.write_text(html)

print("Studio Note MKI installed.")
print(f"Backup: {backup.name}")
PY

echo
echo "Done."
