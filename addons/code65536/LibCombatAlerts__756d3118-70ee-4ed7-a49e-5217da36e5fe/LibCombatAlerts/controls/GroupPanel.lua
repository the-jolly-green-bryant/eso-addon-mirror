local LCA = LibCombatAlerts


--------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------

-- Also publicly exposed in the Public Interface section below; see comment there regarding usage
local SHOW_TANK   = 0x01
local SHOW_HEALER = 0x02
local SHOW_DAMAGE = 0x04
local SHOW_OTHER  = 0x08
local SHOW_ALL    = 0x0F -- SHOW_TANK | SHOW_HEALER | SHOW_DAMAGE | SHOW_OTHER

local ICON_PADDING = 4 -- Space between header icon and header text
local ICON_OFFSET = 28 -- 24 for header icon plus padding
local OTHER_WIDTH = 28 -- 20 for role icon, 2x2 padding around role icon, 4 padding at end
local REFRESH_DELAY = 500

local DEFAULT_POSITION = {
	right = 0,
	mid = 0,
}

local DEFAULT_OPTIONS = {
	-- Appearance
	headerIcon = nil,
	headerText = -1,
	headerAlign = nil,
	headerHide = false,
	colorHeader = 0xFFFFFFFF,
	colorBG = 0x00000077,
	colorName = 0xFFFFFFFF,
	colorStat = 0xFFFF00FF,
	columns = 2,
	paneWidth = 160,
	statWidth = 26,
	scale = 1,
	showRoles = SHOW_ALL,
	minimumPaneCount = 0,

	-- Options
	useUnitId = true,
	useRange = true,
	strikeDead = true,
	highlightSelf = true,
}

local ROLE_ICONS = {
	[LFG_ROLE_INVALID] = "/esoui/art/crafting/gamepad/crafting_alchemy_trait_unknown.dds",
	[LFG_ROLE_DPS] = "/esoui/art/lfg/lfg_icon_dps.dds",
	[LFG_ROLE_TANK] = "/esoui/art/lfg/lfg_icon_tank.dds",
	[LFG_ROLE_HEAL] = "/esoui/art/lfg/lfg_icon_healer.dds",
}

local ROLE_ICONS_HD = {
	[LFG_ROLE_INVALID] = "/esoui/art/crafting/gamepad/crafting_alchemy_trait_unknown.dds",
	[LFG_ROLE_DPS] = "/esoui/art/lfg/gamepad/lfg_roleicon_dps.dds",
	[LFG_ROLE_TANK] = "/esoui/art/lfg/gamepad/lfg_roleicon_tank.dds",
	[LFG_ROLE_HEAL] = "/esoui/art/lfg/gamepad/lfg_roleicon_healer.dds",
}

local ROLE_ICONS_HD_THRESHOLD = 1.3 -- Switch at or above 130% scaling


--------------------------------------------------------------------------------
-- Pool
--------------------------------------------------------------------------------

local PanePool = { }
do
	local Pool
	local function GetPool( )
		if (not Pool) then
			Pool = ZO_ControlPool:New("LCA_GroupPanel_Pane")
		end
		return Pool
	end

	function PanePool.Add( parent )
		local control, key = GetPool():AcquireObject()
		local pane = {
			control = control,
			key = key,
			bg = control:GetNamedChild("Backdrop"),
			name = control:GetNamedChild("Name"),
			role = control:GetNamedChild("Role"),
			stat = control:GetNamedChild("Stat"),
		}
		control:SetParent(parent)
		pane.bg:SetEdgeColor(0, 0, 0, 0)
		return pane
	end

	function PanePool.Remove( pane )
		pane.control:SetParent()
		pane.control:SetHidden(true)
		GetPool():ReleaseObject(pane.key)
	end
end


--------------------------------------------------------------------------------
-- LCA_GroupPanel
--------------------------------------------------------------------------------

local LCA_GroupPanel = LCA.BaseControlObject:Subclass()
LCA.GroupPanel = LCA_GroupPanel

-- Preserve GuiRoot to guard against redefinition
local GuiRoot = GuiRoot


--------------------------------------------------------------------------------
-- Public interface
--------------------------------------------------------------------------------

-- Flags for the showRoles field for role filtering; combine using bitwise or
LCA.GROUP_PANEL_SHOW_TANK = SHOW_TANK
LCA.GROUP_PANEL_SHOW_HEALER = SHOW_HEALER
LCA.GROUP_PANEL_SHOW_DAMAGE = SHOW_DAMAGE
LCA.GROUP_PANEL_SHOW_OTHER = SHOW_OTHER
LCA.GROUP_PANEL_SHOW_ALL = SHOW_ALL

