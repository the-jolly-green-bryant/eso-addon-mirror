-- Create namespace
DsRglobals = {}
local DsRglobals = DsRglobals  or {}

DsRglobals.name = "DsRglobals"

local currentChar = GetUnitName("player")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Rabenwacht Leader
-------------------------------------------------------------------------------------------------------------------------------------------------
DsRglobals.GuildLeader={
    [1] = "@Hasenwarrior",
    [2] = "@PettiPuuh",
    [3] = "@flo1980",
    [4] = "@Prof_Flausch",
    [5] = "@Ravnic93",
    [6] = "@Magnolyon",
    -- [4] = "@Siraa",
    -- [5] = "@Sisiktil",
}

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Onine Status
-------------------------------------------------------------------------------------------------------------------------------------------------
DsRglobals.Status = {
    [PLAYER_STATUS_ONLINE]          = "DsRGuildHall/misc/status-on.dds",
    [PLAYER_STATUS_AWAY]            = "DsRGuildHall/misc/status-afk.dds",
    [PLAYER_STATUS_DO_NOT_DISTURB]  = "DsRGuildHall/misc/status-dnd.dds",
    [PLAYER_STATUS_OFFLINE]         = "DsRGuildHall/misc/status-off.dds",
}

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Holiday Icon
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRglobals:HolidayIconLoad()
    local DsRIcon = ""
    local ld      = os.date("*t")
    
    -- Valentine's Day
    if ld.month == 2 and ld.day == 14 then
        DsRIcon = "DsRGuildHall/misc/DsR_valentin.dds"
    -- Ester
    elseif (ld.month == 3 and ld.day >= 25) and (ld.month == 3 and ld.day <= 29) then
        DsRIcon = "DsRGuildHall/misc/DsR_ester.dds"
    -- Christmas
    elseif ld.month == 12 and ld.day >= 0 and ld.day <= 26 then
        DsRIcon = "DsRGuildHall/misc/DsR_xmas.dds"
    else
        DsRIcon = "DsRGuildHall/misc/DsR_normal.dds"
    end

    return DsRIcon
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Donation
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRglobals:DsRdonation()
	SCENE_MANAGER:Show('mailSend')
	zo_callLater(function() 
		ZO_MailSendToField:SetText("@Hasenwarrior")
		ZO_MailSendSubjectField:SetText(GetString(DsRGuild_donationMailSubject))
		ZO_MailSendBodyField:SetText(zo_strformat( GetString(DsRGuild_donationMailTxT), GetDisplayName():gsub("^@", "") ))
        QueueMoneyAttachment(500000)
		ZO_MailSendBodyField:TakeFocus()
	end, 250)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Alliance
