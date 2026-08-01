local Strings = Reforged.Strings or {}
Reforged.Strings = Strings

local COLOR = Reforged.COLOR_SECONDARY
local RESET = Reforged.COLOR_RESET

-- Escapes magic Lua pattern characters so the string can be used as a literal in gsub.
function Strings.magicReplace(str, what, with)
    what = zo_strgsub(what, "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1")
    with = zo_strgsub(with, "[%%]", "%%%%")
    return zo_strgsub(str, what, with)
end

-- Formats a bilingual string according to the display mode.
-- Inline format (single line): used for names, locations, NPC titles.
-- Tooltip format (newline): used for item tooltips, ability names.
function Strings.buildDouble(ptText, enText, mode, newline)
    local sep = newline and "\n" or " "
    if mode == "bren" then
        return string.format("%s%s%s(%s)%s", ptText, sep, COLOR, enText, RESET)
    elseif mode == "enbr" then
        return string.format("%s%s%s(%s)%s", enText, sep, COLOR, ptText, RESET)
    elseif mode == "en" then
        return enText
    end
    return ptText  -- "br" or unknown
end

-- Removes ESO color/markup codes and lowercases the result for use as a lookup key.
function Strings.toKey(text)
    return zo_strlower(ZO_CachedStrFormat("<<z:1>>", text))
end
