HealerHelper.SET_BARS_NONE = 0
HealerHelper.SET_BARS_FRONT = 1
HealerHelper.SET_BARS_BACK = 2
HealerHelper.SET_BARS_BOTH = 3


HealerHelper.SET_META_NONE          = 0  -- other
HealerHelper.SET_META_FIVE_PIECE    = 1  -- 5 piece body/weapons
HealerHelper.SET_META_TWO_PIECE_TOP = 2  -- head/shoulders
HealerHelper.SET_META_ARENA_RESTO   = 3  -- restoration arena staff
HealerHelper.SET_META_ARENA_DESTRO  = 4  -- destruction arean staff



-- after switching to combat we will check front bar 1 time, and backbar 1 time
-- while out of  combat we check front and backbar during each barswap
HealerHelper.EquipedTrackingBars = {false,false, false, false} -- front bar set items, back bar set items colelcted yet?


-- list of meta gear sets worn by healers, other non-meta sets will trigger gear warnings
HealerHelper.GearSetsData = {
	-- Set name                     meta  Set in link code                                                                  set size, front, back
	["Spell Power Cure"]        = { true, "|H1:item:111889:364:50:26582:370:50:18:0:0:0:0:0:0:0:2049:29:0:1:0:7299:0|h|h",        5,    0,    0, HealerHelper.SET_META_FIVE_PIECE},
	["Spaulder of Ruin"]        = { true, "|H1:item:181695:364:50:0:0:0:18:0:0:0:0:0:0:0:2049:10:0:1:0:9340:0|h|h",               1,    0,    0, HealerHelper.SET_META_TWO_PIECE_TOP},
	["Master Architect"]        = { true, "|H1:item:124293:364:50:0:0:0:18:0:0:0:0:0:0:0:2049:60:0:1:0:6850:0|h|h",               5,    0,    0, HealerHelper.SET_META_FIVE_PIECE},
	["War Machine"]             = { true, "|H1:item:124095:364:50:26583:370:50:33:0:0:0:0:0:0:0:1:60:0:1:0:0:0|h|h",              5,    0,    0, HealerHelper.SET_META_FIVE_PIECE},
	["Archdruid"]               = { true, "|H1:item:189351:364:50:26582:370:50:18:0:0:0:0:0:0:0:2049:67:0:1:0:10000:0|h|h",       2,    0,    0, HealerHelper.SET_META_TWO_PIECE_TOP},
	["Pillager's"]              = { true, "|H1:item:187086:364:50:0:0:0:18:0:0:0:0:0:0:0:2049:130:0:1:0:9700:0|h|h",              5,    0,    0, HealerHelper.SET_META_FIVE_PIECE},
	["Pearls of Ehlnofey"]      = { true, "|H1:item:171437:364:50:45884:370:50:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h",                1,    0,    0, HealerHelper.SET_META_NONE},
	["Oakensoul"]               = { true, "|H1:item:187658:364:50:45883:370:50:31:0:0:0:0:0:0:0:2049:0:0:1:0:0:0|h|h",            1,    0,    0, HealerHelper.SET_META_NONE},
	["Olorime's"]               = { true, "|H1:item:137334:364:50:26844:370:50:2:0:0:0:0:0:0:0:2049:73:0:1:0:296:0|h|h",          5,    0,    0, HealerHelper.SET_META_FIVE_PIECE},
	["Roaring Opportunist's"]   = { true, "|H1:item:162509:364:50:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h",                       5,    0,    0, HealerHelper.SET_META_FIVE_PIECE},
	["Martial Knowledge"]       = { true, "|H1:item:95504:364:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:1000:0|h|h",                     5,    0,    0, HealerHelper.SET_META_FIVE_PIECE},
	["Z'en's"]                  = { true, "|H1:item:153101:364:50:26848:370:50:2:0:0:0:0:0:0:0:2049:89:0:1:0:352:0|h|h",          5,    0,    0, HealerHelper.SET_META_FIVE_PIECE},
	["Powerful Assault"]        = { true, "|H1:item:117102:364:50:68343:370:50:0:0:0:0:0:0:0:0:1:24:0:1:0:8350:0|h|h",            5,    0,    0, HealerHelper.SET_META_FIVE_PIECE},
	["Jorvuld's"]               = { true, "|H1:item:129120:364:50:0:0:0:2:0:0:0:0:0:0:0:2049:70:0:1:0:451:0|h|h",                 5,    0,    0, HealerHelper.SET_META_FIVE_PIECE},
	["Master's Restoration"]    = { true, "|H1:item:166064:364:50:26844:370:50:2:0:0:0:0:0:0:0:2049:1:0:1:0:251:0|h|h",           2,    0,    0, HealerHelper.SET_META_ARENA_RESTO},
	["Blackrose Restoration"]   = { true, "|H1:item:145179:364:50:54484:370:50:1:0:0:0:0:0:0:0:2049:80:0:1:0:477:0|h|h",          2,    0,    0, HealerHelper.SET_META_ARENA_RESTO},
	["Maelstrom's Restoration"] = { true, "|H1:item:166218:364:50:54484:370:50:0:0:0:0:0:0:0:0:1:14:0:1:0:56:0|h|h",              2,    0,    0, HealerHelper.SET_META_ARENA_RESTO},
	["Crushing Wall"]           = { true, "|H1:item:166266:364:50:26848:370:50:4:0:0:0:0:0:0:0:1:14:0:1:0:34:0|h|h",              2,    0,    0, HealerHelper.SET_META_ARENA_DESTRO},
    ["Destructive Impact"]      = { true, "|H1:item:166062:364:50:5365:370:50:3:0:0:0:0:0:0:0:2049:5:0:1:0:161:0|h|h",            2,    0,    0, HealerHelper.SET_META_ARENA_DESTRO},
	["Symphony of Blades"]      = { true, "|H1:item:147237:364:50:0:0:0:18:0:0:0:0:0:0:0:2049:67:0:1:0:9367:0|h|h",               2,    0,    0, HealerHelper.SET_META_TWO_PIECE_TOP},
	["Ozezan the Inferno's"]    = {false, "|H1:item:193707:363:50:0:0:0:0:0:0:0:0:0:0:0:1:67:0:1:0:10000:0|h|h",                  2,    0,    0, HealerHelper.SET_META_TWO_PIECE_TOP},
	["Nazaray"]                 = { true, "|H1:item:183825:364:50:68343:370:50:11:0:0:0:0:0:0:0:2049:67:0:1:0:10000:0|h|h",       2,    0,    0, HealerHelper.SET_META_TWO_PIECE_TOP},
	["Catalyst"]                = { true, "|H1:item:164865:364:50:26587:370:50:26:0:0:0:0:0:0:0:2049:107:0:1:0:104:0|h|h",        5,    0,    0, HealerHelper.SET_META_FIVE_PIECE},
	["Crypcanon"]               = { true, "|H1:item:194509:364:50:0:0:0:0:0:0:0:0:0:0:0:2048:0:0:0:0:10000:0|h|h",                1,    0,    0, HealerHelper.SET_META_NONE},


}


