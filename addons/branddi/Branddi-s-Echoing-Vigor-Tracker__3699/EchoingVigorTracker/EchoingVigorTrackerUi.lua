function EchoingVigorTracker.savePos()
	EchoingVigorTracker.savedVars.offsetX = EchoingVigorTrackerFrame:GetLeft()
	EchoingVigorTracker.savedVars.offsetY = EchoingVigorTrackerFrame:GetTop()
end

function EchoingVigorTracker.adjustFrameLocation()
	EchoingVigorTrackerFrame:ClearAnchors()
	EchoingVigorTrackerFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, EchoingVigorTracker.savedVars.offsetX, EchoingVigorTracker.savedVars.offsetY)
end



function EchoingVigorTracker.showUI()
    if EchoingVigorTracker.manuallyShowUi==false then
        EchoingVigorTracker.manuallyShowUi = true

        EchoingVigorTrackerFrame:SetMovable(true)
		EchoingVigorTrackerFrame:SetMouseEnabled(true)

        EchoingVigorTracker.updateUi()
    else
        EchoingVigorTracker.manuallyShowUi = false

        EchoingVigorTrackerFrame:SetMovable(false)
		EchoingVigorTrackerFrame:SetMouseEnabled(false)

        EchoingVigorTracker.updateUi()
    end
end



