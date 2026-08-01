local changelogs = {
    {
        version = 30000,
        callback = function() DynamicCP.OpenSettingsMenu() end,
        text = [[[Version 3.0.0]

- Added "slottable sets": At the top of your CP menu, you can now create sets of slottable stars. These sets can then be attached to CP presets, custom rules, or used in quickstars. If you change the stars in your slottable set, it's automatically updated in the places that you use them.

- Added "automatic presets": These are the green options at the top of presets, with icons showing what CP they will prioritize. They use as many points as you have available, until stars useful for your detected build are allocated. More info can be found in Dynamic CP > Preset Settings, where you can also delete the old hardcoded presets.

Go to settings?]]
    }
}

function DynamicCP.MaybeShowChangelog(forceLatest)
    local fullText = "Dynamic CP " .. DynamicCP.version .. " Changelog"
    local last

    if (forceLatest) then
        last = changelogs[#changelogs]
        fullText = fullText .. "\n\n" .. last.text
    else
        for _, changelog in ipairs(changelogs) do
            if (changelog.version > DynamicCP.savedOptions.lastChangelog) then
                fullText = fullText .. "\n\n" .. changelog.text
                last = changelog
            end
        end
    end

    -- Nothing to show
    if (last == nil) then
        return
    end

    DynamicCP.savedOptions.lastChangelog = last.version

    DynamicCP.ShowModelessPrompt(fullText, last.callback)
end