function LCA_GroupPanel:New( )
	local obj = LCA.BaseControlObject.New(self, "LCA_GroupPanel")

	obj.enabled = false
	obj.listening = false

	-- Initialize top-level control
	obj.control = WINDOW_MANAGER:CreateControlFromVirtual(obj.ID, GuiRoot, "LCA_GroupPanel")
	obj.fragment = ZO_SimpleSceneFragment:New(obj.control)

	-- Initialize child elements
	obj.icon = obj.control:GetNamedChild("Icon")
	obj.header = obj.control:GetNamedChild("Header")
	obj.panes = { }

	-- Positioning
	obj.positioner = LCA.MoveableControl:New(obj.control)

	return obj
end

function LCA_GroupPanel:SetRepositionCallback( fn )
	self.positioner:RegisterCallback(self.ID, LCA.EVENT_CONTROL_MOVE_STOP, fn)
end

function LCA_GroupPanel:SetPosition( pos )
	self.positioner:UpdatePosition(pos or DEFAULT_POSITION)
end

function LCA_GroupPanel:SetPositionSnap( ... )
	self.positioner:SetSnap(...)
end

function LCA_GroupPanel:ToggleLock( ... )
	self.positioner:ToggleLock(...)
end

function LCA_GroupPanel:GetLeftTopPosition( )
	return self.positioner:GetLeftTopPosition()
end

function LCA_GroupPanel:ToggleGamepadMove( ... )
	return self.positioner:ToggleGamepadMove(...)
end

function LCA_GroupPanel:GetDefaultPosition( )
	return ZO_ShallowTableCopy(DEFAULT_POSITION)
end

