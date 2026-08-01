local stackTrackingIDs = {
    [122586] = true,
    [122587] = true,
}
local iconTopLevel = nil
local stackLabel = nil
local textColor = {1, 1, 1, 1}
local currentStackCount = 0
local icon = nil
local alertSound = SOUNDS.DUEL_START

local ImpitoyableStackSavedVars = nil
local defaultSavedVars = {
    position = { x = 0, y = 0 },
    iconSize = 64,
    textSize = 24,
    textColor = {1, 1, 1, 1 },
	minStacksToShow = 1,
}

local function UpdateStackCount(stackCount)
    if not iconTopLevel or not stackLabel then return end

    local minStacks = ImpitoyableStackSavedVars.minStacksToShow or 1

    if stackCount < minStacks then
        iconTopLevel:SetHidden(true)
        soundPlayed = false 
    else
        iconTopLevel:SetHidden(false)
        stackLabel:SetText(tostring(stackCount))

        if not soundPlayed then
            PlaySound(alertSound)
            soundPlayed = true
        end
    end
end

local function UpdateIconSize(size)
    if icon and iconTopLevel then
        icon:SetDimensions(size, size)
        iconTopLevel:SetDimensions(size, size)
    end
end

local function MakeIconMovable()
    iconTopLevel:SetMovable(true)
    iconTopLevel:SetMouseEnabled(true)

    iconTopLevel:SetHandler("OnMouseDown", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            iconTopLevel:StartMoving()
        end
    end)

    iconTopLevel:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            iconTopLevel:StopMovingOrResizing()
            local left, top = iconTopLevel:GetLeft(), iconTopLevel:GetTop()
            ImpitoyableStackSavedVars.position.x = left
            ImpitoyableStackSavedVars.position.y = top
        end
    end)
end

local function IsPositionValid(x, y)
    local screenWidth, screenHeight = GuiRoot:GetDimensions()
    return x >= 0 and x <= screenWidth and y >= 0 and y <= screenHeight
end

local function CreateUI()
    iconTopLevel = WINDOW_MANAGER:CreateTopLevelWindow("ImpitoyableStackIcon")

    if not ImpitoyableStackSavedVars or not ImpitoyableStackSavedVars.position then
        ImpitoyableStackSavedVars.position = { x = 0, y = 200 }
    end

    if not IsPositionValid(ImpitoyableStackSavedVars.position.x, ImpitoyableStackSavedVars.position.y) then
        ImpitoyableStackSavedVars.position = { x = 0, y = 200 }
    end

    iconTopLevel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ImpitoyableStackSavedVars.position.x, ImpitoyableStackSavedVars.position.y)
    iconTopLevel:SetHidden(true)

    icon = WINDOW_MANAGER:CreateControl(nil, iconTopLevel, CT_TEXTURE)
    UpdateIconSize(ImpitoyableStackSavedVars.iconSize)
    icon:SetAnchor(CENTER, iconTopLevel, CENTER, 0, 0)
    icon:SetTexture("/esoui/art/icons/ability_nightblade_005.dds")

	stackLabel = WINDOW_MANAGER:CreateControl(nil, iconTopLevel, CT_LABEL)
	stackLabel:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", tonumber(ImpitoyableStackSavedVars.textSize) or 24))
	stackLabel:SetColor(unpack(ImpitoyableStackSavedVars.textColor))
	stackLabel:SetAnchor(CENTER, icon, CENTER, 0, 0)
	stackLabel:SetHidden(false)

    MakeIconMovable()
end

