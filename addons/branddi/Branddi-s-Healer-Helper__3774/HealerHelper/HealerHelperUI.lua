
HealerHelper.manuallyShowUi = false

function HealerHelper.showUI()
    if HealerHelper.manuallyShowUi==false then
        HealerHelper.manuallyShowUi = true

        HealerHelperRoFrame:SetMovable(true)
		HealerHelperRoFrame:SetMouseEnabled(true)
        HealerHelperRoFrame:SetHidden(false)

        HealerHelperCombatMessageFrame:SetMovable(true)
		HealerHelperCombatMessageFrame:SetMouseEnabled(true)
        HealerHelperCombatMessageFrame:SetHidden(false)

        HealerHelperGearMessageFrame:SetMovable(true)
		HealerHelperGearMessageFrame:SetMouseEnabled(true)
        HealerHelperGearMessageFrame:SetHidden(false)

        HealerHelper.skillSuggesterUpdateTimer()
        HealerHelperFrame_BG:SetHidden(false)

        HealerHelperFrame_Icon7:SetTexture("HealerHelper/icons/arrow-purple.dds")
        HealerHelperFrame_Icon7:SetHidden(false)

        HealerHelperFrame_Potion1:SetTexture("HealerHelper/icons/arrow-smallgreen.dds")
        HealerHelperFrame_Potion1:SetHidden(false)
        HealerHelperFrame_Potion2:SetTexture("HealerHelper/icons/arrow-smallgreenflipped.dds")
        HealerHelperFrame_Potion2:SetHidden(false)


    else
        HealerHelper.manuallyShowUi = false


        HealerHelperRoFrame:SetMovable(false)
		HealerHelperRoFrame:SetMouseEnabled(false)
        HealerHelperRoFrame:SetHidden(true)


        HealerHelperCombatMessageFrame:SetMovable(false)
		HealerHelperCombatMessageFrame:SetMouseEnabled(false)
        HealerHelperCombatMessageFrame:SetHidden(true)

        HealerHelperGearMessageFrame:SetMovable(false)
		HealerHelperGearMessageFrame:SetMouseEnabled(false)
        HealerHelperGearMessageFrame:SetHidden(true)


        HealerHelper.skillSuggesterUpdateTimer()
        HealerHelperFrame_BG:SetHidden(true)


        HealerHelperFrame_Icon7:SetHidden(true)
        HealerHelperFrame_Potion1:SetHidden(true)
        HealerHelperFrame_Potion2:SetHidden(true)
    end
end



function HealerHelper.printHelp()

    if HealerHelper.savedVars.extraFeatures then
        d("/hh ?            --> display this list")
        d("/hh help         --> display this list")

        d("/hh dev          --> toggle development mode")
        d("/hh ui           --> toggle advanced ui")
        d("/hh debug        --> dump skill debug info")
        d("/hh skillsuggest --> test one cycle of skill selection")
        d("/hh sets         --> dump sets debug info")
        d("/hh mtbeta       --> toggle beta for minor toughness")
        d("/hh mtdebug      --> dump debug info for minor toughness")
    end

end


function HealerHelper.toggleExtraFeatures()
    HealerHelper.savedVars.extraFeatures = not HealerHelper.savedVars.extraFeatures
    if HealerHelper.savedVars.extraFeatures then
        d("HealerHelper: Development features enabled (reloadui required)")
    else
        d("HealerHelper: Development features disabled (reloadui required)")
    end
end


function HealerHelper.toggleAdvancedUI()
    HealerHelper.savedVars.advancedUI = not HealerHelper.savedVars.advancedUI
    if HealerHelper.savedVars.advancedUI then
        d("HealerHelper: Advanced UI features enabled (reloadui required)")
    else
        d("HealerHelper: Advanced UI features disabled (reloadui required)")
    end
end


