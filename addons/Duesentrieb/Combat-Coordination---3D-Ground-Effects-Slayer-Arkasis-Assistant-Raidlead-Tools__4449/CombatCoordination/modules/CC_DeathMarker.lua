local CC = CombatCoordination

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name      = "DeathMarker",
    menuName  = "DEATH MARKER - REZ HELPER",
    iconPath  = "/esoui/art/icons/passive_necromancer_002.dds",
    menuLayer = 0,

    ActiveMarkers = {},
    isLoopRunning = false,

    TextureChoices = CC.CHEVRON_CHOICES,
    TextureValues  = CC.CHEVRON_VALUES,

    Default = {
        enableDrawName = true,
        enableDrawVisuals = true,
        offsetTY = 0,

        Color = { 0.5, 0.5, 0.5, 0.75 },

        fontSize = 75,
        fontStyle = "$(BOLD_FONT)",
        fontWeight = "thick-outline",

        texture = "/textures/chevron_64_clean.dds",
        width = 75, height = 75,

        autoHideSec = 30, -- 0 = INFINITE

        enableNotification = true,
        volumeNotification = 0,
    },
    ---@type table|any
    SV = {},
}

function Module:CustomDisable()
    self:ClearAll()
end

----------------------------------------------------------------------------------------------------
-- DEATH STATE CHANGED
----------------------------------------------------------------------------------------------------
function Module:OnDeathStateChanged(eventCode, unitTag, isDead)
    if not CC.SV.enableAddon then return end
    if not unitTag or unitTag == "" then return end

    -- IGNORE SELF
    if AreUnitsEqual(unitTag, "player") then return end
    if not IsUnitGrouped(unitTag) then return end

    if isDead then
        local _, TX, TY, TZ = GetUnitRawWorldPosition(unitTag)
        if not TX then return end

        local displayName = GetUnitDisplayName(unitTag) or unitTag
        self:AddMarker(unitTag, TX, TY, TZ, displayName, false)
    else
        self:RemoveMarker(unitTag)
    end
end

----------------------------------------------------------------------------------------------------
-- NOTIFICATION
----------------------------------------------------------------------------------------------------
function Module:PlayNotification(displayName)
    if not self.SV.enableNotification then return end

    local durationSec = 2.0
    local colorHex = CC.GetHexColorFromArray(self.SV.Color) or "|cBFBFBF"
    local size = math.floor(CC.DisplayNotification.SV.fontSize)
    local iconSkull = string.format("|t%d:%d:/esoui/art/icons/mapkey/mapkey_groupboss.dds|t ", size, size)

    local line1 = iconSkull .. colorHex .. tostring(displayName) .. "|r"
    local line2 = ""
    local playSound = false

    -- TODO: CHANGE TO THIS BREAKING GLASS SOUND LIKE BANDITS HAD?
    if self.SV.volumeNotification > 0 then
        CC.PlaySound(SOUNDS.DUEL_START, self.SV.volumeNotification)
    end

    CC.DisplayNotification:TriggerCustom(durationSec, line1, line2, playSound)
end

