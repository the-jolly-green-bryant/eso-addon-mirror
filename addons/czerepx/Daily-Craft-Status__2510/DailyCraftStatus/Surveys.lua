local _addon = _G["DailyCraftStatus"]

_addon.surveyFigures = "014" --0=total,1=best,2=2nd best,3=3rd best,4=craglorn best,5=backpack,6=craglorn total
_addon.surveyReport = {}
_addon.surveysPickList = {}

local DCS_AddMenuItem = _addon.AddMenuItem

local AddUniqueItemIdToList = _addon.AddUniqueItemIdToList
local AddUniqueItemIdLinkToList = _addon.AddUniqueItemIdLinkToList
local _out = _addon._out
local _outd = _addon._outd
local _translate = _addon._translate

local surveyDefs = {
		--contains sample Craglorn surveys IDs, for localized names of surveys and "Craglorn" zone name
		{ CRAFTING_TYPE_BLACKSMITHING, "esoui/art/icons/mapkey/mapkey_smithy.dds", 57798 },
		{ CRAFTING_TYPE_CLOTHIER, "esoui/art/icons/mapkey/mapkey_clothier.dds", 57768 },
		{ CRAFTING_TYPE_WOODWORKING, "esoui/art/icons/mapkey/mapkey_woodworker.dds", 57830 },
		{ CRAFTING_TYPE_JEWELRYCRAFTING, "esoui/art/icons/mapkey/mapkey_jewelrycrafting.dds", 139437 },
		{ CRAFTING_TYPE_ALCHEMY, "esoui/art/icons/mapkey/mapkey_alchemist.dds", 57785 },
		{ CRAFTING_TYPE_ENCHANTING, "esoui/art/icons/mapkey/mapkey_enchanter.dds", 57813}, 
	}

local surveyLinkPattern = "|H1:item:%d:4:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h"

local searchBanks = {
		BAG_HOUSE_BANK_ONE,
		BAG_HOUSE_BANK_TWO,
		BAG_HOUSE_BANK_THREE,
		BAG_HOUSE_BANK_FOUR,
		BAG_HOUSE_BANK_FIVE,
		BAG_HOUSE_BANK_SIX,
		BAG_HOUSE_BANK_SEVEN,
		BAG_HOUSE_BANK_EIGHT,
		BAG_HOUSE_BANK_NINE,
		BAG_HOUSE_BANK_TEN,
		BAG_BACKPACK,
		BAG_BANK,
		BAG_SUBSCRIBER_BANK
	}
	
local langCraglorn = ""


local function DCS_moveItem(sourceBag, sourceSlot, targetBag, emptySlot, stackCount)
	if IsProtectedFunction("RequestMoveItem") then
		CallSecureProtected("RequestMoveItem", sourceBag, sourceSlot, targetBag, emptySlot, stackCount)
	else
		RequestMoveItem(sourceBag, sourceSlot, targetBag, emptySlot, stackCount)
	end
end

