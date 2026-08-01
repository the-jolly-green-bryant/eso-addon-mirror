-------------------------------------------------------------------------------------------------
--  Libraries --
-------------------------------------------------------------------------------------------------
local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")
-------------------------------------------------------------------------------------------------
--  Initialize Variables --
-------------------------------------------------------------------------------------------------
championUI = {}
championUI.name = "championUI" 
championUI.version = "2.0.0" 
championUI.author = "Hozec"

---------------------------------------------------------------------------------------------------------
-- S E T T I N G S
---------------------------------------------------------------------------------------------------------
championUI.defaultSettings = {
	OffsetX = 200,
	OffsetY= 100,
	Show = true,
	FontSize = 12,
	Width = 180,
	Height = 120,
}

championUI.savedVariables = championUI.defaultSettings


function championUI.CreateSettingsWindow()
local panelData = {
	type = "panel",
	name = "Champion UI",
	displayName = "Champion UI",
	author = championUI.author,
	version = championUI.version,
	--slashCommand = "",
	registerForRefresh = true,
	registerForDefaults = true,
}

local optionsData = {
[1] = {
		type = "checkbox",
		name = "Show UI Element",
		tooltip = "Show UI Element",
		getFunc = function() return championUI.savedVariables.Show end,
		setFunc = function(value) 
				championUI.savedVariables.Show = value 
				championUI.ToggleUI() end,
		default = true,
	    },
[2] = {
        type = "slider",
        name = "Font Size",
        tooltip = "Font Size",
        min = 12,
        max = 32,
        step = 2,
        getFunc = function() return championUI.savedVariables.FontSize end,
        setFunc = function(value) 
				championUI.savedVariables.FontSize = value
				championUI.ChangeFontSize()
				end,
        default = 12,
    },
[3] = {
        type = "header",
        name = "Coming Soon",
    },
[4] = {
        type = "dropdown",
        name = "Font",
        tooltip = "Font Options",
        choices = {"1", "2", "3"},
        getFunc = function()  end,
        setFunc = function(var)  end,
		disabled = true,
    },
}
 LAM2:RegisterAddonPanel("champion_ui", panelData)
 LAM2:RegisterOptionControls("champion_ui", optionsData)
end
 
-------------------------------------------------------------------------------------------------
--  OnAddOnLoaded  --
-------------------------------------------------------------------------------------------------
function championUI.OnAddOnLoaded(event, addonName)
   if addonName ~= championUI.name then return end
	championUI.Initialize()
	--Shows/Hide UI
end
 
-------------------------------------------------------------------------------------------------
--  Initialize Function --
-------------------------------------------------------------------------------------------------
function championUI.Initialize()
 -- Register Keybinding
    ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_ChampUI", "Toggle Champion UI")

--saves default position to center of screen.
championUI.savedVariables = ZO_SavedVars:New("championUIVars", 1, nil, championUI.defaultSettings)

championUI.CreateSettingsWindow()
championUI.ChangeFontSize()

--Loads the ui element to the last saved position
CHAMPIONUI:ClearAnchors()
CHAMPIONUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, championUI.savedVariables.OffsetX, championUI.savedVariables.OffsetY)


EVENT_MANAGER:UnregisterForEvent(championUI.name, EVENT_ADD_ON_LOADED)
EVENT_MANAGER:RegisterForEvent( championUI.Name, EVENT_PLAYER_ACTIVATED, championUI.PlayerActivated )
end 
 
 
 -------------------------------------------------------------------------------------------------
--  Other Functions --
-------------------------------------------------------------------------------------------------
function championUI.PlayerActivated()
local player = GetUnitName("player")
	EVENT_MANAGER:UnregisterForEvent(championUI.Name, EVENT_PLAYER_ACTIVATED)
	--Checks to see if the champion system is activated
	if IsChampionSystemUnlocked() then
		CHAMPIONUI_SCENE_FRAGMENT = ZO_HUDFadeSceneFragment:New(CHAMPIONUI)
		championUI.ToggleUI()
		
	end
end

--GetChampionPointAttributeIcon(attribute)
function championUI.update()
--gets champion rank information
local rank =  GetPlayerChampionPointsEarned()
local xpNeeded = FormatIntegerWithDigitGrouping(GetNumChampionXPInChampionPoint(rank), ",")
local xpCurrent = FormatIntegerWithDigitGrouping(GetPlayerChampionXP(), ",")
local nextChampRank = GetChampionPointAttributeForRank(rank+1)
local color = nil
--The Warrior
if ( nextChampRank == 1 ) then
	color = "|cD6660C"
-- The Mage
elseif ( nextChampRank == 2 ) then
	color = "|c1970c9"
-- The Thief
else
	color = "|c0dab36"
end