HealerHelper.blackroseRestorationSkills = {
    [40130]={true,"Ward Ally"},
    [40126]={true,"Healing Ward"},
	[37232]={true,"Steadfast Ward"},
}

HealerHelper.maelstromRestorationSkills = {
    [40079]={true,"Radiating Regeneration"},
	[40076]={true,"Rapid Regeneration"},
	[28536]={true,"Regeneration"},
}

HealerHelper.mastersRestorationSkills = {
    [40060]={true,"Healing Springs"},
    [40058]={true,"Illustrious Healing"},
	[28385]={true,"Grand Healing"},
}

HealerHelper.crushingWallSkills = {
    [39073]={true,"Unstable Wall of Storms"},
    [39053]={true,"Unstable Wall of Fire"},
	[39067]={true,"Unstable Wall of Frost"},

	[39012]={true,"Blockade of Fire"},
    [39018]={true,"Blockade of Storms"},
	[39028]={true,"Blockade of Frost"},
}


function HealerHelper.seenGearOnBohBars()
	return HealerHelper.EquipedTrackingBars[1] and HealerHelper.EquipedTrackingBars[2] and HealerHelper.EquipedTrackingBars[3] and HealerHelper.EquipedTrackingBars[4]
end

function HealerHelper.clearSetCountersAsEnteringCombat()
	-- set both bars as needs to be read for sets on next swap
	HealerHelper.EquipedTrackingBars = {false,false, false, false}
end

