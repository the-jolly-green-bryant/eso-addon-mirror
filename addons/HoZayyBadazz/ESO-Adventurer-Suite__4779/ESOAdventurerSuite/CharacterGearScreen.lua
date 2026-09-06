-- ESO Adventurer Suite
-- Copyright (c) 2026 HoZayyBadazz. All Rights Reserved.
-- Suite-native enhanced desktop Character / Equipment presentation.
-- v0.29.226

ESOProgressionCoach = ESOProgressionCoach or {}
local EPC = ESOProgressionCoach
EPC.CharacterGearScreen = EPC.CharacterGearScreen or {}
local G = EPC.CharacterGearScreen

local NS = "ESOAdventurerSuite_CharacterGearScreen029226"
local REF_W, REF_H = 2560, 1440
local MIN_SCALE, MAX_SCALE = 0.68, 1.18
local DEFAULT_SLOT_SIZE = 68
-- v0.29.207: the original source layout was authored around ultrawide screens.
-- The Suite now fits the equipment cluster into the actual free center area between
-- desktop chat/left UI and the inventory/right panel instead of assuming full-screen room.
local SAFE_LEFT_FRACTION = 0.17
local SAFE_RIGHT_FRACTION = 0.69
local SAFE_MARGIN = 24
local COMPACT_LABEL_WIDTH = 360
local DETAILED_LABEL_WIDTH = 420
local WEAPON_Y = 425
local OUTFIT_ICON = "EsoUI/Art/Dye/dyes_tabicon_dye_down.dds"
local COSTUME_ICON = "EsoUI/Art/Dye/dyes_tabicon_costumedye_down.dds"

local PLAYER_SLOTS = {
    { slot=EQUIP_SLOT_HEAD, control="ZO_CharacterEquipmentSlotsHead", x=-575, y=-535, side="right", outfit=OUTFIT_SLOT_HEAD },
    { slot=EQUIP_SLOT_SHOULDERS, control="ZO_CharacterEquipmentSlotsShoulder", x=-575, y=-335, side="right", outfit=OUTFIT_SLOT_SHOULDERS },
    { slot=EQUIP_SLOT_HAND, control="ZO_CharacterEquipmentSlotsGlove", x=-575, y=-135, side="right", outfit=OUTFIT_SLOT_HANDS },
    { slot=EQUIP_SLOT_RING1, control="ZO_CharacterEquipmentSlotsRing1", x=-575, y=65, side="right" },
    { slot=EQUIP_SLOT_LEGS, control="ZO_CharacterEquipmentSlotsLeg", x=-575, y=265, side="right", outfit=OUTFIT_SLOT_LEGS },
    { slot=EQUIP_SLOT_NECK, control="ZO_CharacterEquipmentSlotsNeck", x=575, y=-535, side="left" },
    { slot=EQUIP_SLOT_CHEST, control="ZO_CharacterEquipmentSlotsChest", x=575, y=-335, side="left", outfit=OUTFIT_SLOT_CHEST },
    { slot=EQUIP_SLOT_WAIST, control="ZO_CharacterEquipmentSlotsBelt", x=575, y=-135, side="left", outfit=OUTFIT_SLOT_WAIST },
    { slot=EQUIP_SLOT_RING2, control="ZO_CharacterEquipmentSlotsRing2", x=575, y=65, side="left" },
    { slot=EQUIP_SLOT_FEET, control="ZO_CharacterEquipmentSlotsFoot", x=575, y=265, side="left", outfit=OUTFIT_SLOT_FEET },
    { slot=EQUIP_SLOT_MAIN_HAND, control="ZO_CharacterEquipmentSlotsMainHand", weaponCol=-1, weaponRow=-1, side="left", weaponOutfit=1 },
    { slot=EQUIP_SLOT_OFF_HAND, control="ZO_CharacterEquipmentSlotsOffHand", weaponCol=1, weaponRow=-1, side="right", weaponOutfit=2 },
    { slot=EQUIP_SLOT_BACKUP_MAIN, control="ZO_CharacterEquipmentSlotsBackupMain", weaponCol=-1, weaponRow=1, side="left", weaponOutfit=3 },
    { slot=EQUIP_SLOT_BACKUP_OFF, control="ZO_CharacterEquipmentSlotsBackupOff", weaponCol=1, weaponRow=1, side="right", weaponOutfit=4 },
    { slot=EQUIP_SLOT_POISON, control="ZO_CharacterEquipmentSlotsPoison", weaponCol=0, weaponRow=-1, side="left", poison=true },
    { slot=EQUIP_SLOT_BACKUP_POISON, control="ZO_CharacterEquipmentSlotsBackupPoison", weaponCol=0, weaponRow=1, side="left", poison=true },
}

local COMPANION_SLOTS = {
    { slot=EQUIP_SLOT_HEAD, control="ZO_CompanionCharacterWindow_Keyboard_TopLevelEquipmentSlotsHead", x=-575, y=-535, side="right", outfit=OUTFIT_SLOT_HEAD },
    { slot=EQUIP_SLOT_SHOULDERS, control="ZO_CompanionCharacterWindow_Keyboard_TopLevelEquipmentSlotsShoulder", x=-575, y=-335, side="right", outfit=OUTFIT_SLOT_SHOULDERS },
    { slot=EQUIP_SLOT_HAND, control="ZO_CompanionCharacterWindow_Keyboard_TopLevelEquipmentSlotsGlove", x=-575, y=-135, side="right", outfit=OUTFIT_SLOT_HANDS },
    { slot=EQUIP_SLOT_RING1, control="ZO_CompanionCharacterWindow_Keyboard_TopLevelEquipmentSlotsRing1", x=-575, y=65, side="right" },
    { slot=EQUIP_SLOT_LEGS, control="ZO_CompanionCharacterWindow_Keyboard_TopLevelEquipmentSlotsLeg", x=-575, y=265, side="right", outfit=OUTFIT_SLOT_LEGS },
    { slot=EQUIP_SLOT_NECK, control="ZO_CompanionCharacterWindow_Keyboard_TopLevelEquipmentSlotsNeck", x=575, y=-535, side="left" },
    { slot=EQUIP_SLOT_CHEST, control="ZO_CompanionCharacterWindow_Keyboard_TopLevelEquipmentSlotsChest", x=575, y=-335, side="left", outfit=OUTFIT_SLOT_CHEST },
    { slot=EQUIP_SLOT_WAIST, control="ZO_CompanionCharacterWindow_Keyboard_TopLevelEquipmentSlotsBelt", x=575, y=-135, side="left", outfit=OUTFIT_SLOT_WAIST },
    { slot=EQUIP_SLOT_RING2, control="ZO_CompanionCharacterWindow_Keyboard_TopLevelEquipmentSlotsRing2", x=575, y=65, side="left" },
    { slot=EQUIP_SLOT_FEET, control="ZO_CompanionCharacterWindow_Keyboard_TopLevelEquipmentSlotsFoot", x=575, y=265, side="left", outfit=OUTFIT_SLOT_FEET },
    { slot=EQUIP_SLOT_MAIN_HAND, control="ZO_CompanionCharacterWindow_Keyboard_TopLevelEquipmentSlotsMainHand", weaponCol=-1, weaponRow=0, side="left", weaponOutfit=1 },
    { slot=EQUIP_SLOT_OFF_HAND, control="ZO_CompanionCharacterWindow_Keyboard_TopLevelEquipmentSlotsOffHand", weaponCol=1, weaponRow=0, side="right", weaponOutfit=2 },
}

local DURABILITY_SLOTS = {
    [EQUIP_SLOT_HEAD]=true, [EQUIP_SLOT_SHOULDERS]=true, [EQUIP_SLOT_CHEST]=true,
    [EQUIP_SLOT_HAND]=true, [EQUIP_SLOT_WAIST]=true, [EQUIP_SLOT_LEGS]=true, [EQUIP_SLOT_FEET]=true,
}
local WEAPON_SLOTS = {
    [EQUIP_SLOT_MAIN_HAND]=true, [EQUIP_SLOT_OFF_HAND]=true,
    [EQUIP_SLOT_BACKUP_MAIN]=true, [EQUIP_SLOT_BACKUP_OFF]=true,
}
local COSTUME_SLOTS = {
    [EQUIP_SLOT_HEAD]=true, [EQUIP_SLOT_SHOULDERS]=true, [EQUIP_SLOT_CHEST]=true,
    [EQUIP_SLOT_HAND]=true, [EQUIP_SLOT_WAIST]=true, [EQUIP_SLOT_LEGS]=true, [EQUIP_SLOT_FEET]=true,
}

local function Safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a, b, c, d, e, f, g = pcall(fn, ...)
    if not ok then return fallback end
    return a, b, c, d, e, f, g
end

local function SafeNumber(fn, fallback, ...)
    -- Capture only the first return value before calling tonumber(). Passing all
    -- Safe() returns directly into tonumber() can accidentally make return #2 the
    -- numeric base argument (for example GetActiveCompanionLevelInfo()).
    local value = Safe(fn, fallback, ...)
    local n = tonumber(value)
    if n == nil then return tonumber(fallback) or 0 end
    return n
end

local function Clamp(v, lo, hi)
    v = tonumber(v) or lo
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

