local ADDON = NameLanguageNinja
local LMN = LibMultilingualName

--------
-- in this file local use, private
--------

-- strings should be replaced in shortenmode. e.g) Recipe
local patternPre = "^"
local patternPost = "%s?[:：]%s"
local langCodeItemPrefix = {
	[LMN.CODE_GERMAN] = {
		"Skizze",
		"Vorlage",
		"Runenkiste",
		"Schatzkarte",
		"Handwerksstil%s?%d+",
		"Stilseite",
		"Rezept",
		"Anleitung",
		"Blaupause"
	},
	[LMN.CODE_ENGLISH] = {
		"Diagram",
		"Pattern",
		"Runebox",
		"", -- TreasureMap
		"Crafting Motif%s?%d+",
		"Style Page",
		"Recipe",
		"Praxis",
		"Blueprint"
	},
	[LMN.CODE_FRENCH] = {
		"diagramme",
		"préparation",
		"Boîte runique",
		"", -- TreasureMap
		"Motif artisanal%s?%d+",
		"Page de style",
		"recette",
		"praxis",
		"Plan"
	},
	[LMN.CODE_JAPANESE] = {
		"ダイアグラム",
		"パターン",
		"ルーンボックス",
		"", -- TreasureMap
		"クラフトモチーフ%s?%d+",
		"スタイルページ",
		"レシピ",
		"設計図",
		"ブループリント"
	},
	[LMN.CODE_RUSSIAN] = {
		"Диаграмма",
		"Шаблон",
		"Рунный ларец",
		"", -- TreasureMap
		"Ремесленный мотив%s?%d+",
		"Страница стиля",
		"Рецепт",
		"Схема",
		"Чертеж"
	},
	[LMN.CODE_SPANISH] = {
		"Diagrama",
		"Patrón",
		"caja rúnica",
		"", -- TreasureMap
		"Motivo de artesanía%s?%d+",
		"Página de estilo",
		"Receta",
		"Esquema",
		"Plano"
	},
	[LMN.CODE_CHINESE] = { -- TODO
		"Diagram",
		"Pattern",
		"Runebox",
		"", -- TreasureMap
		"Crafting Motif%s?%d+",
		"Style Page",
		"Recipe",
		"Praxis",
		"Blueprint"
	}
}

local function replaceIfSpecificHead(name)
	if not ADDON.SaveData.LinkInChat.ShortenMode.OmitItemPrefix then
		return name, false
	end

	for langCode, replaceData in pairs(langCodeItemPrefix) do
		for _key, replaceStr in pairs(replaceData) do
			if string.len(replaceStr) > 0 then
				local pettern = patternPre .. replaceStr .. patternPost
				local newName = string.gsub(name, pettern, "")
				if name ~= newName then
					return newName, true
				end
			end
		end
	end

	return name, false
end

local function getIconString(itemLink)
	local color = {
		["R"] = 255,
		["G"] = 255,
		["B"] = 255
	}
	local sizeX = ADDON.SaveData.LinkInChat.ShortenMode.IconSize
	local sizeY = ADDON.SaveData.LinkInChat.ShortenMode.IconSize

	--GetItemLinkIcon(string itemLink)
	--Returns: textureName itemIcon
	local itemIcon = GetItemLinkIcon(itemLink)

	--GetItemLinkEquipType(string itemLink)
	--Returns: number EquipType equipType
	local equipType = GetItemLinkEquipType(itemLink)

	-- GetItemLinkItemType(string itemLink)
	-- Returns: number ItemType itemType, number SpecializedItemType specializedItemType
	--local itemType, specializedItemType = GetItemLinkItemType(itemLink)
	local itemType, specializedItemType = GetItemLinkItemType(itemLink)

	-- GetItemLinkWeaponType(string itemLink)
	-- Returns: number WeaponType weaponType
	--WEAPONTYPE_FIRE_STAFF,      -- Fire staff
	--WEAPONTYPE_FROST_STAFF,     -- Ice staff
	--WEAPONTYPE_LIGHTNING_STAFF, -- Lightning staff
	--WEAPONTYPE_HEALING_STAFF,   -- Heal staff
	local weaponType = GetItemLinkWeaponType(itemLink)

	-- GetItemLinkArmorType(string itemLink)
	-- Returns: number ArmorType armorType
	local armorType = GetItemLinkArmorType(itemLink)
	-- ARMORTYPE_LIGHT
	-- ARMORTYPE_MEDIUM
	-- ARMORTYPE_HEAVY

	-- GetItemLinkItemStyle(string itemLink)
	-- Returns: number style
	local style = GetItemLinkItemStyle(itemLink)
	-- ITEMSTYLE_UNDAUNTED

	ADDON.develop_delay(
		itemIcon ..
			" equipType:" ..
				equipType ..
					" itemType:" ..
						itemType ..
							" specializedItemType:" ..
								specializedItemType .. " weaponType:" .. weaponType .. " armorType:" .. armorType .. " style:" .. style
	)

	local weakColor = 160
	local strongColor = 255
	local badgeChar = ""

	if weaponType == WEAPONTYPE_FIRE_STAFF then
		-- flame is red
		color = {["R"] = strongColor, ["G"] = weakColor, ["B"] = weakColor}
		badgeChar = badgeChar .. "F"
	end
	if weaponType == WEAPONTYPE_FROST_STAFF then
		-- ice is blue
		color = {["R"] = weakColor, ["G"] = weakColor, ["B"] = strongColor}
		badgeChar = badgeChar .. "I"
	end
	if weaponType == WEAPONTYPE_LIGHTNING_STAFF then
		-- lightning is yellow
		color = {["R"] = strongColor, ["G"] = strongColor, ["B"] = weakColor}
		badgeChar = badgeChar .. "L"
	end
	if weaponType == WEAPONTYPE_HEALING_STAFF then
		-- healing is green
		color = {["R"] = weakColor, ["G"] = strongColor, ["B"] = weakColor}
		badgeChar = badgeChar .. "H"
	end

	if armorType == ARMORTYPE_LIGHT then
		badgeChar = badgeChar .. "L"
	end
	if armorType == ARMORTYPE_MEDIUM then
		badgeChar = badgeChar .. "M"
	end
	if armorType == ARMORTYPE_HEAVY then
		badgeChar = badgeChar .. "H"
	end

	local format = "|c%02x%02x%02x|t%d:%d:%s:inheritcolor|t%s|r"
	local iconString = string.format(format, color.R, color.G, color.B, sizeX, sizeY, itemIcon, badgeChar)

	return iconString
