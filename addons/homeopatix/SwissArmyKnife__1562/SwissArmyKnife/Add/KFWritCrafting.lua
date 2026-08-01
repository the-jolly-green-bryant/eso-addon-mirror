-- WritCrafting Addon File
-- @author    : Homeo
-- @lastModif : 23/09/2017
	




function GetWrit()

	SwissArmyKnifeContainerWritLabel_1:SetText("")
	SwissArmyKnifeContainerWritLabel_2:SetText("")
	SwissArmyKnifeContainerWritLabel_3:SetText("")
	SwissArmyKnifeContainerWritLabel_4:SetText("")
	SwissArmyKnifeContainerWritLabel_5:SetText("")
	SwissArmyKnifeContainerWritLabel_6:SetText("")

	SwissArmyKnifeContainerWritIcon_1:SetColor(255, 255, 255, 255)
	SwissArmyKnifeContainerWritIcon_2:SetColor(255, 255, 255, 255)
	SwissArmyKnifeContainerWritIcon_3:SetColor(255, 255, 255, 255)
	SwissArmyKnifeContainerWritIcon_4:SetColor(255, 255, 255, 255)
	SwissArmyKnifeContainerWritIcon_5:SetColor(255, 255, 255, 255)
	SwissArmyKnifeContainerWritIcon_6:SetColor(255, 255, 255, 255)

	SwissArmyKnifeContainerWritIcon_1:SetAlpha(0.3)
	SwissArmyKnifeContainerWritIcon_2:SetAlpha(0.3)
	SwissArmyKnifeContainerWritIcon_3:SetAlpha(0.3)
	SwissArmyKnifeContainerWritIcon_4:SetAlpha(0.3)
	SwissArmyKnifeContainerWritIcon_5:SetAlpha(0.3)
	SwissArmyKnifeContainerWritIcon_6:SetAlpha(0.3)
	

	local WritIcon = ""
	local Qnbr = 0
	local QCompleted = 0
	local QNotCom = 0
  	local questCount = GetNumJournalQuests()
	StationType = GetCraftingInteractionType()

  	for questIndex = 1, questCount do
    		if IsValidQuestIndex(questIndex) then
      			RepeatType = GetJournalQuestRepeatType(questIndex)
      			QuestName, BackgroundText, ActiveStepText, ActiveStepType, ActiveStepTrackerOverrideText, Completed, Tracked, QuestLevel, Pushed, QuestType, InstanceDisplayType = GetJournalQuestInfo(questIndex)

			--d(QuestName)
      			local questComplete = GetJournalQuestIsComplete(questIndex)

      			if (QuestType == QUEST_TYPE_CRAFTING and RepeatType == QUEST_REPEAT_DAILY) then

          			WritIcon, Qnbr = ReturnIconWrit(QuestName)
				
        			local steps = GetJournalQuestNumSteps(questIndex)

        			stepText, stepVisibility, stepType, stepTrackerOverrideText, conditions = GetJournalQuestStepInfo(questIndex, steps)

        			for conditionIndex = 1, conditions do

          				conditionText, current, max, isFailCondition, isComplete, isCreditShared, isVisible = GetJournalQuestConditionInfo(questIndex, steps, conditionIndex)
         
					if(current == max) then
						QCompleted = QCompleted + 1
					else
						QNotCom = QNotCom + 1
        				end
       				end
				WritIcon = "|t140%:140%:" .. WritIcon .. "|t"
				val = (QCompleted+QNotCom)-1

				if(Qnbr == 0) then -- tailleur
					SwissArmyKnifeContainerWritIcon_1:SetColor(255, 255, 255, 255)
					SwissArmyKnifeContainerWritIcon_1:SetAlpha(1)
					if(StationType == 2) then
						DisplayWritAtStation(questIndex, WritIcon)
					end

					if(QCompleted == val) then
						SwissArmyKnifeContainerWritLabel_1:SetText(string.format("|c4DFF00%s|r/|c4DFF00%s|r", QCompleted, val))
					else
						SwissArmyKnifeContainerWritLabel_1:SetText(string.format("|cF53D00%s|r/%s", QCompleted, val))
					end
				end
				if(Qnbr == 1) then -- forge
					SwissArmyKnifeContainerWritIcon_2:SetColor(255, 255, 255, 255)
					SwissArmyKnifeContainerWritIcon_2:SetAlpha(1)
			
					if(StationType == 1) then
						DisplayWritAtStation(questIndex, WritIcon)
					end

					if(QCompleted == val) then
						SwissArmyKnifeContainerWritLabel_2:SetText(string.format("|c4DFF00%s|r/|c4DFF00%s|r", QCompleted, val))
					else
						SwissArmyKnifeContainerWritLabel_2:SetText(string.format("|cF53D00%s|r/%s", QCompleted, val))
					end
				end
				if(Qnbr == 2) then -- bois
					SwissArmyKnifeContainerWritIcon_3:SetColor(255, 255, 255, 255)
					SwissArmyKnifeContainerWritIcon_3:SetAlpha(1)
					if(StationType == 6) then
						DisplayWritAtStation(questIndex, WritIcon)
					end
					if(QCompleted == val) then
						SwissArmyKnifeContainerWritLabel_3:SetText(string.format("|c4DFF00%s|r/|c4DFF00%s|r", QCompleted, val))
					else
						SwissArmyKnifeContainerWritLabel_3:SetText(string.format("|cF53D00%s|r/%s", QCompleted, val))
					end
				end
				if(Qnbr == 3) then -- enchant
					SwissArmyKnifeContainerWritIcon_4:SetColor(255, 255, 255, 255)
					SwissArmyKnifeContainerWritIcon_4:SetAlpha(1)
					if(StationType == 3) then
						DisplayWritAtStation(questIndex, WritIcon)
					end
					if(QCompleted == val) then
						SwissArmyKnifeContainerWritLabel_4:SetText(string.format("|c4DFF00%s|r/|c4DFF00%s|r", QCompleted, val))
					else
						SwissArmyKnifeContainerWritLabel_4:SetText(string.format("|cF53D00%s|r/%s", QCompleted, val))
					end
				end
				if(Qnbr == 4) then -- cuisine
					SwissArmyKnifeContainerWritIcon_5:SetColor(255, 255, 255, 255)
					SwissArmyKnifeContainerWritIcon_5:SetAlpha(1)
					if(StationType == 5) then
						DisplayWritAtStation(questIndex, WritIcon)
					end
					if(QCompleted == val) then
						SwissArmyKnifeContainerWritLabel_5:SetText(string.format("|c4DFF00%s|r/|c4DFF00%s|r", QCompleted, val))
					else
						SwissArmyKnifeContainerWritLabel_5:SetText(string.format("|cF53D00%s|r/%s", QCompleted, val))
					end
				end
				if(Qnbr == 5) then -- alchimie
					SwissArmyKnifeContainerWritIcon_6:SetColor(255, 255, 255, 255)
					SwissArmyKnifeContainerWritIcon_6:SetAlpha(1)
					if(StationType == 4) then
						DisplayWritAtStation(questIndex, WritIcon)
					end
					if(QCompleted == val) then
						SwissArmyKnifeContainerWritLabel_6:SetText(string.format("|c4DFF00%s|r/|c4DFF00%s|r", QCompleted, val))
					else
						SwissArmyKnifeContainerWritLabel_6:SetText(string.format("|cF53D00%s|r/%s", QCompleted, val))
					end
				end

	
				--d(string.format("%s %s/%s",WritIcon, QCompleted, (QCompleted+QNotCom)-1))
				QCompleted = 0
				QNotCom = 0
				val = 0
				--d("*******************")
    			end
     		end
  	end
