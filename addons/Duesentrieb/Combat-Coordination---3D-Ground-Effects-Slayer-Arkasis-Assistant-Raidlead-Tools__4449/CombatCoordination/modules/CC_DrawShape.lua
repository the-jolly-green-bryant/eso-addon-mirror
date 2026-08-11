local CC = CombatCoordination
local LUT = CC.LUT.DRAW_SHAPE

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name      = "DrawShape",
    menuName  = "DRAW SHAPE",
    iconPath  = "/esoui/art/icons/u26_ability_digging_03.dds",
    menuLayer = 0,

    isAiming = false,
    previewEffectId = nil,

    Broadcast = {
        LUT.CIRCLE,
        LUT.RECTANGLE,
    },

    Default = {
        shapeType = LUT.CIRCLE,
        enablePrintChat = false,

        Color = { 0.5, 1, 1, 0.5 },
        textureCircle = "/textures/circle_4_clean.dds",
        textureRectangle   = "/textures/square_4_clean.dds",
        width  = 1000, height = 1000,
        durationMs = 10000,
    },
    ---@type table|any
    SV = {},
}

----------------------------------------------------------------------------------------------------
-- CUSTOM ENABLE
----------------------------------------------------------------------------------------------------
function Module:CustomEnable()
    -- YEAH YEAH I KNOW.. LIBCUSTOMMENU IS IN THE DEPENDENCIES. BUT I MIGHT CHANGE THAT.
    if LibCustomMenu then
        LibCustomMenu:RegisterGroupListContextMenu(function(Data) self:OnContextMenu(Data) end, LibCustomMenu.CATEGORY_LATE)
    end
end

----------------------------------------------------------------------------------------------------
-- PLACE ON UNIT OR SELF
----------------------------------------------------------------------------------------------------
function Module:PlaceOnUnit(unitTag, isTracking, alternativeShape)
    local shapeType = alternativeShape or self.SV.shapeType
    local heading = CC.GetCameraYaw() or 0
    local isRectangle = (shapeType == LUT.RECTANGLE)
    local width, height = self.SV.width, isRectangle and self.SV.height or self.SV.width

    -- STATIC FOR RECT
    if isRectangle then isTracking = false end

    if isRectangle and AreUnitsEqual(unitTag, "player") then
        local _, _, playerHeading = GetMapPlayerPosition("player")
        heading = playerHeading or heading
    end

    local TX, TY, TZ = 0, 0, 0

    if isTracking then
        local trackIndex = AreUnitsEqual(unitTag, "player") and 0 or GetGroupIndexByUnitTag(unitTag)
        TX, TY, TZ = trackIndex, trackIndex, trackIndex
    else
        -- STATIC.. GET POSITION OF TARGET
        local _, worldX, worldY, worldZ = GetUnitRawWorldPosition(unitTag)
        if not worldX or worldX == 0 then return end

        TX, TY, TZ = worldX, worldY, worldZ

        -- STATIC.. OFFSET FOR RECT
        if isRectangle then
            local offset = height / 2
            TX = worldX - (offset * math.sin(heading))
            TZ = worldZ - (offset * math.cos(heading))
        end
    end

    local RX = width / 100
    local RY = math.floor((((heading or 0) % (2 * math.pi)) * 100) + 0.5)
    local RZ = height / 100

    -- COMPRESSED DATA FOR LGB
    local Data = {
        ID = shapeType,
        TX = TX, TY = TY, TZ = TZ,
        RX = RX, RY = RY, RZ = RZ,
    }

    if IsUnitGrouped("player") then
        CC.Broadcast:Send(Data)
    else
        self:HandleBroadcast("player", Data)
    end
end

----------------------------------------------------------------------------------------------------
-- PLACE ON SELF
----------------------------------------------------------------------------------------------------
function Module:PlaceOnSelf()
    self:PlaceOnUnit("player", true)
end

----------------------------------------------------------------------------------------------------
-- START / STOP AIMING
----------------------------------------------------------------------------------------------------
function Module:ToggleAimMode()
    if self.isAiming then
        self:CancelAiming()
    else
        self:StartAiming()
    end
end
SLASH_COMMANDS["/cc_drawshape"] = function() CC.DrawShape:ToggleAimMode() end

