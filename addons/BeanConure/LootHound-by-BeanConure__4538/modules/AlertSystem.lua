LootHound.AlertSystem = {}
local AS = LootHound.AlertSystem

function AS:Init()
    -- Relies on the native Center Screen Announce system; no overlay setup required.
end

-- Public function called by ItemTracker when a match is found.
function AS:Trigger(itemLink, entry)
    local sv = LootHound.savedVars
    local label = entry.label or "Watch Hit"

    -- 1. Chat Box Message
    if sv.alertChat then
        CHAT_SYSTEM:AddMessage(
            string.format(
                "|cE0BC6B[LootHound]|r Tracked item found: %s |c888888(Rule: %s)|r",
                itemLink, label
            )
        )
    end

    -- 2. Audio Chimes
    if sv.alertSound then
        PlaySound(SOUNDS.TELVAR_MULTIPLIERUP) 
        zo_callLater(function() PlaySound(SOUNDS.NEW_MAIL) end, 200)
    end

    -- 3. Center Screen Pop-up (Center Screen Announcement)
    if sv.alertFlash then
        -- Create a custom message parameter object to bypass default limitations
        local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.NONE)
        
        -- Format the text (Main Title, Subtitle)
        messageParams:SetText("|cE0BC6BTracked item found:|r", itemLink)
        
        -- Override the default speed so the text stays on screen for 4.5 seconds
        messageParams:SetLifespanMS(4500) 
        
        -- Push the message to the player's screen
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
    end
end