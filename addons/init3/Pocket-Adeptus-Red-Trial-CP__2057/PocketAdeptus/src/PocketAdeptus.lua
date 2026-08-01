PocketAdeptus = PocketAdeptus or {}
local PocketAdeptus = PocketAdeptus

PocketAdeptus.author = "@init3 [NA]"
PocketAdeptus.name = "PocketAdeptus"
PocketAdeptus.version = "2.4"
PocketAdeptus.CPVersion = 3
PocketAdeptus.variableVersion = 1

local LSC = LibSlashCommander -- This library is used to have subcommands under the /cp and /cpset commands

-- The red cp skills. These correspond to the format used in the SavedVariables file
local cpTypes = {"ironclad", "spellShield", "mediumArmorFocus", "resistant", "hardy", "thickSkinned", "eleDefender", "lightArmorFocus",
"bastion", "quickRecovery", "expertDefender", "heavyArmorFocus"}
-- Also the red cp skills, but these are used to display the skills in a more reader friendly format in the settings menu
local cpNames = {"Ironclad", "Spell Shield", "Medium Armor Focus", "Resistant", "Hardy", "Thick Skinned", "Elemental Defender",
"Light Armor Focus", "Bastion", "Quick Recovery", "Expert Defender", "Heavy Armor Focus"}
-- Associates trial ids with a cleaner way of looking at them when using the /cp and /cpset commands
local instances = {aa = "vAA", as = "vAS", cr = "vCR", dsa = "vDSA", hof = "vHoF", hrc = "vHRC", ma = "vMA", mol = "vMoL", so = "vSO", brp = "vBRP", ss = "vSS", gen = "General"}

local function dbg(msg)
     if PocketAdeptus.sv.debug then
          d("|cff0096PocketAdeptus ::|r |cff0000" .. msg .. "|r")
     end
end

local function alert(msg)
     d("|cff0096PocketAdeptus ::|r |cff0000" .. msg .. "|r")
end

local function getCP(instance)
     instance = string.gsub(instance, "%s+", "") -- Trims excess spaces in commands to avoid the command not working when an extra space is put in the command
     if instance == "aa" or instance == "as" or instance == "cr" or instance == "dsa" or instance == "hof"
     or instance == "hrc" or instance == "ma" or instance == "maw" or instance == "mol" or instance == "so"
     or instance == "brp" or instance == "ss" or instance == "gen" then -- Checks to see if the input provided to the /cp commands refers to one of the trials.
          cp = "Pocket Adeptus " .. instances[instance] .. " Red CP: "
          for i, type in pairs(cpTypes) do -- Iterates through the saved CP configuration and appends to the output string all CP skills with at least 1 point in it
               if PocketAdeptus.sv[instance][type] > 0 then
                    cp = cp .. PocketAdeptus.sv[instance][type] .. " " .. cpNames[i] .. ", "
               end
          end
          StartChatInput(cp:sub(1, - 3)) -- Places the CP configuration into the chat box and trims the extra "," at the end of the string
     else
          alert("Valid options include: aa, as, cr, dsa, hof, hrc, ma, mol, so, brp, ss, gen") -- Input validation for non-supported input
     end
end

local function resetCP()
     THE_TOWER, THE_SHADOW, THE_LOVER, THE_RITUAL, THE_ATRONACH, THE_APPRENTICE = {}, {}, {}, {}, {}, {}

     -- STORE OLD CP IN TABLES
     -- Iterates through the CP skills and saves the old green and blue CP configurations to tbe re-applied when the red CP is changed
     for skill = 1, 4 do
          table.insert(THE_TOWER, GetNumPointsSpentOnChampionSkill(1, skill))
     end
     for skill = 1, 4 do
          table.insert(THE_RITUAL, GetNumPointsSpentOnChampionSkill(5, skill))
     end
     for skill = 1, 4 do
          table.insert(THE_ATRONACH, GetNumPointsSpentOnChampionSkill(6, skill))
     end
     for skill = 1, 4 do
          table.insert(THE_APPRENTICE, GetNumPointsSpentOnChampionSkill(7, skill))
     end
     for skill = 1, 4 do
          table.insert(THE_SHADOW, GetNumPointsSpentOnChampionSkill(8, skill))
     end
     for skill = 1, 4 do
          table.insert(THE_LOVER, GetNumPointsSpentOnChampionSkill(9, skill))
     end

     SetChampionIsInRespecMode(true)
     ClearPendingChampionPoints()
