-- @TODO
-- full localisation
-- controller mode
-- actual guild tabard icon + guildname

--------------------------------------------------------------------------------
-- Load in global variables --
--------------------------------------------------------------------------------
ArmoryStyleManager = {
	variableVersion = 1,
	color = {
		defaultText = GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_NORMAL)
	},

	-- setting ids for internal use, using strings because they are used as keys
	-- in a table that also uses ingame category ids as keys, and we don't know
	-- which ids might be added to the game in the future;
	-- making these part of the ArmoryStyleManager table for easy access in
	-- ArmoryStyleManager_Menu.lua
	DISPLAY_SETTING_CUSTOM_RECALL = "customrecall",
	DISPLAY_SETTING_CUSTOM_GATHERING = "customgathering",
	DISPLAY_SETTING_SKILL_STYLES = "skillstyles",
	DISPLAY_SETTING_TABARD = "tabard",
	DISPLAY_SETTING_GROUP_APPAREL = "groupapparel",
	DISPLAY_SETTING_GROUP_BODY_FEATURES = "groupbodyfeatures",
	DISPLAY_SETTING_GROUP_ANIMAL_COMPANIONS = "groupanimalcompanions",
	DISPLAY_SETTING_GROUP_CUSTOMIZED_ACTIONS = "groupcustomizedactions",
}

-- delay between UseCollectible retries (ms)
local LOAD_DELAY = 250
-- abort trying to equip collectibles after this (ms)
local MAX_TIME_ELAPSED = 5000

-- less typing
local ASM = ArmoryStyleManager
local WM = WINDOW_MANAGER
local AKB = ARMORY_KEYBOARD
local EM = EVENT_MANAGER

-- used for addon identification
local name = "ArmoryStyleManager"

-- pointers to UI elements
local ExpandedEntry = nil
local UIContainer = nil
local Header = nil
local CurseOutfitRow = nil
local Mundus = nil
local Outfit = nil
local EquipmentRow = nil
local BuildName = nil
local Divider = nil
local RoleButton = nil
local LockButton = nil
local TitleLabel = nil

-- Custom class holding collectible icons and their logic
local IconList = nil

-- 20240903 changed from alphabetical order to display order, since icons are now rendered by iterating over this table
local COLLECTIBLE_TYPES = {
	COLLECTIBLE_CATEGORY_TYPE_POLYMORPH,
	COLLECTIBLE_CATEGORY_TYPE_PERSONALITY,
	COLLECTIBLE_CATEGORY_TYPE_COSTUME,
	COLLECTIBLE_CATEGORY_TYPE_HAT,
	COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY, -- major adornment
	COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY, -- minor adornment
	COLLECTIBLE_CATEGORY_TYPE_SKIN,
	COLLECTIBLE_CATEGORY_TYPE_HAIR,
	COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS,
	COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING,
	COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING,
	COLLECTIBLE_CATEGORY_TYPE_MOUNT,
	COLLECTIBLE_CATEGORY_TYPE_VANITY_PET,
}

-- 20240827: add customized actions
-- populate this table with a list of all customized actions known to the game during init
local CUSTOM_ACTION_COLLECTIBLE_IDS = {}
local CUSTOM_ACTION_CATEGORY_ID = 13 -- found by looking at the collectible data on uesp.net
local CUSTOM_ACTION_RECALL_SUBCATEGORY_ID = 3

-- 20240828: add skill styles
-- populate this table with a list of all customized styles known to the game during init
local SKILLSTYLE_COLLECTIBLE_IDS = {}
local SKILLSTYLE_CATEGORY_ID = 4     -- found by looking at the collectible data on uesp.net
local SKILLSTYLE_SUBCATEGORY_ID = 12 -- found by looking at the collectible data on uesp.net

local GRASHOROG_ID = 9745
local ZUQOTH_ID = 10618

local ICON_PADDING = 10
local ICON_SIZE = 45

local RANDOM_MOUNT_ICON = {
	[1] = "esoui/art/collections/random_favoritemount.dds",
	[2] = "esoui/art/collections/random_anymount.dds",
}

local CURSE_ICON = {
	[0] = nil,
	[1] = "esoui/art/armory/buildicons/buildicon_44.dds",
	[2] = "esoui/art/armory/buildicons/buildicon_45.dds"
}

local ROLE_ICONS = {
	active = {
		[1] = "esoui/art/lfg/gamepad/lfg_roleicon_dps_down.dds",
		[4] = "esoui/art/lfg/gamepad/lfg_roleicon_healer_down.dds",
		[2] = "esoui/art/lfg/gamepad/lfg_roleicon_tank_down.dds",
	},
	notActive = {
		[1] = "esoui/art/lfg/gamepad/lfg_roleicon_dps_up.dds",
		[4] = "esoui/art/lfg/gamepad/lfg_roleicon_healer_up.dds",
		[2] = "esoui/art/lfg/gamepad/lfg_roleicon_tank_up.dds",
	}
}

local TABARD_ICON = "esoui/art/guild/guild_heraldryaccess.dds"

local showDebug = nil

-- 20240826: added randomMountType to builds to support the new feature, default set to 0 (disabled) to keep existing behavior when not set by player
-- 20240827: added customizedActions to builds to support the feature, default set to empty table to keep old behavior for existing builds, newly saved builds will have a populated table
-- 20240828: added skillStyles to builds, default to nil to keep old behavior for existing builds, newly saved builds will have a table assigned to this
-- 20240904: changed default value in the defaultData["builds"][buildnr]["collectibles"] table from 0 to nil; this allows to check whether we have no saved data (fresh install, nil) or saved data saying no collectible active for the category (existing installs, 0); doing so will prevent new users from losing their current selection of collectibles when loading a build without first saving it with the collectible selection attached;
-- 20240919: added title (default nil)
-- 20240921: changed randomMountType to nil => loading a build with no data (new install) while random mount is selected will no longer overwrite current setting
local defaultData = {
	-- 20240927 allow buffering of collectible ids to equip later on zone change (currently only for pets)
	needsUpdate = {},

	builds = {
		[1] = {
			locked = false,
			role = nil,
			roleActive = true,
			tabard = nil,
			randomMountType = nil,
			collectibles = {
				[2] = nil,
				[3] = nil,
				[4] = nil,
				[9] = nil,
				[10] = nil,
				[11] = nil,
				[12] = nil,
				[13] = nil,
				[14] = nil,
				[15] = nil,
				[16] = nil,
				[17] = nil,
				[18] = nil,
			},
			customizedActions = {},
			skillStyles = nil,
			title = nil,
		},
		[2] = {
			locked = false,
			role = nil,
			roleActive = true,
			tabard = nil,
			randomMountType = nil,
			collectibles = {
				[2] = nil,
				[3] = nil,
				[4] = nil,
				[9] = nil,
				[10] = nil,
				[11] = nil,
				[12] = nil,
				[13] = nil,
				[14] = nil,
				[15] = nil,
				[16] = nil,
				[17] = nil,
				[18] = nil,
			},
			customizedActions = {},
			skillStyles = nil,
			title = nil,
		},
		[3] = {
			locked = false,
			role = nil,
			roleActive = true,
			tabard = nil,
			randomMountType = nil,
			collectibles = {
				[2] = nil,
				[3] = nil,
				[4] = nil,
				[9] = nil,
				[10] = nil,
				[11] = nil,
				[12] = nil,
				[13] = nil,
				[14] = nil,
				[15] = nil,
				[16] = nil,
				[17] = nil,
				[18] = nil,
			},
			customizedActions = {},
			skillStyles = nil,
			title = nil,
		},
		[4] = {
			locked = false,
			role = nil,
			roleActive = true,
			tabard = nil,
			randomMountType = nil,
			collectibles = {
				[2] = nil,
				[3] = nil,
				[4] = nil,
				[9] = nil,
				[10] = nil,
				[11] = nil,
				[12] = nil,
				[13] = nil,
				[14] = nil,
				[15] = nil,
				[16] = nil,
				[17] = nil,
				[18] = nil,
			},
			customizedActions = {},
			skillStyles = nil,
			title = nil,
		},
		[5] = {
			locked = false,
			role = nil,
			roleActive = true,
			tabard = nil,
			randomMountType = nil,
			collectibles = {
				[2] = nil,
				[3] = nil,
				[4] = nil,
				[9] = nil,
				[10] = nil,
				[11] = nil,
				[12] = nil,
				[13] = nil,
				[14] = nil,
				[15] = nil,
				[16] = nil,
				[17] = nil,
				[18] = nil,
			},
			customizedActions = {},
			skillStyles = nil,
			title = nil,
		},
		[6] = {
			locked = false,
			role = nil,
			roleActive = true,
			tabard = nil,
			randomMountType = nil,
			collectibles = {
				[2] = nil,
				[3] = nil,
				[4] = nil,
				[9] = nil,
				[10] = nil,
				[11] = nil,
				[12] = nil,
				[13] = nil,
				[14] = nil,
				[15] = nil,
				[16] = nil,
				[17] = nil,
				[18] = nil,
			},
			customizedActions = {},
			skillStyles = nil,
			title = nil,
		},
		[7] = {
			locked = false,
			role = nil,
			roleActive = true,
			tabard = nil,
			randomMountType = nil,
			collectibles = {
				[2] = nil,
				[3] = nil,
				[4] = nil,
				[9] = nil,
				[10] = nil,
				[11] = nil,
				[12] = nil,
				[13] = nil,
				[14] = nil,
				[15] = nil,
				[16] = nil,
				[17] = nil,
				[18] = nil,
			},
			customizedActions = {},
			skillStyles = nil,
			title = nil,
		},
		[8] = {
			locked = false,
			role = nil,
			roleActive = true,
			tabard = nil,
			randomMountType = nil,
			collectibles = {
				[2] = nil,
				[3] = nil,
				[4] = nil,
				[9] = nil,
				[10] = nil,
				[11] = nil,
				[12] = nil,
				[13] = nil,
				[14] = nil,
				[15] = nil,
				[16] = nil,
				[17] = nil,
				[18] = nil,
			},
			customizedActions = {},
			skillStyles = nil,
			title = nil,
		},
		[9] = {
			locked = false,
			role = nil,
			roleActive = true,
			tabard = nil,
			randomMountType = nil,
			collectibles = {
				[2] = nil,
				[3] = nil,
				[4] = nil,
				[9] = nil,
				[10] = nil,
				[11] = nil,
				[12] = nil,
				[13] = nil,
				[14] = nil,
				[15] = nil,
				[16] = nil,
				[17] = nil,
				[18] = nil,
			},
			customizedActions = {},
			skillStyles = nil,
			title = nil,
		},
		[10] = {
			locked = false,
			role = nil,
			roleActive = true,
			tabard = nil,
			randomMountType = nil, 
			collectibles = {
				[2] = nil,
				[3] = nil,
				[4] = nil,
				[9] = nil,
				[10] = nil,
				[11] = nil,
				[12] = nil,
				[13] = nil,
				[14] = nil,
				[15] = nil,
				[16] = nil,
				[17] = nil,
				[18] = nil,
			},
			customizedActions = {},
			skillStyles = nil,
			title = nil,
		}
	}
}

