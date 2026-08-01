local SousChef = SousChef
local u = SousChef.Utility
local m = SousChef.Media
local LibSort = SousChef.libSort
local str = SousChef.Strings[SousChef.lang]

function SousChef.AddRankToSlot(row, funcs)
    local idFunc = funcs[1]	
    local slot = row.dataEntry and row.dataEntry.data or nil
	if slot == nil then return end
    local bagId = slot[funcs[2]]
    local slotIndex = funcs[3] and slot[funcs[3]] or nil

	local rankIcon = SousChef.getIcon(row)
	
	--Allow for ingeniousclown's Inventory Grid View
	if row:GetWidth() - row:GetHeight() < 5 then	-- if we're mostly square	
		rankIcon:SetDimensions(20,20)
		rankIcon:ClearAnchors()
		rankIcon:SetAnchor(TOPLEFT, row, TOPLEFT, 2)
	else				
		rankIcon:SetDimensions(30, 30)
		rankIcon:ClearAnchors()
		rankIcon:SetAnchor(RIGHT, row, RIGHT, -100)
	end
	
	rankIcon:SetHidden(true)
	rankIcon:SetHandler("OnMouseEnter", nil)
	rankIcon:SetHandler("OnMouseExit", nil)
		
	--Are we gold or soulgem slot? Stay hidden and go away
	if not bagId or not slot.name or slot.name == "" then return end

	local itemLink = idFunc(bagId, slotIndex)
	local itemType = GetItemLinkItemType(itemLink)
	--let's try for a performance gain here: if it's not our type of item, go away now
	if (itemType ~= ITEMTYPE_FLAVORING) and (itemType ~= ITEMTYPE_INGREDIENT) and (itemType ~= ITEMTYPE_RECIPE) and (itemType ~= ITEMTYPE_SPICE) then
		return
	end

	--are we an ingredient?
	local id = u.GetItemID(itemLink)
	--local texture = SousChef.Pantry[id]
	local texture = SousChef.Pantry[itemLink]
	if SousChef.settings.showAltIngredientKnowledge then texture = SousChef.settings.Pantry[itemLink] end
	if texture then
		rankIcon:SetHidden(false)
		rankIcon:SetTexture(m.COOKING[texture])
		-- add tooltips
		rankIcon:SetHandler("OnMouseEnter", function(self)
			ZO_Tooltips_ShowTextTooltip(self, TOP, str.TOOLTIP_INGREDIENT_TYPES[texture])
		end)
		rankIcon:SetHandler("OnMouseExit", function(self)
			ZO_Tooltips_HideTextTooltip()
		end)

		if SousChef:IsOnShoppingList(id) then
			rankIcon:SetColor(SousChef.settings.shoppingColour[1], SousChef.settings.shoppingColour[2], SousChef.settings.shoppingColour[3])
		else
			if SousChef.settings.onlyShowShopping then return rankIcon:SetHidden(true) end
			rankIcon:SetColor(SousChef.settings.colour[1], SousChef.settings.colour[2], SousChef.settings.colour[3])
		end
		return
	end
   
	--are we a recipe?
    if SousChef.settings.processRecipes then
		if u.MatchInIgnoreList(slot.name) then return end
		if GetItemLinkItemType(itemLink) == ITEMTYPE_RECIPE then
			local match = SousChef.Cookbook[u.CleanString(GetItemLinkName(GetItemLinkRecipeResultItemLink(itemLink)))]
			local gmatch = SousChef.settings.Cookbook[u.CleanString(GetItemLinkName(GetItemLinkRecipeResultItemLink(itemLink)))]
			if (match and SousChef.settings.checkKnown == "known") or (not match and SousChef.settings.checkKnown == "unknown")then
	            rankIcon:SetTexture(m.CANLEARN)
	            rankIcon:SetHidden(false)
	            if not match and gmatch and SousChef.settings.checkKnown == "unknown" and SousChef.settings.markAlt then
	                rankIcon:SetColor(1,1,1,0.2)
	            else
	                rankIcon:SetColor(1,1,1,1)
	            end
	        end
	    end
    end	
end

function SousChef.UnregisterSort()
	LibSort:Unregister("Sous Chef")
end

function SousChef.SetupSort()
	LibSort:Register("Sous Chef", "Ingredient Rank", "The Provisioning Rank", "provisioningRank", SousChef.FindIngredientRank)
	LibSort:RegisterDefaultOrder("Sous Chef", {"Ingredient Rank"})
end

function SousChef.FindIngredientRank(bagId, slotIndex)
	local link = GetItemLink(bagId, slotIndex)
	local id = u.GetItemID(link)
	local texture = SousChef.Pantry[link]
	if SousChef.settings.showAltIngredientKnowledge then texture = SousChef.settings.Pantry[link] end
	return texture or 100 
end
