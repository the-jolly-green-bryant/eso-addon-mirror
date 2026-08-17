import os, re, sys, json, time
from pathlib import Path

import requests
from tqdm import tqdm
import arabic_reshaper
from bidi.algorithm import get_display

# =======================
# Settings
# =======================
GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY", "").strip()
TARGET_LANG = "ar"
SOURCE_LANG = "en"

BATCH_LINES = 40                 # ارفعها للسرعة (مثلاً 80) إذا ما صار أخطاء
MAX_BATCH_CHARS = 14000          # لتجنب حدود الطلب
SLEEP_BETWEEN_CALLS = 0.0
MAX_RETRIES = 8

RLM = "\u200f"  # invisible RTL marker (helps word order in ESO)

# Arabic detection
AR_LOGICAL_RE = re.compile(r"[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]")
AR_PRESENT_RE = re.compile(r"[\uFB50-\uFDFF\uFE70-\uFEFF]")

PLACEHOLDER_RE = re.compile(
    r"(\<\<\d+\>\>|"              # <<1>>
    r"\|c[0-9A-Fa-f]{6}\||\|r|"    # |cffffff| / |r
    r"\%\%|\%[sdif]|\%d|"         # %s %d etc.
    r"\$\([A-Za-z0-9_]+\))"       # $(VAR)
)

TRANSLATE_URL = "https://translation.googleapis.com/language/translate/v2"

def has_arabic_any(s: str) -> bool:
    return bool(AR_LOGICAL_RE.search(s) or AR_PRESENT_RE.search(s))

def is_arabicish(s: str) -> bool:
    return bool(AR_LOGICAL_RE.search(s) or AR_PRESENT_RE.search(s))

def protect(text: str):
    mapping = {}
    def repl(m):
        key = f"__PH_{len(mapping)}__"
        mapping[key] = m.group(0)
        return key
    return PLACEHOLDER_RE.sub(repl, text), mapping

def unprotect(text: str, mapping: dict):
    for k, v in mapping.items():
        text = text.replace(k, v)
    return text

def site_word(word: str) -> str:
    """Make ONE word look like arabic-text.com output."""
    if not is_arabicish(word):
        return word
    if AR_PRESENT_RE.search(word):
        return get_display(word)
    reshaped = arabic_reshaper.reshape(word)
    return get_display(reshaped)

def shape_like_site_keep_order(text: str) -> str:
    """
    - يحوّل العربية لشكل arabic-text.com (كلمة-بكلمة)
    - يضيف RLM قبل المقاطع العربية لتثبيت ترتيب الكلمات داخل واجهة LTR مثل ESO
    """
    if not text or not has_arabic_any(text):
        return text

    tokens = re.split(r"(\s+)", text)
    out = []
    saw_ar = False

    for tok in tokens:
        if tok == "" or tok.isspace():
            out.append(tok)
            continue

        parts = re.split(r"([^\w\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]+)", tok)
        new_parts = []
        for p in parts:
            if not p:
                continue
            if is_arabicish(p):
                saw_ar = True
                new_parts.append(RLM + site_word(p))
            else:
                new_parts.append(p)
        out.append("".join(new_parts))

    res = "".join(out)
    if saw_ar and not res.startswith(RLM):
        res = RLM + res
    return res

def google_translate_lines(lines: list[str]) -> list[str]:
    """
    Translate a list of strings using Google Translate v2.
    Returns list[str] same length/order.
    """
    if not GOOGLE_API_KEY:
        raise SystemExit("GOOGLE_API_KEY غير مضبوط. استخدم: set GOOGLE_API_KEY=AIza...")

    # protect placeholders
    protected = []
    maps = []
    for ln in lines:
        pln, mp = protect(ln)
        protected.append(pln)
        maps.append(mp)

    params = {"key": GOOGLE_API_KEY}
    data = {
        "q": protected,
        "source": SOURCE_LANG,
        "target": TARGET_LANG,
        "format": "text",
    }

    last_err = None
    for attempt in range(MAX_RETRIES):
        try:
            r = requests.post(TRANSLATE_URL, params=params, data=data, timeout=60)
            if r.status_code == 200:
                js = r.json()
                out = [item["translatedText"] for item in js["data"]["translations"]]
                if len(out) != len(lines):
                    raise RuntimeError("Google returned mismatched line count.")
                # Unprotect
                return [unprotect(s, mp) for s, mp in zip(out, maps)]

            # Backoff on quota/rate
            last_err = RuntimeError(f"HTTP {r.status_code}: {r.text[:300]}")
            time.sleep(0.8 * (attempt + 1))
            continue

        except Exception as e:
            last_err = e
            time.sleep(0.8 * (attempt + 1))
            continue

    raise last_err

def make_batches(all_lines: list[str], start: int):
    """
    Yield (i, batch_lines) where batch respects BATCH_LINES and MAX_BATCH_CHARS.
    """
    i = start
    n = len(all_lines)
    while i < n:
        batch = []
        chars = 0
        while i < n and len(batch) < BATCH_LINES:
            s = all_lines[i]
            # count core length only (no newline)
            core = s.rstrip("\r\n")
            add = len(core)
            if batch and (chars + add) > MAX_BATCH_CHARS:
                break
            batch.append(s)
            chars += add
            i += 1
        yield i, batch

def main():
    if len(sys.argv) < 2:
        print('Usage: python google_eso_translate_progress.py "C:\\path\\er.lang.LUA"')
        sys.exit(1)

    in_path = Path(sys.argv[1])
    if not in_path.exists():
        raise SystemExit("الملف غير موجود: " + str(in_path))

    out_path = in_path.with_name(in_path.stem + "_AR_google_eso" + in_path.suffix)
    state_path = in_path.with_name(in_path.stem + "_google_progress.json")

    lines = in_path.read_text(encoding="utf-8", errors="replace").splitlines(True)
    total = len(lines)

    start_line = 0
    if state_path.exists():
        st = json.loads(state_path.read_text(encoding="utf-8"))
        start_line = int(st.get("next_line", 0))

    if start_line == 0 and out_path.exists():
        out_path.unlink()

    pbar = tqdm(total=total, initial=start_line, unit="line", desc="Google Translating")

    i = start_line
    # iterate batches
    for next_i, batch in make_batches(lines, start_line):
        # Split into core + newline tails
        core = [b.rstrip("\r\n") for b in batch]
        tails = [b[len(c):] for b, c in zip(batch, core)]

        # Translate
        translated = google_translate_lines(core)

        # Shape like arabic-text.com + keep word order in ESO
        final = [shape_like_site_keep_order(t) + tail for t, tail in zip(translated, tails)]

        with open(out_path, "a", encoding="utf-8", newline="") as f:
            f.writelines(final)

        i = next_i
        state_path.write_text(json.dumps({"next_line": i}, ensure_ascii=False), encoding="utf-8")

        pbar.update(len(batch))
        pbar.set_postfix_str(f"{i}/{total} ({(i/total)*100:.2f}%)")
        if SLEEP_BETWEEN_CALLS:
            time.sleep(SLEEP_BETWEEN_CALLS)

    pbar.close()
    print("\nتم ✅")
    print("الملف الناتج:", out_path)
    print("ملف المتابعة:", state_path)

if __name__ == "__main__":
    main()