local function CaptureControlState(control)
    if not control then return nil end
    local state = { control = control, anchors = {} }
    if control.GetNumAnchors and control.GetAnchor then
        local count = SafeNumber(control.GetNumAnchors, 0, control) or 0
        for i = 1, count do
            local point, relativeTo, relativePoint, x, y = Safe(control.GetAnchor, nil, control, i)
            if point then state.anchors[#state.anchors + 1] = {point, relativeTo, relativePoint, x or 0, y or 0} end
        end
    end
    state.width = SafeNumber(control.GetWidth, nil, control)
    state.height = SafeNumber(control.GetHeight, nil, control)
    state.scale = SafeNumber(control.GetScale, nil, control)
    state.hidden = Safe(control.IsHidden, nil, control)
    state.mouseEnabled = Safe(control.IsMouseEnabled, nil, control)
    return state
end

local function RestoreControlState(state)
    if not state or not state.control then return end
    local control = state.control
    if control.ClearAnchors and control.SetAnchor and state.anchors then
        pcall(control.ClearAnchors, control)
        for _, a in ipairs(state.anchors) do
            pcall(control.SetAnchor, control, a[1], a[2], a[3], a[4], a[5])
        end
    end
    if state.scale and control.SetScale then pcall(control.SetScale, control, state.scale) end
    if state.width and state.height and control.SetDimensions then pcall(control.SetDimensions, control, state.width, state.height) end
    if state.hidden ~= nil and control.SetHidden then pcall(control.SetHidden, control, state.hidden) end
    if state.mouseEnabled ~= nil and control.SetMouseEnabled then pcall(control.SetMouseEnabled, control, state.mouseEnabled) end
end

local function RestoreCapturedControlState(states, control)
    if not states or not control then return false end
    for _, state in ipairs(states) do
        if state and state.control == control then
            RestoreControlState(state)
            return true
        end
    end
    return false
end

local function LayoutScale()
    local w, h = 1920, 1080
    if GuiRoot and GuiRoot.GetDimensions then
        local ok, rw, rh = pcall(GuiRoot.GetDimensions, GuiRoot)
        if ok and tonumber(rw) and tonumber(rh) then w, h = rw, rh end
    end
    return Clamp(math.min(w / REF_W, h / REF_H), MIN_SCALE, MAX_SCALE)
end

local function RootDimensions()
    local w, h = 1920, 1080
    if GuiRoot and GuiRoot.GetDimensions then
        local ok, rw, rh = pcall(GuiRoot.GetDimensions, GuiRoot)
        if ok and tonumber(rw) and tonumber(rh) and rw > 0 and rh > 0 then w, h = rw, rh end
    end
    return w, h
end

local function VisibleLeft(control)
    if not control or (control.IsHidden and control:IsHidden()) or not control.GetLeft then return nil end
    local ok, left = pcall(control.GetLeft, control)
    left = ok and tonumber(left) or nil
    if left and left > 0 then return left end
    return nil
end


local function ControlName(control)
    if not control or not control.GetName then return nil end
    local ok, name = pcall(control.GetName, control)
    return ok and name or nil
end

function G:HideCompanionNativeChildren()
    local root = rawget(_G, "ZO_CompanionCharacterWindow_Keyboard_TopLevel")
    if not root or not root.GetNumChildren or not root.GetChild then return end
    local keep = {}
    for _, slotData in ipairs(COMPANION_SLOTS) do
        keep[slotData.control] = true
    end
    keep["ZO_CompanionCharacterWindow_Keyboard_TopLevel"] = true

    local count = SafeNumber(root.GetNumChildren, 0, root) or 0
    self._hiddenCompanionChildren = self._hiddenCompanionChildren or {}
    for i = 1, count do
        local child = Safe(root.GetChild, nil, root, i)
        local name = ControlName(child)
        if child and name and not keep[name] then
            self._hiddenCompanionChildren[name] = true
            if child.SetHidden then pcall(child.SetHidden, child, true) end
        end
    end
end

function G:BuildAdaptiveLayout(isCompanion)
    local w, h = RootDimensions()
    local scale = LayoutScale()
    local adaptive = EPC.saved.characterGearAdaptiveLayout029207 ~= false
    local safeLeft, safeRight
    if isCompanion and adaptive then
        -- v0.29.222: keep the companion layout centered more naturally between
        -- the left/right gear icons while still leaving room for the native
        -- companion information panel farther to the right.
        safeLeft = w * 0.07
        safeRight = w * 0.67
    else
        safeLeft = adaptive and (w * SAFE_LEFT_FRACTION) or (w * 0.18)
        safeRight = adaptive and (w * SAFE_RIGHT_FRACTION) or (w * 0.82)
    end

    if adaptive then
        local inventory = rawget(_G, "ZO_PlayerInventory")
        local invLeft = VisibleLeft(inventory)
        if invLeft then safeRight = math.min(safeRight, invLeft - SAFE_MARGIN) end
    end

    safeLeft = Clamp(safeLeft, 24, w - 420)
    safeRight = Clamp(safeRight, safeLeft + 720, w - 24)
    local centerX = (safeLeft + safeRight) * 0.5
    local available = safeRight - safeLeft
    local density = tostring(EPC.saved.characterGearDensity029207 or "compact")
    if density ~= "compact" and density ~= "detailed" and density ~= "icons" then density = "compact" end
    local baseLabel = density == "detailed" and DETAILED_LABEL_WIDTH or COMPACT_LABEL_WIDTH
    if density == "icons" then baseLabel = 24 end
    local labelWidth = Clamp(baseLabel * math.max(scale, 0.92), 240, density == "detailed" and 420 or 360)
    local slotSize = Clamp(EPC.saved.characterGearSlotSize029206, 64, 128) * scale
    local reserve = density == "icons" and 52 or (labelWidth + slotSize * 0.55 + 18)
    local half = available * 0.5
    local spread = Clamp(math.min(470 * scale, half - reserve), 270 * scale, 470 * scale)
    if density == "icons" then spread = Clamp(math.min(470 * scale, half - 70), 265 * scale, 470 * scale) end

    -- Five armor/jewelry rows. The old 200px vertical jumps made the top and
    -- bottom labels collide with headers/keybind strips at 1440p.
    local rowStep = Clamp(150 * scale, 108, 164)
    local topY = -2 * rowStep - 25 * scale
    local weaponY = Clamp(WEAPON_Y * scale, 315, math.max(330, h * 0.34))

    return {
        w=w, h=h, scale=scale, safeLeft=safeLeft, safeRight=safeRight,
        centerX=centerX, centerY=h*0.5, available=available, spread=spread,
        labelWidth=labelWidth, density=density, rowStep=rowStep, topY=topY,
        weaponY=weaponY, slotSize=slotSize,
    }
end

local function ShouldShowStats(layout)
    local mode = tostring(EPC.saved.characterGearStatsMode029207 or "auto")
    if mode == "show" then return true end
    if mode == "hide" then return false end
    -- Auto: on standard 16:9/1440p layouts the inventory + gear cluster already
    -- consume the center/right area. Keep the full native stat list off that canvas.
    return (layout.w or 0) >= 3200 and (layout.available or 0) >= 1350
end

local function CreateLabel(name, parent, font)
    local c = WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)
    c:SetFont(font or "ZoFontGameSmall")
    c:SetMouseEnabled(false)
    c:SetDrawLayer(DL_OVERLAY)
    c:SetDrawLevel(8)
    c:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    return c
end

local function CreateTexture(name, parent, texture)
    local c = WINDOW_MANAGER:CreateControl(name, parent, CT_TEXTURE)
    c:SetTexture(texture)
    c:SetMouseEnabled(false)
    c:SetDrawLayer(DL_OVERLAY)
    c:SetDrawLevel(8)
    return c
end


-- v0.29.224: contained left-side stats card for both Player and Companion.
-- This intentionally does not re-enable the full-screen native black backdrop.
local GEAR_STATS_ROWS = {
    { label="Maximum Magicka", power="POWERTYPE_MAGICKA" },
    { label="Magicka Recovery", stat="STAT_MAGICKA_REGEN_COMBAT" },
    { label="Maximum Health", power="POWERTYPE_HEALTH" },
    { label="Health Recovery", stat="STAT_HEALTH_REGEN_COMBAT" },
    { label="Maximum Stamina", power="POWERTYPE_STAMINA" },
    { label="Stamina Recovery", stat="STAT_STAMINA_REGEN_COMBAT" },
    { spacer=true },
    { label="Spell Damage", stat="STAT_SPELL_POWER", fallback="STAT_WEAPON_AND_SPELL_DAMAGE" },
    { label="Spell Critical", stat="STAT_SPELL_CRITICAL", critical=true },
    { label="Spell Penetration", stat="STAT_SPELL_PENETRATION", fallback="STAT_OFFENSIVE_PENETRATION" },
    { label="Weapon Damage", stat="STAT_WEAPON_POWER", fallback="STAT_ATTACK_POWER", fallback2="STAT_WEAPON_AND_SPELL_DAMAGE" },
    { label="Weapon Critical", stat="STAT_CRITICAL_STRIKE", critical=true },
    { label="Physical Penetration", stat="STAT_PHYSICAL_PENETRATION", fallback="STAT_OFFENSIVE_PENETRATION" },
    { spacer=true },
    { label="Spell Resistance", stat="STAT_SPELL_RESIST" },
    { label="Physical Resistance", stat="STAT_PHYSICAL_RESIST" },
    { label="Critical Resistance", stat="STAT_CRITICAL_RESISTANCE" },
}

local function GearReadPowerMax(unitTag, powerName)
    local powerType = rawget(_G, powerName or "")
    if powerType == nil or type(GetUnitPower) ~= "function" then return 0 end
    local current, maximum = Safe(GetUnitPower, 0, unitTag, powerType)
    maximum = tonumber(maximum) or 0
    if maximum <= 0 then maximum = tonumber(current) or 0 end
    return maximum
end

local function GearReadPlayerStat(statName)
    local stat = rawget(_G, statName or "")
    if stat == nil or type(GetPlayerStat) ~= "function" then return 0 end
    local bonus = rawget(_G, "STAT_BONUS_OPTION_APPLY_BONUS") or rawget(_G, "STAT_BONUS_OPTION_DONT_APPLY_BONUS") or 0
    return SafeNumber(GetPlayerStat, 0, stat, bonus) or 0
end

local function GearReadUnitStat(unitTag, statName)
    if unitTag == "player" then return GearReadPlayerStat(statName) end
    local stat = rawget(_G, statName or "")
    if stat == nil then return 0 end
    local fn = rawget(_G, "GetUnitEffectiveStat")
    if type(fn) == "function" then
        return SafeNumber(fn, 0, unitTag, stat) or 0
    end
    return 0
end

local function GearReadRow(unitTag, row)
    if row.power then return GearReadPowerMax(unitTag, row.power) end
    local value = GearReadUnitStat(unitTag, row.stat)
    if value <= 0 and row.fallback then value = GearReadUnitStat(unitTag, row.fallback) end
    if value <= 0 and row.fallback2 then value = GearReadUnitStat(unitTag, row.fallback2) end
    return tonumber(value) or 0
end

local function GearFormatInteger(value)
    value = tonumber(value) or 0
    if value <= 0 then return "—" end
    value = math.floor(value + 0.5)
    local s = tostring(value)
    while true do
        local n, count = s:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
        s = n
        if count == 0 then break end
    end
    return s
end

local function GearFormatCritical(value)
    value = tonumber(value) or 0
    if value <= 0 then return "—" end
    if type(GetCriticalStrikeChance) == "function" then
        local chance = SafeNumber(GetCriticalStrikeChance, 0, value) or 0
        if chance > 0 then return string.format("%.1f%%", chance) end
    end
    return GearFormatInteger(value)
end

local GEAR_MUNDUS_WORDS = {
    "the thief", "the shadow", "the lover", "the warrior", "the mage", "the tower",
    "the serpent", "the steed", "the lord", "the lady", "the atronach", "the ritual", "the apprentice",
}

local function GearGetMundusName()
    if type(GetNumBuffs) ~= "function" or type(GetUnitBuffInfo) ~= "function" then return "None detected" end
    local count = SafeNumber(GetNumBuffs, 0, "player") or 0
    for i=1,count do
        local name = tostring(Safe(GetUnitBuffInfo, "", "player", i) or "")
        local low = zo_strlower and zo_strlower(name) or string.lower(name)
        if low:find("boon:", 1, true) then return name end
        for _, word in ipairs(GEAR_MUNDUS_WORDS) do
            if low:find(word, 1, true) then return name end
        end
    end
    return "None detected"
end

