--	Author:		instant (updated by KLingo)
--	File:		insjunkyard.lua
--	Version:	1.03
--	Date:		2014-09-20

-- TODO: 
--    Localization
--    Add "gold summary" on /list junk
--    Rewrite the whole damn thing
--    Rescan inventory for junk and mark it accordingly
--    "Beat" the other 342 loot addons that have appeared :)


insJY = {}
insJY.name = "insjunkyard"
insJY.varWarn = 0 -- warning 1/0 on inventory size.
insJY.protect = 1

local funname = "|cFFFF00ins|c00FF00JunkYard|cFFFFFF"     
local value = 0
local totalqty = 0
local added = 0


-- Setup Colours?
	local colWhite     = "|cFFFFFF" -- white (c1)
    local colYellow    = "|cFFFF00" --yellow (c2)
    local colGreen     = "|c00FF00" --green (c3)
	local colTeal      = "|c00FFFF" -- teal (c4)
	local colRed       = "|cFF0000" -- Red

local function QualCol(quality)
	local r,g,b  = GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, quality)
	local colour = string.format("%.2x%.2x%.2x", zo_floor(r * 255), zo_floor(g * 255), zo_floor(b * 255))
	return "|c"..colour
end

local function store(...)
      if insJY.SVP.autosell then
      	SellAllJunk()
      end
end

local function getFunc(varName)
	if insJY.SVG.debug==true then d(varName) end
	return varName
end

-- strip the gear and return a lot of stuff that was asked...
local function stripGear(itemLoc)
		local itemFILTER= GetItemFilterTypeInfo(1, itemLoc)  -- 1/2 weapon/Apparel
		local itemTRAIT = GetItemTrait(1,itemLoc)
		local itemTYPE  = GetItemType(1,itemLoc)
		local link = GetItemLink(1, itemLoc)	
		
		local name,col,typID,id,qual,levelreq,enchant,ench1,ench2,un1,un2,un3,un4,un5,un6,un7,un8,un9,style,un10,bound,charge,un11=ZO_LinkHandler_ParseLink(link)
		local icon,stack,sellprice,meets,locked,equiptype,itemstyle,quality = GetItemInfo(1,itemLoc)
		-- whinstone, a02ef7, item, 45159, 5,   36,  26848,  5, 36,  0,   0,  0,  0,  0,  0,  0,  0,  0,  6,    0,    0,   368,   0
		--   name      color, type,  id,  qual, lvl,  ench, str, str,un1,un2,un3,un4,un5,un6,un7,un8,un9,style,un10,bound,charge, un11
	if insJY.SVG.debug == true then
		d(link)
		d("Texture: "..tostring(icon))
		d("Itemname: "..tostring(name))
		d("Type: "..GetString("SI_ITEMTYPE",itemTYPE).. " - Filter: "..GetString("SI_ITEMFILTERTYPE", itemFILTER))
		d("ID: "..tostring(id))

		d(qual)
		local colour=QualCol(quality)
		d("Quality: "..tostring("|c"..colour.." - "..qual.." - "..quality))

		if tonumber(itemTRAIT)>0 then 
			d("Trait: "..tostring(itemTRAIT).."-"..GetString("SI_ITEMTRAITTYPE",itemTRAIT))
		end
		d("Bound: "..tostring(bound))
		-- weapon/armor related
		if itemFILTER==ITEMFILTERTYPE_ARMOR or itemFILTER==ITEMFILTERTYPE_WEAPONS then
				d("Level Required: "..tostring(levelreq))
				d("Enchant: "..tostring(enchant).. " - Strenght: "..tostring(ench1).."-"..tostring(ench2))
				d("Style: "..tostring(style).. " - "..GetString("SI_ITEMSTYLE", style))
		end
		-- weapon related
		if itemFILTER==ITEMFILTERTYPE_WEAPONS then 
				d("Charges: "..tostring(charge))
		end
	end
		
	return name,tonumber(id),tonumber(quality),tonumber(sellprice),tonumber(levelreq),enchant,tonumber(style),tonumber(bound),tonumber(itemFILTER),tonumber(itemTRAIT),tonumber(itemTYPE)
end