--------------------------------------------------------------------------------
-- Utility functions for settings menu --
--------------------------------------------------------------------------------

--- @param table table
--- @param value any
--- @return boolean
local function TableContains(table, value)
	for _, v in pairs(table) do
		if v == value then return true end
	end

	return false
end

--- @param categoryId integer
--- @return boolean 
local function IsApparel(categoryId)
	return TableContains(
	{
		COLLECTIBLE_CATEGORY_TYPE_COSTUME,
		COLLECTIBLE_CATEGORY_TYPE_HAT,
		COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY,
		COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY,
	},
	categoryId
	)
end

--- @param categoryId integer
--- @return boolean 
local function IsBodyFeature(categoryId)
	return TableContains(
	{
		COLLECTIBLE_CATEGORY_TYPE_HAIR,
		COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS,
		COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING,
		COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING,
		COLLECTIBLE_CATEGORY_TYPE_SKIN,
	},
	categoryId
	)
end

--- @param categoryId integer
--- @return boolean 
local function IsAnimalCompanion(categoryId)
	return TableContains(
	{
		COLLECTIBLE_CATEGORY_TYPE_MOUNT,
		COLLECTIBLE_CATEGORY_TYPE_VANITY_PET,
	},
	categoryId
	)
end

--------------------------------------------------------------------------------
-- Menu object and utility functions used by it --
--------------------------------------------------------------------------------

ASM_MENU = {} -- uses libAddonMenu2-0

-- @return void
local function InitDisplaySettings()
	ASM.savedVariables.displaySettings = ASM.savedVariables.displaySettings or {}
end

--- @param category integer|string One of the DISPLAY_SETTING values
--- @return boolean
function ASM:GetDisplaySetting(category)
	InitDisplaySettings()
	-- default values if nothing saved
	if self.savedVariables.displaySettings[category] == nil then
		if TableContains(
			{
				ASM.DISPLAY_SETTING_GROUP_APPAREL,
				ASM.DISPLAY_SETTING_GROUP_BODY_FEATURES,
				ASM.DISPLAY_SETTING_GROUP_ANIMAL_COMPANIONS,
				ASM.DISPLAY_SETTING_GROUP_CUSTOMIZED_ACTIONS,
			},
			category
			) then
			self.savedVariables.displaySettings[category] = false
		else
			self.savedVariables.displaySettings[category] = true
		end
	end

	return self.savedVariables.displaySettings[category]
end

--- @param category integer|string One of the DISPLAY_SETTING values
--- @param value boolean
--- @return void
function ASM:SetDisplaySetting(category, value)
	InitDisplaySettings()

	self.savedVariables.displaySettings[category] = value
end

--- @return table COLLECTIBLE_TYPES
function ASM:GetCollectibleTypes()
	return COLLECTIBLE_TYPES
end

--------------------------------------------------------------------------------
-- Utility functions --
--------------------------------------------------------------------------------

--- @return integer AKB.selectedBuildIndex
local function GetSelectedBuildIndex()
	-- @TODO - controller support
	return AKB.selectedBuildIndex
end

--- @return table savedBuildData
local function GetSelectedBuildData()
	return ASM.savedVariables.builds[GetSelectedBuildIndex()]
end

--- @return boolean
local function IsCurrentBuildLocked()
	return GetSelectedBuildData().locked
end

--- @param message string
--- @return void
local function dbg(message, ...)
	if showDebug then
		d(string.format(message, ...))
	end
end

--------------------------------------------------------------------------------
-- UI elements --
--------------------------------------------------------------------------------

-- used to create the "lock/unlock build" and "save/don't save role" buttons
--- @param name string
--- @param parent Control
--- @return Control button
local function CreateButton(name, parent)
	local button = WM:CreateControl(name, parent, CT_BUTTON)

	button:SetInheritScale(false)
	button:SetDrawTier(DT_HIGH)
	button:SetDrawLayer(DL_OVERLAY)
	button:SetMouseEnabled(true)
	button:SetState(BSTATE_NORMAL)
	button:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	button:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	button:SetFont("ZoFontHeader")
	button:SetNormalTexture("ESOUI/art/miscellaneous/gamepad/gp_icon_locked32.dds")

	return button
end

--- @return Control button
local function CreateLockButton()
	local button = CreateButton("ArmoryStyleManager-lock", Header)

	button:SetDimensions(32, 32)
	button:SetAnchor(RIGHT, Collapse, RIGHT, -30, 0)

	button:SetHandler("OnMouseUp", function(self)
		local currentBuild = ASM.savedVariables.builds[AKB.selectedBuildIndex]

		currentBuild.locked = not currentBuild.locked
		KEYBIND_STRIP:UpdateKeybindButtonGroup(AKB.keybindStripDescriptor)

		ASM:RefreshUI()
	end)

	return button
end

--- @return Control button
local function CreateRoleButton()
	local button = CreateButton("ArmoryStyleManager-role", Header)

	button:SetDimensions(ICON_SIZE, ICON_SIZE)
	button:SetAnchor(RIGHT, Collapse, LEFT, -45, 0)

	button:SetHandler("OnMouseUp", function(self)
		local currentBuild = ASM.savedVariables.builds[AKB.selectedBuildIndex]

		currentBuild.roleActive = not currentBuild.roleActive

		ASM:RefreshUI()
	end)

	return button
end

--- @return Control label
local function CreateTitleLabel()
	local label = WM:CreateControl("ArmoryStyleManager-title", Header, CT_LABEL)

	label:SetFont("ZoFontWinH4")
	label:SetAnchor(TOP, BuildName, BOTTOM)

	return label
