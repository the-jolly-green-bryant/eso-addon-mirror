local strings = {
	DUR_HEADING1 = "Прочность доспехов",
	DUR_HEADING2 = "Заряд оружия",
	DUR_HEADING3 = "Прочее",
	DUR_SHOW_DURABILITY = "Показывать проценты",
	DUR_SHOW_DURABILITY_TT = "Показывать проценты в нижнем правом углу ячееек предметов",
	DUR_SHOW_ALWAYS = "Всегда показывать проценты",
	DUR_SHOW_ALWAYS_TT = "Показывать проценты прочности, независимо от того сколько осталось процентов",
	DUR_SHOW_CHARGE_ALWAYS_TT = "Показывать проценты заряда оружия, независимо от того сколько осталось процентов",
	DUR_SHOW_HIGHLIGHT = "Показывать подсветку",
	DUR_SHOW_HIGHLIGHT_TT = "Показывать цветную подсветку при достижении определенного процента",
	DUR_COLOUR = "Цвет подсветки",
	DUR_COLOUR_TT = "Цвет подсветки для предупреждения",
	DUR_THRESHOLD = "Процент для предупреждения (подсветка)",
	DUR_THRESHOLD_TT = "Процент при котором будет появляться предупреждение (подсветка)",
	DUR_REPAIR = "Ремонт при посещении торговца",
	DUR_REPAIR_PER = "Процент быстрого восстановления",
	DUR_REPAIR_PER_TT = "Предлагать ремонт только тогда, когда худшее снаряжение находится на этом уровне или ниже",
}

if GetString(DUR_HEADING1):len() == 0 then
	for key,value in pairs(strings) do
		SafeAddVersion(key, 1)
		ZO_CreateStringId(key, value)
	end
end