end

function DisplayWantedInWindowHelper(v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12)

	local heat, bounty = GetPlayerInfamyData()

	if(bounty > 0) then
		if(SAK.settings.DISPLAY_WRITHELPER_WINDOW_WARNING == true) then
			WritDisplayShow()

			if(SAK.settings.bounty_display ~= 10) then
				WritDisplayerTitle:SetColor(255, 0, 0, 255)
			else
				WritDisplayerTitle:SetColor(255, 0, 0, 0)
			end

			WritDisplayerTitle:SetText("!!! WANTED !!!")
    			WritDisplayerObjective:SetText(string.format("%s %s %s %s %s %s %s \n          %s %s/%s   %s%s", v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12))
			WritDisplayerIcon:SetText(SAK.stolenIcon)
		end
	else
		WritDisplayHide()
		WritDisplayerTitle:SetText("")
    		WritDisplayerObjective:SetText("")
		WritDisplayerIcon:SetText("")
	end
end


function LookingForGroup()
	WritDisplayerTitle:SetColor(255, 255, 0, 255)
	if(SAK.settings.DISPLAY_WRITHELPER_WINDOW_LFG == true) then
		if(IsCurrentlySearchingForGroup("player") == true) then
			WritDisplayShow()
			local searchStartTimeMs, searchEstimatedCompletionTimeMs = GetLFGSearchTimes() 
			local timeSinceSearchStartMs = GetFrameTimeMilliseconds() - searchStartTimeMs
			local textStartTime = ZO_FormatTimeMilliseconds(timeSinceSearchStartMs, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_TWELVE_HOUR)

			WritDisplayerTitle:SetText(SAK.lang.KF_WRIT_HELPER_7)
			WritDisplayerIcon:SetText(SAK.IconSearch)
	
			if searchEstimatedCompletionTimeMs > 0 then
                		local textEstimatedTime = ZO_GetSimplifiedTimeEstimateText(searchEstimatedCompletionTimeMs)
                		WritDisplayerObjective:SetText(string.format("%s : %s \n%s : %s", SAK.lang.KF_WRIT_HELPER_9, textStartTime, SAK.lang.KF_WRIT_HELPER_8, textEstimatedTime))
            		else
                		WritDisplayerObjective:SetText(string.format("%s : %s", SAK.lang.KF_WRIT_HELPER_9, textStartTime))
            		end
		else
			WritDisplayHide()
			WritDisplayerTitle:SetText("")
    			WritDisplayerObjective:SetText("")
			WritDisplayerIcon:SetText("")
		end
	end
