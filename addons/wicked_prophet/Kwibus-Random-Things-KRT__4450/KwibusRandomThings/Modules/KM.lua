local KRT = KwibusRandomThings
local EM = EVENT_MANAGER
local WM = WINDOW_MANAGER
local ADDON_NAME = KRT.name

local EnsureTable = KRT.EnsureTable
local IsNonEmptyString = KRT.IsNonEmptyString
local DebounceNextFrame = KRT.DebounceNextFrame
local RGBToHex = KRT.RGBToHex

local LSB = LibSkillBlocker
local DEFAULTS = { km = {
    enabled = true,
    blockFlare = true,
    timeout = 20,
    text = "ARCHSTUPID",
    showStaticLabel = true,
    labelScale = 1.8,
    debugEnabled = false,
    blockedAbilityIds = { [61489] = true },
    offsetX = 0,
    offsetY = -200,
    enableReposition = false,
} }

KRT.KM = {
    id = "km",
    defaults = DEFAULTS.km,
    ARCHDRUID_ABILITY_ID = 176816,
    DEFAULT_FLARE_ID = 61489,
    MIN_PIECES = 2,
    SLOTS = { EQUIP_SLOT_HEAD, EQUIP_SLOT_SHOULDERS },

    lastArchdruidTime = 0,
    _lastArchdruidCount = nil,

    _piecesCacheCount = 0,
    _piecesCacheAtMs = 0,

    warningWindow = nil,
    warningLabel = nil,
    registeredBlocks = {},
    _loopsRegistered = false,
}

function KRT.KM:SV()
    return KRT.sv and KRT.sv.km
end

function KRT.KM:Debug(msg, ...)
    local sv = self:SV()
    if not (sv and sv.debugEnabled) then return end
    if select("#", ...) > 0 then
        d(string.format("[KM] " .. msg, ...))
    else
        d("[KM] " .. tostring(msg))
    end
end

function KRT.KM:HasLibSkillBlocker()
    return LSB ~= nil
end

local function IsArchdruidSetName(setName)
    if not IsNonEmptyString(setName) then return false end
    local lower = zo_strlower(setName)
    if string.find(lower, "archdruid", 1, true) == 1 then return true end
    if string.find(lower, "архидруид", 1, true) == 1 then return true end
    return false
end

function KRT.KM:_ComputeArchdruidPieceCount()
    local count = 0
    for _, slot in ipairs(self.SLOTS) do
        local link = GetItemLink(BAG_WORN, slot)
        if IsNonEmptyString(link) then
            local hasSet, setName = GetItemLinkSetInfo(link, false)
            if hasSet and IsArchdruidSetName(setName) then
                count = count + 1
            end
        end
    end

    if count ~= self._lastArchdruidCount then
        self._lastArchdruidCount = count
        self:Debug("Archdruid pieces equipped: %d", count)
    end
    return count
end

function KRT.KM:GetArchdruidPieceCountCached(maxAgeMs)
    local nowMs = GetFrameTimeMilliseconds()
    if (nowMs - (self._piecesCacheAtMs or 0)) > (maxAgeMs or 5000) then
        self._piecesCacheCount = self:_ComputeArchdruidPieceCount()
        self._piecesCacheAtMs = nowMs
    end
    return self._piecesCacheCount or 0
end

function KRT.KM:HasTwoPieces()
    return self:GetArchdruidPieceCountCached(5000) >= self.MIN_PIECES
end

function KRT.KM:CreateWarningWindow()
    if self.warningWindow then return end

    local win = WM:CreateTopLevelWindow("KromitorMomentWarningWindow")
    win:SetDimensions(120, 40)
    win:SetHidden(true)
    win:SetMouseEnabled(false)
    win:SetMovable(false)
    win:SetClampedToScreen(true)
    win:SetDrawLayer(DL_OVERLAY)
    win:SetDrawTier(DT_HIGH)
    win:SetDrawLevel(9999)

    local label = WM:CreateControl("KromitorMomentWarningLabel", win, CT_LABEL)
    label:SetAnchor(CENTER, win, CENTER, 0, 0)
    label:SetFont("ZoFontAnnounceLarge")
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetColor(1, 0.1, 0.1, 1)

    self.warningWindow = win
    self.warningLabel = label
    self:UpdateWarningText()
end

