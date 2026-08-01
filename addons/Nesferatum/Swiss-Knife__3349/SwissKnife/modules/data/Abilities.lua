local SK = SwissKnife

SK.Data.abilities = {
	CAST_MODES = {
		NOT_ACTIVE = 1,
		PROC = 2,
		--STACK = 3,
		AVA_LOCATION = 4,
		PHASE = 5
	},
	EFFECT = {
		BUFF = 1,
		CURSE = 2,
		BLEEDING = 3,
		DAMAGE = 4
	},
	MODES_ICONS = {
		[1] = "/SwissKnife/textures/abilities/mode1.dds",
		[2] = "/SwissKnife/textures/abilities/mode2.dds",
		[3] = "/SwissKnife/textures/abilities/mode3.dds",
		[4] = "/SwissKnife/textures/abilities/mode4.dds",
		[5] = "/SwissKnife/textures/abilities/mode5.dds",
	},
	BUFFS = {
		AEGIS = { -- эгида
			MIN = 76618,
			MAJ = nil
		},
		BERSERK = { -- ярость
			MIN = 61744,
			MAJ = 61745
		},
		BRUTALITY = { -- жестокость
			MIN = 61662,
			MAJ = 61665
		},
		COURAGE = { -- храбрость
			MIN = 147417,
			MAJ = nil
		},
		EMPOWER = 61737, -- усиление
		ENDURANCE = { -- выносливость
			MIN = 61704,
			MAJ = 61705
		},
		EVASION = { -- уклонение
			MIN = 61715,
			MAJ = 61716
		},
		EXPEDITION = { -- ускорение
			MIN = 61735,
			MAJ = 61736
		},
		FORCE = { -- сила
			MIN = 61746,
			MAJ = 61747
		},
		FORTITUDE = { -- стойкость
			MIN = 61697,
			MAJ = 61698
		},
		GALLOP = { -- спешка
			MIN = nil,
			MAJ = nil
		},
		HEROISM = { -- героизм
			MIN = 61708,
			MAJ = 61709
		},
		INTELLECT = { -- интеллект
			MIN = 61706,
			MAJ = 61707
		},
		MENDING = { -- исцеление
			MIN = 61710,
			MAJ = 61711
		},
		PROPHECY = { -- предвидение
			MIN = 61691,
			MAJ = 61689
		},
		PROTECTION = { -- защита
			MIN = 61721,
			MAJ = 61722
		},
		RESOLVE = { -- решимость
			MIN = 61693,
			MAJ = 61694
		},
		SAVAGERY = { -- свирепость
			MIN = 61666,
			MAJ = 61667
		},
		SLAYER = { -- жажда убийств
			MIN = 76617,
			MAJ = nil
		},
		SORCERY = { -- колдовство
			MIN = 61685,
			MAJ = 61687,
		},
		TOUGHNESS = { -- твердость
			MIN = 88490,
			MAJ = nil
		},
		VITALITY = { -- живучесть
			MIN = nil,
			MAJ = 61713
		},
	},
	DEBUFFS = {
		BREACH = { -- прорыв
			MIN = 61742,
			MAJ = 61743
		},
		BRITTLE = { -- хрупкость
			MIN = 145975,
			MAJ = nil
		},
		COWARDICE = { -- трусость
			MIN = nil,
			MAJ = nil
		},
		DEFILE = { -- болезнь
			MIN = nil,
			MAJ = nil
		},
		ENERVATION = { -- бессилие
			MIN = nil,
			MAJ = nil
		},
		HINDRANCE = { -- замедление
			MIN = nil,
			MAJ = nil
		},
		LIFESTEAL = { -- похищение жизни
			MIN = 86304,
			MAJ = nil
		},
		MAGICKASTEAL = { -- похищение магии
			MIN = 88401,
			MAJ = nil
		},
		MAIM = { -- повреждение
			MIN = 61723,
			MAJ = nil
		},
		MANGLE = { -- увечье
			MIN = nil,
			MAJ = nil
		},
		UNCERTAINTY = { -- неуверенность
			MIN = nil,
			MAJ = nil
		},
		VULNERABILITY = { -- уязвимость
			MIN = 79717,
			MAJ = nil
		},
	},
	DEFAULT_TRACKED_ABILITIES = {}
}

