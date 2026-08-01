-- Targets.lua

local string Time = ("Addon is Working")
local string Date = ("Addon is Working")
Targets = {}

-- Global variables for the addon.
Targets.name                = "Targets"
Targets.currentInstance     = "Unknown"       -- Updated using GetUnitZone("player")
Targets.currentBossArray    = nil             -- Set if a matching boss array is found for the zone
Targets.savedVariables      = nil             -- Will be initialized in Initialize
Targets.markerCounter       = 0               -- Marker counter starts at 0
Targets.markTargets         = false           -- Whether target marking should occur

-- Define enemy name arrays for each dungeon.
-- The names must match exactly what the API returns.
Targets.bossNames = {}

-- New arrays for additional dungeons:

Targets.bossNames["Fungal Grotto I"] = {
    "Tazkad the Packmaster",
    "War Chief Ozozai",
    "Broodbirther",
    "Clatterclaw",
    "Kra'gh the Dreugh King",
	"Murkwater Mender"
}

Targets.bossNames["Fungal Grotto II"] = {
    "Ciirenas the Shepherd",  
    "Shadow Tormentor",
    "Spawn of Mephala",
	"Reggr Dark-Dawn",
    "Vila Theran",
	"Spider Cult Healer"
}

Targets.bossNames["Spindleclutch I"] = {
    "Spindlekin",
    "Swarm Mother",
    "Cerise the Widow-Maker",
    "Big Rabbu",
    "The Whisperer",
	"Corrupted Healer"
}

Targets.bossNames["Spindleclutch II"] = {
    "Bloodfiend",
    "Flesh Atronach",
    "Boneman Archer",
	"Boneman Warrior",
	"Bloodspawn",
	"Swarm Mother Nightmare",
	"The Widow-Maker Nightmare",
	"Big Rabbu Nightmare",
	"Corrupted Healer Nightmare",
	"Vorenor Winterbourne",
	"Vampire Bonelord",
	"Vampire Necromancer"
}

Targets.bossNames["The Banished Cells I"] = {
    "Cell Haunter",
	"Clannfear",
    "Skeletal Destroyer",
    "Shadow Proxy",
    "The Feast"
}

Targets.bossNames["The Banished Cells II"] = {
    "Keeper Voranil",
	"Keeper Areldur",
	"Maw of the Infernal",
	"Keeper Imiril",
	"The Feast",
	"Dremora Hauzkyn",
	"High Kinlord Rilis"
}

Targets.bossNames["Darkshade Caverns I"] = {
    "Pit Rat Mender",
    "Foreman Llothan",
	"The Hive Lord",
    "Cavern Patriarch",
    "Cutting Sphere",
    "Sentinel of Rkugamz"
}

Targets.bossNames["Darkshade Caverns II"] = {
    "The Fallen Foreman",
    "Draining Scrib",
	"Sedating Scrib",
    "Transmuted Alit",
    "Grobull the Transmuted",
	"Engine Garrison's Centurion",
    "The Engine Guardian",
	"Dwarven Centurion"
}

Targets.bossNames["Elden Hollow I"] = {
    "Akash gra-Mal",
    "Nenesh gro-Mal",
    "Leafseether",
    "Darkfern Healer",
    "Spriggan",
    "Thalmor Adept",
    "Strangler Saplings",
    "Darkfern Skeleton",
}

Targets.bossNames["Elden Hollow II"] = {
    "Dremora Fearkyn",
	"Infested Fearkyn",
	"Shadow Tendril",
	"Aura of Protection",
	"Frenzied Guardian",
	"Mystic Guardian",
    "Murklight",
    "Nova Tendril",
    "Shadow Tendril"
}

Targets.bossNames["Wayrest Sewers I"] = {
    "Pellingare Sawbones",
    "Slimecraw",
    "The Rat Whisperer",
    "Archmaster Siniel",
	"Uulgarg the Hungry",
	"Restless Soul",
	"Varaine Pellingare",
	"Allene Pellingare"
}

Targets.bossNames["Wayrest Sewers II"] = {
    "Hired Necromancer",
	"Fiendish Nightmare",
	"Bone Colossus",
    "Skull Reaper",
    "Uulgarg the Risen",
    "The Forgotten One",
	"Malubeth the Scourger",
	"Escaped Soul",
	"Varaine Pellingare",
	"Allene Pellingare"
}

Targets.bossNames["Arx Corinium"] = {
    "Sellistrix the Lamia Queen",
	"Sliklenia the Songstress",
	"Ganakton the Tempest",
    "Matron Ixniaa",
	"Menacing Lamia Curare",
	"Lamia Curare",
	"Ixniaa's Handmaiden"
}

Targets.bossNames["City of Ash I"] = {
    "Flame Atronach",
	"Warden of the Shrine",
	"Infernal Guardian",
    "Rothariel Flameheart",
	"Dark Ember",
	"Banekin Minion",
	"Aura of Protection",
}

