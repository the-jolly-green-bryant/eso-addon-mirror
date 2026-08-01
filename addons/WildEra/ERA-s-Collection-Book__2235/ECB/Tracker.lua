
function ECB_LoadTracker()
	-- main frame
	ECB_TRACKER:SetDimensions(ECB.dimensions.tracker.width, ECB.dimensions.tracker.height)
	
	-- header
	ECB_TRACKER_HEADER:SetDimensions(ECB.dimensions.tracker.width, ECB.dimensions.tracker.default.header.height)
	ECB_TRACKER_HEADER_TITLE:SetDimensions(ECB.dimensions.tracker.width, ECB.dimensions.tracker.default.header.height - 1)
	
	-- body
	ECB_TRACKER_CONTENT:SetDimensions(ECB.dimensions.tracker.width, ECB.dimensions.tracker.height - ECB.dimensions.tracker.default.header.height)
	ECB_TRACKER_CONTENT_BODY_:SetDimensions(ECB.dimensions.tracker.width - 15, ECB.dimensions.tracker.height - ECB.dimensions.tracker.default.header.height - 12)
	
	-- background
	ECB_TRACKER_HEADER_BG:SetAlpha(ECB.dimensions.tracker.opacity / 100)
	ECB_TRACKER_CONTENT_BG:SetAlpha(ECB.dimensions.tracker.opacity / 100)

	local previousCategory = nil
	for i, category in ipairs(ECB.database.categories) do
		category.parameters.tracker.label:SetHidden(not category.parameters.tracker.active)
		category.parameters.tracker.body:SetHidden(true)
		category.parameters.tracker.open = false
		
		if category.parameters.tracker.active then
			-- attach category label to the scroll container
			category.parameters.tracker.label:SetDimensions(ECB.dimensions.tracker.category.width, ECB.dimensions.tracker.category.height)
			category.parameters.tracker.label:SetParent(ECB_TRACKER_CONTENT_BODY_ScrollChild)
			if previousCategory == nil then
				category.parameters.tracker.label:SetAnchor(TOPLEFT, ECB_TRACKER_CONTENT_BODY_ScrollChild, TOPLEFT, 0, 0)
			else
				category.parameters.tracker.label:SetAnchor(TOPLEFT, previousCategory.parameters.tracker.label, BOTTOMLEFT, 0, 0)
			end
			previousCategory = category
			
			-- attach category body to the scroll container
			category.parameters.tracker.body:SetParent(ECB_TRACKER_CONTENT_BODY_ScrollChild)
			category.parameters.tracker.body:SetAnchor(TOPLEFT, category.parameters.tracker.label, BOTTOMLEFT, ECB.dimensions.tracker.default.collectible.offsetX, 0)
			
			-- fill category label
			local text = GetString(category.title)
			category.parameters.tracker.label:SetText(string.format("%s%s (%d/%d)", ECB.parameters.default.prefix, text, category.parameters.unlockedCount, #category.collectibles.list))

			-- collectibles
			local previousCollectible = nil
			for j, collectible in ipairs(category.collectibles.list) do
				if (collectible.active ~= nil and collectible.active) or (collectible.unlocked ~= nil and not collectible.unlocked) then
					collectible.label:SetDimensions(ECB.dimensions.tracker.collectible.width, ECB.dimensions.tracker.collectible.height)
					if previousCollectible == nil then
						collectible.label:SetAnchor(TOPLEFT, category.parameters.tracker.body, TOPLEFT, 0, 0)
					else
						collectible.label:SetAnchor(TOPLEFT, previousCollectible, BOTTOMLEFT, 0, 0)
					end
					previousCollectible = collectible.label
			
					-- fill collectible label
					collectible.label:SetText(string.format("%s%s", ECB.parameters.default.prefix, collectible.name))
				end
				
				-- if category on 2 levels and active
				if (collectible.active ~= nil and collectible.active) then
					local collectibleText = GetString(collectible.name)
					collectible.label:SetText(string.format("%s%s (%d/%d)", ECB.parameters.default.prefix, collectibleText, collectible.unlockedCount, #collectible.list))
					collectible.body:SetAnchor(TOPLEFT, collectible.label, BOTTOMLEFT, ECB.dimensions.tracker.default.collectible.offsetX, 0)
					collectible.body:SetHidden(true)
					collectible.open = false
					local previousSubCollectible = nil
					for k, subCollectible in ipairs(collectible.list) do
						if not subCollectible.unlocked then
							subCollectible.label:SetDimensions(ECB.dimensions.tracker.collectible.width - ECB.dimensions.tracker.default.collectible.offsetX, ECB.dimensions.tracker.collectible.height)
							if previousSubCollectible == nil then
								subCollectible.label:SetAnchor(TOPLEFT, collectible.body, TOPLEFT, 0, 0)
							else
								subCollectible.label:SetAnchor(TOPLEFT, previousSubCollectible, BOTTOMLEFT, 0, 0)
							end
							previousSubCollectible = subCollectible.label
							
							-- fill subCollectible label
							subCollectible.label:SetText(string.format("%s%s", ECB.parameters.default.prefix, subCollectible.name))
						end
					end
				end
			end
		end
	end
end

function ECB_SaveTracker()
	-- width
	local textWidth = ECB_GUI_BOOK_CONTENT_SETTINGS_RIGHT_UI_WIDTH:GetText()
	numberWidth = tonumber(textWidth)
	if numberWidth ~= nil then
		if numberWidth <= 220 then
			numberWidth = 220
		end
		if numberWidth >= 600 then
			numberWidth = 600
		end
		ECB.dimensions.tracker.width = numberWidth
		ECB_GUI_BOOK_CONTENT_SETTINGS_RIGHT_UI_WIDTH:SetText(ECB.dimensions.tracker.width)
	end
	
	-- height
	local textHeight = ECB_GUI_BOOK_CONTENT_SETTINGS_RIGHT_UI_HEIGHT:GetText()
	numberHeight = tonumber(textHeight)
	if numberHeight ~= nil then
		if numberHeight <= 200 then
			numberHeight = 200
		end
		if numberHeight >= 600 then
			numberHeight = 600
		end
		ECB.dimensions.tracker.height = numberHeight
		ECB_GUI_BOOK_CONTENT_SETTINGS_RIGHT_UI_HEIGHT:SetText(ECB.dimensions.tracker.height)
	end
	
	-- opacity
	local textOpacity = ECB_GUI_BOOK_CONTENT_SETTINGS_RIGHT_UI_BG:GetText()
	numberOpacity = tonumber(textOpacity)
	if numberOpacity ~= nil then
		if numberOpacity <= 0 then
			numberOpacity = 0
		end
		if numberOpacity >= 100 then
			numberOpacity = 100
		end
		ECB.dimensions.tracker.opacity = numberOpacity
		ECB_GUI_BOOK_CONTENT_SETTINGS_RIGHT_UI_BG:SetText(ECB.dimensions.tracker.opacity)
	end
	
	-- save values
	ECB.savedVars.dimensions = {}
	ECB.savedVars.dimensions.width = ECB.dimensions.tracker.width
	ECB.savedVars.dimensions.height = ECB.dimensions.tracker.height
	ECB.savedVars.dimensions.opacity = ECB.dimensions.tracker.opacity
	
	ECB_LoadTracker()
end

function ECB_ResetTracker()
	-- width
	ECB_GUI_BOOK_CONTENT_SETTINGS_RIGHT_UI_WIDTH:SetText(ECB.dimensions.tracker.default.width)
	ECB.dimensions.tracker.width = ECB.dimensions.tracker.default.width
	
	-- height
	ECB_GUI_BOOK_CONTENT_SETTINGS_RIGHT_UI_HEIGHT:SetText(ECB.dimensions.tracker.default.height)
	ECB.dimensions.tracker.height = ECB.dimensions.tracker.default.width
	
	-- opacity
	ECB_GUI_BOOK_CONTENT_SETTINGS_RIGHT_UI_BG:SetText(ECB.dimensions.tracker.default.opacity)
	ECB.dimensions.tracker.opacity = ECB.dimensions.tracker.default.opacity
	
	-- save values
	ECB.savedVars.dimensions = {}
	ECB.savedVars.dimensions.width = ECB.dimensions.tracker.width
	ECB.savedVars.dimensions.height = ECB.dimensions.tracker.height
	ECB.savedVars.dimensions.opacity = ECB.dimensions.tracker.opacity
	
	ECB_LoadTracker()
end