function KRT.KM:UpdateWarningText()
    local win, label = self.warningWindow, self.warningLabel
    if not (win and label) then return end

    local sv = self:SV()
    if not sv then return end

    local scale = sv.labelScale or DEFAULTS.km.labelScale
    local text = IsNonEmptyString(sv.text) and sv.text or DEFAULTS.km.text

    label:SetText(text)
    label:SetScale(scale)

    DebounceNextFrame("KM_Resize", function()
        local tries = 0
        local function ResizeHitbox()
            tries = tries + 1
            local w = (label:GetTextWidth() or 0) * scale + 24
            local h = (label:GetTextHeight() or 0) * scale + 24
            if (w <= 26 or h <= 26) and tries < 6 then
                zo_callLater(ResizeHitbox, 0)
                return
            end
            if w < 60 then w = 60 end
            if h < 30 then h = 30 end
            label:SetDimensions(w / scale, h / scale)
            win:SetDimensions(w, h)
        end
        ResizeHitbox()
    end)
end

function KRT.KM:ApplyAnchor()
    local sv = self:SV()
    if not (self.warningWindow and sv) then return end
    self.warningWindow:ClearAnchors()
    self.warningWindow:SetAnchor(CENTER, GuiRoot, CENTER, sv.offsetX or 0, sv.offsetY or DEFAULTS.km.offsetY)
end

function KRT.KM:EnableDragging(enable)
    local sv = self:SV()
    local ui, label = self.warningWindow, self.warningLabel
    if not (ui and label and sv) then return end

    ui:SetMouseEnabled(false)
    ui:SetMovable(true)
    ui:SetClampedToScreen(true)
    ui:SetDrawTier(DT_HIGH)
    ui:SetDrawLayer(DL_OVERLAY)

    if enable then
        ui:SetHidden(false)
        label:SetMouseEnabled(true)

        label:SetHandler("OnMouseDown", function(_, button)
            if button == MOUSE_BUTTON_INDEX_LEFT then
                ui:StartMoving()
            end
        end)

        label:SetHandler("OnMouseUp", function(_, button)
            if button == MOUSE_BUTTON_INDEX_LEFT then
                ui:StopMovingOrResizing()
            end
        end)

        ui:SetHandler("OnMoveStop", function(control)
            local rootCx, rootCy = GuiRoot:GetCenter()
            local ux, uy = control:GetCenter()
            sv.offsetX = zo_round(ux - rootCx)
            sv.offsetY = zo_round(uy - rootCy)
            self:ApplyAnchor()
        end)
    else
        label:SetMouseEnabled(false)
        label:SetHandler("OnMouseDown", nil)
        label:SetHandler("OnMouseUp", nil)
        ui:SetHandler("OnMoveStop", nil)
        self:OnUpdate()
    end
end

function KRT.KM:OnCombatEvent()
    self.lastArchdruidTime = GetGameTimeSeconds()
    local sv = self:SV()
    if self.warningWindow and sv and not sv.enableReposition then
        self.warningWindow:SetHidden(true)
    end
end

function KRT.KM:ToggleBackgroundLoops(enable)
    if enable and not self._loopsRegistered then
        EM:RegisterForEvent(ADDON_NAME .. "_KM_Archdruid", EVENT_COMBAT_EVENT, function(...)
            self:OnCombatEvent(...)
        end)
        EM:AddFilterForEvent(ADDON_NAME .. "_KM_Archdruid", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, self.ARCHDRUID_ABILITY_ID)
        EM:RegisterForUpdate(ADDON_NAME .. "_KM_Update", 250, function()
            self:OnUpdate()
        end)
        self._loopsRegistered = true
    elseif not enable and self._loopsRegistered then
        EM:UnregisterForEvent(ADDON_NAME .. "_KM_Archdruid", EVENT_COMBAT_EVENT)
        EM:UnregisterForUpdate(ADDON_NAME .. "_KM_Update")
        self._loopsRegistered = false
    end
end

function KRT.KM:OnUpdate()
    local sv = self:SV()
    if not (sv and self.warningWindow) then return end

    if sv.enableReposition then
        self.warningWindow:SetHidden(false)
        return
    end

    if not IsUnitInCombat("player") then
        self.warningWindow:SetHidden(true)
        return
    end

    if not self:HasTwoPieces() then
        self.warningWindow:SetHidden(true)
        return
    end

    local elapsed = GetGameTimeSeconds() - (self.lastArchdruidTime or 0)
    local timeout = sv.timeout or DEFAULTS.km.timeout
    local show = (elapsed >= timeout) and sv.showStaticLabel
    self.warningWindow:SetHidden(not show)
