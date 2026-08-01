HighlandTracker = {}
HighlandTracker.name = "HighlandTickTracker"
local LSD = LibSetDetection
local SM = SCENE_MANAGER

local tickDuration = 1000
local currentStacks = 0
local isInCombat = false
local trustedTickTime = 0
local isUpdateRegistered = false



HighlandTracker.UI = {}



local function IsHighlandSentinelEquipped()
    if LibSetDetection.AreUnitDataAvailable("player") then
        local setData = LibSetDetection.GetUnitSetData("player")
        if setData and setData[764] and setData[764].activeType and setData[764].activeType ~= 0 then
            return true
        end
    end
end

local function setHudDisplay(show)
    if not HighlandTracker.savedVars.showOnlyInCombat then
        show = true
    end

    if HighlandTracker.UI.frag then
        if show then
            SM:GetScene("hud"):AddFragment(HighlandTracker.UI.frag)
            SM:GetScene("hudui"):AddFragment(HighlandTracker.UI.frag)
        else
            SM:GetScene("hud"):RemoveFragment(HighlandTracker.UI.frag)
            SM:GetScene("hudui"):RemoveFragment(HighlandTracker.UI.frag)
        end
    end
end



local function CreateUI()
    HighlandTracker.savedVars = ZO_SavedVars:New("HighlandTracker_SavedVariables", 1, nil, {
        offsetX = 200,
        offsetY = 200,
        barWidth = 200,
        barHeight = 25,
        barColor = {0, 1, 0, 1},
        showStackCounter = true,
		showOnlyInCombat = true
    })

    HighlandTracker.UI.frame = WINDOW_MANAGER:CreateTopLevelWindow("HighlandTrackerUI")
    local frame = HighlandTracker.UI.frame

    frame:SetDimensions(HighlandTracker.savedVars.barWidth + 10, HighlandTracker.savedVars.barHeight + 10)
    frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, HighlandTracker.savedVars.offsetX, HighlandTracker.savedVars.offsetY)
    frame:SetMovable(true)
    frame:SetMouseEnabled(true)
    frame:SetHandler("OnMoveStop", function()
        HighlandTracker.savedVars.offsetX = frame:GetLeft()
        HighlandTracker.savedVars.offsetY = frame:GetTop()
    end)
    frame:SetHidden(true)

    -- Border/Outline
    HighlandTracker.UI.border = WINDOW_MANAGER:CreateControl("$(parent)Border", frame, CT_BACKDROP)
    HighlandTracker.UI.border:SetDimensions(HighlandTracker.savedVars.barWidth + 4, HighlandTracker.savedVars.barHeight + 4)
    HighlandTracker.UI.border:SetAnchor(CENTER, frame, CENTER, 0, 0)
    HighlandTracker.UI.border:SetCenterColor(0, 0, 0, 0.5)
    HighlandTracker.UI.border:SetEdgeColor(1, 1, 1, 1)
    HighlandTracker.UI.border:SetEdgeTexture("", 1, 1, 2, 0)

    -- Tick Bar (Progress Bar)
	HighlandTracker.UI.tickBar = WINDOW_MANAGER:CreateControl("$(parent)TickBar", frame, CT_STATUSBAR)
	HighlandTracker.UI.tickBar:SetDimensions(HighlandTracker.savedVars.barWidth, HighlandTracker.savedVars.barHeight)
	HighlandTracker.UI.tickBar:SetAnchor(LEFT, HighlandTracker.UI.border, LEFT, 2, 0)
	HighlandTracker.UI.tickBar:SetMinMax(0, tickDuration - 0.001)
	HighlandTracker.UI.tickBar:SetValue(0)
	HighlandTracker.UI.tickBar:SetHidden(false)



    local r, g, b, a = unpack(HighlandTracker.savedVars.barColor or {0, 1, 0, 1})
    if not r or not g or not b or not a then
        r, g, b, a = 0, 1, 0, 1 -- Default green
    end
    local startColor = ZO_ColorDef:New(r, g, b, a)
    local endColor = ZO_ColorDef:New(r * 0.6, g * 0.6, b * 0.6, a)

    -- Apply gradient color safely
    zo_callLater(function()
        ZO_StatusBar_SetGradientColor(HighlandTracker.UI.tickBar, {startColor, endColor})
    end, 50)

    -- Leading Edge Effect
    HighlandTracker.UI.edge = WINDOW_MANAGER:CreateControl("$(parent)Edge", frame, CT_TEXTURE)
    HighlandTracker.UI.edge:SetTexture("esoui/art/miscellaneous/progressbar_genericfill_leadingedge_blunt.dds")
    HighlandTracker.UI.edge:SetDimensions(6, HighlandTracker.savedVars.barHeight + 2)
    HighlandTracker.UI.edge:SetAnchor(RIGHT, HighlandTracker.UI.tickBar, RIGHT, -1, 0)
    HighlandTracker.UI.edge:SetHidden(false)

    -- Glow Effect
    HighlandTracker.UI.glow = WINDOW_MANAGER:CreateControl("$(parent)Glow", frame, CT_TEXTURE)
    HighlandTracker.UI.glow:SetTexture("EsoUI/Art/Miscellaneous/progressbar_genericfill_leadingedge_glow.dds")
    HighlandTracker.UI.glow:SetDimensions(HighlandTracker.savedVars.barWidth, HighlandTracker.savedVars.barHeight)
    HighlandTracker.UI.glow:SetAnchor(CENTER, HighlandTracker.UI.tickBar, CENTER, 0, 0)
    HighlandTracker.UI.glow:SetColor(1, 1, 1, 0.3)
    HighlandTracker.UI.glow:SetHidden(false)

    -- Stack Counter Label
    HighlandTracker.UI.tickLabel = WINDOW_MANAGER:CreateControl("$(parent)TickLabel", frame, CT_LABEL)
    HighlandTracker.UI.tickLabel:SetAnchor(CENTER, HighlandTracker.UI.border, TOP, 0, -20)
    HighlandTracker.UI.tickLabel:SetFont("ZoFontWinH1")
    HighlandTracker.UI.tickLabel:SetColor(1, 1, 1, 1)
    HighlandTracker.UI.tickLabel:SetScale(1.5)
    HighlandTracker.UI.tickLabel:SetText("0")
    HighlandTracker.UI.tickLabel:SetHidden(not HighlandTracker.savedVars.showStackCounter)

    -- Scene Fragment
    HighlandTracker.UI.frag = ZO_FadeSceneFragment:New(frame, nil, 0)
    HighlandTracker.UI.frag:RegisterCallback("StateChange", function(_, newState)
        if newState == SCENE_FRAGMENT_SHOWING then
            if not HighlandTracker.savedVars.showOnlyInCombat then
                setHudDisplay(IsHighlandSentinelEquipped())
            else
                setHudDisplay(isInCombat and IsHighlandSentinelEquipped() and currentStacks > 0)
            end
        elseif newState == SCENE_FRAGMENT_HIDDEN then
            setHudDisplay(false)
        end
    end)
