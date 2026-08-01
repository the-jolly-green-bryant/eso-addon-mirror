AI = {}

AI.name = "AwesomeInfo"
AI.version = "2.11"
AI.initialised = false
AI.moving = false

local LMP = LibStub('LibMediaProvider-1.0')

-- Set-up the defaults options for saved variables.
AI.defaults = {
    locx            = 1375,
    locy            = 30,
    scaling         = 1.0,
    textAlign       = "CENTER",
    clockShow       = true,
    clock24         = true,
    clockSpace      = 15,
    notifFontSize   = 16,
    dateShow        = false,
    skillsShow      = true,
    bagsShow        = true,
    bagsWarn        = 10,       -- this is in MINUTES
    bagsCritical    = 5,        -- this is in MINUTES
    duraShow        = true,
    duraWarning     = 25,       -- percentage
    duraCritical    = 10,       -- percentage
    researchShow    = true,
    horseShow       = true,
    horseWarning    = 30,       -- this is in MINUTES
    resSmithShow    = {},       -- these are effectively arrays based on character name.
    resClothShow    = {},
    resWoodShow     = {},
    resWarning      = 120,      -- this is in MINUTES
    weaponShow      = true,
    weaponWarning   = 50,       -- percentage
    weaponCritical  = 20,       -- percentage
    windowLocked    = false,
    show2shard      = false,
    show1shard      = false,
    fenceShow	    = false,
    sellShow	    = false,
    sellWarning	    = 10,
    sellCritical    = 2,
    launderShow	    = false,
    launderWarning  = 10,
    launderCritical = 2,
}

function AI.Initialise(eventCode, addOnName)

    -- Only initialize our own addon
    if (AI.name ~= addOnName) then return end

    -- Load the saved variables
    AI.vars = ZO_SavedVars:NewAccountWide("AI_SavedVariables", 1, nil, AI.defaults)
	
    AI.lastOnUpdate = 0
    AI.duraLastUpdate = 8
    AI.duraFrequency = 10   -- number of seconds between re-checking durability
    AI.characterName = GetUnitName("player")   -- used for character specific settings like crafting

    AI.craftName = {}
    AI.craftName[CRAFTING_TYPE_BLACKSMITHING]   = "Blacksmithing"
    AI.craftName[CRAFTING_TYPE_CLOTHIER]        = "Clothing"
    AI.craftName[CRAFTING_TYPE_WOODWORKING]     = "Woodworking"

    -- Check if the tradeskill research timers have been configured for this character. If not, default to True.
    if (AI.vars.resClothShow[AI.characterName] == nil) then
        AI.vars.resSmithShow[AI.characterName]  = true
        AI.vars.resClothShow[AI.characterName]  = true
        AI.vars.resWoodShow[AI.characterName]   = true
    end
	
    -- Set-up all the labels. They're created in the XML but define additional info about them here.
    -- They are also set so that each label is anchored to the bottom of the previous one.
    -- This allows them to link together seamlessly without requiring code to move them around when one is hidden.
    
    AwesomeInfo:SetMovable(AI.vars.windowLocked)

    AwesomeInfoBG:SetAlpha(0)
	
    AwesomeInfoLabelTime:SetAnchor(TOP, AwesomeInfo, TOP, 0, 0)
    AwesomeInfoLabelSkills:SetAnchor(TOP, AwesomeInfoLabelTime, BOTTOM, 0, AI.vars.clockSpace)
    AwesomeInfoLabelBags:SetAnchor(TOP, AwesomeInfoLabelSkills, BOTTOM, 0, 0)
    AwesomeInfoLabelDura:SetAnchor(TOP, AwesomeInfoLabelBags, BOTTOM, 0, 0)
    AwesomeInfoLabelWeapon:SetAnchor(TOP, AwesomeInfoLabelDura, BOTTOM, 0, 0)
    AwesomeInfoLabelRes1:SetAnchor(TOP, AwesomeInfoLabelWeapon, BOTTOM, 0, 0)
    AwesomeInfoLabelRes2:SetAnchor(TOP, AwesomeInfoLabelRes1, BOTTOM, 0, 0)
    AwesomeInfoLabelRes3:SetAnchor(TOP, AwesomeInfoLabelRes2, BOTTOM, 0, 0)
    AwesomeInfoLabelHorse:SetAnchor(TOP, AwesomeInfoLabelRes3, BOTTOM, 0, 0)
    AwesomeInfoLabelShard:SetAnchor(TOP, AwesomeInfoLabelHorse, BOTTOM, 0, 0)
    AwesomeInfoLabelFence:SetAnchor(TOP, AwesomeInfoLabelShard, BOTTOM, 0, 0)
    
    local fragment = ZO_SimpleSceneFragment:New( AwesomeInfo )
    SCENE_MANAGER:GetScene('hud'):AddFragment( fragment )	
    SCENE_MANAGER:GetScene('hudui'):AddFragment( fragment )
	
    AI.SetTextAlign(AI.vars.textAlign)
	
    -- Run various events to set the correct warning flags
    AI.OnInventorySlotUpdate()
    AI.OnSkillsChange()

    -- Invoke config menu set-up
    AI.CreateConfigMenu()

    -- The rest of the event registration is here, rather than with ADD_ON_LOADED because I don't want any of them being
    -- called until after initialisation is complete.

    EVENT_MANAGER:RegisterForEvent("AI", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, AI.OnInventorySlotUpdate)
    EVENT_MANAGER:RegisterForEvent("AI", EVENT_MOUNT_UPDATE, AI.OnMountUpdate)
    EVENT_MANAGER:RegisterForEvent("AI",  EVENT_ATTRIBUTE_UPGRADE_UPDATED , AI.OnSkillsChange)
    EVENT_MANAGER:RegisterForEvent("AI",  EVENT_SKILL_POINTS_CHANGED , AI.OnSkillsChange)

    AI.initialised = true
