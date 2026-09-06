local BA = BMGAdventures
BA.Challenges = {}

local function add(def)
    BA.Challenges[#BA.Challenges + 1] = def
end

local function reward(discipline, axp, dxp, score, unlocks)
    return { adventurerXP=axp or 0, discipline=discipline, disciplineXP=dxp or 0, score=score or 0, unlocks=unlocks or {} }
end

local function countChallenge(id, name, category, activityType, goal, axp, dxp, score, opts)
    opts = opts or {}
    add({ id=id, name=name, description=opts.description or name, category=category, activityType=activityType, goal=goal,
          subjectId=opts.subjectId, secret=opts.secret or false, weekly=opts.weekly or false,
          rewards=reward(category, axp, dxp, score, opts.unlocks), evidence=opts.evidence or "NATIVE_RESULT" })
end

local function metaChallenge(id, name, category, metaType, goal, axp, dxp, score, opts)
    opts = opts or {}
    add({ id=id, name=name, description=opts.description or name, category=category, activityType="PROFILE_META", goal=goal,
          metaType=metaType, metaArg=opts.metaArg, secret=opts.secret or false,
          rewards=reward(category, axp, dxp, score, opts.unlocks), evidence="BMG_STATE" })
end

-- Adventurer / meta (10)
metaChallenge("BMG_ADV_FIRST_STEP", "First Steps", "ADV", "COMPLETED_CHALLENGES", 1, 100, 0, 10, {unlocks={"TITLE_FIRST_STEPS","BADGE_FIRST_STEPS"}})
metaChallenge("BMG_ADV_10", "Ten Adventures", "ADV", "COMPLETED_CHALLENGES", 10, 250, 0, 25)
metaChallenge("BMG_ADV_25", "Twenty-Five Adventures", "ADV", "COMPLETED_CHALLENGES", 25, 500, 0, 50)
metaChallenge("BMG_ADV_50", "Fifty Adventures", "ADV", "COMPLETED_CHALLENGES", 50, 1000, 0, 100)
metaChallenge("BMG_ADV_SCORE_500", "Adventure Score 500", "ADV", "ADVENTURE_SCORE", 500, 250, 0, 25, {unlocks={"BADGE_SCORE_500"}})
metaChallenge("BMG_ADV_SCORE_1000", "Adventure Score 1,000", "ADV", "ADVENTURE_SCORE", 1000, 500, 0, 50, {unlocks={"BADGE_SCORE_1000"}})
metaChallenge("BMG_ADV_3_DISC_5", "A Little of Everything", "ADV", "DISCIPLINES_AT_LEVEL", 3, 500, 0, 50, {metaArg=5})
metaChallenge("BMG_ADV_3_DISC_10", "Well Rounded", "ADV", "DISCIPLINES_AT_LEVEL", 3, 750, 0, 75, {metaArg=10})
metaChallenge("BMG_ADV_LEVEL_10", "Adventurer Level 10", "ADV", "ADVENTURER_LEVEL", 10, 500, 0, 50, {unlocks={"TITLE_ADVENTURER_10","UNLOCK_AM_ADV_10"}})
metaChallenge("BMG_ADV_LEVEL_25", "Adventurer Level 25", "ADV", "ADVENTURER_LEVEL", 25, 1000, 0, 100, {unlocks={"TITLE_ADVENTURER_25","UNLOCK_AM_ADV_25"}})

-- Raider (20)
countChallenge("BMG_RAID_FIRST", "First Veteran Trial", "RAID", "TRIAL_CLEAR", 1, 200, 400, 25)
for i, goal in ipairs({2,3,5,10,25}) do countChallenge("BMG_RAID_CLEAR_"..goal, "Veteran Trial Clears "..goal, "RAID", "TRIAL_CLEAR", goal, 150+goal*10, 300+goal*20, 25+goal) end
countChallenge("BMG_RAID_RG_VET", "Rockgrove Veteran", "RAID", "TRIAL_CLEAR", 1, 300, 600, 50, {subjectId="ROCKGROVE"})
countChallenge("BMG_RAID_RG_HM", "Rockgrove Hard Mode", "RAID", "TRIAL_HM", 1, 750, 1500, 100, {subjectId="ROCKGROVE"})
countChallenge("BMG_RAID_DSR_VET", "Dreadsail Reef Veteran", "RAID", "TRIAL_CLEAR", 1, 300, 600, 50, {subjectId="DREADSAIL_REEF"})
countChallenge("BMG_RAID_DSR_HM", "Dreadsail Reef Hard Mode", "RAID", "TRIAL_HM", 1, 750, 1500, 100, {subjectId="DREADSAIL_REEF"})
countChallenge("BMG_RAID_AS_VET", "Asylum Sanctorium Veteran", "RAID", "TRIAL_CLEAR", 1, 300, 600, 50, {subjectId="ASYLUM_SANCTORIUM"})
countChallenge("BMG_RAID_AS_P1", "Asylum Sanctorium +1", "RAID", "TRIAL_VARIANT", 1, 500, 1000, 75, {subjectId="ASYLUM_PLUS_1"})
countChallenge("BMG_RAID_AS_P2", "Asylum Sanctorium +2", "RAID", "TRIAL_VARIANT", 1, 750, 1500, 100, {subjectId="ASYLUM_PLUS_2"})
countChallenge("BMG_RAID_ACH_1", "First Raid Achievement", "RAID", "RAID_ACHIEVEMENT", 1, 150, 300, 25)
countChallenge("BMG_RAID_ACH_5", "Five Raid Achievements", "RAID", "RAID_ACHIEVEMENT", 5, 250, 500, 50)
countChallenge("BMG_RAID_ACH_10", "Ten Raid Achievements", "RAID", "RAID_ACHIEVEMENT", 10, 500, 1000, 75)
countChallenge("BMG_RAID_HM_1", "First Trial Hard Mode", "RAID", "TRIAL_HM", 1, 400, 800, 50)
countChallenge("BMG_RAID_HM_3", "Three Trial Hard Modes", "RAID", "TRIAL_HM_UNIQUE", 3, 750, 1500, 100)
metaChallenge("BMG_RAID_BETA_META", "Raider Beta Master", "RAID", "CATEGORY_COMPLETIONS", 10, 1000, 2000, 150, {metaArg="RAID", unlocks={"TITLE_RAIDER_BETA","BADGE_RAIDER_BETA","UNLOCK_AM_RAIDER_BETA"}})
countChallenge("BMG_RAID_SCORE_EVENT", "Score Runner", "RAID", "TRIAL_SCORE_EVENT", 3, 250, 500, 25)

-- Dungeon (15)
countChallenge("BMG_DUNG_FIRST", "First Dungeon", "DUNG", "DUNGEON_CLEAR", 1, 100, 200, 10)
countChallenge("BMG_DUNG_VET", "First Veteran Dungeon", "DUNG", "DUNGEON_VET_CLEAR", 1, 150, 300, 25)
countChallenge("BMG_DUNG_HM", "First Dungeon Hard Mode", "DUNG", "DUNGEON_HM", 1, 250, 500, 50)
countChallenge("BMG_DUNG_SPEED", "First Dungeon Speed", "DUNG", "DUNGEON_SPEED", 1, 200, 400, 25)
countChallenge("BMG_DUNG_NODEATH", "First Dungeon No Death", "DUNG", "DUNGEON_NODEATH", 1, 200, 400, 25)
countChallenge("BMG_DUNG_TRIFECTA", "First Dungeon Trifecta", "DUNG", "DUNGEON_TRIFECTA", 1, 500, 1000, 75)
for _, goal in ipairs({3,5,10}) do countChallenge("BMG_DUNG_UNIQUE_"..goal, "Unique Veteran Dungeons "..goal, "DUNG", "DUNGEON_VET_UNIQUE", goal, 150+goal*15, 300+goal*30, 20+goal*2) end
for _, goal in ipairs({3,5}) do countChallenge("BMG_DUNG_HM_UNIQUE_"..goal, "Unique Dungeon Hard Modes "..goal, "DUNG", "DUNGEON_HM_UNIQUE", goal, 250+goal*25, 500+goal*50, 40+goal*5) end
countChallenge("BMG_DUNG_ACH_10", "Ten Dungeon Achievements", "DUNG", "DUNGEON_ACHIEVEMENT", 10, 250, 500, 50)
countChallenge("BMG_DUNG_ACH_25", "Twenty-Five Dungeon Achievements", "DUNG", "DUNGEON_ACHIEVEMENT", 25, 500, 1000, 75)
countChallenge("BMG_DUNG_RECORDED_5", "Five Recorded Dungeon Clears", "DUNG", "DUNGEON_CLEAR", 5, 200, 400, 25)
metaChallenge("BMG_DUNG_BETA_META", "Dungeon Beta Master", "DUNG", "CATEGORY_COMPLETIONS", 8, 750, 1500, 100, {metaArg="DUNG", unlocks={"TITLE_DUNGEON_BETA","BADGE_DUNGEON_BETA"}})

-- Explorer (15)
countChallenge("BMG_EXPL_FIRST_POI", "First Discovery", "EXPL", "POI_DISCOVERED", 1, 50, 100, 10)
for _, goal in ipairs({10,25,50,100}) do countChallenge("BMG_EXPL_POI_"..goal, "Discover "..goal.." Points of Interest", "EXPL", "POI_DISCOVERED", goal, 50+goal*3, 100+goal*5, 10+math.floor(goal/5)) end
countChallenge("BMG_EXPL_ZONE_1", "First Zone Completion", "EXPL", "ZONE_COMPLETE", 1, 150, 300, 25)
countChallenge("BMG_EXPL_ZONE_3", "Three Zone Completions", "EXPL", "ZONE_COMPLETE", 3, 300, 600, 50)
countChallenge("BMG_EXPL_ZONE_5", "Five Zone Completions", "EXPL", "ZONE_COMPLETE", 5, 500, 1000, 75)
countChallenge("BMG_EXPL_ANTIQUITY_1", "First Antiquity", "EXPL", "ANTIQUITY_RECOVERED", 1, 100, 200, 10)
countChallenge("BMG_EXPL_ANTIQUITY_10", "Recover 10 Antiquities", "EXPL", "ANTIQUITY_RECOVERED", 10, 200, 400, 25)
countChallenge("BMG_EXPL_ANTIQUITY_25", "Recover 25 Antiquities", "EXPL", "ANTIQUITY_RECOVERED", 25, 400, 800, 50)
countChallenge("BMG_EXPL_WORLD_EVENT_1", "First World Event", "EXPL", "WORLD_EVENT_COMPLETE", 1, 100, 200, 10)
countChallenge("BMG_EXPL_WORLD_EVENT_5", "Five World Events", "EXPL", "WORLD_EVENT_COMPLETE", 5, 200, 400, 25)
countChallenge("BMG_EXPL_WORLD_EVENT_10", "Ten World Events", "EXPL", "WORLD_EVENT_COMPLETE", 10, 300, 600, 50)
metaChallenge("BMG_EXPL_BETA_META", "Explorer Beta Master", "EXPL", "CATEGORY_COMPLETIONS", 8, 750, 1500, 100, {metaArg="EXPL", unlocks={"TITLE_EXPLORER_BETA","BADGE_EXPLORER_BETA","UNLOCK_AM_EXPLORER_BETA"}})

-- Questing (10)
countChallenge("BMG_QUEST_FIRST", "First Recorded Quest", "QUEST", "QUEST_COMPLETE", 1, 50, 100, 10)
for _, goal in ipairs({10,25,50}) do countChallenge("BMG_QUEST_COUNT_"..goal, "Complete "..goal.." Quests", "QUEST", "QUEST_COMPLETE", goal, 50+goal*4, 100+goal*8, 10+math.floor(goal/2)) end
countChallenge("BMG_QUEST_REPEAT_1", "First Repeatable Quest", "QUEST", "REPEATABLE_QUEST_COMPLETE", 1, 75, 150, 10)
countChallenge("BMG_QUEST_REPEAT_10", "Ten Repeatable Quests", "QUEST", "REPEATABLE_QUEST_COMPLETE", 10, 150, 300, 25)
countChallenge("BMG_QUEST_REPEAT_25", "Twenty-Five Repeatable Quests", "QUEST", "REPEATABLE_QUEST_COMPLETE", 25, 300, 600, 50)
countChallenge("BMG_QUEST_ZONE_1", "First Zone Story", "QUEST", "ZONE_STORY_COMPLETE", 1, 200, 400, 25)
countChallenge("BMG_QUEST_ZONE_3", "Three Zone Stories", "QUEST", "ZONE_STORY_COMPLETE", 3, 400, 800, 50)
metaChallenge("BMG_QUEST_BETA_META", "Questing Beta Master", "QUEST", "CATEGORY_COMPLETIONS", 6, 500, 1000, 75, {metaArg="QUEST", unlocks={"TITLE_QUEST_BETA","BADGE_QUEST_BETA"}})

-- PvP (10)
countChallenge("BMG_PVP_BG_KILL_1", "First Battleground Kill", "PVP", "BG_KILL", 1, 50, 100, 10)
countChallenge("BMG_PVP_BG_KILL_10", "Ten Battleground Kills", "PVP", "BG_KILL", 10, 100, 200, 20)
countChallenge("BMG_PVP_BG_KILL_25", "Twenty-Five Battleground Kills", "PVP", "BG_KILL", 25, 200, 400, 30)
countChallenge("BMG_PVP_MEDAL_1", "First Battleground Medal", "PVP", "BG_MEDAL", 1, 50, 100, 10)
countChallenge("BMG_PVP_MEDAL_10", "Ten Battleground Medals", "PVP", "BG_MEDAL", 10, 150, 300, 25)
countChallenge("BMG_PVP_AP_GAIN_1", "First Recorded Alliance Points", "PVP", "AP_GAIN", 1, 50, 100, 10)
countChallenge("BMG_PVP_AP_25000", "Earn 25,000 Recorded AP", "PVP", "AP_GAIN_AMOUNT", 25000, 200, 400, 25)
countChallenge("BMG_PVP_AP_100000", "Earn 100,000 Recorded AP", "PVP", "AP_GAIN_AMOUNT", 100000, 500, 1000, 75)
countChallenge("BMG_PVP_NATIVE_MILESTONE", "PvP Progression Milestone", "PVP", "PVP_MILESTONE", 1, 250, 500, 50)
metaChallenge("BMG_PVP_BETA_META", "PvP Beta Master", "PVP", "CATEGORY_COMPLETIONS", 6, 500, 1000, 75, {metaArg="PVP", unlocks={"TITLE_PVP_BETA","BADGE_PVP_BETA"}})

-- Mastery (10)
countChallenge("BMG_MAST_CRAFT_1", "First Craft", "MAST", "CRAFT_COMPLETE", 1, 25, 50, 5)
countChallenge("BMG_MAST_CRAFT_10", "Craft 10 Items", "MAST", "CRAFT_COMPLETE", 10, 75, 150, 10)
countChallenge("BMG_MAST_CRAFT_50", "Craft 50 Items", "MAST", "CRAFT_COMPLETE", 50, 150, 300, 25)
countChallenge("BMG_MAST_RESEARCH_1", "First Trait Research", "MAST", "TRAIT_RESEARCH_COMPLETE", 1, 100, 200, 10)
countChallenge("BMG_MAST_RESEARCH_5", "Research 5 Traits", "MAST", "TRAIT_RESEARCH_COMPLETE", 5, 150, 300, 25)
countChallenge("BMG_MAST_RESEARCH_10", "Research 10 Traits", "MAST", "TRAIT_RESEARCH_COMPLETE", 10, 250, 500, 50)
countChallenge("BMG_MAST_LORE_1", "First Lore Book", "MAST", "LORE_BOOK_LEARNED", 1, 25, 50, 5)
countChallenge("BMG_MAST_LORE_10", "Learn 10 Lore Books", "MAST", "LORE_BOOK_LEARNED", 10, 100, 200, 20)
countChallenge("BMG_MAST_LORE_COLLECTION", "Complete a Lore Collection", "MAST", "LORE_COLLECTION_COMPLETE", 1, 200, 400, 50)
metaChallenge("BMG_MAST_BETA_META", "Mastery Beta Master", "MAST", "CATEGORY_COMPLETIONS", 6, 500, 1000, 75, {metaArg="MAST", unlocks={"TITLE_MASTERY_BETA","BADGE_MASTERY_BETA"}})

-- Weekly templates (5)
countChallenge("BMG_WEEKLY_DUNGEON_01", "Weekly: Veteran Explorer", "DUNG", "DUNGEON_CLEAR", 3, 150, 300, 0, {weekly=true})
countChallenge("BMG_WEEKLY_RAIDER_01", "Weekly: Trial Runner", "RAID", "TRIAL_CLEAR", 2, 250, 500, 0, {weekly=true})
countChallenge("BMG_WEEKLY_EXPL_01", "Weekly: World Adventurer", "EXPL", "WORLD_EVENT_COMPLETE", 5, 150, 300, 0, {weekly=true})
countChallenge("BMG_WEEKLY_QUEST_01", "Weekly: Story Time", "QUEST", "QUEST_COMPLETE", 10, 150, 300, 0, {weekly=true})
countChallenge("BMG_WEEKLY_MIXED_01", "Weekly: Variety", "ADV", "MULTI_ACTIVITY", 3, 250, 0, 0, {weekly=true})

-- Secret beta (5)
countChallenge("BMG_SECRET_BUSY_DAY", "Busy Day", "ADV", "SESSION_DISCIPLINES", 3, 300, 0, 50, {secret=true})
countChallenge("BMG_SECRET_WORLD_TRAVELER", "World Traveler", "EXPL", "SESSION_POI_ZONES", 3, 300, 500, 50, {secret=true})
countChallenge("BMG_SECRET_VARIETY", "Variety Is the Spice", "ADV", "MULTI_ACTIVITY", 3, 300, 0, 50, {secret=true})
countChallenge("BMG_SECRET_RAIDER", "Raid Fever", "RAID", "SESSION_CATEGORY_COMPLETIONS", 3, 400, 800, 75, {secret=true, subjectId="RAID"})
countChallenge("BMG_SECRET_ADVENTURER", "Hidden Adventurer", "ADV", "SESSION_CHALLENGES", 5, 500, 0, 100, {secret=true, unlocks={"TITLE_SECRET_BETA","BADGE_SECRET_BETA","UNLOCK_AM_SECRET_BETA"}})

-- Verified legacy prestige mappings (dev2)
countChallenge("BMG_RAID_LEGACY_PLANESBREAKER", "Planesbreaker", "RAID", "LEGACY_PRESTIGE", 1, 2500, 5000, 250, {subjectId="SOUL_SAVIOR", evidence="NATIVE_PERSISTENT", unlocks={"TITLE_PLANESBREAKER","BADGE_PLANESBREAKER"}})
countChallenge("BMG_RAID_LEGACY_GODSLAYER", "Godslayer", "RAID", "LEGACY_PRESTIGE", 1, 2500, 5000, 250, {subjectId="GODSLAYER", evidence="NATIVE_PERSISTENT", unlocks={"TITLE_GODSLAYER","BADGE_GODSLAYER"}})
countChallenge("BMG_RAID_LEGACY_SWASHBUCKLER", "Swashbuckler Supreme", "RAID", "LEGACY_PRESTIGE", 1, 2500, 5000, 250, {subjectId="SWASHBUCKLER", evidence="NATIVE_PERSISTENT", unlocks={"TITLE_SWASHBUCKLER","BADGE_SWASHBUCKLER"}})
countChallenge("BMG_RAID_LEGACY_REDEEMER", "Immortal Redeemer", "RAID", "LEGACY_PRESTIGE", 1, 2000, 4000, 200, {subjectId="ASYLUM_REDEEMER", evidence="NATIVE_PERSISTENT", unlocks={"TITLE_REDEEMER","BADGE_REDEEMER"}})
countChallenge("BMG_RAID_LEGACY_TICKTOCK", "Tick-Tock Tormentor", "RAID", "LEGACY_PRESTIGE", 1, 2000, 4000, 200, {subjectId="LIKE_CLOCKWORK", evidence="NATIVE_PERSISTENT", unlocks={"TITLE_TICKTOCK","BADGE_TICKTOCK"}})
countChallenge("BMG_RAID_LEGACY_GRYPHON", "Gryphon Heart", "RAID", "LEGACY_PRESTIGE", 1, 2000, 4000, 200, {subjectId="PATH_TO_ALAXON", evidence="NATIVE_PERSISTENT", unlocks={"TITLE_GRYPHON","BADGE_GRYPHON"}})

assert(#BA.Challenges == 106, "BMG Adventures dev2 registry must contain exactly 106 challenges; found " .. tostring(#BA.Challenges))
