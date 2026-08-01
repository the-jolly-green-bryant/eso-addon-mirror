local KD = KyzderpsDerps
local Spud = KD.AntiSpud

---------------------------------------------------------------------
---------------------------------------------------------------------
local function CheckSkills()
    local hasProblems = false

    -- Check class masteries
    if (Spud.IsCurrentStateEnabledInSetting(KD.savedOptions.antispud.skills.classMastery)) then
        local isPure = SKILLS_DATA_MANAGER:GetNumPlayerClassActiveSkillLines() == SKILLS_DATA_MANAGER:GetNumActiveClassSkillLines()
        if (isPure) then
            for skillLineIndex = 1, GetNumSkillLines(SKILL_TYPE_CLASS) do
                local _, _, isActive = GetSkillLineDynamicInfo(SKILL_TYPE_CLASS, skillLineIndex)
                local skillLineId = GetSkillLineId(SKILL_TYPE_CLASS, skillLineIndex)
                if (isActive and IsClassMasterySkillLine(skillLineId)) then
                    -- current active class mastery line
                    -- nb: 356
                    local skillLineData = SKILLS_DATA_MANAGER:GetActiveClassMasterySkillLine(1)
                    if (skillLineData) then
                        local available = SKILL_POINT_ALLOCATION_MANAGER:GetAvailableClassMasteryPointsForSkillLine(skillLineData)
                        if (available > 0) then
                            local className = GetClassName(GetUnitGender("player"), GetUnitClassId("player"))
                            Spud.Display(zo_strformat("You are a pure <<1>> but you have\n<<2>> unallocated class mastery point<<3>>",
                                    className, available, available == 1 and "" or "s"), Spud.SKILLS)
                            hasProblems = true
                        end
                    end
                    break
                end
            end
        end
    end

    if (not hasProblems) then
        Spud.Display(nil, Spud.SKILLS)
    end
end
Spud.CheckSkills = CheckSkills


---------------------------------------------------------------------
---------------------------------------------------------------------
local function OnSpudStateChanged(oldState, newState)
    CheckSkills()
end


---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function Spud.InitializeSkills()
    KyzderpsDerps:dbg("    Initializing AntiSpud Skills...")

    Spud.Display(nil, Spud.SKILLS)

    Spud.RegisterStateListener("Skills", OnSpudStateChanged)

    EVENT_MANAGER:RegisterForEvent(KD.name .. "AntiSpudSkills", EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, CheckSkills)
    EVENT_MANAGER:RegisterForEvent(KD.name .. "AntiSpudSkillsWW", EVENT_WEREWOLF_STATE_CHANGED, CheckSkills)
    EVENT_MANAGER:RegisterForEvent(KD.name .. "AntiSpudSkillsUpdated", EVENT_SKILLS_FULL_UPDATE, CheckSkills)
    CheckSkills()
end
