-- PB's QuestTrackerFontChanger
-- Author: PinkBanther
--
-- Adjusts the fonts of the HUD trackers stacked down the top right of the screen:
--
--   * the focused quest tracker -- quest name, step description, objectives
--   * the Golden Pursuits tracker -- the tracked pursuit and its progress (the same panel
--     also carries Tamriel Tomes)
--   * the house information tracker -- the house name, owner and visitor count shown while
--     you are in a house, including on a home tour
--
-- On screen they run quest tracker -> zone story -> Golden Pursuits -> house information.
--
-- They are kept as separate sections everywhere -- settings, saved variables, chat commands --
-- because they are different pieces of UI that happen to sit on top of each other, and
-- somebody who wants a bigger house name usually does not want a bigger quest tracker.
--
-- Why this add-on can do more than PB's NamePlateChanger, and where the limits actually are
-- (full evidence in FINDINGS.md):
--
-- The overhead nametag is drawn by the engine, so that add-on can only hand the client a font
-- descriptor through a client setting. Both trackers here are the opposite: ordinary Lua UI
-- built out of LabelControls, and a LabelControl takes SetFont(descriptor) directly. So there
-- is no client setting to write, nothing that outlives the session, and -- unlike the
-- nameplate font -- no UI reload when the face changes.
--
-- Each tracker gives its text more than one font, and those are what the sliders map onto:
--
--   section  role           control                     gamepad              keyboard
--   quest    questName      ZO_TrackedHeader            ZoFontGamepadBold27  ZoFontGameShadow
--   quest    questStep      ZO_QuestStepDescription     ZoFontGamepadBold22  ZoFontGameShadow
--   quest    questGoal      ZO_QuestCondition           ZoFontGamepad34      ZoFontGameShadow
--   pursuit  pursuitName    ...ContainerHeader          ZoFontGamepadBold27  ZoFontGameShadow
--   pursuit  pursuitDetail  ...SubLabel/ProgressLabel   ZoFontGamepad34      ZoFontGameShadow
--   house    houseName      ...ContainerHeader          ZoFontGamepadBold27  ZoFontGameShadow
--   house    houseDetail    ...SubLabel/Population/Tags ZoFontGamepad34      ZoFontGameShadow
--
-- One slider per font the game actually uses, no more and no fewer. Those named fonts resolve
-- to "face|size|style" descriptors in esoui/fontdefs/, which is the form written back here.
--
-- Two kinds of hook, because the trackers are built two ways:
--
--   pool       The quest tracker. Pooled labels, rebuilt whenever a step advances.
--              ApplyPlatformStyleToHeader and friends are file-local and cannot be hooked --
--              but they are installed on the pools with SetCustomAcquireBehavior, and
--              pool.customAcquireBehavior is a plain field. Wrapping it styles every label the
--              moment it is acquired, for the whole session.
--   hudTracker Golden Pursuits and the house panel. Both are ZO_HUDTracker_Base subclasses: a
--              handful of fixed labels on a singleton, whose fonts are only ever set by the
--              public ApplyPlatformStyle. Wrapping that method on the instance is enough --
--              and calling it is also how the game's own font is put back.
--
-- Both wrappers run after the game's own styling, which is what makes the label underneath
-- pristine and safe to measure. control:GetFontSize() there is the client's real size for
-- that role -- including the resolution scaling $(GP_27) and friends carry, which an add-on
-- cannot compute. That measurement becomes the default the sliders start from, so "untouched
-- settings" really is pixel-identical to the stock UI.
--
-- Nothing is written while every setting in a section still equals the game's own value. That
-- is the whole cost control: a descriptor that differs makes the client build a font, and on
-- console that build is billed to the 100 MB pool every add-on shares.

if PBS_QUEST_TRACKER_FONT_CHANGER then
	return
end

local addon = {
	name = "PBsQuestTrackerFontChanger",
}

-- The display name is a Lua constant and the version comes from the manifest, the same way
-- PB's NamePlateChanger does it -- reading the name back out of "## Title" mangles the
-- "PB's " prefix in the settings library. Typographic apostrophe (U+2019), not ASCII '.
local DISPLAY_NAME = "PB’s QuestTrackerFontChanger"
local AUTHOR = "PinkBanther"
local SLASH = "/pbquest"
local SHORT_SLASH = "/pbqt"

local function ReadManifestVersion()
	local manager = GetAddOnManager and GetAddOnManager()
	if not manager then
		return ""
	end
	for index = 1, manager:GetNumAddOns() do
		local name, title = manager:GetAddOnInfo(index)
		if name == addon.name and title then
			local plain = title:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
			return plain:match("([%d]+[%d%.]*)%s*$") or ""
		end
	end
	return ""
end

addon.author = AUTHOR
addon.baseTitle = DISPLAY_NAME
addon.version = ReadManifestVersion()
addon.title = addon.version ~= "" and (DISPLAY_NAME .. " " .. addon.version) or DISPLAY_NAME

-- ---------------------------------------------------------------------------------------
-- Output
--
-- A message printed at EVENT_ADD_ON_LOADED is thrown away because chat is not up yet, so
-- anything user-facing is either a command response or fires on EVENT_PLAYER_ACTIVATED.
-- ---------------------------------------------------------------------------------------

local function Say(text)
	if CHAT_ROUTER and CHAT_ROUTER.AddSystemMessage then
		CHAT_ROUTER:AddSystemMessage(text)
	elseif CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then
		CHAT_SYSTEM:AddMessage(text)
	else
		d(text)
	end
end

local function Line(text, ...)
	if select("#", ...) > 0 then
		local ok, formatted = pcall(string.format, text, ...)
		Say(ok and formatted or text)
	else
		Say(text)
	end
end

addon.Line = Line

-- ---------------------------------------------------------------------------------------
-- The two trackers and the text in them
--
-- poolName is the field on FOCUSED_QUEST_TRACKER; labels are the fields on the singleton named
-- by trackerGlobal. Both are found by the name the game gives them rather than by position, so
-- a client that grows another label does not silently shift everything along.
--
-- The two "detail" roles cover several labels at once because the game gives those labels the
-- same font: the pursuit's name and its progress line are one font, and so are the house's
-- owner line, visitor count and House Tours tags. Splitting them would only be more ways to
-- make lines that belong together disagree.
--
-- The sections are in the order they appear down the screen, and the settings panel is built
-- straight from this list, so the panel reads the same way as the HUD.
-- ---------------------------------------------------------------------------------------

