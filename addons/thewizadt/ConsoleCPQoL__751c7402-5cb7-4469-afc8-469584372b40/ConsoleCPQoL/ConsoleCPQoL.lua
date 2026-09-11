-- ============================================================================
-- ConsoleCPQoL - Fully Automatic Gamepad CP Addon (Engine Post-Hook Fix)
-- ============================================================================

local ConsoleCPQoL = {}
ConsoleCPQoL.name = "ConsoleCPQoL"

local activeLabels = {}
local isCPUIOpen = false

local function ClearPerkLabels()
    for _, label in pairs(activeLabels) do
        if label then
            label:SetHidden(true)
            label:SetText("")
        end
    end
    -- Sweep all possible label indices
    for i = 1, 300 do
        local n = WINDOW_MANAGER:GetControlByName("ConsoleCPQoL_StarLabel_" .. i)
        if n then
            n:SetHidden(true)
            n:SetText("")
        end
    end
end

local function RefreshPerkLabels()
    if not isCPUIOpen then return end
    if not ZO_ChampionPerksCanvas then return end

    local fontSize = 24
    local fontString = string.format("$(MEDIUM_FONT)|%d|soft-shadow-thin", fontSize)

    local childCount = ZO_ChampionPerksCanvas:GetNumChildren()
    local createdCount = 0

    for i = 1, childCount do
        local child = ZO_ChampionPerksCanvas:GetChild(i)
        
        if child and child.star then
            local skillName = nil

            if child.star.championSkillData then
                local id = child.star.championSkillData.championSkillId
                if id then 
                    skillName = GetChampionSkillName(id) 
                end
            elseif child.star.championClusterData and child.star.championClusterData.clusterChildren then
                local firstChild = child.star.championClusterData.clusterChildren[1]
                if firstChild and firstChild.GetFormattedName then
                    skillName = firstChild:GetFormattedName()
                end
            end

            if skillName and skillName ~= "" then
                local labelName = "ConsoleCPQoL_StarLabel_" .. i
                local n = WINDOW_MANAGER:GetControlByName(labelName)
                
                if not n then
                    n = WINDOW_MANAGER:CreateControl(labelName, ZO_ChampionPerksCanvas, CT_LABEL)
                    n:SetColor(1, 0.9, 0.2, 1) -- Bright Gold
                    n:SetDrawLayer(DL_OVERLAY)
                    n:SetDrawLevel(2)
                    n:SetDrawTier(DT_HIGH)
                    n:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
                end

                n:SetFont(fontString)
                n:ClearAnchors()
                n:SetAnchor(CENTER, child, CENTER, 0, -35)
                n:SetText(zo_strformat("<<C:1>>", skillName))
                n:SetHidden(false)
                
                table.insert(activeLabels, n)
                createdCount = createdCount + 1
            end
        end
    end
end

-- Secure hook into ESO's Gamepad Tooltips engine framework
local function InitializeTooltipHooks()
    if GAMEPAD_TOOLTIPS then
        -- Hook when any gamepad tooltip is laid out/shown
        if GAMEPAD_TOOLTIPS.LayoutChampionPerkSkill and not GAMEPAD_TOOLTIPS._ccpHooked then
            SecurePostHook(GAMEPAD_TOOLTIPS, "LayoutChampionPerkSkill", function()
                d("[CCP Debug] Tooltip Laid Out (Showing)")
                ClearPerkLabels()
                if ZO_ChampionPerksCanvas then
                    ZO_ChampionPerksCanvas:SetHidden(true)
                end
            end)
            GAMEPAD_TOOLTIPS._ccpHooked = true
        end

        -- Hook when tooltips are cleared/hidden
        if GAMEPAD_TOOLTIPS.ClearTooltip and not GAMEPAD_TOOLTIPS._ccpClearHooked then
            SecurePostHook(GAMEPAD_TOOLTIPS, "ClearTooltip", function()
                d("[CCP Debug] Tooltip Cleared (Hidden)")
                if ZO_ChampionPerksCanvas then
                    ZO_ChampionPerksCanvas:SetHidden(false)
                end
                if isCPUIOpen then
                    zo_callLater(RefreshPerkLabels, 50)
                end
            end)
            GAMEPAD_TOOLTIPS._ccpClearHooked = true
        end
    end
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ConsoleCPQoL.name then return end
    EVENT_MANAGER:UnregisterForEvent(ConsoleCPQoL.name, EVENT_ADD_ON_LOADED)
    
    InitializeTooltipHooks()

    if SCENE_MANAGER then
        local cpScene = SCENE_MANAGER:GetScene("gamepad_championPerks_root")
        if cpScene then
            cpScene:RegisterCallback("StateChange", function(oldState, newState)
                if newState == SCENE_SHOWING or newState == SCENE_SHOWN then
                    isCPUIOpen = true
                    InitializeTooltipHooks()
                    zo_callLater(RefreshPerkLabels, 200)
                    zo_callLater(RefreshPerkLabels, 600)
                elseif newState == SCENE_HIDDEN or newState == SCENE_HIDING then
                    isCPUIOpen = false
                    ClearPerkLabels()
                end
            end)
        end
    end
end

EVENT_MANAGER:RegisterForEvent(ConsoleCPQoL.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

if ZO_ChampionPerks_Gamepad then
    local oldUpdate = ZO_ChampionPerks_Gamepad.Update
    if oldUpdate then
        ZO_ChampionPerks_Gamepad.Update = function(self, ...)
            oldUpdate(self, ...)
            if isCPUIOpen then
                InitializeTooltipHooks()
                zo_callLater(RefreshPerkLabels, 30)
            end
        end
    end
end

SLASH_COMMANDS["/ccptest"] = function()
    isCPUIOpen = true
    RefreshPerkLabels()
end

SLASH_COMMANDS["/ccpclear"] = function()
    ClearPerkLabels()
    if ZO_ChampionPerksCanvas then
        ZO_ChampionPerksCanvas:SetHidden(true)
    end
    d("[CCP Debug] Manual clear executed via /ccpclear")
end