end

function OnWritMoveStop()
  	SAK.settings.OffsetWritX = WritDisplayer:GetLeft()
	SAK.settings.OffsetWritY = WritDisplayer:GetTop()
end

function WritDisplayHide()
	WritDisplayer:SetHidden(true)
end

function WritDisplayShow()
	WritDisplayer:SetHidden(false)
end

function DisplayWritAtStation(Index, icon)

	-- display the writ helper
	if(SAK.settings.DISPLAY_WRITHELPER_WINDOW == true) then
		WritDisplayShow()
	else
		WritDisplayHide()
	end

	QuestName = GetJournalQuestInfo(Index)

	objective = ""

	local p1, p2, p3, p4 = " "
    	p1 = GetJournalQuestConditionInfo(Index, 1, 1)
    	p2 = GetJournalQuestConditionInfo(Index, 1, 2)
    	p3 = GetJournalQuestConditionInfo(Index, 1, 3)
    	p4 = GetJournalQuestConditionInfo(Index, 1, 4)

	conditionText, current, max = GetJournalQuestConditionInfo(Index, 1, 1)

    	if p1 ~= "" then
		if(current == max) then
			objective = objective .. "|c4DFF00" .. p1 .. "|r\n"
		else
			objective = objective .. p1 .. "\n"
		end
    	end
	conditionText, current, max = GetJournalQuestConditionInfo(Index, 1, 2)

    	if p2 ~= "" then
		if(current == max) then
			objective = objective .. "|c4DFF00" .. p2 .. "|r\n"
		else
			objective = objective .. p2 .. "\n"
		end
    	end
	conditionText, current, max = GetJournalQuestConditionInfo(Index, 1, 3)

    	if p3 ~= "" then
		if(current == max) then
			objective = objective .. "|c4DFF00" .. p3 .. "|r\n"
		else
			objective = objective .. p3 .. "\n"
		end
    	end
	conditionText, current, max = GetJournalQuestConditionInfo(Index, 1, 4)

    	if p4 ~= "" then
		if(current == max) then
			objective = objective .. "|c4DFF00" .. p4 .. "|r\n"
		else
			objective = objective .. p4 .. "\n"
		end
    	end
	
    	WritDisplayerTitle:SetText(QuestName)
	WritDisplayerTitle:SetColor(255, 255, 0, 255)
    	WritDisplayerObjective:SetText(string.format(objective))
	WritDisplayerIcon:SetText(icon)
end

function ReturnIconWrit(Qname)
	WritIcon = ""
	nbQ = 0

	-- language
	if GetCVar("language.2") == "fr" then
		if Qname == "Commande de tailleur" then
			WritIcon = SAK.IconClothing
			nbQ = 0
		end
		if Qname == "Commande de forge" then
			WritIcon = SAK.IconBlacksmith
			nbQ = 1
		end
		if Qname == "Commande de travail du bois" then
			WritIcon = SAK.IconWoodwork
			nbQ = 2
		end
		if Qname == "Commandes d'enchantement" then
			WritIcon = SAK.IconEnchant
			nbQ = 3
		end
		if Qname == "Commande de cuisine" then
			WritIcon = SAK.IconProvision
			nbQ = 4
		end
		if Qname == "Commande d'alchimie" then
			WritIcon = SAK.IconAlchemy
			nbQ = 5
		end
	end

	if GetCVar("language.2") == "en" then
		if Qname == "Clothier Writ" then
			WritIcon = SAK.IconClothing
			nbQ = 0
		end
		if Qname == "Blacksmith Writ" then
			WritIcon = SAK.IconBlacksmith
			nbQ = 1
		end
		if Qname == "Woodworker Writ" then
			WritIcon = SAK.IconWoodwork
			nbQ = 2
		end
		if Qname == "Enchanter Writ" then
			WritIcon = SAK.IconEnchant
			nbQ = 3
		end
		if Qname == "Provisioner Writ" then
			WritIcon = SAK.IconProvision
			nbQ = 4
		end
		if Qname == "Alchemist Writ" then
			WritIcon = SAK.IconAlchemy
			nbQ = 5
		end
	end

	if GetCVar("language.2") == "de" then
		if Qname == "Schneiderschrieb" then
			WritIcon = SAK.IconClothing
			nbQ = 0
		end
		if Qname == "Schmiedeschrieb" then
			WritIcon = SAK.IconBlacksmith
			nbQ = 1
		end
		if Qname == "Schreinerschrieb" then
			WritIcon = SAK.IconWoodwork
			nbQ = 2
		end
		if Qname == "Verzaubererschrieb" then
			WritIcon = SAK.IconEnchant
			nbQ = 3
		end
		if Qname == "Versorgerschrieb" then
			WritIcon = SAK.IconProvision
			nbQ = 4
		end
		if Qname == "Alchemistenschrieb" then
			WritIcon = SAK.IconAlchemy
			nbQ = 5
		end
	end
	

	return WritIcon, nbQ
end