--- ESO Farm-Buddy AddOn written by Keldor

ESOFarmBuddyControlUtils = {}


function ESOFarmBuddyControlUtils:GetCtrlByItemId(itemId)

    local numChildren = ESOFarmBuddy.CtrlsItemList:GetNumChildren()
    if numChildren > 0 then
        for i = 1, numChildren do
            local ctrl = ESOFarmBuddy.CtrlsItemList:GetChild(i)
            if ctrl.itemId == itemId then
                return ctrl
            end
        end
    end

    return nil
end

function ESOFarmBuddyControlUtils:IsItemIdInCtrlList(itemId)

    local numChildren = ESOFarmBuddy.CtrlsItemList:GetNumChildren()
    if numChildren > 0 then
        for i = 1, numChildren do
            local ctrl = ESOFarmBuddy.CtrlsItemList:GetChild(i)
            if ctrl.itemId == itemId then
                return true
            end
        end
    end

    return false
end

function ESOFarmBuddyControlUtils:ClearItemList()

    local goalSetterItemId
    if ESOFarmBuddyGoalSetter:IsHidden() == false then
        goalSetterItemId = ESOFarmBuddyGoalSetter:GetNamedChild("SetButton").itemId
    end

    local numChildren = ESOFarmBuddy.CtrlsItemList:GetNumChildren()
    if numChildren > 0 then
        for i = 1, numChildren do

            local ctrl = ESOFarmBuddy.CtrlsItemList:GetChild(i)
            if ESOFarmBuddyUtils:IsItemIdInSVList(ctrl.itemId) == false then
                if ctrl.itemId == goalSetterItemId then
                    ESOFarmBuddyGoalSetter:SetHidden(true)
                end

                ESOFarmBuddy.Remove(ctrl)
            end
        end
    end
end