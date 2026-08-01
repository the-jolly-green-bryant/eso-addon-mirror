TauntHelper = TauntHelper or { }
local TauntHelper = TauntHelper

TauntHelper.name		= "TauntHelper"
TauntHelper.version		= "1.5.3"
TauntHelper.varVersion 	= "1"

TauntHelper.reticleIsTrackedMob = false -- is the current target a trackable mob

TauntHelper.hasTauntSlotted 	= nil -- nil means out of combat check, true = taunt slotted, false - no taunt

TauntHelper.auditMode 	        = false

TauntHelper.currentLanguage     = "en"
-- testing different languages
-- /script SetCVar("language.2", "en")
-- /script SetCVar("language.2", "fr")
-- /script SetCVar("language.2", "jp")


TauntHelper.defaults	= {
	["offsetX"]	= 500,
	["offsetY"]	= 500,

	["offsetTauntStacksX"]	= 500,
	["offsetTauntStacksY"]	= 1000,


	["customTrackingList"] = { }, -- list of mobs manually added to tracking
	["tantTrackingAllMobs"] = false, -- show all mods (like how untaunted works)
	["tantTrackingAllBosses"] = true, -- show bosses

	["tauntTrackingAllMobs"] = false, -- show all mods (like how untaunted works)
	["tauntTrackingAllBosses"] = true, -- show bosses


    ["detectSpawnedAdds"]=true, -- detect spawned adds
    ["afterTauntSeconds"]=5, -- after taunt expire show long to show
    ["detectSpawnedAddsSeconds"]=5, -- how long to display loose adds
    ["dpsDisplayLooseAdds"]=true, -- when no taunt slotted, do we look for loose adds?
    ["global"]=true, -- account wide settings

    ["seenMobsTrackingList"] = { }, -- list of mobs seen that aren't recorded in the addon or boss to process later
    ["displayStolenMobs"]=true,

    ["goodTauntColor"]=   {0.0, 0.4, 0.0, 1.0},
    ["mediumTauntColor"]= {0.7, 0.7, 0.0, 1.0},
    ["badTauntColor"]=    {0.8, 0.0, 0.0, 1.0},
    ["looseTauntColor"]=  {0.6, 0.6, 0.6, 1.0},
    ["stolenTauntColor"]= {0.0, 0.0, 1.0, 1.0},


    ["tauntImmunityColor"]= {0.7, 0.0, 0.7, 1.0},
    ["reticleOverColor"]=   {0.7, 0.7, 0.0, 1.0},


    ["tauntCounter2ImmunityColor"]= {0.7, 0.4, 0.0, 1.0},
    ["tauntCounter3ImmunityColor"]= {0.7, 0.4, 0.0, 1.0},
    ["tauntCounter4ImmunityColor"]= {0.7, 0.0, 0.0, 1.0},

    ["blinkLostTaunt"]= true,
    ["blinkLooseMob"]= false,
    ["blinkStolenTaunt"]= false,

    ["debugToChat"]= false,

    ["reverseTauntBarDirection"]= false,
    ["risingTauntBars"]= false,
    ["fontTauntBars"]="Univers 57",
    ["fontSizeTauntBars"]=18,

    ["widthOfTauntBars"]=226,
    ["heightOfTauntBars"]=34,
    ["borderOfTauntBars"]=4,

    ["normalDirectionOfTauntBars"]=true,

    ["displayMobDifficulty"]=false,
    ["enableTauntStacks"]=false,



}


-- Utility used to dump ability IDs to figure out what to include in TauntHelper.tauntSkills
-- /script TauntHelper.dumpSkills()
-- /th dump
function TauntHelper.dumpSkills()
    for hotbarSlot = 3, 7 do -- skill 1,2,3,4,5 (not ults or light attack or heavy attack)
        local abilityId = GetSlotBoundId(hotbarSlot, HOTBAR_CATEGORY_PRIMARY)
        d(string.format('[%i] = "%s", -- %s', abilityId, GetAbilityName(abilityId), GetAbilityName(abilityId)))
    end
    for hotbarSlot = 3, 7 do -- skill 1,2,3,4,5 (not ults or light attack or heavy attack)
        local abilityId = GetSlotBoundId(hotbarSlot, HOTBAR_CATEGORY_BACKUP)
        d(string.format('[%i] = "%s", -- %s', abilityId, GetAbilityName(abilityId), GetAbilityName(abilityId)))
    end