end -- AI.Initialise


EVENT_MANAGER:RegisterForEvent("AI", EVENT_ADD_ON_LOADED, AI.Initialise)


-- SLASH COMMAND FUNCTIONALITY
-- Typing /ainfo as a command will activate this function. Primarily used for testing.
function AIslash(extra)
    d(AI.vars)
end -- AIslash
 
SLASH_COMMANDS["/ainfo"] = AIslash


function AI.OnUpdate()
    -- Bail if we haven't completed the initialisation routine yet.
    if (not AI.initialised) then return end
    -- Only run this update if a full second has elapsed since last time we did so.
    local curSeconds = GetSecondsSinceMidnight()
    if ( curSeconds ~= AI.lastOnUpdate ) then
        AI.lastOnUpdate = curSeconds
		-- Update the CLOCK if option is enabled
        if (AI.vars.clockShow) then
            local timeFormat = 0
            if (AI.vars.clock24) then
                timeFormat = TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR
            else
                timeFormat = TIME_FORMAT_PRECISION_TWELVE_HOUR
            end
            	
   		local formattedTime = FormatTimeSeconds(GetSecondsSinceMidnight(), TIME_FORMAT_STYLE_CLOCK_TIME, timeFormat, TIME_FORMAT_DIRECTION_NONE)
            	AwesomeInfoLabelTime:SetText(formattedTime)
		AwesomeInfoLabelSkills:SetAnchor(TOP, AwesomeInfoLabelTime, BOTTOM, 0, AI.vars.clockSpace)
        else
            	AwesomeInfoLabelTime:SetText("")
            	AwesomeInfoLabelTime:SetHeight( 0 )
		AwesomeInfoLabelSkills:SetAnchor(TOP, AwesomeInfoLabelTime, BOTTOM, 0, 0)
        end
        
	AI.UpdateFence()
		
		-- LESS FREQUENT CHECK - Only check periodically, every duraFrequency seconds
        AI.duraLastUpdate = AI.duraLastUpdate + 1
        if (AI.duraLastUpdate > AI.duraFrequency) then
            AI.duraLastUpdate = 0
            AI.UpdateMountInfo()
            AI.UpdateDurability()
            AI.UpdateWeaponCharge()
            AI.UpdateResearch()
	    
        end

	AI.UpdateWidthAndHeight()
		
    end
