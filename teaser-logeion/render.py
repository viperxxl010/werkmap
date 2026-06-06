#!/usr/bin/env python3
"""
Aigenwijs teaser — "Voorbij de prompt" (C-day / Logeion 2026)
Programmatisch gerenderde 20-seconden teaser (1080x1920, 30fps) als MP4.

Huisstijl (echte aigenwijs-merkkleuren, tokens hieronder):
  - Groen-zwart canvas met groene + paarse gloed
  - Mint-groen (#76F9A1) als primair kernwoord-accent ("wérkt")
  - Merkpaars (#7100F6) als AI-laag + logo
  - Echte aigenwijs-logo op de titelkaart
  - Bricolage Grotesque (display) + JetBrains Mono ("prompt"-feel) + Instrument Sans (body)
"""
import math, os, sys
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import imageio_ffmpeg

# ----------------------------------------------------------------------------- config
W, H = 1080, 1920
FPS = 30
DUR = 20.0
N = int(round(DUR * FPS))
OUT_DIR = os.path.dirname(os.path.abspath(__file__))
FONT_DIR = "/mnt/skills/examples/canvas-design/canvas-fonts"

# ---- huisstijl tokens (echte aigenwijs-merkkleuren) -------------------------
BG_TOP   = (9, 17, 13)          # groen-zwart canvas
BG_BOT   = (3, 6, 6)
GLOW_GRN = (118, 249, 161)      # groene gloed (mint)
GLOW_PUR = (113, 0, 246)        # paarse gloed (merkpaars)
INK      = (245, 247, 245)      # wit
MUTED    = (138, 150, 145)
GREEN    = (118, 249, 161)      # primair accent / kernwoorden ("wérkt")
GREEN_DK = (70, 200, 120)
PURPLE   = (113, 0, 246)        # merkpaars (logo / AI-laag)
RED      = (255, 96, 84)        # (ongebruikt)
LOGO_PATH = f"{OUT_DIR}/assets_logo.png"

F_DISPLAY = f"{FONT_DIR}/BricolageGrotesque-Bold.ttf"
F_DISP_RG = f"{FONT_DIR}/BricolageGrotesque-Regular.ttf"
F_MONO    = f"{FONT_DIR}/JetBrainsMono-Regular.ttf"
F_MONO_B  = f"{FONT_DIR}/JetBrainsMono-Bold.ttf"
F_BODY    = f"{FONT_DIR}/InstrumentSans-Regular.ttf"
F_BODY_B  = f"{FONT_DIR}/InstrumentSans-Bold.ttf"

# ----------------------------------------------------------------------------- helpers
_font_cache = {}
def font(path, size):
    k = (path, int(size))
    if k not in _font_cache:
        _font_cache[k] = ImageFont.truetype(path, int(size))
    return _font_cache[k]

def clamp(x, a=0.0, b=1.0): return max(a, min(b, x))
def lerp(a, b, t): return a + (b - a) * t
def mix(c1, c2, t):
    return tuple(int(round(lerp(c1[i], c2[i], t))) for i in range(3))

def ease_out_cubic(t): t = clamp(t); return 1 - (1 - t) ** 3
def ease_out_quint(t): t = clamp(t); return 1 - (1 - t) ** 5
def ease_in_out(t):
    t = clamp(t)
    return 3 * t * t - 2 * t * t * t
def ease_out_back(t, s=1.7):
    t = clamp(t); t -= 1
    return 1 + (s + 1) * t ** 3 + s * t ** 2

def win(t, t0, t1, fin=0.35, fout=0.35):
    """alpha 0..1 met fade-in/out binnen [t0,t1]."""
    if t < t0 or t > t1: return 0.0
    a = 1.0
    if t < t0 + fin: a = min(a, ease_in_out((t - t0) / fin))
    if t > t1 - fout: a = min(a, ease_in_out((t1 - t) / fout))
    return clamp(a)

def appear(t, t0, dur):
    if t <= t0: return 0.0
    return clamp((t - t0) / dur)