Targets.bossNames["City of Ash II"] = {
    "Flame Atronach",
	"Ash Titan",
	"Storm Atronach",
    "Urata Militant",
	"Urata Elementalist",
	"Akezel",
	"Aura of Protection",
	"Dremora Gandrakyn",
	"Flame Colossus",
	"Horvantud the Fire Maw"
}

Targets.bossNames["Crypt of Hearts I"] = {
    "Ilambris-Athor",
	"Ilambris-Zaven",
	"Death's Leviathan",
    "Zombie",
	"Dogas the Berserker",
	"Uulkar Bonehand",
	"The Mage Master's Slave",
	"Bone Colossus"
}

Targets.bossNames["Crypt of Hearts II"] = {
    "Wraith",
	"Ilambris-Zaven",
	"Ilambris-Athor",
    "Ilambris Amalgam",
	"Ruzozuzalpamaz",
	"Mezeluth",
	"Chamber Guardian",
	"Ibelgast's Broodnurse",
	"Ibelgast's Cauterizer",
	"Ogrim",
	"Spiderkith Cauterizer"
}

Targets.bossNames["Direfrost Keep"] = {
    "Frost Atronach",
	"Ice Wraith",
	"Ice Skeleton",
    "Guardian of the Flame",
	"Drodda's Apprentice",
	"Frostkin",
	"Teethnasher the Frostbound",
	"Lord Agomar",
	"Frost Troll",
	"Direfrost Cryomancer"
}

Targets.bossNames["Tempest Island"] = {
    "Stormreeve Neidir",
	"Storm Atronach",
	"Lightning Avatar",
    "Commodore Ohmanil",
	"Yalorasse the Speaker",
	"Sonolia the Matriarch",
	"Sea Viper Healer",
	"Lamia Curare"
}

Targets.bossNames["Volenfell"] = {
    "The Guardian's Strength",
	"Tremorscale",
	"Quintus Verres",
    "Monstrous Gargoyle",
	"Unstable Dwarven Spider",
	"Boilbite's Assassin Beetle",
	"Desert Lioness",
	"Treasure Hunter Healer",
	"Duneripper"
}

Targets.bossNames["Blackheart Haven"] = {
    "Captain Blackheart",
	"Roost Mother",
	"Atarus",
    "Hollow Heart",
	"First Mate Wavecutter",
	"Iron-Heel",
	"Bone Colossus",
	"Blackheart Bonelord",
	"Hag",
	"Haven Sinker"
}

Targets.bossNames["Blessed Crucible"] = {
    "Lava Atronach",
	"Incineration Beetle",
	"Stinger",
    "The Troll King",
	"Dynus Aralas",
	"Enraged Durzog",
	"Grunt the Clever",
	"Gladiator Healer",
	"Gladiator Necromancer"
}

Targets.bossNames["Selene's Web"] = {
    "Earth Mender",
	"Foulhide",
	"Longclaw",
    "Mennir Many-Legs",
	"Queen Aklayah",
	"Treethane Kerninn",
	"Aura of Protection",
	"Selene's Shaman"
}

Targets.bossNames["Vaults of Madness"] = {
    "Reanimated Mage",
	"Reanimated Atronach",
	"Reanimated Monstrosity",
    "Iskra the Omen",
	"Grothdarr",
	"The Feast",
	"Aura of Protection",
	"The Ancient One",
	"Achaeraizur",
	"Risen Dead",
	"The Cursed One",
	"Watcher",
	"Seducer Necromancer",
	"Dremora Bonelord",
	"Skeletal Healer"
}

----------------------------------------------------------------------
-- Initialization and Core Clock Functions
----------------------------------------------------------------------

function Targets:Initialize()
    self.inCombat = IsUnitInCombat("player")
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, self.OnPlayerCombatState)
    
    self.savedVariables = ZO_SavedVars:NewAccountWide("TargetsSavedVariables", 1, nil, {})
    self:RestorePosition()
    self:UpdateZoneInfo()  -- Sets currentInstance, currentBossArray, and markTargets.
    
    -- Register the reticle target changed event.
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_RETICLE_TARGET_CHANGED, Targets.OnReticleTargetChanged)
end

function Targets.OnAddOnLoaded(event, addonName)
    if addonName == Targets.name then
        Targets:Initialize()
    end
end
EVENT_MANAGER:RegisterForEvent(Targets.name, EVENT_ADD_ON_LOADED, Targets.OnAddOnLoaded)

function Targets.OnPlayerCombatState(event, inCombat)

  if inCombat ~= Targets.inCombat then
 
    Targets.inCombat = inCombat																			--All the combat state code
 
    if inCombat then

	  TargetsIndicatorDate:SetColor(10, 0, 0)
	  TargetsIndicatorTime:SetColor(10, 0, 0)
    else

	  TargetsIndicatorDate:SetColor(0.77255, 0.76078, 0.61961)
	  TargetsIndicatorTime:SetColor(0.77255, 0.76078, 0.61961)
    end
  end
