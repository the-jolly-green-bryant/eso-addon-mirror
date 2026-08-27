ShoppingListCraftingIntegration = {}

local Crafting = ShoppingListCraftingIntegration
Crafting.__index = Crafting

function Crafting:New(owner)
    return setmetatable({ owner = owner }, self)
end

function Crafting:IsSupportedMasterWrit(itemLink)
    return type(itemLink) == "string"
        and itemLink ~= ""
        and ITEMTYPE_MASTER_WRIT ~= nil
        and GetItemLinkItemType(itemLink) == ITEMTYPE_MASTER_WRIT
        and WritWorthy ~= nil
        and type(WritWorthy.ToMatKnowList) == "function"
end

function Crafting:GetActionName(itemLink)
    if not self:IsSupportedMasterWrit(itemLink) then
        return nil
    end
    local list = self.owner.data:GetCurrentList()
    if not list then
        return nil
    end
    return zo_strformat(
        GetString(SI_SHOPPING_LIST_CONTEXT_ADD_WRIT_MATERIALS),
        list.name
    )
end

function Crafting:ShowStatus(message, isError)
    if self.owner.ui then
        self.owner.ui:SetStatus(message, isError)
    end
    if self.owner.gamepad then
        self.owner.gamepad:SetStatus(message, isError)
    end
    if d then
        d(message)
    end
end

function Crafting:AddMasterWritMaterials(itemLink)
    if not self:IsSupportedMasterWrit(itemLink) then
        self:ShowStatus(
            GetString(SI_SHOPPING_LIST_ERROR_CRAFTING_UNAVAILABLE),
            true
        )
        return false
    end

    local ok, materialRows = pcall(WritWorthy.ToMatKnowList, itemLink)
    if not ok or type(materialRows) ~= "table" or #materialRows == 0 then
        self:ShowStatus(
            GetString(SI_SHOPPING_LIST_ERROR_CRAFTING_UNAVAILABLE),
            true
        )
        return false
    end

    local materials = {}
    for _, row in ipairs(materialRows) do
        materials[#materials + 1] = {
            itemLink = row.link,
            quantity = row.ct,
        }
    end

    local success, resultOrError = self.owner.API:AddCraftingMaterials(
        materials,
        { silent = true }
    )
    if not success then
        self:ShowStatus(zo_strformat(
            GetString(SI_SHOPPING_LIST_ERROR_CRAFTING_ADD_FAILED),
            resultOrError
        ), true)
        return false
    end

    local message = zo_strformat(
        GetString(SI_SHOPPING_LIST_STATUS_CRAFTING_MATERIALS_ADDED),
        resultOrError.materialCount,
        resultOrError.listName
    )
    self:ShowStatus(message)
    return true, resultOrError
end
