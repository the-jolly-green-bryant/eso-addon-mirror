-- Parts of code "borrowed" from No Interact by Rhyono

local LongPressCtrlToInteract =
 {
   Name = "LongPressCtrlToInteract",
   Author = "|c3CB371@Masteroshi430|r",
   Version = "2026.07.19",
   Defaults = 
   {
	 setKey = "CTRL",
	 noSeats = false,
	 noEmpties = false,
	 noKnownBooks = false,
	 noInsects = false,
	 companionRecall = false,
	 noInsectsWithMirri = false,
	 noCookingFires = false,
	 secondSpam = 0,
   },
   charDefaults = 
   {
	 PreferedCompanionCollectibleID = nil,
   }	 
 }

-- Cache of localized strings / lookup sets, built once instead of re-resolving
-- GetString()/GetMapNameById() every single frame inside the reticle hooks.
local Cache = {}

local function BuildCache()
	-- Actions that always get "regular" (fast-path) behavior. A set (table
	-- keyed by string) turns what used to be a 16-way OR chain of GetString()
	-- calls + string comparisons into a single O(1) table lookup.
	Cache.RegularActionSet =
	{
		[GetString(SI_GAMECAMERAACTIONTYPE3)] = true,
		[GetString(SI_GAMECAMERAACTIONTYPE4)] = true,
		[GetString(SI_GAMECAMERAACTIONTYPE8)] = true,
		[GetString(SI_GAMECAMERAACTIONTYPE9)] = true,
		[GetString(SI_GAMECAMERAACTIONTYPE11)] = true,
		[GetString(SI_GAMECAMERAACTIONTYPE12)] = true,
		[GetString(SI_GAMECAMERAACTIONTYPE16)] = true,
		[GetString(SI_GAMECAMERAACTIONTYPE17)] = true,
		[GetString(SI_GAMECAMERAACTIONTYPE18)] = true,
		[GetString(SI_GAMECAMERAACTIONTYPE19)] = true,
		[GetString(SI_GAMECAMERAACTIONTYPE20)] = true,
		[GetString(SI_GAMECAMERAACTIONTYPE21)] = true,
		[GetString(SI_GAMECAMERAACTIONTYPE23)] = true,
		[GetString(SI_GAMECAMERAACTIONTYPE24)] = true,
		[GetString(SI_GAMECAMERAACTIONTYPE25)] = true,
		[GetString(SI_GAMECAMERAACTIONTYPE26)] = true,
		[GetString(SI_GAMECAMERAACTIONTYPE27)] = true,
		[GetString(SI_GAMECAMERAACTIONTYPE5)] = true,
		[GetString(SI_GAMECAMERAACTIONTYPE7)] = true,
		[GetString(SI_GAMECAMERAACTIONTYPE13)] = true,
	}
	-- Handled separately since it also needs IsGameCameraInteractableUnitMonster()
	Cache.ActionType1 = GetString(SI_GAMECAMERAACTIONTYPE1)
	Cache.ActionType13 = GetString(SI_GAMECAMERAACTIONTYPE13) -- steal / outlaw refuge action text

	Cache.SeatText = GetString(LPCI_SEAT)
	Cache.CookingFireText = GetString(LPCI_COOKING_FIRE)
	Cache.InsectButterflyText = GetString(LPCI_INSECT_BUTTERFLY)
	Cache.InsectTorchbugText = GetString(LPCI_INSECT_TORCHBUG)
	Cache.OutlawRefugeText = GetString(SI_MONSTERSOCIALCLASS28)

	-- Static map name lookup, doesn't change during a session
	Cache.DarkBrotherhoodMapName = GetMapNameById(1063)
end

local function OnAddOnLoaded(event, addonName)
	if addonName == LongPressCtrlToInteract.Name then 
			-- Load the saved variables
    LongPressCtrlToInteract.vars = ZO_SavedVars:NewAccountWide("LongPressCtrlToInteractSavedVars", 2, nil, LongPressCtrlToInteract.Defaults)
	LongPressCtrlToInteract.CharSavedVars = ZO_SavedVars:NewCharacterIdSettings("LongPressCtrlToInteractSavedVars", 5, nil, LongPressCtrlToInteract.charDefaults)
	LongPressCtrlToInteract:Initialize()
    LongPressCtrlToInteract.CreateConfiguration()
	
	EVENT_MANAGER:UnregisterForEvent(LongPressCtrlToInteract.Name, EVENT_ADD_ON_LOADED)
	end