end
-- skill list based on this GetSlotBoundId(hotbarSlot, HOTBAR_CATEGORY_PRIMARY)
TauntHelper.tauntSkills	= {
    [38989]  = "Frost Clench", -- Frost Clench Ice Staff
    [20496]  = "Unrelenting Grip", -- Unrelenting Dragonknight

    [28306]  = "Puncture", -- Puncture S&B
    [38256]  = "Ransack", -- Ransack S&B
    [38250]  = "Pierce Armor", -- Pierce Armor S&B

    [39475]  = "Inner Fire", -- Inner Fire Undaunted
    [42056]  = "Inner Rage", -- Inner Rage Undaunted
    [42060]  = "Inner Beast", -- Inner Fire Undaunted

    [183430] = "Runic Sunder", -- Runic Sunder Arcanist
    [186531] = "Runic Embrace", -- Runic Embrace Arcanist
    [183165] = "Runic Jolt", -- Runic Jolt Arcanist

    [40336]  = "Silver Leash", -- Silver Leash Fighters Guild
}
TauntHelper.tauntScribe	= {
    [12]  = "Taunt", -- Taunt (Focus Script)
    [14]  = "Pull", -- Pull (Focus Script)
}

function TauntHelper.IsCraftedAbilityTaunt(abilityId)
    local firstScribe, secondScribe, thirdScribe = GetCraftedAbilityActiveScriptIds(abilityId)
    if TauntHelper.tauntScribe[firstScribe]==nil then -- This is the taunt scribe
        return false
    else
        return true
    end
end

function TauntHelper.IsAbilityTaunt(abilityId)
    if TauntHelper.tauntSkills[abilityId]==nil then
        return false
    else
        return true
    end
end

-- /script d(TauntHelper.isTauntSkillSlotted())
function TauntHelper.isTauntSkillSlotted()


    if IsUnitInCombat("player") == false then
        TauntHelper.hasTauntSlotted=nil -- used to quickly check for taunt once in combat
    end

    if TauntHelper.hasTauntSlotted~=nil then
        return TauntHelper.hasTauntSlotted
    else
        local hasTaunt = false

        for _, hotbarCategory in pairs({HOTBAR_CATEGORY_PRIMARY, HOTBAR_CATEGORY_BACKUP}) do
            for hotbarSlot = 3, 7 do -- skill 1,2,3,4,5 (not ults or light attack or heavy attack)
                if GetSlotType(hotbarSlot, hotbarCategory) == ACTION_TYPE_CRAFTED_ABILITY then
                    if TauntHelper.IsCraftedAbilityTaunt(GetSlotBoundId(hotbarSlot, hotbarCategory)) then
                        hasTaunt = true
                        break
                    end
                else
                    if TauntHelper.IsAbilityTaunt(GetSlotBoundId(hotbarSlot, hotbarCategory)) then
                        hasTaunt = true
                        break
                    end
                end
            end
            if hasTaunt == true then
                break
            end
        end


        --[[]
        for hotbarSlot = 3, 7 do -- skill 1,2,3,4,5 (not ults or light attack or heavy attack)
            if GetAPIVersion()>=101042 and GetSlotType(hotbarSlot) == ACTION_TYPE_CRAFTED_ABILITY then
                if TauntHelper.IsCraftedAbilityTaunt(GetSlotBoundId(hotbarSlot, HOTBAR_CATEGORY_PRIMARY)) then
                    hasTaunt = true
                    break
                end
                if TauntHelper.IsCraftedAbilityTaunt(GetSlotBoundId(hotbarSlot, HOTBAR_CATEGORY_BACKUP)) then
                    hasTaunt = true
                    break
                end
            else
                if TauntHelper.IsAbilityTaunt(GetSlotBoundId(hotbarSlot, HOTBAR_CATEGORY_PRIMARY)) then
                    hasTaunt = true
                    break
                end
                if TauntHelper.IsAbilityTaunt(GetSlotBoundId(hotbarSlot, HOTBAR_CATEGORY_BACKUP)) then
                    hasTaunt = true
                    break
                end

            end
        end
    --]]
        if IsUnitInCombat("player") == true then
            TauntHelper.hasTauntSlotted = hasTaunt
        end
        return hasTaunt
    end