-------------------------------------------------------------------------------------------------------------------------------------------------
local function CharAlliance(charNum)
    local name, gender, level, classId, raceId, alliance, charId, locationId = GetCharacterInfo ( charNum )
    if alliance == 1 then
        Icon  = zo_iconFormat("/esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds", 40, 40)
    elseif alliance == 2 then
        Icon  = zo_iconFormat("/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds", 40, 40)
    elseif alliance == 3 then
        Icon  = zo_iconFormat("/esoui/art/mappins/ava_borderkeep_pin_daggerfall.dds", 40, 40)
    end
    return alliance, Icon
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- PlayTime
-------------------------------------------------------------------------------------------------------------------------------------------------
local function PlayTime(CharName)
    local Second     = DsRGuildLoot.sV.charplayed[CharName] or 0
    local SecToMin   = zo_floor(Second/60)
    local MinToHou   = zo_floor(SecToMin/60)
    local Number     = DsRglobals:ThousandNumber(MinToHou)
  
    return Number
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- CharDetailsMenue
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRglobals:CharDetails(CharName, charNum)
    local alliance, Icon = CharAlliance(charNum)
    local Time           = PlayTime(CharName)
    local name, gender, level, classId, raceId, alliance, charId, locationId = GetCharacterInfo ( charNum )
    local classIcon      = zo_iconFormat(ZO_GetClassIcon(classId),24,24)

    if currentChar == CharName then
        CharName = classIcon .. "|c34eb64" .. CharName .. "|r" .. Icon .. "|c7f7f7f(" .. Time .. " h)|r"
    else
        CharName = classIcon .. CharName .. Icon  .. "|c7f7f7f(" .. Time .. " h)|r"
    end
    return CharName
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Time to String
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRglobals:secondsToString(time)
    local years   = zo_floor(time/(86400*30*12))
    local months  = zo_floor(time/(86400*30))
    local days    = zo_floor(time/86400)
    local hours   = zo_floor(zo_mod(time, 86400)/3600)
    local minutes = zo_floor(zo_mod(time,3600)/60)
    local seconds = zo_floor(zo_mod(time,60))

    if years > 0 then
        return string.format("%s years", years)
    end
    if months > 0 then
        return string.format("%s months", months)
    end
    if days > 0 then
        return string.format("%s days", days)
    end
    if hours > 0 then
        return string.format("%s hours", hours)
    end
    if minutes > 0 then
        return string.format("%s minutes", minutes)
    end
    if seconds > 0 then
        return string.format("%s seconds", seconds)
    end
    return "0 days"
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Number Thousandseperator
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRglobals:ThousandNumber(amount)
    local Seperator = "."

    local function IsValueInteger(value)
      return value % 2 == 0
    end
  
    local function comma_value(amount)
      local formatted = tostring(amount)
      local k
  
      repeat
        formatted, k = zo_strgsub(formatted, "^(-?%d+)(%d%d%d)", "%1" .. Seperator .. "%2")
      until k == 0
  
      return formatted
    end
  
    amount = amount or 0
    local applyFormatting = amount > 100 or IsValueInteger(amount)
 
    return comma_value(zo_roundToNearest(amount, 0.01))
  end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Char Location
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRglobals:CharLocation() 
    local location  = nil

    local Dungeon      = IsUnitInDungeon("player")
    local Imperial     = IsInImperialCity()
    local Cyrodiil     = IsInCyrodiil()
    local Battleground = IsActiveWorldBattleground()

    if Dungeon == true then
        location = "Dungeon"
    end
    if Imperial == true then
        location = "Imperial"
    end
    if Cyrodiil == true then
        location = "Cyrodiil"
    end
    if Battleground == true then
        location = "Battleground"
    end

    if Dungeon == false and Imperial == false and Cyrodiil == false and Battleground == false then
        location = "OpenWorld"
    end

    return location
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Loot History
-------------------------------------------------------------------------------------------------------------------------------------------------
DsRglobals.MenuScenes = {
    SCENE_MANAGER:GetScene("inventory"),
    SCENE_MANAGER:GetScene("bank"),
    SCENE_MANAGER:GetScene("guildBank"),
    SCENE_MANAGER:GetScene("houseBank"),
    SCENE_MANAGER:GetScene("skills"),
    SCENE_MANAGER:GetScene("achievements"),
    SCENE_MANAGER:GetScene("antiquityJournalKeyboard"),
    SCENE_MANAGER:GetScene("antiquityLoreKeyboard"),
    WORLD_MAP_SCENE,
    STATS_SCENE,
    QUEST_JOURNAL_SCENE,
    PLAYER_SUBMENU_SCENE,
    KEYBOARD_GROUP_MENU_SCENE,
    CAMPAIGN_OVERVIEW_SCENE,
    CAMPAIGN_BROWSER_SCENE,
    LEADERBOARDS_SCENE,
    COMPANION_CHARACTER_KEYBOARD_SCENE,
    COMPANION_SKILLS_KEYBOARD_SCENE,
    DAILY_LOGIN_REWARDS_KEYBOARD_SCENE,
    KEYBOARD_GROUP_MENU_SCENE,
    GAME_MENU_SCENE,
    NOTIFICATIONS_SCENE,
    LORE_LIBRARY_SCENE,
    NOTIFICATIONS_SCENE,
    COLLECTIONS_BOOK_SCENE,
    GUILD_HOME_SCENE,
    GUILD_ROSTER_SCENE,
    GUILD_RANKS_SCENE,
    GUILD_CREATE_SCENE,
    GUILD_HISTORY_SCENE,
    GUILD_HERALDRY_SCENE,
    KEYBOARD_GUILD_RECRUITMENT_SCENE,
    KEYBOARD_GUILD_BROWSER_SCENE,
    KEYBOARD_LINK_GUILD_INFO_SCENE,
    TRADING_HOUSE_SCENE,
    FRIENDS_LIST_SCENE,
    MAIL_INBOX_SCENE,
    MAIL_SEND_SCENE,
    ENCHANTING_SCENE,
    SMITHING_SCENE,
    ALCHEMY_SCENE,
    PROVISIONER_SCENE,
    TRADING_HOUSE_SCENE,
}

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Buff Ability
-------------------------------------------------------------------------------------------------------------------------------------------------
DsRglobals.abilityTypes = {
    [1] = { name="ABILITY_TYPE_DAMAGE", listname="Damage" },
    [2] = { name="ABILITY_TYPE_HEAL", listname="Heal" },
    [3] = { name="ABILITY_TYPE_RESURRECT", listname="Resurrect" },
    [4] = { name="ABILITY_TYPE_BLINK", listname="Blink" },  
    [5] = { name="ABILITY_TYPE_BONUS", listname="Bonus Effect" },
    [6] = { name="ABILITY_TYPE_REGISTERTRIGGER", listname="Register Trigger" },
    [7] = { name="ABILITY_TYPE_SETTARGET", listname="Set Target" },
    [8] = { name="ABILITY_TYPE_THREAT", listname="Threat" },
    [9] = { name="ABILITY_TYPE_STUN", listname="Stun" },
    [10] = { name="ABILITY_TYPE_SNARE", listname="Snare" },
    [11] = { name="ABILITY_TYPE_SILENCE", listname="Silence" },
    [12] = { name="ABILITY_TYPE_REMOVETYPE", listname="Remove Type" },
    [13] = { name="ABILITY_TYPE_SETCOOLDOWN", listname="Set Cooldown" },
    [14] = { name="ABILITY_TYPE_COMBATRESOURCE", listname="Combat Resource" },
    [15] = { name="ABILITY_TYPE_DAMAGESHIELD", listname="Damage Shield" },
    [16] = { name="ABILITY_TYPE_MOVEPOSITION", listname="Move Position" },
    [17] = { name="ABILITY_TYPE_KNOCKBACK", listname="Knockback" },
    [18] = { name="ABILITY_TYPE_CHARGE", listname="Charge" },
    [19] = { name="ABILITY_TYPE_IMMUNITY", listname="Immunity" },
    [20] = { name="ABILITY_TYPE_INTERCEPT", listname="Intercept" },
    [21] = { name="ABILITY_TYPE_REFLECTION", listname="Reflection" },
    [22] = { name="ABILITY_TYPE_AREAEFFECT", listname="Area Effect" },
    [23] = { name="ABILITY_TYPE_PHASETHROUGH", listname="Phase Through" },
    [24] = { name="ABILITY_TYPE_CREATEINVENTORYITEM", listname="Create Inventory Item" },
    [25] = { name="ABILITY_TYPE_DAMAGELIMIT", listname="Damage Limit" },
    [26] = { name="ABILITY_TYPE_AREATELEPORT", listname="Area Teleport" },
    [27] = { name="ABILITY_TYPE_FEAR", listname="Fear" },
    [28] = { name="ABILITY_TYPE_TRAUMA", listname="Trauma" },
    [29] = { name="ABILITY_TYPE_STEALTH", listname="Stealth" },
    [30] = { name="ABILITY_TYPE_SEESTEALTH", listname="See Stealth" },
    [31] = { name="ABILITY_TYPE_FLIGHT", listname="Flight" },
    [32] = { name="ABILITY_TYPE_DISORIENT", listname="Disorient" },
    [33] = { name="ABILITY_TYPE_STAGGER", listname="Stagger" },
    [34] = { name="ABILITY_TYPE_SLOWFALL", listname="Slow Fall" },
    [35] = { name="ABILITY_TYPE_JUMP", listname="Jump" },
    [36] = { name="ABILITY_TYPE_SIEGECLUSTERAREAEFFECT", listname="Siege Cluster AoE" },
    [37] = { name="ABILITY_TYPE_SUMMON", listname="Summon" },
    [38] = { name="ABILITY_TYPE_MOUNT", listname="Mount" },
    [39] = { name="ABILITY_TYPE_INTERACTREFUSALOVERRIDE", listname="Interact Refusal Override" },
    [40] = { name="ABILITY_TYPE_BLADETURN", listname="Blade Turn" },
    [41] = { name="ABILITY_TYPE_NONEXISTENT", listname="Nonexistent" },
    [42] = { name="ABILITY_TYPE_NOKILL", listname="No Kill" },
    [43] = { name="ABILITY_TYPE_NOAGGRO", listname="No Aggro" },
    [44] = { name="ABILITY_TYPE_DISPEL", listname="Dispel" },
    [45] = { name="ABILITY_TYPE_VAMPIRE", listname="Vampire" },
    [46] = { name="ABILITY_TYPE_CREATEINTERACTABLE", listname="Create Interactable" },
    [47] = { name="ABILITY_TYPE_MODIFYCOOLDOWN", listname="Modify Cooldown" },
    [48] = { name="ABILITY_TYPE_LEVITATE", listname="Levitate" },
    [49] = { name="ABILITY_TYPE_PACIFY", listname="Pacify" },
    [50] = { name="ABILITY_TYPE_ACTIONLIST", listname="Action List" },
    [51] = { name="ABILITY_TYPE_INTERRUPT", listname="Interrupt" },
    [52] = { name="ABILITY_TYPE_BLOCK", listname="Block" },
    [53] = { name="ABILITY_TYPE_OFFBALANCE", listname="Off Balance" },
    [54] = { name="ABILITY_TYPE_EXHAUSTED", listname="Exhausted" },
    [55] = { name="ABILITY_TYPE_MODIFYDURATION", listname="Modify Duration" },
    [56] = { name="ABILITY_TYPE_DODGE", listname="Dodge" },
    [57] = { name="ABILITY_TYPE_SHOWNON", listname="Show Non" },
    [58] = { name="ABILITY_TYPE_MISDIRECT", listname="Misdirect" },
    [59] = { name="ABILITY_TYPE_FREECAST", listname="Free Cast" },
    [60] = { name="ABILITY_TYPE_SIEGECREATE", listname="Siege Create" },
    [61] = { name="ABILITY_TYPE_SIEGEAREAEFFECT", listname="Siege Area Effect" },
    [62] = { name="ABILITY_TYPE_DEFEND", listname="Defend" },
    [63] = { name="ABILITY_TYPE_FREEINTERACT", listname="Free Interact" },
    [64] = { name="ABILITY_TYPE_CHANGEAPPEARANCE", listname="Change Appearance" },
    [65] = { name="ABILITY_TYPE_ATTACKERREFLECT", listname="Attacker Reflect" },
    [66] = { name="ABILITY_TYPE_ATTACKERINTERCEPT", listname="Attacker Intercept" },
    [67] = { name="ABILITY_TYPE_DISARM", listname="Disarm" },
    [68] = { name="ABILITY_TYPE_PARRY", listname="Parry" },
    [69] = { name="ABILITY_TYPE_PATHLINE", listname="Path Line" },
    [70] = { name="ABILITY_TYPE_DEPRECATED_0", listname="Deprecated" },
    [71] = { name="ABILITY_TYPE_FIRETRIGGER", listname="Fire Trigger" },
    [72] = { name="ABILITY_TYPE_LEAP", listname="Leap" },
    [73] = { name="ABILITY_TYPE_REVEAL", listname="Reveal" },
    [74] = { name="ABILITY_TYPE_SIEGEPACKUP", listname="Siege Pack Up" },
    [75] = { name="ABILITY_TYPE_RECALL", listname="Recall" },
    [76] = { name="ABILITY_TYPE_GRANTABILITY", listname="Grant Ability" },
    [77] = { name="ABILITY_TYPE_HIDE", listname="Hide" },
    [78] = { name="ABILITY_TYPE_SETHOTBAR", listname="Set Hotbar" },
    [79] = { name="ABILITY_TYPE_NOLOCKPICK", listname="No Lockpick" },
    [80] = { name="ABILITY_TYPE_FILLSOULGEM", listname="Fill Soul Gem" },
    [81] = { name="ABILITY_TYPE_SOULGEMRESURRECT", listname="Soul Gem Resurrect" },
    [82] = { name="ABILITY_TYPE_DESPAWNOVERRIDE", listname="Despawn Override" },
    [83] = { name="ABILITY_TYPE_UPDATEDEATHDIALOG", listname="Update Death Dialog" },
    [84] = { name="ABILITY_TYPE_COSTMECHANICOVERRIDE", listname="Cost Mechanic Override" },
    [85] = { name="ABILITY_TYPE_CLIENTFX", listname="Client FX" },
    [86] = { name="ABILITY_TYPE_AVOIDDEATH", listname="Avoid Death" },
    [87] = { name="ABILITY_TYPE_NONCOMBATBONUS", listname="Non‑Combat Bonus" },
    [88] = { name="ABILITY_TYPE_NOSEETARGET", listname="No See Target" },
    [89] = { name="ABILITY_TYPE_DIRECTEDMOVEMENTABILITY", listname="Directed Movement" },
    [90] = { name="ABILITY_TYPE_SETPERSONALITY", listname="Set Personality" },
    [91] = { name="ABILITY_TYPE_BASIC", listname="Basic" },
    [92] = { name="ABILITY_TYPE_REWINDTIME", listname="Rewind Time" },
    [93] = { name="ABILITY_TYPE_LIGHTHEAVYATTACKOVERRIDE", listname="Light/Heavy Attack Override" },
    [94] = { name="ABILITY_TYPE_DERIVEDSTATCACHE", listname="Derived Stat Cache" },
    [95] = { name="ABILITY_TYPE_AVAREACH", listname="Ava Reach" },
    [96] = { name="ABILITY_TYPE_RANDOMBRANCH", listname="Random Branch" },
    [97] = { name="ABILITY_TYPE_MOUNTBLOCK", listname="Mount Block" },
    [98] = { name="ABILITY_TYPE_PERSISTENTRADIUS", listname="Persistent Radius" },
    [99] = { name="ABILITY_TYPE_HARDDISMOUNT", listname="Hard Dismount" },
    [100] = { name="ABILITY_TYPE_LINKTARGET", listname="Link Target" },
    [101] = { name="ABILITY_TYPE_CUSTOMTARGETAREA", listname="Custom Target Area" },
    [102] = { name="ABILITY_TYPE_DAMAGETRANSFER", listname="Damage Transfer" },
    [103] = { name="ABILITY_TYPE_DISABLEITEMSETS", listname="Disable Item Sets" },
    [104] = { name="ABILITY_TYPE_FOLLOWWAYPOINTPATH", listname="Follow Waypoint Path" },
    [105] = { name="ABILITY_TYPE_SETAIMATTARGET", listname="Set Aim At Target" },
    [106] = { name="ABILITY_TYPE_FACETARGET", listname="Face Target" },
    [107] = { name="ABILITY_TYPE_LOSMOVEPOSITION", listname="LOS Move Position" },
    [108] = { name="ABILITY_TYPE_DISABLECLIENTTURNING", listname="Disable Client Turning" },
    [109] = { name="ABILITY_TYPE_DAMAGEIMMUNE", listname="Damage Immune" },
    [110] = { name="ABILITY_TYPE_STOPMOVING", listname="Stop Moving" },
    [111] = { name="ABILITY_TYPE_RESOURCETAP", listname="Resource Tap" },
    [112] = { name="ABILITY_TYPE_HOTBARSLOTOVERRIDE", listname="Hotbar Slot Override" },
    [113] = { name="ABILITY_TYPE_REPAIR", listname="Repair" },
    [114] = { name="ABILITY_TYPE_PREVENTHEALING", listname="Prevent Healing" },
    [115] = { name="ABILITY_TYPE_PLAYERFLIGHT", listname="Player Flight" },
    [116] = { name="ABILITY_TYPE_PAUSECOOLDOWN", listname="Pause Cooldown" },
}

