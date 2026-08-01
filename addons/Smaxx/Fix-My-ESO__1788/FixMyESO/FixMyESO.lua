local ADDON_NAME = "FixMyESO"

local styles = {
	de = {
		[1] = 'Bretonen^p',
		[2] = 'Rothwardonen^p',
		[3] = 'Orks^p',
		[4] = 'Dunkelelfen^p',
		[5] = 'Nord^p',
		[6] = 'Argonier^p',
		[7] = 'Hochelfen^p',
		[8] = 'Waldelfen^p',
		[9] = 'Khajiit^p',
		[11] = 'Diebesgilde^f',
		[12] = 'dunkle Bruderschaft^fc',
		[13] = 'Malacath^M',
		[14] = 'Dwemer^p',
		[15] = 'alte Elfen^p',
		[16] = 'Orden der Stunde^m',
		[17] = 'Barbaren^p',
		[19] = 'Wilde^p',
		[20] = 'Daedra^p',
		[21] = 'Trinimac^M',
		[22] = 'Orkahnen^p',
		[23] = 'Dolchsturz-Bündnis^n',
		[24] = 'Ebenherz-Pakt^m',
		[25] = 'Aldmeri-Dominion^n',
		[26] = 'Söldner^p',
		[27] = 'Himmlische^p',
		[28] = 'Glasit^n',
		[29] = 'Xivkyn^p',
		[30] = 'Seelenberaubte^p',
		[31] = 'Draugr^p',
		[32] = 'Maormer^p',
		[33] = 'Akaviri^p',
		[34] = 'Kaiserliche^p',
		[35] = 'Yokudaner^p',
		[37] = 'Reikwinter^p',
		[39] = 'Minotauren^p',
		[40] = 'Ebenerz^n',
		[41] = 'Abahs Wacht^Fg',
		[42] = 'Gestaltwandler^p',
		[43] = 'Morag Tong^f',
		[44] = 'Ro\'Wada^p',
		[45] = 'dro-m\'Athra^p',
		[46] = 'Assassinenbund^m',
		[47] = 'Gesetzlose^p',
		[48] = 'Redoran^p',
		[49] = 'Hlaalu^p',
		[50] = 'kriegerische Ordinatoren^p',
		[51] = 'Telvanni^p',
		[52] = 'Kriegswappenträgger^p',
		[53] = 'Frostwirker^p',
		[54] = 'Aschländer^p',
		[55] = 'Wurmkult^m',
		[56] = 'Seidenringg^m',
		[57] = 'Mazzatun^M',
		[58] = 'grimmiger Harlekin^m',
		[59] = 'Kürbisfratze^M',
		[61] = 'Blutquellschmiede^f',
		[62] = 'Grauenshorn-Klan^m'
	},
	fr = {
		[1] = "Bréton",
		[2] = "Rougegarde",
		[3] = "Orque",
		[4] = "Elfe noir",
		[5] = "Nordique",
		[6] = "Argonien",
		[7] = "Haut-elfe",
		[8] = "Elfe des bois",
		[9] = "Khajiit",
		[11] = "Guilde des voleurs",
		[12] = "Confrérie noire",
		[13] = "Malacath",
		[14] = "Dwemer",
		[15] = "Elfe antique",
		[16] = "Akatosh",
		[17] = "Crevasse",
		[18] = "Bandit",
		[19] = "Primitif",
		[20] = "Daedrique",
		[21] = "Trinimac",
		[22] = "Orque ancien",
		[23] = "Alliance de Daguefilante",
		[24] = "Pacte de Cœurébène",
		[25] = "Domaine aldmeri",
		[26] = "Mercenaire",
		[27] = "Raidelorn",
		[28] = "Verre",
		[29] = "Xivkyn",
		[30] = "Absous",
		[31] = "Draugr",
		[32] = "Maormer",
		[33] = "Akavirois",
		[34] = "Impérial",
		[35] = "Yokudan",
		[37] = "Hiver de la Crevasse",
		[39] = "Minotaure",
		[40] = "Ébonite",
		[41] = "Garde d'Abah",
		[42] = "Changeforme",
		[43] = "Morag Tong",
		[44] = "Ra Gada",
		[45] = "Dro-m'Athra",
		[46] = "Ligue des assassins",
		[47] = "Hors-la-loi",
		[48] = "Redoran",
		[49] = "Hlaalu",
		[50] = "Ordonnateur",
		[51] = "Telvanni",
		[52] = "Exalté",
		[53] = "Lancegivre",
		[54] = "Cendrais",
		[55] = "Culte du Ver",
		[56] = "Anneau de soie",
		[57] = "Mazzatun",
		[58] = "Sinistre Arlequin",
		[59] = "Hallowjack",
		[61] = "Sangracine",
		[62] = "Épervine",
	},
}

