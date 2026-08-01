-- Crystal Fragment Proc
-- This addon alerts you when Crystal Fragments procs by displaying a texture at the center bottom of the screen when the effect is triggered.
-- Author: MightyThagmar, based on Supplier (Nicholas)

-------------------------------------------------------------------------------------------------
--  Libraries --
-------------------------------------------------------------------------------------------------
local LAM2 = LibAddonMenu2

TCFP = {}

TCFP.name = "ThagmarsCrystalFragmentsProc"
TCFP.displayVersion = "1.0.2"

TCFP.Default = {
    offsetX = 0,  -- Keep centered
    offsetY = 0,  
    iconWidth = 750,  -- 50% wider than height (500 * 1.5)
    iconHeight = 500, -- Default height
    showTCFP = true,
    textSize = 50
}



--FUNC - Initialize whenever addon is loaded
function TCFP.OnAddOnLoaded(event, addonName)
  if addonName == TCFP.name then
	TCFP:Initialize()
  end
end

function TCFP:Initialize()
    -- 🚀 Ensure saved variables exist, and fallback to defaults if nil
    TCFP.savedVariables = ZO_SavedVars:NewCharacterIdSettings("TCFPSavedVariables", 1, nil, TCFP.Default)

    -- ✅ If first time installation, apply default values
    if not TCFP.savedVariables.iconWidth or not TCFP.savedVariables.iconHeight then
        d("[TCFP] First-time setup detected, applying default values.")

        -- Copy defaults into savedVariables
        for k, v in pairs(TCFP.Default) do
            if TCFP.savedVariables[k] == nil then
                TCFP.savedVariables[k] = v
            end
        end
    end

    TCFP.inCombat = IsUnitInCombat("player")
    TCFP.ClassId = GetUnitClassId("player")

    -- ✅ Create the settings menu **before** restoring settings
    TCFP.CreateSettingsWindow()

    -- 🚀 Register events **only if the player is a Sorcerer**
    if TCFP.ClassId == 2 then
         
        EVENT_MANAGER:RegisterForEvent(TCFP.name, EVENT_PLAYER_COMBAT_STATE, TCFP.OnPlayerCombatState)
        EVENT_MANAGER:RegisterForEvent(TCFP.name, EVENT_EFFECT_CHANGED, TCFP.checkCrystalProc)
        EVENT_MANAGER:RegisterForEvent(TCFP.name, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, TCFP.OnPlayerSwapWeap)

        createBuffImage()

        -- ✅ Restore UI settings (after settings menu is created)
        TCFP:RestoreSettings()

        -- ✅ Slash Command to Toggle UI
        SLASH_COMMANDS["/TCFP"] = showIndicator

    end
end



--FUNC - A function that sets the indicator to be shown or not
function showIndicator(toDo)
	if toDo == "show" then
		TCFPWindow:SetHidden(false)
	else if toDo == "hide" then
		TCFPWindow:SetHidden(true)
	else return end
	end
end

--FUNC - Creates the Crystal Fragment Buff image
function createBuffImage()
    -- Ensure `TCFPWindow` exists
    if not TCFPWindow then
        TCFPWindow = WINDOW_MANAGER:CreateTopLevelWindow("TCFPWindow")
        TCFPWindow:SetMovable(true)
        TCFPWindow:SetMouseEnabled(true)
        TCFPWindow:SetClampedToScreen(true)
        TCFPWindow:SetDimensions(TCFP.savedVariables.iconWidth, TCFP.savedVariables.iconHeight)
        TCFPWindow:SetAnchor(CENTER, GuiRoot, CENTER, TCFP.savedVariables.offsetX, TCFP.savedVariables.offsetY)
        TCFPWindow:SetHidden(true) -- Start hidden
        TCFPWindow:SetHandler("OnMoveStop", function() TCFP.OnIndicatorMoveStop() end)
    end

    -- Ensure `TCFPWindowImage` exists
    if not TCFPWindowImage then
        d("[TCFP] Creating TCFPWindowImage...")

        TCFPWindowImage = WINDOW_MANAGER:CreateControl("TCFPWindowImage", TCFPWindow, CT_TEXTURE)
        TCFPWindowImage:SetAnchor(CENTER, TCFPWindow, CENTER, 0, 0)
        TCFPWindowImage:SetDimensions(TCFP.savedVariables.iconWidth, TCFP.savedVariables.iconHeight)
        TCFPWindowImage:SetHidden(true) -- Start hidden

        local texturePath = "ThagmarsCrystalFragmentsProc/frags.dds"
        TCFPWindowImage:SetTexture(texturePath)

        if TCFPWindowImage:GetTextureFileName() == "" then
            d("[TCFP] ERROR: Texture failed to load! Check file path and format.")
        else
            d("[TCFP] Texture loaded successfully: " .. TCFPWindowImage:GetTextureFileName())
        end
    end

    -- 🚀 Ensure `TCFPWindowCounter` exists
    if not TCFPWindowCounter then
        TCFPWindowCounter = GetControl("TCFPWindowCounter") -- Try to get from XML

        if not TCFPWindowCounter then
            d("[TCFP] Creating new TCFPWindowCounter")
            TCFPWindowCounter = WINDOW_MANAGER:CreateControl("TCFPWindowCounter", TCFPWindow, CT_LABEL)
            TCFPWindowCounter:SetFont("EsoUI/Common/Fonts/univers67.otf|50|thick-outline")
            TCFPWindowCounter:SetColor(1, 1, 1, 1)
            TCFPWindowCounter:SetAnchor(CENTER, TCFPWindow, CENTER, 0, 0)
            TCFPWindowCounter:SetText("8")
        end
    end
