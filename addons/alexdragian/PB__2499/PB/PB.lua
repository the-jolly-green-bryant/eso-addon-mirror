PB = {
  enums = {},
  name = "PB",
  addon = "PB",
  version = "0.0.23"
}

local LMM2 = LibMainMenu2

local backgroundToggle = true

function PB.GetGuilds()
  local guilds = {};
  for guild = 1, GetNumGuilds() do
    guildId = GetGuildId( guild )
    if PB.db.roster.options.guilds[guildId] then
      guilds[#guilds + 1] = guildId
    end
  end

  PB.guildList = guilds
  return guilds
end

function PB:Initialize()
  PB.LoadDatabase()

  PB.CreateMenu()

  EVENT_MANAGER:UnregisterForEvent(PB.addon, EVENT_ADD_ON_LOADED)
  
  PB.SetupHistoryScans()
  PB.SetTrackerBagHook()

  LMM2:Init()

  PB.SetGuildTabHook( LMM2 )
end
  

function PB.OnAddOnLoaded(event, addonName)
  if addonName == PB.name then
    PB:Initialize()
  end
end

function PB.OnPlayerActivated()
  -- Player is now active --
end

function PB.Debug()
  PB.db.roster.guildData = {}
  --progressionId=GetProgressionSkillProgressionId(SKILL_TYPE_CLASS, 1, 1)
  -- PickupAbilityBySkillLine(SKILL_TYPE_GUILD, 2, 5)
  -- skillName, _, _ = GetSkillAbilityInfo(SKILL_TYPE_GUILD, 2, 5)
  -- d(skillName)
  --ChooseSkillProgressionMorphSlot(progressionId, MORPH_SLOT_MORPH_1)

end

EVENT_MANAGER:RegisterForEvent(PB.addon, EVENT_ADD_ON_LOADED, PB.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(PB.addon, EVENT_PLAYER_ACTIVATED, PB.OnPlayerActivated)