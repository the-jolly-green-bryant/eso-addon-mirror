BSCMaarselok = BSCMaarselok or {}
local BSCML = BSCMaarselok

BSCML.Name = "BSCs-Maarselok"
BSCML.NameSpaced = "BloodStainChild666's Maarselok"
BSCML.Author = "BloodStainChild666"
BSCML.Version = 1
BSCML.SavedVar = "BSCMaarselokSaved"
BSCML.isCombat = false
BSCML.PROC_COOLDOWN = 7000
BSCML.MAARSELOK_ID = 126941

BSCML.EndTime = GetGameTimeMilliseconds()
BSCML.isRunning = false
BSCML.MAARSELOK_ITEM = "|H1:item:152348:363:50:0:0:0:0:0:0:0:0:0:0:0:1:67:0:1:0:10000:0|h|h"
BSCML.UIisHidden = false

local addonIsRegister = false
local debug_mode = false

local function SlashCommand(text)
	local ftext = zo_strlower(text)
	if ftext == 'debug' then
		if debug_mode then
			debug_mode = false
			d("Debug Mode Disabled!")
		else
			debug_mode = true
			d("Debug Mode Enabled!")
		end
	elseif ftext == 'debugclear' then
		d("Debug List is now Empty again!")
	elseif ftext == 'data' then
		d("Get All Skill Data!")
	elseif ftext == 'test' then
		local abilityId = BSCML.MAARSELOK_ID
		d(zo_strformat("Name [<<1>>]", GetAbilityName(abilityId)))
		d(zo_strformat("Icon [<<1>>]", GetAbilityIcon(abilityId)))		
		d(zo_strformat("Desc [<<1>>]", GetAbilityDescription(abilityId)))		
	else
		d(" ")
		d("Print Debug List :")

		d(" ")

	end
end

local defaultSV = 
{
	PLAYSOUND = true,
	SOUND = "DUEL_START",
	--
	ONLYINCOMBAT = false,
	ONLYIFSETACTIVE = false,
	--
	USEICON = true,
	--
	DIMENSION = 80,
	TEXTSCALING = 20,
	--
	--UI_UPDATE_DELAY = 0, --ms
	UI_UPDATE_INTERVAL = 100, --ms
	UI_TEXTURE_TRANSP = true,
	UI_ALPHA = 1,
	UI_SCALE = 100,
	--
	UI_LEFT = 400,
	UI_TOP  = 400,
	-- 
	textcolor_r = 1,
	textcolor_g = 1,
	textcolor_b = 1,
	textcolor_a = 1,
	--
	text_anchro_top_bottom = 0,
	text_anchro_left_right = 0,
}

function BSCML.CheckMaarselok()

	if BSCML.SV.ONLYIFSETACTIVE == false then return true end

	local set = 0
	_,_,_,set = GetItemLinkSetInfo(BSCML.MAARSELOK_ITEM, true)
	
	if (set == 2) then 
		BSCML.RegisterAddon()
		return true 
	end
	
	BSCML.UnregisterAddon()
	return false
end


function BSCML.OnPlayerCombatState(event, inCombat)
	if BSCML.SV.ONLYINCOMBAT == true then
		if inCombat ~= BSCML.isCombat then
			BSCML.isCombat = inCombat
			
			BSCML.HideUI(not inCombat)
		end
	end
end

function BSCML.OnCombatEvent(setKey, _, result, _, abilityName, _, _, _, _, _, _, _, _, _, _, _, abilityId)	
	if BSCML.isRunning == true then return end
	
	BSCML.isRunning = true
	
	BSCML.EndTime = GetGameTimeMilliseconds() + BSCML.PROC_COOLDOWN --(BSCML.PROC_COOLDOWN - BSCML.SV.UI_UPDATE_DELAY)
	EVENT_MANAGER:RegisterForUpdate(BSCML.Name.."Update", BSCML.SV.UI_UPDATE_INTERVAL, BSCML.UpdateUI)