end -- AI.OnUpdate

function AI.UpdateFence()
	if (AI.vars.fenceShow) then
		local textFence = ""
		
		if (AI.vars.sellShow) then
			local sellTotal, sellUsed  = GetFenceSellTransactionInfo()
			local sellLeft = sellTotal - sellUsed
			if (sellLeft <= AI.vars.sellWarning) then		
				if (sellLeft <= AI.vars.sellCritical) then
					textFence = textFence .. "|cFF6060Sells left:|r " .. sellLeft   -- faded red
				else
					textFence = textFence .. "|cFFFF60Sells left:|r " .. sellLeft   -- faded yellow
				end	
			end
		end
		if (AI.vars.launderShow) then
			local launderTotal, launderUsed  = GetFenceLaunderTransactionInfo()
			local launderLeft = launderTotal - launderUsed
			if (launderLeft <= AI.vars.launderWarning) then
				if (textFence ~= "") then
					textFence = textFence .. " "
				end
				if (launderLeft <= AI.vars.launderCritical) then
					textFence = textFence .. "|cFF6060Launders left:|r " .. launderLeft   -- faded red
				else
					textFence = textFence .. "|cFFFF60Launders left:|r " .. launderLeft   -- faded yellow
				end	
			end
		end
		AwesomeInfoLabelFence:SetText(textFence)
	else
		AwesomeInfoLabelFence:SetText("")
		AwesomeInfoLabelFence:SetHeight( 0 )
	end
end -- AI.UpdateFence()

function AI.UpdateWidthAndHeight()
	if AI.moving then return end

	local maxWidth = 0;
	local maxHeight = 0;
	
	for i = 2, AwesomeInfo:GetNumChildren() do
		local child = AwesomeInfo:GetChild(i)
		child:SetWidth(0)
		local currentWidth = child:GetTextWidth()
		maxHeight = maxHeight + child:GetTextHeight()
		if (maxWidth < currentWidth) then
			maxWidth = currentWidth
		end
	end
	
	for i = 2, AwesomeInfo:GetNumChildren() do
		local child = AwesomeInfo:GetChild(i)
		child:SetWidth(maxWidth)
	end
    	
	if (AI.vars.clockShow) then	
		maxHeight = maxHeight + AI.vars.clockSpace
	end
	
	AwesomeInfo:SetWidth(maxWidth)
	AwesomeInfo:SetHeight(maxHeight) 

	AI.UpdateAnchor()
end

function AI.UpdateMountInfo()
    if (AI.vars.horseShow) then
        local inventoryBonus, maxInventoryBonus, staminaBonus, maxStaminaBonus, speedBonus, maxSpeedBonus = GetRidingStats()
	local ridingSkillMaxedOut = (inventoryBonus == maxInventoryBonus) and (staminaBonus == maxStaminaBonus) and (speedBonus == maxSpeedBonus)

        local mountTimer = GetTimeUntilCanBeTrained()
        if mountTimer == nil or ridingSkillMaxedOut then  -- fix for characters with no mount, or fully trained mounts.
            AwesomeInfoLabelHorse:SetText("")
            AwesomeInfoLabelHorse:SetHeight( 0 )
            return
        end
        if (mountTimer > 0) then
            mountTimer = math.floor(mountTimer / 60000) -- we only want the time in WHOLE minutes.
            if (mountTimer < AI.vars.horseWarning) then
                local horseTimeFormatted = FormatTimeSeconds(60 * mountTimer, TIME_FORMAT_STYLE_DESCRIPTIVE_SHORT , TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR , TIME_FORMAT_DIRECTION_NONE)
                AwesomeInfoLabelHorse:SetText("Train mount in " .. horseTimeFormatted)
            else
                AwesomeInfoLabelHorse:SetText("")
                AwesomeInfoLabelHorse:SetHeight( 0 )
            end
        else
            AwesomeInfoLabelHorse:SetText("|cFFFF80Mount can be trained|r")  -- yellow
        end
    else
        AwesomeInfoLabelHorse:SetText("")
        AwesomeInfoLabelHorse:SetHeight( 0 )
    end
