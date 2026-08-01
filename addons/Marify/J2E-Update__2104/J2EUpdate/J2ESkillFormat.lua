
J2EUpdate.originGetUnitBuffInfo = GetUnitBuffInfo




function J2EUpdate.CustomisedGetUnitBuffInfo(unitTag, buffIndex)
    local buffName,
          timeStarted,
          timeEnding,
          buffSlot,
          stackCount,
          iconFilename,
          buffType,
          effectType,
          abilityType,
          statusEffectType,
          abilityId,
          canClickOff,
          castByPlayer = J2EUpdate.originGetUnitBuffInfo(unitTag, buffIndex)

    local txt = J2EUpdate:GetSkillName(abilityId)
    if txt then
        buffName = zo_strformat("<<1>> (<<2>>)", buffName, txt)
    end

    return buffName,
           timeStarted,
           timeEnding,
           buffSlot,
           stackCount,
           iconFilename,
           buffType,
           effectType,
           abilityType,
           statusEffectType,
           abilityId,
           canClickOff,
           castByPlayer
end




function J2EUpdate:AddCpSkillName(parent)

    if (not self.savedVariables.showSkillNameBottom) then
        self:ResetCachedSkillFormat()
        return
    end
    if parent == nil then
        return
    end
    local skillData  = parent:GetChampionSkillData()
    if skillData == nil then
        return
    end
    self:Debug("　　[AddCpSkillName]")


    local abilityId  = skillData:GetAbilityId()
    local nameBefore = ZO_CachedStrFormat(SI_CHAMPION_STAR_NAME, skillData:GetRawName())
    local nameAfter  = self:GetSkillName(abilityId)
    self:Debug(zo_strformat("　　　　cpSkillName=<<1>>:\"<<2>>\" > \"<<3>>\"", abilityId,
                                                                               nameBefore,
                                                                               nameAfter))
    if nameAfter then
        --if self.savedVariables.isCollectingData then
        --    self.savedVariables.newSkillTable[abilityId] = nil
        --end

        local txt = zo_strformat(GetString(J2E_FORMAT_NAME), nameAfter)
        ChampionSkillTooltip:AddLine(txt, "", 0.8, 0.8, 0.8, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)

    --elseif self.savedVariables.isCollectingData then
    --    self.savedVariables.newSkillTable[abilityId] = nameBefore
    --    self:DebugIfMarify("New Skill " .. tostring(abilityId) .. ":" .. tostring(nameBefore), self.failedColor)
    end
end




function J2EUpdate:AddSkillName(progressionData, tooltip)

    if (not self.savedVariables.showSkillNameBottom) then
        self:ResetCachedSkillFormat()
        return
    end
    self:Debug("　　[AddSkillName]")


    local abilityId  = progressionData.abilityId
    local nameBefore = progressionData:GetName()
    local nameAfter  = self:GetSkillName(abilityId)
    self:Debug(zo_strformat("　　　　cpSkillName=<<1>>:\"<<2>>\" > \"<<3>>\"", abilityId,
                                                                               nameBefore,
                                                                               nameAfter))
    if nameAfter then
        --if self.savedVariables.isCollectingData then
        --    self.savedVariables.newSkillTable[abilityId] = nil
        --end

        local txt = zo_strformat(GetString(J2E_FORMAT_NAME), nameAfter)
        tooltip:AddLine(txt, "", 0.8, 0.8, 0.8, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)

    --elseif self.savedVariables.isCollectingData then
    --    self.savedVariables.newSkillTable[abilityId] = nameBefore
    --    self:DebugIfMarify("New Skill " .. tostring(abilityId) .. ":" .. tostring(nameBefore), self.failedColor)
    end
end




function J2EUpdate:GetSkillLineName(skillLineId)

    local name = self.savedVariables.skillLineTable[skillLineId]
    local defName = self.defaultSkillLineTable[skillLineId]
    if name then
        if defName and defName == name then
            self.savedVariables.skillLineTable[skillLineId] = nil
        end
        return name
    elseif defName then
        return defName
    end

    return nil
end




