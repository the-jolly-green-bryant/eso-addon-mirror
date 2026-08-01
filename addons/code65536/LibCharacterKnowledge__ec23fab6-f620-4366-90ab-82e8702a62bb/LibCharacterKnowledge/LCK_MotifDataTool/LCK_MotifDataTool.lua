--------------------------------------------------------------------------------
-- This tool generates the motif data for LCK's CuratedData.lua, and is intended
-- for use only by an addon developer for the maintenance of LCK. While the code
-- for this tool is now included in LCK, it is disabled and will not load unless
-- manually enabled by renaming the manifest.
--
-- The bitfield structures are defined in Internal.LoadMotifData()
--
-- Usage: Invoke /lckstyles, then /reloadui, then look in SavedVariables.
--------------------------------------------------------------------------------


local LCCC = LibCodesCommonCode
local LCK = LibCharacterKnowledge
local LMAA = LibMultiAccountAchievements
local Data, Styles, ChapterNames, CrownNumbers, Achievements, BookIds
local NameAdjustments, AchievementAdjustments, BookNameFixes

local function Msg( text )
	CHAT_ROUTER:AddSystemMessage(text)
end

local function Initialize( )
	if (not LCK_MotifDataTool) then LCK_MotifDataTool = { } end
	Data = LCK_MotifDataTool
	Data.styles = { }
	Styles = Data.styles

	ChapterNames = {
		{ id = ITEM_STYLE_CHAPTER_SHOULDERS, name = "Cops" }, -- Manual fix for Scalecaller
		{ id = ITEM_STYLE_CHAPTER_DAGGERS, name = "Concord Dagger" }, -- Manual fix for Kindred's Concord
		{ id = ITEM_STYLE_CHAPTER_HELMETS, name = "Concord Helmet" }, -- Manual fix for Kindred's Concord
		{ id = ITEM_STYLE_CHAPTER_SHIELDS, name = "Concord Shield" }, -- Manual fix for Kindred's Concord
		unpack(LCK.GetMotifChapterNames()),
	}

	-- More manual fixes
	NameAdjustments = {
		["Psijic Order"] = "Psijic",
		["Order of the Hour"] = "Order Hour",
		["Coldharbour Dominator"] = "Coldharbour Dom",
	}

	CrownNumbers = {
		[43] = true, -- Grim Harlequin
		[46] = true, -- Frostcaster
		[53] = true, -- Tsaesci
		[129] = true, -- Hircine Bloodhunter
	}

	AchievementAdjustments = {
		["Hollowjack"] = "Happy Work for Hollowjack",
		["Psijic Order"] = "Psijic Style Master",
		["Moongrave Fane"] = "Moongrave Style Master",
		["Annihilarch's Chosen"] = "Annihilarch's Style Master",
		["Coldharbour Dominator"] = "Coldharbour Dom. Style Master",
	}

	Achievements = {
		[15] = 1043, -- Ancient Elf
		[17] = 1043, -- Barbaric
		[19] = 1043, -- Primal
		[20] = 1043, -- Daedric
		[34] = 1043, -- Imperial
	}
	for i = 1, 9 do
		Achievements[i] = 1030
	end

	BookNameFixes = {
		{ "Helms", "Helmets" },
		{ "Cops", "Shoulders" },
		{ "Leg Greaves", "Legs" },
		{ "Chest Pieces", "Chests" },
		{ "Moongrave", "Moongrave Fane" },
	}

	BookIds = {
		-- No chapters
		[1] = 2170, -- Breton
		[2] = 2171, -- Redguard
		[3] = 2173, -- Orc
		[4] = 2167, -- Dark Elf
		[5] = 2169, -- Nord
		[6] = 2174, -- Argonian
		[7] = 2166, -- High Elf
		[8] = 2168, -- Wood Elf
		[9] = 2172, -- Khajiit
		[15] = 2476, -- Ancient Elf
		[17] = 2481, -- Barbaric
		[19] = 2504, -- Primal
		[20] = 2505, -- Daedric
		[34] = 2175, -- Imperial
		[30] = 3566, -- Soul Shriven
		[38] = 4727, -- Tsaesci
		[53] = 4018, -- Frostcaster
		[58] = 3895, -- Grim Harlequin

		-- Chaptered, no achievement
		[151] = 8029, -- Hircine Bloodhunter

		-- Different ID order (sorted here by bookId)
		[28] = 3174, -- Glass
		[21] = 3286, -- Trinimac
		[13] = 3287, -- Malacath
		[43] = 3452, -- Morag Tong
		[42] = 3453, -- Skinchanger
		[41] = 3536, -- Abah's Watch
		[11] = 3537, -- Thieves Guild
		[46] = 3609, -- Assassins League
		[31] = 3610, -- Draugr
		[39] = 3925, -- Minotaur
		[16] = 3926, -- Order Hour
		[57] = 4066, -- Mazzatun
		[56] = 4067, -- Silken Ring
		[52] = 4447, -- Buoyant Armiger
		[51] = 4448, -- Telvanni
		[50] = 4449, -- Militant Ordinator
		[55] = 4942, -- Worm Cult
		[75] = 5114, -- Pyandonean
		[80] = 5314, -- Honor Guard
		[79] = 5315, -- Dead-Water
		[81] = 5316, -- Elder Argonian
	}