----------------------------------------------------------------------------------------------------
-- ADD MARKER
----------------------------------------------------------------------------------------------------
function Module:AddMarker(unitTag, TX, TY, TZ, displayName, isTest)
    self.ActiveMarkers[unitTag] = {
        isTest = isTest,
        deathTime = GetGameTimeSeconds()
    }

    -- local cleanName = string.gsub(displayName, "^@", "")
    local trackingKey = "DeathMarker_" .. tostring(unitTag)
    local currentTime = GetGameTimeMilliseconds()

    -- REMOVE EXISTING
    if CC.DisplayEffect.EffectTimers[trackingKey] then
        CC.DisplayEffect:RemoveTrackedEffect(CC.DisplayEffect.EffectTimers[trackingKey].effectId)
    end
    if CC.DisplayLabel.LabelTimers[trackingKey] then
        CC.DisplayLabel:RemoveTrackedLabel(CC.DisplayLabel.LabelTimers[trackingKey].labelId)
    end

    local width, height = self.SV.width, self.SV.height
    local colorMarker = self.SV.Color

    -- DRAW EFFECT
    if self.SV.enableDrawVisuals then
        local effectId = CC.DisplayEffect:Draw3DEffect({
            ID = trackingKey,

            TX = TX, RX = 0, FX = false,
            TY = TY, RY = 0, FY = true,
            TZ = TZ, RZ = 0, FZ = false,

            offsetTY = height / 2 + self.SV.offsetTY,
            textureCoordsRotation = math.pi,

            unitTag = unitTag, -- TRACKING BECAUSE CORPSED GET PUSHED AROUND A LOT o.O

            width = width, height = height,
            texture = self.SV.texture,
            durationMs = 0, -- INFINITE
            Color = colorMarker,
        })
        CC.DisplayEffect.EffectTimers[trackingKey] = { currentTime = currentTime, startTime = currentTime, effectId = effectId }
    end

    -- DRAW LABEL
    if self.SV.enableDrawName then
        local font = string.format("%s|%d|%s", self.SV.fontStyle, self.SV.fontSize, self.SV.fontWeight)
        local labelId = CC.DisplayLabel:Draw3DLabel({
            ID = trackingKey,

            TX = TX, RX = 0,             FX = false,
            TY = TY, RY = 0,             FY = true,
            TZ = TZ, RZ = (math.pi / 2), FZ = false,

            offsetTY = height * 1.5 + self.SV.offsetTY,
            isProximityFade = true,

            unitTag = unitTag, -- TRACKING BECAUSE CORPSED GET PUSHED AROUND A LOT o.O

            font = font,
            displayText = displayName,
            durationMs = 0, -- INFINITE
            Color = colorMarker,
        })
        CC.DisplayLabel.LabelTimers[trackingKey] = { currentTime = currentTime, startTime = currentTime, labelId = labelId }
    end

    self:StartUpdateLoop()
    self:PlayNotification(displayName)
end

----------------------------------------------------------------------------------------------------
-- CLEANUP
----------------------------------------------------------------------------------------------------
function Module:RemoveMarker(unitTag)
    self.ActiveMarkers[unitTag] = nil
    local trackingKey = "DeathMarker_" .. tostring(unitTag)

    if CC.DisplayEffect.EffectTimers[trackingKey] then
        CC.DisplayEffect:RemoveTrackedEffect(CC.DisplayEffect.EffectTimers[trackingKey].effectId)
        CC.DisplayEffect.EffectTimers[trackingKey] = nil
    end

    if CC.DisplayLabel.LabelTimers[trackingKey] then
        CC.DisplayLabel:RemoveTrackedLabel(CC.DisplayLabel.LabelTimers[trackingKey].labelId)
        CC.DisplayLabel.LabelTimers[trackingKey] = nil
    end
end

function Module:ClearAll()
    for unitTag, _ in pairs(self.ActiveMarkers) do
        self:RemoveMarker(unitTag)
    end
    self.ActiveMarkers = {}

    if self.isLoopRunning then
        self.isLoopRunning = false
        EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. self.name .. "OnUpdate")
    end
end

----------------------------------------------------------------------------------------------------
-- UPDATE
----------------------------------------------------------------------------------------------------
function Module:StartUpdateLoop()
    if self.isLoopRunning then return end
    self.isLoopRunning = true

    EVENT_MANAGER:RegisterForUpdate(CC.NAME .. self.name .. "OnUpdate", 100, function()
        self:OnUpdate()
    end)
end

function Module:OnUpdate()
    local count = 0
    local currentTime = GetGameTimeSeconds()

    for unitTag, Marker in pairs(self.ActiveMarkers) do
        count = count + 1
        local remove = false

        -- REMOVAL
        if not DoesUnitExist(unitTag) then remove = true
        elseif not Marker.isTest and not IsUnitGrouped(unitTag) then remove = true
        elseif not IsUnitOnline(unitTag) then remove = true
        elseif not Marker.isTest and not IsUnitDead(unitTag) then remove = true
        elseif IsUnitBeingResurrected(unitTag) or DoesUnitHaveResurrectPending(unitTag) then remove = true
        elseif self.SV.autoHideSec > 0 and (currentTime - Marker.deathTime) > self.SV.autoHideSec then remove = true
        end

        if remove then
            self:RemoveMarker(unitTag)
            count = count - 1
        end
    end

    -- NO MARKERS.. STOP LOOP
    if count <= 0 then
        self:ClearAll()
    end
end