function J2EUpdate:GetSkillName(abilityId)

    --self:Debug("　　　　[GetSkillName(" .. tostring(abilityId) .. ")]")
    local name = self.savedVariables.skillTable[abilityId]
    local defName = self.defaultSkillTable[abilityId]
    if name then
        if defName and defName == name then
            self.savedVariables.skillTable[abilityId] = nil
        end
        return name
    elseif defName then
        return defName
    end

    return nil
end




function J2EUpdate:ResetCachedSkillFormat()
    self:Debug("　　[ResetCachedSkillFormat]", self.disabledColor)

    self:ResetString(SI_ABILITY_NAME)
    self:ResetString(SI_ABILITY_NAME_AND_RANK)
    self:ResetString(SI_ABILITY_TOOLTIP_NAME)


    self:ResetString(SI_CHAMPION_CLUSTER_NAME)
    ZO_ResetCachedStrFormat(SI_CHAMPION_CLUSTER_NAME)

    self:ResetString(SI_CHAMPION_STAR_NAME)
    ZO_ResetCachedStrFormat(SI_CHAMPION_STAR_NAME)

    self:ResetString(SI_CHAMPION_CONSTELLATION_NAME_FORMAT)
    ZO_ResetCachedStrFormat(SI_CHAMPION_CONSTELLATION_NAME_FORMAT)


    if IsInGamepadPreferredMode() then
        ZO_ResetCachedStrFormat(SI_GAMEPAD_ABILITY_NAME_AND_UPGRADE_LEVELS)
        self:ResetString(SI_GAMEPAD_ABILITY_NAME_AND_UPGRADE_LEVELS)
    else
        ZO_ResetCachedStrFormat(SI_ABILITY_NAME_AND_UPGRADE_LEVELS)
        self:ResetString(SI_ABILITY_NAME_AND_UPGRADE_LEVELS)
    end


    if self.savedVariables.showSkillName or self.savedVariables.showSkillNameBottom then
        GetUnitBuffInfo = self.CustomisedGetUnitBuffInfo
    else
        GetUnitBuffInfo = self.originGetUnitBuffInfo
    end
end




function J2EUpdate:SetClusterFormat(championClusterData)

    if (not self.savedVariables.showSkillName) and (not self.savedVariables.showSkillNameBottom) then
        return
    end
    self:Debug("　　[SetClusterFormat]")


    local skillData = championClusterData.rootChampionSkillData
    local rootCpSkillId = skillData:GetId()
    local nameBefore = GetChampionClusterName(rootCpSkillId)
    local nameAfter  = self:GetSkillName(rootCpSkillId) -- Very illegal !!!
    self:Debug(zo_strformat("　　　　cpSkillName=<<1>>:\"<<2>>\" > \"<<3>>\"", rootCpSkillId,
                                                                               nameBefore,
                                                                               nameAfter))
    if nameAfter then
        --if self.savedVariables.isCollectingData then
        --    self.savedVariables.newSkillTable[rootCpSkillId] = nil
        --end

        local txt = zo_strformat("|c<<1>>(<<2>>)|r", self.txtColor, nameAfter)
        self:UpdateString(SI_CHAMPION_CLUSTER_NAME, "<<1>>" .. txt)

        ZO_ResetCachedStrFormat(SI_CHAMPION_CLUSTER_NAME)
        local result = ZO_CachedStrFormat(SI_CHAMPION_CLUSTER_NAME, nameBefore)
        self:Debug("　　　　> \"" .. tostring(result) .. "\"")

    --elseif self.savedVariables.isCollectingData then
    --    self.savedVariables.newSkillTable[rootCpSkillId] = nameBefore
    --    self:DebugIfMarify("New Cluster " .. tostring(rootCpSkillId) .. ":" .. tostring(nameBefore), self.failedColor)
    end
end




