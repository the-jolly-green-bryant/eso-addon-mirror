local sf = string.format
local zo_str = zo_strformat

local function MotifHeaderSetup(node, control, data, open)
	local motif = TraitBuddy.data:GetMotif(data.order)

	control:GetNamedChild("Icon"):SetTexture(motif:CollectibleIcon())
	local crown = control:GetNamedChild("CrownStore")
	if crown then
		crown:SetHidden(not motif:IsCrownStoreOnly())
	end

	local ctrl = control:GetNamedChild("Text")
	local linkName = motif:SimpleLinkName()
	if linkName == nil then linkName = GetString(SI_CRAFTING_UNKNOWN_NAME) end
	ctrl:SetText(linkName)
	ctrl:SetColor(data.normalColor.r, data.normalColor.g, data.normalColor.b, data.normalColor.a)

	control.order = data.order
	control:GetNamedChild("Material"):SetTexture(motif:MaterialIcon())
	
	ctrl = control:GetNamedChild("Toggle")
	if ctrl then
		ZO_ToggleButton_SetState(ctrl, open)
	end
end

local function ChapterEntrySetup(node, control, data, open)
	local parentdata = node:GetParent():GetData()
	local motif = TraitBuddy.data:GetMotif(parentdata.order)
	
	local ctrl = control:GetNamedChild("Text")
	ctrl:SetText(motif:SimpleChapterLinkName(data.chapter))
	ctrl:SetColor(parentdata.normalColor.r, parentdata.normalColor.g, parentdata.normalColor.b, parentdata.normalColor.a)
end

local function ChapterEntryEquality(left, right)
	return left.data.chapter == right.data.chapter
end

local function DoesSelectedCharacter_KnowMotif(order, chapter)
	local known = false
	if TraitBuddy.ui.selector:IsCharacterSelected() then
		local c = TraitBuddy.ui.selector:GetSelectedCharacter()
		if chapter then
			if c.motifs[order] then
				if c.motifs[order][chapter] == true then
					known = true
				end
			end
		else
			if c.motifs[order] == true then
				known = true
			end
		end
	end
	return known
end

local function OnFilterSelected(comboBox, text, item, selectionChanged)
	TraitBuddy.ui.motifs:OnFilterSelected(selectionChanged, item.index)
end

TB_Motifs = ZO_Object:Subclass()

