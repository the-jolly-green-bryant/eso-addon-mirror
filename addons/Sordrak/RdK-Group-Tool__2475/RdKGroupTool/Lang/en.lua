-- RdKGroupTool - Language - en
-- By @s0rdrak (PC / EU)

local RdKGTool = _G['RdKGTool']
local RdKGToolMenu = RdKGTool.menu
local RdKGToolGroup = RdKGTool.group
local RdKGToolCrown = RdKGToolGroup.crown
local RdKGToolAI = RdKGToolGroup.ai
local RdKGToolFtcv = RdKGToolGroup.ftcv
local RdKGToolFtcw = RdKGToolGroup.ftcw
local RdKGToolBeam = RdKGToolGroup.ftcb
local RdKGToolOverview = RdKGToolGroup.ro
local RdKGToolGBeam = RdKGToolGroup.gb
local RdKGToolHdm = RdKGToolGroup.hdm
local RdKGToolDt = RdKGToolGroup.dt
local RdKGToolIsdp = RdKGToolGroup.isdp
local RdKGToolCompass = RdKGTool.compass
local RdKGToolYacs = RdKGToolCompass.yacs
local RdKGToolSC = RdKGToolCompass.sc
local RdKGToolUtil = RdKGTool.util
local RdKGToolUtilUI = RdKGToolUtil.ui
local RdKGToolUltimates = RdKGToolUtil.ultimates
local RdKGToolNetworking = RdKGToolUtil.networking
local RdKGToolUtilGroup = RdKGToolUtil.group
local RdKGToolVersioning = RdKGToolUtil.versioning
local RdKGToolGMenu = RdKGToolUtil.groupMenu
local RdKGToolBeams = RdKGToolUtil.beams
local RdKGToolToolbox = RdKGTool.toolbox
local RdKGToolSm = RdKGToolToolbox.sm
local RdKGToolRecharger = RdKGToolToolbox.recharger
local RdKGToolBft = RdKGToolToolbox.bft
local RdKGToolSiege = RdKGToolToolbox.siege
local RdKGToolCL = RdKGToolToolbox.cl
local RdKGToolEnhance = RdKGToolToolbox.enhancements
local RdKGToolRespawner = RdKGToolToolbox.respawner
local RdKGToolSP = RdKGToolToolbox.sp
local RdKGToolSO = RdKGToolToolbox.so
local RdKGToolAdmin = RdKGTool.admin
local RdKGToolConfig = RdKGTool.cfg

RdKGTool.config.constants.CMD_TEXT_MENU = RdKGTool.slashCmd .. " menu: opens the configuration menu"
RdKGTool.config.constants.CMD_TEXT_MENU = RdKGTool.config.constants.CMD_TEXT_MENU .. "\r\n" .. RdKGTool.slashCmd .." admin: opens the admin interface"
RdKGTool.config.constants.CMD_TEXT_MENU = RdKGTool.config.constants.CMD_TEXT_MENU .. "\r\n" .. RdKGTool.slashCmd .." config: opens the configuration import / export interface"
RdKGTool.config.constants.CMD_TEXT_MENU = RdKGTool.config.constants.CMD_TEXT_MENU .. "\r\n" .. RdKGTool.slashCmd .." hdm clear: Resets the Healing Damage Meter"
RdKGTool.config.constants.CMD_TEXT_MENU = RdKGTool.config.constants.CMD_TEXT_MENU .. "\r\n/ai: enable auto invite (e.g. /ai rdk) - turn off with /ai"

--Tool
RdKGTool.constants = RdKGTool.constants or {}
RdKGTool.constants.MISSING_LIBRARIES = "RdK Group Tool is missing the following libraries: "

--Menu Constants
--Profile
RdKGToolMenu.constants = RdKGToolMenu.constants or {}
RdKGToolMenu.constants.PROFILE_HEADER = "Profile Settings"
RdKGToolMenu.constants.PROFILE_SELECTED_PROFILE = "Selected Profile"
RdKGToolMenu.constants.PROFILE_SELECTED_PROFILE_TOOLTIP = "Select the profile you want to use"
RdKGToolMenu.constants.PROFILE_NEW_PROFILE = "New Profile"
RdKGToolMenu.constants.PROFILE_ADD_PROFILE = "Add"
RdKGToolMenu.constants.PROFILE_CLONE_PROFILE = "Copy"
RdKGToolMenu.constants.PROFILE_REMOVE_PROFILE = "Remove"
RdKGToolMenu.constants.PROFILE_EXISTS = "|cFF0000The profile already exists. Please use another name|r"
RdKGToolMenu.constants.PROFILE_CANT_REMOVE_DEFAULT = "|cFF0000This profile can't be removed|r"

--Fixed Components
RdKGToolMenu.constants.POSITION_FIXED_SET = "Set Position Fixed"
RdKGToolMenu.constants.POSITION_FIXED_UNSET = "Unset Position Fixed"

--Donate
RdKGToolMenu.constants.FEEDBACK = "Feedback"
RdKGToolMenu.constants.FEEDBACK_STRING = "Please provide your feedback through the official ESO forums or ESOUI. I won't be able to respond to your in-game mails."
RdKGToolMenu.constants.DONATE = "Donate"
RdKGToolMenu.constants.DONATE_5K = "Donate 5'000 gold"
RdKGToolMenu.constants.DONATE_50K = "Donate 50'000 gold"
RdKGToolMenu.constants.DONATE_SERVER_ERROR = "Thank you for trying to donate something. Unfortunately, we are playing on different servers."
RdKGToolMenu.constants.DONATE_MAIL_SUBJECT = "RdK Group Tool Donation"

--Group
RdKGToolMenu.constants.GROUP_HEADER = "|cFF8174Group Settings|r"

--Crown
RdKGToolMenu.constants.CROWN_HEADER = "|c4592FFCrown|r"
RdKGToolMenu.constants.CROWN_CHK_GROUP_CROWN_ENABLED = "Custom crown activated"
RdKGToolMenu.constants.CROWN_SELECTED_MODE = "Crown Mode"
RdKGToolMenu.constants.CROWN_MODE = {}
RdKGToolMenu.constants.CROWN_MODE[1] = "Pin"
RdKGToolMenu.constants.CROWN_SELECTED_CROWN = "Selected Crown"
RdKGToolMenu.constants.CROWN_SIZE = "Size"
RdKGToolMenu.constants.CROWN_WARNING = "|cFF0000Only 1 AddOn can implement this functionality. If two AddOns are using this functionality, the game will crash!|r"
RdKGToolMenu.constants.CROWN_PVP_ONLY = "PvP Only"

--Auto Invite
RdKGToolMenu.constants.AI_HEADER = "|c4592FFAuto Invite|r"
RdKGToolMenu.constants.AI_ENABLED = "Enabled"
RdKGToolMenu.constants.AI_INVITE_TEXT = "Invite String"
RdKGToolMenu.constants.AI_GROUP_SIZE = "Max Group Size"
RdKGToolMenu.constants.AI_PVP_CHECK = "PvP Only"
RdKGToolMenu.constants.AI_SEND_CHAT_MESSAGES = "Send Chat Messages"
RdKGToolMenu.constants.AI_AUTO_KICK = "Auto Kick"
RdKGToolMenu.constants.AI_AUTO_KICK_TIME = "Auto Kick Interval"
RdKGToolMenu.constants.AI_CHAT = "Allowed Chats"
RdKGToolMenu.constants.AI_CHAT_RESTRICTIONS = "Player Restrictions"
RdKGToolMenu.constants.AI_CHAT_RESTRICTIONS_TOOLTIP = "Defines to who the auto invite is restricted."
RdKGToolMenu.constants.AI_CHAT_RESTRICTIONS_GUILD = "Guild"
RdKGToolMenu.constants.AI_CHAT_RESTRICTIONS_GUILD_FRIEND = "Guild and Friends"
RdKGToolMenu.constants.AI_CHAT_RESTRICTIONS_FRIEND = "Friends"
RdKGToolMenu.constants.AI_CHAT_RESTRICTIONS_SPECIFIC_GUILD = "Specific Guild"
RdKGToolMenu.constants.AI_CHAT_RESTRICTIONS_SPECIFIC_GUILD_FRIEND = "Specific Guild and Friends"
RdKGToolMenu.constants.AI_CHAT_RESTRICTIONS_NONE = "None"
RdKGToolMenu.constants.AI_SHOW_MEMBER_LEFT = "Show all leave messages"

--Follow The Crown Visual
RdKGToolMenu.constants.FTCV_HEADER = "|c4592FFFollow The Crown (Arrow)|r"
RdKGToolMenu.constants.FTCV_ENABLED = "Enabled"
RdKGToolMenu.constants.FTCV_MODE = "Mode"
RdKGToolMenu.constants.FTCV_COLOR_MODE = "Color Mode"
RdKGToolMenu.constants.FTCV_COLOR_MODE_ORIENTATION = "Orientation (Front, Side, Behind)"
RdKGToolMenu.constants.FTCV_COLOR_MODE_DISTANCE = "Distance (Close, Far)"
RdKGToolMenu.constants.FTCV_COLOR_FRONT = "Color 1 (Front / Close)"
RdKGToolMenu.constants.FTCV_COLOR_SIDE = "Color 2 (Side)"
RdKGToolMenu.constants.FTCV_COLOR_BACK = "Color 3 (Behind / Far)"
RdKGToolMenu.constants.FTCV_OPACITY_CLOSE = "Distance Opacity Close"
RdKGToolMenu.constants.FTCV_OPACITY_FAR = "Distance Opacity Far"
RdKGToolMenu.constants.FTCV_SIZE_CLOSE = "Size Close"
RdKGToolMenu.constants.FTCV_SIZE_FAR = "Size Far"
RdKGToolMenu.constants.FTCV_PVP_ONLY = "PvP Only"
RdKGToolMenu.constants.FTCV_MODE_RETICLE = "Reticle"
RdKGToolMenu.constants.FTCV_MODE_FIXED = "Fixed"
RdKGToolMenu.constants.FTCV_POSITION = "Position"
RdKGToolMenu.constants.FTCV_MAX_DISTANCE = "Maximum Allowed Distance"
RdKGToolMenu.constants.FTCV_MIN_DISTANCE = "Minimum Distance"
RdKGToolMenu.constants.FTCV_TEXTURES = "Texture"

--Follow The Crown Warnings
RdKGToolMenu.constants.FTCW_HEADER = "|c4592FFFollow The Crown (Warnings)|r"
RdKGToolMenu.constants.FTCW_ENABLED = "Enabled"
RdKGToolMenu.constants.FTCW_WARNINGS_ENABLED = "Warnings Enabled"
RdKGToolMenu.constants.FTCW_DISTANCE_ENABLED = "Distance Enabled"
RdKGToolMenu.constants.FTCW_DISTANCE_BACKDROP_ENABLED = "Distance Background Enabled"
RdKGToolMenu.constants.FTCW_POSITION_FIXED = "Position Fixed"
RdKGToolMenu.constants.FTCW_DISTANCE = "Maximum Allowed Distance"
RdKGToolMenu.constants.FTCW_IGNORE_DISTANCE = "Distance Deactivation"
RdKGToolMenu.constants.FTCW_WARNING_COLOR = "Warning Color"
RdKGToolMenu.constants.FTCW_DISTANCE_COLOR_NORMAL = "Distance Color Normal"
RdKGToolMenu.constants.FTCW_DISTANCE_COLOR_ALERT = "Distance Color Alert"
RdKGToolMenu.constants.FTCW_PVP_ONLY = "PvP Only"

--Follow The Crown Audio
RdKGToolMenu.constants.FTCA_HEADER = "|c4592FFFollow The Crown (Audio)|r"
RdKGToolMenu.constants.FTCA_ENABLED = "Enabled"
RdKGToolMenu.constants.FTCA_DISTANCE = "Maximum Allowed Distance"
RdKGToolMenu.constants.FTCA_IGNORE_DISTANCE = "Distance Deactivation"
RdKGToolMenu.constants.FTCA_PVP_ONLY = "PvP Only"
RdKGToolMenu.constants.FTCA_UNMOUNTED_ONLY = "Only Without Mount"
RdKGToolMenu.constants.FTCA_SOUND = "Audio"
RdKGToolMenu.constants.FTCA_INTERVAL = "Interval"
RdKGToolMenu.constants.FTCA_THRESHOLD = "Threshold"

--Follow The Crown Beam
RdKGToolMenu.constants.FTCB_HEADER = "|c4592FFFollow The Crown (Beam)|r"
RdKGToolMenu.constants.FTCB_WARNING = "|cFF0000SubSampling Quality has to be set to High. Otherwise this module won't work.|r"
RdKGToolMenu.constants.FTCB_ENABLED = "Enabled"
RdKGToolMenu.constants.FTCB_PVP_ONLY = "PvP Only"
RdKGToolMenu.constants.FTCB_SELECTED_BEAM = "Selected Beam"
RdKGToolMenu.constants.FTCB_COLOR = "Color"

--Debuff Overview
RdKGToolMenu.constants.DBO_HEADER = "|c4592FFDebuff Overview|r"
RdKGToolMenu.constants.DBO_ENABLED = "Enabled"
RdKGToolMenu.constants.DBO_PVP_ONLY = "PvP Only"
RdKGToolMenu.constants.DBO_CRITICAL_AMOUNT = "Critical Amount Of Debuffs"
RdKGToolMenu.constants.DBO_COLOR_OKAY = "Color Okay [0]"
RdKGToolMenu.constants.DBO_COLOR_NOT_OKAY = "Color Not Okay  [1]"
RdKGToolMenu.constants.DBO_COLOR_CRITICAL = " Color Critical"
RdKGToolMenu.constants.DBO_POSITION_FIXED = "Position Fixed"
RdKGToolMenu.constants.DBO_COLOR_OUT_OF_RANGE = "Color Out Of Range"
RdKGToolMenu.constants.DBO_DESCRIPTION = "This module requires the map pins of other modules (Resource Overview, Synergy Overview, Healing Damage Meter). To get the best results, activate the Resource Overview."
RdKGToolMenu.constants.DBO_SIZE = "Size"

