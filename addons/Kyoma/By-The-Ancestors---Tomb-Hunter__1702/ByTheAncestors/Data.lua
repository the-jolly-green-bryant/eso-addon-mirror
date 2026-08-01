--format: { globalX, globalY, criteriaIndex, itemId }, -- "tomb name"
local data = {
	{ 0.2457, 0.2516,  1, 114287 }, -- Seran Ancestral Tomb
	{ 0.1635, 0.3131,  2, 114288 }, -- Ginith Ancestral Tomb
	{ 0.2461, 0.3229,  3, 114289 }, -- Rethandus Ancestral Tomb
	{ 0.2917, 0.4413,  4, 114298 }, -- Salothran Ancestral Tomb
	{ 0.2923, 0.5019,  5, 114299 }, -- Telvayn Ancestral Tomb
	{ 0.3639, 0.5935,  6, 114300 }, -- Uveran Ancestral Tomb
	{ 0.3283, 0.6126,  7, 114301 }, -- Norvayn Ancestral Tomb
	{ 0.3629, 0.6655,  8, 114302 }, -- Tharys Ancestral Tomb
	{ 0.2973, 0.7397,  9, 114303 }, -- Heran Ancestral Tomb
	{ 0.3871, 0.7536, 10, 114304 }, -- Lleran Ancestral Tomb
	{ 0.3634, 0.8089, 11, 114305 }, -- Thelas Ancestral Tomb
	{ 0.4781, 0.6871, 12, 114306 }, -- Sarano Ancestral Tomb
	{ 0.4839, 0.8052, 13, 114307 }, -- Othrelas Ancestral Tomb
	{ 0.6057, 0.6380, 14, 114308 }, -- Aran Ancestral Tomb
	{ 0.6344, 0.7734, 15, 114309 }, -- Velas Ancestral Tomb
	{ 0.6500, 0.8094, 16, 114310 }, -- Releth Ancestral Tomb
	{ 0.6975, 0.7732, 17, 114311 }, -- Raviro Ancestral Tomb
	{ 0.7375, 0.8064, 18, 114312 }, -- Redas Ancestral Tomb
	{ 0.7737, 0.9257, 19, 114313 }, -- Arano Ancestral Tomb
	{ 0.8638, 0.7423, 20, 114314 }, -- Hlervu Ancestral Tomb
	{ 0.7090, 0.6283, 21, 114315 }, -- Maren Ancestral Tomb
	{ 0.8420, 0.6527, 22, 114316 }, -- Arenim Ancestral Tomb
	{ 0.6177, 0.5767, 23, 114317 }, -- Serano Ancestral Tomb
	{ 0.7268, 0.5814, 24, 114318 }, -- Andas Ancestral Tomb
	{ 0.8588, 0.6105, 25, 114319 }, -- Verelnim Ancestral Tomb
	{ 0.6749, 0.4530, 26, 114320 }, -- Ieneth Ancestral Tomb
	{ 0.8263, 0.4781, 27, 114321 }, -- Sadryon Ancestral Tomb
	{ 0.6477, 0.3547, 28, 114322 }, -- Venim Ancestral Tomb
	{ 0.6305, 0.2959, 29, 114323 }, -- Nerano Ancestral Tomb
	{ 0.6111, 0.2596, 30, 114324 }, -- Favel Ancestral Tomb
}

local links = {}
for i, pinData in pairs(data) do
	local itemId = pinData[4]
    links[itemId] = ("|H1:item:%d:1:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h"):format(itemId)
end

function ByTheAncestors_GetLocalData()
	return data, links
end



