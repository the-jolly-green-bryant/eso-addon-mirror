PotionBlocker = PotionBlocker or {}
local pot = PotionBlocker
local EM = GetEventManager()
local libDialog = LibDialog
local currentQuickSlot = GetCurrentQuickslot()
local CLEVER = {
	[1] = "|H0:item:72198:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:1000:0|h|h", 
	[2] = "|H0:item:72150:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h",
}

pot.name = "PotionBlocker"
pot.version = "1.4"

pot.downTime	= 0

pot.UPDATE_INTERVAL	= 100

pot.defaults	= {
	["toggle"] = true,
	["offsetX"]	= 1291.8018798828,
	["offsetY"]	= 1262.1693115234,
	["timerSize"]	= 28,
	["passiveHide"]	= false,
	["colourUp"]	= {1,1,1},
	["colourDown"]	= {1,0,0},
	["hideTimer"] = false,
}

pot.COLORS = {
	["UP"] = {
		1, 1, 1,
	},
	["DOWN"] = {
		1, 0, 0,
	} 
}

pot.dots		= { 
	"Clever Alchemist", 
}


function pot.setPos()
	local x, y = pot.savedVariables.offsetX, pot.savedVariables.offsetY
	potFrame:ClearAnchors()
	potFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

function savePos()
	pot.savedVariables.offsetX = potFrame:GetLeft()
	pot.savedVariables.offsetY = potFrame:GetTop()
end

function pot.hideOutOfCombat()
	if pot.savedVariables.passiveHide then 
		potFrame:SetHidden(not IsUnitInCombat("player"))
	end
end 

function pot.hideFrame()
	potFrame:SetHidden(IsReticleHidden())
	if not IsReticleHidden() then pot.hideOutOfCombat() end
end

function pot.setFontSize(size)
	potFrameTime:SetFont(string.format('%s|%d|%s', '$(CHAT_FONT)', size, 'soft-shadow-thick'))
end

function pot.textInitial()
	potFrameTime:SetColor(unpack(pot.savedVariables.colourDown))
	potFrameTime:SetFont(string.format('%s|%d|%s', '$(CHAT_FONT)', pot.savedVariables.timerSize, 'soft-shadow-thick'))
end

function pot.countDown()
	if not pot.active and (pot.downTime - GetGameTimeMilliseconds()/1000 > 0) then
	potFrameTime:SetColor(unpack(pot.savedVariables.colourDown))
	   potFrameTime:SetText(string.format("%.1f", pot.time(pot.downTime)))
   else
	   potFrameTime:SetColor(unpack(pot.savedVariables.colourUp))
	   potFrameTime:SetText("0.0")
	   EM:UnregisterForUpdate(pot.name.."Update")
   end
end

function pot.time(nd)
	return math.floor((nd - GetGameTimeMilliseconds()/1000) * 20 + 0.5)/20
end
	
function pot.combatEvent(_, result, _, abilityName, _, _, _, _, _, _, _, _, _, _, _, _, _)
	for i, dot in ipairs(pot.dots) do 
		if result == ACTION_RESULT_ABILITY_ON_COOLDOWN then
			if abilityName == dot then    
				EM:RegisterForUpdate(pot.name.."Update", pot.UPDATE_INTERVAL, pot.countDown)
				pot.downTime = GetGameTimeMilliseconds()/1000 + 20	-- 10 seconds after clever alchemist procs
				pot.active = false
			end  
		end 
	end   
end  




local function cleverCheck()
	local p = 0

	for key, value in ipairs(CLEVER)
	do
		_,_,_,p = GetItemLinkSetInfo(CLEVER[key], true)
		if(p >= 3) then return true else return false end
	end

end

function changeCurrentQuickSlot()
	if GetActiveWeaponPairInfo() == 2 then 	
		currentQuickSlot = GetCurrentQuickslot();
	end
end

function checkslot()
	if(cleverCheck() == true) then
		local itemLinkNew;
		local itemTypeNew;
		if GetActiveWeaponPairInfo() == 1 then 	
			itemLink = GetSlotItemLink(GetCurrentQuickslot())
			itemType = GetItemLinkItemType(itemLink)
			if itemType == ITEMTYPE_POTION then	
				for i = 8, 16 do
					itemLinkNew = GetSlotItemLink(i)
					itemTypeNew = GetItemLinkItemType(itemLinkNew)
					if itemTypeNew == 0 or itemTypeNew == ITEMTYPE_CROWN_ITEM then
						SetCurrentQuickslot(i)
					end
				end
			end
		end
	end
end

-- function checkMomentSlotted()
-- 	if(cleverCheck() == true) then
-- 		for i = 8, 16 do
-- 			itemLinkNew = GetSlotItemLink(i)
-- 			itemTypeNew = GetItemLinkItemType(itemLinkNew)
-- 			if itemTypeNew == 0 or itemTypeNew == ITEMTYPE_CROWN_ITEM then
-- 			else
-- 				d("PotionCuck | Slot a momento or crown item in your quickslots")
-- 			end
-- 		end
-- 	end
-- end

function potionBlock(eventCode, isHotbarSwap)
	if(cleverCheck() == true) then
		if GetActiveWeaponPairInfo() == 1 then 	
				for i = 8, 16 do
					itemLinkNew = GetSlotItemLink(i)
					itemTypeNew = GetItemLinkItemType(itemLinkNew)
					if itemTypeNew == 0 or itemTypeNew == ITEMTYPE_CROWN_ITEM then
						SetCurrentQuickslot(i)
					end
				end
		end

		if GetActiveWeaponPairInfo() == 2 then 	
			SetCurrentQuickslot(currentQuickSlot)
		end
	end
end


function pot.init(event, addon)
	if addon ~= pot.name then return end
	EM:UnregisterForEvent(pot.name.."Load", EVENT_ADD_ON_LOADED)
	pot.savedVariables = ZO_SavedVars:New("PotionBlockerSavedVars", 1, nil, pot.defaults)
	pot.setupMenu()
	pot.setupUI()
	pot.setPos()	
	pot.textInitial()
	if pot.savedVariables.hideTimer == false then
		EM:RegisterForEvent(pot.name.."PassiveHide", EVENT_PLAYER_COMBAT_STATE, pot.hideOutOfCombat)
	else 
		pot.hideFrame()
	end
	EM:RegisterForEvent(pot.name.."potionWillBeBlocked", EVENT_ACTION_SLOTS_FULL_UPDATE , potionBlock)
	EM:RegisterForEvent(pot.name.."quickslotchange", EVENT_ACTIVE_QUICKSLOT_CHANGED , changeCurrentQuickSlot)
	EM:RegisterForEvent(pot.name.."quickslotcheck", EVENT_ACTIVE_QUICKSLOT_CHANGED , checkslot)
	EM:RegisterForEvent(pot.name.."timer", EVENT_COMBAT_EVENT, pot.combatEvent)

	local fragment = ZO_FadeSceneFragment:New( potFrame )
 
	SCENE_MANAGER:GetScene('hud'):AddFragment( fragment )
	SCENE_MANAGER:GetScene('hudui'):AddFragment( fragment )

end

EM:RegisterForEvent(pot.name.."Load", EVENT_ADD_ON_LOADED, pot.init)