--Rapid Tracker
RdKGToolMenu.constants.RT_HEADER = "|c4592FFRapid Overview|r"
RdKGToolMenu.constants.RT_ENABLED = "Enabled"
RdKGToolMenu.constants.RT_PVP_ONLY = "PvP Only"
RdKGToolMenu.constants.RT_POSITION_FIXED = "Position Fixed"
RdKGToolMenu.constants.RT_COLOR_LABEL_IN_RANGE = "Color Name In Range"
RdKGToolMenu.constants.RT_COLOR_LABEL_NOT_IN_RANGE = "Color Name Out Of Range"
RdKGToolMenu.constants.RT_COLOR_LABEL_OUT_OF_RANGE = "Color Name AFK"
RdKGToolMenu.constants.RT_COLOR_RAPID_ON = "Color Rapid Active"
RdKGToolMenu.constants.RT_COLOR_RAPID_OFF = "Color Rapid Inactive"

--Resource Overview
RdKGToolMenu.constants.RO_HEADER_ULTIMATES = "|c4592FFResource Overview (Combined)|r"
RdKGToolMenu.constants.RO_ENABLED = "Enabled"
RdKGToolMenu.constants.RO_PVP_ONLY = "PvP Only"
RdKGToolMenu.constants.RO_POSITION_FIXED = "Position Fixed"
RdKGToolMenu.constants.RO_ULTIMATE_OVERVIEW_ENABLED = "Ultimate Group Overview Enabled"
RdKGToolMenu.constants.RO_CLIENT_ULTIMATE_ENABLED = "Client Window Enabled"
RdKGToolMenu.constants.RO_GROUP_ULTIMATES_ENABLED = "Group Window Enabled"
RdKGToolMenu.constants.RO_SHOW_SOFT_RESOURCES = "Display Stamina / Magicka"
RdKGToolMenu.constants.RO_DISPLAYED_ULTIMATES = "Displayed Number of Ultimates"
RdKGToolMenu.constants.RO_COLOR_BACKGROUND = "Resource Background Color"
RdKGToolMenu.constants.RO_COLOR_MAGICKA = "Resource Magicka Color"
RdKGToolMenu.constants.RO_COLOR_STAMINA = "Resource Stamina Color"
RdKGToolMenu.constants.RO_COLOR_OUT_OF_RANGE = "Resource Out Of Range Color"
RdKGToolMenu.constants.RO_COLOR_DEAD = "Resource Dead Color"
RdKGToolMenu.constants.RO_COLOR_PROGRESS_NOT_FULL = "Resource Not Full Color"
RdKGToolMenu.constants.RO_COLOR_PROGRESS_FULL = "Resource Full Color"
RdKGToolMenu.constants.RO_COLOR_LABEL_FULL = "Resource Label Color \"Full\""
RdKGToolMenu.constants.RO_COLOR_LABEL_NOT_FULL = "Resource Label Color \"Not Full\""
RdKGToolMenu.constants.RO_COLOR_LABEL_GROUP = "Resource Label Color \"Group\""
RdKGToolMenu.constants.RO_COLOR_LABEL_ANNOUNCEMENT = "Announcement Color"
RdKGToolMenu.constants.RO_ANNOUNCEMENT_SIZE = "Announcement Size"
RdKGToolMenu.constants.RO_IN_COMBAT_ENABLED = "In Combat State Enabled"
RdKGToolMenu.constants.RO_IN_COMBAT_COLOR = "In Combat Color"
RdKGToolMenu.constants.RO_OUT_OF_COMBAT_COLOR = "Out Of Combat Color"
RdKGToolMenu.constants.RO_IN_STEALTH_ENABLED = "In Stealth State Enabled"
RdKGToolMenu.constants.RO_ULTIMATE_GROUPS_ENABLED = "Ultimate Groups Enabled"
RdKGToolMenu.constants.RO_ULTIMATE_SORTING_MODE = "Order Mode"
RdKGToolMenu.constants.RO_ULTIMATE_GROUP_SIZE_DESTRO = "Destruction Group Size"
RdKGToolMenu.constants.RO_ULTIMATE_GROUP_SIZE_STORM = "Storm Group Size"
RdKGToolMenu.constants.RO_ULTIMATE_GROUP_SIZE_NORTHERNSTORM = "Northern Storm Group Size"
RdKGToolMenu.constants.RO_ULTIMATE_GROUP_SIZE_PERMAFROST = "Permafrost Group Size"
RdKGToolMenu.constants.RO_ULTIMATE_GROUP_SIZE_NEGATE = "Negate Group Size"
RdKGToolMenu.constants.RO_ULTIMATE_GROUP_SIZE_NEGATE_OFFENSIVE = "Negate Off Group Size"
RdKGToolMenu.constants.RO_ULTIMATE_GROUP_SIZE_NEGATE_COUNTER = "Negate Counter Group Size"
RdKGToolMenu.constants.RO_ULTIMATE_GROUP_SIZE_NOVA = "Nova Group Size"
RdKGToolMenu.constants.RO_ULTIMATE_DISPLAY_MODE = "Display Mode"
RdKGToolMenu.constants.RO_MAX_DISTANCE = "Max Distance"
RdKGToolMenu.constants.RO_SOUND_ENABLED = "Sound Enabled"
RdKGToolMenu.constants.RO_SELECTED_SOUND = "Selected Sound"
RdKGToolMenu.constants.RO_HEADER_GROUPS = "|c4592FFResource Overview (Split)|r"
RdKGToolMenu.constants.RO_GROUPS_ENABLED = "Groups Enabled"
RdKGToolMenu.constants.RO_GROUPS_MODE = "Mode"
RdKGToolMenu.constants.RO_GROUPS_1_NAME = "Group 1 Name"
RdKGToolMenu.constants.RO_GROUPS_2_NAME = "Group 2 Name"
RdKGToolMenu.constants.RO_GROUPS_3_NAME = "Group 3 Name"
RdKGToolMenu.constants.RO_GROUPS_4_NAME = "Group 4 Name"
RdKGToolMenu.constants.RO_GROUPS_5_NAME = "Group 5 Name"
RdKGToolMenu.constants.RO_GROUPS_1_ENABLED = "Group 1 Enabled"
RdKGToolMenu.constants.RO_GROUPS_2_ENABLED = "Group 2 Enabled"
RdKGToolMenu.constants.RO_GROUPS_3_ENABLED = "Group 3 Enabled"
RdKGToolMenu.constants.RO_GROUPS_4_ENABLED = "Group 4 Enabled"
RdKGToolMenu.constants.RO_GROUPS_5_ENABLED = "Group 5 Enabled"
RdKGToolMenu.constants.RO_GROUPS_1_DEFAULT = "Damage"
RdKGToolMenu.constants.RO_GROUPS_2_DEFAULT = "Support"
RdKGToolMenu.constants.RO_GROUPS_3_DEFAULT = "Heal"
RdKGToolMenu.constants.RO_GROUPS_4_DEFAULT = "Synergy"
RdKGToolMenu.constants.RO_GROUPS_5_DEFAULT = "Undefined"
RdKGToolMenu.constants.RO_GROUPS_PRIORITY = " Priority:"
RdKGToolMenu.constants.RO_GROUPS_GROUP = " Group:"
RdKGToolMenu.constants.RO_COLOR_GROUPS_EDGE_OUT_OF_COMBAT = "Border Out Of Combat"
RdKGToolMenu.constants.RO_COLOR_GROUPS_EDGE_IN_COMBAT = "Border In Combat"
RdKGToolMenu.constants.RO_SIZE = "Size"
RdKGToolMenu.constants.RO_SPACING = "Spacing"
RdKGToolMenu.constants.RO_SHARED_SETTING = "This resource overview setting (Combined / Split) is shared. Changing the value will change the value in both modules. Disable the modules functionality by adjusting other (windows) settings."

--HP Damage Meter
RdKGToolMenu.constants.HDM_HEADER = "|c4592FFHealing Damage Meter|r"
RdKGToolMenu.constants.HDM_ENABLED = "Enabled"
RdKGToolMenu.constants.HDM_PVP_ONLY = "PvP Only"
RdKGToolMenu.constants.HDM_POSITION_FIXED = "Position Fixed"
RdKGToolMenu.constants.HDM_WINDOW_ENABLED = "Window Enabled"
RdKGToolMenu.constants.HDM_USING_ALPHA = "Using Alpha"
RdKGToolMenu.constants.HDM_USING_COLORS = "Background Colors"
RdKGToolMenu.constants.HDM_USING_HIGHLIGHT_APPLICANT = "Applicant Highlight"
RdKGToolMenu.constants.HDM_AUTO_RESET = "Reset Counter Out Of Combat"
RdKGToolMenu.constants.HDM_SELECTED_VIEWMODE = "Selected Mode"
RdKGToolMenu.constants.HDM_ALIVE_COLOR = "Color Alive"
RdKGToolMenu.constants.HDM_DEAD_COLOR = "Color Dead"
RdKGToolMenu.constants.HDM_BACKGROUND_COLOR_HEALER = "Background Color Healer"
RdKGToolMenu.constants.HDM_BACKGROUND_COLOR_DD = "Background Color DD"
RdKGToolMenu.constants.HDM_BACKGROUND_COLOR_TANK = "Background Color Tank"
RdKGToolMenu.constants.HDM_BACKGROUND_COLOR_APPLICANT = "Background Color Applicant"
RdKGToolMenu.constants.HDM_SIZE = "Size"

--Potion Overview
RdKGToolMenu.constants.PO_HEADER = "|c4592FFPotion Overview|r"
RdKGToolMenu.constants.PO_ENABLED = "Enabled"
RdKGToolMenu.constants.PO_PVP_ONLY = "PvP Only"
RdKGToolMenu.constants.PO_POSITION_FIXED = "Position Fixed"
RdKGToolMenu.constants.PO_COLOR_BACKGROUND_NO_IMMOVABLE = "Background Color No Immovable"
RdKGToolMenu.constants.PO_COLOR_BACKGROUND_IMMOVABLE_FULL = "Background Color Immovable Full"
RdKGToolMenu.constants.PO_COLOR_BACKGROUND_IMMOVABLE_LOW = "Background Color Immovable Low"
RdKGToolMenu.constants.PO_COLOR_PROGRESS_IMMOVABLE = "Progress Color Immovable"
-- U30+ Change (Temporary Fix)
--[[
RdKGToolMenu.constants.PO_COLOR_CRAFTED_PROGRESS_POTION = "Progress Color Potion (Crafted)"
RdKGToolMenu.constants.PO_COLOR_CROWN_PROGRESS_POTION = "Progress Color Potion (Crown)"
RdKGToolMenu.constants.PO_COLOR_NON_CRAFTED_PROGRESS_POTION = "Progress Color Potion (Non Crafted)"
RdKGToolMenu.constants.PO_COLOR_ALLIANCE_PROGRESS_POTION = "Progress Color Potion (Alliance)"
]]
RdKGToolMenu.constants.PO_COLOR_CRAFTED_PROGRESS_POTION = "Progress Color Potion"
RdKGToolMenu.constants.PO_COLOR_LABEL_IMMOVABLE = "Immovable Label Color"
RdKGToolMenu.constants.PO_COLOR_LABEL_POTION = "Potion Label Color"
RdKGToolMenu.constants.PO_COLOR_BACKDROP_IMMOVABLE = "Immovable Backdrop Color"
RdKGToolMenu.constants.PO_COLOR_BACKDROP_POTION = "Potion Backdrop Color"
RdKGToolMenu.constants.PO_SOUND_ENABLED = "Sound Enabled"
RdKGToolMenu.constants.PO_SELECTED_SOUND = "Selected Sound"

--Detonation Tracker
RdKGToolMenu.constants.DT_HEADER = "|c4592FFDetonation / Shalk Tracker|r"
RdKGToolMenu.constants.DT_ENABLED = "Enabled"
RdKGToolMenu.constants.DT_PVP_ONLY = "PvP Only"
RdKGToolMenu.constants.DT_POSITION_FIXED = "Position Fixed"
RdKGToolMenu.constants.DT_FONT_COLOR_DETONATION = "Detonation: Font Color"
RdKGToolMenu.constants.DT_PROGRESS_COLOR_DETONATION = "Detonation: Progress Color"
RdKGToolMenu.constants.DT_FONT_COLOR_SUBTERRANEAN_ASSAULT = "Sub Assault: Font Color"
RdKGToolMenu.constants.DT_PROGRESS_COLOR_SUBTERRANEAN_ASSAULT = "Sub Assault: Progress Color"
RdKGToolMenu.constants.DT_FONT_COLOR_SUBTERRANEAN_ASSAULT2 = "Sub Assault 2: Font Color"
RdKGToolMenu.constants.DT_PROGRESS_COLOR_SUBTERRANEAN_ASSAULT2 = "Sub Assault 2: Progress Color"
RdKGToolMenu.constants.DT_FONT_COLOR_DEEP_FISSURE = "Deep Fissure: Font Color"
RdKGToolMenu.constants.DT_PROGRESS_COLOR_DEEP_FISSURE = "Deep Fissure: Progress Color"
RdKGToolMenu.constants.DT_FONT_COLOR_DEEP_FISSURE2 = "Deep Fissure 2: Font Color"
RdKGToolMenu.constants.DT_PROGRESS_COLOR_DEEP_FISSURE2 = "Deep Fissure 2: Progress Color"
RdKGToolMenu.constants.DT_FONT_COLOR_SOUL_OF_FLAME = "Soul Of Flame: Font Color"
RdKGToolMenu.constants.DT_PROGRESS_COLOR_SOUL_OF_FLAME = "Soul Of Flame: Progress Color"
RdKGToolMenu.constants.DT_SOUL_OF_FLAME_PROMPT_ENABLED = "Soul Of Flame: Cast Prompt"
RdKGToolMenu.constants.DT_SOUL_OF_FLAME_TEXT = "Cast Prompt Text"
RdKGToolMenu.constants.DT_SIZE = "Size"
RdKGToolMenu.constants.DT_MODE = "Mode"
RdKGToolMenu.constants.DT_SMOOTH_TRANSITION = "Smooth Transition"
RdKGToolMenu.constants.DT_SOUL_BETWEEN_DESC = "Display Soul Of Flame Prompt Window"
RdKGToolMenu.constants.DT_SOUL_BETWEEN1 = "Between"
RdKGToolMenu.constants.DT_SOUL_BETWEEN2 = "And"

