"""Rebuild the included original PNG and WAV assets (requires Pillow)."""
from PIL import Image, ImageDraw
from pathlib import Path
import math, wave, struct

root = Path(__file__).parent / 'assets'
images = root / 'images'
audio = root / 'audio'
images.mkdir(parents=True, exist_ok=True)
audio.mkdir(parents=True, exist_ok=True)

# Portrait backgrounds: cool blue home, very light quiz pages.
for filename, top, bottom in [
    ('ocean_background.png', (227, 249, 254), (94, 201, 225)),
    ('quiz_background.png', (255, 255, 255), (242, 250, 253)),
]:
    w, h = 720, 1280
    im = Image.new('RGB', (w, h))
    px = im.load()
    for y in range(h):
        t = y / (h - 1)
        color = tuple(round(top[i]*(1-t) + bottom[i]*t) for i in range(3))
        for x in range(w): px[x, y] = color
    d = ImageDraw.Draw(im, 'RGBA')
    for j in range(7):
        cy = 150 + j*185
        points = [(x, int(cy + 20*math.sin(x/76 + j*.85))) for x in range(-2,w+3,3)]
        d.line(points, fill=(35, 154, 198, 24 if 'quiz' in filename else 52), width=4)
    for x,y,r in [(90,170,24),(650,105,39),(580,340,19),(155,610,35),(640,830,28),(100,1080,26)]:
        d.ellipse((x-r,y-r,x+r,y+r), outline=(19, 140, 188, 38), width=5)
    im.save(images / filename, optimize=True)


def icon(name):
    im = Image.new('RGBA',(256,256),(0,0,0,0))
    d=ImageDraw.Draw(im)
    d.rounded_rectangle((12,12,244,244),radius=58,fill=(11,121,170,255))
    d.rounded_rectangle((22,22,234,234),radius=51,outline=(129,239,245,255),width=6)
    white=(255,255,255,255); aqua=(119,231,239,255); yellow=(255,208,108,255)
    if name=='simulation':
        d.line([(92,47),(164,47)], fill=white,width=13)
        d.line([(103,48),(103,108),(52,187)], fill=white,width=13)
        d.line([(153,48),(153,108),(204,187)], fill=white,width=13)
        d.line([(52,187),(204,187)], fill=white,width=13)
        d.polygon([(78,153),(178,153),(199,184),(56,184)], fill=aqua)
        for x,y in [(102,133),(140,119),(154,145)]: d.ellipse((x-7,y-7,x+7,y+7),fill=yellow)
    elif name=='quiz':
        d.rounded_rectangle((51,47,205,209),radius=18,fill=white)
        d.arc((82,68,170,154),195,540,fill=(11,121,170),width=17)
        d.ellipse((121,172,140,191),fill=(11,121,170))
    elif name=='game':
        d.rounded_rectangle((33,89,222,181),radius=42,fill=white)
        d.line([(78,132),(120,132)],fill=(11,121,170),width=13)
        d.line([(99,111),(99,153)],fill=(11,121,170),width=13)
        d.ellipse((162,111,183,132),fill=(255,173,82))
        d.ellipse((184,139,205,160),fill=(88,202,215))
    elif name=='options':
        d.rounded_rectangle((51,48,207,210),radius=18,fill=white)
        for y in [83,127,171]:
            d.ellipse((69,y-9,87,y+9),fill=(11,121,170))
            d.line([(104,y),(186,y)],fill=(11,121,170),width=10)
    elif name=='settings':
        cx=cy=128
        for k in range(12):
            a=2*math.pi*k/12
            x=cx+70*math.cos(a);y=cy+70*math.sin(a)
            d.ellipse((x-15,y-15,x+15,y+15),fill=white)
        d.ellipse((65,65,191,191),fill=white)
        d.ellipse((103,103,153,153),fill=(11,121,170))
    im.save(images/f'{name}.png',optimize=True)

for name in ['simulation','quiz','game','options','settings']: icon(name)
logo=Image.new('RGBA',(280,280),(0,0,0,0)); d=ImageDraw.Draw(logo)
d.ellipse((20,20,260,260),fill=(13,119,165,255),outline=(125,231,241,255),width=11)
d.polygon([(140,48),(80,151),(91,201),(128,224),(170,215),(199,180),(188,140)],fill=(135,235,245,255))
d.ellipse((111,129,169,188),fill=(255,255,255,210))
d.ellipse((123,142,156,177),fill=(15,136,186,255))
logo.save(images/'logo.png',optimize=True)

rate=22050

def save_wav(name, samples):
    with wave.open(str(audio/name),'wb') as f:
        f.setnchannels(1);f.setsampwidth(2);f.setframerate(rate)
        f.writeframes(b''.join(struct.pack('<h',max(-32767,min(32767,int(s*32767)))) for s in samples))

def tone(freq, duration, volume=.16):
    count=int(rate*duration)
    return [volume*math.sin(2*math.pi*freq*n/rate)*min(1,n/(rate*.03))*min(1,(count-n)/(rate*.12)) for n in range(count)]

save_wav('tap.wav',tone(540,.11,.18))
save_wav('correct.wav',tone(660,.17,.14)+tone(880,.26,.15))
save_wav('wrong.wav',tone(220,.20,.15)+tone(180,.23,.13))
# A quiet eight-second loop with soft chord tones and a shaped envelope.
notes=[(261.63,329.63,392.0),(220.0,261.63,329.63),(174.61,261.63,349.23),(196.0,293.66,392.0)]
samples=[]
for chord in notes:
    for n in range(rate*2):
        t=n/rate
        fade=min(1,t/.28,(2-t)/.28)
        sound=sum(math.sin(2*math.pi*f*t)*.025 + math.sin(2*math.pi*f*2*t)*.004 for f in chord)
        samples.append(sound*max(0,fade))
save_wav('background_music.wav',samples)
print('Generated',len(list(images.iterdir())),'images and',len(list(audio.iterdir())),'audio files.')
