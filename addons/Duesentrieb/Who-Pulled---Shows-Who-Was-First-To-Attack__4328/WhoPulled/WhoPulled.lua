WhoPulled = {
    name = "WhoPulled",
    author = "@Duesentrieb",
    version = "20251229-0001",
    chat = "|cff7f00[WhoPulled]|r ",
    slash = "/whopulled",

    LGCS = nil,

    wasGroupEvent = false,
    wasPlayerEvent = false,
    wasDistanceEvent = false,
    wasMessageSent = false,

    timeCombatStart = 0,
    timeGroupDpsUpdate = 0,
    timePlayerDpsUpdate = 0,
    timeDeltaDpsUpdate = 0,

    MEAN_RANGE_MAX = 1000,
    LEARNING_FACTOR = 0.25,
    MAGNET_FACTOR = 0.05,

    default = {
        enableAddon = true,
        enableDebug = false,

        enableOnlyGroup = false,
        enableOnlyBoss = false,
        enableOnlyNotTank = false,
        enableOnlyNotUnknown = false,

        delayCombatStart = 4000, -- improving over time
        delayCombatEnd = 4000, -- improving over time

        countGroupDpsUpdate = 1,
        countPlayerDpsUpdate = 1,

        meanTimeGroupDpsUpdate = 2500, -- improving over time
        meanTimePlayerDpsUpdate = 1500, -- improving over time

        ----------------------------------
        -- COLORS FOR FUNCTION COLORSTRING
        ----------------------------------
        COL = {
            [0] = "|cffff7f", -- Unknown
            [1] = "|cffff7f", -- DPS
            [2] = "|c7fff7f", -- Tank
            [3] = "|cffff7f", -- Unknown
            [4] = "|cffff7f", -- Heal

            OG = "|cff7f00", -- Orange
            WH = "|cffffff", -- White
            GN = "|c7fff7f", -- Green
            RD = "|cff0000", -- Red
            BU = "|c7fbfff", -- Blue
            YE = "|cffff7f", -- Yellow
            END = "|r" -- /color
        },
    },

    SV = {},
    SVVersion = 1,
    SVName = "WhoPulledVariables",

    varAddonPanel = nil,
    isLoaded = false
}


-------------
-- LOCAL VARS
-------------
local WP = WhoPulled


------------------------------------
-- SCRIPTS FOR TESTING AND DEBUGGING
------------------------------------
-- /script WhoPulled.SV.enableDebug = true
-- /script WhoPulled.SV.enableDebug = false


---------------------------------------
-- ENABLE THE ADDON AND REGISTER EVENTS
---------------------------------------
function WP.Enable()
    WP.LGCS:RegisterForEvent(LibGroupCombatStats.EVENT_GROUP_DPS_UPDATE, WP.onGroupDpsUpdate)
    WP.LGCS:RegisterForEvent(LibGroupCombatStats.EVENT_PLAYER_DPS_UPDATE, WP.onPlayerDpsUpdate)

    EVENT_MANAGER:RegisterForEvent(WP.name, EVENT_PLAYER_COMBAT_STATE, WP.onPlayerCombatState)
    EVENT_MANAGER:RegisterForEvent(WP.name, EVENT_PLAYER_ACTIVATED, WP.onPlayerActivated)

    WP.resetEvent()
end


------------------------------------------
-- DISABLE THE ADDON AND DEREGISTER EVENTS
------------------------------------------
function WP.Disable()
    EVENT_MANAGER:UnregisterForEvent(WP.name, EVENT_PLAYER_COMBAT_STATE)
    EVENT_MANAGER:UnregisterForEvent(WP.name, EVENT_PLAYER_ACTIVATED)
end


--------------------------------------------------
-- PRINT DEBUG MESSAGE IN CHAT
-- CAN BE FORCED - EVEN WHEN not WP.SV.enableDebug
--------------------------------------------------
---@param msg any
---@param force any
function WhoPulled.debug(msg, force)
    if WP.SV.enableDebug or force then
        d(WP.chat .. WP.colorString('WH', msg))
    end
end