--Group Beams
RdKGToolMenu.constants.GB_HEADER = "|c4592FFGroup Beams|r"
RdKGToolMenu.constants.GB_DESCRIPTION = "The beam of the player depends on the role that has been assigned. The role can be assigned by the group leader or by the player."
RdKGToolMenu.constants.GB_ENABLED = "Enabled"
RdKGToolMenu.constants.GB_PVP_ONLY = "PvP Only"
RdKGToolMenu.constants.GB_HIDE_WHEN_DEAD = "Hide When Dead"
RdKGToolMenu.constants.GB_SIZE = "Size"
RdKGToolMenu.constants.GB_SELECTED_BEAM = "Selected Beam"
RdKGToolMenu.constants.GB_ROLE_RAPID_ENABLED = "Rapid Enabled"
RdKGToolMenu.constants.GB_ROLE_RAPID_COLOR = "Rapid Color"
RdKGToolMenu.constants.GB_ROLE_PURGE_ENABLED = "Purge Enabled"
RdKGToolMenu.constants.GB_ROLE_PURGE_COLOR = "Purge Color"
RdKGToolMenu.constants.GB_ROLE_HEAL_ENABLED = "Heal Enabled"
RdKGToolMenu.constants.GB_ROLE_HEAL_COLOR = "Heal Color"
RdKGToolMenu.constants.GB_ROLE_DD_ENABLED = "DD Enabled"
RdKGToolMenu.constants.GB_ROLE_DD_COLOR = "DD Color"
RdKGToolMenu.constants.GB_ROLE_SYNERGY_ENABLED = "Synergy Enabled"
RdKGToolMenu.constants.GB_ROLE_SYNERGY_COLOR = "Synergy Color"
RdKGToolMenu.constants.GB_ROLE_CC_ENABLED = "CC Enabled"
RdKGToolMenu.constants.GB_ROLE_CC_COLOR = "CC Color"
RdKGToolMenu.constants.GB_ROLE_SUPPORT_ENABLED = "Support Enabled"
RdKGToolMenu.constants.GB_ROLE_SUPPORT_COLOR = "Support Color"
RdKGToolMenu.constants.GB_ROLE_PLACEHOLDER_ENABLED = "Undefined Enabled"
RdKGToolMenu.constants.GB_ROLE_PLACEHOLDER_COLOR = "Undefined Color"
RdKGToolMenu.constants.GB_ROLE_APPLICANT_ENABLED = "Applicant Enabled"
RdKGToolMenu.constants.GB_ROLE_APPLICANT_COLOR = "Applicant Color"

--I See Dead People
RdKGToolMenu.constants.ISDP_HEADER = "|c4592FFI See Dead People|r"
RdKGToolMenu.constants.ISDP_ENABLED = "Enabled"
RdKGToolMenu.constants.ISDP_PVP_ONLY = "PvP Only"
RdKGToolMenu.constants.ISDP_SIZE = "Size"
RdKGToolMenu.constants.ISDP_SELECTED_BEAM = "Selected Beam"
RdKGToolMenu.constants.ISDP_COLOR_DEAD = "Dead Color"
RdKGToolMenu.constants.ISDP_COLOR_BEING_RESURRECTED = "Being Resurrected Color"
RdKGToolMenu.constants.ISDP_COLOR_RESURRECTED = "Resurrected Color"

--Compass
RdKGToolMenu.constants.COMPASS_HEADER = "|cFF8174Compass Settings|r"
--YACS
RdKGToolMenu.constants.YACS_HEADER = "|c4592FFYet Another Compass|r"
RdKGToolMenu.constants.YACS_CHK_ADDON_ENABLED = "Enabled"
RdKGToolMenu.constants.YACS_CHK_PVP = "Enabled in PVP"
RdKGToolMenu.constants.YACS_CHK_PVE = "Enabled in PVE"
RdKGToolMenu.constants.YACS_CHK_COMBAT = "Enabled in Combat"
RdKGToolMenu.constants.YACS_CHK_MOVABLE = "Movable Compass"
RdKGToolMenu.constants.YACS_COLOR_COMPASS = "Compass Color"
RdKGToolMenu.constants.YACS_COMPASS_SIZE = "Compass Size"
RdKGToolMenu.constants.YACS_COMPASS_SIZE_TOOLTIPE = "Sets the size of the compass."
RdKGToolMenu.constants.YACS_COMPASS_STYLE = "Style"
RdKGToolMenu.constants.YACS_COMPASS_STYLE_TOOLTIP = "Select the compass style you prefer."
RdKGToolMenu.constants.YACS_RESTORE_DEFAULTS = "Restore Defaults"

--SC
RdKGToolMenu.constants.COMPASS_SC_HEADER = "|c4592FFSimple Compass|r"
RdKGToolMenu.constants.COMPASS_SC_ENABLED = "Enabled"
RdKGToolMenu.constants.COMPASS_SC_PVP = "Enabled in PVP"
RdKGToolMenu.constants.COMPASS_SC_PVE = "Enabled in PVE"
RdKGToolMenu.constants.COMPASS_SC_POSITION_FIXED = "Position Fixed"
RdKGToolMenu.constants.COMPASS_SC_COLOR_BACKDROP = "Background Color"
RdKGToolMenu.constants.COMPASS_SC_COLOR_DIRECTION_NORTH = "Color North"
RdKGToolMenu.constants.COMPASS_SC_COLOR_DIRECTION_SOUTH = "Color South"
RdKGToolMenu.constants.COMPASS_SC_COLOR_DIRECTION_WEST = "Color West"
RdKGToolMenu.constants.COMPASS_SC_COLOR_DIRECTION_EAST = "Color East"
RdKGToolMenu.constants.COMPASS_SC_COLOR_DIRECTION_OTHERS = "Color Others"
RdKGToolMenu.constants.COMPASS_SC_COLOR_MARKERS = "Color Markers"

--Toolbox
RdKGToolMenu.constants.TOOLBOX_HEADER = "|cFF8174Toolbox Settings|r"
--Siege Merchant
RdKGToolMenu.constants.SM_HEADER = "|c4592FFSiege Merchant|r"
RdKGToolMenu.constants.SM_ENABLED = "Enabled"
RdKGToolMenu.constants.SM_SEND_CHAT_MESSAGES = "Send Chat Messages"
RdKGToolMenu.constants.SM_ITEM_REPAIR_WALL = "Keep Wall Masonry Repair Kit"
RdKGToolMenu.constants.SM_ITEM_REPAIR_DOOR = "Keep Door Woodwork Repair Kit"
RdKGToolMenu.constants.SM_ITEM_REPAIR_SIEGE = "Siege Repair Kit"
RdKGToolMenu.constants.SM_ITEM_BALLISTA_FIRE = "Fire Ballista"
RdKGToolMenu.constants.SM_ITEM_BALLISTA_STONE = "Ballista"
RdKGToolMenu.constants.SM_ITEM_BALLISTA_LIGHTNING = "Lightning Ballista"
RdKGToolMenu.constants.SM_ITEM_TREBUCHET_FIRE = "Firepot Trebuchet"
RdKGToolMenu.constants.SM_ITEM_TREBUCHET_STONE = "Stone Trebuchet"
RdKGToolMenu.constants.SM_ITEM_TREBUCHET_ICE = "Iceball Trebuchet"
RdKGToolMenu.constants.SM_ITEM_CATAPULT_MEATBAG = "Meatbag Catapult"
RdKGToolMenu.constants.SM_ITEM_CATAPULT_OIL = "Oil Catapult"
RdKGToolMenu.constants.SM_ITEM_CATAPULT_SCATTERSHOT = "Scattershot Catapult"
RdKGToolMenu.constants.SM_ITEM_OIL = "Flaming Oil"
RdKGToolMenu.constants.SM_ITEM_CAMP = "Forward Camp"
RdKGToolMenu.constants.SM_ITEM_RAM = "Battering Ram"
RdKGToolMenu.constants.SM_ITEM_KEEP_RECALL = "Keep Recall Stone"
RdKGToolMenu.constants.SM_ITEM_DESTRUCTIBLE_REPAIR = "Bridge / Milegate Repair Kit"
RdKGToolMenu.constants.SM_MIN = "Minimum"
RdKGToolMenu.constants.SM_MAX = "Maximum"
RdKGToolMenu.constants.SM_PAYMENT_OPTIONS = "Payment Options"
RdKGToolMenu.constants.SM_ITEM_REPAIR_ALL = "Cyrodiil Repair Kit"
RdKGToolMenu.constants.SM_ITEM_POT_RED = "Alliance Health Draught"
RdKGToolMenu.constants.SM_ITEM_POT_GREEN = "Alliance Battle Draught"
RdKGToolMenu.constants.SM_ITEM_POT_BLUE = "Alliance Spell Draught"
RdKGToolMenu.constants.SM_ITEM_TRI_POT = "Bound Tri-Restoration Potion"
RdKGToolMenu.constants.SM_ITEM_CF_TACK = "Cyrodilic Field Tack"
RdKGToolMenu.constants.SM_ITEM_CF_TREAT = "Cyrodilic Field Treat"
RdKGToolMenu.constants.SM_ITEM_CF_BAR = "Cyrodilic Field Bar"
RdKGToolMenu.constants.SM_ITEM_CF_BREW = "Cyrodilic Field Brew"
RdKGToolMenu.constants.SM_ITEM_CF_TEA = "Cyrodilic Field Tea"
RdKGToolMenu.constants.SM_ITEM_CF_TONIC = "Cyrodilic Field Tonic"
RdKGToolMenu.constants.SM_ITEM_SOUL_GEM = "Soul Gem"
RdKGToolMenu.constants.SM_ITEM_SOUL_GEM_EMPTY = "Soul Gem (Empty)"

--Recharger
RdKGToolMenu.constants.RECHARGER_HEADER = "|c4592FFRecharger|r"
RdKGToolMenu.constants.RECHARGER_ENABLED = "Enabled"
RdKGToolMenu.constants.RECHARGER_SEND_CHAT_MESSAGES = "Send Chat Messages"
RdKGToolMenu.constants.RECHARGER_PERCENT = "Minimum Recharge Percentage"
RdKGToolMenu.constants.RECHARGER_SOULGEMS_EMPTY_WARNING = "No Soul Gems Alert"
RdKGToolMenu.constants.RECHARGER_SOULGEMS_THRESHOLD_WARNING = "Soon Out Of Soul Gems Alert"
RdKGToolMenu.constants.RECHARGER_SOULGEMS_THRESHOLD_SLIDER = "Soul Gems Threshold"
RdKGToolMenu.constants.RECHARGER_SOULGEMS_EMPTY_LOGIN_WARNING = "Soul Gems Login Alert"
RdKGToolMenu.constants.RECHARGER_INTERVAL = "Check Interval"

--Keep Claimer
RdKGToolMenu.constants.KC_HEADER = "|c4592FFKeep Claimer|r"
RdKGToolMenu.constants.KC_ENABLED = "Enabled"
RdKGToolMenu.constants.KC_GUILD_1 = "Priority 1"
RdKGToolMenu.constants.KC_GUILD_2 = "Priority 2"
RdKGToolMenu.constants.KC_GUILD_3 = "Priority 3"
RdKGToolMenu.constants.KC_GUILD_4 = "Priority 4"
RdKGToolMenu.constants.KC_GUILD_5 = "Priority 5"
RdKGToolMenu.constants.KC_CLAIM_KEEPS = "Claim Keeps"
RdKGToolMenu.constants.KC_CLAIM_OUTPOSTS = "Claim Outposts"
RdKGToolMenu.constants.KC_CLAIM_RESOURCES = "Claim Resources"

--Buff Food Tracker
RdKGToolMenu.constants.BFT_HEADER = "|c4592FFBuff Food Tracker|r"
RdKGToolMenu.constants.BFT_ENABLED = "Enabled"
RdKGToolMenu.constants.BFT_PVP_ONLY = "PvP Only"
RdKGToolMenu.constants.BFT_POSITION_FIXED = "Position Fixed"
RdKGToolMenu.constants.BFT_SIZE = "Warning Size"
RdKGToolMenu.constants.BFT_COLOR = "Warning Color"
RdKGToolMenu.constants.BFT_SOUND_ENABLED = "Sound Enabled"
RdKGToolMenu.constants.BFT_SELECTED_SOUND = "Selected Sound"
RdKGToolMenu.constants.BFT_WARNING_TIMER = "Warning Timer"

--Cyrodiil Log
RdKGToolMenu.constants.CL_HEADER = "|c4592FFCyrodiil Log|r"
RdKGToolMenu.constants.CL_ENABLED = "Enabled"
RdKGToolMenu.constants.CL_GUILD_CLAIM_ENABLED = "Guild Claim Messages"
RdKGToolMenu.constants.CL_GUILD_LOST_ENABLED = "Guild Lost Messages"
RdKGToolMenu.constants.CL_UA_ENABLED = "Under Attack Messages"
RdKGToolMenu.constants.CL_UA_LOST_ENABLED = "Under Attack Status Lost Messages"
RdKGToolMenu.constants.CL_KEEP_ALLIANCE_CHANGED_ENABLED = "Owning Alliance Changed Messages"
RdKGToolMenu.constants.CL_TICK_DEFENSE = "Defense Tick Messages"
RdKGToolMenu.constants.CL_TICK_OFFENSE = "Offense Tick Messages"
RdKGToolMenu.constants.CL_SCROLL_NOTIFICATIONS = "Scroll Messages"
RdKGToolMenu.constants.CL_EMPEROR_ENABLED = "Emperor Messages"
RdKGToolMenu.constants.CL_QUEST_ENABLED = "Quest Messages"
RdKGToolMenu.constants.CL_BATTLEGROUND_ENABLED = "Battleground Messages"
RdKGToolMenu.constants.CL_DAEDRIC_ARTIFACT_ENABLED = "Daedric Artifacte Messages"

