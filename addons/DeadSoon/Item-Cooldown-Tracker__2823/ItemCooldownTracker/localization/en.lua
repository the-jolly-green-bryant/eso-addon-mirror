-- ADDON NAMEPSACE INITIALIZATION - NEVER REMOVE
ICDT = {}
ICDT.loc = {}
ICDT.loc.prefix = {}
ICDT.loc.suffix = {}
ICDT.loc.items = {}
ICDT.loc.settings = {}
ICDT.loc.chat = {}
ICDT.loc.dialogs = {}

-- fix strings
ICDT.loc.prefix.pvp = "1. PVP: "
ICDT.loc.prefix.misc = "2. Misc: "
ICDT.loc.prefix.morrowind = "3. Morrowind: "
ICDT.loc.prefix.summerset = "4. Summerset: "
ICDT.loc.prefix.elsweyr = "5. Elsweyr: "
ICDT.loc.prefix.dragonhold = "6. Dragonhold: "
ICDT.loc.prefix.greymoor = "7. Greymoor: "
ICDT.loc.prefix.markarth = "8. Markarth: "
ICDT.loc.prefix.blackwood = "9. Blackwood: "
ICDT.loc.prefix.deadlands = "10. Deadlands: "
ICDT.loc.prefix.highIsle = "11. High Isle: "
ICDT.loc.prefix.firesong = "12. Firesong: "
ICDT.loc.prefix.necrom = "13. Necrom: "
ICDT.loc.prefix.goldRoad = "14. Gold Road: "
ICDT.loc.prefix.wormCult1 = "15. Worm Cult 1: "


-- ENGLISH LANGUAGE LOCALIZATION
ICDT.loc.suffix.publicDungeonFragment = " (PD Fragment)"

-- Items
ICDT.loc.items.transmutRewardCyrodiil = ICDT.loc.prefix.pvp .. "Uncracked Transmutation Geode ('Rewards for the Worthy')"
ICDT.loc.items.fragCyrodiil = ICDT.loc.prefix.pvp .. "Arena Gladiator's Proof (Cyrodiil)"
ICDT.loc.items.fragImperialCity = ICDT.loc.prefix.pvp .. "Siege of Cyrodiil Merit (Imperial City)"
ICDT.loc.items.dropRemainsSilent = ICDT.loc.prefix.misc .. "Loot from 'Remains-Silent' (Outlaw Refuges)"
ICDT.loc.items.styleShieldOfSenchal = ICDT.loc.prefix.dragonhold .. "Shield of Senchal Style Pages (Southern Elsweyr)"
ICDT.loc.items.styleDragonguard = ICDT.loc.prefix.dragonhold .. "Dragonguard Style Pages (Tideholm)"
ICDT.loc.items.styleNewMoon = ICDT.loc.prefix.dragonhold .. "New Moon Priest Style Pages (Tideholm)"
ICDT.loc.items.styleBlackreachVanguard = ICDT.loc.prefix.greymoor .. "Blackreach Vanguard Style Pages (Western Skyrim)"
ICDT.loc.items.styleGreymoor = ICDT.loc.prefix.greymoor .. "Greymoor Style Pages (Western Skyrim)"
ICDT.loc.items.styleArkthzandArmory = ICDT.loc.prefix.markarth .. "Arkthzand Armory Style Pages (Reach)"
ICDT.loc.items.styleNighthollow = ICDT.loc.prefix.markarth .. "Nighthollow Style Pages (Reach)"
ICDT.loc.items.styleWaywardGuardian = ICDT.loc.prefix.markarth .. "Wayward Guardian Style Pages (Reach)"
ICDT.loc.items.styleBlackFinLegion = ICDT.loc.prefix.blackwood .. "Black Fin Legion Style Pages (Blackwood)"
ICDT.loc.items.styleIvoryBrigade = ICDT.loc.prefix.blackwood .. "Ivory Brigade Style Pages (Blackwood)"
ICDT.loc.items.styleHouseHexos = ICDT.loc.prefix.deadlands .. "House Hexos Style Pages (Fargrave)"
ICDT.loc.items.styleFargraveGuardian = ICDT.loc.prefix.deadlands .. "Fargrave Guardian Style Pages (Fargrave)"
ICDT.loc.items.styleAnnihilarch = ICDT.loc.prefix.deadlands .. "Annihilarch's Chosen Style Pages (Deadlands)"
ICDT.loc.items.styleSteadfastSociety = ICDT.loc.prefix.highIsle .. "Steadfast Society Style Pages (High Isle)"
ICDT.loc.items.styleSystresGuardian = ICDT.loc.prefix.highIsle .. "Systres Guardian Style Pages (High Isle)"
ICDT.loc.items.styleHouseMornard = ICDT.loc.prefix.firesong .. "House Mornard Style Pages (Galen)"
ICDT.loc.items.styleFiresong = ICDT.loc.prefix.firesong .. "Firesong Style Pages (Galen)"
ICDT.loc.items.styleDeadKeeper = ICDT.loc.prefix.necrom .. "Dead Keeper Style Pages (Telvanni)"
ICDT.loc.items.styleKindred = ICDT.loc.prefix.necrom .. "Kindred's Concord Style Pages (Telvanni)"
ICDT.loc.items.styleShardBorn = ICDT.loc.prefix.goldRoad .. "Shardborn Style Pages (West Weald)"
ICDT.loc.items.styleWestWealdLegion = ICDT.loc.prefix.goldRoad .. "West Weald Legion Style Pages (West Weald)"
ICDT.loc.items.styleTideBorn = ICDT.loc.prefix.wormCult1 .. "Tide-Born Style Pages (Solstice)"