DsRglobals.EffectTyp = {
    [1] = { name="BUFF_EFFECT_TYPE_BUFF",   listname="Buff" },
    [2] = { name="BUFF_EFFECT_TYPE_DEBUFF", listname="Debuff" },
}

DsRglobals.sourceType = {
    [0] = { name="BUFF_EFFECT_SOURCE_TYPE_NONE",    listname="None" },
    [1] = { name="BUFF_EFFECT_SOURCE_TYPE_SELF",    listname="Self" },
    [2] = { name="BUFF_EFFECT_SOURCE_TYPE_AOE",     listname="AOE" },
    [3] = { name="BUFF_EFFECT_SOURCE_TYPE_GROUP",   listname="Group" },
    [4] = { name="BUFF_EFFECT_SOURCE_TYPE_TARGET",  listname="Target" },
    [5] = { name="UNDOKUMENTRIERT",                 listname="Ability" },
}

DsRglobals.Raids = {
    [1]  = { id = 1000, de = "Anstalt Sanctorium",        en = "Asylum Sanctorium" },
    [2]  = { id = 638,  de = "Ätherisches Archiv",        en = "Aetherian Archive" },
    [3]  = { id = 1263, de = "Felshain",                  en = "Rockgrove" },
    [4]  = { id = 1344, de = "Grauenssegelriff",          en = "Dreadsail Reef" },
    [5]  = { id = 975,  de = "Hallen der Fertigung",      en = "Halls of Fabrication" },
    [6]  = { id = 1196, de = "Kynes Ägis",                en = "Kyne's Aegis" },
    [7]  = { id = 1478, de = "Luminit-Zitadelle",         en = "Sanity's Edge" },
    [8]  = { id = 639,  de = "Sanctum Ophidia",           en = "Sanctum Ophidia" },
    [9]  = { id = 725,  de = "Schlund von Lorkhaj",       en = "Maw of Lorkhaj" },
    [10] = { id = 1121, de = "Sonnspitz",                 en = "Sunspire" },
    [11] = { id = 1051, de = "Wolkenruh",                 en = "Cloudrest" },
    [12] = { id = 636,  de = "Zitadelle von Hel Ra",      en = "Hel Ra Citadel" },
    [13] = { id = 1427, de = "Rand des Wahnsinns",        en = "Edge of Madness" },
    [14] = { id = 1548, de = "Gebeinkäfig",               en = "Ossein Cage" },
}