local function insJunkYard_guisetup()
			insJY.protect = 0
			ClearMenu()
			if insJY.SVG.debug==true then d("Starting GUI Setup.") end
			if ZO_MainMenuCategoryBar:IsHidden()==false then
					ZO_SceneManager_ToggleUIModeBinding()				
			end
			if(CHAT_SYSTEM:IsMinimized()) then
				else
					CHAT_SYSTEM:Minimize()
			end
			ZO_SceneManager_ToggleGameMenuBinding()
			ZO_OptionsWindow:SetHidden(false)

			if added== 0 then 
					ZO_OptionsWindow_AddUserPanel("OPTIONS_PANEL_INSJUNKYARD2OPTIONS", insJY.name)
					added = 1
			end
			ZO_OptionsWindow_ChangePanels("OPTIONS_PANEL_INSJUNKYARD2OPTIONS")
			ZO_OptionsWindowTitle:SetText("INS:Junkyard Settings")	
			
			-- since we hacked we need to load all the settings here
			-- globals
			INSJY_Settings_GLOBALCheckbox:toggleFunction(getFunc(insJY.SVG.global) and 1 or 0)			
			INSJY_Settings_GLOBALJUNKCheckbox:toggleFunction(getFunc(insJY.SVG.globaljunk) and 1 or 0)			
			INSJY_Settings_MESSAGECheckbox:toggleFunction(getFunc(insJY.SVG.launchmessage) and 1 or 0)
			-- settings
			INSJY_Settings_SALESPAMCheckbox:toggleFunction(getFunc(insJY.SVP.salespam) and 1 or 0)
			INSJY_Settings_SUMMARYCheckbox:toggleFunction(getFunc(insJY.SVP.summary) and 1 or 0)
			
			INSJY_Settings_LOOTCheckbox:toggleFunction(getFunc(insJY.SVP.loot) and 1 or 0)
			INSJY_Settings_PARTYCheckbox:toggleFunction(getFunc(insJY.SVP.party) and 1 or 0)
			INSJY_Settings_JUNKSPAMCheckbox:toggleFunction(getFunc(insJY.SVP.junkspam) and 1 or 0)
			INSJY_Settings_JUNKYARDCheckbox:toggleFunction(getFunc(insJY.SVP.junkyard) and 1 or 0)
			
			INSJY_Settings_AUTOMARKCheckbox:toggleFunction(getFunc(insJY.SVP.autoadd) and 1 or 0)
			INSJY_Settings_TRAITCheckbox:toggleFunction(getFunc(insJY.SVP.trait) and 1 or 0)
			INSJY_Settings_SELLCheckbox:toggleFunction(getFunc(insJY.SVP.autosell) and 1 or 0)
			INSJY_Settings_WARNCheckbox:toggleFunction(getFunc(insJY.SVP.warn) and 1 or 0)
			INSJY_Settings_DESTROYCheckbox:toggleFunction(getFunc(insJY.SVP.destroy) and 1 or 0)
			
			local traittext = GetString("SI_ITEMQUALITY",insJY.SVP.quality)
			INSJY_Settings_TRAITSETTINGSDropdownSelectedItemText:SetText(traittext)
					
			-- hide the buttons so the user dont use them... as they are related to the GAME and not us =)
			-- We're usually very nice to the game.  Even if its 32-bit... 
      		ZO_OptionsWindowApplyButton:SetHidden(true)
			ZO_OptionsWindowResetToDefaultButton:SetHidden(true)
end

-- exit the setup menu and kill/hide the stuff we added. Should in theory not break anything :D
function insJY.GuiExit()
		insJY.protect = 1
		if insJY.SVG.debug==true then d("Exiting GUI Setup.") end
		ZO_OptionsWindow:SetHidden(true)
		ZO_SceneManager_ToggleGameMenuBinding()
		if(CHAT_SYSTEM:IsMinimized()) then
			CHAT_SYSTEM:Maximize()
		end
		local maxnum=#ZO_OptionsWindow.panelNames
		for i=1,maxnum do
			if ZO_OptionsWindow.panelNames[i]==insJY.name then
					table.remove(ZO_OptionsWindow.panelNames, i)
			end
		end
		local maxnum=ZO_GameMenu_InGameNavigationContainerScrollChildContainer3:GetNumChildren()
		for i=1,maxnum do
			if insJY.SVG.debug==true then d(i.."-"..ZO_GameMenu_InGameNavigationContainerScrollChildContainer3:GetChild(i):GetText()) end
			if ZO_GameMenu_InGameNavigationContainerScrollChildContainer3:GetChild(i):GetText()==insJY.name then
				if insJY.SVG.debug==true then d("Removing insJY from List!") end
				ZO_GameMenu_InGameNavigationContainerScrollChildContainer3:GetChild(i):SetEnabled(false)
				ZO_GameMenu_InGameNavigationContainerScrollChildContainer3:GetChild(i):SetHidden(true)
				ZO_GameMenu_InGameNavigationContainerScrollChildContainer3:GetChild(i):SetScale(0)
			end
		end	
		-- ugly but doable ;)	
		-- /script d(ZO_GameMenu_InGameNavigationContainerScrollChildContainer3:GetChildren()[2]:GetName())
		-- ZO_GameMenu_InGameNavigationContainerScrollChildContainer3  (Settings)
		-- :GetNumChildren() -> 14
		--/script d(ZO_GameMenu_InGameNavigationContainerScrollChildContainer3:GetChildren()) (list all)
end


local function sell(...)
   	id, itemName, itemqty, itemcash = ...
   	itemName = string.gsub(itemName, "(^p)", "")
	itemName = string.gsub(itemName, "(^n)", "")
	if insJY.SVP.salespam == true then
			d(colWhite.."Sold: "..colYellow..itemName..colWhite.." for "..colYellow..itemcash..colWhite.." Gold")
	end
	totalqty = totalqty + itemqty
	value = value + itemcash
end

local function cstore(...)
	if insJY.SVP.summary == true then
		if totalqty > 0 then 
      		d(colWhite.."Sold "..colYellow..totalqty..colWhite.." junk items for a total of "..colGreen..value..colWhite.. " gold.")
		end
	end 
    totalqty = 0
    value = 0
end

local function filterAdd(key,onOff)
	if insJY.SVG.debug==true then
		d(tostring(key).." : "..tostring(onOff))
	end
	table.insert(insJY.SVP.filters, { key, onOff } )
end

local function filterRemove(id)

end

local function filterList()
	for k,v in pairs(insJY.SVP.filters) do 
		d("id["..tostring(k).."] filter["..v[1].."] ["..v[2].."]")
	end
end

