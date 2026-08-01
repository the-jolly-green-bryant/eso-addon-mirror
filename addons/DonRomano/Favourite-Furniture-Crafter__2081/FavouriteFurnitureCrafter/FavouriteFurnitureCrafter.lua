
FavouriteFurnitureCrafter = {}

FavouriteFurnitureCrafter.name = "FavouriteFurnitureCrafter"
FavouriteFurnitureCrafter.FavouriteCheckBox = nil

local ffc_controlPool = {}
local ffc_curControlPoolIndex = 1
-- local FFC_TEXTURE_BUTTON_UP = "esoui/art/icons/guildranks/guild_indexicon_recruit_up.dds"
local FFC_TEXTURE_BUTTON_DOWN = "esoui/art/icons/guildranks/guild_indexicon_recruit_down.dds"
local FFC_TEXTURE_BUTTON_OVER = "esoui/art/icons/guildranks/guild_indexicon_recruit_over.dds"


local FFC_AllFavourites = {}

local FFC_MarkString = nil
local FFC_UnmarkString = nil

local function FFC_ShowTooltip(self)
	--InitializeTooltip(tooltipControl, [owner, point, offsetX, offsetY, relativePoint])
	InitializeTooltip(InformationTooltip, self, TOPRIGHT, 0, 5, BOTTOMRIGHT)
	--SetTooltipText(tooltipControl, text, [r, g, b])
	if self.state == TOGGLE_BUTTON_OPEN then
		SetTooltipText(InformationTooltip, FFC_MarkString)
	else
		SetTooltipText(InformationTooltip, FFC_UnmarkString)
	end

end
 
local function FFC_HideTooltip(self)
   --ClearTooltip(tooltipControl)
   ClearTooltip(InformationTooltip)
end
 

local function FFC_AcquireControl(parent)
	local ctrl = ffc_controlPool[ffc_curControlPoolIndex]
	if ctrl == nil then
		ctrl = WINDOW_MANAGER:CreateControl("ffc_FavCheck_" .. ffc_curControlPoolIndex, parent, CT_BUTTON)
		ffc_controlPool[ffc_curControlPoolIndex] = ctrl
		ctrl:SetHandler("OnMouseEnter", function(self) FFC_ShowTooltip(self) end)
		ctrl:SetHandler("OnMouseExit", function(self) FFC_HideTooltip(self) end)		
	end
	ffc_curControlPoolIndex = ffc_curControlPoolIndex + 1
	ctrl:SetHidden(true)
	return ctrl
end

local function FFC_ReleasePool()
	for _,v in ipairs(ffc_controlPool) do 
		v:SetHidden(true)
		v:SetMouseEnabled(false)
	end
	ffc_curControlPoolIndex = 1
end

local function FFC_SetButtonOpen(button)
	button.state = TOGGLE_BUTTON_OPEN
	button:SetNormalTexture()
	button:SetPressedTexture(FFC_TEXTURE_BUTTON_DOWN)
	button:SetMouseOverTexture(FFC_TEXTURE_BUTTON_OVER)
end
local function FFC_SetButtonClosed(button)
	button.state = TOGGLE_BUTTON_CLOSED
	button:SetNormalTexture(FFC_TEXTURE_BUTTON_DOWN)
	button:SetMouseOverTexture(FFC_TEXTURE_BUTTON_OVER)
	button:SetPressedTexture()
end

function FavouriteFurnitureCrafter.OnButtonClicked(button)
	if button.state == TOGGLE_BUTTON_OPEN then
		FFC_AllFavourites[button:GetParent().data.name]=true
		FFC_SetButtonClosed(button)
	else
		FFC_AllFavourites[button:GetParent().data.name]=nil
		FFC_SetButtonOpen(button)
	end
end

function FavouriteFurnitureCrafter.SetFavoriteCheckBoxState()
	if FFC_AllFavourites["ffc_FavouritesFilterOn_"..GetCraftingInteractionType().."_"..PROVISIONER.tabs:GetNamedChild("Label"):GetText()] then
		ZO_CheckButton_SetChecked(FavouriteFurnitureCrafter.FavouriteCheckBox)
	else
		ZO_CheckButton_SetUnchecked(FavouriteFurnitureCrafter.FavouriteCheckBox)
	end
end

