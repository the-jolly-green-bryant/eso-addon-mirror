local ArcanumGuildHall = _G['ArcanumGuildHall']
local zo_strformat = zo_strformat

function ArcanumGuildHall:ToggleChangelog(visible)
    local CHG_OFFSET_Y = -120

    ArcanumGuildHall_Changelog:ClearAnchors()
    ArcanumGuildHall_Changelog:SetAnchor(CENTER, GuiRoot, CENTER, 0, CHG_OFFSET_Y)

    ArcanumGuildHall_Changelog:SetHidden(not visible)
end

function ArcanumGuildHall:ChangelogScreen()
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

    ArcanumGuildHall_Changelog_Title:SetText(zo_strformat(self.GetDefaultLocaleString("CHANGELOG_TITLE"), self.name))
    ArcanumGuildHall_Changelog_About:SetText(zo_strformat(self.GetDefaultLocaleString("CHANGELOG_FROM"), self.version, self.author))
    ArcanumGuildHall_Changelog_Text:SetText(changelog)

    local shouldShow = (self.db.welcomeVersion ~= self.version)
    self:ToggleChangelog(shouldShow)

    self.db.welcomeVersion = self.version
end