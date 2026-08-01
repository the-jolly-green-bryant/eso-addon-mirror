-- RdK Group Tool Synergy Overview
-- By @s0rdrak (PC / EU)

RdKGTool.toolbox = RdKGTool.toolbox or {}
local RdKGToolTB = RdKGTool.toolbox
RdKGTool.toolbox.so = RdKGTool.toolbox.so or {}
local RdKGToolSO = RdKGTool.toolbox.so
RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu
RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGToolUtil.chatSystem = RdKGToolUtil.chatSystem or {}
local RdKGToolChat = RdKGToolUtil.chatSystem
RdKGToolUtil.fonts = RdKGToolUtil.fonts or {}
local RdKGToolFonts = RdKGToolUtil.fonts
RdKGToolUtil.group = RdKGToolUtil.group or {}
local RdKGToolUtilGroup = RdKGToolUtil.group
RdKGToolUtil.networking = RdKGToolUtil.networking or {}
local RdKGToolNetworking = RdKGToolUtil.networking
RdKGToolUtil.math = RdKGToolUtil.math or {}
local RdKGToolMath = RdKGToolUtil.math
RdKGTool.group = RdKGTool.group or {}
local RdKGToolGroup = RdKGTool.group
RdKGToolGroup.dbo = RdKGToolGroup.dbo or {}
local RdKGToolDbo = RdKGToolGroup.dbo

RdKGToolSO.callbackName = RdKGTool.addonName .. "ToolboxSynergyOverview"
RdKGToolSO.messageLoopCallbackName = RdKGTool.addonName .. "ToolboxSynergyOverviewMessageLoop"

RdKGToolSO.constants = {}
RdKGToolSO.constants.TLW = "RdKGTool.toolbox.so.tlw"
RdKGToolSO.constants.PREFIX = "SO"

RdKGToolSO.constants.MODES = {}
RdKGToolSO.constants.MODES.TABLE_FULL = 1
RdKGToolSO.constants.MODES.TABLE_REDUCED = 2
RdKGToolSO.constants.TABLE_MODES = {}

RdKGToolSO.constants.SYNERGY_ID = {}
RdKGToolSO.constants.SYNERGY_ID.COMBUSTION_SHARD = 1
RdKGToolSO.constants.SYNERGY_ID.TALONS = 2
RdKGToolSO.constants.SYNERGY_ID.NOVA = 3
RdKGToolSO.constants.SYNERGY_ID.BLOOD_ALTAR = 4
RdKGToolSO.constants.SYNERGY_ID.STANDARD = 5
RdKGToolSO.constants.SYNERGY_ID.PURGE = 6
RdKGToolSO.constants.SYNERGY_ID.BONE_SHIELD = 7
RdKGToolSO.constants.SYNERGY_ID.FLOOD_CONDUIT = 8
RdKGToolSO.constants.SYNERGY_ID.ATRONACH = 9
RdKGToolSO.constants.SYNERGY_ID.TRAPPING_WEBS = 10
RdKGToolSO.constants.SYNERGY_ID.RADIATE = 11
RdKGToolSO.constants.SYNERGY_ID.CONSUMING_DARKNESS = 12
RdKGToolSO.constants.SYNERGY_ID.SOUL_LEECH = 13
RdKGToolSO.constants.SYNERGY_ID.WARDEN_HEALING = 14
RdKGToolSO.constants.SYNERGY_ID.GRAVE_ROBBER = 15
RdKGToolSO.constants.SYNERGY_ID.PURE_AGONY = 16
RdKGToolSO.constants.SYNERGY_ID.ICY_ESCAPE = 17
RdKGToolSO.constants.SYNERGY_ID.SANGUINE_BURST = 18
RdKGToolSO.constants.SYNERGY_ID.HEED_THE_CALL = 19
RdKGToolSO.constants.SYNERGY_ID.URSUS = 20
RdKGToolSO.constants.SYNERGY_ID.GRYPHON = 21
RdKGToolSO.constants.SYNERGY_ID.RUNEBREAK = 22
RdKGToolSO.constants.SYNERGY_ID.PASSAGE = 23
RdKGToolSO.constants.SYNERGY_ID.RECOVERY = 24

RdKGToolSO.constants.SYNERGY_ABLITY_ID = {}
RdKGToolSO.constants.SYNERGY_ABLITY_ID.BLOOD_ALTAR = 41965
RdKGToolSO.constants.SYNERGY_ABLITY_ID.OVERFLOWING_ALTAR = 39519
RdKGToolSO.constants.SYNERGY_ABLITY_ID.TRAPPING_WEBS = 39451
RdKGToolSO.constants.SYNERGY_ABLITY_ID.SHADOW_SILK = 41997
RdKGToolSO.constants.SYNERGY_ABLITY_ID.TANGLING_WEBS = 42019
RdKGToolSO.constants.SYNERGY_ABLITY_ID.INNER_FIRE = 42057
RdKGToolSO.constants.SYNERGY_ABLITY_ID.INNER_BEAST = 41840
RdKGToolSO.constants.SYNERGY_ABLITY_ID.BONE_SHIELD = 39424
RdKGToolSO.constants.SYNERGY_ABLITY_ID.BONE_SURGE = 42196
RdKGToolSO.constants.SYNERGY_ABLITY_ID.NECROTIC_ORB = 85434
RdKGToolSO.constants.SYNERGY_ABLITY_ID.ENERGY_ORB = 63512
RdKGToolSO.constants.SYNERGY_ABLITY_ID.LUMINOUS_SHARDS = 48052
RdKGToolSO.constants.SYNERGY_ABLITY_ID.SPEAR_SHARDS = 95926
RdKGToolSO.constants.SYNERGY_ABLITY_ID.LIGHTNING_SPLASH = 43769
RdKGToolSO.constants.SYNERGY_ABLITY_ID.HEALING_SEED = 85576
RdKGToolSO.constants.SYNERGY_ABLITY_ID.EXTENDED_RITUAL = 22270
RdKGToolSO.constants.SYNERGY_ABLITY_ID.SUMMON_STORM_ATRONACH = 48085
RdKGToolSO.constants.SYNERGY_ABLITY_ID.SUMMON_ATRONACH = 48085
RdKGToolSO.constants.SYNERGY_ABLITY_ID.STANDARD = 67717
RdKGToolSO.constants.SYNERGY_ABLITY_ID.TALONS = 48040
RdKGToolSO.constants.SYNERGY_ABLITY_ID.NOVA = 48938
RdKGToolSO.constants.SYNERGY_ABLITY_ID.SUPER_NOVA = 48939
RdKGToolSO.constants.SYNERGY_ABLITY_ID.CONSUMING_DARKNESS = 77769
RdKGToolSO.constants.SYNERGY_ABLITY_ID.SOUL_SHRED = 25172
RdKGToolSO.constants.SYNERGY_ABLITY_ID.GRAVE_ROBBER = 115567
RdKGToolSO.constants.SYNERGY_ABLITY_ID.PURE_AGONY = 118610
RdKGToolSO.constants.SYNERGY_ABLITY_ID.ICY_ESCAPE = 88892
RdKGToolSO.constants.SYNERGY_ABLITY_ID.SANGUINE_BURST = 141971
RdKGToolSO.constants.SYNERGY_ABLITY_ID.HEED_THE_CALL = 142780
RdKGToolSO.constants.SYNERGY_ABLITY_ID.URSUS = 112414
RdKGToolSO.constants.SYNERGY_ABLITY_ID.GRYPHON = 167045
RdKGToolSO.constants.SYNERGY_ABLITY_ID.RUNEBREAK = 191080
RdKGToolSO.constants.SYNERGY_ABLITY_ID.PASSAGE = 190646
RdKGToolSO.constants.SYNERGY_ABLITY_ID.RECOVERY = 241235

RdKGToolSO.constants.DISPLAYMODE_ALL = 1
RdKGToolSO.constants.DISPLAYMODE_SYNERGY = 2

RdKGToolSO.constants.sizes = {}
RdKGToolSO.constants.size = {}
RdKGToolSO.constants.size.SMALL = 1
RdKGToolSO.constants.size.BIG = 2

RdKGToolSO.controls = {}

RdKGToolSO.config = {}
RdKGToolSO.config.full = {}
RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL] = {}
RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].rowHeight = 18
RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].synergyDimension = 14
RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].spacing = 4
RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].labelWidth = 100
RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].width = RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].labelWidth + 16 * RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].synergyDimension + 15 * RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].spacing
RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].height = 13 * RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].rowHeight
RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].fontSize = RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].rowHeight - 2
RdKGToolSO.config.full[RdKGToolSO.constants.size.BIG] = {}
RdKGToolSO.config.full[RdKGToolSO.constants.size.BIG].rowHeight = 30
RdKGToolSO.config.full[RdKGToolSO.constants.size.BIG].synergyDimension = 26
RdKGToolSO.config.full[RdKGToolSO.constants.size.BIG].spacing = 5
RdKGToolSO.config.full[RdKGToolSO.constants.size.BIG].labelWidth = 150
RdKGToolSO.config.full[RdKGToolSO.constants.size.BIG].width = RdKGToolSO.config.full[RdKGToolSO.constants.size.BIG].labelWidth + 16 * RdKGToolSO.config.full[RdKGToolSO.constants.size.BIG].synergyDimension + 15 * RdKGToolSO.config.full[RdKGToolSO.constants.size.BIG].spacing
RdKGToolSO.config.full[RdKGToolSO.constants.size.BIG].height = 13 * RdKGToolSO.config.full[RdKGToolSO.constants.size.BIG].rowHeight
RdKGToolSO.config.full[RdKGToolSO.constants.size.BIG].fontSize = RdKGToolSO.config.full[RdKGToolSO.constants.size.BIG].rowHeight - 10
RdKGToolSO.config.isClampedToScreen = true
RdKGToolSO.config.updateInterval = 100
RdKGToolSO.config.buffUpdateInterval = 100
RdKGToolSO.config.messageUpdateInterval = 100
RdKGToolSO.config.backdropAlphaOdd = 0.25
RdKGToolSO.config.backdropAlphaEven = 0.15
RdKGToolSO.config.minCooldownMs = 200
RdKGToolSO.config.reduced = {}
RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL] = {}
RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].synergyDimension = 40--50
RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].entryHeight = 20--25
RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].width = 16 * RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].synergyDimension
RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].height = 6 * RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].entryHeight + RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].synergyDimension
RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].fontSize = RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].entryHeight - 9
RdKGToolSO.config.reduced[RdKGToolSO.constants.size.BIG] = {}
RdKGToolSO.config.reduced[RdKGToolSO.constants.size.BIG].synergyDimension = 50--50
RdKGToolSO.config.reduced[RdKGToolSO.constants.size.BIG].entryHeight = 25--25
RdKGToolSO.config.reduced[RdKGToolSO.constants.size.BIG].width = 16 * RdKGToolSO.config.reduced[RdKGToolSO.constants.size.BIG].synergyDimension
RdKGToolSO.config.reduced[RdKGToolSO.constants.size.BIG].height = 6 * RdKGToolSO.config.reduced[RdKGToolSO.constants.size.BIG].entryHeight + RdKGToolSO.config.reduced[RdKGToolSO.constants.size.BIG].synergyDimension
RdKGToolSO.config.reduced[RdKGToolSO.constants.size.BIG].fontSize = RdKGToolSO.config.reduced[RdKGToolSO.constants.size.BIG].entryHeight - 9

RdKGToolSO.state = {}
RdKGToolSO.state.initialized = false
RdKGToolSO.state.registredConsumers = false
RdKGToolSO.state.foreground = true
RdKGToolSO.state.activeLayerIndex = 1
RdKGToolSO.state.registredActiveConsumers = false
RdKGToolSO.state.lastMessages = {}
RdKGToolSO.state.lastSynergy = 0

RdKGToolSO.state.SYNERGY_DATA = {}
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.BLOOD_ALTAR] = {}
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.BLOOD_ALTAR].cooldown = 20
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.BLOOD_ALTAR].texture = "/esoui/art/icons/ability_undaunted_001_b.dds"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.BLOOD_ALTAR].callbackName = RdKGToolSO.callbackName .. ".altar"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.BLOOD_ALTAR].id = RdKGToolSO.constants.SYNERGY_ID.BLOOD_ALTAR

RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.TRAPPING_WEBS] = {}
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.TRAPPING_WEBS].cooldown = 20
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.TRAPPING_WEBS].texture = "/esoui/art/icons/ability_undaunted_003_b.dds"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.TRAPPING_WEBS].callbackName = RdKGToolSO.callbackName .. ".trapping_webs"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.TRAPPING_WEBS].id = RdKGToolSO.constants.SYNERGY_ID.TRAPPING_WEBS

RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.RADIATE] = {}
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.RADIATE].cooldown = 20
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.RADIATE].texture = "/esoui/art/icons/ability_undaunted_002_b.dds"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.RADIATE].callbackName = RdKGToolSO.callbackName .. ".radiate"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.RADIATE].id = RdKGToolSO.constants.SYNERGY_ID.RADIATE

RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.BONE_SHIELD] = {}
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.BONE_SHIELD].cooldown = 20
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.BONE_SHIELD].texture = "/esoui/art/icons/ability_undaunted_005b.dds"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.BONE_SHIELD].callbackName = RdKGToolSO.callbackName .. ".bone_shield"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.BONE_SHIELD].id = RdKGToolSO.constants.SYNERGY_ID.BONE_SHIELD

RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.COMBUSTION_SHARD] = {}
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.COMBUSTION_SHARD].cooldown = 20
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.COMBUSTION_SHARD].texture = "/esoui/art/icons/ability_undaunted_004b.dds"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.COMBUSTION_SHARD].callbackName = RdKGToolSO.callbackName .. ".combustion"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.COMBUSTION_SHARD].id = RdKGToolSO.constants.SYNERGY_ID.COMBUSTION_SHARD

RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.FLOOD_CONDUIT] = {}
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.FLOOD_CONDUIT].cooldown = 20
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.FLOOD_CONDUIT].texture = "/esoui/art/icons/ability_sorcerer_liquid_lightning.dds"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.FLOOD_CONDUIT].callbackName = RdKGToolSO.callbackName .. ".conduit"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.FLOOD_CONDUIT].id = RdKGToolSO.constants.SYNERGY_ID.FLOOD_CONDUIT

RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.PURGE] = {}
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.PURGE].cooldown = 20
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.PURGE].texture = "/esoui/art/icons/ability_templar_extended_ritual.dds"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.PURGE].callbackName = RdKGToolSO.callbackName .. ".purge"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.PURGE].id = RdKGToolSO.constants.SYNERGY_ID.PURGE

RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.ATRONACH] = {}
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.ATRONACH].cooldown = 20
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.ATRONACH].texture = "/esoui/art/icons/ability_sorcerer_storm_atronach.dds"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.ATRONACH].callbackName = RdKGToolSO.callbackName .. ".atronach"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.ATRONACH].id = RdKGToolSO.constants.SYNERGY_ID.ATRONACH

RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.STANDARD] = {}
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.STANDARD].cooldown = 20
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.STANDARD].texture = "/esoui/art/icons/ability_dragonknight_006.dds"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.STANDARD].callbackName = RdKGToolSO.callbackName .. ".standard"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.STANDARD].id = RdKGToolSO.constants.SYNERGY_ID.STANDARD

RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.TALONS] = {}
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.TALONS].cooldown = 20
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.TALONS].texture = "/esoui/art/icons/ability_dragonknight_010.dds"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.TALONS].callbackName = RdKGToolSO.callbackName .. ".talons"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.TALONS].id = RdKGToolSO.constants.SYNERGY_ID.TALONS

RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.NOVA] = {}
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.NOVA].cooldown = 20
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.NOVA].texture = "/esoui/art/icons/ability_templar_solar_disturbance.dds"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.NOVA].callbackName = RdKGToolSO.callbackName .. ".nova"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.NOVA].id = RdKGToolSO.constants.SYNERGY_ID.NOVA

RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.CONSUMING_DARKNESS] = {}
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.CONSUMING_DARKNESS].cooldown = 20
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.CONSUMING_DARKNESS].texture = "/esoui/art/icons/ability_nightblade_015.dds"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.CONSUMING_DARKNESS].callbackName = RdKGToolSO.callbackName .. ".consuming_darkness"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.CONSUMING_DARKNESS].id = RdKGToolSO.constants.SYNERGY_ID.CONSUMING_DARKNESS

RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.SOUL_LEECH] = {}
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.SOUL_LEECH].cooldown = 20
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.SOUL_LEECH].texture = "/esoui/art/icons/ability_nightblade_018.dds"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.SOUL_LEECH].callbackName = RdKGToolSO.callbackName .. ".soul_leech"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.SOUL_LEECH].id = RdKGToolSO.constants.SYNERGY_ID.SOUL_LEECH

RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.WARDEN_HEALING] = {}
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.WARDEN_HEALING].cooldown = 20
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.WARDEN_HEALING].texture = "esoui/art/icons/ability_warden_007.dds"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.WARDEN_HEALING].callbackName = RdKGToolSO.callbackName .. ".warden_healing"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.WARDEN_HEALING].id = RdKGToolSO.constants.SYNERGY_ID.WARDEN_HEALING

RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.GRAVE_ROBBER] = {}
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.GRAVE_ROBBER].cooldown = 20
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.GRAVE_ROBBER].texture = "esoui/art/icons/ability_necromancer_004.dds"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.GRAVE_ROBBER].callbackName = RdKGToolSO.callbackName .. ".grave_robber"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.GRAVE_ROBBER].id = RdKGToolSO.constants.SYNERGY_ID.GRAVE_ROBBER

RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.PURE_AGONY] = {}
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.PURE_AGONY].cooldown = 20
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.PURE_AGONY].texture = "esoui/art/icons/ability_necromancer_010.dds"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.PURE_AGONY].callbackName = RdKGToolSO.callbackName .. ".pure_agony"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.PURE_AGONY].id = RdKGToolSO.constants.SYNERGY_ID.PURE_AGONY

RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.ICY_ESCAPE] = {}
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.ICY_ESCAPE].cooldown = 20
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.ICY_ESCAPE].texture = "esoui/art/icons/ability_warden_005_b.dds"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.ICY_ESCAPE].callbackName = RdKGToolSO.callbackName .. ".icy_escape"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.ICY_ESCAPE].id = RdKGToolSO.constants.SYNERGY_ID.ICY_ESCAPE

RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.SANGUINE_BURST] = {}
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.SANGUINE_BURST].cooldown = 20
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.SANGUINE_BURST].texture = "esoui/art/icons/ability_u23_bloodball_chokeonit.dds"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.SANGUINE_BURST].callbackName = RdKGToolSO.callbackName .. ".sanguine_burst"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.SANGUINE_BURST].id = RdKGToolSO.constants.SYNERGY_ID.SANGUINE_BURST

RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.HEED_THE_CALL] = {}
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.HEED_THE_CALL].cooldown = 20
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.HEED_THE_CALL].texture = "esoui/art/icons/achievement_u26_skyrim_werewolfdevour100.dds"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.HEED_THE_CALL].callbackName = RdKGToolSO.callbackName .. ".heed_the_call"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.HEED_THE_CALL].id = RdKGToolSO.constants.SYNERGY_ID.HEED_THE_CALL

RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.URSUS] = {}
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.URSUS].cooldown = 20
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.URSUS].texture = "esoui/art/icons/ability_warden_018_c.dds"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.URSUS].callbackName = RdKGToolSO.callbackName .. ".ursus"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.URSUS].id = RdKGToolSO.constants.SYNERGY_ID.URSUS

RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.GRYPHON] = {}
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.GRYPHON].cooldown = 20
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.GRYPHON].texture = "esoui/art/icons/achievement_trial_cr_flavor_3.dds"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.GRYPHON].callbackName = RdKGToolSO.callbackName .. ".gryphon"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.GRYPHON].id = RdKGToolSO.constants.SYNERGY_ID.GRYPHON

RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.RUNEBREAK] = {}
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.RUNEBREAK].cooldown = 20
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.RUNEBREAK].texture = "esoui/art/icons/ability_arcanist_004.dds"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.RUNEBREAK].callbackName = RdKGToolSO.callbackName .. ".runebreak"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.RUNEBREAK].id = RdKGToolSO.constants.SYNERGY_ID.RUNEBREAK

RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.PASSAGE] = {}
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.PASSAGE].cooldown = 20
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.PASSAGE].texture = "esoui/art/icons/ability_arcanist_016_b.dds"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.PASSAGE].callbackName = RdKGToolSO.callbackName .. ".passage"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.PASSAGE].id = RdKGToolSO.constants.SYNERGY_ID.PASSAGE


RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.RECOVERY] = {}
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.RECOVERY].cooldown = 20
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.RECOVERY].texture = "esoui/art/icons/ability_healer_018.dds"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.RECOVERY].callbackName = RdKGToolSO.callbackName .. ".recovery"
RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.RECOVERY].id = RdKGToolSO.constants.SYNERGY_ID.RECOVERY

RdKGToolSO.state.SYNERGIES = {}
RdKGToolSO.state.SYNERGIES[RdKGToolSO.constants.SYNERGY_ABLITY_ID.BLOOD_ALTAR] = RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.BLOOD_ALTAR]
RdKGToolSO.state.SYNERGIES[RdKGToolSO.constants.SYNERGY_ABLITY_ID.OVERFLOWING_ALTAR] = RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.BLOOD_ALTAR]
RdKGToolSO.state.SYNERGIES[RdKGToolSO.constants.SYNERGY_ABLITY_ID.TRAPPING_WEBS] = RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.TRAPPING_WEBS]
RdKGToolSO.state.SYNERGIES[RdKGToolSO.constants.SYNERGY_ABLITY_ID.SHADOW_SILK] = RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.TRAPPING_WEBS]
RdKGToolSO.state.SYNERGIES[RdKGToolSO.constants.SYNERGY_ABLITY_ID.TANGLING_WEBS] = RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.TRAPPING_WEBS]
RdKGToolSO.state.SYNERGIES[RdKGToolSO.constants.SYNERGY_ABLITY_ID.INNER_FIRE] = RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.RADIATE]
RdKGToolSO.state.SYNERGIES[RdKGToolSO.constants.SYNERGY_ABLITY_ID.INNER_BEAST] = RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.RADIATE]
RdKGToolSO.state.SYNERGIES[RdKGToolSO.constants.SYNERGY_ABLITY_ID.BONE_SHIELD] = RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.BONE_SHIELD]
RdKGToolSO.state.SYNERGIES[RdKGToolSO.constants.SYNERGY_ABLITY_ID.BONE_SURGE] = RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.BONE_SHIELD]
RdKGToolSO.state.SYNERGIES[RdKGToolSO.constants.SYNERGY_ABLITY_ID.NECROTIC_ORB] = RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.COMBUSTION_SHARD]
RdKGToolSO.state.SYNERGIES[RdKGToolSO.constants.SYNERGY_ABLITY_ID.ENERGY_ORB] = RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.COMBUSTION_SHARD]
RdKGToolSO.state.SYNERGIES[RdKGToolSO.constants.SYNERGY_ABLITY_ID.LUMINOUS_SHARDS] = RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.COMBUSTION_SHARD]
RdKGToolSO.state.SYNERGIES[RdKGToolSO.constants.SYNERGY_ABLITY_ID.SPEAR_SHARDS] = RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.COMBUSTION_SHARD]
RdKGToolSO.state.SYNERGIES[RdKGToolSO.constants.SYNERGY_ABLITY_ID.LIGHTNING_SPLASH] = RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.FLOOD_CONDUIT]
RdKGToolSO.state.SYNERGIES[RdKGToolSO.constants.SYNERGY_ABLITY_ID.HEALING_SEED] = RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.WARDEN_HEALING]
RdKGToolSO.state.SYNERGIES[RdKGToolSO.constants.SYNERGY_ABLITY_ID.EXTENDED_RITUAL] = RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.PURGE]
RdKGToolSO.state.SYNERGIES[RdKGToolSO.constants.SYNERGY_ABLITY_ID.SUMMON_STORM_ATRONACH] = RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.ATRONACH]
RdKGToolSO.state.SYNERGIES[RdKGToolSO.constants.SYNERGY_ABLITY_ID.SUMMON_ATRONACH] = RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.ATRONACH]
RdKGToolSO.state.SYNERGIES[RdKGToolSO.constants.SYNERGY_ABLITY_ID.STANDARD] = RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.STANDARD]
RdKGToolSO.state.SYNERGIES[RdKGToolSO.constants.SYNERGY_ABLITY_ID.TALONS] = RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.TALONS]
RdKGToolSO.state.SYNERGIES[RdKGToolSO.constants.SYNERGY_ABLITY_ID.NOVA] = RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.NOVA]
RdKGToolSO.state.SYNERGIES[RdKGToolSO.constants.SYNERGY_ABLITY_ID.SUPER_NOVA] = RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.NOVA]
RdKGToolSO.state.SYNERGIES[RdKGToolSO.constants.SYNERGY_ABLITY_ID.CONSUMING_DARKNESS] = RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.CONSUMING_DARKNESS]
RdKGToolSO.state.SYNERGIES[RdKGToolSO.constants.SYNERGY_ABLITY_ID.SOUL_SHRED] = RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.SOUL_LEECH]
RdKGToolSO.state.SYNERGIES[RdKGToolSO.constants.SYNERGY_ABLITY_ID.GRAVE_ROBBER] = RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.GRAVE_ROBBER]
RdKGToolSO.state.SYNERGIES[RdKGToolSO.constants.SYNERGY_ABLITY_ID.PURE_AGONY] = RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.PURE_AGONY]
RdKGToolSO.state.SYNERGIES[RdKGToolSO.constants.SYNERGY_ABLITY_ID.ICY_ESCAPE] = RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.ICY_ESCAPE]
RdKGToolSO.state.SYNERGIES[RdKGToolSO.constants.SYNERGY_ABLITY_ID.SANGUINE_BURST] = RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.SANGUINE_BURST]
RdKGToolSO.state.SYNERGIES[RdKGToolSO.constants.SYNERGY_ABLITY_ID.HEED_THE_CALL] = RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.HEED_THE_CALL]
RdKGToolSO.state.SYNERGIES[RdKGToolSO.constants.SYNERGY_ABLITY_ID.URSUS] = RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.URSUS]
RdKGToolSO.state.SYNERGIES[RdKGToolSO.constants.SYNERGY_ABLITY_ID.GRYPHON] = RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.GRYPHON]
RdKGToolSO.state.SYNERGIES[RdKGToolSO.constants.SYNERGY_ABLITY_ID.RUNEBREAK] = RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.RUNEBREAK]
RdKGToolSO.state.SYNERGIES[RdKGToolSO.constants.SYNERGY_ABLITY_ID.PASSAGE] = RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.PASSAGE]
RdKGToolSO.state.SYNERGIES[RdKGToolSO.constants.SYNERGY_ABLITY_ID.RECOVERY] = RdKGToolSO.state.SYNERGY_DATA[RdKGToolSO.constants.SYNERGY_ID.RECOVERY]