--Cyrodiil Status
RdKGToolMenu.constants.CS_HEADER = "|c4592FFCyrodiil Status|r"
RdKGToolMenu.constants.CS_ENABLED = "Enabled"
RdKGToolMenu.constants.CS_POSITION_FIXED = "Position Fixed"
RdKGToolMenu.constants.CS_HIDE_ON_WORLDMAP = "Hide on World Map"
RdKGToolMenu.constants.CS_SHOW_FLAGS = "Show Flags"
RdKGToolMenu.constants.CS_SHOW_SIEGES = "Show Sieges"
RdKGToolMenu.constants.CS_SHOW_OWNER_CHANGES = "Show Keep Flip Timers"
RdKGToolMenu.constants.CS_SHOW_ACTION_TIMERS = "Show Action Timers"
RdKGToolMenu.constants.CS_COLOR_DEFAULT = "Default Color"
RdKGToolMenu.constants.CS_COLOR_COOLDOWN = "Cooldown Color"
RdKGToolMenu.constants.CS_COLOR_FLIPS_POSITIVE = "Positive Flag Flip Color"
RdKGToolMenu.constants.CS_COLOR_FLIPS_NEGATIVE = "Negative Flag Flip Color"
RdKGToolMenu.constants.CS_SHOW_KEEPS = "Show Keeps"
RdKGToolMenu.constants.CS_SHOW_OUTPOSTS = "Show Outposts"
RdKGToolMenu.constants.CS_SHOW_RESOURCES = "Show Resources"
RdKGToolMenu.constants.CS_SHOW_VILLAGES = "Show Towns"
RdKGToolMenu.constants.CS_SHOW_TEMPLES = "Show Temples"
RdKGToolMenu.constants.CS_SHOW_DESTRUCTIBLES = "Show Destructibles"

--Enhancements
RdKGToolMenu.constants.ENHANCE_HEADER = "|c4592FFEnhancements|r"
RdKGToolMenu.constants.ENHANCE_QUEST_TRACKER_ENABLED = "Quest Tracker Disabled"
RdKGToolMenu.constants.ENHANCE_QUEST_TRACKER_PVP_ONLY = "Quest Tracker PvP Only"
RdKGToolMenu.constants.ENHANCE_COMPASS_TWEAKS_ENABLED = "Compass Enhancements Enabled"
RdKGToolMenu.constants.ENHANCE_COMPASS_PVP_ONLY = "Compass PvP Only"
RdKGToolMenu.constants.ENHANCE_COMPASS_HIDDEN = "Compass Hidden"
RdKGToolMenu.constants.ENHANCE_COMPASS_WIDTH = "Compass Width"
RdKGToolMenu.constants.ENHANCE_ALERTS_TWEAKS_ENABLED = "Alerts Enhancements Enabled"
RdKGToolMenu.constants.ENHANCE_ALERTS_PVP_ONLY = "Alerts PvP Only"
RdKGToolMenu.constants.ENHANCE_ALERTS_HIDDEN = "Alerts Hidden"
RdKGToolMenu.constants.ENHANCE_ALERTS_POSITION = "Alerts Position"
RdKGToolMenu.constants.ENHANCE_ALERTS_COLOR = "Alerts Color"
RdKGToolMenu.constants.ENHANCE_RESPAWN_TIMER_ENABLED = "Respawn Timer Enabled"

--Respawner
RdKGToolMenu.constants.RESPAWNER_HEADER = "|c4592FFRespawner|r"
RdKGToolMenu.constants.RESPAWNER_ENABLED = "Enabled"
RdKGToolMenu.constants.RESPAWNER_RESTRICTED_PORT = "Restricted Range"

--Camp Preview
RdKGToolMenu.constants.CP_HEADER = "|c4592FFCamp Preview|r"
RdKGToolMenu.constants.CP_ENABLED = "Enabled"

--Synergy Prevention
RdKGToolMenu.constants.SP_HEADER = "|c4592FFSynergy Prevention|r"
RdKGToolMenu.constants.SP_ENABLED = "Enabled"
RdKGToolMenu.constants.SP_PVP_ONLY = "PvP Only"
RdKGToolMenu.constants.SP_WINDOW_ENABLED = "Window Enabled"
RdKGToolMenu.constants.SP_POSITION_FIXED = "Position Fixed"
RdKGToolMenu.constants.SP_MODE = "Mode"
RdKGToolMenu.constants.SP_MAX_DISTANCE = "Maximum Distance"
RdKGToolMenu.constants.SP_SYNERGY_COMBUSTION_SHARD = "Prevent Combustion / Shards"
RdKGToolMenu.constants.SP_SYNERGY_TALONS = "Prevent Talons"
RdKGToolMenu.constants.SP_SYNERGY_NOVA = "Prevent Nova"
RdKGToolMenu.constants.SP_SYNERGY_BLOOD_ALTAR = "Prevent Altar"
RdKGToolMenu.constants.SP_SYNERGY_STANDARD = "Prevent Standard"
RdKGToolMenu.constants.SP_SYNERGY_PURGE = "Prevent Ritual"
RdKGToolMenu.constants.SP_SYNERGY_BONE_SHIELD = "Prevent Bone Shield"
RdKGToolMenu.constants.SP_SYNERGY_FLOOD_CONDUIT = "Prevent Conduit"
RdKGToolMenu.constants.SP_SYNERGY_ATRONACH = "Prevent Atronach"
RdKGToolMenu.constants.SP_SYNERGY_TRAPPING_WEBS = "Prevent Trapping Webs"
RdKGToolMenu.constants.SP_SYNERGY_RADIATE = "Prevent Radiate"
RdKGToolMenu.constants.SP_SYNERGY_CONSUMING_DARKNESS = "Prevent Consuming Darkness"
RdKGToolMenu.constants.SP_SYNERGY_SOUL_LEECH = "Prevent Soul Leech"
RdKGToolMenu.constants.SP_SYNERGY_WARDEN_HEALING = "Prevent Healing Seed"
RdKGToolMenu.constants.SP_SYNERGY_GRAVE_ROBBER = "Prevent Grave Robber"
RdKGToolMenu.constants.SP_SYNERGY_PURE_AGONY = "Prevent Pure Agony"
RdKGToolMenu.constants.SP_SYNERGY_ICY_ESCAPE = "Prevent Icy Escape"
RdKGToolMenu.constants.SP_SYNERGY_SANGUINE_BURST = "Prevent Sanguine Burst"
RdKGToolMenu.constants.SP_SYNERGY_HEED_THE_CALL = "Prevent Heed the Call"
RdKGToolMenu.constants.SP_SYNERGY_URSUS = "Prevent Ursus's Blessing"
RdKGToolMenu.constants.SP_SYNERGY_GRYPHON = "Prevent Gryphon's Reprisal"
RdKGToolMenu.constants.SP_SYNERGY_RUNEBREAK = "Prevent Runebreak"
RdKGToolMenu.constants.SP_SYNERGY_PASSAGE = "Prevent Passage"
RdKGToolMenu.constants.SP_SYNERGY_RECOVERY = "Prevent Convergence Release"

--Synergy Overview
RdKGToolMenu.constants.SO_HEADER = "|c4592FFSynergy Overview|r"
RdKGToolMenu.constants.SO_ENABLED = "Enabled"
RdKGToolMenu.constants.SO_WINDOW_ENABLED = "Window Enabled"
RdKGToolMenu.constants.SO_PVP_ONLY = "PvP Only"
RdKGToolMenu.constants.SO_POSITION_FIXED = "Position Fixed"
RdKGToolMenu.constants.SO_DISPLAY_MODE = "Display Mode"
RdKGToolMenu.constants.SO_TABLE_MODE = "Table Mode"
RdKGToolMenu.constants.SO_SIZE = "Size"
RdKGToolMenu.constants.SO_COLOR_SYNERGY_BACKDROP = "Synergy Backdrop Color"
RdKGToolMenu.constants.SO_COLOR_SYNERGY_PROGRESS = "Synergy Progress Color"
RdKGToolMenu.constants.SO_COLOR_SYNERGY = "Synergy Color"
RdKGToolMenu.constants.SO_COLOR_BACKGROUND = "Background Color"
RdKGToolMenu.constants.SO_COLOR_TEXT = "Text Color"
RdKGToolMenu.constants.SO_SYNERGY_COMBUSTION_SHARD = "Show Combustion / Shards"
RdKGToolMenu.constants.SO_SYNERGY_TALONS = "Show Talons"
RdKGToolMenu.constants.SO_SYNERGY_NOVA = "Show Nova"
RdKGToolMenu.constants.SO_SYNERGY_BLOOD_ALTAR = "Show Altar"
RdKGToolMenu.constants.SO_SYNERGY_STANDARD = "Show Standard"
RdKGToolMenu.constants.SO_SYNERGY_PURGE = "Show Ritual"
RdKGToolMenu.constants.SO_SYNERGY_BONE_SHIELD = "Show Bone Shield"
RdKGToolMenu.constants.SO_SYNERGY_FLOOD_CONDUIT = "Show Conduit"
RdKGToolMenu.constants.SO_SYNERGY_ATRONACH = "Show Atronach"
RdKGToolMenu.constants.SO_SYNERGY_TRAPPING_WEBS = "Show Trapping Webs"
RdKGToolMenu.constants.SO_SYNERGY_RADIATE = "Show Radiate"
RdKGToolMenu.constants.SO_SYNERGY_CONSUMING_DARKNESS = "Show Consuming Darkness"
RdKGToolMenu.constants.SO_SYNERGY_SOUL_LEECH = "Show Soul Leech"
RdKGToolMenu.constants.SO_SYNERGY_WARDEN_HEALING = "Show Healing Seed"
RdKGToolMenu.constants.SO_SYNERGY_GRAVE_ROBBER = "Show Grave Robber"
RdKGToolMenu.constants.SO_SYNERGY_PURE_AGONY = "Show Pure Agony"
RdKGToolMenu.constants.SO_SYNERGY_ICY_ESCAPE = "Show Icy Escape"
RdKGToolMenu.constants.SO_SYNERGY_SANGUINE_BURST = "Show Sanguine Burst"
RdKGToolMenu.constants.SO_SYNERGY_HEED_THE_CALL = "Show Heed the Call"
RdKGToolMenu.constants.SO_SYNERGY_URSUS = "Show Ursus's Blessing"
RdKGToolMenu.constants.SO_SYNERGY_GRYPHON = "Show Gryphon's Reprisal"
RdKGToolMenu.constants.SO_SYNERGY_RUNEBREAK = "Show Runebreak"
RdKGToolMenu.constants.SO_SYNERGY_PASSAGE = "Show Passage"
RdKGToolMenu.constants.SO_SYNERGY_RECOVERY = "Show Convergence Release"
RdKGToolMenu.constants.SO_REDUCED_SPACING = "Reduced Spacing"

--Role Assignment
RdKGToolMenu.constants.RA_HEADER = "|c4592FFRole Assignment|r"
RdKGToolMenu.constants.RA_ENABLED = "Enabled"
RdKGToolMenu.constants.RA_OVERRIDE_ALLOWED = "Override Allowed"
RdKGToolMenu.constants.RA_ROLE = "Character Role"

--Campaign Joiner
RdKGToolMenu.constants.CAJ_HEADER = "|c4592FFCampaign Auto Join|r"
RdKGToolMenu.constants.CAJ_ENABLED = "Enabled"

--AvA Messages
RdKGToolMenu.constants.AM_HEADER = "|c4592FFAvA Messages|r"
RdKGToolMenu.constants.AM_PVP_ONLY = "PvP Only"
RdKGToolMenu.constants.AM_CORONATE_EMPEROR = "Coronate Emperor Messages"
RdKGToolMenu.constants.AM_DEPOSE_EMPEROR = "Depose Emperor Messages"
RdKGToolMenu.constants.AM_KEEP_GATE = "Keep Gate Messages"
RdKGToolMenu.constants.AM_ARTIFACT_CONTROL = "Artifact Messages"
RdKGToolMenu.constants.AM_REVENGE_KILL = "Revenge Kill Messages"
RdKGToolMenu.constants.AM_AVENGE_KILL = "Avenge Kill Messages"
RdKGToolMenu.constants.AM_QUEST_ADDED = "Quest Added Messages"
RdKGToolMenu.constants.AM_QUEST_COMPLETE = "Quest Completed Messages"
RdKGToolMenu.constants.AM_QUEST_CONDITION_COUNTER_CHANGED = "Quest Counter Changed Messages"
RdKGToolMenu.constants.AM_QUEST_CONDITION_CHANGED = "Quest Condition Messages"
RdKGToolMenu.constants.AM_DAEDRIC_ARTIFACT_OBJECTIVE_SPAWNED_BUT_NOT_REVEALED = "Daedric Artifact Spawned Messages"
RdKGToolMenu.constants.AM_DAEDRIC_ARTIFACT_OBJECTIVE_STATE_CHANGED = "Daedric Artifact State Messages"

--Push Timer
RdKGToolMenu.constants.PT_HEADER = "|c4592FFPush Timer|r"
RdKGToolMenu.constants.PT_ENABLED = "Enabled"
RdKGToolMenu.constants.PT_POSITION_FIXED = "Position Fixed"
RdKGToolMenu.constants.PT_PVP_ONLY = "PvP Only"
RdKGToolMenu.constants.PT_FONT_COLOR = "Font Color"
RdKGToolMenu.constants.PT_LEAD_COLOR = "Lead Color"
RdKGToolMenu.constants.PT_SHALK_COLOR = "Shalk Color"
RdKGToolMenu.constants.PT_SOUL_COLOR = "Soul of Flame Color"
RdKGToolMenu.constants.PT_DETO_COLOR = "Detonation Color"
RdKGToolMenu.constants.PT_SIZE = "Size"
RdKGToolMenu.constants.PT_SMOOTH_TRANSITION = "Smooth Transition"
RdKGToolMenu.constants.PT_LEAD_LINE_COLOR = "Lead Line Color"
RdKGToolMenu.constants.PT_TIMER_ENABLED = "Timer Window Enabled"
RdKGToolMenu.constants.PT_TIMER_TEXT_ENABLED = "Timer Text Enabled"
RdKGToolMenu.constants.PT_TIMER_SHOW_ALL_ENABLED = "Show all"
RdKGToolMenu.constants.PT_OVERVIEW_ENABLED = "Overview Timer Enabled"
RdKGToolMenu.constants.PT_OVERVIEW_SIZE = "Size"
RdKGToolMenu.constants.PT_OVERVIEW_COLOR = "Color"
RdKGToolMenu.constants.PT_REACTION_ENABLED = "Timer Reaction Enabled"
RdKGToolMenu.constants.PT_REACTION_SIZE = "Size"
RdKGToolMenu.constants.PT_REACTION_COLOR = "Color"
RdKGToolMenu.constants.PT_REACTION_TEXT = "Displayed Text"
RdKGToolMenu.constants.PT_REACTION_TIME = "Time to show text"

--Util
RdKGToolMenu.constants.UTIL_HEADER = "|cFF8174Util Settings|r"

--Util Networking
RdKGToolMenu.constants.NET_HEADER = "|c4592FFNetworking|r"
RdKGToolMenu.constants.NET_ENABLED = "Enabled"
RdKGToolMenu.constants.NET_URGENT_MODE = "Urgent Mode"
RdKGToolMenu.constants.NET_INTERVAL = "Update Interval"