end

function BSCML.RegisterAddon()
	if addonIsRegister == true then return end

	addonIsRegister = true
	
	EVENT_MANAGER:RegisterForEvent(BSCML.Name, EVENT_PLAYER_COMBAT_STATE, BSCML.OnPlayerCombatState)	
	EVENT_MANAGER:RegisterForEvent(BSCML.Name, EVENT_COMBAT_EVENT, BSCML.OnCombatEvent)
	EVENT_MANAGER:AddFilterForEvent(BSCML.Name, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, BSCML.MAARSELOK_ID)
	EVENT_MANAGER:AddFilterForEvent(BSCML.Name, EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
	
	if BSCML.UIisHidden == true then
		BSCML.HideUI(false)
	end	
end

function BSCML.UnregisterAddon()
	if addonIsRegister == false then return end

	addonIsRegister = false
	EVENT_MANAGER:UnregisterForEvent(BSCML.Name, EVENT_PLAYER_COMBAT_STATE)
	EVENT_MANAGER:UnregisterForEvent(BSCML.Name, EVENT_COMBAT_EVENT)
	
	if BSCML.UIisHidden == false then
		BSCML.HideUI(true)
	end	
end

function BSCML.SlotUpdate(_eventCode, _iBagId, _iSlotId, _bNewItem, _itemSoundCategory, _UpdateReason)

	if _iBagId == BAG_VIRTUAL then return end

	if _UpdateReason == INVENTORY_UPDATE_REASON_DURABILITY_CHANGE then return end
	if _UpdateReason == INVENTORY_UPDATE_REASON_DYE_CHANGE then return end
	if _UpdateReason == INVENTORY_UPDATE_REASON_ITEM_CHARGE then return end
	if _UpdateReason == INVENTORY_UPDATE_REASON_PLAYER_LOCKED then return end
	
	BSCML.CheckMaarselok() 
end

function BSCML.OnPlayerActivated()	
	EVENT_MANAGER:UnregisterForEvent(BSCML.Name, EVENT_PLAYER_ACTIVATED)
	
	BSCML.RegisterAddon()
	
	BSCML.SetIcon()
	BSCML.SetTextAnchors()
	BSCML.SetIconDimension()	
	BSCML.SetFont()
	BSCML.SetAlpha()
	
	BSCML.isCombat = IsUnitInCombat("player");
	if BSCML.SV.ONLYINCOMBAT == true then
		BSCML.HideUI(not BSCML.isCombat)
	else
		BSCML.HideUI(false)
	end	
	
	BSCML.CheckMaarselok() 
	
	
	-- Hide UI
	SCENE_MANAGER:GetScene("hud"):AddFragment(BSCML.Fragment);
	SCENE_MANAGER:GetScene("hudui"):AddFragment(BSCML.Fragment);	
	
end

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////// --- Init -- //////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function BSCML.init(event, addonName)	
	if addonName ~= BSCML.Name then
		return 
	end	
	EVENT_MANAGER:UnregisterForEvent(BSCML.Name, 	EVENT_ADD_ON_LOADED)
	
	-- Saved vars are needed
	BSCML.SV = ZO_SavedVars:NewCharacterNameSettings(BSCML.SavedVar, BSCML.Version, nil, defaultSV)	
		
	-- Command
	SLASH_COMMANDS['/bscml'] = SlashCommand
	--
	BSCML.BuildMenu()
	--
	BSCML.CreateWindow()	
	
	--
	EVENT_MANAGER:RegisterForEvent(BSCML.Name,  EVENT_PLAYER_ACTIVATED,     BSCML.OnPlayerActivated)	
	EVENT_MANAGER:RegisterForEvent(BSCML.Name, 	EVENT_INVENTORY_SINGLE_SLOT_UPDATE, BSCML.SlotUpdate)
	
end

EVENT_MANAGER:RegisterForEvent(BSCML.Name, EVENT_ADD_ON_LOADED, BSCML.init)