----------------------------------------------------------------------------------------------------
-- START AIMING
----------------------------------------------------------------------------------------------------
function Module:StartAiming()
    self.isAiming = true
    -- TODO: BETTER INSTRUCTIONS?
    --d(string.format("%s Draw Shape (Block = Place | Menu = Cancel)", CC.CHAT))

    local startX, startY, startZ = CC.GetAimTargetPosition()
    local isRectangle  = (self.SV.shapeType == LUT.RECTANGLE)
    local texture = isRectangle and self.SV.textureRectangle or self.SV.textureCircle

    local width = self.SV.width
    local height = isRectangle and self.SV.height or self.SV.width

    -- DRAW PREVIEW
    self.previewEffectId = CC.DisplayEffect:Draw3DEffect({
        ID = "CC_DrawShape_Preview",
        unitTag = "camera",

        TX = startX, RX = -(math.pi / 2), FX = false,
        TY = startY, RY = 0,              FY = isRectangle, -- RECT?
        TZ = startZ, RZ = 0,              FZ = false,

        isFastUpdate = true,

        width = width, height = height,
        texture = texture,
        durationMs = 0,
        ColorStart = self.SV.Color,
    })

    local wasBlocking = IsBlockActive()

    -- AIMING LOOP
    EVENT_MANAGER:RegisterForUpdate(CC.NAME .. "DrawShape_Aiming_OnUpdate", 100, function()
        -- FAILSAFE
        if SCENE_MANAGER:IsInUIMode() then
            self:CancelAiming()
            return
        end

        local isBlocking = IsBlockActive()

        -- ONLY NEW
        if isBlocking and not wasBlocking then
            self:ConfirmPlacement()
            return
        end

        wasBlocking = isBlocking
    end)
end

----------------------------------------------------------------------------------------------------
-- STOP AIMING
----------------------------------------------------------------------------------------------------
function Module:CancelAiming()
    if not self.isAiming then return end
    self.isAiming = false
    EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. "DrawShape_Aiming_OnUpdate")

    if self.previewEffectId then
        CC.DisplayEffect:RemoveTrackedEffect(self.previewEffectId)
        self.previewEffectId = nil
    end
end

----------------------------------------------------------------------------------------------------
-- CONFIRM PLACEMENT AND LGB
----------------------------------------------------------------------------------------------------
function Module:ConfirmPlacement()
    if not self.isAiming then return end
    self:CancelAiming()

    local isRectangle = (self.SV.shapeType == LUT.RECTANGLE)
    local TX, TY, TZ = CC.GetAimTargetPosition()

    -- ABORT IF 0,0,0
    if not TX or (TX == 0 and TY == 0 and TZ == 0) then
        d(string.format("%s %s", CC.CHAT, CC.ColorString("Invalid placement location.", "RD")))
        return
    end

    local heading = CC.GetCameraYaw() or 0
    local width = self.SV.width
    local height  = isRectangle and self.SV.height or self.SV.width

    -- VALUES
    local RX = width / 100
    local RY = math.floor((((heading or 0) % (2 * math.pi)) * 100) + 0.5)
    local RZ = height / 100

    -- COMPRESSED DATA FOR LGB
    local Data = {
        ID = self.SV.shapeType,
        TX = TX, TY = TY, TZ = TZ,
        RX = RX, -- WIDTH IN METER
        RY = RY, -- ANGLE
        RZ = RZ, -- HEIGHT IN METER
    }

    if IsUnitGrouped("player") then
        CC.Broadcast:Send(Data)
    else
        self:HandleBroadcast("player", Data)
    end
end

