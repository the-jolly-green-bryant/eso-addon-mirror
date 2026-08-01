DsRGroupAttackProtocol       = {}
local DsRGroupAttackProtocol = DsRGroupAttackProtocol or {}

local LGB         = LibGroupBroadcast
local localPlayer = "player"

local protocolGroupAttackCountdown = {}
local MESSAGE_ID_PULLCOUNTDOWN     = 230 -- auf https://wiki.esoui.com/LibGroupBroadcast_IDs#Handlers eingetragen
local isCountdownActive            = false

---------------------------------------------------------
-- Eigenes Center-Screen-UI (ohne XML, mit Fade-In)
---------------------------------------------------------
DsRGroupAttackUI = {}

function DsRGroupAttackUI:Initialize()
    -- Top-Level Window
    self.control = WINDOW_MANAGER:CreateTopLevelWindow("DsRGroupAttackCountdownUI")
    local c = self.control

    c:ClearAnchors()
    c:SetAnchor(CENTER, GuiRoot, CENTER, 0, -250)
    c:SetDimensions(600, 200)
    c:SetHidden(true)
    c:SetHandler("OnShow", function()
        c:SetAlpha(1)
    end)
    c:SetMovable(false)
    c:SetMouseEnabled(false)
    c:SetClampedToScreen(true)

    -- Text
    c.label = WINDOW_MANAGER:CreateControl(nil, c, CT_LABEL)
    c.label:SetAnchor(CENTER, c, CENTER, 0, 0)
    c.label:SetFont("$(BOLD_FONT)|200|soft-shadow-thick")
    c.label:SetColor(1, 0, 1, 1)   -- reines Magenta
    c.label:SetHidden(false)

    -- Badge-Bild für "0 erreicht"
    c.badge = WINDOW_MANAGER:CreateControl(nil, c, CT_TEXTURE)
    c.badge:SetAnchor(CENTER, c, CENTER, 0, 0)
    c.badge:SetDimensions(256, 256)
    c.badge:SetTexture("EsoUI/Art/HUD/HUD_Countdown_Badge_Dueling.dds")
    c.badge:SetColor(0.1, 1, 0.1, 1)
    c.badge:SetHidden(true)

    -- Draw order
    c:SetDrawLayer(DL_OVERLAY)
    c:SetDrawTier(DT_HIGH)
    c:SetDrawLevel(999999)

    -- Animation
    self.timeline = ANIMATION_MANAGER:CreateTimeline()

    local fade = self.timeline:InsertAnimation(ANIMATION_ALPHA, c.label)
    fade:SetDuration(300)
    fade:SetStartAlpha(0)
    fade:SetEndAlpha(1)
end

-- Zeigt eine einzelne Zahl mit Fade-In an und blendet sie nach "seconds" wieder aus
function DsRGroupAttackUI:ShowNumber(num)
    local c = self.control

    c:SetHidden(false)
    c.label:SetHidden(false)
    c.label:SetText(tostring(num))
    c.label:SetAlpha(0)

    self.timeline:PlayFromStart()

    PlaySound(SOUNDS.MAP_PING)
end

-- Startet einen 3-2-1-... Countdown
function DsRGroupAttackUI:StartCountdown(seconds)
    local remaining = seconds
local texturePath = "EsoUI/Art/HUD/HUD_Countdown_Badge_Dueling.dds"
    local function tick()
        if remaining <= 0 then
            -- Zahl ausblenden
            self.control.label:SetHidden(true)

            -- Badge anzeigen
            self.control.badge:SetHidden(false)

            PlaySound(SOUNDS.DUEL_START)

            -- 1 Sekunde später Badge ausblenden
            zo_callLater(function()
                self.control.badge:SetHidden(true)
                self.control:SetHidden(true)
            end, 1000)

            return
        end

        self:ShowNumber(remaining)
        remaining = remaining - 1

        zo_callLater(tick, 1000)
    end
    tick()
end

---------------------------------------------------------
-- LGB / Protokoll-Registrierung
---------------------------------------------------------
function DsRGroupAttackProtocol:RegisterLGBProtocols(handler)
    local handler            = LGB:RegisterHandler("DsRGuildHall", "DsRGAPHandler")
    local CreateNumericField = LGB.CreateNumericField
    local protocolOptions    = {
        isRelevantInCombat = false
    }
    protocolGroupAttackCountdown = handler:DeclareProtocol(MESSAGE_ID_PULLCOUNTDOWN, "DsRGroupAttackCountdown")
    protocolGroupAttackCountdown:AddField(CreateNumericField("duration", {
        minValue = 3,
        maxValue = 10,
    }))
    protocolGroupAttackCountdown:OnData(function(...) DsRGroupAttackProtocol:onGroupAttackCountdownMessageReceived(...) end)
    protocolGroupAttackCountdown:Finalize(protocolOptions)

    DsRGroupAttackUI:Initialize()
end

---------------------------------------------------------
-- Rendering des Countdowns
---------------------------------------------------------
function DsRGroupAttackProtocol:RenderGroupAttackCountdown(durationMS)
    local seconds = math.floor((durationMS or 0) / 1000)
    if seconds < 1 then seconds = 1 end

    -- !!!!! AKTUELL IST KEIN VERSATZ MEHR DRIN !!!!!!!
    -- if IsUnitGroupLeader(localPlayer) then --  Falls ein Versatz von 1 Sekunde zwischen LEAD und GROUP ist
        -- zo_callLater(function()  DsRGroupAttackUI:StartCountdown(seconds) end, 1000)
    -- else
        DsRGroupAttackUI:StartCountdown(seconds)
    -- end
end

---------------------------------------------------------
-- Empfang der LGB-Nachricht
---------------------------------------------------------
function DsRGroupAttackProtocol:onGroupAttackCountdownMessageReceived(unitTag, data)
    if isCountdownActive then return end

    local duration = data.duration * 1000
    isCountdownActive = true
    zo_callLater(function() isCountdownActive = false end, duration)
    DsRGroupAttackProtocol:RenderGroupAttackCountdown(duration)
end

---------------------------------------------------------
-- Senden der LGB-Nachricht
---------------------------------------------------------
function DsRGroupAttackProtocol:SendGroupAttackCountdown(duration)
    duration = tonumber(duration) or DsRGuildPvP.pvp.PvPGroupAttackTime

    if not IsUnitGroupLeader(localPlayer) then
        CHAT_SYSTEM:Maximize()
        df('|cFF0000%s|r', DsR.Localization[DsR.language].DsRGuildGroupAttack_NOT_LEADER)
        return
    end

    if not duration then duration = DsRGuildPvP.pvp.PvPGroupAttackTime end
    if duration < 3 then duration = 3 end
    if duration > 10 then duration = 10 end

    protocolGroupAttackCountdown:Send({
        duration = duration
    })

    -- Wenn ich in keiner Gruppe bin zum testen !!
    -- DsRGroupAttackProtocol:onGroupAttackCountdownMessageReceived(localPlayer, { duration = duration })
end