local function getCount(itemLink)
	local i, linkname
	local count=0
	local number = GetBagSize(1)
	for i = 0, number do
		linkname = GetItemLink(1,i)
		if linkname==itemLink then
			if insJY.SVG.debug==true then d("Linkname: "..linkname.." and "..itemLink.." are equal") end		
			-- count them..
			count = GetItemTotalCount(1,i)
			if insJY.SVG.debug==true then d("TOtalCount:"..count) end
			if count==1 then count=0 end
			return count
		end
	end
end

-- loot messages
local function moreLoot(eventCode, receivedBy, itemName, quantity, itemSound, lootType, self)
    receivedBy = string.gsub(receivedBy, "(^Fx)", "")
    receivedBy = string.gsub(receivedBy, "(^Mx)", "")

		if insJY.SVG.debug==true then
			d(eventCode..receivedBy..itemName..quantity..lootType)
		end

		if self==true then 
			receivedBy="You"
		end
	  
		local count=0
		local cmax=100
		count=getCount(itemName)
		itemName = string.gsub(itemName, "(^p)", "")
		itemName = string.gsub(itemName, "(^n)", "")
		local lootmessage=colWhite.."["..colGreen..receivedBy..colWhite.."]"..colYellow.." looted "..colWhite.."["..colGreen..quantity..colWhite.." x "..colGreen..itemName..colWhite.."]"
		-- getItemInfo (2nd argument = qty in bags)
		if insJY.SVG.debug==true then 
			d("Count:"..tostring(count)) 
			d("Lootmessage:"..lootmessage)
		end		
		if insJY.SVP.loot==true then
			if self==true then
				if count==nil then count=0 end
				if count>1 then
					if count>100 then cmax=200 end
					if count>200 then cmax=300 end
					lootmessage=lootmessage.." ["..colGreen..count..colWhite.." / "..colGreen..cmax..colWhite.."]"
				end				
				d(lootmessage)
			end
		end
		if insJY.SVP.party==true then
			if self==false then
				d(lootmessage)
			end
		end
end


local function createListing(i,iQual)
	 		local link = GetItemLink(1,i)
	 		if link ~= "" then
	 				local name,id,quality,sellprice,level,enchant,style,bound,itemFILTER,itemTRAIT,itemTYPE = stripGear(i)
	 				if tonumber(style)>0 then
	 					 style = GetString("SI_ITEMSTYLE", style)
	 				end
	 				if tonumber(itemTRAIT)>0 then
	 						itemTRAIT = GetString("SI_ITEMTRAITTYPE",itemTRAIT)
	 				end
	 				itemTYPE = GetString("SI_ITEMTYPE",itemTYPE)
	 				itemFILTER = GetString("SI_ITEMFILTERTYPE", itemFILTER)
	 				
	 				link = string.gsub(link, "(^p)", "")
	 				link = string.gsub(link, "(^n)", "")
	 				link = "*"..colWhite.." ["..colYellow..i..colWhite.."]"..link
						if iQual==quality or iQual==999 then
							link = link.." "
							if itemTYPE~=nil then
								link = link..colWhite.."("..colYellow..itemTYPE..colWhite..")"
							end
							if itemFILTER~=nil then
								link = link..colWhite.."("..colYellow..itemFILTER..colWhite..")"
							end
							if style~=nil and style~=0 then
								link = link..colWhite.."("..colYellow..style..colWhite..")"
							end
							local jVal
							if itemTRAIT~=nil and itemTRAIT~=0 then
								link = link..colWhite.."("..colYellow..itemTRAIT..colWhite..")"
							end
							if sellprice==0 then
									link = link..colWhite.."("..colGreen.."Worthless"..colWhite..")"
							end
			 				if IsItemJunk(1,i) then 
			 					jVal="["..colRed.."Junk"..colWhite.."]."
			 				else
			 					jVal=" "
			 				end							
							d(link..jVal)
	 				  end
			end
end

-- NEEDS: rewrite for new item information... 
-- SCAN for TRAIT(ornate) or FILTERS (for traits...)
local function itemScan(slotId)
    local k, v
		local icon,stack,sellprice,meets,locked,equiptype,itemstyle,quality = GetItemInfo(1,slotId)
		if insJY.SVG.debug==true then d("Slot:"..slotId) end
		for k,v in pairs(insJY.SVP.filters) do
				if insJY.SVG.debug==true then 
					d(tostring(icon)..k)
					d(v)
				end
				if string.find(tostring(icon),v[1]) then
					if insJY.SVG.debug==true then d("We have a match on filter") end
					if v[2]==true then
						d("Filter is enabled for : "..v[1])
					end
					return true
				end
		end
		-- ITEM_TRAIT_TYPE_ARMOR_ORNATE, ITEM_TRAIT_TYPE_WEAPON_ORNATE)
		if GetItemTrait(1,slotId)==ITEM_TRAIT_TYPE_ARMOR_ORNATE or GetItemTrait(1,slotId)==ITEM_TRAIT_TYPE_WEAPON_ORNATE or GetString("SI_ITEMTRAITTYPE",GetItemTrait(1,slotId))=="Ornate" then
				if insJY.SVG.debug==true then d("Itemtrait on item") end
				if insJY.SVP.trait==true then					
						if insJY.SVP.quality<=quality then return true end -- item matches or is below quality threshhold.
				end
		end
		return false
end

