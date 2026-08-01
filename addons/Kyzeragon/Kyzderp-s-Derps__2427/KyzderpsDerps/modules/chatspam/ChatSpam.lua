KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.ChatSpam = KyzderpsDerps.ChatSpam or {}
local Spam = KyzderpsDerps.ChatSpam
Spam.name = KyzderpsDerps.name .. "Spam"

---------------------------------------------------------------------
-- Messaging choice
---------------------------------------------------------------------
local spamFilter

function Spam.AddMessage(text)
    if (KyzderpsDerps.savedOptions.chatSpam.useLFCP and spamFilter) then
        spamFilter:AddMessage(text)
    else
        KyzderpsDerps:msg(text)
    end
end

---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function Spam.Initialize()
    if (LibFilteredChatPanel) then
        spamFilter = LibFilteredChatPanel:CreateFilter(Spam.name, "/esoui/art/journal/journal_tabicon_cadwell_down.dds", {0.7, 0.7, 0.7}, false)
    end

    Spam.InitializeCSAHook()
    Spam.InitializeLootHistory()
    Spam.InitializeScore()
    Spam.InitializeInteract()
end
