--Change the numbers 999999 below to seconds that you want the chat to stay active
--If unpinned (not minimized)
local ZO_GAMEPAD_CHAT_SYSTEM_SECONDS_VISIBLE_UNPINNED = 999999
--If pinned (minimized)
local ZO_GAMEPAD_CHAT_SYSTEM_SECONDS_VISIBLE_PINNED = 999999


local calledOnce = false
local function onEventPlayerActivated()
    if calledOnce then return end
    if not IsChatSystemAvailableForCurrentPlatform() then return end

    --Gamepad chat
    local control = ZO_GamepadTextChat
    local selfGamepadChatSystem = GAMEPAD_CHAT_SYSTEM
    local g_expirationTime = 0

    function GAMEPAD_CHAT_SYSTEM:StartVisibilityTimer()
--d("[GamepadChatNoFade]GAMEPAD_CHAT_SYSTEM - StartVisibilityTimer")
        local secondsToExpire = ZO_GAMEPAD_CHAT_SYSTEM_SECONDS_VISIBLE_UNPINNED

        if selfGamepadChatSystem:IsWindowPinned() then
            secondsToExpire = ZO_GAMEPAD_CHAT_SYSTEM_SECONDS_VISIBLE_PINNED
        end

        g_expirationTime = GetFrameTimeSeconds() + secondsToExpire
    end

    --Remove old OnUpdateHandler of vanilla code
    control:SetHandler("OnUpdate", nil)

    -- timer handling
    local function OnUpdate()
        -- do not fade if the user is actively editing text
        if not IsVirtualKeyboardOnScreen() and not selfGamepadChatSystem.editControl:HasFocus() then
            if g_expirationTime then
                if GetFrameTimeSeconds() > g_expirationTime then
                    g_expirationTime = nil

                    for i,container in pairs(selfGamepadChatSystem.containers) do
                        container:HandleVisibleTimeExpired()
                    end
                end
            end
        end
    end
    control:SetHandler("OnUpdate", OnUpdate)

    calledOnce = true
end

EVENT_MANAGER:RegisterForEvent("GamepadChatNoFade_Event_Player_Activated", EVENT_PLAYER_ACTIVATED, onEventPlayerActivated)