end

local function getItemNames(itemLink, shortenMode)
	local itemId = GetItemLinkItemId(itemLink)
	local isSet, setName, numBonuses, numEquipped, maxEquipped, setId = GetItemLinkSetInfo(itemLink, false)
	local names = {}
	local icon = ""

	local clientLangCode = string.lower(GetCVar("language.2"))

	if shortenMode then
		local langCode = ADDON.GetLangCodeForShortenMode()
		local name = ""
		if isSet and LMN.GetRawSetItemName(langCode, setId) and ADDON.SaveData.LinkInChat.ShortenMode.UseSetName then
			name = LMN.GetSetItemName(langCode, setId)
			icon = getIconString(itemLink)
		else
			if clientLangCode == langCode then
				local _itemName = GetItemLinkName(itemLink)
				name = ZO_CachedStrFormat("<<C:1>>", _itemName)
			else
				name = LMN.GetItemName(langCode, itemId)
			end
			local newName, replaced = replaceIfSpecificHead(name)
			if replaced then
				name = newName
				icon = getIconString(itemLink)
			end
		end
		local strlenMax = ADDON.SaveData.LinkInChat.ShortenMode.OmitNameIfLengthGreaterThan
		local strlen = string.len(name)
		-- TODO UTF8
		--utf8.len(name)
		--utf8.sub(name, 0, strlenMax)
		if strlenMax and 0 < strlenMax and strlenMax < strlen then
			name = string.sub(name, 0, strlenMax)
		end

		names[#names + 1] = name
	else
		-- get item's names in your selected languages for tooltip
		for key, langCode in ipairs(LMN.ALL_LANG_CODES) do
			if clientLangCode == langCode then
				--GetItemLinkName(string itemLink)
				--Returns: string itemName
				local _itemName = GetItemLinkName(itemLink)
				names[#names + 1] = ZO_CachedStrFormat("<<C:1>>", _itemName)
			else
				if ADDON.SaveData.LinkInChat.Languages[langCode] then
					if LMN.GetRawItemName(langCode, itemId) then
						names[#names + 1] = LMN.GetItemName(langCode, itemId)
					end
				end
			end
		end
	end

	return names, icon
end

local function addNamesToMessage(message)
	if (not message) then
		return
	end
	if not ADDON.SaveData.LinkInChat.Replace then
		if ADDON.IS_DEBUG() then
			return "N]" .. message
		end
		return message
	end

	local types = {"item", "achievement", "book", "url"}
	-- exclude "channel" , "character"
	local found = {}
	local count = 0
	local debugMessage = ""

	-- count all of Link In Chat.
	for _typeKey, type in pairs(types) do
		for link in string.gmatch(message, "(|H%d:" .. type .. ":.-|h.-|h)") do
			debugMessage = debugMessage .. " matched. type = " .. type .. " link: " .. string.gsub(link, "|", "｜")
			count = count + 1
		end
	end
	if count == 0 then
		if ADDON.IS_DEBUG() then
			return "0]" .. message
		end
		return message
	end

	ADDON.develop_delay(
		debugMessage
	)
	ADDON.develop_delay(
			"count = " .. count
	)
	ADDON.develop_delay(
			"IfNumOfLinkInChatGreaterThan: " .. ADDON.SaveData.LinkInChat.ShortenMode.IfNumOfLinkInChatGreaterThan
	)

	local shortenMode = false
	local parentheses_from = "["
	local parentheses_to = "]"

	if ADDON.SaveData.LinkInChat.ShortenMode.IfNumOfLinkInChatGreaterThan < count then
		shortenMode = true
		parentheses_from = ""
		parentheses_to = ""
	end

	-- pick up all of Link In Chat replasable.
	local linkTitle = ADDON.SaveData.LinkInChat.LinkTitle
	if string.len(linkTitle) < 1 then
		linkTitle = "LINK"
	end
	for _typeKey, type in pairs(types) do
		local format = "(|H%d:" .. type .. ":.-|h|h)"

		if ADDON.SaveData.LinkInChat.IncludeDesignatedTitle then
			--ADDON.develop_delay("IncludeDesignatedTitle")
			format = "(|H%d:" .. type .. ":.-|h.-|h)"
		end
		ADDON.develop_delay(
			"type: " .. type .. " format: " .. string.gsub(format, "|", "｜")
		)

		for link in string.gmatch(message, format) do
			local names = {}
			local icon = ""
			if type == "item" then
				names, icon = getItemNames(link, shortenMode)
			end

			if (#names > 0) then
				local namesAllStr = ""
				for _key, name in pairs(names) do
					if string.len(namesAllStr) > 0 then
						namesAllStr = namesAllStr .. "/"
					end
					namesAllStr = namesAllStr .. name
				end
				ADDON.develop_delay(
					"namesAllStr: " .. namesAllStr
				)

				local withAlias = string.gsub(link, "|h.*|h", "|h" .. linkTitle .. "|h", 1)
				..  parentheses_from .. namesAllStr .. parentheses_to
				
				if ADDON.SaveData.LinkInChat.ShortenMode.IconPositionRight then
					found[link] = withAlias .. icon
				else
					found[link] = icon .. withAlias
				end
				ADDON.develop_delay(
					"new link: " .. string.gsub(found[link], "|", "｜")
				)
			end
		end
	end

	local new_message = message
	for link, withAlias in pairs(found) do
		new_message = string.gsub(new_message, link, withAlias)
	end

	if ADDON.SaveData.LinkInChat.NotReplaceIfLengthGreaterThan == 0 then
		ADDON.develop_delay(
			" NotReplaceIfLengthGreaterThan == 0 "
		)
	else
		if string.len(new_message) > ADDON.SaveData.LinkInChat.NotReplaceIfLengthGreaterThan then
			ADDON.develop_delay(
				"the new message is too long. replacer stops. length: " .. string.len(new_message)
			)
			return message
		else
			ADDON.develop_delay(
				"the new message length: " .. string.len(new_message)
			)
		end
	end

	if ADDON.IS_DEBUG() then
		return count .. "]" .. new_message
	end
	return new_message
end

local function addNamesToSystemMessage(message)
	return addNamesToMessage(message)
end

local function addNamesToNormalMessage(messageType, fromName, text, isFromCustomerService, fromDisplayName)
	local formattedText = addNamesToMessage(text)

	local channelInfo = ZO_ChatSystem_GetChannelInfo()[messageType]
	if (not channelInfo or not channelInfo.format) then
		return
	end

	return formattedText, channelInfo.saveTarget
end

--------
-- in this ADDON use, protected
--------

function ADDON.HookChatMessage()
	ADDON.develop("HookChatMessage")

	-- system message
	local previousSystemMessageFormatter = CHAT_ROUTER:GetRegisteredMessageFormatters()["AddSystemMessage"]
	if (previousSystemMessageFormatter) then
		CHAT_ROUTER:RegisterMessageFormatter(
			"AddSystemMessage",
			function(...)
				return addNamesToSystemMessage(previousSystemMessageFormatter(...))
			end
		)
	else
		CHAT_ROUTER:RegisterMessageFormatter("AddSystemMessage", addNamesToSystemMessage)
	end

	-- normal message
	local oldNormalMessageFormatter = CHAT_ROUTER:GetRegisteredMessageFormatters()[EVENT_CHAT_MESSAGE_CHANNEL]
	if (oldNormalMessageFormatter) then
		CHAT_ROUTER:RegisterMessageFormatter(
			EVENT_CHAT_MESSAGE_CHANNEL,
			function(messageType, fromName, text, isFromCustomerService, fromDisplayName)
				local oldText = oldNormalMessageFormatter(messageType, fromName, text, isFromCustomerService, fromDisplayName)
				return addNamesToNormalMessage(messageType, fromName, oldText, isFromCustomerService, fromDisplayName)
			end
		)
	else
		CHAT_ROUTER:RegisterMessageFormatter(EVENT_CHAT_MESSAGE_CHANNEL, addNamesToNormalMessage)
	end
end