RdKGToolSO.state.fullWidth = RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].width
RdKGToolSO.state.reducedWidth = RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].width
RdKGToolSO.state.reducedSynergyDimension = RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].synergyDimension
RdKGToolSO.state.reducedEntryHeight = RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].entryHeight


local wm = WINDOW_MANAGER

function RdKGToolSO.Initialize()
	RdKGTool.profile.AddProfileChangeListener(RdKGToolSO.callbackName, RdKGToolSO.OnProfileChanged)

	RdKGToolSO.state.controlFont = RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.CHAT_FONT, RdKGToolFonts.constants.INPUT_KB, RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].fontSize, RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THIN)
	
	RdKGToolSO.CreateUI()
	
	RdKGToolMenu.AddPositionFixedConsumer(RdKGToolSO.SetSoPositionLocked)
	
	RdKGToolSO.state.initialized = true
	RdKGToolSO.SetEnabled(RdKGToolSO.soVars.enabled, RdKGToolSO.soVars.windowEnabled)
	RdKGToolSO.SetPositionLocked(RdKGToolSO.soVars.positionLocked)
	RdKGToolSO.SetControlVisibility()
	
	RdKGToolSO.AdjustSize()
end

function RdKGToolSO.CreateUI()
	RdKGToolSO.controls.TLW = wm:CreateTopLevelWindow(RdKGToolSO.constants.TLW)
	
	RdKGToolSO.SetTlwLocation()
	
	RdKGToolSO.controls.TLW:SetClampedToScreen(RdKGToolSO.config.isClampedToScreen)
	RdKGToolSO.controls.TLW:SetHandler("OnMoveStop", RdKGToolSO.SaveWindowLocation)
	RdKGToolSO.controls.TLW:SetDimensions(RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].width, RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].height)
	
	--full table mode
	RdKGToolSO.controls.TLW.fullTableControl = wm:CreateControl(nil, RdKGToolSO.controls.TLW, CT_CONTROL)
	
	local fullTableControl = RdKGToolSO.controls.TLW.fullTableControl
	
	
	fullTableControl:SetDimensions(RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].width, RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].height)
	fullTableControl:SetAnchor(TOPLEFT, RdKGToolSO.controls.TLW, TOPLEFT, 0, 0)
	
	fullTableControl.movableBackdrop = wm:CreateControl(nil, fullTableControl, CT_BACKDROP)
	
	fullTableControl.movableBackdrop:SetAnchor(TOPLEFT, fullTableControl, TOPLEFT, 0, 0)
	fullTableControl.movableBackdrop:SetDimensions(RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].width, RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].height)
	
	fullTableControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.0)
	fullTableControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
	
	fullTableControl.header = RdKGToolSO.CreateUiHeader(fullTableControl)
	fullTableControl.rows = {}
	for i = 1, 24 do
		fullTableControl.rows[i] = RdKGToolSO.CreateUiRow(fullTableControl, i * RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].rowHeight)
	end
	
	--reduced table mode
	RdKGToolSO.controls.TLW.reducedTableControl = wm:CreateControl(nil, RdKGToolSO.controls.TLW, CT_CONTROL)
	
	local reducedTableControl = RdKGToolSO.controls.TLW.reducedTableControl
	
	
	reducedTableControl:SetDimensions(RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].width, RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].height)
	reducedTableControl:SetAnchor(TOPLEFT, RdKGToolSO.controls.TLW, TOPLEFT, 0, 0)
	
	reducedTableControl.movableBackdrop = wm:CreateControl(nil, reducedTableControl, CT_BACKDROP)
	
	reducedTableControl.movableBackdrop:SetAnchor(TOPLEFT, reducedTableControl, TOPLEFT, 0, 0)
	reducedTableControl.movableBackdrop:SetDimensions(RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].width, RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].height)
	
	reducedTableControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.0)
	reducedTableControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
	
	reducedTableControl.header = RdKGToolSO.CreateUiReducedHeader(reducedTableControl)
	reducedTableControl.entries = {}
	for i = 1, 12 do
		reducedTableControl.entries[i] = RdKGToolSO.CreateReducedEntry(reducedTableControl)
	end
end

function RdKGToolSO.SetTlwLocation()
	RdKGToolSO.controls.TLW:ClearAnchors()
	if RdKGToolSO.soVars.location == nil then
		RdKGToolSO.controls.TLW:SetAnchor(CENTER, GuiRoot, CENTER, -250, 250)
	else
		RdKGToolSO.controls.TLW:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RdKGToolSO.soVars.location.x, RdKGToolSO.soVars.location.y)
	end
end

function RdKGToolSO.CreateUiHeader(control)
	local header = wm:CreateControl(nil, control, CT_CONTROL)
	header:SetDimensions(RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].width, RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].rowHeight)
	header:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
	
	header.synergies = {}
	
	for i = 1, #RdKGToolSO.state.SYNERGY_DATA do
		local positionX = RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].labelWidth + ((i - 1) * RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].synergyDimension) + ((i - 1) * RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].spacing)
		header.synergies[i] = RdKGToolSO.CreateSynergyIcon(header, positionX, RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].spacing, i)
	end
	
	return header
end

function RdKGToolSO.CreateUiReducedHeader(control)
	local header = wm:CreateControl(nil, control, CT_CONTROL)
	header:SetDimensions(RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].width, RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].synergyDimension)
	header:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
	
	header.synergies = {}
	for i = 1, #RdKGToolSO.state.SYNERGY_DATA do
		local positionX = ((i - 1) * RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].synergyDimension)
		header.synergies[i] = RdKGToolSO.CreateReducedSynergyIcon(header, positionX, 0, i)
	end
	return header
end

function RdKGToolSO.CreateSynergyIcon(control, positionX, positionY, index)
	local texture = wm:CreateControl(nil, control, CT_TEXTURE)
	texture:SetAnchor(TOPLEFT, control, TOPLEFT, positionX, positionY)
	texture:SetDimensions(RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].synergyDimension, RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].synergyDimension)
	texture:SetTexture(RdKGToolSO.state.SYNERGY_DATA[index].texture)
	return texture
end

function RdKGToolSO.CreateReducedSynergyIcon(control, positionX, positionY, index)
	local retControl = wm:CreateControl(nil, control, CT_CONTROL)
	retControl:SetAnchor(TOPLEFT, control, TOPLEFT, positionX, positionY)
	retControl:SetDimensions(RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].synergyDimension, RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].synergyDimension)
	
	retControl.texture = wm:CreateControl(nil, retControl, CT_TEXTURE)
	retControl.texture:SetAnchor(TOPLEFT, retControl, TOPLEFT, 0, 0)
	retControl.texture:SetDimensions(RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].synergyDimension, RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].synergyDimension)
	retControl.texture:SetTexture(RdKGToolSO.state.SYNERGY_DATA[index].texture)
	retControl.texture:SetDrawTier(0)
	
	retControl.border = wm:CreateControl(nil, retControl, CT_TEXTURE)
	retControl.border:SetAnchor(TOPLEFT, retControl, TOPLEFT, 0, 0)
	retControl.border:SetDimensions(RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].synergyDimension, RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].synergyDimension)
	retControl.border:SetTexture("/esoui/art/actionbar/abilityframe64_up.dds")
	retControl.border:SetDrawTier(1)
	return retControl
end

function RdKGToolSO.CreateUiRow(control, positionY)
	local row = wm:CreateControl(nil, control, CT_CONTROL)
	row:SetDimensions(RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].width, RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].rowHeight)
	row:SetAnchor(TOPLEFT, control, TOPLEFT, 0, positionY)
	row:SetHidden(true)
	
	row.backdrop = wm:CreateControl(nil, row, CT_BACKDROP)
	row.backdrop:SetAnchor(TOPLEFT, row, TOPLEFT, 0, 0)
	row.backdrop:SetDimensions(RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].width, RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].rowHeight)
	row.backdrop:SetCenterColor(RdKGToolSO.soVars.backgroundColor.r, RdKGToolSO.soVars.backgroundColor.g, RdKGToolSO.soVars.backgroundColor.b, 0)
	row.backdrop:SetEdgeColor(RdKGToolSO.soVars.backgroundColor.r, RdKGToolSO.soVars.backgroundColor.g, RdKGToolSO.soVars.backgroundColor.b, 0)
		
	row.label = wm:CreateControl(nil, row, CT_LABEL)
	row.label:SetDimensions(RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].labelWidth, RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].rowHeight)
	row.label:SetAnchor(TOPLEFT, row, TOPLEFT, 0, 0)
	row.label:SetFont(RdKGToolSO.state.controlFont)
	row.label:SetWrapMode(ELLIPSIS)
	row.label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	row.label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	--row.label:SetText("test")
	
	row.synergies = {}
	for i = 1, #RdKGToolSO.state.SYNERGY_DATA do
		local positionX = RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].labelWidth + ((i - 1) * RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].synergyDimension) + ((i - 1) * RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].spacing)
		row.synergies[i] = RdKGToolSO.CreateSynergyProgressBar(row, positionX, RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].spacing / 2)
	end
	return row
end

function RdKGToolSO.CreateReducedEntry(control)
	local sizeIncrease = RdKGToolSO.soVars.size - RdKGToolSO.constants.size.SMALL
	local synergyDimension = (RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].synergyDimension + (RdKGToolSO.config.reduced[RdKGToolSO.constants.size.BIG].synergyDimension - RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].synergyDimension) * sizeIncrease)
	local entryHeight = (RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].entryHeight + (RdKGToolSO.config.reduced[RdKGToolSO.constants.size.BIG].entryHeight - RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].entryHeight) * sizeIncrease)
	local font = RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.CHAT_FONT, RdKGToolFonts.constants.INPUT_KB, (RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].fontSize + (RdKGToolSO.config.reduced[RdKGToolSO.constants.size.BIG].fontSize - RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].fontSize) * sizeIncrease), RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THIN)
	
	local entry = wm:CreateControl(nil, control, CT_CONTROL)
	entry:SetDimensions(synergyDimension, entryHeight)
	entry:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
	
	entry.backdrop = wm:CreateControl(nil, entry, CT_BACKDROP)
	entry.backdrop:SetAnchor(TOPLEFT, entry, TOPLEFT, 0, 0)
	entry.backdrop:SetDimensions(synergyDimension, entryHeight)
	entry.backdrop:SetCenterColor(RdKGToolSO.soVars.synergyBackdropColor.r, RdKGToolSO.soVars.synergyBackdropColor.g, RdKGToolSO.soVars.synergyBackdropColor.b, RdKGToolSO.soVars.synergyBackdropColor.a)
	entry.backdrop:SetEdgeColor(RdKGToolSO.soVars.synergyBackdropColor.r, RdKGToolSO.soVars.synergyBackdropColor.g, RdKGToolSO.soVars.synergyBackdropColor.b, 0)
	
	entry.progress = wm:CreateControl(nil, entry, CT_STATUSBAR)
	entry.progress:SetAnchor(TOPLEFT, entry, TOPLEFT, 1, 1)
	entry.progress:SetDimensions(synergyDimension - 2, entryHeight - 2)
	entry.progress:SetMinMax(0, 100)
	entry.progress:SetValue(0)
	entry.progress:SetColor(RdKGToolSO.soVars.progressColor.r, RdKGToolSO.soVars.progressColor.g, RdKGToolSO.soVars.progressColor.b, 1)
	
	entry.name = wm:CreateControl(nil, entry, CT_LABEL)
	entry.name:SetDimensions(synergyDimension - 8, entryHeight - 4)
	entry.name:SetAnchor(TOPLEFT, entry, TOPLEFT, 4, 2)
	entry.name:SetFont(font)
	entry.name:SetWrapMode(ELLIPSIS)
	entry.name:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	entry.name:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	entry.name:SetColor(RdKGToolSO.soVars.textColor.r, RdKGToolSO.soVars.textColor.g, RdKGToolSO.soVars.textColor.b, 1)
	
	entry.edge = wm:CreateControl(nil, entry, CT_BACKDROP)
	entry.edge:SetAnchor(TOPLEFT, entry, TOPLEFT, 0, 0)
	entry.edge:SetDimensions(synergyDimension, entryHeight)
	entry.edge:SetEdgeTexture(nil, 1, 1, 1, 0)
	entry.edge:SetCenterColor(0, 0, 0, 0)
	entry.edge:SetEdgeColor(0, 0, 0, 1)
	
	return entry
