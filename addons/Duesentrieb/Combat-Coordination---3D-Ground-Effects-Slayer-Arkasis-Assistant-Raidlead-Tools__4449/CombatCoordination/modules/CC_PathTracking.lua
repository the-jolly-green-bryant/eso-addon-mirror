local CC = CombatCoordination

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name      = "PathTracking",
    menuName  = "PATH TRACKING",
    iconPath  = "/esoui/art/icons/ability_smith_002.dds",
    menuLayer = 0,

    TextureChoices = CC.CHEVRON_CHOICES,
    TextureValues  = CC.CHEVRON_VALUES,

    GroupChoices = { GetUnitDisplayName("player") },
    GroupValues = { "player" },

    unitTag = "player",
    ActiveTracks = {},
    isUpdateLoop = false,

    Default = {
        enableDrawSelf = true,
        enableDrawGroup = true,
        enableGameAoeFriendlyColor = false,
        ColorStart = { 0, 1, 0, 0.75 },
        ColorEnd = { 1, 0, 0, 0.75 },
        texture = "/textures/chevron_64_clean.dds",
        width = 75, height = 75,
        updateMs = 100, durationMs = 2500,
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
-- PATH TRACKING TICK
----------------------------------------------------------------------------------------------------
function Module:OnUpdate()
    local currentTime = GetGameTimeMilliseconds()

    local width = self.SV.width
    local height = self.SV.height
    local targetSpacing = 2 * height
    if targetSpacing <= 0 then return end

    local activeCounter = 0

    for unitTag, TrackData in pairs(self.ActiveTracks) do
        if TrackData.endTime and currentTime > TrackData.endTime then
            self.ActiveTracks[unitTag] = nil
        else
            activeCounter = activeCounter + 1
            local _, worldX, worldY, worldZ = GetUnitRawWorldPosition(unitTag)

            if worldX then
                if not TrackData.LastPosition.TX then
                    TrackData.LastPosition.TX = worldX
                    TrackData.LastPosition.TY = worldY
                    TrackData.LastPosition.TZ = worldZ
                    TrackData.LastPosition.RX = -(math.pi / 2)
                    TrackData.LastPosition.RY = 0
                    TrackData.LastPosition.RZ = 0
                else
                    local distanceX = worldX - TrackData.LastPosition.TX
                    local distanceY = worldY - TrackData.LastPosition.TY
                    local distanceZ = worldZ - TrackData.LastPosition.TZ
                    local distance = math.sqrt(distanceX^2 + distanceY^2 + distanceZ^2)

                    -- DOOR OR PORT.. RESTART
                    if distance > 2800 then
                        TrackData.LastPosition.TX = worldX
                        TrackData.LastPosition.TY = worldY
                        TrackData.LastPosition.TZ = worldZ
                        distance = 0
                    end

                    -- FILL THE GAP
                    while distance >= targetSpacing do
                        local normalizedX = distanceX / distance
                        local normalizedY = distanceY / distance
                        local normalizedZ = distanceZ / distance

                        local ID = "PathTracking_" .. tostring(unitTag)
                        local TX = TrackData.LastPosition.TX + (normalizedX * targetSpacing)
                        local TY = TrackData.LastPosition.TY + (normalizedY * targetSpacing)
                        local TZ = TrackData.LastPosition.TZ + (normalizedZ * targetSpacing)

                        local forwardDistance = math.sqrt(normalizedX^2 + normalizedZ^2)
                        local slopePitch = math.atan2(normalizedY, forwardDistance)
                        local RX = -(math.pi / 2) + slopePitch
                        local RY = math.atan2(normalizedX, normalizedZ) - math.pi
                        local RZ = 0

                        local texture = self.SV.texture
                        local ColorStart = self.SV.enableGameAoeFriendlyColor and CC.GetGameAoeFriendlyColor() or self.SV.ColorStart
                        local ColorEnd = self.SV.enableGameAoeFriendlyColor and CC.GetGameAoeFriendlyColor() or self.SV.ColorEnd
                        local durationMs = self.SV.durationMs

                        local effectId = CC.DisplayEffect:Draw3DEffect(
                        {
                            ID = ID,

                            TX = TX, RX = RX, FX = false,
                            TY = TY, RY = RY, FY = false,
                            TZ = TZ, RZ = RZ, FZ = false,

                            width = width,
                            height = height,

                            texture = texture,
                            durationMs = durationMs,

                            -- FOR WHATEVER REASON ITS RIGHT SIDE UP NOW.
                            -- I MEAN WTF? BUT ITS FINE.. SO GUESS THIS IS NO LONGER NEEDED?
                            -- textureCoordsRotation = math.pi,

                            -- DYNAMICS
                            ColorStart = ColorStart,
                            ColorEnd = ColorEnd,
                        })

                        TrackData.LastPosition.TX = TX
                        TrackData.LastPosition.TY = TY
                        TrackData.LastPosition.TZ = TZ
                        TrackData.LastPosition.RX = RX
                        TrackData.LastPosition.RY = RY
                        TrackData.LastPosition.RZ = RZ

                        distanceX = worldX - TX
                        distanceY = worldY - TY
                        distanceZ = worldZ - TZ
                        distance = math.sqrt(distanceX^2 + distanceY^2 + distanceZ^2)
                    end
                end
            end
        end
    end

    if activeCounter == 0 then
        self:StopUpdateLoop()
    end
end

----------------------------------------------------------------------------------------------------
-- TOGGLE CURRENT TARGET; TODO: KEYBIND?
----------------------------------------------------------------------------------------------------
function Module:ToggleCurrentTarget()
    local unitTag = "player"

    if DoesUnitExist("reticleover") and IsUnitPlayer("reticleover") then
        local foundTag = nil

        for i = 1, GetGroupSize() do
            local tag = GetGroupUnitTagByIndex(i)
            if AreUnitsEqual("reticleover", tag) then
                foundTag = tag
                break
            end
        end

        if foundTag then
            unitTag = foundTag
        elseif AreUnitsEqual("reticleover", "player") then
            unitTag = "player"
        else
            CC.Debug("Module:ToggleCurrentTarget(); reticleover is not in group.")
            return
        end
    end

    local displayName = GetUnitDisplayName(unitTag)

    -- REMOVE AND STOP
    if self.ActiveTracks[unitTag] then
        self.ActiveTracks[unitTag] = nil
        d(string.format("%s Tracking stopped. Target: %s.", CC.CHAT, CC.ColorString(displayName, "RD")))

        local effectId = "PathTracking_" .. tostring(unitTag)
        CC.DisplayEffect:RemoveTrackedEffect(effectId)

        if ZO_IsTableEmpty(self.ActiveTracks) then
            self:StopUpdateLoop()
        end

    -- ADD TO LIST AND START LOOP
    else
        self:AddTrack(unitTag, nil)
        d(string.format("%s Tracking started. Target: %s.", CC.CHAT, CC.ColorString(displayName, "GN")))
    end
end

----------------------------------------------------------------------------------------------------
-- CONTEXT MENU (LIBCUSTOMMENU) RETURN IF NO LibCustomMenu
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
    local displayName = GetUnitDisplayName(unitTag)

    local menuIcon = string.format("|t%d:%d:/esoui/art/icons/ability_smith_002.dds|t ", CC.SIZE_ICON_LCM, CC.SIZE_ICON_LCM)
    AddCustomSubMenuItem(menuIcon .. CC.ColorString("[CC] Path Tracking", "tier2"), {
        {
            label = "Start Tracking",
            callback = function()
                self:AddTrack(unitTag, nil)
                d(string.format("%s Tracking started. Target: %s.", CC.CHAT, CC.ColorString(displayName, "GN")))
            end,
        },
        {
            label = "Stop Tracking",
            callback = function()
                if self.ActiveTracks[unitTag] then
                    self.ActiveTracks[unitTag] = nil
                    d(string.format("%s Tracking stopped. Target: %s.", CC.CHAT, CC.ColorString(displayName, "RD")))

                    local effectId = "PathTracking_" .. tostring(unitTag)
                    CC.DisplayEffect:RemoveTrackedEffect(effectId)

                    if ZO_IsTableEmpty(self.ActiveTracks) then
                        self:StopUpdateLoop()
                    end
                end
            end,
        },
        {
            label = "Stop All Tracks",
            callback = function()
                ZO_ClearTable(self.ActiveTracks)
                d(string.format("%s %s", CC.CHAT, CC.ColorString("All tracking operations stopped.", "RD")))
                self:StopUpdateLoop()
            end,
        }
    })
end

----------------------------------------------------------------------------------------------------
-- ADD / REMOVE TRACKS
----------------------------------------------------------------------------------------------------
function Module:AddTrack(unitTag, durationMs)
    -- local isPlayer = AreUnitsEqual(unitTag, "player")
    -- if not self.SV.enableDrawSelf and isPlayer and not isForced then return end
    -- if not self.SV.enableDrawGroup and not isPlayer and not isForced then return end

    local currentTime = GetGameTimeMilliseconds()
    local endTime = nil
    if durationMs and durationMs > 0 then endTime = currentTime + durationMs end

    self.ActiveTracks[unitTag] = {
        endTime = endTime,
        LastPosition = { TX = nil, TY = nil, TZ = nil, RX = nil, RY = nil, RZ = nil }
    }
    self:StartUpdateLoop()
end

----------------------------------------------------------------------------------------------------
-- START / STOP LOOOP
----------------------------------------------------------------------------------------------------
function Module:StartUpdateLoop()
    if self.isUpdateLoop then return end
    self.isUpdateLoop = true
    EVENT_MANAGER:RegisterForUpdate(CC.NAME .. self.name .. "OnUpdate", self.SV.updateMs, function() self:OnUpdate() end)
end

function Module:StopUpdateLoop()
    self.isUpdateLoop = false
    EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. self.name .. "OnUpdate")