end



--Modified reticle hook from No, Thank You! 
local function HookReticleTake()
    LongPressCtrlToInteract.followerName = LongPressCtrlToInteract.followerName or "Norbert"
	local function DisableReticleTake_Hook(interactionPossible)
		if interactionPossible then
			local action,text,blocked,isOwned,addinfo,contextInfo,contextLink,isCriminalInteract = GetGameCameraInteractableActionInfo()


			-- do not display reticle text for empty containers KEEP FIRST
			if LongPressCtrlToInteract.vars.noEmpties and blocked and addinfo == ADDITIONAL_INTERACT_INFO_EMPTY then return true end 
			
			if text ~= '' and text ~= nil then
			   -- evaluate collectibles once instead of up to 4x below
			   local mirriActive = IsCollectibleActive(9353)
			   local isobelActive = IsCollectibleActive(9912)

			   -- alert about Mirri 1 Isobel before entering Dark Brotherhood Sanctuary
			   if (mirriActive or isobelActive) and text == Cache.DarkBrotherhoodMapName and GetTimeStamp() > LongPressCtrlToInteract.vars.secondSpam + 6 then 
				  local msg = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, nil)
	              msg:SetText(zo_strformat(GetString(LPCI_DARK1), GetUnitName("companion")), GetString(LPCI_DARK2)) 
	              msg:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_ACTIVITY_COMPLETE)
	              msg:MarkSuppressIconFrame()
				  msg:SetIconData("esoui/art/icons/mapkey/mapkey_darkbrotherhood.dds", nil)
				  msg:MarkQueueImmediately()
				  msg:SetSound(SOUNDS.DAEDRIC_ARTIFACT_SPAWNED)
				  CENTER_SCREEN_ANNOUNCE:DisplayMessage(msg)
				  LongPressCtrlToInteract.vars.secondSpam = GetTimeStamp()
				  return true
				elseif (mirriActive or isobelActive) and text == Cache.DarkBrotherhoodMapName then  
				  return true
				end
				
			   -- alert about Isobel before entering an outlaw's refuge 
			   if isobelActive and action == Cache.ActionType13 and string.find(text, Cache.OutlawRefugeText) and GetTimeStamp() > LongPressCtrlToInteract.vars.secondSpam + 6 then 
				  local msg = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, nil)
	              msg:SetText(zo_strformat(GetString(LPCI_OUTLAW1), GetUnitName("companion")), GetString(LPCI_OUTLAW2)) 
	              msg:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_ACTIVITY_COMPLETE)
	              msg:MarkSuppressIconFrame()
				  msg:SetIconData("esoui/art/icons/mapkey/mapkey_fence.dds", nil)
				  msg:MarkQueueImmediately()
				  msg:SetSound(SOUNDS.DAEDRIC_ARTIFACT_SPAWNED)
				  CENTER_SCREEN_ANNOUNCE:DisplayMessage(msg)
				  LongPressCtrlToInteract.vars.secondSpam = GetTimeStamp()
				  return true
				elseif isobelActive and action == Cache.ActionType13 and string.find(text, Cache.OutlawRefugeText) then  
				  return true
				end
				
			
				-- don't display reticle text for seats
				if LongPressCtrlToInteract.vars.noSeats and text == Cache.SeatText then return true end
				
				-- don't display reticle text for Cooking Fire not in town
				if LongPressCtrlToInteract.vars.noCookingFires and text == Cache.CookingFireText and GetMapType() ~= MAPTYPE_SUBZONE then return true end
				
				
               -- don't display reticle text for insects Mirri does't want you to kill
                if (text == Cache.InsectButterflyText or text == Cache.InsectTorchbugText) and LongPressCtrlToInteract.isNoInsectsWithMirri() then
				    return true
                end				
				
				-- don't display reticle text for all insects
				-- if LongPressCtrlToInteract.vars.noInsects and (text == GetString(LPCI_INSECT_BUTTERFLY) or text == GetString(LPCI_INSECT_TORCHBUG) or (text == GetString(LPCI_INSECT_WASP) and action == GetString(SI_GAMECAMERAACTIONTYPE7)) 
				   -- or text == GetString(LPCI_INSECT_FLESHFLIES) or text == GetString(LPCI_INSECT_DRAGONFLY) or text == GetString(LPCI_INSECT_NETCHCALF)	or text == GetString(LPCI_INSECT_FETCHERFLY) or text == GetString(LPCI_INSECT_DOVAH)
                   -- or text == GetString(LPCI_INSECT_WINTER)	or text == GetString(LPCI_INSECT_MOONS) or text == GetString(LPCI_INSECT_SWAMP_JELLY) or text == GetString(LPCI_INSECT_BLACKREACH_JELLY) or text == GetString(LPCI_INSECT_MOON_JELLY))  then
				   -- return true
				-- end
			end	
			
			if Cache.RegularActionSet[action] or (action == Cache.ActionType1 and IsGameCameraInteractableUnitMonster()) then 
			   return false -- performance Filtering: Regular behavior with -- harvest -- disarm -- destroy -- repair -- unlock -- fish -- Reel In -- Pack Up -- steal -- Steal From -- pickpocket -- trespass -- hide -- preview -- exit home -- excavate -- search (enemy corpses only)  -- use -- take -- open
			end

			if text ~= '' and text ~= nil then
			    -- do not display reticle text for companion without the Ctrl key presssed
			    if text == GetUnitName("companion") and not LongPressCtrlToInteract.isKeyDown() then return true end
			    
				-- do not display reticle text for follower without the Ctrl key pressed
				if  text == LongPressCtrlToInteract.followerName and not LongPressCtrlToInteract.isKeyDown() then return true end
				
				-- do not display reticle text for known books  if ACTIONS: -- Search -- Read --- Examine ---
				--if LongPressCtrlToInteract.vars.noKnownBooks and (action == GetString(SI_GAMECAMERAACTIONTYPE1) or action == GetString(SI_GAMECAMERAACTIONTYPE15) or action == GetString(SI_GAMECAMERAACTIONTYPE6)) and LongPressCtrlToInteract.isKnownBook(text) then return true end
				--to test : "Inspect", -- SI_GAMECAMERAACTIONTYPE10
				
			    -- should work for group companions 
				local maxGroupSize = MAX_GROUP_SIZE_THRESHOLD
			    for i=1, maxGroupSize do
						if text == GetUnitName("group"..i.."companion") and not LongPressCtrlToInteract.isKeyDown() then
							return true
						end
				end
				
			end	
		end
	    return false
	end	
	ZO_PreHook(RETICLE, "TryHandlingInteraction", DisableReticleTake_Hook)
