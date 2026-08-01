VersesAndVisions = {}
VersesAndVisions.name = "VersesAndVisions"

function VersesAndVisions.updateBuffStacks(buffType, abilityId, stackCount)
    VersesAndVisions.buffStacks = VersesAndVisions.buffStacks or {}
	
	local name = GetAbilityName(abilityId)
	local icon = GetAbilityIcon(abilityId)
	local description = GetAbilityDescription(abilityId)
	local _, isAvatarVision = GetAbilityEndlessDungeonBuffType(abilityId)
	local buffTypeName = GetString("SI_ENDLESSDUNGEONBUFFTYPE", buffType)
	local avatarVisionSetIcon = VersesAndVisions.GetAvatarVisionSetIcon(abilityId)
	
	
	isAvatarVision = true
	
	local buffinfo = {
	                  name = name,
					  icon = icon,
					  description = description,
					  isAvatarVision = isAvatarVision,
	                  buffTypeName = buffTypeName,
					  stackCount = stackCount,
					  buffType = buffType,
					  abilityId = abilityId,
					  avatarVisionSetIcon = avatarVisionSetIcon,
	                 }

    if buffType == ENDLESS_DUNGEON_BUFF_TYPE_VERSE then
	       VersesAndVisions.buffStacks[ENDLESS_DUNGEON_BUFF_TYPE_VERSE] = VersesAndVisions.buffStacks[ENDLESS_DUNGEON_BUFF_TYPE_VERSE] or {}
		   
		   if stackCount == 0 then 
		      if VersesAndVisions.buffStacks[ENDLESS_DUNGEON_BUFF_TYPE_VERSE][abilityId] then
			      VersesAndVisions.buffStacks[ENDLESS_DUNGEON_BUFF_TYPE_VERSE][abilityId] = nil
				  if VersesAndVisions.buffIcon[abilityId] then
				     VersesAndVisions.buffIcon[abilityId]:SetHidden(true)
					 if VersesAndVisions.stackText[abilityId] then
					     VersesAndVisions.stackText[abilityId]:SetHidden(true)
						 VersesAndVisions.stackText[abilityId] = nil
					 end
				     VersesAndVisions.buffIcon[abilityId] = nil
				  end
				  if VersesAndVisions.buffHighlightIcon[abilityId] then
				     VersesAndVisions.buffHighlightIcon[abilityId]:SetHidden(true)
				     VersesAndVisions.buffHighlightIcon[abilityId] = nil
				  end
				  
				  
			  end  
		    else	
                 VersesAndVisions.buffStacks[ENDLESS_DUNGEON_BUFF_TYPE_VERSE][abilityId] = buffinfo 
		   end
		   
	elseif buffType == ENDLESS_DUNGEON_BUFF_TYPE_VISION then
	       VersesAndVisions.buffStacks[ENDLESS_DUNGEON_BUFF_TYPE_VISION] = VersesAndVisions.buffStacks[ENDLESS_DUNGEON_BUFF_TYPE_VISION] or {}
		   	
			if stackCount == 0 then 
		      if VersesAndVisions.buffStacks[ENDLESS_DUNGEON_BUFF_TYPE_VISION][abilityId] then
			      VersesAndVisions.buffStacks[ENDLESS_DUNGEON_BUFF_TYPE_VISION][abilityId] = nil
				  if VersesAndVisions.buffIcon[abilityId] then
				     VersesAndVisions.buffIcon[abilityId]:SetHidden(true)
					 if VersesAndVisions.stackText[abilityId] then
					     VersesAndVisions.stackText[abilityId]:SetHidden(true)
						 VersesAndVisions.stackText[abilityId] = nil
					 end
				     VersesAndVisions.buffIcon[abilityId] = nil
				  end
				  if VersesAndVisions.buffHighlightIcon[abilityId] then
				     VersesAndVisions.buffHighlightIcon[abilityId]:SetHidden(true)
				     VersesAndVisions.buffHighlightIcon[abilityId] = nil
				  end
				  if VersesAndVisions.avatarIcon[abilityId] then
				     VersesAndVisions.avatarIcon[abilityId]:SetHidden(true) 
					 VersesAndVisions.avatarIcon[abilityId] = nil
				  end 
			  end
            else 
                VersesAndVisions.buffStacks[ENDLESS_DUNGEON_BUFF_TYPE_VISION][abilityId] = buffinfo  
		   end
    end
	
		
	local emptyVerses = true
	
	if VersesAndVisions.buffStacks[ENDLESS_DUNGEON_BUFF_TYPE_VERSE] and not ZO_IsTableEmpty(VersesAndVisions.buffStacks[ENDLESS_DUNGEON_BUFF_TYPE_VERSE]) then
	   emptyVerses = false
    end	
	
	
	local emptyVisions = true
	
	if VersesAndVisions.buffStacks[ENDLESS_DUNGEON_BUFF_TYPE_VISION] and not ZO_IsTableEmpty(VersesAndVisions.buffStacks[ENDLESS_DUNGEON_BUFF_TYPE_VISION]) then
	   emptyVisions = false
    end
	
	
	local infiniteArchiveTracker = ZO_EndDunHUDTracker
	
	if LUIE then -- compatibility with LUI extended
	    infiniteArchiveTracker = ZO_EndDunHUDTrackerContainer
	end
	
	if Azurah then -- compatibility with Azurah
	    infiniteArchiveTracker = ZO_EndDunHUDTracker
	end
	
	local topLeft = TOPLEFT
    local bottomLeft = BOTTOMLEFT
	local gamepadXoffset = 0
	local gamepadYoffset = 0
	local fontSize = 18
	local font = "$(BOLD_FONT)"
	
	
	if IsInGamepadPreferredMode() then
	    topLeft = TOPRIGHT
        bottomLeft = BOTTOMRIGHT
		gamepadXoffset = -20
		gamepadYoffset = -40
		fontSize = "$(GP_34)"
		font = "$(GAMEPAD_MEDIUM_FONT)" 
	end

	VersesAndVisions.main = VersesAndVisions.main or WINDOW_MANAGER:CreateTopLevelWindow(nil)
	VersesAndVisions.main:ClearAnchors()
	VersesAndVisions.main:SetAnchor(topLeft, infiniteArchiveTracker, bottomLeft, gamepadXoffset, gamepadYoffset) 
	VersesAndVisions.main:SetDimensions(10,10)
	VersesAndVisions.main:SetDrawLayer(1)
	VersesAndVisions.main:SetResizeToFitDescendents(true)
	VersesAndVisions.main:SetAlpha(1)
	
    VersesAndVisions.verseTitle = VersesAndVisions.verseTitle or WINDOW_MANAGER:CreateControl(nil, VersesAndVisions.main, CT_LABEL)
	VersesAndVisions.verseTitle:ClearAnchors()
	VersesAndVisions.verseTitle:SetHidden(emptyVerses)
	VersesAndVisions.verseTitle:SetFont(font .. "|" .. fontSize .. "|" ..  "soft-shadow-thin")
	VersesAndVisions.verseTitle:SetText(GetString(SI_ENDLESS_DUNGEON_SUMMARY_VERSES_HEADER))
	VersesAndVisions.verseTitle:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
	VersesAndVisions.verseTitle:ClearAnchors()
	VersesAndVisions.verseTitle:SetAnchor(topLeft, VersesAndVisions.main, topLeft, 0, -15)

	
	local visionParent = VersesAndVisions.main
	local Yoffset = 15
	local verseCounter = 1
	-- Draw all the verses
	if not emptyVerses then
		for key, value in pairs(VersesAndVisions.buffStacks[ENDLESS_DUNGEON_BUFF_TYPE_VERSE]) do
		    local maybeVisionParent, realDeal = VersesAndVisions.drawThatbuffIcon(value, VersesAndVisions.verseTitle, verseCounter)
			if realDeal then 
			   visionParent = maybeVisionParent 
			end
			Yoffset = 33
			verseCounter = verseCounter + 1
		end
	end
	

	
	VersesAndVisions.visionTitle = VersesAndVisions.visionTitle or WINDOW_MANAGER:CreateControl(nil, VersesAndVisions.main, CT_LABEL)
	VersesAndVisions.visionTitle:ClearAnchors()
	VersesAndVisions.visionTitle:SetHidden(emptyVisions)
	VersesAndVisions.visionTitle:SetFont(font .. "|" .. fontSize .. "|" ..  "soft-shadow-thin")
	VersesAndVisions.visionTitle:SetText(GetString(SI_ENDLESS_DUNGEON_SUMMARY_VISIONS_HEADER))
	VersesAndVisions.visionTitle:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
	VersesAndVisions.visionTitle:ClearAnchors()
	VersesAndVisions.visionTitle:SetAnchor(topLeft, visionParent, topLeft, 0, Yoffset)
	
	
	local visionCounter = 1
	-- Draw all the visions
	if not emptyVisions then
		for key, value in pairs(VersesAndVisions.buffStacks[ENDLESS_DUNGEON_BUFF_TYPE_VISION]) do
			
		    local maybeVerseParent, realDeal = VersesAndVisions.drawThatbuffIcon(value, VersesAndVisions.visionTitle, visionCounter)
			if realDeal then 
			   visionParent = maybeVerseParent 
			end
			Yoffset = 33
			visionCounter = visionCounter + 1
		end
	end
	
	
    local offensive = GetItemLinkInventoryCount("|H0:item:203611:370:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", INVENTORY_COUNT_BAG_OPTION_BACKPACK)
    local defensive = GetItemLinkInventoryCount("|H0:item:203612:370:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", INVENTORY_COUNT_BAG_OPTION_BACKPACK)
    local utility = GetItemLinkInventoryCount("|H0:item:203613:370:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", INVENTORY_COUNT_BAG_OPTION_BACKPACK)
    local tranformation = GetItemLinkInventoryCount("|H0:item:208359:370:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", INVENTORY_COUNT_BAG_OPTION_BACKPACK)
	
	local noVerseInInventory = (offensive + defensive + utility + tranformation) == 0
	
	VersesAndVisions.inventoryTitle = VersesAndVisions.inventoryTitle or WINDOW_MANAGER:CreateControl(nil, VersesAndVisions.main, CT_LABEL)
	VersesAndVisions.inventoryTitle:ClearAnchors()
	VersesAndVisions.inventoryTitle:SetHidden(noVerseInInventory)
	VersesAndVisions.inventoryTitle:SetFont(font .. "|" .. fontSize .. "|" ..  "soft-shadow-thin")
	VersesAndVisions.inventoryTitle:SetText(GetString(SI_SCRIBING_FILTER_USABLE))
	VersesAndVisions.inventoryTitle:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
	VersesAndVisions.inventoryTitle:ClearAnchors()
	VersesAndVisions.inventoryTitle:SetAnchor(topLeft, visionParent, topLeft, 0, Yoffset)
	
	local inventoryVerseText = ""
	
	if offensive > 0 then 
	   local icon = GetItemLinkIcon("|H0:item:203611:370:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")
	   local number = ""
	   if offensive > 1 then
	       number = "x"..offensive
	   end
	   inventoryVerseText = zo_iconFormat(icon, 32, 32)..number
	end
	
	if defensive > 0 then 
	   local icon = GetItemLinkIcon("|H0:item:203612:370:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")
	   local number = ""
	   if defensive > 1 then
	       number = "x"..defensive
	   end
	   inventoryVerseText = inventoryVerseText.." "..zo_iconFormat(icon, 32, 32)..number
	end
	
	if utility > 0 then 
	   local icon = GetItemLinkIcon("|H0:item:203613:370:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")
	   local number = ""
	   if utility > 1 then
	       number = "x"..utility
	   end
	   inventoryVerseText = inventoryVerseText.." "..zo_iconFormat(icon, 32, 32)..number
	end
	
	if tranformation > 0 then 
	   local icon = GetItemLinkIcon("|H0:item:208359:370:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")
	   local number = ""
	   if tranformation > 1 then
	       number = "x"..tranformation
	   end
	   inventoryVerseText = inventoryVerseText.." "..zo_iconFormat(icon, 32, 32)..number
	end
	
	Yoffset = 33
	
	VersesAndVisions.inventoryText = VersesAndVisions.inventoryText or WINDOW_MANAGER:CreateControl(nil, VersesAndVisions.main, CT_LABEL)
	VersesAndVisions.inventoryText:ClearAnchors()
	VersesAndVisions.inventoryText:SetHidden(noVerseInInventory)
	VersesAndVisions.inventoryText:SetFont(font .. "|" .. fontSize .. "|" ..  "soft-shadow-thin")
	VersesAndVisions.inventoryText:SetText(inventoryVerseText)
	VersesAndVisions.inventoryText:SetColor(ZO_WHITE:UnpackRGBA())
	VersesAndVisions.inventoryText:ClearAnchors()
	VersesAndVisions.inventoryText:SetAnchor(topLeft, VersesAndVisions.inventoryTitle, topLeft, 0, Yoffset) 

	
	if not noVerseInInventory then
	     visionParent = VersesAndVisions.inventoryText
	end
	
	-- moves default quest tracker under this addon UI
	if IsInGamepadPreferredMode() then
	    ZO_FocusedQuestTrackerPanel:SetAnchor(TOPRIGHT, visionParent, BOTTOMRIGHT, math.abs(gamepadXoffset), 0)
	else
	    ZO_FocusedQuestTrackerPanel:SetAnchor(TOPLEFT, visionParent, BOTTOMLEFT, -50, 0)
	end
	
