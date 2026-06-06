# Teaser — "Voorbij de prompt" (Aigenwijs × C-day / Logeion)

Programmatisch gerenderde teaservideo voor het optreden van **Aigenwijs**
(Eric Kalsbeek & Luke Andries) op **C-day 2026** (het communicatiecongres van
Logeion). De video is volledig in code opgebouwd — geen losse videobeelden —
en in de Aigenwijs-stijl: donker, eigenwijs canvas met een electric-lime accent.

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

## Huisstijl aanpassen
De look zit in losse tokens bovenin `render.py` — makkelijk te vervangen door
de exacte Aigenwijs-merkkleuren/-fonts zodra die beschikbaar zijn:
```python
LIME = (201, 249, 78)   # accent / kernwoorden
INK  = (244, 242, 233)  # tekst
GLOW_VIO = (124,108,255) # gloed
F_DISPLAY = ".../BricolageGrotesque-Bold.ttf"
F_MONO    = ".../JetBrainsMono-Regular.ttf"
```

## Let op
- De huidige stijl is een **opgebouwde Aigenwijs-look**; de officiële
  huisstijl-skill was in deze omgeving niet beschikbaar. Lever je de exacte
  merk-tokens (hex-kleuren, logo, fonts) aan, dan slijp ik 'm 1-op-1 bij.
- Er zijn **geen foto's** van de C-day-site verwerkt (site blokkeerde
  geautomatiseerde toegang). Sprekersfoto's kunnen in de titel-/teamscene
  worden ingepast zodra je ze aanlevert.
- Inhoud van de sessie is verwerkt zoals door jou aangeleverd.
