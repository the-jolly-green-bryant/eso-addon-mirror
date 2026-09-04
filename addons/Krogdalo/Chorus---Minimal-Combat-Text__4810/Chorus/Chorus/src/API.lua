local API = Chorus.API
local function has(name) return type(_G[name]) == "function" end
API.Has = has
function API.Now() return GetGameTimeMilliseconds() end
function API.Language() if has("GetCVar") then return (GetCVar("language.2") or "en"):lower() end return "en" end
function API.Print(msg) if has("d") then d(msg) else print(msg) end end
local nameCache = {}
function API.ResetNames() nameCache = {} end
function API.AbilityName(id)
    local n = nameCache[id]
    if n then return n end
    n = has("GetAbilityName") and GetAbilityName(id) or ""
    n = Chorus.Format.CleanName(n)
    if n == "" then n = "#" .. tostring(id) end
    nameCache[id] = n
    return n
end
function API.LuiCombatTextEnabled()
    local L = _G.LUIE
    return L and type(L.SV) == "table" and L.SV.CombatText_Enabled == true
end
