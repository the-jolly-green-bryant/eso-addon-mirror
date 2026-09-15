-- ESO Adventurer Suite
-- v0.29.500 - tighten armor/jewelry item-name to set-name spacing.
-- Keeps long names readable while removing the empty reserved second line from
-- ordinary one-line gear names. Weapon-grid spacing is intentionally untouched.

local EPC = ESOProgressionCoach
if not EPC or not EPC.CharacterGearScreen then return end
local G = EPC.CharacterGearScreen

if G._easArmorTextSpacing029500 then return end
G._easArmorTextSpacing029500 = true

local BaseRefreshSlot029500 = G.RefreshSlot
if type(BaseRefreshSlot029500) ~= "function" then return end

local function TightenArmorText029500(slotData)
    if type(slotData) ~= "table" or slotData.weaponCol ~= nil then return end
    local controlName = slotData.control
    local control = controlName and rawget(_G, controlName) or nil
    if not control then return end

    local nameLabel = control.EASGearName
    local setLabel = control.EASGearSet
    if not nameLabel or not setLabel then return end
    if nameLabel.IsHidden and nameLabel:IsHidden() then return end

    local width = tonumber(nameLabel.GetWidth and nameLabel:GetWidth()) or 0
    local currentHeight = tonumber(nameLabel.GetHeight and nameLabel:GetHeight()) or 0
    if width <= 0 or currentHeight <= 0 then return end

    local textHeight = nil
    if type(nameLabel.GetTextHeight) == "function" then
        local ok, measured = pcall(nameLabel.GetTextHeight, nameLabel)
        if ok then textHeight = tonumber(measured) end
    end

    -- ESO labels may report a zero/empty text height for a frame immediately
    -- after SetText. Fall back to a conservative one-line height derived from
    -- the existing two-line reservation instead of guessing a font metric.
    if not textHeight or textHeight <= 0 then
        textHeight = math.max(18, math.floor(currentHeight * 0.52 + 0.5))
    end

    -- Preserve genuine two-line item names, but eliminate unused vertical space
    -- for the common one-line case. The small padding keeps glyph descenders and
    -- soft shadows from being clipped.
    local desiredHeight = math.max(20, math.min(currentHeight, math.ceil(textHeight + 3)))
    if math.abs(desiredHeight - currentHeight) >= 2 and type(nameLabel.SetHeight) == "function" then
        pcall(nameLabel.SetHeight, nameLabel, desiredHeight)
    end
end

function G:RefreshSlot(slotData, isCompanion)
    BaseRefreshSlot029500(self, slotData, isCompanion)
    TightenArmorText029500(slotData)
end