end


--FUNC - Event handler for EVENT_EFFECT_CHANGED. Checks for Crystal Fragment Passive Proc and display/remove alert accordingly.
function TCFP.checkCrystalProc(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitID, abilityID)
    -- Ignore effects not related to the player
    if unitTag ~= "player" then return end
    
    -- Ensure `TCFPWindow` exists before modifying it
    if not TCFPWindow then
        d("[TCFP] ERROR: TCFPWindow is nil! Creating now...")
        createBuffImage()
    end

    -- Ensure `TCFPWindowImage` exists
    if not TCFPWindowImage then
        d("[TCFP] ERROR: TCFPWindowImage is nil! Recreating...")
        createBuffImage()
    end

    -- Ensure `TCFPWindowCounter` exists
    if not TCFPWindowCounter then
        d("[TCFP] ERROR: TCFPWindowCounter is nil! Recreating...")
        createBuffImage()
    end

    -- Check whether the effect is a Crystal Fragments proc
    if abilityID == 46327 then
        -- Locate the Crystal Fragment slot if not found
        if not crystalFragSlotFound then
            crystalFragSlot = 3
            while crystalFragSlot < 8 do
                if GetSlotBoundId(crystalFragSlot) == 114716 then
                    crystalFragSlotFound = true
                    break
                end
                crystalFragSlot = crystalFragSlot + 1
            end
        end

        -- 🚀 Ensure `TCFPWindowImage` is set correctly before making it visible
        if TCFPWindow and TCFPWindowImage and GetSlotBoundId(crystalFragSlot) == 114716 and TCFP.inCombat then
            TCFPWindowImage:SetHidden(false)
            TCFPWindow:SetHidden(false)

            -- d("[TCFP] Showing Crystal Fragments Proc Image!")

            crystalFragDuration = 8
            if TCFPWindowCounter then
                TCFPWindowCounter:SetText(string.format("%d", crystalFragDuration))
            else
                d("[TCFP] ERROR: TCFPWindowCounter is still nil!")
            end

            EVENT_MANAGER:RegisterForUpdate(TCFP.name, 1000, function(gameTimeMs) TCFP.UpdateTimer() end)
        else
            if TCFPWindow then
                TCFPWindow:SetHidden(true)
            end
            EVENT_MANAGER:UnregisterForUpdate(TCFP.name)
        end
    end
end



--FUNC - If combat is over, set boolean variable crystalFragSlotFound back to false. This is
--	done to make sure the addon still works if user move their skills in their hotbar during gameplay.
function TCFP.OnPlayerCombatState(event, inCombat)
  if inCombat ~= TCFP.inCombat then
    TCFP.inCombat = inCombat
	if not inCombat then
		crystalFragSlotFound = false
    end
  end
end