function LCA_GroupPanel:Enable( options )
	self.enabled = true
	self.options = LCA.PopulateOptions(options, DEFAULT_OPTIONS)
	self.data = { }

	-- Start listeners
	if (not self.listening) then
		self.listening = true
		local DelayedRefreshGroup = function( )
			EVENT_MANAGER:UnregisterForUpdate(self.ID)
			EVENT_MANAGER:RegisterForUpdate(self.ID, REFRESH_DELAY, function() self:RefreshGroup() end, true)
		end
		EVENT_MANAGER:RegisterForEvent(self.ID, EVENT_GROUP_MEMBER_JOINED, DelayedRefreshGroup)
		EVENT_MANAGER:RegisterForEvent(self.ID, EVENT_GROUP_MEMBER_LEFT, DelayedRefreshGroup)
		EVENT_MANAGER:RegisterForEvent(self.ID, EVENT_GROUP_MEMBER_ROLE_CHANGED, DelayedRefreshGroup)
		EVENT_MANAGER:RegisterForEvent(self.ID, EVENT_GROUP_UPDATE, DelayedRefreshGroup)
		EVENT_MANAGER:RegisterForEvent(self.ID, EVENT_PLAYER_ACTIVATED, DelayedRefreshGroup)
	end

	if (self.options.useRange) then
		EVENT_MANAGER:RegisterForEvent(self.ID, EVENT_GROUP_SUPPORT_RANGE_UPDATE, function(_, ...) self:OnGroupSupportRangeUpdate(...) end)
	end
	if (self.options.strikeDead) then
		EVENT_MANAGER:RegisterForEvent(self.ID, EVENT_UNIT_DEATH_STATE_CHANGED, function(_, unitTag) self:UpdatePaneDisplayForUnit(unitTag) end)
		EVENT_MANAGER:AddFilterForEvent(self.ID, EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
	end
	if (self.options.useUnitId) then
		LCA.ToggleUnitIdTracking(self.ID, true)
	end

	-- Initialize appearance and show
	self.control:SetScale(self.options.scale)
	self.roleIcons = (self.options.scale >= ROLE_ICONS_HD_THRESHOLD) and ROLE_ICONS_HD or ROLE_ICONS
	self.icon:SetHidden(self.options.headerHide)
	self.header:SetHidden(self.options.headerHide)
	if (not self.options.headerHide) then
		local iconOffset = 0
		if (self.options.headerIcon) then
			self.icon:SetAlpha(1)
			self.icon:SetTexture(self.options.headerIcon)
			self.header:SetAnchor(TOPLEFT, self.icon, TOPRIGHT, ICON_PADDING)
			self.options.headerAlign = self.options.headerAlign or TEXT_ALIGN_LEFT
			iconOffset = ICON_OFFSET
		else
			self.icon:SetAlpha(0)
			self.header:SetAnchor(TOPLEFT, self.control, TOPLEFT)
		end
		self.header:SetWidth(self.options.paneWidth * self.options.columns - iconOffset)
		self.header:SetColor(LCA.UnpackRGBA(self.options.colorHeader))
		self.header:SetText((self.options.headerText == -1) and LCA.GetZoneName(LCA.GetZoneId()) or self.options.headerText)
		self.header:SetHorizontalAlignment(self.options.headerAlign or TEXT_ALIGN_CENTER)
	end
	self:RefreshGroup()
	self:SetPosition(self.options.pos)
	LCA.ToggleUIFragment(self.fragment, true)
end

function LCA_GroupPanel:Disable( )
	if (self.enabled) then
		self.enabled = false

		-- Stop listeners
		self.listening = false
		EVENT_MANAGER:UnregisterForEvent(self.ID, EVENT_GROUP_MEMBER_JOINED)
		EVENT_MANAGER:UnregisterForEvent(self.ID, EVENT_GROUP_MEMBER_LEFT)
		EVENT_MANAGER:UnregisterForEvent(self.ID, EVENT_GROUP_MEMBER_ROLE_CHANGED)
		EVENT_MANAGER:UnregisterForEvent(self.ID, EVENT_GROUP_UPDATE)
		EVENT_MANAGER:UnregisterForEvent(self.ID, EVENT_PLAYER_ACTIVATED)
		EVENT_MANAGER:UnregisterForEvent(self.ID, EVENT_GROUP_SUPPORT_RANGE_UPDATE)
		EVENT_MANAGER:UnregisterForEvent(self.ID, EVENT_UNIT_DEATH_STATE_CHANGED)
		LCA.ToggleUnitIdTracking(self.ID, false)

		-- Remove panes
		for _, pane in pairs(self.panes) do
			PanePool.Remove(pane)
		end
		self.panes = { }

		-- Hide
		LCA.ToggleUIFragment(self.fragment, false)
	end
end

function LCA_GroupPanel:IsEnabled( )
	return self.enabled
end

function LCA_GroupPanel:UpdateUnitData( unitTag, unitId, color, statText )
	if (not self.enabled) then return end

	local unitTagOrId
	if (self.options.useUnitId) then
		if (type(unitId) ~= "number" and type(unitTag) == "string") then
			unitId = LCA.IdentifyGroupUnitTag(unitTag)
		end
		if (type(unitId) == "number") then
			unitTagOrId = unitId
		end
	elseif (type(unitTag) == "string") then
		unitTagOrId = unitTag
	end

	if (unitTagOrId) then
		self.data[unitTagOrId] = {
			color = color,
			statText = statText,
		}
		self:UpdatePaneDisplayForUnit(unitTag, unitId)
	end
end

function LCA_GroupPanel:ToggleAdditionalScene( sceneName, enable )
	local scene = SCENE_MANAGER:GetScene(sceneName)
	if (scene and enable) then
		scene:AddFragment(self.fragment)
	elseif (scene and not enable) then
		scene:RemoveFragment(self.fragment)
	end
end

function LCA_GroupPanel:SetMinimumPaneCount( count )
	self.options.minimumPaneCount = count
	if (self.units and zo_max(count, LCA.CountTable(self.units)) ~= #self.panes) then
		self:RefreshGroup()
	end
end


--------------------------------------------------------------------------------
-- Private functions; do not call these externally
--------------------------------------------------------------------------------

function LCA_GroupPanel:OnGroupSupportRangeUpdate( unitTag, status )
	if (self.units[unitTag]) then
		self:UpdatePaneDisplay(self.units[unitTag].paneId, nil, nil, (status or not self.options.useRange) and 1 or 0.5)
	end
end

function LCA_GroupPanel:UpdatePaneDisplay( paneId, color, statText, alpha, nameText )
	local pane = self.panes[paneId]

	-- Should never be nil, but sanity-check anyway just in case
	if (not pane) then return end

	if (color and color ~= pane.lcaCurrentColor) then
		pane.lcaCurrentColor = color
		pane.bg:SetCenterColor(LCA.UnpackRGBA(color))
	end

	if (statText and statText ~= pane.lcaCurrentStat) then
		pane.lcaCurrentStat = statText
		pane.stat:SetText(statText)
	end

	if (alpha and alpha ~= pane.lcaCurrentAlpha) then
		pane.lcaCurrentAlpha = alpha
		pane.control:SetAlpha(alpha)
	end

	if (nameText and nameText ~= pane.lcaCurrentName) then
		pane.lcaCurrentName = nameText
		pane.name:SetText(nameText)
	end
end

function LCA_GroupPanel:UpdatePaneDisplayForUnit( unitTag, unitId )
	if (type(unitTag) ~= "string" and type(unitId) == "number") then
		unitTag = LCA.IdentifyGroupUnitId(unitId)
	end

	local unit = type(unitTag) == "string" and self.units[unitTag]
	if (unit) then
		local data, color, statText

		if (self.options.useUnitId) then
			if (type(unitId) ~= "number") then
				unitId = LCA.IdentifyGroupUnitTag(unitTag)
			end
			if (unitId) then
				data = self.data[unitId]
			end
		else
			data = self.data[unitTag]
		end

		if (data) then
			color = data.color
			if (color and self.options.highlightSelf and unit.isSelf) then
				color = BitOr(color, 0xFF)
			end
			statText = data.statText
		end

		self:UpdatePaneDisplay(
			unit.paneId,
			color or self.options.colorBG,
			statText or "",
			nil,
			unit[(self.options.strikeDead and IsUnitDead(unitTag)) and "nameStriked" or "name"]
		)
	end
end

local function FindNextValidMemberIndex( members, index, flags )
	if (index) then
		for i = index + 1, #members do
			local role = members[i].role

			if ( (role == LFG_ROLE_TANK and BitAnd(flags, SHOW_TANK) > 0) or
			     (role == LFG_ROLE_HEAL and BitAnd(flags, SHOW_HEALER) > 0) or
			     (role == LFG_ROLE_DPS and BitAnd(flags, SHOW_DAMAGE) > 0) or
			     (role == LFG_ROLE_INVALID and BitAnd(flags, SHOW_OTHER) > 0) ) then
				return i
			end
		end
	end

	return nil
end

function LCA_GroupPanel:RefreshGroup( )
	self.units = { }
	local members = LCA.GetSortedGroupMembers()
	local memberIndex = 0

	for i = 1, MAX_GROUP_SIZE_THRESHOLD do
		local pane = self.panes[i]

		memberIndex = FindNextValidMemberIndex(members, memberIndex, self.options.showRoles)

		if (memberIndex or i <= self.options.minimumPaneCount) then
			if (not pane) then
				pane = PanePool.Add(self.control)
				self.panes[i] = pane
			end

			pane.bg:SetWidth(self.options.paneWidth)
			pane.name:SetWidth(self.options.paneWidth - self.options.statWidth - OTHER_WIDTH)
			pane.stat:SetWidth(self.options.statWidth)

			pane.name:SetColor(LCA.UnpackRGBA(self.options.colorName))
			pane.stat:SetColor(LCA.UnpackRGBA(self.options.colorStat))

			if (memberIndex) then
				local member = members[memberIndex]
				local unitTag = member.unitTag
				local name = UndecorateDisplayName(member.account)
				self.units[unitTag] = {
					paneId = i,
					isSelf = AreUnitsEqual("player", unitTag),
					name = name,
					nameStriked = string.format("|l0:0:0:50%%:2:ignore|l%s|l", name),
				}

				pane.role:SetTexture(self.roleIcons[member.role])

				self:UpdatePaneDisplayForUnit(unitTag)
				self:OnGroupSupportRangeUpdate(unitTag, IsUnitInGroupSupportRange(unitTag))
			else
				pane.role:SetTexture(LCA.GetTexture("clear"))
				self:UpdatePaneDisplay(i, self.options.colorBG, "", 1, "")
			end

			if (i == 1) then
				-- First pane
				if (self.options.headerHide) then
					pane.control:SetAnchor(TOPLEFT, self.control, TOPLEFT)
				else
					pane.control:SetAnchor(TOPLEFT, self.icon, BOTTOMLEFT)
				end
			elseif (i <= self.options.columns) then
				-- Remainder of the first row
				pane.control:SetAnchor(TOPLEFT, self.panes[i - 1].control, TOPRIGHT)
			else
				-- All other panes
				pane.control:SetAnchor(TOPLEFT, self.panes[i - self.options.columns].control, BOTTOMLEFT)
			end
			pane.control:SetHidden(false)
		elseif (pane) then
			PanePool.Remove(pane)
			self.panes[i] = nil
		end
	end
end