DsRglobals.StackableSets = {
    [50978]  = { stack = true, maxStack = 5},  -- Tobender Krieger
    [110118] = { stack = true, maxStack = 1},  -- Siroria
    [116742] = { stack = true, maxStack = 10}, -- Tzogvins Kriegstrupp
    [126631] = { stack = true, maxStack = 20}, -- Azurfäuleschnitter
    [136123] = { stack = true, maxStack = 1},  -- Thrassische Würger
    [137126] = { stack = true, maxStack = 10}, -- Appetit des Drachens
    [150750] = { stack = true, maxStack = 5},  -- Kinras' Zorn
    [152673] = { stack = true, maxStack = 3},  -- Baron Zaudrus
    [155150] = { stack = true, maxStack = 10}, -- Watkilt des Harpunierers
    [155176] = { stack = true, maxStack = 30}, -- Fete des Todbringers
    [176055] = { stack = true, maxStack = 4},  -- Rüstung des Feldwebels
    [181117] = { stack = true, maxStack = 3},  -- Bastion des Draoife
    [188146] = { stack = true, maxStack = 30}, -- Roksa die Verkrümmte
    [203257] = { stack = true, maxStack = 1},  -- Colovianischer Hochlandgeneral
    [219681] = { stack = true, maxStack = 3},  -- Hochland-Schildwache
    [249004] = { stack = true, maxStack = 4},  -- Fallenmeister-Werkzeug
    [260047] = { stack = true, maxStack = 10}, -- Blutdieb
    -- []  = { stack = true, maxStack = 5},  -- Belharzas Band
    -- []  = { stack = true, maxStack = 5},  -- Blutmond
    -- []  = { stack = true, maxStack = 5},  -- Chaotischer Wirbelwind
    -- []  = { stack = true, maxStack = 10}, -- Der Krawall
    -- []  = { stack = true, maxStack = 20}, -- Dov-rha-Panzerschuhe
    -- []  = { stack = true, maxStack = 10}, -- Drachengardeelite
    -- []  = { stack = true, maxStack = 10}, -- Elan des Zweiglings
    -- []  = { stack = true, maxStack = 10}, -- Glorgoloch der Zerstörer
}

