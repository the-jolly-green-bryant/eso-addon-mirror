local DEBUG =
function() end
-- d
 
local function _tr(str)
    return str
end

if not InventoryManager then InventoryManager = {} end
local IM = InventoryManager

local TXT_NO_CARE
local TXT_NO_MARK
local TXT_ANY_MARK
 
local I_NO_CARE = -3
local I_NO_MARK = -2
local I_ANY_MARK = -1
 
local FCOISL = {}
 
local hasFCOIS = nil
 
local staticIconList = nil
local protection_fns = nil
 
IM.FCOISL = FCOISL
 
local DIList = nil
local DIChoices = nil
 
function FCOISL:hasAddon()
    if hasFCOIS ~= nil then return hasFCOIS end
 
    TXT_NO_CARE = GetString(IM_FCOIS_NOCAREMARK)
    TXT_NO_MARK = GetString(IM_FCOIS_NOMARK)
    TXT_ANY_MARK = GetString(IM_FCOIS_ANYMARK)
 
    hasFCOIS = ( FCOIS ~= nil and ((FCOIsMarked ~= nil and FCOGetDynamicInfo ~= nil and FCOGetIconText ~= nil) or (FCOIS.IsMarked ~= nil and FCOIS.GetDynamicInfo ~= nil and FCOIS.GetIconText ~= nil)))
 
    if(hasFCOIS) then
        staticIconList = {
            FCOIS_CON_ICON_GEAR_1,
            FCOIS_CON_ICON_GEAR_2,
            FCOIS_CON_ICON_GEAR_3,
            FCOIS_CON_ICON_GEAR_4,
            FCOIS_CON_ICON_GEAR_5,
            FCOIS_CON_ICON_LOCK,
            FCOIS_CON_ICON_SELL,
            FCOIS_CON_ICON_RESEARCH,
            FCOIS_CON_ICON_DECONSTRUCTION,
            FCOIS_CON_ICON_IMPROVEMENT,
            FCOIS_CON_ICON_SELL_AT_GUILDSTORE,
            FCOIS_CON_ICON_INTRICATE,
        }
 
        protected_actions = {
            [IM.ACTION_DESTROY]       =  FCOIS.IsDestroyLocked,
            [IM.ACTION_SELL]          = {
                [false] = FCOIS.IsVendorSellLocked,
                [true]  = FCOIS.IsFenceSellLocked
            },
            [IM.ACTION_LAUNDER]       =  FCOIS.IsLaunderLocked,
            [IM.ACTION_DECONSTRUCT]   = {
                [false] = FCOIS.IsDeconstructionLocked,
                [true]  = FCOIS.IsEnchantingExtractionLocked
            },
        }
    end
 
    return hasFCOIS
end
 
function FCOISL:IsProtectedAction(action, bagId, slotId, extraParm)
    if not protected_actions or not protected_actions[action] then return false end
 
    local pa = protected_actions[action]
    if extraParm ~= nil then
        return pa[extraParm](bagId, slotId)
    end
 
    if type(pa) == "table" then
        for _, v in pairs(pa) do
            if not v(bagId, slotId) then return false end
        end
        return true
    end
    return pa(bagId, slotId)
end
 
function FCOISL:GetIconText(iconNr)
    local str
    if FCOGetIconText then str = FCOGetIconText(iconNr) end
    if FCOIS.GetIconText then str = FCOIS.GetIconText(iconNr) end
    if str then return str end
 
    str = GetString("IM_FCO_STATIC_TXT", iconNr)
    if str == "" then return nil end
 
    return str
end
 
