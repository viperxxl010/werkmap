# Teaser — "Voorbij de prompt" (Aigenwijs × C-day / Logeion)

Programmatisch gerenderde teaservideo voor het optreden van **Aigenwijs**
(Eric Kalsbeek & Luke Andries) op **C-day 2026** (het communicatiecongres van
Logeion). De video is volledig in code opgebouwd — geen losse videobeelden —
in de **echte Aigenwijs-huisstijl**: groen-zwart canvas, **mint-groen** als
kernwoord-accent, **merkpaars** als "AI-laag", en het echte aigenwijs-logo op
de titelkaart.

Concept: **groen = de menselijke/waarde-woorden, paars = de AI**
(skills-netwerk, "Volledig AI", logo).

## Eindresultaat
`teaser_voorbij_de_prompt.mp4` — **20 s · 1080×1920 (9:16) · 30 fps · ~18 MB**
met audiobed. Geschikt voor LinkedIn / Instagram / Stories & Reels.

## Storyboard (20 s)
| t (s) | Scene | Kern |
|------|-------|------|
| 0–3   | Prompt | getypte prompt `"schrijf even een tekstje"` → doorgestreept → *losse prompts.* |
| 3–5.2 | Statement | "De meesten blijven hangen in **prompts**." |
| 5.2–7.4 | Kanteling | "Maar er is al **veel meer mogelijk**." |
| 7.4–10.4 | **SKILLS** | geen prompt — een skill · kent jouw werkwijze · snapt jouw huisstijl · denkt mét je team mee |
| 10.4–12.6 | Context | "**Context is alles.**" — de belangrijkste les |
| 12.6–15.8 | Team | "Wat als skills samenwerken?" → AI-agent-netwerk → "Eén communicatieteam. **Volledig AI**." |
| 15.8–17.4 | Riser | flash-opbouw: *voorbij · de · prompt* |
| 17.4–20 | Titelkaart | **VOORBIJ DE PROMPT** · aigenwijs · Eric Kalsbeek · Luke Andries · C-day 2026 · *kom het zélf zien* |

Kernwoorden die nieuwsgierig maken: *prompt → skills → context is alles →
AI-communicatieteam → voorbij de prompt.*

## Opnieuw renderen
```bash
pip install Pillow imageio-ffmpeg numpy
python3 render.py     # -> teaser_voorbij_de_prompt_silent.mp4 (600 frames)
python3 audio.py      # genereert audiobed + muxt -> teaser_voorbij_de_prompt.mp4
```
Snelle visuele check zonder volledige render: `python3 render.py --keyframes`
(schrijft previews naar `keyframes/`).

## Huisstijl (echte merkkleuren)
De look zit in losse tokens bovenin `render.py`:
```python
GREEN  = (118, 249, 161)  # #76F9A1  mint-accent / kernwoorden ("wérkt")
PURPLE = (113,   0, 246)  # #7100F6  merkpaars / AI-laag / logo
INK    = (245, 247, 245)  # wit
BG_TOP = (9, 17, 13); BG_BOT = (3, 6, 6)   # groen-zwart canvas
F_DISPLAY = ".../BricolageGrotesque-Bold.ttf"
F_MONO    = ".../JetBrainsMono-Regular.ttf"
```
Het logo (`assets_logo.png`, transparant) wordt op de titelkaart geplaatst.
Het lettertype is nu Bricolage Grotesque; lever je het huisstijl-font aan, dan
swap ik `F_DISPLAY`.

## Let op
- **Geen foto's** verwerkt (op jouw verzoek / de C-day-site blokkeerde
  geautomatiseerde toegang). Sprekersfoto's kunnen later in de titel-/teamscene.
- Inhoud van de sessie is verwerkt zoals door jou aangeleverd.
