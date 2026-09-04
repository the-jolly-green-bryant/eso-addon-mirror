local Fonts = Chorus.Fonts

Fonts.BUILTIN = {
    { key = "univers-bold", label = "Univers Bold (game default)", face = "$(BOLD_FONT)", secondary = "$(MEDIUM_FONT)" },
    { key = "univers",      label = "Univers",                     face = "$(MEDIUM_FONT)", secondary = "$(MEDIUM_FONT)" },
    { key = "antique",      label = "Trajan (antique)",            face = "$(ANTIQUE_FONT)" },
    { key = "handwritten",  label = "Handwritten",                 face = "$(HANDWRITTEN_FONT)" },
    { key = "stone",        label = "Stone tablet",                face = "$(STONE_TABLET_FONT)" },
    { key = "futura",       label = "Futura (gamepad)",            face = "$(GAMEPAD_BOLD_FONT)", secondary = "$(GAMEPAD_MEDIUM_FONT)" },
}
Fonts.DEFAULT = "univers-bold"

local function lmp() local L = _G.LibMediaProvider; return L and L.Fetch and L end

function Fonts.List()
    local out = {}
    for _, f in ipairs(Fonts.BUILTIN) do out[#out + 1] = f end
    local L = lmp()
    if L and L.List then
        local ok, names = pcall(L.List, L, "font")
        if ok and type(names) == "table" then
            table.sort(names)
            for _, name in ipairs(names) do out[#out + 1] = { key = "lmp:" .. name, label = name } end
        end
    end
    return out
end

function Fonts.Resolve(key)
    for _, f in ipairs(Fonts.BUILTIN) do
        if f.key == key then return f.face, f.secondary or f.face end
    end
    if type(key) == "string" and key:sub(1, 4) == "lmp:" then
        local L = lmp()
        if L then
            local ok, path = pcall(L.Fetch, L, "font", key:sub(5))
            if ok and type(path) == "string" and path ~= "" then return path, path end
        end
    end
    return Fonts.Resolve(Fonts.DEFAULT)
end

function Fonts.Choices()
    local names, values = {}, {}
    for i, f in ipairs(Fonts.List()) do names[i], values[i] = f.label, f.key end
    return names, values
end