end

local ArmoryStyleManagerIconList = ZO_ControlPool:Subclass()

--- @return ArmoryStyleManagerIconList IconList
function ArmoryStyleManagerIconList:New()
	local CollectibleIconList = ZO_ControlPool.New(self, "ArmoryStyleManagerIcon", CurseOutfitRow)
	CollectibleIconList:InitDataAndAnchors()

	return CollectibleIconList
end

--- @return void
function ArmoryStyleManagerIconList:InitDataAndAnchors()
	self.iconData = {}
	self.groupedApparel = ASM:GetDisplaySetting(ASM.DISPLAY_SETTING_GROUP_APPAREL)
	self.groupedBodyFeatures = ASM:GetDisplaySetting(ASM.DISPLAY_SETTING_GROUP_BODY_FEATURES)
	self.groupedAnimalCompanions = ASM:GetDisplaySetting(ASM.DISPLAY_SETTING_GROUP_ANIMAL_COMPANIONS)
	self.groupedCustomizedActions = ASM:GetDisplaySetting(ASM.DISPLAY_SETTING_GROUP_CUSTOMIZED_ACTIONS)
	self.apparelIconId = nil
	self.bodyFeaturesIconId = nil
	self.animalCompanionsIconId = nil
	self:ResetAnchors()
end

--- @return void
function ArmoryStyleManagerIconList:Reset()
	if not self.iconData or #self.iconData == 0 then return end
	self:ReleaseAllObjects()
	self:InitDataAndAnchors()
end

--- @return void
function ArmoryStyleManagerIconList:ResetAnchors()
	Mundus:SetAnchor(TOPLEFT, Divider, BOTTOMLEFT, 15, 27)
	Outfit:ClearAnchors()
	Outfit:SetAnchor(TOPLEFT, Mundus, TOPRIGHT, ICON_PADDING)
end

--- @return boolean
function ArmoryStyleManagerIconList:HasPoly()
	return GetSelectedBuildData().collectibles[COLLECTIBLE_CATEGORY_TYPE_POLYMORPH] and GetSelectedBuildData().collectibles[COLLECTIBLE_CATEGORY_TYPE_POLYMORPH] > 1
end

--- @return boolean
function ArmoryStyleManagerIconList:HasSkin()
	return GetSelectedBuildData().collectibles[COLLECTIBLE_CATEGORY_TYPE_SKIN] and GetSelectedBuildData().collectibles[COLLECTIBLE_CATEGORY_TYPE_SKIN] > 1
end

--- @param path string
--- @param tooltip string
--- @return integer index
function ArmoryStyleManagerIconList:Add(path, tooltip)
	table.insert(self.iconData, { path = path, tooltip = tooltip })

	return #self.iconData
end

--- @param categoryId integer
--- @return void
function ArmoryStyleManagerIconList:AddGroupedByCategoryId(categoryId)
	local collectibleId = GetSelectedBuildData().collectibles[categoryId]

	if collectibleId and collectibleId > 1 then
		local name, _, iconPath = GetCollectibleInfo(collectibleId)
		local tooltip = ""

		if IsApparel(categoryId) then
			if not self.apparelIconId then
				-- no icon selected for apparel icon, use icon of current collectible
				self.apparelIconId = self:Add(iconPath, "Apparel\n")
			end

			tooltip = zo_strformat("|t20:20:<<1>>|t <<2>>: <<3>>", iconPath, GetString("SI_COLLECTIBLECATEGORYTYPE", categoryId), name)
			self.iconData[self.apparelIconId]["tooltip"] = self.iconData[self.apparelIconId]["tooltip"] .. "\n" .. tooltip
		elseif IsBodyFeature(categoryId) then
			if not self.bodyFeaturesIconId then
				-- no icon selected for body features icon, use icon of current collectible
				self.bodyFeaturesIconId = self:Add(iconPath, "Body Features\n")
			end

			tooltip = zo_strformat("|t20:20:<<1>>|t <<2>>: <<3>>", iconPath, GetString("SI_COLLECTIBLECATEGORYTYPE", categoryId), name)
			self.iconData[self.bodyFeaturesIconId]["tooltip"] = self.iconData[self.bodyFeaturesIconId]["tooltip"] .."\n" .. tooltip
		elseif IsAnimalCompanion(categoryId) then
			if categoryId == COLLECTIBLE_CATEGORY_TYPE_MOUNT and GetSelectedBuildData().randomMountType > 0 then
				name = GetString("SI_RANDOMMOUNTTYPE", GetSelectedBuildData().randomMountType)
				iconPath = RANDOM_MOUNT_ICON[GetSelectedBuildData().randomMountType]
			end

			if not self.animalCompanionsIconId then
				self.animalCompanionsIconId = self:Add(iconPath, "Animal Companions\n")
			end

			tooltip = zo_strformat("|t20:20:<<1>>|t <<2>>: <<3>>", iconPath, GetString("SI_COLLECTIBLECATEGORYTYPE", categoryId), name)
			self.iconData[self.animalCompanionsIconId]["tooltip"] = self.iconData[self.animalCompanionsIconId]["tooltip"] .. "\n" .. tooltip
		end
	end
end

--- @param collectibleId integer
--- @return string dyeString
function ArmoryStyleManagerIconList:GetDyeString(collectibleId)
	local dye1, dye2, dye3 = GetCurrentCollectibleDyes(RESTYLE_MODE_COLLECTIBLE, collectibleId)
	local tooltipText = ""
	local dye1Text, dye2Text, dye3Text = "", "", ""

	if dye1 > 0 or dye2 > 0 or dye3 > 0 then
		tooltipText = "\n\nDyes: "

		if dye1 > 0 then
			dye1Text = string.format("%s, ", GetDyeInfoById(dye1))
		else
			dye1Text = "none, "
		end

		if dye2 > 0 then
			dye2Text = string.format("%s, ", GetDyeInfoById(dye2))
		else
			dye2Text = "none, "
		end

		if dye3 > 0 then
			dye3Text = GetDyeInfoById(dye3)
		else
			dye3Text = "none"
		end
	end

	return string.format("%s%s%s%s", tooltipText, dye1Text, dye2Text, dye3Text)
end

--- @param categoryId integer
--- @return void
function ArmoryStyleManagerIconList:AddByCategoryId(categoryId)
	if (self.groupedApparel and IsApparel(categoryId))
		or (self.groupedBodyFeatures and IsBodyFeature(categoryId))
		or (self.groupedAnimalCompanions and IsAnimalCompanion(categoryId)) then
		self:AddGroupedByCategoryId(categoryId)
	else
		local collectibleId = GetSelectedBuildData().collectibles[categoryId]

		if collectibleId and collectibleId > 1 then -- @todo existing logic checks for > 1 but should this be > 0?
			local name, description, iconPath, tooltip
			local category = GetString("SI_COLLECTIBLECATEGORYTYPE", categoryId)
			--local category = GetCollectibleCategoryNameByCollectibleId(collectibleId) -- fails for mounts/pets, showing "bipedals" not "mounts", "daedric" not "pets"
			--local category = GetCollectibleCategoryNameByCategoryId(categoryId) -- fails spectacularly

			local randomMountType = GetSelectedBuildData().randomMountType
			if categoryId == COLLECTIBLE_CATEGORY_TYPE_MOUNT and randomMountType and randomMountType > 0 then
				name = GetString("SI_RANDOMMOUNTTYPE", randomMountType)
				iconPath = RANDOM_MOUNT_ICON[randomMountType]
				tooltip = string.format("%s: %s", category, name)
			else
				name, description, iconPath = GetCollectibleInfo(collectibleId)
				tooltip = string.format("%s: %s\n\n%s", category, name, description)

				-- append dye information to tooltip if applied
				if categoryId == COLLECTIBLE_CATEGORY_TYPE_HAT or categoryId == COLLECTIBLE_CATEGORY_TYPE_COSTUME then
					tooltip = tooltip .. self:GetDyeString(collectibleId)
				end
			end

			self:Add(iconPath, tooltip)
		end
	end
end