function HealerHelper.countEquipedSets(forced)
	local bar = HealerHelper.currentBar
	if bar < 1 or bar > 2  then -- SG WW phase will appear as Bar 0
		-- d("bar = ".. bar)
		return
	end

	if (HealerHelper.inCombat == false) or (HealerHelper.EquipedTrackingBars[bar]==false) or (HealerHelper.EquipedTrackingBars[bar+2]==false) or forced then -- check sets out of combat, or anytime in combat and not checked current bar yet

		HealerHelper.GearSetsData["Ozezan the Inferno's"][1] = HealerHelper.savedVars.ozezanMeta

		if HealerHelper.inCombat then
			if HealerHelper.EquipedTrackingBars[bar]==true then
				HealerHelper.EquipedTrackingBars[bar+2]=true -- indicates that the bar is measured for Equiped sets and no longer needs to be updated until out of combat
			else
				HealerHelper.EquipedTrackingBars[bar]=true -- indicates that the bar is measured for Equiped sets and no longer needs to be updated until out of combat
			end
		end

		for k, v in pairs(HealerHelper.GearSetsData) do
			HealerHelper.GearSetsData[k][bar+3] = HealerHelper.countGearSetEquipped(k)
		end


		-- messages for gear setups
		HealerHelper.setMessage("Backbar_SPC", HealerHelper.getGetSetBars("Spell Power Cure")==2 and HealerHelper.seenGearOnBohBars())

		HealerHelper.setMessage("Onebar_SPC", HealerHelper.getGetSetBars("Spell Power Cure")==1 and HealerHelper.checkIfGearSetEquipped("Pearls of Ehlnofey")==false and HealerHelper.seenGearOnBohBars())

		HealerHelper.setMessage("Onebar_Jorvulds", (HealerHelper.getGetSetBars("Jorvuld's")==1 or HealerHelper.getGetSetBars("Jorvuld's")==2) and HealerHelper.seenGearOnBohBars())

		HealerHelper.setMessage("ROwoJO", (HealerHelper.CountPlayersInGroupAndZone()>4 and HealerHelper.checkIfGearSetEquipped("Roaring Opportunist's") and HealerHelper.checkIfGearSetEquipped("Jorvuld's")==false) and HealerHelper.savedVars.metaGearWarnings and HealerHelper.seenGearOnBohBars())

		HealerHelper.setMessage("DungeonROJO", (HealerHelper.CountPlayersInGroupAndZone()>=3 and  HealerHelper.CountPlayersInGroupAndZone()<=4 and HealerHelper.checkIfGearSetEquipped("Roaring Opportunist's") and HealerHelper.checkIfGearSetEquipped("Jorvuld's")) and HealerHelper.savedVars.metaGearWarnings and HealerHelper.seenGearOnBohBars())


		HealerHelper.setMessage("PA_Skill", HealerHelper.skillMissingToProcPowerfulAssault() and HealerHelper.seenGearOnBohBars())
		HealerHelper.setMessage("Olo_Skill", HealerHelper.skillMissingToProcOlorime() and HealerHelper.seenGearOnBohBars())

		HealerHelper.setMessage("MissingOneFivePieceSet", HealerHelper.countFivePieceSets()==1 and HealerHelper.savedVars.metaGearWarnings and HealerHelper.seenGearOnBohBars())
		HealerHelper.setMessage("MissingTwoFivePieceSets", HealerHelper.countFivePieceSets()==0 and HealerHelper.savedVars.metaGearWarnings and HealerHelper.seenGearOnBohBars())
		HealerHelper.setMessage("MissingTopSet", HealerHelper.hasTwoPieceTopSets()==false and HealerHelper.savedVars.metaGearWarnings and HealerHelper.seenGearOnBohBars())

		HealerHelper.setMessage("BRPResto_Skill", HealerHelper.skillMissingToProc("Blackrose Restoration",HealerHelper.blackroseRestorationSkills) and HealerHelper.seenGearOnBohBars())
		HealerHelper.setMessage("MAResto_Skill", HealerHelper.skillMissingToProc("Maelstrom's Restoration",HealerHelper.maelstromRestorationSkills) and HealerHelper.seenGearOnBohBars())
		HealerHelper.setMessage("DSAResto_Skill", HealerHelper.skillMissingToProc("Master's Restoration",HealerHelper.mastersRestorationSkills) and HealerHelper.seenGearOnBohBars())

		HealerHelper.setMessage("MADestro_Skill", HealerHelper.skillMissingToProc("Crushing Wall",HealerHelper.crushingWallSkills) and HealerHelper.seenGearOnBohBars())

		HealerHelper.setMessage("Oakensoul", HealerHelper.checkIfGearSetEquipped("Oakensoul"))

	end
end

-- /script d(HealerHelper.countGearSetEquipped("Spaulder of Ruin"))
function HealerHelper.countGearSetEquipped(setName)
	if HealerHelper.GearSetsData[setName]==nil then
		d("HH: Error 1 Gear set ".. setName .. " not found")
		return 0
	end
	local _,_,_,np,_,_,p = GetItemLinkSetInfo(HealerHelper.GearSetsData[setName][2], true)
	return np+p
end