addon.sections = {
	{
		key = "quest",
		kind = "pool",
		headingId = "SI_PBSQTFC_SECTION_QUEST",
		noteId = "SI_PBSQTFC_SECTION_QUEST_NOTE",
		enabledId = "SI_PBSQTFC_QUEST_ENABLED",
		enabledTooltipId = "SI_PBSQTFC_QUEST_ENABLED_TOOLTIP",
		faceId = "SI_PBSQTFC_QUEST_FACE",
		faceTooltipId = "SI_PBSQTFC_QUEST_FACE_TOOLTIP",
		styleId = "SI_PBSQTFC_QUEST_STYLE",
		styleTooltipId = "SI_PBSQTFC_QUEST_STYLE_TOOLTIP",
		roles = {
			{ key = "questName", poolName = "headerPool", command = "name", stringId = "SI_PBSQTFC_SIZE_QUEST_NAME", tooltipId = "SI_PBSQTFC_SIZE_QUEST_NAME_TOOLTIP" },
			{ key = "questStep", poolName = "stepDescriptionPool", command = "step", stringId = "SI_PBSQTFC_SIZE_QUEST_STEP", tooltipId = "SI_PBSQTFC_SIZE_QUEST_STEP_TOOLTIP" },
			{ key = "questGoal", poolName = "conditionPool", command = "goal", stringId = "SI_PBSQTFC_SIZE_QUEST_GOAL", tooltipId = "SI_PBSQTFC_SIZE_QUEST_GOAL_TOOLTIP" },
		},
	},
	{
		key = "pursuit",
		kind = "hudTracker",
		trackerGlobal = "PROMOTIONAL_EVENT_TRACKER",
		headingId = "SI_PBSQTFC_SECTION_PURSUIT",
		noteId = "SI_PBSQTFC_SECTION_PURSUIT_NOTE",
		enabledId = "SI_PBSQTFC_PURSUIT_ENABLED",
		enabledTooltipId = "SI_PBSQTFC_PURSUIT_ENABLED_TOOLTIP",
		faceId = "SI_PBSQTFC_PURSUIT_FACE",
		faceTooltipId = "SI_PBSQTFC_PURSUIT_FACE_TOOLTIP",
		styleId = "SI_PBSQTFC_PURSUIT_STYLE",
		styleTooltipId = "SI_PBSQTFC_PURSUIT_STYLE_TOOLTIP",
		roles = {
			{ key = "pursuitName", labels = { "headerLabel" }, command = "name", stringId = "SI_PBSQTFC_SIZE_PURSUIT_NAME", tooltipId = "SI_PBSQTFC_SIZE_PURSUIT_NAME_TOOLTIP" },
			{ key = "pursuitDetail", labels = { "subLabel", "progressLabel" }, command = "detail", stringId = "SI_PBSQTFC_SIZE_PURSUIT_DETAIL", tooltipId = "SI_PBSQTFC_SIZE_PURSUIT_DETAIL_TOOLTIP" },
		},
		spacingRole = "pursuitDetail",
		spacingAnchors = {
			"SUBLABEL_PRIMARY_ANCHOR", "SUBLABEL_SECONDARY_ANCHOR",
			"PROGRESS_LABEL_PRIMARY_ANCHOR", "PROGRESS_LABEL_SECONDARY_ANCHOR",
		},
	},
	{
		key = "house",
		kind = "hudTracker",
		trackerGlobal = "HOUSE_INFORMATION_TRACKER",
		headingId = "SI_PBSQTFC_SECTION_HOUSE",
		noteId = "SI_PBSQTFC_SECTION_HOUSE_NOTE",
		enabledId = "SI_PBSQTFC_HOUSE_ENABLED",
		enabledTooltipId = "SI_PBSQTFC_HOUSE_ENABLED_TOOLTIP",
		faceId = "SI_PBSQTFC_HOUSE_FACE",
		faceTooltipId = "SI_PBSQTFC_HOUSE_FACE_TOOLTIP",
		styleId = "SI_PBSQTFC_HOUSE_STYLE",
		styleTooltipId = "SI_PBSQTFC_HOUSE_STYLE_TOOLTIP",
		roles = {
			{ key = "houseName", labels = { "headerLabel" }, command = "name", stringId = "SI_PBSQTFC_SIZE_HOUSE_NAME", tooltipId = "SI_PBSQTFC_SIZE_HOUSE_NAME_TOOLTIP" },
			{ key = "houseDetail", labels = { "subLabel", "populationLabel", "tagsLabel" }, command = "detail", stringId = "SI_PBSQTFC_SIZE_HOUSE_DETAIL", tooltipId = "SI_PBSQTFC_SIZE_HOUSE_DETAIL_TOOLTIP" },
		},
		-- Every gap in this panel sits above a "detail" label, so they all follow that role's
		-- size. The gap above the header is the panel's own TOP_LEVEL anchor, which places the
		-- whole thing on screen and is deliberately left alone -- as are CONTAINER_* and
		-- HEADER_*, for the same reason.
		spacingRole = "houseDetail",
		spacingAnchors = {
			"SUBLABEL_PRIMARY_ANCHOR", "SUBLABEL_SECONDARY_ANCHOR",
			"POPULATION_HEADERLABEL_PRIMARY_ANCHOR", "POPULATION_HEADERLABEL_SECONDARY_ANCHOR",
			"POPULATION_SUBLABEL_PRIMARY_ANCHOR", "POPULATION_SUBLABEL_SECONDARY_ANCHOR",
			"TAGS_LABEL_PRIMARY_ANCHOR", "TAGS_LABEL_SECONDARY_ANCHOR",
		},
	},
}

-- Flat lookups, built once, so nothing has to walk the tree to answer "which section is this
-- role in".
addon.roleByKey = {}
addon.sectionByKey = {}
addon.sectionOfRole = {}
for _, section in ipairs(addon.sections) do
	addon.sectionByKey[section.key] = section
	for _, role in ipairs(section.roles) do
		role.sectionKey = section.key
		addon.roleByKey[role.key] = role
		addon.sectionOfRole[role.key] = section
	end
end

-- ---------------------------------------------------------------------------------------
-- What the game's own fonts are
--
-- Taken from the client's own source rather than guessed. questtracker.lua and
-- houseinformationtracker.lua name a font object per platform, and esoui/fontdefs/ defines
-- that object as "face|size|style":
--
--   ZoFontGamepadBold27  = $(GAMEPAD_BOLD_FONT)|$(GP_27)|soft-shadow-thick
--   ZoFontGamepadBold22  = $(GAMEPAD_BOLD_FONT)|$(GP_22)|soft-shadow-thick
--   ZoFontGamepad34      = $(GAMEPAD_MEDIUM_FONT)|$(GP_34)|soft-shadow-thick
--   ZoFontGameShadow     = $(BOLD_FONT)|$(KB_18)|soft-shadow-thin
--
-- The sizes below are the numbers in those names. $(GP_27) is that number after the client's
-- own resolution scaling, which an add-on cannot compute -- so these are only the fallback
-- until a real label has been measured. See MeasureDefault.
-- ---------------------------------------------------------------------------------------

