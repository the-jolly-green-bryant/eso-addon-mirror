-- SnapShot Pre-Coding -------------------------------------------------------------------------

SnapShot            = SnapShot or {}
SnapShot.name       = "SnapShot"

BAG_MAIL = 100 -- Extensible inventory container for mail items
BAG_PLAYER_HOUSE = 200 -- Extensible inventory container for placed furniture
OT_ITEM_ID_MAX = 204548  -- Highest itemId value

SnapShot.ReportName = ""

SnapShot.MAX_LOOTS  = 2000                                                 -- Maximum size of SnapShot.Loots

SnapShot.PageCount  = 1
SnapShot.PageLength = 500
SnapShot.PageNum    = 1

SnapShot.Header     = {}                                                                    -- Output Header
SnapShot.Lines      = {}                                                             -- Output Display Lines

SnapShot.Loots      = {}                                                            -- List of gathered loot
SnapShot.Stuff      = {}                                                                    -- Data Raw List
SnapShot.StuffXT    = {}                                                           -- Extended Data Raw List

SnapShot.History    = { {},{},{},{},{} }                                 -- Guild Event History Entry Guilds
for ix=1,5 do SnapShot.History[ix] = { {},{},{},{},{} } end                -- Guild Event History Categories

OT_Recipes = {} -- Recipe Id numbers by Recipe List/Index
OT_Styles     = {}       --[[ Style Info by StyleId number
	*string* _name_
	*number* _achievement_
	*number* _criterion_
	*number* _loreCollection_
	*number* _loreBook_
	*number* _loreChapter_
	*string* _motifId_
]]

if GetString("OT_BAG",0)=="" then -- Create OT_BAG name strings.
  local n
  ZO_CreateStringId("OT_BAG"..BAG_BACKPACK,"Backpack")
  ZO_CreateStringId("OT_BAG"..BAG_BANK,"Bank")
  ZO_CreateStringId("OT_BAG"..BAG_BUYBACK,"Buyback")
  ZO_CreateStringId("OT_BAG"..BAG_COMPANION_WORN,"Companion")
  ZO_CreateStringId("OT_BAG"..BAG_GUILDBANK,"Guild Bank")
  ZO_CreateStringId("OT_BAG"..BAG_HOUSE_BANK_ONE,"Storage 1")
  ZO_CreateStringId("OT_BAG"..BAG_HOUSE_BANK_TWO,"Storage 2")
  ZO_CreateStringId("OT_BAG"..BAG_HOUSE_BANK_THREE,"Storage 3")
  ZO_CreateStringId("OT_BAG"..BAG_HOUSE_BANK_FOUR,"Storage 4")
  ZO_CreateStringId("OT_BAG"..BAG_HOUSE_BANK_FIVE,"Storage 5")
  ZO_CreateStringId("OT_BAG"..BAG_HOUSE_BANK_SIX,"Storage 6")
  ZO_CreateStringId("OT_BAG"..BAG_HOUSE_BANK_SEVEN,"Storage 7")
  ZO_CreateStringId("OT_BAG"..BAG_HOUSE_BANK_EIGHT,"Storage 8")
  ZO_CreateStringId("OT_BAG"..BAG_HOUSE_BANK_NINE,"Storage 9")
  ZO_CreateStringId("OT_BAG"..BAG_HOUSE_BANK_TEN,"Storage 10")
  ZO_CreateStringId("OT_BAG"..BAG_SUBSCRIBER_BANK,"Bank")
  ZO_CreateStringId("OT_BAG"..BAG_VIRTUAL,"Craft Bag")
  ZO_CreateStringId("OT_BAG"..BAG_WORN,"Equipped")
  if BAG_MAIL         then ZO_CreateStringId("OT_BAG"..BAG_MAIL,"Mail") end
  if BAG_PLAYER_HOUSE then ZO_CreateStringId("OT_BAG"..BAG_PLAYER_HOUSE,"House") end
end

function OT_CleanNumberList(listString) -- Extracts and sorts a list of numbers from a string.
	if not listString then return {} end
	local list = {}
	for s in string.gmatch(listString,"%d+") do table.insert(list,tonumber(s)) end
	table.sort(list)
	local i = 1
	while i < #list do
		while i < #list and list[i+1] == list[i] do
			table.remove(list,i+1)
		end
		i = i+1
	end
	return table.concat(list," ")
