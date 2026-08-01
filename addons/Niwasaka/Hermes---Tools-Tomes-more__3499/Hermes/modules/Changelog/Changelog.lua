local Hermes = _G['Hermes']
local zo_strformat = zo_strformat

function Hermes:ToggleChangelog(visible)
    local CHG_OFFSET_Y = -120

    Hermes_Changelog:ClearAnchors()
    Hermes_Changelog:SetAnchor(CENTER, GuiRoot, CENTER, 0, CHG_OFFSET_Y)

    Hermes_Changelog:SetHidden(not visible)
end

function Hermes:ChangelogScreen()
    if not self.db.showChangelog then
        return
    end

    local messages = self.GetDefaultLocaleString("changelog_message") or {}
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

    Hermes_Changelog_Title:SetText(zo_strformat(self.GetDefaultLocaleString("CHANGELOG_TITLE"), self.name))
    Hermes_Changelog_About:SetText(zo_strformat(self.GetDefaultLocaleString("CHANGELOG_FROM"), self.version, self.author))
    Hermes_Changelog_Text:SetText(changelog)

    local shouldShow = (self.db.welcomeVersion ~= self.version)
    self:ToggleChangelog(shouldShow)

    self.db.welcomeVersion = self.version
end