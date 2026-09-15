-- ESO Adventurer Suite
-- v0.29.555 - Character Gear weapon text hard column clamp.
-- Measures the actual weapon/poison cell spacing at runtime and prevents item/set
-- labels from drawing into neighboring columns at any supported UI scale.

local EPC = ESOProgressionCoach
if not EPC or not EPC.CharacterGearScreen then return end

local G = EPC.CharacterGearScreen

local WEAPON_SLOT_029555 = {
    [EQUIP_SLOT_MAIN_HAND] = true,
    [EQUIP_SLOT_OFF_HAND] = true,
    [EQUIP_SLOT_BACKUP_MAIN] = true,
    [EQUIP_SLOT_BACKUP_OFF] = true,
}

local PLAYER_WEAPON_CONTROLS_029555 = {
    "ZO_CharacterEquipmentSlotsMainHand",
    "ZO_CharacterEquipmentSlotsOffHand",
    "ZO_CharacterEquipmentSlotsPoison",
    "ZO_CharacterEquipmentSlotsBackupMain",
    "ZO_CharacterEquipmentSlotsBackupOff",
    "ZO_CharacterEquipmentSlotsBackupPoison",
}

local function Safe029555(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a, b, c, d, e, f, g = pcall(fn, ...)
    if not ok or a == nil then return fallback end
    return a, b, c, d, e, f, g
end

local function Center029555(control)
    if not control or type(control.GetCenter) ~= "function" then return nil, nil end
    local ok, x, y = pcall(control.GetCenter, control)
    if not ok then return nil, nil end
    return tonumber(x), tonumber(y)
end

local function Width029555(control)
    if not control or type(control.GetWidth) ~= "function" then return 0 end
    local ok, value = pcall(control.GetWidth, control)
    return ok and (tonumber(value) or 0) or 0
end

local function MeasuredColumnWidth029555(control, fallback)
    local x, y = Center029555(control)
    if not x or not y then return fallback end

    local ownW = Width029555(control)
    local rowTolerance = math.max(18, ownW * 0.75)
    local nearest = nil

    for _, controlName in ipairs(PLAYER_WEAPON_CONTROLS_029555) do
        local other = rawget(_G, controlName)
        if other and other ~= control then
            local ox, oy = Center029555(other)
            if ox and oy and math.abs(oy - y) <= rowTolerance then
                local distance = math.abs(ox - x)
                if distance > 1 and (not nearest or distance < nearest) then
                    nearest = distance
                end
            end
        end
    end

    if nearest then
        -- Six pixels of breathing room on each side guarantees adjacent centered
        -- labels never touch, even with soft-shadow glyphs.
        return math.max(58, math.min(fallback, math.floor(nearest - 12)))
    end
    return fallback
end

local function ConfigureSingleLine029555(label, width, fontSize)
    if not label then return end
    if type(label.SetDimensions) == "function" then
        pcall(label.SetDimensions, label, width, fontSize + 6)
    end
    if type(label.SetHorizontalAlignment) == "function" then
        pcall(label.SetHorizontalAlignment, label, TEXT_ALIGN_CENTER)
    end
    if type(label.SetVerticalAlignment) == "function" then
        pcall(label.SetVerticalAlignment, label, TEXT_ALIGN_CENTER)
    end
    if type(label.SetMaxLineCount) == "function" then
        pcall(label.SetMaxLineCount, label, 1)
    end
    if type(label.SetWrapMode) == "function" then
        local mode = rawget(_G, "TEXT_WRAP_MODE_ELLIPSIS") or rawget(_G, "TEXT_WRAP_MODE_TRUNCATE")
        if mode ~= nil then pcall(label.SetWrapMode, label, mode) end
    end
end

local function RefreshWeaponText029555(self, slotData, isCompanion)
    if isCompanion or type(slotData) ~= "table" or not WEAPON_SLOT_029555[slotData.slot] then return end

    local control = rawget(_G, slotData.control or "")
    if not control or not control.EASGearName or not control.EASGearSet then return end

    local saved = EPC.saved or {}
    local layout = self.currentLayout
    local scale = type(layout) == "table" and tonumber(layout.scale) or 1
    scale = math.max(0.68, math.min(1.0, scale or 1))

    local slotWidth = Width029555(control)
    if slotWidth <= 0 then
        slotWidth = (tonumber(saved.characterGearSlotSize029206) or 68) * scale
    end

    -- Start near one icon-width, then cap against the real neighboring centers.
    -- This is intentionally much tighter than the old 104-154px block that was
    -- visibly overlapping Main Hand / Off Hand text in the live EQ screen.
    local desiredWidth = math.floor(math.max(66, math.min(112, slotWidth + 18)) + 0.5)
    local width = MeasuredColumnWidth029555(control, desiredWidth)

    local nameFontSize = math.floor(math.max(13, math.min(17, 17 * scale)) + 0.5)
    local setFontSize = math.floor(math.max(12, math.min(15, 15 * scale)) + 0.5)

    control.EASGearName:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", nameFontSize))
    control.EASGearSet:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", setFontSize))
    ConfigureSingleLine029555(control.EASGearName, width, nameFontSize)
    ConfigureSingleLine029555(control.EASGearSet, width, setFontSize)

    -- Each weapon owns a self-contained two-line block directly below its icon.
    control.EASGearName:ClearAnchors()
    control.EASGearName:SetAnchor(TOP, control, BOTTOM, 0, 4)
    control.EASGearSet:ClearAnchors()
    control.EASGearSet:SetAnchor(TOP, control.EASGearName, BOTTOM, 0, 0)

    -- Put set progress first so the useful N/N information remains visible even
    -- when a long localized set name must be ellipsized inside the narrow column.
    local link = Safe029555(GetItemLink, "", BAG_WORN, slotData.slot, LINK_STYLE_DEFAULT or 0) or ""
    if link ~= "" and type(GetItemLinkSetInfo) == "function" then
        local hasSet, setName, _, normalEquipped, maxEquipped, _, perfectedEquipped = Safe029555(GetItemLinkSetInfo, false, link)
        maxEquipped = tonumber(maxEquipped) or 0
        if hasSet and maxEquipped > 0 then
            local count = math.min((tonumber(normalEquipped) or 0) + (tonumber(perfectedEquipped) or 0), maxEquipped)
            local setText = tostring(setName or "Set")
            control.EASGearSet:SetText(string.format("%d/%d • %s", count, maxEquipped, setText))
            control.EASGearSet:SetColor(0.98, 0.99, 1, 1)
            control.EASGearSet:SetHidden(saved.characterGearShowDetails029206 == false or saved.characterGearShowSetCount029206 == false)
        end
    end
end

if type(G.RefreshSlot) == "function" and not G._weaponTextFix029555 then
    G._weaponTextFix029555 = true
    local BaseRefreshSlot029555 = G.RefreshSlot
    function G:RefreshSlot(slotData, isCompanion)
        BaseRefreshSlot029555(self, slotData, isCompanion)
        RefreshWeaponText029555(self, slotData, isCompanion)
    end
end
