CombatInsightsUtils = CombatInsightsUtils or {}
local Utils = CombatInsightsUtils


local mainlogger
local subloggers = {}

if LibDebugLogger then
    mainlogger = LibDebugLogger.Create("CombatInsights")
end

local DummyLogger={}
function DummyLogger.Debug() end
function DummyLogger.Warn() end
function DummyLogger.Info() end
function DummyLogger.Error() end
function DummyLogger.SetEnabled() end


local function debugPrint(message, ...)
    df("[CPChUt]: %s", message:format(...))
end

function Utils.CreateSubLogger(name)
    if mainlogger == nil then return DummyLogger end
    if subloggers[name] then return subloggers[name] end
    local sl = mainlogger:Create(name)
    subloggers[name] = sl
    return sl
end


function Utils.DeepCopy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[Utils.DeepCopy(orig_key, copies)] = Utils.DeepCopy(orig_value, copies)
            end
            setmetatable(copy, Utils.DeepCopy(getmetatable(orig), copies))
            -- setmetatable(copy, getmetatable(orig))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end


function Utils.TableCopyNumeric(source, dest)
    dest = dest or {}
    for i=1,#source do
        dest[i] = source[i]
    end
    return dest
end

function Utils.GetBloodThirstyValue(enemyHpPercent, maxValue)
    if enemyHpPercent > 0.9 then return 0 end
    if enemyHpPercent < 0.09 then return 1 end
    return (0.9-enemyHpPercent)/(0.91)+0.1
end


local function getSelectionIds(control)
    local ids = {}
    local allIds = {}
    local numselected = 0
    for i = 1, control:GetNumChildren() do
        local child = control:GetChild(i)
        allIds[child.dataId] = true
        local selected = not child:GetNamedChild("HighLight"):IsHidden()
        if selected then
            ids[child.dataId] = true
            numselected = numselected + 1
            -- local abilityTxt = child:GetNamedChild("Name"):GetText()
            
            -- local _,_, id = string.find(abilityTxt, "^%((%d+)")
            -- if id then
            --     ids[tonumber(id)] = true
            --     numselected = numselected + 1
            --     -- table.insert(ids, id)
            -- else
            --     hasError = true
            -- end
        end
    end
    if numselected > 0 then
        return numselected, ids
    end
    return numselected, allIds
end

function Utils.GetCMXSelectedAbilities()
    return getSelectionIds(CombatMetrics_Report_AbilityPanelPanelScrollChild)
end


function Utils.GetCMXSelectedUnits()
    return getSelectionIds(CombatMetrics_Report_UnitPanelPanelScrollChild)
    -- local numselected, allIds = getSelectionIds(CombatMetrics_Report_UnitPanelPanelScrollChild)
    -- if cmxFight then
    --     local realids = {}
    --     for id,_ in pairs(allIds) do
    --         realids[cmxFight.units[id].unitId] = true
    --     end
    --     return numselected, realids
    -- end
    -- return numselected, allIds
end



function Utils.GetItemBloodThirstyValue(itemLink)
    local id, desc = GetItemLinkTraitInfo(itemLink)
        
    if id == ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY then
        -- debugPrint("getBloodThirstyValue %d %s", id, desc)
        --Increases your Weapon and Spell Damage against enemies under 90% Health by up to 350.
        --2 or 3 digit without trailing % the digits are color formatted like |cffffff350|r
        local _,_,val = string.find(desc, "(%d%d%d?)|r[^%%]+")
        -- debugPrint("find res: %s", tostring(val))
        if val then
            return val
        end
    end
    return 0
end

function Utils.GetCoralRiptideValue(staminaPercent)
    return 740 * (staminaPercent <= 0.33 and 1 or (1-staminaPercent)/(1-0.33))
end


function Utils.CMXFightUID(cmxFight)
    -- the saved fights have different unit ids so like this we consider them different fights
    return string.format("%d%010d", cmxFight.date, cmxFight.playerid)
end

function Utils.GetSetName(itemLink)
    local _, setName, _, _, _, _ = GetItemLinkSetInfo(itemLink)
    return setName
end