local function listInv(iQual)
		local iQual= tonumber(iQual)
		local i
		if insJY.SVG.debug==true then d(iQual) end
	  d(colWhite.." Listing Inventory:")
	  local number = GetBagSize(1)
	  local curInv,maxInv =PLAYER_INVENTORY:GetNumSlots(INVENTORY_BACKPACK)
	  for i = 0,number do
	 					createListing(i,iQual)
	  end
	  d(colWhite.." Bag status ("..colYellow..curInv..colWhite.." used / "..colYellow..maxInv..colWhite.." total)")
	  d(colGreen.."/junkyard add"..colYellow.." #"..colWhite.." to add item to autojunk and junk list")
end

local function listJunk()
		local i = 0
		local jVal
	  d(colWhite.." Listing Junk Items:")
	  number = GetBagSize(1)
	  for i = 0,number do
	 		if IsItemJunk(1,i) or itemScan(i)==true then
 					createListing(i,999)
	 		end 
	  end
		local curInv,maxInv =PLAYER_INVENTORY:GetNumSlots(INVENTORY_BACKPACK)
	  d(colWhite.." Bag status ("..colYellow..curInv..colWhite.." used / "..colYellow..maxInv..colWhite.." total)")	  
	  d(colGreen.."/junkyard add"..colYellow.." #"..colWhite.." to add item to autojunk and junk list")
	  d(colGreen.."/junkyard remove"..colYellow.." #"..colWhite.." to remove item from junk list")
end

-- List the saved junk list
local function listmark()
		local k, v
		d(colWhite.." Listing saved junk items.")
		for k,v in pairs(insJY.SV.junk) do
			d(colWhite.."#"..colYellow..k..colWhite.." Name: "..colGreen..v[1])
		end
		d(colWhite.."Type "..colTeal.."/junkyard delmark #"..colWhite.." to remove an entry from the mark list.")
end

local function delmark(id)
	if id~="" then
		local xid = tonumber(id)
		-- failsafe to make sure we received a number.
		if xid==nil then 
			if string.lower(id)=="all" then
				d("Deleting all items on MARK list.")
				for k,v in pairs(insJY.SV.junk) do
					table.remove(insJY.SV.junk, k)
				end
			else
				return
			end
		end
		--d(insJY.SV.junk[id])
		--d(insJY.funname..colWhite.."Removing: "..colGreen..insJY.SV.junk[id][1]..colWhite" from mark list.")
		if insJY.SV.junk[xid] then
			if insJY.SVG.debug==true then d("the id:"..xid) end
			d("Removed: "..insJY.SV.junk[xid][1])
			table.remove(insJY.SV.junk, xid)
		end
	end
end

-- remove item from the junklist and unmark it as junk
local function remFromJunk(itemId)
		local k, v
		local name = GetItemLink(1,itemId)
		if name ~= ""  then
			SetItemIsJunk(1,itemId,false)	 
			d(colGreen.."Un-Marked "..colWhite..GetItemLink(1,itemId,1).." as junk")		
			for k,v in pairs(insJY.SV.junk) do
				if v[1]==name then
					if insJY.SVG.debug==true then d("We are removing k:"..k.." from the mark list as v[1]:"..v[1]) end
					delmark(k)
				end
			end
			-- Iterate through list and remove from junk list.. insJY.SV.junk[name] = false
		else
			d("Could not find an item at this location: 1,"..itemId)
		end
end


-- SCANS for a match on the MARK LIST (itemlinks) vs the input itemLink.
local function scanMARK(itemLink)
  local k, v
	if insJY.SVG.debug==true then d("insJY.scan 1: Scanned name: "..itemLink) end
	-- scan through junk for a match of iname and a value in SV.junk
	for k,v in pairs(insJY.SV.junk) do
		if insJY.SVG.debug==true then d("insJY.scan 2: We compare: "..k.." - "..v[1].." - "..itemLink) end
		if v[1]==itemLink then
			-- we found a hit
			if insJY.SVG.debug==true then  d("insJY.scan 3: We return true: "..v[1].." seems to be like "..itemLink) end
			return true -- we return the fact that we had a hit
		else
	 		if insJY.SVG.debug==true then  d("insJY.scan 4: We return false: "..v[1].." is not "..itemLink) end
		end		
	end
	if insJY.SVG.debug==true then  d("insJY.scan 5: We are returning false..") end
	return false
end

-- Lets the player mark a item as junk
local function addToJunk(itemId)
		local i = 0
		if itemId=="all" then -- we add all items to the MARK junk list.
				local number = GetBagSize(1)	
			  for i = 0,number do
			 		if IsItemJunk(1,i) then
			 			if insJY.SVG.debug==true then d("addtoJunk 1: Item is junk: id "..i) end
			 			local link = GetItemLink(1,i)			 			
			 			if link ~= "" then
			 				if insJY.SVG.debug==true then d("addtoJunk 2: Item name: "..link) end
			 				if scanMARK(GetItemLink(1,i))~=true then
			 					if insJY.SVG.debug==true then d("addtoJunk 3: We call ourself after running insJY.scan") end
			 					addToJunk(i)
			 				end
			 			end
			 		end
			 	end
		else		-- normal operation below.		
				local jname = GetItemLink(1,itemId)
				if insJY.SVG.debug==true then d("AddToJunk 4:  Getitemlink(1,"..itemId..") returned "..jname) end
				if jname ~= ""  then
					SetItemIsJunk(1,itemId,true)
					-- need a rewrite.. 
					if insJY.SVG.debug==true then 
							d(colRed.."Marked "..colWhite..GetItemLink(1,itemId,1).." as junk")
					end
					--local count=0;for _ in pairs(insJY.SV.junk) do count = count +1 end;
					--count=count+1
					--insJY.SV.junk[count] = { name, true }
					
					-- We add the item to the junk table when scanMARK returns false.
			 		if scanMARK(jname)==false then	
			 			if insJY.SVG.debug==true then d("AddToJunk 5:  Scan returned false for: "..GetItemLink(1,itemId).." and "..jname.." so we add it!")				end
						table.insert(insJY.SV.junk, {jname})
					else
						if insJY.SVG.debug==true then d("AddToJunk 6:  Scan returned true for: "..GetItemLink(1,itemId).." and "..jname.. " which means its alread on list!")				end
					end
				else
					d("AddToJunk 7:  Could not find an item at this location: 1,"..itemId)
				end
		end
