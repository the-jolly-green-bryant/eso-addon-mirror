if IsNewerEssentialHousingHubVersionAvailable() or not IsEssentialHousingHubRootPathValid() then
	return
end

local EHH = EssentialHousingHub
if not EHH then
	return
end

---[ Help ]---

function EHH:GetHelpTopicData()
	return HOUSING_HUB_HELP_TOPICS
end

function EHH:GetHelpDialog()
	return HousingHubHelp
end

function EHH:GetHelpSettings()
	local settings = self:GetSettings()
	local data = settings.HelpDialog

	if not data then
		data =
		{
			Anchor = TOPLEFT,
			X = 50,
			Y = 50,
			SizeX = 800,
			SizeY = 600,
		}
		settings.HelpDialog = data
	end

	return data
end

function EHH:SetHelpSettings(anchor, x, y, sizeX, sizeY)
	if anchor and x and y and sizeX and sizeY then
		local data = self:GetHelpSettings()
		data.Anchor, data.X, data.Y, data.SizeX, data.SizeY = anchor, x, y, sizeX, sizeY
	end
end

function EHH:RefreshHelpSettings(anchor, x, y, sizeX, sizeY)
	local helpDialog = self:GetHelpDialog()
	local screenWidth, screenHeight = GuiRoot:GetDimensions()
	local width, height = helpDialog:GetDimensions()
	local left, top = helpDialog:GetLeft(), helpDialog:GetTop()

	if x and y then
		self:SetHelpSettings(anchor, x, y, sizeX, sizeY)
	else
		local data = self:GetHelpSettings()
		anchor, x, y, sizeX, sizeY = data.Anchor, data.X, data.Y, data.SizeX, data.SizeY
	end

	helpDialog:ClearAnchors()
	helpDialog:SetAnchor(anchor, GuiRoot, nil, x, y)
	helpDialog:SetDimensions(sizeX, sizeY)
end

function EHH:SetCanHelpShow(visible)
	local helpDialog = self:GetHelpDialog()
	if helpDialog then
		helpDialog.CanShow = visible
		helpDialog:SetHidden(helpDialog.IsHidden or not helpDialog.CanShow)
	end
end

function EHH:SetHelpHidden(hidden)
	local helpDialog = self:GetHelpDialog()
	if helpDialog then
		helpDialog.IsHidden = hidden
		helpDialog:SetHidden(helpDialog.IsHidden or not helpDialog.CanShow)
	end
end

function EHH:SetHelpAnchor(point, relativeTo, relativePoint, offsetX, offsetY)
	local helpDialog = self:GetHelpDialog()
	if helpDialog then
		helpDialog:ClearAnchors()
		helpDialog:SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY)
	end
end

function EHH:SetupHelp(helpDialog)
	helpDialog.Search = helpDialog:GetNamedChild("Search")
	helpDialog.SearchBackdrop = helpDialog:GetNamedChild("SearchBackdrop")

	local hideSearchBox = 10 > NonContiguousCount(self:GetHelpTopicData())
	helpDialog.Search:SetHidden(hideSearchBox)
	helpDialog.SearchBackdrop:SetHidden(hideSearchBox)

	helpDialog.TopicPool = ZO_ControlPool:New("HousingHubHelpTopicLabel", helpDialog:GetNamedChild("TopicsScrollScrollChild"), "HousingHubHelpTopic")
	helpDialog.LastTopic = nil

	helpDialog.AcquireTopic = function(helpDialog)
		local topic = helpDialog.TopicPool:AcquireObject()
		topic:SetInheritAlpha(false)
		topic:SetWidth(248)
		return topic
	end

	helpDialog.ReleaseAllTopics = function(helpDialog)
		helpDialog.LastTopic = nil
		helpDialog.TopicPool:ReleaseAllObjects()
	end
	
	helpDialog.AddTopic = function(helpDialog, topicId, topicLabel)
		local topic = helpDialog:AcquireTopic()
		topic.TopicId = topicId
		topic:SetText(topicLabel)

		topic:ClearAnchors()
		if helpDialog.LastTopic then
			topic:SetAnchor(TOPLEFT, helpDialog.LastTopic, BOTTOMLEFT, 0, 6)
		else
			topic:SetAnchor(TOPLEFT, nil, nil, 0, 0)
		end
		helpDialog.LastTopic = topic

		return topic
	end
