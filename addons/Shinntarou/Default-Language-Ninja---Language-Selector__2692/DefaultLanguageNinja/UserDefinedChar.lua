local ADDON = DefaultLanguageNinja

--------
-- in this ADDON use, protected
--------

-- USER_DEFINED_CHAR
ADDON.USER_DEFINED_CHAR = {
	-- const
	["VALUES"] = {
		1,
		2,
		3,
		4,
		5,
		6,
		7,
		8,
		9,
		10,
		11,
		12,
		13,
		14,
		15,
		16,
		17,
		18,
		19,
		20,
		21,
		22,
		23,
		24,
		25,
		26
	},
	["CHOICES"] = {
		"a",
		"b",
		"c",
		"d",
		"e",
		"f",
		"g",
		"h",
		"i",
		"j",
		"k",
		"l",
		"m",
		"n",
		"o",
		"p",
		"q",
		"r",
		"s",
		"t",
		"u",
		"v",
		"w",
		"x",
		"y",
		"z"
	},
	-- getter
	["GetValue"] = function(choice)
		for key, var in ipairs(ADDON.USER_DEFINED_CHAR.CHOICES) do
			if (choice == var) then
				return ADDON.USER_DEFINED_CHAR.VALUES[key]
			end
		end
		return false
	end,
	["GetChoice"] = function(value)
		for key, var in ipairs(ADDON.USER_DEFINED_CHAR.VALUES) do
			if (value == var) then
				return ADDON.USER_DEFINED_CHAR.CHOICES[key]
			end
		end
		return false
	end
}