# ----------------------------------------------------------------------------- background
def build_base():
    yy = np.linspace(0, 1, H)[:, None]
    grad = np.zeros((H, W, 3), np.float32)
    for i in range(3):
        grad[:, :, i] = lerp(BG_TOP[i], BG_BOT[i], 1.0)  # placeholder
    # vertical gradient
    for i in range(3):
        grad[:, :, i] = BG_TOP[i] * (1 - yy[:, 0])[:, None] + BG_BOT[i] * yy[:, 0][:, None]
    Y, X = np.mgrid[0:H, 0:W].astype(np.float32)
    # groene radiale gloed (boven-midden)
    dg = np.sqrt((X - W * 0.5) ** 2 + (Y - H * 0.30) ** 2)
    glow_g = np.clip(1 - dg / (W * 0.95), 0, 1) ** 2.4
    # paarse gloed (onder, AI-laag)
    dp = np.sqrt((X - W * 0.5) ** 2 + (Y - H * 0.80) ** 2)
    glow_p = np.clip(1 - dp / (W * 1.05), 0, 1) ** 2.6
    for i in range(3):
        grad[:, :, i] += GLOW_GRN[i] * 0.10 * glow_g + GLOW_PUR[i] * 0.085 * glow_p
    # subtiele vignette
    dv = np.sqrt(((X - W / 2) / (W / 2)) ** 2 + ((Y - H / 2) / (H / 2)) ** 2)
    vig = np.clip(1 - (dv - 0.6) * 0.55, 0.45, 1.0)
    grad *= vig[:, :, None]
    return np.clip(grad, 0, 255).astype(np.float32)

BASE = build_base()

# logo (RGBA, transparant, merkpaars) — geschaald geladen
_LOGO_RAW = Image.open(LOGO_PATH).convert("RGBA")
def logo_scaled(width):
    w = int(width); h = int(round(w * _LOGO_RAW.height / _LOGO_RAW.width))
    return _LOGO_RAW.resize((w, h), Image.LANCZOS)

# grain tiles
rng = np.random.default_rng(7)
GRAIN = [(rng.standard_normal((H, W, 1)) * 5.0).astype(np.float32) for _ in range(14)]

def new_frame(idx):
    arr = BASE + GRAIN[idx % len(GRAIN)]
    img = Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8), "RGB").convert("RGBA")
    return img

# ----------------------------------------------------------------------------- text
def text_center(draw, xy, s, fnt, fill, a=1.0):
    r, g, b = fill
    draw.text(xy, s, font=fnt, fill=(r, g, b, int(255 * clamp(a))), anchor="mm")

def text_anchor(draw, xy, s, fnt, fill, a=1.0, anchor="mm"):
    r, g, b = fill
    draw.text(xy, s, font=fnt, fill=(r, g, b, int(255 * clamp(a))), anchor=anchor)

def tracked_width(draw, s, fnt, tr):
    return sum(draw.textlength(ch, font=fnt) for ch in s) + tr * (len(s) - 1)

def text_tracked(draw, cx, cy, s, fnt, fill, tr=0, a=1.0):
    r, g, b = fill
    col = (r, g, b, int(255 * clamp(a)))
    tot = tracked_width(draw, s, fnt, tr)
    x = cx - tot / 2
    for ch in s:
        draw.text((x, cy), ch, font=fnt, fill=col, anchor="lm")
        x += draw.textlength(ch, font=fnt) + tr

def glow_text(img, cx, cy, s, fnt, color, a=1.0, blur=22, grow=1.0, tracked=False, tr=0):
    """Draw a soft glow behind a word."""
    if a <= 0.01: return img
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    col = (color[0], color[1], color[2], int(200 * clamp(a) * grow))
    if tracked:
        tot = tracked_width(d, s, fnt, tr); x = cx - tot / 2
        for ch in s:
            d.text((x, cy), ch, font=fnt, fill=col, anchor="lm")
            x += d.textlength(ch, font=fnt) + tr
    else:
        d.text((cx, cy), s, font=fnt, fill=col, anchor="mm")
    layer = layer.filter(ImageFilter.GaussianBlur(blur))
    return Image.alpha_composite(img, layer)

# multi-line helper (centered block)
def block(draw, cx, cy, lines, fnt, leading, default_fill, a=1.0):
    """lines: list of (text, fill) ; returns nothing. Vertically centered around cy."""
    n = len(lines)
    total = leading * (n - 1)
    y = cy - total / 2
    for s, fl in lines:
        text_center(draw, (cx, y), s, fnt, fl or default_fill, a)
        y += leading