---------------------------
-- PRINT STATISTICS IN CHAT
---------------------------
function WhoPulled.printStatistic()
    WP.timeDeltaDpsUpdate = math.abs(WP.SV.meanTimeGroupDpsUpdate - WP.SV.meanTimePlayerDpsUpdate)
    d(WP.chat .. WP.colorString('BU', "STATISTICS (lifetime):"))
    d(WP.chat .. WP.colorString('WH', string.format("%i ms - meanTimeGroupDpsUpdate", WP.SV.meanTimeGroupDpsUpdate)))
    d(WP.chat .. WP.colorString('WH', string.format("%i ms - meanTimePlayerDpsUpdate", WP.SV.meanTimePlayerDpsUpdate)))
    d(WP.chat .. WP.colorString('WH', string.format("%i - countGroupDpsUpdate", WP.SV.countGroupDpsUpdate)))
    d(WP.chat .. WP.colorString('WH', string.format("%i - countPlayerDpsUpdate", WP.SV.countPlayerDpsUpdate)))
    d(WP.chat .. WP.colorString('WH', string.format("%i ms - Player Update → Group Update", WP.timeDeltaDpsUpdate)))
end


--------------------------------------------------
-- RESET VARS AFTER FIGHT ENDS
-- DELAYED CALL BY WhoPulled.onPlayerCombatState()
--------------------------------------------------
function WhoPulled.resetEvent()
    local isCombat = IsUnitInCombat("player")

	if not isCombat then
        if WP.wasGroupEvent or WP.wasPlayerEvent or WP.wasDistanceEvent or WP.wasMessageSent then
            WP.debug("Reset!", false)

            WP.wasGroupEvent = false
            WP.wasPlayerEvent = false
            WP.wasDistanceEvent = false
            WP.wasMessageSent = false
        end
	end
end


----------------------
-- FIGHT STARTS / ENDS
----------------------
function WhoPulled.onPlayerCombatState()
    local isCombat = IsUnitInCombat("player")

    WP.SV.delayCombatStart = WP.SV.meanTimeGroupDpsUpdate + WP.SV.meanTimePlayerDpsUpdate
    WP.SV.delayCombatEnd = WP.SV.meanTimeGroupDpsUpdate + WP.SV.meanTimePlayerDpsUpdate

	if isCombat then
        WP.timeCombatStart = GetGameTimeMilliseconds()
        WP.debug("Fight!", false)

        -- UNKNOWN
        zo_callLater(function()
            WP.sendMessage(nil, nil)
        end, WP.SV.delayCombatStart)
    else
		zo_callLater(function()
            WP.resetEvent()
        end, WP.SV.delayCombatEnd)
	end
end


--------------------------------------------
-- GET CURRENT AND MAXHEALTH FROM F.E. BOSS1
--------------------------------------------
---@param unitTag any
---@return integer
function WhoPulled.getHealthPercentage(unitTag)
	local currentHealth, maxHealth = GetUnitPower(unitTag, POWERTYPE_HEALTH)
	if not currentHealth or currentHealth == "" then return 0 end
	if not maxHealth or maxHealth == "" then return 0 end

	local percentage = currentHealth / maxHealth * 100
	return percentage
end


----------------------------------
-- COLORIZE A STRING AND RETURN IT
----------------------------------
---@param color any
---@param string any
---@return any
function WP.colorString(color, string)
    if not WP.SV.COL[color] then return string end
    if not string then return "" end
    return WP.SV.COL[color] .. string .. WP.SV.COL.END
end