end

function KRT.KM:_EnsureSkillBlockRegistered(abilityId)
    if self.registeredBlocks[abilityId] then return end
    if not LSB then return end

    self.registeredBlocks[abilityId] = true
    local idForClosure = abilityId

    LSB.RegisterSkillBlock(ADDON_NAME, idForClosure, function()
        local sv = KRT.sv and KRT.sv.km
        return sv and sv.enabled and sv.blockFlare and sv.blockedAbilityIds and sv.blockedAbilityIds[idForClosure]
    end, true)
end

function KRT.KM:SetupSkillBlocking()
    local sv = self:SV()
    if not sv then return end

    if not self:HasLibSkillBlocker() then
        if sv.blockFlare then
            sv.blockFlare = false
        end
        self:Debug("LibSkillBlocker not found - forcing blockFlare off")
        return
    end

    sv.blockedAbilityIds = EnsureTable(sv.blockedAbilityIds)
    if sv.blockedAbilityIds[self.DEFAULT_FLARE_ID] == nil then
        sv.blockedAbilityIds[self.DEFAULT_FLARE_ID] = true
    end

    for id, _ in pairs(sv.blockedAbilityIds) do
        self:_EnsureSkillBlockRegistered(id)
    end
end

function KRT.KM:GetBlockedAbilityListText()
    local sv = self:SV()
    if not sv then return "None" end

    local lines = {}
    for abilityId, enabled in pairs(sv.blockedAbilityIds or {}) do
        if enabled then
            local name = GetAbilityName(abilityId)
            if IsNonEmptyString(name) then
                table.insert(lines, string.format("%d (%s)", abilityId, name))
            else
                table.insert(lines, tostring(abilityId))
            end
        end
    end

    if #lines == 0 then return "None" end
    table.sort(lines)
    return table.concat(lines, "\n")
end

function KRT.KM:AddBlockedAbilityIdFromString(str)
    local sv = self:SV()
    if not sv then return end

    local id = tonumber(str)
    if not id then return end

    sv.blockedAbilityIds = EnsureTable(sv.blockedAbilityIds)
    sv.blockedAbilityIds[id] = true
    self:_EnsureSkillBlockRegistered(id)
end

function KRT.KM:RemoveBlockedAbilityIdFromString(str)
    local sv = self:SV()
    if not sv then return end

    local id = tonumber(str)
    if not id then return end

    if sv.blockedAbilityIds then
        sv.blockedAbilityIds[id] = nil
    end
end

function KRT.KM:RegisterSlashCommands()
    SLASH_COMMANDS["/kmtest"] = function()
        if self.warningWindow then
            self.warningWindow:SetHidden(false)
        end
    end
end

function KRT.KM:Initialize()
    local sv = self:SV()
    if not sv then return end

    sv.blockedAbilityIds = EnsureTable(sv.blockedAbilityIds)
    if sv.blockedAbilityIds[self.DEFAULT_FLARE_ID] == nil then
        sv.blockedAbilityIds[self.DEFAULT_FLARE_ID] = true
    end

    if not self:HasLibSkillBlocker() then
        sv.blockFlare = false
    end

    self.lastArchdruidTime = GetGameTimeSeconds() - (sv.timeout or DEFAULTS.km.timeout)

    self:CreateWarningWindow()
    self:ApplyAnchor()
    self:EnableDragging(sv.enableReposition)
    self:SetupSkillBlocking()
    self:RegisterSlashCommands()

    if sv.enabled then
        self:ToggleBackgroundLoops(true)
    end
end

local function SV()
    return KRT.sv
end