function HealerHelper.slashCommands(name)
    --d("HealerHelper.slashCommands("..name..")")
    if name == nil then return HealerHelper.printHelp() end
    if name == "" then return HealerHelper.printHelp() end
    if name == "?" then return HealerHelper.printHelp() end
    if name == "help" then return HealerHelper.printHelp() end

    --if name == "gamepad" then return HealerHelper.gamepadMode() end


    if name == "dev" then return HealerHelper.toggleExtraFeatures() end

    if name == "trauma" then return HealerHelper.printTraumaDebug() end



    if HealerHelper.savedVars.extraFeatures then
        if name == "debug" then return HealerHelper.printDebug() end
        --if name == "skillsuggest" then return HealerHelper.doSkillSelectionTasks() end

        if name == "sets" then return HealerHelper.printSets() end

        if name == "mtdebug" then return HealerHelper.minorToughnessDebugToggle() end
        if name == "mtbeta" then return HealerHelper.minorToughnessBetaToggle() end

        if name == "ui" then return HealerHelper.toggleAdvancedUI() end

    end

end




function HealerHelper.savePos()
	HealerHelper.savedVars.ROoffsetX = HealerHelperRoFrame:GetLeft()
	HealerHelper.savedVars.ROoffsetY = HealerHelperRoFrame:GetTop()

  	HealerHelper.savedVars.CombatMessageOffsetX = HealerHelperCombatMessageFrame:GetLeft()
	HealerHelper.savedVars.CombatMessageOffsetY = HealerHelperCombatMessageFrame:GetTop()

  	HealerHelper.savedVars.GearMessageOffsetX = HealerHelperGearMessageFrame:GetLeft()
	HealerHelper.savedVars.GearMessageOffsetY = HealerHelperGearMessageFrame:GetTop()


end



function HealerHelper.setArrowColor(position, color)

    --if true then return end
    local flipped = ""
    if position >= 8 and position ~= 101 then -- 101 is potion top icon
        flipped="flipped"
    end
    local texture = string.format("HealerHelper/icons/arrow-%s%s.dds", color, flipped)
    --if HealerHelper.movingUI then return end -- prevent changing icons during moving UI


    if (mcolor == "") or (IsReticleHidden() and HealerHelper.manuallyShowUi==false)  then
          if position == 1 then
            HealerHelperFrame_Icon1:SetHidden(true)
        elseif position == 2 then
            HealerHelperFrame_Icon2:SetHidden(true)
        elseif position == 3 then
            HealerHelperFrame_Icon3:SetHidden(true)
        elseif position == 4 then
            HealerHelperFrame_Icon4:SetHidden(true)
        elseif position == 5 then
            HealerHelperFrame_Icon5:SetHidden(true)
        elseif position == 6 then -- ultimate
            HealerHelperFrame_Icon6:SetHidden(true)
        elseif position == 7 then -- HA status
            HealerHelperFrame_Icon7:SetHidden(true)

        elseif position == 8 then
            HealerHelperFrame_Icon8:SetHidden(true)
        elseif position == 9 then
            HealerHelperFrame_Icon9:SetHidden(true)
        elseif position == 10 then
            HealerHelperFrame_Icon10:SetHidden(true)
        elseif position == 11 then
            HealerHelperFrame_Icon11:SetHidden(true)
        elseif position == 12 then
            HealerHelperFrame_Icon12:SetHidden(true)
        elseif position == 13 then -- ultimate
            HealerHelperFrame_Icon13:SetHidden(true)
        --elseif position == 14 then -- HA status
        --    HealerHelperFrame_Icon14:SetHidden(true)

        elseif position == 101 then
            HealerHelperFrame_Potion1:SetHidden(true)
        elseif position == 102 then
            HealerHelperFrame_Potion2:SetHidden(true)



        end

    else
        if position == 1 then
            HealerHelperFrame_Icon1:SetTexture(texture)
            HealerHelperFrame_Icon1:SetHidden(false)
        elseif position == 2 then
            HealerHelperFrame_Icon2:SetTexture(texture)
            HealerHelperFrame_Icon2:SetHidden(false)
        elseif position == 3 then
            HealerHelperFrame_Icon3:SetTexture(texture)
            HealerHelperFrame_Icon3:SetHidden(false)
        elseif position == 4 then
            HealerHelperFrame_Icon4:SetTexture(texture)
            HealerHelperFrame_Icon4:SetHidden(false)
        elseif position == 5 then
            HealerHelperFrame_Icon5:SetTexture(texture)
            HealerHelperFrame_Icon5:SetHidden(false)
        elseif position == 6 then -- ultimate
            HealerHelperFrame_Icon6:SetTexture(texture)
            HealerHelperFrame_Icon6:SetHidden(false)
        elseif position == 7 then -- ha status
            HealerHelperFrame_Icon7:SetTexture(texture)
            HealerHelperFrame_Icon7:SetHidden(false)

        elseif position == 8 then
            HealerHelperFrame_Icon8:SetTexture(texture)
            HealerHelperFrame_Icon8:SetHidden(false)
        elseif position == 9 then
            HealerHelperFrame_Icon9:SetTexture(texture)
            HealerHelperFrame_Icon9:SetHidden(false)
        elseif position == 10 then
            HealerHelperFrame_Icon10:SetTexture(texture)
            HealerHelperFrame_Icon10:SetHidden(false)
        elseif position == 11 then
            HealerHelperFrame_Icon11:SetTexture(texture)
            HealerHelperFrame_Icon11:SetHidden(false)
        elseif position == 12 then
            HealerHelperFrame_Icon12:SetTexture(texture)
            HealerHelperFrame_Icon12:SetHidden(false)
        elseif position == 13 then -- ultimate
            HealerHelperFrame_Icon13:SetTexture(texture)
            HealerHelperFrame_Icon13:SetHidden(false)
        --elseif position == 14 then -- ha status
        --    HealerHelperFrame_Icon14:SetTexture(texture)
        --    HealerHelperFrame_Icon14:SetHidden(false)

        elseif position == 101 then
            HealerHelperFrame_Potion1:SetTexture(texture)
            HealerHelperFrame_Potion1:SetHidden(false)
        elseif position == 102 then
            HealerHelperFrame_Potion2:SetTexture(texture)
            HealerHelperFrame_Potion2:SetHidden(false)

        end
    end
