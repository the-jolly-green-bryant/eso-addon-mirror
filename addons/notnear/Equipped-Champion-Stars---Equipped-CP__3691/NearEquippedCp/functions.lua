local addon = NEAR_EC
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

function NEAR_EC.CreateProfileList()
    local charList
    if addon.ASV_main.char then
        charList = {}
        for i = 1, GetNumCharacters() do
            local name, _, _, _, _, _, id, _ = GetCharacterInfo(i)
            if addon.ASV_main.char[id] then
                charList[#charList + 1] = { charId = id, charName = zo_strformat("<<1>>", name), }
            end
        end
    end

    local profilesList = {
        choices = {},
        choicesValues = {},
    }

    -- Add "Account Wide" option if addon.ASV_main.accountwide is false
    if not addon.ASV_main.accountwide then
        table.insert(profilesList.choices, "Account Wide")
        table.insert(profilesList.choicesValues, "account")
    end

    if charList ~= nil and #charList > 0 then
        for i = 1, #charList do
            -- Skip adding if charId is the same as GetCurrentCharacterId()
            if addon.ASV_main.accountwide or charList[i].charId ~= GetCurrentCharacterId() then
                table.insert(profilesList.choices, charList[i].charName)
                table.insert(profilesList.choicesValues, charList[i].charId)
            end
        end
    end

    return profilesList
end

function NEAR_EC.OverwriteData(newId)
    local currentData = addon.ASV
    local sv

    if newId == "account" then
        sv = addon.ASV_main.account
    else
        sv = addon.ASV_main.char[newId]
    end

    for index, value in pairs(sv) do
        currentData[index] = value
    end

    ReloadUI()
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- [index] = {abilityId, abilityName}
addon.assignedCP = nil
local types = { "_Craft", "_Warfare", "_Fitness" }

-- Show/Hide the window
function NEAR_EC.ToggleGui()
	NEC_GUI:ToggleHidden()
end

-- Hide the window
function NEAR_EC.Hide()
    local sv = addon.ASV
    if not NEC_GUI:IsHidden() and sv.lockUI then
	    NEC_GUI:SetHidden(true)
    end
end

---------------------------------------------------------------------------------

-- Hide in combat
function NEAR_EC.OnCombatState(event, inCombat)
    local sv = addon.ASV

    inCombat = inCombat or IsUnitInCombat("player")

    if inCombat and sv.hide.inCombat and not NEC_GUI:IsHidden() then
        NEC_GUI:SetHidden(true)
    else -- TODO: if combat state change while on a menu it will show even if sv.hide.inMenu == true, can recticle state be checked here?
        NEC_GUI:SetHidden(false)
    end
end

-- Hide on menu open
function NEAR_EC.OnGuiUpdate(event, hide)
    local sv = addon.ASV
    if sv.hide.inMenu then
        if hide and not NEC_GUI:IsHidden() then
            addon.Hide()
        elseif not hide then
            addon.OnCombatState()
        end
    end
end

---------------------------------------------------------------------------------

-- Set Movable
function NEAR_EC.lockUI()
    local sv = addon.ASV
    local control = NEC_GUI
    if not sv.lockUI then
        control:SetMovable(true)
        control:SetHidden(false)
    else
        control:SetMovable(false)
    end
end

-- Save position
function NEAR_EC.SavePos()
    local sv = addon.ASV
    local control = NEC_GUI
    local _, point, _, relativePoint, offsetX, offsetY, _ = control:GetAnchor()
    if sv.guiAnchors == nil then sv.guiAnchors = {} end
    sv.guiAnchors.point = point
    sv.guiAnchors.relativePoint = relativePoint
    sv.offsetX = offsetX
    sv.offsetY = offsetY
end

-- Restore position
function NEAR_EC.RestorePos()
    local sv = addon.ASV

    local point = sv.guiAnchors == nil and (sv.labelAnchors.point == TOPLEFT and TOPLEFT or TOPRIGHT) or sv.guiAnchors.point
    local relativePoint = sv.guiAnchors == nil and (sv.labelAnchors.point == TOPLEFT and TOPLEFT or TOPRIGHT) or sv.guiAnchors.relativePoint
    local offsetX = sv.offsetX or ((point == TOPLEFT or point == BOTTOMLEFT) and 50 or -50)
    local offsetY = sv.offsetY or 50

    local control = NEC_GUI
    control:ClearAnchors()
    control:SetAnchor(point, GuiRoot, relativePoint, offsetX, offsetY)
end

-- Reset position
function NEAR_EC.ResetPos()
    local sv = addon.ASV
    if sv.guiAnchors.point == BOTTOMLEFT then sv.guiAnchors.point = TOPLEFT
    elseif sv.guiAnchors.point == BOTTOMRIGHT then sv.guiAnchors.point = TOPRIGHT end
    if sv.guiAnchors.relativePoint == BOTTOMLEFT then sv.guiAnchors.relativePoint = TOPLEFT
    elseif sv.guiAnchors.relativePoint == BOTTOMRIGHT then sv.guiAnchors.relativePoint = TOPRIGHT end
    sv.offsetX = nil
    sv.offsetY = nil
    addon.RestorePos()
end

---------------------------------------------------------------------------------

function NEAR_EC.UpdateControl()
    addon.ClearAssigned()
    addon.GetAssigned()
    addon.UpdateText()
end

---------------------------------------------------------------------------------

function NEAR_EC.SetColors()

    local gray  = { r = 0.835, g = 0.792, b = 0.8,   } -- d5cacc
    local green = { r = 0.498, g = 0.612, b = 0.31,  } -- 7f9c4f
    local blue  = { r = 0.314, g = 0.588, b = 0.702, } -- 5096b3
    local red   = { r = 0.71,  g = 0.384, b = 0.22,  } -- b56238

    local control = NEC_GUI:GetNamedChild("_Title")
    control:SetColor(gray.r, gray.g, gray.b, gray.a)

    for index, controlName in ipairs(types) do
        local color = (index == 1 and green) or (index == 2 and blue) or (index == 3 and red)

        for i = 1, 4 do
            control = NEC_GUI:GetNamedChild(controlName)
            control = control:GetNamedChild("_Name" .. i)
            control:SetColor(color.r, color.g, color.b, 1)
        end

    end

end

function NEAR_EC.SetAnchorsByType()
    local sv = addon.ASV

    local point = sv.labelAnchors.point
    local relativePoint = sv.labelAnchors.relativePoint
    local offsetX = point == TOPLEFT and 2 or -2

    local targetControl = GetControl("NEC_GUI_Title")

    for _, controlName in ipairs(types) do
        local control = GetControl("NEC_GUI" .. controlName)
        control:ClearAnchors()
        control:SetAnchor(point, targetControl, relativePoint, offsetX)
        targetControl = control
        offsetX = 0
    end

end

function NEAR_EC.SetAnchors()
    local sv = addon.ASV

    local point = sv.labelAnchors.point
    local offsetX = point == TOPLEFT and 2 or -2

    -- Set anchors for _Title control
    local targetControl = GetControl("NEC_GUI")
    local control = NEC_GUI:GetNamedChild("_Title")
    control:ClearAnchors()
    control:SetAnchor(point, targetControl, point, offsetX)

    -- Set anchors for the other controls
    addon.SetAnchorsByType()

    for _, controlName in ipairs(types) do
        local parent = NEC_GUI:GetNamedChild(controlName)
        local prev_control = parent

        for i = 1, 4 do
            local relativePoint = i == 1 and point or sv.labelAnchors.relativePoint

            control = parent:GetNamedChild("_Name" .. i)
            control:ClearAnchors()
            control:SetAnchor(point, prev_control, relativePoint, 0)

            prev_control = control
        end

    end

end

function NEAR_EC.UpdateText()

    if addon.assignedCP == nil then
        addon.GetAssigned()
    end

    for index, controlName in ipairs(types) do
        local parent = NEC_GUI:GetNamedChild(controlName)

        for i = 1, 4 do
            local control = parent:GetNamedChild("_Name".. i)
            local current = addon.assignedCP[index][i].abilityName
            control:SetText(current)
        end

    end

end

function NEAR_EC.ShowByType()
    local sv = addon.ASV

    local point = sv.labelAnchors.point
    local relativePoint = sv.labelAnchors.relativePoint

    local hide = {
        not sv.show_craft,
        not sv.show_warfare,
        not sv.show_fitness,
    }

    local show_all = (sv.show_all and true) or (sv.show_craft and sv.show_warfare and sv.show_fitness and true or false)

    if not show_all  then

        for index, controlName in ipairs(types) do
            local control = NEC_GUI:GetNamedChild(controlName)
            control:SetHidden(hide[index]) -- Hide/Show the control
        end

        local targetControls = {
            [1] = GetControl("NEC_GUI_Title"),
            [2] = GetControl("NEC_GUI" .. types[1]),
            [3] = GetControl("NEC_GUI" .. types[2]),
        }

        -- Set anchors for warfare and fitness
        for i = 2, 3 do
            local showType
            if i == 2 then
                showType = 1 + (sv.show_craft and 1 or 0)
            else
                showType = 1 + (sv.show_craft and 1 or 0) + (sv.show_warfare and 2 or 0)
            end

            local targetControl = targetControls[showType]
            local offsetX = showType == 1 and (point == TOPLEFT and 2 or -2) or 0

            local control = GetControl("NEC_GUI" .. types[i])
            control:ClearAnchors()
            control:SetAnchor(point, targetControl, relativePoint, offsetX)
        end

    else
        for _, controlName in ipairs(types) do
            local control = NEC_GUI:GetNamedChild(controlName)
            control:SetHidden(false) -- Show the control
        end

        -- Reset anchors
        addon.SetAnchorsByType()
    end
end

---------------------------------------------------------------------------------

function NEAR_EC.GetAssigned()
    if addon.assignedCP ~= nil then return end

    addon.assignedCP = {}

    for index, _ in ipairs(types) do
        addon.assignedCP[index] = {}

        local loop_start, loop_end
        if index == 1 then
            loop_start, loop_end = 1, 4
        elseif index == 2 then
            loop_start, loop_end = 5, 8
        elseif index == 3 then
            loop_start, loop_end = 9, 12
        end

        for i = loop_start, loop_end do
            local skillId = GetSlotBoundId(i, HOTBAR_CATEGORY_CHAMPION)
            local skillName = zo_strformat("<<C:1>>", GetChampionSkillName(skillId))
            local abilityData = {
                ['abilityId'] = skillId,
                ['abilityName'] = skillName
            }

            local indexCP = #addon.assignedCP[index] + 1
            addon.assignedCP[index][indexCP] = abilityData
        end

    end
end

function NEAR_EC.ClearAssigned()
    addon.assignedCP = nil
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------

NEAR_EC.events = {}

function NEAR_EC.events.register()
    EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_CHAMPION_PURCHASE_RESULT, addon.UpdateControl)

	addon.events.menu(true)
	addon.events.combat(true)
end

---Un/RegisterForEvent EVENT_PLAYER_COMBAT_STATE
---@param init boolean|nil --OnAddonLoaded Init
function NEAR_EC.events.combat(init)
    local sv = addon.ASV

    if sv.hide.inCombat then
        EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_PLAYER_COMBAT_STATE, addon.OnCombatState)
    elseif not init then
        EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_PLAYER_COMBAT_STATE)
    end
end

---Un/RegisterForEvent EVENT_RETICLE_HIDDEN_UPDATE
---@param init boolean|nil --OnAddonLoaded Init
function NEAR_EC.events.menu(init)
    local sv = addon.ASV

    if sv.hide.inMenu then
        EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_RETICLE_HIDDEN_UPDATE, addon.OnGuiUpdate)
    elseif not init then
        EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_RETICLE_HIDDEN_UPDATE)
        if NEC_GUI:IsHidden() then
            NEC_GUI:SetHidden(false)
        end
    end
end