end

function RdKGToolSO.CreateSynergyProgressBar(control, positionX, positionY)
	local synergy = wm:CreateControl(nil, control, CT_CONTROL)
	synergy:SetAnchor(TOPLEFT, control, TOPLEFT, positionX, positionY)
	synergy:SetDimensions(RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].synergyDimension, RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].synergyDimension)
	
	synergy.backdrop = wm:CreateControl(nil, synergy, CT_BACKDROP)
	synergy.backdrop:SetAnchor(TOPLEFT, synergy, TOPLEFT, 0, 0)
	synergy.backdrop:SetDimensions(RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].synergyDimension, RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].synergyDimension)
	synergy.backdrop:SetCenterColor(RdKGToolSO.soVars.synergyBackdropColor.r, RdKGToolSO.soVars.synergyBackdropColor.g, RdKGToolSO.soVars.synergyBackdropColor.b, RdKGToolSO.soVars.synergyBackdropColor.a)
	synergy.backdrop:SetEdgeColor(RdKGToolSO.soVars.synergyBackdropColor.r, RdKGToolSO.soVars.synergyBackdropColor.g, RdKGToolSO.soVars.synergyBackdropColor.b, 0)
	
	synergy.progress = wm:CreateControl(nil, synergy, CT_STATUSBAR)
	synergy.progress:SetAnchor(TOPLEFT, synergy, TOPLEFT, 0, 0)
	synergy.progress:SetDimensions(RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].synergyDimension, RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].synergyDimension)
	synergy.progress:SetMinMax(0, 100)
	synergy.progress:SetValue(0)
	synergy.progress:SetColor(RdKGToolSO.soVars.progressColor.r, RdKGToolSO.soVars.progressColor.g, RdKGToolSO.soVars.progressColor.b, 1)
	
	return synergy
end

function RdKGToolSO.AdjustSynergyColors()
	for i = 1, #RdKGToolSO.controls.TLW.fullTableControl.rows do
		for j = 1, #RdKGToolSO.controls.TLW.fullTableControl.rows[i].synergies do
			local synergy = RdKGToolSO.controls.TLW.fullTableControl.rows[i].synergies[j]
			synergy.backdrop:SetCenterColor(RdKGToolSO.soVars.synergyBackdropColor.r, RdKGToolSO.soVars.synergyBackdropColor.g, RdKGToolSO.soVars.synergyBackdropColor.b, RdKGToolSO.soVars.synergyBackdropColor.a)
			synergy.backdrop:SetEdgeColor(RdKGToolSO.soVars.synergyBackdropColor.r, RdKGToolSO.soVars.synergyBackdropColor.g, RdKGToolSO.soVars.synergyBackdropColor.b, 0)
			synergy.progress:SetColor(RdKGToolSO.soVars.progressColor.r, RdKGToolSO.soVars.progressColor.g, RdKGToolSO.soVars.progressColor.b, 1)
			RdKGToolSO.controls.TLW.fullTableControl.rows[i].label:SetColor(RdKGToolSO.soVars.textColor.r, RdKGToolSO.soVars.textColor.g, RdKGToolSO.soVars.textColor.b, 1)
		end
	end
	
	for j = 1, #RdKGToolSO.controls.TLW.reducedTableControl.entries do
		local entry = RdKGToolSO.controls.TLW.reducedTableControl.entries[j]
		entry.backdrop:SetCenterColor(RdKGToolSO.soVars.synergyBackdropColor.r, RdKGToolSO.soVars.synergyBackdropColor.g, RdKGToolSO.soVars.synergyBackdropColor.b, RdKGToolSO.soVars.synergyBackdropColor.a)
		entry.backdrop:SetEdgeColor(RdKGToolSO.soVars.synergyBackdropColor.r, RdKGToolSO.soVars.synergyBackdropColor.g, RdKGToolSO.soVars.synergyBackdropColor.b, 0)
		entry.progress:SetColor(RdKGToolSO.soVars.progressColor.r, RdKGToolSO.soVars.progressColor.g, RdKGToolSO.soVars.progressColor.b, 1)
		entry.name:SetColor(RdKGToolSO.soVars.textColor.r, RdKGToolSO.soVars.textColor.g, RdKGToolSO.soVars.textColor.b, 1)
	end

end

function RdKGToolSO.SetEnabled(enabled, windowEnabled)
	if RdKGToolSO.state.initialized == true and enabled ~= nil then
		RdKGToolSO.soVars.enabled = enabled
		RdKGToolSO.soVars.windowEnabled = windowEnabled
		if enabled == true then
			if RdKGToolSO.state.registredConsumers == false then
				EVENT_MANAGER:RegisterForEvent(RdKGToolSO.callbackName, EVENT_PLAYER_ACTIVATED, RdKGToolSO.OnPlayerActivated)
			end
			RdKGToolSO.state.registredConsumers = true
		else
			if RdKGToolSO.state.registredConsumers == true then
				EVENT_MANAGER:UnregisterForEvent(RdKGToolSO.callbackName, EVENT_PLAYER_ACTIVATED)
			end
			RdKGToolSO.state.registredConsumers = false
			RdKGToolSO.SetControlVisibility()
		end
		RdKGToolSO.OnPlayerActivated()
	end
end

function RdKGToolSO.GetDefaults()
	local defaults = {}
	defaults.enabled = true
	defaults.windowEnabled = false
	defaults.positionLocked = true
	defaults.pvpOnly = true
	defaults.tableMode = RdKGToolSO.constants.MODES.TABLE_FULL
	defaults.synergyBackdropColor = {}
	defaults.synergyBackdropColor.r = 0.25
	defaults.synergyBackdropColor.g = 0.25
	defaults.synergyBackdropColor.b = 0.25
	defaults.synergyBackdropColor.a = 0.4
	defaults.progressColor = {}
	defaults.progressColor.r = 1.0
	defaults.progressColor.g = 0.0
	defaults.progressColor.b = 0.0
	defaults.synergyColor = {}
	defaults.synergyColor.r = 0.1
	defaults.synergyColor.g = 1.0
	defaults.synergyColor.b = 0.1
	defaults.backgroundColor = {}
	defaults.backgroundColor.r = 0.8
	defaults.backgroundColor.g = 0.8
	defaults.backgroundColor.b = 0.8
	defaults.textColor = {}
	defaults.textColor.r = 1.0
	defaults.textColor.g = 1.0
	defaults.textColor.b = 1.0
	defaults.spacing = 0
	defaults.displayMode = RdKGToolSO.constants.DISPLAYMODE_ALL
	defaults.synergyVisibility = {}
	defaults.synergyVisibility[RdKGToolSO.constants.SYNERGY_ID.COMBUSTION_SHARD] = true
	defaults.synergyVisibility[RdKGToolSO.constants.SYNERGY_ID.TALONS] = true
	defaults.synergyVisibility[RdKGToolSO.constants.SYNERGY_ID.NOVA] = true
	defaults.synergyVisibility[RdKGToolSO.constants.SYNERGY_ID.BLOOD_ALTAR] = true
	defaults.synergyVisibility[RdKGToolSO.constants.SYNERGY_ID.STANDARD] = true
	defaults.synergyVisibility[RdKGToolSO.constants.SYNERGY_ID.PURGE] = false
	defaults.synergyVisibility[RdKGToolSO.constants.SYNERGY_ID.BONE_SHIELD] = false
	defaults.synergyVisibility[RdKGToolSO.constants.SYNERGY_ID.FLOOD_CONDUIT] = false
	defaults.synergyVisibility[RdKGToolSO.constants.SYNERGY_ID.ATRONACH] = false
	defaults.synergyVisibility[RdKGToolSO.constants.SYNERGY_ID.TRAPPING_WEBS] = false
	defaults.synergyVisibility[RdKGToolSO.constants.SYNERGY_ID.RADIATE] = false
	defaults.synergyVisibility[RdKGToolSO.constants.SYNERGY_ID.CONSUMING_DARKNESS] = false
	defaults.synergyVisibility[RdKGToolSO.constants.SYNERGY_ID.SOUL_LEECH] = false
	defaults.synergyVisibility[RdKGToolSO.constants.SYNERGY_ID.WARDEN_HEALING] = false
	defaults.synergyVisibility[RdKGToolSO.constants.SYNERGY_ID.GRAVE_ROBBER] = true
	defaults.synergyVisibility[RdKGToolSO.constants.SYNERGY_ID.PURE_AGONY] = true
	defaults.synergyVisibility[RdKGToolSO.constants.SYNERGY_ID.ICY_ESCAPE] = false
	defaults.synergyVisibility[RdKGToolSO.constants.SYNERGY_ID.SANGUINE_BURST] = false
	defaults.synergyVisibility[RdKGToolSO.constants.SYNERGY_ID.HEED_THE_CALL] = false
	defaults.synergyVisibility[RdKGToolSO.constants.SYNERGY_ID.URSUS] = false
	defaults.synergyVisibility[RdKGToolSO.constants.SYNERGY_ID.GRYPHON] = false
	defaults.synergyVisibility[RdKGToolSO.constants.SYNERGY_ID.RUNEBREAK] = false
	defaults.synergyVisibility[RdKGToolSO.constants.SYNERGY_ID.PASSAGE] = false
	defaults.synergyVisibility[RdKGToolSO.constants.SYNERGY_ID.RECOVERY] = false
	defaults.size = RdKGToolSO.constants.size.SMALL
	return defaults
end

function RdKGToolSO.SetPositionLocked(value)
	RdKGToolSO.soVars.positionLocked = value
	
	RdKGToolSO.controls.TLW:SetMovable(not value)
	RdKGToolSO.controls.TLW:SetMouseEnabled(not value)
	if value == true then
		RdKGToolSO.controls.TLW.fullTableControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.0)
		RdKGToolSO.controls.TLW.fullTableControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
		RdKGToolSO.controls.TLW.reducedTableControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.0)
		RdKGToolSO.controls.TLW.reducedTableControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
	else
		RdKGToolSO.controls.TLW.fullTableControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.5)
		RdKGToolSO.controls.TLW.fullTableControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
		RdKGToolSO.controls.TLW.reducedTableControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.5)
		RdKGToolSO.controls.TLW.reducedTableControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
	end
end

function RdKGToolSO.SetControlVisibility()
	local enabled = RdKGToolSO.soVars.enabled and RdKGToolSO.soVars.windowEnabled
	local setHidden = true
	if enabled ~= nil and enabled == true and (RdKGToolSO.soVars.pvpOnly == false or (RdKGToolSO.soVars.pvpOnly == true and RdKGToolUtil.IsInPvPArea() == true)) then
		setHidden = false
	end
	if setHidden == false then
		if RdKGToolSO.state.foreground == false then
			RdKGToolSO.controls.TLW:SetHidden(RdKGToolSO.state.activeLayerIndex > 2)
		else
			RdKGToolSO.controls.TLW:SetHidden(false)
		end
	else
		RdKGToolSO.controls.TLW:SetHidden(setHidden)
	end
	if RdKGToolSO.soVars.tableMode == RdKGToolSO.constants.MODES.TABLE_FULL then
		RdKGToolSO.controls.TLW.fullTableControl:SetHidden(false)
		RdKGToolSO.controls.TLW.reducedTableControl:SetHidden(true)
		
		local sizeIncrease = RdKGToolSO.soVars.size - RdKGToolSO.constants.size.SMALL
		local width = RdKGToolSO.state.fullWidth
		local height = (RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].height + (RdKGToolSO.config.full[RdKGToolSO.constants.size.BIG].height - RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].height) * sizeIncrease)
		RdKGToolSO.controls.TLW:SetDimensions(width, height)
	elseif RdKGToolSO.soVars.tableMode == RdKGToolSO.constants.MODES.TABLE_REDUCED then
		RdKGToolSO.controls.TLW.fullTableControl:SetHidden(true)
		RdKGToolSO.controls.TLW.reducedTableControl:SetHidden(false)
		
		local sizeIncrease = RdKGToolSO.soVars.size - RdKGToolSO.constants.size.SMALL
		local width = RdKGToolSO.state.reducedWidth
		local height = (RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].height + (RdKGToolSO.config.reduced[RdKGToolSO.constants.size.BIG].height - RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].height) * sizeIncrease)
		RdKGToolSO.controls.TLW:SetDimensions(width, height)
	end
	--d(setHidden)
