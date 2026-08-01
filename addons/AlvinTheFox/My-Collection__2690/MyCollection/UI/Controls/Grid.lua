local Saved = MyCollection.Internals.Saved
local Data = MyCollection.Internals.Data
local Constants = MyCollection.Internals.Constants
local Extensions = MyCollection.Internals.Functions.Extensions
local Dependencies =  MyCollection.Internals.Dependencies
local Logger = MyCollection.Internals.Dependencies.Logger
local EventManager = MyCollection.Internals.Dependencies.Officials.EventManager
local UI = MyCollection.UI
local Controls = MyCollection.UI.Controls

Controls.Grid = ZO_SortFilterList:Subclass()
--Controls.Grid.__index = Controls.Grid

local Grid = Controls.Grid
local MYCOLLECTION_DATA = 1
local MYCOLLECTION_SORTTYPE = 1
local MYCOLLECTION_MAX_ORDER = 10001

-- Constructor
function Grid:New(element)
    local instance = ZO_SortFilterList.New(self, element)

    instance:Setup(element)
    return instance
end

-- UI containers
Grid.Element = nil

-- Sub Elements
Grid.SearchBox = nil

-- Properties

-- Functions
function Grid:Setup(element)

    self.Element = element

    ZO_ScrollList_AddDataType(self.list, MYCOLLECTION_DATA, "MyCollectionUIGridRow", 95, function(control, data) self:SetupItemRow(control, data) end, nil, nil,
        function (control) 
            for i=1, control:GetNamedChild("Items"):GetNumChildren(), 1 do
                local item = control:GetNamedChild("Items"):GetChild(i)
                item.reference = nil
                item.itemLink = nil
                item.itemType = nil
                item:SetPressedTexture()
                item:SetMouseOverTexture()
            end
            ZO_ObjectPool_DefaultResetControl(control)
        end)
    ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
    self:SetAlternateRowBackgrounds(true)

    self.masterList = {}

    local sortKeys = {
        ["key"]                 = { isNumeric = true },
        ["order"]               = { isNumeric = true, tiebreaker = "key", tieBreakerSortOrder = ZO_SORT_ORDER_UP },
        ["set"]                 = { caseInsensitive = true, tiebreaker = "order", tieBreakerSortOrder = ZO_SORT_ORDER_DOWN },
        ["completition"]        = { isNumeric = true, tiebreaker = "order", tieBreakerSortOrder = ZO_SORT_ORDER_DOWN },
    }

    self.currentSortKey = "order"
    self.currentSortOrder = ZO_SORT_ORDER_UP
    self.sortHeaderGroup:SelectAndResetSortForKey(self.currentSortKey)
    self.sortFunction = function( listEntry1, listEntry2 )
        return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, sortKeys, self.currentSortOrder)
    end    

    -- setup searcj
    self.SearchBox = self.Element:GetNamedChild("SearchBox")
    self.SearchBox:SetHandler("OnTextChanged", function() self:RefreshFilters() end)
    self.search = ZO_StringSearch:New()
    self.search:AddProcessor(MYCOLLECTION_SORTTYPE, function(stringSearch, data, searchTerm, cache) return(self:ProcessItemEntry(stringSearch, data, searchTerm, cache)) end)
end

