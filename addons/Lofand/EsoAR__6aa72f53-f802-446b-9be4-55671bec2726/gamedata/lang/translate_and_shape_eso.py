import os
import re
import sys
import json
import time
from pathlib import Path

from openai import OpenAI
import arabic_reshaper
from bidi.algorithm import get_display

# =========================
# Settings
# =========================
MODEL = os.getenv("OPENAI_MODEL", "gpt-4o-mini")  # تقدر تغيّرها
BATCH_LINES = 80       # كم سطر في كل طلب (قلّلها إذا واجهت أخطاء)
SLEEP_SEC = 0.2        # تهدئة بسيطة بين الطلبات

# RTL invisible marker (helps keep word order in LTR renderers like ESO)
RLM = "\u200f"

# Arabic ranges
AR_LOGICAL_RE = re.compile(r"[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]")
AR_PRESENT_RE = re.compile(r"[\uFB50-\uFDFF\uFE70-\uFEFF]")

def has_arabic_any(s: str) -> bool:
    return bool(AR_LOGICAL_RE.search(s) or AR_PRESENT_RE.search(s))

def is_arabicish(s: str) -> bool:
    return bool(AR_LOGICAL_RE.search(s) or AR_PRESENT_RE.search(s))

def site_word(word: str) -> str:
    """Make ONE word look like arabic-text.com output."""
    if not is_arabicish(word):
        return word
    if AR_PRESENT_RE.search(word):
        return get_display(word)
    reshaped = arabic_reshaper.reshape(word)
    return get_display(reshaped)

def convert_text_keep_order(text: str) -> str:
    """
    Apply arabic-text.com-like shaping word-by-word,
    and add RLM markers to keep word order in ESO.
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

# =========================
# Placeholder protection
# =========================
PLACEHOLDER_RE = re.compile(
    r"(\<\<\d+\>\>|"          # <<1>>
    r"\|c[0-9A-Fa-f]{6}\||\|r|" # |cffffff| / |r
    r"\%\%|\%[sdif]|\%d|"      # %s %d etc.
    r"\$\([A-Za-z0-9_]+\))"    # $(VAR)
)

def protect(text: str):
    """Replace placeholders with tokens so translation doesn't break them."""
    mapping = {}
    def repl(m):
        key = f"__PH_{len(mapping)}__"
        mapping[key] = m.group(0)
        return key
    protected = PLACEHOLDER_RE.sub(repl, text)
    return protected, mapping

def unprotect(text: str, mapping: dict):
    for k, v in mapping.items():
        text = text.replace(k, v)
    return text

# =========================
# OpenAI translate (JSON array in / JSON array out)
# =========================
client = OpenAI()

def translate_lines(lines):
    """
    Translate list[str] EN->AR, keep same count/order.
    Returns list[str].
    """
    protected_lines = []
    maps = []
    for ln in lines:
        pln, mp = protect(ln)
        protected_lines.append(pln)
        maps.append(mp)

    prompt = (
        "Translate the following lines from English to Arabic.\n"
        "Rules:\n"
        "- Return ONLY a JSON array of strings.\n"
        "- Keep line count and order exactly the same.\n"
        "- Do NOT translate placeholder tokens like __PH_0__.\n"
        "- Keep punctuation and symbols.\n"
        "Lines:\n"
        + json.dumps(protected_lines, ensure_ascii=False)
    )

    resp = client.responses.create(
        model=MODEL,
        input=prompt
    )

    out_text = resp.output_text.strip()

    try:
        arr = json.loads(out_text)
        if not isinstance(arr, list) or len(arr) != len(lines):
            raise ValueError("Bad JSON shape")
    except Exception:
        raise RuntimeError("Model did not return valid JSON array. Try smaller BATCH_LINES.")

    # restore placeholders
    restored = []
    for s, mp in zip(arr, maps):
        restored.append(unprotect(s, mp))
    return restored

# =========================
# Main file loop with resume
# =========================
def main():
    if len(sys.argv) < 2:
        print('Usage: python translate_and_shape_eso.py "C:\\path\\er.lang.LUA"')
        sys.exit(1)

    in_path = Path(sys.argv[1])
    out_path = in_path.with_name(in_path.stem + "_AR_eso" + in_path.suffix)
    state_path = in_path.with_name(in_path.stem + "_progress.json")

    # Load progress
    start_line = 0
    if state_path.exists():
        st = json.loads(state_path.read_text(encoding="utf-8"))
        start_line = int(st.get("next_line", 0))

    # Read all lines (stream-ish would be nicer, but ok)
    lines = in_path.read_text(encoding="utf-8", errors="replace").splitlines(True)

    # Prepare output (append mode for resume)
    if start_line == 0 and out_path.exists():
        out_path.unlink()

    # Write batches
    i = start_line
    total = len(lines)

    while i < total:
        batch = lines[i:i+BATCH_LINES]

        # Strip only newline for translation, keep newline separately
        core = [b.rstrip("\r\n") for b in batch]
        nl = [b[len(core[j]):] if core[j] != b else ("\n" if b.endswith("\n") else "") for j, b in enumerate(batch)]
        # (safe way)
        nl = []
        for b, c in zip(batch, core):
            nl.append(b[len(c):])

        # Translate
        translated = translate_lines(core)

        # Shape + order for ESO
        final = [convert_text_keep_order(t) + n for t, n in zip(translated, nl)]

        with open(out_path, "a", encoding="utf-8", newline="") as f:
            f.writelines(final)

        i += len(batch)
        state_path.write_text(json.dumps({"next_line": i}, ensure_ascii=False), encoding="utf-8")

        print(f"Done lines: {i}/{total}")
        time.sleep(SLEEP_SEC)

    print("FINISHED:", out_path)
    print("You can delete progress file:", state_path)

if __name__ == "__main__":
    main()
