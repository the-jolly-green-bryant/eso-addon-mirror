AST.Tracking = {}

T = AST.Tracking
local em = EVENT_MANAGER

function T.synergyCheck(eventCode, result, _, abilityName, _, _, _, sourceType, _, targetType, _, _, _, _, sourceUnitId, targetUnitId, abilityId)
    local start = GetFrameTimeSeconds()

    if (sourceType == COMBAT_UNIT_TYPE_PLAYER or sourceType == COMBAT_UNIT_TYPE_GROUP) and AST.SV.trackerui then
        if AST.Data.SynergyData[abilityId].group == 1 then
            if result == 2240 then AST.Data.TrackerTimer[1] = start + AST.Data.SynergyData[abilityId].cooldown end
        else
            AST.Data.TrackerTimer[AST.Data.SynergyData[abilityId].group] = start + AST.Data.SynergyData[abilityId].cooldown
        end
    end

    if result == ACTION_RESULT_EFFECT_GAINED and AST.SV.healerui then

        if AST.ids[targetUnitId] then
            local tag = AST.ids[targetUnitId]
            local name = zo_strformat("<<1>>", GetUnitDisplayName(tag))
            local role = GetGroupMemberSelectedRole(tag)

            -- d("AST " .. name .. " - role: " .. role)

            if AST.SV.healer.tanksonly then
                if role ~= 2 then return; end
            end

            if AST.SV.healer.ddsonly then
                if role ~= 1 then return; end
            end

            -- local role      = GetGroupMemberAssignedRole(usedBy)

            for k, v in ipairs(AST.Data.HealerTimer) do
                if v.name == name then
                    if AST.Data.SynergyData[abilityId].group == AST.SV.healer.firstsynergy then
                        AST.Data.HealerTimer[k].firstsynergy = start + AST.Data.SynergyData[abilityId].cooldown
                    elseif (AST.Data.SynergyData[abilityId].group == AST.SV.healer.secondsynergy) then
    					--d("starting cooldown for second synergy")
                        AST.Data.HealerTimer[k].secondsynergy = start + AST.Data.SynergyData[abilityId].cooldown
                    elseif (AST.Data.SynergyData[abilityId].group == AST.SV.healer.thirdsynergy) then
                        AST.Data.HealerTimer[k].thirdsynergy = start + AST.Data.SynergyData[abilityId].cooldown
                    elseif (AST.Data.SynergyData[abilityId].group == AST.SV.healer.fourthsynergy) then
                        AST.Data.HealerTimer[k].fourthsynergy = start + AST.Data.SynergyData[abilityId].cooldown
                    end
                end
            end
            -- d("Synergy activated! ID: "..abilityId.." From: "..name.." Result: "..result.." Source: "..sourceType)
        end
    end

    em:RegisterForUpdate(AST.name.."Update", AST.SV.interval, T.countDown)
end

function T.countDown()
    local count, counttotal, counter, countAll = 0, 0, 0, 0

    if AST.SV.trackerui then
        for k, v in ipairs(AST.Data.TrackerTimer) do
            local element   = ASTGrid:GetNamedChild("SynergyTimer"..k)
            local icon      = ASTGrid:GetNamedChild("SynergyIcon"..k)

            if AST.time(v, 1) <= 0.1 then
                element:SetText("0.0")
                element:SetColor(255, 255, 255, 1)
                icon:SetColor(1, 1, 1, 1)

                if AST.SV.textures then icon:SetAlpha(AST.SV.alpha) end

                counter = counter + 1
            else
                if AST.SV.interval == 1000 then
                    element:SetText(AST.time(AST.Data.TrackerTimer[k], 0))
                else
                    element:SetText(string.format("%.1f", AST.time(AST.Data.TrackerTimer[k], 1)))
                end

                element:SetColor(255, 0, 0, 1)
                icon:SetColor(0.5, 0.5, 0.5, 1)
            end

            countAll = countAll + 1
        end

    end

	--TODO, fix this numbered timer stuff where there are 40 timers found by number
    if AST.SV.healerui then
        for k, v in ipairs(AST.Data.HealerTimer) do
            local z = (k * 4 - 3)
			local x = (k * 4 - 2)
			local wat = (k * 4 - 1)
			local nou = (k * 4)

            local firElement = ASTHealerUI:GetNamedChild("HealerTimer"..z)
            local secElement = ASTHealerUI:GetNamedChild("HealerTimer"..x)
			local thirdElement = ASTHealerUI:GetNamedChild("HealerTimer"..wat)
			local fourthElement = ASTHealerUI:GetNamedChild("HealerTimer"..nou)

            if k <= 10 then
                if AST.time(v.firstsynergy, 1) <= 0.1 then
                    firElement:SetText("0")
                    firElement:SetColor(255, 255, 255, 1)
                    count = count + 1
                else
                    firElement:SetText(AST.time(AST.Data.HealerTimer[k].firstsynergy, 0))
                    firElement:SetColor(255, 0, 0, 1)
                end
				if AST.time(v.secondsynergy, 1) <= 0.1 then
					secElement:SetText("0")
					secElement:SetColor(255, 255, 255, 1)
					count = count + 1
				else
					secElement:SetText(AST.time(AST.Data.HealerTimer[k].secondsynergy, 0))
					secElement:SetColor(255, 0, 0, 1)
				end
				if AST.time(v.thirdsynergy, 1) <= 0.1 then
					thirdElement:SetText("0")
					thirdElement:SetColor(255, 255, 255, 1)
					count = count + 1
				else
					thirdElement:SetText(AST.time(AST.Data.HealerTimer[k].thirdsynergy, 0))
					thirdElement:SetColor(255, 0, 0, 1)
				end
				if AST.time(v.fourthsynergy, 1) <= 0.1 then
					fourthElement:SetText("0")
					fourthElement:SetColor(255, 255, 255, 1)
					count = count + 1
				else
					fourthElement:SetText(AST.time(AST.Data.HealerTimer[k].fourthsynergy, 0))
					fourthElement:SetColor(255, 0, 0, 1)
				end

                counttotal = counttotal + 2
            end
        end
    end

    if counter == countAll and count == counttotal then em:UnregisterForUpdate(AST.name.."Update") end
end
