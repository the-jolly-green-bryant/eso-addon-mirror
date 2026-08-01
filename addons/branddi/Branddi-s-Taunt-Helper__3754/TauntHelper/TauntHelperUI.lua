TauntHelper.MAX_NUMBER_OF_BARS = 10
TauntHelper.LockedUI = true


function TauntHelper.setupUI()
    TauntHelper.setPos()
    TauntHelperFrame:SetHidden(false)



    local barDimension = {
        width = TauntHelper.savedVars.widthOfTauntBars,
        height = TauntHelper.savedVars.heightOfTauntBars,
    }
    local timerDimension = {
        width = 30,
        height = barDimension.height - 10,
    }
    local fontPath = LibMediaProvider:Fetch("font", TauntHelper.savedVars.fontTauntBars)
    local fontString = fontPath .. "|$(KB_" .. TauntHelper.savedVars.fontSizeTauntBars .. ")|soft-shadow-thin"


    for i = 1, 10 do
        local frameBar = _G["TauntHelperFrame" .. i .. "Bar"]
        local frameBg = _G["TauntHelperFrame" .. i .. "Bg"]
        local frameTimer = _G["TauntHelperFrame" .. i .. "Timer"]
        local frameLabel = _G["TauntHelperFrame" .. i .. "Label"]

        frameBar:SetDimensions(barDimension.width, barDimension.height * 10)
        frameBg:SetEdgeTexture("", 1, 1, TauntHelper.savedVars.borderOfTauntBars)
        frameBg:SetDimensions(barDimension.width, barDimension.height)
        frameBar:SetDimensions(barDimension.width - 12, barDimension.height - 12)
        frameTimer:SetDimensions(timerDimension.width, timerDimension.height)
        frameTimer:SetFont(fontString)
        frameLabel:SetFont(fontString)

        if TauntHelper.savedVars.normalDirectionOfTauntBars then
            frameBar:SetBarAlignment(BAR_ALIGNMENT_NORMAL)
        else
            frameBar:SetBarAlignment(BAR_ALIGNMENT_REVERSE)
        end

    end

    TauntHelper.updateUI()
end