SK.Data.abilities.ABILITY_NAMES = {
	[SK.Data.abilities.BUFFS.AEGIS.MIN] = "Малая эгида",
	--[SK.Data.abilities.BUFFS.AEGIS.MAJ] = "Великая эгида",
	[SK.Data.abilities.BUFFS.BERSERK.MIN] = "Малая ярость",
	[SK.Data.abilities.BUFFS.BERSERK.MAJ] = "Великая ярость",
	[SK.Data.abilities.BUFFS.BRUTALITY.MIN] = "Малая жестокость",
	[SK.Data.abilities.BUFFS.BRUTALITY.MAJ] = "Великая жестокость",
	[SK.Data.abilities.BUFFS.COURAGE.MIN] = "Малая храбрость",
	--[SK.Data.abilities.BUFFS.COURAGE.MAJ] = "Великая храбрость",
	[SK.Data.abilities.BUFFS.EMPOWER] = "Усиление",
	[SK.Data.abilities.BUFFS.ENDURANCE.MIN] = "Малая выносливость",
	[SK.Data.abilities.BUFFS.ENDURANCE.MAJ] = "Великая выносливость",
	[SK.Data.abilities.BUFFS.EVASION.MIN] = "Малое уклонение",
	[SK.Data.abilities.BUFFS.EVASION.MAJ] = "Великое уклонение",
	[SK.Data.abilities.BUFFS.EXPEDITION.MIN] = "Малое ускорение",
	[SK.Data.abilities.BUFFS.EXPEDITION.MAJ] = "Великое ускорение",
	[SK.Data.abilities.BUFFS.FORCE.MIN] = "Малая сила",
	[SK.Data.abilities.BUFFS.FORCE.MAJ] = "Великая сила",
	[SK.Data.abilities.BUFFS.FORTITUDE.MIN] = "Малая стойкость",
	[SK.Data.abilities.BUFFS.FORTITUDE.MAJ] = "Великая стойкость",
	--[SK.Data.abilities.BUFFS.GALLOP.MIN] = "Малая спешка",
	--[SK.Data.abilities.BUFFS.GALLOP.MAJ] = "Великая спешка",
	[SK.Data.abilities.BUFFS.HEROISM.MIN] = "Малый героизм",
	[SK.Data.abilities.BUFFS.HEROISM.MAJ] = "Великий героизм",
	[SK.Data.abilities.BUFFS.INTELLECT.MIN] = "Малый интеллект",
	[SK.Data.abilities.BUFFS.INTELLECT.MAJ] = "Великий интеллект",
	[SK.Data.abilities.BUFFS.MENDING.MIN] = "Малое исцеление",
	[SK.Data.abilities.BUFFS.MENDING.MAJ] = "Великое исцеление",
	[SK.Data.abilities.BUFFS.PROPHECY.MIN] = "Малое предвидение",
	[SK.Data.abilities.BUFFS.PROPHECY.MAJ] = "Великое предвидение",
	[SK.Data.abilities.BUFFS.PROTECTION.MIN] = "Малая защита",
	[SK.Data.abilities.BUFFS.PROTECTION.MAJ] = "Великая защита",
	[SK.Data.abilities.BUFFS.RESOLVE.MIN] = "Малая решимость",
	[SK.Data.abilities.BUFFS.RESOLVE.MAJ] = "Великая решимость",
	[SK.Data.abilities.BUFFS.SAVAGERY.MIN] = "Малая свирепость",
	[SK.Data.abilities.BUFFS.SAVAGERY.MAJ] = "Великая свирепость",
	[SK.Data.abilities.BUFFS.SLAYER.MIN] = "Малая жажда убийств",
	--[SK.Data.abilities.BUFFS.SLAYER.MAJ] = "Великая жажда убийств",
	[SK.Data.abilities.BUFFS.SORCERY.MIN] = "Малое колдовство",
	[SK.Data.abilities.BUFFS.SORCERY.MAJ] = "Великое колдовство",
	[SK.Data.abilities.BUFFS.TOUGHNESS.MIN] = "Малая твердость",
	--[SK.Data.abilities.BUFFS.TOUGHNESS.MAJ] = "Великая твердость",
	--[SK.Data.abilities.BUFFS.VITALITY.MIN] = "Малая живучесть",
	--[SK.Data.abilities.BUFFS.VITALITY.MAJ] = "Великая живучесть",
	[SK.Data.abilities.DEBUFFS.BREACH.MIN] = "Малый прорыв",
	[SK.Data.abilities.DEBUFFS.BREACH.MAJ] = "Великий прорыв",
	[SK.Data.abilities.DEBUFFS.BRITTLE.MIN] = "Малая хрупкость",
	--[SK.Data.abilities.DEBUFFS.BRITTLE.MAJ] = "Великая хрупкость",
	--[SK.Data.abilities.DEBUFFS.COWARDICE.MIN] = "Малая трусость",
	--[SK.Data.abilities.DEBUFFS.COWARDICE.MAJ] = "Великая трусость",
	--[SK.Data.abilities.DEBUFFS.DEFILE.MIN] = "Малая болезнь",
	--[SK.Data.abilities.DEBUFFS.DEFILE.MAJ] = "Великая болезнь",
	--[SK.Data.abilities.DEBUFFS.ENERVATION.MIN] = "Малое бессилие",
	--[SK.Data.abilities.DEBUFFS.ENERVATION.MAJ] = "Великое бессилие",
	--[SK.Data.abilities.DEBUFFS.HINDRANCE.MIN] = "Малое замедление",
	--[SK.Data.abilities.DEBUFFS.HINDRANCE.MAJ] = "Великое замедление",
	[SK.Data.abilities.DEBUFFS.LIFESTEAL.MIN] = "Малое похищение жизни",
	--[SK.Data.abilities.DEBUFFS.LIFESTEAL.MAJ] = "Великое похищение жизни",
	[SK.Data.abilities.DEBUFFS.MAGICKASTEAL.MIN] = "Малое похищение магии",
	--[SK.Data.abilities.DEBUFFS.MAGICKASTEAL.MAJ] = "Великое похищение магии",
	[SK.Data.abilities.DEBUFFS.MAIM.MIN] = "Малое повреждение",
	--[SK.Data.abilities.DEBUFFS.MAIM.MAJ] = "Великое повреждение",
	--[SK.Data.abilities.DEBUFFS.MANGLE.MIN] = "Малое увечье",
	--[SK.Data.abilities.DEBUFFS.MANGLE.MAJ] = "Великое увечье",
	--[SK.Data.abilities.DEBUFFS.UNCERTAINTY.MIN] = "Малая неуверенность",
	--[SK.Data.abilities.DEBUFFS.UNCERTAINTY.MAJ] = "Великая неуверенность",
	[SK.Data.abilities.DEBUFFS.VULNERABILITY.MIN] = "Малая уязвимость",
	--[SK.Data.abilities.DEBUFFS.VULNERABILITY.MAJ] = "Великая уязвимость",
}

SK.Data.abilities.TYPES_ICONS = {
	[SK.Data.abilities.EFFECT.BUFF] = "/SwissKnife/textures/abilities/sparkles.dds",
	[SK.Data.abilities.EFFECT.CURSE] = "/SwissKnife/textures/abilities/cursed.dds",
	[SK.Data.abilities.EFFECT.BLEEDING] = "/SwissKnife/textures/abilities/bleeding.dds",
	[SK.Data.abilities.EFFECT.DAMAGE] = "/SwissKnife/textures/abilities/target.dds"
}