function J2EUpdate:SetCpSkillFormat(parent)

    if (not self.savedVariables.showSkillName) then
        return
    end
    self:Debug("　　[SetCpSkillFormat]")


    local skillData   = parent:GetChampionSkillData()
    if skillData == nil then
        self:Debug("　　　　>No skillData")
        return
    end
    local abilityId  = skillData:GetAbilityId()
    local nameBefore = ZO_CachedStrFormat(SI_CHAMPION_STAR_NAME, skillData:GetRawName())
    local nameAfter  = self:GetSkillName(abilityId)
    self:Debug(zo_strformat("　　　　cpSkillName=<<1>>:\"<<2>>\" > \"<<3>>\"", abilityId,
                                                                               nameBefore,
                                                                               nameAfter))
    if nameAfter then
        --if self.savedVariables.isCollectingData then
        --    self.savedVariables.newSkillTable[abilityId] = nil
        --end

        local txt = zo_strformat("\n|c<<1>>(<<2>>)|r", self.txtColor, nameAfter)
        self:UpdateString(SI_ABILITY_TOOLTIP_NAME, "<<1>>" .. txt)

        ZO_ResetCachedStrFormat(SI_ABILITY_TOOLTIP_NAME)
        local result = ZO_CachedStrFormat(SI_ABILITY_TOOLTIP_NAME, skillData:GetRawName())
        self:Debug("　　　　> \"" .. tostring(string.gsub(result, "\n", "")) .. "\"")

    --elseif self.savedVariables.isCollectingData then
    --    self.savedVariables.newSkillTable[abilityId] = nameBefore
    --    self:DebugIfMarify("New Skill " .. tostring(abilityId) .. ":" .. tostring(nameBefore), self.failedColor)
    end
end




function J2EUpdate:SetDisciplineFormat(disciplineData)

    if (not self.savedVariables.showSkillName) and (not self.savedVariables.showSkillNameBottom) then
        return
    end
    self:Debug("　　[SetDisciplineFormat]")


    local disciplineId = disciplineData:GetId()
    local nameBefore = GetChampionDisciplineName(disciplineId)
    local nameAfter  = GetString("J2E_CP_DISCIPLINE", disciplineId)
    self:Debug(zo_strformat("　　　　disciplineName=<<1>>:\"<<2>>\" > \"<<3>>\"", disciplineId,
                                                                                  nameBefore,
                                                                                  nameAfter))

    local txt = zo_strformat("|c<<1>>(<<2>>)|r", self.txtColor, nameAfter)
    self:UpdateString(SI_CHAMPION_CONSTELLATION_NAME_FORMAT, "<<1>>" .. txt)

    ZO_ResetCachedStrFormat(SI_CHAMPION_CONSTELLATION_NAME_FORMAT)
    local result = ZO_CachedStrFormat(SI_CHAMPION_CONSTELLATION_NAME_FORMAT, GetChampionDisciplineName(disciplineId))
    self:Debug("　　　　> \"" .. tostring(result) .. "\"")
end