# ----------------------------------------------------------------------------- persistent chrome
def draw_chrome(img, draw, t):
    # bovenbalk merk-tag (vanaf scene 2)
    a = win(t, 3.0, 19.4, 0.5, 0.4)
    if a > 0:
        text_anchor(draw, (70, 86), "AIGENWIJS", font(F_MONO_B, 30), GREEN, a * 0.9, "lm")
        text_anchor(draw, (W - 70, 86), "voorbij de prompt", font(F_MONO, 28), MUTED, a * 0.8, "rm")
    # voortgangsbalk onder
    pa = win(t, 0.4, 19.7, 0.4, 0.3)
    if pa > 0:
        y = H - 70
        draw.line([(70, y), (W - 70, y)], fill=(255, 255, 255, int(28 * pa)), width=3)
        px = 70 + (W - 140) * clamp(t / DUR)
        draw.line([(70, y), (px, y)], fill=(GREEN[0], GREEN[1], GREEN[2], int(220 * pa)), width=3)

# ----------------------------------------------------------------------------- scenes
def scene_prompt(img, draw, t):
    a = win(t, 0.0, 3.0, 0.5, 0.45)
    if a <= 0: return img
    cx = W / 2
    # label
    text_center(draw, (cx, H * 0.30), "[ anno 2026 ]", font(F_MONO, 34), GREEN, a * 0.85)
    # typewriter prompt
    full = '"schrijf even een tekstje"'
    chars = int(clamp((t - 0.45) / 1.25) * len(full))
    shown = full[:chars]
    prefix = "jij ▸ "
    fnt = font(F_MONO, 46)
    pw = draw.textlength(prefix, font=fnt)
    fw = draw.textlength(full, font=fnt)
    x0 = cx - (pw + fw) / 2
    y = H * 0.46
    text_anchor(draw, (x0, y), prefix, fnt, MUTED, a, "lm")
    text_anchor(draw, (x0 + pw, y), shown, fnt, INK, a, "lm")
    # knipperende cursor
    if t < 1.85 and int(t * 2) % 2 == 0:
        cxp = x0 + pw + draw.textlength(shown, font=fnt)
        draw.line([(cxp + 6, y - 30), (cxp + 6, y + 30)], fill=(GREEN[0], GREEN[1], GREEN[2], int(255 * a)), width=4)
    # strikethrough + label
    if t > 1.95:
        sp = ease_out_cubic((t - 1.95) / 0.5)
        xL = x0 + pw
        xR = xL + fw * sp
        draw.line([(xL, y), (xR, y)], fill=(PURPLE[0], PURPLE[1], PURPLE[2], int(255 * a)), width=7)
        la = clamp((t - 2.25) / 0.4)
        text_center(draw, (cx, H * 0.585), "losse prompts.", font(F_BODY, 50), MUTED, a * la)
    return img

def scene_statement2(img, draw, t):
    a = win(t, 3.05, 5.25, 0.4, 0.4)
    if a <= 0: return img
    p = ease_out_quint(appear(t, 3.05, 0.6))
    dy = (1 - p) * 60
    cx = W / 2; cy = H * 0.46 - dy
    f = font(F_DISPLAY, 104)
    text_center(draw, (cx, cy - 62), "De meesten blijven", f, INK, a)
    line2a = "hangen in "; line2b = "prompts."
    wA = draw.textlength(line2a, font=f); wB = draw.textlength(line2b, font=f)
    x0 = cx - (wA + wB) / 2; y2 = cy + 62
    text_anchor(draw, (x0, y2), line2a, f, INK, a, "lm")
    img2 = glow_text(img, x0 + wA + wB / 2, y2, line2b, f, GREEN, a * 0.7, blur=26)
    d2 = ImageDraw.Draw(img2)
    text_anchor(d2, (x0 + wA, y2), line2b, f, GREEN, a, "lm")
    return img2

def scene_turn(img, draw, t):
    a = win(t, 5.3, 7.45, 0.4, 0.4)
    if a <= 0: return img
    cx = W / 2; cy = H * 0.46
    f = font(F_DISPLAY, 104)
    text_center(draw, (cx, cy - 62), "Maar er is al", f, INK, a)
    p = ease_out_back(clamp((t - 5.55) / 0.55))
    sc = lerp(0.8, 1.0, clamp(p))
    fz = int(104 * sc)
    f2 = font(F_DISPLAY, fz)
    img2 = glow_text(img, cx, cy + 70, "veel meer mogelijk", f2, GREEN, a * 0.8 * clamp(p), blur=30)
    d2 = ImageDraw.Draw(img2)
    text_center(d2, (cx, cy + 70), "veel meer mogelijk", f2, GREEN, a)
    return img2

