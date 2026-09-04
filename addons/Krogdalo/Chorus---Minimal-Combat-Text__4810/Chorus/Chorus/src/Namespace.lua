Chorus = Chorus or {}
Chorus.name = "Chorus"
Chorus.version = "0.2.4"
Chorus.svVersion = 1
for _, mod in ipairs({ "Strings", "Format", "Fonts", "Engine", "API", "Settings", "Events", "Widgets", "Text", "Menu" }) do
    Chorus[mod] = Chorus[mod] or {}
end
