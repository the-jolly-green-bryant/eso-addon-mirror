if LawfulNecromancy == nil then LawfulNecromancy = { } end
local LawfulNecromancy = _G['LawfulNecromancy']
local L = { }

-- [[ Slash Command ]]
L.slash = { }
L.slash.block_in_combat_enabled  = "Kriminelle Fähigkeiten beliben im Kampf gesperrt."
L.slash.block_in_combat_disabled = "Kriminelle Fähigkeiten werden automatisch im Kampf entsperrt."

-- [[ Keybindings ]]
local kb = { }
kb.SI_BINDING_NAME_LAWFULNECROMANCY_UNBLOCK = "Temporär erlauben"

for i, v in pairs(kb) do
    ZO_CreateStringId(i, v)
end

function LawfulNecromancy:GetLocale()
    return L
end
