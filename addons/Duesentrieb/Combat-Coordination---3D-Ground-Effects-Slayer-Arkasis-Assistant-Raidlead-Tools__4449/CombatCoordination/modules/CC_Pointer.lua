local CC = CombatCoordination
local LUT = CC.LUT.POINTER

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name      = "Pointer",
    menuName  = "POINTER - FLARE 2.0",
    iconPath  = "/esoui/art/icons/ability_ava_revealing_flare.dds",
    menuLayer = 0,

    isAiming = false,
    previewEffectId = nil,

    TextureChoices = CC.CHEVRON_CHOICES,
    TextureValues  = CC.CHEVRON_VALUES,

    Broadcast = {
        LUT.PLACE,
    },

    Default = {
        enableDrawName = true,
        enablePrintChat = false,
        offsetTY = 0,

        fontSize = 100,
        fontStyle = "$(BOLD_FONT)",
        fontWeight = "thick-outline",

        texture = "/textures/chevron_64_clean.dds",
        width = 100, height = 100,
        updateMs = 100, durationMs = 10000,
        -- TODO: MAKE DURATION AN OPTION IN MENU
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
        -- GROUP LIST, PLAYER INTERACTION?, CHAT? TODO: ADD THESE EVENTUALLY
        LibCustomMenu:RegisterGroupListContextMenu(function(Data) self:OnContextMenu(Data) end, LibCustomMenu.CATEGORY_LATE)
    end
end

----------------------------------------------------------------------------------------------------
-- PLACE ON UNIT OR SELF
----------------------------------------------------------------------------------------------------
function Module:PlaceOnUnit(unitTag)
    local _, worldX, worldY, worldZ = GetUnitRawWorldPosition(unitTag)
    if not worldX then return end

    local Data = { ID = LUT.PLACE, TX = worldX, TY = worldY, TZ = worldZ, RX = 0, RY = 0, RZ = 0 }

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
    self:PlaceOnUnit("player")
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
SLASH_COMMANDS["/cc_pointer"] = function() CC.Pointer:ToggleAimMode() end

----------------------------------------------------------------------------------------------------
-- START AIMING
----------------------------------------------------------------------------------------------------
function Module:StartAiming()
    self.isAiming = true
    -- d(string.format("%s Pointer (Right Click = Place | Hotkey/Menu = Cancel)", CC.CHAT))

    local Color = CC.GetColorFromGroupIndex("player")
    local width = self.SV.width
    local height = self.SV.height

    local startX, startY, startZ = CC.GetAimTargetPosition()

    -- DRAW PREVIEW
    self.previewEffectId = CC.DisplayEffect:Draw3DEffect({
        ID = "CC_Pointer_Preview",
        unitTag = "camera", -- COOL TRICK; HUH?

        TX = startX, RX = 0, FX = false,
        TY = startY, RY = 0, FY = true,
        TZ = startZ, RZ = 0, FZ = false,

        offsetTY = height / 2,
        textureCoordsRotation = math.pi,

        isFastUpdate = true,

        width = width, height = height,
        texture = self.SV.texture,
        durationMs = 0,
        ColorStart = Color,
    })

    local wasBlocking = IsBlockActive()

    -- AIMING LOOP
    EVENT_MANAGER:RegisterForUpdate(CC.NAME .. "Pointer_Aiming_OnUpdate", 100, function()
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
-- CANCEL AIMING
----------------------------------------------------------------------------------------------------
function Module:CancelAiming()
    if not self.isAiming then return end
    self.isAiming = false
    EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. "Pointer_Aiming_OnUpdate")

    if self.previewEffectId then
        CC.DisplayEffect:RemoveTrackedEffect(self.previewEffectId)
        self.previewEffectId = nil
    end
end

----------------------------------------------------------------------------------------------------
-- PLACE POINTER
----------------------------------------------------------------------------------------------------
function Module:ConfirmPlacement()
    if not self.isAiming then return end
    self:CancelAiming()

    local TX, TY, TZ = CC.GetAimTargetPosition()

    -- ABORT IF 0,0,0
    if not TX or (TX == 0 and TY == 0 and TZ == 0) then
        d(string.format("%s %s", CC.CHAT, CC.ColorString("Invalid placement location.", "RD")))
        return
    end

    local Data = {
        ID = LUT.PLACE,
        TX = TX, TY = TY, TZ = TZ,
        RX = 0, RY = 0, RZ = 0
    }

    if IsUnitGrouped("player") then
        CC.Broadcast:Send(Data)
    else
        self:HandleBroadcast("player", Data)
    end
end

----------------------------------------------------------------------------------------------------
-- HANDLE INCOMING BROADCAST
----------------------------------------------------------------------------------------------------
function Module:HandleBroadcast(unitTag, Data)
    if not Data or Data.ID ~= LUT.PLACE then return end

    local Color = CC.GetColorFromGroupIndex(unitTag)
    local displayName = GetUnitDisplayName(unitTag) or unitTag
    local playerLink = CC.GetPlayerLinkFromDisplayName(displayName) or displayName

    local TX, TY, TZ = Data.TX, Data.TY, Data.TZ
    local width = self.SV.width
    local height = self.SV.height
    local font = string.format("%s|%d|%s", self.SV.fontStyle, self.SV.fontSize, self.SV.fontWeight)

    if self.SV.enablePrintChat then
        d(string.format("%s Pointer drawn. Source: %s - X: %d, Y: %d, Z: %d.", CC.CHAT, playerLink, TX, TY, TZ))
    end

    -- DRAW POINTER
    CC.DisplayEffect:Draw3DEffect({
        ID = "CC_Pointer_" .. tostring(unitTag),

        TX = TX, RX = 0, FX = false,
        TY = TY, RY = 0, FY = true,
        TZ = TZ, RZ = 0, FZ = false,

        offsetTY = height / 2,
        textureCoordsRotation = math.pi,

        width = width, height = height,
        texture = self.SV.texture,
        durationMs = self.SV.durationMs,
        Color = Color,
    })

    -- DRAW LABEL
    if self.SV.enableDrawName then
        CC.DisplayLabel:Draw3DLabel({
            ID = LUT.PLACE,

            TX = TX, RX = 0,             FX = false,
            TY = TY, RY = 0,             FY = true,
            TZ = TZ, RZ = (math.pi / 2), FZ = false,

            offsetTY = height * 1.5 + self.SV.offsetTY,
            isProximityFade = true,

            font = font,
            displayText = displayName,
            durationMs = self.SV.durationMs,
            Color = Color,
        })
    end
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

    local menuIcon = string.format("|t%d:%d:/esoui/art/icons/ability_ava_scorching_flare.dds|t ", CC.SIZE_ICON_LCM, CC.SIZE_ICON_LCM)

    AddCustomSubMenuItem(menuIcon .. CC.ColorString("[CC] Draw Pointer", "tier2"), {
        {
            label = "Draw Pointer (Static)",
            callback = function() self:PlaceOnUnit(unitTag) end,
        },
    })
end

----------------------------------------------------------------------------------------------------
-- LAM2 MENU SETTINGS
----------------------------------------------------------------------------------------------------
function Module:GetMenuOptions()
    local menuIcon = string.format("|t%d:%d:%s|t", CC.SIZE_ICON_LAM_SM, CC.SIZE_ICON_LAM_SM, self.iconPath)

    return {
        type = "submenu",
        name = string.format("%s %s %s", menuIcon, CC.ColorString(self.menuName, "tier2"), CC.ColorString("[LGB]", "GN")),
        controls = {
            {
                type = "description",
                text = CC.ColorString("Command:", "tier2") .. " Define a " .. CC.ColorString("[Keybind]", "tier3") .. " or type " .. CC.ColorString("[/cc_pointer]", "tier3") .. ".\n" ..
                       CC.ColorString("Note:", "tier2") .. " The color maps to your group index. Pointer will last for 10s.",
                width = "full",
            },

            ----------------------------------------------------------------------------------------------------
            -- MANUAL PLACEMENT
            ----------------------------------------------------------------------------------------------------
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
                disabled = function() return not CC.SV.enableAddon end,
            },
            {
                type = "button",
                name = "PLACE ON SELF",
                func = function()
                    self:PlaceOnSelf()
                end,
                width = "half",
                disabled = function() return not CC.SV.enableAddon end,
            },

            ----------------------------------------------------------------------------------------------------
            -- TIMER SETTINGS
            ----------------------------------------------------------------------------------------------------
            { type = "header", name = CC.ColorString("SETTINGS NAMEPLATE", "tier3") },
            {
                type = "checkbox",
                name = "Enable Nameplate",
                tooltip = "Draws player's name above marker.",
                getFunc = function() return self.SV.enableDrawName end,
                setFunc = function(value) self.SV.enableDrawName = value end,
                default = self.Default.enableDrawName,
                disabled = function() return not CC.SV.enableAddon end,
            },
            {
                type = "slider",
                name = "Font Size",
                tooltip = "Adjusts fontsize of nameplate.",
                min = 50, max = 150, step = 5,
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

            { type = "header", name = CC.ColorString("VISUALS", "tier3") },
            {
                type = "slider",
                name = "Marker Width [meter]",
                min = 0.5, max = 1.5, step = 0.1, decimals = 1,
                getFunc = function() return self.SV.width / 100 end,
                setFunc = function(value) self.SV.width = value * 100 end,
                default = self.Default.width / 100,
                disabled = function() return not CC.SV.enableAddon end,
            },
            {
                type = "slider",
                name = "Marker Height [meter]",
                min = 0.5, max = 1.5, step = 0.1, decimals = 1,
                getFunc = function() return self.SV.height / 100 end,
                setFunc = function(value) self.SV.height = value * 100 end,
                default = self.Default.height / 100,
                disabled = function() return not CC.SV.enableAddon end,
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
                disabled = function() return not CC.SV.enableAddon end,
            },
            {
                type = "custom",
                createFunc = function(CustomControl)
                    local Control = WINDOW_MANAGER:CreateControl(nil, CustomControl, CT_TEXTURE)
                    Control:SetAnchor(CENTER, CustomControl, CENTER)
                    Control:SetDimensions(128, 128)
                    Control:SetTexture(CC.NAME .. self.SV.texture)
                    local Color = CC.GetColorFromGroupIndex("player")
                    Control:SetColor(unpack(Color))
                    Control:SetTextureRotation(math.pi)

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