end

local function setCP(instance)
     instance = string.gsub(instance, "%s+", "")
     if instance == "aa" or instance == "as" or instance == "cr" or instance == "dsa" or instance == "hof"
     or instance == "hrc" or instance == "ma" or instance == "maw" or instance == "mol" or instance == "so"
     or instance == "brp" or instance == "ss" or instance == "gen" then -- Input Validation
          local playerEffectiveCP = GetMaxSpendableChampionPointsInAttribute()*3
          local playerCP = GetPlayerChampionPointsEarned()
          PocketAdeptus.availableRedCP = 0

          if playerCP > playerEffectiveCP then
               PocketAdeptus.availableRedCP = GetMaxSpendableChampionPointsInAttribute()
          else
               PocketAdeptus.availableRedCP = GetNumSpentChampionPoints(ATTRIBUTE_HEALTH) + GetNumUnspentChampionPoints(ATTRIBUTE_HEALTH)
          end
          local redCPToSpend = PocketAdeptus.sv[instance]["heavyArmorFocus"] +
                              PocketAdeptus.sv[instance]["bastion"] +
                              PocketAdeptus.sv[instance]["expertDefender"] +
                              PocketAdeptus.sv[instance]["quickRecovery"] +
                              PocketAdeptus.sv[instance]["lightArmorFocus"] +
                              PocketAdeptus.sv[instance]["thickSkinned"] +
                              PocketAdeptus.sv[instance]["hardy"] +
                              PocketAdeptus.sv[instance]["eleDefender"] +
                              PocketAdeptus.sv[instance]["mediumArmorFocus"] +
                              PocketAdeptus.sv[instance]["ironclad"] +
                              PocketAdeptus.sv[instance]["spellShield"] +
                              PocketAdeptus.sv[instance]["resistant"]


          if redCPToSpend > PocketAdeptus.availableRedCP then
               PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
               alert("You do not have enough Champion Points.")
               alert("Red CP available: " .. Pocketadeptus.availableRedCP)
               alert("Red CP attempting to spend: " .. redCPToSpend)
               return
          end

          -- Confirms CP change is needed by comparing the old red cp to the requested cp configuration
          count = 0 -- Checks each skill tree and increments by 1 if the tree is already in the correct configuration
          if GetNumPointsSpentOnChampionSkill(2, 1) == PocketAdeptus.sv[instance]["heavyArmorFocus"] then count = count + 1 end
          if GetNumPointsSpentOnChampionSkill(2, 2) == PocketAdeptus.sv[instance]["bastion"] then count = count + 1 end
          if GetNumPointsSpentOnChampionSkill(2, 3) == PocketAdeptus.sv[instance]["expertDefender"] then count = count + 1 end
          if GetNumPointsSpentOnChampionSkill(2, 4) == PocketAdeptus.sv[instance]["quickRecovery"] then count = count + 1 end

          if GetNumPointsSpentOnChampionSkill(3, 1) == PocketAdeptus.sv[instance]["lightArmorFocus"] then count = count + 1 end
          if GetNumPointsSpentOnChampionSkill(3, 2) == PocketAdeptus.sv[instance]["thickSkinned"] then count = count + 1 end
          if GetNumPointsSpentOnChampionSkill(3, 3) == PocketAdeptus.sv[instance]["hardy"] then count = count + 1 end
          if GetNumPointsSpentOnChampionSkill(3, 4) == PocketAdeptus.sv[instance]["eleDefender"] then count = count + 1 end

          if GetNumPointsSpentOnChampionSkill(4, 1) == PocketAdeptus.sv[instance]["mediumArmorFocus"] then count = count + 1 end
          if GetNumPointsSpentOnChampionSkill(4, 2) == PocketAdeptus.sv[instance]["ironclad"] then count = count + 1 end
          if GetNumPointsSpentOnChampionSkill(4, 3) == PocketAdeptus.sv[instance]["spellShield"] then count = count + 1 end
          if GetNumPointsSpentOnChampionSkill(4, 4) == PocketAdeptus.sv[instance]["resistant"] then count = count + 1 end

          if count == 12 then -- If count is 12 (3 Trees 4 skill per tree) then all of the red cp trees had the correct configuration and didn't need to be changed
               alert("Red CP is already set for " .. instances[instance])
               return
          end

          local lfg_role = GetSelectedLFGRole()
          if lfg_role == LFG_ROLE_DPS then
               local mag_current, mag_max, mag_effective = GetUnitPower("player", POWERTYPE_MAGICKA)
               local stam_current, stam_max, stam_effective = GetUnitPower("player", POWERTYPE_STAMINA)

               if mag_max > stam_max then
                    dbg("Max Mag is greater than Max Stam")
                    if PocketAdeptus.sv[instance]["mediumArmorFocus"] > 0 then
                         PocketAdeptus.sv[instance]["lightArmorFocus"] = PocketAdeptus.sv[instance]["mediumArmorFocus"]
                         PocketAdeptus.sv[instance]["mediumArmorFocus"] = 0
                    end
               else
                    dbg("Max Stam is greater than Max Mag")
                    if PocketAdeptus.sv[instance]["lightArmorFocus"] > 0 then
                         PocketAdeptus.sv[instance]["mediumArmorFocus"] = PocketAdeptus.sv[instance]["lightArmorFocus"]
                         PocketAdeptus.sv[instance]["lightArmorFocus"] = 0
                    end
               end
          end

          resetCP() -- Resets CP configuration
          --Sets the old green and blue CP to their previous states
          for skill = 1, 4 do
               SetNumPendingChampionPoints(1, skill, THE_TOWER[skill])
          end
          for skill = 1, 4 do
               SetNumPendingChampionPoints(5, skill, THE_RITUAL[skill])
          end
          for skill = 1, 4 do
               SetNumPendingChampionPoints(6, skill, THE_ATRONACH[skill])
          end
          for skill = 1, 4 do
               SetNumPendingChampionPoints(7, skill, THE_APPRENTICE[skill])
          end
          for skill = 1, 4 do
               SetNumPendingChampionPoints(8, skill, THE_SHADOW[skill])
          end
          for skill = 1, 4 do
               SetNumPendingChampionPoints(9, skill, THE_LOVER[skill])
          end

          -- Sets the new red CP to the requested configuration
          -- THE_LORD
          SetNumPendingChampionPoints(2, 1, PocketAdeptus.sv[instance]["heavyArmorFocus"])
          SetNumPendingChampionPoints(2, 2, PocketAdeptus.sv[instance]["bastion"])
          SetNumPendingChampionPoints(2, 3, PocketAdeptus.sv[instance]["expertDefender"])
          SetNumPendingChampionPoints(2, 4, PocketAdeptus.sv[instance]["quickRecovery"])
          -- THE_lADY
          SetNumPendingChampionPoints(3, 1, PocketAdeptus.sv[instance]["lightArmorFocus"])
          SetNumPendingChampionPoints(3, 2, PocketAdeptus.sv[instance]["thickSkinned"])
          SetNumPendingChampionPoints(3, 3, PocketAdeptus.sv[instance]["hardy"])
          SetNumPendingChampionPoints(3, 4, PocketAdeptus.sv[instance]["eleDefender"])
          -- THE_STEED
          SetNumPendingChampionPoints(4, 1, PocketAdeptus.sv[instance]["mediumArmorFocus"])
          SetNumPendingChampionPoints(4, 2, PocketAdeptus.sv[instance]["ironclad"])
          SetNumPendingChampionPoints(4, 3, PocketAdeptus.sv[instance]["spellShield"])
          SetNumPendingChampionPoints(4, 4, PocketAdeptus.sv[instance]["resistant"])

          if PocketAdeptus.sv["autoConfirm"] then
               SpendPendingChampionPoints() -- Automatically confirms CP configurations if setting is enabled
               alert("Auto-confirmed change to " .. instances[instance] .. " red CP")
          else
               alert(instances[instance] .. " red CP set but needs to be confirmed manually in the CP redistribution menu") -- Otherwise requires manual confirmation
          end
     end