---------------------------------------------------------
-- THE INBOX - FIRST VALID MESSAGE GETS PRINTED INTO CHAT
---------------------------------------------------------
---@param unitTag any
---@param dpsData any
function WhoPulled.sendMessage(unitTag, dpsData)
    if not WP.SV.enableAddon then return end
    if WP.wasMessageSent then return end

    local unitName = GetUnitDisplayName(unitTag) or "unitTag"
    local playerName = GetUnitDisplayName("player") or "player"
    local selectedRole = GetGroupMemberSelectedRole(unitTag) or 0

    local stringRole = ""
    local colorName = selectedRole
    if selectedRole == 1 then stringRole = ": DPS" end
    if selectedRole == 2 then stringRole = ": Tank" end
    if selectedRole == 4 then stringRole = ": Heal" end

    local facingName = string.format("%s%s", unitName, stringRole)
    local facingLink = ZO_LinkHandler_CreateLink(facingName, nil, "character", unitName)

    local stringName = WP.colorString(colorName, facingLink)
    local stringBoss = GetUnitName("boss1") or GetUnitName("boss2") or GetUnitName("boss3") or GetUnitName("boss4")

    if #stringBoss > 0 then
        if #stringBoss > 14 then stringBoss = string.sub(stringBoss, 1, 12):gsub("%s+$", "") .. ".." end
        stringBoss = WP.colorString('WH', " → ") .. WP.colorString('WH', string.format("[%s]", stringBoss))
    end

    ------------------------------------------------------
    -- "BODYPULL" - STILL UNDER CONSTRUCTION! COMING SOON!
    ------------------------------------------------------
    if WP.wasDistanceEvent then
        if #stringBoss > 0 then stringName = WP.colorString(colorName, "Bodypull")
        else stringName = WP.colorString(colorName, "Bodypull..") end

    -----------------------------------------------------------
    -- "UNKNOWN" - MESSAGE BY COMBAT STATE WP.SV.delayCombatEnd
    -----------------------------------------------------------
    elseif not unitTag or not dpsData then
        local currentTime = GetGameTimeMilliseconds()
        local timePassed = math.abs(currentTime - WP.timeCombatStart)
        if timePassed < WP.SV.delayCombatStart then
            WP.debug("Fake!", false)
            return
        end

        if #stringBoss > 0 then stringName = WP.colorString(colorName, "Unknown")
        else stringName = WP.colorString(colorName, "Unknown..") end

    -----------------------------------------------------
    -- "GROUP MEMBER" - MESSAGE BY EVENT_GROUP_DPS_UPDATE
    -----------------------------------------------------
    elseif unitName ~= playerName then
        WP.SV.countGroupDpsUpdate = WP.SV.countGroupDpsUpdate + 1
        WP.SV.meanTimeGroupDpsUpdate = WP.calculateMean(WP.SV.meanTimeGroupDpsUpdate, WP.timeGroupDpsUpdate, WP.default.meanTimeGroupDpsUpdate)

    ------------------------------------------------
    -- "PLAYER" - MESSAGE BY EVENT_PLAYER_DPS_UPDATE
    ------------------------------------------------
    elseif unitName == playerName then
        WP.SV.countPlayerDpsUpdate = WP.SV.countPlayerDpsUpdate + 1
        WP.SV.meanTimePlayerDpsUpdate = WP.calculateMean(WP.SV.meanTimePlayerDpsUpdate, WP.timePlayerDpsUpdate, WP.default.meanTimePlayerDpsUpdate)

    end

    ------------------------
    -- PRINT MESSAGE TO CHAT
    ------------------------
    WP.wasMessageSent = true

    -- exit late so meanTime etc. will still be calculated
    if WP.SV.enableOnlyGroup and not IsUnitGrouped("player") then WP.debug("WP.SV.enableOnlyGroup", false) return end
    if WP.SV.enableOnlyBoss and (not stringBoss or stringBoss == "") then WP.debug("WP.SV.enableOnlyBoss", false) return end
    if WP.SV.enableOnlyNotTank and selectedRole == 2 then WP.debug("WP.SV.enableOnlyNotTank", false) return end
    if WP.SV.enableOnlyNotUnknown and (not unitTag or not dpsData) then WP.debug("Return: WP.SV.enableOnlyNotUnknown", false) return end

    d(string.format("%s%s%s", WP.chat, stringName, stringBoss))
end


-----------------------------------------
-- CALCULATE NEW MEAN VALUE AND RETURN IT
-----------------------------------------
---@param oldMean any
---@param newTime any
---@param default any
---@return integer
function WP.calculateMean(oldMean, newTime, default)
    if not oldMean or not newTime or not default then
        local meanDefault = (WP.default.meanTimeGroupDpsUpdate + WP.default.meanTimePlayerDpsUpdate) / 2
        return meanDefault
    end

    local deltaMeas = math.abs(oldMean - newTime)

    local trust = math.exp(-1/2 * (deltaMeas^2) / (WP.MEAN_RANGE_MAX^2))
    local impactMeas = (newTime - oldMean) * trust * WP.LEARNING_FACTOR
    local impactMagnet = (default - oldMean) * WP.MAGNET_FACTOR

    local newMean = math.floor((oldMean + impactMeas + impactMagnet) + 0.5)

    local deltaMean = (newMean - oldMean)
    local signMean = "" if deltaMean > 0 then signMean = "+" end
    WP.debug(string.format("time:%ims old:%ims new:%ims (%s%ims)", newTime, oldMean, newMean, signMean, deltaMean), false)

    return newMean
end


-----------------------------------------------------
-- GROUP DPS UPDATE - INCOMING EVENT_GROUP_DPS_UPDATE
-----------------------------------------------------
---@param unitTag any
---@param dpsData any
function WhoPulled.onGroupDpsUpdate(unitTag, dpsData)
    if WP.wasGroupEvent then return end
    if not IsUnitInCombat("player") then return end
    if not unitTag then WP.debug("onGroupDpsUpdate - not unitTag") return end
    if not dpsData then WP.debug("onGroupDpsUpdate - not dpsData") return end

    WP.wasGroupEvent = true

    local currentTime = GetGameTimeMilliseconds()
    WP.timeGroupDpsUpdate = math.abs(currentTime - WP.timeCombatStart)
    if WP.timeGroupDpsUpdate > WP.SV.delayCombatStart then return end

    WP.sendMessage(unitTag, dpsData)
