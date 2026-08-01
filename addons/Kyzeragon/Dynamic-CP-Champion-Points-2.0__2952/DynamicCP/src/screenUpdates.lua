-- ZOS has currently implemented a cooldown on how often you can change slottables
local SLOTTABLE_COOLDOWN_STRING = "ERROR: Unable to commit changes. This is probably due to ZOS's 30-second cooldown on changing slottables. Try again in %.0f seconds."
local SLOTTABLE_COOLDOWN = 30000
local lastSlottableChange = 0

---------------------------------------------------------------------
-- Refresh/reset star labels to the default
function DynamicCP.RefreshLabels(show)
    local styles = DynamicCP.GetStyles()
    for i = 1, ZO_ChampionPerksCanvas:GetNumChildren() do
        local child = ZO_ChampionPerksCanvas:GetChild(i)
        if (child.star and child.star.championSkillData) then
            local id = child.star.championSkillData.championSkillId
            local n = child:GetNamedChild("Name")
            if (not n) then
                n = WINDOW_MANAGER:CreateControl("$(parent)Name", child, CT_LABEL)
                n:SetInheritScale(false)
                n:SetAnchor(CENTER, child, CENTER, 0, -20)
            end

            local slottable = CanChampionSkillTypeBeSlotted(GetChampionSkillType(id))
            if (slottable) then
                n:SetFont(styles.GetSizedFont(DynamicCP.savedOptions.slottableLabelSize))
                n:SetColor(unpack(DynamicCP.savedOptions.slottableLabelColor))
            else
                n:SetFont(styles.GetSizedFont(DynamicCP.savedOptions.passiveLabelSize))
                n:SetColor(unpack(DynamicCP.savedOptions.passiveLabelColor))
            end
            n:SetText(zo_strformat("<<C:1>>", GetChampionSkillName(id)))

            n:SetHidden(not show)
        elseif (child.star and child.star.championClusterData) then
            local text = ""
            for _, clusterChild in ipairs(child.star.championClusterData.clusterChildren) do
                text = text .. clusterChild:GetFormattedName() .. "\n"
            end
            local n = child:GetNamedChild("Name")
            if (not n) then
                n = WINDOW_MANAGER:CreateControl("$(parent)Name", child, CT_LABEL)
                n:SetInheritScale(false)
                n:SetAnchor(CENTER, child, CENTER, 0, -20)
            end
            n:SetFont(styles.GetSizedFont(DynamicCP.savedOptions.clusterLabelSize))
            n:SetColor(unpack(DynamicCP.savedOptions.clusterLabelColor))
            n:SetText(text)
            n:SetHidden(not show)
        end
    end
end


---------------------------------------------------------------------
-- utils
local function IsInBounds(control)
    local x, y = control:GetCenter()
    return x >= 0 and x <= GuiRoot:GetWidth() and y >= 0 and y <= GuiRoot:GetHeight()
end

---------------------------------------------------------------------
-- idk if this is the right way to do it...
-- When the animations have settled, check positions of the canvases to see which is active
local function OnCanvasAnimationStopped()
    EVENT_MANAGER:UnregisterForUpdate(DynamicCP.name .. "RectTimeout")

    if (ZO_ChampionPerksCanvas:IsHidden()) then
        -- This is not consistent, do not use this to trigger exit events
        return
    end

    local greenBounds = IsInBounds(ZO_ChampionPerksCanvasConstellation1) or IsInBounds(ZO_ChampionPerksCanvasConstellation4)
    local blueBounds = IsInBounds(ZO_ChampionPerksCanvasConstellation2) or IsInBounds(ZO_ChampionPerksCanvasConstellation5)
    local redBounds = IsInBounds(ZO_ChampionPerksCanvasConstellation3) or IsInBounds(ZO_ChampionPerksCanvasConstellation6)

    local activeConstellation = nil
    if (greenBounds and blueBounds and redBounds) then
        activeConstellation = "All"
    elseif (greenBounds) then
        activeConstellation = "Green"
    elseif (blueBounds) then
        activeConstellation = "Blue"
    elseif (redBounds) then
        activeConstellation = "Red"
    else
        activeConstellation = "Cluster"
        DynamicCP.RefreshLabels(DynamicCP.savedOptions.showLabels)
        DynamicCP.AddMouseDoubleClickStars()
    end
end