addon.platformDefaults = {
	Gamepad = {
		questName = { face = "$(GAMEPAD_BOLD_FONT)", size = 27, style = "soft-shadow-thick" },
		questStep = { face = "$(GAMEPAD_BOLD_FONT)", size = 22, style = "soft-shadow-thick" },
		questGoal = { face = "$(GAMEPAD_MEDIUM_FONT)", size = 34, style = "soft-shadow-thick" },
		pursuitName = { face = "$(GAMEPAD_BOLD_FONT)", size = 27, style = "soft-shadow-thick" },
		pursuitDetail = { face = "$(GAMEPAD_MEDIUM_FONT)", size = 34, style = "soft-shadow-thick" },
		houseName = { face = "$(GAMEPAD_BOLD_FONT)", size = 27, style = "soft-shadow-thick" },
		houseDetail = { face = "$(GAMEPAD_MEDIUM_FONT)", size = 34, style = "soft-shadow-thick" },
	},
	Keyboard = {
		questName = { face = "$(BOLD_FONT)", size = 18, style = "soft-shadow-thin" },
		questStep = { face = "$(BOLD_FONT)", size = 18, style = "soft-shadow-thin" },
		questGoal = { face = "$(BOLD_FONT)", size = 18, style = "soft-shadow-thin" },
		pursuitName = { face = "$(BOLD_FONT)", size = 18, style = "soft-shadow-thin" },
		pursuitDetail = { face = "$(BOLD_FONT)", size = 18, style = "soft-shadow-thin" },
		houseName = { face = "$(BOLD_FONT)", size = 18, style = "soft-shadow-thin" },
		houseDetail = { face = "$(BOLD_FONT)", size = 18, style = "soft-shadow-thin" },
	},
}

-- ---------------------------------------------------------------------------------------
-- Faces offered in the settings panel
--
-- The same list as PB's NamePlateChanger, for the same reasons. Aliases only, never resolved
-- paths: every one of these is defined per language, so the Japanese client hands back a face
-- that can draw Japanese quest and house names. A raw Latin path would not.
--
-- Not every face the client defines, either -- only the ones the console UI already has
-- loaded. A face that is not otherwise in use has to be built when it is set, and on console
-- that build is billed to the 100 MB pool every add-on shares. Measured on PS5, these four
-- crash: ANTIQUE_FONT / HANDWRITTEN_FONT / STONE_TABLET_FONT (all ESO_KafuPenji-M on a
-- Japanese client, a brush face the UI never draws with) and CHAT_FONT (ESO_FWUDC_70-M, not
-- used by the gamepad UI).
--
--   alias                  western             japanese
--   GAMEPAD_MEDIUM_FONT    FTN57               FTN57  (latin; CJK falls back to the gothic)
--   GAMEPAD_BOLD_FONT      FTN87               FTN87  (latin; CJK falls back to the gothic)
--   GAMEPAD_LIGHT_FONT     FTN47               ESO_FWNTLGUDC70-DB  \
--   MEDIUM_FONT            Univers57           ESO_FWNTLGUDC70-DB   > the same gothic
--   BOLD_FONT              Univers67           ESO_FWNTLGUDC70-DB  /
--
-- "" is Default and means "leave each part on the face the game picked for it" -- which is not
-- one face: in gamepad mode the quest and house names are bold and everything under them is
-- medium. Picking a face here deliberately collapses that distinction.
-- ---------------------------------------------------------------------------------------

addon.faces = {
	{ alias = "", stringId = "SI_PBSQTFC_FACE_DEFAULT" },
	{ alias = "$(GAMEPAD_MEDIUM_FONT)", stringId = "SI_PBSQTFC_FACE_GAMEPAD_MEDIUM" },
	{ alias = "$(GAMEPAD_BOLD_FONT)", stringId = "SI_PBSQTFC_FACE_GAMEPAD_BOLD" },
	{ alias = "$(GAMEPAD_LIGHT_FONT)", stringId = "SI_PBSQTFC_FACE_GAMEPAD_LIGHT" },
	{ alias = "$(MEDIUM_FONT)", stringId = "SI_PBSQTFC_FACE_MEDIUM" },
	{ alias = "$(BOLD_FONT)", stringId = "SI_PBSQTFC_FACE_BOLD" },
}

-- ---------------------------------------------------------------------------------------
-- Outline styles
--
-- A font descriptor takes the style as a *token*, not as a FONT_STYLE_* number -- SetFont on
-- a LabelControl parses "face|size|style", where the nameplate API took a separate numeric
-- style. The token names are not the enum names lowercased either: FONT_STYLE_OUTLINE_THICK
-- is written "thick-outline".
--
-- Only tokens the client's own fontdefs actually use are offered. The whole of esoui defines
-- exactly four -- shadow, soft-shadow-thin, soft-shadow-thick, thick-outline -- so anything
-- else would be a guess about what the engine's parser accepts, and a font that fails to
-- build is not a good surprise on console. FONT_STYLE_OUTLINE and FONT_STYLE_OUTLINE_SHADOW
-- exist as enum values with no token anywhere in the client source; they are left out until
-- one is measured.
--
-- STYLE_INHERIT keeps whatever the role already had. Like the face, it is "" rather than nil:
-- nil cannot be told apart from "not set", does not survive a round trip through the settings
-- library, and reads back as the first item in a dropdown.
-- ---------------------------------------------------------------------------------------

addon.STYLE_INHERIT = ""
addon.STYLE_NONE = "none"

addon.styles = {
	{ token = "", stringId = "SI_PBSQTFC_STYLE_DEFAULT" },
	{ token = "none", stringId = "SI_PBSQTFC_STYLE_NORMAL" },
	{ token = "shadow", stringId = "SI_PBSQTFC_STYLE_SHADOW" },
	{ token = "soft-shadow-thin", stringId = "SI_PBSQTFC_STYLE_SOFT_SHADOW_THIN" },
	{ token = "soft-shadow-thick", stringId = "SI_PBSQTFC_STYLE_SOFT_SHADOW_THICK" },
	{ token = "thick-outline", stringId = "SI_PBSQTFC_STYLE_OUTLINE_THICK" },
}

addon.MIN_SIZE = 10
addon.MAX_SIZE = 72

-- Each section carries its own switch, face and outline: they are separate pieces of UI, and
-- a house name big enough to read across a courtyard is not a quest tracker anyone wants.
--
-- Sizes are per platform because the game's own are: 27 / 22 / 34 in gamepad mode against 18
-- for everything in keyboard mode. One shared number would be wrong in whichever mode it was
-- not chosen in. An empty table means "no part has been changed", which is what makes an
-- untouched install cost nothing.
--
-- The measurements are outside the sections because they are not a setting -- they are what
-- the client draws, keyed by role, and they stay correct however the sections are configured.
addon.sectionDefaults = {
	enabled = true,
	face = "",
	style = addon.STYLE_INHERIT,
	sizes = { Gamepad = {}, Keyboard = {} },
}

