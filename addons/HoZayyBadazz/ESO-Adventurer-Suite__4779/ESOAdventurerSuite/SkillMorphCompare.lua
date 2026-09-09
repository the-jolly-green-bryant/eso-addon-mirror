local EPC = ESOProgressionCoach
if not EPC then return end

local M = EPC.SkillMorphCompare or {}
EPC.SkillMorphCompare = M

-- v0.29.468: this module is intentionally hard-disabled against ESO's native
-- Skills controls at load time, not only after Initialize(). Keeping the flag
-- established immediately lets diagnostics prove the secure barrier is active
-- even when the module initializer has not run yet.
M.disabledForSecureSkills029453 = true

local unpackFn = unpack or table.unpack

local function safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a,b,c,d,e,f,g,h = pcall(fn, ...)
    if not ok then return fallback end
    return a,b,c,d,e,f,g,h
end

local function clearAlternate()
    local tip = rawget(_G, "EASAlternateMorphTooltip")
    if tip and type(ClearTooltip) == "function" then pcall(ClearTooltip, tip) end
    local top = rawget(_G, "EASAlternateMorphTooltipTopLevel")
    if top and type(top.SetHidden) == "function" then top:SetHidden(true) end
end

local function resolveSkillIndices(...)
    if type(GetSkillAbilityInfo) ~= "function" then return nil end
    local nums = {}
    for i=1,select("#", ...) do
        local v = select(i,...)
        if type(v)=="number" then nums[#nums+1]=v end
    end
    for i=1,math.max(0,#nums-2) do
        local skillType, lineIndex, skillIndex = nums[i], nums[i+1], nums[i+2]
        if skillType >= 1 and skillType <= 20 and lineIndex >= 1 and lineIndex <= 100 and skillIndex >= 1 and skillIndex <= 100 then
            local _,_,_,passive,_,_,progressionIndex,rank = safe(GetSkillAbilityInfo,nil,skillType,lineIndex,skillIndex)
            progressionIndex = tonumber((progressionIndex))
            if progressionIndex and progressionIndex > 0 then
                return skillType,lineIndex,skillIndex,passive==true,progressionIndex,tonumber((rank)) or 1
            end
        end
    end
    return nil
end

function M:ShowForSkillTooltipCall(primary, ...)
    clearAlternate()
    local _,_,_,passive,progressionIndex,rank = resolveSkillIndices(...)
    if passive or not progressionIndex then return end

    local _, morphChoice, currentRank = safe(GetAbilityProgressionInfo,nil,progressionIndex)
    morphChoice = tonumber((morphChoice)) or (rawget(_G,"MORPH_SLOT_BASE") or 0)
    rank = tonumber((currentRank)) or tonumber((rank)) or 1
    local m1 = rawget(_G,"MORPH_SLOT_MORPH_1") or 1
    local m2 = rawget(_G,"MORPH_SLOT_MORPH_2") or 2
    local alternate
    if morphChoice == m1 then alternate = m2
    elseif morphChoice == m2 then alternate = m1
    else return end

    local tip = rawget(_G,"EASAlternateMorphTooltip")
    local top = rawget(_G,"EASAlternateMorphTooltipTopLevel")
    if not tip or not primary or type(tip.SetProgressionAbility)~="function" or type(InitializeTooltip)~="function" then return end

    InitializeTooltip(tip, primary, TOPRIGHT, -8, 0, TOPLEFT)
    local ok = pcall(tip.SetProgressionAbility, tip, progressionIndex, alternate, rank)
    if not ok then clearAlternate(); return end
    if top and type(top.SetHidden)=="function" then top:SetHidden(false) end
end

function M:HookTooltipObject(name)
    -- v0.29.450: deliberately disabled. Post-hooking native Skills tooltip/slot
    -- methods can taint the protected skill-drag path that ultimately calls
    -- PickupAbilityById. Morph comparison now uses a read-only mouseover poll.
    return false
end

function M:InstallHooks()
    return false
end



-- 0.29.384: direct keyboard/PerfectPixel skill-row hover support.
-- PerfectPixel still routes through ESO's keyboard skill-slot mouse-enter handler,
-- but it can bypass the tooltip method that older versions of this module hooked.
local function getControlSkillIndices029384(control)
    if not control then return nil end

    local skillType = tonumber(control.skillType)
    local lineIndex = tonumber(control.lineIndex or control.skillLineIndex)
    local skillIndex = tonumber(control.index or control.skillIndex)

    -- Newer keyboard rows often keep the model on the slot/parent control.
    local data = control.data or control.skillData
    if type(data) == "table" then
        skillType = skillType or tonumber(data.skillType)
        lineIndex = lineIndex or tonumber(data.lineIndex or data.skillLineIndex)
        skillIndex = skillIndex or tonumber(data.index or data.skillIndex)
    end

    local parent = type(control.GetParent) == "function" and control:GetParent() or nil
    if parent then
        skillType = skillType or tonumber(parent.skillType)
        lineIndex = lineIndex or tonumber(parent.lineIndex or parent.skillLineIndex)
        skillIndex = skillIndex or tonumber(parent.index or parent.skillIndex)
        local pd = parent.data or parent.skillData
        if type(pd) == "table" then
            skillType = skillType or tonumber(pd.skillType)
            lineIndex = lineIndex or tonumber(pd.lineIndex or pd.skillLineIndex)
            skillIndex = skillIndex or tonumber(pd.index or pd.skillIndex)
        end
    end

    if not skillType or not lineIndex or not skillIndex then return nil end
    return skillType, lineIndex, skillIndex
end

local function getProgressionFromControl029384(control)
    local skillType, lineIndex, skillIndex = getControlSkillIndices029384(control)
    if not skillType then return nil end

    -- Prefer the modern direct progression API when available.
    local progressionIndex
    if type(GetProgressionSkillProgressionIndex) == "function" then
        progressionIndex = tonumber((safe(GetProgressionSkillProgressionIndex, nil, skillType, lineIndex, skillIndex)))
    end

    -- Stock skill API fallback. Also lets us reject passives/crafted entries cleanly.
    local passive = false
    local abilityId = 0
    if type(GetSkillAbilityInfo) == "function" then
        local _,_,_,isPassive,_,_,pi = safe(GetSkillAbilityInfo,nil,skillType,lineIndex,skillIndex)
        passive = isPassive == true
        progressionIndex = progressionIndex or tonumber((pi))
    end
    if passive then return nil end

    if type(GetSkillAbilityId) == "function" then
        abilityId = tonumber((safe(GetSkillAbilityId,0,skillType,lineIndex,skillIndex))) or 0
    end
    if (not progressionIndex or progressionIndex <= 0) and abilityId > 0 and type(GetAbilityProgressionXPInfoFromAbilityId) == "function" then
        local hasProgression, pi = safe(GetAbilityProgressionXPInfoFromAbilityId,false,abilityId)
        if hasProgression then progressionIndex = tonumber((pi)) end
    end

    if not progressionIndex or progressionIndex <= 0 then return nil end
    return progressionIndex
end

function M:ShowForSkillControl029384(control)
    clearAlternate()
    if not control then return end

    -- 0.29.385: use ESO's native skill data object directly.
    -- Current keyboard Skills assigns skillProgressionData to the actual slot
    -- before ZO_Skills_AbilitySlot_OnMouseEnter runs. PerfectPixel preserves
    -- that object even when it changes the surrounding row/layout.
    local current = control.skillProgressionData
    if type(current) ~= "table" then return end

    local skillData = current.skillData
    if type(current.GetSkillData) == "function" then
        local ok, value = pcall(current.GetSkillData, current)
        if ok and value then skillData = value end
    end
    if type(skillData) ~= "table" then return end

    local isPassive = false
    if type(skillData.IsPassive) == "function" then
        local ok, value = pcall(skillData.IsPassive, skillData)
        if ok then isPassive = value == true end
    end
    if isPassive then return end

    local currentMorph
    if type(current.GetMorphSlot) == "function" then
        local ok, value = pcall(current.GetMorphSlot, current)
        if ok then currentMorph = tonumber(value) end
    end
    if not currentMorph and type(skillData.GetPointAllocator) == "function" then
        local ok, allocator = pcall(skillData.GetPointAllocator, skillData)
        if ok and allocator and type(allocator.GetMorphSlot) == "function" then
            local ok2, value = pcall(allocator.GetMorphSlot, allocator)
            if ok2 then currentMorph = tonumber(value) end
        end
    end

    local m1 = rawget(_G, "MORPH_SLOT_MORPH_1") or 1
    local m2 = rawget(_G, "MORPH_SLOT_MORPH_2") or 2
    local alternateMorph
    if currentMorph == m1 then
        alternateMorph = m2
    elseif currentMorph == m2 then
        alternateMorph = m1
    else
        -- Base/unmorphed skills do not have an "other chosen morph" yet.
        return
    end

    if type(skillData.GetMorphData) ~= "function" then return end
    local okAlt, alternate = pcall(skillData.GetMorphData, skillData, alternateMorph)
    if not okAlt or type(alternate) ~= "table" then return end

    local tip = rawget(_G, "EASAlternateMorphTooltip")
    local top = rawget(_G, "EASAlternateMorphTooltipTopLevel")
    if not tip or type(InitializeTooltip) ~= "function" then return end

    -- 0.29.386: place the comparison on the side of the native tooltip that
    -- has room. PerfectPixel can resize/reanchor SkillTooltip, so a fixed
    -- TOPLEFT->TOPRIGHT anchor can overlap it. Use its real screen bounds and
    -- choose the opposite side, with a 16px gap.
    local primary = rawget(_G, "SkillTooltip")
    local owner = primary or control
    local point, relPoint, offsetX = TOPLEFT, TOPRIGHT, 16

    if primary and type(primary.GetLeft) == "function" and type(primary.GetRight) == "function" then
        local okL, left = pcall(primary.GetLeft, primary)
        local okR, right = pcall(primary.GetRight, primary)
        local screenW = 0
        if GuiRoot and type(GuiRoot.GetWidth) == "function" then
            local okW, w = pcall(GuiRoot.GetWidth, GuiRoot)
            if okW then screenW = tonumber(w) or 0 end
        end

        left = okL and tonumber(left) or nil
        right = okR and tonumber(right) or nil
        if left and right and screenW > 0 then
            local freeLeft = left
            local freeRight = screenW - right
            -- The alternate tooltip is 384px wide. Prefer the side that can
            -- fully contain it; otherwise use the side with more room.
            local needed = 400
            if freeRight >= needed then
                point, relPoint, offsetX = TOPLEFT, TOPRIGHT, 16
            elseif freeLeft >= needed then
                point, relPoint, offsetX = TOPRIGHT, TOPLEFT, -16
            elseif freeLeft > freeRight then
                point, relPoint, offsetX = TOPRIGHT, TOPLEFT, -16
            else
                point, relPoint, offsetX = TOPLEFT, TOPRIGHT, 16
            end
        end
    end

    local okInit = pcall(InitializeTooltip, tip, owner, point, offsetX, 0, relPoint)
    if not okInit then return end

    -- Let ESO's own progression object render the complete localized tooltip.
    -- This is the same data path the stock Skills menu uses for the current morph.
    local rendered = false
    if type(alternate.SetKeyboardTooltip) == "function" then
        local SHOW_SKILL_POINT_COST = false
        local DONT_SHOW_UPGRADE_TEXT = false
        local DONT_SHOW_ADVISED = false
        local SHOW_BAD_MORPH = true
        local ok = pcall(alternate.SetKeyboardTooltip, alternate, tip,
            SHOW_SKILL_POINT_COST, DONT_SHOW_UPGRADE_TEXT, DONT_SHOW_ADVISED, SHOW_BAD_MORPH)
        rendered = ok
    end

    -- Compatibility fallback for older API objects.
    if not rendered and type(tip.SetProgressionAbility) == "function" then
        local progressionIndex
        if type(GetAbilityProgressionXPInfoFromAbilityId) == "function" and type(alternate.GetAbilityId) == "function" then
            local okId, abilityId = pcall(alternate.GetAbilityId, alternate)
            if okId and tonumber(abilityId) and tonumber(abilityId) > 0 then
                local has, pi = safe(GetAbilityProgressionXPInfoFromAbilityId, false, tonumber(abilityId))
                if has then progressionIndex = tonumber(pi) end
            end
        end
        if progressionIndex then
            local rank = 1
            if type(alternate.GetCurrentRank) == "function" then
                local okRank, r = pcall(alternate.GetCurrentRank, alternate)
                if okRank then rank = tonumber(r) or 1 end
            end
            rendered = pcall(tip.SetProgressionAbility, tip, progressionIndex, alternateMorph, rank)
        end
    end

    if not rendered then
        clearAlternate()
        return
    end
    if top and type(top.SetHidden) == "function" then top:SetHidden(false) end
end

function M:InstallDirectSkillHover029384()
    -- v0.29.450: retained as a compatibility no-op. Never post-hook
    -- ZO_Skills_AbilitySlot_OnMouseEnter/Exit because that taints ESO's
    -- protected drag handler and can block PickupAbilityById.
    return false
end

local function findHoveredSkillControl029450()
    if not WINDOW_MANAGER or type(WINDOW_MANAGER.GetMouseOverControl) ~= "function" then return nil end
    local ok, control = pcall(WINDOW_MANAGER.GetMouseOverControl, WINDOW_MANAGER)
    if not ok then return nil end
    local depth = 0
    while control and depth < 6 do
        if type(control.skillProgressionData) == "table" then return control end
        if type(control.GetParent) ~= "function" then break end
        local okParent, parent = pcall(control.GetParent, control)
        if not okParent or parent == control then break end
        control = parent
        depth = depth + 1
    end
    return nil
end

function M:PollSkillHover029450()
    -- v0.29.468: secure hard barrier. This compatibility entry point remains
    -- callable, but it deliberately does not inspect ESO native Skills controls.
    self.disabledForSecureSkills029453 = true
    self.lastHoverControl029450 = nil
    clearAlternate()
    return false
end

function M:SetPolling029450(enabled)
    -- v0.29.468: secure hard barrier. Never register a Skills mouseover poll.
    local key = (EPC.name or "ESOAdventurerSuite") .. "_SkillMorphHover029450"
    if EVENT_MANAGER and type(EVENT_MANAGER.UnregisterForUpdate) == "function" then
        EVENT_MANAGER:UnregisterForUpdate(key)
    end
    self.lastHoverControl029450 = nil
    clearAlternate()
    self.disabledForSecureSkills029453 = true
    return false
end

function M:Initialize()
    if self.baseInitialized then return end
    self.baseInitialized = true

    -- v0.29.453: HARD TAINT BARRIER.
    -- Do not register callbacks on the native Skills scenes, do not poll native
    -- Skills controls, and do not inspect native skillProgressionData objects.
    -- ESO's ZO_Skills_AbilitySlot_OnDragStart -> TryPickup -> PickupAbilityById
    -- path must remain completely untouched by Suite code.
    local key = (EPC.name or "ESOAdventurerSuite") .. "_SkillMorphHover029450"
    if EVENT_MANAGER and type(EVENT_MANAGER.UnregisterForUpdate) == "function" then
        EVENT_MANAGER:UnregisterForUpdate(key)
    end
    self.lastHoverControl029450 = nil
    clearAlternate()
    self.disabledForSecureSkills029453 = true
end
