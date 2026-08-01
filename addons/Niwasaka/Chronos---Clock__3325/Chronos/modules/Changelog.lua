local Chronos = _G['Chronos']
local zo_strformat = zo_strformat

function Chronos.ToggleChangelog(visible)
    local CHG_OFFSET_Y = -120

    Chronos_Changelog:ClearAnchors()
    Chronos_Changelog:SetAnchor(CENTER, GuiRoot, CENTER, 0, CHG_OFFSET_Y)

    Chronos_Changelog:SetHidden(not visible)
end

function Chronos.ChangelogScreen()
    if not Chronos.db.showChangelog then return end

    local messages = Chronos.GetDefaultLocaleString("changelog_message") or {}
    local changelog = table.concat(messages, "\n")

    local replacements = {
        ["%[%*%]"] = "|t12:12:esoui/art/miscellaneous/bullet.dds|t",
        ["%[%+%]"] = "|t12:12:esoui/art/miscellaneous/spinnerplus_up.dds|t",
        ["%[%-%]"] = "|t12:12:esoui/art/miscellaneous/spinnerminus_up.dds|t",
        ["%[%=%]"] = "|t12:12:esoui/art/miscellaneous/check.dds|t",
    }

    for pattern, replacement in pairs(replacements) do
        changelog = string.gsub(changelog, pattern, replacement)
    end

    Chronos_Changelog_Title:SetText(zo_strformat(Chronos.GetDefaultLocaleString("changelog_title"), Chronos.name))
    Chronos_Changelog_About:SetText(zo_strformat(Chronos.GetDefaultLocaleString("changelog_from"), Chronos.version, Chronos.author))
    Chronos_Changelog_Text:SetText(changelog)

    local shouldShow = (Chronos.db.welcomeVersion ~= Chronos.version)
    Chronos.ToggleChangelog(shouldShow)

    Chronos.db.welcomeVersion = Chronos.version
end