end

do
	local function HelpTopicComparer(left, right)
		return left.TitleLower < right.TitleLower
	end

	function EHH:FilterHelpTopics(search)
		local helpDialog = self:GetHelpDialog()
		helpDialog:ReleaseAllTopics()

		if not search then
			search = helpDialog.TopicFilter or ""
		else
			search = self:Trim(string.lower(search or ""))
			helpDialog.TopicFilter = search
		end

		local data = self:GetHelpTopicData()
		if data then
			local topics = {}

			for topicId, topicData in pairs(data) do
				local title = topicData.TitleLower
				local content = topicData.ContentLower

				if "" == search or zo_plainstrfind(title, search) or zo_plainstrfind(content, search) then
					table.insert(topics, topicData)
				end
			end

			table.sort(topics, HelpTopicComparer)

			for topicIndex, topicData in ipairs(topics) do
				helpDialog:AddTopic(topicData.TopicId, topicData.Title)
			end
		end
	end
end

function EHH:ShowHelpTopic(topic)
	local helpDialog = self:GetHelpDialog()
	local contentString, contentUrl = self:GetHelpTopicContent(topic)
	if contentString then
		helpDialog.ContentLabel:SetText(contentString)
		self:SetHelpHidden(false)
	elseif contentUrl then
		self:HideHelp()
		self:HideHousingHub()
		self:ShowURL(contentUrl)
	end
end

function EHH:HideHelp()
	self:SetHelpHidden(true)
end

function EHH:ResetHelp()
	self:ShowHelpTopic("Index")
end

function EHH:GetHelpTopicContent(topic)
	local data = self:GetHelpTopicData()
	if data then
		local topicData = data[topic]
		if topicData then
			if topicData.Url then
				return nil, topicData.Url
			else
				local title = topicData.Title or ""
				local content = topicData.Content or ""
				return string.format("|ac%s\n|r\n%s", title, content), nil
			end
		end
	end

	return string.format("There currently is no information on the topic \"%s\"", topic or "(n/a)"), nil
end

---[ Global XML ]---

-- Help Dialog

function EHH_Help_OnInitialized(self)
	local hub = EssentialHousingHub
	hub:SetupHelp(self)
	hub:SetHelpHidden(true)
end

function EHH_Help_OnEffectivelyShown()
	EssentialHousingHub:RefreshHelpSettings()
	EssentialHousingHub:FilterHelpTopics()
end

do
	local function OnHelpMouseUpdate(self)
		local mouseX, mouseY = GetUIMousePosition()
		if self:IsPointInside(mouseX, mouseY, 6, 6, -6, -6) then
			WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_PAN)
		else
			WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_DO_NOT_CARE)
		end
	end

	function EHH_Help_OnMouseEnter(self)
		self:SetHandler("OnUpdate", OnHelpMouseUpdate, "MouseCursor")
	end
end

function EHH_Help_OnMouseExit(self)
	self:SetHandler("OnUpdate", nil, "MouseCursor")
	WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_DO_NOT_CARE)
end

function EHH_Help_OnStopMovingOrResizing(self)
	local hub = EssentialHousingHub
	local x, y = self:GetLeft(), self:GetTop()
	local sizeX, sizeY = self:GetDimensions()
	hub:RefreshHelpSettings(TOPLEFT, x, y, sizeX, sizeY)
end

function EHH_Help_OnRectChanged(self)
	if self.Content then
		local width, height = self.Content:GetDimensions()
		self.Content:SetTextureCoords(0.05, width / 2000, 0.05, height / 1000)

		if self.ContentLabel then
			self.ContentLabel:SetWidth(width - 32)
		end
	end

	if self.Topics then
		local width, height = self.Topics:GetDimensions()
		self.Topics:SetTextureCoords(width / 2000, 0.05, 0.05, height / 1000)
	end
end

function EHH_Help_OnTopicClicked(self)
	local topic = self.TopicId
	EssentialHousingHub:ShowHelpTopic(topic)
end

---[ Module Registration ]---

EssentialHousingHub.Modules.UserInterfaceHelp = true