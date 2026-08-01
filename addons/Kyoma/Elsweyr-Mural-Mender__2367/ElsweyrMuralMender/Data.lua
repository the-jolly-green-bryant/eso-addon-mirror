ElsweyrMuralMender = ElsweyrMuralMender or {}

--format: { globalX, globalY, criteriaIndex }, -- "tablet name"

local data = {}

data["elsweyr"] = {
	["elsweyr_base"] = {
		--{ 0.000, 0.000,  1 }, -- Anequina Fragment (quest item)
		{ 0.3842, 0.2161,  2 }, -- Riverhold Fragment
		{ 0.7026, 0.3784,  3 }, -- Rimmen Fragment
		{ 0.8002, 0.3434,  4 }, -- Khenarthia Fragment
		{ 0.4437, 0.2522,  5 }, -- Dune Fragment
		{ 0.2876, 0.3995,  6 }, -- Verkarth Fragment
		{ 0.3319, 0.3442,  7 }, -- Meirvale Fragment
		{ 0.2970, 0.7202,  8 }, -- Pellitine Fragment
		{ 0.6416, 0.3754,  9 }, -- Alabaster Fragment
		{ 0.4866, 0.3951, 10 }, -- Senchal Fragment
		{ 0.4835, 0.4846, 11 }, -- Orcrest Fragment
		{ 0.6050, 0.4864, 12 }, -- Corinthe Fragment
		{ 0.3374, 0.5671, 13 }, -- Helkarn Fragment
		{ 0.6304, 0.5919, 14 }, -- Bruk'ra Fragment
		{ 0.5900, 0.6916, 15 }, -- Tenmar Fragment
		{ 0.2002, 0.5997, 16 }, -- Torval Fragment
	},
	["abodeofignominy_base"] = {
		{ 0.6888, 0.2817, 2 }, -- Riverhold Fragment
	},
	["orcrest_base"] = {
		{ 0.3268, 0.4087, 11 }, -- Orcrest Fragment
	},
	["thetangle_base"] = {
		{ 0.4417, 0.5206, 14 }, -- Bruk'ra Fragment
	},
	["rimmennecropolis_base"] = {
		{ 0.0848, 0.7160 , 3 }, -- Rimmen Fragment
	},
	["predatorrise_base"] = {
		{ 0.5915, 0.3795, 6 }, -- Verkarth Fragment
	},
}

function ElsweyrMuralMender:GetLocalData(zone, subzone)
	if type(zone) == "string" and type(subzone) == "string" and data[zone] and data[zone][subzone] then
		return data[zone][subzone]
	end
end
