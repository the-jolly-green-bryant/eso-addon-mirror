-- top level namespace for all global variables in this addon
DQT = {}

--[[
	Main file for the addon
--]]

local Main = {}
DQT.Main = Main

Main.name = "PolloxsDailyQuestTracker"
Main.checkedTexture = "/esoui/art/buttons/checkbox_checked.dds"
Main.uncheckedTexture = "/esoui/art/buttons/checkbox_unchecked.dds"
Main.disabledTexture = "/esoui/art/buttons/checkbox_disabled.dds"

--[[
	Get the quest sections to show

	@return a filtered version of DQT.Info.QuestSections
--]]
function Main:getSectionsToShow()
	local questSections = {}

	for _, section in ipairs(DQT.Info.QuestSections) do
		if DQT.Settings:shouldShowSection(section) then
			questSections[#questSections + 1] = section
		end
	end

	return questSections
end

function Main:getCharactersToShow()
	local characters = {}

	for _, character in ipairs(DQT.Utils:getCharacters()) do
		if DQT.Settings:shouldShowCharacter(character.id) then
			characters[#characters + 1] = character
		end
	end

	return characters
end

--[[Get the names of all the quests to track

	@return a set of quest names. Do "if questNames['foo']" to see if foo is in set
--]]
function Main:getAllQuestNames()
	if not self.allQuestNames then
		local allQuestNames = {}

		-- track all quests, even if we're not currently showing them
		for _, section in ipairs(DQT.Info.QuestSections) do
			if section.type() == "QuestSection" then
				for _, questType in ipairs(section:getQuestTypes()) do
					for _, quest in ipairs(questType:getQuests()) do
						allQuestNames[quest:getName()] = true
					end
				end
			end
		end

		self.allQuestNames = allQuestNames
	end

	return self.allQuestNames
end

--[[
	Update quest added time

	@param eventCode (number)
	@param journalIndex (number)
	@param questName (string)
	@param objectiveName (string)
--]]
function Main.onQuestAdded(eventCode, journalIndex, questName, objectiveName)
	-- if this is one of the daily quests we track, then update the quest status
	if Main:getAllQuestNames()[questName] then
		DQT.SV:getForChar(GetCurrentCharacterId()).questStatuses[questName] = {
			addedTime = DQT.Utils:getCurrentTime(),
			isCompleted = false
		}
	end
end

--[[
	Update quest completed status

	@param eventCode (number)
	@param questName (string)
	@param level (number)
	@param previousExperience (number)
	@param currentExperience (number)
	@param championPoints (number)
	@param questType (QuestType)
	@param instanceDisplayType (InstanceDisplayType)
--]]
function Main.onQuestComplete(eventCode, questName, level, previousExperience, currentExperience, championPoints, questType, instanceDisplayType)
	local QuestStatus = DQT.SV:getForChar(GetCurrentCharacterId()).questStatuses[questName]

	-- if QuestStatus is nil, this is not a tracked quest, a quest started when the addon was not enabled, or a bug
	if QuestStatus ~= nil then
		QuestStatus.isCompleted = true
		Main:refresh()
	end
end

--[[
	Is the given daily quest complete today? For example, for a Summerset World Boss,
	this will check if any of the Summerset World Boss quests were completed today.

	@param resetTime (integer) UTC time in seconds
	@param questType
--]]
function Main:isDailyQuestTypeComplete(characterId, questType)
	local questStatuses = DQT.SV:getForChar(characterId).questStatuses
	local previousResetTime = self.resetTime - 86400

	for _, quest in ipairs(questType:getQuests()) do
		local questStatus = questStatuses[quest:getName()]

		if questStatus then
			-- only count quest if it is completed and it wasn't picked up yesterday
			if questStatus.isCompleted and (questStatus.addedTime > previousResetTime) then
				return true
			end
		end
	end

	return false
end

--[[
	Is the given daily quest complete today?

	@param resetTime (integer) UTC time in seconds
	@param questName (string)
--]]
function Main:isDailyQuestComplete(characterId, quest)
	local questStatuses = DQT.SV:getForChar(characterId).questStatuses
	local previousResetTime = self.resetTime - 86400

	local questStatus = questStatuses[quest:getName()]

	if questStatus then
		-- only count quest if it is completed and it wasn't picked up yesterday
		return questStatus.isCompleted and (questStatus.addedTime > previousResetTime)
	else
		return false
	end
end

function Main.colorize(control, texture)
	local settings = DQT.SV:getAccountWide().settings.customColors
	local color

	if settings.toggle then
		color = (texture == Main.checkedTexture and settings.colorChecked) or
			(texture == Main.uncheckedTexture and settings.colorUnchecked) or settings.colorDisabled
	else
		if texture == Main.disabledTexture then
			color = { r = 0.5, g = 0.5, b = 0.5 }
		end
	end
	if color == nil then
		color = { r = 1, g = 1, b = 1 }
	end

	control:SetColor(color.r, color.g, color.b, 1)
end

local function toggleHudUI(onShow)
	local settings = DQT.SV:getAccountWide().settings

	if settings.showCursor then
		-- SCENE_MANAGER:OnToggleHUDUIBinding()
		if IsGameCameraActive() then
			if onShow and not SCENE_MANAGER:IsInUIMode() then
				SCENE_MANAGER:SetInUIMode(true)
			elseif onShow == false then
				SCENE_MANAGER:SetInUIMode(false)
			end
		end
	end
end

function Main:refresh()
	if not DQTWindow:IsHidden() then
		self.tree:RefreshVisible()
		self.lastRefreshTime = os.time()
	end
end

function Main:onShow()
	self:refresh()

	toggleHudUI(true)
end

function Main:onHide()
	toggleHudUI(false)
end

function Main:update()
	local currentTime = DQT.Utils:getCurrentTime()

	-- calculate next reset time if necessary, and update rows
	-- also refresh periodically to update timers
	if (os.difftime(os.time(), self.lastRefreshTime) > 60) or (self.resetTime < currentTime) then
		self.resetTime = DQT.Utils:getResetTime()
		self:refresh()
	end

	local timeUntilReset = os.difftime(self.resetTime, currentTime)

	-- format and display the remaining time
	local hoursRemaining = math.floor(timeUntilReset / 3600)
	local minutesRemaining = math.floor((timeUntilReset - hoursRemaining * 3600) / 60)
	local secondsRemaining = math.floor(timeUntilReset - hoursRemaining * 3600 - minutesRemaining * 60)

	DQTWindowTimeUntilReset:SetText(string.format("%s: %d:%.2d:%.2d", GetString(DQT_TIME_UNTIL_RESET), hoursRemaining, minutesRemaining, secondsRemaining))
end

-- Show or hide the window
function Main.toggleDisplay()
	DQTWindow:ToggleHidden()
end

-- Hide the window
function Main.closeWindow()
	DQTWindow:SetHidden(true)
end

--[[
	Sets up the controls inside a node that was created with the DQTQuestSection template

	@param data {name: sectionName}
--]]
function Main.TreeSectionSetup(node, control, data, open, userRequested, enabled)
	control:GetNamedChild("Name"):SetText(data.section:getName())
	control:GetNamedChild("Name"):SetFont(DQT.Font.Header2)
end

--[[
	Sets up the controls inside a node that was created with the DQTQuestType template

	@param data {sectionName: section name, questType: questType}
--]]
function Main.TreeQuestTypeSetup(node, questTypeControl, data, open, userRequested, enabled)
	local nameControl = questTypeControl:GetNamedChild("Name")
	nameControl:SetText(data.questType:getName())
	nameControl:SetFont(DQT.Font.Game)

	if not data.questType:isShareable() then
		questTypeControl:GetNamedChild("Toggle"):SetHidden(true)
	end

	local columnIndex = 1
	local previousStatusControl = nil

	for _, character in ipairs(Main:getCharactersToShow()) do
		local statusControl = questTypeControl:GetNamedChild(string.format("Status%s", columnIndex))
		statusControl:SetHidden(false)
		local isQuestTypeComplete = Main:isDailyQuestTypeComplete(character.id, data.questType)
		local statusTexture = isQuestTypeComplete and Main.checkedTexture or Main.uncheckedTexture
		statusControl:SetTexture(statusTexture)

		Main.colorize(statusControl, statusTexture)

		-- center status control in column
		if previousStatusControl then
			statusControl:SetAnchor(CENTER, previousStatusControl, CENTER, Main.COLUMN_WIDTH)
		else
			statusControl:SetAnchor(CENTER, nameControl, LEFT,
				Main.COLUMN_INDENT - Main.QUEST_TYPE_INDENT - questTypeControl:GetNamedChild("Toggle"):GetWidth()
				+ Main.COLUMN_WIDTH / 2)
		end

		columnIndex = columnIndex + 1
		previousStatusControl = statusControl
	end
end

--[[
	Sets up the controls inside a node that was created with the DQTQuest template

	@param data {questName: quest name}
--]]
function Main.TreeQuestSetup(node, nodeControl, data, open, userRequested, enabled)
	local nameControl = nodeControl:GetNamedChild("Name")
	nameControl:SetText(data.quest:getDisplayName())
	nameControl:SetFont(DQT.Font.Quest)

	local columnIndex = 1
	local previousStatusControl = nil

	for _, character in ipairs(Main:getCharactersToShow()) do
		local statusControl = nodeControl:GetNamedChild(string.format("Status%s", columnIndex))
		statusControl:SetHidden(false)
		local statusTexture = (Main:isDailyQuestComplete(character.id, data.quest) and Main.checkedTexture or Main.uncheckedTexture)
		statusControl:SetTexture(statusTexture)

		Main.colorize(statusControl, statusTexture)

		if previousStatusControl then
			statusControl:SetAnchor(CENTER, previousStatusControl, CENTER, Main.COLUMN_WIDTH)
		else
			statusControl:SetAnchor(CENTER, nameControl, LEFT,
				Main.COLUMN_INDENT - Main.QUEST_TYPE_INDENT - Main.QUEST_INDENT
				+ Main.COLUMN_WIDTH / 2)
		end

		columnIndex = columnIndex + 1
		previousStatusControl = statusControl
	end
end

--[[
	Sets up the controls inside a node that was created with the DQTTimerSection template

	@param data {name: sectionName}
--]]
function Main.TreeTimerSectionSetup(node, control, data, open, userRequested, enabled)
	local nameControl = control:GetNamedChild("Name")
	nameControl:SetText(data.section:getName())
	nameControl:SetFont(DQT.Font.Header2)
end

--[[
	Sets up the controls inside a node that was created with the DQTTimer template
--]]
function Main.TreeTimerSetup(node, nodeControl, data, open, userRequested, enabled)
	local nameControl = nodeControl:GetNamedChild("Name")
	nameControl:SetText(data.quest:getName())
	nameControl:SetFont(DQT.Font.Game)

	local columnIndex = 1
	local previousStatusControl = nil

	for _, character in ipairs(Main:getCharactersToShow()) do
		local statusControl = nodeControl:GetNamedChild(string.format("Status%s", columnIndex))
		statusControl:SetHidden(false)
		local statusTexture

		local timeRemaining = data.quest:getTimeRemaining(character.id)
		if type(timeRemaining) == "number" then
			statusTexture = (timeRemaining == 0 and Main.uncheckedTexture or Main.checkedTexture)
		else
			statusTexture = Main.disabledTexture
		end
		statusControl:SetTexture(statusTexture)

		Main.colorize(statusControl, statusTexture)

		if previousStatusControl then
			statusControl:SetAnchor(CENTER, previousStatusControl, CENTER, Main.COLUMN_WIDTH)
		else
			statusControl:SetAnchor(CENTER, nameControl, LEFT,
				Main.COLUMN_INDENT - Main.TIMER_INDENT
				+ Main.COLUMN_WIDTH / 2)
		end

		columnIndex = columnIndex + 1
		previousStatusControl = statusControl
	end
end

--[[
	Creates the column labels for the rows, which are the names of the enabled charactes.

	Resizes and constrains the window as necessary to contain the header.
--]]
function Main:createHeader()
	local headerControl = DQTWindow:GetNamedChild("Header")
	local previousControl = nil
	local headerHeight = 0
	local characters = self:getCharactersToShow()
	local columnHeaderControl
	local columnHeaderHeight

	for index, character in ipairs(characters) do
		columnHeaderControl = CreateControlFromVirtual("ColumnHeader", headerControl, "DQTColumnHeader", index)

		-- colorize current character name
		local formattedName = ((GetCurrentCharacterId() == character.id)
			and string.format("|c66b2ff%s|r", character.name)
			or character.name)
		columnHeaderControl:SetText(formattedName)
		columnHeaderControl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
		columnHeaderControl:SetFont(DQT.Font.Header)

		-- set column width but leave a little padding
		columnHeaderControl:SetWidth(self.COLUMN_WIDTH - 10)

		if previousControl then
			columnHeaderControl:SetAnchor(CENTER, previousControl, CENTER, self.COLUMN_WIDTH)
		else
			columnHeaderControl:SetAnchor(CENTER, headerControl, LEFT,
				self.COLUMN_INDENT + self.COLUMN_WIDTH / 2)
		end

		columnHeaderHeight = columnHeaderControl:GetHeight()

		if columnHeaderHeight > headerHeight then
			headerHeight = columnHeaderHeight
		end

		previousControl = columnHeaderControl
	end

	headerControl:SetHeight(columnHeaderHeight)

	-- ensure the window is exactly wide enough to contain the header, plus a little extra
	local width = self.COLUMN_INDENT + self.COLUMN_WIDTH * #characters + 40
	local _, minHeight, maxWidth, maxHeight = DQTWindow:GetDimensionConstraints()
	DQTWindow:SetDimensionConstraints(width, minHeight, maxWidth, maxHeight)
	DQTWindow:SetDimensions(width, DQTWindow:GetHeight())
	self:onResizeStop()
end

function Main:initializeRows()
	-- Create a section for each category of quests
	for _, section in ipairs(self:getSectionsToShow()) do
		local sectionNode

		if section.type() == "QuestSection" then
			sectionNode = self.tree:AddNode("DQTQuestSection", { section = section })

			-- Create a row for each quest in this section
			for _, questType in ipairs(section:getQuestTypes()) do
				local questTypeNode = self.tree:AddNode("DQTQuestType", { questType = questType }, sectionNode)

				-- for quest types with multiple quests that you can share, add option to show each one
				if questType:isShareable() then
					for _, quest in ipairs(questType:getQuests()) do
						self.tree:AddNode("DQTQuest", { quest = quest }, questTypeNode)
					end
				end
			end
		else
			-- timer section
			sectionNode = self.tree:AddNode("DQTTimerSection", { section = section })

			for _, quest in ipairs(section:getQuests()) do
				self.tree:AddNode("DQTTimer", { quest = quest }, sectionNode)
			end
		end

		sectionNode:SetOpen(true)
	end
end

--[[
	Handler for toggling showing of quests in quest type

	@param button (integer) which mouse mutton they click, e.g. MOUSE_BUTTON_INDEX_LEFT
--]]
function Main:onToggleQuestType(buttonControl, button)
	-- toggle only if left click
	if button == MOUSE_BUTTON_INDEX_LEFT then
		ZO_ToggleButton_Toggle(buttonControl)
		local parentNode = buttonControl:GetParent().node
		parentNode:SetOpen(not parentNode:IsOpen(), USER_REQUESTED_OPEN)
	end
end

-- save window position when moving it
function Main:onMoveStop()
	local x, y = DQTWindow:GetScreenRect()
	self.windowProperties.x = x
	self.windowProperties.y = y
end

-- save window size when resizing it
function Main:onResizeStop()
	local width, height = DQTWindow:GetDesiredWidth(), DQTWindow:GetDesiredHeight()
	self.windowProperties.width = width
	self.windowProperties.height = height
end

-- initializes GUI layout settings
function Main:initializeWindowScaling()
	local properties = self.windowProperties
	local scale = properties.scale or 1

	-- List of acceptable sizes
	local acceptableSizes = { 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 28, 30, 32, 34, 36, 40, 48, 54 }

	-- Helper function to round to the nearest acceptable size
	local function roundToNearest(size)
		local nearest = acceptableSizes[1]
		local smallestDiff = math.abs(size - nearest)
		for _, acceptableSize in ipairs(acceptableSizes) do
			local diff = math.abs(size - acceptableSize)
			if diff < smallestDiff then
				nearest = acceptableSize
				smallestDiff = diff
			end
		end
		return nearest
	end

	-- Function to format font strings
	local function formatFontString(style, size, weight)
		local roundedSize = roundToNearest(size * scale)
		return string.format("$(%s)|$(KB_%s)|%s", style, roundedSize, weight)
	end

	-- setup fonts

	DQT.Font = {}
	DQT.Font.Quest = formatFontString("MEDIUM_FONT", 16, "soft-shadow-thin")
	DQT.Font.Game = formatFontString("MEDIUM_FONT", 18, "soft-shadow-thin")
	DQT.Font.Header = formatFontString("BOLD_FONT", 18, "soft-shadow-thick")
	DQT.Font.Header2 = formatFontString("BOLD_FONT", 20, "soft-shadow-thick")
	DQT.Font.WindowSubtitle = formatFontString("BOLD_FONT", 18, "soft-shadow-thick")

	-- setup dimensions

	local dimensions = { 5, 10, 20, 24, 25, 28, 42, 200, 206, 210, 230, 300, 500 }
	for _, dimension in ipairs(dimensions) do
		_G["DQT_window_dimension" .. dimension] = dimension * scale
	end

	-- setup spacing

	Main.QUEST_TYPE_INDENT = 2 * scale
	Main.QUEST_INDENT = 30 * scale
	Main.TIMER_INDENT = 26 * scale

	-- how wide is each column with status box and character name
	Main.COLUMN_WIDTH = 100 * scale

	-- how far indented from left side is first column of character name
	Main.COLUMN_INDENT = 240 * scale
end

-- initializes window size and position from saved properties
function Main:initializeWindowProperties()
	local properties = self.windowProperties
	DQTWindow:ClearAnchors()
	DQTWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, properties.x, properties.y)
	DQTWindow:SetDimensions(properties.width, properties.height)
	DQTWindowTimeUntilReset:SetFont(DQT.Font.WindowSubtitle)
	DQTWindowCloseButton:SetDimensions(DQT_window_dimension25, DQT_window_dimension25)
end

function Main:initialize()
	-- load saved variables
	DQT.SV:init()

	-- reload previous window postion/size, and enable saving of postion/size
	self.windowProperties = DQT.SV:getAccountWide().windowProperties
	self:initializeWindowScaling()
	self:initializeWindowProperties()

	-- setup settings in menu
	DQT.Settings:initialize(DQT.SV:getAccountWide().settings, DQT.SV:getAccountWide().windowProperties)

	-- initialize window data
	self.resetTime = DQT.Utils:getResetTime()
	self.lastRefreshTime = os.time() -- last time we called RefreshVisible, in local time
	self:createHeader()

	local scrollContainer = DQTWindow:GetNamedChild("ScrollFrame")
	self.tree = ZO_Tree:New(scrollContainer:GetNamedChild("ScrollChild"), 0, 0, 3000)
	self.tree:AddTemplate("DQTQuestSection", self.TreeSectionSetup, nil, nil, Main.QUEST_TYPE_INDENT, 0)
	self.tree:AddTemplate("DQTQuestType", self.TreeQuestTypeSetup, nil, nil, Main.QUEST_INDENT, 0)
	self.tree:AddTemplate("DQTQuest", self.TreeQuestSetup, nil, nil, 0, 0)
	self.tree:AddTemplate("DQTTimerSection", self.TreeTimerSectionSetup, nil, nil, Main.TIMER_INDENT, 0)
	self.tree:AddTemplate("DQTTimer", self.TreeTimerSetup, nil, nil, 0, 0)
	self:initializeRows()

	-- register a slash command for showing the window by typing in the chat window
	SLASH_COMMANDS["/dqt"] = Main.toggleDisplay
	SLASH_COMMANDS["/dailyquest"] = Main.toggleDisplay
end

function Main.OnAddOnLoaded(event, addonName)
	-- The event fires each time *any* addon loads - but we only care about when our own addon loads
	if addonName == Main.name then
		EVENT_MANAGER:UnregisterForEvent(Main.name, EVENT_ADD_ON_LOADED)


		EVENT_MANAGER:RegisterForEvent(Main.name, EVENT_QUEST_ADDED, Main.onQuestAdded)
		EVENT_MANAGER:RegisterForEvent(Main.name, EVENT_QUEST_COMPLETE, Main.onQuestComplete)

		Main:initialize()
	end
end

EVENT_MANAGER:RegisterForEvent(Main.name, EVENT_ADD_ON_LOADED, Main.OnAddOnLoaded)