end


function VersesAndVisions.drawThatbuffIcon(buffinfo, parent, counter)

     local offsetX, offsetY = VersesAndVisions.CalculateOffsets(counter) 
	 
	 local topLeft = TOPLEFT
	 local font = "$(BOLD_FONT)"
	 local fontSize = "16"
	
	
	 if IsInGamepadPreferredMode() then
	    topLeft = TOPRIGHT
		font = "$(GAMEPAD_MEDIUM_FONT)"
		fontSize = "24"
	 end

	 
     VersesAndVisions.buffIcon = VersesAndVisions.buffIcon or {}
     VersesAndVisions.buffIcon[buffinfo.abilityId] = VersesAndVisions.buffIcon[buffinfo.abilityId] or WINDOW_MANAGER:CreateControl(nil, VersesAndVisions.main, CT_TEXTURE)
     VersesAndVisions.buffIcon[buffinfo.abilityId]:ClearAnchors() 
     VersesAndVisions.buffIcon[buffinfo.abilityId]:SetTexture(buffinfo.icon)
	 VersesAndVisions.buffIcon[buffinfo.abilityId]:SetDimensions(32,32)
	 VersesAndVisions.buffIcon[buffinfo.abilityId]:SetHidden(false)
     VersesAndVisions.buffIcon[buffinfo.abilityId]:SetAnchor(topLeft, parent, topLeft, 0 + offsetX , 22 + offsetY)
	 
	 
	 
	if buffinfo.isAvatarVision and buffinfo.avatarVisionSetIcon ~= "" then
		 VersesAndVisions.avatarIcon = VersesAndVisions.avatarIcon or {}
		 VersesAndVisions.avatarIcon[buffinfo.abilityId] = VersesAndVisions.avatarIcon[buffinfo.abilityId] or WINDOW_MANAGER:CreateControl(nil, VersesAndVisions.main, CT_TEXTURE)
		 VersesAndVisions.avatarIcon[buffinfo.abilityId]:ClearAnchors() 
		 VersesAndVisions.avatarIcon[buffinfo.abilityId]:SetTexture(buffinfo.avatarVisionSetIcon)
		 VersesAndVisions.avatarIcon[buffinfo.abilityId]:SetDimensions(16,16)
		 VersesAndVisions.avatarIcon[buffinfo.abilityId]:SetHidden(false)
		 VersesAndVisions.avatarIcon[buffinfo.abilityId]:SetAnchor(topLeft, VersesAndVisions.buffIcon[buffinfo.abilityId], CENTER , 4 , 4)
	end 
	 
	 
	 
	 VersesAndVisions.buffHighlightIcon = VersesAndVisions.buffHighlightIcon or {}
     VersesAndVisions.buffHighlightIcon[buffinfo.abilityId] = VersesAndVisions.buffHighlightIcon[buffinfo.abilityId] or WINDOW_MANAGER:CreateControl(nil, VersesAndVisions.main, CT_TEXTURE)
     VersesAndVisions.buffHighlightIcon[buffinfo.abilityId]:ClearAnchors() 
     VersesAndVisions.buffHighlightIcon[buffinfo.abilityId]:SetTexture(buffinfo.icon)
	 VersesAndVisions.buffHighlightIcon[buffinfo.abilityId]:SetDimensions(32,32)
     VersesAndVisions.buffHighlightIcon[buffinfo.abilityId]:SetColor(ZO_ColorDef:New(0,0,0):UnpackRGBA())
	 VersesAndVisions.buffHighlightIcon[buffinfo.abilityId]:SetAlpha(0)
	 VersesAndVisions.buffHighlightIcon[buffinfo.abilityId]:SetHidden(false)
     VersesAndVisions.buffHighlightIcon[buffinfo.abilityId]:SetAnchor(topLeft, parent, topLeft, 0 + offsetX , 22 + offsetY)
	 
	 VersesAndVisions.stackText = VersesAndVisions.stackText or {}
	 
	 if buffinfo.stackCount > 1 then
		  VersesAndVisions.stackText[buffinfo.abilityId] = VersesAndVisions.stackText[buffinfo.abilityId] or WINDOW_MANAGER:CreateControl(nil, VersesAndVisions.main, CT_LABEL)
		  VersesAndVisions.stackText[buffinfo.abilityId]:ClearAnchors()
          VersesAndVisions.stackText[buffinfo.abilityId]:SetHidden(false)
		  VersesAndVisions.stackText[buffinfo.abilityId]:SetFont("$(BOLD_FONT)" .. "|" .. fontSize .. "|" ..  "thick-outline")
		  VersesAndVisions.stackText[buffinfo.abilityId]:SetText(buffinfo.stackCount)
		  VersesAndVisions.stackText[buffinfo.abilityId]:SetColor(ZO_WHITE:UnpackRGBA())
		  VersesAndVisions.stackText[buffinfo.abilityId]:ClearAnchors()
		  VersesAndVisions.stackText[buffinfo.abilityId]:SetAnchor(topLeft, VersesAndVisions.buffIcon[buffinfo.abilityId], CENTER , 4 , -8)
	 else
	     if VersesAndVisions.stackText[buffinfo.abilityId] then
		     VersesAndVisions.stackText[buffinfo.abilityId]:SetHidden(true)
		     VersesAndVisions.stackText[buffinfo.abilityId] = nil
		 end
	 end
	 
	 
	 local realDeal = false
	 if offsetX == 0 then
	    realDeal = true 
	 end

	 VersesAndVisions.buffHighlightIcon[buffinfo.abilityId]:SetMouseEnabled(true)
	 VersesAndVisions.buffHighlightIcon[buffinfo.abilityId]:SetHandler("OnMouseEnter", function() VersesAndVisions.HighlightIsOn = true VersesAndVisions.HighlightOn(buffinfo.abilityId) InitializeTooltip(AbilityIconTooltip, VersesAndVisions.buffIcon[buffinfo.abilityId], TOP, 0, 15, BOTTOM) AbilityIconTooltip:SetEndlessDungeonBuff(buffinfo.abilityId, true)  end )
     VersesAndVisions.buffHighlightIcon[buffinfo.abilityId]:SetHandler("OnMouseExit", function() VersesAndVisions.HighlightIsOn = false VersesAndVisions.HighlightOff(buffinfo.abilityId) ClearTooltip(AbilityIconTooltip) end)
	 
	 return VersesAndVisions.buffIcon[buffinfo.abilityId], realDeal