addon.accountDefaults = {
	quest = { enabled = true, face = "", style = "", sizes = { Gamepad = {}, Keyboard = {} } },
	pursuit = { enabled = true, face = "", style = "", sizes = { Gamepad = {}, Keyboard = {} } },
	house = { enabled = true, face = "", style = "", sizes = { Gamepad = {}, Keyboard = {} } },
	measured = { Gamepad = {}, Keyboard = {} },
}

-- ---------------------------------------------------------------------------------------
-- Settings lookups
-- ---------------------------------------------------------------------------------------

-- Which of the two style sets is on screen. On console this is always Gamepad.
function addon:Platform()
	local gamepadPreferred = IsInGamepadPreferredMode and IsInGamepadPreferredMode()
	return gamepadPreferred and "Gamepad" or "Keyboard"
end

-- The saved settings for one section, repaired if a partial table came back from an older
-- build. Never returns nil: every caller would otherwise need the same guard.
function addon:Settings(sectionKey)
	local account = self.account
	local settings = account[sectionKey]
	if type(settings) ~= "table" then
		settings = {}
		account[sectionKey] = settings
	end
	if settings.enabled == nil then
		settings.enabled = self.sectionDefaults.enabled
	end
	settings.face = settings.face or self.sectionDefaults.face
	settings.style = settings.style or self.sectionDefaults.style
	if type(settings.sizes) ~= "table" then
		settings.sizes = { Gamepad = {}, Keyboard = {} }
	end
	settings.sizes.Gamepad = settings.sizes.Gamepad or {}
	settings.sizes.Keyboard = settings.sizes.Keyboard or {}
	return settings
end

function addon:SettingsForRole(roleKey)
	return self:Settings(self.roleByKey[roleKey].sectionKey)
end

function addon:RoleDefaults(roleKey, platform)
	return self.platformDefaults[platform or self:Platform()][roleKey]
end

-- The size the game itself draws this role at: measured if a label has ever been seen,
-- otherwise the number out of the font's name.
function addon:DefaultSize(roleKey, platform)
	platform = platform or self:Platform()
	local account = self.account
	local measured = account and account.measured and account.measured[platform]
	local value = measured and measured[roleKey]
	if type(value) == "number" and value > 0 then
		return value
	end
	return self:RoleDefaults(roleKey, platform).size
end

function addon:SizeFor(roleKey, platform)
	platform = platform or self:Platform()
	local value = self:SettingsForRole(roleKey).sizes[platform][roleKey]
	if type(value) == "number" then
		return value
	end
	return self:DefaultSize(roleKey, platform)
end

function addon:SetSizeFor(roleKey, value, platform)
	platform = platform or self:Platform()
	self:SettingsForRole(roleKey).sizes[platform][roleKey] = value
end

-- Whether a label is still carrying a font the game put there.
--
-- The game always styles with a *named* font object -- "ZoFontGamepadBold27" -- and this
-- add-on always writes a descriptor, which by construction contains a "|". So the two are
-- told apart by the string itself rather than by trusting the call order. Same test PB's
-- NamePlateChanger uses on the nameplate descriptor, for the same reason.
local function LooksLikeStock(font)
	return type(font) == "string" and font ~= "" and not font:find("|", 1, true)
end

-- Records what the client's own font for this role really is.
--
-- Reading one of our own fonts back here would make it the new "default", and the real one
-- would be gone for good -- that is the mistake PB's NamePlateChanger had to grow a repair
-- path for. Three things stop it:
--
--   * this only runs immediately after the game's own styling call, so the label is pristine,
--   * once per role per session, so there is one chance to get it wrong rather than many,
--   * and the label is checked anyway. Belt and braces, because the first point is an
--     assumption about the client's load order and the third is a fact about the string.
function addon:MeasureDefault(control, roleKey)
	local platform = self:Platform()
	self.measuredThisSession = self.measuredThisSession or {}
	self.measuredThisSession[platform] = self.measuredThisSession[platform] or {}
	if self.measuredThisSession[platform][roleKey] then
		return
	end

	if type(control.GetFont) == "function" then
		local gotFont, font = pcall(control.GetFont, control)
		if gotFont and not LooksLikeStock(font) then
			-- Not the game's font. Left unmarked so a later, pristine label still counts.
			return
		end
	end

	if type(control.GetFontSize) ~= "function" then
		return
	end
	local ok, size = pcall(control.GetFontSize, control)
	if not ok or type(size) ~= "number" or size <= 0 then
		-- Not marked as done: a label the client has not laid out yet reports nothing, and
		-- the house tracker can be hooked before it has ever been styled. Marking it here
		-- would spend the session's one measurement on a label that had no font to read.
		return
	end
	self.measuredThisSession[platform][roleKey] = true

	local account = self.account
	account.measured = account.measured or {}
	account.measured[platform] = account.measured[platform] or {}
	account.measured[platform][roleKey] = size
end

-- Anyone who already picked one of the retired faces is still carrying it in saved variables.
-- Checked against the offered list rather than against a list of bad names, so removing a
-- face from self.faces is always enough to stop it being used, in every section.
function addon:DropRetiredFace()
	local dropped = false
	for _, section in ipairs(self.sections) do
		local settings = self:Settings(section.key)
		local chosen = settings.face
		if chosen ~= nil and chosen ~= "" then
			local offered = false
			for _, face in ipairs(self.faces) do
				if face.alias == chosen then
					offered = true
					break
				end
			end
			if not offered then
				settings.face = ""
				dropped = true
			end
		end
	end
	return dropped
end

-- ---------------------------------------------------------------------------------------
-- Building and applying the font
-- ---------------------------------------------------------------------------------------

-- True when this role would be drawn differently from the way the game draws it.
--
-- This is the cost control. A descriptor that matches nothing the client has built makes it
-- build a font, and on console that is billed to the 100 MB pool every add-on shares. While
-- the answer here is false the add-on never calls SetFont at all, so an installed-but-unset
-- add-on is indistinguishable from not having it.
function addon:RoleDiffers(roleKey)
	local settings = self:SettingsForRole(roleKey)
	if not settings.enabled then
		return false
	end
	if settings.face ~= "" then
		return true
	end
	if settings.style ~= self.STYLE_INHERIT then
		return true
	end
	return self:SizeFor(roleKey) ~= self:DefaultSize(roleKey)
end

function addon:SectionDiffers(sectionKey)
	for _, role in ipairs(self.sectionByKey[sectionKey].roles) do
		if self:RoleDiffers(role.key) then
			return true
		end
	end
	return false