end

function RdKGToolSO.RegisterForCombatEvent(id, suffix)
	if id ~= nil then
		local data = RdKGToolSO.state.SYNERGIES[id]
		if data ~= nil then
			local callbackName = data.callbackName
			if suffix ~= nil then
				callbackName = callbackName .. suffix
			end
			EVENT_MANAGER:RegisterForEvent(callbackName, EVENT_COMBAT_EVENT, RdKGToolSO.OnCombatEvent)
			EVENT_MANAGER:AddFilterForEvent(callbackName, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, id)
		end
	end
end

function RdKGToolSO.UnregisterForCombatEvent(id, suffix)
	if id ~= nil then
		local data = RdKGToolSO.state.SYNERGIES[id]
		if data ~= nil then
			local callbackName = data.callbackName
			if suffix ~= nil then
				callbackName = callbackName .. suffix
			end
			EVENT_MANAGER:UnregisterForEvent(callbackName, EVENT_COMBAT_EVENT)
		end
	end
end

function RdKGToolSO.AdjustSynergyDisplay()
	--fullTableControl
	local fullTableControl = RdKGToolSO.controls.TLW.fullTableControl
	local header = fullTableControl.header
	local rows = fullTableControl.rows
	
	local sizeIncrease = RdKGToolSO.soVars.size - RdKGToolSO.constants.size.SMALL
	local synergyDimension = (RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].synergyDimension + (RdKGToolSO.config.full[RdKGToolSO.constants.size.BIG].synergyDimension - RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].synergyDimension) * sizeIncrease)
	local labelWidth = (RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].labelWidth + (RdKGToolSO.config.full[RdKGToolSO.constants.size.BIG].labelWidth - RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].labelWidth) * sizeIncrease)
	local spacing = (RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].spacing + (RdKGToolSO.config.full[RdKGToolSO.constants.size.BIG].spacing - RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].spacing) * sizeIncrease)
	local rowHeight = (RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].rowHeight + (RdKGToolSO.config.full[RdKGToolSO.constants.size.BIG].rowHeight - RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].rowHeight) * sizeIncrease)
	--local width = (RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].width + (RdKGToolSO.config.full[RdKGToolSO.constants.size.BIG].width - RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].width) * sizeIncrease)
	local height = (RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].height + (RdKGToolSO.config.full[RdKGToolSO.constants.size.BIG].height - RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].height) * sizeIncrease)
	
	for i = 1, #rows do
		local visibleIndex = 1
		for j = 1, #rows[i].synergies do
			local synergy = rows[i].synergies[j]
			if RdKGToolSO.soVars.synergyVisibility[j] == true then
				synergy:SetHidden(false)
				synergy:ClearAnchors()
				local positionX = labelWidth + ((visibleIndex - 1) * synergyDimension) + ((visibleIndex - 1) * spacing)
				synergy:SetAnchor(TOPLEFT, rows[i], TOPLEFT, positionX, spacing / 2)
				
				visibleIndex = visibleIndex + 1
			else
				synergy:SetHidden(true)
			end
		end
		rows[i].backdrop:SetDimensions(labelWidth + ((visibleIndex - 1) * synergyDimension) + ((visibleIndex - 1) * spacing), rowHeight)
	end
	local visibleIndex = 1
	for i = 1, #header.synergies do
		local synergy = header.synergies[i]
		if RdKGToolSO.soVars.synergyVisibility[i] == true then
			synergy:SetHidden(false)
			synergy:ClearAnchors()
			local positionX = labelWidth + ((visibleIndex - 1) * synergyDimension) + ((visibleIndex - 1) * spacing)
			synergy:SetAnchor(TOPLEFT, header, TOPLEFT, positionX, spacing / 2)
				
			visibleIndex = visibleIndex + 1
		else
			synergy:SetHidden(true)
		end
		RdKGToolSO.state.fullWidth = labelWidth + ((visibleIndex - 1) * synergyDimension) + ((visibleIndex - 1) * spacing)
	end
	fullTableControl.movableBackdrop:SetDimensions(RdKGToolSO.state.fullWidth, height)
	--reducedTableControl
	local reducedTableControl = RdKGToolSO.controls.TLW.reducedTableControl
	synergyDimension = (RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].synergyDimension + (RdKGToolSO.config.reduced[RdKGToolSO.constants.size.BIG].synergyDimension - RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].synergyDimension) * sizeIncrease)
	--width = (RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].width + (RdKGToolSO.config.reduced[RdKGToolSO.constants.size.BIG].width - RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].width) * sizeIncrease)
	height = (RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].height + (RdKGToolSO.config.reduced[RdKGToolSO.constants.size.BIG].height - RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].height) * sizeIncrease)
	
	
	header = reducedTableControl.header
	visibleIndex = 1
	for i = 1, #header.synergies do
		local synergy = header.synergies[i]
		if RdKGToolSO.soVars.synergyVisibility[i] == true then
			synergy:SetHidden(false)
			synergy:ClearAnchors()
			local positionX = (visibleIndex - 1) * synergyDimension + (visibleIndex - 1) * RdKGToolSO.soVars.spacing
			synergy:SetAnchor(TOPLEFT, header, TOPLEFT, positionX, 0)
				
			visibleIndex = visibleIndex + 1
		else
			synergy:SetHidden(true)
		end
		RdKGToolSO.state.reducedWidth = (visibleIndex - 1) * synergyDimension + (visibleIndex - 1) * RdKGToolSO.soVars.spacing
	end
	reducedTableControl.movableBackdrop:SetDimensions(RdKGToolSO.state.reducedWidth, height)
	RdKGToolSO.SetControlVisibility()
end

function RdKGToolSO.GetSynergyIdForAbilityId(abilityId)
	local synergyId = 0
	if RdKGToolSO.state.SYNERGIES[abilityId] ~= nil then
		synergyId = RdKGToolSO.state.SYNERGIES[abilityId].id
	end
	return synergyId
end

function RdKGToolSO.SortNumbers(value1, value2) 
	return value1 > value2
end

function RdKGToolSO.SortSynergyList(playerA, playerB)
	local index = RdKGToolSO.state.tempSortIndex --to prevent a closure performance impact
	if playerA.synergies == nil and playerB.synergies == nil then
		return true
	elseif playerA.synergies ~= nil and playerB.synergies == nil then
		return true
	elseif playerA.synergies == nil and playerB.synergies ~= nil then
		return false
	elseif playerA.synergies[index] == nil and playerB.synergies[index] == nil then
		return true
	elseif playerA.synergies[index] ~= nil and playerB.synergies[index] == nil then
		return true
	elseif playerA.synergies[index] == nil and playerB.synergies[index] ~= nil then
		return false
	end
	if playerA.synergies[index] > playerB.synergies[index] then
		return true
	else
		return false
	end
end

function RdKGToolSO.CreateSortedSynergyList(players)
	local synergyList = {}
	local synergyHeaders = RdKGToolSO.controls.TLW.reducedTableControl.header.synergies
	for i = 1, #synergyHeaders do
		if synergyHeaders[i]:IsHidden() == false then
			synergyList[i] = {}
			for j = 1, #players do
				if players[j].synergies[i] ~= nil and (RdKGToolSO.soVars.displayMode == RdKGToolSO.constants.DISPLAYMODE_ALL or (RdKGToolSO.soVars.displayMode == RdKGToolSO.constants.DISPLAYMODE_SYNERGY and players[j].role == RdKGToolUtilGroup.constants.roles.ROLE_SYNERGY)) then
					--d("adding synergy")
					table.insert(synergyList[i], players[j])
				end
			end
			RdKGToolSO.state.tempSortIndex = i
			--d("sorting synergies")
			table.sort(synergyList[i], RdKGToolSO.SortSynergyList)
		end
	end
	return synergyList
end

function RdKGToolSO.AdjustSize()
	local sizeIncrease = RdKGToolSO.soVars.size - RdKGToolSO.constants.size.SMALL
	local synergyDimension = (RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].synergyDimension + (RdKGToolSO.config.full[RdKGToolSO.constants.size.BIG].synergyDimension - RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].synergyDimension) * sizeIncrease)
	local labelWidth = (RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].labelWidth + (RdKGToolSO.config.full[RdKGToolSO.constants.size.BIG].labelWidth - RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].labelWidth) * sizeIncrease)
	local spacing = (RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].spacing + (RdKGToolSO.config.full[RdKGToolSO.constants.size.BIG].spacing - RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].spacing) * sizeIncrease)
	local rowHeight = (RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].rowHeight + (RdKGToolSO.config.full[RdKGToolSO.constants.size.BIG].rowHeight - RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].rowHeight) * sizeIncrease)
	local fontSize = (RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].fontSize + (RdKGToolSO.config.full[RdKGToolSO.constants.size.BIG].fontSize - RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].fontSize) * sizeIncrease)
	local width = RdKGToolSO.state.fullWidth
	local height = (RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].height + (RdKGToolSO.config.full[RdKGToolSO.constants.size.BIG].height - RdKGToolSO.config.full[RdKGToolSO.constants.size.SMALL].height) * sizeIncrease)
	
	RdKGToolSO.state.controlFont = RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.CHAT_FONT, RdKGToolFonts.constants.INPUT_KB, fontSize, RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THIN)
	--full
	local fullTableControl = RdKGToolSO.controls.TLW.fullTableControl
	
	fullTableControl:SetDimensions(width, height)
	fullTableControl.movableBackdrop:SetDimensions(width, height)

	fullTableControl.header:SetDimensions(width, rowHeight)
	for i = 1, #RdKGToolSO.state.SYNERGY_DATA do
		local positionX = labelWidth + ((i - 1) * synergyDimension) + ((i - 1) * spacing)
		fullTableControl.header.synergies[i]:ClearAnchors()
		fullTableControl.header.synergies[i]:SetAnchor(TOPLEFT, fullTableControl.header, TOPLEFT, positionX, spacing)
		fullTableControl.header.synergies[i]:SetDimensions(synergyDimension, synergyDimension)
	end


	for i = 1, 24 do
		fullTableControl.rows[i]:SetDimensions(width, rowHeight)
		fullTableControl.rows[i]:ClearAnchors()
		fullTableControl.rows[i]:SetAnchor(TOPLEFT, fullTableControl, TOPLEFT, 0, i * rowHeight)
		
		fullTableControl.rows[i].backdrop:SetDimensions(width, rowHeight)
		fullTableControl.rows[i].label:SetDimensions(labelWidth, rowHeight)
		fullTableControl.rows[i].label:SetFont(RdKGToolSO.state.controlFont)
		
		for j = 1, #RdKGToolSO.state.SYNERGY_DATA do
			local positionX = labelWidth + ((j - 1) * synergyDimension) + ((j - 1) * spacing)
			fullTableControl.rows[i].synergies[j]:ClearAnchors()
			fullTableControl.rows[i].synergies[j]:SetAnchor(TOPLEFT, control, TOPLEFT, positionX, spacing / 2)
			fullTableControl.rows[i].synergies[j]:SetDimensions(synergyDimension, synergyDimension)
			fullTableControl.rows[i].synergies[j].backdrop:SetDimensions(synergyDimension, synergyDimension)
			fullTableControl.rows[i].synergies[j].progress:SetDimensions(synergyDimension, synergyDimension)
		end
	end
	
	--reduced
	local reducedTableControl = RdKGToolSO.controls.TLW.reducedTableControl
	width = RdKGToolSO.state.reducedWidth
	height = (RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].height + (RdKGToolSO.config.reduced[RdKGToolSO.constants.size.BIG].height - RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].height) * sizeIncrease)
	synergyDimension = (RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].synergyDimension + (RdKGToolSO.config.reduced[RdKGToolSO.constants.size.BIG].synergyDimension - RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].synergyDimension) * sizeIncrease)
	local entryHeight = (RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].entryHeight + (RdKGToolSO.config.reduced[RdKGToolSO.constants.size.BIG].entryHeight - RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].entryHeight) * sizeIncrease)
	fontSize = (RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].fontSize + (RdKGToolSO.config.reduced[RdKGToolSO.constants.size.BIG].fontSize - RdKGToolSO.config.reduced[RdKGToolSO.constants.size.SMALL].fontSize) * sizeIncrease)
	
	RdKGToolSO.state.reducedSynergyDimension = synergyDimension
	RdKGToolSO.state.reducedEntryHeight = entryHeight
	
	reducedTableControl:SetDimensions(width, height)
	
	reducedTableControl.movableBackdrop:SetDimensions(width, height)
		
	reducedTableControl.header:SetDimensions(width, synergyDimension)
	
	for i = 1, #RdKGToolSO.state.SYNERGY_DATA do
		local positionX = ((i - 1) * synergyDimension) + (i - 1) * RdKGToolSO.soVars.spacing
		--d(positionX)
		reducedTableControl.header.synergies[i]:ClearAnchors()
		reducedTableControl.header.synergies[i]:SetAnchor(TOPLEFT, reducedTableControl.header, TOPLEFT, positionX, 0)
		reducedTableControl.header.synergies[i]:SetDimensions(synergyDimension, synergyDimension)
		reducedTableControl.header.synergies[i].texture:ClearAnchors()
		reducedTableControl.header.synergies[i].texture:SetAnchor(TOPLEFT, reducedTableControl.header.synergies[i], TOPLEFT, 0, 0)
		reducedTableControl.header.synergies[i].texture:SetDimensions(synergyDimension, synergyDimension)
		reducedTableControl.header.synergies[i].border:ClearAnchors()
		reducedTableControl.header.synergies[i].border:SetAnchor(TOPLEFT, reducedTableControl.header.synergies[i], TOPLEFT, 0, 0)
		reducedTableControl.header.synergies[i].border:SetDimensions(synergyDimension, synergyDimension)
	end
	
	local font = RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.CHAT_FONT, RdKGToolFonts.constants.INPUT_KB, fontSize, RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THIN)
	for i = 1, #reducedTableControl.entries do
		reducedTableControl.entries[i]:SetDimensions(synergyDimension + RdKGToolSO.soVars.spacing, entryHeight)
		
		reducedTableControl.entries[i].backdrop:ClearAnchors()
		reducedTableControl.entries[i].backdrop:SetAnchor(TOPLEFT, reducedTableControl.entries[i], TOPLEFT, 0, 0)
		reducedTableControl.entries[i].backdrop:SetDimensions(synergyDimension + RdKGToolSO.soVars.spacing, entryHeight)
		
		reducedTableControl.entries[i].progress:ClearAnchors()
		reducedTableControl.entries[i].progress:SetAnchor(TOPLEFT, reducedTableControl.entries[i], TOPLEFT, 1, 1)
		reducedTableControl.entries[i].progress:SetDimensions(synergyDimension - 2 + RdKGToolSO.soVars.spacing, entryHeight - 2)
		
		reducedTableControl.entries[i].name:SetFont(font)
		reducedTableControl.entries[i].name:SetDimensions(synergyDimension - 8 + RdKGToolSO.soVars.spacing, entryHeight - 4)
		reducedTableControl.entries[i].name:ClearAnchors()
		reducedTableControl.entries[i].name:SetAnchor(TOPLEFT, reducedTableControl.entries[i], TOPLEFT, 4, 2)
		
		reducedTableControl.entries[i].edge:ClearAnchors()
		reducedTableControl.entries[i].edge:SetAnchor(TOPLEFT, reducedTableControl.entries[i], TOPLEFT, 0, 0)
		reducedTableControl.entries[i].edge:SetDimensions(synergyDimension + RdKGToolSO.soVars.spacing, entryHeight)
		
	end
	RdKGToolSO.AdjustSynergyDisplay()
