local TBoxAddon = _G['TBoxAddon']
local L = TBoxAddon.DB.Strings

function TBoxAddon.Round(number, decimals) -- Round number to decimals number of places.
	-- number:		The number to round.
	-- decimals:	The number of decimals to round to. 0 = Nearest integer.
	--
	-- Example: PF.Round(42.185, 2) = 42.19
	-- NOTE: Value of decimals must be a whole number >= 0.

	local tDec = math.floor(decimals)
	return tonumber(string.format("%." .. (tDec or 0) .. "f", number))
end
local rND = TBoxAddon.Round

function TBoxAddon.DB.PostFrames()
	if TBoxAddon.InitCheck == 2 then -- support for UI localization
		TBoxAddon_MainFrameNavFrameQualityHead:SetText(L.TBoxAddon_QUALITYHEAD)
		TBoxAddon_MainFrameNavFrameTimeHead:SetText(L.TBoxAddon_TIMEHEAD)
		TBoxAddon_MainFrameHeaderTitle:SetText("|cFEE854ESO|r |cFF9900" .. L.TBoxAddon_TITLE .. "|r")
		TBoxAddon_MainFrameNavFrameRecentHead:SetText(L.TBoxAddon_RECENT)
		TBoxAddon.DB.RecentIconGrid()
	end

	if TBoxAddon.ASV.aOpts.sortState == 1 then -- remember last set sort state and reset at load
		TBoxAddon_MainFrameSortByAlpha:SetState(1)
		TBoxAddon_MainFrameSortByFound:SetState(0)
	elseif TBoxAddon.ASV.aOpts.sortState == 2 then
		TBoxAddon_MainFrameSortByAlpha:SetState(0)
		TBoxAddon_MainFrameSortByFound:SetState(1)
	end
end