end

local function FindLower( haystack, needle )
	return zo_plainstrfind(zo_strlower(haystack), zo_strlower(needle))
end

local function GetDetails( itemId )
	local itemLink = LCK.GetItemLinkFromItemId(itemId)
	local name = LocalizeString("<<t:1>>", GetItemLinkName(itemLink))
	local itemType, specializedItemType = GetItemLinkItemType(itemLink)

	local styleId, chapterId

	for id, data in pairs(Styles) do
		if (FindLower(name, string.format(": %s", data.name))) then
			if (styleId) then
				Msg(string.format("[ERROR] Extra style ID: %s (%s and %s)", itemLink, Styles[styleId].name, data.name))
			end
			styleId = id
		end
	end

	if (specializedItemType == SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_BOOK) then
		chapterId = ITEM_STYLE_CHAPTER_ALL
	else
		for _, chapter in ipairs(ChapterNames) do
			if (FindLower(name, string.format(" %s", chapter.name))) then
				if (chapterId) then
					Msg(string.format("[ERROR] Extra chapter ID: %s (%s)", itemLink, chapter.name))
				end
				chapterId = chapter.id
			end
		end

		if (not chapterId) then
			if (string.find(name, "^Crown") or string.find(name, "Style$") or string.find(name, "Tome Edition$")) then
				chapterId = ITEM_STYLE_CHAPTER_ALL
			end
		end
	end

	if not styleId then
		Msg(string.format("[ERROR] Cannot identify style for %s", itemLink))
	end
	if not chapterId then
		Msg(string.format("[ERROR] Cannot identify chapter for %s", itemLink))
	end

	local _, _, number = string.find(name, " (%d+)")
	number = (number or 0) + 0
	if chapterId == ITEM_STYLE_CHAPTER_ALL and number == 0 then
		Msg(string.format("[ERROR] Cannot identify number for %s", itemLink))
	end

	local bopChapter = false
	if (chapterId and chapterId ~= ITEM_STYLE_CHAPTER_ALL and GetItemLinkBindType(itemLink) == BIND_TYPE_ON_PICKUP) then
		bopChapter = true
	end

	return itemLink, name, styleId, chapterId, number, bopChapter
end

local function FindAchievement( styleName )
	for i = 1, LMAA.GetMaxAchievementId() do
		if (FindLower(zo_strformat(GetAchievementName(i)), AchievementAdjustments[styleName] or styleName .. " Style Master")) then
			return i
		end
	end
end

local function MatchBookTitleWithItemName( title, itemName )
	if (itemName == nil or itemName == "" or title == "") then return false end
	local title2 = title
	for _, fix in ipairs(BookNameFixes) do
		title2 = string.gsub(title2, fix[1], fix[2])
	end
	return FindLower(itemName, title) or FindLower(itemName, title2) or FindLower(title, itemName) or FindLower(title2, itemName)
end

local function FindBookId( styleId )
	local styleData = Styles[styleId]
	local achievementId = styleData.achievement
	local numCriteria = GetAchievementNumCriteria(achievementId)
	local collectionId = GetAchievementLinkedBookCollectionId(achievementId)
	local categoryIndex, collectionIndex = GetLoreBookCollectionIndicesFromCollectionId(collectionId)
	local _, _, _, totalBooks, _, _, collectionId2 = GetLoreCollectionInfo(categoryIndex, collectionIndex)

	local manualChapterBookId = false
	local indexToChapterLookup = LCK.GetMotifChapterNames()

	local bookIdFirstChapter = 0
	if (numCriteria == 14 and totalBooks == 14 and collectionId == collectionId2) then
		bookIdFirstChapter = select(4, GetLoreBookInfo(categoryIndex, collectionIndex, 1))
	end

	local bookIdAll = BookIds[styleId] or bookIdFirstChapter - 1
	if (bookIdFirstChapter == 0) then
		bookIdFirstChapter = bookIdAll + 1
		manualChapterBookId = true
	end

	local title, _, _, bookId = GetLoreBookInfo(GetLoreBookIndicesFromBookId(bookIdAll))
	if (bookId ~= bookIdAll or not MatchBookTitleWithItemName(title, styleData.itemNames[ITEM_STYLE_CHAPTER_ALL])) then
		Msg(string.format("[WARNING] Mismatch: book name [%s] and item name [%s] for [%d/%d]", title, styleData.itemNames[ITEM_STYLE_CHAPTER_ALL] or "", styleId, ITEM_STYLE_CHAPTER_ALL))
	end

	if (next(styleData.chapters)) then
		for i = 1, 14 do
			local bookIndex = i
			local chapterId = indexToChapterLookup[bookIndex].id
			if (manualChapterBookId) then
				categoryIndex, collectionIndex, bookIndex = GetLoreBookIndicesFromBookId(bookIdFirstChapter + bookIndex - 1)
			end
			local title, _, _, bookId = GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex)
			if (bookId ~= bookIdFirstChapter + bookIndex - 1) then
				Msg(string.format("[ERROR] bookId sequence not contiguous for [%d/%s]", styleId, styleData.name))
			end
			if (not MatchBookTitleWithItemName(title, styleData.itemNames[chapterId])) then
				Msg(string.format("[WARNING] Mismatch: book name [%s] and item name [%s] for [%d/%d]", title, styleData.itemNames[chapterId] or "", styleId, chapterId))
			end
		end
	end

	local chapterOffset = 0
	if (next(styleData.chapters)) then
		chapterOffset = bookIdFirstChapter - bookIdAll
	end
	return bookIdAll, chapterOffset