end


function TauntHelper.OnPlayerCombatState(event, inCombat)

    if inCombat == false and IsUnitDead("player")==false then -- only reset if you go out of combat while alive
        TauntHelper.OnTauntCleanup()
    end
    TauntHelper.checkIfAddonNeedsToBeLoadedOrUnloaded()
end

function TauntHelper.checkIfAddonNeedsToBeLoadedOrUnloaded()
    if TauntHelper.isTauntSkillSlotted() or TauntHelper.savedVars.dpsDisplayLooseAdds or TauntHelper.auditMode then -- check if taunt is slotted....
	    TauntHelper.InitializeOnTaunt()
	else
	    TauntHelper.DeinitializeOnTaunt()
    end
end

function TauntHelper.printHelp()
    d("Branddi's Taunt Helper Command Line Interface")
    d("/th help  --- this menu")
    d("/th print --- print custom added mobs")
    d("/th clear --- clear custom added mobs")
    d("/th dump  --- print current taunt list")
    d("/th audit --- developer audit mode")
end

function TauntHelper.slashCommands(name)
    if name == nil then return TauntHelper.printHelp() end
    if name == "" then return TauntHelper.printHelp() end
    if name == "?" then return TauntHelper.printHelp() end
    if name == "help" then return TauntHelper.printHelp() end
    if name == "print" then return TauntHelper.printToCustomLists() end
    if name == "clear" then return TauntHelper.clearCustomLists() end
    if name == "dump" then return TauntHelper.dumpTauntLists() end
    if name == "audit" then
        TauntHelper.auditMode = not TauntHelper.auditMode
        if TauntHelper.auditMode then
            d("TauntHelper auditMode ON")
        else
            d("TauntHelper auditMode OFF")
        end
    end
end


function TauntHelper.resetVariables()
    for var, value in pairs(TauntHelper.defaults) do
        if var == "global" then
            -- skip
        elseif var == "offsetX" then
            -- skip
        elseif var == "offsetY" then
            -- skip
        elseif var == "offsetTauntStacksX" then
            -- skip
        elseif var == "offsetTauntStacksY" then
            -- skip
        else
            TauntHelper.savedVars[var]=value
        end
    end
end



function TauntHelper.Init(event, addon)
	if addon ~= TauntHelper.name then return end


	TauntHelper.currentLanguage = GetCVar("Language.2")


	EVENT_MANAGER:UnregisterForEvent(TauntHelper.name.."Load", EVENT_ADD_ON_LOADED)

    TauntHelper.savedVars = ZO_SavedVars:NewCharacterIdSettings(TauntHelper.name.."SavedVars",  TauntHelper.varVersion, nil, TauntHelper.defaults)
    if TauntHelper.savedVars.global then
        TauntHelper.savedVars = ZO_SavedVars:NewAccountWide(TauntHelper.name.."SavedVars",  TauntHelper.varVersion, nil, TauntHelper.defaults)
        TauntHelper.savedVars.global = true
    end

    TauntHelper.savedVars.tauntTrackingAllMobs = TauntHelper.savedVars.tantTrackingAllMobs -- to cleanup spelling error in future release
    TauntHelper.savedVars.tauntTrackingAllBosses = TauntHelper.savedVars.tantTrackingAllBosses  -- to cleanup spelling error in future release


    if GetDisplayName() == "@Branddi" then -- enable debugging by default for myself
        TauntHelper.savedVars.debugToChat = true
    end


    TauntHelper.setupUI()

	TauntHelper.setupMenu()

	TauntHelper.checkIfAddonNeedsToBeLoadedOrUnloaded()

	EVENT_MANAGER:RegisterForEvent(TauntHelper.name.."CombatState", EVENT_PLAYER_COMBAT_STATE, TauntHelper.OnPlayerCombatState)

    TauntHelper.loadCustomLists() -- load custom values into the list

    SLASH_COMMANDS["/th"] = TauntHelper.slashCommands


end

EVENT_MANAGER:RegisterForEvent(TauntHelper.name.."Load", EVENT_ADD_ON_LOADED, TauntHelper.Init)