end

function OT_GetBagName(bagId)
  if bagId < BAG_MAIL then return GetString("OT_BAG",bagId) end
  if bagId < BAG_PLAYER_HOUSE then return GetString("OT_BAG",BAG_MAIL) end
  return GetString("OT_BAG",BAG_PLAYER_HOUSE)
end

function OT_GetGuildNameFromIndex(guildNum)
	if guildNum < 1 or guildNum > GetNumGuilds() then return "" end
	return GetGuildName(GetGuildId(guildNum))
end

function OT_GetItemTypeName(itemType) -- Sunsetted by direct coding
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

function OT_GetLinkName(link) -- Sunsetted by direct coding
	if not link or #link < 5 then return "" end
	if link:sub(5,8) == 'coll' then
		return zo_strformat(SI_TOOLTIP_ITEM_NAME,GetCollectibleName(GetCollectibleIdFromLink(link)))
	end
	if link:sub(5,8) == 'curr' then
		local currT = tonumber(link:match('%d+',5))
		return zo_strformat(SI_TOOLTIP_ITEM_NAME,GetCurrencyName(currT))
	end
	return zo_strformat(SI_TOOLTIP_ITEM_NAME,GetItemLinkName(link))
end

function OT_GetPriceATT(itemLink) -- ATT Sales Average.
	local value = 0
	if ArkadiusTradeTools
    and ArkadiusTradeTools.Modules
    and ArkadiusTradeTools.Modules.Sales
    and ArkadiusTradeTools.Modules.Sales.addMenuItems
    then value = ArkadiusTradeTools.Modules.Sales:GetAveragePricePerItem(itemLink,0)
	end
	return OT_TrimDecimals(value)
end

function OT_GetPriceMM(itemLink) -- MM Sales Average. Last checked 2024 Feb 29
	local value = 0
	if MasterMerchant then value = MasterMerchant.GetItemLinePrice(itemLink) or 0 end
	return OT_TrimDecimals(value)
end

function OT_GetPriceTTC(itemLink,cat) -- TTC Sales. Last checked 2024 Feb 29
	local value = 0
	if TamrielTradeCentre then
		local iTTC = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
		if iTTC then
      if     cat=="Avg" then value = (iTTC.Avg or 0)
      elseif cat=="Sale" then value = (iTTC.SaleAvg or 0)
      elseif cat=="Sugg" then value = (iTTC.SuggestedPrice or 0) * 1.25
      end
		end
	end
	return OT_TrimDecimals(value)
end

function OT_GetSmithingTraitItemName(traitIndex)
	local ix,traitraitIndex,traitItem = 1,0,""
	repeat
		traitraitIndex,traitItem = GetSmithingTraitItemInfo(ix)
		ix = ix+1
	until traitraitIndex == traitIndex or ix > ITEM_TRAIT_TYPE_MAX_VALUE+1
	if traitraitIndex ~= traitIndex then traitItem = "" end
	return zo_strformat(SI_TOOLTIP_ITEM_NAME,traitItem)
end

function OT_GetStyleBookIndex(itemStyleId,itemStyleChapter)
	if OT_Styles[itemStyleId] then
		local id,ch = itemStyleId,itemStyleChapter or 0
		if ch < 0 or ch > 14 then ch = 0 end
		if ch == 0
			then return 2,OT_Styles[id].loreCollection,OT_Styles[id].loreBook
			else return 2,OT_Styles[id].loreChapter,ch
		end
	end
	return 0,0,0
end

function OT_GetStyleIdFromName(styleName)
	if styleName == "Order Hour" then styleName = "Order of the Hour" end
	if styleName == "Psijic"     then styleName = "Psijic Order"      end
	if styleName == "Moongrave"  then styleName = "Moongrave Fane"    end
	for i = 1,#OT_Styles do
		if OT_Styles[i].name == styleName then return i end
	end
	return 0
end

function OT_Hash2Link(hash) -- Converts a link hash back to a link
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

function OT_IsButtonPressed(uiObject)
	if uiObject and uiObject:GetState() then return uiObject:GetState()==BSTATE_PRESSED end
	return false
end