--- @return void
function ArmoryStyleManagerIconList:AddAllCategories()
	-- tabard
	local tabard = tonumber(GetSelectedBuildData().tabard)

	if tabard and tabard > 0 and ASM:GetDisplaySetting(ASM.DISPLAY_SETTING_TABARD) then
		self:Add(TABARD_ICON, "Guild Tabard") -- @todo: localized string
	end

	-- next the "original" type of collectibles
	for _, categoryId in pairs(COLLECTIBLE_TYPES) do
		-- only try to add the icon if it's enabled in the settings menu
		if ASM:GetDisplaySetting(categoryId) then
			-- @TODO look for a way to save the hasPoly/hasSkin limitations in the COLLECTIBLE_TYPES table so we can have cleaner conditional statements here
			if categoryId == COLLECTIBLE_CATEGORY_TYPE_POLYMORPH or
				categoryId == COLLECTIBLE_CATEGORY_TYPE_PERSONALITY or
				categoryId == COLLECTIBLE_CATEGORY_TYPE_MOUNT or
				categoryId == COLLECTIBLE_CATEGORY_TYPE_VANITY_PET then -- always show these
				self:AddByCategoryId(categoryId)
			elseif categoryId == COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING or
				categoryId == COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING then -- only show if not poly and not skin
				if not self:HasPoly() and not self:HasSkin() then
					self:AddByCategoryId(categoryId)
				end
			elseif categoryId == COLLECTIBLE_CATEGORY_TYPE_HAT then                                    -- custom rule
				if not self:HasPoly() and GetSelectedBuildData().collectibles[categoryId] ~= 5002 then -- 5002 => hidden hat?
					self:AddByCategoryId(categoryId)
				end
			else -- everything else shows if not poly
				if not self:HasPoly() then
					self:AddByCategoryId(categoryId)
				end
			end
		end
	end
end

--- @return void
function ArmoryStyleManagerIconList:AddCustomizedActions()
	-- Recalling, show separate unless "grouped" setting enabled
	if not self.groupedCustomizedActions then
		-- Only show when enabled in settings
		if ASM:GetDisplaySetting(ASM.DISPLAY_SETTING_CUSTOM_RECALL) then
			local collectibleId = GetSelectedBuildData().customizedActions[CUSTOM_ACTION_RECALL_SUBCATEGORY_ID]

			if collectibleId and collectibleId > 0 then
				local name, description, iconPath = GetCollectibleInfo(collectibleId)
				local category = GetCollectibleCategoryNameByCollectibleId(collectibleId)

				local tooltip = string.format("%s: %s\n\n%s", category, name, description)
				self:Add(iconPath, tooltip)
			end
		end
	end

	-- Customized gathering actions
	if ASM:GetDisplaySetting(ASM.DISPLAY_SETTING_CUSTOM_GATHERING) then
		-- If one or more are active, use the icon of the first one, and show info on all active ones in the tooltip
		local customGatheringIcon
		local customGatheringTooltip = { GetString(SI_COLLECTIBLECATEGORYTYPE29) .. "\n" }

		for subCategoryId, collectibleId in pairs(GetSelectedBuildData().customizedActions) do
			if (subCategoryId ~= CUSTOM_ACTION_RECALL_SUBCATEGORY_ID or self.groupedCustomizedActions) and collectibleId > 0 then
				local icon = GetCollectibleIcon(collectibleId)
				-- found at least one, use it's iconpath to indicate there are custom gathering actions saved, and show them all in the tooltip
				if not customGatheringIcon then customGatheringIcon = icon end
				table.insert(customGatheringTooltip, zo_strformat("|t20:20:<<1>>|t <<2>>", icon, GetCollectibleName(collectibleId)))
			end
		end

		if customGatheringIcon then
			self:Add(customGatheringIcon, table.concat(customGatheringTooltip, "\n"))
		end
	end
end

--- @return void
function ArmoryStyleManagerIconList:AddSkillStyles()
	-- only add when enabled in settings
	if ASM:GetDisplaySetting(ASM.DISPLAY_SETTING_SKILL_STYLES) then
		local skillStylesIcon
		local skillStylesTooltip = { "Skill Styles\n" } -- @TODO really no localized string for this?

		if GetSelectedBuildData().skillStyles then
			for skillStyleId, active in pairs(GetSelectedBuildData().skillStyles) do
				if active then
					local icon = GetCollectibleIcon(skillStyleId)
					-- found at least one, use it's iconpath to indicate there are custom gathering actions saved, and show them all in the tooltip
					if not skillStylesIcon then skillStylesIcon = icon end
					table.insert(skillStylesTooltip, zo_strformat("|t20:20:<<1>>|t <<2>>", icon, GetCollectibleName(skillStyleId)))
				end
			end
		end

		if skillStylesIcon then
			self:Add(skillStylesIcon, table.concat(skillStylesTooltip, "\n"))
		end
	end
end

--- @param totalWidth integer
--- @param mundusOutfitTwoLines boolean
--- @return integer usableWidth
function ArmoryStyleManagerIconList:CalculateUsableWidth(totalWidth, mundusOutfitTwoLines)
	local textWidth, usableWidth

	if not mundusOutfitTwoLines then
		textWidth = Outfit:GetWidth() + ICON_PADDING + Mundus:GetWidth() -- there's an ICON_PADDING between the two labels
		usableWidth = totalWidth - textWidth - (3 * ICON_PADDING) 
	else
		usableWidth = totalWidth - math.max(Mundus:GetWidth(), Outfit:GetWidth()) - (3 * ICON_PADDING)
	end

	return usableWidth
end

--- @param usableWidth integer
--- @param iconWidth integer
--- @param padding integer
--- @return integer result
function ArmoryStyleManagerIconList:CalculateRoomForIcons(usableWidth, iconWidth, padding)
	local result = math.floor((usableWidth + padding) / (iconWidth + padding))
	return result
end

--- @return void
function ArmoryStyleManagerIconList:Show()
	-- default to showing icons in a single row, increase to 2 rows if needed after available space calculated
	local rows = 1
	local mundusOutfitTwoLines = false
	local iconScale = 1
	local scaledIconSize = ICON_SIZE
	local scaledIconPadding = ICON_PADDING

	-- start checking if we have enough room to display all the icons
	-- if we don't, move outfit info under mundus info, and check again
	-- if we still don't, scale icons down, limited to 45% size (half size to fit on 2 rows minus a couple pixels of padding)
	-- if we still don't, use 2 rows to display the icons

	-- EquipmentRow is a full width container within the armory ui, should be a safe reference point to get our total available width
	-- @TODO: write a cleaner way to provide padding-right to the icon row
	local totalWidth = EquipmentRow:GetWidth() - ICON_PADDING
	local usableWidth = self:CalculateUsableWidth(totalWidth, mundusOutfitTwoLines)
	local roomForIcons = self:CalculateRoomForIcons(usableWidth, scaledIconSize, scaledIconPadding)

	-- Moving and scaling of controls so they can fit
	if roomForIcons < #self.iconData then
		mundusOutfitTwoLines = true
		-- move mundus up a bit
		Mundus:SetAnchor(TOPLEFT, Divider, BOTTOMLEFT, 15, ICON_PADDING + 1) -- same as defined in original xml but smaller y offset
		-- move outfit under mundus
		Outfit:ClearAnchors()
		Outfit:SetAnchor(TOPLEFT, Mundus, BOTTOMLEFT, 0, ICON_PADDING)

		usableWidth = self:CalculateUsableWidth(totalWidth, mundusOutfitTwoLines)
		roomForIcons = self:CalculateRoomForIcons(usableWidth, scaledIconSize, scaledIconPadding)

		if roomForIcons < #self.iconData then
			-- scale icons down
			local iconAndPaddingAvailable = math.floor((usableWidth + scaledIconPadding) / #self.iconData)
			iconScale = math.max(0.70, (iconAndPaddingAvailable / (scaledIconSize + scaledIconPadding))) -- don't go lower than scale 0.45
			scaledIconSize = math.floor(scaledIconSize * iconScale)
			scaledIconPadding = math.floor(scaledIconPadding * iconScale)

			roomForIcons = self:CalculateRoomForIcons(usableWidth, scaledIconSize, scaledIconPadding)
			if roomForIcons < #self.iconData then
				rows = 2
			end
		end
	end

	-- Start displaying the icons
	local columns = roomForIcons
	local currentColumn = 1
	local currentRow = 1
	local lastIcon = nil

	for id, data in pairs(self.iconData) do
		local newIcon, _ = self:AcquireObject()
		newIcon:SetDimensions(scaledIconSize, scaledIconSize)

		if currentColumn == 1 then
			if currentRow == 1 then
				if mundusOutfitTwoLines then
					local topPadding = 18
					if rows > 1 then topPadding = 0 end --scaledIconPadding end
					newIcon:SetAnchor(TOPLEFT, Mundus, TOPLEFT,
					(math.max(Mundus:GetWidth(), Outfit:GetWidth()) + ICON_PADDING),
					topPadding)
				else
					newIcon:SetAnchor(TOPLEFT, Outfit, TOPRIGHT, ICON_PADDING)
				end
			else
				newIcon:SetAnchor(TOPLEFT, Mundus, TOPLEFT,
				(math.max(Mundus:GetWidth(), Outfit:GetWidth()) + ICON_PADDING),
				((currentRow - 1) * scaledIconSize) + (currentRow * 2))
			end
		else
			newIcon:SetAnchor(LEFT, lastIcon, RIGHT, scaledIconPadding)
		end

		newIcon:SetMouseEnabled(true)
		if data['tooltip'] and data['tooltip'] ~= '' then
			newIcon:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, data['tooltip']) end)
			newIcon:SetHandler("OnMouseExit", function(self) ZO_Tooltips_HideTextTooltip() end)
		else
			newIcon:SetHandler("OnMouseEnter", nil)
			newIcon:SetHandler("OnMouseExit", nil)
		end
		newIcon:SetText(zo_strformat("|t<<1>>:<<2>>:<<3>>|t|r", scaledIconSize, scaledIconSize, data['path']))
		newIcon:SetHidden(false)

		lastIcon = newIcon
		self.iconData[id]['icon'] = newIcon

		currentColumn = currentColumn + 1
		if currentColumn > columns then
			currentColumn = 1
			currentRow = currentRow + 1
		end
	end