function Grid:SetupItemRow( control, data )
	control.data = data

    -- For default ordering
    local key = control:GetNamedChild("Key")
    
    local order = control:GetNamedChild("Order")
    order.normalColor = ZO_DEFAULT_TEXT
    if data.order < MYCOLLECTION_MAX_ORDER then
        order:SetText(data.order)
    else
        order:SetText(nil)
    end

    local set = control:GetNamedChild("Set")
    set.normalColor = ZO_DEFAULT_TEXT
	set:SetText(data.set)

    local items = control:GetNamedChild("Items")
    
    -- Set Item icons
    for key, typeId in pairs(Constants.EquipTypes.Armors) do        
        local piece = items:GetNamedChild(key)
        local setPiece = data.reference:GetArmorPiece(typeId)
        piece.reference = setPiece
        if setPiece:HasItem() then
            local link = setPiece:GetReferences()[next(setPiece:GetReferences())]:GetLink()
            piece:SetNormalTexture(Dependencies.Officials.GetItemLinkIcon(link))
            piece.itemLink = link
        else
            piece:SetNormalTexture("MyCollection/UI/Textures/Apparel/".. key .."_up.dds")
            piece:SetPressedTexture("MyCollection/UI/Textures/Apparel/".. key .."_down.dds")
            piece:SetMouseOverTexture("MyCollection/UI/Textures/Apparel/".. key .."_over.dds")
            piece.itemType = key
        end
        piece.traitId = setPiece.traitType
        piece.traitType = "ARMOR"
        piece.traitOptions = Constants.TraitTypes.Armor
        piece:SetHandler("OnMouseEnter", Grid.OnMouseEnterItem)
        piece:SetHandler("OnMouseExit", Grid.OnMouseExitItem)
        piece:SetHandler("OnMouseUp", Grid.OnMouseUpItem)
    end
    for key, typeId in pairs(Constants.EquipTypes.Jewelleries) do
        local piece = items:GetNamedChild(key)
        local setPiece = data.reference:GetJewelleryPiece(typeId)
        piece.reference = setPiece
        if setPiece:HasItem() then
            local link = setPiece:GetReferences()[next(setPiece:GetReferences())]:GetLink()
            piece:SetNormalTexture(Dependencies.Officials.GetItemLinkIcon(link))
            piece.itemLink = link
        else
            piece:SetNormalTexture("MyCollection/UI/Textures/Apparel/".. key .."_up.dds")
            piece:SetPressedTexture("MyCollection/UI/Textures/Apparel/".. key .."_down.dds")
            piece:SetMouseOverTexture("MyCollection/UI/Textures/Apparel/".. key .."_over.dds")
            piece.itemType = key
        end
        piece.traitId = setPiece.traitType
        piece.traitType = "JEWELLERY"
        piece.traitOptions = Constants.TraitTypes.Jewelleries
        piece:SetHandler("OnMouseEnter", Grid.OnMouseEnterItem)
        piece:SetHandler("OnMouseExit", Grid.OnMouseExitItem)
        piece:SetHandler("OnMouseUp", Grid.OnMouseUpItem)
    end
    for key, typeId in pairs(Constants.WeaponTypes) do
        local piece = items:GetNamedChild(key)
        local setPiece = data.reference:GetWeaponPiece(typeId)
        piece.reference = setPiece
        if setPiece:HasItem() then
            local link = setPiece:GetReferences()[next(setPiece:GetReferences())]:GetLink()
            piece:SetNormalTexture(Dependencies.Officials.GetItemLinkIcon(link))
            piece.itemLink = link
        else
            piece:SetNormalTexture("MyCollection/UI/Textures/Weapons/".. key .."_up.dds")
            piece:SetPressedTexture("MyCollection/UI/Textures/Weapons/".. key .."_down.dds")
            piece:SetMouseOverTexture("MyCollection/UI/Textures/Weapons/".. key .."_over.dds")
            piece.itemType = key
        end
        piece.traitId = setPiece.traitType
        piece.traitType = "WEAPON"
        piece.traitOptions = Constants.TraitTypes.Weapons
        piece:SetHandler("OnMouseEnter", Grid.OnMouseEnterItem)
        piece:SetHandler("OnMouseExit", Grid.OnMouseExitItem)
        piece:SetHandler("OnMouseUp", Grid.OnMouseUpItem)
    end


	ZO_SortFilterList.SetupRow(self, control, data)
end

function Grid:ProcessItemEntry( stringSearch, data, searchTerm, cache )
	if 
        zo_plainstrfind(data.set:lower(), searchTerm)
    then
		return true
	end

	return false
end

function Grid:BuildMasterList()
    self.masterList = {}
    local sets = Data.Collection:GetSets()
    for key, set in pairs(sets) do
        local new = {
            type = MYCOLLECTION_SORTTYPE,
            key = key,
            order = sets[key]:GetOrderNumber(),
            set = sets[key]:GetSetName(),
            completition = sets[key]:Completition(),
            reference = sets[key],
            referenceId = key,
        }
        if new.order == nil then
            new.order = MYCOLLECTION_MAX_ORDER
        end
        table.insert(self.masterList, new)
    end

end