--Util Group
RdKGToolMenu.constants.UTIL_GROUP_HEADER = "|c4592FFGroup|r"
RdKGToolMenu.constants.UTIL_GROUP_DISPLAY_TYPE = "Display Type"

--Util Alliance Color
RdKGToolMenu.constants.AC_HEADER = "|c4592FFAlliance Colors|r"
RdKGToolMenu.constants.AC_DC_COLOR = "DC Color"
RdKGToolMenu.constants.AC_EP_COLOR = "EP Color"
RdKGToolMenu.constants.AC_AD_COLOR = "AD Color"
RdKGToolMenu.constants.AC_NO_ALLIANCE_COLOR = "No Alliance Color"

--Chat System
RdKGToolMenu.constants.CHAT_HEADER = "|c4592FFChat System|r"
RdKGToolMenu.constants.CHAT_ENABLED = "Enabled"
RdKGToolMenu.constants.CHAT_SELECTED_TAB = "Selected Tab"
RdKGToolMenu.constants.CHAT_REFRESH = "Refresh"
RdKGToolMenu.constants.CHAT_WARNINGS_ONLY = "Show Warnings"
RdKGToolMenu.constants.CHAT_DEBUG_ONLY = "Show Debug"
RdKGToolMenu.constants.CHAT_NORMAL_ONLY = "Show Normal"
RdKGToolMenu.constants.CHAT_PREFIX_ENABLED = "Prefix Enabled"
RdKGToolMenu.constants.CHAT_RDK_PREFIX_ENABLED = "RdK Prefix Enabled"
RdKGToolMenu.constants.CHAT_COLOR_PREFIX = "Prefix Color"
RdKGToolMenu.constants.CHAT_COLOR_BODY = "Body Color"
RdKGToolMenu.constants.CHAT_COLOR_WARNING = "Warning Color"
RdKGToolMenu.constants.CHAT_COLOR_DEBUG = "Debug Color"
RdKGToolMenu.constants.CHAT_COLOR_PLAYER = "Player Color"
RdKGToolMenu.constants.CHAT_ADD_TIMESTAMP = "Add Timestamp"
RdKGToolMenu.constants.CHAT_HIDE_SECONDS = "Hide Timestamp Seconds"
RdKGToolMenu.constants.CHAT_COLOR_TIMESTAMP = "Timestamp Color"

--Class Role
RdKGToolMenu.constants.CR_HEADER = "|cFF8174Class / Role|r"

--BG Templar Heal
RdKGToolMenu.constants.CRBG_TPHEAL_HEADER = "|c4592FFTemplar Healer (Group)|r"
RdKGToolMenu.constants.CRBG_TPHEAL_ENABLED = "Enabled"
RdKGToolMenu.constants.CRBG_TPHEAL_PVP_ONLY = "PvP Only"
RdKGToolMenu.constants.CRBG_TPHEAL_POSITION_FIXED = "Position Fixed"
RdKGToolMenu.constants.CRBG_TPHEAL_COLOR_PROGRESS_DAMAGE = "Progress Damage"
RdKGToolMenu.constants.CRBG_TPHEAL_COLOR_LABEL_DAMAGE = "Label Damage"
RdKGToolMenu.constants.CRBG_TPHEAL_COLOR_PROGRESS_HEALING = "Progress Healing"
RdKGToolMenu.constants.CRBG_TPHEAL_COLOR_LABEL_HEALING = "Label Healing"
RdKGToolMenu.constants.CRBG_TPHEAL_COLOR_PROGRESS_RECOVERY = "Progress Recovery"
RdKGToolMenu.constants.CRBG_TPHEAL_COLOR_LABEL_RECOVERY = "Label Recovery"
RdKGToolMenu.constants.CRBG_TPHEAL_COLOR_LABEL_COOLDOWN = "Label Cooldown"

--AddOn Integration
RdKGToolMenu.constants.ADDON_INTEGRATION_HEADER = "|cFF8174AddOn Integration Settings|r"
--Miats Pvp Alerts
RdKGToolMenu.constants.MPAI_HEADER = "|c4592FFMiat Pvp Alerts|r"
RdKGToolMenu.constants.MPAI_ENABLED = "Clear After Login (Enabled)"
RdKGToolMenu.constants.MPAI_ONPLAYERACTIVATION = "Clear After Loading Screen"
RdKGToolMenu.constants.MPAI_CLEAR_VARS = "Clear Vars"

--Admin
RdKGToolMenu.constants.ADMIN_HEADER = "|cFF8174Admin Settings|r"
--Group Share
RdKGToolMenu.constants.ADMIN_GROUP_SHARE_HEADER = "|c4592FFGroup Share|r"
RdKGToolMenu.constants.ADMIN_GROUP_SHARE_ENABLED = "Enabled"
RdKGToolMenu.constants.ADMIN_GROUP_SHARE_WARNING = "|cFF0000Enabling this will allow ranks 1 to 3 of any of your guilds to query the allowed configurations|r"
RdKGToolMenu.constants.ADMIN_GROUP_SHARE_ALLOW_CLIENT_CONFIGURATION = "Allow Client Configuration"
RdKGToolMenu.constants.ADMIN_GROUP_SHARE_ALLOW_ADDON_CONFIGURATION = "Allow AddOn Configuration"
RdKGToolMenu.constants.ADMIN_GROUP_SHARE_ALLOW_STATS = "Allow Stats"
RdKGToolMenu.constants.ADMIN_GROUP_SHARE_ALLOW_SKILLS = "Allow Skills"
RdKGToolMenu.constants.ADMIN_GROUP_SHARE_ALLOW_EQUIPMENT = "Allow Equipment"
RdKGToolMenu.constants.ADMIN_GROUP_SHARE_ALLOW_CP = "Allow CP"

--Base
--Crown
RdKGToolCrown.constants = RdKGToolCrown.constants or {}
RdKGToolCrown.constants.PAPA_CROWN_DETECTED = "Papa Crown has been detected. Crown Settings aren't applied."
RdKGToolCrown.constants.SANCTS_ULTIMATE_ORGANIZER_DETECTED = "Sancts Ultimate Organizer has been detected. Crown Settings aren't applied."
RdKGToolCrown.constants.CROWN_OF_CYRODIIL_DETECTED = "Crown of Cyrodiil has been detected. Crown Settings aren't applied."
RdKGToolCrown.config.crowns[1].name = "Crown: Standard"
RdKGToolCrown.config.crowns[2].name = "Arrow: White"
RdKGToolCrown.config.crowns[3].name = "Arrow: Blue"
RdKGToolCrown.config.crowns[4].name = "Arrow: Light Blue"
RdKGToolCrown.config.crowns[5].name = "Arrow: Yellow"
RdKGToolCrown.config.crowns[6].name = "Arrow: Light Green"
RdKGToolCrown.config.crowns[7].name = "Arrow: Red"
RdKGToolCrown.config.crowns[8].name = "Arrow: Pink"
RdKGToolCrown.config.crowns[9].name = "Crown: White"
RdKGToolCrown.config.crowns[10].name = "RdK: White"

--Auto Invite
RdKGToolAI.constants = RdKGToolAI.constants or {}
RdKGToolAI.constants.AI_MENU_NAME = "Auto Invite"
RdKGToolAI.constants.AI_ENABLED = "Enabled"
RdKGToolAI.constants.AI_INVITE_TEXT = "Invite String"
RdKGToolAI.constants.AI_SENT_INVITE_TO = "Sent invite to|c%s%s|c%s.|r"
RdKGToolAI.constants.AI_NOT_LEADER_SEND_TO = "Invitation has not been sent to|r |c%s%s|c%s. You don't have the crown.|r"
RdKGToolAI.constants.AI_FULL_GROUP = "No invitation has been sent. The group is already full."
RdKGToolAI.constants.AI_REQUIREMENTS_NOT_MET = "Invitation has not been sent to|r |c%s%s |c%s. The requirements aren't fulfilled.|r"
RdKGToolAI.constants.AI_AUTO_KICK_MESSAGE = "Group member|r |c%s%s|r |c%swill be removed from the group.|r"
RdKGToolAI.constants.TOGGLE_AI = "Toggle Auto Invite"
RdKGToolAI.constants.AI_ENABLED_TRUE = "Auto Invite activated."
RdKGToolAI.constants.AI_ENABLED_FALSE = "Auto Invite deactivated."
RdKGToolAI.constants.AI_MEMBER_LEFT = "Member|r |c%s%s|r |c%shas left the group."

--Follow The Crown Visual
RdKGToolFtcv.textures[1].name = "Arrow 1"
RdKGToolFtcv.textures[2].name = "Arrow 2"
RdKGToolFtcv.textures[3].name = "Arrow 3"
RdKGToolFtcv.textures[4].name = "Arrow 4"
RdKGToolFtcv.textures[5].name = "Arrow 5"
RdKGToolFtcv.textures[6].name = "Arrow 6"
RdKGToolFtcv.textures[7].name = "Arrow 7"
RdKGToolFtcv.textures[8].name = "Arrow 8"

--Follow The Crown Warnings
RdKGToolFtcw.constants = RdKGToolFtcw.constants or {}
RdKGToolFtcw.constants.FTCW_MAX_DISTANCE ="Maximum Distance Reached!!!"

--Resource Overview
RdKGToolOverview.config.ultimateModes = RdKGToolOverview.config.ultimateModes or {}
--RdKGToolOverview.config.ultimateModes[RdKGToolOverview.constants.ultimateModes.ORDER_BY_GROUP] = "Group Assignment"
RdKGToolOverview.config.ultimateModes[RdKGToolOverview.constants.ultimateModes.ORDER_BY_READINESS] = "Readiness"
RdKGToolOverview.config.ultimateModes[RdKGToolOverview.constants.ultimateModes.ORDER_BY_NAME] = "Name"
RdKGToolOverview.constants.BOOM = "BOOM"
RdKGToolOverview.constants.TOGGLE_BOOM = "Send BOOM"
RdKGToolOverview.constants.IDENENTIFIER_DESTRUCTION = "Destro"
RdKGToolOverview.constants.IDENENTIFIER_STORM = "Storm"
RdKGToolOverview.constants.IDENENTIFIER_NEGATE = "Neg."
RdKGToolOverview.constants.IDENENTIFIER_NOVA = "Nova"
RdKGToolOverview.config.groupsModes = RdKGToolOverview.config.groupsModes or {}
RdKGToolOverview.config.groupsModes[RdKGToolOverview.constants.groupsModes.MODE_PRIORITY_NAME] = "Priority - Name"
RdKGToolOverview.config.groupsModes[RdKGToolOverview.constants.groupsModes.MODE_PRIORITY_PERCENT] = "Priority - Percent"
RdKGToolOverview.config.groupsModes[RdKGToolOverview.constants.groupsModes.MODE_PERCENT] = "Percent"
RdKGToolOverview.config.displayModes = RdKGToolOverview.config.displayModes or {}
RdKGToolOverview.config.displayModes[RdKGToolOverview.constants.displayModes.CLASSIC] = "Classic"
RdKGToolOverview.config.displayModes[RdKGToolOverview.constants.displayModes.SWIMLANES] = "Swimlanes"

--Healing / Damage Meter
RdKGToolHdm.constants = RdKGToolHdm.constants or {}
RdKGToolHdm.constants.TITLE_HEALING = "Healing"
RdKGToolHdm.constants.TITLE_DAMAGE = "Damage"
RdKGToolHdm.constants.viewModes = RdKGToolHdm.constants.viewModes or {}
RdKGToolHdm.constants.viewModes[RdKGToolHdm.constants.VIEWMODE_BOTH] = "Both"
RdKGToolHdm.constants.viewModes[RdKGToolHdm.constants.VIEWMODE_HEALING] = "Healing"
RdKGToolHdm.constants.viewModes[RdKGToolHdm.constants.VIEWMODE_DAMAGE] = "Damage"
RdKGToolHdm.constants.viewModes[RdKGToolHdm.constants.VIEWMODE_BOTH_ON_TOP] = "Both (Vertically)"
RdKGToolHdm.constants.RESET_COUNTER = "Reset Counter"

--Detonation Tracker
RdKGToolDt.constants.modes = RdKGToolDt.constants.modes or {}
RdKGToolDt.constants.modes[RdKGToolDt.constants.MODE_ALL] = "All"
RdKGToolDt.constants.modes[RdKGToolDt.constants.MODE_DETONATION] = "Detonation"
RdKGToolDt.constants.modes[RdKGToolDt.constants.MODE_SHALK] = "Shalk"
RdKGToolDt.constants.modes[RdKGToolDt.constants.MODE_SOUL_OF_FLAME] = "Soul of Flame"
RdKGToolDt.constants.DT_SOUL_OF_FLAME_TEXT = "Cast Soul of Flame!"

--I See Dead People
RdKGToolIsdp.constants = RdKGToolIsdp.constants or {}
RdKGToolIsdp.constants.BEAM_SKULL_USING_BUFFER = "Skull"
RdKGToolIsdp.constants.BEAM_SKULL_NOT_USING_BUFFER = "Skull (w/o Buffer)"

--Compass
--YACS
RdKGToolYacs.compasses[1].name = "Standard"
RdKGToolYacs.compasses[2].name = "Fat North"
RdKGToolYacs.compasses[3].name = "Thin Lines"
RdKGToolYacs.compasses[4].name = "Fancy Underline North "
RdKGToolYacs.compasses[5].name = "Fat Underline North"
RdKGToolYacs.compasses[6].name = "Gribouillis"
RdKGToolYacs.compasses[7].name = "Circled 1"
RdKGToolYacs.compasses[8].name = "Circled 2"
RdKGToolYacs.compasses[9].name = "Diamond 1"
RdKGToolYacs.compasses[10].name = "Diamond 2"
RdKGToolYacs.compasses[11].name = "Dots 1"
RdKGToolYacs.compasses[12].name = "Dots 2"
RdKGToolYacs.compasses[13].name = "ELetters 1"
RdKGToolYacs.compasses[14].name = "ELetters 2"
RdKGToolYacs.compasses[15].name = "Full Arrow 1"
RdKGToolYacs.compasses[16].name = "Full Arrow 2"
RdKGToolYacs.compasses[17].name = "Needle 1"
RdKGToolYacs.compasses[18].name = "Needle 2"
RdKGToolYacs.compasses[19].name = "Small Arrow 1"
RdKGToolYacs.compasses[20].name = "Small Arrow 2"
RdKGToolYacs.compasses[21].name = "Compass Fr. 1"
RdKGToolYacs.compasses[22].name = "Compass Fr. 2"
RdKGToolYacs.compasses[23].name = "Compass Fr. 3"
RdKGToolYacs.compasses[24].name = "Compass Fr. 4"
RdKGToolYacs.config.constants.TOGGLE_YACS = "Toggle Compass"

