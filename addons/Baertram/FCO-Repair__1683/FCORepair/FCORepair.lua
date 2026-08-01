------------------------------------------------------------------
--FCORepair.lua
--Author: Baertram
--[[
Help repairing your equipment
]]
------------------------------------------------------------------
if FCORep == nil then FCORep = {} end
local FCORep = FCORep

local EM = EVENT_MANAGER
local WM = WINDOW_MANAGER

--Addon variables
FCORep.addonVars = {}
FCORep.addonVars.gAddonName					= "FCORepair"
FCORep.addonVars.addonNameMenu				= "FCO Repair"
FCORep.addonVars.addonNameMenuDisplay		= "|c00FF00FCO |cFFFF00Repair|r"
FCORep.addonVars.addonAuthor 				= '|cFFFF00Baertram|r'
FCORep.addonVars.addonVersion		   		= 0.10 -- Changing this will reset SavedVariables!
FCORep.addonVars.addonVersionOptions 		= '0.0.7' -- version shown in the settings panel
FCORep.addonVars.addonVersionOptionsNumber 	= 0.07
FCORep.addonVars.addonSavedVariablesName	= "FCORepair_Settings"
FCORep.addonVars.gAddonLoaded				= false
local addonName = FCORep.addonVars.gAddonName

-- Add [] around the name for the equipped items
function FCORep.addBracketsToName(rowControl, slot)
    if rowControl == nil or slot == nil
            --Add [] around equipped items is enabled?
    or not FCORep.settingsVars.settings.addBracketsAroundName then return false end

    --slot.bagid got the item's bagId. If it's 0 the item is equipped
    --rowControl.GetChildByName("Name") is the label control for the name
    --Get the label where we want to change the color
    local nameLabel = WM:GetControlByName(rowControl:GetName(), "Name")
    if nameLabel == nil then return false end
    --Check the equipped state and te default name
    if slot.name == nil then return false end
    if slot.bagId == BAG_WORN then
        nameLabel:SetText("[ " .. slot.name .. " ]")
    else
        nameLabel:SetText(slot.name)
    end
end

--Check the value of the condition and the threshold values and color the condition if needed
function FCORep.checkAndColorizeConditionValue(rowControl, slot)
    if rowControl == nil or slot == nil then return end
    local settings = FCORep.settingsVars.settings
    --Colorize the condition is enabled?
    if not settings.colorizeCondition then return false end
    --[[
    FCORep.repairListSlots = FCORep.repairListSlots or {}
    FCORep.repairListSlots[rowControl:GetName()] = {
        control = rowControl,
        slot = slot
    }
    ]]
    --Check the condition
    --slot.condition got the item's condition value, e.g. 52 (= 52%)
    --Is the condition higher than the high threshold value?
    local cond = slot.condition
    if not cond then return false end
    --Get the label where we want to change the color
    local condLabel = rowControl:GetNamedChild("ItemCondition")
    if condLabel == nil then return false end

    local condSet = settings.condition
    local high = condSet["high"]
    local medium = condSet["medium"]
    local low = condSet["low"]

    local colorToUse
    if cond >= high.value and cond > medium.value then
        colorToUse = high.color
    elseif cond < high.value and cond >= medium.value then
        colorToUse = medium.color
    elseif cond < medium.value then
        colorToUse = low.color
        --else
        --NO threshold values met, do not change color!
    end
    if not colorToUse then return end
    condLabel:SetColor(colorToUse.r, colorToUse.g, colorToUse.b, colorToUse.a)
end

--Localization
local function Localization()
--d("[FCORep] Localization - Start, useClientLang: " .. tostring(FCORep.settingsVars.settings.alwaysUseClientLanguage))
	--Was localization already done during keybindings? Then abort here
 	if FCORep.preventerVars.gLocalizationDone == true then return end
    --Fallback to english variable
    local fallbackToEnglish = false
	--Always use the client's language?
    if not FCORep.settingsVars.settings.alwaysUseClientLanguage then
		--Was a language chosen already?
	    if not FCORep.settingsVars.settings.languageChosen then