end

function insJY.scanitall(slotId)
		--d("GetItemName")
		--d(GetItemName(1,slotId))
		--d("GetItemLevel")
		--d(GetItemLevel(1,slotId))
		d("GetItemInfo:")
		d(GetItemInfo(1,slotId))
		--** textureName* , ** _stack_, ** _sellPrice_, ** _meetsUsageRequirement_, ** _locked_, ** _equipType_, ** _itemStyle_, _quality_
		d("GetItemStatValue")
		d(GetItemStatValue(1,slotId))
		--d("GetItemFilterTypeInfo")
		--d(GetItemFilterTypeInfo(1,slotId))
		d("GetItemInstanceId")
		d(GetItemInstanceId(1,slotId))	
		--d("GetItemCooldownInfo")
		--d(GetItemCooldownInfo(1,slotId))
		--d("GetItemCurrentActionBarSlot")
		--d(GetItemCurrentActionBarSlot(1,slotId))
		d("GetItemSoundCategory")
		d(GetItemSoundCategory(1,slotId))
		--d("IsItemEnchantment")
		--d(IsItemEnchantment(1,slotId))
		--d("GetChargeInfoForItem")
		--d(GetChargeInfoForItem(1,slotId))
		--d("GetItemCondition")
		--d(GetItemCondition(1,slotId))
		--d("GetItemTrait")
		--d(GetItemTrait(1,slotId)) -- 
		d("GetItemCraftingInfo")
		d(GetItemCraftingInfo(1,slotId))
		stripGear(slotId)
end

-- destroy function
local function destroyGear(i)
		if insJY.SVP.destroy == true then
				local name,id,quality,sellprice,level,enchant,style,bound,itemFILTER,itemTRAIT,itemTYPE = stripGear(i)
				local link = GetItemLink(1,i)
				if IsItemJunk(1,i) then -- check if item is in junk bag
						if sellprice==0 then  -- check if item is worth nothing
								if scanMARK(link) then  -- if the item IS on the MARKED list. 

									    if(GetCursorContentType()== MOUSE_CONTENT_EMPTY) then -- the mouse must be clear
														d(colWhite.."Destroying: "..link..colWhite.." with value ["..colYellow..sellprice..colWhite.."].")									    
    												local status = true
    												ClearCursor()
												    status = CallSecureProtected("PickupInventoryItem", 1, i)
									    			SetCursorItemSoundsEnabled(true)
									    			if (status) then status = CallSecureProtected("PlaceInWorldLeftClick") end

										  end
								end
						end
				end
		end
end


local function runthroughInventory()
	  local number = GetBagSize(1)
	  for i = 0, number do
	 		if IsItemJunk(1,i) then
 					destroyGear(i)
	 		end 
	  end		
end

local function OnInventorySlotUpdate (eventCode,bagId,slotId,isNewItem,itemSoundCategory,updateReason)
	local curInv, maxInv
	curInv,maxInv =PLAYER_INVENTORY:GetNumSlots(INVENTORY_BACKPACK)

	if maxInv-curInv<5 then
		if insJY.SVP.destroy == true then runthroughInventory() end -- run through inventory and destroy items... 
			if insJY.SVP.warn then
			  --if maxInv-curInv<tonumber(insJY.SVP.warn) then   TODO
			  	if insJY.varWarn== 0 then
				  	if maxInv-curInv<10 then
			  			CheckInventorySpaceAndWarn(5)
				  	end
			  		d(colWhite.."Warning, you only have "..colGreen..maxInv-curInv..colWhite.." slot(s) free!. ["..curInv.."/"..maxInv.."]")
			  		insJY.varWarn= 1
			  	end
			elseif maxInv-curInv<5 then
					if insJY.varWarn==1 then insJY.varWarn=0 end
			end
  end
  
  -- if automarking of junk items is set to true
	if insJY.SVP.junkyard==true then
	  -- if we are in the users bag and it is registered as a new item
    if bagId == BAG_BACKPACK and isNewItem then
        -- if the itemtype is registered as TRASH or we have it in the MARK list, or itemSCAN(?) reports true.
        if GetItemType(bagId, slotId) == ITEMTYPE_TRASH or scanMARK(GetItemLink(bagId,slotId)) or itemScan(slotId) then
            SetItemIsJunk(bagId, slotId, true)
            if insJY.SVP.junkspam==true then d(GetItemLink(bagId,slotId,1).." put in junk bag.") end
        end
    end
  end
  if insJY.SVP.autoadd==true then -- automark option set enabled
    if bagId == BAG_BACKPACK then  -- if it is not a new item
    		if (IsItemJunk(bagId, slotId)) and bagId==BAG_BACKPACK then -- means the item was set to junk and we are in player inventory.
    			  if insJY.SVG.debug==true then d("OnInventory 1: Item is Junk and we are in players inventory.") end
    				if GetItemType(bagId, slotId) ~= ITEMTYPE_TRASH and (GetItemTrait(bagId,slotId)~=10 and GetItemTrait(bagId,slotId)~=19 and GetItemTrait(bagId,slotId)~=24) then  -- if the item is trash OR has the trait we really dont want it on the mark list.
    						if insJY.SVG.debug==true then d("OnInventory 2: We matched a criteria for GetItemtype NOT Trash or traited") end
   							addToJunk(slotId) -- add item to the MARK list.
   					end
   			elseif (IsItemJunk(bagId, slotId)==false) and bagId==BAG_BACKPACK then 
   			    if insJY.SVG.debug==true then d("OnInventory 3: Item is not/no longer on junk list..") end
   			    if scanMARK(GetItemLink(1,slotId)) then -- if we get a hit on the mark list, but the item isn't junk.. then 
   			    	 remFromJunk(slotId) -- we remove the item from the mark list
   			    end 
   			end
    end
	end
	
