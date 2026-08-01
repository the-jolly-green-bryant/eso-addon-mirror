--[[ LibOT : Obersver Tim's Extensions to the ESO API, encapsulated in OTX object.                        ]]

OTX_ITEM_ID_MIN = 70      -- Lowest itemId value
OTX_ITEM_ID_MAX = 200000  -- Highest itemId value

OTX = {}
OTX.name       = "LibOT"  -- Library name
OTX.Recipes    = {}       -- Recipe Id numbers by Recipe List/Index
OTX.Styles     = {}       --[[ Style Info by StyleId number
	*string* _name_
	*number* _achievement_
	*number* _criterion_
	*number* _loreCollection_
	*number* _loreBook_
	*number* _loreChapter_
	*string* _motifId_
]]

local BAG_HOUSE = 1000  -- Base bagId for houses
local BAG_MAIL  = 100   -- Base base bagId for mail attachments

-- =========================================================================================================

function OTX.ButtonArraySetAll(uiObject,loVal,hiVal,bState,locked)                        -- nref 2021/10/13
	if not uiOject or not loVal or not hiVal or not bState then return end
	if not locked then locked = false end
	for i=loVal,hiVal do
		local tObject = GetControl(uiObject:GetName(),i)
		if tObject then tObject:SetState(bState,locked) end
	end
end

function OTX.CleanNumberList(listString)                                                       -- 2021/10/13
	if not listString then return {} end
	local tList = {}
	for s in string.gmatch(listString,"%d+") do table.insert(tList,tonumber(s)) end
	table.sort(tList)
	local i = 1
	while i < #tList do
		while i < #tList and tList[i+1] == tList[i] do
			table.remove(tList,i+1)
		end
		i = i+1
	end
	return table.concat(tList," ")
end

function OTX.CleanString(aString)                                                              -- 2021/10/13
	return zo_strformat(SI_TOOLTIP_ITEM_NAME,aString)
end

function OTX.DoSomething(uiObject)                                                        -- nref 2021/10/16
	if uiObject then d(uiObject:GetName()) end
end

function OTX.GetBagName(bagId)                                                                 -- 2021/10/13
  if bagId<BAG_MAIL then return GetString("OTX_BAG",bagId)
    elseif bagId < BAG_MAIL+100 then return "Mail"
    elseif bagId >= BAG_HOUSE then return "House"
  end
end

function OTX.GetGuildNameFromIndex(guildNum)                                                   -- 2021/10/13
	if guildNum < 1 or guildNum > GetNumGuilds() then return "" end
	return GetGuildName(GetGuildId(guildNum))
end

function OTX.GetHashFromLink(link)                                                             -- 2021/09/19
	if not link then return end
	local format = string.format
	local linkTable = {}
	local hash = ""
	for l in string.gmatch(link,":([^:|]+)") do table.insert(linkTable,l) end
	if       linkTable[1] == "achievement" then hash = "A"
		elseif linkTable[1] == "book"        then hash = "B"
		elseif linkTable[1] == "collectible" then hash = "C"
		elseif linkTable[1] == "guild"       then hash = "G"
		elseif linkTable[1] == "item"        then hash = "I"
		elseif linkTable[1] == "quest_item"  then hash = "Q"
		elseif linkTable[1] == "currency"    then hash = "R"
		else   hash = format("?%s",string.lower(linkTable[1]))
	end
	for i = 2,#linkTable do
		local digits = "0123456789abcdefghijklmnopqrstuvwxyz"
		local fields = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		if #linkTable[i] > 9 then
			val = linkTable[i]
			hash = format("%s%s%s",hash,fields:sub(i-1,i-1),val)
		else
			local field = tonumber(linkTable[i])
			if field > 0 then
				local val = ""
				while field > 0 do
					val = format("%s%s",digits:sub((field % 36)+1,(field % 36)+1),val)
					field = math.floor(field/36)
				end
				hash = format("%s%s%s",hash,fields:sub(i-1,i-1),val)
			end
		end
	end
	if hash:sub(1,1) == "G" then hash = format("%s:%s",hash,link:match("|h(.+)|h")) end
	return hash
end

function OTX.GetHouseLink(houseId,linkStyle)                                              -- nref 2021/10/16
	if linkStyle ~= LINK_STYLE_BRACKETS then linkStyle = LINK_STYLE_DEFAULT end
	local coll = GetCollectibleIdForHouse(houseId)
	if coll > 0 then return GetCollectibleLink(coll,linkStyle) end
	return nil
end

function OTX.GetHouseName(houseId)                                                        -- nref 2021/10/15
	local zoneId = GetHouseZoneId(houseId)
	if zoneId > 0 then return GetZoneNameById(zoneId) end
	return ""
end

function OTX.GetItemLinkWritVouchers(itemLink)                                                 -- 2021/10/12
	if GetItemLinkItemType(itemLink) ~= ITEMTYPE_MASTER_WRIT then return 0 end
	return math.floor(((string.match(itemLink,"(%d+)|") or 0)+5000)/10000)
end

function OTX.GetItemTypeName(itemType) -- Sunsetted by direct coding
	if itemType < 1 or itemType > ITEMTYPE_MAX_VALUE then itemType = 0 end
	local itemText = GetString("SI_ITEMTYPE",itemType)
	if itemType == ITEMTYPE_BLACKSMITHING_MATERIAL       then itemText = "Smithing Mat" end
	if itemType == ITEMTYPE_BLACKSMITHING_RAW_MATERIAL   then itemText = "Raw Smithing" end
	if itemType == ITEMTYPE_CLOTHIER_MATERIAL            then itemText = "Clothing Mat" end
	if itemType == ITEMTYPE_CLOTHIER_RAW_MATERIAL        then itemText = "Raw Clothing" end
	if itemType == ITEMTYPE_JEWELRYCRAFTING_MATERIAL     then itemText = "Jewelry Mat" end
	if itemType == ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL then itemText = "Raw Jewelry" end
	if itemType == ITEMTYPE_RAW_MATERIAL                 then itemText = "Raw Style" end
	if itemType == ITEMTYPE_WOODWORKING_MATERIAL         then itemText = "Woodworking Mat" end
	if itemType == ITEMTYPE_WOODWORKING_RAW_MATERIAL     then itemText = "Raw Woodworking" end
	return itemText
end

function OTX.GetLinkFromHash(hash)                                                             -- 2021/09/19
	local function Fetch(s)
		local val = hash:sub(2):match(s) or "0"
		if #val < 10 then val = tonumber(val,36) end
		return val
	end
	if not hash then return end
	local format = string.format
	local linkTable = {0}
	local a = Fetch("A([^%u]+)")
	if hash:sub(1,1) == "A" then
		link = format("|H1:achievement:%s:%s:%s|h|h",a,Fetch("B([^%u]+)"),Fetch("C([^%u]+)"))
	elseif hash:sub(1,1) == "B" then link = format("|H1:book:%s|h|h",a)
	elseif hash:sub(1,1) == "C" then link = format("|H1:collectible:%s|h|h",a)
	elseif hash:sub(1,1) == "G" then
		link = format("|H1:guild:%s|h%s|h",Fetch("A([^%u]+):"),hash:match(":(.+)"))
	elseif hash:sub(1,1) == "I" then
		link = format("|H1:item:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s|h|h",a,
			Fetch("B([^%u]+)"),Fetch("C([^%u]+)"),Fetch("D([^%u]+)"),Fetch("E([^%u]+)"),Fetch("F([^%u]+)"),
			Fetch("G([^%u]+)"),Fetch("H([^%u]+)"),Fetch("I([^%u]+)"),Fetch("J([^%u]+)"),Fetch("K([^%u]+)"),
			Fetch("L([^%u]+)"),Fetch("M([^%u]+)"),Fetch("N([^%u]+)"),Fetch("O([^%u]+)"),Fetch("P([^%u]+)"),
			Fetch("Q([^%u]+)"),Fetch("R([^%u]+)"),Fetch("S([^%u]+)"),Fetch("T([^%u]+)"),Fetch("U([^%u]+)"))
	elseif hash:sub(1,1) == "Q" then link = format("|H1:quest_item:%s|h|h",a)
	elseif hash:sub(1,1) == "R" then link = format("|H1:currency:%s|h|h",a)
	end
	return link
end

function OTX.GetLinkName(link)         -- Sunsetted by direct coding
	if not link or #link < 5 then return "" end
	if link:sub(5,8) == 'coll' then
		return OTX.CleanString(GetCollectibleName(GetCollectibleIdFromLink(link)))
	end
	if link:sub(5,8) == 'curr' then
		local currT = tonumber(link:match('%d+',5))
		return OTX.CleanString(GetCurrencyName(currT))
	end
	return OTX.CleanString(GetItemLinkName(link))
end
function OTX.GetPriceATT(itemLink)     -- Sunsetted by OT_GetPriceATT
	local value = 0
	if ArkadiusTradeTools
    and ArkadiusTradeTools.Modules
    and ArkadiusTradeTools.Modules.Sales
    and ArkadiusTradeTools.Modules.Sales.addMenuItems
    then value = ArkadiusTradeTools.Modules.Sales:GetAveragePricePerItem(itemLink,0)
	end
	return OTX.TrimDecimals(value)
end
function OTX.GetPriceMM(itemLink)      -- Sunsetted by OT_GetPriceMM
	local value = 0
	if MasterMerchant then value = MasterMerchant.GetItemLinePrice(itemLink) or 0 end
	return OTX.TrimDecimals(value)
end

function OTX.GetPriceTTC(itemLink,avgPrice)                                                    -- 2021/09/19
	local value = 0
	if TamrielTradeCentre then
		local iTTC = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
		if iTTC then
			if avgPrice
				then value = (iTTC.Avg or 0)
				else value = (iTTC.SuggestedPrice or 0) * 1.25
			end
		end
	end
	return OTX.TrimDecimals(value)
  -- iTTC.SaleAvg
end

function OTX.GetStyleBookIndex(itemStyleId,itemStyleChapter)                                   -- 2021/10/11
	if OTX.Styles[itemStyleId] then
		local id,ch = itemStyleId,itemStyleChapter or 0
		if ch < 0 or ch > 14 then ch = 0 end
		if ch == 0
			then return 2,OTX.Styles[id].loreCollection,OTX.Styles[id].loreBook
			else return 2,OTX.Styles[id].loreChapter,ch
		end
	end
	return 0,0,0
end

function OTX.GetStyleIdFromMotif(motif)                                                   -- nref 2021/10/16
	for ix = 1,#OTX.Styles do
		if OTX.Styles[ix].motifId == motif then return ix end
	end
	return ""
end

function OTX.GetStyleIdFromName(styleName)                                                     -- 2021/10/11
	if styleName == "Order Hour" then styleName = "Order of the Hour" end
	if styleName == "Psijic"     then styleName = "Psijic Order"      end
	if styleName == "Moongrave"  then styleName = "Moongrave Fane"    end
	for i = 1,#OTX.Styles do
		if OTX.Styles[i].name == styleName then return i end
	end
	return 0
end

function OTX.GetSmithingTraitItemName(traitIndex)                                              -- 2021/10/12
	local ix,traitraitIndex,traitItem = 1,0,""
	repeat
		traitraitIndex,traitItem = GetSmithingTraitItemInfo(ix)
		ix = ix+1
	until traitraitIndex == traitIndex or ix > ITEM_TRAIT_TYPE_MAX_VALUE+1
	if traitraitIndex ~= traitIndex then traitItem = "" end
	return OTX.CleanString(traitItem)
end

function OTX.GetText(uiObject)                                                                 -- 2021/10/13
	if uiObject and uiObject:GetText() then return uiObject:GetText() else return "" end
end

function OTX.IsButtonPressed(uiObject)                                                         -- 2021/10/13
	if uiObject and uiObject:GetState() then return uiObject:GetState()==BSTATE_PRESSED end
	return false
end

function OTX.IsHouseOwned(houseId)                                                        -- nref 2021/10/15
	local cId = GetCollectibleIdForHouse(houseId)
	if cId > 0 then return IsCollectibleUnlocked(cId) end
	return false
end

function OTX.IsItemStyleKnown(itemStyleId,itemStyleChapter)                               -- nref 2021/10/16
	if not itemStyleId then return false end
	if OTX.Styles[itemStyleId].motifId == "" then return false end

	local chapter = itemStyleChapter or 0
	local record = OTX.Styles[itemStyleId]
	if chapter < 1 or chapter > 14 then chapter = 0 end
	
	local known = 0
	if record.achievement > 0 and criterion > 0 then
		_,known = GetAchievementCriterion(record.achievement,record.criterion)
	elseif record.achievement > 0 then
		if chapter > 0
			then _,known = GetAchievementCriterion(record.achievement,chapter)
			else known = IsAchievementComplete(record.achievement) and 1 or 0
		end
	elseif record.loreBook > 0 then
		local cat,coll,book = OTX.GetStyleBookIndex(itemStyleId,chapter)
		_,_,known = GetLoreBookInfo(cat,coll,book) and 1 or 0
	end
	return (known > 0)
end

function OTX.MakeBagNames()                                                                    -- 2021/10/13
	ZO_CreateStringId("OTX_BAG0",  "Equipped")
	ZO_CreateStringId("OTX_BAG1",  "Backpack")
	ZO_CreateStringId("OTX_BAG2",  "Bank")
	ZO_CreateStringId("OTX_BAG3",  "Guild")
	ZO_CreateStringId("OTX_BAG4",  "Buyback")
	ZO_CreateStringId("OTX_BAG5",  "Craft")
	ZO_CreateStringId("OTX_BAG6",  "Bank")
	ZO_CreateStringId("OTX_BAG7",  "Storage 1")
	ZO_CreateStringId("OTX_BAG8",  "Storage 2")
	ZO_CreateStringId("OTX_BAG9",  "Storage 3")
	ZO_CreateStringId("OTX_BAG10", "Storage 4")
	ZO_CreateStringId("OTX_BAG11", "Storage 5")
	ZO_CreateStringId("OTX_BAG12", "Storage 6")
	ZO_CreateStringId("OTX_BAG13", "Storage 7")
	ZO_CreateStringId("OTX_BAG14", "Storage 8")
	ZO_CreateStringId("OTX_BAG15", "Storage 9")
	ZO_CreateStringId("OTX_BAG16", "Storage 10")
	ZO_CreateStringId("OTX_BAG17", "Delete")
end

function OTX.MakeRecipeList(maxNum)                                                                  -- 2021/10/15
  if maxNum == nil then maxNum = OTX_ITEM_ID_MAX end
	local itemTemplate = "|H1:item:%s:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
	local matList = ":10:11:27:28:31:33:35:36:37:38:39:40:41:42:43:44:45:46:51:52:53:58:"
		.."62:63:64:65:66:66:67:68:"
	for i = 1,GetNumRecipeLists() do
		OTX.Recipes[i] = {}
		local _,recipeListLength = GetRecipeListInfo(i)
		for j = 1,recipeListLength do
			OTX.Recipes[i][j] = 0
		end
	end
	for i=OTX_ITEM_ID_MIN,maxNum do
		local itemLink = string.format(itemTemplate,i)
		local itemType,_ = GetItemLinkItemType(itemLink)
		itemType = string.format(":%s:",itemType)
		if itemType == ":29:" then
			local rList,rIndex = GetItemLinkGrantedRecipeIndices(itemLink)
			if OTX.Recipes[rList][rIndex] < 1 then OTX.Recipes[rList][rIndex] = i end
		end
	end
end

function OTX.MakeStyleList()                                                                   -- 2021/10/11
	local function SetCriterionForGroupStyles(achievementId)
		local c,id
		for i=1,GetAchievementNumCriteria(achievementId) do
			c = GetAchievementCriterion(achievementId,i)
			c = string.match(c,"the (.+) Racial")
			if c == "Primitive" then c = "Primal" end -- Manual Correction
			id = OTX.GetStyleIdFromName(c)
			if id > 0 then
				OTX.Styles[id].achievement = achievementId
				OTX.Styles[id].criterion = c
			end
		end
	end

	for i=1,GetHighestItemStyleId() do
		OTX.Styles[i] = {
			name           = GetItemStyleName(i) or "",
			achievement    = 0,
			criterion      = 0,
			loreCollection = 0,
			loreBook       = 0,
			loreChapter    = 0,
			motifId        = ""
		}
	end
	SetCriterionForGroupStyles(1030)  -- Alliance Styles Achievements
	SetCriterionForGroupStyles(1043)  -- Rare Styles Achievements
	for i=1100,MAX_ACHIEVEMENTS do
		local c,id
		c = GetAchievementName(i)
		if c == "Happy Work For Hollowjack" then  -- Manual Correction
			c = "Hollowjack Style Master"
		end
		if string.find(c,"Style Master") then
			c = string.match(c,"(.+) Style")
			id = OTX.GetStyleIdFromName(c)
			if id > 0 then OTX.Styles[id].achievement = i end
		end
	end
	for i=1,14 do  -- Alliance/Rare Styles Lorebooks
		local s,id
		s = string.match(GetLoreBookInfo(2,1,i+2),": (.+) Style")
		id = OTX.GetStyleIdFromName(s)
		if id > 0 then
			OTX.Styles[id].loreCollection = 1
			OTX.Styles[id].loreBook = i+2
			OTX.Styles[id].motifId = string.format("%s",i)
		end
	end
	do local dwemer = 14                                                 -- Manual Correction
		OTX.Styles[dwemer].loreCollection = 3
		OTX.Styles[dwemer].loreBook = 1
		OTX.Styles[dwemer].loreChapter = 2
		OTX.Styles[dwemer].motifId = "15"
	end
	do local shriven = 30                                                -- Manual Correction
		OTX.Styles[shriven].loreCollection = 3
		OTX.Styles[shriven].loreBook = 1
		OTX.Styles[shriven].loreChapter = 2
		OTX.Styles[shriven].motifId = "29"
	end
	i = 2; a = GetLoreBookInfo(2,3,i); repeat                            -- Motif Lorebooks
		id = OTX.GetStyleIdFromName(string.match(a,": (.+) Sty"))
		if id > 0 then
			OTX.Styles[id].loreCollection = 3
			OTX.Styles[id].loreBook = i
			OTX.Styles[id].motifId = string.match(a,"Motif (.+):") or ""
		end
		i = i+1; a = GetLoreBookInfo(2,3,i)
	until #a < 1
	i = 4; a = GetLoreBookInfo(2,i,1); repeat                            -- Motif Chapter Books
		id = OTX.GetStyleIdFromName(string.match(a,": (.+) Axes"))
		if id > 0 then
			if OTX.Styles[id].motif == "" then
				OTX.Styles[id].motif = string.match(a,"Motif (.+):") or ""
			end
			OTX.Styles[id].loreChapter = i
		end
		i = i+1; a = GetLoreBookInfo(2,i,1)
	until #a < 1
end

function OTX.RadioButtonGet(uiObject,loVal,hiVal)                                         -- nref 2021/10/13
	if not uiObject or not loVal or not hiVal then return 0 end
	for i=loVal,hiVal do
		if OTX.IsButtonPressed(GetControl(uiObject:GetName(),i)) then return i end
	end
	return 0
end

function OTX.RadioButtonSet(uiObject,loVal,hiVal,picked)                                  -- nref 2021/10/13
	if not uiObject or not loVal or not hiVal or not picked then return end
	for i=loVal,hiVal do
		local tObject = GetControl(uiObject:GetName(),i)
		if tObject and i==picked
			then tObject:SetState(BSTATE_PRESSED,false)
			else tObject:SetState(BSTATE_NORMAL,false)
		end
	end
end

function OTX.SetToolTip(uiObject, toolTipText)                                                 -- 2021/10/16
	if not uiObject then return end
	uiObject:SetMouseEnabled(true)
	uiObject:SetHandler(
		"OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, toolTipText) end
	)
	uiObject:SetHandler("OnMouseExit", function(self) ZO_Tooltips_HideTextTooltip() end )
end

function OTX.ToggleVisible(uiObject)                                                           -- 2021/10/03
	uiObject:SetHidden(not uiObject:IsHidden())
end

function OTX.TrimDecimals(num)                                                                 -- 2021/09/19
	num = num or 0
	if num > 0 and num < 10 then return math.floor(num*100+0.5)/100 end
	if num > 0 and num < 100 then return math.floor(num*10+0.5)/10 end
	return math.floor(num+0.5)
end

-- =========================================================================================================

function OTX.AddonLoaded(event,addonName)                                                      -- 2021/10/04
	if addonName ~= "LibOT" then return end
	EVENT_MANAGER:UnregisterForEvent(OTX.name,EVENT_ADD_ON_LOADED)
	OTX.MakeBagNames()
	OTX.MakeStyleList()
end

EVENT_MANAGER:RegisterForEvent(OTX.name,EVENT_ADD_ON_LOADED,OTX.AddonLoaded)

-- =========================================================================================================
