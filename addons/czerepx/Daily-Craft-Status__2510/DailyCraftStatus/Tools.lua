local _addon = _G["DailyCraftStatus"]

local debugFlag = false

function _addon.CheckQuestItemMatch(bagId, slotId, questId, conditionId)
	local name = GetItemName(bagId, slotId)
	if name==nil or name=="" then return false end
	if DoesItemFulfillJournalQuestCondition(bagId, slotId, questId, 1, conditionId) then 
--		d(name.." found in bank")
		return true 
	end
	return false
end

function _addon.FindQuestItemInBank(bagId, questId, conditionId)
  for slotId = 0, GetBagSize(bagId) do
    if _addon.CheckQuestItemMatch(bagId,slotId,questId,conditionId) then 
     	local itemLink = GetItemLink(bagId,slotId)
    	local inventoryCount, bankCount, craftBagCount = GetItemLinkStacks(itemLink)
    	return true, (inventoryCount+bankCount+craftBagCount), itemLink 
    end
  end
  return false
end;

function _addon.FindFromList(s, list)
	for i=1,#list do
	  if string.find(s,list[i]) then return true end
	end
	return false
end

function _addon.GetGuiRootRelativeAnchor(toplevel)
	local left, top = toplevel:GetLeft(), toplevel:GetTop()  --todo: check what is left/top for non-toplevel controls as well...
	local screenW, screenH = GuiRoot:GetWidth(), GuiRoot:GetHeight()
	local anchor= 0
	local x, y
	
	if top < (screenH / 3) then
		y = top
		if left < (screenW / 3) then
		  anchor, x = TOPLEFT, left
		elseif ( left < (screenW / 3) * 2) then
		  anchor, x = TOP, (left - screenW / 2)
		else
		  anchor, x = TOPRIGHT, (left - screenW)
		end
	elseif top < ((screenH / 3) * 2) then
		y = top - screenH / 2
		if left < (screenW / 3) then
		  anchor, x = LEFT, left
		elseif ( left < (screenW / 3) * 2) then
		  anchor, x = CENTER, (left - screenW / 2)
		else
		  anchor, x = RIGHT, (left - screenW)
		end
	else
		y = top - screenH
		if left < (screenW / 3) then
		  anchor, x = BOTTOMLEFT, left
		elseif ( left < (screenW / 3) * 2) then
		  anchor, x = BOTTOM, (left - screenW / 2)
		else
		  anchor, x = BOTTOMRIGHT, (left - screenW)
		end
	end

	return anchor, x, y
end

function _addon.AddUniqueItemIdToList(idTable, itemId)
	for i=1, #idTable do
		local tid = idTable[i]
		if not tonumber(tid) then	tid = GetItemLinkItemId(tid) end	
		if tid==itemId then return false end	 
	end
	idTable[#idTable+1] = itemId
	return true
end

function _addon.AddUniqueItemIdLinkToList(idTable, itemLink)
	local itemId = GetItemLinkItemId(itemLink)
	for i=1, #idTable do
		local tid = idTable[i]
		if not tonumber(tid) then	tid = GetItemLinkItemId(tid) end	
		if tid==itemId then return false end	 
	end
	idTable[#idTable+1] = itemLink
	return true
end

-- obsolete since Update 37 changes
function _addon.GetLastDailyReset_old()
	local diff = math.floor(GetDiffBetweenTimeStamps(GetTimeStamp(),1604469600)/86400)  --6am UTC
	return 1604469600 + diff*86400
end

function _addon.GetLastDailyReset_EU()
	local diff = math.floor(GetDiffBetweenTimeStamps(GetTimeStamp(),1604458800)/86400)  --3am UTC
	return 1604458800 + diff*86400
end

function _addon.GetLastDailyReset_NA()
	local diff = math.floor(GetDiffBetweenTimeStamps(GetTimeStamp(),1604484000)/86400)  --10am UTC
	return 1604484000 + diff*86400
end

function _addon.CanTrainRiding()
	if GetTimeUntilCanBeTrained()==0 then
		local s1,max1,s2,max2,s3,max3 = GetRidingStats()
		if (s1<max1 or s2<max2 or s3<max3) then
			return true
		end
	end
	return false
end

function _addon._out(s) CHAT_SYSTEM:AddMessage("DCS: "..s) end
function _addon._outd(s) if debugFlag then _addon._out(s) end end

function _addon._translate(s)
	local placeHolder = "["..s.."]"
	local res
	if _addon.translation then res = _addon.translation[s] end
	if not res then	res = _addon.default_translation[s] end	
	return (res or placeHolder)
end

