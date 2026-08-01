CitizenNotifier = {
    name = "CitizenNotifier",

    OSI = {
        callback = {
            bounce =
                function(data)
                    data.offset = 0.5 + 0.5 * math.sin(GetGameTimeMilliseconds() / 1000 * 2)
                end,
        },
    },
}
local alert = false
local alert2 = false

------------------------
--Notification Section--
------------------------
--notifications Show/Hide
function CitizenNotifier.ShowAndHideSample()
    if CitizenBanner_1:IsHidden() then
        CitizenBanner_1:SetText("Banner Position")
        CitizenBanner:SetMovable(true)

        CitizenAlert_1:SetText("Alert Position")
        CitizenAlert:SetMovable(true)

        CitizenBanner_1:SetHidden(false)
        CitizenAlert_1:SetHidden(false)
    else
        CitizenBanner_1:SetHidden(true)
        CitizenAlert_1:SetHidden(true)

        CitizenBanner:SetMovable(false)
        CitizenAlert:SetMovable(false)
    end
end
--Save notifiers new location
function CitizenNotifier.saveUiPosition()
    CitizenAddon.notifier.banner.left = CitizenBanner:GetLeft()
    CitizenAddon.notifier.banner.top = CitizenBanner:GetTop()

    CitizenAddon.notifier.alert.left = CitizenAlert:GetLeft()
    CitizenAddon.notifier.alert.top = CitizenAlert:GetTop()
end

------------------------
--Banner/Alert Section--
------------------------
--Set a Banner
function CitizenNotifier.SetBanner(text)
    if CitizenBanner_1:IsHidden() then
        CitizenBanner_1:SetHidden(false)
    end
    CitizenBanner_1:SetText(text)
end
--Remove a Banner
function CitizenNotifier.RemoveBanner()
    CitizenBanner_1:SetHidden(true)
    CitizenBanner_1:SetText("Banner Position")
end
--Set Banner 2
function CitizenNotifier.SetBanner2(text)
    if CitizenBanner_2:IsHidden() then
        CitizenBanner_2:SetHidden(false)
    end
    CitizenBanner_2:SetText(text)
end
--Remove Banner 2
function CitizenNotifier.RemoveBanner2()
    CitizenBanner_2:SetHidden(true)
    CitizenBanner_2:SetText("Banner 2 Position")
end
--Set Banner 3
function CitizenNotifier.SetBanner3(text)
    if CitizenBanner_3:IsHidden() then
        CitizenBanner_3:SetHidden(false)
    end
    CitizenBanner_3:SetText(text)
end
--Remove Banner 3
function CitizenNotifier.RemoveBanner3()
    CitizenBanner_3:SetHidden(true)
    CitizenBanner_3:SetText("Banner 3 Position")
end
--Remove all banners
function CitizenNotifier.RemoveAllBanners()
    CitizenBanner_1:SetHidden(true)
    CitizenBanner_2:SetHidden(true)
    CitizenBanner_3:SetHidden(true)
    CitizenBanner_1:SetText("Banner Position")
    CitizenBanner_2:SetText("Banner 2 Position")
    CitizenBanner_3:SetText("Banner 3 Position")
end
--Alert
function CitizenNotifier.Alert(text ,time, sound)
    if not alert then
        alert = true
        CitizenAlert_1:SetText(text)
        CitizenAlert_1:SetHidden(false)
        zo_callLater(
            function()
                CitizenAlert_1:SetHidden(true)
                CitizenAlert_1:SetText("Alert Position")
                alert = false
            end,
            time
        )
    elseif alert and not alert2 then
        alert2 = true
        CitizenAlert_2:SetText(text)
        CitizenAlert_2:SetHidden(false)
        zo_callLater(
            function()
                CitizenAlert_2:SetHidden(true)
                CitizenAlert_2:SetText("Alert 2 Position")
                alert2 = false
            end,
            time
        )
    elseif alert and alert2 then
        CitizenAlert_3:SetText(text)
        CitizenAlert_3:SetHidden(false)
        zo_callLater(
            function()
                CitizenAlert_3:SetHidden(true)
                CitizenAlert_3:SetText("Alert 3 Position")
            end,
            time
        )
    else
        zo_callLater(
            function()
                CitizenNotifier.Alert(text ,time, nil)
            end,
            1000
        )
    end
    if sound ~= nil then
        PlaySound(sound)
    end
end

