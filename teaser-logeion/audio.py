#!/usr/bin/env python3
"""Genereert een subtiele teaser-audiobed (20s) en muxt die in de video."""
import os, subprocess, wave, struct
import numpy as np
import imageio_ffmpeg

SR = 44100
DUR = 20.0
HERE = os.path.dirname(os.path.abspath(__file__))
n = int(SR * DUR)
t = np.arange(n) / SR
out = np.zeros(n, np.float32)

def env_exp(at, dur, tau):
    e = np.zeros(n, np.float32)
    i0 = int(at * SR); i1 = min(n, int((at + dur) * SR))
    if i1 <= i0: return e
    tt = (np.arange(i1 - i0)) / SR
    e[i0:i1] = np.exp(-tt / tau)
    return e

def kick(at, f0=120, f1=45, dur=0.45, tau=0.12, amp=0.55):
    i0 = int(at * SR); i1 = min(n, int((at + dur) * SR))
    if i1 <= i0: return
    tt = (np.arange(i1 - i0)) / SR
    f = f1 + (f0 - f1) * np.exp(-tt / 0.06)
    ph = 2 * np.pi * np.cumsum(f) / SR
    out[i0:i1] += amp * np.sin(ph) * np.exp(-tt / tau)

def click(at, amp=0.10, dur=0.012):
    i0 = int(at * SR); i1 = min(n, int((at + dur) * SR))
    if i1 <= i0: return
    tt = np.arange(i1 - i0) / SR
    out[i0:i1] += amp * (np.random.standard_normal(i1 - i0)) * np.exp(-tt / 0.004)

# --- lage drone (E1) die langzaam zwelt
drone = (0.10 * np.sin(2*np.pi*41.2*t) + 0.06 * np.sin(2*np.pi*55.0*t + 0.4))
swell = np.clip(t / 6.0, 0.15, 1.0) * (0.6 + 0.4*np.sin(2*np.pi*0.06*t))
out += drone * swell

# --- ticks tijdens prompt-scene (0.4-2.6s)
for k in range(6):
    click(0.5 + k * 0.32, amp=0.08)

# --- kicks op scene-overgangen
for at in [3.05, 5.30, 7.50, 10.50, 12.70, 14.20]:
    kick(at, amp=0.42)

# --- riser 15.8 -> 17.45
i0 = int(15.8 * SR); i1 = int(17.45 * SR)
tt = (np.arange(i1 - i0)) / SR
rl = tt / (tt[-1])
noise = np.random.standard_normal(i1 - i0)
# simpele 1-pole lowpass die opent
lp = np.zeros_like(noise); a = 0.0
for i in range(len(noise)):
    a += (rl[i] ** 2) * (noise[i] - a) * 0.5
    lp[i] = a
sweep = np.sin(2*np.pi*(120 + 600*rl**2)*tt)
out[i0:i1] += (0.30*lp + 0.12*sweep) * (rl**1.5)
# versnellende ticks in riser
tk = 15.8
step = 0.16
while tk < 17.4:
    click(tk, amp=0.12)
    step *= 0.82
    tk += max(step, 0.045)

# --- impact + shimmer-pad op titel (17.45 -> eind)
kick(17.45, f0=160, f1=42, dur=0.8, tau=0.22, amp=0.8)
out[int(17.45*SR):min(n,int(17.7*SR))] += 0.25*np.random.standard_normal(min(n,int(17.7*SR))-int(17.45*SR))*np.exp(-np.arange(min(n,int(17.7*SR))-int(17.45*SR))/SR/0.05)
pad_env = np.clip((t - 17.45) / 0.8, 0, 1) * np.where(t > 17.45, 1.0, 0.0)
for f in [220.0, 277.18, 329.63]:   # A3 / C#4 / E4
    out += 0.05 * np.sin(2*np.pi*f*t) * pad_env

# --- master: fade in/out, soft-clip, normaliseer
fin = int(0.15*SR); fout = int(0.5*SR)
out[:fin] *= np.linspace(0, 1, fin)
out[-fout:] *= np.linspace(1, 0, fout)
out = np.tanh(out * 1.2)
out /= max(1e-6, np.max(np.abs(out)))
out *= 0.89

# stereo
stereo = np.stack([out, out], axis=1)
pcm = (stereo * 32767).astype(np.int16)
wav_path = os.path.join(HERE, "teaser_bed.wav")
with wave.open(wav_path, "w") as w:
    w.setnchannels(2); w.setsampwidth(2); w.setframerate(SR)
    w.writeframes(pcm.tobytes())
print("WROTE", wav_path)

# --- mux
ff = imageio_ffmpeg.get_ffmpeg_exe()
silent = os.path.join(HERE, "teaser_voorbij_de_prompt_silent.mp4")
final = os.path.join(HERE, "teaser_voorbij_de_prompt.mp4")
cmd = [ff, "-y", "-i", silent, "-i", wav_path,
       "-c:v", "libx264", "-crf", "23", "-preset", "slow",
       "-pix_fmt", "yuv420p", "-movflags", "+faststart",
       "-c:a", "aac", "-b:a", "160k", "-shortest", final]
subprocess.run(cmd, check=True, capture_output=True)
print("WROTE", final)
