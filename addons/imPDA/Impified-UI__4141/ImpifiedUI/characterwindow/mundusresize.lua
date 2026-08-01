local feature = {}

local function changeFontSize(size)
    ZO_CharacterWindowStatsScrollScrollChildZO_MundusStonesStatsEntryHeader:SetFont(('$(BOLD_FONT)|$(KB_%d)|soft-shadow-thin'):format(size))
end

function feature.Setup(addon)
    if not addon.savedVariables.characterWindow.mundusResize.enabled then return end

    changeFontSize(addon.savedVariables.characterWindow.mundusResize.size)
end

function feature.GetSettingsControl(addon)
    return {
        {
            type = 'slider',
            name = 'Font size of a Mundus row in inventory',
            getFunc = function() return addon.savedVariables.characterWindow.mundusResize.size end,
            setFunc = function(value)
                addon.savedVariables.characterWindow.mundusResize.size = value
                changeFontSize(value)
            end,
            tooltip = 'Позволяет сделать строчку "Камень Мундуса" в окне персонажа меньше, чтобы избавиться от скроллбара',
            min = 4,
            max = 36,
        },
    }
end

assert(ImpifiedUI, 'ImpifiedUI not found')
ImpifiedUI:AddFeature(feature)
