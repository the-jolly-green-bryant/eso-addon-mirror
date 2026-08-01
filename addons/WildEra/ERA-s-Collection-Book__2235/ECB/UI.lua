
function ECB:ToggleWindow()
	ECB_TRACKER:SetHidden(ECB.active.tracker)
	ECB.active.tracker = not ECB.active.tracker
	ECB.savedVars.active = ECB.active.tracker
	if ECB.active.book then
		ECB:ToggleBookWindow()
	end
end

function ECB:ToggleBookWindow()
	ECB_GUI_BOOK:SetHidden(ECB.active.book)
	ECB.active.book = not ECB.active.book
end

function ECB:HideIfActive()
	if ECB.active.tracker then
		ECB_TRACKER:SetHidden(true)
		if ECB.active.book then
			ECB_GUI_BOOK:SetHidden(true)
		end
	end
end

function ECB:ShowIfActive()
	if ECB.active.tracker then
		ECB_TRACKER:SetHidden(false)
		if ECB.active.book then
			ECB_GUI_BOOK:SetHidden(false)
		end
	end
end

function ECB:SaveWindowLocation()
	ECB.savedVars.position = {}
	ECB.savedVars.position.x = ECB_TRACKER:GetLeft()
	ECB.savedVars.position.y = ECB_TRACKER:GetTop()
end

function ECB:OpenCloseCategory(categoryId)
	for i, category in ipairs(ECB.database.categories) do
		if category.id == categoryId then
			category.parameters.tracker.body:SetHidden(category.parameters.tracker.open)
			
			-- find next category active
			local nextCategory = nil
			for y = i + 1, #ECB.database.categories do
				if ECB.database.categories[y].parameters.tracker.active then
					nextCategory = ECB.database.categories[y]
					break
				end
			end
			
			if nextCategory ~= nil then
				local element = category.parameters.tracker.label
				local offsetX = 0
				if not category.parameters.tracker.open then
					element = category.parameters.tracker.body
					offsetX = offsetX - ECB.dimensions.tracker.default.collectible.offsetX
				end
				nextCategory.parameters.tracker.label:SetAnchor(TOPLEFT, element, BOTTOMLEFT, offsetX, 0)
			end
			
			category.parameters.tracker.open = not category.parameters.tracker.open
			
			break
		end
	end
end

function ECB:OpenCloseSubCategory(categoryId, subCategoryId)
	for i, category in ipairs(ECB.database.categories) do
		if category.id == categoryId then
			for j, subCategory in ipairs(category.collectibles.list) do
				if subCategory.id == subCategoryId then
					subCategory.body:SetHidden(subCategory.open)
					
					-- find next sub category active
					local nextCategory = nil
					for y = j + 1, #category.collectibles.list do
						if category.collectibles.list[y].active then
							nextCategory = category.collectibles.list[y]
							break
						end
					end
					
					if nextCategory ~= nil then
						local element = subCategory.label
						local offsetX = 0
						if not subCategory.open then
							element = subCategory.body
							offsetX = offsetX - ECB.dimensions.tracker.default.collectible.offsetX
						end
						nextCategory.label:SetAnchor(TOPLEFT, element, BOTTOMLEFT, offsetX, 0)
					end
					
					subCategory.open = not subCategory.open
					
					break
				end
			end
			
			break
		end
	end
end

function ECB:OpenChapter(chapterId)
	for i, page in ipairs(ECB.database.book) do
		if page.id == chapterId then
			-- change title
			local titleText = GetString(page.title)
			ECB_GUI_BOOK_CONTENT_TITLE:SetText(string.format("%s%s", ECB.parameters.default.prefix, string.upper(titleText)))
			ECB_GUI_BOOK_SUMMARY_BG_SELECT:SetAnchor(TOPLEFT, page.menu, TOPLEFT, 0, 0)
			ECB_GUI_BOOK_SUMMARY_BG_SELECT:SetAnchor(BOTTOMRIGHT, page.menu, BOTTOMRIGHT, 0, 4)
			
			-- open content
			page.content:SetHidden(false)
		else
			-- close content
			page.content:SetHidden(true)
		end
	end
end