end

----------------------------------------------------------------------------------------------------
-- LAM2
----------------------------------------------------------------------------------------------------
function Module:GetMenuOptions()
    local menuIcon = string.format("|t%d:%d:%s|t", CC.SIZE_ICON_LAM_SM, CC.SIZE_ICON_LAM_SM, self.iconPath)

    return {
        type = "submenu",
        name = string.format("%s %s", menuIcon, CC.ColorString(self.menuName, "tier2")),
        controls = {
            {
                type = "description",
                text = CC.ColorString("Note:", "tier2") .. " Define a " .. CC.ColorString("[Keybind]", "tier3") .. " to track your current target.\n" ..
                       CC.ColorString("Tip:", "tier2") .. " You can also track group members directly via the group window by right-clicking their name and using the context menu.",
                       width = "full",
            },
            { type = "header", name = CC.ColorString("MANUAL TRACKING", "tier3") },
            {
                type = "dropdown",
                name = "Choose Group Member",
                choices = self.GroupChoices,
                choicesValues = self.GroupValues,
                getFunc = function() return self.unitTag end,
                setFunc = function(value) self.unitTag = value end,
                reference = "CC_PathTracker_Dropdown_GroupMember",
                disabled = function() return not CC.SV.enableAddon or (not self.SV.enableDrawSelf and not self.SV.enableDrawGroup) end,
            },
            {
                type = "button",
                name = "REFRESH LIST",
                func = function()
                    ZO_ClearTable(self.GroupChoices)
                    ZO_ClearTable(self.GroupValues)

                    table.insert(self.GroupChoices, GetUnitDisplayName("player"))
                    table.insert(self.GroupValues, "player")

                    if GetGroupSize() > 0 then
                        for i = 1, GetGroupSize() do
                            local unitTag = "group" .. i
                            if not AreUnitsEqual("player", unitTag) then
                                local displayName = GetUnitDisplayName(unitTag)
                                if displayName and displayName ~= "" then
                                    table.insert(self.GroupChoices, displayName)
                                    table.insert(self.GroupValues, unitTag)
                                end
                            end
                        end
                    end

                    self.unitTag = "player"

                    if CC_PathTracker_Dropdown_GroupMember then
                        CC_PathTracker_Dropdown_GroupMember:UpdateChoices(self.GroupChoices, self.GroupValues)
                        CC_PathTracker_Dropdown_GroupMember:UpdateValue()
                    end
                end,
                width = "half",
                disabled = function() return not CC.SV.enableAddon or (not self.SV.enableDrawSelf and not self.SV.enableDrawGroup) end,
            },
            {
                type = "slider",
                name = "Tracking Duration [sec]",
                min = 1, max = 10, step = 1,
                getFunc = function() return self.SV.durationMs / 1000 end,
                setFunc = function(value) self.SV.durationMs = value * 1000 end,
                default = self.Default.durationMs / 1000,
                disabled = function() return not CC.SV.enableAddon or (not self.SV.enableDrawSelf and not self.SV.enableDrawGroup) end,
            },
            {
                type = "button",
                name = CC.ColorString("START TRACKING", "GN"),
                func = function()
                    if self.unitTag then self:AddTrack(self.unitTag, nil) end
                end,
                width = "half",
                disabled = function() return not CC.SV.enableAddon or (not self.SV.enableDrawSelf and not self.SV.enableDrawGroup) end,
            },
            {
                type = "button",
                name = CC.ColorString("STOP ALL", "RD"),
                func = function()
                    ZO_ClearTable(self.ActiveTracks)
                end,
                width = "half",
                disabled = function() return not CC.SV.enableAddon or (not self.SV.enableDrawSelf and not self.SV.enableDrawGroup) end,
            },
            { type = "header", name = CC.ColorString("VISUALS", "tier3") },
            {
                type = "slider",
                name = "Marker Width [meter]",
                min = 0.25, max = 1.25, step = 0.05, decimals = 2,
                getFunc = function() return self.SV.width / 100 end,
                setFunc = function(value)
                    self.SV.width = value * 100
                end,
                default = self.Default.width / 100,
                disabled = function() return not CC.SV.enableAddon or (not self.SV.enableDrawSelf and not self.SV.enableDrawGroup) end,
            },
            {
                type = "slider",
                name = "Marker Height [meter]",
                min = 0.25, max = 1.25, step = 0.05, decimals = 2,
                getFunc = function() return self.SV.height / 100 end,
                setFunc = function(value)
                    self.SV.height = value * 100
                end,
                default = self.Default.height / 100,
                disabled = function() return not CC.SV.enableAddon or (not self.SV.enableDrawSelf and not self.SV.enableDrawGroup) end,
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
                disabled = function() return not CC.SV.enableAddon or (not self.SV.enableDrawSelf and not self.SV.enableDrawGroup) end,
            },
            {
                type = "checkbox",
                name = "Enable Game AOE Color",
                getFunc = function() return self.SV.enableGameAoeFriendlyColor end,
                setFunc = function(value) self.SV.enableGameAoeFriendlyColor = value end,
                default = self.Default.enableGameAoeFriendlyColor,
                disabled = function() return not CC.SV.enableAddon or (not self.SV.enableDrawSelf and not self.SV.enableDrawGroup) end,
            },
            {
                type = "colorpicker",
                name = "Start Color",
                getFunc = function() return unpack(self.SV.ColorStart) end,
                setFunc = function(r, g, b, a)
                    self.SV.ColorStart = {r, g, b, a}
                    local Preview = CC.Menu.Previews[self.name]
                    if Preview then Preview:SetColor(r, g, b, a) end
                end,
                default = CC.GetRgbaFromArray(self.Default.ColorStart),
                disabled = function() return not CC.SV.enableAddon or self.SV.enableGameAoeFriendlyColor end,
            },
            {
                type = "colorpicker",
                name = "End Color",
                getFunc = function() return unpack(self.SV.ColorEnd) end,
                setFunc = function(r, g, b, a) self.SV.ColorEnd = {r, g, b, a} end,
                default = CC.GetRgbaFromArray(self.Default.ColorEnd),
                disabled = function() return not CC.SV.enableAddon or self.SV.enableGameAoeFriendlyColor end,
            },
            {
                type = "custom",
                createFunc = function(CustomControl)
                    local Control = WINDOW_MANAGER:CreateControl(nil, CustomControl, CT_TEXTURE)
                    Control:SetAnchor(CENTER, CustomControl, CENTER)
                    Control:SetDimensions(128, 128)
                    Control:SetTexture(CC.NAME .. self.SV.texture)

                    local Color = self.SV.ColorStart
                    Control:SetColor(unpack(Color))

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