end


function VersesAndVisions.CalculateOffsets(counter)
   local columns = 5

   local vRow = counter
   local line = 0

   while(vRow > columns) do
       vRow = vRow - columns
       line = line + 1
   end
 
   vRow = vRow - 1
   local offsetX = vRow * 35
   local offsetY = line * 30
   
   if IsInGamepadPreferredMode() then
       offsetX = vRow * -35
	   if line == 0 then
	      offsetY = 15
	   end
   end

   return offsetX, offsetY  
end


function VersesAndVisions.GetAvatarVisionSetIcon(abilityId)
    local _, isAvatarVision = GetAbilityEndlessDungeonBuffType(abilityId)
	
	if isAvatarVision then
	     if abilityId == 199997 or abilityId == 200494 or abilityId == 202510 then
		    return GetAbilityIcon(202134)
	     elseif abilityId == 200004 or abilityId == 200679 or abilityId == 202804 then
		    return GetAbilityIcon(196020)
	     elseif abilityId == 199990 or abilityId == 200421 or abilityId == 202743 then
		    return GetAbilityIcon(191802)
	     elseif abilityId == 220557 or abilityId == 220563 or abilityId == 220568 then
		    return GetAbilityIcon(220189)
         else
             return ""		 
		 end
	else
	    return ""
    end
