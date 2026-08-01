CitizenClock = {
    name = "CitizenClock",
}

local Refresh

--CitizenClock.name .."OneMinTick", 60000
local function RefreshEveryMin()
    local t, s = ZO_FormatTime(GetSecondsSinceMidnight(), TIME_FORMAT_STYLE_CLOCK_TIME, TIME_FORMAT_PRECISION_TWELVE_HOUR, nil)
	CitizenRTC_Time:SetText(t)

    if (60-s) > 2 then
        EVENT_MANAGER:UnregisterForUpdate(CitizenClock.name .."OneMinTick")
        EVENT_MANAGER:RegisterForUpdate(CitizenClock.name .."Refresh", 750, Refresh)
    end
end

--CitizenClock.name .."Refresh", 750
function Refresh()
    local t, s = ZO_FormatTime(GetSecondsSinceMidnight(), TIME_FORMAT_STYLE_CLOCK_TIME, TIME_FORMAT_PRECISION_TWELVE_HOUR, nil)
	CitizenRTC_Time:SetText(t)

    if s == 60 then
        EVENT_MANAGER:UnregisterForUpdate(CitizenClock.name .."Refresh")
        EVENT_MANAGER:RegisterForUpdate(CitizenClock.name .."OneMinTick", 60000, RefreshEveryMin)
    end
end

function CitizenClock.Start()
    local CitizenRTC = CreateControl("CitizenRTC", GuiRoot, CT_TOPLEVELCONTROL)
    CitizenRTC:SetDimensions(128, 64)
    CitizenRTC:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, CitizenAddon.generalOptions.realTimeClock.left, CitizenAddon.generalOptions.realTimeClock.top)
    CitizenRTC:SetMouseEnabled(true)
    CitizenRTC:SetMovable(true)
    CitizenRTC:SetClampedToScreen(false)
    CitizenRTC:SetDrawTier(DT_HIGH)
    CitizenRTC:SetHidden(true)
    CitizenRTC:SetHandler("OnMoveStop", function ()
        CitizenAddon.generalOptions.realTimeClock.left = CitizenRTC:GetLeft()
        CitizenAddon.generalOptions.realTimeClock.top = CitizenRTC:GetTop()
    end)
    -- Background Texture
    local background = CreateControl("CitizenRTC_Background", CitizenRTC, CT_TEXTURE)
    background:SetTexture("/esoui/art/performance/statusmetermunge.dds")
    background:SetTextureCoords(0.125, 0.875, 0.375, 0.625)
    background:SetAnchorFill()
    -- Time Label
    local timeLabel = CreateControl("CitizenRTC_Time", CitizenRTC, CT_LABEL)
    timeLabel:SetFont("ZoFontWinT2")
    timeLabel:SetColor(1, 1, 1, 1)
    timeLabel:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
    timeLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    timeLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    timeLabel:SetAnchorFill()

    EVENT_MANAGER:RegisterForUpdate(CitizenClock.name .."Refresh", 750, Refresh)
end