end

-- "face|size" or "face|size|style", the form the client's own fontdefs use.
function addon:BuildDescriptor(roleKey)
	local settings = self:SettingsForRole(roleKey)
	local defaults = self:RoleDefaults(roleKey)

	local face = settings.face
	if face == nil or face == "" then
		face = defaults.face
	end

	local size = math.floor(tonumber(self:SizeFor(roleKey)) or defaults.size)
	size = math.max(self.MIN_SIZE, math.min(self.MAX_SIZE, size))

	local style = settings.style
	if style == nil or style == self.STYLE_INHERIT then
		style = defaults.style
	end

	if style == self.STYLE_NONE or style == "" then
		return string.format("%s|%d", face, size)
	end
	return string.format("%s|%d|%s", face, size, style)
end

-- ---------------------------------------------------------------------------------------
-- Line spacing
--
-- The gaps between the lines are not part of the font. They are separate numbers the game
-- sets alongside it -- tree node offsets in the quest tracker, anchor offsets in the two HUD
-- panels -- and they do not move when the font does, so shrinking the text just leaves the
-- rows floating apart. Each gap is therefore scaled by the same ratio as the text below it.
--
-- Which text is "below it" is not a guess: an offset positions the top of a control against
-- the bottom of the one before it, so the gap belongs to the control it places, and it scales
-- with that control's role.
--
-- The numbers are read back from the game rather than hardcoded. QUEST_TRACKER_TREE_LINE_SPACING
-- and the anchor offsets live in file-local constants tables an add-on cannot reach, but the
-- values are on the node and on the anchor by the time we run.
-- ---------------------------------------------------------------------------------------

-- How much bigger this role is being drawn than the game draws it. 1 when nothing differs,
-- which is what keeps an untouched section untouched.
function addon:SizeRatio(roleKey)
	if not self:RoleDiffers(roleKey) then
		return 1
	end
	local defaultSize = self:DefaultSize(roleKey)
	if type(defaultSize) ~= "number" or defaultSize <= 0 then
		return 1
	end
	return self:SizeFor(roleKey) / defaultSize
end

-- Scales one offset, remembering the game's own value for it.
--
-- The same problem as measuring a font: read back naively, our own scaled offset becomes the
-- next "base" and the game's number compounds away with every update. The test is the same
-- shape as the one on fonts -- if the current value is not what we last wrote, the game wrote
-- it and it is the base. A node the game re-creates on every rebuild re-bases on its own; a
-- node the game writes once (the quest header) keeps the base captured the first time.
local function ScaledOffset(store, key, current, ratio)
	if type(current) ~= "number" then
		return nil
	end

	local record = store[key]
	if not record or record.written ~= current then
		record = { base = current }
		store[key] = record
	end

	local target = record.base
	if ratio ~= 1 then
		target = math.max(0, math.floor(record.base * ratio + 0.5))
	end
	record.written = target
	return target
end

-- Keyed by the node or anchor object, with weak keys so a tracker rebuild does not pile up
-- entries for controls that no longer exist.
function addon:SpacingStore(name)
	self.spacingStores = self.spacingStores or {}
	if not self.spacingStores[name] then
		self.spacingStores[name] = setmetatable({}, { __mode = "k" })
	end
	return self.spacingStores[name]
end

-- Scales the gaps in the quest tracker's tree.
--
-- Runs immediately before the tracker lays the tree out, which is the one moment every node's
-- offset is guaranteed to be current: the game sets it from its constants right after every
-- AddChild, and re-sets it in ApplyPlatformStyleToCondition.
function addon:ScaleQuestSpacing(tracker)
	local store = self:SpacingStore("node")

	for _, role in ipairs(self.sectionByKey.quest.roles) do
		local ratio = self:SizeRatio(role.key)
		local pool = tracker[role.poolName]
		if pool and type(pool.GetActiveObjects) == "function" then
			for _, control in pairs(pool:GetActiveObjects()) do
				local node = control.m_TreeNode
				if node and type(node.SetOffsetY) == "function" then
					local target = ScaledOffset(store, node, node.m_OffsetY, ratio)
					if target and target ~= node.m_OffsetY then
						pcall(node.SetOffsetY, node, target)
					end
				end
			end
		end
	end
end

-- Scales the gaps in one of the two HUD panels.
--
-- These live on the ZO_Anchor objects in the platform style table, which the panel re-applies
-- to its labels in RefreshAnchors. That table is the game's and it is shared for the session,
-- so the base is captured before anything is written and an unchanged section writes nothing
-- -- turning the section off puts the game's own numbers straight back.
function addon:ScaleHudTrackerSpacing(section, tracker)
	local style = tracker.currentStyle
	if not style or not section.spacingAnchors then
		return
	end

	local store = self:SpacingStore("anchor")
	local ratio = self:SizeRatio(section.spacingRole)

	for _, styleKey in ipairs(section.spacingAnchors) do
		local anchor = style[styleKey]
		if type(anchor) == "table" and type(anchor.GetOffsetY) == "function" and type(anchor.SetOffsets) == "function" then
			local okY, currentY = pcall(anchor.GetOffsetY, anchor)
			local okX, currentX = pcall(anchor.GetOffsetX, anchor)
			if okY and okX then
				local target = ScaledOffset(store, anchor, currentY, ratio)
				if target and target ~= currentY then
					pcall(anchor.SetOffsets, anchor, currentX, target)
				end
			end
		end
	end
end

-- Grows the quest-name box to match the quest-name font.
--
-- The gamepad quest tracker header is the one control in either tracker that is given a fixed
-- height (QUEST_HEADER_BASE_HEIGHT = 28); everything else is left at height 0 and sizes itself
-- to its text, the house tracker included. The quest tree stacks nodes by anchoring each
-- control's top to the previous control's bottom, so a quest name larger than the box the game
-- sized for its own font would be clipped and the step description under it overlapped.
--
-- Grown in the same proportion as the font rather than measured, because at acquire time the
-- label has no text yet. Only ever grown: the box is generous for the game's own size, and
-- shrinking it would pull the rest of the tracker up into it. In keyboard mode the header
-- height is unconstrained and this does nothing.
function addon:StretchHeader(control, roleKey)
	if roleKey ~= "questName" then
		return
	end
	if type(control.GetHeight) ~= "function" or type(control.SetHeight) ~= "function" then
		return
	end

	local ok, baseHeight = pcall(control.GetHeight, control)
	if not ok or type(baseHeight) ~= "number" or baseHeight <= 0 then
		return
	end

	local defaultSize = self:DefaultSize(roleKey)
	local size = self:SizeFor(roleKey)
	if defaultSize <= 0 or size <= defaultSize then
		return
	end

	pcall(control.SetHeight, control, math.ceil(baseHeight * size / defaultSize))