end

-- Commands
command = LSC:Register({"/cp"}, getCP, "Provides recommended Trial CP")
command2 = LSC:Register({"/cpset"}, setCP, "Sets recommended Trial CP")

function PocketAdeptus.UpdateCP()
     PocketAdeptus.sv.aa = PocketAdeptus.defaults.aa
     PocketAdeptus.sv.as = PocketAdeptus.defaults.as
     PocketAdeptus.sv.cr = PocketAdeptus.defaults.cr
     PocketAdeptus.sv.hof = PocketAdeptus.defaults.hof
     PocketAdeptus.sv.hrc = PocketAdeptus.defaults.hrc
     PocketAdeptus.sv.mol = PocketAdeptus.defaults.mol
     PocketAdeptus.sv.so = PocketAdeptus.defaults.so
     PocketAdeptus.sv.dsa = PocketAdeptus.defaults.dsa
     PocketAdeptus.sv.ma = PocketAdeptus.defaults.ma
     PocketAdeptus.sv.brp = PocketAdeptus.defaults.brp
     PocketAdeptus.sv.ss = PocketAdeptus.defaults.ss
     alert("Updated Trial CP Presets")
     alert("Reloading UI...")
     zo_callLater(function() ReloadUI() end, 350)
end

SLASH_COMMANDS["/pocketupdate"] = function() PocketAdeptus.UpdateCP() end