---------------------------------------------------------------------
-- Check for unsaved changes when exiting screen
local function DisplayWarning(text)
    DynamicCPWarningLabel:SetText(text)
    DynamicCPWarningLabel:SetFont(DynamicCP.GetStyles().gameFont)
    DynamicCPWarning:SetHidden(false)
    DynamicCPWarning:ClearAnchors()
    DynamicCPWarning:SetAnchor(BOTTOM, ZO_Dialog1, TOP, 0, -10)
end

local function SetWarning(text)
    DynamicCPWarningLabel:SetText(text)
end

local function HideWarning()
    DynamicCPWarning:SetHidden(true)
end

function DynamicCP.OnExitedCPScreen()
    if (DynamicCP.savedOptions.showLeaveWarning and CHAMPION_PERKS:HasUnsavedChanges()) then
        local text = "Warning: You have left the Champion Points screen without saving"
        if (CHAMPION_DATA_MANAGER:HasUnsavedChanges()) then
            text = text .. " points"
                    .. (CHAMPION_PERKS.championBar:HasUnsavedChanges() and " and slottables." or ".")
        elseif (CHAMPION_PERKS.championBar:HasUnsavedChanges()) then
            text = text .. " slottables."
        end
        CHAMPION_PERKS:SpendPendingPoints()
        DisplayWarning(text)
        EVENT_MANAGER:RegisterForUpdate(DynamicCP.name .. "Warning", 10000, function()
            EVENT_MANAGER:UnregisterForUpdate(DynamicCP.name .. "Warning")
            HideWarning()
        end)
    elseif (not CHAMPION_PERKS:HasUnsavedChanges()) then
        HideWarning()
    end
end