def scene_skills(img, draw, t):
    a = win(t, 7.5, 10.45, 0.4, 0.4)
    if a <= 0: return img
    cx = W / 2
    p = ease_out_quint(appear(t, 7.5, 0.55))
    fz = int(lerp(150, 210, p))
    f = font(F_DISPLAY, fz)
    yk = H * 0.34
    img = glow_text(img, cx, yk, "SKILLS", f, GREEN, a * (0.5 + 0.5 * p), blur=40, tracked=True, tr=10)
    draw = ImageDraw.Draw(img)
    text_tracked(draw, cx, yk, "SKILLS", f, GREEN, tr=10, a=a)
    text_center(draw, (cx, H * 0.45), "geen prompt — een skill", font(F_BODY_B, 50), INK, a * clamp((t - 7.9) / 0.4))
    items = ["kent jouw werkwijze", "snapt jouw huisstijl", "denkt mét je team mee"]
    y = H * 0.545
    for i, it in enumerate(items):
        ia = clamp((t - (8.4 + i * 0.45)) / 0.4)
        if ia <= 0: continue
        dx = (1 - ease_out_cubic(ia)) * 40
        fb = font(F_BODY, 48)
        wTot = 50 + draw.textlength(it, font=fb)
        x0 = cx - wTot / 2 - dx
        # driehoek-bullet (zelf getekend i.p.v. glyph)
        ty = y; ts = 15
        draw.polygon([(x0, ty - ts), (x0, ty + ts), (x0 + ts * 1.4, ty)],
                     fill=(GREEN[0], GREEN[1], GREEN[2], int(255 * a * ia)))
        text_anchor(draw, (x0 + 50, y), it, fb, INK, a * ia, "lm")
        y += 86
    return img

def scene_context(img, draw, t):
    a = win(t, 10.5, 12.65, 0.4, 0.4)
    if a <= 0: return img
    cx = W / 2; cy = H * 0.45
    f = font(F_DISPLAY, 118)
    text_center(draw, (cx, cy), "Context", f, INK, a)
    img2 = glow_text(img, cx, cy + 130, "is alles.", f, GREEN, a * 0.8, blur=30)
    d2 = ImageDraw.Draw(img2)
    text_center(d2, (cx, cy + 130), "is alles.", f, GREEN, a)
    # onderstreping sweep
    sw = ease_out_cubic(clamp((t - 10.8) / 0.6))
    wL = d2.textlength("is alles.", font=f)
    y = cy + 130 + 78
    d2.line([(cx - wL / 2, y), (cx - wL / 2 + wL * sw, y)], fill=(GREEN[0], GREEN[1], GREEN[2], int(220 * a)), width=7)
    text_center(d2, (cx, H * 0.60), "— de belangrijkste les", font(F_MONO, 36), MUTED, a * clamp((t - 11.0) / 0.4))
    return img2

def _nodes(cx, cy, R, k):
    pts = []
    for i in range(6):
        ang = -math.pi / 2 + i * (2 * math.pi / 6)
        pts.append((cx + R * math.cos(ang), cy + R * math.sin(ang) * 0.62))
    return pts