function J2EUpdate:SetSkillFormat(progressionData, isTooltip)

    if (not self.savedVariables.showSkillName) then
        return
    end


    self:Debug("　　[SetSkillFormat(" .. tostring(isTooltip) .. ")]:" .. progressionData:GetName())
    if progressionData == nil or progressionData == "" then
        self:Debug("　　　　>No progressionData")
        return
    end


    local skillName = self:GetSkillName(progressionData.abilityId)
    if skillName then
        --self:Debug(progressionData:GetName() .. "(" .. tostring(isTooltip) .. ")")
        local skillData = progressionData:GetSkillData()

        local targetSkillData
        if GAMEPAD_SKILLS and GAMEPAD_SKILLS.lineFilterList and GAMEPAD_SKILLS.lineFilterList:GetTargetData() then
            targetSkillData = GAMEPAD_SKILLS.lineFilterList:GetTargetData().skillData
            --if targetSkillData then
            --    self:Debug("　　targetSkillData=" .. tostring(targetSkillData), "7cfc00")
            --    self:Debug("　　skillData=" .. tostring(skillData), "7cfc00")
            --end
        end


        local txt
        if isTooltip then
            --self:Debug("　　isTooltip")
            txt = zo_strformat("|c<<1>>(<<2>>)|r", self.txtColor, skillName)

        elseif skillData:GetPointAllocator():IsPurchased() then
            --self:Debug("　　IsPurchased")
            txt = zo_strformat("|c<<1>>(<<2>>)|r", self.txtColor, skillName)

        elseif targetSkillData and targetSkillData == skillData then
            --self:Debug("　　IsTarget")
            txt = zo_strformat("|c<<1>>(<<2>>)|r", self.txtColor, skillName)

        else
            --self:Debug("　　not Color")
            txt = zo_strformat("(<<1>>)", skillName)
        end


        local lineBreak
        if isTooltip then
            --self:Debug("　　isBreak")
            lineBreak = "\n"
        elseif IsInGamepadPreferredMode() and GAMEPAD_SKILLS.mode == ZO_GAMEPAD_SKILLS_ABILITY_LIST_BROWSE_MODE then
            --self:Debug("　　isBreak")
            lineBreak = "\n"
        else
            --self:Debug("　　not Break")
            lineBreak = " "
        end
        txt = lineBreak .. txt


        if progressionData:IsActive() and progressionData:HasRankData() then
            -- Active with Rank
            self:Debug("　　[SetSkillFormat(" .. tostring(isTooltip) .. ")] Active with Rank:" .. progressionData:GetName())
            self:UpdateString(SI_ABILITY_NAME_AND_RANK, "<<1>> <<2>>" .. txt)

        elseif isTooltip and not(skillData:GetPointAllocator():IsPurchased()) and IsInGamepadPreferredMode() then
            -- Tooltip(Not Purchased:GAME_PAD)
            self:Debug("　　[SetSkillFormat(" .. tostring(isTooltip) .. ")] Tooltip(Not Purchased:GAME_PAD):" .. progressionData:GetName())
            self:UpdateString(SI_ABILITY_NAME_AND_RANK, "<<1>> <<2>>" .. txt)

        elseif isTooltip and not(skillData:GetPointAllocator():IsPurchased()) then
            -- Tooltip(Not Purchased:KEYBOARD)
            self:Debug("[SetSkillFormat(" .. tostring(isTooltip) .. ")] Tooltip(Not Purchased:KEYBOARD):" .. progressionData:GetName())
            self:UpdateString(SI_ABILITY_TOOLTIP_NAME, "<<1>>" .. txt)

        elseif isTooltip and progressionData:IsPassive() and IsInGamepadPreferredMode() then
            -- Tooltip(Passive:GAME_PAD)
            self:Debug("　　[SetSkillFormat(" .. tostring(isTooltip) .. ")] Tooltip(Passive:GAME_PAD):" .. progressionData:GetName())
            self:UpdateString(SI_ABILITY_NAME_AND_RANK, "<<1>> <<2>>" .. txt)

        elseif isTooltip and progressionData:IsPassive() then
            -- Tooltip(Passive:KEYBOARD)
            self:Debug("　　[SetSkillFormat(" .. tostring(isTooltip) .. ")] Tooltip(Passive):" .. progressionData:GetName())
            self:UpdateString(SI_ABILITY_TOOLTIP_NAME, "<<1>>" .. txt)

        elseif progressionData:IsPassive() and skillData:GetNumRanks() > 1  and IsInGamepadPreferredMode() then
            -- Passive with Levels(GAME_PAD)
            self:Debug("　　[SetSkillFormat(" .. tostring(isTooltip) .. ")] Passive with Levels(GAME_PAD):" .. progressionData:GetName())
            self:UpdateString(SI_GAMEPAD_ABILITY_NAME_AND_UPGRADE_LEVELS, "(|cffffff<<2>>/<<3>>|r) <<1>>" .. txt)

        elseif progressionData:IsPassive() and skillData:GetNumRanks() > 1 then
            -- Passive with Levels(KEYBOARD)
            self:Debug("　　[SetSkillFormat(" .. tostring(isTooltip) .. ")] Passive with Levels(KEYBOARD):" .. progressionData:GetName())
            self:UpdateString(SI_ABILITY_NAME_AND_UPGRADE_LEVELS, "<<1>> (<<2>> / <<3>>)" .. txt)

        else
            -- Else
            self:Debug("　　[SetSkillFormat(" .. tostring(isTooltip) .. ")] Else:" .. progressionData:GetName())
            self:UpdateString(SI_ABILITY_NAME, "<<1>>" .. txt)
        end
    else
        self:DebugIfMarify("No Data(SetSkillFormat):" .. tostring(progressionData.abilityId)
                                               .. ":" .. tostring(progressionData:GetName()), self.failedColor)
    end