function HealerHelper.checkIfGearSetEquipped(setName)
	if HealerHelper.GearSetsData[setName]==nil then
		d("HH: Error 2 Gear set ".. setName .. " not found")
		return false
	end
	if HealerHelper.GearSetsData[setName][4]>=HealerHelper.GearSetsData[setName][3] or HealerHelper.GearSetsData[setName][5]>=HealerHelper.GearSetsData[setName][3] then
		return true
	else
		return false
	end
end

function HealerHelper.getGetSetBars(setName)
	if HealerHelper.GearSetsData[setName]==nil then
		d("HH: Error 3 Gear set ".. setName .. " not found")
		return HealerHelper.SET_BARS_NONE
	end
	if HealerHelper.GearSetsData[setName][4] >= HealerHelper.GearSetsData[setName][3] and HealerHelper.GearSetsData[setName][5] >= HealerHelper.GearSetsData[setName][3] then
		return HealerHelper.SET_BARS_BOTH -- set active on either bar
	elseif HealerHelper.GearSetsData[setName][4]>=HealerHelper.GearSetsData[setName][3] then
		return HealerHelper.SET_BARS_FRONT -- set only active on front bar
	elseif  HealerHelper.GearSetsData[setName][5]>=HealerHelper.GearSetsData[setName][3] then
		return HealerHelper.SET_BARS_BACK -- set only active on back bar
	else
		return HealerHelper.SET_BARS_NONE -- set not active on any bar
	end
end

function HealerHelper.printSets()
	d("HH -- Sets debug dump --")

	for k, v in pairs(HealerHelper.GearSetsData) do
		if HealerHelper.checkIfGearSetEquipped(k) then
			d(k.." - bars: " .. HealerHelper.getGetSetBars(k))
		end
	end
	if HealerHelper.hasTwoPieceTopSets() then
		d("2p set: true")
	else
		d("2p set: false")
	end
	d("5p sets:"..HealerHelper.countFivePieceSets())

end

function HealerHelper.OnGearUpdate(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange, triggeredByCharacterName, triggeredByDisplayName, isLastUpdateForMessage)
	HealerHelper.countEquipedSets(true)
end

function HealerHelper.countFivePieceSets()
	local sets = 0
	for k, v in pairs(HealerHelper.GearSetsData) do
		if v[1] == true then -- meta set
			if v[6]==HealerHelper.SET_META_FIVE_PIECE then
				if HealerHelper.checkIfGearSetEquipped(k) then
					sets = sets +1

				end
			end
		end
	end
	return sets
end

function HealerHelper.hasTwoPieceTopSets()
	local sets = 0
	for k, v in pairs(HealerHelper.GearSetsData) do
		if v[1] == true then
			if v[6]==HealerHelper.SET_META_TWO_PIECE_TOP then
				if HealerHelper.checkIfGearSetEquipped(k) then
					sets = sets +1
				end
			end
		end
	end
	if sets >= 1 then
		return true
	else
		return false
	end
end

HealerHelper.GetSetTrackingEnable = false

function HealerHelper.InitialiseGetSetsTracking()


    if HealerHelper.GetSetTrackingEnable == false then

        EVENT_MANAGER:RegisterForEvent(HealerHelper.name .. "GetSetsTracking" , EVENT_INVENTORY_SINGLE_SLOT_UPDATE, HealerHelper.OnGearUpdate)
        EVENT_MANAGER:AddFilterForEvent(HealerHelper.name .. "GetSetsTracking" , EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)

        HealerHelper.GetSetTrackingEnable = true
    end
end

function HealerHelper.DeinitialiseGetSetsTracking()
    if HealerHelper.GetSetTrackingEnable == true then
		EVENT_MANAGER:UnregisterForEvent(HealerHelper.name .. "GetSetsTracking" , EVENT_INVENTORY_SINGLE_SLOT_UPDATE)

        HealerHelper.GetSetTrackingEnable = false
    end
end

function HealerHelper.skillMissingToProc(setName,skills)


    if HealerHelper.checkIfGearSetEquipped(setName) then

        for i=1,12 do
            if i == 6 or i == 12 then
                -- skip ultimates
            else
                local skillSlot = i -- 1,2,3,4,5    7,8,9,10,11

                local bar = 1
                if i >= 7 then
                    bar = 2
                end

                local skillId = HealerHelper.Skills[skillSlot]
                if HealerHelper.getGetSetBars(setName)==3 or  HealerHelper.getGetSetBars(setName)==bar then
                    if skills[skillId]~= nil then
                        if skills[skillId][1] == true then
                            return false -- found a skill to proc PA
                        end
                    end
                end
            end
        end
        return true -- no skills to proc set
    else
        return false -- not wearing proc set
    end
end