function FCOISL:GetDynamicIconList()
    if DIList then return DIList end
 
    DIList = { }
    if not self:hasAddon() then return DIList end
 
    local totalNumberOfDynamicIcons, numberToDynamicIconNr
    if FCOGetDynamicInfo then totalNumberOfDynamicIcons, numberToDynamicIconNr = FCOGetDynamicInfo() end
    if FCOIS.GetDynamicInfo then totalNumberOfDynamicIcons, numberToDynamicIconNr = FCOIS.GetDynamicInfo() end
 
    for _, dynamicIconNr in pairs(staticIconList) do
        local dynIconName = FCOISL:GetIconText(dynamicIconNr)
        DIList[#DIList + 1] = { dynamicIconNr, dynIconName }
        DIList[dynIconName] = dynamicIconNr
    end
 
    for index, dynamicIconNr in pairs(numberToDynamicIconNr) do
        local dynIconName = FCOISL:GetIconText(dynamicIconNr)
        DIList[#DIList + 1] = { dynamicIconNr, dynIconName }
        DIList[dynIconName] = dynamicIconNr
    end
 
    return DIList
end
 
 
function FCOISL:GetIndexedMark(mark)
    if mark == I_NO_MARK then return TXT_NO_MARK
    elseif mark == I_ANY_MARK then return TXT_ANY_MARK
    end
 
    return (FCOISL:hasAddon() and FCOISL:GetIconText(mark)) or TXT_NO_CARE
end
 
function FCOISL:GetMarkIndex(markText)
 
    if markText == TXT_NO_CARE then return nil
    elseif markText == TXT_NO_MARK then return I_NO_MARK
    elseif markText == TXT_ANY_MARK then return I_ANY_MARK
    else 
		if not FCOISL:hasAddon() then return nil end
		return FCOISL:GetDynamicIconList()[markText]
    end
end
 
function FCOISL:GetDefaultMark() return I_NO_CARE end
 
function FCOISL:IsNoMark(mark) return mark == I_NO_MARK end
 
function FCOISL:IsAnyMark(mark) return mark == I_ANY_MARK end
 
function FCOISL:GetIconChoices()
--    if DIChoices then return DIChoices end
 
    DIChoices = { TXT_NO_CARE, TXT_NO_MARK, TXT_ANY_MARK }

	-- We abuse this function to generate choices for other addons, too, so provide at least the generic set.
	-- TODO: If I have to extend it further, provide an abstraction layer for inventory savers. Joy...
    if not self:hasAddon() then return DIChoices end
 
    for _, v in pairs(staticIconList) do
        DIChoices[#DIChoices + 1] = FCOISL:GetIconText(v)
    end
 
    local totalNumberOfDynamicIcons, numberToDynamicIconNr
    if FCOGetDynamicInfo then totalNumberOfDynamicIcons, numberToDynamicIconNr = FCOGetDynamicInfo() end
    if FCOIS.GetDynamicInfo then totalNumberOfDynamicIcons, numberToDynamicIconNr = FCOIS.GetDynamicInfo() end
    for index, dynamicIconNr in pairs(numberToDynamicIconNr) do
        local dynIconName = FCOISL:GetIconText(dynamicIconNr)
        DIChoices[#DIChoices + 1] = dynIconName
		DEBUG(dynIconName)
    end
 
    return DIChoices
end
 
function FCOISL:FitMark(instanceId, mark, bagId, slotIndex)
    -- If we have switched off this addon, render this filter setting as irrelevant
    if not FCOISL:hasAddon() then return true end
 
    if not mark then return true end
 
    if mark == I_NO_MARK then return not FCOISL:HasMark(instanceId, nil, bagId, slotIndex)
    elseif mark == I_ANY_MARK then return FCOISL:HasMark(instanceId, nil, bagId, slotIndex)
    end
 
    return FCOISL:HasMark(instanceId, mark, bagId, slotIndex)
end
 
function FCOISL:HasMark(instanceId, mark, bagId, slotIndex)
    local _tab = self:GetDynamicIconList()
 
    if mark then
        local retVar = false
        if FCOIsMarked then retVar = FCOIsMarked(instanceId, mark) end
        if FCOIS.IsMarked then retVar = FCOIS.IsMarked(bagId, slotIndex, mark) end
        return retVar
    end
 
    for i = 1, #_tab, 1 do
        if FCOIsMarked and FCOIsMarked(instanceId, _tab[i]) then return true end
        if FCOIS.IsMarked and FCOIS.IsMarked(bagId, slotIndex, _tab[i]) then return true end
    end
 
    return false
end


