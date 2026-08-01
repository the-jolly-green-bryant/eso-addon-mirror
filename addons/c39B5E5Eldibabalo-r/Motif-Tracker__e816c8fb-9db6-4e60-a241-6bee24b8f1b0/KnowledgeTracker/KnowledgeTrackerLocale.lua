-- =============================================================================
-- Motifs Tracker — Localisation v2.0.0
-- UI strings for EN, DE, FR, JA, ZH.
-- Motif NAMES come from the game API (already localised).
-- =============================================================================

KT_Locale = {}

local lang = "en"

local strings = {
    TITLE = {
        en = "Motifs Tracker",
        de = "Stil-Tracker",
        fr = "Suivi des Motifs",
        ja = "モチーフトラッカー",
        zh = "样式追踪器",
    },
    COL_NAME = {
        en = "NAME",
        de = "NAME",
        fr = "NOM",
        ja = "名前",
        zh = "名称",
    },
    COL_CHAPTERS = {
        en = "CHAPTERS",
        de = "KAPITEL",
        fr = "CHAPITRES",
        ja = "チャプター",
        zh = "章节",
    },
    KB_SCROLL_UP = {
        en = "Scroll Up",
        de = "Hoch scrollen",
        fr = "Défiler haut",
        ja = "上スクロール",
        zh = "向上滚动",
    },
    KB_SCROLL_DOWN = {
        en = "Scroll Down",
        de = "Runter scrollen",
        fr = "Défiler bas",
        ja = "下スクロール",
        zh = "向下滚动",
    },
    KB_SEARCH = {
        en = "Search",
        de = "Suche",
        fr = "Recherche",
        ja = "検索",
        zh = "搜索",
    },
    KB_GROUP = {
        en = "Group",
        de = "Gruppieren",
        fr = "Grouper",
        ja = "グループ",
        zh = "分组",
    },
    KB_NEXT_CHAR = {
        en = "Next Char",
        de = "Nächster Char",
        fr = "Perso suiv.",
        ja = "次キャラ",
        zh = "下个角色",
    },
    KB_PREV_CHAR = {
        en = "Prev Char",
        de = "Vorheriger Char",
        fr = "Perso préc.",
        ja = "前キャラ",
        zh = "上个角色",
    },
    KB_PIN_CHAR = {
        en = "Pin Char",
        de = "Char anheften",
        fr = "Épingler perso",
        ja = "キャラ固定",
        zh = "固定角色",
    },
    MENU_ENTRY = {
        en = "Motifs Tracker",
        de = "Stil-Tracker",
        fr = "Suivi des Motifs",
        ja = "モチーフトラッカー",
        zh = "样式追踪器",
    },
    FOOTER_COMPLETE = {
        en = "Complete",
        de = "Vollständig",
        fr = "Complet",
        ja = "完了",
        zh = "已完成",
    },
}

-- ═══════════════════════════════════════════════════════════════════════════
-- PUBLIC API
-- ═══════════════════════════════════════════════════════════════════════════

function KT_Locale.Init()
    local raw = GetCVar and GetCVar("language.2") or "en"
    lang = (raw and raw ~= "") and string.lower(raw) or "en"
end

function KT_Locale.L(key)
    local entry = strings[key]
    if not entry then return key end
    return entry[lang] or entry["en"] or key
end