end -- AI.UpdateMountInfo

function AI.OnInventorySlotUpdate (eventCode,bagId,slotId,isNewItem,itemSoundCategory,updateReason)
    AI.DoUpdateInventory()
    AI.UpdateWeaponCharge()
end -- AI.OnInventorySlotUpdate

function AI.OnMountUpdate(eventCode,mountIndex)
    AI.DoUpdateInventory()
end -- AI.OnMountUpdate

function AI.DoUpdateInventory()
    if (AI.vars.bagsShow) then
        local curInv,maxInv =PLAYER_INVENTORY:GetNumSlots(INVENTORY_BACKPACK)
        local freeInv = maxInv - curInv
        -- d("Free slots: " .. freeInv .. " - Warn: " .. AI.vars.bagsWarn .. " - Crit: " ..AI.vars.bagsCritical)
        if (freeInv <= AI.vars.bagsWarn) then
            AwesomeInfoLabelBags:SetText("Bag space: " .. freeInv)
            if (freeInv <= AI.vars.bagsCritical) then
                AwesomeInfoLabelBags:SetColor(255,0,0,1)    -- red
            else
                AwesomeInfoLabelBags:SetColor(255,255,0,1)  -- yellow
            end
        else
            AwesomeInfoLabelBags:SetText("")
            AwesomeInfoLabelBags:SetHeight( 0 )
        end
    else
        AwesomeInfoLabelBags:SetText("")
        AwesomeInfoLabelBags:SetHeight( 0 )
    end
end -- AI.DoUpdateInventory

function AI.OnSkillsChange(...)
    if (AI.vars.skillsShow) then
        local attributePoints = GetAttributeUnspentPoints()
        local skillPoints = GetAvailableSkillPoints()
        if (attributePoints + skillPoints > 0) then
            local displaytext = ""
            if (attributePoints > 0) then
                displaytext = "|cFFFF60Attributes:|r " .. attributePoints   -- faded yellow
            end
            if (attributePoints > 0 and skillPoints > 0) then
			    displaytext = displaytext .. " " 
			end
			if (skillPoints > 0) then
                displaytext = displaytext .. "|c60FF60Skills:|r " .. skillPoints   -- faded green
            end
            AwesomeInfoLabelSkills:SetText(displaytext)
        else
            AwesomeInfoLabelSkills:SetText("")
            AwesomeInfoLabelSkills:SetHeight( 0 )
        end
    else
        AwesomeInfoLabelSkills:SetText("")
        AwesomeInfoLabelSkills:SetHeight( 0 )
    end
    if (AI.vars.shard1Show or AI.vars.shard2Show) then	
		local shards = GetNumSkyShards()
        local displaytext = ""
		if (shards == 2 and AI.vars.shard1Show) then
			displaytext = displaytext .. "|cFFFF60Shard missing:|r " .. "1"  -- faded red
		end
		if (shards == 1 and AI.vars.shard2Show) then
			displaytext = displaytext .. "|cFFFF60Shard missing:|r " .. "2"  -- faded yellow
		end
        AwesomeInfoLabelShard:SetText(displaytext)		
	else
        AwesomeInfoLabelShard:SetText("")
        AwesomeInfoLabelShard:SetHeight( 0 )
    end	
end -- AI.OnSkillsChange