end

function RdKGToolSO.GetPlayerDebuffs()
	return RdKGToolDbo.GetPlayerDebuffs()
end

--callbacks
function RdKGToolSO.OnProfileChanged(currentProfile)
	if currentProfile ~= nil then
		RdKGToolSO.soVars = currentProfile.toolbox.so
		if RdKGToolSO.state.initialized == true then
			RdKGToolSO.SetEnabled(RdKGToolSO.soVars.enabled, RdKGToolSO.soVars.windowEnabled)
			RdKGToolSO.SetPositionLocked(RdKGToolSO.soVars.positionLocked)
			RdKGToolSO.SetControlVisibility()
			RdKGToolSO.SetTlwLocation()
			RdKGToolSO.AdjustSynergyColors()
			RdKGToolSO.AdjustSize()
		end
	end
end

function RdKGToolSO.OnPlayerActivated(eventCode, initial)
	if RdKGToolSO.soVars.enabled == true and (RdKGToolSO.soVars.pvpOnly == false or (RdKGToolSO.soVars.pvpOnly == true and RdKGToolUtil.IsInPvPArea() == true)) then
		if RdKGToolSO.state.registredActiveConsumers == false then
			EVENT_MANAGER:RegisterForEvent(RdKGToolSO.callbackName, EVENT_ACTION_LAYER_POPPED, RdKGToolSO.SetForegroundVisibility)
			EVENT_MANAGER:RegisterForEvent(RdKGToolSO.callbackName, EVENT_ACTION_LAYER_PUSHED, RdKGToolSO.SetForegroundVisibility)
		
			RdKGToolSO.RegisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.BLOOD_ALTAR, "1")
			RdKGToolSO.RegisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.OVERFLOWING_ALTAR, "2")
			RdKGToolSO.RegisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.TRAPPING_WEBS, "1")
			RdKGToolSO.RegisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.SHADOW_SILK, "2")
			RdKGToolSO.RegisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.TANGLING_WEBS, "3")
			RdKGToolSO.RegisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.INNER_FIRE, "1")
			RdKGToolSO.RegisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.INNER_BEAST, "2")
			RdKGToolSO.RegisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.BONE_SHIELD, "1")
			RdKGToolSO.RegisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.BONE_SURGE, "2")
			RdKGToolSO.RegisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.NECROTIC_ORB, "1")
			RdKGToolSO.RegisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.ENERGY_ORB, "2")
			RdKGToolSO.RegisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.LUMINOUS_SHARDS, "3")
			RdKGToolSO.RegisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.SPEAR_SHARDS, "4")
			RdKGToolSO.RegisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.LIGHTNING_SPLASH, nil)
			RdKGToolSO.RegisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.HEALING_SEED, nil)
			RdKGToolSO.RegisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.EXTENDED_RITUAL, nil)
			RdKGToolSO.RegisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.SUMMON_STORM_ATRONACH, "1")
			RdKGToolSO.RegisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.SUMMON_ATRONACH, "2")
			RdKGToolSO.RegisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.STANDARD, nil)
			RdKGToolSO.RegisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.TALONS, nil)
			RdKGToolSO.RegisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.NOVA, "1")
			RdKGToolSO.RegisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.SUPER_NOVA, "2")
			RdKGToolSO.RegisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.CONSUMING_DARKNESS, nil)
			RdKGToolSO.RegisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.SOUL_SHRED, nil)
			RdKGToolSO.RegisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.GRAVE_ROBBER, nil)
			RdKGToolSO.RegisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.PURE_AGONY, nil)
			RdKGToolSO.RegisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.ICY_ESCAPE, nil)
			RdKGToolSO.RegisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.SANGUINE_BURST, nil)
			RdKGToolSO.RegisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.HEED_THE_CALL, nil)
			RdKGToolSO.RegisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.URSUS, nil)
			RdKGToolSO.RegisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.GRYPHON, nil)
			RdKGToolSO.RegisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.RUNEBREAK, nil)
			RdKGToolSO.RegisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.PASSAGE, nil)
			RdKGToolSO.RegisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.RECOVERY, nil)
			
			RdKGToolUtilGroup.AddFeature(RdKGToolSO.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_SYNERGY, RdKGToolSO.config.updateInterval)
			RdKGToolUtilGroup.AddFeature(RdKGToolSO.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_BUFFS, RdKGToolSO.config.buffUpdateInterval)
			--RdKGToolUtilGroup.AddFeature(RdKGToolSO.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_DEAD_STATE, RdKGToolSO.config.updateInterval)
			
			EVENT_MANAGER:RegisterForUpdate(RdKGToolSO.callbackName, RdKGToolSO.config.updateInterval, RdKGToolSO.UiLoop)
			EVENT_MANAGER:RegisterForUpdate(RdKGToolSO.messageLoopCallbackName, RdKGToolSO.config.messageUpdateInterval, RdKGToolSO.MessageLoop)
			
			RdKGToolSO.state.registredActiveConsumers = true
		end
	else
		if RdKGToolSO.state.registredActiveConsumers == true then
			EVENT_MANAGER:UnregisterForEvent(RdKGToolSO.callbackName, EVENT_ACTION_LAYER_POPPED)
			EVENT_MANAGER:UnregisterForEvent(RdKGToolSO.callbackName, EVENT_ACTION_LAYER_PUSHED)
			
			RdKGToolSO.UnregisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.BLOOD_ALTAR, "1")
			RdKGToolSO.UnregisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.OVERFLOWING_ALTAR, "2")
			RdKGToolSO.UnregisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.TRAPPING_WEBS, "1")
			RdKGToolSO.UnregisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.SHADOW_SILK, "2")
			RdKGToolSO.UnregisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.TANGLING_WEBS, "3")
			RdKGToolSO.UnregisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.INNER_FIRE, "1")
			RdKGToolSO.UnregisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.INNER_BEAST, "2")
			RdKGToolSO.UnregisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.BONE_SHIELD, "1")
			RdKGToolSO.UnregisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.BONE_SURGE, "2")
			RdKGToolSO.UnregisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.NECROTIC_ORB, "1")
			RdKGToolSO.UnregisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.ENERGY_ORB, "2")
			RdKGToolSO.UnregisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.LUMINOUS_SHARDS, "3")
			RdKGToolSO.UnregisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.SPEAR_SHARDS, "4")
			RdKGToolSO.UnregisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.LIGHTNING_SPLASH, nil)
			RdKGToolSO.UnregisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.HEALING_SEED, nil)
			RdKGToolSO.UnregisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.EXTENDED_RITUAL, nil)
			RdKGToolSO.UnregisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.SUMMON_STORM_ATRONACH, "1")
			RdKGToolSO.UnregisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.SUMMON_ATRONACH, "2")
			RdKGToolSO.UnregisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.STANDARD, nil)
			RdKGToolSO.UnregisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.TALONS, nil)
			RdKGToolSO.UnregisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.NOVA, "1")
			RdKGToolSO.UnregisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.SUPER_NOVA, "2")
			RdKGToolSO.UnregisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.CONSUMING_DARKNESS, nil)
			RdKGToolSO.UnregisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.SOUL_SHRED, nil)
			RdKGToolSO.UnregisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.GRAVE_ROBBER, nil)
			RdKGToolSO.UnregisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.PURE_AGONY, nil)
			RdKGToolSO.UnregisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.ICY_ESCAPE, nil)
			RdKGToolSO.UnregisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.SANGUINE_BURST, nil)
			RdKGToolSO.UnregisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.HEED_THE_CALL, nil)
			RdKGToolSO.UnregisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.URSUS, nil)
			RdKGToolSO.UnregisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.GRYPHON, nil)
			RdKGToolSO.UnregisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.RUNEBREAK, nil)
			RdKGToolSO.UnregisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.PASSAGE, nil)
			RdKGToolSO.UnregisterForCombatEvent(RdKGToolSO.constants.SYNERGY_ABLITY_ID.RECOVERY, nil)
			
			RdKGToolUtilGroup.RemoveFeature(RdKGToolSO.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_SYNERGY)
			RdKGToolUtilGroup.RemoveFeature(RdKGToolSO.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_BUFFS)
			--RdKGToolUtilGroup.RemoveFeature(RdKGToolSO.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_DEAD_STATE)
			
			EVENT_MANAGER:UnregisterForUpdate(RdKGToolSO.callbackName)
			EVENT_MANAGER:UnregisterForUpdate(RdKGToolSO.messageLoopCallbackName)
			
			RdKGToolSO.state.registredActiveConsumers = false
		end
	end
	RdKGToolSO.SetControlVisibility()
end