---------------
--OSI Section--
---------------
--Set a icon for player (can have refreshable timer)
---@param displayName string
---@param texture string
---@param size number|nil
---@param color table|nil {R number, G number, B number, A number|nil}
---@param offset number|nil
---@param callback function|nil
---@param time table|nil {timer number, showTimer boolean|nil, stackable boolean|nil, stayAfter boolean|nil}
function CitizenNotifier.Icon(displayName, texture, size, color, offset, callback, time)
    OSI.SetMechanicIconForUnit(displayName, texture, size, color, offset, callback)

    if time ~= nil then
        local timer, showTimer, stackable, stayAfter = time[1], time[2], time[3], time[4]

        if showTimer then
            local icon = OSI.GetIconForPlayer(displayName)

            if icon then
                if stackable then
                    icon.CitiEndTimes = icon.CitiEndTimes or {}
                    table.insert(icon.CitiEndTimes, (GetFrameTimeMilliseconds()+timer) / 1000)
                else
                    icon.CitiEndTime = (GetFrameTimeMilliseconds()+timer) / 1000
                end

                if not icon.CitiLabel then
                    icon.CitiLabel = icon.ctrl:CreateControl(icon.ctrl:GetName() .."Label", CT_LABEL)
                    icon.CitiLabel:SetAnchor(CENTER, icon.ctrl, CENTER, 0, 0)
                    icon.CitiLabel:SetFont("$(BOLD_FONT)|$(KB_54)|outline")
                    icon.CitiLabel:SetScale(icon.ctrl:GetScale()+0.3)
                    icon.CitiLabel:SetDrawLayer(DL_BACKGROUND)
                    icon.CitiLabel:SetDrawTier(DT_LOW)
                    icon.CitiLabel:SetColor(0.9, 0.9, 0.9, 0.85)
                    icon.CitiLabel:SetDrawLevel(icon.ctrl:GetDrawLevel()+1)
                end
            else
                return
            end
            icon.CitiLabel:SetHidden(false)

            EVENT_MANAGER:RegisterForUpdate(CitizenNotifier.name .."IconFor".. displayName, 500,
                function ()
                    local currentTime = GetFrameTimeMilliseconds()/1000

                    if stackable then
                        if currentTime >= icon.CitiEndTimes[1] then
                            table.remove(icon.CitiEndTimes, 1)
                        end

                        if #icon.CitiEndTimes == 1 then
                            icon.CitiLabel:SetText(tostring(zo_floor(icon.CitiEndTimes[1]-currentTime)))
                        elseif #icon.CitiEndTimes == 2 then
                            icon.CitiLabel:SetText(tostring(zo_floor(icon.CitiEndTimes[1]-currentTime)) .." |cf0f0f0/|r ".. tostring(zo_floor(icon.CitiEndTimes[2]-currentTime)))
                        elseif #icon.CitiEndTimes == 3 then
                            icon.CitiLabel:SetText(tostring(zo_floor(icon.CitiEndTimes[1]-currentTime)) .." |cf0f0f0/|r ".. tostring(zo_floor(icon.CitiEndTimes[2]-currentTime)) .." |cf0f0f0/|r ".. tostring(zo_floor(icon.CitiEndTimes[3]-currentTime)))
                        elseif #icon.CitiEndTimes == 4 then
                            icon.CitiLabel:SetText(tostring(zo_floor(icon.CitiEndTimes[1]-currentTime)) .." |cf0f0f0/|r ".. tostring(zo_floor(icon.CitiEndTimes[2]-currentTime)) .." |cf0f0f0/|r ".. tostring(zo_floor(icon.CitiEndTimes[3]-currentTime)) .." |cf0f0f0/|r ".. tostring(zo_floor(icon.CitiEndTimes[4]-currentTime)))
                        elseif #icon.CitiEndTimes >= 5 then
                            icon.CitiLabel:SetText("+5 Stacks")
                        end

                        if #icon.CitiEndTimes == 0 then
                            EVENT_MANAGER:UnregisterForUpdate(CitizenNotifier.name .."IconFor".. displayName)

                            if stayAfter then
                                icon.CitiLabel:SetText("Over")
                            else
                                CitizenNotifier.RemoveIcon(displayName)
                            end
                        end

                    else
                        local timeLeft = icon.CitiEndTime - currentTime
                        icon.CitiLabel:SetText(tostring(zo_floor(timeLeft)))

                        if timeLeft <= 0 then
                            EVENT_MANAGER:UnregisterForUpdate(CitizenNotifier.name .."IconFor".. displayName)

                            if stayAfter then
                                icon.CitiLabel:SetText("Over")
                            else
                                CitizenNotifier.RemoveIcon(displayName)
                            end
                        end
                    end
                end
            )
        else
            EVENT_MANAGER:RegisterForUpdate(CitizenNotifier.name .."IconFor".. displayName, timer,
                function ()
                    EVENT_MANAGER:UnregisterForUpdate(CitizenNotifier.name .."IconFor".. displayName)
                    CitizenNotifier.RemoveIcon(displayName)
                end
            )
        end
    end
end
--Remove a icon of a player
function CitizenNotifier.RemoveIcon(displayName)
    local icon = OSI.GetIconForPlayer(displayName)
    if icon and icon.CitiLabel then
        icon.CitiLabel:SetHidden(true)
        icon.CitiLabel:SetText("")
    end
    OSI.RemoveMechanicIconForUnit(displayName)
end
--Set a world position icon (can have refreshable timer)
function CitizenNotifier.WroldPositionIcon(x, y, z, texture, size, color, offset, callback, time)
    local groundIcon = OSI.CreatePositionIcon(x, y, z, texture, size, color, offset, callback)

    if time ~= nil then --(Using EVENT_MANAGER:RegisterForUpdate instead of zo_callLater makes it refreshable)
        EVENT_MANAGER:RegisterForUpdate(CitizenNotifier.name .."IconFor".. x..":"..y..":"..z, time,
            function ()
                EVENT_MANAGER:UnregisterForUpdate(CitizenNotifier.name .."IconFor".. x..":"..y..":"..z)
                OSI.DiscardPositionIcon(groundIcon)
                groundIcon = nil
            end
        )
    end
end



---------
--Lists--
---------

-- white = {1,1,1},
-- red = {1,0,0},
-- orange = {1,0.5,0},
-- yellow = {1,1,0},
-- green = {0,1,0},
-- aqua = {0,1,1},
-- blue = {0,0,1},
-- purple = {0.5,0,1},
-- black = {0,0,0},

-- SOUNDS.DUEL_START
-- SOUNDS.DUEL_FORFEIT