--SC
RdKGToolSC.constants = RdKGToolSC.constants or {}
RdKGToolSC.constants.NORTH = "N"
RdKGToolSC.constants.NORTH_EAST = "NE"
RdKGToolSC.constants.EAST = "E"
RdKGToolSC.constants.SOUTH_EAST = "SE"
RdKGToolSC.constants.SOUTH = "S"
RdKGToolSC.constants.SOUTH_WEST = "SW"
RdKGToolSC.constants.WEST = "W"
RdKGToolSC.constants.NORTH_WEST = "NW"

--Toolbox
--Siege Merchant
RdKGToolSm.paymentOptions = RdKGToolSm.paymentOptions or {}
RdKGToolSm.paymentOptions[1] = "Only AP"
RdKGToolSm.paymentOptions[2] = "Only Gold"
RdKGToolSm.paymentOptions[3] = "First AP, Then Gold"
RdKGToolSm.paymentOptions[4] = "First Gold, Then AP"
RdKGToolSm.constants = RdKGToolSm.constants or {}
RdKGToolSm.constants.ERROR_UNKNOWN = "An unknown error occurred."
RdKGToolSm.constants.ERROR_UNKNOWN_PAYMENT_OPTION = "Unkown payment option has been selected."
RdKGToolSm.constants.ERROR_PAYMENT_NOT_ENOUGH_GOLD = "Not enough gold present to buy more items."
RdKGToolSm.constants.ERROR_PAYMENT_NOT_ENOUGH_AP = "Not enough AP present to buy more items."
RdKGToolSm.constants.ERROR_PAYMENT_NOT_ENOUGH_AP_OR_GOLD = "Not enough AP or gold present to buy more items."
RdKGToolSm.constants.ERROR_PAYMENT_NOT_ENOUGH_INVENTORY_SLOTS = "Not enough inventory slots available to buy more items."
RdKGToolSm.constants.SUCCESS_MESSAGE = "Purchase completed."

--Recharger
RdKGToolRecharger.constants = RdKGToolRecharger.constants or {}
RdKGToolRecharger.constants.MESSAGE_SUCCESS = "%s (%d%%) has been recharged."
RdKGToolRecharger.constants.MESSAGE_WARNING_LOW_SOULGEMS = "Less than %d soul gems are available."
RdKGToolRecharger.constants.MESSAGE_WARNING_NO_SOULGEMS = "No more soul gems are left."

--Buff Food Tracking
RdKGToolBft.constants = RdKGToolBft.constants or {}
RdKGToolBft.constants.BUFF_FOOD_STRING = "Buff Food: %s"

--Siege
RdKGToolSiege.constants = RdKGToolSiege.constants or {}
RdKGToolSiege.constants.TOGGLE_SIEGE = "|c4592FFRdK: Toggle View|r"

--Cyrodiil Log
RdKGToolCL.constants = RdKGToolCL.constants or {}
RdKGToolCL.constants.MESSAGE_KEEP_GUILD_CLAIM = "%s|c%s claimed %s|c%s for %s"
RdKGToolCL.constants.MESSAGE_KEEP_GUILD_LOST = "%s|c%s lost %s"
RdKGToolCL.constants.MESSAGE_KEEP_STATUS_UA = "%s|c%s is under siege"
RdKGToolCL.constants.MESSAGE_KEEP_STATUS_UA_LOST = "%s|c%s is not under siege anymore"
RdKGToolCL.constants.MESSAGE_KEEP_OWNER_CHANGED = "%s|c%s belongs to %s"
RdKGToolCL.constants.MESSAGE_TICK_DEFENSE = "|c%s%s|t16:16:/esoui/art/currency/alliancepoints.dds|t|c%s gained for defending %s"
RdKGToolCL.constants.MESSAGE_TICK_OFFENSE = "|c%s%s|t16:16:/esoui/art/currency/alliancepoints.dds|t|c%s gained for capturing %s"
RdKGToolCL.constants.MESSAGE_SCROLL_PICKED_UP = "%s|c%s has picked up the %s"
RdKGToolCL.constants.MESSAGE_SCROLL_DROPPED = "%s|c%s has dropped the %s"
RdKGToolCL.constants.MESSAGE_SCROLL_RETURNED = "%s|c%s has returned the %s"
RdKGToolCL.constants.MESSAGE_SCROLL_RETURNED_BY_TIMER = "%s|c%s has been returned"
RdKGToolCL.constants.MESSAGE_SCROLL_CAPTURED = "%s|c%s has captured %s|c%s at %s"
RdKGToolCL.constants.MESSAGE_EMPEROR_CORONATED = "%s|c%s has been crowned emperor"
RdKGToolCL.constants.MESSAGE_EMPEROR_DEPOSED = "%s|c%s has been deposed as emperor"
RdKGToolCL.constants.MESSAGE_QUEST_REWARD = "|c%s%s|t16:16:/esoui/art/currency/alliancepoints.dds|t|c%s gained for completing a quest"
RdKGToolCL.constants.MESSAGE_BATTLEGROUND_REWARD = "|c%s%s|t16:16:/esoui/art/currency/alliancepoints.dds|t|c%s gained for completing the battleground"
RdKGToolCL.constants.MESSAGE_BATTLEGROUND_MEDAL_REWARD = "|c%s%s|t16:16:/esoui/art/currency/alliancepoints.dds|t|c%s gained for getting a medal"
RdKGToolCL.constants.MESSAGE_DAEDRIC_ARTIFACT_SPAWNED = "|c%s%s has spawned"
RdKGToolCL.constants.MESSAGE_DAEDRIC_ARTIFACT_REVEALED = "|c%s%s has been revealed"
RdKGToolCL.constants.MESSAGE_DAEDRIC_ARTIFACT_DROPPED = "|c%s%s has been dropped by %s|c%s"
RdKGToolCL.constants.MESSAGE_DAEDRIC_ARTIFACT_TAKEN = "|c%s%s has been taken by %s|c%s"
RdKGToolCL.constants.MESSAGE_DAEDRIC_ARTIFACT_DESPAWNED = "|c%s%s has returned to oblivion"

--Respawner
RdKGToolRespawner.constants = RdKGToolRespawner.constants or {}
RdKGToolRespawner.constants.KEYBINDING_RESPAWN_CAMP = "Respawn at Camp"
RdKGToolRespawner.constants.KEYBINDING_RESPAWN_KEEP = "Respawn at Keep"
RdKGToolRespawner.constants.RESPAWN_CAMP = "Camp"
RdKGToolRespawner.constants.RESPAWN_KEEP = "Keep"

--Synergy Prevention - /script for i = 1, 500000 do if GetAbilityName(i) == "" then d(i) end end
RdKGToolSP.constants = RdKGToolSP.constants or {}
RdKGToolSP.constants.ON = "ON"
RdKGToolSP.constants.OFF = "OFF"
RdKGToolSP.constants.KEYBINDING = "Toggle Synergy Prevention"
RdKGToolSP.constants.SYNERGY_COMBUSTION = "Combustion" -- 3463, 26319, 29424 .. 
RdKGToolSP.constants.SYNERGY_HEALING_COMBUSTION = "Healing Combustion" -- 63507, 63511 .. 
RdKGToolSP.constants.SYNERGY_SHARDS_BLESSED = "Blessed Shards" -- 26832, 94973 ..
RdKGToolSP.constants.SYNERGY_SHARDS_HOLY = "Holy Shards" -- 95922, 95925 .. 
RdKGToolSP.constants.SYNERGY_BLOOD_FEAST = "Blood Feast" -- 41963, 41964 .. 
RdKGToolSP.constants.SYNERGY_BLOOD_FUNNEL = "Blood Funnel" -- 39500, 39501 ..
RdKGToolSP.constants.SYNERGY_SUPERNOVA = "Supernova" -- 31538, 31540
RdKGToolSP.constants.SYNERGY_GRAVITY_CRUSH = "Gravity Crush" -- 31603, 31604 .. 
RdKGToolSP.constants.SYNERGY_SHACKLE = "Shackle" -- 32905, 32910 ..
RdKGToolSP.constants.SYNERGY_PURIFY = "Purify" -- 22260, 22269 ..
RdKGToolSP.constants.SYNERGY_BONE_WALL = "Bone Wall" -- 39377, 39379 ..
RdKGToolSP.constants.SYNERGY_SPINAL_SURGE = "Spinal Surge" -- 42194, 42195 ..
RdKGToolSP.constants.SYNERGY_IGNITE = "Ignite" -- 10805, 10809 ..
RdKGToolSP.constants.SYNERGY_RADIATE = "Radiate" -- 41838, 41839 .. 
RdKGToolSP.constants.SYNERGY_CONDUIT = "Conduit" -- 23196, 136046
RdKGToolSP.constants.SYNERGY_SPAWN_BROODLINGS = "Spawn Broodling" -- 39429, 39430 ..
RdKGToolSP.constants.SYNERGY_BLACK_WIDOWS = "Black Widow" -- 41994, 41996
RdKGToolSP.constants.SYNERGY_ARACHNOPHOBIA = "Arachnophobia" -- 18111, 18116 ..
RdKGToolSP.constants.SYNERGY_HIDDEN_REFRESH = "Hidden Refresh" -- 37729, 37730 ..
RdKGToolSP.constants.SYNERGY_SOUL_LEECH = "Soul Leech" -- 25169, 25170 ..
RdKGToolSP.constants.SYNERGY_HARVEST = "Harvest" -- 85572, 85576 ..
RdKGToolSP.constants.SYNERGY_ATRONACH = "Charged Lightning" -- 48076, 102310, 102321 ..
RdKGToolSP.constants.SYNERGY_GRAVE_ROBBER = "Grave Robber" -- 115548, 115567 ..
RdKGToolSP.constants.SYNERGY_PURE_AGONY = "Pure Agony" -- 118604, 118606 ..
RdKGToolSP.constants.SYNERGY_ICY_ESCAPE = "Icy Escape" -- 88884, 110370 ...
RdKGToolSP.constants.SYNERGY_SANGUINE_BURST = "Sanguine Burst" -- 141920, 142305
RdKGToolSP.constants.SYNERGY_HEED_THE_CALL = "Heed the Call" -- 142712, 142775, 142780
RdKGToolSP.constants.SYNERGY_URSUS = "Shield of Ursus" --111437
--RdKGToolSP.constants.blacklist = RdKGToolSP.constants.blacklist or {}
--RdKGToolSP.constants.blacklist[RdKGToolSP.constants.SYNERGY_COMBUSTION] = true
--RdKGToolSP.constants.blacklist[RdKGToolSP.constants.SYNERGY_SUPERNOVA] = true
--RdKGToolSP.constants.blacklist[RdKGToolSP.constants.SYNERGY_GRAVITY_CRUSH] = true
--RdKGToolSP.constants.blacklist[RdKGToolSP.constants.SYNERGY_SHACKLE] = true
--RdKGToolSP.constants.blacklist[RdKGToolSP.constants.SYNERGY_IGNITE] = true
--RdKGToolSP.constants.blacklist[RdKGToolSP.constants.SYNERGY_RADIATE] = true
--RdKGToolSP.constants.blacklist[RdKGToolSP.constants.SYNERGY_CONDUIT] = true
--RdKGToolSP.constants.blacklist[RdKGToolSP.constants.SYNERGY_GRAVE_ROBBER] = true
--RdKGToolSP.constants.blacklist[RdKGToolSP.constants.SYNERGY_PURE_AGONY] = true
RdKGToolSP.constants.MODES = RdKGToolSP.constants.MODES or {}
RdKGToolSP.constants.MODES[RdKGToolSP.constants.MODE_BLOCK_ALL] = "All"
RdKGToolSP.constants.MODES[RdKGToolSP.constants.MODE_BLOCK_IF_SYNERGY_ROLE] = "Synergy Role"

--Synergy Overview
RdKGToolSO.constants.DISPLAY_MODES = RdKGToolSO.constants.DISPLAY_MODES or {}
RdKGToolSO.constants.DISPLAY_MODES[RdKGToolSO.constants.DISPLAYMODE_ALL] = "All"
RdKGToolSO.constants.DISPLAY_MODES[RdKGToolSO.constants.DISPLAYMODE_SYNERGY] = "Synergy Role"
RdKGToolSO.constants.TABLE_MODES = RdKGToolSO.constants.TABLE_MODES or {}
RdKGToolSO.constants.TABLE_MODES[RdKGToolSO.constants.MODES.TABLE_FULL] = "Full"
RdKGToolSO.constants.TABLE_MODES[RdKGToolSO.constants.MODES.TABLE_REDUCED] = "Reduced"

--util
--util
RdKGToolUtil.constants = RdKGToolUtil.constants or {}
RdKGToolUtil.constants.G1 = "Guild 1"
RdKGToolUtil.constants.O1 = "Officer 1"
RdKGToolUtil.constants.G2 = "Guild 2"
RdKGToolUtil.constants.O2 = "Officer 2"
RdKGToolUtil.constants.G3 = "Guild 3"
RdKGToolUtil.constants.O3 = "Officer 3"
RdKGToolUtil.constants.G4 = "Guild 4"
RdKGToolUtil.constants.O4 = "Officer 4"
RdKGToolUtil.constants.G5 = "Guild 5"
RdKGToolUtil.constants.O5 = "Officer 5"
RdKGToolUtil.constants.EMOTE = "Emote"
RdKGToolUtil.constants.SAY = "Say"
RdKGToolUtil.constants.YELL = "Yell"
RdKGToolUtil.constants.GROUP = "Group"
RdKGToolUtil.constants.TELL = "Tell"
RdKGToolUtil.constants.ZONE = "Zone"
RdKGToolUtil.constants.ENZONE = "Zone - English"
RdKGToolUtil.constants.FRZONE = "Zone - French"
RdKGToolUtil.constants.DEZONE = "Zone - German"
RdKGToolUtil.constants.JPZONE = "Zone - Japan"