end

-- Puts our font on one label, if there is anything to put.
--
-- Never touches a label while the settings still match the game -- the label keeps the named
-- font object the game gave it, rather than an identical descriptor of ours.
function addon:StyleLabel(control, roleKey)
	if not control or type(control.SetFont) ~= "function" then
		return false
	end
	if not self:RoleDiffers(roleKey) then
		return false
	end
	local descriptor = self:BuildDescriptor(roleKey)
	local ok = pcall(control.SetFont, control, descriptor)
	if ok then
		self.lastDescriptor = self.lastDescriptor or {}
		self.lastDescriptor[roleKey] = descriptor
		self:StretchHeader(control, roleKey)
	end
	return ok
end

-- ---------------------------------------------------------------------------------------
-- The quest tracker
-- ---------------------------------------------------------------------------------------

function addon:QuestTracker()
	return FOCUSED_QUEST_TRACKER
end

-- Wraps the font-setting the tracker already does.
--
-- ApplyPlatformStyleToHeader / ...ToCondition / ...ToStepDescription are file-local in
-- questtracker.lua and cannot be hooked -- but they are installed on the pools with
-- SetCustomAcquireBehavior, and pool.customAcquireBehavior is a plain field. Reading it,
-- calling it first and then styling on top means:
--
--   * every label is ours from the moment it is acquired, including the ones the tracker
--     rebuilds on its own after a quest step advances,
--   * the game's own call has just run, so the label is pristine and safe to measure,
--   * nothing has to poll, and the tracker's own UpdateTreeView still runs afterwards and
--     lays out the new text heights.
function addon:HookQuestTracker()
	self.hooked = self.hooked or {}
	if self.hooked.quest then
		return true
	end

	local tracker = self:QuestTracker()
	if not tracker then
		return false
	end

	for _, role in ipairs(self.sectionByKey.quest.roles) do
		local pool = tracker[role.poolName]
		if not pool or type(pool.SetCustomAcquireBehavior) ~= "function" then
			return false
		end
	end

	for _, role in ipairs(self.sectionByKey.quest.roles) do
		local pool = tracker[role.poolName]
		local roleKey = role.key
		local previous = pool.customAcquireBehavior
		pool:SetCustomAcquireBehavior(function(control, objectKey)
			if previous then
				previous(control, objectKey)
			end
			addon:MeasureDefault(control, roleKey)
			addon:StyleLabel(control, roleKey)
		end)
	end

	-- The gaps between the rows are set on the tree nodes, not on the labels, and the node
	-- does not exist yet when a label is acquired -- the game creates it immediately
	-- afterwards. UpdateTreeView is where those offsets are turned into anchors, so scaling
	-- them on the way in is both the first moment they are all present and the last moment
	-- before they are used.
	if type(tracker.UpdateTreeView) == "function" then
		local previousUpdate = tracker.UpdateTreeView
		tracker.UpdateTreeView = function(trackerSelf)
			addon:ScaleQuestSpacing(trackerSelf)
			previousUpdate(trackerSelf)
		end
	end

	self.hooked.quest = true
	return true
end

-- Re-draws the quest tracker with the current settings.
--
-- ApplyPlatformStyle first, always. It is the tracker's own public method for putting the
-- platform's named fonts back on every active label, so it is both how "off" restores the
-- game's font and how a *smaller* setting gets applied -- without it, a label would keep the
-- larger font we gave it a moment ago and nothing would shrink.
--
-- It ends with its own UpdateTreeView, so the second one here is for our fonts: the labels
-- have new text heights and the tree stacks them by height.
function addon:RefreshQuest()
	local tracker = self:QuestTracker()
	if not tracker then
		return false
	end

	if type(tracker.ApplyPlatformStyle) == "function" then
		pcall(tracker.ApplyPlatformStyle, tracker)
	end

	for _, role in ipairs(self.sectionByKey.quest.roles) do
		local pool = tracker[role.poolName]
		if pool and type(pool.GetActiveObjects) == "function" then
			for _, control in pairs(pool:GetActiveObjects()) do
				self:StyleLabel(control, role.key)
			end
		end
	end

	if type(tracker.UpdateTreeView) == "function" then
		pcall(tracker.UpdateTreeView, tracker)
	end
	return true
end

-- ---------------------------------------------------------------------------------------
-- The ZO_HUDTracker_Base panels: Golden Pursuits and the house information
--
-- Golden Pursuits is the panel carrying the pursuit you are tracking and its progress; the
-- same controls are reused for Tamriel Tomes, so one setting covers both. The house panel
-- appears below it while you are in a house -- yours or someone else's on a home tour -- and
-- carries the house name, the owner, the visitor count and the House Tours tags.
--
-- Nothing in either is pooled: each is a singleton with a handful of fixed labels, and
-- ApplyPlatformStyle is the only thing that ever sets their fonts (Update and Refresh call
-- SetText, never SetFont). It is a public method on the instance, so it can be wrapped
-- directly -- and because it is the only writer, our font stays put until the next time it is
-- called, which is a platform change or one of our own refreshes.
--
-- Unlike the quest tracker's header, every label here is unconstrained and the containers are
-- resizeToFitDescendents, so a larger font grows the panel instead of being clipped.
-- ---------------------------------------------------------------------------------------

function addon:TrackerFor(section)
	return section.trackerGlobal and _G[section.trackerGlobal] or nil
end

function addon:HookHudTracker(section)
	self.hooked = self.hooked or {}
	if self.hooked[section.key] then
		return true
	end

	local tracker = self:TrackerFor(section)
	if not tracker or type(tracker.ApplyPlatformStyle) ~= "function" then
		return false
	end

	local previous = tracker.ApplyPlatformStyle
	-- Assigned on the instance, so the class method is left alone for the other panels that
	-- inherit from ZO_HUDTracker_Base. ZO_PlatformStyle calls this through self:, so the
	-- instance field is what it finds.
	tracker.ApplyPlatformStyle = function(trackerSelf, style)
		previous(trackerSelf, style)
		addon:StyleHudTrackerLabels(section, trackerSelf)
	end

	self.hooked[section.key] = true
	-- Its fonts were set when the client built the UI, before this hook existed, so the labels
	-- on screen are still the game's own -- pristine, and the one moment to measure them.
	self:StyleHudTrackerLabels(section, tracker)
	return true
end