function Grid:FilterScrollList()
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    ZO_ClearNumericallyIndexedTable(scrollData)
    
	local searchInput = self.SearchBox:GetText()

    for i, data in ipairs(self.masterList) do
        if 
            searchInput == "" or
            self.search:IsMatch(searchInput, data)    
        then
            table.insert(scrollData, ZO_ScrollList_CreateDataEntry(MYCOLLECTION_DATA, data))
        end
    end
end

function Grid:SortScrollList()
    if (self.currentSortKey ~= nil and self.currentSortOrder ~= nil) then
        local scrollData = ZO_ScrollList_GetDataList(self.list)
        table.sort(scrollData, self.sortFunction)        
	end

	self:RefreshVisible()
end

function Grid:ShowContextMenu( control )
	ClearMenu()
    AddMenuItem(GetString(MYCOLLECTION_CONTEXT_REMOVE), function () 
        Data.Collection:RemoveSet(control.data.referenceId) 
        self:RefreshData() 
    end)
    AddMenuItem(GetString(MYCOLLECTION_CONTEXT_CHANGEORDER), function () 
        ZO_Dialogs_ShowDialog("MyCollection_SetOrderNumber", 
            {
                currentSet = control.data.reference,
            }, 
            {
                initialEditText = control.data.order
            }
        ) 
    end)
	self:ShowMenu(control)
end

function Grid:ShowTraitMenu( control )
    ClearMenu()

    AddMenuItem("None", function () 
        control.reference:SetTrait(0)
        control.traitId = 0
        control.traitName = GetString(traitTextId)
        self:RefreshData()
    end)

    for key, trait in pairs(control.traitOptions) do
        local traitTextId = _G["MYCOLLECTION_TRAIT_".. control.traitType .. "_" .. key:upper()]
        AddMenuItem(GetString(traitTextId), function () 
            control.reference:SetTrait(trait)
            control.traitId = trait
            control.traitName = GetString(traitTextId)
            self:RefreshData()
        end)
    end

	self:ShowMenu(control)
end

-- Event static functions
function Grid.OnMouseEnterItem(control)
    if control.itemLink ~= nil then
        InitializeTooltip(ItemTooltip, control, TOPRIGHT, -100, 0, TOPLEFT)
        ItemTooltip:SetLink(control.itemLink)
        ZO_Tooltip_AddDivider(ItemTooltip)        
        ItemTooltip:AddLine("Current trait filter: ".. Extensions.Constants.GetTraitName(control.traitId))
    else   
        ZO_Tooltips_ShowTextTooltip(control, TOP, control.itemType .. " (" .. Extensions.Constants.GetTraitName(control.traitId) .. ")")
    end
end

function Grid.OnMouseExitItem(control)    
    ClearTooltip(ItemTooltip)
    ZO_Tooltips_HideTextTooltip()
end

function Grid.OnMouseUpItem(control, button, upInside)    
    if (upInside) then
        if (button == MOUSE_BUTTON_INDEX_RIGHT) then
            UI.Frame.Grid:ShowTraitMenu(control)
		end
	end
end

function Grid.OnMouseUp(control, button, upInside)
    if (upInside) then
        if (button == MOUSE_BUTTON_INDEX_RIGHT) then
            UI.Frame.Grid:ShowContextMenu(control)
		end
	end
end

function Grid.OnMouseEnter(control)  
	UI.Frame.Grid:Row_OnMouseEnter(control)
end

function Grid.OnMouseExit(control)    
	UI.Frame.Grid:Row_OnMouseExit(control)
    
end


-- https://esoapi.uesp.net/100020/src/libraries/zo_tooltip/zo_tooltip.lua.html#624
-- https://esoapi.uesp.net/100020/src/libraries/zo_templates/tooltip.lua.html#64
-- https://esoapi.uesp.net/current/src/libraries/zo_contextmenus/zo_contextmenus.lua.html#266
-- https://esoapi.uesp.net/current/src/libraries/zo_sortfilterlist/zo_sortfilterlist.lua.html
-- https://esoapi.uesp.net/current/src/libraries/zo_menubar/zo_menubar.lua.html#656
-- https://esoapi.uesp.net/100031/src/libraries/zo_templates/scrolltemplates.lua.html
-- https://esoapi.uesp.net/current/src/libraries/zo_dialog/zo_dialog.lua.html#394