function OT_Link2Hash(link) -- Converts a link to a compressed hash value
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

function OT_MakeRecipeList(maxNum)
  if maxNum == nil then maxNum = OT_ITEM_ID_MAX end
	local itemTemplate = "|H1:item:%s:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
	local matList = ":10:11:27:28:31:33:35:36:37:38:39:40:41:42:43:44:45:46:51:52:53:58:"
		.."62:63:64:65:66:66:67:68:"
	for i = 1,GetNumRecipeLists() do
		OT_Recipes[i] = {}
		local _,recipeListLength = GetRecipeListInfo(i)
		for j = 1,recipeListLength do
			OT_Recipes[i][j] = 0
		end
	end
	for i=1,maxNum do
		local itemLink = string.format(itemTemplate,i)
		local itemType,_ = GetItemLinkItemType(itemLink)
		itemType = string.format(":%s:",itemType)
		if itemType == ":29:" then
			local rList,rIndex = GetItemLinkGrantedRecipeIndices(itemLink)
			if OT_Recipes[rList][rIndex] < 1 then OT_Recipes[rList][rIndex] = i end
		end
	end
end

function OT_MakeStyleList()
	local function SetCriterionForGroupStyles(achievementId)
		local c,id
		for i=1,GetAchievementNumCriteria(achievementId) do
			c = GetAchievementCriterion(achievementId,i)
			c = string.match(c,"the (.+) Racial")
			if c == "Primitive" then c = "Primal" end -- Manual Correction
			id = OT_GetStyleIdFromName(c)
			if id > 0 then
				OT_Styles[id].achievement = achievementId
				OT_Styles[id].criterion = c
			end
		end
	end

	for i=1,GetHighestItemStyleId() do
		OT_Styles[i] = {
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
			id = OT_GetStyleIdFromName(c)
			if id > 0 then OT_Styles[id].achievement = i end
		end
	end
	for i=1,14 do  -- Alliance/Rare Styles Lorebooks
		local s,id
		s = string.match(GetLoreBookInfo(2,1,i+2),": (.+) Style")
		id = OT_GetStyleIdFromName(s)
		if id > 0 then
			OT_Styles[id].loreCollection = 1
			OT_Styles[id].loreBook = i+2
			OT_Styles[id].motifId = string.format("%s",i)
		end
	end
	do local dwemer = 14                                                 -- Manual Correction
		OT_Styles[dwemer].loreCollection = 3
		OT_Styles[dwemer].loreBook = 1
		OT_Styles[dwemer].loreChapter = 2
		OT_Styles[dwemer].motifId = "15"
	end
	do local shriven = 30                                                -- Manual Correction
		OT_Styles[shriven].loreCollection = 3
		OT_Styles[shriven].loreBook = 1
		OT_Styles[shriven].loreChapter = 2
		OT_Styles[shriven].motifId = "29"
	end
	i = 2; a = GetLoreBookInfo(2,3,i); repeat                            -- Motif Lorebooks
		id = OT_GetStyleIdFromName(string.match(a,": (.+) Sty"))
		if id > 0 then
			OT_Styles[id].loreCollection = 3
			OT_Styles[id].loreBook = i
			OT_Styles[id].motifId = string.match(a,"Motif (.+):") or ""
		end
		i = i+1; a = GetLoreBookInfo(2,3,i)
	until #a < 1
	i = 4; a = GetLoreBookInfo(2,i,1); repeat                            -- Motif Chapter Books
		id = OT_GetStyleIdFromName(string.match(a,": (.+) Axes"))
		if id > 0 then
			if OT_Styles[id].motif == "" then
				OT_Styles[id].motif = string.match(a,"Motif (.+):") or ""
			end
			OT_Styles[id].loreChapter = i
		end
		i = i+1; a = GetLoreBookInfo(2,i,1)
	until #a < 1
end

function OT_TrimDecimals(num)                                                                 -- 2021/09/19
	num = num or 0
	if num > 0 and num < 10 then return math.floor(num*100+0.5)/100 end
	if num > 0 and num < 100 then return math.floor(num*10+0.5)/10 end
	return math.floor(num+0.5)
end

function OT_UIText(uiObject)
	if uiObject and uiObject:GetText() then return uiObject:GetText() else return "" end
end