end




function J2EUpdate:SetSkillLineName()

    if (not self.savedVariables.showSkillName) then
        return
    end
    self:Debug("　　[SetSkillLineName]")
    --self:ResetCachedSkillFormat()


    local lineBreak = IsInGamepadPreferredMode() and "\n" or " "
    local skillLineName
    local txt
    for _, skillTypeData in SKILLS_DATA_MANAGER:SkillTypeIterator() do
        --self:Debug("　　" .. tostring(skillTypeData:GetSkillType()) .. ":" .. tostring(skillTypeData:GetName()))
        for _, skillLineData in skillTypeData:SkillLineIterator() do
            if skillLineData:IsAvailable() or skillLineData:IsAdvised() then

                skillLineName = GetSkillLineName(GetSkillLineIndicesFromSkillLineId(skillLineData:GetId()))
                txt = self:GetSkillLineName(skillLineData:GetId())
                if txt and selectedSkillLineData and selectedSkillLineData == skillLineData then
                    skillLineName = zo_strformat("<<1>><<2>>|c<<4>>(<<3>>)|r", skillLineName, lineBreak, txt, self.txtColor)
                elseif txt then
                    skillLineName = zo_strformat("<<1>><<2>>(<<3>>)",          skillLineName, lineBreak, txt)
                end
                --self:Debug("　　　　" .. tostring(skillLineData:GetId()) .. ":" .. tostring(skillLineName:gsub("\n", "")))
                skillLineData.name = skillLineName
            end
        end
    end
end




function J2EUpdate:SetStarFormat(skillData)

    if (not self.savedVariables.showSkillName) and (not self.savedVariables.showSkillNameBottom) then
        return
    end
    self:Debug("　　[SetStarFormat]")


    local abilityId   = skillData:GetAbilityId()
    local nameBefore = ZO_CachedStrFormat(SI_CHAMPION_STAR_NAME, skillData:GetRawName())
    local nameAfter  = self:GetSkillName(abilityId)
    self:Debug(zo_strformat("　　　　cpSkillName=<<1>>:\"<<2>>\" > \"<<3>>\"", abilityId,
                                                                               nameBefore,
                                                                               nameAfter))
    if nameAfter then
        --if self.savedVariables.isCollectingData then
        --    self.savedVariables.newSkillTable[abilityId] = nil
        --end

        local txt = zo_strformat("|c<<1>>(<<2>>)|r", self.txtColor, nameAfter)
        if IsInGamepadPreferredMode() then
            if string.len(nameBefore) + string.len(nameAfter) > 32 then
                txt = zo_strformat("\n|c<<1>>(<<2>>)|r", self.txtColor, nameAfter)
            end
        end
        self:UpdateString(SI_CHAMPION_STAR_NAME, "<<1>>" .. txt)

        ZO_ResetCachedStrFormat(SI_CHAMPION_STAR_NAME)
        local result = ZO_CachedStrFormat(SI_CHAMPION_STAR_NAME, skillData:GetRawName())
        self:Debug("　　　　> \"" .. tostring(string.gsub(result, "\n", "")) .. "\"")

    --elseif self.savedVariables.isCollectingData then
    --    self.savedVariables.newSkillTable[abilityId] = nameBefore
    --    self:DebugIfMarify("New Skill " .. tostring(abilityId) .. ":" .. tostring(nameBefore), self.failedColor)
    end
end




function J2EUpdate:ShowClusterStarName(star)

    if not self.savedVariables.showStarName then
        return
    end

    local data = star:GetChampionClusterData()
    if not data then
        return
    end

    self:Debug("　　[ShowClusterStarName]")
    local abilityId = data.rootChampionSkillData:GetId()
    self:ShowName(star, abilityId, data)
