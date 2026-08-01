CitizenBRP = {
    name = "CitizenBRP",
    waveIcons = {},
}
local lastPortalSpawn = 0
local stage = 0
local round = 0
local wave = 0

--Return current stage
local function GetCurrentStage()
	local x, y = GetMapPlayerPosition('player');

	if x>0.54 and x<0.64 and y>0.79 and y<0.89 then
		return 1
	elseif x>0.3 and x<0.4 and y>0.69 and y<0.8 then
		return 2
	elseif x>0.41 and x<0.52 and y>0.43 and y<0.53 then
		return 3
	elseif x>0.63 and x<0.73 and y>0.22 and y<0.32 then
		return 4
	elseif x>0.4 and x<0.5 and y>0.08 and y<0.18 then
		return 5
	else
		return 0
	end
end

--New wave
local function newWave()
    stage = GetCurrentStage()

	-- STAGE 1
    -- right down mid 104100, 61100, 66150
    -- right up down  103000, 61100, 66150
    -- right up up    102700, 61100, 66150

    -- left down mid  104100, 61100, 70750
    -- left up down   103000, 61100, 70750
    -- left up up     102700, 61100, 70750

    -- entrance right 105750, 61100, 68000
    -- entrance left  105750, 61100, 67600
	if stage == 1 then
        if round == 1 then
            if wave == 1 then
            elseif wave == 2 then
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(104100, 61100, 66150, "/esoui/art/icons/progression_tabicon_bow_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(102700, 61100, 66150, "/esoui/art/icons/progression_tabicon_bow_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(102700, 61100, 70750, "/esoui/art/icons/progression_tabicon_bow_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))

                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(105750, 61100, 68050, "/esoui/art/icons/progression_tabicon_avaleadership_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize+38, nil, nil, CitizenNotifier.OSI.callback.bounce))

            elseif wave == 3 then
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(104100, 61100, 70750, "/esoui/art/icons/progression_tabicon_bow_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(103000, 61100, 70750, "/esoui/art/icons/progression_tabicon_bow_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(103000, 61100, 66150, "/esoui/art/icons/progression_tabicon_bow_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))

                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(105750, 61100, 67600, "/esoui/art/icons/progression_tabicon_1handed_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize+38, nil, nil, CitizenNotifier.OSI.callback.bounce))

            end
        elseif round == 2 then
            if wave == 1 then
            elseif wave == 2 then --Trigger, one add left
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(104100, 61100, 66150, "/esoui/art/icons/progression_tabicon_bow_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(102700, 61100, 70750, "/esoui/art/icons/progression_tabicon_bow_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))

                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(103000, 61100, 66150, "/esoui/art/icons/progression_tabicon_armorlight_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(102700, 61100, 66150, "/esoui/art/icons/progression_tabicon_armorlight_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(105750, 61100, 68000, "/esoui/art/icons/progression_tabicon_armorlight_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(105750, 61100, 67600, "/esoui/art/icons/progression_tabicon_armorlight_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(103000, 61100, 70750, "/esoui/art/icons/progression_tabicon_armorlight_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(104100, 61100, 70750, "/esoui/art/icons/progression_tabicon_armorlight_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))

            elseif wave == 3 then
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(104100, 61100, 66150, "/esoui/art/icons/progression_tabicon_bow_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(102700, 61100, 66150, "/esoui/art/icons/progression_tabicon_bow_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(104100, 61100, 70750, "/esoui/art/icons/progression_tabicon_bow_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(102700, 61100, 70750, "/esoui/art/icons/progression_tabicon_bow_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))

                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(105750, 61100, 68000, "/esoui/art/icons/progression_tabicon_1handed_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize+38, nil, nil, CitizenNotifier.OSI.callback.bounce))

            end
        elseif round == 3 then
            if wave == 1 then
            elseif wave == 2 then --Trigger, one add left
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(104100, 61100, 66150, "/esoui/art/icons/progression_tabicon_bow_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(104100, 61100, 70750, "/esoui/art/icons/progression_tabicon_bow_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))

                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(103000, 61100, 66150, "/esoui/art/icons/progression_tabicon_damagestaff_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize+38, nil, nil, CitizenNotifier.OSI.callback.bounce))

                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(103000, 61100, 70750, "/esoui/art/icons/progression_tabicon_avaleadership_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize+38, nil, nil, CitizenNotifier.OSI.callback.bounce))

            elseif wave == 3 then
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(102700, 61100, 66150, "/esoui/art/icons/progression_tabicon_bow_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(105750, 61100, 68000, "/esoui/art/icons/progression_tabicon_bow_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(102700, 61100, 70750, "/esoui/art/icons/progression_tabicon_bow_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))

                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(104100, 61100, 66150, "/esoui/art/icons/progression_tabicon_damagestaff_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize+38, nil, nil, CitizenNotifier.OSI.callback.bounce))

                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(105750, 61100, 67600, "/esoui/art/icons/progression_tabicon_1handed_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize+38, nil, nil, CitizenNotifier.OSI.callback.bounce))

            end
        elseif round == 4 then
            if wave == 1 then
            elseif wave == 2 then
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(102700, 61100, 66150, "/esoui/art/icons/progression_tabicon_damagestaff_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize+38, nil, nil, CitizenNotifier.OSI.callback.bounce))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(102700, 61100, 70750, "/esoui/art/icons/progression_tabicon_damagestaff_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize+38, nil, nil, CitizenNotifier.OSI.callback.bounce))

                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(104100, 61100, 66150, "/esoui/art/icons/progression_tabicon_bow_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(104100, 61100, 70750, "/esoui/art/icons/progression_tabicon_bow_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))

                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(105750, 61100, 68000, "/esoui/art/icons/progression_tabicon_avaleadership_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize+38, nil, nil, CitizenNotifier.OSI.callback.bounce))

            elseif wave == 3 then
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(104100, 61100, 66150, "/esoui/art/icons/progression_tabicon_1handed_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize+38, nil, nil, CitizenNotifier.OSI.callback.bounce))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(104100, 61100, 70750, "/esoui/art/icons/progression_tabicon_1handed_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize+38, nil, nil, CitizenNotifier.OSI.callback.bounce))

                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(105750, 61100, 67600, "/esoui/art/icons/progression_tabicon_bow_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(102700, 61100, 70750, "/esoui/art/icons/progression_tabicon_bow_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))

            end
        elseif round == 5 then
        end

	-- STAGE 2
    -- left up mid     88400, 57150, 62750
    -- left down up    88400, 57150, 63800
    -- left down down  88400, 57150, 64200

    -- right up mid    92800, 57150, 62900
    -- right down up   92800, 57150, 64000
    -- right down down 92800, 57150, 64450

    -- exit right      90150, 57150, 61200
    -- exit left       89800, 57150, 61200
	elseif stage == 2 then
        if round == 1 then
            if wave == 1 then
            elseif wave == 2 then
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(88400, 57150, 64200, "/CitizenAddon/Textures/pet_spidermephala_white_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(92800, 57150, 64450, "/CitizenAddon/Textures/pet_spidermephala_white_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))

                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(88400, 57150, 63800, "/CitizenAddon/Textures/hoarvor_white_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(90150, 57150, 61200, "/CitizenAddon/Textures/hoarvor_white_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))

                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(88400, 57150, 62750, "/CitizenAddon/Textures/crocodile_white_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(92800, 57150, 62900, "/CitizenAddon/Textures/crocodile_white_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))

            elseif wave == 3 then
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(88400, 57150, 64200, "/esoui/art/icons/progression_tabicon_dragonaspect_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(92800, 57150, 62900, "/esoui/art/icons/progression_tabicon_dragonaspect_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(92800, 57150, 64450, "/esoui/art/icons/progression_tabicon_dragonaspect_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))

                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(90150, 57150, 61200, "/esoui/art/charactercreate/charactercreate_argonianicon_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize+38, nil, nil, CitizenNotifier.OSI.callback.bounce))

            end
        elseif round == 2 then
            if wave == 1 then
            elseif wave == 2 then
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(88400, 57150, 64200, "/CitizenAddon/Textures/pet_spidermephala_white_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(88400, 57150, 62750, "/CitizenAddon/Textures/pet_spidermephala_white_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(92800, 57150, 62900, "/CitizenAddon/Textures/pet_spidermephala_white_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))

                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(92800, 57150, 64450, "/CitizenAddon/Textures/crocodile_white_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))

                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(90150, 57150, 61200, "/CitizenAddon/Textures/pet_hajmota_slateback_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize+38, nil, nil, CitizenNotifier.OSI.callback.bounce))

            elseif wave == 3 then
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(88400, 57150, 63800, "/CitizenAddon/Textures/pet_spidermephala_white_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(88400, 57150, 62750, "/CitizenAddon/Textures/pet_spidermephala_white_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(92800, 57150, 64000, "/CitizenAddon/Textures/pet_spidermephala_white_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))

                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(89800, 57150, 61200, "/esoui/art/charactercreate/charactercreate_argonianicon_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize+38, nil, nil, CitizenNotifier.OSI.callback.bounce))

            end
        elseif round == 3 then
            if wave == 1 then
            elseif wave == 2 then
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(88400, 57150, 64200, "/CitizenAddon/Textures/crocodile_white_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(92800, 57150, 64450, "/CitizenAddon/Textures/crocodile_white_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))

                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(90150, 57150, 61200, "/CitizenAddon/Textures/cartoklept_map_damaged_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize+38, nil, nil, CitizenNotifier.OSI.callback.bounce))

            elseif wave == 3 then
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(88400, 57150, 62750, "/CitizenAddon/Textures/cartoklept_map_damaged_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize+38, nil, nil, CitizenNotifier.OSI.callback.bounce))

                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(92800, 57150, 62900, "/esoui/art/charactercreate/charactercreate_argonianicon_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize+38, nil, nil, CitizenNotifier.OSI.callback.bounce))

            end
        elseif round == 4 then
            if wave == 1 then
            elseif wave == 2 then
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(88400, 57150, 63800, "/esoui/art/charactercreate/charactercreate_argonianicon_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize+38, nil, nil, CitizenNotifier.OSI.callback.bounce))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(92800, 57150, 64000, "/esoui/art/charactercreate/charactercreate_argonianicon_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize+38, nil, nil, CitizenNotifier.OSI.callback.bounce))

            elseif wave == 3 then
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(88400, 57150, 64200, "/CitizenAddon/Textures/pet_spidermephala_white_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(92800, 57150, 64450, "/CitizenAddon/Textures/pet_spidermephala_white_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(89800, 57150, 61200, "/CitizenAddon/Textures/pet_spidermephala_white_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))

                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(90150, 57150, 61200, "/CitizenAddon/Textures/pet_wamasuhatchling_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize+38, nil, nil, CitizenNotifier.OSI.callback.bounce))

            end
        elseif round == 5 then
        end

	-- STAGE 3
	elseif stage == 3 then
        if round == 1 then
            if wave == 1 then
            elseif wave == 2 then
            elseif wave == 3 then
            end
        elseif round == 2 then
            if wave == 1 then
            elseif wave == 2 then
            elseif wave == 3 then
            end
        elseif round == 3 then
            if wave == 1 then
            elseif wave == 2 then
            elseif wave == 3 then
            end
        elseif round == 4 then
            if wave == 1 then
            elseif wave == 2 then
            elseif wave == 3 then
            end
        elseif round == 5 then
        end

	-- STAGE 4
	elseif stage == 4 then
        if round == 1 then
            if wave == 1 then
            elseif wave == 2 then
            elseif wave == 3 then
            end
        elseif round == 2 then
            if wave == 1 then
            elseif wave == 2 then
            elseif wave == 3 then
            end
        elseif round == 3 then
            if wave == 1 then
            elseif wave == 2 then
            elseif wave == 3 then
            end
        elseif round == 4 then
            if wave == 1 then
            elseif wave == 2 then
            elseif wave == 3 then
            end
        elseif round == 5 then
        end

	-- STAGE 5
	elseif stage == 5 then
        if round == 1 then
            if wave == 1 then
            elseif wave == 2 then
            elseif wave == 3 then
            end
        elseif round == 2 then
            if wave == 1 then
            elseif wave == 2 then
            elseif wave == 3 then
            end
        elseif round == 3 then
            if wave == 1 then
            elseif wave == 2 then
            elseif wave == 3 then
            end
        elseif round == 4 then
            if wave == 1 then
            elseif wave == 2 then
            elseif wave == 3 then
            end
        elseif round == 5 then
        end
	end

    zo_callLater(
        function()
            if CitizenBRP.waveIcons then
                for _, IconObject in pairs(CitizenBRP.waveIcons) do
                    OSI.DiscardPositionIcon(IconObject)
                end
            end
        end,
        CitizenAddon.PVEcontent.BRP.waveIcons.duration
    )
end

---CitizenAddon.name .."BrpAnnouncement", EVENT_DISPLAY_ANNOUNCEMENT
function CitizenBRP.Announcement(_, primaryText, _, _, _, _, _)
    stage = GetCurrentStage()

	if primaryText=='Final Round' or primaryText=='Letzte Runde' or primaryText=='Dernière manche' or primaryText=='Последний раунд' or primaryText=='最終ラウンド' then
		round = 5
		wave = 0
	else
		local roundNumber = string.match(primaryText, '^.+%s(%d)$')
		if roundNumber then
			round = tonumber(roundNumber)
			wave = 0
		end
	end
end

--get wave spawns by tracking portals
---CitizenAddon.name .."BrpPortalSpawned", EVENT_COMBAT_EVENT
    --COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED
    --ABILITY_ID, 114578
function CitizenBRP.PortalSpawned(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _)
	local time = GetGameTimeMilliseconds()

	if time-lastPortalSpawn >= 700 then
		wave = wave + 1
        newWave()
	end
	lastPortalSpawn = time
end

---CitizenAddon.name .."InCombatInBRP", EVENT_PLAYER_COMBAT_STATE
function CitizenBRP.CombatState(_, inCombat)
    if not inCombat then
        --STAGE 1 ROUND 1 WAVE 1
        if stage==0 and round==0 and wave==0 then
            table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(103000, 61050, 66150, "/esoui/art/icons/progression_tabicon_armorlight_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
            table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(104100, 61050, 66150, "/esoui/art/icons/progression_tabicon_armorlight_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
            table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(104100, 61050, 70750, "/esoui/art/icons/progression_tabicon_armorlight_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))

            table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(102700, 61050, 66150, "/esoui/art/icons/progression_tabicon_bow_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
            table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(103000, 61050, 70750, "/esoui/art/icons/progression_tabicon_bow_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
            table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(102700, 61050, 70750, "/esoui/art/icons/progression_tabicon_bow_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))

        elseif stage == 1 then
            --STAGE 1 ROUND 1 WAVE 1
            if (round==1 and CitizenAddon.group.deadMembers>=CitizenAddon.group.size) then
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(103000, 61050, 66150, "/esoui/art/icons/progression_tabicon_armorlight_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(104100, 61050, 66150, "/esoui/art/icons/progression_tabicon_armorlight_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(104100, 61050, 70750, "/esoui/art/icons/progression_tabicon_armorlight_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))

                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(102700, 61050, 66150, "/esoui/art/icons/progression_tabicon_bow_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(103000, 61050, 70750, "/esoui/art/icons/progression_tabicon_bow_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(102700, 61050, 70750, "/esoui/art/icons/progression_tabicon_bow_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))

            --STAGE 1 ROUND 2 WAVE 1
            elseif (round==1 and wave==3 and CitizenAddon.group.deadMembers<=CitizenAddon.group.size) or (round==2 and CitizenAddon.group.deadMembers>=CitizenAddon.group.size) then
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(102700, 61050, 66150, "/esoui/art/icons/progression_tabicon_armorlight_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(102700, 61050, 70750, "/esoui/art/icons/progression_tabicon_armorlight_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))

                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(104100, 61050, 70750, "/esoui/art/icons/progression_tabicon_damagestaff_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize+38, nil, nil, CitizenNotifier.OSI.callback.bounce))

                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(103000, 61050, 70750, "/esoui/art/icons/progression_tabicon_bow_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(105750, 61050, 67600, "/esoui/art/icons/progression_tabicon_bow_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))

            --STAGE 1 ROUND 3 WAVE 1
            elseif (round==2 and wave==3 and CitizenAddon.group.deadMembers<=CitizenAddon.group.size) or (round==3 and CitizenAddon.group.deadMembers>=CitizenAddon.group.size) then
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(104100, 61050, 66150, "/esoui/art/icons/progression_tabicon_bow_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(102700, 61050, 66150, "/esoui/art/icons/progression_tabicon_bow_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(104100, 61050, 70750, "/esoui/art/icons/progression_tabicon_bow_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(102700, 61050, 70750, "/esoui/art/icons/progression_tabicon_bow_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))

                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(105750, 61050, 67600, "/esoui/art/icons/progression_tabicon_avaleadership_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize+38, nil, nil, CitizenNotifier.OSI.callback.bounce))

            --STAGE 1 ROUND 4 WAVE 1
            elseif (round==3 and wave==3 and CitizenAddon.group.deadMembers<=CitizenAddon.group.size) or (round==4 and CitizenAddon.group.deadMembers>=CitizenAddon.group.size) then
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(103000, 61050, 66150, "/esoui/art/icons/progression_tabicon_avaleadership_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize+38, nil, nil, CitizenNotifier.OSI.callback.bounce))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(103000, 61050, 70750, "/esoui/art/icons/progression_tabicon_avaleadership_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize+38, nil, nil, CitizenNotifier.OSI.callback.bounce))

                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(105750, 61050, 68000, "/esoui/art/icons/progression_tabicon_bow_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))

            --STAGE 1 ROUND 5 BOSS
            elseif (round==4 and wave==3 and CitizenAddon.group.deadMembers<=CitizenAddon.group.size) or (round==5 and CitizenAddon.group.deadMembers>=CitizenAddon.group.size) then
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(103720, 60950, 68500, "/OdySupportIcons/icons/squares/squaretwo_red.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize-48, nil, nil, CitizenNotifier.OSI.callback.bounce))

            --STAGE 2 ROUND 1 WAVE 1
            elseif (round==5 and CitizenAddon.group.deadMembers<=CitizenAddon.group.size) then
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(88350, 57150, 62750, "/CitizenAddon/Textures/pet_spidermephala_white_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(92800, 57150, 62900, "/CitizenAddon/Textures/pet_spidermephala_white_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(90150, 57150, 61200, "/CitizenAddon/Textures/pet_spidermephala_white_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))

                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(92800, 57150, 64450, "/esoui/art/icons/progression_tabicon_dragonaspect_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(88400, 57150, 64200, "/esoui/art/icons/progression_tabicon_dragonaspect_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))

            end

        elseif stage == 2 then
            --STAGE 2 ROUND 1 WAVE 1
            if (round==1 and CitizenAddon.group.deadMembers>=CitizenAddon.group.size) then
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(88350, 57150, 62750, "/CitizenAddon/Textures/pet_spidermephala_white_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(92800, 57150, 62900, "/CitizenAddon/Textures/pet_spidermephala_white_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(90150, 57150, 61200, "/CitizenAddon/Textures/pet_spidermephala_white_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))

                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(92800, 57150, 64450, "/esoui/art/icons/progression_tabicon_dragonaspect_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(88400, 57150, 64200, "/esoui/art/icons/progression_tabicon_dragonaspect_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))

            --STAGE 2 ROUND 2 WAVE 1
            elseif (round==1 and wave==3 and CitizenAddon.group.deadMembers<=CitizenAddon.group.size) or (round==2 and CitizenAddon.group.deadMembers>=CitizenAddon.group.size) then
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(88400, 57150, 62750, "/CitizenAddon/Textures/hoarvor_white_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(89800, 57150, 61200, "/CitizenAddon/Textures/hoarvor_white_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(92800, 57150, 62900, "/CitizenAddon/Textures/hoarvor_white_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))

                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(92800, 57150, 64000, "/CitizenAddon/Textures/pet_spidermephala_white_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(88400, 57150, 63800, "/CitizenAddon/Textures/pet_spidermephala_white_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(90150, 57150, 61200, "/CitizenAddon/Textures/pet_spidermephala_white_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))

            --STAGE 2 ROUND 3 WAVE 1
            elseif (round==2 and wave==3 and CitizenAddon.group.deadMembers<=CitizenAddon.group.size) or (round==3 and CitizenAddon.group.deadMembers>=CitizenAddon.group.size) then
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(88400, 57150, 64200, "/CitizenAddon/Textures/pet_spidermephala_white_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(92800, 57150, 64450, "/CitizenAddon/Textures/pet_spidermephala_white_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))

                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(88400, 57150, 63800, "/esoui/art/icons/progression_tabicon_dragonaspect_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(92800, 57150, 64000, "/esoui/art/icons/progression_tabicon_dragonaspect_down.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))

                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(89800, 57150, 61200, "/CitizenAddon/Textures/cartoklept_map_damaged_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize+38, nil, nil, CitizenNotifier.OSI.callback.bounce))

            --STAGE 2 ROUND 4 WAVE 1
            elseif (round==3 and wave==3 and CitizenAddon.group.deadMembers<=CitizenAddon.group.size) or (round==4 and CitizenAddon.group.deadMembers>=CitizenAddon.group.size) then
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(88400, 57150, 62750, "/CitizenAddon/Textures/crocodile_white_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(92800, 57150, 62900, "/CitizenAddon/Textures/crocodile_white_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))

                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(88400, 57150, 64200, "/CitizenAddon/Textures/pet_spidermephala_white_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(92800, 57150, 64450, "/CitizenAddon/Textures/pet_spidermephala_white_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(90150, 57150, 61200, "/CitizenAddon/Textures/pet_spidermephala_white_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(89800, 57150, 61200, "/CitizenAddon/Textures/pet_spidermephala_white_glow.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize, nil, nil, nil))

            --STAGE 2 ROUND 5 BOSS
            elseif (round==4 and wave==3 and CitizenAddon.group.deadMembers<=CitizenAddon.group.size) or (round==5 and CitizenAddon.group.deadMembers>=CitizenAddon.group.size) then
                table.insert(CitizenBRP.waveIcons, OSI.CreatePositionIcon(90090, 57145, 63415, "/OdySupportIcons/icons/squares/squaretwo_red.dds", CitizenAddon.PVEcontent.BRP.waveIcons.OsiIconSize-48, nil, nil, CitizenNotifier.OSI.callback.bounce))

            end

        --STAGE 3
        elseif stage == 3 then

        --STAGE 4
        elseif stage == 4 then

        --STAGE 5
        elseif stage == 5 then

        end

    elseif inCombat then
        zo_callLater(
            function()
                if CitizenBRP.waveIcons then
                    for _, IconObject in pairs(CitizenBRP.waveIcons) do
                        OSI.DiscardPositionIcon(IconObject)
                    end
                end
            end,
            CitizenAddon.PVEcontent.BRP.waveIcons.duration
        )
    end
end

--ONE
-- small sword man
    --/esoui/art/icons/progression_tabicon_armorlight_down.dds
-- 2 handed sword man
    --/esoui/art/icons/progression_tabicon_avaleadership_down.dds
-- sword and board
    --/esoui/art/icons/progression_tabicon_1handed_down.dds
-- archer
    --/esoui/art/icons/progression_tabicon_bow_down.dds
-- fire mage
    --/esoui/art/icons/progression_tabicon_damagestaff_down.dds
-- 

--TWO
--wing
    --/esoui/art/icons/progression_tabicon_dragonaspect_down.dds
--croco
    --/CitizenAddon/Textures/crocodile_white_glow.dds
--archer
    --/esoui/art/charactercreate/charactercreate_argonianicon_down.dds
--spider
    --/CitizenAddon/Textures/pet_spidermephala_white_glow.dds
--wamasu
    --/CitizenAddon/Textures/pet_wamasuhatchling_glow.dds
--troll
    --/CitizenAddon/Textures/cartoklept_map_damaged_glow.dds
--haji
    --/CitizenAddon/Textures/pet_hajmota_slateback_glow.dds
--hoarvor
    --/CitizenAddon/Textures/hoarvor_white_glow.dds


--THREE
--infiuser
    --/esoui/art/icons/progression_tabicon_solspear_down.dds
--normal mage
    --/esoui/art/icons/progression_tabicon_daedricconjuration_down.dds
--footvamp
    --/CitizenAddon/Textures/buildicon_44_white_glow.dds
--garg
    --/CitizenAddon/Textures/cartoklept_map_glow.dds
--bat
    --/CitizenAddon/Textures/bat_white_glow.dds

--FIVE
--2h skele
    --/esoui/art/icons/progression_tabicon_2handed_down.dds
--mage skele
    --/esoui/art/icons/progression_tabicon_magma_down.dds
--big mage
    --/esoui/art/icons/progression_tabicon_darkmagic_down.dds
--ghost
    --/esoui/art/icons/progression_tabicon_sunmagic_down.dds