end

-- the settings menu
function LongPressCtrlToInteract.CreateConfiguration()
	local LAM = LibAddonMenu2
	local panelData = 
	{
		type = "panel",
		name = LongPressCtrlToInteract.Name,
		author = LongPressCtrlToInteract.Author,
		version = LongPressCtrlToInteract.Version,
		registerForDefaults = true,
		registerForRefresh = true,
	}
	LAM:RegisterAddonPanel(LongPressCtrlToInteract.Name.."Config", panelData)
	
    local optionsData = {}
    optionsData[#optionsData + 1] = 
	{
	  type = "dropdown",
	  name = GetString(LPCI_LONG),
	  tooltip = GetString(LPCI_LONG_TOOLTIP_1)..ZO_Keybindings_GetBindingStringFromAction("GAME_CAMERA_INTERACT", KEYBIND_TEXT_OPTIONS_FULL_NAME, KEYBIND_TEXTURE_OPTIONS_NONE, 1)..GetString(LPCI_LONG_TOOLTIP_2),
	  choices = {"CTRL", "SHIFT", "ALT", "CMD"},
	  getFunc = function()  return LongPressCtrlToInteract.vars.setKey end, 
	  setFunc = function(NewVal) LongPressCtrlToInteract.vars.setKey = NewVal end,
	  width = "half",
	} 
    optionsData[#optionsData + 1] = 
	{
	  type = "checkbox",
	  name = GetString(LPCI_NO_SEATS),
	  tooltip = GetString(LPCI_NO_SEATS_TOOLTIP),
	  getFunc = function() return LongPressCtrlToInteract.vars.noSeats end,
      setFunc = function(NewVal) LongPressCtrlToInteract.vars.noSeats = NewVal end,
      width = "half",	--or "full" (optional)
	} 
    optionsData[#optionsData + 1] = 
	{
	  type = "checkbox",
	  name =  GetString(LPCI_NO_EMPTY),
	  tooltip = GetString(LPCI_NO_EMPTY_TOOLTIP),
	  getFunc = function() return LongPressCtrlToInteract.vars.noEmpties end,
      setFunc = function(NewVal) LongPressCtrlToInteract.vars.noEmpties = NewVal end,
      width = "half",	--or "full" (optional)
	} 	
    -- optionsData[#optionsData + 1] = 
	-- {
	  -- type = "checkbox",
	  -- name = GetString(LPCI_NO_KNOWN_BOOKS),
	  -- tooltip = GetString(LPCI_NO_KNOWN_BOOKS_TOOLTIP),
	  -- getFunc = function() return LongPressCtrlToInteract.vars.noKnownBooks end,
      -- setFunc = function(NewVal) LongPressCtrlToInteract.vars.noKnownBooks = NewVal end,
      -- width = "half",	--or "full" (optional)
	-- }
    -- optionsData[#optionsData + 1] = 
	-- {
	  -- type = "checkbox",
	  -- name = GetString(LPCI_NO_INSECTS),
	  -- tooltip = GetString(LPCI_NO_INSECTS_TOOLTIP),
	  -- getFunc = function() return LongPressCtrlToInteract.vars.noInsects end,
      -- setFunc = function(NewVal) LongPressCtrlToInteract.vars.noInsects = NewVal end,
      -- width = "half",	--or "full" (optional)
	-- }
    optionsData[#optionsData + 1] = 
	{
	  type = "checkbox",
	  name = GetString(LPCI_COMPANION_RECALL),
	  tooltip = GetString(LPCI_COMPANION_RECALL_TOOLTIP),
	  getFunc = function() return LongPressCtrlToInteract.vars.companionRecall end,
      setFunc = function(NewVal) LongPressCtrlToInteract.vars.companionRecall = NewVal end,
      width = "half",	--or "full" (optional)
	}
    optionsData[#optionsData + 1] = 
	{
	  type = "checkbox",
	  name = GetString(LPCI_NO_INSECTS_WITH_MIRRI),
	  tooltip = GetString(LPCI_NO_INSECTS_WITH_MIRRI_TOOLTIP),
	  getFunc = function() return LongPressCtrlToInteract.vars.noInsectsWithMirri end,
      setFunc = function(NewVal) LongPressCtrlToInteract.vars.noInsectsWithMirri = NewVal end,
      width = "half",	--or "full" (optional)
	}
    optionsData[#optionsData + 1] = 
	{
	  type = "checkbox",
	  name = GetString(LPCI_NO_COOKING_FIRES),
	  tooltip = GetString(LPCI_NO_COOKING_FIRES_TOOLTIP),
	  getFunc = function() return LongPressCtrlToInteract.vars.noCookingFires end,
      setFunc = function(NewVal) LongPressCtrlToInteract.vars.noCookingFires = NewVal end,
      width = "half",	--or "full" (optional)
	}
	LAM:RegisterOptionControls(LongPressCtrlToInteract.Name.."Config", optionsData)
end

-- is the key down?
function LongPressCtrlToInteract.isKeyDown()
    -- setKey always comes from a fixed-choice dropdown ("CTRL","SHIFT","ALT","CMD"),
    -- so it's already uppercase; no need to call string.upper() on every check.
    local key = LongPressCtrlToInteract.vars.setKey
	if  key == "CTRL" then return IsControlKeyDown()
	elseif  key == "SHIFT" then return IsShiftKeyDown()
	elseif  key == "ALT" then return IsAltKeyDown()
	elseif  key == "CMD" then return IsCommandKeyDown()
	end
end

-- is the future interaction a known book?
-- function LongPressCtrlToInteract.isKnownBook(thisTitle) 
	-- for index = 1, #LongPressCtrlToInteract.knownBookTitles do
	     -- local bookTitle = LongPressCtrlToInteract.knownBookTitles[index]
		 -- if thisTitle == bookTitle then
			-- return true
		-- else 
			-- local toSplit = LongPressCtrlToInteract.mysplit(thisTitle, ":")
			-- if toSplit[2] then
			   -- toSplit[2] = toSplit[2]:sub(2)
			   -- if toSplit[2] == bookTitle then return true end	-- workaround for "Note: A Way Out" type titles
			-- end	
		-- end
	-- end
    -- return false
-- end	

-- populate list of known book titles at load 
-- function LongPressCtrlToInteract.PopulateKnownLorebooksAtStart()
    -- LongPressCtrlToInteract.knownBookTitles = {}
    -- for categoryIndex = 1, GetNumLoreCategories() do
        -- local categoryName, numCollections = GetLoreCategoryInfo(categoryIndex)
        -- for collectionIndex = 1, numCollections do
            -- local collectionName, description, numKnownBooks, totalBooks, hidden = GetLoreCollectionInfo(categoryIndex, collectionIndex)
            -- if not hidden then
                -- for bookIndex = 1, totalBooks do
                    -- local title, icon, known = GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex)
                    -- if  known then
                       -- table.insert(LongPressCtrlToInteract.knownBookTitles, title)
                    -- end
                -- end
            -- end
        -- end
    -- end
-- end

-- populate list of known book titles at book learned 
-- function LongPressCtrlToInteract.LorebookLearned(categoryIndex, collectionIndex,  bookIndex)
   -- local title, icon, known = GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex)
   -- table.insert(LongPressCtrlToInteract.knownBookTitles, title)
-- end 

-- string splitter
function LongPressCtrlToInteract.mysplit(inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end

-- Call last companion after combat
function LongPressCtrlToInteract.CallPreferedAssistant()
    if not LongPressCtrlToInteract.vars.companionRecall then return end
	
	if HasActiveCompanion() == true then 
	   local activeCompanionCollectibleID = GetCompanionCollectibleId(GetActiveCompanionDefId())
	   if IsCollectibleActive(activeCompanionCollectibleID) then 
		    LongPressCtrlToInteract.CharSavedVars.PreferedCompanionCollectibleID = activeCompanionCollectibleID
	      return
	   end
  end

	if IsUnitInCombat("player") or GetGroupSize() > 1 or IsInstanceEndlessDungeon() then return end

	if LongPressCtrlToInteract.CharSavedVars.PreferedCompanionCollectibleID and HasActiveCompanion() == false and not IsInAvAZone() and not IsCollectibleBlocked(LongPressCtrlToInteract.CharSavedVars.PreferedCompanionCollectibleID,GAMEPLAY_ACTOR_CATEGORY_COMPANION) and not HasPendingCompanion() and not HasBlockedCompanion() then
     zo_callLater(function()  UseCollectible(LongPressCtrlToInteract.CharSavedVars.PreferedCompanionCollectibleID) end, 5000)
  end
end

-- do we stop interaction with insects when Mirri is active
function LongPressCtrlToInteract.isNoInsectsWithMirri()
   if LongPressCtrlToInteract.vars.noInsectsWithMirri == false then return false end
   
   if HasActiveCompanion() == true then 
	   if IsCollectibleActive(9353) then return true end -- MIRRI ELENDIS
   end
   return false
end

-- init
function LongPressCtrlToInteract.Initialize()
	BuildCache()
	EVENT_MANAGER:UnregisterForEvent(LongPressCtrlToInteract.Name, EVENT_ADD_ON_LOADED)
	EVENT_MANAGER:RegisterForEvent(LongPressCtrlToInteract.Name, EVENT_CHATTER_BEGIN,LongPressCtrlToInteract.GetThatFollowerName)
	--EVENT_MANAGER:RegisterForEvent(LongPressCtrlToInteract.Name, EVENT_LORE_BOOK_LEARNED,LongPressCtrlToInteract.LorebookLearned) 

	-- combat state
	EVENT_MANAGER:RegisterForEvent(LongPressCtrlToInteract.Name, EVENT_PLAYER_COMBAT_STATE, LongPressCtrlToInteract.CallPreferedAssistant)
	
	--LongPressCtrlToInteract.PopulateKnownLorebooksAtStart()
	HookReticleTake()
end

--- Get follower name from 1st interaction
function LongPressCtrlToInteract.GetThatFollowerName()
    if IsInteractingWithMyAssistant() or IsUnitFriendlyFollower("interact") == false or GetUnitName("interact") == nil or GetUnitName("interact") == "" or GetUnitName("interact") == GetUnitName("companion")then return end
    LongPressCtrlToInteract.followerName = GetUnitName("interact") 
end

--Stops interaction
local WHEEL_MANAGER = INTERACTIVE_WHEEL_MANAGER
local orgInteract = WHEEL_MANAGER.StartInteraction
    WHEEL_MANAGER.StartInteraction = function(...)
	local action,text,blocked,isOwned,addinfo,contextInfo,contextLink,isCriminalInteract = GetGameCameraInteractableActionInfo()

	-- -- 500ms cooldown to avoid double tap/click
	-- if LongPressCtrlToInteract.LastStartInterraction and GetFrameTimeMilliseconds() < LongPressCtrlToInteract.LastStartInterraction + 500 then
	   -- return true
	-- end
	-- LongPressCtrlToInteract.LastStartInterraction = GetFrameTimeMilliseconds()
	
	-- exclude nil or blank text
	if text == nil or text == '' then return orgInteract(...) end   
    
	local key = LongPressCtrlToInteract.vars.setKey
	
    -- do not interact with empty containers KEEP FIRST
	if LongPressCtrlToInteract.vars.noEmpties and blocked and addinfo == ADDITIONAL_INTERACT_INFO_EMPTY then return true end 
	
	-- evaluate collectibles once instead of up to 3x below
	local mirriActive = IsCollectibleActive(9353)
	local isobelActive = IsCollectibleActive(9912)

	-- Mirri and Isobel : disallow entering Dark Brotherhood Sanctuary 
   if (mirriActive or isobelActive) and text == Cache.DarkBrotherhoodMapName then
       return true
   end

	-- Isobel : disallow entering an outlaw's refuge 
   if isobelActive and action == Cache.ActionType13 and string.find(text, Cache.OutlawRefugeText) then
       return true
   end     

   
	
	-- do not interact with seats
	if LongPressCtrlToInteract.vars.noSeats and text == Cache.SeatText then return true end
	
	-- do not interact with Cooking Fire not in town 
	if LongPressCtrlToInteract.vars.noCookingFires and text == Cache.CookingFireText and GetMapType() ~= MAPTYPE_SUBZONE then return true end
		
	   -- do not interact with insects Mirri does't want you to kill
		if (text == Cache.InsectButterflyText or text == Cache.InsectTorchbugText) and LongPressCtrlToInteract.isNoInsectsWithMirri() then
			return true
		end				
		
		-- do not interact with insects
		-- if LongPressCtrlToInteract.vars.noInsects and (text == GetString(LPCI_INSECT_BUTTERFLY) or text == GetString(LPCI_INSECT_TORCHBUG) or (text == GetString(LPCI_INSECT_WASP) and action == GetString(SI_GAMECAMERAACTIONTYPE7)) 
		   -- or text == GetString(LPCI_INSECT_FLESHFLIES) or text == GetString(LPCI_INSECT_DRAGONFLY) or text == GetString(LPCI_INSECT_NETCHCALF)	or text == GetString(LPCI_INSECT_FETCHERFLY) or text == GetString(LPCI_INSECT_DOVAH)
		   -- or text == GetString(LPCI_INSECT_WINTER)	or text == GetString(LPCI_INSECT_MOONS) or text == GetString(LPCI_INSECT_SWAMP_JELLY) or text == GetString(LPCI_INSECT_BLACKREACH_JELLY) or text == GetString(LPCI_INSECT_MOON_JELLY))  then
		   -- return true
		-- end
	
	if Cache.RegularActionSet[action] or (action == Cache.ActionType1 and IsGameCameraInteractableUnitMonster()) then 
	   return orgInteract(...)  -- performance Filtering: Regular behavior with -- harvest -- disarm -- destroy -- repair -- unlock -- fish -- Reel In -- Pack Up -- steal -- Steal From -- pickpocket -- trespass -- hide -- preview -- exit home -- excavate -- search (enemy corpses only)  -- use -- take -- open
	end	
	
	-- Only resolve the keybind display string once we actually know we need
	-- it for a chat message, instead of on every single interaction attempt.
	local keyString

	 -- chat message if you try to interact with companion without the Ctrl key
	 if text == GetUnitName("companion") and not LongPressCtrlToInteract.isKeyDown() then 
		 keyString = ZO_Keybindings_GetBindingStringFromAction("GAME_CAMERA_INTERACT", KEYBIND_TEXT_OPTIONS_FULL_NAME, KEYBIND_TEXTURE_OPTIONS_NONE, 1)
		 CHAT_SYSTEM:AddMessage("|c666666"..GetString(LPCI_PRESS).."|r |cC3C09C"..key.."+"..keyString.."|r |c666666"..GetString(LPCI_TO_INTERACT_WITH).."|r|c9DFE00"..zo_iconTextFormatNoSpace("esoui/art/compass/activecompanion.dds",20,20,"")..text..".|r")
		 return true
	 end
	
	 -- chat message if you try to interact with follower without the Ctrl key 
	 if text == LongPressCtrlToInteract.followerName and not LongPressCtrlToInteract.isKeyDown() then 
		 keyString = ZO_Keybindings_GetBindingStringFromAction("GAME_CAMERA_INTERACT", KEYBIND_TEXT_OPTIONS_FULL_NAME, KEYBIND_TEXTURE_OPTIONS_NONE, 1)
		 CHAT_SYSTEM:AddMessage("|c666666"..GetString(LPCI_PRESS).."|r |cC3C09C"..key.."+"..keyString.."|r |c666666"..GetString(LPCI_TO_INTERACT_WITH).."|r|c9DFE00"..zo_iconTextFormatNoSpace("LongPressCtrlToInteract/art/icons/follower_32.dds",16,16,"")..text..".|r") 
		 return true
	 end
	 
	-- should work for group companions
	local maxGroupSize = MAX_GROUP_SIZE_THRESHOLD
	for i=1, maxGroupSize do 
	    if text == GetUnitName("group"..i.."companion") and not LongPressCtrlToInteract.isKeyDown() then   
			keyString = keyString or ZO_Keybindings_GetBindingStringFromAction("GAME_CAMERA_INTERACT", KEYBIND_TEXT_OPTIONS_FULL_NAME, KEYBIND_TEXTURE_OPTIONS_NONE, 1)
			CHAT_SYSTEM:AddMessage("|c666666"..GetString(LPCI_PRESS).."|r |cC3C09C"..key.."+"..keyString.."|r |c666666"..GetString(LPCI_TO_INTERACT_WITH).."|r|c9DFE00"..zo_iconTextFormatNoSpace("esoui/art/compass/activecompanion.dds",20,20,"")..text..".|r")
		    return true
        end
	end
	
		-- do not interact with known books  if ACTIONS: -- Search -- Read --- Examine ---
	--if LongPressCtrlToInteract.vars.noKnownBooks and (action == GetString(SI_GAMECAMERAACTIONTYPE1) or action == GetString(SI_GAMECAMERAACTIONTYPE15) or action == GetString(SI_GAMECAMERAACTIONTYPE6)) and LongPressCtrlToInteract.isKnownBook(text) then return true end
	
	return orgInteract(...)
end



EVENT_MANAGER:RegisterForEvent(LongPressCtrlToInteract.Name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