end



local function ProcessTickBar(difference)
    if HighlandTracker.UI.frame:IsHidden() then return end

    local progress = math.min(tickDuration, difference)
    HighlandTracker.UI.tickBar:SetValue(progress)

    local barWidth = HighlandTracker.savedVars.barWidth
    local clampedWidth = math.min(barWidth, math.floor(barWidth * (progress / tickDuration)))

    HighlandTracker.UI.edge:ClearAnchors()
    HighlandTracker.UI.edge:SetAnchor(LEFT, HighlandTracker.UI.tickBar, LEFT, clampedWidth - 1, 0)

    if progress >= tickDuration then
        trustedTickTime = GetFrameTimeMilliseconds()
        HighlandTracker.UI.tickBar:SetValue(0)
    end

    HighlandTracker.UI.tickLabel:SetText(string.format("%d", currentStacks))
end





local function OnUpdate()
    if not isInCombat or not IsHighlandSentinelEquipped() then
        if not HighlandTracker.UI.frame:IsHidden() then
            if setHudDisplay then
                zo_callLater(function() setHudDisplay(false) end, 500)
            end
        end
        return
    end

    local foundStacks = 0
    for i = 1, GetNumBuffs("player") do
        local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, _, castByPlayer = GetUnitBuffInfo("player", i)
        if abilityId == 219681 then
            foundStacks = stackCount or 0
            break
        end
    end

    if foundStacks == 0 then
        if currentStacks ~= 0 then
            currentStacks = 0
            HighlandTracker.UI.tickLabel:SetText("0")

            if AdjustUpdateRate then
                AdjustUpdateRate()
            end

            if setHudDisplay then
                zo_callLater(function() setHudDisplay(false) end, 500)
            end
        end
    else
        currentStacks = foundStacks

        if setHudDisplay then
            setHudDisplay(true)
        end

        if AdjustUpdateRate then
            AdjustUpdateRate()
        end
    end

    if currentStacks > 0 then
        local difference = GetFrameTimeMilliseconds() - trustedTickTime
        if difference >= tickDuration then
            trustedTickTime = GetFrameTimeMilliseconds()
        end

        if ProcessTickBar then
            ProcessTickBar(difference)
        else
            d("[HighlandTracker] Error: ProcessTickBar is nil")
        end
    end