end


function HealerHelper.adjustFrameLocation()

	HealerHelperRoFrame:ClearAnchors()
	HealerHelperRoFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, HealerHelper.savedVars.ROoffsetX, HealerHelper.savedVars.ROoffsetY)

	HealerHelperCombatMessageFrame:ClearAnchors()
	HealerHelperCombatMessageFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, HealerHelper.savedVars.CombatMessageOffsetX, HealerHelper.savedVars.CombatMessageOffsetY)


	HealerHelperGearMessageFrame:ClearAnchors()
	HealerHelperGearMessageFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, HealerHelper.savedVars.GearMessageOffsetX, HealerHelper.savedVars.GearMessageOffsetY)


    -- setup changes based on gamepad mode
    local extraGap = 0
    local extraHeight = 0
    local extraVerticalOffset = 0
    if IsInGamepadPreferredMode() then
        extraGap=21
        extraHeight=186-158
        extraVerticalOffset=63-56
        if HealerHelper.AreHotKeysVisible() then
            extraHeight = extraHeight + 25
        end
    else
        if HealerHelper.AreHotKeysVisible() then
            extraHeight = extraHeight + 15
        end
        if FancyActionBar == nil then
            extraVerticalOffset = -27
            extraHeight = extraHeight - 52
        end
    end

    HealerHelperFrame:SetDimensions(HealerHelperFrame:GetWidth(),HealerHelper.savedVars.height+extraHeight)

    HealerHelper.savedVars.arrowWidth=52
    HealerHelper.savedVars.arrowYOffset=0
    HealerHelper.savedVars.arrowHeight=26




    HealerHelperFrame_GapP1to1:SetDimensions(58+(HealerHelper.savedVars.gapWidth+extraGap)/2,HealerHelper.savedVars.arrowWidth)
    HealerHelperFrame_GapP2to8:SetDimensions(58+(HealerHelper.savedVars.gapWidth+extraGap)/2,HealerHelper.savedVars.arrowWidth)

    HealerHelperFrame_Gap1to2:SetDimensions((HealerHelper.savedVars.gapWidth+extraGap),HealerHelper.savedVars.arrowWidth)
    HealerHelperFrame_Gap2to3:SetDimensions((HealerHelper.savedVars.gapWidth+extraGap),HealerHelper.savedVars.arrowWidth)
    HealerHelperFrame_Gap3to4:SetDimensions((HealerHelper.savedVars.gapWidth+extraGap),HealerHelper.savedVars.arrowWidth)
    HealerHelperFrame_Gap4to5:SetDimensions((HealerHelper.savedVars.gapWidth+extraGap),HealerHelper.savedVars.arrowWidth)

    HealerHelperFrame_Icon1:SetDimensions(HealerHelper.savedVars.arrowWidth,HealerHelper.savedVars.arrowHeight)
    HealerHelperFrame_Icon2:SetDimensions(HealerHelper.savedVars.arrowWidth,HealerHelper.savedVars.arrowHeight)
    HealerHelperFrame_Icon3:SetDimensions(HealerHelper.savedVars.arrowWidth,HealerHelper.savedVars.arrowHeight)
    HealerHelperFrame_Icon4:SetDimensions(HealerHelper.savedVars.arrowWidth,HealerHelper.savedVars.arrowHeight)
    HealerHelperFrame_Icon5:SetDimensions(HealerHelper.savedVars.arrowWidth,HealerHelper.savedVars.arrowHeight)
    HealerHelperFrame_Icon6:SetDimensions(HealerHelper.savedVars.arrowWidth,HealerHelper.savedVars.arrowHeight)

    HealerHelperFrame_GapUltimate:SetDimensions(10+(HealerHelper.savedVars.gapWidth+extraGap)*3.1,HealerHelper.savedVars.arrowWidth)



    HealerHelperFrame_Gap8to9:SetDimensions((HealerHelper.savedVars.gapWidth+extraGap),HealerHelper.savedVars.arrowWidth)
    HealerHelperFrame_Gap9to10:SetDimensions((HealerHelper.savedVars.gapWidth+extraGap),HealerHelper.savedVars.arrowWidth)
    HealerHelperFrame_Gap10to11:SetDimensions((HealerHelper.savedVars.gapWidth+extraGap),HealerHelper.savedVars.arrowWidth)
    HealerHelperFrame_Gap11to12:SetDimensions((HealerHelper.savedVars.gapWidth+extraGap),HealerHelper.savedVars.arrowWidth)

    HealerHelperFrame_Icon8:SetDimensions(HealerHelper.savedVars.arrowWidth,HealerHelper.savedVars.arrowHeight)
    HealerHelperFrame_Icon9:SetDimensions(HealerHelper.savedVars.arrowWidth,HealerHelper.savedVars.arrowHeight)
    HealerHelperFrame_Icon10:SetDimensions(HealerHelper.savedVars.arrowWidth,HealerHelper.savedVars.arrowHeight)
    HealerHelperFrame_Icon11:SetDimensions(HealerHelper.savedVars.arrowWidth,HealerHelper.savedVars.arrowHeight)
    HealerHelperFrame_Icon12:SetDimensions(HealerHelper.savedVars.arrowWidth,HealerHelper.savedVars.arrowHeight)
    HealerHelperFrame_Icon13:SetDimensions(HealerHelper.savedVars.arrowWidth,HealerHelper.savedVars.arrowHeight)

    HealerHelperFrame_GapUltimate2:SetDimensions(10+(HealerHelper.savedVars.gapWidth+extraGap)*3.1,HealerHelper.savedVars.arrowWidth)

    --HealerHelperFrame_GapUltimate:SetDimensions(10,HealerHelper.savedVars.arrowWidth)
    --HealerHelperFrame_GapUltimate2:SetDimensions(10,HealerHelper.savedVars.arrowWidth)

    local yOffset = -HealerHelper.savedVars.arrowYOffset -- default yOffset

    -- Fancy Action Bar
    local activeWeaponPair = GetActiveWeaponPairInfo()
    yOffset=-HealerHelper.savedVars.arrowWidth*(activeWeaponPair-1)-HealerHelper.savedVars.arrowYOffset





    local actionBar = ZO_ActionBar1

	HealerHelperFrame:ClearAnchors()
    HealerHelperFrame:SetAnchor(TOPLEFT, actionBar, TOPLEFT, 0, -(HealerHelper.savedVars.verticalOffset+extraVerticalOffset))


    if HealerHelperFrame:GetLeft() == actionBar:GetLeft() and HealerHelperFrame:GetTop()==actionBar:GetTop()-(HealerHelper.savedVars.verticalOffset+extraVerticalOffset) then
        HealerHelper.HudHitEdgeOfScreen = false
    else

        --d(HealerHelperFrame:GetTop() - (actionBar:GetTop()-(HealerHelper.savedVars.verticalOffset+extraVerticalOffset)))
        HealerHelper.AdjustControlsPositions()

        if HealerHelperFrame:GetLeft() == actionBar:GetLeft() and HealerHelperFrame:GetTop()==actionBar:GetTop()-(HealerHelper.savedVars.verticalOffset+extraVerticalOffset) then
            HealerHelper.HudHitEdgeOfScreen = false
        else
            HealerHelper.HudHitEdgeOfScreen = true
        end
        --d(HealerHelperFrame:GetTop() - (actionBar:GetTop()-(HealerHelper.savedVars.verticalOffset+extraVerticalOffset)))
    end




    local fontPath = LibMediaProvider:Fetch("font", HealerHelper.savedVars.fontCombatMessage)
    local fontString = fontPath .. "|$(KB_" .. HealerHelper.savedVars.fontSizeCombatMessage .. ")|soft-shadow-thick"

    for i = 1, 4 do
        local frameMessage = _G["HealerHelperCombatMessageFrameMessage" .. i]

        frameMessage:SetFont(fontString)
        frameMessage:SetColor(unpack(HealerHelper.savedVars.fontColorCombatMessage))

    end


    fontPath = LibMediaProvider:Fetch("font", HealerHelper.savedVars.fontBuildMessage)
    fontString = fontPath .. "|$(KB_" .. HealerHelper.savedVars.fontSizeBuildMessage .. ")|soft-shadow-thick"

    for i = 1, 6 do
        local frameMessage = _G["HealerHelperGearMessageFrameMessage" .. i]

        frameMessage:SetFont(fontString)
        frameMessage:SetColor(unpack(HealerHelper.savedVars.fontColorBuildMessage))

    end