function G:EnsureGearStatsCard()
    if self.gearStatsCard then return self.gearStatsCard end
    local wm=WINDOW_MANAGER
    local panel=wm:CreateTopLevelWindow(NS .. "GearStatsCard")
    panel:SetDimensions(270, 540)
    panel:SetMouseEnabled(false)
    panel:SetClampedToScreen(true)
    if panel.SetDrawTier and rawget(_G,"DT_HIGH") then panel:SetDrawTier(DT_HIGH) end
    panel:SetDrawLayer(DL_CONTROLS)
    panel:SetDrawLevel(5)

    local bg=wm:CreateControl(nil,panel,CT_BACKDROP)
    bg:SetAnchorFill(panel)
    bg:SetCenterColor(0.01,0.012,0.016,0.76)
    bg:SetEdgeColor(0.30,0.28,0.20,0.72)
    bg:SetEdgeTexture("EsoUI/Art/Tooltips/UI-SliderBackdrop.dds",1,1,1)

    local title=CreateLabel(NS.."GearStatsTitle",panel,"$(BOLD_FONT)|18|soft-shadow-thick")
    title:SetAnchor(TOPLEFT,panel,TOPLEFT,14,9)
    title:SetDimensions(242,26)
    title:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    panel.title=title

    panel.statRows={}
    local y=42
    for i,row in ipairs(GEAR_STATS_ROWS) do
        if row.spacer then
            local div=wm:CreateControl(nil,panel,CT_TEXTURE)
            div:SetTexture("EsoUI/Art/Miscellaneous/white_1x1.dds")
            div:SetColor(0.72,0.62,0.38,0.58)
            div:SetAnchor(TOPLEFT,panel,TOPLEFT,12,y+5)
            div:SetDimensions(246,1)
            y=y+18
        else
            local left=CreateLabel(NS.."GearStatsL"..i,panel,"$(BOLD_FONT)|14|soft-shadow-thick")
            local right=CreateLabel(NS.."GearStatsR"..i,panel,"$(BOLD_FONT)|14|soft-shadow-thick")
            left:SetAnchor(TOPLEFT,panel,TOPLEFT,14,y)
            left:SetDimensions(166,21)
            left:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
            left:SetColor(0.91,0.88,0.70,1)
            left:SetText(row.label)
            right:SetAnchor(TOPRIGHT,panel,TOPRIGHT,-14,y)
            right:SetDimensions(78,21)
            right:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
            right:SetColor(1,1,1,1)
            panel.statRows[#panel.statRows+1]={meta=row,value=right}
            y=y+24
        end
    end

    local div=wm:CreateControl(nil,panel,CT_TEXTURE)
    div:SetTexture("EsoUI/Art/Miscellaneous/white_1x1.dds")
    div:SetColor(0.72,0.62,0.38,0.72)
    div:SetAnchor(BOTTOMLEFT,panel,BOTTOMLEFT,12,-58)
    div:SetDimensions(246,1)

    local footerTitle=CreateLabel(NS.."GearStatsFooterTitle",panel,"$(BOLD_FONT)|16|soft-shadow-thick")
    footerTitle:SetAnchor(BOTTOMLEFT,panel,BOTTOMLEFT,14,-49)
    footerTitle:SetDimensions(242,21)
    footerTitle:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    panel.footerTitle=footerTitle

    local footerValue=CreateLabel(NS.."GearStatsFooterValue",panel,"$(MEDIUM_FONT)|13|soft-shadow-thick")
    footerValue:SetAnchor(BOTTOMLEFT,panel,BOTTOMLEFT,14,-27)
    footerValue:SetDimensions(242,22)
    footerValue:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    footerValue:SetColor(0.70,0.90,1,1)
    panel.footerValue=footerValue

    panel:SetHidden(true)
    self.gearStatsCard=panel
    return panel
end

function G:RefreshGearStatsCard(isCompanion)
    local panel=self:EnsureGearStatsCard()
    local _,h=RootDimensions()
    local cardH=math.min(540,math.max(500,h-170))
    panel:SetDimensions(270,cardH)
    panel:ClearAnchors()
    -- v0.29.236: nudge the left-side stats card upward slightly for both
    -- character and companion screens so it sits a little higher on the page.
    panel:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,22,math.max(56,(h-cardH)*0.46 - 22))
    panel.title:SetText(isCompanion and "COMPANION STATS" or "CHARACTER STATS")
    local tag=isCompanion and "companion" or "player"
    for _,entry in ipairs(panel.statRows) do
        local v=GearReadRow(tag,entry.meta)
        entry.value:SetText(entry.meta.critical and GearFormatCritical(v) or GearFormatInteger(v))
    end
    if isCompanion then
        panel.footerTitle:SetText("COMPANION")
        local name=type(GetUnitName)=="function" and tostring(Safe(GetUnitName,"","companion") or "") or ""
        local level=type(GetActiveCompanionLevelInfo)=="function" and SafeNumber(GetActiveCompanionLevelInfo,0) or 0
        if name=="" then name="Active companion" end
        panel.footerValue:SetText(level>0 and zo_strformat("<<1>>  •  Level <<2>>",name,level) or name)
    else
        panel.footerTitle:SetText("MUNDUS")
        panel.footerValue:SetText(GearGetMundusName())
    end
    panel:SetHidden(false)
end

function G:HideGearStatsCard()
    if self.gearStatsCard then self.gearStatsCard:SetHidden(true) end
end

