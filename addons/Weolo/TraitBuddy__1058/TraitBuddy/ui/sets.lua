local sf = string.format

local function TB_SetsHeader_Setup(node, control, data, open)
    -- On first setup the control may already exist from the tree's recycler.
    -- Ensure the named children we expect are there.
    if not control.setNameLabel then
        local wm = WINDOW_MANAGER
        control:SetDimensions(470, 36)
        control:SetMouseEnabled(true)

        local setName = wm:CreateControl(nil, control, CT_LABEL)
        setName:SetAnchor(LEFT, control, LEFT, 10, 0)
        setName:SetFont("ZoFontHeader2")
        control.setNameLabel = setName

        local traits = wm:CreateControl(nil, control, CT_LABEL)
        traits:SetAnchor(RIGHT, control, RIGHT, -10, 0)
        traits:SetFont("ZoFontHeader3")
        control.traitsLabel = traits

        control:SetHandler("OnMouseEnter", function(self)
            TraitBuddy.ui.sets:Header_OnMouseEnter(self)
        end)
        control:SetHandler("OnMouseExit", function(self)
            TraitBuddy.ui.sets:Header_OnMouseExit(self)
        end)

        -- Patch GetNamedChild so sets.lua's Header_OnMouseEnter can call it
        local origGet = control.GetNamedChild
        control.GetNamedChild = function(self, name)
            if name == "SetName" then return self.setNameLabel end
            if name == "Traits"  then return self.traitsLabel  end
            return origGet(self, name)
        end
    end

    -- Populate (mirrors TreeHeaderSetup)
    control.setNameLabel:SetText(data.name)
    control.traitsLabel:SetText(data.traits)
    control.key = data.key
end

local function TB_SetsHeader_Equality(left, right)
    return left.data.name == right.data.name
end

local function SortByName(left, right)
    return left.name < right.name
end

local function SortByTrait(left, right)
	if left.traits == right.traits then
		return left.name < right.name
	else
		return left.traits < right.traits
	end
end

TB_Sets = ZO_Object:Subclass()

function TB_Sets:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function TB_Sets:Initialize(parent)
	self.parent = parent
	self.scrollContainer = self.parent:GetNamedChild("ScrollChild")
	self.tree = ZO_Tree:New(self.scrollContainer, 0, 0, 500)
	self.tree:SetOpenAnimation("ZO_TreeOpenAnimation")
	self.tree:AddTemplate("TB_SetsHeader", TB_SetsHeader_Setup, nil, TB_SetsHeader_Equality, 0, 0)
	self.sortByName = 1
	self.sortByTrait = 2
	self.qualityColor = GetItemQualityColor(ITEM_FUNCTIONAL_QUALITY_LEGENDARY)
	self:Create()
end

function TB_Sets:Show()
	if self.parent:IsHidden() then
		self.parent:SetHidden(false)
	end
end

function TB_Sets:Hide()
	if not self.parent:IsHidden() then
		self.parent:SetHidden(true)
	end
end

function TB_Sets:Create()
	-- Populate tree with all sets
	local tree = self.tree
	tree:Reset()
	local sets = TraitBuddy.data:GetSets()
	table.sort(sets, SortByName)
	for i, set in pairs(sets) do
		tree:AddNode("TB_SetsHeader", {key=i, id=set.id, name=set.name, traits=set.traits}, nil, nil)
	end
	tree:Commit()
end

function TB_Sets:Header_OnMouseEnter(header)
	local set = TraitBuddy.data:GetSet(header.key)
	if not set then return end

	InitializeTooltip(InformationTooltip, header, LEFT, 5, 0)
	InformationTooltip:AddLine(set.name, "ZoFontHeader3", self.qualityColor.r, self.qualityColor.g, self.qualityColor.b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
	InformationTooltip:AddLine(sf("%d %s", set.traits, GetString(SI_CRAFTING_COMPONENT_TOOLTIP_TRAITS)), "ZoFontHeader2", 1, 1, 1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
	ZO_Tooltip_AddDivider(InformationTooltip)
	
	-- Get set bonuses directly from the set ID — no item link needed.
	-- GetItemSetInfo / GetItemSetBonusInfo accept the set ID that LibSets provides.
	local hasSet, _, numBonuses = GetItemSetInfo(set.id)
	if hasSet and numBonuses and numBonuses > 0 then
		for i = 1, numBonuses do
			local numRequired, bonusDescription = GetItemSetBonusInfo(set.id, i)
			if bonusDescription and bonusDescription ~= "" then
				InformationTooltip:AddLine(bonusDescription, "ZoFontGame", 1, 1, 1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
			end
		end
	end
	
	-- Show locations. Use ipairs so #locations gaps are never an issue.
	if set.locations and #set.locations > 0 then
		InformationTooltip:AddVerticalPadding(5)
		InformationTooltip:AddLine(GetString(SI_MAP_INFO_MODE_LOCATIONS), "ZoFontHeader2", 1, 1, 1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
		ZO_Tooltip_AddDivider(InformationTooltip)
		for i = 1, #set.locations do
			local zone = set.locations[i].zone
			InformationTooltip:AddLine(zone:GetFormattedText(), "ZoFontGame", 1, 1, 1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
		end
	end
end

function TB_Sets:Header_OnMouseExit(header)
	ClearTooltip(InformationTooltip)
end