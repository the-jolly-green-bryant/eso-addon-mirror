-- Code derived from GodSendPlus, originally by Focus (MIT License).

local ADDON_NAME = "FurnitureShoppingList"
local ADDON_VERSION = "1.2.1"

local SL_WINDOW = nil
SL_RECIPIENTS = nil

local RECIPIENTS_SORT_KEYS =
{
	["name"] = { },
	["need"] = { tiebreaker = "name", isNumeric = true },
    ["price"] = { tiebreaker = "name", isNumeric = true },
}

local FurnitureShoppingListWindow = ZO_Object:Subclass()
local FurnitureShoppingListRecipients = ZO_SortFilterList:Subclass()
FurnitureShoppingListData = {}
FurnitureShoppingListDataLookup = {}

local function getMM (itemLink)
    if not MasterMerchant then return 0 end

    local theIID = string.match(itemLink, '|H.-:item:(.-):')
    local itemIndex = MasterMerchant.makeIndexFromLink(itemLink)
    local tipStats = MasterMerchant:toolTipStats(tonumber(theIID), itemIndex, true, true)
    if tipStats.avgPrice then return tipStats.avgPrice else return 0 end
end

function FurnitureShoppingListWindow:New(control)
	local manager = ZO_Object.New(self)
	
	manager.control = control

    return manager
end

function FurnitureShoppingListRecipients:New(control)
	local manager = ZO_SortFilterList.New(self, control)
	
	ZO_ScrollList_AddDataType(manager.list, 1, "FurnitureShoppingListRecipientsRow", 30, function(control, data) manager:SetupRow(control, data) end)
	ZO_ScrollList_EnableHighlight(manager.list, "ZO_ThinListHighlight")
	
	manager:SetAlternateRowBackgrounds(true)
	
	manager.control = control

    manager.mm = GetControl(control, "MM")

    control.container = manager
	manager.masterList = {}
	manager.sortHeaderGroup:SelectHeaderByKey("id")
	
	return manager
end

function FurnitureShoppingListRecipients:SetupRow(control, data)
	ZO_SortFilterList.SetupRow(self, control, data)
	
	control:SetHandler("OnMouseUp", function(control, button, upInside, linkText) self:OnRowMouseUp(control, button, upInside, linkText) end)
	
	GetControl(control, "Name"):SetText(data.name)
	GetControl(control, "Need"):SetText(data.need)
    GetControl(control, "Price"):SetText(data.price)
	
end

function FurnitureShoppingListRecipients:BuildMasterList()
	ZO_ClearNumericallyIndexedTable(self.masterList)

    local mm_total = 0

    for mat, need in pairs(FurnitureShoppingListData) do
        local name = FurnitureShoppingListDataLookup[mat]

        if need > 0 then
            local cost = getMM(name) or 0
            local this_row = zo_floor(cost*need)
            mm_total = mm_total + this_row
            table.insert(self.masterList, {name=name, need=need, price=this_row})
        end
	end
	 
		self.mm:SetText((nil ~= MasterMerchant and "MM: " .. mm_total .. "g") or "")
end

function FurnitureShoppingListRecipients:FilterScrollList()
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    ZO_ClearNumericallyIndexedTable(scrollData)

    for i = 1, #self.masterList do
		local data = self.masterList[i]
		if data.mail ~= false then
		table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
		else end
    end
end

function FurnitureShoppingListRecipients:SortScrollList()
end

function FurnitureShoppingListRecipients:ColorRow(control, data, mouseIsOver)

end

function FurnitureShoppingListRecipients:OnRowMouseUp(control, button, upInside, linkText)
	if (button == 2 and linkText) then
		if (not self.unlockSelectionCallback) then self.unlockSelectionCallback = function() self:UnlockSelection() end	end
		SetMenuHiddenCallback(self.unlockSelectionCallback)
		self:LockSelection()
	end
end

function FurnitureShoppingListWindow_Toggle()
    SL_WINDOW.control:SetHidden(not SL_WINDOW.control:IsHidden())
end

function FurnitureShoppingListRecipientsRow_OnMouseEnter(control)	
	SL_RECIPIENTS:EnterRow(control)
end

function FurnitureShoppingListRecipientsRow_OnMouseExit(control)
	SL_RECIPIENTS:ExitRow(control)
end