--ui
RdKGToolUtilUI.constants = RdKGToolUtilUI.constants or {}
RdKGToolUtilUI.constants.ON = "ON"
RdKGToolUtilUI.constants.OFF = "OFF"

--Ultimates
RdKGToolUltimates.constants = RdKGToolUltimates.constants or {}
RdKGToolUltimates.constants.NEGATE = "Sorcerer - Negate"
RdKGToolUltimates.constants.NEGATE_OFFENSIVE = "Sorcerer - Negate Offensive"
RdKGToolUltimates.constants.NEGATE_COUNTER = "Sorcerer - Negate Counter"
RdKGToolUltimates.constants.ATRONACH = "Sorcerer - Atronach"
RdKGToolUltimates.constants.OVERLOAD = "Sorcerer - Overload"
RdKGToolUltimates.constants.SWEEP = "Templar - Sweep"
RdKGToolUltimates.constants.NOVA = "Templar - Nova"
RdKGToolUltimates.constants.T_HEAL = "Templar - Healing Ultimate"
RdKGToolUltimates.constants.STANDARD = "Dragonknight - Standard"
RdKGToolUltimates.constants.LEAP = "Dragonknight - Dragon Leap"
RdKGToolUltimates.constants.MAGMA = "Dragonknight - Magma Armor"
RdKGToolUltimates.constants.STROKE = "Nightblade - Death Stroke"
RdKGToolUltimates.constants.DARKNESS = "Nightblade - Consuming Darkness"
RdKGToolUltimates.constants.SOUL = "Nightblade - Soul Shred"
RdKGToolUltimates.constants.SOUL_SIPHON = "Nightblade - Soul Siphon"
RdKGToolUltimates.constants.SOUL_TETHER = "Nightblade - Soul Tether"
RdKGToolUltimates.constants.STORM = "Warden - Storm"
RdKGToolUltimates.constants.NORTHERN_STORM = "Warden - Northern Storm"
RdKGToolUltimates.constants.PERMAFROST = "Warden - Permafrost"
RdKGToolUltimates.constants.W_HEAL = "Warden - Healing Ultimate"
RdKGToolUltimates.constants.GUARDIAN = "Warden - Guardian"
RdKGToolUltimates.constants.COLOSSUS = "Necromancer - Colossus"
RdKGToolUltimates.constants.GOLIATH = "Necromancer - Goliath"
RdKGToolUltimates.constants.REANIMATE = "Necromancer - Reanimate"
RdKGToolUltimates.constants.UNBLINKING_EYE = "Arcanist - Unblinking Eye"
RdKGToolUltimates.constants.GIBBERING_SHIELD = "Arcanist - Gibbering Shield"
RdKGToolUltimates.constants.VITALIZING_GLYPHIC = "Arcanist - Vitalizing Glyphic"
RdKGToolUltimates.constants.DESTRUCTION = "Weapon - Destruction Staff"
RdKGToolUltimates.constants.RESTORATION = "Weapon - Restoration Staff"
RdKGToolUltimates.constants.TWO_HANDED = "Weapon - Two Handed"
RdKGToolUltimates.constants.SHIELD = "Weapon - One Handed and Shield"
RdKGToolUltimates.constants.DUAL_WIELD = "Weapon - Dual Wield"
RdKGToolUltimates.constants.BOW = "Weapon - Bow"
RdKGToolUltimates.constants.SOUL_MAGIC = "World - Soul Strike"
RdKGToolUltimates.constants.WEREWOLF = "World (Werewolf) - Werewolf"
RdKGToolUltimates.constants.VAMPIRE = "World (Vampire) - Bat Swarm"
RdKGToolUltimates.constants.MAGES = "Guild (Mages) - Meteor"
RdKGToolUltimates.constants.FIGHTERS = "Guild (Fighters) - Dawnbreaker"
RdKGToolUltimates.constants.PSIJIC = "Guild (Psijic) - Undo"
RdKGToolUltimates.constants.ALLIANCE_SUPPORT = "Alliance War (Support) - Barrier"
RdKGToolUltimates.constants.ALLIANCE_ASSAULT = "Alliance War (Assault) - War Horn"

--Networking
RdKGToolNetworking.constants.urgentSelection[RdKGToolNetworking.constants.urgentMode.DIRECT] = "Direct"
RdKGToolNetworking.constants.urgentSelection[RdKGToolNetworking.constants.urgentMode.CRITICAL] = "Queue (Critical)"

--Util Group
RdKGToolUtilGroup.constants.displayTypes[RdKGToolUtilGroup.constants.BY_CHAR_NAME] = "By Name"
RdKGToolUtilGroup.constants.displayTypes[RdKGToolUtilGroup.constants.BY_DISPLAY_NAME] = "By @Account"

RdKGToolUtilGroup.constants.ROLE_RAPID = "Rapid"
RdKGToolUtilGroup.constants.ROLE_PURGE = "Purge"
RdKGToolUtilGroup.constants.ROLE_HEAL = "Healer"
RdKGToolUtilGroup.constants.ROLE_DD = "DD"
RdKGToolUtilGroup.constants.ROLE_SYNERGY = "Synergy"
RdKGToolUtilGroup.constants.ROLE_CC = "CC"
RdKGToolUtilGroup.constants.ROLE_SUPPORT = "Support"
RdKGToolUtilGroup.constants.ROLE_PLACEHOLDER = "Undefined"
RdKGToolUtilGroup.constants.ROLE_APPLICANT = "Applicant"

--Util Versioning
RdKGToolVersioning.constants = RdKGToolVersioning.constants or {}
RdKGToolVersioning.constants.CLIENT_OUT_OF_DATE = "|cFF0000[RdK Group Tool] Client version is out of date|r"

--Util Enhancements
RdKGToolEnhance.constants = RdKGToolEnhance.constants or {}
RdKGToolEnhance.constants.positionNames = RdKGToolEnhance.constants.positionNames or {}
RdKGToolEnhance.constants.positionNames[RdKGToolEnhance.constants.TOPRIGHT] = "Top Right"
RdKGToolEnhance.constants.positionNames[RdKGToolEnhance.constants.BOTTOMRIGHT] = "Bottom Right"
RdKGToolEnhance.constants.positionNames[RdKGToolEnhance.constants.TOPLEFT] = "Top Left"
RdKGToolEnhance.constants.positionNames[RdKGToolEnhance.constants.BOTTOMLEFT] = "Bottom Left"
RdKGToolEnhance.constants.CAMP_RESPAWN = "Camp : "

--Util Group Menu
RdKGToolGMenu.constants = RdKGToolGMenu.constants or {}
RdKGToolGMenu.constants.BG_LEADER_ADD_CROWN = "Mark as Crown"
RdKGToolGMenu.constants.BG_LEADER_REMOVE_CROWN = "Remove Crown"
RdKGToolGMenu.constants.ROLE_MENU_ENTRY = "Role"
RdKGToolGMenu.constants.ROLE_SUBMENU_SET = "Set"
RdKGToolGMenu.constants.ROLE_SUBMENU_REMOVE = "Remove"
RdKGToolGMenu.constants.ROLE_SUBMENU_RAPID = RdKGToolUtilGroup.constants.ROLE_RAPID
RdKGToolGMenu.constants.ROLE_SUBMENU_PURGE = RdKGToolUtilGroup.constants.ROLE_PURGE
RdKGToolGMenu.constants.ROLE_SUBMENU_HEAL = RdKGToolUtilGroup.constants.ROLE_HEAL
RdKGToolGMenu.constants.ROLE_SUBMENU_DD = RdKGToolUtilGroup.constants.ROLE_DD
RdKGToolGMenu.constants.ROLE_SUBMENU_SYNERGY = RdKGToolUtilGroup.constants.ROLE_SYNERGY
RdKGToolGMenu.constants.ROLE_SUBMENU_CC = RdKGToolUtilGroup.constants.ROLE_CC
RdKGToolGMenu.constants.ROLE_SUBMENU_SUPPORT = RdKGToolUtilGroup.constants.ROLE_SUPPORT
RdKGToolGMenu.constants.ROLE_SUBMENU_PLACEHOLDER = RdKGToolUtilGroup.constants.ROLE_PLACEHOLDER
RdKGToolGMenu.constants.ROLE_SUBMENU_APPLICANT = RdKGToolUtilGroup.constants.ROLE_APPLICANT

--Util Beams
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_1].name = "Beam 1"
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_2].name = "Beam 2"
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_3].name = "Beam 3"
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_4].name = "Beam 4"
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_5].name = "Circle 1"
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_6].name = "Circle 1 (w/o Buffer)"
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_7].name = "Circle 2"
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_8].name = "Circle 2 (w/o Buffer)"
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_9].name = "Arrows 1"
RdKGToolBeams.constants.BEAM[RdKGToolBeams.constants.beams.BEAM_10].name = "Arrows 2"

