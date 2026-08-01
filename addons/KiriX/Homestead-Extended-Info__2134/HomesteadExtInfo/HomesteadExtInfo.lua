local function getHomesteadCapacity(houseID)
	Capacity1 = GetHouseFurnishingPlacementLimit(houseID, HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_ITEM) 		--Обычные предметы
	Capacity2 = GetHouseFurnishingPlacementLimit(houseID, HOUSING_FURNISHING_LIMIT_TYPE_HIGH_IMPACT_ITEM)		--Особые предметы
	Capacity3 = GetHouseFurnishingPlacementLimit(houseID, HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_COLLECTIBLE)	--Обычные коллекционные предметы
	Capacity4 = GetHouseFurnishingPlacementLimit(houseID, HOUSING_FURNISHING_LIMIT_TYPE_HIGH_IMPACT_COLLECTIBLE)--Особые коллекционные предметы
	return Capacity1.."/"..Capacity2.."/"..Capacity3.."/"..Capacity4
end

local function getCharCurrency(cur) --Получаем данные о валюте, имеющейся у текущего персонажа и в его банке
	CharCur = GetCurrencyAmount(cur, CURRENCY_LOCATION_CHARACTER) + GetCurrencyAmount(cur, CURRENCY_LOCATION_BANK) + GetCurrencyAmount(cur, CURRENCY_LOCATION_ACCOUNT)
	return CharCur
end

local function setColor(price, cur) --Определяем цвет цены. Если средств достаточно - белая, в противном случае - красная
	CharCur = getCharCurrency(cur)
	if price > CharCur then
		Color = "|cFF0000" --красный
	else
		Color = "|cFFFFFF" --белый
	end
	
	return Color
end