end


--[[

crafting_ore_base
crafting_ores
crafting_metals
crafting_jewlery_base
crafting_medium_armor_component
crafting_smith_plug_sp_names
crafting_light_armor_vendor
crafting_components_runestone (ench)
crafting_forester_weapon_component (wood)
crafting_smith_plug
crafting_runecrafter_armor_component
crafting_medium_armor_sp_names 
crafting_metals_manganese
crafting_enchantment_base_sardonyx
crafting_forester_weapon_vendor_component
]]--




---## Start of function to handle commands
local function commandHandler(text)
 -- put everything in lowercase
  local input = string.lower(text)
  -- set up some variables
  local com = {}
  local index = 1
  -- set quality text and colour
  	local qtrcol = QualCol(insJY.SVP.quality)
  	local qtrstr = GetString("SI_ITEMQUALITY",insJY.SVP.quality)
 	local qtr = qtrcol..qtrstr
  
  -- separate arguments 
  if text~=nil then 
    if insJY.SVG.debug==true then d(text.." "..input) end
  	for value in string.gmatch(input,"%w+") do 
  		  com[index] = value
	    	index = index + 1
		end
	end
  -- the check... 
  if com[1]=="delmark" or com[1]=="dm" then
  	if com[2]==nil then
  		d("Please include the # to remove, or type \"all\" to remove all entries. \"/junkyard list mark\" for list.")
  	else
  		delmark(com[2])
  	end
  elseif com[1]=="remove" then
  	if com[2]~="" then
 			remFromJunk(com[2])
 		else
 			d("You need to supply a ItemID. Type \"/junkyard list\" or \"/junkyard list all\" for ItemIDs")
 		end
 	elseif com[1]=="add" then
 		if com[2]~="" then
 		  addToJunk(com[2])
 		else
 			d("You need to supply a ItemID. Type \"/junkyard list\" or \"/junkyard list all\" for ItemIDs")
 		end
  elseif com[1]=="list" then
  	if com[2]=="all" then
  		listInv(999)
  	elseif com[2]=="mark" then
	  	listmark()
	  elseif com[2]=="q" then
	  	listInv(com[3])
	  else
  	-- might as well default to listing junk when the user do not select an option
	  	listJunk()  	
  	end  
  elseif com[1]=="setup" then
  	insJunkYard_guisetup()
  elseif com[1]=="set" then
  	if com[2]=="auto" then
  	 	  insJY.SVP.autoadd= not insJY.SVP.autoadd
  	 		d(colWhite.." Autoadd to MARK List from UI. ["..colTeal..tostring(insJY.SVP.autoadd)..colWhite.."].")
  	elseif com[2]=="global" then
  	 	  insJY.SVG.global= not insJY.SVG.global
  	 		d(colWhite.." GLOBAL PROFILES ["..colTeal..tostring(insJY.SVG.global)..colWhite.."].")
  	 		d(colRed.." PLEASE RELOAD UI WITH /RELOADUI IF YOU CHANGE THIS!")
  	elseif com[2]=="globaljunk" then
  	 	  insJY.SVG.globaljunk= not insJY.SVG.globaljunk
  	 		d(colWhite.." GLOBAL JUNK Profile ["..colTeal..tostring(insJY.SVG.globaljunk)..colWhite.."].")
  	 		d(colRed.." PLEASE RELOAD UI WITH /RELOADUI IF YOU CHANGE THIS!")
  	elseif com[2]=="welcome" then
  	 	  insJY.SVG.launchmessage= not insJY.SVG.launchmessage
  	 		d(colWhite.." Welcome message ["..colTeal..tostring(insJY.SVG.launchmessage)..colWhite.."].") 	 		
  	elseif com[2]=="destroy" then
  	 	  insJY.SVP.destroy= not insJY.SVP.destroy
  	 		d(colWhite.." Autodestroy 0 value junk/mark items ["..colTeal..tostring(insJY.SVP.destroy)..colWhite.."].")
  	elseif com[2]=="trait" then
  	  if com[3]==nil then
	  		insJY.SVP.trait = not insJY.SVP.trait
				d(colWhite.." Autojunk traited "..qtr..colWhite.." items ["..colTeal..tostring(insJY.SVP.trait)..colWhite.."].")
  	  else
  	  	 if tonumber(com[3])>=0 and tonumber(com[3])<=5 then
  	  	 		insJY.SVP.quality = tonumber(com[3])
  				qtrcol = QualCol(insJY.SVP.quality)
  				qtrstr = GetString("SI_ITEMQUALITY", insJY.SVP.quality)
 				qtr = qtrcol..qtrstr
  	  	 		d(colWhite.." Autojunk traited quality set to "..qtr)
  	  	 else
  	  	 		d(colWhite.." Enter a number between 0 and 5")
  	  	 end
			end
  	elseif com[2]=="salespam" then
	  	insJY.SVP.salespam = not insJY.SVP.salespam
			d(colWhite.." Sales feedback per item ["..colTeal..tostring(insJY.SVP.salespam)..colWhite.."].")
  	elseif com[2]=="junkspam" then
	  	insJY.SVP.junkspam = not insJY.SVP.junkspam
			d(colWhite.." Junk feedback per item ["..colTeal..tostring(insJY.SVP.junkspam)..colWhite.."].")
  	elseif com[2]=="summary" then
	  	insJY.SVP.summary = not insJY.SVP.summary
			d(colWhite.." Sales summary ["..colTeal..tostring(insJY.SVP.summary)..colWhite.."].")
		elseif com[2]=="loot" then
	  	insJY.SVP.loot = not insJY.SVP.loot
			d(colWhite.." Loot messages ["..colTeal..tostring(insJY.SVP.loot)..colWhite.."].")
		elseif com[2]=="party" then
	  	insJY.SVP.party = not insJY.SVP.party
			d(colWhite.." Party loot message ["..colTeal..tostring(insJY.SVP.party)..colWhite.."].")
		elseif com[2]=="junkyard" then
	  	insJY.SVP.junkyard = not insJY.SVP.junkyard
			d(colWhite.." Automarking junk items ["..colTeal..tostring(insJY.SVP.junkyard)..colWhite.."].")
		elseif com[2]=="autosell" then
	  	insJY.SVP.autosell = not insJY.SVP.autosell
			d(colWhite.." Autoselling junk items ["..colTeal..tostring(insJY.SVP.autosell)..colWhite.."].")
			-- Setting for Inventory Warning (/Junkyard warn (blank, 0, or size) )
		elseif com[2]=="warn" then
			insJY.SVP.warn= not insJY.SVP.warn
			d(colWhite.." Warning on below 5 inventory slots ["..colTeal..tostring(insJY.SVP.warn)..colWhite.."].")
		  --if tonumber(com[3])==nil then
		  --	d(colWhite.." Please enter a number. 0 to disable, any other to set that as limit.")
		  --elseif tonumber(com[3])==0 then
				--insJY.SVP.warn = 0
				--d(colWhite.." Warning on low inventory ["..colTeal.."disabled"..colWhite.."].")
			--else
				--insJY.SVP.warn = tonumber(com[3])
				--d(colWhite.." Warning on low inventory set to ["..colTeal..insJY.SVP.warn..colWhite.." slots. ]")
			--end
  	elseif com[2]=="debug" then
	  	insJY.SVG.debug = not insJY.SVG.debug
			d("Debug "..tostring(insJY.SVG.debug))
		else
				d(colTeal.."/junkyard set "..colWhite.."- Settings available")
				d(colTeal.."set global"..colWhite.." Toggle accountwide settings. "..colYellow.."["..colTeal..tostring(insJY.SVG.global)..colYellow.."]")
				d(colTeal.."set globaljunk"..colWhite.." Toggle accountwide JUNKMARK list. "..colYellow.."["..colTeal..tostring(insJY.SVG.globaljunk)..colYellow.."]")
				d("Please reload UI when you use this. Type /reloadui or go through Menu/Addons")
				d(colTeal.."set welcome"..colWhite.." Toggle welcome message on login. "..colYellow.."["..colTeal..tostring(insJY.SVG.launchmessage)..colYellow.."]")
				d(colTeal.."set salespam"..colWhite.." Toggle individual item sale feedback. "..colYellow.."["..colTeal..tostring(insJY.SVP.salespam)..colYellow.."]")
				d(colTeal.."set junkspam"..colWhite.." Toggle individual item junk feedback. "..colYellow.."["..colTeal..tostring(insJY.SVP.junkspam)..colYellow.."]")
				d(colTeal.."set summary"..colWhite.." Toggle item/gold summary on vendor exit. "..colYellow.."["..colTeal..tostring(insJY.SVP.summary)..colYellow.."]")
				d(colTeal.."set loot"..colWhite.." Toggle loot messages in chat. "..colYellow.."["..colTeal..tostring(insJY.SVP.loot)..colYellow.."]")
				d(colTeal.."set party"..colWhite.." Toggle loot messages from party members. "..colYellow.."["..colTeal..tostring(insJY.SVP.party)..colYellow.."]")
				d(colTeal.."set junkyard"..colWhite.." Toggle automarking junk items. "..colYellow.."["..colTeal..tostring(insJY.SVP.junkyard)..colYellow.."]")
				d(colTeal.."set auto"..colWhite.." Toggle adding to Mark list when item is marked in UI. "..colYellow.."["..colTeal..tostring(insJY.SVP.autoadd)..colYellow.."]")
				d(colTeal.."set trait"..colWhite.." Toggle automarking trait items. "..colYellow.."["..colTeal..tostring(insJY.SVP.trait)..colYellow.."] ["..colWhite..qtr..colWhite.."]")
				d(colTeal.."set autosell"..colWhite.." Toggle autoselling junk items. "..colYellow.."["..colTeal..tostring(insJY.SVP.autosell)..colYellow.."]")
				d(colTeal.."set warn "..colWhite.." Toggle low space warning on below 5 slots.. "..colYellow.."["..colTeal..tostring(insJY.SVP.warn)..colYellow.."]")
				d(colTeal.."set destroy "..colWhite.." Toggle autodestruction of 0 value junk items.."..colYellow.."["..colTeal..tostring(insJY.SVP.destroy)..colYellow.."]")
		end -- end set
	elseif com[1]=="help" then
		d("Please see Read.Me in the addon folder for help, or wait for version 2.00")
  else
		d(funname..colWhite.." commands:")
		d(colTeal.."/junkyard or /jy")
		d(colTeal.."setup"..colWhite.." - For GUI setup!")
		d(colTeal.."list all"..colWhite.." - List all items.")
		d(colTeal.."list"..colWhite.." - List all items in JUNK inventory.")
		d(colTeal.."list q #"..colWhite.." - List all items of quality level # (0-5)")
		d(colTeal.."set"..colWhite.." - For a list of settings available.")
		d(colTeal.."help"..colWhite.." - For help.")
		d("--------------------------")
		d("Mark commands.")
		d(colTeal.."list mark"..colWhite.." - List all items in saved junkyard list.")
		d(colTeal.."remove"..colYellow.." #"..colWhite.." - Remove item from junk list (use 'list junk' to see id).")
		d(colTeal.."add"..colYellow.." #"..colWhite.." - Add item to junk+saved list (use 'list'/'list all' to see id).")
		d(colTeal.."add all"..colYellow.." #"..colWhite.." - Add all items currently in your Junk inventory to the list.")
		d(colTeal.."delmark or dm"..colYellow.." #"..colWhite.." - Remove item from SAVED junk list (use 'list mark' to see id).")
	end