function FavouriteFurnitureCrafter.AddHeaderCheckBox()
	FavouriteFurnitureCrafter.FavouriteCheckBox = CreateControlFromVirtual("$(parent)FavouriteCheck", PROVISIONER.haveIngredientsCheckBox:GetParent(), "ZO_CheckButton")
	local _, _, anchorObject = PROVISIONER.haveIngredientsCheckBox:GetAnchor()
	FavouriteFurnitureCrafter.FavouriteCheckBox:SetAnchor(TOPLEFT,anchorObject,TOPLEFT,50,16)
	FavouriteFurnitureCrafter.FavouriteCheckBox:SetDimensions(PROVISIONER.haveIngredientsCheckBox:GetDimensions())
	FavouriteFurnitureCrafter.FavouriteCheckBox:SetHidden(false)
	FavouriteFurnitureCrafter.SetFavoriteCheckBoxState()
	ZO_CheckButton_SetToggleFunction(FavouriteFurnitureCrafter.FavouriteCheckBox, function ()
				FFC_AllFavourites["ffc_FavouritesFilterOn_"..GetCraftingInteractionType().."_"..PROVISIONER.tabs:GetNamedChild("Label"):GetText()] = ZO_CheckButton_IsChecked(FavouriteFurnitureCrafter.FavouriteCheckBox)
				PROVISIONER:DirtyRecipeList()
				end)
	ZO_CheckButton_SetLabelText(FavouriteFurnitureCrafter.FavouriteCheckBox, GetString(FFC_FAVOURITES))
	if(FavouriteFurnitureCrafter.FavouriteCheckBox.label) then
		local w = FavouriteFurnitureCrafter.FavouriteCheckBox.label:GetTextDimensions()
		local w1 = PROVISIONER.haveIngredientsCheckBox:GetChild():GetTextDimensions()
		local checkWidth = FavouriteFurnitureCrafter.FavouriteCheckBox:GetWidth()
		ZO_CheckButton_SetLabelWidth(FavouriteFurnitureCrafter.FavouriteCheckBox.label, w)
		PROVISIONER.haveIngredientsCheckBox:SetAnchor(LEFT,FavouriteFurnitureCrafter.FavouriteCheckBox,RIGHT,w+checkWidth+25,0)
		PROVISIONER.haveSkillsCheckBox:SetAnchor(LEFT,PROVISIONER.haveIngredientsCheckBox,RIGHT,w1+checkWidth+25,0)
	else
		PROVISIONER.haveIngredientsCheckBox:SetAnchor(LEFT,FavouriteFurnitureCrafter.FavouriteCheckBox,RIGHT,200,0)
	end
end

function FavouriteFurnitureCrafter.RecipeSetupFunction(node, control, data, open, userRequested, enabled)
	FavouriteFurnitureCrafter.oldSetupFunction(node, control, data, open, userRequested, enabled)

	local ffc_button = FFC_AcquireControl(control)
	ffc_button:SetAnchor(TOPLEFT, control, TOPLEFT, -34, -4)
	if FFC_AllFavourites[data.name] then
		FFC_SetButtonClosed(ffc_button)
	else
		FFC_SetButtonOpen(ffc_button)
	end
	ffc_button:SetDimensions(32,32)
	ffc_button:SetHidden (false)
	ffc_button:SetMouseEnabled(true)
	ffc_button:SetHandler("OnClicked",FavouriteFurnitureCrafter.OnButtonClicked )
	
end
function FavouriteFurnitureCrafter.DoesRecipePassFilter (checkFavouriteOn, recipeName)
	if not checkFavouriteOn then
		return true
	else
		return FFC_AllFavourites[recipeName]==true
	end
end