local function HomesteadExtInfoSetPrice(...)
	local HomesteadGoldPrice, HomesteadCrownPrice1, HomesteadCrownPrice2, c=0, HomesteadYard, HomesteadGuests, HomesteadCapacity
	local houseID = HEIHouseIDs[zo_strlower(ZO_HousingBook_KeyboardContentsName:GetText())]
	
	if HEIPrices[houseID] ~= nil then

		if HEIPrices[houseID]["gold"] == nil then
			HomesteadGoldPrice = "|cFFFFFF" .. GetString(SI_HOMESTEADEXTINFO_NA) .. "|r"
		elseif HEIPrices[houseID]["gold"] == 0 then
			HomesteadGoldPrice = ""
		else
			Color = setColor(HEIPrices[houseID]["gold"], CURT_MONEY)
			HomesteadGoldPrice = Color..ZO_CachedStrFormat("<<F:1>>", HEIPrices[houseID]["gold"]).."|r|t16:16:EsoUI/Art/currency/currency_gold.dds|t"
		end

		if HEIPrices[houseID]["crown1"] == nil then
			HomesteadCrownPrice1 = "|cFFFFFF" .. GetString(SI_HOMESTEADEXTINFO_NA) .. "|r"
		elseif HEIPrices[houseID]["crown1"] == 0 then
			HomesteadCrownPrice1 = ""
		else
			Color = setColor(HEIPrices[houseID]["crown1"], CURT_CROWNS)
			HomesteadCrownPrice1 = Color..ZO_CachedStrFormat("<<F:1>>", HEIPrices[houseID]["crown1"]).."|r"
			c = 1
		end

		if HEIPrices[houseID]["crown2"] == 0 or HEIPrices[houseID]["crown2"] == nil then
			HomesteadCrownPrice2 = ""
		else
			Color = setColor(HEIPrices[houseID]["crown2"], CURT_CROWNS)
			HomesteadCrownPrice2 = " ("..Color..ZO_CachedStrFormat("<<F:1>>", HEIPrices[houseID]["crown2"]).."|r)"
			c = 1
		end

		if c == 1 then
			if HomesteadGoldPrice ~= "" then
				HomesteadCrownPrice1 = " / "..HomesteadCrownPrice1..HomesteadCrownPrice2.."|t16:16:EsoUI/Art/currency/currency_crown.dds|t\n"
			else
				HomesteadCrownPrice1 = HomesteadCrownPrice1..HomesteadCrownPrice2.."|t16:16:EsoUI/Art/currency/currency_crown.dds|t\n"
			end
		else
			HomesteadCrownPrice1 = "\n"
		end

		if HEIPrices[houseID]["yard"] == nil then
			HomesteadYard = GetString(SI_HOMESTEADEXTINFO_NA)
		elseif HEIPrices[houseID]["yard"] == 0 then
			HomesteadYard = GetString(SI_HOMESTEADEXTINFO_HASNTYARD)
		elseif HEIPrices[houseID]["yard"] == 1 then
			HomesteadYard = GetString(SI_HOMESTEADEXTINFO_HASYARD)
		else
			HomesteadYard = GetString(SI_HOMESTEADEXTINFO_NA)
		end
		if HEIPrices[houseID]["guests"] == nil then
			HomesteadGuests = GetString(SI_HOMESTEADEXTINFO_NA)
		else
			HomesteadGuests = HEIPrices[houseID]["guests"]
		end
		if getHomesteadCapacity(houseID) == nil then
			HomesteadCapacity = GetString(SI_HOMESTEADEXTINFO_NA)
		else
			HomesteadCapacity = getHomesteadCapacity(houseID)
		end
	else
		HomesteadGoldPrice = nil
	end

	if HomesteadExtInfo_Text == nil then -- Создание контрола с текстом, если его нет
		CreateControl("HomesteadExtInfo_Text", ZO_HousingBook_KeyboardContentsScrollContainerScrollChild, CT_LABEL)
		HomesteadExtInfo_Text:SetAnchor(TOPLEFT, ZO_HousingBook_KeyboardContentsScrollContainerScrollChildDescription, BOTTOMLEFT, 0, 10)
		HomesteadExtInfo_Text:SetFont("ZoFontWinH4")
		HomesteadExtInfo_Text:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_NORMAL))
	end

	if HomesteadGoldPrice ~= nil then
		HomesteadExtInfo_Text:SetText(GetString(SI_HOMESTEADEXTINFO_PRICE)..HomesteadGoldPrice..HomesteadCrownPrice1.. 	--цена
									GetString(SI_HOMESTEADEXTINFO_CAPACITY).."|cFFFFFF"..HomesteadCapacity.."|r\n".. 	--вместимость
									GetString(SI_HOMESTEADEXTINFO_YARD).."|cFFFFFF"..HomesteadYard.."|r\n"..			--двор
									GetString(SI_HOMESTEADEXTINFO_GUESTS).."|cFFFFFF"..HomesteadGuests.."|r"			--гости
									--.."\nID: " .. houseID																--отладка
									)
		ZO_HousingBook_KeyboardContentsScrollContainerScrollChildLocationLabel:SetAnchor(TOPLEFT, HomesteadExtInfo_Text, BOTTOMLEFT, 0, 5)
		HomesteadExtInfo_Text:SetHidden(false)
	else
		if houseID ~= nil then
			HomesteadExtInfo_Text:SetText("|cFF0000"..GetString(SI_HOMESTEADEXTINFO_NODATA).."|cFFFF00"..houseID.."|r|r") --нет данных
		else
			HomesteadExtInfo_Text:SetText("|cFF0000"..GetString(SI_HOMESTEADEXTINFO_NODATA_NOID).."|r") --нет данных
		end
		ZO_HousingBook_KeyboardContentsScrollContainerScrollChildLocationLabel:SetAnchor(TOPLEFT, HomesteadExtInfo_Text, BOTTOMLEFT, 0, 5)
		HomesteadExtInfo_Text:SetHidden(false)
	end
	
end

--testHouses = {}

function HomesteadExtInfoOnInit(eventCode, addOnName)
	if addOnName ~= "HomesteadExtInfo" then return end
	EVENT_MANAGER:UnregisterForEvent("HomesteadExtInfo_OnAddOnLoaded", EVENT_ADD_ON_LOADED)
	
	for i = 1, 200 do -- Генерация таблицы с ID домов. Возможно, в будущем нужно будет увеличить число, но я взял с запасом
		local tempCollectibleId = GetCollectibleIdForHouse(i)
		
		if tempCollectibleId ~= 0 then
			HEIHouseIDs[zo_strlower(zo_strformat(GetString(SI_COLLECTIBLE_NAME_FORMATTER), GetCollectibleName(tempCollectibleId)))] = i
			
			--[[if HEIPrices[i] == nil then -- /script d(testHouses)
				testHouses[i] = GetCollectibleName(tempCollectibleId)
			end]]
		end
	end
	
	HomesteadExtInfoSetPrice()
end

EVENT_MANAGER:RegisterForEvent("HomesteadExtInfo_OnAddOnLoaded", EVENT_ADD_ON_LOADED, function(_event, _name) HomesteadExtInfoOnInit(_event, _name) end)
ZO_HousingBook_KeyboardContentsScrollContainerScrollChildDescription:SetHandler("OnTextChanged", HomesteadExtInfoSetPrice)