--d("[FCORep] Localization: Fallback to english. Language chosen: " .. tostring(FCORep.settingsVars.settings.languageChosen) .. ", defaultLanguage: " .. tostring(FCORep.settingsVars.defaultSettings.language))
			if FCORep.settingsVars.defaultSettings.language == nil then
--d("[FCORep] Localization: defaultSettings.language is NIL -> Fallback to english now")
		    	fallbackToEnglish = true
		    else
				--Is the languages array filled and the language is not valid (not in the language array with the value "true")?
				if FCORep.langVars.languages ~= nil and #FCORep.langVars.languages > 0 and not FCORep.langVars.languages[FCORep.settingsVars.defaultSettings.language] then
		        	fallbackToEnglish = true
--d("[FCORep] Localization: defaultSettings.language is ~= " .. i .. ", and this language # is not valid -> Fallback to english now")
				end
		    end
		end
	end
--d("[FCORep] localization, fallBackToEnglish: " .. tostring(fallbackToEnglish))
	--Fallback to english language now
    if (fallbackToEnglish) then FCORep.settingsVars.defaultSettings.language = 1 end
	--Is the standard language english set?
    if FCORep.settingsVars.settings.alwaysUseClientLanguage or (FCORep.settingsVars.defaultSettings.language == 1 and not FCORep.settingsVars.settings.languageChosen) then
--d("[FCORep] localization: Language chosen is false or always use client language is true!")
		local lang = GetCVar("language.2")
		--Check for supported languages
		if(lang == "de") then
	    	FCORep.settingsVars.defaultSettings.language = 2
	    elseif (lang == "en") then
	    	FCORep.settingsVars.defaultSettings.language = 1
	    elseif (lang == "fr") then
	    	FCORep.settingsVars.defaultSettings.language = 3
	    elseif (lang == "es") then
	    	FCORep.settingsVars.defaultSettings.language = 4
	    elseif (lang == "it") then
	    	FCORep.settingsVars.defaultSettings.language = 5
	    elseif (lang == "jp") then
	    	FCORep.settingsVars.defaultSettings.language = 6
	    elseif (lang == "ru") then
	    	FCORep.settingsVars.defaultSettings.language = 7
		else
	    	FCORep.settingsVars.defaultSettings.language = 1
	    end
	end
--d("[FCORep] localization: default settings, language: " .. tostring(FCORep.settingsVars.defaultSettings.language))
    --Get the localized texts from the localization file
    FCORep.localizationVars.FCORep_loc = FCORep.localizationVars.localizationAll[FCORep.settingsVars.defaultSettings.language]
end

--==============================================================================
--============================== END SETTINGS ==================================
--==============================================================================


--Addon loads up
local function FCORepair_Loaded(eventCode, addOnNameOfEachAddon)
	--Is this addon found?
	if addOnNameOfEachAddon ~= addonName then
        return
    end
	--Unregister this event again so it isn't fired again after this addon has beend reckognized
    EM:UnregisterForEvent(addonName, EVENT_ADD_ON_LOADED)

	FCORep.addonVars.gAddonLoaded = false

    --Load the user settings
    FCORep.LoadUserSettings()

	-- Set Localization
    Localization()

    --Build the LAM menu
    FCORep.BuildAddonMenu()

	--Create the hooks
    FCORep.CreateHooks()

    --Register the event handler callback functions
    FCORep.RegisterEventHandlers()
end

-- Register the event "addon loaded" for this addon
local function FCORepair_Initialized()
	EM:RegisterForEvent(addonName, EVENT_ADD_ON_LOADED, FCORepair_Loaded)
end


--------------------------------------------------------------------------------
--- Call the start function for this addon to register events etc.
--------------------------------------------------------------------------------
FCORepair_Initialized()