function EchoingVigorTracker.updateUi()
    if EchoingVigorTracker.manuallyShowUi==true then

        for i=1, 12 do
            local name ="@name"..i

            local frameBar = _G["EchoingVigorTrackerFrame" .. i .. "Bar"]
            local frameBg = _G["EchoingVigorTrackerFrame" .. i .. "Bg"]
            local frameLabel = _G["EchoingVigorTrackerFrame" .. i .. "Label"]

            if i == 1 then
                name = "EV active, <15m"
                frameBar:SetColor(unpack(EchoingVigorTracker.savedVars.activeEchoingVigorInRangeColor))
                frameBar:SetValue(1)
                frameBg:SetCenterColor(unpack(EchoingVigorTracker.savedVars.normalBackgroundColor))
            elseif i == 2 then
                name = "EV active, >15m"
                frameBar:SetColor(unpack(EchoingVigorTracker.savedVars.activeEchoingVigorOutsideRangeColor))
                frameBar:SetValue(0.5)
                frameBg:SetCenterColor(unpack(EchoingVigorTracker.savedVars.normalBackgroundColor))
            elseif i == 3 then
                name = "EV eligable, <15m"
                frameBar:SetColor(unpack(EchoingVigorTracker.savedVars.inactiveEchoingVigorCanReceieveColor))
                frameBar:SetValue(1)
                frameBg:SetCenterColor(unpack(EchoingVigorTracker.savedVars.normalBackgroundColor))
            elseif i == 4 then
                name = "EV eligable, <15m"
                frameBar:SetColor(unpack(EchoingVigorTracker.savedVars.inactiveEchoingVigorCanReceieveColor))
                frameBar:SetValue(1)
                frameBg:SetCenterColor(unpack(EchoingVigorTracker.savedVars.normalBackgroundColor))


            elseif i == 5 then
                name = "EV ineligible, <15m"
                frameBar:SetColor(unpack(EchoingVigorTracker.savedVars.inactiveEchoingVigorCannotReceieveColor))
                frameBar:SetValue(1)
                frameBg:SetCenterColor(unpack(EchoingVigorTracker.savedVars.normalBackgroundColor))
            elseif i == 6 then
                name = "EV ineligible >15m"
                frameBar:SetColor(unpack(EchoingVigorTracker.savedVars.activeEchoingVigorInRangeColor))
                frameBar:SetValue(0)
                frameBg:SetCenterColor(unpack(EchoingVigorTracker.savedVars.normalBackgroundColor))
            elseif i == 7 then
                name = "EV recommend"
                frameBar:SetColor(unpack(EchoingVigorTracker.savedVars.activeEchoingVigorInRangeColor))
                frameBar:SetValue(1)
                frameBg:SetCenterColor(unpack(EchoingVigorTracker.savedVars.recommendCastingEchoingVigorBackgroundColor))
            elseif i == 8 then
                name = "casting"
                frameBar:SetColor(unpack(EchoingVigorTracker.savedVars.activeEchoingVigorInRangeColor))
                frameBar:SetValue(1)
                frameBg:SetCenterColor(unpack(EchoingVigorTracker.savedVars.recommendCastingEchoingVigorBackgroundColor))
            elseif i == 9 then
                name = "background"
                frameBar:SetColor(unpack(EchoingVigorTracker.savedVars.activeEchoingVigorInRangeColor))
                frameBar:SetValue(1)
                frameBg:SetCenterColor(unpack(EchoingVigorTracker.savedVars.recommendCastingEchoingVigorBackgroundColor))

            else
                frameBar:SetColor(unpack(EchoingVigorTracker.savedVars.activeEchoingVigorInRangeColor))
                frameBar:SetValue(1)
                frameBg:SetCenterColor(unpack(EchoingVigorTracker.savedVars.recommendCastingEchoingVigorBackgroundColor))
            end

            frameLabel:SetText(string.format('%s', name))


            frameBar:SetHidden(false)
            frameBg:SetHidden(false)

            frameLabel:SetHidden(false)
        end
        EchoingVigorTrackerFrame:SetHidden(false)
        return

    elseif EchoingVigorTracker.addonLoaded==false or EchoingVigorTracker.savedVars.enabled==false or  IsReticleHidden() or (EchoingVigorTracker.savedVars.showOnlyInCombat and EchoingVigorTracker.inCombat==false) then
        EchoingVigorTrackerFrame:SetHidden(true)
        return
    end




    local targetsGuaranteed, targetsWithEv, totalTargets = EchoingVigorTracker.countEchoingVigorTargets()
    local displayNewTargetsAsLikelyToReceivedEchoingVigor = false
    if targetsGuaranteed > 0 then
        displayNewTargetsAsLikelyToReceivedEchoingVigor= true
    end



    local requiredTargets = 0
    if totalTargets>6 then
        requiredTargets = EchoingVigorTracker.savedVars.requiredTargetsToRecommendCastingTrials
    else
        requiredTargets = EchoingVigorTracker.savedVars.requiredTargetsToRecommendCastingDungeons
    end

    if requiredTargets > totalTargets then
        requiredTargets=totalTargets
    end

    local recommendCasting = EchoingVigorTracker.savedVars.recommendCastingEnabled
    if targetsGuaranteed < requiredTargets then
        recommendCasting = false
    end


    for i=1, 12 do
        local unitTag = "group"..i
        local role = GetGroupMemberSelectedRole(unitTag)
		if IsUnitGrouped("player")==false and i == 1 then
			unitTag="player"
            role=1
		end

        local frameBar = _G["EchoingVigorTrackerFrame" .. i .. "Bar"]
        local frameBg = _G["EchoingVigorTrackerFrame" .. i .. "Bg"]
        local frameLabel = _G["EchoingVigorTrackerFrame" .. i .. "Label"]

        local evUntil = EchoingVigorTracker.echoingVigorMembers[i][EchoingVigorTracker.EVT_ECHOING_VIGOR_EXPIRES]
        local evRemainingMs = evUntil-GetGameTimeMilliseconds()
        if evRemainingMs<0 then
            evRemainingMs=0
        end

		local validEvTarget = EchoingVigorTracker.validEchoingVigorTarget(unitTag)

        local name = EchoingVigorTracker.echoingVigorMembers[i][EchoingVigorTracker.EVT_AT_NAME]



        if role > 0 then

            if recommendCasting then
                frameBg:SetCenterColor(unpack(EchoingVigorTracker.savedVars.recommendCastingEchoingVigorBackgroundColor))
            else
                frameBg:SetCenterColor(unpack(EchoingVigorTracker.savedVars.normalBackgroundColor))
            end

			if evRemainingMs==0 then
				if validEvTarget and displayNewTargetsAsLikelyToReceivedEchoingVigor then -- in range and needs EV
					frameBar:SetColor(unpack(EchoingVigorTracker.savedVars.inactiveEchoingVigorCanReceieveColor))
					frameBar:SetValue(1)
                elseif validEvTarget then -- target is unlikely to get EV due to others around
					frameBar:SetColor(unpack(EchoingVigorTracker.savedVars.inactiveEchoingVigorCannotReceieveColor))
					frameBar:SetValue(1)
				else
					frameBar:SetValue(0)
					frameBar:SetColor(unpack(EchoingVigorTracker.savedVars.inactiveEchoingVigorCannotReceieveColor))
				end

			else
				if validEvTarget then
					frameBar:SetColor(unpack(EchoingVigorTracker.savedVars.activeEchoingVigorInRangeColor))
				else
					frameBar:SetColor(unpack(EchoingVigorTracker.savedVars.activeEchoingVigorOutsideRangeColor))
				end
            	local progress = evRemainingMs/15000
				frameBar:SetValue(progress)
			end

            frameLabel:SetText(string.format('%s', name))

            frameBar:SetHidden(false)
            frameBg:SetHidden(false)
            frameLabel:SetHidden(false)
        else
            frameBar:SetHidden(true)
            frameBg:SetHidden(true)
            frameLabel:SetHidden(true)
        end

    end
    EchoingVigorTrackerFrame:SetHidden(false)
end