-- /cp subcommands
-- GEN
local genGet = command:RegisterSubCommand()
genGet:AddAlias("Gen")
genGet:SetCallback(function() getCP("gen") end)
genGet:SetDescription("General")

-- AA
local aaGet = command:RegisterSubCommand()
aaGet:AddAlias("AA")
aaGet:SetCallback(function() getCP("aa") end)
aaGet:SetDescription("Aetherian Archive")

--AS
local asGet = command:RegisterSubCommand()
asGet:AddAlias("AS")
asGet:SetCallback(function() getCP("as") end)
asGet:SetDescription("Asylum Sanctorium")

--CR
local crGet = command:RegisterSubCommand()
crGet:AddAlias("CR")
crGet:SetCallback(function() getCP("cr") end)
crGet:SetDescription("Cloudrest")

--DSA
local dsaGet = command:RegisterSubCommand()
dsaGet:AddAlias("DSA")
dsaGet:SetCallback(function() getCP("dsa") end)
dsaGet:SetDescription("Dragonstar Arena")

--HoF
local hofGet = command:RegisterSubCommand()
hofGet:AddAlias("HOF")
hofGet:SetCallback(function() getCP("hof") end)
hofGet:SetDescription("Halls of Fabrication")

--HRC
local hrcGet = command:RegisterSubCommand()
hrcGet:AddAlias("HRC")
hrcGet:SetCallback(function() getCP("hrc") end)
hrcGet:SetDescription("Hel Ra Citadel")

--MA
local maGet = command:RegisterSubCommand()
maGet:AddAlias("MA")
maGet:SetCallback(function() getCP("ma") end)
maGet:SetDescription("Maelstrom Arena")

--MoL
local molGet = command:RegisterSubCommand()
molGet:AddAlias("MoL")
molGet:SetCallback(function() getCP("mol") end)
molGet:SetDescription("Maw of Lorkhaj")

--SO
local soGet = command:RegisterSubCommand()
soGet:AddAlias("SO")
soGet:SetCallback(function() getCP("so") end)
soGet:SetDescription("Sanctum Ophidia")

--BRP
local brpGet = command:RegisterSubCommand()
brpGet:AddAlias("BRP")
brpGet:SetCallback(function() getCP("brp") end)
brpGet:SetDescription("Blackrose Prison")

--SS
local ssGet = command:RegisterSubCommand()
ssGet:AddAlias("SS")
ssGet:SetCallback(function() getCP("ss") end)
ssGet:SetDescription("Sunspire")

-- /cpset subcommands
-- GEN
local genSet = command2:RegisterSubCommand()
genSet:AddAlias("Gen")
genSet:SetCallback(function() setCP("gen") end)
genSet:SetDescription("General")