--/script EVENT_MANAGER:RegisterForEvent("test",EVENT_COMBAT_EVENT, function(_, _, _, an,_,_,sn,_,tn,_,_,_,_,_,si,ti,ai) d("---") d(an) d(ai) d(si)d(ti)d(sn)d(tn) end)
--/script EVENT_MANAGER:RegisterForEvent("test",EVENT_COMBAT_EVENT, function(_, _, _, an,_,_,sn,_,tn,_,_,_,_,_,si,ti,ai) d("---") d(an) d(ai) d(sn)d(tn) end)
--/script EVENT_MANAGER:RegisterForEvent("test",EVENT_COMBAT_EVENT, function(_, _, _, an,_,_,sn,_,tn,_,_,_,_,_,si,ti,ai) d("---") if sn == "Cartraf^Mx" or tn == "Cartraf^Mx" then d(an) d(ai) d(sn)d(tn) end end)
--/script EVENT_MANAGER:RegisterForEvent("test",EVENT_COMBAT_EVENT, function(_, _, _, an, gr,_,sn,_,tn,_,_,_,_,_,si,ti,ai) d("---") if sn == "Flying Locus^Mx" or tn == "Flying Locus^Mx" then d(an) d(ai) d(sn)d(tn) d(gr) end end)
--/script EVENT_MANAGER:RegisterForEvent("test",EVENT_COMBAT_EVENT, function(_, _, _, an, gr,_,sn,_,tn,_,_,_,_,_,si,ti,ai) d("---") if sn == "Flying Locus^Mx" or tn == "Mulinor^Mx" then d(an) d(ai) d(sn)d(tn) d(gr) end end)
function RdKGToolSO.OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, isLog, sourceUnitId, targetUnitId, abilityId) 
	--[[
	d("---New Data: " .. GetGameTimeMilliseconds() .. "---")
	d("Source: " .. sourceName)
	d("Source Unit ID: " .. sourceUnitId)
	d("Target: " .. targetName) -- raw name
	d("Target Unit ID: " .. targetUnitId)
	d("Ability Name: " .. abilityName)
	d("Ability ID: " .. abilityId)
	]]
	--[[
	local message = {}
				message.b0 = RdKGToolNetworking.messageTypes.MESSAGE_ID_HP
				message.b1, message.b2, message.b3 = RdKGToolNetworking.EncodeInt24(RdKGToolHdm.state.meter.healing)
				RdKGToolHdm.state.meter.healing = 0
				message.sent = false
				RdKGToolNetworking.SendMessage(message, RdKGToolNetworking.constants.priorities.MEDIUM)
				RdKGToolHdm.state.meter.lastHpMessage = message
	]]
	--d("---")
	--d(abilityId)
	--d(result)
	if result == ACTION_RESULT_EFFECT_GAINED  and targetName == GetRawUnitName("player") then
		local timeStamp = GetGameTimeMilliseconds()
		--if RdKGToolSO.state.lastSynergy + RdKGToolSO.config.minCooldownMs < timeStamp then
			
			RdKGToolSO.state.lastSynergy = timeStamp
			local synergyId = RdKGToolSO.GetSynergyIdForAbilityId(abilityId)
			--d(abilityId)
			if synergyId ~= 0 then
				local message = {}
				message.b0 = RdKGToolNetworking.messageTypes.MESSAGE_ID_SYNERGY
				message.b1 = synergyId
				message.b2 = 0
				local debuffs = RdKGToolSO.GetPlayerDebuffs()
				if debuffs > 7 then
					debuffs = 7
				end
				message.b3 = debuffs
				message.timeStamp = timeStamp
				message.sent = false
				RdKGToolNetworking.SendSynergyMessage(message, RdKGToolNetworking.constants.priorities.HIGH)
				table.insert(RdKGToolSO.state.lastMessages, message)
				RdKGToolChat.SendChatMessage("Synergy Message Sent: " .. message.b1 .. " - " .. message.b2, RdKGToolSO.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
			end
		--end
	end
	
end

function RdKGToolSO.MessageLoop()
	local messages = RdKGToolSO.state.lastMessages
	local removeMessages = {}
	for i = 1, #messages do
		local message = messages[i]
		if message.sent == true then
			table.insert(removeMessages, i)
		else
			message.b2 = tonumber(string.format("%d",(GetGameTimeMilliseconds() - message.timeStamp) / 100))
			local debuffs = RdKGToolSO.GetPlayerDebuffs()
			if debuffs > 7 then
				debuffs = 7
			end
			message.b3 = debuffs
		end
	end
	table.sort(removeMessages, RdKGToolSO.SortNumbers)
	for i = 1, #removeMessages do
		table.remove(messages, removeMessages[i])
	end
end

function RdKGToolSO.SetForegroundVisibility(eventCode, layerIndex, activeLayerIndex)
	if eventCode == EVENT_ACTION_LAYER_POPPED then
		RdKGToolSO.state.foreground = true
	elseif eventCode == EVENT_ACTION_LAYER_PUSHED then
		RdKGToolSO.state.foreground = false
	end
	--hack?
	RdKGToolSO.state.activeLayerIndex = activeLayerIndex
	
	RdKGToolSO.SetControlVisibility()
end

function RdKGToolSO.SaveWindowLocation()
	if RdKGToolSO.soVars.positionLocked == false then
		RdKGToolSO.soVars.location = RdKGToolSO.soVars.location or {}
		RdKGToolSO.soVars.location.x = RdKGToolSO.controls.TLW:GetLeft()
		RdKGToolSO.soVars.location.y = RdKGToolSO.controls.TLW:GetTop()
	end
end

function RdKGToolSO.UiLoop()
	local players = RdKGToolUtilGroup.GetGroupInformation()
	local timeStamp = GetGameTimeMilliseconds()
	if RdKGToolSO.soVars.tableMode == RdKGToolSO.constants.MODES.TABLE_FULL then
		--RdKGToolSO.constants.MODES.TABLE_FULL
		local rows = RdKGToolSO.controls.TLW.fullTableControl.rows
		if players ~= nil then
			local visibleIndex = 1
			for i = 1, #players do
				local player = players[i]
				local row = rows[visibleIndex]
				if RdKGToolSO.soVars.displayMode == RdKGToolSO.constants.DISPLAYMODE_ALL or (RdKGToolSO.soVars.displayMode == RdKGToolSO.constants.DISPLAYMODE_SYNERGY and players[i].role == RdKGToolUtilGroup.constants.roles.ROLE_SYNERGY) then
					row:SetHidden(false)
					row.label:SetText(player.name)
					local alpha = RdKGToolSO.config.backdropAlphaOdd
					if visibleIndex % 2 == 0 then
						alpha = RdKGToolSO.config.backdropAlphaEven
					end
					if player.role == RdKGToolUtilGroup.constants.roles.ROLE_SYNERGY then
						row.backdrop:SetCenterColor(RdKGToolSO.soVars.synergyColor.r, RdKGToolSO.soVars.synergyColor.g, RdKGToolSO.soVars.synergyColor.b, alpha)
						row.backdrop:SetEdgeColor(RdKGToolSO.soVars.synergyColor.r, RdKGToolSO.soVars.synergyColor.g, RdKGToolSO.soVars.synergyColor.b, 0)
					else
						row.backdrop:SetCenterColor(RdKGToolSO.soVars.backgroundColor.r, RdKGToolSO.soVars.backgroundColor.g, RdKGToolSO.soVars.backgroundColor.b, alpha)
						row.backdrop:SetEdgeColor(RdKGToolSO.soVars.backgroundColor.r, RdKGToolSO.soVars.backgroundColor.g, RdKGToolSO.soVars.backgroundColor.b, 0)
					end
					
					
					visibleIndex = visibleIndex + 1
					for j = 1, #row.synergies do
						local progress = 0
						if player.synergies[j] ~= nil then
							progress = (RdKGToolSO.state.SYNERGY_DATA[j].cooldown * 1000) - (timeStamp - player.synergies[j]) 
							if progress < 0 then
								progress = 0
								player.synergies[j] = nil
							end
							progress = progress / (RdKGToolSO.state.SYNERGY_DATA[j].cooldown * 1000) * 100
						end
						row.synergies[j].progress:SetValue(progress)
					end
					
				end

			end
			for i = visibleIndex, #rows do --prev 24
				rows[i]:SetHidden(true)
			end
		else
			for i = 1, #rows do
				rows[i]:SetHidden(true)
			end
		end
	elseif RdKGToolSO.soVars.tableMode == RdKGToolSO.constants.MODES.TABLE_REDUCED then
		--RdKGToolSO.constants.MODES.TABLE_REDUCED
		local reducedTableControl = RdKGToolSO.controls.TLW.reducedTableControl
		local entries = reducedTableControl.entries
		local synergyControls = reducedTableControl.header.synergies
		if players ~= nil then
			local visibleIndex = 1
			local currentControlWidthIndex = 0
			local synergies = RdKGToolSO.CreateSortedSynergyList(players)
			for i = 1, #synergyControls do
				if synergyControls[i]:IsHidden() == false then
					--d("loop 1")
					local currentControlHeightIndex = 0
					local synergyPlayerList = synergies[i]
					if synergyPlayerList ~= nil then
						--d("loop 2")
						for j = 1, #synergyPlayerList do
							local synergyControl = entries[visibleIndex] 
							if synergyControl == nil then
								synergyControl = RdKGToolSO.CreateReducedEntry(reducedTableControl)
								entries[visibleIndex] = synergyControl
							end
							synergyControl.name:SetText(synergyPlayerList[j].name)
							local progress = 0
							if synergyPlayerList[j].synergies[i] ~= nil then
								progress = (RdKGToolSO.state.SYNERGY_DATA[i].cooldown * 1000) - (timeStamp - synergyPlayerList[j].synergies[i]) 
								if progress < 0 then
									progress = 0
									synergyPlayerList[j].synergies[i] = nil
								end
								progress = progress / (RdKGToolSO.state.SYNERGY_DATA[i].cooldown * 1000) * 100
							end
							synergyControl.progress:SetValue(progress)
							
							synergyControl:ClearAnchors()
							synergyControl:SetAnchor(TOPLEFT, reducedTableControl, TOPLEFT, (currentControlWidthIndex) * RdKGToolSO.state.reducedSynergyDimension + (currentControlWidthIndex) * RdKGToolSO.soVars.spacing , RdKGToolSO.state.reducedSynergyDimension + (currentControlHeightIndex * RdKGToolSO.state.reducedEntryHeight) - (currentControlHeightIndex * 1))
							synergyControl:SetHidden(false)
							
							visibleIndex = visibleIndex + 1
							currentControlHeightIndex = currentControlHeightIndex + 1
							--d("synergy")
						end
					end
					currentControlWidthIndex = currentControlWidthIndex + 1
				end
				--local player = players[i]
				--local entry = entries[visibleIndex]
				--if RdKGToolSO.soVars.displayMode == RdKGToolSO.constants.DISPLAYMODE_ALL or (RdKGToolSO.soVars.displayMode == RdKGToolSO.constants.DISPLAYMODE_SYNERGY and players[i].role == RdKGToolUtilGroup.constants.roles.ROLE_SYNERGY) then
					
				--end
			end
			for i = visibleIndex, #entries do
				entries[i]:SetHidden(true)
			end 
		else
			for i = 1, #entries do
				entries[i]:SetHidden(true)
			end
		end
	end
end

--menu interaction
function RdKGToolSO.GetMenu()
	local menu = {
		[1] = {
			type = "submenu",
			name = RdKGToolMenu.constants.SO_HEADER,
			controls = {
				[1] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SO_ENABLED,
					getFunc = RdKGToolSO.GetSoEnabled,
					setFunc = RdKGToolSO.SetSoEnabled
				},
				[2] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SO_WINDOW_ENABLED,
					getFunc = RdKGToolSO.GetSoWindowEnabled,
					setFunc = RdKGToolSO.SetSoWindowEnabled
				},
				[3] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SO_PVP_ONLY,
					getFunc = RdKGToolSO.GetSoPvpOnly,
					setFunc = RdKGToolSO.SetSoPvpOnly
				},
				[4] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SO_POSITION_FIXED,
					getFunc = RdKGToolSO.GetSoPositionLocked,
					setFunc = RdKGToolSO.SetSoPositionLocked
				},
				[5] = {
					type = "dropdown",
					name = RdKGToolMenu.constants.SO_TABLE_MODE,
					choices = RdKGToolSO.GetSoTableModes(),
					getFunc = RdKGToolSO.GetSoTableMode,
					setFunc = RdKGToolSO.SetSoTableMode
				},
				[6] = {
					type = "dropdown",
					name = RdKGToolMenu.constants.SO_DISPLAY_MODE,
					choices = RdKGToolSO.GetSoDisplayModes(),
					getFunc = RdKGToolSO.GetSoDisplayMode,
					setFunc = RdKGToolSO.SetSoDisplayMode
				},
				[7] = {
					type = "slider",
					name = RdKGToolMenu.constants.SO_REDUCED_SPACING,
					min = 0,
					max = 100,
					step = 1,
					getFunc = RdKGToolSO.GetSoReducedSpacing,
					setFunc = RdKGToolSO.SetSoReducedSpacing,
					width = "full",
					decimals = 0,
					default = 0
				},
				[8] = {
					type = "slider",
					name = RdKGToolMenu.constants.SO_SIZE,
					min = 1.0,
					max = 2.0,
					step = 0.01,
					getFunc = RdKGToolSO.GetSoSize,
					setFunc = RdKGToolSO.SetSoSize,
					width = "full",
					decimals = 2,
					default = 1.0
				},
				[9] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.SO_COLOR_SYNERGY_BACKDROP,
					getFunc = RdKGToolSO.GetSoSynergyBackdropColor,
					setFunc = RdKGToolSO.SetSoSynergyBackdropColor,
					width = "full"
				},
				[10] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.SO_COLOR_SYNERGY_PROGRESS,
					getFunc = RdKGToolSO.GetSoSynergyProgressColor,
					setFunc = RdKGToolSO.SetSoSynergyProgressColor,
					width = "full"
				},
				[11] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.SO_COLOR_SYNERGY,
					getFunc = RdKGToolSO.GetSoSynergyColor,
					setFunc = RdKGToolSO.SetSoSynergyColor,
					width = "full"
				},
				[12] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.SO_COLOR_BACKGROUND,
					getFunc = RdKGToolSO.GetSoBackgroundColor,
					setFunc = RdKGToolSO.SetSoBackgroundColor,
					width = "full"
				},
				[13] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.SO_COLOR_TEXT,
					getFunc = RdKGToolSO.GetSoTextColor,
					setFunc = RdKGToolSO.SetSoTextColor,
					width = "full"
				},
				[14] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SO_SYNERGY_COMBUSTION_SHARD,
					getFunc = function() return RdKGToolSO.GetSoSynergyEnabled(1) end,
					setFunc = function(value) RdKGToolSO.SetSoSynergyEnabled(1, value) end
				},
				[15] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SO_SYNERGY_TALONS,
					getFunc = function() return RdKGToolSO.GetSoSynergyEnabled(2) end,
					setFunc = function(value) RdKGToolSO.SetSoSynergyEnabled(2, value) end
				},
				[16] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SO_SYNERGY_NOVA,
					getFunc = function() return RdKGToolSO.GetSoSynergyEnabled(3) end,
					setFunc = function(value) RdKGToolSO.SetSoSynergyEnabled(3, value) end
				},
				[17] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SO_SYNERGY_BLOOD_ALTAR,
					getFunc = function() return RdKGToolSO.GetSoSynergyEnabled(4) end,
					setFunc = function(value) RdKGToolSO.SetSoSynergyEnabled(4, value) end
				},
				[18] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SO_SYNERGY_STANDARD,
					getFunc = function() return RdKGToolSO.GetSoSynergyEnabled(5) end,
					setFunc = function(value) RdKGToolSO.SetSoSynergyEnabled(5, value) end
				},
				[19] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SO_SYNERGY_PURGE,
					getFunc = function() return RdKGToolSO.GetSoSynergyEnabled(6) end,
					setFunc = function(value) RdKGToolSO.SetSoSynergyEnabled(6, value) end
				},
				[20] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SO_SYNERGY_BONE_SHIELD,
					getFunc = function() return RdKGToolSO.GetSoSynergyEnabled(7) end,
					setFunc = function(value) RdKGToolSO.SetSoSynergyEnabled(7, value) end
				},
				[21] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SO_SYNERGY_FLOOD_CONDUIT,
					getFunc = function() return RdKGToolSO.GetSoSynergyEnabled(8) end,
					setFunc = function(value) RdKGToolSO.SetSoSynergyEnabled(8, value) end
				},
				[22] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SO_SYNERGY_ATRONACH,
					getFunc = function() return RdKGToolSO.GetSoSynergyEnabled(9) end,
					setFunc = function(value) RdKGToolSO.SetSoSynergyEnabled(9, value) end
				},
				[23] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SO_SYNERGY_TRAPPING_WEBS,
					getFunc = function() return RdKGToolSO.GetSoSynergyEnabled(10) end,
					setFunc = function(value) RdKGToolSO.SetSoSynergyEnabled(10, value) end
				},
				[24] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SO_SYNERGY_RADIATE,
					getFunc = function() return RdKGToolSO.GetSoSynergyEnabled(11) end,
					setFunc = function(value) RdKGToolSO.SetSoSynergyEnabled(11, value) end
				},
				[25] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SO_SYNERGY_CONSUMING_DARKNESS,
					getFunc = function() return RdKGToolSO.GetSoSynergyEnabled(12) end,
					setFunc = function(value) RdKGToolSO.SetSoSynergyEnabled(12, value) end
				},
				[26] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SO_SYNERGY_SOUL_LEECH,
					getFunc = function() return RdKGToolSO.GetSoSynergyEnabled(13) end,
					setFunc = function(value) RdKGToolSO.SetSoSynergyEnabled(13, value) end
				},
				[27] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SO_SYNERGY_WARDEN_HEALING,
					getFunc = function() return RdKGToolSO.GetSoSynergyEnabled(14) end,
					setFunc = function(value) RdKGToolSO.SetSoSynergyEnabled(14, value) end
				},
				[28] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SO_SYNERGY_GRAVE_ROBBER,
					getFunc = function() return RdKGToolSO.GetSoSynergyEnabled(15) end,
					setFunc = function(value) RdKGToolSO.SetSoSynergyEnabled(15, value) end
				},
				[29] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SO_SYNERGY_PURE_AGONY,
					getFunc = function() return RdKGToolSO.GetSoSynergyEnabled(16) end,
					setFunc = function(value) RdKGToolSO.SetSoSynergyEnabled(16, value) end
				},
				[30] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SO_SYNERGY_ICY_ESCAPE,
					getFunc = function() return RdKGToolSO.GetSoSynergyEnabled(17) end,
					setFunc = function(value) RdKGToolSO.SetSoSynergyEnabled(17, value) end
				},
				[31] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SO_SYNERGY_SANGUINE_BURST,
					getFunc = function() return RdKGToolSO.GetSoSynergyEnabled(18) end,
					setFunc = function(value) RdKGToolSO.SetSoSynergyEnabled(18, value) end
				},
				[32] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SO_SYNERGY_HEED_THE_CALL,
					getFunc = function() return RdKGToolSO.GetSoSynergyEnabled(19) end,
					setFunc = function(value) RdKGToolSO.SetSoSynergyEnabled(19, value) end
				},
				[33] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SO_SYNERGY_URSUS,
					getFunc = function() return RdKGToolSO.GetSoSynergyEnabled(20) end,
					setFunc = function(value) RdKGToolSO.SetSoSynergyEnabled(20, value) end
				},
				[34] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SO_SYNERGY_GRYPHON,
					getFunc = function() return RdKGToolSO.GetSoSynergyEnabled(21) end,
					setFunc = function(value) RdKGToolSO.SetSoSynergyEnabled(21, value) end
				},
				[35] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SO_SYNERGY_RUNEBREAK,
					getFunc = function() return RdKGToolSO.GetSoSynergyEnabled(22) end,
					setFunc = function(value) RdKGToolSO.SetSoSynergyEnabled(22, value) end
				},
				[36] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SO_SYNERGY_PASSAGE,
					getFunc = function() return RdKGToolSO.GetSoSynergyEnabled(23) end,
					setFunc = function(value) RdKGToolSO.SetSoSynergyEnabled(23, value) end
				},
				[37] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SO_SYNERGY_RECOVERY,
					getFunc = function() return RdKGToolSO.GetSoSynergyEnabled(24) end,
					setFunc = function(value) RdKGToolSO.SetSoSynergyEnabled(24, value) end
				}
			}
		}
	}
	return menu