function TBoxAddon.DB.RecentIconGrid()
	local tTable = {}
	local iTable = {}
	local zTable = {}
	local zoneCount = {}
	local cCounter = 0
	local cFound = 0

	TBoxAddon.AT.TreasureTableF = {} -- update the known table with new entries
	for k, v in pairs(TBoxAddon.ASV.TreasureDB) do
		if (v.found) and TBoxAddon.AT.TreasureTable[k] then
			TBoxAddon.AT.TreasureTableF[k] = true
		end
	end

	for k, _ in pairs(TBoxAddon.AT.TreasureTableF) do -- parse current known table and sort by date found
		local tIcon = GetItemLinkIcon(TBoxAddon.AT.TreasureTable[k].link)
		local tFound = TBoxAddon.ASV.TreasureDB[k].lastFound
		local tQualt = TBoxAddon.AT.TreasureTable[k].quality
		if tFound then -- safety check
			if tQualt >= TBoxAddon.ASV.aOpts.recentQuality then
				tTable[k] = {
					icon = tIcon,
					found = tFound,
					ID = k,
				}
			end
		end
	end
	for k, v in pairs(tTable) do table.insert(iTable, {icon=v.icon, found=v.found, ID=v.ID}) end
	table.sort(iTable, function(a,b) return a.found > b.found end)

	local tMax = (#iTable >= 25) and 25 or #iTable
	for i = 1, 25 do -- handle hiding extra buttons when changing quality filter
		local testIcon = TBoxAddon_MainFrameNavFrame:GetNamedChild('MiniRecentIcon'..tostring(i))
		local testButton = TBoxAddon_MainFrameNavFrame:GetNamedChild('MiniRecentButton'..tostring(i))	
		if testIcon ~= nil then testIcon:SetHidden(true) end
		if testButton ~= nil then testButton:SetHidden(true) end
	end
	for i = 1, tMax do -- generate the sliding box of recently found controls
		local tId = iTable[i].ID
		local tIcon = iTable[i].icon
		local testIcon = TBoxAddon_MainFrameNavFrame:GetNamedChild('MiniRecentIcon'..tostring(i))
		local testButton = TBoxAddon_MainFrameNavFrame:GetNamedChild('MiniRecentButton'..tostring(i))
		local iControl
		local bControl

		if testButton == nil then
			bControl = WINDOW_MANAGER:CreateControl('TBoxAddon_MainFrameNavFrameMiniRecentButton'..tostring(i), TBoxAddon_MainFrameNavFrame, CT_BUTTON)
			bControl:SetWidth(42)
			bControl:SetHeight(42)
			bControl:SetParent(TBoxAddon_MainFrameNavFrame)
		else
			bControl = testButton
		end
		if testIcon == nil then
			iControl = WINDOW_MANAGER:CreateControl('TBoxAddon_MainFrameNavFrameMiniRecentIcon'..tostring(i), TBoxAddon_MainFrameNavFrame, CT_TEXTURE)
			iControl:SetWidth(34)
			iControl:SetHeight(34)
			iControl:SetTexture(tTable[tId].icon)
			iControl:SetParent(bControl)
		else
			iControl = testIcon
			iControl:SetTexture(tTable[tId].icon)
		end
		iControl:SetHidden(false)
		bControl:SetHidden(false)

		if i == 1 then
			bControl:SetAnchor(TOPLEFT, TBoxAddon_MainFrameNavFrame, TOPLEFT, 17, 260)
			cCounter = 1
		elseif i == cCounter + 5 then
			bControl:SetAnchor(TOPLEFT, GetControl('TBoxAddon_MainFrameNavFrameMiniRecentButton'..tostring(i-5)), BOTTOMLEFT, 0, 10)
			cCounter = cCounter + 5
		else
			bControl:SetAnchor(TOPLEFT, GetControl('TBoxAddon_MainFrameNavFrameMiniRecentButton'..tostring(i-1)), TOPRIGHT, 12, 0)
		end
		iControl:SetAnchor(CENTER, bControl, CENTER, 0, 0)
		iControl:SetDrawLayer(DL_CONTROLS)

		bControl:SetHandler("OnMouseEnter", function() TBoxAddon.XMLNavigation(501, iControl, 1, tId) end)
		bControl:SetHandler("OnMouseExit", function() TBoxAddon.XMLNavigation(501, iControl, 2, tId) end)
		bControl:SetHandler("OnMouseDown", function() TBoxAddon.XMLNavigation(501, iControl, 3, tId) end)
		bControl:SetHandler("OnMouseUp", function(self, button, upInside) if (upInside) then TBoxAddon.XMLNavigation(501, iControl, 4, tId) end end)
	end

	for k, d in pairs(TBoxAddon.ASV.TreasureDB) do
		if (d.found) then cFound = cFound + 1 end
		if d.zones ~= nil then
			for t, v in pairs(d.zones) do
				if t and t ~= "" then
					if not zoneCount[t] then
						zoneCount[t] = 1
					else
						zoneCount[t] = zoneCount[t] + 1
					end
				end
			end
		end
	end
	for k, v in pairs(zoneCount) do table.insert(zTable, {zone=k, count=v}) end
	table.sort(zTable, function(a,b) return a.count > b.count end)

	if cFound == 0 then -- update the favorite zone values
		TBoxAddon.AT.FavoriteZone = L.TBoxAddon_NONE
		TBoxAddon_MainFrameNavFrameFavoriteZone:SetText(L.TBoxAddon_FAVZONE.." |c00FF00"..tostring(TBoxAddon.AT.FavoriteZone).."|r")
	else
		TBoxAddon.AT.FavoriteZone = zTable[1].zone
		TBoxAddon_MainFrameNavFrameFavoriteZone:SetText(L.TBoxAddon_FAVZONE.." |c00FF00"..tostring(TBoxAddon.AT.FavoriteZone).."|r ("..tostring(zTable[1].count)..")")
	end

	TBoxAddon.AT.TreasuresFound = cFound -- update the number of found treasures
	TBoxAddon_MainFrameNavFrameStatsTotals:SetText(L.TBoxAddon_TFOUND.." |c00FF00"..tostring(TBoxAddon.AT.TreasuresFound).."|r / |cFFFF00"..tostring(TBoxAddon.AT.TreasuresTotal).."|r")
end