function FavouriteFurnitureCrafter.RefreshRecipeList(provisioner_obj)
	FFC_ReleasePool()
    provisioner_obj.recipeTree:Reset()
	FavouriteFurnitureCrafter.SetFavoriteCheckBoxState()
    local knowAnyRecipesInTab = false
    local hasRecipesWithFilter = false
    local checkNumCreatable = ZO_CheckButton_IsChecked(provisioner_obj.haveIngredientsCheckBox)
    local checkSkills = ZO_CheckButton_IsChecked(provisioner_obj.haveSkillsCheckBox)
	local checkFavourite = ZO_CheckButton_IsChecked(FavouriteFurnitureCrafter.FavouriteCheckBox)
    local craftingInteractionType = GetCraftingInteractionType()
    local recipeData = PROVISIONER_MANAGER:GetRecipeData()
	local favParent
	local favTempRecipeList = {}
    for _, recipeList in pairs(recipeData) do
        local parent
        for _, recipe in ipairs(recipeList.recipes) do
            if provisioner_obj:DoesRecipePassFilter(recipe.specialIngredientType, checkNumCreatable, recipe.numCreatable, checkSkills, recipe.tradeskillsLevelReqs, recipe.qualityReq, craftingInteractionType, recipe.requiredCraftingStationType) 
				and FavouriteFurnitureCrafter.DoesRecipePassFilter(checkFavourite, recipe.name) then
					if not checkFavourite then
						parent = parent or provisioner_obj.recipeTree:AddNode("ZO_IconHeader", {
						recipeListIndex = recipeList.recipeListIndex,
						name = recipeList.recipeListName,
						upIcon = recipeList.upIcon,
						downIcon = recipeList.downIcon,
						overIcon = recipeList.overIcon,
						disabledIcon = recipeList.disabledIcon
						}, nil, SOUNDS.PROVISIONING_BLADE_SELECTED)
						
						provisioner_obj.recipeTree:AddNode("ZO_ProvisionerNavigationEntry", recipe, parent, SOUNDS.PROVISIONING_ENTRY_SELECTED)
					else
						favParent = favParent or provisioner_obj.recipeTree:AddNode("ZO_IconHeader", {
						recipeListIndex = recipeList.recipeListIndex,
						name = GetString(FFC_FAVOURITES),
						upIcon = FFC_TEXTURE_BUTTON_DOWN,
						downIcon = FFC_TEXTURE_BUTTON_DOWN,
						overIcon = FFC_TEXTURE_BUTTON_DOWN,
						disabledIcon = FFC_TEXTURE_BUTTON_DOWN
						}, nil, SOUNDS.PROVISIONING_BLADE_SELECTED)
						table.insert(favTempRecipeList, recipe)
					end
                hasRecipesWithFilter = true
            end
            knowAnyRecipesInTab = true
        end
    end
	
	--Sorting
	if checkFavourite then
		table.sort (favTempRecipeList, function(k1,k2) return k1.name < k2.name end)
		for _,recipe in ipairs(favTempRecipeList) do
			provisioner_obj.recipeTree:AddNode("ZO_ProvisionerNavigationEntry", recipe, favParent, SOUNDS.PROVISIONING_ENTRY_SELECTED)
		end
	end
	
    provisioner_obj.recipeTree:Commit()
    provisioner_obj.noRecipesLabel:SetHidden(hasRecipesWithFilter)
    ZO_CheckButton_SetEnableState(provisioner_obj.haveIngredientsCheckBox, knowAnyRecipesInTab)
    ZO_CheckButton_SetEnableState(provisioner_obj.haveSkillsCheckBox, knowAnyRecipesInTab)
    if not hasRecipesWithFilter then
        if knowAnyRecipesInTab then
            provisioner_obj.noRecipesLabel:SetText(GetString(SI_PROVISIONER_NONE_MATCHING_FILTER))
        else
            --If there are no recipes all the types show the same message.
            provisioner_obj.noRecipesLabel:SetText(GetString(SI_PROVISIONER_NO_RECIPES))
            ZO_CheckButton_SetChecked(provisioner_obj.haveIngredientsCheckBox)
            ZO_CheckButton_SetChecked(provisioner_obj.haveSkillsCheckBox)
        end
        provisioner_obj:RefreshRecipeDetails()
	else
		if checkFavourite then
			provisioner_obj.recipeTree:SelectAnything()
		end
    end
end

function FavouriteFurnitureCrafter:Initialize()
	FFC_AllFavourites = ZO_SavedVars:New("FFC_AllFavourites",1,nil,{})
	FFC_MarkString = GetString(FFC_MARK)
	FFC_UnmarkString = GetString(FFC_UNMARK)	
    EVENT_MANAGER:RegisterForEvent("FavouriteFurnitureCrafter", EVENT_CRAFTING_STATION_INTERACT, function(eventCode, craftingType)
			if FavouriteFurnitureCrafter.oldSetupFunction == nil then
				FavouriteFurnitureCrafter.oldSetupFunction = PROVISIONER.recipeTree.templateInfo.ZO_ProvisionerNavigationEntry.setupFunction
				PROVISIONER.recipeTree.templateInfo.ZO_ProvisionerNavigationEntry.setupFunction = FavouriteFurnitureCrafter.RecipeSetupFunction
			end
			
			if FavouriteFurnitureCrafter.oldRefreshRecipeList == nil then
				FavouriteFurnitureCrafter.oldRefreshRecipeList = PROVISIONER.RefreshRecipeList
				PROVISIONER.RefreshRecipeList = FavouriteFurnitureCrafter.RefreshRecipeList
			end
			if FavouriteFurnitureCrafter.FavouriteCheckBox == nill then
				FavouriteFurnitureCrafter.AddHeaderCheckBox()
			end
	end)
 end
 
function FavouriteFurnitureCrafter.OnAddOnLoaded(event, addonName)
  if addonName ~= FavouriteFurnitureCrafter.name then
	return
  end
    FavouriteFurnitureCrafter:Initialize()
end

 
EVENT_MANAGER:RegisterForEvent(FavouriteFurnitureCrafter.name, EVENT_ADD_ON_LOADED, FavouriteFurnitureCrafter.OnAddOnLoaded)