end

function Targets.OnIndicatorMoveStop()
    if TargetsIndicator then
        Targets.savedVariables.left = TargetsIndicator:GetLeft()
        Targets.savedVariables.top  = TargetsIndicator:GetTop()
    end
end

function Targets:RestorePosition()
    if not TargetsIndicator then return end
    local left = self.savedVariables.left or 0
    local top  = self.savedVariables.top or 0
    TargetsIndicator:ClearAnchors()
    TargetsIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function Targets.Update()
    Time = os.date('%H:%M:%S')
    if TargetsIndicatorTime then
        TargetsIndicatorTime:SetText(Time)
    end
    Date = os.date('%d/%m/%Y')
    if TargetsIndicatorDate then
        TargetsIndicatorDate:SetText(Date)
    end
end

----------------------------------------------------------------------
-- Zone Information (Using GetUnitZone)
----------------------------------------------------------------------
function Targets:UpdateZoneInfo()
    self.currentInstance = GetUnitZone("player") or "Unknown"
    local playerRole = GetGroupMemberSelectedRole("player") or "No Role"
	
	-- Set markTargets based on the required conditions.
    if IsUnitGrouped("player") and IsUnitInDungeon("player") and (GetGroupMemberSelectedRole("player") == 2) then
        self.markTargets = true
        d("You are the target marker")
	
		if self.bossNames[self.currentInstance] then
			self.currentBossArray = self.bossNames[self.currentInstance]
			d("Enemy list found for " .. self.currentInstance)
		else
			self.currentBossArray = nil
			d("No enemy list found for " .. self.currentInstance)
		end

    else
        self.markTargets = false
    end
end

local function OnPlayerActivated()
    Targets:UpdateZoneInfo()
end
EVENT_MANAGER:RegisterForEvent(Targets.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

----------------------------------------------------------------------
-- Function: Compare Target Actor to Array
----------------------------------------------------------------------
function Targets.CheckForBossMatch(targetName)
    if Targets.currentBossArray then
        for i, boss in ipairs(Targets.currentBossArray) do
            if targetName == boss then
                return true
            end
        end
    end
    return false
end

----------------------------------------------------------------------
-- Reticle Target Event: Check Conditions and Mark Target
----------------------------------------------------------------------
function Targets.OnReticleTargetChanged(event, unitTag)
	if not Targets.markTargets then 
	return 
	end				
				local targetName = GetUnitName("reticleover")
				if targetName and targetName ~= "" then
					if Targets.CheckForBossMatch(targetName) == true then

						if IsUnitDead("reticleover") then
							AssignTargetMarkerToReticleTarget(TARGET_MARKER_TYPE_NONE)
						else
							if GetUnitTargetMarkerType("reticleover") == TARGET_MARKER_TYPE_NONE then
								-- Increment the marker counter and clamp it between 0 and 8.
								Targets.markerCounter = Targets.markerCounter + 1
								if Targets.markerCounter < 1 or Targets.markerCounter > 8 then
									Targets.markerCounter = 1
								end

								local markerType
								if Targets.markerCounter == 1 then
									markerType = TARGET_MARKER_TYPE_ONE
								elseif Targets.markerCounter == 2 then
									markerType = TARGET_MARKER_TYPE_TWO
								elseif Targets.markerCounter == 3 then
									markerType = TARGET_MARKER_TYPE_THREE
								elseif Targets.markerCounter == 4 then
									markerType = TARGET_MARKER_TYPE_FOUR
								elseif Targets.markerCounter == 5 then
									markerType = TARGET_MARKER_TYPE_FIVE
								elseif Targets.markerCounter == 6 then
									markerType = TARGET_MARKER_TYPE_SIX
								elseif Targets.markerCounter == 7 then
									markerType = TARGET_MARKER_TYPE_SEVEN
								elseif Targets.markerCounter == 8 then
									markerType = TARGET_MARKER_TYPE_EIGHT
								else
									markerType = TARGET_MARKER_TYPE_ONE
								end
								AssignTargetMarkerToReticleTarget(markerType)
								d(targetName .. " has been marked")
							end
						end
					else
						if GetUnitTargetMarkerType("reticleover") ~= TARGET_MARKER_TYPE_NONE then
						markerType = GetUnitTargetMarkerType("reticleover")
						AssignTargetMarkerToReticleTarget(markerType)
						end
					end
				end		
			
	
end

----------------------------------------------------------------------
-- Debug Slash Command: Print Instance Status and Target Marker Message
----------------------------------------------------------------------
SLASH_COMMANDS["/printinstance"] = function()
    local supportText = (Targets.currentBossArray and "is supported") or "is not supported"
    local markerText = (Targets.markTargets and "are" or "are not") .. " the target marker"
    d("Instance " .. tostring(Targets.currentInstance) .. " " .. supportText .. ". You " .. markerText .. ".")
end
