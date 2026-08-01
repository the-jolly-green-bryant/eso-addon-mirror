-- =============================================================================
-- Under Pressure -- UI/Fonts.lua
-- =============================================================================
-- Console-safe font resolution. Read this before changing any font anywhere
-- in the addon.
--
-- WHY THIS MODULE EXISTS
-- ----------------------
-- Fonts in ESO are defined per input mode, in two separate files:
--     esoui/fontdefs/keyboard/defaultfontdefs_keyboard.xml
--     esoui/fontdefs/gamepad/defaultfontdefs_gamepad.xml
-- A font defined in one is NOT available in the other. ZOS says so directly
-- in the header comment of the keyboard file: "Any files loaded on the
-- Consoles should not use these fonts as they will not render."
--
-- Console is ALWAYS gamepad mode, so a keyboard-only font string simply does
-- not resolve there. Observed severity: COSMETIC. Versions through 0.2.7
-- shipped keyboard-only fonts and ran fine for dozens of users, so SetFont
-- evidently falls back to a default rather than raising. The symptom was that
-- size controls appeared to do nothing.
--
-- (Worth knowing what the bad case would look like anyway: console does not
-- surface Lua errors to the player, and the counter font is applied inside
-- UP.UI.Init(), which runs before event registration and before the engine
-- tick starts. Anything that DID throw there would abort init and produce a
-- silently dead addon. Hence the pcall in Apply below -- insurance, not a
-- response to a known throw.)
--
-- Versions through 0.2.7 carried two distinct offenders:
--   1. Indicator.xml used font="ZoFontWinH3". Verified against the live
--      fontdefs at API 101050: ZoFontWinH3 is defined ONLY in the keyboard
--      file, zero occurrences in the gamepad file.
--   2. Indicator.lua and Debug.lua built descriptors from $(MEDIUM_FONT) and
--      $(BOLD_FONT). Those two constants appear 54 times across the keyboard
--      fontdefs and NEVER in the gamepad fontdefs -- ZOS uses the
--      $(GAMEPAD_MEDIUM_FONT) / $(GAMEPAD_BOLD_FONT) family there instead.
--
-- THE APPROACH
-- ------------
-- We do not gamble on $() substitution constants resolving in gamepad mode
-- at all. Instead we snap any requested pixel size to the nearest NAMED font
-- from the gamepad fontdefs -- names that are verified present in the file
-- ZOS actually loads on console. Every SetFont is additionally wrapped in
-- pcall, so even if a future patch removes a name from the ladder, the
-- failure is a wrong-looking label rather than a dead addon.
--
-- Ladder verified 2026-07-28 against
-- raw.githubusercontent.com/esoui/esoui/live/esoui/fontdefs/gamepad/
-- defaultfontdefs_gamepad.xml at API version 101050. Re-verify if a future
-- update changes the available sizes -- do NOT assume this list stays valid,
-- and do NOT trust that a font exists just because a sibling addon uses it.
--
-- Note the two ladders are not identical: bold has no 36, medium has no 48.
-- =============================================================================

UP = UP or {}
UP.Fonts = {}

-- Ascending. Each entry is {nominalSize, fontName}. The nominal size is the
-- $(GP_nn) token ZOS names the font after; the rendered pixel height is
-- subject to the gamepad UI scale, so treat these as a monotonic ladder
-- rather than exact pixel measurements.
local MEDIUM_LADDER = {
    { 18, "ZoFontGamepad18" },
    { 20, "ZoFontGamepad20" },
    { 22, "ZoFontGamepad22" },
    { 25, "ZoFontGamepad25" },
    { 27, "ZoFontGamepad27" },
    { 34, "ZoFontGamepad34" },
    { 36, "ZoFontGamepad36" },
    { 42, "ZoFontGamepad42" },
    { 54, "ZoFontGamepad54" },
    { 61, "ZoFontGamepad61" },
}

local BOLD_LADDER = {
    { 18, "ZoFontGamepadBold18" },
    { 20, "ZoFontGamepadBold20" },
    { 22, "ZoFontGamepadBold22" },
    { 25, "ZoFontGamepadBold25" },
    { 27, "ZoFontGamepadBold27" },
    { 34, "ZoFontGamepadBold34" },
    { 42, "ZoFontGamepadBold42" },
    { 48, "ZoFontGamepadBold48" },
    { 54, "ZoFontGamepadBold54" },
}

-- Exposed so the settings panel can clamp its slider to the real range
-- instead of hardcoding numbers that could drift out of sync with the ladder.
UP.Fonts.MIN_SIZE = 18
UP.Fonts.MAX_SIZE = 61

-- ---------------------------------------------------------------------------
-- Snap a requested size to the nearest available named font
-- ---------------------------------------------------------------------------
-- Returns fontName, nominalSize. Ties round up (a slightly-too-big label is
-- more readable at couch distance than a slightly-too-small one, which is the
-- whole point of the size slider on console).
function UP.Fonts.Nearest(sizePx, bold)
    local ladder = bold and BOLD_LADDER or MEDIUM_LADDER
    local want = tonumber(sizePx) or 27

    local bestName, bestSize, bestDist
    for _, entry in ipairs(ladder) do
        local size, name = entry[1], entry[2]
        local dist = math.abs(size - want)
        -- "<=" makes ties resolve to the later (larger) ladder entry.
        if bestDist == nil or dist <= bestDist then
            bestDist, bestSize, bestName = dist, size, name
        end
    end
    return bestName, bestSize
end

-- ---------------------------------------------------------------------------
-- Apply a font to a control, safely
-- ---------------------------------------------------------------------------
-- Never throws. Returns the font name applied, or nil if it could not be
-- applied. A nil return is worth logging but must never abort a caller --
-- see the module header for why an init-time font throw is catastrophic.
function UP.Fonts.Apply(ctrl, sizePx, bold)
    if not (ctrl and ctrl.SetFont) then return nil end
    local name = UP.Fonts.Nearest(sizePx, bold)
    local ok = pcall(ctrl.SetFont, ctrl, name)
    if not ok then
        if UP.Debug and UP.Debug.Log then
            UP.Debug.Log(("font apply FAILED: %s"):format(tostring(name)))
        end
        return nil
    end
    return name
end