--Gets unspent skill points
local uWarrior = GetNumUnspentChampionPoints(1)
local uThief = GetNumUnspentChampionPoints(3)
local uMage = GetNumUnspentChampionPoints(2)
--gets spent skill points
local sWarrior = GetNumSpentChampionPoints(1) -- (2,3,4) Lord/Lady/steed
local sThief =  GetNumSpentChampionPoints(3) -- (1,8,9) Tower/Shadow/Lover
local sMage =  GetNumSpentChampionPoints(2) -- (5,6,7) Ritual/Atronach/ Apprentice



CHAMPIONUIDisplayRank:SetText("Champion Rank: |cffffff "..tostring(rank))
if (IsUnitChampion('player')) then
	CHAMPIONUIDisplayXP:SetText(color.."XP: "..xpCurrent.."/"..xpNeeded)
end
CHAMPIONUIWarriorLabel:SetText("|cD6660C"..uWarrior.."/"..sWarrior)
CHAMPIONUIThiefLabel:SetText("|c0dab36"..uThief.."/"..sThief)
CHAMPIONUIMageLabel:SetText("|c1970c9"..uMage.."/"..sMage)
end



--Toggles The UI element
function championUI.ToggleUI()	

	if (not championUI.savedVariables.Show) then
	    HUD_SCENE:RemoveFragment(CHAMPIONUI_SCENE_FRAGMENT)
		HUD_UI_SCENE:RemoveFragment(CHAMPIONUI_SCENE_FRAGMENT)
		SIEGE_BAR_SCENE:RemoveFragment(CHAMPIONUI_SCENE_FRAGMENT)
	else
		HUD_SCENE:AddFragment(CHAMPIONUI_SCENE_FRAGMENT)
		HUD_UI_SCENE:AddFragment(CHAMPIONUI_SCENE_FRAGMENT)
		SIEGE_BAR_SCENE:AddFragment(CHAMPIONUI_SCENE_FRAGMENT)	
		championUI.update()		
	end
end 

function championUI.ChangeFontSize()
	CHAMPIONUIDisplayRank:SetFont(string.format( "%s|%d|%s", "$(BOLD_FONT)", championUI.savedVariables.FontSize, "soft-shadow-thick"))
	CHAMPIONUIUnspentLabel:SetFont(string.format( "%s|%d|%s", "$(BOLD_FONT)", championUI.savedVariables.FontSize, "soft-shadow-thick"))
	
	CHAMPIONUIWarriorLabel:SetFont(string.format( "%s|%d|%s", "$(BOLD_FONT)", championUI.savedVariables.FontSize, "soft-shadow-thick"))
	CHAMPIONUIWarriortxt:SetFont(string.format( "%s|%d|%s", "$(BOLD_FONT)", championUI.savedVariables.FontSize, "soft-shadow-thick"))
	
	CHAMPIONUIThiefLabel:SetFont(string.format( "%s|%d|%s", "$(BOLD_FONT)", championUI.savedVariables.FontSize, "soft-shadow-thick"))
	CHAMPIONUIThieftxt:SetFont(string.format( "%s|%d|%s", "$(BOLD_FONT)", championUI.savedVariables.FontSize, "soft-shadow-thick"))
	
	CHAMPIONUIMageLabel:SetFont(string.format( "%s|%d|%s", "$(BOLD_FONT)", championUI.savedVariables.FontSize, "soft-shadow-thick"))
	CHAMPIONUIMagetxt:SetFont(string.format( "%s|%d|%s", "$(BOLD_FONT)", championUI.savedVariables.FontSize, "soft-shadow-thick"))
	
	if (IsUnitChampion('player')) then
		CHAMPIONUIDisplayXP:SetFont(string.format( "%s|%d|%s", "$(BOLD_FONT)", championUI.savedVariables.FontSize, "soft-shadow-thick"))
	end
end

function championUI.ToggleUIKeyBind()
	championUI.savedVariables.Show = not championUI.savedVariables.Show 
	championUI.ToggleUI()
end 

-------------------------------------------------------------------------------------------------
--  XML Handlers --
-------------------------------------------------------------------------------------------------

local function ChampionUI_OnMoveStop(self)
	championUI.savedVariables.OffsetX = self:GetLeft()
	championUI.savedVariables.OffsetY = self:GetTop()
end

local function ChampionUI_ResizeStop(self)
  
end

local function ChampionUI_ResizeStart(self)
  
    
end

function CHAMPIONUI_OnInitialized(self)
    self:SetHandler("OnResizeStart", ChampionUI_ResizeStart)
    self:SetHandler("OnResizeStop", ChampionUI_ResizeStop)
    self:SetHandler("OnMoveStop", ChampionUI_OnMoveStop)
	
end




-------------------------------------------------------------------------------------------------
--  Register Events --
-------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent("championUI.name", EVENT_ADD_ON_LOADED, championUI.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent("championUI.name", EVENT_UNSPENT_CHAMPION_POINTS_CHANGED, championUI.update)
EVENT_MANAGER:RegisterForEvent("championUI.name" , EVENT_EXPERIENCE_UPDATE, championUI.update)