local stylesNames = {
	fr = "Style :", -- non break space :)
	de = "Stil:",
}

local function OnAddonLoaded(_, addon)

	if addon == ADDON_NAME then

		local lang = GetCVar("Language.2")

		-- test if this is still required
		if GetItemStyleName(1) == "" then

			local original_GetItemStyleName = GetItemStyleName
			GetItemStyleName = function(id)
				if styles[lang] then
					return styles[lang][id] or ""
				end
				return original_GetItemStyleName(id)
			end
			
			local original_GenerateMasterWritBaseText = GenerateMasterWritBaseText
			GenerateMasterWritBaseText = function(link)
				if styles[lang] then
					local styleId = select(15, ZO_LinkHandler_ParseLink(link))
					return original_GenerateMasterWritBaseText(link) .. " " .. zo_strformat("<<C:1>>", styles[lang][tonumber(styleId)] or "")
				end
				return original_GenerateMasterWritBaseText(link)
			end
			
			local function ModifyTooltip(itemLink)
				
				local _, _, linkType = ZO_LinkHandler_ParseLink(itemLink)
				if linkType ~= ITEM_LINK_TYPE then return end
				local itemType = GetItemLinkItemType(itemLink)
				if itemType == ITEMTYPE_MASTER_WRIT then
					if stylesNames[lang] then
						local styleId = select(15, ZO_LinkHandler_ParseLink(itemLink))
						if lang == "fr" then
							SafeAddString(SI_MASTER_WRIT_ITEM_DURABLE_FORMAT_STRING, GetString(SI_MASTER_WRIT_ITEM_DURABLE_FORMAT_STRING) .. " " .. zo_strformat("<<C:1>>", styles[lang][tonumber(styleId)] or ""), 1)
						elseif lang == "de" then
							SafeAddString(SI_MASTER_WRIT_ITEM_DURABLE_FORMAT_STRING, string.gsub(GetString(SI_MASTER_WRIT_ITEM_DURABLE_FORMAT_STRING), "<<5>>", "\n" .. stylesNames[lang] .. " " .. zo_strformat("<<C:1>>", styles[lang][tonumber(styleId)] or "")) .. "\n", 1)
						end
					end
				end
			end
			
			local function TooltipHook(tooltipControl, method, linkFunc)
				local origMethod = tooltipControl[method]     
				tooltipControl[method] = function(self, ...)
					local orgText = GetString(SI_MASTER_WRIT_ITEM_DURABLE_FORMAT_STRING)
					local itemLink = linkFunc(...)
					ModifyTooltip(itemLink)
					origMethod(self, ...)
					SafeAddString(SI_MASTER_WRIT_ITEM_DURABLE_FORMAT_STRING, orgText, 1)
				end
			end
			
			local function ReturnItemLink(itemLink)
				return itemLink
			end
			
			-- ItemTooltip are tooltips displayed when you hover an item
			TooltipHook(ItemTooltip, "SetBagItem", GetItemLink)
			TooltipHook(ItemTooltip, "SetTradeItem", GetTradeItemLink)
			TooltipHook(ItemTooltip, "SetBuybackItem", GetBuybackItemLink)
			TooltipHook(ItemTooltip, "SetStoreItem", GetStoreItemLink)
			TooltipHook(ItemTooltip, "SetAttachedMailItem", GetAttachedItemLink)
			TooltipHook(ItemTooltip, "SetLootItem", GetLootItemLink)
			TooltipHook(ItemTooltip, "SetTradingHouseItem", GetTradingHouseSearchResultItemLink)
			TooltipHook(ItemTooltip, "SetTradingHouseListing", GetTradingHouseListingItemLink)
			TooltipHook(ItemTooltip, "SetAction", GetSlotItemLink)
			TooltipHook(ItemTooltip, "SetLink", ReturnItemLink)
			
			-- Is the Tooltip when you click on a link
			TooltipHook(PopupTooltip, "SetLink", ReturnItemLink)
		
		end
		
		EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
			
	end
	
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)