local function DCS_getEmptySlots(bagId,emptySlots,maxSlots)
	local cnt = 0
	if not emptySlots then emptySlots = {} end
	for slotId = 0,GetBagSize(bagId) do
		if GetItemId(bagId,slotId)==0 then	
			emptySlots[#emptySlots+1] = slotId
			cnt = cnt + 1
			if cnt==maxSlots then return end
		end
	end
end

local function DCS_moveToBackpack(itemId,bagId,toSlotId)
	for slotId = 0,GetBagSize(bagId) do
		if GetItemId(bagId, slotId)==itemId then
			local stackCount = GetSlotStackSize(bagId,slotId)
			local itemLink = GetItemLink(bagId,slotId)
			DCS_moveItem(bagId,slotId,BAG_BACKPACK,toSlotId,stackCount)
			_out("picked up: "..itemLink)
			return true
		end
	end
	return false
end

function _addon.moveSurveys(bagId)
	if #_addon.surveysPickList>0 then
		local emptySlots = {}
		local useSlot = 0
		DCS_getEmptySlots(BAG_BACKPACK,emptySlots,#_addon.surveysPickList)
	
		for i=#_addon.surveysPickList,1,-1 do
			useSlot = useSlot + 1
			if useSlot>#emptySlots then return end
			local itemId = _addon.surveysPickList[i]
			local found = DCS_moveToBackpack(itemId,bagId,emptySlots[useSlot])
			if not found then
				if bagId==BAG_BANK then
					found = DCS_moveToBackpack(itemId,BAG_SUBSCRIBER_BANK,emptySlots[useSlot])
				end
			end	
			if found then	table.remove(_addon.surveysPickList,i) end
		end	
	end
end

local function DCS_getBackpackSurveys()
	local slines = ""
	local t = {}
	local uidt = {}
	
	local bagId = BAG_BACKPACK
	for slotId = 0, GetBagSize(bagId) do
		local itemType, specializedItemType = GetItemType(bagId,slotId)
		if specializedItemType==SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT then
			local _, stackCount = GetItemInfo(bagId,slotId)
			local itemLink = GetItemLink(bagId,slotId)
			local itemId = GetItemLinkItemId(itemLink)
			t[#t+1] = { GetItemLinkName(itemLink), itemLink, stackCount }
			uidt[#uidt+1] = itemId
		end
	end

	for _,itemId in pairs(_addon.surveysPickList) do
		local itemLink = string.format(surveyLinkPattern,itemId)
		if AddUniqueItemIdToList(uidt,itemId) then
  		t[#t+1] = { GetItemLinkName(itemLink), itemLink, 0  }
  	end
	end	

	table.sort(t,function (a,b) return a[1] < b[1] end)

	for i=1,#t do
		if t[i][3]==0 then
			local itemLink = t[i][2]
			local itemId = GetItemLinkItemId(itemLink)
			slines = slines.."|cA0A0A0"..string.format("|H0:dcs_picklist:%d|h%s|h",itemId,t[i][1]).."|cFFFFFF "
			local _, bankCount = GetItemLinkStacks(itemLink)			
			if bankCount > 0 then
				slines = slines..string.format("  |t16:16:/esoui/art/tooltips/icon_bank.dds|t %d", bankCount)
			end	
			local houseCount = 0
			if _addon.accountSettings.houseSurveys then
				houseCount = _addon.accountSettings.houseSurveys[itemId] or 0
			end	
			if houseCount > 0 then
				slines = slines..string.format("  |t16:16:/esoui/art/icons/mapkey/mapkey_housing.dds|t %d", houseCount)
			end	
			slines = slines.."\n"
		else
			slines = slines..t[i][2]..string.format(" (%d)",t[i][3]).."\n"
		end	
	end

	return slines
end

function _addon.updateHouseSurveys()
	local houseSurveys = {}
	for i=1,#searchBanks do
		local bagId = searchBanks[i]
		if IsHouseBankBag(bagId) then 
			for slotId = 0, GetBagSize(bagId) do
				local _, specializedItemType = GetItemType(bagId,slotId)
				if specializedItemType==SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT then
					local _, stackCount = GetItemInfo(bagId,slotId)
					local itemLink = GetItemLink(bagId,slotId)
					local itemId = GetItemLinkItemId(itemLink)
					if not houseSurveys[itemId] then houseSurveys[itemId] = 0 end
					houseSurveys[itemId] = houseSurveys[itemId] + stackCount
				end
			end
		end	
	end
	_addon.accountSettings.houseSurveys = houseSurveys
end

function _addon.updateSurveys()

	if IsOwnerOfCurrentHouse() then
		_addon.updateHouseSurveys()
	end	

	if _addon.showSurveys==false then 
		_addon.surveys:SetText("")
		_addon.surveys:SetHidden(true)
		_addon.updateBackgrounds()
		_addon.updatePosition()
		return 
	end;

	_addon.surveys:SetHidden(false)

	--initiate survey types from sample itemIDs the first time it is needed
	if not surveyDefs[1][4] then
		for i=1,#surveyDefs do	
			local itemLink = string.format(surveyLinkPattern,surveyDefs[i][3])
			local itemName = GetItemLinkName(itemLink)
			local surveyType,location = zo_strsplit(":",itemName)
			langCraglorn = zo_strsplit(" ",string.sub(location,2))
			surveyDefs[i][4] = surveyType
		end
	end

	local surveysByType = {}
	local surveysAtHand = {}
--	local activeZone = GetPlayerActiveZoneName()
	local activeSurvey = {}

	local houseSurveys = _addon.accountSettings.houseSurveys
	if not houseSurveys then houseSurveys = {} end	

	for i=1,#searchBanks do
		local bagId = searchBanks[i]
		if not IsHouseBankBag(bagId) then 
			for slotId = 0, GetBagSize(bagId) do
				local itemType, specializedItemType = GetItemType(bagId,slotId)

				if specializedItemType==SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT then
					local _, stackCount = GetItemInfo(bagId,slotId)
					local itemLink = GetItemLink(bagId,slotId)
					local itemName = GetItemLinkName(itemLink)
					local itemId = GetItemLinkItemId(itemLink)
					local surveyType,location = zo_strsplit(":",itemName)

					if not surveysByType[surveyType] then surveysByType[surveyType] = {} end
					t = surveysByType[surveyType]
					if not t[itemId] then t[itemId] = 0 end
					t[itemId] = t[itemId] + stackCount 					

					if bagId==BAG_BACKPACK then
						if not surveysAtHand[surveyType] then surveysAtHand[surveyType] = {0, itemId} end
						surveysAtHand[surveyType][1] = surveysAtHand[surveyType][1] + stackCount
						if itemLink==_addon.lastSurveyUsed then activeSurvey = { itemLink, surveyType, stackCount }	end

						--the simple test fails because some zone names do not match survey location names (eg. Alikr vs Alikr Desert)
						--if string.find(itemName,activeZone) or string.find(activeZone,location) then 
						--	if itemLink==_addon.lastSurveyUsed then activeSurveyType = surveyType end
						--end
					end	
				end
			end
		end	
	end
	
	for itemId,qty in pairs(houseSurveys) do
		local itemLink = string.format(surveyLinkPattern,itemId)
		local itemName = GetItemLinkName(itemLink)
		local surveyType,location = zo_strsplit(":",itemName)

		if not surveysByType[surveyType] then surveysByType[surveyType] = {} end
		t = surveysByType[surveyType]
		if not t[itemId] then t[itemId] = 0 end
		t[itemId] = t[itemId] + qty 		
	end
	
	local ltxt = ""	
	local surveyReport = {}
	for i=1,#surveyDefs do
		local surveyType = surveyDefs[i][4]
		local orgt = surveysByType[surveyType]
		if orgt then

			--copy inner table for sorting first
			local t = {} 
			for key,v in pairs(orgt) do
				t[#t+1] = { v, key }
			end	
			table.sort(t,function (a,b) return a[1] > b[1] end)

			local totqty = 0
			local craqty = 0
			local cnt = 0
			local slines = ""
			local clines = ""
			local figures = {}

			for _,ti in pairs(t) do
				local qty = ti[1]
				local itemLink = string.format(surveyLinkPattern,ti[2])
				local itemName = GetItemLinkName(itemLink)
				local _,location = zo_strsplit(":",itemName)
				cnt = cnt + 1
				if cnt <= 3 then figures[string.format("%d",cnt)] = ti end			
				--if cnt <= 10 then slines = slines..zo_strformat("  |c0080F0<<1>> |cFFFFFF(<<2>>)\n",location,qty) end
				
				local repline = "|"..zo_strsplit("|",itemLink).."|h"..location.."|h"..string.format(" (%d)",qty).."\n"
				slines = slines..repline
				if string.find(itemName,langCraglorn) then 
					if not figures["4"] then figures["4"] = ti	end	
					craqty = craqty + qty
					clines = clines..repline
				end	
				totqty = totqty + qty
			end	

			figures["0"] = {totqty,""}
			figures["5"] = surveysAtHand[surveyType]
			figures["6"] = {craqty,""}
			
			local stxt = ""
			local showtypef = false
			for j=1,string.len(_addon.surveyFigures) do
				local ch = string.sub(_addon.surveyFigures,j,j)
				if ch>='0' and ch<='9' then
					if stxt~="" then stxt = stxt.."/" end
					local figId = ch
					local t = figures[figId]
					if t then
						if t[1]>0 then showtypef = true end
						--todo: %.2d??? single-digit figures are hard to click...
						if ch=="0" then
							stxt = stxt..string.format("|H1:dcs_total:0:%d|h%d|h",surveyDefs[i][1],t[1])
						elseif ch=="6" then	
							stxt = stxt..string.format("|H1:dcs_cratotal:0:%d|h%d|h",surveyDefs[i][1],t[1])
						else	
							local itemLink = string.format(surveyLinkPattern,t[2])
							stxt = stxt.."|"..zo_strsplit("|",itemLink).."|h"..string.format("%d",t[1]).."|h"
							--if figId=="5" and surveyType==activeSurvey[2] then
							--	stxt = stxt.."*"
							--end	
						end	
					else
						stxt = stxt.."-"
					end
				else
					--stxt = stxt..ch
				end
			end	

			if surveyType==activeSurvey[2] then
				stxt = stxt..string.format(" |cFFD000%d|cFFFFFF",activeSurvey[3])
				showtypef = true
			end	
			
			if showtypef then
				local icon = surveyDefs[i][2]

--[[				
				local blueColor = ZO_ColorDef:New("0000FF")
				local iconStr = "|t24:24:"..icon..":inheritColor|t"
				iconStr = blueColor:Colorize(iconStr)
				ltxt = ltxt..iconStr..stxt.."  "
]]--
				
				ltxt = ltxt.."|t24:24:"..icon.."|t"..stxt.."  "
			end	

			local icon = surveyDefs[i][2]
			surveyReport[surveyDefs[i][1]] = { 
					zo_strformat("|t<<1>>:<<1>>:<<2>>|t <<3>> (<<4>>)",_addon.iconSizes[_addon.uiScale],icon,surveyType,totqty), 
					slines,
					clines
				}
		end	
	end	
	
	if next(surveysAtHand) or #_addon.surveysPickList>0 then
		ltxt = ltxt.."|t16:16:/esoui/art/tooltips/icon_bag.dds|t |c0080F0|H0:dcs_backpack|h[...]|h"	
	end
	
	_addon.surveyReport = surveyReport
	_addon.surveys:SetText(ltxt)
	_addon.updateBackgrounds()
	_addon.updatePosition()
end

local msgWnd = nil

local function DCS_createMsgWnd()
	if msgWnd then return end
	msgWnd = WINDOW_MANAGER:CreateTopLevelWindow(_addon.name.."MsgWnd")
	msgWnd:SetMouseEnabled(true)
	msgWnd:SetMovable(true)
--	msgWnd:SetHidden(false)
	msgWnd:SetClampedToScreen(true)
	msgWnd:SetDimensions(350, 600)
	msgWnd:SetAnchor(CENTER, GuiRoot, CENTER,0,0)
	msgWnd:SetResizeHandleSize(8)
	
	local bg = WINDOW_MANAGER:CreateControl(nil, msgWnd, CT_BACKDROP)
	bg:SetAnchorFill(msgWnd)
	bg:SetCenterColor(0,0,0,1)
	bg:SetEdgeTexture("esoui/art/tooltips/ui-border.dds", 128, 16)

  local cb = WINDOW_MANAGER:CreateControlFromVirtual(nil,msgWnd, "ZO_CloseButton")
  cb:SetHandler("OnClicked", function(...) msgWnd:SetHidden(true) end)

	local title = WINDOW_MANAGER:CreateControl(nil,msgWnd,CT_LABEL)
	title:SetMouseEnabled(false)
	title:SetAnchor(TOPLEFT, msgWnd, TOPLEFT,20,8)
	title:SetAnchor(BOTTOMRIGHT, msgWnd, TOPRIGHT,-20,36)
	title:SetFont("ZoFontGame")
	title:SetText("")

	local divider = WINDOW_MANAGER:CreateControl(nil, msgWnd, CT_TEXTURE)
	divider:SetDimensions(4,8)
	divider:SetAnchor(TOPLEFT,msgWnd,TOPLEFT,20,36)
	divider:SetAnchor(TOPRIGHT,msgWnd,TOPRIGHT,-20,40)
	divider:SetTexture("esoui/art/miscellaneous/horizontaldivider.dds")

	local buffer = WINDOW_MANAGER:CreateControl(nil, msgWnd, CT_TEXTBUFFER)
	buffer:SetMaxHistoryLines(1000)
	buffer:SetMouseEnabled(true)
	buffer:SetLinkEnabled(true)
	buffer:SetAnchor(TOPLEFT, msgWnd, TOPLEFT,20,60)
	buffer:SetAnchor(BOTTOMRIGHT, msgWnd, BOTTOMRIGHT,-20,-20)
	buffer:SetFont("ZoFontGame")
	buffer:SetHandler("OnLinkClicked", function(...) _addon.surveyLinkClicked(...)  end)
	buffer:SetHandler("OnMouseWheel", function(_, delta) buffer:SetScrollPosition(buffer:GetScrollPosition() + delta)	end)	

  local scrolldown = WINDOW_MANAGER:CreateControlFromVirtual(nil,msgWnd, "ZO_ScrollDownButton")
	scrolldown:SetAnchor(TOP, buffer, BOTTOM, -16, 0)
	scrolldown:SetHandler("OnClicked", function(...) buffer:SetScrollPosition(buffer:GetScrollPosition() - 1) end)

  local scrollup = WINDOW_MANAGER:CreateControlFromVirtual(nil,msgWnd, "ZO_ScrollUpButton")
	scrollup:SetAnchor(BOTTOM, msgWnd, BOTTOM, 16, -4)
	scrollup:SetHandler("OnClicked", function(...) buffer:SetScrollPosition(buffer:GetScrollPosition() + 1) end)

	buffer._setText = function(s) 
			buffer:Clear()
			buffer:AddMessage(s)
			local vpad = buffer:GetNumVisibleLines() - buffer:GetNumHistoryLines() - 1
			if vpad > 0 then buffer:AddMessage(string.rep("|c000000\n",vpad)) end --adding empty strings won't work
			buffer:SetScrollPosition(buffer:GetNumHistoryLines()-buffer:GetNumVisibleLines())
			scrolldown:SetHidden(vpad > 0)
			scrollup:SetHidden(vpad > 0)
		end

	msgWnd.title = title
	msgWnd.buffer = buffer
end

function _addon.surveyLinkClicked(control,linkData,linkText,button)  
	local _, _, linkType,itemId,subType = ZO_LinkHandler_ParseLink(linkText)
	itemId = tonumber(itemId)
	subType = tonumber(subType)
	
	if linkType=="dcs_total" then
		if _addon.surveyReport[subType] then   
			DCS_createMsgWnd()
			msgWnd.title:SetText(_addon.surveyReport[subType][1])
			msgWnd.buffer._setText(_addon.surveyReport[subType][2])
			msgWnd:SetHidden(false)
		end
		return
	end	

	if linkType=="dcs_cratotal" then
		if _addon.surveyReport[subType] then   
			DCS_createMsgWnd()
			msgWnd.title:SetText(_addon.surveyReport[subType][1])
			msgWnd.buffer._setText(_addon.surveyReport[subType][3])
			msgWnd:SetHidden(false)
		end
		return
	end	

	if linkType=="dcs_backpack" then
		DCS_createMsgWnd()
		msgWnd.title:SetText("|t24:24:/esoui/art/tooltips/icon_bag.dds|t ...")
		msgWnd.buffer._setText(DCS_getBackpackSurveys())
		msgWnd:SetHidden(false)
		return
	end	

	if linkType=="dcs_picklist" then
		local t = _addon.surveysPickList
		for i=#t,1,-1 do
			if t[i]==itemId then
				table.remove(t,i)
				i = -1
			end
		end	
		msgWnd.buffer._setText(DCS_getBackpackSurveys())
		return
	end	
	
	if button==MOUSE_BUTTON_INDEX_RIGHT then
		if itemId>0 then
			ClearMenu()
			DCS_AddMenuItem(_translate("Pick Up Survey"), function() 
					if not _addon.surveysPickList then _addon.surveysPickList = {} end
					if AddUniqueItemIdToList(_addon.surveysPickList,itemId) then
						local itemLink = string.format(surveyLinkPattern,itemId)
						_out(itemLink.." added to pick list")
						_addon.updateSurveys()
					end	
				end)
			if #_addon.surveysPickList>0 then 	
				DCS_AddMenuItem(_translate("Clear Survey Pick List"), function() 
						_addon.surveysPickList = {}
						_out("survey pick list cleared")
						_addon.updateSurveys()
					end)
			end  		
			ShowMenu()
		end	
	else	
		ZO_LinkHandler_OnLinkClicked(linkText, button) 
	end	
end