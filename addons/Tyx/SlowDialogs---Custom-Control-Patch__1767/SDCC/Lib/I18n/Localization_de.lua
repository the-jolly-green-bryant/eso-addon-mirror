--[[----------------------------------------------
    Project:    Slow Dialogs
    Author:     Arne Rantzen (Tyx)
    Created:    2017-07-20
    Updated:    2020-02-14
    License:    GPL-3.0
----------------------------------------------]]--

--- German translation for SlowDialogsGlobal
local translation = {
    displayName = "Langsame Dialoge",
    author = "Shinni",

    delayOption = "Verzögerung",
    delayTooltip = "Verzögerung zwischen zwei Zeichen in Millisekunden.",

    startDelayOption = "Anfängliche Verzögerung",
    startDelayTooltip = "Verzögerung bis der Text anfängt zu erscheinen.",

    fadeLengthOption = "Einblendlänge",
    fadeLengthTooltip = "Länger der Einblendanimation."
}

for key, str in pairs(translation) do
    SlowDialogsGlobal[key] = str
end