local function CreateSettingsMenu()
    local LAM = LibAddonMenu2
    local panelData = {
        type = "panel",
        name = "ImpitoyableStack Settings",
        displayName = "ImpitoyableStack",
        author = "|c530effT|r|c4a1dffe|r|c422bffn|r|c3a39ffs|r|c3248ffhiraito|r ",
        version = "1.0",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsData = {
        {
            type = "slider",
            name = GetString(SLIDER_SIZE),
            tooltip = GetString(SLIDER_SIZE2),
            min = 32,
            max = 128,
            step = 4,
            getFunc = function() return ImpitoyableStackSavedVars.iconSize end,
			setFunc = function(value)
				ImpitoyableStackSavedVars.iconSize = value
				UpdateIconSize(value)
			end,
        },
		{
			type = "slider",
			name = GetString(SLIDER_TEXT),
			tooltip = GetString(SLIDER_TEXT2),
			min = 16,
			max = 40,
			step = 1,
			getFunc = function()
				return tonumber(ImpitoyableStackSavedVars.textSize) or 24
			end,
			setFunc = function(value)
				ImpitoyableStackSavedVars.textSize = tonumber(value)
				if stackLabel then
					stackLabel:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", ImpitoyableStackSavedVars.textSize))
				end
			end,
		},
        {
            type = "colorpicker",
            name = GetString(COLOR_PICKER),
            tooltip = GetString(COLOR_PICKER2),
            getFunc = function()
                return unpack(ImpitoyableStackSavedVars.textColor)
            end,
            setFunc = function(r, g, b, a)
                ImpitoyableStackSavedVars.textColor = {r, g, b, a}
                if stackLabel then
                    stackLabel:SetColor(r, g, b, a)
                end
            end,
        },
        {
            type = "slider",
            name = GetString(POS_X),
            tooltip = GetString(POS_X2),
            min = 0,
            max = GuiRoot:GetWidth(),
            step = 1,
            getFunc = function() return ImpitoyableStackSavedVars.position.x end,
            setFunc = function(value)
                ImpitoyableStackSavedVars.position.x = value
                if iconTopLevel then
                    iconTopLevel:ClearAnchors()
                    iconTopLevel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, value, ImpitoyableStackSavedVars.position.y)
                end
            end,
        },
        {
            type = "slider",
            name = GetString(POS_Y),
            tooltip = GetString(POS_Y2),
            min = 0,
            max = GuiRoot:GetHeight(),
            step = 1,
            getFunc = function() return ImpitoyableStackSavedVars.position.y end,
            setFunc = function(value)
                ImpitoyableStackSavedVars.position.y = value
                if iconTopLevel then
                    iconTopLevel:ClearAnchors()
                    iconTopLevel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ImpitoyableStackSavedVars.position.x, value)
                end
            end,
        },
		{
			type = "slider",
			name = GetString(SLIDER_STACK),
			tooltip = GetString(SLIDER_STACK2),
			min = 1,
			max = 10,
			step = 1,
			getFunc = function() return ImpitoyableStackSavedVars.minStacksToShow or 1 end,
			setFunc = function(value)
				ImpitoyableStackSavedVars.minStacksToShow = value
				UpdateStackCount(currentStackCount)
			end,
		},
        {
            type = "button",
            name = GetString(BUTTOM_HIDE),
            tooltip = GetString(BUTTOM_HIDE2),
            func = function()
                if iconTopLevel:IsHidden() then
                    iconTopLevel:SetHidden(false)
                else
                    iconTopLevel:SetHidden(true)
                end
            end,
        },
    }

    LAM:RegisterAddonPanel("ImpitoyableStackPanel", panelData)
    LAM:RegisterOptionControls("ImpitoyableStackPanel", optionsData)
end

local function OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime,
    stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)

    if not stackTrackingIDs[abilityId] then return end
    if unitTag ~= "player" then return end

    if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
        currentStackCount = stackCount or 1
        UpdateStackCount(currentStackCount)

    elseif changeType == EFFECT_RESULT_FADED then
        currentStackCount = 0
        UpdateStackCount(currentStackCount)
    end
end

local function OnAddonLoaded(event, addonName)
    if addonName ~= "ImpitoyableStack" then return end

    EVENT_MANAGER:UnregisterForEvent("ImpitoyableStack", EVENT_ADD_ON_LOADED)

    ImpitoyableStackSavedVars = ZO_SavedVars:NewAccountWide("ImpitoyableStack", 1, nil, defaultSavedVars)

    CreateUI()
    CreateSettingsMenu()

    EVENT_MANAGER:RegisterForEvent("ImpitoyableStackEffect", EVENT_EFFECT_CHANGED, OnEffectChanged)
end

EVENT_MANAGER:RegisterForEvent("ImpitoyableStack", EVENT_ADD_ON_LOADED, OnAddonLoaded)