def scene_team(img, draw, t):
    a = win(t, 12.7, 15.85, 0.4, 0.45)
    if a <= 0: return img
    cx = W / 2
    # twee uitspraken
    if t < 14.15:
        aa = win(t, 12.7, 14.2, 0.4, 0.25)
        f = font(F_DISPLAY, 100)
        text_center(draw, (cx, H * 0.45 - 60), "Wat als skills", f, INK, aa)
        img = glow_text(img, cx, H * 0.45 + 60, "samenwerken?", f, GREEN, aa * 0.7, blur=26)
        draw = ImageDraw.Draw(img)
        text_center(draw, (cx, H * 0.45 + 60), "samenwerken?", f, GREEN, aa)
        return img
    aa = win(t, 14.2, 15.85, 0.3, 0.45)
    # node-graph
    cyN = H * 0.40
    R = 250
    pts = _nodes(cx, cyN, R, 6)
    labels = ["woordvoering", "kernboodschap", "research", "strategie", "creatie", "redactie"]
    links = [(0,1),(1,2),(2,3),(3,4),(4,5),(5,0),(0,3),(1,4),(2,5)]
    layer = Image.new("RGBA", img.size, (0,0,0,0))
    dl = ImageDraw.Draw(layer)
    appear_p = clamp((t - 14.25) / 0.6)
    for j,(p1,p2) in enumerate(links):
        lp = clamp((t - (14.3 + j*0.05)) / 0.4)
        if lp <= 0: continue
        x1,y1 = pts[p1]; x2,y2 = pts[p2]
        x2i = lerp(x1, x2, ease_out_cubic(lp)); y2i = lerp(y1, y2, ease_out_cubic(lp))
        pulse = 0.5 + 0.5*math.sin(t*4 + j)
        dl.line([(x1,y1),(x2i,y2i)], fill=(PURPLE[0],PURPLE[1],PURPLE[2], int((90+90*pulse)*aa)), width=3)
    img = Image.alpha_composite(img, layer)
    draw = ImageDraw.Draw(img)
    for i,(x,y) in enumerate(pts):
        np_ = clamp((t - (14.3 + i*0.06)) / 0.35)
        if np_ <= 0: continue
        rr = 12 * ease_out_back(np_)
        draw.ellipse([x-rr,y-rr,x+rr,y+rr], fill=(PURPLE[0],PURPLE[1],PURPLE[2],int(255*aa)))
        draw.ellipse([x-rr-6,y-rr-6,x+rr+6,y+rr+6], outline=(PURPLE[0],PURPLE[1],PURPLE[2],int(110*aa)), width=2)
        text_center(draw, (x, y+34), labels[i], font(F_MONO, 26), MUTED, aa*np_)
    # onderschrift
    f = font(F_DISPLAY, 86)
    yb = H * 0.66
    text_center(draw, (cx, yb), "Eén communicatieteam.", f, INK, aa)
    img = glow_text(img, cx, yb+98, "Volledig AI.", f, PURPLE, aa*0.95, blur=34)
    draw = ImageDraw.Draw(img)
    text_center(draw, (cx, yb+98), "Volledig AI.", f, PURPLE, aa)
    return img

def scene_riser(img, draw, t):
    # snelle woord-flashes die de titel opbouwen
    words = [("voorbij", 15.9, 16.3), ("de", 16.3, 16.6), ("prompt", 16.6, 17.4)]
    cx, cy = W/2, H*0.45
    for w,(t0),(t1) in [(w,a,b) for (w,a,b) in words]:
        if t0 <= t < t1:
            local = (t - t0)/(t1 - t0)
            sc = lerp(0.7, 1.25, ease_out_quint(min(local*2,1)))
            al = win(t, t0, t1, 0.08, 0.12)
            f = font(F_DISPLAY, int(150*sc))
            col = GREEN if w == "prompt" else INK
            img = glow_text(img, cx, cy, w, f, col, al*0.6, blur=34)
            d = ImageDraw.Draw(img)
            text_center(d, (cx, cy), w, f, col, al)
    return img