-- Shift the native Companion information border/panel to the right as one area.
-- The equipment root itself stays centered around the actual companion model.
local function GearShiftControlX(control,dx)
    local controlType=type(control)
    if controlType~="userdata" and controlType~="table" then return false end
    if not control.GetNumAnchors or not control.GetAnchor then return false end
    local count=SafeNumber(control.GetNumAnchors,0,control) or 0
    if count<=0 then return false end
    local anchors={}
    for i=1,count do
        local point,relativeTo,relativePoint,x,y=Safe(control.GetAnchor,nil,control,i)
        if point then anchors[#anchors+1]={point,relativeTo,relativePoint,tonumber(x) or 0,tonumber(y) or 0} end
    end
    if #anchors==0 then return false end
    local okClear=pcall(control.ClearAnchors,control)
    if not okClear then return false end
    for _,a in ipairs(anchors) do
        local okAnchor=pcall(control.SetAnchor,control,a[1],a[2],a[3],a[4]+dx,a[5])
        if not okAnchor then return false end
    end
    return true
end

local function GearCompanionInfoCandidate(control,name,w)
    local controlType=type(control)
    if controlType~="userdata" and controlType~="table" then return false end
    if not control.GetLeft or not control.GetWidth then return false end
    name=tostring(name or "")
    if name=="" or name=="ZO_CompanionCharacterWindow_Keyboard_TopLevel" then return false end
    if name:find("EquipmentSlots",1,true) or name:find("PaperDoll",1,true) then return false end
    if not name:find("Companion",1,true) then return false end
    local parent=control.GetParent and Safe(control.GetParent,nil,control) or nil
    if parent and parent~=GuiRoot then return false end
    local left=SafeNumber(control.GetLeft,0,control) or 0
    local width=SafeNumber(control.GetWidth,0,control) or 0
    return left>=w*0.43 and width>=120
end

function G:ShiftCompanionInfoPanelRight(layout)
    if self.companionInfoShiftApplied then return end
    local w=(layout and layout.w) or select(1,RootDimensions())
    local dx=Clamp(w*0.12,170,235)
    local targets,seen={},{}
    local function add(c)
        local ct=type(c)
        if ct~="userdata" and ct~="table" then return end
        if not c.GetNumAnchors or not c.GetAnchor then return end
        if not seen[c] then seen[c]=true; targets[#targets+1]=c end
    end
    -- v0.29.225 SECURITY/TAINT FIX:
    -- Never enumerate _G here. ESO exposes protected/private entries in the
    -- global environment (for example PlayDefaultQuickChat), and touching them
    -- from insecure addon code can taint the call stack. Only inspect a small,
    -- explicit whitelist of known UI controls.
    local controlNames={
        "ZO_SharedRightPanelBackground",
        "ZO_CompanionCharacter_Keyboard",
        "ZO_CompanionCharacter_Keyboard_TopLevel",
        "ZO_Companion_Keyboard",
        "ZO_CompanionCharacterOverview_Keyboard",
        "ZO_CompanionCharacterInfo_Keyboard",
        "ZO_CompanionCharacterWindow_Keyboard",
        "ZO_CompanionCharacterWindow_Keyboard_TopLevel",
    }
    for _,name in ipairs(controlNames) do
        local control=rawget(_G,name)
        if control and (name=="ZO_SharedRightPanelBackground" or GearCompanionInfoCandidate(control,name,w)) then
            add(control)
        end
    end
    self.companionInfoOriginal={}
    for _,c in ipairs(targets) do
        if c and c~=rawget(_G,"ZO_CompanionCharacterWindow_Keyboard_TopLevel") then
            local state=CaptureControlState(c)
            if state and GearShiftControlX(c,dx) then self.companionInfoOriginal[#self.companionInfoOriginal+1]=state end
        end
    end
    self.companionInfoShiftApplied=true
end

function G:RestoreCompanionInfoPanel()
    if self.companionInfoOriginal then
        for _,state in ipairs(self.companionInfoOriginal) do RestoreControlState(state) end
    end
    self.companionInfoOriginal=nil
    self.companionInfoShiftApplied=false
end

local WORKSPACE_VIGNETTE_TEXTURE = "ESOAdventurerSuite/Art029125/character_gear_vignette.dds"

local function EnsureWorkspaceBackdrop(self)
    -- v0.29.216: backdrop removed by request. The Character Gear screen now
    -- relies on larger icons and fonts for readability instead of a dark panel.
    return nil
end

function G:HideWorkspaceBackdrop()
    if self.workspaceBackdrop and self.workspaceBackdrop.SetHidden then
        self.workspaceBackdrop:SetHidden(true)
    end
end

function G:LayoutWorkspaceBackdrop(layout)
    self:HideWorkspaceBackdrop()
end

local function EnsureSlotBackdrop(slot)
    if slot.EASGearBackdrop then return slot.EASGearBackdrop end
    local bg = WINDOW_MANAGER:CreateControl(slot:GetName() .. "EASGearBackdrop", slot, CT_BACKDROP)
    bg:SetMouseEnabled(false)
    bg:SetDrawLayer(DL_BACKGROUND)
    bg:SetDrawLevel(0)
    bg:SetEdgeTexture("EsoUI/Art/Miscellaneous/white_1x1.dds", 1, 1, 2)
    slot.EASGearBackdrop = bg
    return bg
end

local function LayoutSlotBackdrop(slot, hasItem, edgeR, edgeG, edgeB, edgeA)
    if not slot then return end
    local bg = EnsureSlotBackdrop(slot)
    local pad = math.max(4, math.floor((slot:GetWidth() or 64) * 0.08))
    bg:ClearAnchors()
    bg:SetAnchor(TOPLEFT, slot, TOPLEFT, -pad, -pad)
    bg:SetAnchor(BOTTOMRIGHT, slot, BOTTOMRIGHT, pad, pad)
    if hasItem then
        local rr, gg, bb = tonumber(edgeR), tonumber(edgeG), tonumber(edgeB)
        if rr and gg and bb then
            bg:SetCenterColor(0.04 + rr * 0.18, 0.045 + gg * 0.18, 0.06 + bb * 0.18, 0.97)
        else
            bg:SetCenterColor(0.05, 0.06, 0.09, 0.92)
        end
        bg:SetEdgeColor(rr or 0.78, gg or 0.67, bb or 0.38, 1)
    else
        bg:SetCenterColor(0.035, 0.045, 0.07, 0.78)
        bg:SetEdgeColor(0.46, 0.48, 0.56, 0.44)
    end
    bg:SetHidden(false)
end

local function HideSlotBackdrop(slot)
    if slot and slot.EASGearBackdrop then
        slot.EASGearBackdrop:SetHidden(true)
    end
end

local function EnsureBorder(slot)
    if slot.EASGearBorderLines then return slot.EASGearBorderLines, slot.EASGearGlowLines, slot.EASGearHaloLines end

    -- v0.29.228 rarity glow boost:
    -- Use THREE visible layers on GuiRoot: a bright solid border, a strong glow,
    -- and a larger outer halo so rarity colors pop immediately.
    local lines, glowLines, haloLines = {}, {}, {}
    local baseName = slot:GetName() or (NS .. "AnonymousGearSlot")
    for i = 1, 4 do
        local halo = WINDOW_MANAGER:CreateControl(baseName .. "EASGearRarityHalo" .. i, GuiRoot, CT_TEXTURE)
        halo:SetTexture("EsoUI/Art/Miscellaneous/white_1x1.dds")
        halo:SetMouseEnabled(false)
        if halo.SetDrawTier and rawget(_G, "DT_HIGH") then halo:SetDrawTier(DT_HIGH) end
        halo:SetDrawLayer(DL_OVERLAY)
        halo:SetDrawLevel(90)
        haloLines[i] = halo

        local glow = WINDOW_MANAGER:CreateControl(baseName .. "EASGearRarityGlow" .. i, GuiRoot, CT_TEXTURE)
        glow:SetTexture("EsoUI/Art/Miscellaneous/white_1x1.dds")
        glow:SetMouseEnabled(false)
        if glow.SetDrawTier and rawget(_G, "DT_HIGH") then glow:SetDrawTier(DT_HIGH) end
        glow:SetDrawLayer(DL_OVERLAY)
        glow:SetDrawLevel(95)
        glowLines[i] = glow

        local line = WINDOW_MANAGER:CreateControl(baseName .. "EASGearRarityFrame" .. i, GuiRoot, CT_TEXTURE)
        line:SetTexture("EsoUI/Art/Miscellaneous/white_1x1.dds")
        line:SetMouseEnabled(false)
        if line.SetDrawTier and rawget(_G, "DT_HIGH") then line:SetDrawTier(DT_HIGH) end
        line:SetDrawLayer(DL_OVERLAY)
        line:SetDrawLevel(100)
        lines[i] = line
    end
    slot.EASGearBorderLines = lines
    slot.EASGearGlowLines = glowLines
    slot.EASGearHaloLines = haloLines
    return lines, glowLines, haloLines
end

local function LayoutBorder(slot, r, g, b, a)
    local lines, glowLines, haloLines = EnsureBorder(slot)
    local width = tonumber(slot:GetWidth()) or 64

    -- Even larger pads and thicker glow so the effect is obvious.
    local pad = math.max(7, math.floor(width * 0.11))
    local thickness = math.max(7, math.floor(width / 12))
    local glowPad = pad + math.max(5, math.floor(width * 0.07))
    local glowThickness = thickness + math.max(8, math.floor(width / 8))
    local haloPad = glowPad + math.max(4, math.floor(width * 0.06))
    local haloThickness = glowThickness + math.max(8, math.floor(width / 7))

    local top, right, bottom, left = lines[1], lines[2], lines[3], lines[4]
    local gTop, gRight, gBottom, gLeft = glowLines[1], glowLines[2], glowLines[3], glowLines[4]
    local hTop, hRight, hBottom, hLeft = haloLines[1], haloLines[2], haloLines[3], haloLines[4]

    local function anchorHorizontal(control, topEdge, extraPad, h)
        control:ClearAnchors()
        if topEdge then
            control:SetAnchor(TOPLEFT, slot, TOPLEFT, -extraPad, -extraPad)
            control:SetAnchor(TOPRIGHT, slot, TOPRIGHT, extraPad, -extraPad)
        else
            control:SetAnchor(BOTTOMLEFT, slot, BOTTOMLEFT, -extraPad, extraPad)
            control:SetAnchor(BOTTOMRIGHT, slot, BOTTOMRIGHT, extraPad, extraPad)
        end
        control:SetHeight(h)
    end

    local function anchorVertical(control, leftEdge, extraPad, w)
        control:ClearAnchors()
        if leftEdge then
            control:SetAnchor(TOPLEFT, slot, TOPLEFT, -extraPad, -extraPad)
            control:SetAnchor(BOTTOMLEFT, slot, BOTTOMLEFT, -extraPad, extraPad)
        else
            control:SetAnchor(TOPRIGHT, slot, TOPRIGHT, extraPad, -extraPad)
            control:SetAnchor(BOTTOMRIGHT, slot, BOTTOMRIGHT, extraPad, extraPad)
        end
        control:SetWidth(w)
    end

    anchorHorizontal(top, true, pad, thickness)
    anchorHorizontal(bottom, false, pad, thickness)
    anchorVertical(left, true, pad, thickness)
    anchorVertical(right, false, pad, thickness)

    anchorHorizontal(gTop, true, glowPad, glowThickness)
    anchorHorizontal(gBottom, false, glowPad, glowThickness)
    anchorVertical(gLeft, true, glowPad, glowThickness)
    anchorVertical(gRight, false, glowPad, glowThickness)

    anchorHorizontal(hTop, true, haloPad, haloThickness)
    anchorHorizontal(hBottom, false, haloPad, haloThickness)
    anchorVertical(hLeft, true, haloPad, haloThickness)
    anchorVertical(hRight, false, haloPad, haloThickness)

    -- Stronger brightness push while preserving the rarity hue.
    local rr = math.min(1, (tonumber(r) or 1) * 1.32 + 0.14)
    local gg = math.min(1, (tonumber(g) or 1) * 1.32 + 0.14)
    local bb = math.min(1, (tonumber(b) or 1) * 1.32 + 0.14)

    for _, halo in ipairs(haloLines) do
        halo:SetColor(rr, gg, bb, 0.22)
        halo:SetHidden(false)
    end
    for _, glow in ipairs(glowLines) do
        glow:SetColor(rr, gg, bb, 0.52)
        glow:SetHidden(false)
    end
    for _, line in ipairs(lines) do
        line:SetColor(rr, gg, bb, 1)
        line:SetHidden(false)
    end
end

local function HideBorder(slot)
    if slot and slot.EASGearBorderLines then
        for _, line in ipairs(slot.EASGearBorderLines) do line:SetHidden(true) end
    end
    if slot and slot.EASGearGlowLines then
        for _, line in ipairs(slot.EASGearGlowLines) do line:SetHidden(true) end
    end
    if slot and slot.EASGearHaloLines then
        for _, line in ipairs(slot.EASGearHaloLines) do line:SetHidden(true) end
    end
end

local function EnsureDecor(slot)
    if slot.EASGearCondition then return end
    local name = slot:GetName()
    -- v0.29.235: reduce the text that sits INSIDE gear icons so the artwork is
    -- easier to see. External gear labels remain unchanged.
    slot.EASGearCondition = CreateLabel(name .. "EASGearCondition", slot, "$(BOLD_FONT)|14|soft-shadow-thick")
    slot.EASGearCondition:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    slot.EASGearLevel = CreateLabel(name .. "EASGearLevel", slot, "$(BOLD_FONT)|13|soft-shadow-thick")
    slot.EASGearLevel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    slot.EASGearName = CreateLabel(name .. "EASGearName", slot, "$(BOLD_FONT)|20|soft-shadow-thick")
    slot.EASGearType = CreateLabel(name .. "EASGearType", slot, "$(MEDIUM_FONT)|17|soft-shadow-thick")
    slot.EASGearSet = CreateLabel(name .. "EASGearSet", slot, "$(MEDIUM_FONT)|16|soft-shadow-thick")
    if slot.EASGearName.SetMaxLineCount then slot.EASGearName:SetMaxLineCount(2) end
    if slot.EASGearType.SetMaxLineCount then slot.EASGearType:SetMaxLineCount(1) end
    if slot.EASGearSet.SetMaxLineCount then slot.EASGearSet:SetMaxLineCount(2) end
    slot.EASGearOutfit = CreateTexture(name .. "EASGearOutfit", slot, OUTFIT_ICON)
    slot.EASGearCostume = CreateTexture(name .. "EASGearCostume", slot, COSTUME_ICON)
    slot.EASGearOutfit:SetDimensions(20, 20)
    slot.EASGearCostume:SetDimensions(20, 20)
end

local function HideDecor(slot)
    if not slot then return end
    for _, key in ipairs({"EASGearCondition","EASGearLevel","EASGearName","EASGearType","EASGearSet","EASGearOutfit","EASGearCostume"}) do
        local c = slot[key]
        if c then c:SetHidden(true) end
    end
    HideBorder(slot)
end

local function HideSlotPresentation(slot)
    HideDecor(slot)
    HideSlotBackdrop(slot)
end

local function GetBag(isCompanion)
    if isCompanion and BAG_COMPANION_WORN then return BAG_COMPANION_WORN end
    return BAG_WORN
end

local function ItemTypeText(link, slotId)
    if not link or link == "" then return "" end
    local equipType = Safe(GetItemLinkEquipType, 0, link)
    if WEAPON_SLOTS[slotId] then
        local wt = Safe(GetItemLinkWeaponType, 0, link)
        if wt and wt ~= 0 then
            local a = Safe(GetString, "", "SI_EQUIPTYPE", equipType) or ""
            local b = Safe(GetString, "", "SI_WEAPONTYPE", wt) or ""
            return zo_strformat("<<1>> <<2>>", a, b)
        end
    end
    local at = Safe(GetItemLinkArmorType, 0, link)
    if at and at ~= 0 then
        local a = Safe(GetString, "", "SI_EQUIPTYPE", equipType) or ""
        local b = Safe(GetString, "", "SI_ARMORTYPE", at) or ""
        return zo_strformat("<<1>> <<2>>", a, b)
    end
    return Safe(GetString, "", "SI_EQUIPTYPE", equipType) or ""
end

local function GetLevelText(bag, slot, unitTag)
    if bag == BAG_WORN then
        local cp = Safe(GetItemRequiredChampionPoints, 0, bag, slot) or 0
        if cp > 0 then
            local current = Safe(GetUnitChampionPoints, 0, unitTag or "player") or 0
            return "CP" .. tostring(cp), current - cp, cp >= 160
        end
        local level = Safe(GetItemRequiredLevel, 0, bag, slot) or 0
        if level > 0 then
            local current = Safe(GetUnitLevel, 1, unitTag or "player") or 1
            return tostring(level), current - level, false
        end
    end
    return "", 0, false
end

local function LowColor(label, value, threshold)
    if value <= threshold * 0.5 then label:SetColor(1, 0.24, 0.20, 1)
    elseif value <= threshold then label:SetColor(1, 0.90, 0.18, 1)
    else label:SetColor(1, 1, 1, 1) end
end

local function DifferenceColor(label, difference, threshold)
    if difference >= threshold * 2 then label:SetColor(1, 0.24, 0.20, 1)
    elseif difference >= threshold then label:SetColor(1, 0.90, 0.18, 1)
    else label:SetColor(1, 1, 1, 1) end
end

local function HasAppearanceOverride(slotData, actorCategory, weaponOutfitSlots)
    if not GetEquippedOutfitIndex or not GetOutfitSlotInfo then return false end
    local outfitIndex = Safe(GetEquippedOutfitIndex, 0, actorCategory) or 0
    if outfitIndex <= 0 then return false end
    local outfitSlot = slotData.outfit
    if slotData.weaponOutfit and weaponOutfitSlots then outfitSlot = weaponOutfitSlots[slotData.weaponOutfit] end
    if not outfitSlot then return false end
    local collectible = Safe(GetOutfitSlotInfo, 0, actorCategory, outfitIndex, outfitSlot) or 0
    return collectible > 0
end

local function AppearanceState(actorCategory)
    local state = { costume=false, hat=false }
    if type(GetActiveCollectibleByType) == "function" then
        local costumeType = rawget(_G, "COLLECTIBLE_CATEGORY_TYPE_COSTUME")
        local hatType = rawget(_G, "COLLECTIBLE_CATEGORY_TYPE_HAT")
        if costumeType then state.costume = (Safe(GetActiveCollectibleByType, 0, costumeType, actorCategory) or 0) > 0 end
        if hatType then state.hat = (Safe(GetActiveCollectibleByType, 0, hatType, actorCategory) or 0) > 0 end
    end
    return state
end

local function WeaponOutfitSlots(actorCategory)
    if type(GetOutfitSlotsForEquippedWeapons) ~= "function" then return {} end
    local a,b,c,d = Safe(GetOutfitSlotsForEquippedWeapons, nil, actorCategory)
    return {a,b,c,d}
end

function G:IsEnabled()
    return EPC.saved and EPC.saved.characterGearScreenEnabled029206 ~= false
end

function G:IsPlayerSceneShowing()
    local inv = self.inventoryScene
    if inv and inv.IsShowing and inv:IsShowing() then return true end
    local chr = self.characterScene
    if chr and chr.IsShowing and chr:IsShowing() then return true end
    return false
end

function G:IsCompanionSceneShowing()
    local scene = rawget(_G, "COMPANION_CHARACTER_KEYBOARD_SCENE")
    return scene and scene.IsShowing and scene:IsShowing() or false
end

function G:RefreshSlot(slotData, isCompanion)
    local control = rawget(_G, slotData.control)
    if not control then return end
    EnsureDecor(control)
    local bag = GetBag(isCompanion)
    local itemName = Safe(GetItemName, "", bag, slotData.slot) or ""
    local hasItem = itemName ~= ""
    LayoutSlotBackdrop(control, hasItem)
    if not hasItem then HideDecor(control); return end

    local saved = EPC.saved
    local quality = Safe(GetItemDisplayQuality, nil, bag, slotData.slot)
    local backdropR, backdropG, backdropB, backdropA = nil, nil, nil, nil
    if saved.characterGearShowQuality029206 ~= false and quality then
        local color = Safe(GetItemQualityColor, nil, quality)
        if color and color.UnpackRGBA then
            local r,g,b,a = color:UnpackRGBA()
            LayoutBorder(control, r,g,b,a)
            backdropR, backdropG, backdropB, backdropA = r, g, b, a
        else
            LayoutBorder(control, 1,1,1,1)
            backdropR, backdropG, backdropB, backdropA = 1, 1, 1, 1
        end
    else
        HideBorder(control)
    end
    LayoutSlotBackdrop(control, true, backdropR, backdropG, backdropB, backdropA)

    local cond = control.EASGearCondition
    cond:SetFont("$(BOLD_FONT)|14|soft-shadow-thick")
    cond:ClearAnchors(); cond:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, -3, 1)
    cond:SetDimensions(control:GetWidth() - 4, 18)
    cond:SetHidden(true)
    local repairThreshold = Clamp(saved.characterGearRepairThreshold029206, 1, 100)
    local chargeThreshold = Clamp(saved.characterGearChargeThreshold029206, 1, 100)
    if not isCompanion and saved.characterGearShowCondition029206 ~= false then
        local hasDurability = Safe(DoesItemHaveDurability, false, bag, slotData.slot) == true
        if hasDurability then
            local condition = SafeNumber(GetItemCondition, 100, bag, slotData.slot) or 100
            cond:SetText(tostring(math.floor(condition + 0.5)) .. "%")
            LowColor(cond, condition, repairThreshold)
            cond:SetHidden(false)
        elseif WEAPON_SLOTS[slotData.slot] and Safe(IsItemChargeable, false, bag, slotData.slot) == true then
            local current, maximum = Safe(GetChargeInfoForItem, 0, bag, slotData.slot)
            current, maximum = tonumber(current) or 0, tonumber(maximum) or 0
            if maximum > 0 then
                local pct = zo_clamp(math.floor(current / maximum * 100 + 0.5), 0, 100)
                cond:SetText(tostring(pct) .. "%")
                LowColor(cond, pct, chargeThreshold)
                cond:SetHidden(false)
            end
        end
    end

    local level = control.EASGearLevel
    level:SetFont("$(BOLD_FONT)|13|soft-shadow-thick")
    level:ClearAnchors(); level:SetAnchor(TOPRIGHT, control, TOPRIGHT, -3, -1)
    level:SetDimensions(control:GetWidth() - 4, 17)
    local levelText, difference, maxCp = GetLevelText(bag, slotData.slot, isCompanion and "companion" or "player")
    level:SetText(levelText)
    if maxCp then level:SetColor(0.35, 0.85, 1, 1) else DifferenceColor(level, difference, Clamp(saved.characterGearLevelWarning029206,1,10)) end
    level:SetHidden(isCompanion or saved.characterGearShowLevel029206 == false or levelText == "" or slotData.poison == true)

    local link = Safe(GetItemLink, "", bag, slotData.slot, LINK_STYLE_DEFAULT or 0) or ""
    local layout = self.currentLayout or self:BuildAdaptiveLayout(isCompanion)
    local density = layout.density or "compact"
    local detailVisible = saved.characterGearShowDetails029206 ~= false and not slotData.poison and density ~= "icons"
    -- v0.29.230: keep the larger gear text overall, but dial the companion
    -- labels back slightly so they do not dominate the companion layout.
    local fontSize = Clamp((tonumber(saved.characterGearFontSize029206) or 20) + 4, 18, 32)
    if isCompanion then
        fontSize = math.max(16, fontSize - 2)
    end
    if density == "compact" then
        fontSize = math.min(fontSize, isCompanion and 24 or 26)
    end
    local detailFont = string.format("$(BOLD_FONT)|%d|soft-shadow-thick", fontSize)
    local subFont = string.format("$(MEDIUM_FONT)|%d|soft-shadow-thick", math.max(isCompanion and 14 or 16, fontSize - 2))
    local nameLabel, typeLabel, setLabel = control.EASGearName, control.EASGearType, control.EASGearSet
    nameLabel:SetFont(detailFont); typeLabel:SetFont(subFont); setLabel:SetFont(subFont)
    local width = layout.labelWidth or (COMPACT_LABEL_WIDTH * math.max(LayoutScale(), 0.88))
    -- v0.29.208: labels expand away from the real 3D character instead of into it.
    -- Two-line name/set boxes preserve full set names on 16:9 layouts without
    -- forcing the equipment controls back over the model.
    local nameHeight = (fontSize + 5) * 2
    local typeHeight = fontSize + 7
    local setHeight = (math.max(10, fontSize - 2) + 5) * 2
    nameLabel:SetDimensions(width, nameHeight); typeLabel:SetDimensions(width, typeHeight); setLabel:SetDimensions(width, setHeight)
    if nameLabel.SetMaxLineCount then pcall(nameLabel.SetMaxLineCount, nameLabel, 2) end
    if setLabel.SetMaxLineCount then pcall(setLabel.SetMaxLineCount, setLabel, 2) end
    nameLabel:ClearAnchors(); typeLabel:ClearAnchors(); setLabel:ClearAnchors()

    local outwardSide = slotData.side
    if slotData.weaponCol == nil then
        if (slotData.x or 0) < 0 then
            outwardSide = "left"
        elseif (slotData.x or 0) > 0 then
            outwardSide = "right"
        end
    end

    local labelGap = slotData.weaponCol ~= nil and 26 or 10
    if outwardSide == "left" then
        nameLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT); typeLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT); setLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        nameLabel:SetAnchor(TOPRIGHT, control, TOPLEFT, -labelGap, -4)
        typeLabel:SetAnchor(TOPRIGHT, nameLabel, BOTTOMRIGHT, 0, -2)
        setLabel:SetAnchor(TOPRIGHT, density == "detailed" and typeLabel or nameLabel, BOTTOMRIGHT, 0, -2)
    else
        nameLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT); typeLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT); setLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        nameLabel:SetAnchor(TOPLEFT, control, TOPRIGHT, labelGap, -4)
        typeLabel:SetAnchor(TOPLEFT, nameLabel, BOTTOMLEFT, 0, -2)
        setLabel:SetAnchor(TOPLEFT, density == "detailed" and typeLabel or nameLabel, BOTTOMLEFT, 0, -2)
    end
    nameLabel:SetText(zo_strformat(SI_TOOLTIP_ITEM_NAME, itemName))
    if quality then
        local qc = Safe(GetItemQualityColor, nil, quality)
        if qc and qc.UnpackRGBA then nameLabel:SetColor(qc:UnpackRGBA()) else nameLabel:SetColor(1,1,1,1) end
    end
    typeLabel:SetText(ItemTypeText(link, slotData.slot))
    typeLabel:SetColor(0.82,0.82,0.82,1)
    typeLabel:SetHidden(not detailVisible or density ~= "detailed")
    local hasSet, setName, _, normalEquipped, maxEquipped, _, perfectedEquipped = false, "", 0,0,0,0,0
    if link ~= "" and type(GetItemLinkSetInfo) == "function" then
        hasSet, setName, _, normalEquipped, maxEquipped, _, perfectedEquipped = GetItemLinkSetInfo(link)
    end
    if hasSet and tonumber(maxEquipped) and maxEquipped > 0 then
        local count = math.min((tonumber(normalEquipped) or 0) + (tonumber(perfectedEquipped) or 0), maxEquipped)
        setLabel:SetText(zo_strformat("<<1>>  <<2>>/<<3>>", setName or "Set", count, maxEquipped))
        setLabel:SetColor(0.73,0.82,1,1)
        setLabel:SetHidden(not detailVisible or saved.characterGearShowSetCount029206 == false)
    else setLabel:SetHidden(true) end
    nameLabel:SetHidden(not detailVisible)
    if density ~= "detailed" then typeLabel:SetHidden(true) end

    local actorCategory = isCompanion and rawget(_G, "GAMEPLAY_ACTOR_CATEGORY_COMPANION") or rawget(_G, "GAMEPLAY_ACTOR_CATEGORY_PLAYER")
    local outfitSlots = actorCategory and WeaponOutfitSlots(actorCategory) or {}
    local appearance = actorCategory and AppearanceState(actorCategory) or {costume=false,hat=false}
    local outfit = actorCategory and HasAppearanceOverride(slotData, actorCategory, outfitSlots)
    local costume = COSTUME_SLOTS[slotData.slot] and (appearance.costume or (slotData.slot == EQUIP_SLOT_HEAD and appearance.hat))
    local outfitIcon, costumeIcon = control.EASGearOutfit, control.EASGearCostume
    outfitIcon:ClearAnchors(); costumeIcon:ClearAnchors()

    -- v0.29.233: weapon appearance indicators get their own dedicated row above
    -- or below the weapon slot instead of hugging the slot edge. This keeps the
    -- marker visually separate from the weapon box and the bar-swap icon.
    if slotData.weaponCol ~= nil then
        -- v0.29.235: weapon appearance is represented in a dedicated utility
        -- cell in the 4-wide weapon grid, so do not float tiny badges around
        -- individual weapon boxes anymore.
        outfitIcon:SetHidden(true)
        costumeIcon:SetHidden(true)
    elseif slotData.side == "left" then
        outfitIcon:SetDimensions(20, 20)
        costumeIcon:SetDimensions(20, 20)
        outfitIcon:SetAnchor(BOTTOMRIGHT, control, BOTTOMLEFT, -8, 0)
        costumeIcon:SetAnchor(BOTTOMRIGHT, outfitIcon, BOTTOMLEFT, -4, 0)
    else
        outfitIcon:SetDimensions(20, 20)
        costumeIcon:SetDimensions(20, 20)
        outfitIcon:SetAnchor(BOTTOMLEFT, control, BOTTOMRIGHT, 8, 0)
        costumeIcon:SetAnchor(BOTTOMLEFT, outfitIcon, BOTTOMRIGHT, 4, 0)
    end
    if slotData.weaponCol == nil then
        outfitIcon:SetHidden(not outfit)
        costumeIcon:SetHidden(not costume)
    end