end

local function GetStyles( )
	Initialize()

	local fieldSizesValid = true

	for i = 1, GetNumValidItemStyles() do
		local styleId = GetValidItemStyleId(i)
		if (styleId ~= GetUniversalStyleId()) then
			local name = GetItemStyleName(styleId)
			Styles[styleId] = {
				name = NameAdjustments[name] or name,
				mat = GetItemStyleMaterialLink(styleId),
				books = { },
				chapters = { },
				achievement = Achievements[styleId] or FindAchievement(name) or 0,
				itemNames = { },
			}
		end
	end

	local encoded = { }
	local encodedBop = { }
	local duplicates = { }
	local styledata = { }

	for _, id in ipairs(LCK.InternalUseOnly_GetRawMotifIds()) do
		local itemLink, name, styleId, chapterId, number, bopChapter = GetDetails(id)

		if (styleId and chapterId) then
			-- Update styles table, which is saved for human inspection
			local formattedName = string.format("%d: %s", id, name)
			if (chapterId == ITEM_STYLE_CHAPTER_ALL) then
				table.insert(Styles[styleId].books, formattedName)
			else
				local chapters = Styles[styleId].chapters
				if (chapters[chapterId] == nil) then
					chapters[chapterId] = formattedName
				else
					duplicates[styleId] = true
					if (type(chapters[chapterId]) == "table") then
						table.insert(chapters[chapterId], formattedName)
					else
						chapters[chapterId] = { chapters[chapterId], formattedName }
					end
				end
			end

			if (not Styles[styleId].itemNames[chapterId] or GetItemLinkBindType(itemLink) ~= BIND_TYPE_ON_PICKUP) then
				Styles[styleId].itemNames[chapterId] = name
			end

			if (not Styles[styleId].number) then
				Styles[styleId].number = number
			elseif (Styles[styleId].number ~= number) then
				Msg(string.format("[WARNING] Potential motif number error for %s (expected %d)", itemLink, Styles[styleId].number))
			end

			-- Update encoded table, for inclusion in LCK
			table.insert(bopChapter and encodedBop or encoded, LCCC.Encode(id, 3) .. LCCC.Encode(BitLShift(styleId, 4) + chapterId, 2))
			if (id >= 2^18 or styleId >= 2^8) then
				fieldSizesValid = false
			end
		end
	end

	for styleId in pairs(duplicates) do
		Msg(string.format("[NOTICE] Duplicate chapters found in %s", Styles[styleId].name))
	end

	local styleIds = { }
	for styleId, data in pairs(Styles) do
		if (data.number) then
			table.insert(styleIds, styleId)
			if (data.achievement == 0 and not CrownNumbers[data.number]) then
				Msg(string.format("[WARNING] No achievement found for %s", data.name))
			end
		end
	end
	table.sort(styleIds)

	for _, styleId in ipairs(styleIds) do
		local number = Styles[styleId].number
		local achId = Styles[styleId].achievement
		local shiftedNumber = BitLShift(number, 8)
		local shiftedCrown = BitLShift(CrownNumbers[number] and 1 or 0, 16)
		local shiftedAchId = BitLShift(achId, 17)
		table.insert(styledata, LCCC.Encode(styleId + shiftedNumber + shiftedCrown + shiftedAchId, 5))
		if (styleId >= 2^8 or number >= 2^8 or achId >= 2^13) then
			fieldSizesValid = false
		end

		local bookId, offset = FindBookId(styleId)
		local shiftedOffset = BitLShift(BitAnd(offset, 0xFF), 14)
		table.insert(styledata, LCCC.Encode(bookId + shiftedOffset, 4))
		if (bookId >= 2^14 or zo_abs(offset) >= 2^7) then
			fieldSizesValid = false
		end
	end

	if (not fieldSizesValid) then
		Msg("[CRITICAL] Data exceeds field sizes; reapportionment is required.")
		return
	end

	local signature = string.format("Generated by LCK_MotifDataTool on %s (%d: %s)", os.date("%Y/%m/%d %H:%M:%S", GetTimeStamp()), GetAPIVersion(), GetESOVersionString())
	Data.encoded = LCCC.Chunk(table.concat(encodedBop, "") .. table.concat(encoded, ""))
	Data.encoded.styledata = table.concat(styledata, "")
	Data.encoded.signature = signature
	Msg(signature)
end

LCK.RegisterForCallback("LCK_MotifDataTool", LCK.EVENT_INITIALIZED, function( )
	SLASH_COMMANDS["/lckstyles"] = GetStyles
end)