end

--------------------------------------------------------------------------------
-- /asm command, use for debugging --
--------------------------------------------------------------------------------

--- @param options table
--- @return void
local function ASM_SlashCommand(options)
	local args = {}
	local searchResult = { string.match(options, "^(%S*)%s*(.-)$") }
	for i, v in pairs(searchResult) do
		if (v ~= nil and v ~= "") then
			args[i] = string.lower(v)
		end
	end

	if args[1] == nil or args[1] == "" then
		d("Armory Style manager - /asm usage:")
		d("/asm custom: list all known customized actions and their ids")
		d("/asm skillstyles: list all known skill styles and their ids")
		d("/asm debug on|off: enable/disable skillstyles")
		return
	end

	if args[1] == "custom" then
		d("stored ids for custom actions:")
		for subcategoryId, collectibles in pairs(CUSTOM_ACTION_COLLECTIBLE_IDS) do
			local subcategory = GetCollectibleSubCategoryInfo(CUSTOM_ACTION_CATEGORY_ID, subcategoryId)
			d("subcategory " .. subcategory .. " (" .. subcategoryId .. ")")
			for _, id in pairs(collectibles) do
				d("id " .. id .. ": " .. GetCollectibleInfo(id))
			end
			d("--")
		end
	elseif args[1] == "skillstyles" then
		for _, id in pairs(SKILLSTYLE_COLLECTIBLE_IDS) do
			local result = GetCollectibleInfo(id)
			if IsCollectibleActive(id, GAMEPLAY_ACTOR_CATEGORY_PLAYER) then
				result = result .. " (this style is active)"
			end
			d(result)
		end
	elseif args[1] == "debug" then
		if args[2] == "on" then
			showDebug = true
		elseif args[2] == "off" then
			showDebug = nil
		elseif args[2] ~= nil then
			d("can only turn debug on or off")
		else
			for cat, id in pairs(ASM.savedVariables.needsUpdate) do
				d(string.format("cat %s: id %s", cat, id))
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Event handlers --
--------------------------------------------------------------------------------
--- @return void
function ASM:RefreshUI()
	local selectedBuildIndex = GetSelectedBuildIndex()
	if not IconList then return end

	-- restore defaults in case we made mundus/outfit use two lines to fit more icons
	IconList:Reset()

	-- Set the Curse Text to nothing so we can replace the long string "Curse: Werewolf" with an icon
	CurseOutfitRow:GetNamedChild("CurseType"):SetText("")

	-- 20240831: function is being called once on opening armory ui for the first time in a session, where it has textWidth = 0 and totalWidth = -20, skip further execution in this scenario to avoid weird behavior when making ui size calculations.  Outfit name can't be a blank string, so that alone should ensure this check always works correctly.
	-- 20240903: @TODO check if this covered by the "if not selectedBuildIndex" a bit further => it's not, keep the current check
	local textWidth = CurseOutfitRow:GetNamedChild("Outfit"):GetTextWidth() + Mundus:GetTextWidth()
	if textWidth == 0 then return false end

	if ASM.savedVariables.currentBuildIndex == nil then
		AKB.buildCountLabel:SetText(string.format("Current Builds: %s", GetNumUnlockedArmoryBuilds()))
	else
		AKB.buildCountLabel:SetText(string.format("Current Build: %s", GetArmoryBuildName(ASM.savedVariables.currentBuildIndex)))
	end

	if not selectedBuildIndex then return false end

	-- Vampire
	local curseType = GetArmoryBuildCurseType(selectedBuildIndex)
	if curseType ~= 0 then
		if curseType == 1 then
			IconList:Add(CURSE_ICON[curseType], GetString(SI_CURSETYPE1))
		elseif curseType == 2 then
			IconList:Add(CURSE_ICON[curseType], GetString(SI_CURSETYPE2))
		end
	end

	-- All other icons
	IconList:AddAllCategories()
	IconList:AddCustomizedActions()
	IconList:AddSkillStyles()

	IconList:Show()

	-- Lock
	if IsCurrentBuildLocked() then
		LockButton:SetNormalTexture("ESOUI/art/miscellaneous/gamepad/gp_icon_locked32.dds")
		LockButton:SetAnchor(RIGHT, Collapse, RIGHT, -30, 0)
	else
		LockButton:SetNormalTexture("ESOUI/art/miscellaneous/gamepad/gp_icon_unlocked32.dds")
		LockButton:SetAnchor(RIGHT, Collapse, RIGHT, -27, 0)
	end

	-- Role
	local roleIcon = nil
	local currentRole = GetSelectedBuildData().role
	if currentRole then
		if GetSelectedBuildData().roleActive then
			roleIcon = ROLE_ICONS.active[currentRole]
		else
			roleIcon = ROLE_ICONS.notActive[currentRole]
		end
		RoleButton:SetNormalTexture(roleIcon)
	else
		RoleButton:SetNormalTexture("")
	end

	local titleIndex = ASM.savedVariables.builds[AKB.selectedBuildIndex].title

	if not titleIndex or titleIndex == 0 then
		-- no title, reset buildname anchor
		BuildName:ClearAnchors()
		BuildName:SetAnchor(TOP, Header, TOP, 0, 30)
		TitleLabel:SetHidden(true)
	else
		-- has title, move buildname up and center things
		BuildName:ClearAnchors()
		BuildName:SetAnchor(TOP, Header, TOP, 0, 16)
		TitleLabel:SetHidden(false)
		TitleLabel:ClearAnchors()
		TitleLabel:SetAnchor(TOP, BuildName, BOTTOM, 0, 5)

		-- 20240919 keep supporting the old way where title was saved as a string
        -- @NOTE - titled indices change when you acquire a new title
        -- 20241228 reverted back to saving/loading strings for title
		if type(titleIndex) == "string" then
			TitleLabel:SetText(string.format("<%s>", titleIndex))
		else
			TitleLabel:SetText(string.format("<%s>", GetTitle(titleIndex)))
		end
	end
end

