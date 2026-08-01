-- First, we create a namespace for our addon by declaring a top-level table that will hold everything else.
FishermansFriend = {}
FishermansFriend.defaults = {}
FishermansFriend.defaults.filtered = {}

FishermansFriend.defaults.filtered[1] = true

local LAM = LibAddonMenu2
local setBait = true

-- This isn't strictly necessary, but we'll use this string later when registering events.
-- Better to define it in a single place rather than retyping the same string.
FishermansFriend.name = "FishermansFriend"

BAIT_LAKE_GUTS = 2
BAIT_LAKE_GUTS_ITEMID = 42870
BAIT_LAKE_MINNOW = 8
BAIT_LAKE_MINNOW_ITEMID = 42876

BAIT_FOUL_CRAWLERS = 3
BAIT_FOUL_CRAWLERS_ITEMID = 42871
BAIT_FOUL_ROE = 9
BAIT_FOUL_ROE_ITEMID = 42873

BAIT_RIVER_INSECT = 4
BAIT_RIVER_INSECT_ITEMID = 42872
BAIT_RIVER_SHAD = 6
BAIT_RIVER_SHAD_ITEMID = 42874

BAIT_SALTWATER_WORMS = 5
BAIT_SALTWATER_WORMS_ITEMID = 42869
BAIT_SALTWATER_CHUB = 7
BAIT_SALTWATER_CHUB_ITEMID = 42875

 
-- Next we create a function that will initialize our addon
function FishermansFriend:Initialize()
    FishermansFriend.SavedVariables = ZO_SavedVars:New("FishermansFriendSavedVariables", 1, nil, FishermansFriend.defaults)
	FishermansFriend.CreateSettings()
end
 
