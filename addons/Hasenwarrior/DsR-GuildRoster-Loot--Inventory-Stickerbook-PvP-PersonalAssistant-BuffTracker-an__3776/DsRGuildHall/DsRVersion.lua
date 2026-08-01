-- Create namespace
DsRVersion = {}
local DsRVersion = DsRVersion or {}

DsRVersion.version      = "2026.04.29"
DsRVersion.AddOnVersion = 20260429

local lang = GetCVar("language.2")
local DsRIcon = DsRglobals:HolidayIconLoad()

ZO_CreateStringId("DsRVersion_Title"  , zo_iconFormat(DsRIcon, 30, 30) .. " |c9fb6cdDsR GuildRoster|r " .. zo_iconFormat(DsRIcon, 30, 30))

if lang == "de" then
    ZO_CreateStringId("DsRVersion_Accept"  , "|cFFA500Verstanden|r")
    ZO_CreateStringId("DsRVersion_Version" , "Änderungen in Version: " .. "|c80dfff" .. DsRVersion.version .. "|r")

    ZO_CreateStringId("DsRVersion_NEW" , "|c80ff80" .. "Neu"          .. "|r")
    ZO_CreateStringId("DsRVersion_MOD" , "|cffff80" .. "Anpassungen"  .. "|r")
    ZO_CreateStringId("DsRVersion_FIX" , "|cff8080" .. "Behoben"      .. "|r")

    ZO_CreateStringId("DsRVersion_NEWtxt"  , "- Kumulative Sets (z.B. 'Fete des Todbringers') werden nun unterstützt im BuffTracker\n- Tabelle für 'Entfernung zum Lead' der einzelnen Gruppenmitglieder (Nur im PvP)")
    ZO_CreateStringId("DsRVersion_MODtxt"  , "- (Gildenintern) Aktualisierung der Raid-Informationen")
    ZO_CreateStringId("DsRVersion_FIXtxt"  , " ")
else
    ZO_CreateStringId("DsRVersion_Accept"  , "|cFFA500Understood|r")
    ZO_CreateStringId("DsRVersion_Version" , "Changes in version:\n" .. "|c80dfff" .. DsRVersion.version .. "|r")

    ZO_CreateStringId("DsRVersion_NEW" , "|c80ff80" .. "New"     .. "|r")
    ZO_CreateStringId("DsRVersion_MOD" , "|cffff80" .. "Modify" .. "|r")
    ZO_CreateStringId("DsRVersion_FIX" , "|cff8080" .. "Fixed"   .. "|r")

    ZO_CreateStringId("DsRVersion_NEWtxt"  , "- Stackable sets (for example 'Death Dealer's Fete') are now supported in BuffTracker\n- Table showing the 'distance to the lead' of each group member (PvP only)")
    ZO_CreateStringId("DsRVersion_MODtxt"  , "- (Guild internal) Update Raidinformation")
    ZO_CreateStringId("DsRVersion_FIXtxt"  , " ")
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Donation
function DsRVersion.DsRdonation(gold)
	SCENE_MANAGER:Show('mailSend')
	zo_callLater(function()
		ZO_MailSendToField:SetText("@Hasenwarrior")
		ZO_MailSendSubjectField:SetText(GetString(DsRGuild_donationMailSubject))
		ZO_MailSendBodyField:SetText(zo_strformat( GetString(DsRGuild_donationMailTxT), GetDisplayName():gsub("^@", "") ))
        QueueMoneyAttachment(gold)
		ZO_MailSendBodyField:TakeFocus()
	end, 250)
end