function AI.UpdateDurability()
    if (AI.vars.duraShow) then
        local minDura = 100
        for i=0,16,1 do
            if (DoesItemHaveDurability(BAG_WORN,i)) then
                minDura = math.min(minDura,GetItemCondition(BAG_WORN,i))
            end
        end
        if (minDura <= AI.vars.duraWarning) then
            local displayText = "Durability: "
            if (minDura <= AI.vars.duraCritical) then
                displayText = displayText .. "|cFF6060" .. minDura .. "%|r  "   -- faded red
            else
                displayText = displayText .. "|cFFFF60" .. minDura .. "%|r  "   -- faded yellow
            end
            displayText = displayText .. "(" .. GetRepairAllCost() .. "g)"
            AwesomeInfoLabelDura:SetText(displayText)
        else
            AwesomeInfoLabelDura:SetText("")
            AwesomeInfoLabelDura:SetHeight( 0 )
        end
    else
        AwesomeInfoLabelDura:SetText("")
        AwesomeInfoLabelDura:SetHeight( 0 )
    end
end -- UpdateDurability

-- Weapon charge alerts
-- Item IDs are 4 & 5 for main weapon set, 20 & 21 for alternate set.
function AI.UpdateWeaponCharge()
    -- This code could probably loop through the four weapon slots or do some sort of table sort, but it's late and this works. :)
    if (AI.vars.duraShow) then
        local lowWeaponIndex = 0
        local lowWeaponValue = 100
        local curCharge
        local weaponChargeTable = { 4, 5, 20, 21 }
        local i,v
        for i,v in ipairs(weaponChargeTable) do
            curCharge = AI.CalcPercentageWeaponCharge(v)
            if (curCharge < lowWeaponValue) then
                lowWeaponValue = curCharge
                lowWeaponIndex = v
            end
        end
        
        if (lowWeaponValue <= AI.vars.weaponWarning) then
            local weaponName = GetItemName(BAG_WORN, lowWeaponIndex) .. " "
            local displayText = zo_strformat(SI_TOOLTIP_ITEM_NAME, weaponName)
            if (lowWeaponValue <= AI.vars.weaponCritical) then
                displayText = displayText .. " |cFF6060" .. lowWeaponValue .. "%|r  "   -- faded red
            else
                displayText = displayText .. " |cFFFF60" .. lowWeaponValue .. "%|r  "   -- faded yellow
            end
            AwesomeInfoLabelWeapon:SetText(displayText)
        else
            AwesomeInfoLabelWeapon:SetText("")
            AwesomeInfoLabelWeapon:SetHeight( 0 )
        end

    else
        AwesomeInfoLabelWeapon:SetText("")
        AwesomeInfoLabelWeapon:SetHeight( 0 )
    end
end -- AI.UpdateWeaponCharge

function AI.CalcPercentageWeaponCharge(slotID)
    local isChargeable = IsItemChargeable(BAG_WORN, slotID)
    if (isChargeable) then
        local charges, maxCharges = GetChargeInfoForItem(BAG_WORN, slotID)
        return math.floor(100 * charges / maxCharges)       -- express as a percentage
    else
        return 100
    end
end -- AI.CalcPercentageWeaponCharge

function AI.MoveStart()
	AI.moving = true
	AwesomeInfoBG:SetAlpha(0.5)
end -- AI.ShowBackdrop

function AI.MoveStop()
	AwesomeInfoBG:SetAlpha(0)

	if (AI.vars.textAlign == "LEFT") then
		AI.vars.locx = AwesomeInfo:GetLeft()
	    	AI.vars.locy = AwesomeInfo:GetTop()
	elseif (AI.vars.textAlign == "CENTER") then
		AI.vars.locx, _ = AwesomeInfo:GetCenter()
	    	AI.vars.locy = AwesomeInfo:GetTop()
	elseif (AI.vars.textAlign == "RIGHT") then
		AI.vars.locx = AwesomeInfo:GetRight()
	    	AI.vars.locy = AwesomeInfo:GetTop()
	end
	AI.moving = false