----------------------------------------------------------------------------------------------------
-- HANDLE INC BROADCAST
----------------------------------------------------------------------------------------------------
function Module:HandleBroadcast(unitTag, Data)
    if not Data or (Data.ID ~= LUT.CIRCLE and Data.ID ~= LUT.RECTANGLE) then return end

    local displayName = GetUnitDisplayName(unitTag) or unitTag
    local isRectangle  = (Data.ID == LUT.RECTANGLE)
    local shapeName = isRectangle and "Rectangle" or "Circle"
    local texture = isRectangle and self.SV.textureRectangle or self.SV.textureCircle

    local targetUnitTag = nil
    local TX, TY, TZ = Data.TX, Data.TY, Data.TZ

    -- DECODE TRACKING TARGET (TX == TY == TZ)
    if TX == TY and TY == TZ then
        local groupIndex = TX
        if groupIndex == 0 then
            targetUnitTag = unitTag
        elseif groupIndex >= 1 and groupIndex <= 12 then
            targetUnitTag = GetGroupUnitTagByIndex(groupIndex)
        end

        -- FETCH POS TO AVOID SPAWN AT 0, 0, 0
        if targetUnitTag and DoesUnitExist(targetUnitTag) then
            local _, worldX, worldY, worldZ = GetUnitRawWorldPosition(targetUnitTag)
            if worldX then
                TX, TY, TZ = worldX, worldY, worldZ
            else
                return
            end
        else
            return
        end
    end

    -- VALUES
    local width = (Data.RX or 0) * 100
    local height = isRectangle and ((Data.RZ or 0) * 100) or width
    local RY = (Data.RY or 0) / 100

    if self.SV.enablePrintChat then
        local chatName = displayName
        if targetUnitTag then
            chatName = chatName .. " -> " .. (GetUnitDisplayName(targetUnitTag) or targetUnitTag)
        end
        d(string.format("%s Shape drawn. Source: %s - Type: %s - W: %dm / H: %dm", CC.CHAT, chatName, shapeName, width / 100, height / 100))
    end

    -- REMOVE IF EXISTS
    local trackingKey = "DrawShape_" .. tostring(unitTag)
    if CC.DisplayEffect.EffectTimers[trackingKey] then
        CC.DisplayEffect:RemoveTrackedEffect(CC.DisplayEffect.EffectTimers[trackingKey].effectId)
    end

    -- DRAW
    local effectId = CC.DisplayEffect:Draw3DEffect({
        ID = trackingKey,
        unitTag = targetUnitTag, -- TRACKING

        TX = TX, RX = -(math.pi / 2),          FX = false,
        TY = TY, RY = isRectangle and RY or 0, FY = false,
        TZ = TZ, RZ = 0,                       FZ = false,

        width = width, height = height,
        texture = texture,
        durationMs = self.SV.durationMs,
        ColorStart = self.SV.Color,
    })

    local currentTime = GetGameTimeMilliseconds()
    CC.DisplayEffect.EffectTimers[trackingKey] = { currentTime = currentTime, startTime = currentTime, effectId = effectId }
end

----------------------------------------------------------------------------------------------------
-- CONTEXT MENU (LIBCUSTOMMENU)
----------------------------------------------------------------------------------------------------
function Module:OnContextMenu(Data)
    -- YEAH YEAH I KNOW.. LIBCUSTOMMENU IS IN THE DEPENDENCIES. BUT I MIGHT CHANGE THAT.
    if not LibCustomMenu or not Data or not Data.displayName then return end
    if not IsUnitGrouped("player") then return end

    local unitTag = nil
    local targetName = Data.displayName

    for i = 1, GetGroupSize() do
        local tag = GetGroupUnitTagByIndex(i)
        if GetUnitDisplayName(tag) == targetName or GetRawUnitName(tag) == targetName then
            unitTag = tag
            break
        end
    end

    if not unitTag and (GetUnitDisplayName("player") == targetName or GetRawUnitName("player") == targetName) then
        unitTag = "player"
    end

    if not unitTag then return end

    local menuIcon = string.format("|t%d:%d:/esoui/art/icons/u26_ability_digging_03.dds|t ", CC.SIZE_ICON_LCM, CC.SIZE_ICON_LCM)
    AddCustomSubMenuItem(menuIcon .. CC.ColorString("[CC] Draw Shape", "tier2"), {
        {
            label = "Draw Circle (Static)",
            callback = function() self:PlaceOnUnit(unitTag, false, LUT.CIRCLE) end,
        },
        {
            label = "Draw Circle (Tracking)",
            callback = function() self:PlaceOnUnit(unitTag, true, LUT.CIRCLE) end,
        },
        -- {
        --     label = "Draw Rectangle (Static)",
        --     callback = function() self:PlaceOnUnit(unitTag, false, LUT.RECTANGLE) end,
        -- },
        -- {
        --     label = "Draw Rectangle (Tracking)",
        --     callback = function() self:PlaceOnUnit(unitTag, true, LUT.RECTANGLE) end,
        -- }
    })
end