--[[]
function TauntHelper.setupUI()
	TauntHelper.setPos()
	TauntHelperFrame:SetHidden(false)



    TauntHelperFrame1Bar:SetDimensions(TauntHelper.savedVars.widthOfTauntBars,TauntHelper.savedVars.heightOfTauntBars*10)




    TauntHelperFrame1Bg:SetEdgeTexture ("", 1, 1, TauntHelper.savedVars.borderOfTauntBars)
    TauntHelperFrame2Bg:SetEdgeTexture ("", 1, 1, TauntHelper.savedVars.borderOfTauntBars)
    TauntHelperFrame3Bg:SetEdgeTexture ("", 1, 1, TauntHelper.savedVars.borderOfTauntBars)
    TauntHelperFrame4Bg:SetEdgeTexture ("", 1, 1, TauntHelper.savedVars.borderOfTauntBars)
    TauntHelperFrame5Bg:SetEdgeTexture ("", 1, 1, TauntHelper.savedVars.borderOfTauntBars)
    TauntHelperFrame6Bg:SetEdgeTexture ("", 1, 1, TauntHelper.savedVars.borderOfTauntBars)
    TauntHelperFrame7Bg:SetEdgeTexture ("", 1, 1, TauntHelper.savedVars.borderOfTauntBars)
    TauntHelperFrame8Bg:SetEdgeTexture ("", 1, 1, TauntHelper.savedVars.borderOfTauntBars)
    TauntHelperFrame9Bg:SetEdgeTexture ("", 1, 1, TauntHelper.savedVars.borderOfTauntBars)
    TauntHelperFrame10Bg:SetEdgeTexture ("", 1, 1, TauntHelper.savedVars.borderOfTauntBars)



    TauntHelperFrame1Bg:SetDimensions (TauntHelper.savedVars.widthOfTauntBars, TauntHelper.savedVars.heightOfTauntBars)
    TauntHelperFrame2Bg:SetDimensions (TauntHelper.savedVars.widthOfTauntBars, TauntHelper.savedVars.heightOfTauntBars)
    TauntHelperFrame3Bg:SetDimensions (TauntHelper.savedVars.widthOfTauntBars, TauntHelper.savedVars.heightOfTauntBars)
    TauntHelperFrame4Bg:SetDimensions (TauntHelper.savedVars.widthOfTauntBars, TauntHelper.savedVars.heightOfTauntBars)
    TauntHelperFrame5Bg:SetDimensions (TauntHelper.savedVars.widthOfTauntBars, TauntHelper.savedVars.heightOfTauntBars)
    TauntHelperFrame6Bg:SetDimensions (TauntHelper.savedVars.widthOfTauntBars, TauntHelper.savedVars.heightOfTauntBars)
    TauntHelperFrame7Bg:SetDimensions (TauntHelper.savedVars.widthOfTauntBars, TauntHelper.savedVars.heightOfTauntBars)
    TauntHelperFrame8Bg:SetDimensions (TauntHelper.savedVars.widthOfTauntBars, TauntHelper.savedVars.heightOfTauntBars)
    TauntHelperFrame9Bg:SetDimensions (TauntHelper.savedVars.widthOfTauntBars, TauntHelper.savedVars.heightOfTauntBars)
    TauntHelperFrame10Bg:SetDimensions(TauntHelper.savedVars.widthOfTauntBars, TauntHelper.savedVars.heightOfTauntBars)




    TauntHelperFrame1Bar:SetDimensions (TauntHelper.savedVars.widthOfTauntBars-12, TauntHelper.savedVars.heightOfTauntBars-12)
    TauntHelperFrame2Bar:SetDimensions (TauntHelper.savedVars.widthOfTauntBars-12, TauntHelper.savedVars.heightOfTauntBars-12)
    TauntHelperFrame3Bar:SetDimensions (TauntHelper.savedVars.widthOfTauntBars-12, TauntHelper.savedVars.heightOfTauntBars-12)
    TauntHelperFrame4Bar:SetDimensions (TauntHelper.savedVars.widthOfTauntBars-12, TauntHelper.savedVars.heightOfTauntBars-12)
    TauntHelperFrame5Bar:SetDimensions (TauntHelper.savedVars.widthOfTauntBars-12, TauntHelper.savedVars.heightOfTauntBars-12)
    TauntHelperFrame6Bar:SetDimensions (TauntHelper.savedVars.widthOfTauntBars-12, TauntHelper.savedVars.heightOfTauntBars-12)
    TauntHelperFrame7Bar:SetDimensions (TauntHelper.savedVars.widthOfTauntBars-12, TauntHelper.savedVars.heightOfTauntBars-12)
    TauntHelperFrame8Bar:SetDimensions (TauntHelper.savedVars.widthOfTauntBars-12, TauntHelper.savedVars.heightOfTauntBars-12)
    TauntHelperFrame9Bar:SetDimensions (TauntHelper.savedVars.widthOfTauntBars-12, TauntHelper.savedVars.heightOfTauntBars-12)
    TauntHelperFrame10Bar:SetDimensions(TauntHelper.savedVars.widthOfTauntBars-12, TauntHelper.savedVars.heightOfTauntBars-12)


    TauntHelperFrame1Timer:SetDimensions (30, TauntHelper.savedVars.heightOfTauntBars-10)
    TauntHelperFrame2Timer:SetDimensions (30, TauntHelper.savedVars.heightOfTauntBars-10)
    TauntHelperFrame3Timer:SetDimensions (30, TauntHelper.savedVars.heightOfTauntBars-10)
    TauntHelperFrame4Timer:SetDimensions (30, TauntHelper.savedVars.heightOfTauntBars-10)
    TauntHelperFrame5Timer:SetDimensions (30, TauntHelper.savedVars.heightOfTauntBars-10)
    TauntHelperFrame6Timer:SetDimensions (30, TauntHelper.savedVars.heightOfTauntBars-10)
    TauntHelperFrame7Timer:SetDimensions (30, TauntHelper.savedVars.heightOfTauntBars-10)
    TauntHelperFrame8Timer:SetDimensions (30, TauntHelper.savedVars.heightOfTauntBars-10)
    TauntHelperFrame9Timer:SetDimensions (30, TauntHelper.savedVars.heightOfTauntBars-10)
    TauntHelperFrame10Timer:SetDimensions(30, TauntHelper.savedVars.heightOfTauntBars-10)


    local fontPath = LibMediaProvider:Fetch("font", TauntHelper.savedVars.fontTauntBars)


	TauntHelperFrame1Timer:SetFont (fontPath.."|$(KB_"..TauntHelper.savedVars.fontSizeTauntBars..")|soft-shadow-thin")`
	TauntHelperFrame2Timer:SetFont (fontPath.."|$(KB_"..TauntHelper.savedVars.fontSizeTauntBars..")|soft-shadow-thin")
    TauntHelperFrame3Timer:SetFont (fontPath.."|$(KB_"..TauntHelper.savedVars.fontSizeTauntBars..")|soft-shadow-thin")
	TauntHelperFrame4Timer:SetFont (fontPath.."|$(KB_"..TauntHelper.savedVars.fontSizeTauntBars..")|soft-shadow-thin")
	TauntHelperFrame5Timer:SetFont (fontPath.."|$(KB_"..TauntHelper.savedVars.fontSizeTauntBars..")|soft-shadow-thin")
	TauntHelperFrame6Timer:SetFont (fontPath.."|$(KB_"..TauntHelper.savedVars.fontSizeTauntBars..")|soft-shadow-thin")
	TauntHelperFrame7Timer:SetFont (fontPath.."|$(KB_"..TauntHelper.savedVars.fontSizeTauntBars..")|soft-shadow-thin")
    TauntHelperFrame8Timer:SetFont (fontPath.."|$(KB_"..TauntHelper.savedVars.fontSizeTauntBars..")|soft-shadow-thin")
	TauntHelperFrame9Timer:SetFont (fontPath.."|$(KB_"..TauntHelper.savedVars.fontSizeTauntBars..")|soft-shadow-thin")
	TauntHelperFrame10Timer:SetFont(fontPath.."|$(KB_"..TauntHelper.savedVars.fontSizeTauntBars..")|soft-shadow-thin")

	TauntHelperFrame1Label:SetFont (fontPath.."|$(KB_"..TauntHelper.savedVars.fontSizeTauntBars..")|soft-shadow-thin")
	TauntHelperFrame2Label:SetFont (fontPath.."|$(KB_"..TauntHelper.savedVars.fontSizeTauntBars..")|soft-shadow-thin")
    TauntHelperFrame3Label:SetFont (fontPath.."|$(KB_"..TauntHelper.savedVars.fontSizeTauntBars..")|soft-shadow-thin")
	TauntHelperFrame4Label:SetFont (fontPath.."|$(KB_"..TauntHelper.savedVars.fontSizeTauntBars..")|soft-shadow-thin")
	TauntHelperFrame5Label:SetFont (fontPath.."|$(KB_"..TauntHelper.savedVars.fontSizeTauntBars..")|soft-shadow-thin")
	TauntHelperFrame6Label:SetFont (fontPath.."|$(KB_"..TauntHelper.savedVars.fontSizeTauntBars..")|soft-shadow-thin")
	TauntHelperFrame7Label:SetFont (fontPath.."|$(KB_"..TauntHelper.savedVars.fontSizeTauntBars..")|soft-shadow-thin")
    TauntHelperFrame8Label:SetFont (fontPath.."|$(KB_"..TauntHelper.savedVars.fontSizeTauntBars..")|soft-shadow-thin")
	TauntHelperFrame9Label:SetFont (fontPath.."|$(KB_"..TauntHelper.savedVars.fontSizeTauntBars..")|soft-shadow-thin")
	TauntHelperFrame10Label:SetFont(fontPath.."|$(KB_"..TauntHelper.savedVars.fontSizeTauntBars..")|soft-shadow-thin")

	TauntHelper.updateUI()
end
--]]

function TauntHelper.setPos()
	local x, y = TauntHelper.savedVars.offsetX, TauntHelper.savedVars.offsetY
	TauntHelperFrame:ClearAnchors()
	TauntHelperFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)


    local x, y = TauntHelper.savedVars.offsetTauntStacksX, TauntHelper.savedVars.offsetTauntStacksY
	TauntHelperTauntStacksFrame:ClearAnchors()
	TauntHelperTauntStacksFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

function TauntHelper.savePos()

	TauntHelper.savedVars.offsetX = TauntHelperFrame:GetLeft()
	TauntHelper.savedVars.offsetY = TauntHelperFrame:GetTop()
	--d("saving position X:"..TauntHelper.savedVars.offsetX.. " Y:" ..  TauntHelper.savedVars.offsetY)


	TauntHelper.savedVars.offsetTauntStacksX = TauntHelperTauntStacksFrame:GetLeft()
	TauntHelper.savedVars.offsetTauntStacksY = TauntHelperTauntStacksFrame:GetTop()

end

function TauntHelper.updateBar(barNum, name, tauntExpiresInMs, highlight, stolen, tauntImmunity, tauntStacks)
    local bg, bar, timer, label = TauntHelper.getUIElements(barNum)
    if bg ~= nil then

        local tauntExpiresInS = tauntExpiresInMs/1000

        label:SetText(name)

        if tauntExpiresInS>=2 then
            timer:SetText(string.format('%i', tauntExpiresInS))
        elseif tauntExpiresInS>=0 then
            timer:SetText(string.format('%.1f', tauntExpiresInS))
        else
            timer:SetText("")
        end

        if stolen then
            bar:SetValue(1)
        else
            local progress = (15000-tauntExpiresInMs)/15000

            if TauntHelper.savedVars.reverseTauntBarDirection then
                if progress < 1 then -- if progress is less than or equal to 0 then we will set the progress to full even when reversed
                    progress = 1 - progress
                end
            end

            bar:SetValue(progress)

        end

        local blinkResult = GetGameTimeMilliseconds() % 500






        if stolen then
            --bar:SetColor(0,   0,   1,  1, 1) -- Blue
            if blinkResult < 250 and TauntHelper.savedVars.blinkStolenTaunt then
                bar:SetColor(0.3,   0.3,   0.3,  1, 1) -- Grey
            else
                bar:SetColor(unpack(TauntHelper.savedVars.stolenTauntColor))
            end
        elseif tauntExpiresInS < -(TauntHelper.savedVars.afterTauntSeconds+15) then -- more than 20 seconds overdue then its a "Loose add that spawned"

            if blinkResult < 250 and TauntHelper.savedVars.blinkLooseMob then
                bar:SetColor(0.3,   0.3,   0.3,  1, 1) -- Grey
            else
                --bar:SetColor(0.6,   0.6,   0.6,  1, 1) -- Red
                bar:SetColor(unpack(TauntHelper.savedVars.looseTauntColor))

            end

        elseif tauntExpiresInS < 0 then

            if blinkResult < 250 and TauntHelper.savedVars.blinkLostTaunt then
                --bar:SetColor(  1,   0.2,   0.8,  1, 1) -- Pink
                bar:SetColor(0.3,   0.3,   0.3,  1, 1) -- Grey
            else
                --bar:SetColor(0.8,     0,     0,  1, 1) -- Red
                bar:SetColor(unpack(TauntHelper.savedVars.badTauntColor))
            end

        elseif tauntExpiresInS < 3 then
            --bar:SetColor(0.8,0,0,1, 1) -- Red
            bar:SetColor(unpack(TauntHelper.savedVars.badTauntColor))
        elseif tauntExpiresInS < 7.5 then
            --bar:SetColor(0.7,0.7,0, 1) -- Yellow
            bar:SetColor(unpack(TauntHelper.savedVars.mediumTauntColor))
        else
            --bar:SetColor(0,0.8,0,1) -- Green?
            bar:SetColor(unpack(TauntHelper.savedVars.goodTauntColor))
        end


        if tauntImmunity and TauntHelper.isTauntSkillSlotted() then -- only display taunt immunity if taunt slotted
            bg:SetEdgeColor(unpack(TauntHelper.savedVars.tauntImmunityColor))
        elseif highlight==true and TauntHelper.isTauntSkillSlotted() then -- only display active target if taunt slotted
            if tauntStacks <= 1 then
                bg:SetEdgeColor(unpack(TauntHelper.savedVars.reticleOverColor))
            elseif tauntStacks == 2 then
                bg:SetEdgeColor(unpack(TauntHelper.savedVars.tauntCounter2ImmunityColor))
            elseif tauntStacks == 3 then
                bg:SetEdgeColor(unpack(TauntHelper.savedVars.tauntCounter3ImmunityColor))
            elseif tauntStacks == 4 then
                bg:SetEdgeColor(unpack(TauntHelper.savedVars.tauntCounter4ImmunityColor))
            elseif tauntStacks == 5 then
                bg:SetEdgeColor(unpack(TauntHelper.savedVars.tauntImmunityColor))
            end
            --d("highlight")
        else
            bg:SetEdgeColor(0,0,0,0) -- remove border alpha 0
        end

        bg:SetHidden(false)
        bar:SetHidden(false)
        timer:SetHidden(false)
        label:SetHidden(false)
    end
end

function TauntHelper.hideBar(barNum)
    local bg, bar, timer, label = TauntHelper.getUIElements(barNum)
    if bg ~= nil then
        bg:SetHidden(true)
        bar:SetHidden(true)
        timer:SetHidden(true)
        label:SetHidden(true)
    end
end

function TauntHelper.getUIElements(barNum)
    if barNum >= 1 and barNum <= 10 then
        local bg = _G["TauntHelperFrame" .. barNum .. "Bg"]
        local bar = _G["TauntHelperFrame" .. barNum .. "Bar"]
        local timer = _G["TauntHelperFrame" .. barNum .. "Timer"]
        local label = _G["TauntHelperFrame" .. barNum .. "Label"]
        return bg, bar, timer, label
    else
        return nil, nil, nil, nil
    end
end

--[[]

function TauntHelper.getUIElements(barNum)
    if barNum == 1 then
        return TauntHelperFrame1Bg, TauntHelperFrame1Bar, TauntHelperFrame1Timer, TauntHelperFrame1Label
    elseif barNum == 2 then
        return TauntHelperFrame2Bg, TauntHelperFrame2Bar, TauntHelperFrame2Timer, TauntHelperFrame2Label
    elseif barNum == 3 then
        return TauntHelperFrame3Bg, TauntHelperFrame3Bar, TauntHelperFrame3Timer, TauntHelperFrame3Label
    elseif barNum == 4 then
        return TauntHelperFrame4Bg, TauntHelperFrame4Bar, TauntHelperFrame4Timer, TauntHelperFrame4Label
    elseif barNum == 5 then
        return TauntHelperFrame5Bg, TauntHelperFrame5Bar, TauntHelperFrame5Timer, TauntHelperFrame5Label
    elseif barNum == 6 then
        return TauntHelperFrame6Bg, TauntHelperFrame6Bar, TauntHelperFrame6Timer, TauntHelperFrame6Label
    elseif barNum == 7 then
        return TauntHelperFrame7Bg, TauntHelperFrame7Bar, TauntHelperFrame7Timer, TauntHelperFrame7Label
    elseif barNum == 8 then
        return TauntHelperFrame8Bg, TauntHelperFrame8Bar, TauntHelperFrame8Timer, TauntHelperFrame8Label
    elseif barNum == 9 then
        return TauntHelperFrame9Bg, TauntHelperFrame9Bar, TauntHelperFrame9Timer, TauntHelperFrame9Label
    elseif barNum == 10 then
        return TauntHelperFrame10Bg, TauntHelperFrame10Bar, TauntHelperFrame10Timer, TauntHelperFrame10Label
    else
        return nil, nil, nil, nil
    end

end
--]]

function TauntHelper.updateUI()
    if TauntHelper.LockedUI == false then
        for bar = 1,TauntHelper.MAX_NUMBER_OF_BARS do
            TauntHelper.updateBar(bar, string.format('Target Mob %i', bar), 7000, false, false, false, 0)
        end
        if TauntHelper.savedVars.enableTauntStacks then
            TauntHelperTauntStacksFrameLabel:SetText("Taunt#")
            TauntHelperTauntStacksFrame:SetHidden(false)
        end
        return
    end


    local currentBar = 0

    if TauntHelper.onTauntInitialized and IsUnitInCombat("player") and IsReticleHidden()==false then -- only display in combat when initialized


        TauntHelper.checkRetcleForActiveTaunt()
        for unitId, tauntDetails in pairs(TauntHelper.tauntList) do
            local tauntExpiresInS = (tauntDetails[TauntHelper.TAUNT_LIST_ENDTIME] - GetGameTimeMilliseconds())/1000

            local displayEntry = false

            if tauntDetails[TauntHelper.TAUNT_LIST_ENABLE] then -- only enabled taunts
                if TauntHelper.auditMode then
                    displayEntry = true -- taunt is added for audit purposes
                elseif TauntHelper.isTauntSkillSlotted()==true then -- if acting as tank
                    if tauntExpiresInS <= 0 or tauntDetails[TauntHelper.TAUNT_LIST_IHAVETAUNT] == true then
                        displayEntry = true -- either taunt expired, or its my taunt (do not show other tank taunts)
                        --d("display because is tant")
                    elseif (GetGameTimeMilliseconds()-tauntDetails[TauntHelper.TAUNT_LIST_STOLENTAUNTTIME])/1000<=TauntHelper.savedVars.afterTauntSeconds  and TauntHelper.savedVars.displayStolenMobs then
                        displayEntry = true -- taunt was stolen within the past 10 seconds?
                    end
                elseif TauntHelper.isTauntSkillSlotted()==false and TauntHelper.savedVars.dpsDisplayLooseAdds then
                    if tauntExpiresInS <= 0 then
                        displayEntry = true -- if not a taunt only show expired taunts
                        --d("display because is dps")
                    end
                end
            end

            if displayEntry then

                -- determine if the taunt was stolen
                local stolen = ((GetGameTimeMilliseconds()-tauntDetails[TauntHelper.TAUNT_LIST_STOLENTAUNTTIME])/1000<=TauntHelper.savedVars.afterTauntSeconds) and (tauntDetails[TauntHelper.TAUNT_LIST_IHAVETAUNT] == false)

                local tauntImmunity = GetGameTimeMilliseconds() < tauntDetails[TauntHelper.TAUNT_LIST_TAUNTIMMUNITYENDTIME]

                local lastSeenAgoInS = (GetGameTimeMilliseconds() - tauntDetails[TauntHelper.TAUNT_LIST_LASTSEENTIME])/1000

                if tauntExpiresInS > -(TauntHelper.savedVars.afterTauntSeconds) or lastSeenAgoInS < TauntHelper.savedVars.detectSpawnedAddsSeconds then -- lastSeenAgoInMs used to detect loose adds
                    local highlight = false
                    local stacks = 0
                    if TauntHelper.reticleOverUnitId==unitId then
                        highlight=true
                        stacks = TauntHelper.reticleOverStacks
                    end

                    currentBar = currentBar + 1

                    local name = tauntDetails[TauntHelper.TAUNT_LIST_INTERNATIONAL_NAME]
                    local useBarAsCurrent = currentBar
                    if TauntHelper.savedVars.risingTauntBars then
                        useBarAsCurrent = TauntHelper.MAX_NUMBER_OF_BARS-currentBar+1
                    end
                    if TauntHelper.savedVars.displayMobDifficulty then
                        local difficulty = "  "
                        if tauntDetails[TauntHelper.TAUNT_LIST_DIFFICULTY]~=nil then
                            difficulty = string.format('%i ', tauntDetails[TauntHelper.TAUNT_LIST_DIFFICULTY])
                        end
                        name = difficulty .. name
                    end
                    TauntHelper.updateBar(useBarAsCurrent, name, tauntExpiresInS*1000, highlight, stolen, tauntImmunity, stacks)
                end
            end
        end
    else
        TauntHelperTauntStacksFrame:SetHidden(true)
    end


    if TauntHelper.savedVars.risingTauntBars then
        -- lets hide any unused bars
        if currentBar<TauntHelper.MAX_NUMBER_OF_BARS then
            for bar = 1,TauntHelper.MAX_NUMBER_OF_BARS-currentBar do
                TauntHelper.hideBar(bar)
            end
        end

    else
        -- lets hide any unused bars
        if currentBar<TauntHelper.MAX_NUMBER_OF_BARS then
            for bar = currentBar+1,TauntHelper.MAX_NUMBER_OF_BARS do
                TauntHelper.hideBar(bar)
            end
        end
    end

end