end -- AI.HideBackdrop

function AI.SetTextAlign(newValue)
    AI.vars.textAlign = newValue
    local alignText = {}
    alignText["LEFT"]   = 0
    alignText["CENTER"] = 1
    alignText["RIGHT"]  = 2



	AI.UpdateAnchor()
	
	for i = 2, AwesomeInfo:GetNumChildren() do
		local child = AwesomeInfo:GetChild(i)
		child:SetHorizontalAlignment(alignText[newValue])
	end
end -- AI.SetTextAlign

function AI.UpdateAnchor()
	AwesomeInfo:ClearAnchors()
	if (AI.vars.textAlign == "LEFT") then
		AwesomeInfo:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, AI.vars.locx, AI.vars.locy)
	elseif (AI.vars.textAlign == "CENTER") then
		AwesomeInfo:SetAnchor(TOP, GuiRoot, TOPLEFT, AI.vars.locx, AI.vars.locy)
	elseif (AI.vars.textAlign == "RIGHT") then
		AwesomeInfo:SetAnchor(TOPRIGHT, GuiRoot, TOPLEFT, AI.vars.locx, AI.vars.locy)
	end
end

-- Function called from timer to display research info
function AI.UpdateResearch()
    UpdateSpecificResearch(AwesomeInfoLabelRes1,AI.vars.resSmithShow[AI.characterName],CRAFTING_TYPE_BLACKSMITHING)
    UpdateSpecificResearch(AwesomeInfoLabelRes2,AI.vars.resClothShow[AI.characterName],CRAFTING_TYPE_CLOTHIER)
    UpdateSpecificResearch(AwesomeInfoLabelRes3,AI.vars.resWoodShow[AI.characterName],CRAFTING_TYPE_WOODWORKING)
end -- AI.UpdateResearch

function UpdateSpecificResearch(thisLabel,doShow,craftType)
    local emptySlots
    local timeRemaining
    local labelText = AI.craftName[craftType]
    if (doShow) then
        emptySlots, timeRemaining = AI.GetResearchTimer(craftType)
        timeRemaining = math.floor(timeRemaining / 60)
        if (timeRemaining < AI.vars.resWarning) then
            if (timeRemaining == 0) then
                labelText = labelText .. " |cFFFF80can research:|r " .. emptySlots
            else
                labelText = labelText .. " " .. FormatTimeSeconds(60 * timeRemaining, TIME_FORMAT_STYLE_DESCRIPTIVE_SHORT , TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR , TIME_FORMAT_DIRECTION_NONE)
            end
            thisLabel:SetText(labelText) 
        else
            thisLabel:SetHeight( 0 )
            thisLabel:SetText("")
        end
    else
        thisLabel:SetHeight( 0 )
        thisLabel:SetText("")
    end

end

function AI.GetResearchTimer(craftType)
    local maxTimer = 2000000
    local maxResearch = GetMaxSimultaneousSmithingResearch(craftType)   -- This is the number of research slots
    local maxLines = GetNumSmithingResearchLines(craftType)     -- This is the number of different items craftable by this profession
    for i = 1, maxLines, 1 do       -- loop through the different craftable items, looking to see if there is research on that item
        name, icon, numTraits, timeRequiredForNextResearchSecs = GetSmithingResearchLineInfo(craftType, i)  -- Get info on that specific item
        for j = 1, numTraits, 1 do      -- loop through the traits, looking for one that is being researched
            duration, timeRemaining = GetSmithingResearchLineTraitTimes(craftType, i, j) 
            if (duration ~= nil and timeRemaining ~= nil) then
                maxResearch = maxResearch - 1
                maxTimer = math.min(maxTimer,timeRemaining)
            end
        end
    end
    if (maxResearch > 0) then   -- There is an unused research slot.
        maxTimer = 0
    end
    return maxResearch, maxTimer
end -- AI.GetResearchTimer