function FurnitureShoppingListLabelField_OnMouseEnter(control)
	if (control:WasTruncated()) then
		InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0)
		SetTooltipText(InformationTooltip, control:GetText())
	end
	
	local row = control:GetParent()
	zo_callHandler(row, "OnMouseEnter")
end

function FurnitureShoppingListLabelField_OnMouseExit(control)
	ClearTooltip(InformationTooltip)
	
	local row = control:GetParent()
	zo_callHandler(row, "OnMouseExit")
end

function FurnitureShoppingListWindowCloseButton_OnClicked (control)
    SL_WINDOW.control:SetHidden(true)
end

function FurnitureShoppingListLabelField_OnLinkMouseUp(control, button, linkText)
	ZO_LinkHandler_OnLinkMouseUp(linkText, button, control)
	
	local row = control:GetParent()
	zo_callHandler(row, "OnMouseUp", button, true, linkText)
end

function FurnitureShoppingListWindow_OnInitialized(self)
	SL_WINDOW = FurnitureShoppingListWindow:New(self)
end

function FurnitureShoppingListRecipients_OnInitialized(self)
    SL_RECIPIENTS = FurnitureShoppingListRecipients:New(self)
end

function FurnitureShoppingList_ClearButton_OnClicked (control)
    FurnitureShoppingListData = {}
    FurnitureShoppingListDataLookup = {}

    SL_RECIPIENTS:RefreshData()
end

function FurnitureShoppingList_RemoveOwn_OnClicked (control)
    for mat, need in pairs(FurnitureShoppingListData) do
        local link = FurnitureShoppingListDataLookup[mat]

        local a, b, c = GetItemLinkStacks(link)

        local total = a + b + c

        if need - total < 0 then need = 0 else need = need - total end

        FurnitureShoppingListData[mat] = need
	end

    SL_RECIPIENTS:RefreshData()
end

function FurnitureShoppingListAdd(itemLink, recipeArray)
    if not FurC then
        CHAT_SYSTEM:AddMessage(GetString(FSL_REQUIRES_FC))
        return
    end
	
	recipeArray = recipeArray or FurC.Find(itemLink)
	local ingredients = FurC.GetIngredients(itemLink, recipeArray)
	
    if not recipeArray or not ingredients or {} == ingredients then
        CHAT_SYSTEM:AddMessage(GetString(FSL_NOT_VALID_ITEM))
        return
    end

    for mat, cost in pairs(ingredients) do
        local n = zo_strformat("<<t:1>>", GetItemLinkName(mat))

        FurnitureShoppingListDataLookup[n] = mat

        if FurnitureShoppingListData[n] ~= nil then
            FurnitureShoppingListData[n] = FurnitureShoppingListData[n] + cost
        else
            FurnitureShoppingListData[n] = cost
        end
    end

    SL_RECIPIENTS:RefreshData()
end

function FurnitureShoppingListDel(itemLink)
    if not FurC then
        CHAT_SYSTEM:AddMessage(GetString(FSL_REQUIRES_FC))
        return
    end

    local recipeArray = FurC.Find(itemLink)
	local ingredients = FurC.GetIngredients(itemLink, recipeArray)
	
    if not recipeArray or not ingredients or {} == ingredients then
        CHAT_SYSTEM:AddMessage(GetString(FSL_NOT_VALID_ITEM))
        return
    end

    for mat, cost in pairs(ingredients) do
        local n = GetItemLinkName(mat)

        FurnitureShoppingListDataLookup[n] = mat

        local q = FurnitureShoppingListData[n]

        if q ~= nil then
            local q = q - cost

            if q < 0 then q = 0 end

            FurnitureShoppingListData[n] = q
        end
    end

    SL_RECIPIENTS:RefreshData()
end

function FurnitureShoppingList_Print_OnClicked(control)
    local s = ""

    for mat, need in pairs(FurnitureShoppingListData) do
        if need > 0 then
            s = s .. ", " .. mat .. ": " .. need
        end
    end

    s, _ = s:gsub("^, ", "")

    if #s > MAX_TEXT_CHAT_INPUT_CHARACTERS then
        if SCENE_MANAGER:IsShowing("mailSend") then
            -- then check the 
            if MAIL_SEND.body:GetText() ~= "" then
                CHAT_SYSTEM:AddMessage(GetString(FSL_OUTPUT_TOO_LONG))
            else
                MAIL_SEND.body:SetText(s:gsub(", ", "\n"))
            end
        else
            CHAT_SYSTEM:AddMessage(GetString(FSL_OUTPUT_TOO_LONG))
        end
    elseif #s == 0 then
        -- do nothing
    else
        StartChatInput(s)
    end