end




function J2EUpdate:ShowName(star, abilityId, data)

    if IsInGamepadPreferredMode() then
        return
    end


    self:Debug("　　　　[ShowName]" .. tostring(abilityId))

    local isActive  = star.active
    local labelName = abilityId .. "Name"
    local label = GetControl(J2EWindow, labelName)
    if label == nil and isActive then
        self:Debug("　　　　　　Create " .. tostring(labelName))
        label = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)" .. labelName,
                                                        J2EWindow,
                                                        "J2ELabelTemplate")
    elseif label == nil and (not isActive) then
        return
    elseif (not isActive) then
        self:Debug("　　　　　　>Hide")
        label:SetHidden(true)
        return
    end


    local starCenterX, _ = star.texture:GetCenter()
    label:ClearAnchors()
    local position = self.savedVariables.labelPositions[abilityId]
    if position == nil then
        position = self.defaultLabelPositions[abilityId]
    end
    self.savedVariables.labelPositions[abilityId] = position


    if position then
        local x, y = zo_strsplit(",", position)
        label:SetAnchor(TOPLEFT, J2EWindow, TOPLEFT, tonumber(x),
                                                     tonumber(y))
    else
        label:SetAnchor(TOPLEFT, J2EWindow, TOPLEFT, 0, 0)
    end


    if data["CanBePurchased"] and (not data:CanBePurchased()) then
        label:SetAlpha(0.5)
    else
        label:SetAlpha(1.0)
    end


    self:Debug("　　　　　　>Show")
    J2EWindow:SetHidden(false)
    local txt = data:GetFormattedName()
    label:SetText(txt)
    label:SetHidden(false)
end




function J2EUpdate:ShowStarName(star)

    if not self.savedVariables.showStarName then
        return
    end

    local data = star:GetChampionSkillData()
    if not data then
        return
    end

    self:Debug("　　[ShowStarName]")
    local abilityId = data:GetAbilityId()
    self:ShowName(star, abilityId, data)
end




function J2EUpdate:UpdateSkillTable()

    self:Debug("[UpdateSkillTable]")
    local size = 0
    for _, skillTypeData in SKILLS_DATA_MANAGER:SkillTypeIterator() do
        --self:Debug("skillType=" .. skillTypeData:GetSkillType() .. ":" .. skillTypeData:GetName())

        for _, skillLineData in skillTypeData:SkillLineIterator() do
            --self:Debug("　　skillLine=" .. skillLineData:GetSkillLineIndex()
            --             .. " " .. skillLineData:GetId() .. ":" .. skillLineData:GetName())
            local skillLineName = skillLineData:GetName():gsub("(\^)%a*", "")
            local defaultSkillLineName = self:GetSkillLineName(skillLineData:GetId())
            if (defaultSkillLineName == nil) or (defaultSkillLineName ~= skillLineName) then
                self.savedVariables.skillLineTable[skillLineData:GetId()] = skillLineName
                size = size + 1
            else
                self.savedVariables.skillLineTable[skillLineData:GetId()] = nil
            end


            for _, skillData in skillLineData:SkillIterator() do
                --self:Debug("　　　　skill=" .. skillData:GetSkillIndex() .. ", isPassive=" .. tostring(skillData:IsPassive()))

                for _, skillProgression in pairs(skillData.skillProgressions) do
                    --self:Debug("　　　　　　abilityId=" .. tostring(skillProgression.abilityId) .. ":" .. tostring(skillProgression.name))

                    local skillName = skillProgression.name:gsub("(\^)%a*", "")
                    local defaultSkillName = self:GetSkillName(skillProgression.abilityId)
                    if (defaultSkillName == nil) or (defaultSkillName ~= skillName) then
                        self.savedVariables.skillTable[skillProgression.abilityId] = skillName
                        size = size + 1
                    else
                        self.savedVariables.skillTable[skillProgression.abilityId] = nil
                    end
                end
            end
        end
    end


    if size > 0 then
        self:Message("Update " .. size .. " Skill name")
    end
    self.updateTotal = self.updateTotal + size
end