def scene_title(img, draw, t):
    a = win(t, 17.45, 20.0, 0.45, 0.0)
    if a <= 0: return img
    cx = W/2
    p = ease_out_quint(appear(t, 17.45, 0.6))
    # accentbalk (gradient groen -> paars)
    bw = (W*0.62) * ease_out_cubic(clamp((t-17.5)/0.5))
    by = H*0.235; steps = 90
    for sidx in range(steps):
        cseg = mix(GREEN, PURPLE, sidx/(steps-1))
        xa = cx - bw/2 + bw*sidx/steps
        xb = cx - bw/2 + bw*(sidx+1)/steps + 1
        draw.rectangle([xa, by, xb, by+8], fill=(cseg[0],cseg[1],cseg[2],int(235*a)))
    f = font(F_DISPLAY, 150)
    yT = H*0.34
    text_tracked(draw, cx, yT, "VOORBIJ", f, INK, tr=4, a=a)
    img = glow_text(img, cx, yT+170, "DE PROMPT", f, GREEN, a*0.85, blur=42, tracked=True, tr=4)
    draw = ImageDraw.Draw(img)
    text_tracked(draw, cx, yT+170, "DE PROMPT", f, GREEN, tr=4, a=a)
    # echte aigenwijs-logo (merkpaars, transparant) met zachte paarse gloed
    lg = logo_scaled(440)
    yW = int(H*0.545)
    lx = int(cx - lg.width/2); ly = int(yW - lg.height/2)
    glow_layer = Image.new("RGBA", img.size, (0,0,0,0))
    tint = Image.new("RGBA", lg.size, (PURPLE[0],PURPLE[1],PURPLE[2],255))
    ga = lg.split()[3].point(lambda v: int(v*0.85*a))
    glow_layer.paste(tint, (lx, ly), ga)
    img = Image.alpha_composite(img, glow_layer.filter(ImageFilter.GaussianBlur(28)))
    layer = Image.new("RGBA", img.size, (0,0,0,0))
    la = lg.split()[3].point(lambda v: int(v*a))
    layer.paste(lg, (lx, ly), la)
    img = Image.alpha_composite(img, layer)
    draw = ImageDraw.Draw(img)
    # sprekers + event
    ap2 = clamp((t-17.9)/0.4)
    text_center(draw, (cx, H*0.635), "Eric Kalsbeek  ·  Luke Andries", font(F_BODY_B, 46), INK, a*ap2)
    text_center(draw, (cx, H*0.675), "C-day 2026  —  Logeion", font(F_MONO, 38), MUTED, a*ap2)
    # CTA pill
    ap3 = clamp((t-18.4)/0.45)
    if ap3 > 0:
        cta = "kom het zélf zien"
        fc = font(F_BODY_B, 44)
        cw = draw.textlength(cta, font=fc)
        pw, ph = cw + 92, 96
        y0 = H*0.745
        x0 = cx - pw/2
        rad = ph/2
        col = (GREEN[0],GREEN[1],GREEN[2],int(235*a*ap3))
        draw.rounded_rectangle([x0, y0, x0+pw, y0+ph], radius=rad, fill=None, outline=col, width=4)
        text_center(draw, (cx, y0+ph/2), cta, fc, GREEN, a*ap3)
    return img

# ----------------------------------------------------------------------------- compose
def render_frame(idx):
    t = idx / FPS
    img = new_frame(idx)
    draw = ImageDraw.Draw(img)
    img = scene_prompt(img, draw, t); draw = ImageDraw.Draw(img)
    img = scene_statement2(img, draw, t); draw = ImageDraw.Draw(img)
    img = scene_turn(img, draw, t); draw = ImageDraw.Draw(img)
    img = scene_skills(img, draw, t); draw = ImageDraw.Draw(img)
    img = scene_context(img, draw, t); draw = ImageDraw.Draw(img)
    img = scene_team(img, draw, t); draw = ImageDraw.Draw(img)
    img = scene_riser(img, draw, t); draw = ImageDraw.Draw(img)
    img = scene_title(img, draw, t); draw = ImageDraw.Draw(img)
    draw_chrome(img, draw, t)
    return img.convert("RGB")

def main():
    keyframes_only = "--keyframes" in sys.argv
    if keyframes_only:
        for ts in [0.9, 2.4, 4.2, 6.4, 9.0, 11.6, 13.4, 15.0, 16.7, 18.0, 19.2]:
            idx = int(ts * FPS)
            render_frame(idx).save(f"{OUT_DIR}/keyframes/kf_{ts:04.1f}.png")
            print("kf", ts)
        return
    out = f"{OUT_DIR}/teaser_voorbij_de_prompt_silent.mp4"
    writer = imageio_ffmpeg.write_frames(
        out, (W, H), fps=FPS, codec="libx264", quality=None,
        pix_fmt_in="rgb24", pix_fmt_out="yuv420p", macro_block_size=8,
        output_params=["-crf", "17", "-preset", "medium", "-profile:v", "high"],
    )
    writer.send(None)
    for idx in range(N):
        writer.send(np.asarray(render_frame(idx), dtype=np.uint8).tobytes())
        if idx % 60 == 0:
            print(f"frame {idx}/{N}", flush=True)
    writer.close()
    print("WROTE", out)

if __name__ == "__main__":
    main()