SK.Data.abilities.DEFAULT_TRACKED_ABILITIES = {
	-- двуручное оржие
	[28297] = { -- движущая сила
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = SK.Data.abilities.BUFFS.ENDURANCE.MIN,
		allBuffs = {
			SK.Data.abilities.BUFFS.BRUTALITY.MAJ,
			SK.Data.abilities.BUFFS.SORCERY.MAJ,
			SK.Data.abilities.BUFFS.ENDURANCE.MIN
		},
		disabled = SK.FALSE
	},
	[38794] = { -- непреодолимая сила
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = SK.Data.abilities.BUFFS.ENDURANCE.MIN,
		allBuffs = {
			SK.Data.abilities.BUFFS.BRUTALITY.MAJ,
			SK.Data.abilities.BUFFS.SORCERY.MAJ,
			SK.Data.abilities.BUFFS.ENDURANCE.MIN
		},
		disabled = SK.FALSE
	},
	[38802] = { -- ободрение
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = SK.Data.abilities.BUFFS.ENDURANCE.MIN,
		allBuffs = {
			SK.Data.abilities.BUFFS.BRUTALITY.MAJ,
			SK.Data.abilities.BUFFS.SORCERY.MAJ,
			SK.Data.abilities.BUFFS.ENDURANCE.MIN
		},
		disabled = SK.FALSE
	},
	[28302] = { -- круговой удар
		mode = SK.Data.abilities.CAST_MODES.PHASE,
		hp = 50,
		disabled = SK.FALSE
	},
	[38823] = { -- круговой разрез
		mode = SK.Data.abilities.CAST_MODES.PHASE,
		hp = 50,
		disabled = SK.FALSE
	},
	[38819] = { -- палач
		mode = SK.Data.abilities.CAST_MODES.PHASE,
		hp = 50,
		disabled = SK.FALSE
	},
	-- одноручное оружие и щит
	[28727] = { -- оборонительная стойка
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 28727,
		disabled = SK.FALSE
	},
	[38312] = { -- защитная стойка
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 38312,
		disabled = SK.FALSE
	},
	[38317] = { -- поглощение снаряда
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 38317,
		disabled = SK.FALSE
	},
	[28306] = { -- укол
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		allDebuffs = {
			38254, -- насмешка
			SK.Data.abilities.DEBUFFS.BREACH.MAJ,
		},
		castByPlayer = SK.TRUE,
		disabled = SK.FALSE
	},
	[38256] = { -- разгром
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		allDebuffs = {
			38254, -- насмешка
			SK.Data.abilities.DEBUFFS.BREACH.MAJ,
		},
		castByPlayer = SK.TRUE,
		disabled = SK.FALSE
	},
	[38250] = { -- пробивание брони
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		allDebuffs = {
			38254, -- насмешка
			SK.Data.abilities.DEBUFFS.BREACH.MAJ,
			SK.Data.abilities.DEBUFFS.BREACH.MIN,
		},
		castByPlayer = SK.TRUE,
		disabled = SK.FALSE
	},
	[28304] = { -- глубокий выпад
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		debuff = SK.Data.abilities.DEBUFFS.MAIM.MIN,
		disabled = SK.FALSE
	},
	[38268] = { -- глубокий порез
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		debuff = SK.Data.abilities.DEBUFFS.MAIM.MIN,
		disabled = SK.FALSE
	},
	[38264] = { -- героический выпад
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		debuff = SK.Data.abilities.DEBUFFS.MAIM.MIN,
		disabled = SK.FALSE
	},
	-- парное оружие
	[28613] = { -- кинжальная оборона
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 28613,
		allBuffs = {
			28613,
			SK.Data.abilities.BUFFS.EVASION.MAJ
		},
		disabled = SK.FALSE
	},
	[38901] = { -- ускоряющий покров
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = SK.Data.abilities.BUFFS.EXPEDITION.MAJ,
		ftBuff = 38901,
		allBuffs = {
			38901,
			SK.Data.abilities.BUFFS.EXPEDITION.MAJ,
			SK.Data.abilities.BUFFS.EVASION.MAJ
		},
		isFT = SK.FALSE,
		disabled = SK.FALSE
	},
	[38906] = { -- смертоносный покров
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 38906,
		allBuffs = {
			38906,
			SK.Data.abilities.BUFFS.EVASION.MAJ
		},
		disabled = SK.FALSE
	},
	-- лук
	[38660] = { -- впрыскивание яда
		mode = SK.Data.abilities.CAST_MODES.PHASE,
		hp = 50,
		disabled = SK.TRUE
	},
	-- посох разрушения
	[29173] = { -- слабость к стихиям
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		debuff = SK.Data.abilities.DEBUFFS.BREACH.MAJ,
		disabled = SK.FALSE
	},
	[39089] = { -- стихийная уязвимость
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		debuff = SK.Data.abilities.DEBUFFS.BREACH.MAJ,
		disabled = SK.FALSE
	},
	[39095] = { -- стихийное поглощение
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		allDebuffs = {
			SK.Data.abilities.DEBUFFS.BREACH.MAJ,
			SK.Data.abilities.DEBUFFS.MAGICKASTEAL.MIN,
		},
		disabled = SK.FALSE
	},
	-- посох восстановления
	[31531] = { -- вытягивание силы
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		debuff = SK.Data.abilities.DEBUFFS.LIFESTEAL.MIN,
		disabled = SK.FALSE
	},
	[40109] = { -- поглощение духа
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		allDebuffs = {
			SK.Data.abilities.DEBUFFS.LIFESTEAL.MIN,
			SK.Data.abilities.DEBUFFS.MAGICKASTEAL.MIN,
		},
		disabled = SK.FALSE
	},
	[40116] = { -- быстрое поглощение
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		debuff = SK.Data.abilities.DEBUFFS.LIFESTEAL.MIN,
		disabled = SK.FALSE
	},
	-- легкие доспехи
	[29338] = { -- оберег пустоты
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 29338,
		disabled = SK.FALSE
	},
	[39186] = { -- магический барьер
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 39186,
		disabled = SK.FALSE
	},
	[39182] = { -- укрощение магии
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 39182,
		disabled = SK.FALSE
	},
	-- средние доспехи
	[29556] = { -- уклонение
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = SK.Data.abilities.BUFFS.EVASION.MAJ,
		disabled = SK.FALSE
	},
	[39195] = { -- туманное смещение
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 39196,
		ftBuff = SK.Data.abilities.BUFFS.EVASION.MAJ,
		allBuffs = {
			39196,
			SK.Data.abilities.BUFFS.EVASION.MAJ
		},
		isFT = SK.FALSE,
		disabled = SK.FALSE
	},
	[39192] = { -- уход от ударов
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = SK.Data.abilities.BUFFS.EVASION.MAJ,
		disabled = SK.FALSE
	},
	-- тяжелые доспехи
	[29552] = { -- неудержимость
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 28301,
		ftBuff = SK.Data.abilities.BUFFS.RESOLVE.MAJ,
		allBuffs = {
			28301, -- невосприимчивость к эффектам контроля
			126581, -- неудержимость
			SK.Data.abilities.BUFFS.RESOLVE.MAJ
		},
		isFT = SK.FALSE,
		disabled = SK.FALSE
	},
	[39205] = { -- неудержимость
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 28301,
		ftBuff = SK.Data.abilities.BUFFS.RESOLVE.MAJ,
		allBuffs = {
			28301,
			126582,
			SK.Data.abilities.BUFFS.RESOLVE.MAJ
		},
		isFT = SK.FALSE,
		disabled = SK.FALSE
	},
	[39197] = { -- непоколебимость
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 28301,
		ftBuff = SK.Data.abilities.BUFFS.RESOLVE.MAJ,
		allBuffs = {
			28301,
			126583,
			SK.Data.abilities.BUFFS.RESOLVE.MAJ
		},
		isFT = SK.FALSE,
		disabled = SK.FALSE
	},
	-- магия душ
	[26768] = { -- захват душ
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		debuff = 126890,
		effect = SK.Data.abilities.EFFECT.BLEEDING,
		castByPlayer = SK.TRUE,
		disabled = SK.FALSE
	},
	[40328] = { -- расщепляющий захват душ
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		debuff = 126895,
		effect = SK.Data.abilities.EFFECT.BLEEDING,
		castByPlayer = SK.TRUE,
		disabled = SK.FALSE
	},
	[40317] = { -- поглощающий захват
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		debuff = 126897,
		castByPlayer = SK.TRUE,
		effect = SK.Data.abilities.EFFECT.BLEEDING,
		disabled = SK.FALSE
	},
	-- гильдия бойцов
	[35737] = { -- круг защиты
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = SK.Data.abilities.BUFFS.PROTECTION.MIN,
		allBuffs = {
			SK.Data.abilities.BUFFS.PROTECTION.MIN,
			SK.Data.abilities.BUFFS.ENDURANCE.MIN
		},
		disabled = SK.FALSE
	},
	[40181] = { -- обращение ко злу
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = SK.Data.abilities.BUFFS.PROTECTION.MIN,
		allBuffs = {
			SK.Data.abilities.BUFFS.PROTECTION.MIN,
			SK.Data.abilities.BUFFS.ENDURANCE.MIN
		},
		disabled = SK.TRUE
	},
	[40169] = { -- охранное кольцо
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = SK.Data.abilities.BUFFS.PROTECTION.MIN,
		allBuffs = {
			SK.Data.abilities.BUFFS.PROTECTION.MIN,
			SK.Data.abilities.BUFFS.ENDURANCE.MIN
		},
		disabled = SK.TRUE
	},
	[35762] = { -- опытный охотник
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 35762,
		disabled = SK.FALSE
	},
	[40194] = { -- свирепый охотник
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 40194,
		disabled = SK.FALSE
	},
	[40195] = { -- замаскированный охотник
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 40195,
		disabled = SK.FALSE
	},
	-- гильдия магов
	[30920] = { -- магический свет
		mode = SK.Data.abilities.CAST_MODES.AVA_LOCATION,
		buff = 30920,
		disabled = SK.FALSE
	},
	[40478] = { -- внутренний свет
		mode = SK.Data.abilities.CAST_MODES.AVA_LOCATION,
		buff = 40478,
		disabled = SK.FALSE
	},
	[40483] = { -- сверкающий магический свет
		mode = SK.Data.abilities.CAST_MODES.AVA_LOCATION,
		buff = 40483,
		disabled = SK.FALSE
	},
	[28567] = { -- энтропия
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		debuff = 126370,
		effect = SK.Data.abilities.EFFECT.BLEEDING,
		castByPlayer = SK.TRUE,
		disabled = SK.FALSE
	},
	[40457] = { -- разложение
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		debuff = 126374,
		effect = SK.Data.abilities.EFFECT.BLEEDING,
		castByPlayer = SK.TRUE,
		disabled = SK.FALSE
	},
	[40452] = { -- структурная энтропия
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		debuff = 126371,
		effect = SK.Data.abilities.EFFECT.BLEEDING,
		castByPlayer = SK.TRUE,
		disabled = SK.FALSE
	},
	-- неустрашимые
	[39369] = { -- костяной щит
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 39369,
		disabled = SK.FALSE
	},
	[42138] = { -- шипастый костяной щит
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 42138,
		disabled = SK.FALSE
	},
	[42176] = { -- костяной вихрь
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 42176,
		disabled = SK.FALSE
	},
	[39475] = { -- внутренний огонь
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		debuff = 38254, -- насмешка
		castByPlayer = SK.TRUE,
		disabled = SK.FALSE
	},
	[42056] = { -- внутренний гнев
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		debuff = 38254, -- насмешка
		castByPlayer = SK.TRUE,
		disabled = SK.FALSE
	},
	[42060] = { -- внутренний зверь
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		debuff = 38254, -- насмешка
		castByPlayer = SK.TRUE,
		disabled = SK.FALSE
	},
	-- орден псиджиков
	[103483] = { -- зачарованное оружие
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 103483,
		disabled = SK.FALSE
	},
	[103571] = { -- стихийное оружие
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 103571,
		disabled = SK.FALSE
	},
	[103623] = { -- сокрушительное оружие
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 103623,
		disabled = SK.FALSE
	},
	[103503] = { -- акселерация
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = SK.Data.abilities.BUFFS.EXPEDITION.MAJ,
		ftBuff = SK.Data.abilities.BUFFS.FORCE.MIN,
		allBuffs = {
			SK.Data.abilities.BUFFS.EXPEDITION.MAJ,
			SK.Data.abilities.BUFFS.FORCE.MIN
		},
		isFT = SK.FALSE,
		disabled = SK.FALSE
	},
	[103706] = { -- продленная акселерация
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = SK.Data.abilities.BUFFS.EXPEDITION.MAJ,
		ftBuff = SK.Data.abilities.BUFFS.FORCE.MIN,
		allBuffs = {
			SK.Data.abilities.BUFFS.EXPEDITION.MAJ,
            SK.Data.abilities.BUFFS.FORCE.MIN
		},
		isFT = SK.FALSE,
		disabled = SK.FALSE
	},
	[103710] = { -- гонка со временем
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = SK.Data.abilities.BUFFS.EXPEDITION.MAJ,
		ftBuff = SK.Data.abilities.BUFFS.FORCE.MIN,
		allBuffs = {
			SK.Data.abilities.BUFFS.EXPEDITION.MAJ,
            SK.Data.abilities.BUFFS.FORCE.MIN
		},
		isFT = SK.FALSE,
		disabled = SK.FALSE
	},
	-- поддержка
	[38573] = { -- барьер
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 38573,
		disabled = SK.FALSE
	},
	[40237] = { -- лечащий барьер
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 40238, -- лечение от барьера
		ftBuff = 40237,
		allBuffs = {
			40237,
            40238
		},
		isFT = SK.FALSE,
		disabled = SK.FALSE
	},
	[40239] = { -- восстанавливающий барьер
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 40239,
		disabled = SK.FALSE
	},
	-- штурм
	[61503] = { -- бодрый клич
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		time = 10,
		disabled = SK.FALSE
	},
	[61505] = { -- громкий клич
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		time = 10,
		disabled = SK.FALSE
	},
	[61507] = { -- быстрый клич
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		time = 5,
		disabled = SK.FALSE
	},
	[38566] = { -- быстрый маневр
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = SK.Data.abilities.BUFFS.EXPEDITION.MAJ,
		disabled = SK.FALSE
	},
	[40211] = { -- отступление
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = SK.Data.abilities.BUFFS.EXPEDITION.MAJ,
		disabled = SK.FALSE
	},
	[40215] = { -- атакующий маневр
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = SK.Data.abilities.BUFFS.EXPEDITION.MIN,
		allBuffs = {
			SK.Data.abilities.BUFFS.EXPEDITION.MAJ,
            SK.Data.abilities.BUFFS.EXPEDITION.MIN
		},
		disabled = SK.FALSE
	},
	[61500] = { -- близкий взрыв
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		time = 8,
		effect = SK.Data.abilities.EFFECT.DAMAGE,
		disabled = SK.FALSE
	},
	[38563] = { -- боевой рог
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 38564,
		disabled = SK.FALSE
	},
	[40223] = { -- яростный рог
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = SK.Data.abilities.BUFFS.FORCE.MAJ,
		ftBuff = 40424,
		allBuffs = {
            40424,
			SK.Data.abilities.BUFFS.FORCE.MAJ
		},
		isFT = SK.FALSE,
		disabled = SK.FALSE
	},
	[40220] = { -- крепкий рог
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 63571,
		ftBuff = 40221,
		allBuffs = {
            40221,
			63571,
		},
		isFT = SK.FALSE,
		disabled = SK.FALSE
	},
	-- сорк
	[46324] = { -- обломки кристала
		mode = SK.Data.abilities.CAST_MODES.PROC,
		buff = 46327,
		effect = SK.Data.abilities.EFFECT.DAMAGE,
		disabled = SK.FALSE
	},
	[46331] = { -- кристальное оружие
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 143806, -- кристальное плетение
		disabled = SK.FALSE
	},
	[24371] = { -- рунная темница
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		debuff = 24559,
		castByPlayer = SK.TRUE,
		disabled = SK.FALSE
	},
	[24578] = { -- рунная клетка
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		debuff = 24578,
		castByPlayer = SK.TRUE,
		disabled = SK.FALSE
	},
	[24574] = { -- защитная руна
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 24574,
		disabled = SK.FALSE
	},
	[28025] = { -- ограда
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		debuff = 28025,
		castByPlayer = SK.TRUE,
		disabled = SK.FALSE
	},
	[28308] = { -- крушащяя тюрьма
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		debuff = 28308,
		castByPlayer = SK.TRUE,
		disabled = SK.FALSE
	},
	[28311] = { -- обездвиживающая тюрьма
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		debuff = 28311,
		castByPlayer = SK.TRUE,
		disabled = SK.FALSE
	},
	[108840] = { -- нестабильный слуга
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 108843, -- призыв нестабильного слуги
		ability = 23304,
		effect = SK.Data.abilities.EFFECT.BLEEDING,
		disabled = SK.FALSE
	},
	[77182] = { -- взрывной слуга
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 88933, -- призыв взрывного слуги
		ability = 23316,
		effect = SK.Data.abilities.EFFECT.BLEEDING,
		disabled = SK.FALSE
	},
	[24326] = { -- даэдрическое проклятие
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		debuff = 24326,
		effect = SK.Data.abilities.EFFECT.DAMAGE,
		castByPlayer = SK.TRUE,
		disabled = SK.FALSE
	},
	[24328] = { -- добыча для даэдра
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		debuff = 24328,
		effect = SK.Data.abilities.EFFECT.DAMAGE,
		castByPlayer = SK.TRUE,
		disabled = SK.FALSE
	},
	[24330] = { -- преследующее проклятие
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		debuff = 24330,
		ftDebuff = 89491,
		effect = SK.Data.abilities.EFFECT.BLEEDING,
		castByPlayer = SK.TRUE,
		disabled = SK.FALSE
	},
	[77140] = { -- сумрак-мучитель
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 88937, -- ярость сумрака-мучителя
		hp = 50,
		ability = 24636,
		disabled = SK.FALSE
	},
	[28418] = { -- призванный оберег
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 28418,
		disabled = SK.FALSE
	},
	[29489] = { -- прочный оберег
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 29489,
		disabled = SK.FALSE
	},
	[29482] = { -- восстанавливающий оберег
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 29482,
		allBuffs = {
			29482,
			SK.Data.abilities.BUFFS.INTELLECT.MIN,
			SK.Data.abilities.BUFFS.ENDURANCE.MIN
		},
		disabled = SK.FALSE
	},
	[24158] = { -- призванная броня
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 24158,
		disabled = SK.FALSE
	},
	[24165] = { -- призванный арсенал
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 24165,
		disabled = SK.FALSE
	},
	[24163] = { -- призванная эгида
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 108855,
		disabled = SK.FALSE
	},
	[23670] = { -- прилив сил
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 23670,
		allBuffs = {
			23670,
			SK.Data.abilities.BUFFS.BRUTALITY.MAJ,
			SK.Data.abilities.BUFFS.SORCERY.MAJ
		},
		disabled = SK.FALSE
	},
	[23674] = { -- прилив энергии
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 23674,
		allBuffs = {
			23674,
			SK.Data.abilities.BUFFS.BRUTALITY.MAJ,
			SK.Data.abilities.BUFFS.SORCERY.MAJ
		},
		disabled = SK.FALSE
	},
	[23678] = { -- критический прилив сил
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 23678,
		allBuffs = {
			23678,
			SK.Data.abilities.BUFFS.BRUTALITY.MAJ,
			SK.Data.abilities.BUFFS.SORCERY.MAJ
		},
		disabled = SK.FALSE
	},
	[23210] = { -- облик молнии
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 23210,
		allBuffs = {
			23210,
			SK.Data.abilities.BUFFS.RESOLVE.MAJ
		},
		disabled = SK.FALSE
	},
	[23231] = { -- ураган
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 23231,
		allBuffs = {
			23231,
			SK.Data.abilities.BUFFS.RESOLVE.MAJ,
			SK.Data.abilities.BUFFS.EXPEDITION.MIN
		},
		disabled = SK.FALSE
	},
	[23213] = { -- неудержимая буря
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = SK.Data.abilities.BUFFS.EXPEDITION.MAJ,
		ftBuff = 23213,
		allBuffs = {
			23213,
			SK.Data.abilities.BUFFS.EXPEDITION.MAJ,
			SK.Data.abilities.BUFFS.RESOLVE.MAJ
		},
		isFT = SK.FALSE,
		disabled = SK.FALSE
	},
	[23234] = { -- молниеносный рывок
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 51392,
		allBuffs = {
			131383, -- шаровая молния
			51392
		},
		effect = SK.Data.abilities.EFFECT.CURSE,
		disabled = SK.FALSE
	},
	[23236] = { -- бегущая молния
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 51392,
		allBuffs = {
			131383, -- шаровая молния
			51392
		},
		effect = SK.Data.abilities.EFFECT.CURSE,
		disabled = SK.FALSE
	},
	[23277] = { -- шаровая молния
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 51392,
		allBuffs = {
			131383, -- шаровая молния
			51392
		},
		disabled = SK.FALSE
	},
	-- рыцарь дракон
	[28967] = { -- инферно
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 28967,
		allBuffs = {
			28967,
			SK.Data.abilities.BUFFS.PROPHECY.MAJ,
			SK.Data.abilities.BUFFS.SAVAGERY.MAJ
		},
		disabled = SK.FALSE
	},
	[32853] = { -- пламя обливиона
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 32853,
		allBuffs = {
			32853,
			SK.Data.abilities.BUFFS.PROPHECY.MAJ,
			SK.Data.abilities.BUFFS.SAVAGERY.MAJ
		},
		disabled = SK.FALSE
	},
	[32881] = { -- прижигание
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 32881,
		allBuffs = {
			32881,
			SK.Data.abilities.BUFFS.PROPHECY.MAJ,
			SK.Data.abilities.BUFFS.SAVAGERY.MAJ
		},
		disabled = SK.FALSE
	},
	[20319] = { -- шипастая броня
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 20319,
		allBuffs = {
			20319,
            SK.Data.abilities.BUFFS.RESOLVE.MAJ
		},
		disabled = SK.FALSE
	},
	[20328] = { -- укрепленная броня
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 31808,
		ftBuff = 20328,
		allBuffs = {
			31808,
            20328,
            SK.Data.abilities.BUFFS.RESOLVE.MAJ
		},
		isFT = SK.FALSE,
		disabled = SK.FALSE
	},
	[20323] = { -- взрывная броня
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 20323,
		allBuffs = {
			20323,
			SK.Data.abilities.BUFFS.RESOLVE.MAJ
		},
		disabled = SK.FALSE
	},
	[21007] = { -- оберегающая чешуя
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 21007,
		disabled = SK.FALSE
	},
	[21014] = { -- оберегающий панцирь
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 108798,
		ftBuff = 21014,
		allBuffs = {
			108798,
			21014
		},
		isFT = SK.FALSE,
		disabled = SK.FALSE
	},
	[21017] = { -- чешуя драконьего огня
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 21017,
		disabled = SK.FALSE
	},
	[29043] = { -- лавовое оружие
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = SK.Data.abilities.BUFFS.BRUTALITY.MAJ,
		allBuffs = {
			SK.Data.abilities.BUFFS.BRUTALITY.MAJ,
			SK.Data.abilities.BUFFS.SORCERY.MAJ
		},
		disabled = SK.FALSE
	},
	[31874] = { -- вулканическое оружие
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = SK.Data.abilities.BUFFS.BRUTALITY.MAJ,
		allBuffs = {
			SK.Data.abilities.BUFFS.BRUTALITY.MAJ,
			SK.Data.abilities.BUFFS.SORCERY.MAJ
		},
		disabled = SK.FALSE
	},
	[31888] = { -- лавый арсенал
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 76537,
		allBuffs = {
			76537, -- лавый арсенал
			SK.Data.abilities.BUFFS.BRUTALITY.MAJ,
			SK.Data.abilities.BUFFS.SORCERY.MAJ
		},
		disabled = SK.FALSE
	},
	[29071] = { -- обсидиановый щит
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = SK.Data.abilities.BUFFS.MENDING.MAJ,
		ftBuff = 29071,
		allBuffs = {
			29071,
			SK.Data.abilities.BUFFS.MENDING.MAJ
		},
		isFT = SK.FALSE,
		disabled = SK.FALSE
	},
	[29224] = { -- вулканический щит
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = SK.Data.abilities.BUFFS.MENDING.MAJ,
		ftBuff = 29224,
		allBuffs = {
			29224,
			SK.Data.abilities.BUFFS.MENDING.MAJ
		},
		isFT = SK.FALSE,
		disabled = SK.FALSE
	},
	[32673] = { -- расколотый щит
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = SK.Data.abilities.BUFFS.MENDING.MAJ,
		ftBuff = 32673,
		allBuffs = {
			32673,
			SK.Data.abilities.BUFFS.MENDING.MAJ
		},
		isFT = SK.FALSE,
		disabled = SK.FALSE
	},
	[29037] = { -- окаменение
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		debuff = 29037,
		castByPlayer = SK.TRUE,
		disabled = SK.FALSE
	},
	[32685] = { -- окамелость
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		debuff = 32685,
		castByPlayer = SK.TRUE,
		disabled = SK.FALSE
	},
	[32678] = { -- дробящие камни
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		debuff = 32678,
		castByPlayer = SK.TRUE,
		disabled = SK.FALSE
	},
	-- хранитель
	[86009] = { -- выжигание
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		time = 9, -- 3 + 6
		effect = SK.Data.abilities.EFFECT.DAMAGE,
		disabled = SK.FALSE
	},
	[86019] = { -- нападение из под земли
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		time = 6, -- 3 + 3
		effect = SK.Data.abilities.EFFECT.DAMAGE,
		disabled = SK.FALSE
	},
	[86015] = { -- глубокий разлом
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		time = 9, -- 3 + 6
		effect = SK.Data.abilities.EFFECT.DAMAGE,
		disabled = SK.FALSE
	},
	[86023] = { -- рой
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		allDebuffs = {
			101703,
			SK.Data.abilities.DEBUFFS.VULNERABILITY.MIN
		},
		effect = SK.Data.abilities.EFFECT.BLEEDING,
		castByPlayer = SK.TRUE,
		disabled = SK.FALSE
	},
	[86027] = { -- нападение мух
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		allDebuffs = {
			101904,
			SK.Data.abilities.DEBUFFS.VULNERABILITY.MIN
		},
		effect = SK.Data.abilities.EFFECT.BLEEDING,
		castByPlayer = SK.TRUE,
		disabled = SK.FALSE
	},
	[86031] = { -- растущий рой
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		allDebuffs = {
			101944,
			SK.Data.abilities.DEBUFFS.VULNERABILITY.MIN
		},
		effect = SK.Data.abilities.EFFECT.BLEEDING,
		castByPlayer = SK.TRUE,
		disabled = SK.FALSE
	},
	[86050] = { -- самка нетча
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 86050,
		allBuffs = {
			86050,
			SK.Data.abilities.BUFFS.BRUTALITY.MAJ,
			SK.Data.abilities.BUFFS.SORCERY.MAJ
		},
		disabled = SK.FALSE
	},
	[86054] = { -- голубая самка нетча
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 86054,
		allBuffs = {
			86054,
			SK.Data.abilities.BUFFS.BRUTALITY.MAJ,
			SK.Data.abilities.BUFFS.SORCERY.MAJ
		},
		disabled = SK.FALSE
	},
	[86058] = { -- самец нетча
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 86058,
		allBuffs = {
			86058,
			SK.Data.abilities.BUFFS.BRUTALITY.MAJ,
			SK.Data.abilities.BUFFS.SORCERY.MAJ
		},
		disabled = SK.FALSE
	},
	[86037] = { -- скорость сокола
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = SK.Data.abilities.BUFFS.EXPEDITION.MAJ,
		disabled = SK.FALSE
	},
	[86041] = { -- коварный хищник
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = SK.Data.abilities.BUFFS.EXPEDITION.MAJ,
		disabled = SK.FALSE
	},
	[86045] = { -- хищная птица
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = SK.Data.abilities.BUFFS.EXPEDITION.MAJ,
		disabled = SK.FALSE
	},
	[86122] = { -- морозный плащ
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = SK.Data.abilities.BUFFS.RESOLVE.MAJ,
		castByPlayer = SK.TRUE,
		disabled = SK.FALSE
	},
	[86126] = { -- широкий морозный плащ
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = SK.Data.abilities.BUFFS.RESOLVE.MAJ,
		castByPlayer = SK.TRUE,
		disabled = SK.FALSE
	},
	[86130] = { -- ледяная крепость
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = SK.Data.abilities.BUFFS.PROTECTION.MIN,
		castByPlayer = SK.TRUE,
		allBuffs = {
			SK.Data.abilities.BUFFS.RESOLVE.MAJ,
			SK.Data.abilities.BUFFS.PROTECTION.MIN
		},
		disabled = SK.FALSE
	},
	[86135] = { -- кристаллический щит
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 86135,
		disabled = SK.FALSE
	},
	[86139] = { -- кристаллическая плита
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 86139,
		disabled = SK.FALSE
	},
	[86143] = { -- мерцающий щит
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 86143,
		disabled = SK.FALSE
	},
	[85578] = { -- целебные семена
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		time = 6,
		disabled = SK.FALSE
	},
	[85845] = { -- вредоносная пыльца
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		time = 6,
		disabled = SK.FALSE
	},
	[85539] = { -- цветок лотоса
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 85539,
		disabled = SK.FALSE
	},
	[85854] = { -- зеленый лотос
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 85854,
		disabled = SK.FALSE
	},
	[85855] = { -- цветущий лотос
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 85855,
		disabled = SK.FALSE
	},
	-- храмовник
	[26158] = { -- пронзающее копье
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		debuff = 26158,
		castByPlayer = SK.TRUE,
		disabled = SK.FALSE
	},
	[26800] = { -- сияющее копье
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		debuff = 26800,
		castByPlayer = SK.TRUE,
		disabled = SK.FALSE
	},
	[26804] = { -- пригвождающее копье
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		debuff = 26800,
		castByPlayer = SK.TRUE,
		disabled = SK.FALSE
	},
	[22178] = { -- солнечный щит
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 22179,
		disabled = SK.FALSE
	},
	[22182] = { -- сияющий оберег
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 22183,
		disabled = SK.FALSE
	},
	[22180] = { -- пылающий щит
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 49091,
		disabled = SK.FALSE
	},
	[21761] = { -- кара света
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		debuff = 21761,
		castByPlayer = SK.TRUE,
		disabled = SK.FALSE
	},
	[21765] = { -- очищающий свет
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		debuff = 21765,
		castByPlayer = SK.TRUE,
		disabled = SK.FALSE
	},
	[21763] = { -- cила света
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		allDebuffs = {
			21763,
			SK.Data.abilities.DEBUFFS.BREACH.MIN
		},
		castByPlayer = SK.TRUE,
		disabled = SK.FALSE
	},
	[21776] = { -- затмение
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		debuff = 21776,
		disabled = SK.FALSE
	},
	[22006] = { -- живая тьма
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 22006,
		disabled = SK.FALSE
	},
	[22004] = { -- нестабильная сфера
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		debuff = 22004,
		disabled = SK.FALSE
	},
	[63029] = { -- блистательное разрушение
		mode = SK.Data.abilities.CAST_MODES.PHASE,
		hp = 50,
		disabled = SK.FALSE
	},
	[63044] = { -- блистательная слава
		mode = SK.Data.abilities.CAST_MODES.PHASE,
		hp = 50,
		disabled = SK.TRUE
	},
	[63046] = { -- блистательное подавление
		mode = SK.Data.abilities.CAST_MODES.PHASE,
		hp = 50,
		disabled = SK.FALSE
	},
	[26209] = { -- восстанавливающая аура
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		time = 20,
		disabled = SK.TRUE
	},
	-- клинок ночи
	[33375] = { -- размытие
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = SK.Data.abilities.BUFFS.EVASION.MAJ,
		disabled = SK.FALSE
	},
	[35414] = { -- мираж
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = SK.Data.abilities.BUFFS.EVASION.MAJ,
		allBuffs = {
			SK.Data.abilities.BUFFS.EVASION.MAJ,
			SK.Data.abilities.BUFFS.RESOLVE.MIN
		},
		disabled = SK.FALSE
	},
	[35419] = { -- призрачный побег
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 125314,
		ftBuff = SK.Data.abilities.BUFFS.EVASION.MAJ,
		allBuffs = {
			125314,
			SK.Data.abilities.BUFFS.EVASION.MAJ
		},
		isFT = SK.FALSE,
		disabled = SK.FALSE
	},
	[33357] = { -- метка
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		allDebuffs = {
			33357,
			SK.Data.abilities.DEBUFFS.BREACH.MAJ
		},
		disabled = SK.FALSE
	},
	[36968] = { -- проникающая метка
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		allDebuffs = {
			36968,
			SK.Data.abilities.DEBUFFS.BREACH.MAJ
		},
		disabled = SK.FALSE
	},
	[36967] = { -- смертельная метка
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		allDebuffs = {
			36967,
			SK.Data.abilities.DEBUFFS.BREACH.MAJ
		},
		disabled = SK.FALSE
	},
	[61902] = { -- мрачная сосредоточенность
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 61902,
		disabled = SK.FALSE
	},
	[61927] = { -- непреклонная сосредоточенность
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 61927,
		disabled = SK.FALSE
	},
	[61919] = { -- безжалостная решимость
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 61919,
		disabled = SK.FALSE
	},
	[25375] = { -- покров тени
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 25376,
		disabled = SK.FALSE
	},
	[25380] = { -- теневая маскировка
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 25381,
		allBuffs = {
			25381,
			62141
		},
		disabled = SK.FALSE
	},
	[25377] = { -- покров тьмы
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 25377,
		ftBuff = SK.Data.abilities.BUFFS.PROTECTION.MIN,
		allBuffs = {
			25377,
			SK.Data.abilities.BUFFS.PROTECTION.MIN
		},
		isFT = SK.FALSE,
		disabled = SK.FALSE
	},
	[33195] = { -- темная тропа
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = SK.Data.abilities.BUFFS.EXPEDITION.MAJ,
		disabled = SK.FALSE
	},
	[36049] = { -- искажающая тропа
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = SK.Data.abilities.BUFFS.EXPEDITION.MAJ,
		disabled = SK.TRUE
	},
	[36028] = { -- обновляющий путь
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = SK.Data.abilities.BUFFS.EXPEDITION.MAJ,
		allBuffs = {
			SK.Data.abilities.BUFFS.EXPEDITION.MAJ,
			SK.Data.abilities.BUFFS.INTELLECT.MIN,
			SK.Data.abilities.BUFFS.ENDURANCE.MIN
		},
		disabled = SK.TRUE
	},
	[33211] = { -- призыв тени
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		time = 20,
		effect = SK.Data.abilities.EFFECT.BLEEDING,
		disabled = SK.FALSE
	},
	[35434] = { -- непроглядная тень
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		time = 20,
		effect = SK.Data.abilities.EFFECT.BLEEDING,
		disabled = SK.FALSE
	},
	[33319] = { -- поглощающие удары
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 33319,
		disabled = SK.FALSE
	},
	[36908] = { -- вытягивающие удары
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 36908,
		disabled = SK.FALSE
	},
	[36935] = { -- поглощающие атаки
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 36935,
		disabled = SK.FALSE
	},
	[33386] = { -- кинжал убийцы
		mode = SK.Data.abilities.CAST_MODES.PHASE,
		hp = 25,
		disabled = SK.FALSE
	},
	[34843] = { -- клинок убийцы
		mode = SK.Data.abilities.CAST_MODES.PHASE,
		hp = 25,
		disabled = SK.FALSE
	},
	[34851] = { -- пронзание
		mode = SK.Data.abilities.CAST_MODES.PHASE,
		hp = 25,
		disabled = SK.FALSE
	},
	-- некромант
	[114860] = { -- взрывающийся скелет
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 114860,
		effect = SK.Data.abilities.EFFECT.DAMAGE,
		disabled = SK.FALSE
	},
	[117690] = { -- моровый взрывающийся скелет
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 117690,
		effect = SK.Data.abilities.EFFECT.DAMAGE,
		disabled = SK.FALSE
	},
	[117749] = { -- преследующий взрывающийся скелет
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 117749,
		effect = SK.Data.abilities.EFFECT.DAMAGE,
		disabled = SK.FALSE
	},
	[114317] = { -- скелет-маг
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 114317,
		effect = SK.Data.abilities.EFFECT.BLEEDING,
		disabled = SK.FALSE
	},
	[118680] = { -- скелет-лучник
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 118680,
		effect = SK.Data.abilities.EFFECT.BLEEDING,
		disabled = SK.FALSE
	},
	[118726] = { -- скелет-колдун
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 118726,
		effect = SK.Data.abilities.EFFECT.BLEEDING,
		disabled = SK.FALSE
	},
	[115206] = { -- костяная броня
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 115206,
		allBuffs = {
			115206,
			SK.Data.abilities.BUFFS.RESOLVE.MAJ -- великая решимость
		},
		disabled = SK.FALSE
	},
	[118237] = { -- манящая броня
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 118237,
		allBuffs = {
			118237,
			SK.Data.abilities.BUFFS.RESOLVE.MAJ -- великая решимость
		},
		disabled = SK.FALSE
	},
	[118244] = { -- броня призывателя
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 118244,
		allBuffs = {
			118244,
			SK.Data.abilities.BUFFS.RESOLVE.MAJ -- великая решимость
		},
		disabled = SK.FALSE
	},
	[115710] = { -- призрачный лекарь
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 115710,
		disabled = SK.FALSE
	},
	[118912] = { -- призрачный страж
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 118912,
		disabled = SK.FALSE
	},
	[118840] = { -- усиленный лекарь
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 118840,
		disabled = SK.FALSE
	},
	-- арканист
	[186452] = { -- вдохновление книгоносца
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 186452,
		disabled = SK.FALSE
	},
	[185842] = { -- вдохновенные познания
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 185842,
		disabled = SK.FALSE
	},
	[183047] = { -- укрепляющий трактат
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 183047,
		disabled = SK.FALSE
	},
	[185836] = { -- вредоносный круг
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		debuff = 185838,
		disabled = SK.FALSE
	},
	[185839] = { -- руна перемещения
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		allDebuffs = {
			185841, -- притягивание
			185840, -- периодический урон
		},
		isCascade = SK.TRUE,
		disabled = SK.FALSE
	},
	[182988] = { -- грозная руна
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		allDebuffs = {
			182989, -- периодический урон
			184258, -- взрыв
		},
		isCascade = SK.TRUE,
		disabled = SK.FALSE
	},
	[183165] = { -- рунный удар
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		allDebuffs = {
			38254, -- насмешка
			SK.Data.abilities.DEBUFFS.MAIM.MIN
		},
		disabled = SK.FALSE
	},
	[183430] = { -- рунное вспарывание
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		allDebuffs = {
			187742, -- рунное вспарывание
			38254, -- насмешка
			SK.Data.abilities.DEBUFFS.MAIM.MIN
		},
		disabled = SK.FALSE
	},
	[186531] = { -- рунные объятия
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		allDebuffs = {
			38254, -- насмешка
			SK.Data.abilities.DEBUFFS.MAIM.MIN,
			SK.Data.abilities.DEBUFFS.LIFESTEAL.MIN
		},
		disabled = SK.FALSE
	},
	[185894] = { -- щит рунной злобы
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 185894,
		disabled = SK.FALSE
	},
	[185901] = { -- оберег ясного ума
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 185901,
		disabled = SK.FALSE
	},
	[183241] = { -- непроницаемый рунный щит
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 183241,
		ftBuff = 184362,
		allBuffs = {
			183241,
			184362
		},
		isCascade = SK.TRUE,
		disabled = SK.FALSE
	},
	[183648] = { -- доспех судьбы
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 183648,
		allBuffs = {
			183648,
			SK.Data.abilities.BUFFS.RESOLVE.MAJ
		},
		disabled = SK.FALSE
	},
	[185908] = { -- доспех создателя знаков
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 185908,
		allBuffs = {
			185908,
			SK.Data.abilities.BUFFS.RESOLVE.MAJ
		},
		disabled = SK.FALSE
	},
	[186477] = { -- нерушимая судьба
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 186477,
		disabled = SK.FALSE
	},
	[185912] = { -- рунная защита
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 194637,
		allBuffs = {
			194637,
			SK.Data.abilities.BUFFS.RESOLVE.MIN,
			SK.Data.abilities.BUFFS.PROTECTION.MIN
		},
		disabled = SK.FALSE
	},
	[183401] = { -- защитная руна тихих вод
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 194646,
		allBuffs = {
			194646,
			SK.Data.abilities.BUFFS.RESOLVE.MIN,
			SK.Data.abilities.BUFFS.PROTECTION.MIN
		},
		disabled = SK.FALSE
	},
	[186489] = { -- защитная руна свободы
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = 186492,
		allBuffs = {
			186492,
			SK.Data.abilities.BUFFS.RESOLVE.MIN,
			SK.Data.abilities.BUFFS.PROTECTION.MIN
		},
		disabled = SK.FALSE
	},
	[185918] = { -- руна сверхъестественного ужаса
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		allDebuffs = {
			185918, -- ужас
			185919, -- оглушение
			-- SK.Data.abilities.DEBUFFS.VULNERABILITY.MIN,
		},
		isCascade = SK.TRUE,
		disabled = SK.FALSE
	},
	[185921] = { -- руна жуткого обожания
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		allDebuffs = {
			185921, -- очарование
			185922, -- притягивание
			-- SK.Data.abilities.DEBUFFS.VULNERABILITY.MIN,
		},
		isCascade = SK.TRUE,
		disabled = SK.FALSE
	},
	[183267] = { -- руна бесцветного омута
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		allDebuffs = {
			183267, -- ужас
			183270, -- оглушение
			-- SK.Data.abilities.DEBUFFS.VULNERABILITY.MIN,
			-- SK.Data.abilities.DEBUFFS.BRITTLE.MIN,
		},
		isCascade = SK.TRUE,
		disabled = SK.FALSE
	},
	[183555] = { -- владения мастера рун
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = SK.Data.abilities.BUFFS.COURAGE.MIN,
		allBuffs = {
			SK.Data.abilities.BUFFS.COURAGE.MIN,
			SK.Data.abilities.BUFFS.FORTITUDE.MIN,
			SK.Data.abilities.BUFFS.INTELLECT.MIN,
			SK.Data.abilities.BUFFS.ENDURANCE.MIN
		},
		disabled = SK.TRUE
	},
	[186229] = { -- усиливающий круг зенаса
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = SK.Data.abilities.BUFFS.COURAGE.MIN,
		allBuffs = {
			SK.Data.abilities.BUFFS.COURAGE.MIN,
			SK.Data.abilities.BUFFS.FORTITUDE.MIN,
			SK.Data.abilities.BUFFS.INTELLECT.MIN,
			SK.Data.abilities.BUFFS.ENDURANCE.MIN
		},
		disabled = SK.TRUE
	},
	[186234] = { -- исцеляющая область
		mode = SK.Data.abilities.CAST_MODES.NOT_ACTIVE,
		buff = SK.Data.abilities.BUFFS.COURAGE.MIN,
		allBuffs = {
			SK.Data.abilities.BUFFS.COURAGE.MIN,
			SK.Data.abilities.BUFFS.FORTITUDE.MIN,
			SK.Data.abilities.BUFFS.INTELLECT.MIN,
			SK.Data.abilities.BUFFS.ENDURANCE.MIN
		},
		disabled = SK.TRUE
	},
}