--- @param control Control
--- @return void
local function CreateUI(control)
	ExpandedEntry = control
	UIContainer = ExpandedEntry:GetNamedChild("Container")
	Header = UIContainer:GetNamedChild("Header")
	Collapse = Header:GetNamedChild("Collapse")
	CurseOutfitRow = ExpandedEntry:GetNamedChild("ContainerCurseOutfitRow")
	Mundus = UIContainer:GetNamedChild("Mundus")
	Outfit = CurseOutfitRow:GetNamedChild("Outfit")
	EquipmentRow = UIContainer:GetNamedChild("EquipmentRow")
	BuildName = Header:GetNamedChild("Name")

	-- single hide operation, no need to store these ui objects    
	UIContainer:GetNamedChild("WeaponSets"):SetHidden(true)
	UIContainer:GetNamedChild("WeaponSets"):SetDimensions(0, 1)

	UIContainer:GetNamedChild("EquipmentLabel"):SetHidden(true)
	UIContainer:GetNamedChild("EquipmentLabel"):SetDimensions(0, 1)

	-- additional divider between equipment and mundus/outfit/collectibles, helps separate things after hiding the WeaponSets and EquipmentLabel labels
	Divider = Divider or WM:CreateControlFromVirtual(nil, UIContainer, "ZO_DynamicHorizontalDivider")
	Divider:SetAnchor(TOPLEFT, EquipmentRow, BOTTOMLEFT, -15, 15)
	Divider:SetAnchor(TOPRIGHT, EquipmentRow, BOTTOMRIGHT, -15, 15)

	IconList = IconList or ArmoryStyleManagerIconList:New()

	LockButton = LockButton or CreateLockButton()
	RoleButton = RoleButton or CreateRoleButton()
	TitleLabel = TitleLabel or CreateTitleLabel()
end

--- @param collectibleType integer
--- @return nil|integer result
local function NeedsUpdate(collectibleType)
	return ASM.savedVariables[collectibleType]
end

--- @param buildIndex integer
--- @return void
local function ArmoryBuildSaved(_, _, buildIndex)
	dbg("Saving data for build")
	local collectibles = {}
	local savedBuild = ASM.savedVariables.builds[buildIndex]

	for i, collectibleType in pairs(COLLECTIBLE_TYPES) do
		-- 20241002: prevent following scenario: player enters house with build 1 and pet X active, loads build 2 with pet Y (still pet X active, Y stored in needsUpdate), edits build 2, and saves it with pet X instead of Y
		collectibles[collectibleType] = NeedsUpdate(collectibleType) or GetActiveCollectibleByType(collectibleType)
	end
	savedBuild.collectibles = collectibles
	-- 20240919 save titles as id, no need to use strings only to use them for retrieving the id again
    -- @IMPORTANT - title indices change when you acquire a new title!
    -- 20241228 reverted back to saving/loading strings for title
    if GetCurrentTitleIndex() then
		savedBuild.title = GetTitle(GetCurrentTitleIndex())
	else
		savedBuild.title = 0
	end
	savedBuild.role = GetSelectedLFGRole()
	savedBuild.tabard = Id64ToString(GetItemUniqueId(BAG_WORN, EQUIP_SLOT_COSTUME))

	-- 20240826: add support for random mount / random favorite mount, expected values are 0 (none), 1 (random favorite) and 2 (random)
	local randomMountType = GetRandomMountType(COLLECTIBLE_CATEGORY_TYPE_MOUNT)
	savedBuild.randomMountType = randomMountType

	-- 20240828: save customized actions
	-- loop over all available collectibles in every known category
	-- if a collectible is active, save it using the corresponding categoryId
	-- if no collectible is active, save 0 as collectibleId for that category
	---- this will be the difference between savedVariable data saved before adding support for the feature (customizedActions[categoryId] = nil),
	---- and the ones saved after (customizedActions[categoryId] = 0).
	for categoryId, collectibleIds in pairs(CUSTOM_ACTION_COLLECTIBLE_IDS) do
		local activeCollectible = 0
		for _, collectibleId in pairs(collectibleIds) do
			if IsCollectibleActive(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER) then
				activeCollectible = collectibleId
				break;
			end
		end
		savedBuild.customizedActions[categoryId] = activeCollectible
	end

	-- 20240828: save skill styles
	-- similar to customized actions, but we have just a single array of active skill styles
	-- start by resetting the table, then populate it with the active skill styles
	-- use the collectibleId as table index, and true/false as value
	savedBuild.skillStyles = {}
	for _, collectibleId in pairs(SKILLSTYLE_COLLECTIBLE_IDS) do
		if IsCollectibleActive(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER) then
			savedBuild.skillStyles[collectibleId] = true
		else
			savedBuild.skillStyles[collectibleId] = false
		end
	end

	ASM:RefreshUI()
	dbg("Finished saving data for build")
end

--------------------------------------------------------------------------------
-- UpdateCollectibles --
--------------------------------------------------------------------------------

--- @param newTitleString integer|string 20240919 switched to saving titleId
--- @return void
local function EquipTitle(newTitleString)
	local currentTitle = GetCurrentTitleIndex()
	local newTitle = nil

	if type(newTitleString) == "string" then
		local numTitles = GetNumTitles()
		for titleIdx = 0, numTitles do
			if GetTitle(titleIdx) == newTitleString then
				newTitle = titleIdx
				break
			end
		end
	else
		newTitle = newTitleString
	end

	if currentTitle ~= newTitle then
		SelectTitle(newTitle)
	end
end

--- @param newRole integer 
--- @param roleActive boolean
--- @return void
local function EquipRole(newRole, roleActive)
	if newRole then
		local oldRole = GetSelectedLFGRole()
		if newRole ~= oldRole and CanUpdateSelectedLFGRole() and roleActive then
			UpdateSelectedLFGRole(newRole)
		end
	end
end

--- @param tabard integer
--- @return void
local function EquipTabard(tabard)
	if tabard ~= '0' then
		local bagSize = GetBagSize(BAG_BACKPACK)
		for bagSlot = 0, bagSize do
			local id = Id64ToString(GetItemUniqueId(BAG_BACKPACK, bagSlot))
			if id == tabard then
				EquipItem(BAG_BACKPACK, bagSlot, EQUIP_SLOT_COSTUME)
			end
		end
	else
		-- unequip tabard only if equipped
		if GetItemUniqueId(0, EQUIP_SLOT_COSTUME) then
			UnequipItem(EQUIP_SLOT_COSTUME)
		end
	end
end

--- @return void
local function UpdateNonCollectibles()
	dbg("Updating non-collectibles")
	local savedBuild = ASM.savedVariables.builds[ASM.savedVariables.currentBuildIndex]

	EquipTitle(savedBuild.title)
	EquipRole(savedBuild.role, savedBuild.roleActive)
	EquipTabard(savedBuild.tabard)
end

--------------------------------------------------------------------------------

-- used when trying to use a collectible and waiting for a successful event response
local usedCollectible = {} -- caches data on the collectible we tried to equip
local collectibleLoadAttempts = 0 -- keep track of failed attempts

--- @return void
local function ResetUsedCollectible()
	usedCollectible = {}
	collectibleLoadAttempts = 0
end