----------------------------------------------------------------------------------------------------
-- LAM2 MENU
----------------------------------------------------------------------------------------------------
function Module:GetMenuOptions()
    -- UPDATE PREVEW
    local function UpdatePreview()
        local Preview = CC.Menu.Previews[self.name]
        if Preview then
            local isRectangle = (self.SV.shapeType == LUT.RECTANGLE)
            local texture = isRectangle and self.SV.textureRectangle or self.SV.textureCircle
            Preview:SetTexture(CC.NAME .. texture)
            Preview:SetColor(unpack(self.SV.Color))
        end
    end

    local menuIcon = string.format("|t%d:%d:%s|t", CC.SIZE_ICON_LAM_SM, CC.SIZE_ICON_LAM_SM, self.iconPath)

    return {
        type = "submenu",
        name = string.format("%s %s %s", menuIcon, CC.ColorString(self.menuName, "tier2"), CC.ColorString("[LGB]", "GN")),
        controls = {
            {
                type = "description",
                text = CC.ColorString("Command:", "tier2") .. " Use " .. CC.ColorString("[Keybind]", "tier3") .. " or " .. CC.ColorString("[/cc_drawshape]", "tier3") .. ".\nDraws and shares (synchronized) 3D shapes.",
                width = "full",
            },
            { type = "header", name = CC.ColorString("MANUAL PLACEMENT", "tier3") },
            {
                type = "button",
                name = "PLACE AT CURSOR",
                func = function()
                    if CC.Menu.PanelName and LibAddonMenu2 then
                        SCENE_MANAGER:SetInUIMode(false)
                        self:StartAiming()
                    end
                end,
                width = "half",
            },
            {
                type = "button",
                name = "PLACE ON SELF",
                func = function()
                    self:PlaceOnSelf()
                end,
                width = "half",
            },
            { type = "header", name = CC.ColorString("VISUALS", "tier3") },
            {
                type = "dropdown",
                name = "Active Shape Type",
                -- TODO: MAKE THIS DEFINED IN MODUL OR GLOBAL?
                choices = { "Circle", "Rectangle" },
                choicesValues = { LUT.CIRCLE, LUT.RECTANGLE },
                getFunc = function() return self.SV.shapeType end,
                setFunc = function(value)
                    self.SV.shapeType = value
                    UpdatePreview()
                end,
                default = self.Default.shapeType,
            },
            {
                type = "description",
                text = CC.ColorString("Note:", "tier2") .. " Parameter specifies diameter, not radius.",
                width = "full",
            },
            {
                type = "slider",
                name = "Width / Diameter [meter]",
                tooltip = "Overall width / diameter in meters. Max: 54m.",
                min = 1, max = 54, step = 1,
                getFunc = function() return self.SV.width / 100 end,
                setFunc = function(value) self.SV.width = value * 100 end,
                default = self.Default.width / 100,
            },
            {
                type = "slider",
                name = "Length [meter]",
                tooltip = "Overall length in meters. Max: 54m.",
                min = 1, max = 54, step = 1,
                getFunc = function() return self.SV.height / 100 end,
                setFunc = function(value) self.SV.height = value * 100 end,
                default = self.Default.height / 100,
                disabled = function() return self.SV.shapeType == LUT.CIRCLE end,
            },
            {
                type = "colorpicker",
                name = "Shape Color",
                getFunc = function() return unpack(self.SV.Color) end,
                setFunc = function(r, g, b, a)
                    self.SV.Color = {r, g, b, a}
                    UpdatePreview()
                end,
                default = CC.GetRgbaFromArray(self.Default.Color),
            },
            {
                type = "dropdown",
                name = "Texture (Circle)",
                choices = CC.CIRCLE_CHOICES,
                choicesValues = CC.CIRCLE_VALUES,
                getFunc = function() return self.SV.textureCircle end,
                setFunc = function(value)
                    self.SV.textureCircle = value
                    UpdatePreview()
                end,
                default = self.Default.textureCircle,
            },
            {
                type = "dropdown",
                name = "Texture (Rectangle)",
                choices = CC.SQUARE_CHOICES,
                choicesValues = CC.SQUARE_VALUES,
                getFunc = function() return self.SV.textureRectangle end,
                setFunc = function(value)
                    self.SV.textureRectangle = value
                    UpdatePreview()
                end,
                default = self.Default.textureRectangle,
            },
            {
                type = "custom",
                createFunc = function(CustomControl)
                    local Control = WINDOW_MANAGER:CreateControl(nil, CustomControl, CT_TEXTURE)
                    Control:SetAnchor(CENTER, CustomControl, CENTER)
                    Control:SetDimensions(128, 128)

                    local isRectangle = (self.SV.shapeType == LUT.RECTANGLE)
                    local texture = isRectangle and self.SV.textureRectangle or self.SV.textureCircle
                    Control:SetTexture(CC.NAME .. texture)
                    Control:SetColor(unpack(self.SV.Color))

                    CC.Menu.Previews[self.name] = Control
                end,
                minHeight = 128,
                width = "full",
            },
            {
                type = "divider",
            },
            {
                type = "checkbox",
                name = "Print Coordinates To Chat",
                getFunc = function() return self.SV.enablePrintChat end,
                setFunc = function(value) self.SV.enablePrintChat = value end,
                default = self.Default.enablePrintChat,
                disabled = function() return not CC.SV.enableAddon end,
            },
        },
    }
end

CC[Module.name] = Module
table.insert(CC.Modules, Module)