-- FUNC - Function that is called every second. Updates the timer.
function TCFP.UpdateTimer()
    crystalFragDuration = crystalFragDuration - 1

    -- 🚀 Check if `TCFPWindowCounter` exists before using it
    if TCFPWindowCounter then
        TCFPWindowCounter:SetText(string.format("%d", crystalFragDuration))
    else
        d("[TCFP] ERROR: TCFPWindowCounter is nil! Skipping text update.")
    end

    -- Hide the window if duration reaches 0
    if crystalFragDuration <= 0 then 
        if TCFPWindow then
            TCFPWindow:SetHidden(true)
        end
        EVENT_MANAGER:UnregisterForUpdate(TCFP.name)
    end
end



--FUNC - Whenever user swaps its weapon, set boolean variable crystalFragSlotFound back to false
function TCFP.OnPlayerSwapWeap(event)
	crystalFragSlotFound = false
end

--FUNC - Restores position and size of the indicator
function TCFP:RestoreSettings()
    local offsetX = TCFP.savedVariables.offsetX or 0
    local offsetY = TCFP.savedVariables.offsetY or 0

    -- 🛠️ Reset to (0,0) when using defaults
    if offsetX == 874 and offsetY == 478 then
        d("[TCFP] Resetting anchor to (0,0) instead of bottom-right corner")
        offsetX = 0
        offsetY = 0
        TCFP.savedVariables.offsetX = 0
        TCFP.savedVariables.offsetY = 0
    end

    -- Maintain 1.5x width-to-height ratio
    TCFP.savedVariables.iconWidth = math.floor(TCFP.savedVariables.iconHeight * 1.5)

    -- Apply settings
    TCFPWindow:SetHidden(TCFP.savedVariables.showTCFP)
    TCFP.SetIconSize(TCFP.savedVariables.iconWidth, TCFP.savedVariables.iconHeight)

    -- 🔥 Always reset anchor to CENTER with the corrected offsets
    TCFPWindow:ClearAnchors()
    TCFPWindow:SetAnchor(CENTER, GuiRoot, CENTER, offsetX, offsetY)

    -- Debugging log
    d(string.format("[TCFP] Window restored to X:%d, Y:%d | Size: %dx%d", offsetX, offsetY, TCFP.savedVariables.iconWidth, TCFP.savedVariables.iconHeight))
end



--FUNC - Saves location of the indicator when moved
function TCFP.OnIndicatorMoveStop()
    local x, y = TCFPWindow:GetLeft(), TCFPWindow:GetTop()

    -- 🛠️ Prevent drifting issue when resetting defaults
    if x == 874 and y == 478 then
        d("[TCFP] Preventing drift. Resetting saved position to (0,0)")
        x = 0
        y = 0
    end

    -- Save new position
    TCFP.savedVariables.offsetX = x
    TCFP.savedVariables.offsetY = y

    -- Debugging output
    d(string.format("[TCFP] New position saved: X:%d, Y:%d", x, y))
end


--FUNC - Sets the Dimensions of the Indicator Image
-- function TCFP.SetIconSize(_width, _height)
--     if TCFPWindow then
--         -- 🚀 Attempt to get current anchor
--         local anchorPoint, relativeTo, relativePoint, offsetX, offsetY = TCFPWindow:GetAnchor()

--         -- 🛠️ Validate anchorPoint and offsets (fallback to CENTER)
--         if not anchorPoint or type(anchorPoint) ~= "number" then
--             d("[TCFP] WARNING: Invalid anchor point detected. Resetting to CENTER.")
--             anchorPoint = CENTER
--             relativeTo = GuiRoot
--             relativePoint = CENTER
--             offsetX = TCFP.savedVariables.offsetX or 0
--             offsetY = TCFP.savedVariables.offsetY or 0
--         end

--         -- 🛠️ Ensure offsetX and offsetY are numbers
--         offsetX = tonumber(offsetX) or 0
--         offsetY = tonumber(offsetY) or 0

--         -- 🚀 Clear existing anchors
--         TCFPWindow:ClearAnchors()

--         -- ✅ Reapply anchor with valid values
--         TCFPWindow:SetAnchor(anchorPoint, relativeTo, relativePoint, offsetX, offsetY)