function DynamicCP.OnPurchased(result, isArmory)
    local resultToString = {
        [CHAMPION_PURCHASE_ABILITY_CAP_EXCEEDED] = "ABILITY_CAP_EXCEEDED",
        [CHAMPION_PURCHASE_ABILITY_LINE_LEVEL_NOT_MET] = "ABILITY_LINE_LEVEL_NOT_MET",
        [CHAMPION_PURCHASE_ATTRIBUTE_CAP_EXCEEDED] = "ATTRIBUTE_CAP_EXCEEDED",
        [CHAMPION_PURCHASE_CARRYING_DAEDRIC_ARTIFACT] = "CARRYING_DAEDRIC_ARTIFACT",
        [CHAMPION_PURCHASE_CHAMPION_BAR_ILLEGAL_SLOT] = "CHAMPION_BAR_ILLEGAL_SLOT",
        [CHAMPION_PURCHASE_CHAMPION_BAR_NOT_CHAMPION_SKILL] = "CHAMPION_BAR_NOT_CHAMPION_SKILL",
        [CHAMPION_PURCHASE_CHAMPION_BAR_ON_COOLDOWN] = "CHAMPION_PURCHASE_CHAMPION_BAR_ON_COOLDOWN",
        [CHAMPION_PURCHASE_CHAMPION_BAR_SKILL_NOT_PURCHASED] = "CHAMPION_BAR_SKILL_NOT_PURCHASED",
        [CHAMPION_PURCHASE_CHAMPION_BAR_SKILL_NOT_SLOTTABLE] = "CHAMPION_BAR_SKILL_NOT_SLOTTABLE",
        [CHAMPION_PURCHASE_CHAMPION_BAR_WRONG_DISCIPLINE] = "CHAMPION_BAR_WRONG_DISCIPLINE",
        [CHAMPION_PURCHASE_CHAMPION_NOT_UNLOCKED] = "CHAMPION_NOT_UNLOCKED",
        [CHAMPION_PURCHASE_CP_DISABLED] = "CP_DISABLED",
        [CHAMPION_PURCHASE_INTERNAL_ERROR] = "INTERNAL_ERROR",
        [CHAMPION_PURCHASE_INVALID_ABILITY] = "INVALID_ABILITY",
        [CHAMPION_PURCHASE_INVALID_ATTRIBUTE] = "INVALID_ATTRIBUTE",
        [CHAMPION_PURCHASE_IN_COMBAT] = "IN_COMBAT",
        [CHAMPION_PURCHASE_IN_NOCP_BATTLEGROUND] = "IN_NOCP_BATTLEGROUND",
        [CHAMPION_PURCHASE_IN_NOCP_CAMPAIGN] = "IN_NOCP_CAMPAIGN",
        [CHAMPION_PURCHASE_NOT_ENOUGH_POINTS] = "NOT_ENOUGH_POINTS",
        [CHAMPION_PURCHASE_RESPEC_FAILED] = "RESPEC_FAILED",
        [CHAMPION_PURCHASE_SKILL_NEEDS_REFUND] = "SKILL_NEEDS_REFUND",
        [CHAMPION_PURCHASE_SKILL_NOT_CONNECTED] = "SKILL_NOT_CONNECTED",
        [CHAMPION_PURCHASE_SUCCESS] = "SUCCESS",
    }
    local armoryResultToString = {
        [ARMORY_BUILD_RESTORE_RESULT_BAD_INDEX] = "BAD_INDEX",
        [ARMORY_BUILD_RESTORE_RESULT_BUSY] = "BUSY",
        [ARMORY_BUILD_RESTORE_RESULT_COOLDOWN] = "COOLDOWN",
        [ARMORY_BUILD_RESTORE_RESULT_EFFECT_COUNT_LIMIT] = "EFFECT_COUNT_LIMIT",
        [ARMORY_BUILD_RESTORE_RESULT_INVALID_PLAYER_STATE] = "INVALID_PLAYER_STATE",
        [ARMORY_BUILD_RESTORE_RESULT_IN_COMBAT] = "IN_COMBAT",
        [ARMORY_BUILD_RESTORE_RESULT_IN_WEREWOLF_FORM] = "IN_WEREWOLF_FORM",
        [ARMORY_BUILD_RESTORE_RESULT_NO_GEAR_SPACE] = "NO_GEAR_SPACE",
        [ARMORY_BUILD_RESTORE_RESULT_NO_INTERACTION] = "NO_INTERACTION",
        [ARMORY_BUILD_RESTORE_RESULT_REMOVE_GEAR_FAILURE] = "REMOVE_GEAR_FAILURE",
        [ARMORY_BUILD_RESTORE_RESULT_RESTORE_FAILED] = "RESTORE_FAILED",
        [ARMORY_BUILD_RESTORE_RESULT_SPECIAL_HOTBAR_ACTIVE] = "SPECIAL_HOTBAR_ACTIVE",
        [ARMORY_BUILD_RESTORE_RESULT_SUCCESS] = "SUCCESS",
        [ARMORY_BUILD_RESTORE_RESULT_TIMEOUT] = "TIMEOUT",
    }

    if (isArmory) then
        DynamicCP.dbg("Armory change " .. armoryResultToString[result])
    else
        DynamicCP.dbg("Purchased " .. resultToString[result])
    end

    if (isArmory) then
        HideWarning()
        -- Loading from armory does NOT affect the cooldown
    elseif (result == CHAMPION_PURCHASE_SUCCESS) then
        HideWarning()
        lastSlottableChange = GetGameTimeMilliseconds()
    elseif (result == CHAMPION_PURCHASE_CHAMPION_BAR_ON_COOLDOWN) then
        if (not DynamicCP.savedOptions.showCooldownWarning) then return end
        -- This is now the result that's given when we're on slottable cooldown
        local secondsRemaining = (SLOTTABLE_COOLDOWN - GetGameTimeMilliseconds() + lastSlottableChange) / 1000
        DisplayWarning(string.format(SLOTTABLE_COOLDOWN_STRING, secondsRemaining))

        -- Update the error message
        EVENT_MANAGER:RegisterForUpdate(DynamicCP.name .. "Warning", 1000, function()
            local secondsRemaining = (SLOTTABLE_COOLDOWN - GetGameTimeMilliseconds() + lastSlottableChange) / 1000
            if (secondsRemaining <= 0) then
                EVENT_MANAGER:UnregisterForUpdate(DynamicCP.name .. "Warning")
                HideWarning()
                -- TODO: Need to actually keep track of what the changes were, otherwise all the changes are lost when purchase request is sent...
                -- CHAMPION_PERKS:SpendPendingPoints()
            else
                SetWarning(string.format(SLOTTABLE_COOLDOWN_STRING, secondsRemaining))
            end
        end)
    else
        DisplayWarning("ERROR: Unable to commit changes. Reason: " .. resultToString[result]) -- Too lazy to find the appropriate localization strings
        EVENT_MANAGER:RegisterForUpdate(DynamicCP.name .. "Warning", 5000, function()
            EVENT_MANAGER:UnregisterForUpdate(DynamicCP.name .. "Warning")
            HideWarning()
        end)
    end
end


---------------------------------------------------------------------
-- Some first-time actions
function DynamicCP.InitLabels()
    -- Timeout to not spam operations on every animation tick
    ZO_ChampionPerksCanvasConstellation1:SetHandler("OnRectChanged", function()
        EVENT_MANAGER:RegisterForUpdate(DynamicCP.name .. "RectTimeout", 200, OnCanvasAnimationStopped)
    end)
end