-- AA
local aaSet = command2:RegisterSubCommand()
aaSet:AddAlias("AA")
aaSet:SetCallback(function() setCP("aa") end)
aaSet:SetDescription("Aetherian Archive")

--AS
local asSet = command2:RegisterSubCommand()
asSet:AddAlias("AS")
asSet:SetCallback(function() setCP("as") end)
asSet:SetDescription("Asylum Sanctorium")

--CR
local crSet = command2:RegisterSubCommand()
crSet:AddAlias("CR")
crSet:SetCallback(function() setCP("cr") end)
crSet:SetDescription("Cloudrest")

--DSA
local dsaSet = command2:RegisterSubCommand()
dsaSet:AddAlias("DSA")
dsaSet:SetCallback(function() setCP("dsa") end)
dsaSet:SetDescription("Dragonstar Arena")

--HoF
local hofSet = command2:RegisterSubCommand()
hofSet:AddAlias("HOF")
hofSet:SetCallback(function() setCP("hof") end)
hofSet:SetDescription("Halls of Fabrication")

--HRC
local hrcSet = command2:RegisterSubCommand()
hrcSet:AddAlias("HRC")
hrcSet:SetCallback(function() setCP("hrc") end)
hrcSet:SetDescription("Hel Ra Citadel")

--MA
local maSet = command2:RegisterSubCommand()
maSet:AddAlias("MA")
maSet:SetCallback(function() setCP("ma") end)
maSet:SetDescription("Maelstrom Arena")

--MoL
local molSet = command2:RegisterSubCommand()
molSet:AddAlias("MoL")
molSet:SetCallback(function() setCP("mol") end)
molSet:SetDescription("Maw of Lorkhaj")

--SO
local soSet = command2:RegisterSubCommand()
soSet:AddAlias("SO")
soSet:SetCallback(function() setCP("so") end)
soSet:SetDescription("Sanctum Ophidia")

--BRP
local brpSet = command2:RegisterSubCommand()
brpSet:AddAlias("BRP")
brpSet:SetCallback(function() setCP("brp") end)
brpSet:SetDescription("Blackrose Prison")

--SS
local ssSet = command2:RegisterSubCommand()
ssSet:AddAlias("SS")
ssSet:SetCallback(function() setCP("ss") end)
ssSet:SetDescription("Sunspire")