end

function RdKGToolSO.GetSoEnabled()
	return RdKGToolSO.soVars.enabled
end

function RdKGToolSO.SetSoEnabled(value)
	RdKGToolSO.SetEnabled(value, RdKGToolSO.soVars.windowEnabled)
	RdKGToolSO.AdjustSynergyDisplay()
end

function RdKGToolSO.GetSoWindowEnabled()
	return RdKGToolSO.soVars.windowEnabled
end

function RdKGToolSO.SetSoWindowEnabled(value)
	RdKGToolSO.SetEnabled(RdKGToolSO.soVars.enabled, value)
	RdKGToolSO.AdjustSynergyDisplay()
end

function RdKGToolSO.GetSoPositionLocked()
	return RdKGToolSO.soVars.positionLocked
end

function RdKGToolSO.SetSoPositionLocked(value)
	RdKGToolSO.SetPositionLocked(value)
end

function RdKGToolSO.GetSoPvpOnly()
	return RdKGToolSO.soVars.pvpOnly
end

function RdKGToolSO.SetSoPvpOnly(value)
	RdKGToolSO.soVars.pvpOnly = value
	RdKGToolSO.SetEnabled(RdKGToolSO.soVars.enabled, RdKGToolSO.soVars.windowEnabled)
	RdKGToolSO.SetControlVisibility()
end

function RdKGToolSO.GetSoSynergyBackdropColor()
	return RdKGToolMenu.GetRGBAColor(RdKGToolSO.soVars.synergyBackdropColor)
end

function RdKGToolSO.SetSoSynergyBackdropColor(r, g, b, a)
	RdKGToolSO.soVars.synergyBackdropColor = RdKGToolMenu.GetColorFromRGBA(r, g, b, a)
	RdKGToolSO.AdjustSynergyColors()
end

function RdKGToolSO.GetSoSynergyProgressColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolSO.soVars.progressColor)
end

function RdKGToolSO.SetSoSynergyProgressColor(r, g, b)
	RdKGToolSO.soVars.progressColor = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolSO.AdjustSynergyColors()
end

function RdKGToolSO.GetSoTableModes()
	return RdKGToolSO.constants.TABLE_MODES
end

function RdKGToolSO.GetSoTableMode()
	return RdKGToolSO.constants.TABLE_MODES[RdKGToolSO.soVars.tableMode]
end

function RdKGToolSO.SetSoTableMode(value)
	if value ~= nil then
		for i = 1, #RdKGToolSO.constants.TABLE_MODES do
			if RdKGToolSO.constants.TABLE_MODES[i] == value then
				RdKGToolSO.soVars.tableMode = i
			end
		end
		RdKGToolSO.SetControlVisibility()
	end
end

function RdKGToolSO.GetSoDisplayModes()
	return RdKGToolSO.constants.DISPLAY_MODES
end

function RdKGToolSO.GetSoDisplayMode()
	return RdKGToolSO.constants.DISPLAY_MODES[RdKGToolSO.soVars.displayMode]
end

function RdKGToolSO.SetSoDisplayMode(value)
	if value ~= nil then
		for i = 1, #RdKGToolSO.constants.DISPLAY_MODES do
			if RdKGToolSO.constants.DISPLAY_MODES[i] == value then
				RdKGToolSO.soVars.displayMode = i
			end
		end
	end
end

function RdKGToolSO.GetSoReducedSpacing()
	return RdKGToolSO.soVars.spacing
end

function RdKGToolSO.SetSoReducedSpacing(value)
	RdKGToolSO.soVars.spacing = value
	RdKGToolSO.AdjustSize()
end

function RdKGToolSO.GetSoSize()
	return RdKGToolSO.soVars.size
end

function RdKGToolSO.SetSoSize(value)
	if value ~= nil and value >= RdKGToolSO.constants.size.SMALL and value <= RdKGToolSO.constants.size.BIG then
		RdKGToolSO.soVars.size = value
		RdKGToolSO.AdjustSize()
	end
end

function RdKGToolSO.GetSoSynergyColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolSO.soVars.synergyColor)
end

function RdKGToolSO.SetSoSynergyColor(r, g, b)
	RdKGToolSO.soVars.synergyColor = RdKGToolMenu.GetColorFromRGB(r, g, b)
end

function RdKGToolSO.GetSoBackgroundColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolSO.soVars.backgroundColor)
end

function RdKGToolSO.SetSoBackgroundColor(r, g, b)
	RdKGToolSO.soVars.backgroundColor = RdKGToolMenu.GetColorFromRGB(r, g, b)
end

function RdKGToolSO.GetSoTextColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolSO.soVars.textColor)
end

function RdKGToolSO.SetSoTextColor(r, g, b)
	RdKGToolSO.soVars.textColor = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolSO.AdjustSynergyColors()
end

function RdKGToolSO.GetSoSynergyEnabled(index)
	return RdKGToolSO.soVars.synergyVisibility[index]
end

function RdKGToolSO.SetSoSynergyEnabled(index, value)
	RdKGToolSO.soVars.synergyVisibility[index] = value
	RdKGToolSO.AdjustSynergyDisplay()
end