end


function VersesAndVisions.wipe()

    if VersesAndVisions.buffStacks and VersesAndVisions.buffStacks[ENDLESS_DUNGEON_BUFF_TYPE_VERSE] then
	
		for key, value in pairs(VersesAndVisions.buffStacks[ENDLESS_DUNGEON_BUFF_TYPE_VERSE]) do
			 if VersesAndVisions.buffIcon[key] then
				 VersesAndVisions.buffIcon[key]:SetHidden(true)
				 if VersesAndVisions.stackText[key] then
					 VersesAndVisions.stackText[key]:SetHidden(true)
					 VersesAndVisions.stackText[key] = nil
				 end
				 VersesAndVisions.buffIcon[key] = nil
			 end
			 if VersesAndVisions.buffHighlightIcon[key] then
				 VersesAndVisions.buffHighlightIcon[key]:SetHidden(true)
				 VersesAndVisions.buffHighlightIcon[key] = nil
			 end
		end
	    VersesAndVisions.verseTitle:SetHidden(true)
	end 


    if VersesAndVisions.buffStacks and VersesAndVisions.buffStacks[ENDLESS_DUNGEON_BUFF_TYPE_VISION] then
	
		for key, value in pairs(VersesAndVisions.buffStacks[ENDLESS_DUNGEON_BUFF_TYPE_VISION]) do
			 if VersesAndVisions.buffIcon[key] then
				 VersesAndVisions.buffIcon[key]:SetHidden(true)
				 if VersesAndVisions.stackText and VersesAndVisions.stackText[key] then
					 VersesAndVisions.stackText[key]:SetHidden(true)
					 VersesAndVisions.stackText[key] = nil
				 end
				 VersesAndVisions.buffIcon[key] = nil
			 end
			 if VersesAndVisions.buffHighlightIcon and VersesAndVisions.buffHighlightIcon[key] then
				 VersesAndVisions.buffHighlightIcon[key]:SetHidden(true)
				 VersesAndVisions.buffHighlightIcon[key] = nil
			 end
			 if VersesAndVisions.avatarIcon and VersesAndVisions.avatarIcon[key] then
			    VersesAndVisions.avatarIcon[key]:SetHidden(true) 
			    VersesAndVisions.avatarIcon[key] = nil
			 end 
		end
	    VersesAndVisions.visionTitle:SetHidden(true)
	end
	
	VersesAndVisions.buffStacks = {}
	VersesAndVisions.buffIcon = {}
	VersesAndVisions.stackText = {}
	VersesAndVisions.buffHighlightIcon = {}
	VersesAndVisions.avatarIcon = {}
	
	if VersesAndVisions.inventoryTitle then
	    VersesAndVisions.inventoryTitle:SetHidden(true)
		 VersesAndVisions.inventoryTitle = nil
	end
	
	if VersesAndVisions.inventoryText then
	    VersesAndVisions.inventoryText:SetHidden(true)
		 VersesAndVisions.inventoryText = nil
	end
	