end


-------------------------------------------------------
-- PLAYER DPS UPDATE - INCOMING EVENT_PLAYER_DPS_UPDATE
-------------------------------------------------------
---@param unitTag any
---@param dpsData any
function WhoPulled.onPlayerDpsUpdate(unitTag, dpsData)
    if WP.wasPlayerEvent then return end
    if not IsUnitInCombat("player") then return end
    if not unitTag then WP.debug("onPlayerDpsUpdate - not dpsData") return end
    if not dpsData then WP.debug("onPlayerDpsUpdate - not dpsData") return end

    WP.wasPlayerEvent = true

    local currentTime = GetGameTimeMilliseconds()
    WP.timePlayerDpsUpdate = math.abs(currentTime - WP.timeCombatStart)
    if WP.timePlayerDpsUpdate > WP.SV.delayCombatStart then return end

    WP.timeDeltaDpsUpdate = math.abs(WP.SV.meanTimeGroupDpsUpdate - WP.SV.meanTimePlayerDpsUpdate)
    zo_callLater(function()
        WP.sendMessage(unitTag, dpsData)
    end, WP.timeDeltaDpsUpdate)
end


----------------------------
-- PLAYER RELOAD / ACTIVATED
----------------------------
function WhoPulled.onPlayerActivated()
    WP.resetEvent()
end