end

local function RegisterUpdateHandler()
    if not isUpdateRegistered then
        EVENT_MANAGER:RegisterForUpdate(HighlandTracker.name .. "Updater", 20, OnUpdate)
        isUpdateRegistered = true
    end
end

local function AdjustUpdateRate()
    if currentStacks > 0 then
        EVENT_MANAGER:UnregisterForUpdate(HighlandTracker.name .. "Updater")
        EVENT_MANAGER:RegisterForUpdate(HighlandTracker.name .. "Updater", 20, OnUpdate)
    else
        EVENT_MANAGER:UnregisterForUpdate(HighlandTracker.name .. "Updater")
        EVENT_MANAGER:RegisterForUpdate(HighlandTracker.name .. "Updater", 100, OnUpdate)
    end
end


local function UnregisterUpdateHandler()
    if isUpdateRegistered then
        EVENT_MANAGER:UnregisterForUpdate(HighlandTracker.name .. "Updater")
        isUpdateRegistered = false
    end
end

function HighlandTracker.OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    
	if unitTag == "player" and abilityId == 219681 then
        currentStacks = stackCount or 0 
        trustedTickTime = GetFrameTimeMilliseconds()
        HighlandTracker.UI.tickLabel:SetText(tostring(currentStacks))

        if currentStacks > 0 then
            RegisterUpdateHandler()
        else
            AdjustUpdateRate()
        end

        if isInCombat ~= nil then
            setHudDisplay(isInCombat and currentStacks > 0)
        end
	end

	
end



local function OnCombatStateChanged(_, inCombat)
    isInCombat = inCombat
    if not isInCombat then
        currentStacks = 0
        trustedTickTime = 0
        UnregisterUpdateHandler()
    else
        RegisterUpdateHandler()
    end
    setHudDisplay(isInCombat and currentStacks > 0)
end

local function OnEquipmentChanged()
    if IsHighlandSentinelEquipped() then
        RegisterUpdateHandler()
    else
        UnregisterUpdateHandler()
    end
    setHudDisplay(isInCombat and currentStacks > 0)
end

local LAM = LibAddonMenu2

