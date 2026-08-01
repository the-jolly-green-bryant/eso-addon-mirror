local ArcanumGuildHall = _G["ArcanumGuildHall"]

local res = ArcanumGuildHallMediaRes
local ArcanumClockFragment = ZO_SimpleSceneFragment:New(ArcanumClock)
local LMP = LibMediaProvider

LMP:Register("background", "ESO Status", "EsoUI/art/performance/statusmetermunge.dds")

function ArcanumGuildHall:GetInGameTime()
    if not self.db.showInGameTime then
        ArcanumClockInGameTimeText:SetHidden(true)
        return nil
    end

    local inGameSecPerDay = 20955
    local realTime = GetTimeStamp()
    local inGameTime = (realTime % inGameSecPerDay) * 86400 / inGameSecPerDay

    ArcanumClockInGameTimeText:SetHidden(false)
    return FormatTimeSeconds(
            inGameTime,
            TIME_FORMAT_STYLE_CLOCK_TIME,
            TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR,
            TIME_FORMAT_DIRECTION_NONE
    )
end

function ArcanumGuildHall:UpdateTime()
    local timeString = ArcanumGuildHall:GetTimeString()
    local inGameTimeString = self:GetInGameTime() or ""

    if ArcanumClockText:GetText() ~= timeString then
        ArcanumClockText:SetText(timeString)
    end

    if ArcanumClockInGameTimeText:GetText() ~= inGameTimeString then
        ArcanumClockInGameTimeText:SetText(inGameTimeString)
    end
end

function ArcanumGuildHall:UpdateClockStyle()
    local font = LMP:Fetch("font", self.db.clockTextFont)
    local fontStr = string.format("%s|%d|%s", font, self.db.clockFontSize, self.db.clockFontOutline)
    local inGameTimefontStr = string.format(
            "%s|%d|%s",
            font,
            math.max(self.db.clockFontSize - self.db.inGameTimeDelta, 4),
            self.db.clockFontOutline
    )
    local texture = LMP:Fetch("background", self.db.clockBackground)

    if self.db.showClockBG == true then
        ArcanumClockBG:SetHidden(false)
        ArcanumClockBG:SetTexture(texture)

        local r, g, b = self:ConvHexToRGB(self.db.clockBackgroundColor)
        ArcanumClockBG:SetColor(r, g, b, 1)
        ArcanumClockBG:SetAlpha(self.db.clockBackgroundAlpha / 100)
    else
        ArcanumClockBG:SetHidden(true)
    end

    ArcanumClockText:SetFont(fontStr)

    local r, g, b = self:ConvHexToRGB(self.db.clockFontColor)
    ArcanumClockText:SetColor(r, g, b, 1)

    local width, height = ArcanumClockText:GetTextDimensions()

    local kaese, nacho = 0, 0

    ArcanumClockText:ClearAnchors()

    if self.db.showInGameTime then
        ArcanumClockInGameTimeText:SetFont(inGameTimefontStr)

        local ir, ig, ib = self:ConvHexToRGB(self.db.inGameTimeColor)
        ArcanumClockInGameTimeText:SetColor(ir, ig, ib, 1)

        kaese, nacho = ArcanumClockInGameTimeText:GetTextDimensions()
        ArcanumClockText:SetAnchor(CENTER, ArcanumClock, CENTER, 0, -8)
    else
        ArcanumClockText:SetAnchor(CENTER, ArcanumClock, CENTER, 0, 0)
    end

    ArcanumClock:SetDimensions(math.max(width, kaese) + 40, height + nacho + 18)
end

function ArcanumGuildHall:UpdateAnchors(panelOpen)
    panelOpen = panelOpen or false

    ArcanumClock:ClearAnchors()

    if panelOpen then
        ArcanumClock:SetAnchor(LEFT, LAMAddonSettingsWindow, RIGHT, 50, 0)
    elseif self.db.clockOffset == nil then
        ArcanumClock:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, 0, 0)
    else
        ArcanumClock:SetAnchor(CENTER, GuiRoot, TOPLEFT, self.db.clockOffset.x, self.db.clockOffset.y)
    end

    ArcanumClock:SetMovable(not panelOpen)
    ArcanumClock:SetHidden(not self.db.showClock)
end

function ArcanumGuildHall:InitClock()
    EVENT_MANAGER:UnregisterForUpdate("ArcanumClockUpdate")
    HUD_SCENE:RemoveFragment(ArcanumClockFragment)
    HUD_UI_SCENE:RemoveFragment(ArcanumClockFragment)

    if self.db.showClock == true then
        HUD_SCENE:AddFragment(ArcanumClockFragment)
        HUD_UI_SCENE:AddFragment(ArcanumClockFragment)

        EVENT_MANAGER:RegisterForUpdate("ArcanumClockUpdate", 2000, function()
            self:UpdateTime()
        end)

        self:UpdateTime()
        self:UpdateClockStyle()
        self:UpdateAnchors()

        zo_callLater(function()
            ArcanumGuildHall:UpdateClockStyle()
        end, 500)
    else
        ArcanumClock:SetHidden(true)
    end
end

function ArcanumGuildHall:SaveClockPosition()
    local centerx, centery = ArcanumClock:GetCenter()
    self.db.clockOffset = {
        x = centerx,
        y = centery,
    }
end

function ArcanumGuildHall:IsPlayerInCombat(_, inCombat)
    if not self.db.isInCombatClock then
        return
    end

    if inCombat == nil then
        inCombat = IsUnitInCombat("player")
    end

    local r, g, b = self:ConvHexToRGB(self.db.clockFontColor)
    local ir, ig, ib = self:ConvHexToRGB(self.db.inGameTimeColor)

    if inCombat ~= self.combat then
        self.combat = inCombat

        if inCombat then
            ArcanumClockText:SetColor(1, 0, 0, 1)
            ArcanumClockInGameTimeText:SetColor(1, 0, 0, 1)
        else
            ArcanumClockText:SetColor(r, g, b, 1)
            ArcanumClockInGameTimeText:SetColor(ir, ig, ib, 1)
        end
    end
end