end


local GAMEPAD_CONSTANTS =
{
	actionBarOffset = -52-1,
	attributesOffset = -152,
}
local KEYBOARD_CONSTANTS =
{
	actionBarOffset = -22-10,
	attributesOffset = -112,
}


local GAMEPAD_CONSTANTS_WO_FAB =
{
	actionBarOffset = -52-1+32,
	attributesOffset = -152+32,
}
local KEYBOARD_CONSTANTS_WO_FAB =
{
	actionBarOffset = -22-10+27,
	attributesOffset = -112+27,
}


local GAMEPAD_CONSTANTS_HOTKEYS =
{
	actionBarOffset = -52-1-25,
	attributesOffset = -152-25,
}
local KEYBOARD_CONSTANTS_HOTKEYS =
{
	actionBarOffset = -22-10-15,
	attributesOffset = -112-15,
}

HealerHelper.ControlsMoved = false

-- Move action bar and attributes up a bit more than FAB defaults
function HealerHelper.AdjustControlsPositions()
    if HealerHelper.ControlsMoved then
        return -- only move controls 1 time
    end
    local actionBar = ZO_ActionBar1
    local style = {}
    if HealerHelper.AreHotKeysVisible() then
        style = IsInGamepadPreferredMode() and GAMEPAD_CONSTANTS_HOTKEYS or KEYBOARD_CONSTANTS_HOTKEYS
    else
        if FancyActionBar == nil then
            style = IsInGamepadPreferredMode() and GAMEPAD_CONSTANTS_WO_FAB or KEYBOARD_CONSTANTS_WO_FAB
        else
            style = IsInGamepadPreferredMode() and GAMEPAD_CONSTANTS or KEYBOARD_CONSTANTS
        end

    end

    local anchor = ZO_Anchor:New()
    anchor:SetFromControlAnchor(actionBar)
    anchor:SetOffsets(nil, style.actionBarOffset)
    anchor:Set(actionBar)

    anchor:SetFromControlAnchor(ZO_PlayerAttribute)
    anchor:SetOffsets(nil, style.attributesOffset)
    anchor:Set(ZO_PlayerAttribute)
    HealerHelper.ControlsMoved = true
end