----------------------------------------------------------------------------------------------------
-- TEST COMMAND
----------------------------------------------------------------------------------------------------
SLASH_COMMANDS["/cc_deathmarker"] = function(displayName)
    local unitTag = "player"
    if displayName and displayName ~= "" then unitTag = displayName end

    if Module.ActiveMarkers[unitTag] then
        Module:RemoveMarker(unitTag)
        d(CC.CHAT .. " Test marker removed.")
        return
    end

    local _, worldX, worldY, worldZ = GetUnitRawWorldPosition(unitTag)
    Module:AddMarker(unitTag, worldX, worldY, worldZ, GetUnitDisplayName(unitTag) or unitTag, true)
    d(CC.CHAT .. " Test marker drawn.")
end

----------------------------------------------------------------------------------------------------
-- LAM2 MENU SETTINGS
----------------------------------------------------------------------------------------------------
function Module:GetMenuOptions()
    local menuIcon = string.format("|t%d:%d:%s|t", CC.SIZE_ICON_LAM_SM, CC.SIZE_ICON_LAM_SM, self.iconPath)

    return {
        type = "submenu",
        name = string.format("%s %s", menuIcon, CC.ColorString(self.menuName, "tier2")),
        controls = {
            {
                type = "description",
                text = "Draws 3D marker on fallen (dead) group members.\nMarker auto-removes upon resurrection.",
                width = "full",
            },

            ----------------------------------------------------------------------------------------------------
            -- BEHAVIOR
            ----------------------------------------------------------------------------------------------------
            { type = "header", name = CC.ColorString("BEHAVIOR", "tier3") },
            {
                type = "slider",
                name = "Auto-Hide Marker [sec]",
                tooltip = "Hide marker after a certain amount of time. 0 = infinite",
                min = 0, max = 60, step = 5,
                getFunc = function() return self.SV.autoHideSec end,
                setFunc = function(value) self.SV.autoHideSec = value end,
                default = self.Default.autoHideSec,
                disabled = function() return not CC.SV.enableAddon end,
            },

            ----------------------------------------------------------------------------------------------------
            -- NOTIFICATION
            ----------------------------------------------------------------------------------------------------
            { type = "header", name = CC.ColorString("NOTIFICATION", "tier3") },
            {
                type = "checkbox",
                name = "Enable Center Screen Notification",
                getFunc = function() return self.SV.enableNotification end,
                setFunc = function(value)
                    self.SV.enableNotification = value
                    local colorHex = CC.GetHexColorFromArray(self.SV.Color) or "|cBFBFBF"
                    local size = math.floor(CC.DisplayNotification.SV.fontSize)
                    local iconSkull = string.format("|t%d:%d:/esoui/art/icons/mapkey/mapkey_groupboss.dds|t ", size, size)
                    local line1 = iconSkull .. colorHex .. "@Duesentrieb|r"
                    if value then CC.DisplayNotification:TriggerCustom(1.5, line1, "", false) end
                end,
                default = self.Default.enableNotification,
                disabled = function() return not CC.SV.enableAddon end,
            },
            {
                type = "slider",
                name = "Volume Notification 0 = OFF",
                min = 0, max = 10, step = 1,
                getFunc = function() return self.SV.volumeNotification end,
                setFunc = function(value)
                    self.SV.volumeNotification = value
                    if value > 0 then
                        CC.PlaySound(SOUNDS.DUEL_START, value)
                    end
                end,
                default = self.Default.volumeNotification,
                disabled = function() return not self.SV.enableNotification or not CC.SV.enableAddon end,
            },

            ----------------------------------------------------------------------------------------------------
            -- NAMEPLATE
            ----------------------------------------------------------------------------------------------------
            { type = "header", name = CC.ColorString("SETTINGS NAMEPLATE", "tier3") },
            {
                type = "checkbox",
                name = "Enable Nameplate",
                tooltip = "Draws player's name above the marker.",
                getFunc = function() return self.SV.enableDrawName end,
                setFunc = function(value) self.SV.enableDrawName = value end,
                default = self.Default.enableDrawName,
                disabled = function() return not CC.SV.enableAddon end,
            },
            {
                type = "slider",
                name = "Font Size",
                tooltip = "Adjusts fontsize of nameplate.",
                min = 50, max = 100, step = 5,
                getFunc = function() return self.SV.fontSize end,
                setFunc = function(value) self.SV.fontSize = value end,
                default = self.Default.fontSize,
                disabled = function() return not CC.SV.enableAddon or not self.SV.enableDrawName end,
            },
            {
                type = "dropdown",
                name = "Font Style",
                tooltip = "Select font style for nameplate.",
                choices = CC.FONT_STYLE_CHOICES,
                choicesValues = CC.FONT_STYLE_VALUES,
                getFunc = function() return self.SV.fontStyle end,
                setFunc = function(value) self.SV.fontStyle = value end,
                default = self.Default.fontStyle,
                disabled = function() return not CC.SV.enableAddon or not self.SV.enableDrawName end,
            },
            {
                type = "dropdown",
                name = "Font Weight",
                tooltip = "Select outline style for nameplate.",
                choices = CC.FONT_WEIGHT_CHOICES,
                choicesValues = CC.FONT_WEIGHT_VALUES,
                getFunc = function() return self.SV.fontWeight end,
                setFunc = function(value) self.SV.fontWeight = value end,
                default = self.Default.fontWeight,
                disabled = function() return not CC.SV.enableAddon or not self.SV.enableDrawName end,
            },
            {
                type = "divider",
            },
            {
                type = "slider",
                name = "Vertical Offset [meter]",
                tooltip = "Distance from the ground for nameplate.",
                min = -2.5, max = 2.5, step = 0.1, decimals = 1,
                getFunc = function() return self.SV.offsetTY / 100 end,
                setFunc = function(value) self.SV.offsetTY = value * 100 end,
                default = self.Default.offsetTY / 100,
                disabled = function() return not CC.SV.enableAddon or not self.SV.enableDrawName end,
            },

            ----------------------------------------------------------------------------------------------------
            -- VISUAL SETTINGS
            ----------------------------------------------------------------------------------------------------
            { type = "header", name = CC.ColorString("VISUALS", "tier3") },
            {
                type = "checkbox",
                name = "Enable Visuals",
                tooltip = "Draws the 3D marker texture on the ground.",
                getFunc = function() return self.SV.enableDrawVisuals end,
                setFunc = function(value) self.SV.enableDrawVisuals = value end,
                default = self.Default.enableDrawVisuals,
                disabled = function() return not CC.SV.enableAddon end,
            },
            {
                type = "colorpicker",
                name = "Marker Color",
                getFunc = function() return unpack(self.SV.Color) end,
                setFunc = function(r, g, b, a)
                    self.SV.Color = {r, g, b, a}
                    local Preview = CC.Menu.Previews[self.name]
                    if Preview then
                        Preview:SetColor(r, g, b, a)
                    end
                end,
                default = CC.GetRgbaFromArray(self.Default.Color),
                disabled = function() return not CC.SV.enableAddon end,
            },
            {
                type = "slider",
                name = "Marker Width [meter]",
                min = 0.5, max = 1, step = 0.05, decimals = 2,
                getFunc = function() return self.SV.width / 100 end,
                setFunc = function(value) self.SV.width = value * 100 end,
                default = self.Default.width / 100,
                disabled = function() return not CC.SV.enableAddon or not self.SV.enableDrawVisuals end,
            },
            {
                type = "slider",
                name = "Marker Height [meter]",
                min = 0.5, max = 1, step = 0.05, decimals = 2,
                getFunc = function() return self.SV.height / 100 end,
                setFunc = function(value) self.SV.height = value * 100 end,
                default = self.Default.height / 100,
                disabled = function() return not CC.SV.enableAddon or not self.SV.enableDrawVisuals end,
            },
            {
                type = "dropdown",
                name = "Texture",
                choices = self.TextureChoices,
                choicesValues = self.TextureValues,
                getFunc = function() return self.SV.texture end,
                setFunc = function(value)
                    self.SV.texture = value
                    local Preview = CC.Menu.Previews[self.name]
                    if Preview then
                        Preview:SetTexture(CC.NAME .. value)
                    end
                end,
                default = self.Default.texture,
                disabled = function() return not CC.SV.enableAddon or not self.SV.enableDrawVisuals end,
            },
            {
                type = "custom",
                createFunc = function(CustomControl)
                    local Control = WINDOW_MANAGER:CreateControl(nil, CustomControl, CT_TEXTURE)
                    Control:SetAnchor(CENTER, CustomControl, CENTER)
                    Control:SetDimensions(128, 128)
                    Control:SetTexture(CC.NAME .. self.SV.texture)
                    Control:SetColor(unpack(self.SV.Color))
                    Control:SetTextureRotation(math.pi)

                    CC.Menu.Previews[self.name] = Control
                end,
                minHeight = 128,
                width = "full",
            },
        },
    }
end

CC[Module.name] = Module
table.insert(CC.Modules, Module)