-- Tracks the last zone you were in for the purposes of changing CP when entering a trial
local function OnZoneChanged()
     if not DoesCurrentMapMatchMapForPlayerLocation() then
          return
     end

     if tonumber(PocketAdeptus.sv.lastZone) == nil then
          dbg("Last Zone contains non-digit values. Replacing value with 57 *ID for Deshaan")
          PocketAdeptus.sv.lastZone = 57
     end

     local zone = GetZoneId(GetUnitZoneIndex("player"))
     local lastZone = 57 -- Deshaan. It's just a placeholder value
     if PocketAdeptus.sv["lastZone"] ~= nil and PocketAdeptus.sv["lastZone"] ~= "" then
          lastZone = PocketAdeptus.sv["lastZone"]
     else
          lastZone = zone
     end

     if GetCurrentZoneDungeonDifficulty() == DUNGEON_DIFFICULTY_VETERAN then
          dbg("Dungeon Difficulty Set to Veteran")
          dbg("Last Zone: " .. lastZone .. " (" .. GetZoneNameById(lastZone) .. ")")
          dbg("Current Zone: " .. zone .. " (" .. GetZoneNameById(zone) .. ")")
     elseif GetCurrentZoneDungeonDifficulty() == DUNGEON_DIFFICULTY_NORMAL then
          dbg("Dungeon Difficulty Set to Normal")
          dbg("Last Zone: " .. lastZone .. " (" .. GetZoneNameById(lastZone) .. ")")
          dbg("Current Zone: " .. zone .. " (" .. GetZoneNameById(zone) .. ")")
          lastZone = zone
          PocketAdeptus.sv["lastZone"] = zone
          return
     else
          dbg("Not in a dungeon")
          dbg("Last Zone: " .. lastZone .. " (" .. GetZoneNameById(lastZone) .. ")")
          dbg("Current Zone: " .. zone .. " (" .. GetZoneNameById(zone) .. ")")
          lastZone = zone
          PocketAdeptus.sv["lastZone"] = zone
          return
     end

     if lastZone ~= zone then
          if zone == 638 then -- Aetherian Archive
               dbg("Auto-Set CP for Aetherian Archive")
               setCP("aa")
          elseif zone == 636 then -- Hel Ra Citadel
               dbg("Auto-Set CP for Hel Ra Citadel")
               setCP("hrc")
          elseif zone == 639 then -- Sanctum Ophidia
               dbg("Auto-Set CP for Sanctum Ophidia")
               setCP("so")
          elseif zone == 725 then -- Maw of Lorkhaj
               dbg("Auto-Set CP for Maw of Lorkhaj")
               setCP("mol")
          elseif zone == 975 then -- Halls of Fabrication
               dbg("Auto-Set CP for Halls of Fabrication")
               setCP("hof")
          elseif zone == 1000 then -- Asylum Sanctorium
               dbg("Auto-Set CP for Asylum Sanctorium")
               setCP("as")
          elseif zone == 1051 then -- Cloudrest
               dbg("Auto-Set CP for Cloudrest")
               setCP("cr")
          elseif zone == 635 then -- Dragonstar Arena
               dbg("Auto-Set CP for Dragonstar Arena")
               setCP("dsa")
          elseif zone == 684 then -- Maelstrom Arena
               dbg("Auto-Set CP for Maelstrom Arena")
               setCP("ma")
          elseif zone == 1082 then
               dbg("Auto-Set CP for Blackrose Prison")
               setCP("brp")
          elseif zone == 1121 then
               dbg("Auto-Set CP for Sunspire")
               setCP("ss")
          else end
          lastZone = zone
          PocketAdeptus.sv["lastZone"] = zone
     else
          dbg("Last Zone equals Current Zone")
     end
end

function PocketAdeptus.OnAddOnLoaded(event, addonName)
     if PocketAdeptus.name ~= addonName then return end

     PocketAdeptus.globalVariables = ZO_SavedVars:NewAccountWide("PocketAdeptusVars", PocketAdeptus.variableVersion, nil, PocketAdeptus.defaults) -- Saved variables for a global configuration
     PocketAdeptus.savedVars = ZO_SavedVars:NewCharacterIdSettings("PocketAdeptusCharacterVars", PocketAdeptus.variableVersion, nil, PocketAdeptus.defaults) -- Per character saved variables

     -- Checks to see if the character is using a non-global configuration and selects the saved variables table to pull information from
     if PocketAdeptusCharacterVars["Default"][GetDisplayName()][GetCurrentCharacterId()]["useGlobalVars"] then
          PocketAdeptus.sv = PocketAdeptusVars["Default"][GetDisplayName()]['$AccountWide']
          PocketAdeptus.useGlobalVars = true
     else
          PocketAdeptus.sv = PocketAdeptusCharacterVars["Default"][GetDisplayName()][GetCurrentCharacterId()]
          PocketAdeptus.useGlobalVars = false
     end

     PocketAdeptus.createSettingsWindow()

     if PocketAdeptus.sv["SetOnZoneChange"] == true then
          CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", OnZoneChanged)
     end

     if PocketAdeptus.CPVersion > PocketAdeptus.sv.CPVersion then
          alert("PocketAdeptus has been updated and the default CP has changed.")
          alert("If you would like to switch your currently saved CP to the new version type '/pocketupdate' or use the 'Update CP' button in the Pocket Adeptus settings.")
          alert("WARNING: Running this command will override currently saved CP presets and reload your UI.")
          PocketAdeptus.sv.CPVersion = PocketAdeptus.CPVersion
     end
end

EVENT_MANAGER:RegisterForEvent(PocketAdeptus.name, EVENT_ADD_ON_LOADED, PocketAdeptus.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(PocketAdeptus.name, EVENT_PLAYER_ACTIVATED, function() CHAMPION_PERKS:PerformDeferredInitializationShared() end)