-- Measures then styles the panel's labels. Called from inside the wrapper, so the game's own
-- ApplyPlatformStyle has just run and every label is pristine.
function addon:StyleHudTrackerLabels(section, tracker)
	tracker = tracker or self:TrackerFor(section)
	if not tracker then
		return false
	end

	for _, role in ipairs(section.roles) do
		for _, labelField in ipairs(role.labels) do
			local control = tracker[labelField]
			if control then
				self:MeasureDefault(control, role.key)
				self:StyleLabel(control, role.key)
			end
		end
	end

	-- The gaps between those labels live on the style table's anchors, so they are scaled
	-- before RefreshAnchors puts the anchors back on the controls.
	self:ScaleHudTrackerSpacing(section, tracker)

	-- The labels are anchored to each other's bottoms, so a size change moves everything under
	-- them. RefreshAnchors is the tracker's own way of settling that, and it is also what
	-- re-places the lower lines when one above them is hidden.
	if type(tracker.RefreshAnchors) == "function" then
		pcall(tracker.RefreshAnchors, tracker)
	end
	return true
end

-- Re-draws one of these panels with the current settings.
--
-- Going back through ApplyPlatformStyle is what restores the game's own fonts, exactly as with
-- the quest tracker -- and since our wrapper is on that method, one call does both halves.
-- currentStyle is the platform table the base class stored the last time it ran; without it
-- the tracker has not been initialised yet and there is nothing to refresh.
function addon:RefreshHudTracker(section)
	local tracker = self:TrackerFor(section)
	if not tracker or type(tracker.ApplyPlatformStyle) ~= "function" then
		return false
	end
	local style = tracker.currentStyle
	if not style then
		return false
	end
	pcall(tracker.ApplyPlatformStyle, tracker, style)
	return true
end

-- ---------------------------------------------------------------------------------------
-- Both at once
-- ---------------------------------------------------------------------------------------

function addon:Refresh(sectionKey)
	for _, section in ipairs(self.sections) do
		if sectionKey == nil or sectionKey == section.key then
			if section.kind == "pool" then
				self:RefreshQuest()
			else
				self:RefreshHudTracker(section)
			end
		end
	end
end

function addon:ResetSection(sectionKey)
	local settings = self:Settings(sectionKey)
	settings.enabled = self.sectionDefaults.enabled
	settings.face = self.sectionDefaults.face
	settings.style = self.sectionDefaults.style
	-- The measurements are kept: they are what the client draws, not a setting, and throwing
	-- them away would only put the sliders back on the unscaled fallback numbers.
	settings.sizes = { Gamepad = {}, Keyboard = {} }
	self:Refresh(sectionKey)
end

function addon:ResetToDefaults()
	for _, section in ipairs(self.sections) do
		self:ResetSection(section.key)
	end
end

-- ---------------------------------------------------------------------------------------
-- Status
-- ---------------------------------------------------------------------------------------

local function DescribeControl(control)
	if not control then
		return "none"
	end
	local face = type(control.GetFontFaceName) == "function" and select(2, pcall(control.GetFontFaceName, control)) or "?"
	local size = type(control.GetFontSize) == "function" and select(2, pcall(control.GetFontSize, control)) or "?"
	local style = type(control.GetFontStyle) == "function" and select(2, pcall(control.GetFontStyle, control)) or "?"
	return string.format("%s | %s | %s", tostring(face), tostring(size), tostring(style))
end

-- One live label for a role, whichever tracker it belongs to, so status reports what the
-- client is really drawing rather than what the add-on believes it asked for.
function addon:SampleControl(roleKey)
	local role = self.roleByKey[roleKey]
	if role.poolName then
		local tracker = self:QuestTracker()
		local pool = tracker and tracker[role.poolName]
		if pool and type(pool.GetActiveObjects) == "function" then
			for _, control in pairs(pool:GetActiveObjects()) do
				return control
			end
		end
		return nil
	end

	local tracker = self:TrackerFor(self.sectionOfRole[roleKey])
	if not tracker then
		return nil
	end
	return tracker[role.labels[1]]
end

function addon:PrintStatus()
	local platform = self:Platform()

	local hooked = self.hooked or {}

	Line("|cFF69B4%s|r", self.title)
	Line("  platform=%s", platform)

	for _, section in ipairs(self.sections) do
		local settings = self:Settings(section.key)
		local found = (section.kind == "pool" and self:QuestTracker() or self:TrackerFor(section)) and "found" or "MISSING"
		Line("  [%s] tracker=%s hooked=%s enabled=%s face=%q style=%q", section.key,
			found, tostring(hooked[section.key] or false),
			tostring(settings.enabled), tostring(settings.face), tostring(settings.style))
		for _, role in ipairs(section.roles) do
			Line("    %s: size=%s default=%s ratio=%.2f differs=%s", role.key,
				tostring(self:SizeFor(role.key)), tostring(self:DefaultSize(role.key)),
				self:SizeRatio(role.key), tostring(self:RoleDiffers(role.key)))
			Line("      written=%s", tostring(self.lastDescriptor and self.lastDescriptor[role.key]))
			Line("      on screen=%s", DescribeControl(self:SampleControl(role.key)))
		end
	end

	if self:GetNumTracked() == 0 then
		Line("  no quest is being tracked, so the quest tracker has no labels to read.")
	end
	if self:TrackerFor(self.sectionByKey.house) and not self:InHouse() then
		Line("  you are not in a house, so the house labels are there but not on screen.")
	end
end

function addon:GetNumTracked()
	local tracker = self:QuestTracker()
	if not tracker or type(tracker.GetNumTracked) ~= "function" then
		return 0
	end
	local ok, count = pcall(tracker.GetNumTracked, tracker)
	return ok and count or 0
end

function addon:InHouse()
	local state = HOUSING_EDITOR_STATE
	if not state or type(state.IsHouseInstance) ~= "function" then
		return false
	end
	local ok, inHouse = pcall(state.IsHouseInstance, state)
	return ok and inHouse or false
end

-- ---------------------------------------------------------------------------------------
-- Slash commands
-- ---------------------------------------------------------------------------------------

local function Usage()
	Line("|cFF69B4%s|r", addon.title)
	Line("  %s                        -- this list", SLASH)
	Line("  %s status                 -- settings, and the font actually on screen", SLASH)
	Line("  %s quest <n>              -- all three quest tracker sizes", SLASH)
	Line("  %s quest <part> <n>       -- one part: name | step | goal", SLASH)
	Line("  %s pursuit <n>            -- both Golden Pursuits sizes", SLASH)
	Line("  %s pursuit <part> <n>     -- one part: name | detail", SLASH)
	Line("  %s house <n>              -- both house tracker sizes", SLASH)
	Line("  %s house <part> <n>       -- one part: name | detail", SLASH)
	Line("  %s size <n>               -- every size in both", SLASH)
	Line("  %s on | off               -- every section", SLASH)
	Line("  %s <section> on | off     -- one section only: quest | pursuit | house", SLASH)
	Line("  %s reset                  -- back to the game's own fonts", SLASH)
	Line("  (%s is the same command)", SHORT_SLASH)