end

function VersesAndVisions.HighlightOn(abilityId)
    if VersesAndVisions.buffHighlightIcon[abilityId] then
	    local currentAlpha = VersesAndVisions.buffHighlightIcon[abilityId]:GetAlpha()
	    if currentAlpha < 1 and VersesAndVisions.HighlightIsOn then 
		   VersesAndVisions.buffHighlightIcon[abilityId]:SetAlpha(currentAlpha + 0.1)
		   zo_callLater(function() VersesAndVisions.HighlightOn(abilityId) end, 5)
		   return
	    end
		VersesAndVisions.buffHighlightIcon[abilityId]:SetAlpha(1)
    end
end


function VersesAndVisions.HighlightOff(abilityId)
     if VersesAndVisions.buffHighlightIcon[abilityId] then
	    local currentAlpha = VersesAndVisions.buffHighlightIcon[abilityId]:GetAlpha()
		if currentAlpha > 0 and not VersesAndVisions.HighlightIsOn then
		  VersesAndVisions.buffHighlightIcon[abilityId]:SetAlpha(currentAlpha - 0.1)
		  zo_callLater(function() VersesAndVisions.HighlightOff(abilityId) end, 5)
		  return
	    end
	    VersesAndVisions.buffHighlightIcon[abilityId]:SetAlpha(0)
    end