--Admin [General]
RdKGToolAdmin.constants = RdKGToolAdmin.constants or {}
RdKGToolAdmin.constants.TOGGLE_ADMIN = "Toggle Admin Interface"
RdKGToolAdmin.constants.HEADER_TITLE = "Admin"
RdKGToolAdmin.constants.PLAYERS_ALL = "All"
--Admin UI [Player]
RdKGToolAdmin.constants.player = RdKGToolAdmin.constants.player or {}
RdKGToolAdmin.constants.player.REQUEST_ALL = "Request All"
RdKGToolAdmin.constants.player.REQUEST_VERSION = "Request Version"
RdKGToolAdmin.constants.player.REQUEST_CLIENT_CONFIGURATION = "Request Client Configuration"
RdKGToolAdmin.constants.player.REQUEST_ADDON_CONFIGURATION = "Request AddOn Configuration"
RdKGToolAdmin.constants.player.REQUEST_EQUIPMENT_INFORMATION = "Request Equipment Information"
RdKGToolAdmin.constants.player.REQUEST_STATS_INFORMATION = "Request Stats Information"
RdKGToolAdmin.constants.player.REQUEST_MUNDUS_INFORMATION = "Request Mundus Information"
RdKGToolAdmin.constants.player.REQUEST_SKILLS_INFORMATION = "Request Skill Information"
RdKGToolAdmin.constants.player.REQUEST_QUICKSLOTS_INFORMATION = "Request Quickslot Information"
RdKGToolAdmin.constants.player.REQUEST_CHAMPION_INFORMATION = "Request CP Information"
--Admin UI [Config]
RdKGToolAdmin.constants = RdKGToolAdmin.constants or {}
RdKGToolAdmin.constants.defaults = RdKGToolAdmin.constants.defaults or {}
RdKGToolAdmin.constants.defaults.ENABLED = "On"
RdKGToolAdmin.constants.defaults.DISABLED = "Off"
RdKGToolAdmin.constants.defaults.UNDEFINED = "N/A"
RdKGToolAdmin.constants.defaults.UNDEFINED_LINE = "-"
RdKGToolAdmin.constants.defaults.UNDEFINED_VERSION = "N/A (Version)"
RdKGToolAdmin.constants.defaults.viewModes = RdKGToolAdmin.constants.defaults.viewModes or {}
RdKGToolAdmin.constants.defaults.viewModes[0] = "Windowed"
RdKGToolAdmin.constants.defaults.viewModes[1] = "Windowed (Fullscreen)"
RdKGToolAdmin.constants.defaults.viewModes[2] = "Fullscreen"
RdKGToolAdmin.constants.defaults.qualitySelection = RdKGToolAdmin.constants.defaults.qualitySelection or {}
RdKGToolAdmin.constants.defaults.qualitySelection[0] = "Off"
RdKGToolAdmin.constants.defaults.qualitySelection[1] = "Low"
RdKGToolAdmin.constants.defaults.qualitySelection[2] = "Medium"
RdKGToolAdmin.constants.defaults.qualitySelection[3] = "High"
RdKGToolAdmin.constants.defaults.qualitySelection[4] = "Ultra"
RdKGToolAdmin.constants.defaults.graphicPresets = RdKGToolAdmin.constants.defaults.graphicPresets or {}
RdKGToolAdmin.constants.defaults.graphicPresets[0] = "Minumum"
RdKGToolAdmin.constants.defaults.graphicPresets[1] = "Low"
RdKGToolAdmin.constants.defaults.graphicPresets[2] = "Medium"
RdKGToolAdmin.constants.defaults.graphicPresets[3] = "High"
RdKGToolAdmin.constants.defaults.graphicPresets[4] = "Ultra-High"
RdKGToolAdmin.constants.defaults.graphicPresets[7] = "Custom"
RdKGToolAdmin.constants.config = RdKGToolAdmin.constants.config or {}
RdKGToolAdmin.constants.config.PLAYER_TITLE = "Player Information"
RdKGToolAdmin.constants.config.PLAYER_DISPLAYNAME_STRING = "Display Name: |c%s%s|r"
RdKGToolAdmin.constants.config.PLAYER_CHARNAME_STRING = "Character Name: |c%s%s|r"
RdKGToolAdmin.constants.config.PLAYER_VERSION_STRING = "Version: |c%s%s.%s.%s|r"
RdKGToolAdmin.constants.config.CLIENT_TITLE = "Client Information"
RdKGToolAdmin.constants.config.CLIENT_AOE_SUBTITLE = "AOE"
RdKGToolAdmin.constants.config.CLIENT_AOE_TELLS_ENABLED_STRING = "Enabled: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_AOE_CUSTOM_COLOR_ENABLED_STRING = "Custom Colors Enabled: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_AOE_CUSTOM_COLOR_FRIENDLY_BRIGHTNESS = "Friendly Brightness: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_AOE_CUSTOM_COLOR_ENEMY_BRIGHTNESS = "Enemy Brightness: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_SOUND_SUBTITLE = "Sound"
RdKGToolAdmin.constants.config.CLIENT_SOUND_ENABLED_STRING = "Enabled: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_SOUND_AUDIO_VOLUME = "Audio Volume: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_SFX_AUDIO_VOLUME = "SFX Volume: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_UI_AUDIO_VOLUME = "UI Volume: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_SUBTITLE = "Graphics"
RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_RESOLUTION_STRING = "Resolution: |c%s%sx%s|r"
RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_WINDOW_MODE_STRING = "Display Mode: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_VSYNC_STRING = "Vertical Sync: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_ANTI_ALIASING_STRING = "Anti-Aliasing: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_AMBIENT_STRING = "Ambient Occlusion: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_BLOOM_STRING = "Bloom: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_DEPTH_OF_FIELD_STRING = "Depth of Field: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_DISTORTION_STRING = "Distortion: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_SUNLIGHT_STRING = "Sunlight Rays: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_ALLY_EFFECTS_STRING = "Additional Ally Effects: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_VIEW_DISTANCE_STRING = "View Distance: ~|c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_PARTICLE_SUPRESSION_DISTANCE_STRING = "Particle Supression Distance: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_PARTICLE_MAXIMUM_STRING = "Maximum Particle Systems: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_REFLECTION_QUALITY_STRING = "Water Reflection Quality: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_SHADOW_QUALITY_STRING = "Shadow Quality: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_SUBSAMPLING_QUALITY_STRING = "SubSampling Quality: |c%s%s|r"
RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_GRAPHIC_PRESETS_STRING = "Graphics Quality: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_TITLE = "AddOn Configuration"
RdKGToolAdmin.constants.config.ADDON_CROWN_SUBTITLE = "Crown"
RdKGToolAdmin.constants.config.ADDON_CROWN_ENABLED_STRING = "Enabled: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_CROWN_SIZE_STRING = "Size: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_CROWN_SELECTED_CROWN_STRING = "Selected Crown: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_FTCV_SUBTITLE = "Follow The Crown (Visual)"
RdKGToolAdmin.constants.config.ADDON_FTCV_ENABLED_STRING = "Enabled: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_FTCV_SIZE_FAR_STRING = "Size Far: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_FTCV_SIZE_CLOSE_STRING = "Size Close: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_FTCV_MIN_DISTANCE_STRING = "Minimum Distance: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_FTCV_MAX_DISTANCE_STRING = "Maximum Distance: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_FTCV_OPACITY_FAR_STRING = "Opacity Far: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_FTCV_OPACITY_CLOSE_STRING = "Opacity Close: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_FTCW_SUBTITLE = "Follow The Crown (Warnings)"
RdKGToolAdmin.constants.config.ADDON_FTCW_ENABLED_STRING = "Enabled: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_FTCW_DISTANCE_ENABLED_STRING = "Distance Enabled: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_FTCW_WARNINGS_ENABLED_STRING = "Warnings Enabled: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_FTCW_MAX_DISTANCE_STRING = "Maximum Distance: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_FTCA_SUBTITLE = "Follow The Crown (Audio)"
RdKGToolAdmin.constants.config.ADDON_FTCA_ENABLED_STRING = "Enabled: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_FTCA_MAX_DISTANCE_STRING = "Maximum Distance: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_FTCA_INTERVAL_STRING = "Interval: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_FTCA_THRESHOLD_STRING = "Threshold: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_FTCB_SUBTITLE = "Follow The Crown (Beam)"
RdKGToolAdmin.constants.config.ADDON_FTCB_ENABLED_STRING = "Enabled: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_FTCB_SELECTED_BEAM_STRING = "Selected Beam: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_FTCB_ALPHA_STRING = "Alpha: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_DBO_SUBTITLE = "Debuff Overview"
RdKGToolAdmin.constants.config.ADDON_DBO_ENABLED_STRING = "Enabled: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RT_SUBTITLE = "Rapid Overview"
RdKGToolAdmin.constants.config.ADDON_RT_ENABLED_STRING = "Enabled: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RO_SUBTITLE = "Resource Overview"
RdKGToolAdmin.constants.config.ADDON_RO_ENABLED_STRING = "Enabled: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RO_ULTIMATE_OVERVIEW_ENABLED_STRING = "Ultimate Group Overview Enabled: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RO_CLIENT_GROUP_ENABLED_STRING = "Client Window Enabled: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RO_GROUP_ULTIMATE_ENABLED_STRING = "Group Window Enabled: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RO_SHOW_SOFT_RESOURCES_STRING = "Stamina / Magicka: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RO_SOUND_ENABLED_STRING = "Sound Enabled: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RO_MAX_DISTANCE_STRING = "Maximum Distance: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RO_GROUP_SIZE_DESTRO_STRING = "Group Size Destro: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RO_GROUP_SIZE_STORM_STRING = "Group Size Storm: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RO_GROUP_SIZE_NORTHERNSTORM_STRING = "Group Size Northern Storm: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RO_GROUP_SIZE_PERMAFROST_STRING = "Group Size Permafrost: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RO_GROUP_SIZE_NEGATE_STRING = "Group Size Negate: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RO_GROUP_SIZE_NEGATE_OFFENSIVE_STRING = "Group Size Negate Offensive: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RO_GROUP_SIZE_NEGATE_COUNTER_STRING = "Group Size Negate Counter: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RO_GROUP_SIZE_NOVA_STRING = "Group Size Nova: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RO_GROUPS_ENABLED_STRING = "Groups Enabled: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_HDM_SUBTITLE = "Health Damage Meter"
RdKGToolAdmin.constants.config.ADDON_HDM_ENABLED_STRING = "Enabled: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_HDM_WINDOW_ENABLED_STRING = "Window Enabled: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_HDM_VIEW_MODE_STRING = "Selected Mode: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_PO_SUBTITLE = "Potion Overview"
RdKGToolAdmin.constants.config.ADDON_PO_ENABLED_STRING = "Enabled: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_PO_SOUND_ENABLED_STRING = "Sound Enabled: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_DT_SUBTITLE = "Detonation Tracker"
RdKGToolAdmin.constants.config.ADDON_DT_ENABLED_STRING = "Enabled: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_GB_SUBTITLE = "Group Beams"
RdKGToolAdmin.constants.config.ADDON_GB_ENABLED_STRING = "Enabled: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_ISDP_SUBTITLE = "I See Dead People"
RdKGToolAdmin.constants.config.ADDON_ISDP_ENABLED_STRING = "Enabled: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_YACS_SUBTITLE = "Yet Another Compass"
RdKGToolAdmin.constants.config.ADDON_YACS_ENABLED_STRING = "Enabled: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_YACS_PVP_ENABLED_STRING = "Enabled in PVP: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_YACS_COMBAT_ENABLED_STRING = "Enabled in Combat: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_SC_SUBTITLE = "Simple Compass"
RdKGToolAdmin.constants.config.ADDON_SC_ENABLED_STRING = "Enabled: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_SM_SUBTITLE = "Siege Merchant"
RdKGToolAdmin.constants.config.ADDON_SM_ENABLED_STRING = "Enabled: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RECHARGER_SUBTITLE = "Recharger"
RdKGToolAdmin.constants.config.ADDON_RECHARGER_ENABLED_STRING = "Enabled: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_KC_SUBTITLE = "Keep Claimer"
RdKGToolAdmin.constants.config.ADDON_KC_ENABLED_STRING = "Enabled: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_BFT_SUBTITLE = "Buff Food Tracker"
RdKGToolAdmin.constants.config.ADDON_BFT_ENABLED_STRING = "Enabled: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_BFT_SOUND_ENABLED_STRING = "Sound Enabled: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_BFT_SIZE_STRING = "Size: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_CL_SUBTITLE = "Cyrodiil Log"
RdKGToolAdmin.constants.config.ADDON_CL_ENABLED_STRING = "Enabled: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_CS_SUBTITLE = "Cyrodiil Status"
RdKGToolAdmin.constants.config.ADDON_CS_ENABLED_STRING = "Enabled: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RESPAWNER_SUBTITLE = "Respawner"
RdKGToolAdmin.constants.config.ADDON_RESPAWNER_ENABLED_STRING = "Enabled: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_CAMP_SUBTITLE = "Camp Preview"
RdKGToolAdmin.constants.config.ADDON_CAMP_ENABLED_STRING = "Enabled: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_SP_SUBTITLE = "Synergy Prevention"
RdKGToolAdmin.constants.config.ADDON_SP_ENABLED_STRING = "Enabled: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_SP_MODE_STRING = "Mode: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_SP_PREVENT_STRING = "%s: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_SO_SUBTITLE = "Synergy Overview"
RdKGToolAdmin.constants.config.ADDON_SO_ENABLED_STRING = "Enabled: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_SO_TABLE_MODE_STRING = "Table Mode: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_SO_DISPLAY_MODE_STRING = "Display Mode: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RA_SUBTITLE = "Role Assignment"
RdKGToolAdmin.constants.config.ADDON_RA_ENABLED_STRING = "Enabled: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_RA_ALLOW_OVERRIDE_STRING = "Allow Override: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_CAJ_SUBTITLE = "Campaign Auto Join"
RdKGToolAdmin.constants.config.ADDON_CAJ_ENABLED_STRING = "Enabled: |c%s%s|r"
RdKGToolAdmin.constants.config.ADDON_CRBGTP_SUBTITLE = "CR - BG - Templar Healer (BG)"
RdKGToolAdmin.constants.config.ADDON_CRBGTP_ENABLED_STRING = "Enabled: |c%s%s|r"
RdKGToolAdmin.constants.config.STATS_TITLE = "Stats"
RdKGToolAdmin.constants.config.STATS_MAGICKA_STRING = "Magicka: |c%s%s|r"
RdKGToolAdmin.constants.config.STATS_HEALTH_STRING = "Health: |c%s%s|r"
RdKGToolAdmin.constants.config.STATS_STAMINA_STRING = "Stamina: |c%s%s|r"
RdKGToolAdmin.constants.config.STATS_MAGICKA_RECOVERY_STRING = "Magicka Recovery: |c%s%s|r"
RdKGToolAdmin.constants.config.STATS_HEALTH_RECOVERY_STRING = "Health Recovery: |c%s%s|r"
RdKGToolAdmin.constants.config.STATS_STAMINA_RECOVERY_STRING = "Stamina Recovery: |c%s%s|r"
RdKGToolAdmin.constants.config.STATS_SPELL_DAMAGE_STRING = "Spell Damage: |c%s%s|r"
RdKGToolAdmin.constants.config.STATS_WEAPON_DAMAGE_STRING = "Weapon Damage: |c%s%s|r"
RdKGToolAdmin.constants.config.STATS_SPELL_PENETRATION_STRING = "Spell Penetration: |c%s%s|r"
RdKGToolAdmin.constants.config.STATS_WEAPON_PENETRATION_STRING = "Weapon Penetration: |c%s%s|r"
RdKGToolAdmin.constants.config.STATS_SPELL_CRITICAL_STRING = "Spell Critical: |c%s%s|r"
RdKGToolAdmin.constants.config.STATS_WEAPON_CRITICAL_STRING = "Weapon Critical: |c%s%s|r"
RdKGToolAdmin.constants.config.STATS_SPELL_RESISTANCE_STRING = "Spell Resistance: |c%s%s|r"
RdKGToolAdmin.constants.config.STATS_PHYSICAL_RESISTANCE_STRING = "Physical Resistance: |c%s%s|r"
RdKGToolAdmin.constants.config.STATS_CRITICAL_RESISTANCE_STRING = "Critical Resistance: |c%s%s|r"
RdKGToolAdmin.constants.config.MUNDUS_TITLE = "Mundus"
RdKGToolAdmin.constants.config.MUNDUS_STONE_1_STRING = "Mundus Stone 1: |c%s%s|r"
RdKGToolAdmin.constants.config.MUNDUS_STONE_2_STRING = "Mundus Stone 2: |c%s%s|r"
RdKGToolAdmin.constants.config.MUNDUS_FILTER = "Boon: "
RdKGToolAdmin.constants.config.CHAMPION_TITLE = "Champion Points"
RdKGToolAdmin.constants.config.SKILLS_TITLE = "Skills"
RdKGToolAdmin.constants.config.EQUIPMENT_TITLE = "Equipment"
RdKGToolAdmin.constants.config.EQUIPMENT_CONTEXT_REQUEST = "Request Item"
RdKGToolAdmin.constants.config.EQUIPMENT_CONTEXT_LINK_IN_CHAT = "Link in Chat"
RdKGToolAdmin.constants.config.QUICKSLOT_TITLE = "Quickslots"

--Config
RdKGToolConfig.constants = RdKGToolConfig.constants or {}
RdKGToolConfig.constants.TOGGLE_CONFIG = "Toggle Configuration Interface"
RdKGToolConfig.constants.HEADER_TITLE = "Configuration Import / Export"
RdKGToolConfig.constants.TAB_IMPORT_TITLE = "Import"
RdKGToolConfig.constants.TAB_EXPORT_TITLE = "Export"
RdKGToolConfig.constants.EXPORT_SELECT_ALL = "Select All"
RdKGToolConfig.constants.EXPORT_PROFILE = "Profile"
RdKGToolConfig.constants.EXPORT_STRING_LENGTH_ERROR = "The configuration string is too long. Please report this issue!"
RdKGToolConfig.constants.IMPORT_PROFILE = "New Profile Name"
RdKGToolConfig.constants.IMPORT = "Import"
RdKGToolConfig.constants.IMPORT_STATUS = "Status: "
RdKGToolConfig.constants.IMPORT_ADD_ALL = "Add all values (e.g. Window Positions)"
RdKGToolConfig.constants.IMPORT_STATUS_STARTED = "Import started"
RdKGToolConfig.constants.IMPORT_STATUS_FAILED = "Import failed"
RdKGToolConfig.constants.IMPORT_STATUS_FINISHED = "Import finished"
RdKGToolConfig.constants.IMPORT_STATUS_FINISHED_DIFFERENT_VERSION = "Import finished (different versions may lead to inconsistencies)"
RdKGToolConfig.constants.IMPORT_STATUS_PROFILE_INVALID_NAME = "Import failed - Invalid Profile Name"
RdKGToolConfig.constants.IMPORT_STATUS_PROFILE_DUPLICATE = "Import failed - Duplicate Profile Name"
RdKGToolConfig.constants.IMPORT_STATUS_NO_CONTENT = "Import failed - No Content"
RdKGToolConfig.constants.IMPORT_CONFIG_LINE_COUNT = "Config Lines: %s"
RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON = "Import failed at line %s. Reason: %s"
RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON_NIL = "Nil value"
RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON_TYPE_BOOLEAN = "Boolean expected"
RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON_TYPE_NUMBER = "Number expected"
RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON_TYPE_INVALID = "Invalid type"
RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON_LAYER_1_INVALID = "Layer1 invalid"
RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON_LAYER_2_INVALID = "Layer2 invalid"
RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON_LAYER_1_2_INVALID = "Layer1 or Layer2 invalid"
RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON_LAYER_X_INVALID = "LayerX invalid"