local PlayersOnlineFragment = ZO_Object:Subclass()
SocialIndicators.PlayersOnlineFragment = PlayersOnlineFragment

function PlayersOnlineFragment:New(db)
	local index = ZO_Object.New(self)
	index:Initialize(db)
	return index
end

function PlayersOnlineFragment:Initialize(socialListFragment)
	self.socialListFragment = socialListFragment
	self.control = WINDOW_MANAGER:CreateTopLevelWindow("SocialIndicatorsPlayersOnlineContainer")
	self.control:SetHidden(true)
	self.control:SetAnchor(TOPLEFT, SocialIndicatorsSocialList, TOPLEFT, 52, 28)
	self.label = self.control:CreateControl("$(parent)Label", CT_LABEL)
	self.label:SetAnchor(TOPLEFT)
	self.label:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
	self.label:SetFont("ZoFontGameLargeBold")
	self.label:SetText("Players Online:") -- TODO: localize
	self.count = self.control:CreateControl("$(parent)Count", CT_LABEL)
	self.count:SetAnchor(LEFT, self.label, RIGHT, 2, 0)
	self.count:SetFont("ZoFontGameLargeBold")
	self.fragment = ZO_FadeSceneFragment:New(self.control, nil, 0)
	self:Update()

	CALLBACK_MANAGER:RegisterCallback("SocialIndicators_SocialListChanged", function(onlineCount, totalCount, filteredOnlineCount, filteredTotalCount)
		self:Update(onlineCount, totalCount, filteredOnlineCount, filteredTotalCount)
	end)
end

function PlayersOnlineFragment:Update(online, total, filteredOnline, filteredTotal)
	if(online == nil) then
		online, total = 0, 0
	end
	local format = (filteredTotal == nil) and "%d/%d" or "%d/%d (%d/%d)"
	self.count:SetText(string.format(format, online, total, filteredOnline, filteredTotal))
end