end

function FurnitureShoppingListAdd_Crafting ()
    local li, ri = PROVISIONER:GetSelectedRecipeListIndex(), PROVISIONER:GetSelectedRecipeIndex()
    local nk = ZO_LinkHandler_CreateChatLink(GetRecipeResultItemLink, li, ri)
    FurnitureShoppingListAdd(nk)
end

function FurnitureShoppingListDel_Crafting ()
    local li, ri = PROVISIONER:GetSelectedRecipeListIndex(), PROVISIONER:GetSelectedRecipeIndex()
    local nk = ZO_LinkHandler_CreateChatLink(GetRecipeResultItemLink, li, ri)
    FurnitureShoppingListDel(nk)
end

function FurnitureShoppingListWindow:InventorySlot_ShowContextMenu (rowControl)
    local bag, slot = ZO_Inventory_GetBagAndIndex(rowControl)
    local slotType = ZO_InventorySlot_GetType(rowControl)

    local link = GetItemLink(bag, slot)

    if link and IsItemLinkPlaceableFurniture(link) then
        zo_callLater(function ()
            AddCustomMenuItem(GetString(FSL_ADD_1_TO_LIST), function() FurnitureShoppingListAdd(link) end)
            AddCustomMenuItem(GetString(FSL_DEL_1_TO_LIST), function () FurnitureShoppingListDel(link) end)
            ShowMenu(self)
        end, 50)
    end
end

local function OnAddonLoaded(eventCode, addonName)
	if addonName ~= (ADDON_NAME) then return end
	
	SLASH_COMMANDS["/sl"] = FurnitureShoppingListWindow_Toggle
	
	EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    -- stolen magic!!!
	local original_OnLinkMouseUp = ZO_LinkHandler_OnLinkMouseUp
	ZO_LinkHandler_OnLinkMouseUp = function(itemLink, button, control)
		if (type(itemLink) == 'string' and #itemLink > 0) then
			local handled = LINK_HANDLER:FireCallbacks(LINK_HANDLER.LINK_MOUSE_UP_EVENT, itemLink, button, ZO_LinkHandler_ParseLink(itemLink))
			if (not handled) then
				original_OnLinkMouseUp(itemLink, button, control)
				if (button == 2 and itemLink ~= '') then
                    if IsItemLinkPlaceableFurniture(itemLink) then
						AddCustomMenuItem(GetString(FSL_ADD_1_TO_LIST), function() FurnitureShoppingListAdd(itemLink) end)
                        AddCustomMenuItem(GetString(FSL_DEL_1_TO_LIST), function () FurnitureShoppingListDel(itemLink) end)
						ShowMenu(control)
					end
				end
			end
		end
	end
   
    ZO_PreHook("ZO_InventorySlot_ShowContextMenu", function (rowControl) SL_WINDOW:InventorySlot_ShowContextMenu(rowControl) end)

    local strip = {
        alignment = KEYBIND_STRIP_ALIGN_CENTER,

        -- Add 1 to list
        {
            name = GetString(FSL_KB_ADD),
            
            callback = function() FurnitureShoppingListAdd_Crafting() end,

            keybind = "SL_ADD",

            visible = function()
                return PROVISIONER:CanPreviewRecipe(PROVISIONER.recipeTree:GetSelectedData())
            end,
        },

        -- Del 1 from list
        {
            name = GetString(FSL_KB_DEL),

            keybind = "SL_DEL",

            callback = function() FurnitureShoppingListDel_Crafting() end,

            visible = function()
                return PROVISIONER:CanPreviewRecipe(PROVISIONER.recipeTree:GetSelectedData())
            end,
        },
    }
      
    PROVISIONER_FRAGMENT:RegisterCallback("StateChange", function (oldState, newState)
        if newState == SCENE_SHOWN then
            KEYBIND_STRIP:AddKeybindButtonGroup(strip)
        elseif newState == SCENE_HIDING then
            KEYBIND_STRIP:RemoveKeybindButtonGroup(strip)
        end
    end)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
