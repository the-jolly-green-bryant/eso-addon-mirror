
RipFilter = {}
local RF = RipFilter or {}

RF.defaults={
  enabled = true,
  debug = false,
  ripFeed = true,
  trialStartReset = true,
  gColourA = "CCCCCC",      -- player colour
  gColourB = "CC0000",
  ngColourA = "CCCCCC",     -- group colour
  ngColourB = "6B79CE",
  recapMergeAttacks = false,       -- Merge Attacks
  recapMaxAttacks = 10,            -- Max Attacks to Save
  recapTop = CENTER,
  recapLeft = CENTER,
  recapHidden = false,
  recapWidth = 490,
  recapHeight = 300,
}

RF.DEATH_ACTION_RESULTS = {
  --[ACTION_RESULT_KILLED_BY_SUBZONE]=true,     -- environment death and damage (fires many times)
  [ACTION_RESULT_DIED_XP]=true,               -- 2262 (detects breath of lorkhaj?)
  [ACTION_RESULT_KILLING_BLOW]=true,          -- 2265 (pvp player deaths)
  [ACTION_RESULT_DIED]=true,                  -- 2260 (pvp unknowns) mostly this
}

RF.RECAP_ACTION_RESULTS = {
  [ACTION_RESULT_KILLED_BY_SUBZONE] = "ENV",            -- environment death and damage (fires many times)
  [ACTION_RESULT_DAMAGE] = "DMG",
  [ACTION_RESULT_CRITICAL_DAMAGE] = "CRIT",
  [ACTION_RESULT_DOT_TICK] = "DOT",
  [ACTION_RESULT_DOT_TICK_CRITICAL] = "DOT CRIT",
  [ACTION_RESULT_FALL_DAMAGE] = "FALL",
  [ACTION_RESULT_BLOCKED_DAMAGE] = "DMG",               -- "DMG WHILE BLOCKING",
  [ACTION_RESULT_DAMAGE_SHIELDED] = "DMG SHIELD TOOK",
  [-1] = "NO DMG",
-- }

-- RF.MITIGATED_ACTION_RESULTS = {
  [ACTION_RESULT_ABSORBED] = "ABSORBED",
  [ACTION_RESULT_BLOCKED] = "BLOCKED",
  [ACTION_RESULT_DEFENDED] = "DEFENDED",
  [ACTION_RESULT_PRECISE_DAMAGE] = "Oh Boy Whats This?",
}

RF.HEAL_ACTION_RESULTS = {
  [ACTION_RESULT_CRITICAL_HEAL] = "CRITICAL HEAL",
  [ACTION_RESULT_HEAL] = "HEAL",
  [ACTION_RESULT_HOT_TICK] = "HOT HEAL",
  [ACTION_RESULT_HOT_TICK_CRITICAL] = "HOT HEAL CRIT",
}

RF.DAMAGE_TYPE = {
  [DAMAGE_TYPE_NONE] = "(none damage)",
  [DAMAGE_TYPE_GENERIC] = "",                        --"(generic damage)",
  [DAMAGE_TYPE_PHYSICAL] = "(physical damage)",
  [DAMAGE_TYPE_FIRE] = "(fire damage)",
  [DAMAGE_TYPE_SHOCK] = "(shock damage)",
  [DAMAGE_TYPE_OBLIVION] = "(oblivion damage)",
  [DAMAGE_TYPE_COLD] = "(cold damage)",
  [DAMAGE_TYPE_EARTH] = "(earth damage)",
  [DAMAGE_TYPE_MAGIC] = "(magic damage)",
  [DAMAGE_TYPE_DROWN] = "(drown damage)",
  [DAMAGE_TYPE_DISEASE] = "(disease damage)",
  [DAMAGE_TYPE_POISON] = "(poison damage)",
}