function KRT.KM:GetLAMSubmenu()
    return {
        type = "submenu",
        name = "Kromitor Moment",
        controls = {
            {
                type = "checkbox",
                name = "Enable KromitorMoment",
                getFunc = function()
                    return SV().km.enabled
                end,
                setFunc = function(v)
                    SV().km.enabled = v
                    if not v then
                        if KRT.KM.warningWindow then
                            KRT.KM.warningWindow:SetHidden(true)
                        end
                        KRT.KM:ToggleBackgroundLoops(false)
                    else
                        KRT.KM:ToggleBackgroundLoops(true)
                    end
                end,
                width = "full",
            },
            {
                type = "checkbox",
                name = "Enable repositioning (drag)",
                getFunc = function()
                    return SV().km.enableReposition
                end,
                setFunc = function(v)
                    SV().km.enableReposition = v
                    KRT.KM:EnableDragging(v)
                    KRT.KM:ApplyAnchor()
                end,
                width = "full",
                disabled = function()
                    return not SV().km.enabled
                end,
            },
            {
                type = "checkbox",
                name = "Block configured skills (LibSkillBlocker)",
                getFunc = function()
                    if not KRT.KM:HasLibSkillBlocker() and SV().km.blockFlare then
                        SV().km.blockFlare = false
                    end
                    return SV().km.blockFlare
                end,
                setFunc = function(v)
                    if not KRT.KM:HasLibSkillBlocker() then
                        SV().km.blockFlare = false
                        return
                    end
                    SV().km.blockFlare = v
                end,
                width = "full",
                disabled = function()
                    return not SV().km.enabled or not KRT.KM:HasLibSkillBlocker()
                end,
                warning = function()
                    if not KRT.KM:HasLibSkillBlocker() then
                        return "|cFF0000libskillblocker is missing or turned off|r"
                    end
                    return nil
                end,
            },
            {
                type = "description",
                title = "Blocked ability IDs",
                text = function()
                    return KRT.KM:GetBlockedAbilityListText()
                end,
                width = "full",
            },
            {
                type = "editbox",
                name = "Add ability ID to block",
                isMultiline = false,
                getFunc = function()
                    return ""
                end,
                setFunc = function(value)
                    KRT.KM:AddBlockedAbilityIdFromString(value)
                    KRT.KM:SetupSkillBlocking()
                end,
                width = "full",
                disabled = function()
                    return not SV().km.enabled
                end,
            },
            {
                type = "editbox",
                name = "Remove ability ID from block list",
                isMultiline = false,
                getFunc = function()
                    return ""
                end,
                setFunc = function(value)
                    KRT.KM:RemoveBlockedAbilityIdFromString(value)
                end,
                width = "full",
                disabled = function()
                    return not SV().km.enabled
                end,
            },
            {
                type = "slider",
                name = "Archdruid timeout (seconds)",
                min = 5,
                max = 60,
                step = 1,
                getFunc = function()
                    return SV().km.timeout
                end,
                setFunc = function(v)
                    SV().km.timeout = v
                end,
                width = "full",
                disabled = function()
                    return not SV().km.enabled
                end,
            },
            {
                type = "editbox",
                name = "Warning text",
                isMultiline = false,
                getFunc = function()
                    return SV().km.text
                end,
                setFunc = function(v)
                    SV().km.text = IsNonEmptyString(v) and v or DEFAULTS.km.text
                    KRT.KM:UpdateWarningText()
                end,
                width = "full",
                disabled = function()
                    return not SV().km.enabled
                end,
            },
            {
                type = "slider",
                name = "Label scale",
                min = 0.5,
                max = 3.0,
                step = 0.1,
                getFunc = function()
                    return SV().km.labelScale
                end,
                setFunc = function(v)
                    SV().km.labelScale = v
                    KRT.KM:UpdateWarningText()
                end,
                width = "full",
                disabled = function()
                    return not SV().km.enabled
                end,
            },
            {
                type = "checkbox",
                name = "Show static label when missing proc",
                getFunc = function()
                    return SV().km.showStaticLabel
                end,
                setFunc = function(v)
                    SV().km.showStaticLabel = v
                end,
                width = "full",
                disabled = function()
                    return not SV().km.enabled
                end,
            },
            {
                type = "button",
                name = "Reset horizontal position",
                func = function()
                    SV().km.offsetX = 0
                    KRT.KM:ApplyAnchor()
                end,
                disabled = function()
                    return not SV().km.enabled or not SV().km.enableReposition
                end,
                width = "half",
            },
            {
                type = "button",
                name = "Reset vertical position",
                func = function()
                    SV().km.offsetY = DEFAULTS.km.offsetY
                    KRT.KM:ApplyAnchor()
                end,
                disabled = function()
                    return not SV().km.enabled or not SV().km.enableReposition
                end,
                width = "half",
            },
            {
                type = "checkbox",
                name = "KM debug logging",
                getFunc = function()
                    return SV().km.debugEnabled
                end,
                setFunc = function(v)
                    SV().km.debugEnabled = v
                end,
                width = "full",
                disabled = function()
                    return not SV().km.enabled
                end,
            },
        },
    }
end

KRT:RegisterModule(KRT.KM)