end

function G:ApplySlotLayout(slotData, slotSize, scale, isCompanion)
    local c = rawget(_G, slotData.control)
    if not c then return end
    local layout = self.currentLayout or self:BuildAdaptiveLayout(isCompanion)
    local x, y
    if slotData.weaponCol ~= nil then
        local slotPx = slotSize * scale
        if isCompanion then
            local gap = slotPx + 22 * scale
            x = layout.centerX + slotData.weaponCol * gap
            if (slotData.weaponCol or 0) > 0 then
                -- v0.29.223: pull the right-side companion gear farther away from
                -- the divider/info panel without moving the companion off center.
                x = x - (34 * scale)
            end
            y = layout.centerY + layout.weaponY
        else
            -- v0.29.235: 4-wide weapon grid. Columns 1-3 are Main/Off/Poison;
            -- column 4 is reserved for utility cells (Appearance / Bar Swap).
            -- The entire grid stays lower than the armor rows but remains clear
            -- of ESO's bottom action prompt.
            local colGap = slotPx + math.max(34, 54 * scale)
            local rowGap = slotPx + math.max(44, 66 * scale)
            local centerY = math.min(layout.centerY + layout.weaponY + math.max(10, 18 * scale), layout.h - math.max(150, 190 * scale))
            local gridColBySlot = {
                [EQUIP_SLOT_MAIN_HAND]=1,
                [EQUIP_SLOT_OFF_HAND]=2,
                [EQUIP_SLOT_POISON]=3,
                [EQUIP_SLOT_BACKUP_MAIN]=1,
                [EQUIP_SLOT_BACKUP_OFF]=2,
                [EQUIP_SLOT_BACKUP_POISON]=3,
            }
            local gridRowBySlot = {
                [EQUIP_SLOT_MAIN_HAND]=1,
                [EQUIP_SLOT_OFF_HAND]=1,
                [EQUIP_SLOT_POISON]=1,
                [EQUIP_SLOT_BACKUP_MAIN]=2,
                [EQUIP_SLOT_BACKUP_OFF]=2,
                [EQUIP_SLOT_BACKUP_POISON]=2,
            }
            local col = gridColBySlot[slotData.slot] or 2
            local row = gridRowBySlot[slotData.slot] or 1
            x = layout.centerX + (col - 2.5) * colGap
            y = centerY + (row == 1 and -0.5 or 0.5) * rowGap
        end
    else
        local rowBySlot = {
            [EQUIP_SLOT_HEAD]=0, [EQUIP_SLOT_NECK]=0,
            [EQUIP_SLOT_SHOULDERS]=1, [EQUIP_SLOT_CHEST]=1,
            [EQUIP_SLOT_HAND]=2, [EQUIP_SLOT_WAIST]=2,
            [EQUIP_SLOT_RING1]=3, [EQUIP_SLOT_RING2]=3,
            [EQUIP_SLOT_LEGS]=4, [EQUIP_SLOT_FEET]=4,
        }
        local row = rowBySlot[slotData.slot] or 2
        local sideSign = (slotData.x or 0) < 0 and -1 or 1
        x = layout.centerX + sideSign * layout.spread
        if isCompanion and sideSign > 0 then
            x = x - (34 * scale)
        end
        y = layout.centerY + layout.topY + row * layout.rowStep
    end
    c:SetScale(1)
    c:SetHidden(false)
    c:ClearAnchors()
    c:SetAnchor(CENTER, GuiRoot, TOPLEFT, x, y)
    c:SetDimensions(slotSize * scale, slotSize * scale)
    LayoutSlotBackdrop(c, Safe(GetItemName, "", GetBag(isCompanion), slotData.slot) ~= "")
    local highlight = c.GetNamedChild and c:GetNamedChild("Highlight") or nil
    if highlight then
        local hs = slotSize * scale * 1.58
        highlight:SetDimensions(hs, hs); highlight:ClearAnchors(); highlight:SetAnchor(CENTER, c, CENTER)
    end
    self:RefreshSlot(slotData, isCompanion)