--- @param type nil|integer collectibleType (categoryId) if "classic" collectible
--- @param id integer collectibleId
--- @return void
local function TryUseCollectible(type, id)
	usedCollectible.type = type
	usedCollectible.id = id
	collectibleLoadAttempts = 0
	UseCollectible(id, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
end

-- @TODO - figure out a way to extract these 2 functions from EVENT_MANAGER before unregistering AlertTextManager, so we don't need to worry about future updates
-- took this from ingame/alerttext/alerthandlers.lua
local AlertTextManagerHandler = function(result, isAttemptingActivation)
	if result == COLLECTIBLE_USAGE_BLOCK_REASON_NOT_BLOCKED then
		local sound = isAttemptingActivation and SOUNDS.COLLECTIBLE_ACTIVATED or SOUNDS.COLLECTIBLE_DEACTIVATED
		PlaySound(sound)
	else
		local sound = (result == COLLECTIBLE_USAGE_BLOCK_REASON_ON_COOLDOWN) and SOUNDS.COLLECTIBLE_ON_COOLDOWN or SOUNDS.GENERAL_ALERT_ERROR
		return UI_ALERT_CATEGORY_ERROR, zo_strformat(GetString("SI_COLLECTIBLEUSAGEBLOCKREASON", result)), sound
	end
end

-- took this from alerttext_shared.lua
local function OnAlertEvent(eventCode, ...)
	local alertHandlers = ZO_AlertText_GetHandlers()
	if alertHandlers[eventCode] then
		local category, message, soundId, noSuppression = AlertTextManagerHandler(...)
		if category then
			if message and message ~= "" then
				if noSuppression then
					ZO_AlertNoSuppression(category, soundId, message)
				else
					ZO_Alert(category, soundId, message)
				end
			else
				ZO_SoundAlert(category, soundId)
			end
		end
	end
end

--- @return void
local function StopCollectibleHandler()
	if usedCollectible.handler then
		dbg("stopping collectible handler")
		usedCollectible.handler = nil
		ResetUsedCollectible()
		EM:UnregisterForEvent(name, EVENT_COLLECTIBLE_USE_RESULT)
		EM:RegisterForEvent("AlertTextManager", EVENT_COLLECTIBLE_USE_RESULT, OnAlertEvent)
	end
end

--- @param result 
--- @return void
local function ProcessCollectibleResult(_, result, _)
	collectibleLoadAttempts = collectibleLoadAttempts + 1
	dbg("attempt %d", collectibleLoadAttempts)
	local collectibleName = GetCollectibleInfo(usedCollectible.id)

	if result == COLLECTIBLE_USAGE_BLOCK_REASON_NOT_BLOCKED then
		dbg("Armory style manager successfully equipped %s", collectibleName)
	else
		local timeElapsed = collectibleLoadAttempts * LOAD_DELAY
		dbg("time elapsed %d", timeElapsed)
		if (timeElapsed >= MAX_TIME_ELAPSED) then
			d(string.format("Armory Style Manager failed to equip %s for %0.1f seconds, aborting", collectibleName, MAX_TIME_ELAPSED / 1000))
		else
			if result == COLLECTIBLE_USAGE_BLOCK_REASON_ON_COOLDOWN then
				dbg("%s is on cooldown, retry in %d milliseconds", collectibleName, LOAD_DELAY)

				if usedCollectible.id then
					zo_callLater(function() UseCollectible(usedCollectible.id) end, LOAD_DELAY)
					return
				else
					d(string.format("Armory Style Manager encountered an error while handling %s", collectibleName))
				end
			elseif result == COLLECTIBLE_USAGE_BLOCK_REASON_BLOCKED_BY_ZONE
				or result == COLLECTIBLE_USAGE_BLOCK_REASON_BLOCKED_BY_SUBZONE then
				d(string.format("Armory Style Manager can't equip %s in this zone, retrying later.", collectibleName))
				if usedCollectible.type and usedCollectible.id then
					ASM.savedVariables.needsUpdate[usedCollectible.type] = usedCollectible.id
				end
			else
				d(string.format("Armory Style Manager was unable to equip %s", collectibleName))
			end
		end
	end

	ASM:UpdateCollectibles()
end

--- @return void
local function StartCollectibleHandler()
	if not usedCollectible.handler then
		dbg("starting test")
		ResetUsedCollectible()
		EM:RegisterForEvent(name, EVENT_COLLECTIBLE_USE_RESULT, ProcessCollectibleResult)
		EM:UnregisterForEvent("AlertTextManager", EVENT_COLLECTIBLE_USE_RESULT)
		usedCollectible.handler = true
	end
end

--------------------------------------------------------------------------------

-- Used by UpateCollectibles()
local collectiblesToEquip = {}
local collectiblesToUnequip = {}
local otherToEquip = {}
local otherToUnequip = {}
local randomMountTypeToEquip = nil

--- @return void
local function ResetCollectibleCache()
	collectiblesToEquip = {}
	collectiblesToUnequip = {}
	otherToEquip = {}
	otherToUnequip = {}
	randomMountTypeToEquip = nil
end

--- @param collectibles table
--- @return void
local function CacheClassicCollectiblesToUpdate(collectibles)
	for collectibleType, id in pairs(collectibles) do
		local equippedCollectible = NeedsUpdate(collectibleType) or GetActiveCollectibleByType(collectibleType)

		if equippedCollectible ~= id then
			if id > 0 and IsCollectibleUnlocked(id) and IsCollectibleUsable(id) and IsCollectibleValidForPlayer(id) then
				collectiblesToEquip[collectibleType] = id
			elseif equippedCollectible > 0 then
				collectiblesToUnequip[collectibleType] = equippedCollectible
			end
		end
	end
end

--- @param type integer
--- @return void
local function CacheRandomMountTypeToUpdate(type)
	-- 20240921 - changed default value for randomMountType from 0 to nil - new installs who load a build before saving first, and have a random mount type selected, will no longer lose that selection
	if type and type ~= GetRandomMountType() then
		randomMountTypeToEquip = type
	end
end

--- @param customizedActions table
--- @return void
local function CacheCustomizedActionsToUpdate(customizedActions)
	-- 20240828 load customized actions
	-- we're looping through the known categories of customized actions, and checking if we have a collectible saved for that category
	-- if we have no data stored, the build was saved before adding support for custom actions, and we don't do anything to keep whatever selection there was before switching builds
	-- if the data stored is 0, the build was saved after support for custom actions was added, and with no custom action active in that category.  Check if any action in that category is currently active, and deactive it.
	-- if the data stored is > 0, we  activate that custom action (if it isn't already), which will deactivate any other active ones in that category automatically
	for categoryId, availableCollectibleIds in pairs(CUSTOM_ACTION_COLLECTIBLE_IDS) do
		local savedCollectibleId = customizedActions[categoryId]

		if savedCollectibleId then
			if savedCollectibleId == 0 then
				for _, collectibleId in pairs(availableCollectibleIds) do
					if IsCollectibleActive(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER) then
						table.insert(otherToUnequip, collectibleId)
					end
				end
			else
				if not IsCollectibleActive(savedCollectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER) then
					table.insert(otherToEquip, savedCollectibleId)
				end
			end
		end
	end
end

--- @param skillStyles table
--- @return void
local function CacheSkillStylesToUpdate(skillStyles)
	-- 20240828: load skill styles
	-- similar to customized actions, but we have just a single array of active skill styles
	-- this time we skip the entire routine if there's no data available in savedVariables
	if type(skillStyles) == "table" then
		for _, collectibleId in pairs(SKILLSTYLE_COLLECTIBLE_IDS) do
			local savedCollectibleId = skillStyles[collectibleId]

			if savedCollectibleId ~= nil then
				if savedCollectibleId == false then
					if IsCollectibleActive(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER) then
						table.insert(otherToUnequip, collectibleId)
					end
				else
					if not IsCollectibleActive(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER) then
						table.insert(otherToEquip, collectibleId)
					end
				end
			end
		end
	end
end

--- @return void
local function CacheCollectiblesToUpdate()
	ResetCollectibleCache()

	local savedBuild = ASM.savedVariables.builds[ASM.savedVariables.currentBuildIndex]

	CacheClassicCollectiblesToUpdate(savedBuild.collectibles)
	CacheRandomMountTypeToUpdate(savedBuild.randomMountType)
	CacheCustomizedActionsToUpdate(savedBuild.customizedActions)
	CacheSkillStylesToUpdate(savedBuild.skillStyles)
end

--- @return void
local function ZoneChanged()
	if next(ASM.savedVariables.needsUpdate) ~= nil then
		ResetCollectibleCache()
		for category, id in pairs(ASM.savedVariables.needsUpdate) do
			local activeId = GetActiveCollectibleByType(category)
			ASM.savedVariables.needsUpdate[category] = nil

			if id == 0 and (activeId > 0) then
				collectiblesToUnequip[category] = activeId
			elseif id > 0 and (activeId ~= id) and IsCollectibleUnlocked(id) and IsCollectibleUsable(id) and IsCollectibleValidForPlayer(id) then
				collectiblesToEquip[category] = id
			end
		end
		ASM:UpdateCollectibles()
	end
end

--- @return void
function ASM:UpdateCollectibles()
	dbg("UpdateCollectibles")
	StartCollectibleHandler()

	for categoryId, collectibleId in pairs(collectiblesToUnequip) do
		collectiblesToUnequip[categoryId] = nil
		return TryUseCollectible(categoryId, collectibleId)
	end

	for categoryId, collectibleId in pairs(collectiblesToEquip) do
		collectiblesToEquip[categoryId] = nil
		return TryUseCollectible(categoryId, collectibleId)
	end

	for i, collectibleId in pairs(otherToUnequip) do
		otherToUnequip[i] = nil
		return TryUseCollectible(nil, collectibleId)
	end

	for i, collectibleId in pairs(otherToEquip) do
		otherToEquip[i] = nil
		return TryUseCollectible(nil, collectibleId)
	end

	-- @TODO doesn't trigger USE_RESULT, seems to work like this but figure out if there's a different event to handle
	-- doing here because handling the actual mount goes first
	if randomMountTypeToEquip then
		SetRandomMountType(randomMountTypeToEquip)
	end

	ResetCollectibleCache()
	StopCollectibleHandler()
	ASM:RefreshUI()
	dbg("------------------------------------------------")
end

--------------------------------------------------------------------------------
--- @param result 
--- @param buildIndex integer
--- @return void
local function ArmoryBuildLoaded(_, result, buildIndex)
	if result ~= ARMORY_BUILD_RESTORE_RESULT_SUCCESS then return false end

	if not usedCollectible.handler then
		ASM.savedVariables.currentBuildIndex = buildIndex

		UpdateNonCollectibles()
		CacheCollectiblesToUpdate()
		zo_callLater(function() ASM:UpdateCollectibles() end, LOAD_DELAY)
	else
		d("Armory Style Manager: still loading previous build, skipping collectibles for this one")
	end
end

--------------------------------------------------------------------------------
-- Assistant Keybind Handlers --
--------------------------------------------------------------------------------

--- @param assistantId integer
--- @return void
local function SummonAssistant(assistantId)
	local _, _, icon, _, unlocked, _, summoned = GetCollectibleInfo(assistantId)

	local summondedMsg = ""
	local colour = ""

	local iconLink = zo_strformat("|t20:20:<<1>>|t", icon)
	local collectibleLink = zo_strformat("|H1:collectible:<<1>>|h|h", assistantId)

	if unlocked then
		colour = "bfbfbf"
		summondedMsg = "You summon"
		if summoned then summondedMsg = "You dismiss" end

		UseCollectible(assistantId)
	else
		colour = "bf0000"
		summondedMsg = "You did not unlock the collectible, cannot summon"
	end

	local message = zo_strformat("|c<<1>><<2>>|r<<3>><<4>>.", colour, summondedMsg, iconLink, collectibleLink)
	d(message)
end

--- @return void
function ASM.SummonGrashorog()
	SummonAssistant(GRASHOROG_ID)
end

--- @return void
function ASM.SummonZuqoth()
	SummonAssistant(ZUQOTH_ID)
end

--------------------------------------------------------------------------------
-- Load in the saved variables  --
--------------------------------------------------------------------------------

--- @return void
local function InitSavedVariables()
	ASM.savedVariables = ZO_SavedVars:NewCharacterIdSettings("ArmoryStyleManagerData", ASM.variableVersion, nil, defaultData)
end

-- Populate CUSTOM_ACTION_COLLECTIBLE_IDS with all customized actions known to the game
-- Populate SKILLSTYLE_COLLECTIBLE_IDS with all skill styles known to the game
-- Afaik zos doesn't add new collectibles while the servers are live, so running this once on addon load should suffice
--- @return void
local function InitCustomizedActionsAndSkillStyles()
	-- two tables containing functions that get evaluated using ZO_FilteredNumericallyIndexedTableIterator in zo_tableutils.lua
	local data = ZO_COLLECTIBLE_DATA_MANAGER:GetAllCollectibleDataObjects(
	{
		-- first table contains functions that are called using a ZO_CollectibleCategoryData object (collectibledatamanager.lua)
		-- this allows us to filter out toplevel categories, but haven't found a way to filter subcategoryId at this level
		function(category)
			return category.categoryIndex == CUSTOM_ACTION_CATEGORY_ID
		end
	}
	)

	for i = 1, #data do
		local _, subcategory = data[i].categoryData:GetCategoryIndicies()

		CUSTOM_ACTION_COLLECTIBLE_IDS[subcategory] = CUSTOM_ACTION_COLLECTIBLE_IDS[subcategory] or {}

		table.insert(CUSTOM_ACTION_COLLECTIBLE_IDS[subcategory], data[i].collectibleId)
	end

	data = ZO_COLLECTIBLE_DATA_MANAGER:GetAllCollectibleDataObjects(
	{
		function(category)
			return category.categoryIndex == SKILLSTYLE_CATEGORY_ID 
		end
	},
	{
		-- second table contains functions that are called using a ZO_CollectibleData object (collectibledatamanager.lua)
		-- this allows us to filter out individual collectibles based on the subcategoryId
		function(collectible)
			local subcategoryIndex
			_, subcategoryIndex = collectible.categoryData:GetCategoryIndicies()
			return subcategoryIndex == SKILLSTYLE_SUBCATEGORY_ID
		end
	}
	)

	for i = 1, #data do
		table.insert(SKILLSTYLE_COLLECTIBLE_IDS, data[i].collectibleId)
	end
end

--------------------------------------------------------------------------------
-- Register Event Handlers  --
--------------------------------------------------------------------------------
--- @return void
local function RegisterEvents()
	-- 20240829: replaced EVENT_ARMORY_BUILD_UPDATE with EVENT_ARMORY_BUILD_SAVE_RESPONSE, since UPDATE would trigger a save when you were in fact loading a build if a change to the armory UI was triggered
	EM:RegisterForEvent(name, EVENT_ARMORY_BUILD_SAVE_RESPONSE, ArmoryBuildSaved)
	EM:RegisterForEvent(name, EVENT_ARMORY_BUILD_RESTORE_RESPONSE, ArmoryBuildLoaded)
	SecurePostHook("ZO_Armory_ExpandedEntry_OnInitialized", CreateUI) -- @todo try call ASM:CreateUI directly without losing "control" variable
	-- 20240919: ASM:RefreshUI was being called twice every time when switching between builds in the UI, disabled one PostHook, monitor if all keeps working correctly
	--SecurePostHook("ZO_Armory_Keyboard_CollapsedEntry_OnMouseUp", ASM:RefreshUI)
	SecurePostHook(AKB, "RefreshBuilds", ASM.RefreshUI)

	-- 20240927: allow for collectibles to be equipped after zone change (currently for pets - can't be equipped inside houses)
	EM:RegisterForEvent(name, EVENT_PLAYER_ACTIVATED, ZoneChanged)
end

local function FixSavedTitles()
    for key, build in pairs(ASM.savedVariables.builds) do
        if build.title and type(build.title) == "number" and build.title ~= 0 then
           d(string.format("about to replace %d with %s for build id %d", build.title, GetTitle(build.title), key)) 
           ASM.savedVariables.builds[key].title = GetTitle(build.title)
        end
    end
end

--------------------------------------------------------------------------------
-- Initialize --
--------------------------------------------------------------------------------
--- @return void
local function Initialize()
	InitSavedVariables()
    -- 20241230: Reverted to saving title string instead of id because id changes when you acquire a new title
    -- (apologies @Dekakaruk, I didn't realize this was a bugfix)
    -- This function checks for saved titles and converts them if necessary, so the bug doesn't affect people who don't save their builds before getting a new title
    -- @TODO: try finding a more robust method than saving the title as string, since this could fail in a couple of ways:
    -- Client language is changed
    -- Typos / other fixes by zos to titles
    --
    FixSavedTitles()

	InitDisplaySettings()
	InitCustomizedActionsAndSkillStyles()

	RegisterEvents()

	local AmoryAssistantName = GetCollectibleInfo(GRASHOROG_ID)
	ZO_CreateStringId("SI_BINDING_NAME_ARMORY_STYLE_MANAGER_SUMMON_GRASHOROG", zo_strformat("Summon <<1>>", AmoryAssistantName))

	local AmoryAssistantName = GetCollectibleInfo(ZUQOTH_ID)
	ZO_CreateStringId("SI_BINDING_NAME_ARMORY_STYLE_MANAGER_SUMMON_ZUQOTH", zo_strformat("Summon <<1>>", AmoryAssistantName))

	AKB.keybindStripDescriptor[2].enabled = function()
		if IsCurrentBuildLocked() then return false end
		local function disabledAlertText()
			return zo_strformat(SI_ARMORY_BUILD_OPERATION_COOLDOWN_ALERT,
			ZO_FormatTimeMilliseconds(ARMORY_OPERATION_COOLDOWN_DURATION_MS,
			TIME_FORMAT_STYLE_SHOW_LARGEST_UNIT_DESCRIPTIVE, TIME_FORMAT_PRECISION_SECONDS))
		end
		return not ZO_ARMORY_MANAGER:IsBuildOperationInProgress(), disabledAlertText
	end

	SLASH_COMMANDS["/asm"] = ASM_SlashCommand

	ASM_MENU.Init()

	EM:UnregisterForEvent(name, EVENT_ADD_ON_LOADED)
end

--- @param e
--- @param addonName string
--- @return void
local function AddonLoaded(e, addonName)
	if addonName ~= name then return end
	Initialize()
end

EM:RegisterForEvent(name, EVENT_ADD_ON_LOADED, AddonLoaded)
