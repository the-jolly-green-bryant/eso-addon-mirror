LostPassives = {
    name = "LostPassives",
    svname = "LostPassivesSavedVariables",
    variableVersion = 1,
    dialogId = "LostPassivesConfirmDialog",
    ui = { rows = {} },

    -- Settings
    defaults = {
        seenEffects = {},
        selectedEffects = {},
    },

}

local LP=LostPassives
local seenEffects
local selectedEffects

local Row = { num = 0 }
function Row:New()
    local o = {}
    Row.num = Row.num + 1
    o.id = Row.num
    o.abilityId = 0
    o.name = "LostPassivesRow" .. tostring(Row.num)
    o.control = CreateControlFromVirtual(o.name, LostPassives.ui.scrollPanelScrollChild, "LostPassivesRowTemplate")
    o.chkBox = o.control:GetNamedChild("CheckBox")
    o.chkBox.id = o.id
    o.lblAbilityId = o.control:GetNamedChild("AbilityId")
    o.lblAbilityName = o.control:GetNamedChild("AbilityName")

    if o.id == 1 then
        o.control:SetAnchor(TOPLEFT, LostPassives.ui.scrollPanelScrollChild, TOPLEFT, 5, 5)
    else
        o.control:SetAnchor(TOPLEFT, LostPassives.ui.rows[o.id-1].control, BOTTOMLEFT, 0, 5)
    end

    setmetatable(o, self)
    self.__index = self
    return o
end

function Row:Set(abilityId, abilityName, isChecked)
    self.abilityId = abilityId
    self.lblAbilityId:SetText(tostring(abilityId))
    self.lblAbilityName:SetText(abilityName)
    ZO_CheckButton_SetCheckState(self.chkBox, isChecked and 1 or 0)
    -- self.chkBox:SetState(isChecked and 1 or 0)
end

local function getSorted(effectList)
    local function compare(a,b)
        return a[2] < b[2]
    end
    local newtbl = {}
    for id,_ in pairs(effectList) do
        table.insert(newtbl, {id, GetAbilityName(id)})
    end
    table.sort(newtbl, compare)
    return newtbl
end

local function showUI()
    local n = 0
    -- for id,_ in pairs(self.SV.seenEffects) do
    --     n = n + 1
    --     if n > #self.ui.rows then
    --         table.insert(self.ui.rows, Row:New())
    --     end
    --     self.ui.rows[n]:Set(id, self.SV.selectedEffects[id] ~= nil)
    -- end

    for _,e in ipairs(getSorted(seenEffects)) do
        n = n + 1
        if n > #LP.ui.rows then
            table.insert(LP.ui.rows, Row:New())
        end
        LP.ui.rows[n]:Set(e[1], e[2], selectedEffects[e[1]] ~= nil)
        LP.ui.rows[n].control:SetHidden(false)
    end
    n = n + 1

    -- hide unused rows (after data clear)
    while n <= #LP.ui.rows do
        LP.ui.rows[n].control:SetHidden(true)
        LP.ui.rows[n]:Set(0, nil, false)
        n = n + 1
    end

    LP.ui.control:SetHidden(false)
end

function LostPassives.SelectAll()
    for _,r in pairs(LP.ui.rows) do
        r.chkBox:SetState(1)
    end
end

function LostPassives.SelectNone()
    for _,r in pairs(LP.ui.rows) do
        r.chkBox:SetState(0)
    end
end

local function clearDataConfirmedCB()
    LP.SV.seenEffects = {}
    LP.SV.selectedEffects = {}
    seenEffects = LP.SV.seenEffects
    selectedEffects = LP.SV.selectedEffects
    showUI()
end

function LostPassives.ClearData()
    ZO_Dialogs_ShowDialog(LP.dialogId)
end

function LostPassives.Save()
    for _,r in pairs(LP.ui.rows) do
        local control = r.chkBox
        local abilityId = LP.ui.rows[control.id].abilityId
        if control:GetState() == 0 then
            selectedEffects[abilityId] = nil
        elseif control:GetState() == 1 then
            selectedEffects[abilityId] = true
        end
    end
    LP.ui.control:SetHidden(true)
end

local function printEffectLost(abilityId)
    df("[|ca84a5dLost|r|ca7b025Passives|r]: Effect lost: %s (%d)", GetAbilityName(abilityId), abilityId)
end

local function debugPrint(message, ...)
    df("[LostPassives]: %s", message:format(...))
end

local function onCombatEvtDbg(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, 
    targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    --  debugPrint("onCombatEvtDbg %s->%s %d r:%d %d %s", sourceName, targetName, abilityId, result, hitValue, abilityName)
    -- if sourceType == COMBAT_UNIT_TYPE_PLAYER and targetType == COMBAT_UNIT_TYPE_PLAYER then
        if result == ACTION_RESULT_EFFECT_GAINED and targetType == COMBAT_UNIT_TYPE_PLAYER then
            seenEffects[abilityId] = true
        elseif result == ACTION_RESULT_EFFECT_FADED and sourceType ~= COMBAT_UNIT_TYPE_GROUP then
            if selectedEffects[abilityId] ~= nil then
                printEffectLost(abilityId)
            end
        end
end

local function OnPlayerActivated(eventCode)
    EVENT_MANAGER:UnregisterForEvent(LostPassives.name, eventCode)

    EVENT_MANAGER:RegisterForEvent(LP.name, EVENT_COMBAT_EVENT, onCombatEvtDbg)
    EVENT_MANAGER:AddFilterForEvent(LP.name, EVENT_COMBAT_EVENT,
        -- REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, 
        REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER,
        REGISTER_FILTER_IS_ERROR, false)
end

local function cmdHandler(arg)
    showUI()
end

function LostPassives.OnAddOnLoaded(event, addOnName)
    if addOnName ~= LostPassives.name then return end
    EVENT_MANAGER:UnregisterForEvent(LostPassives.name, EVENT_ADD_ON_LOADED);

    LP.SV = ZO_SavedVars:New("LostPassivesSavedVariables", LostPassives.variableVersion, nil, LostPassives.defaults)
    seenEffects = LP.SV.seenEffects
    selectedEffects = LP.SV.selectedEffects

    LP.ui.control = LostPassivesWindow
    LP.ui.fragment = ZO_HUDFadeSceneFragment:New(LP.ui.control);
    LP.ui.bg = LP.ui.control:GetNamedChild("Bg")
    LP.ui.topRow = LP.ui.bg:GetNamedChild("TopRow")
    LP.ui.scrollPanel = LP.ui.bg:GetNamedChild("Panel")
    LP.ui.scrollPanelScrollChild = LP.ui.scrollPanel:GetNamedChild("Scroll"):GetNamedChild("Child")
    LP.ui.scrollPanelScrollBar = LP.ui.scrollPanel:GetNamedChild("ScrollBar")


    EVENT_MANAGER:RegisterForEvent(LostPassives.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    SLASH_COMMANDS["/passives"] = cmdHandler

    ESO_Dialogs[LP.dialogId] = {
        canQueue = true,
        title = {
            text = "Confirm data clear",
        },
        mainText = {
            text = "This action will throw away all observed effects and your selection",
        },
        buttons = {
            [1] = {
                text = "Confirm",
                callback = clearDataConfirmedCB,
            },
            [2] = {
                text = "Cancel",
                callback = function(dialog) end,
            }
        }
    }
end
EVENT_MANAGER:RegisterForEvent(LostPassives.name, EVENT_ADD_ON_LOADED, LostPassives.OnAddOnLoaded)