--Setting Menu
function FishermansFriend.CreateSettings()
	local panelName = "FishermansFriendSettingsPanel"
	
	local panelData = {
	   type = "panel",
		name = "Fisherman's Friend",
		displayName = "Fisherman's Friend",
		author = "GameDude",
--		website = "",
--      feedback = "",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	local panel = LAM:RegisterAddonPanel(panelName, panelData)
	local optionsData = {}
		optionsData[#optionsData + 1] = {
			type = "header",
			name = "Fisherman's Friend Settings",
		}
		optionsData[#optionsData + 1] = {
			type = "description",
			text = "You can change whether or not you want to use the alternative baits first (Shad, Chub, Fish Roe, and Minnow) over the regular baits (Worms, Guys, Insect Parts, Crawlers.",
		}
		optionsData[#optionsData + 1] = {
            type = "button",
            name = "Close Settings",
			width = "half",
            func = function()
                SCENE_MANAGER:ShowBaseScene()
            end,
        }
		optionsData[#optionsData + 1] = {
			type = "header",
			name = "Default Items"
		}
		optionsData[#optionsData + 1] = {
			type = "checkbox",
			name = "Use Alternative Baits First",
			default = true,
			width = "half",
			disabled = false,
			getFunc = function() return FishermansFriend.SavedVariables.filtered[1] end,
			setFunc = function(value) FishermansFriend.SavedVariables.filtered[1] = value end
		}

		
	LAM:RegisterOptionControls(panelName, optionsData)
end


-- Lure numbers
-- 2, Guts, Lake Bait
-- 3, Crawlers, Foul Bait
-- 4, Insect Parts, River Bait
-- 5, Worms, Saltwater Bait
-- 6, Shad, River Bait
-- 7, Chub, Saltwater Bait
-- 8, Minnow, Lake Bait
-- 9, Fish Roe, Foul Bait
local function FishermansFriend_OnEffectivelyShown(interactableName, additionalInfo)
	if additionalInfo == ADDITIONAL_INTERACT_INFO_FISHING_NODE and setBait == true then -- Only try to set bait whenever we're looking at fishing hole
		if interactableName == "Lake Fishing Hole" then
			local regularBaitQuantity = FishermansFriend.GetItemQuantity(BAIT_LAKE_GUTS_ITEMID)
			local alternativeBaitQuantity = FishermansFriend.GetItemQuantity(BAIT_LAKE_MINNOW_ITEMID)
			
			if FishermansFriend.SavedVariables.filtered[1] == true then
				if alternativeBaitQuantity > 0 then
					SetFishingLure(BAIT_LAKE_MINNOW)
				else
					SetFishingLure(BAIT_LAKE_GUTS)
				end
			else 
				if regularBaitQuantity > 0 then
					SetFishingLure(BAIT_LAKE_GUTS)
				else
					SetFishingLure(BAIT_LAKE_MINNOW)
				end
			end
			
			setBait = false
		elseif interactableName == "Saltwater Fishing Hole" then
			local regularBaitQuantity = FishermansFriend.GetItemQuantity(BAIT_SALTWATER_WORMS_ITEMID)
			local alternativeBaitQuantity = FishermansFriend.GetItemQuantity(BAIT_SALTWATER_CHUB_ITEMID)
			
			if FishermansFriend.SavedVariables.filtered[1] == true then
				if alternativeBaitQuantity > 0 then
					SetFishingLure(BAIT_SALTWATER_CHUB)
				else
					SetFishingLure(BAIT_SALTWATER_WORMS)
				end
			else 
				if regularBaitQuantity > 0 then
					SetFishingLure(BAIT_SALTWATER_WORMS)
				else
					SetFishingLure(BAIT_SALTWATER_CHUB)
				end
			end
			
			setBait = false
		elseif interactableName == "Foul Fishing Hole" then
			local regularBaitQuantity = FishermansFriend.GetItemQuantity(BAIT_FOUL_CRAWLERS_ITEMID)
			local alternativeBaitQuantity = FishermansFriend.GetItemQuantity(BAIT_FOUL_ROE_ITEMID)
			
			if FishermansFriend.SavedVariables.filtered[1] == true then
				if alternativeBaitQuantity > 0 then
					SetFishingLure(BAIT_FOUL_ROE)
				else
					SetFishingLure(BAIT_FOUL_CRAWLERS)
				end
			else 
				if regularBaitQuantity > 0 then
					SetFishingLure(BAIT_FOUL_CRAWLERS)
				else
					SetFishingLure(BAIT_FOUL_ROE)
				end
			end
			
			setBait = false
		elseif interactableName == "River Fishing Hole" then
			local regularBaitQuantity = FishermansFriend.GetItemQuantity(BAIT_RIVER_INSECT_ITEMID)
			local alternativeBaitQuantity = FishermansFriend.GetItemQuantity(BAIT_RIVER_SHAD_ITEMID)
			
			if FishermansFriend.SavedVariables.filtered[1] == true then
				if alternativeBaitQuantity > 0 then
					SetFishingLure(BAIT_RIVER_SHAD)
				else
					SetFishingLure(BAIT_RIVER_INSECT)
				end
			else 
				if regularBaitQuantity > 0 then
					SetFishingLure(BAIT_RIVER_INSECT)
				else
					SetFishingLure(BAIT_RIVER_SHAD)
				end
			end
			
			setBait = false
		end
	end
end

function FishermansFriend.GetItemQuantity(itemId)
	local icon, qnt = GetItemInfo(BAG_VIRTUAL, itemId)
	local icon, qnt2 = GetItemInfo(BAG_BACKPACK, itemId)
	if HasCraftBagAccess() then return (qnt + qnt2) else return qnt2 end
end

-- Then we create an event handler function which will be called when the "addon loaded" event
-- occurs. We'll use this to initialize our addon after all of its resources are fully loaded.
function FishermansFriend.OnAddOnLoaded(event, addonName)
	-- The event fires each time *any* addon loads - but we only care about when our own addon loads.
	if addonName == FishermansFriend.name then
	FishermansFriend:Initialize()
	end
end

function ZO_Reticle:TryHandlingInteraction(interactionPossible, currentFrameTimeSeconds)
if interactionPossible then
	local action, interactableName, interactionBlocked, isOwned, additionalInteractInfo, context, contextLink, isCriminalInteract = GetGameCameraInteractableActionInfo()
	local interactKeybindButtonColor = ZO_NORMAL_TEXT
	local additionalInfoLabelColor = ZO_CONTRAST_TEXT
	self.interactKeybindButton:ShowKeyIcon()

	if action and interactableName then
		if isOwned or isCriminalInteract then
			interactKeybindButtonColor = ZO_ERROR_COLOR
		end

		if additionalInteractInfo == ADDITIONAL_INTERACT_INFO_NONE or additionalInteractInfo == ADDITIONAL_INTERACT_INFO_INSTANCE_TYPE or additionalInteractInfo == ADDITIONAL_INTERACT_INFO_HOUSE_BANK then
			self.interactKeybindButton:SetText(zo_strformat(SI_GAME_CAMERA_TARGET, action))
		elseif additionalInteractInfo == ADDITIONAL_INTERACT_INFO_EMPTY then
			self.interactKeybindButton:SetText(zo_strformat(SI_FORMAT_BULLET_TEXT, GetString(SI_GAME_CAMERA_ACTION_EMPTY)))
			self.interactKeybindButton:HideKeyIcon()
		elseif additionalInteractInfo == ADDITIONAL_INTERACT_INFO_LOCKED then
			self.interactKeybindButton:SetText(zo_strformat(SI_GAME_CAMERA_TARGET_ADDITIONAL_INFO, action, GetString("SI_LOCKQUALITY", context)))
		elseif additionalInteractInfo == ADDITIONAL_INTERACT_INFO_FISHING_NODE then
			self.additionalInfo:SetHidden(false)
			self.additionalInfo:SetText(GetString(SI_HOLD_TO_SELECT_BAIT))
			local lure = GetFishingLure()
			if lure then
				local name = GetFishingLureInfo(lure)
				self.interactKeybindButton:SetText(zo_strformat(SI_GAME_CAMERA_TARGET_ADDITIONAL_INFO_BAIT, action, name))
			else
				self.interactKeybindButton:SetText(zo_strformat(SI_GAME_CAMERA_TARGET_ADDITIONAL_INFO, action, GetString(SI_NO_BAIT_OR_LURE_SELECTED)))
				setBait = true
			end
			FishermansFriend_OnEffectivelyShown(interactableName, additionalInteractInfo)
		elseif additionalInteractInfo == ADDITIONAL_INTERACT_INFO_REQUIRES_KEY then
			local itemName = GetItemLinkName(contextLink)
			if interactionBlocked == true then
				self.interactKeybindButton:SetText(zo_strformat(SI_GAME_CAMERA_TARGET_ADDITIONAL_INFO_REQUIRES_KEY, action, itemName))
			else
				self.interactKeybindButton:SetText(zo_strformat(SI_GAME_CAMERA_TARGET_ADDITIONAL_INFO_WILL_CONSUME_KEY, action, itemName))
			end
		elseif additionalInteractInfo == ADDITIONAL_INTERACT_INFO_PICKPOCKET_CHANCE then
			local isHostile, difficulty, isEmpty, prospectiveResult, monsterSocialClassString, monsterSocialClass
			self.isInBonus, isHostile, self.percentChance, difficulty, isEmpty, prospectiveResult, monsterSocialClassString, monsterSocialClass = GetGameCameraPickpocketingBonusInfo()

			-- Prevent your success chance from going over 100%
			self.percentChance = zo_min(self.percentChance, 100)

			local additionalInfoText
			if(isEmpty and prospectiveResult == PROSPECTIVE_PICKPOCKET_RESULT_INVENTORY_FULL) then
				additionalInfoText = GetString(SI_JUSTICE_PICKPOCKET_TARGET_EMPTY)
			elseif prospectiveResult ~= PROSPECTIVE_PICKPOCKET_RESULT_CAN_ATTEMPT then
				additionalInfoText = GetString("SI_PROSPECTIVEPICKPOCKETRESULT", prospectiveResult)
			else
				additionalInfoText = isEmpty and GetString(SI_JUSTICE_PICKPOCKET_TARGET_EMPTY) or monsterSocialClassString
			end
			
			self.interactKeybindButton:SetText(zo_strformat(SI_GAME_CAMERA_TARGET_ADDITIONAL_INFO, action, additionalInfoText))
			
			interactKeybindButtonColor = ((not isHostile) and ZO_ERROR_COLOR or ZO_NORMAL_TEXT)
			
			if not interactionBlocked then
				TriggerTutorial(TUTORIAL_TRIGGER_PICKPOCKET_PROMPT_VIEWED)
				self.additionalInfo:SetHidden(false)
				additionalInfoLabelColor = (self.isInBonus and ZO_SUCCEEDED_TEXT or ZO_CONTRAST_TEXT)

				if(self.isInBonus and not self.wasInBonus) then
					self.bonusScrollTimeline:PlayForward()
					PlaySound(SOUNDS.JUSTICE_PICKPOCKET_BONUS)
					self.wasInBonus = true
				elseif(not self.isInBonus and self.wasInBonus) then
					self.bonusScrollTimeline:PlayBackward()
					self.wasInBonus = false
				elseif(not self.bonusScrollTimeline:IsPlaying()) then
					self.additionalInfo:SetText(zo_strformat(SI_PICKPOCKET_SUCCESS_CHANCE, self.percentChance))
					self.oldPercentChance = self.percentChance
				end
			else
				self.additionalInfo:SetHidden(true)
			end
		elseif additionalInteractInfo == ADDITIONAL_INTERACT_INFO_WEREWOLF_ACTIVE_WHILE_ATTEMPTING_TO_CRAFT then
			self.interactKeybindButton:SetText(zo_strformat(SI_CANNOT_CRAFT_WHILE_WEREWOLF))
		elseif additionalInteractInfo == ADDITIONAL_INTERACT_INFO_WEREWOLF_ACTIVE_WHILE_ATTEMPTING_TO_EXCAVATE then
			self.interactKeybindButton:SetText(zo_strformat(SI_CANNOT_EXCAVATE_WHILE_WEREWOLF))
		elseif additionalInteractInfo == ADDITIONAL_INTERACT_INFO_IN_HIDEYHOLE then
			self.interactKeybindButton:SetText(zo_strformat(SI_EXIT_HIDEYHOLE))
		end
		
		local interactContextString = interactableName
		if additionalInteractInfo == ADDITIONAL_INTERACT_INFO_INSTANCE_TYPE then
			local instanceType = context
			if instanceType ~= INSTANCE_DISPLAY_TYPE_NONE then 
				local instanceTypeString = zo_iconTextFormat(GetInstanceDisplayTypeIcon(instanceType), 34, 34, GetString("SI_INSTANCEDISPLAYTYPE", instanceType))
				interactContextString = zo_strformat(SI_ZONE_DOOR_RETICLE_INSTANCE_TYPE_FORMAT, interactableName, instanceTypeString)
			end
		elseif additionalInteractInfo == ADDITIONAL_INTERACT_INFO_HOUSE_BANK then
			--Don't attempt to add the collectible nickname to the prompt if it isn't our house bank
			if IsOwnerOfCurrentHouse() then
				local bankBag = context
				local collectibleId = GetCollectibleForHouseBankBag(bankBag)
				if collectibleId ~= 0 then
					local collectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(collectibleId)
					if collectibleData then
						local nickname = collectibleData:GetNickname()
						if nickname ~= "" then
							interactContextString = zo_strformat(SI_RETICLE_HOUSE_BANK_WITH_NICKNAME_FORMAT, interactableName, nickname)
						end
					end
				end
			end
		end
		self.interactContext:SetText(interactContextString)

		self.interactionBlocked = interactionBlocked
		self.interactKeybindButton:SetNormalTextColor(interactKeybindButtonColor)
		self.additionalInfo:SetColor(additionalInfoLabelColor:UnpackRGBA())  
		return true
	end
else
	setBait = true -- Reset setBait to true so next time they look at a hole it'll set it
end
end
 
-- Finally, we'll register our event handler function to be called when the proper event occurs.
EVENT_MANAGER:RegisterForEvent(FishermansFriend.name, EVENT_ADD_ON_LOADED, FishermansFriend.OnAddOnLoaded)