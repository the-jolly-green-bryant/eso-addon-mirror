
KeepStatus.MainBar = {}
KeepStatus.MainBar.type = "MainBar"
KeepStatus.MainBar.__index = KeepStatus.MainBar

setmetatable(KeepStatus.MainBar, {
    __call = function(cls, ...) return cls.new(...) end
})

local MainBar = KeepStatus.MainBar

function MainBar.new()
	return setmetatable({}, MainBar)
end

local TEXT_TIME = "txt1"
local L_LUMBERMILL, L_MINE, L_FARM = "img1", "img3", "img2"
local verticalY = 5

function MainBar:configureLabel(label)
	local startHorizontalX = 190

    label:exposeControls(3,1)

    label.main:SetCenterColor(KeepStatus.invisColor:UnpackRGBA())

    label:getControl(L_LUMBERMILL):SetTexture('esoui/art/icons/mapkey/mapkey_lumbermill.dds')
    label:getControl(L_FARM):SetTexture('esoui/art/icons/mapkey/mapkey_farm.dds')
    label:getControl(L_MINE):SetTexture('esoui/art/icons/mapkey/mapkey_mine.dds')

	label:positionControl(L_LUMBERMILL, KeepStatus.iconWidthHeight, KeepStatus.iconWidthHeight, startHorizontalX, verticalY)
	startHorizontalX = startHorizontalX + 30
    label:positionControl(L_FARM, KeepStatus.iconWidthHeight, KeepStatus.iconWidthHeight, startHorizontalX, verticalY)
	startHorizontalX = startHorizontalX + 30
    label:positionControl(L_MINE, KeepStatus.iconWidthHeight, KeepStatus.iconWidthHeight, startHorizontalX, verticalY)

	label:positionControl(TEXT_TIME, 90, 40, 10, 10)
end

function MainBar:updateLabel(label)
	if KeepStatus.SV.timerOn == true then
		label:getControl(TEXT_TIME):SetHidden(false)
		label:getControl(TEXT_TIME):SetText(KeepStatus.formatTime(GetSecondsUntilCampaignScoreReevaluation(KeepStatus.campaignId)))
	else
		label:getControl(TEXT_TIME):SetHidden(true)
	end
end

function MainBar:update()
	
end