end

local function ApplySizeToRoles(roles, size, what)
	size = math.max(addon.MIN_SIZE, math.min(addon.MAX_SIZE, math.floor(size)))
	local touched = {}
	for _, role in ipairs(roles) do
		addon:SetSizeFor(role.key, size)
		local sectionKey = role.sectionKey
		if not touched[sectionKey] then
			touched[sectionKey] = true
			addon:Settings(sectionKey).enabled = true
		end
	end
	for sectionKey in pairs(touched) do
		addon:Refresh(sectionKey)
	end
	Line("%s font size: %d", what, size)
end

local function SetSectionEnabled(sectionKey, enabled)
	addon:Settings(sectionKey).enabled = enabled
	addon:Refresh(sectionKey)
end

-- "quest 30", "quest goal 30", "quest off". Returns false if nothing here matched, so the
-- caller can fall through to the usage text rather than swallowing a typo.
local function HandleSectionCommand(section, args)
	local first = (args[2] or ""):lower()

	if first == "on" or first == "off" then
		SetSectionEnabled(section.key, first == "on")
		Line("%s: custom font %s", section.key, first)
		return true
	end

	local size = tonumber(first)
	if size then
		ApplySizeToRoles(section.roles, size, section.key)
		return true
	end

	for _, role in ipairs(section.roles) do
		if role.command == first then
			local roleSize = tonumber(args[3])
			if not roleSize then
				Line("usage: %s %s %s <%d-%d>", SLASH, section.key, role.command, addon.MIN_SIZE, addon.MAX_SIZE)
				return true
			end
			ApplySizeToRoles({ role }, roleSize, section.key .. " " .. role.command)
			return true
		end
	end

	return false
end

local function OnSlash(argumentString)
	local args = {}
	for word in tostring(argumentString or ""):gmatch("%S+") do
		args[#args + 1] = word
	end

	local command = (args[1] or ""):lower()
	local section = addon.sectionByKey[command]

	if command == "status" then
		addon:PrintStatus()
		return
	end

	if section then
		if HandleSectionCommand(section, args) then
			return
		end
		local parts = {}
		for _, role in ipairs(section.roles) do
			parts[#parts + 1] = role.command
		end
		Line("usage: %s %s <%d-%d> | %s <part> <n> | %s on|off",
			SLASH, section.key, addon.MIN_SIZE, addon.MAX_SIZE, section.key, section.key)
		Line("       parts: %s", table.concat(parts, " | "))
		return
	end

	if command == "size" then
		local size = tonumber(args[2])
		if not size then
			Line("usage: %s size <%d-%d>", SLASH, addon.MIN_SIZE, addon.MAX_SIZE)
			return
		end
		local allRoles = {}
		for _, eachSection in ipairs(addon.sections) do
			for _, role in ipairs(eachSection.roles) do
				allRoles[#allRoles + 1] = role
			end
		end
		ApplySizeToRoles(allRoles, size, "all")
	elseif command == "on" or command == "off" then
		for _, eachSection in ipairs(addon.sections) do
			SetSectionEnabled(eachSection.key, command == "on")
		end
		Line("custom fonts %s in every tracker", command)
	elseif command == "reset" then
		addon:ResetToDefaults()
		Line("reset -- every part of every tracker is back to the game's own font")
	else
		Usage()
	end
end

-- ---------------------------------------------------------------------------------------
-- Bootstrap
-- ---------------------------------------------------------------------------------------

-- FOCUSED_QUEST_TRACKER is created from ZO_FocusedQuestTrackerPanel's OnInitialized and
-- HOUSE_INFORMATION_TRACKER from ZO_HouseInformationTrackerTopLevel's, both while the ingame
-- UI is built -- before add-ons load. Hooking at EVENT_ADD_ON_LOADED is therefore the normal
-- path; the retry at EVENT_PLAYER_ACTIVATED is only there so a client that ordered it the
-- other way round is not left unhooked for the session.
local function HookAll()
	local allOk = true
	addon.reportedMissing = addon.reportedMissing or {}

	for _, section in ipairs(addon.sections) do
		local ok
		if section.kind == "pool" then
			ok = addon:HookQuestTracker()
		else
			ok = addon:HookHudTracker(section)
		end

		if not ok then
			allOk = false
			if not addon.reportedMissing[section.key] then
				addon.reportedMissing[section.key] = true
				Line("|cFF69B4%s|r: the %s panel was not found, so it has not been changed.", addon.title, section.key)
				Line("  Run '%s status' and send the lines it prints.", SLASH)
			end
		end
	end

	return allOk
end

-- How long after the first zone load to wait before touching either tracker.
--
-- Only the first apply of a session can make the client build a font, and the moment right
-- after a loading screen is the worst time to ask for one: every add-on is initialising at
-- once against the 100 MB pool console add-ons share. That is what was killing PB's
-- NamePlateChanger, and a second's delay costs nothing here -- there is no per-zone re-apply
-- to lag behind, because the hooks keep every tracker styled by themselves.
local FIRST_APPLY_DELAY_MS = 1000

local function OnPlayerActivated()
	HookAll()

	-- Only the first activation needs this. The quest labels for a quest that was already
	-- being tracked were acquired before the hook existed; every acquire after this one goes
	-- through the hook, and the HUD panels are styled by HookHudTracker as it attaches.
	if addon.firstApplyDone then
		return
	end
	addon.firstApplyDone = true

	if zo_callLater then
		zo_callLater(function()
			addon:Refresh()
		end, FIRST_APPLY_DELAY_MS)
	else
		addon:Refresh()
	end
end

local function OnAddOnLoaded(_, loadedName)
	if loadedName ~= addon.name then
		return
	end
	EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)

	addon.account = ZO_SavedVars:NewAccountWide("PBsQuestTrackerFontChanger_Data", 1, nil, addon.accountDefaults)
	addon.droppedFace = addon:DropRetiredFace()

	SLASH_COMMANDS[SLASH] = OnSlash
	SLASH_COMMANDS[SHORT_SLASH] = OnSlash

	HookAll()

	if addon.InitSettings then
		addon:InitSettings()
	end

	EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

	-- Switching between keyboard and gamepad mode makes every tracker re-apply its own
	-- platform fonts, which wipes ours. Their handlers and this one are all on the same event
	-- with no guaranteed order, so ours is deferred by a frame rather than racing them. On
	-- console this never fires.
	if EVENT_GAMEPAD_PREFERRED_MODE_CHANGED then
		EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, function()
			if zo_callLater then
				zo_callLater(function()
					addon:Refresh()
				end, 100)
			else
				addon:Refresh()
			end
		end)
	end
end

PBS_QUEST_TRACKER_FONT_CHANGER = addon
EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