end
----### end of function

local function Intro()
		EVENT_MANAGER:UnregisterForEvent("insJY", EVENT_PLAYER_ACTIVATED)
		if(insJY.SVG.launchmessage) then d(funname.." launched! Type '/junkyard' for options. '/junkyard setup' for GUI.") end
end

-- Initializing	the addon
local function Initialize( eventCode, addOnName )
     if ( addOnName ~= insJY.name ) then return end
     
     insJY.GlobalDefaults = { global = true,
                              launchmessage = true,
                              debug = false,
                              globaljunk = false,  -- is our junk list shared or per character. 
											      }
     
     insJY.DefaultJunk = { ["junk"] = { }, 
                           ["superjunk"] = { }, 
     											} -- the junk table.
     
     insJY.Default = { ["salespam"] = false, -- spam when selling items
                       ["junkspam"] = true, -- spam messages when stuff is junked
                       ["summary"] = true, -- summary on vendor sold items
                       ["loot"] = false, -- loot messages
                       ["party"] = false, -- party loot messages
                       ["junkyard"] = true, 
                       ["trait"] = true, -- trash Ornate traited items
                       ["autosell"] = false, -- automatically sell stuff
                       ["warn"] = true, -- warn when 5 slots left
                       ["filters"] = { }, -- filters for traits -- TODO
                       ["autoadd"] = false,  -- autoadd items to mark list.
                       ["quality"] = 0,  -- Quality Treshhold
                       ["destroy"] = false, -- autodestroy items that match various checks... 
                       ["newjunk"] = false, -- setting for new junk routine.  dont know why I'm adding this.
                        }
    
		insJY.SVG = ZO_SavedVars:NewAccountWide("insJY_SV" , 202 , "GlobalSettings" , insJY.GlobalDefaults, "Global" )

		-- Since we added some fields we have to add them here, or users will have to reconfigure.
		if insJY.SVG.globaljunk == nil then	insJY.SVG.globaljunk = false end

		if insJY.SVG.global==true then
			insJY.SVP = ZO_SavedVars:NewAccountWide("insJY_SV" , 202 , "settings" , insJY.Default, "Global" )
		else
			insJY.SVP = ZO_SavedVars:New("insJY_SV" , 202 , "settings", insJY.Default, "Profile")
		end

		if insJY.SVG.globaljunk == true then
			insJY.SV  = ZO_SavedVars:NewAccountWide("insJY_SV" , 202 , "junk" , insJY.DefaultJunk, "Global" )
		else	
			insJY.SV  = ZO_SavedVars:New("insJY_SV" , 202 , "junk" , insJY.DefaultJunk, "Profile" )
		end

     EVENT_MANAGER:RegisterForEvent("insJY",EVENT_OPEN_STORE, store)     
     EVENT_MANAGER:RegisterForEvent("insJY",EVENT_CLOSE_STORE, cstore)     
     EVENT_MANAGER:RegisterForEvent("insJY",EVENT_SELL_RECEIPT, sell)
     EVENT_MANAGER:RegisterForEvent("insJY",EVENT_INVENTORY_SINGLE_SLOT_UPDATE,OnInventorySlotUpdate )
     EVENT_MANAGER:RegisterForEvent("insJY",EVENT_LOOT_RECEIVED, moreLoot)

		SLASH_COMMANDS["/junkyard"] = commandHandler
		SLASH_COMMANDS["/jy"] = commandHandler
end

EVENT_MANAGER:RegisterForEvent("insJY",EVENT_ADD_ON_LOADED,Initialize)
EVENT_MANAGER:RegisterForEvent("insJY", EVENT_PLAYER_ACTIVATED, Intro)