--         -- 🔥 Update size
--         TCFPWindow:SetDimensions(_width, _height)
--     end
-- end
function TCFP.SetIconSize(_width, _height)
    if TCFPWindow then
        -- Clear existing anchors to avoid drifting
        TCFPWindow:ClearAnchors()

        -- 🔥 Reset anchor to CENTER after resizing
        TCFPWindow:SetAnchor(CENTER, GuiRoot, CENTER, TCFP.savedVariables.offsetX, TCFP.savedVariables.offsetY)

        -- Apply new size
        TCFPWindow:SetDimensions(_width, _height)
        TCFPWindowImage:SetDimensions(_width, _height)

        -- Debug log
        d(string.format("[TCFP] Resized to %dx%d at offset X:%d, Y:%d", _width, _height, TCFP.savedVariables.offsetX, TCFP.savedVariables.offsetY))
    end
end








--FUNC - Sets the size of the Indicator Timer Text
function TCFP.SetTextSize(size)
    if TCFPWindowCounter then
        TCFPWindowCounter:SetFont("EsoUI/Common/Fonts/univers67.otf|" .. size .. "|thick-outline")
    else
        d("[ThagmarsCrystalFragmentsProc] Error: TCFPWindowCounter is nil!")
    end
end


-- FUNC - Create the Settings Window for this Addon. (Requires LibAddonMenu2!)
function TCFP.CreateSettingsWindow() 
    -- Prevent duplicate control creation
    if TCFP.SettingsPanel then return end

    local panelData = {
        type = "panel",
        name = "Thagmar's Crystal Fragments Proc",
        displayName = "Crystal Fragments Proc",
        author = "MightyThagmar",
        version = TCFP.version,
        slashCommand = "/TCFP menu",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    
    -- Store the panel reference to prevent duplication
    TCFP.SettingsPanel = LAM2:RegisterAddonPanel("Crystal_Fragments_Proc", panelData)

    local optionsData = {
        [1] = {
            type = "header",
            name = "Crystal Fragments Proc Indicator Settings",
        },
        [2] = {
            type = "description",
            text = "Here you can adjust how the indicator looks.",
        },
        [3] = {
            type = "checkbox",
            name = "Show Crystal Fragments Proc Indicator",
            tooltip = "When ON the indicator will be visible. When OFF the indicator will be hidden.",
            default = false,
            getFunc = function() return not TCFP.savedVariables.showTCFP end,
            setFunc = function(newValue) 
                TCFP.savedVariables.showTCFP = not newValue
                TCFPWindow:SetHidden(not newValue)
            end,
        },
        [4] = {
            type = "slider",
            name = "Select Width",
            tooltip = "Adjusts the width of the icon",
            min = 150,
            max = 1500,
            step = 10,
            default = 750,
            getFunc = function() return TCFP.savedVariables.iconWidth end,
            setFunc = function(newValue)
                TCFP.savedVariables.iconWidth = newValue
                TCFP.savedVariables.iconHeight = math.floor(newValue / 1.5)
                TCFP.SetIconSize(newValue, TCFP.savedVariables.iconHeight)
            end,
        },
        [5] = {
            type = "slider",
            name = "Select Height",
            tooltip = "Adjusts the height of the icon",
            min = 100,
            max = 1000,
            step = 10,
            default = 500,
            getFunc = function() return TCFP.savedVariables.iconHeight end,
            setFunc = function(newValue)
                TCFP.savedVariables.iconHeight = newValue
                TCFP.savedVariables.iconWidth = math.floor(newValue * 1.5)
                TCFP.SetIconSize(TCFP.savedVariables.iconWidth, newValue)
            end,
        },                        
        [6] = {
            type = "slider",
            name = "Select Timer Text Size",
            tooltip = "Adjusts the font size of the timer",
            min = 25,
            max = 85,
            step = 1,
            default = 50,
            getFunc = function() return TCFP.savedVariables.textSize end,
            setFunc = function(newValue)
                TCFP.savedVariables.textSize = newValue
                TCFP.SetTextSize(newValue)
            end,
        },
        [7] = {
            type = "button",
            name = "Reset to Default Position",
            tooltip = "Resets the icon's position to the center of the screen.",
            func = function()
                d("[TCFP] Resetting position to (0,0)")
                TCFP.savedVariables.offsetX = 0
                TCFP.savedVariables.offsetY = 0
                TCFP:RestoreSettings()
            end,
        },
    }

    -- Register settings only once
    LAM2:RegisterOptionControls("Crystal_Fragments_Proc", optionsData)
end



EVENT_MANAGER:RegisterForEvent(TCFP.name, EVENT_ADD_ON_LOADED, TCFP.OnAddOnLoaded)