end

function G:CapturePlayerState()
    if self.playerOriginal then return end
    local states = {}
    local function add(control) if control then states[#states + 1] = CaptureControlState(control) end end
    add(rawget(_G, "ZO_Character"))
    add(rawget(_G, "ZO_CharacterAccessoriesSection"))
    add(rawget(_G, "ZO_CharacterWeaponsSection"))
    add(rawget(_G, "ZO_CharacterHeaderSection"))
    add(rawget(_G, "ZO_CharacterHeaderSectionTitle"))
    add(rawget(_G, "ZO_CharacterHeaderSectionDivider"))
    add(rawget(_G, "ZO_CharacterApparelSectionText"))
    local nativeBg = rawget(_G, "ZO_SharedWideLeftPanelBackground")
    add(nativeBg)
    if nativeBg and nativeBg.GetNamedChild then
        add(nativeBg:GetNamedChild("Left"))
        add(nativeBg:GetNamedChild("Right"))
    end
    add(rawget(_G, "ZO_CharacterPaperDoll"))
    add(rawget(_G, "ZO_CharacterWeaponSwap"))
    add(rawget(_G, "ZO_CharacterWindowStats"))
    for _, d in ipairs(PLAYER_SLOTS) do add(rawget(_G, d.control)) end
    self.playerOriginal = states
end

function G:CaptureCompanionState()
    if self.companionOriginal then return end
    local states = {}
    local function add(control) if control then states[#states + 1] = CaptureControlState(control) end end
    add(rawget(_G, "ZO_CompanionCharacterWindow_Keyboard_TopLevel"))
    add(rawget(_G, "ZO_CompanionCharacterWindow_Keyboard_TopLevelTitle"))
    add(rawget(_G, "ZO_CompanionCharacterWindow_Keyboard_TopLevelHeaderDivider"))
    add(rawget(_G, "ZO_CompanionCharacterWindow_Keyboard_TopLevelApparelSectionText"))
    add(rawget(_G, "ZO_CompanionCharacterWindow_Keyboard_TopLevelPaperDoll"))
    add(rawget(_G, "ZO_CompanionCharacterWindow_Keyboard_TopLevelAccessoriesSection"))
    add(rawget(_G, "ZO_CompanionCharacterWindow_Keyboard_TopLevelWeaponsSection"))
    local thinBg = rawget(_G, "ZO_SharedThinLeftPanelBackground")
    add(thinBg)
    if thinBg and thinBg.GetNamedChild then
        add(thinBg:GetNamedChild("Left"))
        add(thinBg:GetNamedChild("Right"))
    end
    for _, d in ipairs(COMPANION_SLOTS) do add(rawget(_G, d.control)) end
    local root = rawget(_G, "ZO_CompanionCharacterWindow_Keyboard_TopLevel")
    if root and root.GetNumChildren and root.GetChild then
        local count = SafeNumber(root.GetNumChildren, 0, root) or 0
        for i = 1, count do
            local child = Safe(root.GetChild, nil, root, i)
            if child then add(child) end
        end
    end
    self.companionOriginal = states
end

function G:RestorePlayerState()
    if self.playerOriginal then for _, state in ipairs(self.playerOriginal) do RestoreControlState(state) end end
    for _, d in ipairs(PLAYER_SLOTS) do HideSlotPresentation(rawget(_G, d.control)) end
    if ZO_CharacterPaperDoll then ZO_CharacterPaperDoll:SetColor(1,1,1,1) end
end

function G:CleanupPlayerScene()
    self:HideGearStatsCard()
    self:HideWeaponUtilityCells()
    -- v0.29.219: never leave Character-screen controls visible after the scene
    -- closes. Restore anchors/dimensions first, then hide scene-owned controls.
    -- ESO will show its native controls again when the Character scene opens.
    self:RestorePlayerState()
    self:HideWorkspaceBackdrop()

    local controls = {
        rawget(_G, "ZO_Character"),
        rawget(_G, "ZO_CharacterAccessoriesSection"),
        rawget(_G, "ZO_CharacterWeaponsSection"),
        rawget(_G, "ZO_CharacterHeaderSection"),
        rawget(_G, "ZO_CharacterHeaderSectionTitle"),
        rawget(_G, "ZO_CharacterHeaderSectionDivider"),
        rawget(_G, "ZO_CharacterApparelSectionText"),
        rawget(_G, "ZO_CharacterPaperDoll"),
        rawget(_G, "ZO_CharacterWeaponSwap"),
        rawget(_G, "ZO_CharacterWindowStats"),
        rawget(_G, "ZO_SharedWideLeftPanelBackground"),
    }
    for _, control in ipairs(controls) do
        if control and control.SetHidden then pcall(control.SetHidden, control, true) end
    end
    for _, d in ipairs(PLAYER_SLOTS) do
        local c = rawget(_G, d.control)
        HideSlotPresentation(c)
        if c and c.SetHidden then pcall(c.SetHidden, c, true) end
    end
end

function G:CleanupCompanionScene()
    self:HideGearStatsCard()
    self:RestoreCompanionInfoPanel()
    -- v0.29.220: companion scene gets the same hard cleanup as the player
    -- Character scene. Restore shared/native state first, then hide only the
    -- Companion-scene-owned controls so nothing leaks onto normal gameplay.
    self:RestoreCompanionState()
    self:HideWorkspaceBackdrop()
    local controls = {
        rawget(_G, "ZO_CompanionCharacterWindow_Keyboard_TopLevel"),
        rawget(_G, "ZO_CompanionCharacterWindow_Keyboard_TopLevelTitle"),
        rawget(_G, "ZO_CompanionCharacterWindow_Keyboard_TopLevelHeaderDivider"),
        rawget(_G, "ZO_CompanionCharacterWindow_Keyboard_TopLevelApparelSectionText"),
        rawget(_G, "ZO_CompanionCharacterWindow_Keyboard_TopLevelPaperDoll"),
        rawget(_G, "ZO_CompanionCharacterWindow_Keyboard_TopLevelAccessoriesSection"),
        rawget(_G, "ZO_CompanionCharacterWindow_Keyboard_TopLevelWeaponsSection"),
        rawget(_G, "ZO_SharedThinLeftPanelBackground"),
    }
    for _, control in ipairs(controls) do
        if control and control.SetHidden then pcall(control.SetHidden, control, true) end
    end
    for _, d in ipairs(COMPANION_SLOTS) do
        local c = rawget(_G, d.control)
        HideSlotPresentation(c)
        if c and c.SetHidden then pcall(c.SetHidden, c, true) end
    end
end

function G:RestoreCompanionState()
    self:RestoreCompanionInfoPanel()
    if self.companionOriginal then for _, state in ipairs(self.companionOriginal) do RestoreControlState(state) end end
    self._hiddenCompanionChildren = nil
    for _, d in ipairs(COMPANION_SLOTS) do HideSlotPresentation(rawget(_G, d.control)) end
end

function G:RestoreAll()
    self:HideWeaponUtilityCells()
    self:RestorePlayerState()
    self:RestoreCompanionState()
    self:HideWorkspaceBackdrop()
    self:HideGearStatsCard()
    if self.inventoryScene and self.distanceFragment and self.cameraFragmentAdded then
        pcall(self.inventoryScene.RemoveFragment, self.inventoryScene, self.distanceFragment)
        self.cameraFragmentAdded = false
    end
end

local function EnsureWeaponUtilityCell(self, key, iconTexture)
    self.weaponUtilityCells = self.weaponUtilityCells or {}
    local cell = self.weaponUtilityCells[key]
    if cell then return cell end

    cell = WINDOW_MANAGER:CreateTopLevelWindow(NS .. "WeaponUtility" .. key)
    cell:SetMouseEnabled(false)
    cell:SetClampedToScreen(true)
    if cell.SetDrawTier and rawget(_G,"DT_HIGH") then cell:SetDrawTier(DT_HIGH) end
    cell:SetDrawLayer(DL_CONTROLS)
    cell:SetDrawLevel(40)

    local bg = WINDOW_MANAGER:CreateControl(nil, cell, CT_BACKDROP)
    bg:SetAnchorFill(cell)
    bg:SetCenterColor(0.035, 0.045, 0.07, 0.92)
    bg:SetEdgeColor(0.72, 0.64, 0.40, 0.82)
    bg:SetEdgeTexture("EsoUI/Art/Miscellaneous/white_1x1.dds", 1, 1, 3)
    cell.bg = bg

    local icon = WINDOW_MANAGER:CreateControl(nil, cell, CT_TEXTURE)
    icon:SetAnchor(CENTER, cell, CENTER)
    icon:SetTexture(iconTexture or OUTFIT_ICON)
    icon:SetColor(1,1,1,1)
    icon:SetMouseEnabled(false)
    icon:SetDrawLayer(DL_OVERLAY)
    icon:SetDrawLevel(50)
    cell.icon = icon

    cell:SetHidden(true)
    self.weaponUtilityCells[key] = cell
    return cell
end

function G:HideWeaponUtilityCells()
    if not self.weaponUtilityCells then return end
    for _, cell in pairs(self.weaponUtilityCells) do
        if cell and cell.SetHidden then cell:SetHidden(true) end
    end
end

function G:LayoutWeaponUtilityCells(layout, slotSize, scale)
    if not layout then return end
    local slotPx = slotSize * scale
    local colGap = slotPx + math.max(34, 54 * scale)
    local rowGap = slotPx + math.max(44, 66 * scale)
    local centerY = math.min(layout.centerY + layout.weaponY + math.max(10, 18 * scale), layout.h - math.max(150, 190 * scale))
    -- v0.29.236: keep the dedicated utility column OUTSIDE the character drag
    -- area. The old fourth-column center sat over the player's legs and stole
    -- the exact mouse area used to rotate the 3D character.
    local desiredUtilityX = layout.centerX + 2.45 * colGap
    local maxUtilityX = (layout.safeRight or (layout.w * 0.78)) - slotPx * 0.62
    local utilityX = math.min(desiredUtilityX, maxUtilityX)
    local topY = centerY - rowGap * 0.5
    local bottomY = centerY + rowGap * 0.5

    local appearance = EnsureWeaponUtilityCell(self, "Appearance", OUTFIT_ICON)
    appearance:SetDimensions(slotPx, slotPx)
    appearance:ClearAnchors()
    appearance:SetAnchor(CENTER, GuiRoot, TOPLEFT, utilityX, topY)
    appearance.icon:SetDimensions(slotPx * 0.58, slotPx * 0.58)

    -- The appearance cell is a real button now, not just a decorative icon.
    -- Clicking it opens ESO's Outfit Styles screen. It is positioned outside
    -- the character rotation canvas so it no longer blocks click-drag rotation.
    appearance:SetMouseEnabled(true)
    appearance:SetHandler("OnMouseUp", function(_, button, upInside)
        if button ~= MOUSE_BUTTON_INDEX_LEFT or upInside == false then return end
        if not SCENE_MANAGER then return end
        local outfitScene = SCENE_MANAGER:GetScene("outfitStylesBook")
        if outfitScene then
            SCENE_MANAGER:Show("outfitStylesBook")
            return
        end
        local collectionsScene = SCENE_MANAGER:GetScene("collectionsBook")
        if collectionsScene then SCENE_MANAGER:Show("collectionsBook") end
    end)

    local actorCategory = rawget(_G, "GAMEPLAY_ACTOR_CATEGORY_PLAYER")
    local outfitSlots = actorCategory and WeaponOutfitSlots(actorCategory) or {}
    local hasWeaponAppearance = false
    if actorCategory then
        for _, slotData in ipairs(PLAYER_SLOTS) do
            if slotData.weaponOutfit and HasAppearanceOverride(slotData, actorCategory, outfitSlots) then
                hasWeaponAppearance = true
                break
            end
        end
    end
    if hasWeaponAppearance then
        appearance.bg:SetEdgeColor(0.35, 0.85, 1.00, 1)
        appearance.icon:SetColor(0.55, 0.92, 1.00, 1)
    else
        appearance.bg:SetEdgeColor(0.58, 0.58, 0.62, 0.78)
        appearance.icon:SetColor(0.80, 0.80, 0.82, 0.92)
    end
    appearance:SetHidden(false)

    local swapCell = EnsureWeaponUtilityCell(self, "Swap", "EsoUI/Art/ActionBar/abilityFrame64_up.dds")
    swapCell:SetDimensions(slotPx, slotPx)
    swapCell:ClearAnchors()
    swapCell:SetAnchor(CENTER, GuiRoot, TOPLEFT, utilityX, bottomY)
    swapCell.icon:SetHidden(true) -- native ZO_CharacterWeaponSwap is centered here instead
    swapCell.bg:SetEdgeColor(0.72, 0.64, 0.40, 0.86)
    swapCell:SetHidden(false)

    if ZO_CharacterWeaponSwap then
        local swapScale = Clamp(slotSize / 64, 0.74, 1.20) * scale * 0.78
        ZO_CharacterWeaponSwap:SetScale(swapScale)
        ZO_CharacterWeaponSwap:ClearAnchors()
        ZO_CharacterWeaponSwap:SetAnchor(CENTER, swapCell, CENTER, 0, 0)
        ZO_CharacterWeaponSwap:SetHidden(false)
    end
end

function G:EnsurePlayerFramingFragment()
    local fragment = rawget(_G, "FRAME_PLAYER_FRAGMENT")
    if not fragment then return end
    local scenes = { self.inventoryScene, self.characterScene }
    for _, scene in ipairs(scenes) do
        if scene and scene.IsShowing and scene:IsShowing() and scene.HasFragment and scene.AddFragment then
            local has = false
            local ok, value = pcall(scene.HasFragment, scene, fragment)
            if ok then has = value == true end
            if not has then pcall(scene.AddFragment, scene, fragment) end
        end
    end
end

function G:ApplyPlayerLayout()
    if not self:IsEnabled() then return end
    if not rawget(_G, "ZO_Character") then return end
    self:CapturePlayerState()
    local layout = self:BuildAdaptiveLayout(false)
    self.currentLayout = layout
    self:LayoutWorkspaceBackdrop(layout)
    local scale = layout.scale
    local slotSize = Clamp(EPC.saved.characterGearSlotSize029206, 64, 128)

    local root = ZO_Character
    -- v0.29.236: do NOT collapse/reparent the native Character root to 1x1.
    -- ESO uses its native Character/framing controls for mouse interaction with
    -- the 3D player. Preserve that state, while our gear slots remain anchored
    -- directly to GuiRoot and can still use the Suite layout.
    RestoreCapturedControlState(self.playerOriginal, root)
    root:SetHidden(false)
    if root.SetMouseEnabled then root:SetMouseEnabled(true) end
    self:EnsurePlayerFramingFragment()

    -- v0.29.217: remove ESO's native wide-left black gradient while the
    -- enhanced Character Gear screen is active. Its original state was captured
    -- in CapturePlayerState() and is restored when the scene closes.
    local nativeWideLeft = rawget(_G, "ZO_SharedWideLeftPanelBackground")
    if nativeWideLeft then nativeWideLeft:SetHidden(true) end

    if ZO_CharacterAccessoriesSection then ZO_CharacterAccessoriesSection:SetHidden(true) end
    if ZO_CharacterWeaponsSection then ZO_CharacterWeaponsSection:SetHidden(true) end
    -- Keep the face/upper-body area completely clear. ESO can refresh the apparel
    -- status label independently of the parent section, so hide each native header
    -- child explicitly every time the Suite reapplies this scene layout.
    if ZO_CharacterHeaderSection then
        ZO_CharacterHeaderSection:SetHidden(true)
        ZO_CharacterHeaderSection:SetScale(1)
        ZO_CharacterHeaderSection:ClearAnchors()
    end
    local headerTitle = rawget(_G, "ZO_CharacterHeaderSectionTitle")
    local headerDivider = rawget(_G, "ZO_CharacterHeaderSectionDivider")
    local apparelText = rawget(_G, "ZO_CharacterApparelSectionText")
    if headerTitle then headerTitle:SetHidden(true) end
    if headerDivider then headerDivider:SetHidden(true) end
    if apparelText then apparelText:SetHidden(true) end

    -- v0.29.208: remove the redundant orange/paper-doll silhouette. The real
    -- framed 3D player is the only character shown in the center of the gear UI.
    if ZO_CharacterPaperDoll then
        ZO_CharacterPaperDoll:SetHidden(true)
        ZO_CharacterPaperDoll:SetColor(1,1,1,1)
    end

    -- The full native attribute list was the large block crossing the character and
    -- right-side gear in the reported 2560x1440 layout. Auto mode keeps it off on
    -- standard-width screens; ultrawide users can retain it, and Show/Hide is explicit.
    local stats = rawget(_G, "ZO_CharacterWindowStats")
    if stats then stats:SetHidden(true) end
    self:RefreshGearStatsCard(false)

    for _, slotData in ipairs(PLAYER_SLOTS) do self:ApplySlotLayout(slotData, slotSize, scale, false) end

    -- v0.29.235: appearance and bar swap now occupy the fourth column of the
    -- 4-wide weapon grid, one dedicated cell per row.
    self:LayoutWeaponUtilityCells(layout, slotSize, scale)

    -- Damaged-item warnings remain on the actual equipment slots/condition text.
    -- The removed silhouette is no longer used as a warning surface.
    self:ApplyCamera(layout)
end

function G:ApplyCompanionLayout()
    if not self:IsEnabled() then return end
    if EPC.saved.characterGearCompanion029206 == false then self:RestoreCompanionState(); return end
    if not rawget(_G, "COMPANION_CHARACTER_KEYBOARD_SCENE") then return end

    self:CaptureCompanionState()
    local layout = self:BuildAdaptiveLayout(true)
    self.currentLayout = layout
    self:LayoutWorkspaceBackdrop(layout)
    local scale = layout.scale
    local slotSize = Clamp(EPC.saved.characterGearSlotSize029206, 64, 128)

    local root = rawget(_G, "ZO_CompanionCharacterWindow_Keyboard_TopLevel")
    if root then
        -- Preserve ESO's native companion interaction surface. Collapsing this
        -- root to 1x1 removed the mouse region used by the companion preview.
        RestoreCapturedControlState(self.companionOriginal, root)
        root:SetHidden(false)
        if root.SetMouseEnabled then root:SetMouseEnabled(true) end
    end
    self:ShiftCompanionInfoPanelRight(layout)
    self:RefreshGearStatsCard(true)

    -- Match the clean player gear screen: remove ESO's companion thin-left
    -- panel and native title/apparel header while this enhanced scene is open.
    local thinBg = rawget(_G, "ZO_SharedThinLeftPanelBackground")
    if thinBg then thinBg:SetHidden(true) end
    local title = rawget(_G, "ZO_CompanionCharacterWindow_Keyboard_TopLevelTitle")
    local divider = rawget(_G, "ZO_CompanionCharacterWindow_Keyboard_TopLevelHeaderDivider")
    local apparel = rawget(_G, "ZO_CompanionCharacterWindow_Keyboard_TopLevelApparelSectionText")
    if title then title:SetHidden(true) end
    if divider then divider:SetHidden(true) end
    if apparel then apparel:SetHidden(true) end

    local accessories = rawget(_G, "ZO_CompanionCharacterWindow_Keyboard_TopLevelAccessoriesSection")
    local weapons = rawget(_G, "ZO_CompanionCharacterWindow_Keyboard_TopLevelWeaponsSection")
    if accessories then accessories:SetHidden(true) end
    if weapons then weapons:SetHidden(true) end

    -- v0.29.236: do not blanket-hide every unknown companion child. Some of
    -- those native controls participate in mouse interaction/character rotation.
    -- Known visual panels are already hidden explicitly above.

    -- The white silhouette is redundant and was explicitly rejected. Keep the
    -- real companion model only.
    local doll = rawget(_G, "ZO_CompanionCharacterWindow_Keyboard_TopLevelPaperDoll")
    if doll then
        doll:SetHidden(true)
        if doll.SetAlpha then doll:SetAlpha(0) end
    end

    for _, slotData in ipairs(COMPANION_SLOTS) do
        self:ApplySlotLayout(slotData, slotSize, scale, true)
        local c = rawget(_G, slotData.control)
        if c then c:SetHidden(false) end
    end
end

function G:ApplyCamera(layout)
    if self.inventoryScene and self.distanceFragment and not self.cameraFragmentAdded then
        pcall(self.inventoryScene.AddFragment, self.inventoryScene, self.distanceFragment)
        self.cameraFragmentAdded = true
    end
    if not self:IsPlayerSceneShowing() then return end

    layout = layout or self.currentLayout or self:BuildAdaptiveLayout(false)
    local baseDistance = Clamp(EPC.saved.characterGearCameraDistance029206, 1.0, 2.95)
    -- Reuse the old figure-size control for the REAL 3D character now that the
    -- paper doll is removed. Higher size = closer framing.
    local characterSize = Clamp(EPC.saved.characterGearFigureScale029206, 0.65, 1.80)
    local distance = Clamp(baseDistance / characterSize, 1.0, 2.95)

    if self.distanceFragment then self.distanceFragment.lookAtDistanceFactor = distance end

    -- Frame the real player in the actual center of the free character canvas,
    -- not the physical center of the monitor. This uses the left-side space that
    -- was previously empty while respecting the inventory boundary on the right.
    if type(SetFrameLocalPlayerTarget) == "function" and type(NormalizeUICanvasPoint) == "function" then
        local targetX = tonumber(layout.centerX) or ((layout.w or 1920) * 0.5)
        local targetY = (tonumber(layout.h) or 1080) * 0.58
        local ok, nx, ny = pcall(NormalizeUICanvasPoint, targetX, targetY)
        if ok and nx and ny then pcall(SetFrameLocalPlayerTarget, nx, ny) end
    end

    if type(SetFrameLocalPlayerLookAtDistanceFactor) == "function" then pcall(SetFrameLocalPlayerLookAtDistanceFactor, distance) end
    if type(RequestReframeLocalPlayerInGameCamera) == "function" then pcall(RequestReframeLocalPlayerInGameCamera) end
end

function G:Refresh()
    if not self:IsEnabled() then self:RestoreAll(); return end
    local shown = false
    if self:IsPlayerSceneShowing() then self:ApplyPlayerLayout(); shown = true end
    if self:IsCompanionSceneShowing() then self:ApplyCompanionLayout(); shown = true end
    if not shown then
        self:HideWorkspaceBackdrop()
        self:HideGearStatsCard()
    end
end

function G:RequestRefresh(delay)
    if self.refreshPending then return end
    self.refreshPending = true
    zo_callLater(function()
        G.refreshPending = false
        G:Refresh()
    end, tonumber(delay) or 50)
end

function G:HideAllDecor()
    self:HideWeaponUtilityCells()
    for _, d in ipairs(PLAYER_SLOTS) do HideDecor(rawget(_G,d.control)) end
    for _, d in ipairs(COMPANION_SLOTS) do HideDecor(rawget(_G,d.control)) end
end

function G:SetupScenes()
    if not SCENE_MANAGER then return end
    self.inventoryScene = SCENE_MANAGER:GetScene("inventory")
    self.characterScene = SCENE_MANAGER:GetScene("character")
    local function hook(scene)
        if not scene or scene.EASCharacterGear029206 then return end
        scene.EASCharacterGear029206 = true
        scene:RegisterCallback("StateChange", function(_, state)
            if state == SCENE_SHOWING or state == SCENE_SHOWN then
                G:EnsurePlayerFramingFragment()
                G:RequestRefresh(20)
            elseif state == SCENE_HIDING or state == SCENE_HIDDEN then
                G:CleanupPlayerScene()
            end
        end)
    end
    hook(self.inventoryScene); hook(self.characterScene)

    local companionScene = rawget(_G, "COMPANION_CHARACTER_KEYBOARD_SCENE")
    if companionScene and not companionScene.EASCharacterGear029206 then
        companionScene.EASCharacterGear029206 = true
        companionScene:RegisterCallback("StateChange", function(_, state)
            if state == SCENE_SHOWING or state == SCENE_SHOWN then
                G:RequestRefresh(20)
            elseif state == SCENE_HIDING or state == SCENE_HIDDEN then
                G:CleanupCompanionScene()
            end
        end)
    end

    if self.inventoryScene and not self.distanceFragment and type(ZO_CharacterFramingLookAtDistance) == "table" and ZO_CharacterFramingLookAtDistance.New then
        self.distanceFragment = ZO_CharacterFramingLookAtDistance:New(Clamp(EPC.saved.characterGearCameraDistance029206,1.0,2.95))
        if self.distanceFragment then self.inventoryScene:AddFragment(self.distanceFragment); self.cameraFragmentAdded = true end
        if rawget(_G,"FRAME_PLAYER_FRAGMENT") then self.inventoryScene:AddFragment(FRAME_PLAYER_FRAGMENT) end
    end
end

function G:RegisterEvents()
    local em = EVENT_MANAGER
    if not em then return end
    local function reg(event, suffix)
        if event then em:RegisterForEvent(NS .. suffix, event, function() G:RequestRefresh(40) end) end
    end
    reg(rawget(_G,"EVENT_INVENTORY_SINGLE_SLOT_UPDATE"), "Slot")
    reg(rawget(_G,"EVENT_INVENTORY_FULL_UPDATE"), "Full")
    reg(rawget(_G,"EVENT_ACTIVE_WEAPON_PAIR_CHANGED"), "Weapon")
    reg(rawget(_G,"EVENT_ARMORY_BUILD_RESTORE_RESPONSE"), "Armory")
    reg(rawget(_G,"EVENT_COLLECTIBLE_UPDATED"), "Collectible")
    reg(rawget(_G,"EVENT_COMPANION_ACTIVATED"), "CompanionOn")
    reg(rawget(_G,"EVENT_COMPANION_DEACTIVATED"), "CompanionOff")
end

function G:ResetDefaults()
    local d = EPC.defaults
    local s = EPC.saved
    local keys = {
        "characterGearScreenEnabled029206","characterGearCompanion029206","characterGearSlotSize029206",
        "characterGearFontSize029206","characterGearShowQuality029206","characterGearShowCondition029206",
        "characterGearShowLevel029206","characterGearShowDetails029206","characterGearShowSetCount029206",
        "characterGearRepairThreshold029206","characterGearChargeThreshold029206","characterGearLevelWarning029206",
        "characterGearFigureScale029206","characterGearHeaderScale029206","characterGearCameraDistance029206",
        "characterGearColorFigureWarning029206",
        "characterGearAdaptiveLayout029207","characterGearDensity029207","characterGearStatsMode029207",
    }
    for _, k in ipairs(keys) do s[k] = d[k] end
    self:RequestRefresh(10)
end

function G:Initialize()
    if self.initialized then return end
    self.initialized = true
    self:SetupScenes()
    self:RegisterEvents()
    zo_callLater(function() G:SetupScenes(); G:RequestRefresh(10) end, 500)
end