function TB_Motifs:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function TB_Motifs:Initialize(parent)
	self.parent = parent
	self.numMotifsTotal, self.numChaptersTotal = TraitBuddy.data:GetNumMotifs()
	self.numChapters = TraitBuddy.data:GetNumChapters()
	self.almostComplete = 8
	self.selectedMotif = nil
	
	self.scrollContainer = parent:GetNamedChild("Container")
	self.tree = ZO_Tree:New(self.scrollContainer:GetNamedChild("ScrollChild"), 0, 0, 500)
	self.tree:SetExclusive(true)
	self.tree:SetOpenAnimation("ZO_TreeOpenAnimation")
	--ZO_Tree:AddTemplate(template, setupFunction, selectionFunction, equalityFunction, childIndent, childSpacing)  
	self.tree:AddTemplate("TB_MotifChildlessHeader", MotifHeaderSetup, nil, nil, 0, 0)
	self.tree:AddTemplate("TB_MotifHeader", MotifHeaderSetup, OnSelection, nil, 0, 0)
	self.tree:AddTemplate("TB_MotifEntry", ChapterEntrySetup, nil, ChapterEntryEquality, 50, 0)
	
	local keys = {}
	for k in pairs(TraitBuddy.data:GetMotifs()) do
		keys[#keys+1] = k;
	end
	table.sort(keys)
	self.keys = keys

	local headings = parent:GetNamedChild("Headings")
	self.filter = headings:GetNamedChild("Filter")
	self:AddFilters()
	self.total = headings:GetNamedChild("Total")
	zo_callLater(function()
		if self.filter then
			self:SelectFirstFilter()
		end
	end, 100)
end

function TB_Motifs:IsMotifKnown(c, order, chapter)
	--Known by anyone, chapter optional, Returns someoneKnows, selectedKnows
	local know, _ = self:GetWhoKnowsMotif(order, chapter, false)
	return (#know > 0), ZO_IsElementInNumericallyIndexedTable(know, c.name)
end

function TB_Motifs:GetWhoKnowsMotif(order, chapter, forTooltip)
	--Figure out who knows the motif, chapter optional. Returns sorted tables of character names
	local know = {}
	local dontKnow = {}
	for _,id in ipairs(TraitBuddy:GetCharacters(true)) do
		local c = TraitBuddy:GetCharacter(id)
		local show = true
		if forTooltip then
			show = c.show.motif
		end
		if show then
			if chapter then
				if c.motifs[order] then
					if c.motifs[order][chapter] == true then
						know[#know+1] = c.name
					else
						dontKnow[#dontKnow+1] = c.name
					end
				else
					dontKnow[#dontKnow+1] = c.name
				end
			else
				if c.motifs[order] == true then
					know[#know+1] = c.name
				else
					dontKnow[#dontKnow+1] = c.name
				end
			end
		end
	end
	return know, dontKnow
end

function TB_Motifs:AddFilters()
	local motifText = GetString("SI_ITEMTYPE", ITEMTYPE_RACIAL_STYLE_MOTIF)
	local text = zo_str(SI_ALCHEMY_UNKNOWN_RESULT, motifText)
	if text:sub(text:len())=="." then
		text = text:sub(0, text:len()-1)
	end
	local texts = {
		[1] = GetString(SI_GAMEPAD_GUILD_HISTORY_SUBCATEGORY_ALL),
		[2] = GetString(TB_MOTIF_ALMOST),
		[3] = text,
		[4] = zo_str(SI_ITEM_FORMAT_STR_KNOWN_ITEM_TYPE, motifText)
	}
	local combobox = ZO_ComboBox_ObjectFromContainer(self.filter)
	combobox:SetSortsItems(false)
	for k,v in ipairs(texts) do
		local item = ZO_ComboBox:CreateItemEntry(v, OnFilterSelected)
		item.index = k
		combobox:AddItem(item, ZO_COMBOBOX_SUPRESS_UPDATE)
	end
	combobox:UpdateItems()
end

function TB_Motifs:OnFilterSelected(selectionChanged, index)
	if selectionChanged then
		if index == 1 then
			self:Create()
		else
			if index == 2 then
				self:Create_AlmostComplete()
			elseif index == 3 then
				self:Create(false)
			elseif index == 4 then
				self:Create(true)
			end
		end
		ZO_Scroll_UpdateScrollBar(self.scrollContainer)
	end
end

function TB_Motifs:SelectFirstFilter()
	if self.filter then
		ZO_ComboBox_ObjectFromContainer(self.filter):SelectFirstItem(false)
	end
end

function TB_Motifs:SelectCurrentFilter()
	local combobox = ZO_ComboBox_ObjectFromContainer(self.filter)
	self:OnFilterSelected(true, combobox:GetSelectedItemData().index)
end

function TB_Motifs:Show()
	if self.parent:IsHidden() then
		self.parent:SetHidden(false)
	end
end

function TB_Motifs:Hide()
	if not self.parent:IsHidden() then
		self.parent:SetHidden(true)
	end
end

function TB_Motifs:DisplayTooltip(control, itemLink, GamePadMode)
	--Add to the motif tooltips
	local itemStyleId, chapter, motifOrder, chapterOrder = TraitBuddy.data:GetMotifStyle(itemLink)
	if itemStyleId > 0 then
		local know, dont = self:GetWhoKnowsMotif(motifOrder, chapterOrder, true)
		if not GamePadMode then
			if (TraitBuddy.settings.tooltip.show.knowSection and #know>0) or (TraitBuddy.settings.tooltip.show.canResearchSection and #dont>0) or TraitBuddy.settings.tooltip.show.motifLocation then
				control:AddVerticalPadding(5)
				ZO_Tooltip_AddDivider(control)
			end
		end
		if #know>0 or #dont>0 then
			TraitBuddy:BuildTooltip(control, know, {}, dont, GamePadMode)
		end
		if TraitBuddy.settings.tooltip.show.motifLocation then
			local motif = TraitBuddy.data:GetMotif(motifOrder)
			if GamePadMode then
				local gp1 = TraitBuddy:GetGamepadStyle(1)
				local bs = control:GetStyle("bodySection")
				gp1.fontColor = ZO_ColorDef:New(1, 1, 1)
				control:AddLine(GetString(SI_HOUSING_LOCATION_HEADER), gp1, bs)
				control:AddLine(motif:CollectibleDescription(), TraitBuddy:GetGamepadStyle(2), bs)
			else
				local r,g,b = ZO_NORMAL_TEXT:UnpackRGB()
				control:AddVerticalPadding(5)
				control:AddLine(GetString(SI_HOUSING_LOCATION_HEADER), "ZoFontGameBold", 1,1,1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
				control:AddLine(motif:CollectibleDescription(), "ZoFontGame", r,g,b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
			end
		end
	end
end

function TB_Motifs:DisplayHeaderTooltip(control, data)
	local motif = TraitBuddy.data:GetMotif(data.order)
	local col = GetItemQualityColor(motif:Quality())
	local linkName = motif:LinkName()
	if linkName == nil then linkName = GetString(SI_CRAFTING_UNKNOWN_NAME) end
	control:AddLine(linkName, "ZoFontGameBold", col.r,col.g,col.b, LEFT, MODIFY_TEXT_TYPE_UPPERCASE, TEXT_ALIGN_CENTER, true)
	if TraitBuddy.settings.tooltip.show.motifLocation then
		ZO_Tooltip_AddDivider(control)
		control:AddVerticalPadding(5)
		control:AddLine(GetString(SI_HOUSING_LOCATION_HEADER), "ZoFontGameBold", 1,1,1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
		local r,g,b = ZO_NORMAL_TEXT:UnpackRGB()
		control:AddLine(motif:CollectibleDescription(), "ZoFontGame", r,g,b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
	end
end

function TB_Motifs:ShouldShow_AlmostComplete(order, hasChapter)
	--Figure out if the motif should be shown
	for id,c in pairs(TraitBuddy:GetCharacters()) do
		if hasChapter then
			local num = 0
			for i = 1, self.numChapters do
				if c.motifs[order][i] then
					num = num + 1
				end
			end
			if c.show.motif and num >= self.almostComplete and num < self.numChapters then
				return true
			end
		else
			if c.motifs[order]==false and c.show.motif then
				return true
			end
		end
	end
	return false
end

function TB_Motifs:ShouldShow(showKnown, order, hasChapter)
	--Figure out if the motif should be shown
	if showKnown==nil then
		return true
	else
		for id,c in pairs(TraitBuddy:GetCharacters()) do
			if hasChapter then
				for i = 1, self.numChapters do
					if c.motifs[order][i]==showKnown and c.show.motif then
						return true
					end
				end
			else
				if c.motifs[order]==showKnown and c.show.motif then
					return true
				end
			end
		end
		return false
	end
end

function TB_Motifs:GetShowChapters(showKnown, order)
	--Figure out if the motif chapters should be shown
	local showChapters = {}
	if showKnown==nil then
		for i = 1, self.numChapters do
			showChapters[i] = true
		end
	else
		for i = 1, self.numChapters do
			showChapters[i] = false
		end
		for id,c in pairs(TraitBuddy:GetCharacters()) do
			for i = 1, self.numChapters do
				if c.motifs[order][i]==showKnown and c.show.motif then
					showChapters[i] = true
				end
			end
		end
	end
	return showChapters
end

function TB_Motifs:Create_AlmostComplete()
	--Populate tree with all motifs which are almost complete
	local tree = self.tree
	local keys = self.keys
	tree:Reset()
	local motifs = TraitBuddy.data:GetMotifs()
	for i=1, #keys do
		local order = keys[i]
		local motif = motifs[order]
		local normal = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, motif:Quality()))
		local highlight = normal:Lerp(ZO_ColorDef:New(1, 1, 1, 1), 0.5)
		if motif:HasChapters() then
			if self:ShouldShow_AlmostComplete(order, true) then
				local header = tree:AddNode("TB_MotifHeader", { order=order, normalColor = normal, highlightColor = highlight }, nil, SOUNDS.JOURNAL_PROGRESS_CATEGORY_SELECTED)
				for j = 1, self.numChapters do
					tree:AddNode("TB_MotifEntry", { chapter=j }, header, nil)
				end
			end
		else
			if self:ShouldShow_AlmostComplete(order, false) then
				tree:AddNode("TB_MotifChildlessHeader", { order=order, normalColor = normal, highlightColor = highlight }, nil, nil)
			end
		end
	end
	self:UpdateUI()
end

function TB_Motifs:Create(showKnown)
	--Populate tree with all motifs, unknown or known
	local tree = self.tree
	local keys = self.keys
	tree:Reset()
	local motifs = TraitBuddy.data:GetMotifs()
	for i=1, #keys do
		local order = keys[i]
		local motif = motifs[order]
		local normal = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, motif:Quality()))
		local highlight = normal:Lerp(ZO_ColorDef:New(1, 1, 1, 1), 0.5)
		if motif:HasChapters() then
			if self:ShouldShow(showKnown, order, true) then
				local header = tree:AddNode("TB_MotifHeader", { order=order, normalColor = normal, highlightColor = highlight }, nil, SOUNDS.JOURNAL_PROGRESS_CATEGORY_SELECTED)
				local showChapters = self:GetShowChapters(showKnown, order)
				for j = 1, self.numChapters do
					if showChapters[j] then
						tree:AddNode("TB_MotifEntry", { chapter=j }, header, nil)
					end
				end
			end
		else
			if self:ShouldShow(showKnown, order, false) then
				tree:AddNode("TB_MotifChildlessHeader", { order=order, normalColor = normal, highlightColor = highlight }, nil, nil)
			end
		end
	end
	self:UpdateUI()
end

function TB_Motifs:FilterMotifsByText(searchText)
    self.tree:Reset()

    for _, order in ipairs(self.keys) do
        local motif = TraitBuddy.data:GetMotif(order)
        if motif then
            local name = motif:SimpleLinkName()
            if name and name:lower():find(searchText:lower()) then
                local normal = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, motif:Quality()))
                local highlight = normal:Lerp(ZO_ColorDef:New(1, 1, 1, 1), 0.5)

                if motif:HasChapters() then
                    local header = self.tree:AddNode("TB_MotifHeader", {
                        order = order,
                        normalColor = normal,
                        highlightColor = highlight,
                    })
                    for j = 1, self.numChapters do
                        self.tree:AddNode("TB_MotifEntry", { chapter = j }, header)
                    end
                else
                    self.tree:AddNode("TB_MotifChildlessHeader", {
                        order = order,
                        normalColor = normal,
                        highlightColor = highlight,
                    })
                end
            end
        end
    end

    self.tree:Commit()
    self:UpdateUI()
end

function TB_Motifs:OnSearchTextChanged(control)
    local text = control:GetText() or ""
    self:FilterMotifsByText(text)
end

function TB_Motifs:Header_OnMouseUp(entry, button, upInside)
	local data = entry.node:GetData()
	local motif = TraitBuddy.data:GetMotif(data.order)

    if (button == MOUSE_BUTTON_INDEX_LEFT) then
		entry.node:SetOpen(not entry.node:IsOpen(), USER_REQUESTED_OPEN)
    elseif (button == MOUSE_BUTTON_INDEX_RIGHT and IsChatSystemAvailableForCurrentPlatform() and upInside and motif:HasAchievement()) then
        ClearMenu()
        AddMenuItem(GetString(TB_LINK_ACHIEVEMENT), function() ZO_LinkHandler_InsertLink(motif:AchievementLink()) end)
        ShowMenu(entry)
    end
end

function TB_Motifs:Header_OnMouseEnter(entry)
	local data = entry.node:GetData()
	entry:GetNamedChild("Text"):SetColor(data.highlightColor.r, data.highlightColor.g, data.highlightColor.b, data.highlightColor.a)
	InitializeTooltip(InformationTooltip, entry, LEFT, 5, 0)
	self:DisplayHeaderTooltip(InformationTooltip, data)
	InformationTooltip:AddVerticalPadding(5)
	InformationTooltip:AddLine(zo_iconTextFormat("esoui/art/icons/icon_rmb.dds", 26, 26, GetString(SI_BINDING_NAME_GAMEPAD_TOGGLE_GAME_CAMERA_UI_MODE)), "ZoFontGame", 1,1,1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
end

function TB_Motifs:Header_OnMouseExit(entry)
	local data = entry.node:GetData()
	entry:GetNamedChild("Text"):SetColor(data.normalColor.r, data.normalColor.g, data.normalColor.b, data.normalColor.a)
	ClearTooltip(InformationTooltip)
end

function TB_Motifs:ChildlessHeader_OnMouseEnter(entry)
	local data = entry.node:GetData()
	local motif = TraitBuddy.data:GetMotif(data.order)
	local link = motif:Link()

	entry:GetNamedChild("Text"):SetColor(data.highlightColor.r, data.highlightColor.g, data.highlightColor.b, data.highlightColor.a)
	InitializeTooltip(ItemTooltip, entry, LEFT, 5, 0)
	ItemTooltip:SetLink(link)
	self:DisplayTooltip(ItemTooltip, link)
	ItemTooltip:AddVerticalPadding(5)
	ItemTooltip:AddLine(zo_iconTextFormat("esoui/art/icons/icon_rmb.dds", 26, 26, GetString(SI_BINDING_NAME_GAMEPAD_TOGGLE_GAME_CAMERA_UI_MODE)), "ZoFontGame", 1,1,1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
end

function TB_Motifs:ChildlessHeader_OnMouseExit(entry)
	local data = entry.node:GetData()
	entry:GetNamedChild("Text"):SetColor(data.normalColor.r, data.normalColor.g, data.normalColor.b, data.normalColor.a)
	ClearTooltip(ItemTooltip)
end

function TB_Motifs:ChildlessHeader_OnMouseUp(entry, button, upInside)
    if (button == MOUSE_BUTTON_INDEX_RIGHT and IsChatSystemAvailableForCurrentPlatform() and upInside) then
		local data = entry.node:GetData()
		local motif = TraitBuddy.data:GetMotif(data.order)

        ClearMenu()
        AddMenuItem(GetString(SI_ITEM_ACTION_LINK_TO_CHAT), function() ZO_LinkHandler_InsertLink(motif:Link()) end)
		if motif:HasAchievement() then
			AddMenuItem(GetString(TB_LINK_ACHIEVEMENT), function() ZO_LinkHandler_InsertLink(motif:AchievementLink()) end)
		end
        ShowMenu(entry)
    end
end

function TB_Motifs:MotifEntry_OnMouseEnter(entry)
	local parentdata = entry.node:GetParent():GetData()
	local data = entry.node:GetData()
	local motif = TraitBuddy.data:GetMotif(parentdata.order)
	local link = motif:ChapterLink(data.chapter)

	entry:GetNamedChild("Text"):SetColor(parentdata.highlightColor.r, parentdata.highlightColor.g, parentdata.highlightColor.b, parentdata.highlightColor.a)
	InitializeTooltip(ItemTooltip, entry, LEFT, 5, 0)
	ItemTooltip:SetLink(link)
	self:DisplayTooltip(ItemTooltip, link)
	ItemTooltip:AddVerticalPadding(5)
	ItemTooltip:AddLine(zo_iconTextFormat("esoui/art/icons/icon_rmb.dds", 26, 26, GetString(SI_BINDING_NAME_GAMEPAD_TOGGLE_GAME_CAMERA_UI_MODE)), "ZoFontGame", 1,1,1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
end

function TB_Motifs:MotifEntry_OnMouseExit(entry)
	local parentdata = entry.node:GetParent():GetData()
	entry:GetNamedChild("Text"):SetColor(parentdata.normalColor.r, parentdata.normalColor.g, parentdata.normalColor.b, parentdata.normalColor.a)
	ClearTooltip(ItemTooltip)
end

function TB_Motifs:MotifEntry_OnMouseUp(entry, button, upInside)
    if (button == MOUSE_BUTTON_INDEX_RIGHT and IsChatSystemAvailableForCurrentPlatform() and upInside) then
		local parentdata = entry.node:GetParent():GetData()
		local data = entry.node:GetData()
		local motif = TraitBuddy.data:GetMotif(parentdata.order)
		local link = motif:ChapterLink(data.chapter)

        ClearMenu()
        AddMenuItem(GetString(SI_ITEM_ACTION_LINK_TO_CHAT), function() ZO_LinkHandler_InsertLink(link) end)
		if motif:HasAchievement() then
			AddMenuItem(GetString(TB_LINK_ACHIEVEMENT), function() ZO_LinkHandler_InsertLink(motif:AchievementLink()) end)
		end
        ShowMenu(entry)
    end
end

function TB_Motifs:Material_OnMouseEnter(control)
	local motif = TraitBuddy.data:GetMotif(control:GetParent().order)
	InitializeTooltip(ItemTooltip, control, LEFT, 5, 0)
	ItemTooltip:SetLink(motif:MaterialLink())
	ItemTooltip:AddVerticalPadding(10)
	ItemTooltip:AddLine(zo_iconTextFormat("esoui/art/icons/icon_rmb.dds", 26, 26, GetString(SI_BINDING_NAME_GAMEPAD_TOGGLE_GAME_CAMERA_UI_MODE)), "ZoFontGame", 1,1,1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
end

function TB_Motifs:Material_OnMouseExit(control)
	ClearTooltip(ItemTooltip)
end

function TB_Motifs:Material_OnMouseUp(control, button, upInside)
	if (button == MOUSE_BUTTON_INDEX_RIGHT and IsChatSystemAvailableForCurrentPlatform() and upInside) then
		local motif = TraitBuddy.data:GetMotif(control:GetParent().order)
		ClearMenu()
        AddMenuItem(GetString(SI_ITEM_ACTION_LINK_TO_CHAT), function() ZO_LinkHandler_InsertLink(motif:MaterialLink()) end)
		ShowMenu(control)
	end
end

function TB_Motifs:OnStyleLearned(itemStyleId, chapterIndex)
	local c = TraitBuddy:GetCharacter(TraitBuddy.characterId)
	if c then
		local motif = TraitBuddy.data:GetMotifByItemStyleId(itemStyleId)
		if motif then
			local order = motif:Order()
			if motif:HasChapters() then
				if chapterIndex == ITEM_STYLE_CHAPTER_ALL then
					--Learned from all in one motif (crown store or looted book)
					for chapter = 1, self.numChapters do
						c.motifs[order][chapter] = true
					end
				else
					local chapter = TraitBuddy.data:GetChapterOrder(chapterIndex)
					c.motifs[order][chapter] = true
				end
			else
				c.motifs[order] = true
			end
		end
		self:SelectCurrentFilter()
	end
end

function TB_Motifs:UpdateUI()
	--Update the motif screen for the currently selected alt
	if not TraitBuddy.ui:IsCreated() then
		TraitBuddy.ui.updatelater:UpdateMotifUI()
		return
	end
	
	self.total.motifs = 0
	self.total.chapters = 0

	if TraitBuddy.ui.selector:IsCharacterSelected() then
		local c = TraitBuddy.ui.selector:GetSelectedCharacter()
		local children = self.tree.rootNode:GetChildren()
		if (children) then
			local colours = TraitBuddy.settings.colours
			for i = 1, #children do
				local data = children[i]:GetData()
				if children[i]:IsLeaf() then
					local someoneKnows, selectedKnows = self:IsMotifKnown(c, data.order)

					local ctrl = children[i]:GetControl()
					ctrl.yes:SetHidden(not someoneKnows)
					ctrl.no:SetHidden(someoneKnows)
					ctrl.no:SetColor(colours.not_known.r, colours.not_known.g, colours.not_known.b)
					if selectedKnows then
						self.total.motifs = self.total.motifs + 1
						ctrl.yes:SetColor(colours.know.r, colours.know.g, colours.know.b)
					elseif someoneKnows then
						ctrl.yes:SetColor(colours.others_know.r, colours.others_know.g, colours.others_know.b)
					end
				else
					local chapters = children[i]:GetChildren()
					local known = 0
					local othersKnow = 0
					for chapter = 1, #chapters do
						local chapterData = chapters[chapter]:GetData()
						local someoneKnows, selectedKnows = self:IsMotifKnown(c, data.order, chapterData.chapter)

						local ctrl = chapters[chapter]:GetControl()
						ctrl.yes:SetHidden(not someoneKnows)
						ctrl.no:SetHidden(someoneKnows)
						ctrl.no:SetColor(colours.not_known.r, colours.not_known.g, colours.not_known.b)
						if selectedKnows then
							known = known + 1
							ctrl.yes:SetColor(colours.know.r, colours.know.g, colours.know.b)
						elseif someoneKnows then
							othersKnow = othersKnow + 1
							ctrl.yes:SetColor(colours.others_know.r, colours.others_know.g, colours.others_know.b)
						end
					end
					local ctrl = children[i]:GetControl()
					ctrl.yes:SetHidden((known < self.numChapters) and (othersKnow < self.numChapters))
					ctrl.no:SetHidden((known > 0) or (known+othersKnow == self.numChapters))
					ctrl.knowText:SetHidden((known == 0) or (known == self.numChapters) or (othersKnow == self.numChapters))
					ctrl.knowText:SetText(sf("%d/%d", known, self.numChapters))
					ctrl.no:SetColor(colours.not_known.r, colours.not_known.g, colours.not_known.b)
					if known == self.numChapters then
						self.total.motifs = self.total.motifs + 1
						ctrl.yes:SetColor(colours.know.r, colours.know.g, colours.know.b)
					else
						ctrl.yes:SetColor(colours.others_know.r, colours.others_know.g, colours.others_know.b)
					end
					self.total.chapters = self.total.chapters + known
				end
			end
			
		end
	else
		--Disable all the motifs
		local children = self.tree.rootNode:GetChildren()
		if (children) then
			for i = 1, #children do
				local ctrl = children[i]:GetControl()
				ctrl.yes:SetHidden(true)
				ctrl.no:SetHidden(false)
				if not children[i]:IsLeaf() then
					ctrl.knowText:SetHidden(true)
					local chapters = children[i]:GetChildren()
					for chapter = 1, #chapters do
						local ctrl = chapters[chapter]:GetControl()
						ctrl.yes:SetHidden(true)
						ctrl.no:SetHidden(false)
					end
				end
			end
		end
	end
	self:UpdateTotal()
end

function TB_Motifs:UpdateTotal()
	self.total:SetText(sf("%d/%d (%d/%d)", self.total.motifs, self.numMotifsTotal, self.total.chapters, self.numChaptersTotal))
end

function TB_Motifs:Total_OnMouseEnter(control)
	local r, g, b = ZO_NORMAL_TEXT:UnpackRGB()
	InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 5, BOTTOMLEFT)
	InformationTooltip:AddLine(sf("%s: %d / %d", GetString(SI_SPECIALIZEDITEMTYPE60), control.motifs, self.numMotifsTotal), "ZoFontGame", r,g,b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
	InformationTooltip:AddLine(sf("%s: %d / %d", GetString(SI_SPECIALIZEDITEMTYPE61), control.chapters, self.numChaptersTotal), "ZoFontGame", r,g,b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
end

function TB_Motifs:Total_OnMouseExit(control)
	ClearTooltip(InformationTooltip)
end