--------------------------------
-- CREATE SETTINGS WINDOW / MENU
--------------------------------
function WP.createSettingsWindow()
    local panelData = {
        type = "panel",
        name = "Who Pulled",
        displayName = WP.SV.COL.OG .. "Who" .. WP.SV.COL.END .. WP.SV.COL.WH .. " Pulled" .. WP.SV.COL.END,
        author = WP.SV.COL.OG .. WP.author .. WP.SV.COL.END .. WP.SV.COL.WH .. " [EU]" .. WP.SV.COL.END,
        version = WP.SV.COL.OG .. WP.version .. WP.SV.COL.END,
        registerForRefresh = true
    }

    local optionsData = {
        {
            type = "header",
            name = WP.SV.COL.OG .. "General Options" .. WP.SV.COL.END
        },
        {
            type = "description",
            text = "Type " .. WP.SV.COL.OG .. WP.slash .. WP.SV.COL.END .. " in chat to print " .. WP.SV.COL.END .. WP.SV.COL.OG .. "statistics" .. WP.SV.COL.END .. ".",
            width = "full"
        },
        {
            type = "checkbox",
            name = "MASTERSWITCH (Turns the entire addon ON/OFF)",
            tooltip = "Enables or disables all features of the addon.",
            getFunc = function() return WP.SV.enableAddon end,
            setFunc = function(value)
                WP.SV.enableAddon = value
                if value == true then
                    WP.Enable()
                else
                    WP.Disable()
                end
            end,
            width = "full"
        },
        {
            type = "divider"
        },
        {
            type = "checkbox",
            name = "Notification: ONLY IF  |cff7f00IN GROUP|r",
            tooltip = "Notification: ONLY IF  IN GROUP",
            getFunc = function() return WP.SV.enableOnlyGroup end,
            setFunc = function(value)
                WP.SV.enableOnlyGroup = value
            end,
            disabled = function() return not WP.SV.enableAddon end,
            width = "full"
        },
        {
            type = "checkbox",
            name = "Notification: ONLY IF  |cff7f00ON BOSS|r",
            tooltip = "Notification: ONLY IF  ON BOSS",
            getFunc = function() return WP.SV.enableOnlyBoss end,
            setFunc = function(value)
                WP.SV.enableOnlyBoss = value
            end,
            disabled = function() return not WP.SV.enableAddon end,
            width = "full"
        },
        {
            type = "checkbox",
            name = "Notification: ONLY IF  |cff7f00NOT PULLED BY TANK|r",
            tooltip = "Notification: ONLY IF  NOT PULLED BY TANK",
            getFunc = function() return WP.SV.enableOnlyNotTank end,
            setFunc = function(value)
                WP.SV.enableOnlyNotTank = value
            end,
            disabled = function() return not WP.SV.enableAddon end,
            width = "full"
        },
        {
            type = "checkbox",
            name = "Notification: ONLY IF  |cff7f00NOT UNKNOWN|r",
            tooltip = "Notification: ONLY IF  NOT UNKNOWN",
            getFunc = function() return WP.SV.enableOnlyNotUnknown end,
            setFunc = function(value)
                WP.SV.enableOnlyNotUnknown = value
            end,
            disabled = function() return not WP.SV.enableAddon end,
            width = "full"
        },
        {
            type = "divider"
        },
        {
            type = "colorpicker",
            name = "Color: TANK",
            tooltip = "Default (rgba): 127, 255, 127, 255",
            getFunc = function()
                local r_hex, g_hex, b_hex = string.match(WP.SV.COL[2], "|c(%x%x)(%x%x)(%x%x)")
                local r = tonumber(r_hex, 16) / 255
                local g = tonumber(g_hex, 16) / 255
                local b = tonumber(b_hex, 16) / 255
                return r, g, b, 1
            end,
            setFunc = function(r, g, b, a)
                WP.SV.COL[2] = string.format("|c%02x%02x%02x", r * 255, g * 255, b * 255)
            end,
            disabled = function() return not WP.SV.enableAddon end,
            width = "full"
        },
        {
            type = "colorpicker",
            name = "Color: OTHER",
            tooltip = "Default (rgba): 255, 255, 127, 255",
            getFunc = function()
                local r_hex, g_hex, b_hex = string.match(WP.SV.COL[1], "|c(%x%x)(%x%x)(%x%x)")
                local r = tonumber(r_hex, 16) / 255
                local g = tonumber(g_hex, 16) / 255
                local b = tonumber(b_hex, 16) / 255
                return r, g, b, 1
            end,
            setFunc = function(r, g, b, a)
                WP.SV.COL[0] = string.format("|c%02x%02x%02x", r * 255, g * 255, b * 255)
                WP.SV.COL[1] = string.format("|c%02x%02x%02x", r * 255, g * 255, b * 255)
                WP.SV.COL[3] = string.format("|c%02x%02x%02x", r * 255, g * 255, b * 255)
                WP.SV.COL[4] = string.format("|c%02x%02x%02x", r * 255, g * 255, b * 255)
                WP.SV.COL[5] = string.format("|c%02x%02x%02x", r * 255, g * 255, b * 255)
            end,
            disabled = function() return not WP.SV.enableAddon end,
            width = "full"
        },
        {
            type = "divider"
        },
        {
            type = "description",
            text = "If you enjoy " .. WP.SV.COL.OG .. "Who Pulled" .. WP.SV.COL.END .. ", consider sharing your feedback or supporting its development. Your input and contributions are greatly appreciated!",
            width = "full"
        },
        {
            type = "button",
            name = "Feedback / Donate",
            tooltip = "Opens a mail to send feedback or donate to the author. <3",
            func = function()
                SCENE_MANAGER:Show('mailSend')
                zo_callLater(function()
                    ZO_MailSendToField:SetText(WP.author)
                    ZO_MailSendSubjectField:SetText("Who Pulled")
                    ZO_MailSendBodyField:TakeFocus()
                end, 250)
            end,
            width = "full"
        }
    }
    WP.varAddonPanel = LibAddonMenu2:RegisterAddonPanel(WhoPulled.name .. "Menu", panelData)
    LibAddonMenu2:RegisterOptionControls(WhoPulled.name .. "Menu", optionsData)
end


-------------------
-- INITIALIZE ADDON
-------------------
function WhoPulled.Initialize()
    WP.SV = ZO_SavedVars:NewAccountWide(WP.SVName, WP.SVVersion, nil, WP.default)

    WP.LGCS = LibGroupCombatStats.RegisterAddon(WP.name, { "DPS" })
    if not WP.LGCS then
        return
    end

    WP.createSettingsWindow()

    if WP.SV.enableAddon then WP.Enable() end
end


-----------------
-- SLASH COMMANDS
-----------------
SLASH_COMMANDS[WP.slash] = WP.printStatistic


-------------------------------
-- ADDON GETS CALLED FIRST TIME
-------------------------------
---@param _ any
---@param name any
function WP.onAddOnLoaded(_, name)
    if name == WP.name then
        EVENT_MANAGER:UnregisterForEvent(WP.name, EVENT_ADD_ON_LOADED)

        WP.Initialize()
    end
end

EVENT_MANAGER:RegisterForEvent(WP.name, EVENT_ADD_ON_LOADED, WP.onAddOnLoaded)