-- Settings
ICDT.loc.settings.introDescription = "1. Select the item(s) you want to track/untrack from the dropdown list below.\n2. Click on the button to track or to untrack the selected item(s)\n3. When you collect a tracked item, the addon automatically logs the current time.\n4. A dialog will warn you if you try to open a container with active cooldown.\n5. Type '/ict' into the chat to see all cooldown times.\n\nFeel free to contact me if you want me to add another item(s) to the dropdown. (Comment/PM on ESOUI or Discord: deadsoon_)"
ICDT.loc.settings.itemsToTrack = "Select item(s) you want to track/untrack:"
ICDT.loc.settings.itemsToTrackTooltip = "Select in the dropdown the item(s) you want to track or untrack via the buttons below."
ICDT.loc.settings.trackSelected = "Track selected"
ICDT.loc.settings.trackSelectedTooltip = "Adds the selected item(s) in the dropdown to the tracking list."
ICDT.loc.settings.untrackSelected = "Untrack selected"
ICDT.loc.settings.untrackSelectedTooltip = "Removes the selected item(s) in the dropdown from the tracking list."
ICDT.loc.settings.preventOpening = "Warning of opening too early (1)"
ICDT.loc.settings.preventOpeningTooltip = "A dialog will warn you if you try to open a container with active cooldown. |cFF0000Works currently ONLY when opening the containers via double click.|r You can use only option (1) OR (2)."
ICDT.loc.settings.preventOpeningRestrict = "Warning of opening too early (2)"
ICDT.loc.settings.preventOpeningRestrictTooltip = "A dialog will warn you if you try to open a container with active cooldown. |cFF0000This option reliably prevents all ways of opening containers BUT has the limitation that you will no longer be able to use items from the inventory while in combat (of course, quick slots are not effected).|r You can use only option (1) OR (2)."