local function CreateSettingsMenu()
    local panelData = {
        type = "panel",
        name = "Highland Tick Tracker",
        displayName = "|c00FF00Highland Tick Tracker Settings|r",
        author = "SkullElf",
        version = "1.0",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    
    local optionsTable = {
        {
            type = "header",
            name = "General Settings",
        },
		{
			type = "checkbox",
			name = "Show Only In Combat",
			tooltip = "If enabled, the bar will only be visible during combat.",
			getFunc = function() return HighlandTracker.savedVars.showOnlyInCombat end,
			setFunc = function(value) 
				HighlandTracker.savedVars.showOnlyInCombat = value 
				setHudDisplay(isInCombat and (not value or currentStacks > 0))
			end,
			default = true,
		},
        {
            type = "checkbox",
            name = "Show Stack Counter",
            tooltip = "Toggle visibility of the stack counter label.",
            getFunc = function() return HighlandTracker.savedVars.showStackCounter end,
            setFunc = function(value) 
                HighlandTracker.savedVars.showStackCounter = value 
                HighlandTracker.UI.tickLabel:SetHidden(not value) 
            end,
            default = true,
        },
        {
            type = "slider",
            name = "Bar Width",
            tooltip = "Adjust the width of the tick bar.",
            min = 100,
            max = 400,
            step = 10,
            getFunc = function() return HighlandTracker.savedVars.barWidth end,
            setFunc = function(value) 
                HighlandTracker.savedVars.barWidth = value
                
                HighlandTracker.UI.border:SetDimensions(value + 4, HighlandTracker.savedVars.barHeight + 4)
                HighlandTracker.UI.tickBar:SetDimensions(value, HighlandTracker.savedVars.barHeight)

                HighlandTracker.UI.edge:SetAnchor(RIGHT, HighlandTracker.UI.tickBar, RIGHT, -1, 0)

                HighlandTracker.UI.glow:SetDimensions(value, HighlandTracker.savedVars.barHeight)
            end,
            default = 200,
        },
        {
            type = "slider",
            name = "Bar Height",
            tooltip = "Adjust the height of the tick bar.",
            min = 10,
            max = 100,
            step = 5,
            getFunc = function() return HighlandTracker.savedVars.barHeight end,
            setFunc = function(value) 
                HighlandTracker.savedVars.barHeight = value

                HighlandTracker.UI.border:SetDimensions(HighlandTracker.savedVars.barWidth + 4, value + 4)
                HighlandTracker.UI.tickBar:SetDimensions(HighlandTracker.savedVars.barWidth, value)

                HighlandTracker.UI.glow:SetDimensions(HighlandTracker.savedVars.barWidth, value)

                HighlandTracker.UI.edge:SetDimensions(6, value + 2)

                HighlandTracker.UI.tickLabel:SetAnchor(CENTER, HighlandTracker.UI.border, TOP, 0, -20)
            end,
            default = 25,
        },
        {
            type = "colorpicker",
            name = "Bar Color",
            tooltip = "Change the color of the tick bar.",
            getFunc = function() return unpack(HighlandTracker.savedVars.barColor) end,
            setFunc = function(r, g, b, a) 
				HighlandTracker.savedVars.barColor = {r, g, b, a} 

				local startColor = ZO_ColorDef:New(r, g, b, a)
				local endColor = ZO_ColorDef:New(r * 0.6, g * 0.6, b * 0.6, a)

				ZO_StatusBar_SetGradientColor(HighlandTracker.UI.tickBar, {startColor, endColor})
			end,
            default = {0, 1, 0, 1},
        }
    }
    
    LAM:RegisterAddonPanel("HighlandTickTrackerPanel", panelData)
    LAM:RegisterOptionControls("HighlandTickTrackerPanel", optionsTable)
end


function HighlandTracker.OnPlayerActivated()
    CreateUI()
    CreateSettingsMenu()
    if IsHighlandSentinelEquipped() then
        RegisterUpdateHandler()
    end
    setHudDisplay(isInCombat and currentStacks > 0)
    EVENT_MANAGER:RegisterForEvent(HighlandTracker.name .. "EffectChanged", EVENT_EFFECT_CHANGED, HighlandTracker.OnEffectChanged)
    EVENT_MANAGER:RegisterForEvent(HighlandTracker.name .. "CombatStateChanged", EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)
    EVENT_MANAGER:RegisterForEvent(HighlandTracker.name .. "InventoryChange1", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnEquipmentChanged)
    EVENT_MANAGER:RegisterForEvent(HighlandTracker.name .. "InventoryChange2", EVENT_INVENTORY_FULL_UPDATE, OnEquipmentChanged)
    
    EVENT_MANAGER:UnregisterForEvent(HighlandTracker.name .. "PlayerActivated", EVENT_PLAYER_ACTIVATED)
end

EVENT_MANAGER:RegisterForEvent(HighlandTracker.name .. "PlayerActivated", EVENT_PLAYER_ACTIVATED, HighlandTracker.OnPlayerActivated)
