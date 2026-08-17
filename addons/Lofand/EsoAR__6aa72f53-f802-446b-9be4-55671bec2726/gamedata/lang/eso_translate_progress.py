import os, re, sys, json, time
from pathlib import Path

from tqdm import tqdm
from openai import OpenAI
import arabic_reshaper
from bidi.algorithm import get_display

# =======================
# إعدادات
# =======================
MODEL = os.getenv("OPENAI_MODEL", "gpt-4o-mini")
BATCH_LINES = 60               # قلّلها لو صار خطأ حجم/429
SLEEP_BETWEEN_CALLS = 0.0      # تهدئة بسيطة
MAX_RETRIES = 8                # إعادة محاولة عند أخطاء مؤقتة

RLM = "\u200f"

AR_LOGICAL_RE = re.compile(r"[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]")
AR_PRESENT_RE = re.compile(r"[\uFB50-\uFDFF\uFE70-\uFEFF]")
QUOTED = re.compile(r'"((?:\\.|[^"\\])*)"')

PLACEHOLDER_RE = re.compile(
    r"(\<\<\d+\>\>|"              # <<1>>
    r"\|c[0-9A-Fa-f]{6}\||\|r|"    # |cffffff| / |r
    r"\%\%|\%[sdif]|\%d|"         # %s %d etc.
    r"\$\([A-Za-z0-9_]+\))"       # $(VAR)
)

def has_arabic_any(s: str) -> bool:
    return bool(AR_LOGICAL_RE.search(s) or AR_PRESENT_RE.search(s))

def is_arabicish(s: str) -> bool:
    return bool(AR_LOGICAL_RE.search(s) or AR_PRESENT_RE.search(s))

def unescape(s: str) -> str:
    return (s.replace(r"\\", "\\")
             .replace(r"\"", '"')
             .replace(r"\n", "\n")
             .replace(r"\t", "\t")
             .replace(r"\r", "\r"))

def escape(s: str) -> str:
    return (s.replace("\\", r"\\")
             .replace('"', r"\"")
             .replace("\n", r"\n")
             .replace("\t", r"\t")
             .replace("\r", r"\r"))

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
    if not is_arabicish(word):
        return word
    if AR_PRESENT_RE.search(word):
        return get_display(word)
    reshaped = arabic_reshaper.reshape(word)
    return get_display(reshaped)

def shape_like_site_keep_order(text: str) -> str:
    """
    - يحوّل العربية لشكل arabic-text.com (كلمة-بكلمة)
    - ويضيف RLM قبل مقاطع العربية لتثبيت ترتيب الكلمات داخل واجهة LTR مثل ESO
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

def translate_lines(client: OpenAI, lines: list[str]) -> list[str]:
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
        "- Keep the same number of lines and the same order.\n"
        "- Do NOT translate placeholder tokens like __PH_0__.\n"
        "- Keep punctuation and symbols.\n"
        "Lines:\n"
        + json.dumps(protected_lines, ensure_ascii=False)
    )

    # Retry loop (يعالج أخطاء مؤقتة)
    last_err = None
    for attempt in range(MAX_RETRIES):
        try:
            resp = client.responses.create(model=MODEL, input=prompt)
            out_text = resp.output_text.strip()
            arr = json.loads(out_text)
            if not isinstance(arr, list) or len(arr) != len(lines):
                raise RuntimeError("Bad JSON shape from model. Reduce BATCH_LINES.")
            restored = [unprotect(s, mp) for s, mp in zip(arr, maps)]
            return restored
        except Exception as e:
            last_err = e
            # تهدئة تدريجية
            time.sleep(0.8 * (attempt + 1))
            continue

    raise last_err

def process_file(in_path: Path):
    api_key = os.getenv("OPENAI_API_KEY", "")
    if not api_key or not api_key.startswith("sk-"):
        raise SystemExit("OPENAI_API_KEY غير مضبوط. استخدم: set OPENAI_API_KEY=sk-...")

    # تأكد أنه ASCII فقط (يتجنب خطأ httpx)
    try:
        api_key.encode("ascii")
    except UnicodeEncodeError:
        raise SystemExit("OPENAI_API_KEY فيه رموز مخفية/غير ASCII. اكتب المفتاح يدويًا من جديد في CMD.")

    client = OpenAI(api_key=api_key)

    out_path = in_path.with_name(in_path.stem + "_AR_eso" + in_path.suffix)
    state_path = in_path.with_name(in_path.stem + "_progress.json")

    # اقرأ الملف
    lines = in_path.read_text(encoding="utf-8", errors="replace").splitlines(True)
    total = len(lines)

    # استئناف
    start_line = 0
    if state_path.exists():
        st = json.loads(state_path.read_text(encoding="utf-8"))
        start_line = int(st.get("next_line", 0))

    # إذا يبدأ من 0 امسح الناتج السابق
    if start_line == 0 and out_path.exists():
        out_path.unlink()

    pbar = tqdm(total=total, initial=start_line, unit="line", desc="Translating")
    i = start_line

    while i < total:
        batch = lines[i:i + BATCH_LINES]

        # ترجمة سطر-بسطر مع الحفاظ على نهاية السطر
        core = [b.rstrip("\r\n") for b in batch]
        tails = [b[len(c):] for b, c in zip(batch, core)]  # \n أو \r\n

        # ترجم
        print(f"\nCalling API for lines {i}..{i+len(core)-1}", flush=True)
        translated = translate_lines(client, core)
        print("API returned", flush=True)

        # شكّل النص مثل الموقع + رتّب الكلمات
        final = [shape_like_site_keep_order(t) + tail for t, tail in zip(translated, tails)]

        with open(out_path, "a", encoding="utf-8", newline="") as f:
            f.writelines(final)

        i += len(batch)
        state_path.write_text(json.dumps({"next_line": i}, ensure_ascii=False), encoding="utf-8")

        pbar.update(len(batch))
        pbar.set_postfix_str(f"{i}/{total} ({(i/total)*100:.2f}%)")
        time.sleep(SLEEP_BETWEEN_CALLS)

    pbar.close()
    print("\nتم ✅")
    print("الملف الناتج:", out_path)
    print("ملف المتابعة:", state_path, "(تقدر تحذفه بعد ما تتأكد)")

def main():
    if len(sys.argv) < 2:
        print('Usage: python eso_translate_progress.py "C:\\path\\er.lang.LUA"')
        sys.exit(1)

    in_path = Path(sys.argv[1])
    if not in_path.exists():
        raise SystemExit("الملف غير موجود: " + str(in_path))

    process_file(in_path)

if __name__ == "__main__":
    main()