ICDT.loc.settings.itemDescriptionDetailedHeader = "Detailed Item Description"
ICDT.loc.settings.itemDescriptionDetailed =
		"PVP: |cd5b526Uncracked Transmutation Geode|r\nYou get this transmutation geode from the PvP mail reward 'Rewards for the Worthy'. Every day you have a save drop of this geode. Until the next daily server reset your chance will be lower to get a geode out of the reward.\n\n" ..
		"PVP: |cd5b526Arena Gladiator's Proof|r\nYou get this fragment item by completing the daily quests from the conquest board in Cyrodiil ('Gladiator's Rucksack'). You can do several of these quests a day but the fragmnent will drop only once a day.\n\n" ..
		"PVP: |cd5b526Siege of Cyrodiil Merit|r\nYou get this fragment item by completing the PvE daily quests in Imperial City ('Siegemaster's Coffer'). You can do several of these quests (for each district) a day but the fragmnent will drop only once a day.\n\n" ..
		"Misc: |cd5b526Loot from 'Remains-Silent'|r\nIf you unlocked the passive skill 'Shadowy Supplier' (Dark Brotherhood) you will find the NPC in any outlaw refuges (Dark Brotherhood symbol). Once a day you can request potions, equipment, edicts and more.\n\n" ..
		"Dragonhold: |cd5b526Shield of Senchal Style Pages|r\nYou have a chance to receive a style page by completing the daily quests (delve or world boss) from the quest givers 'Guybert Flaubert' or 'Bruccius Baenius' in Senchal.\n\n" ..
		"Dragonhold: |cd5b526Dragonguard Style Pages|r\nYou have a chance to receive a style page by completing the daily quests from the quest givers 'Dirge Truptor' or 'Chizbari the Chipper' on Tideholm.\n\n" ..
		"Dragonhold: |cd5b526New Moon Priest Style Pages|r\nIf you fullfill the prerequisites (Southern Elsweyr main quest), you can loot a crate on Tideholm directly in front of the quest giver 'Dirge Truptor' once a day. The crate is reset daily at the same time but the style pages can only be looted once a day (no save drop!).\n\n" ..
		"Greymoor: |cd5b526Blackreach Vanguard Style Pages|r\nYou have a chance to receive a style page by completing the daily quests (delve or world boss) from the quest givers 'Tinzen' or 'Hidaver' in Western Skyrim.\n\n" ..
		"Greymoor: |cd5b526Greymoor Style Pages|r\nYou have a chance to receive a style page by completing the daily quest (harrowstorm) from quest giver 'Jylta' in Western Skyrim.\n\n" ..
		"Markarth: |cd5b526Arkthzand Armory Style Pages|r\nYou have a chance to receive a style page by completing the daily quests (delve or world boss) from the quest givers 'Bralthahan' or 'Gwenyfe' in the Reach.\n\n" ..
		"Markarth: |cd5b526Nighthollow Style Pages|r\nYou have a chance to receive a style page by completing the daily quest (harrowstorm) from quest giver 'Nelldena' in the Reach.\n\n" ..
		"Markarth: |cd5b526Wayward Guardian Style Pages|r\nIf you fullfill the prerequisites (main quest Markarth), you can complete daily quests from the quest giver 'Ardanir' in the Reach. As a reward, there is a chance to receive a style page.\n\n" ..
		"Blackwood: |cd5b526Black Fin Legion Style Pages|r\nYou have a chance to receive a style page by completing the daily quest (delve) from quest giver 'Deetum-Jas' in Blackwood.\n\n" ..
		"Blackwood: |cd5b526Ivory Brigade Style Pages|r\nYou have a chance to receive a style page by completing the daily quest (world boss) from quest giver 'Britta Silanus' in Blackwood.\n\n" ..
		"Deadlands: |cd5b526House Hexos Style Pages|r\nYou have a chance to receive a style page by completing the daily quests (delve) from quest giver 'Luna Beriel' in Fargrave.\n\n" ..
		"Deadlands: |cd5b526Fargrave Guardian Style Pages|r\nYou have a chance to receive a style page by completing the daily quests (world boss) from quest giver 'Vaveli Indavel' in Fargrave.\n\n" ..
		"Deadlands: |cd5b526Annihilarch's Chosen Style Pages|r\nYou have a chance to receive a style page when opening the reward chest after you killed the final boss in a portal ('Atoll of Immolation') in the Deadlands.\n\n" ..		
		"High Isle: |cd5b526Steadfast Society Style Pages|r\nYou have a chance to receive a style page by completing the daily quests (world boss) from quest giver 'Parisse Plouff' in High Isle.\n\n" ..
		"High Isle: |cd5b526Systres Guardian Style Pages|r\nYou have a chance to receive a style page by completing the daily quests (delve) from quest giver 'Wayllod' in High Isle.\n\n" ..
		"Firesong: |cd5b526House Mornard Style Pages|r\nYou have a chance to receive a style page by completing the daily quests (delve or world boss) from the quest givers 'Juline Courcelles' or 'Druid Gastoc' in Galen.\n\n" ..
		"Firesong: |cd5b526Firesong Style Pages|r\nYou have a chance to receive a style page by completing the daily quest (volcanic vents) from the quest giver 'Druid Aishabeh' in Galen.\n\n" ..
		"Necrom: |cd5b526Dead Keeper Style Pages|r\nYou have a chance to receive a style page by completing the daily quests (delve or world boss) from the quest givers 'Ordinator Tilena' or 'Ordinator Nelyn' in Telvanni.\n\n" ..
		"Necrom: |cd5b526Kindred's Concord Style Pages|r\nYou have a chance to receive a style page by completing the daily quest from the quest giver 'Ordinator Tandasea' in Telvanni. Also, the stype pages can drop from bosses in 'Bastion Nymic'.\n\n" ..
		"Gold Road: |cd5b526Shardborn Concord Style Pages|r\nYou have a chance to receive a style page by completing the daily quests (delve or world boss) from the quest givers 'Commandant Salerius' or 'Lieutenant Agrance' in West Weald.\n\n" ..
		"Gold Road: |cd5b526West Weald Legion Style Pages|r\nYou have a chance to receive a style page by completing the daily quest from the quest giver 'Legionairy Jaida' in West Weald.\n\n" ..
		"Worm Cult 1: |cd5b526Tide-Born Style Pages|r\nYou have a chance to receive a style page by completing the daily quests (delve or world boss) from the quest givers 'Lector Volonaro' or 'Morlia' in Solstice.\n\n"


-- Chat output
ICDT.loc.chat.lootRecorded = "Tracked item collected!"
ICDT.loc.chat.noRecords = "Not collected so far"
ICDT.loc.chat.cooldownActiveTime = "You have to wait %d hours and %d minutes!"


-- Dialogs
ICDT.loc.dialogs.initialSetupBody = "Please be briefly informed how the addon works. By default, tracking is enabled for all supported items.\n\nConfirm this dialog to jump to the settings."
ICDT.loc.dialogs.useItemBody1 = "Attention! The cooldown of the item is still active!"
ICDT.loc.dialogs.useItemBody2 = "Do you really want to open this container?"
ICDT.loc.dialogs.noServerResetTime = "WARNING: The addon cannot detect the server you are playing on. The daily reset time of the server is unknown. The tracking of items is not possible.\n\nPlease contact me via ingame mail (@DeadSoon), Discord (deadsoon_) or ESOUI (@DeadSoon) and disable the addon until an update was released."


-- Universal
ICDT.loc.cooldownExpired = "No cooldown"
ICDT.loc.cooldownActive = "Cooldown active!"
ICDT.loc.cooldownShort = "%d hours and %d minutes left"