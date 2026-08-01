if LawfulNecromancy == nil then LawfulNecromancy = { } end
local LawfulNecromancy = _G['LawfulNecromancy']
local L = { }

-- [[ Slash Command ]]
L.slash = { }
L.slash.block_in_combat_enabled  = "Criminal abilities remain blocked in combat."
L.slash.block_in_combat_disabled = "Criminal abilities are now automatically unblocked in combat."

-- [[ Keybindings ]]
local kb = { }
kb.SI_BINDING_NAME_LAWFULNECROMANCY_UNBLOCK = "Temporary unblock"

for i, v in pairs(kb) do
    ZO_CreateStringId(i, v)
end

function LawfulNecromancy:GetLocale()
    return L
end