end

EVENT_MANAGER:RegisterForEvent(VersesAndVisions.name, EVENT_ENDLESS_DUNGEON_BUFF_STACK_COUNT_UPDATED, function(_, buffType, abilityId, stackCount) if stackCount == 0 then VersesAndVisions.updateBuffStacks(buffType, abilityId, stackCount) else zo_callLater(function() VersesAndVisions.updateBuffStacks(buffType, abilityId, stackCount) end, 4000) end end)
EVENT_MANAGER:RegisterForEvent(VersesAndVisions.name, EVENT_ENDLESS_DUNGEON_COMPLETED, VersesAndVisions.wipe)
EVENT_MANAGER:RegisterForEvent(VersesAndVisions.name, EVENT_ENDLESS_DUNGEON_INITIALIZED, VersesAndVisions.wipe)
EVENT_MANAGER:RegisterForEvent(VersesAndVisions.name, EVENT_ENDLESS_DUNGEON_STARTED, VersesAndVisions.wipe)
EVENT_MANAGER:RegisterForEvent(VersesAndVisions.name, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, function() if IsInstanceEndlessDungeon() then VersesAndVisions.updateBuffStacks() end end) 



SecurePostHook(ENDLESS_DUNGEON_HUD_TRACKER, "OnHiding", function()
 	if VersesAndVisions.main then
	    VersesAndVisions.main:SetHidden(true)
	end        
end)

SecurePostHook(ENDLESS_DUNGEON_HUD_TRACKER, "OnShown", function()
 	if VersesAndVisions.main then
	    VersesAndVisions.main:SetHidden(false)
	end        
end)