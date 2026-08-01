-- little hack to get the current interactable name
local lastInteractableName
ZO_PreHook(FISHING_MANAGER, "StartInteraction", function()
	local _, name = GetGameCameraInteractableActionInfo()
	lastInteractableName = name
end)

-- name of the marked for death contract book
local contractBook = {
	["Marked for Death"] = true,
	["死亡标记"] = true,
}

-- first few characters of the quest dialog that aren't spree contracts
local dialog = {
	-- EN
	["ink there wa"] = true,
	["n has more e"] = true,
	["a burr in my"] = true,
	["renn's court"] = true,
	["ssing throug"] = true,
	[" a criminal "] = true,
	[" abide loite"] = true,
	["ners at the "] = true,
	[" Jode, my ma"] = true,
	["adan has man"] = true,
	["t thumb your"] = true,
	["a thief who'"] = true,
	["e believes t"] = true,
	["Thalmor in G"] = true,
	["y I suffer t"] = true,
	["he refugees "] = true,
	["l keeps feed"] = true,
	["en is very w"] = true,
	[" customer — "] = true,
	[" sees the wa"] = true,
	[" is a quiet "] = true,
	["s. Such a dr"] = true,
	[" Judgment? P"] = true,
	["e spies in t"] = true,
	["een dishonor"] = true,
	["e Oasis Inn."] = true,
	["riness of th"] = true,
	["eak capacity"] = true,
	["n denied app"] = true,
	["itive that o"] = true,
	["des among th"] = true,
	["tolerate thi"] = true,
	["g muscled ou"] = true,
	[" hides among"] = true,
	["has fled far"] = true,
	["rell has an "] = true,
	["cement in th"] = true,
	[" best job I "] = true,
	["o serve powe"] = true,
	["s busybody i"] = true,
	["tor stalks m"] = true,
	["an employee "] = true,
	["ced to resid"] = true,
	["s of mistrus"] = true,
	["o give an of"] = true,
	[" making camp"] = true,
	["ishonors our"] = true,
	["less jest co"] = true,
	["us death is "] = true,
	["the spine of"] = true,
	[" can't take "] = true,
	["e may not be"] = true,
	["—former love"] = true,
	[" are the nec"] = true,
	[" a worshiper"] = true,
	["duty. Nobody"] = true,
	[" Dark Elves."] = true,
	["ng my mind. "] = true,
	["ughterfish b"] = true,
	["-drinkers at"] = true,
	["icious of a "] = true,
	-- ZH A Chinese character has three characters
	["酒馆的酿"] = true,
	["尔家族派"] = true,
	["受不了那"] = true,
	["疑在肖尔"] = true,
	["与乔德，"] = true,
	["配偶认为"] = true,
	["刺杀执行"] = true,
	["亲属玷污"] = true,
	["阿祖拉信"] = true,
	["地点在裂"] = true,
	["的暗精灵"] = true,
	["强迫臣服"] = true,
	["地战死是"] = true,
	["格林村庄"] = true,
	["无心的玩"] = true,
	["疯了。尼"] = true,
	["绿洲酒馆"] = true,
	["弗克赫尔"] = true,
	["是我的职"] = true,
	["因为一个"] = true,
	["一个顾客"] = true,
	["蠢货一直"] = true,
	["盛名的永"] = true,
	["瓦森非常"] = true,
	["间谍藏匿"] = true,
	["赖账的骗"] = true,
	["猎物逃到"] = true,
	["个店里的"] = true,
	["来我的手"] = true,
	["儿我正和"] = true,
	["儿喂食的"] = true,
	["大厅？呸"] = true,
	["恩女王的"] = true,
	["之城中心"] = true,
	["确定匕落"] = true,
	["生意正遭"] = true,
	["的梭默将"] = true,
	["丹王的忧"] = true,
	["来希斯米"] = true,
	["卫里藏着"] = true,
	["之树的织"] = true,
	["爱人，曾"] = true,
	["小偷一直"] = true,
	["在我的码"] = true,
	["拉杰德的"] = true,
	["的仇敌可"] = true,
	["正有个罪"] = true,
	["的受不了"] = true,
	["不了小偷"] = true,
	["为仪式寻"] = true,
	["者已在阿"] = true,
	["不能对荒"] = true,
	["精灵内部"] = true,
	["港湾的难"] = true,
	["加是个清"] = true,
	["次出海的"] = true,
	["一场战斗"] = true,
	["斗士公会"] = true,
	["看，你可"] = true,
	["权贵的人"] = true,
	["我都要面"] = true,
}

-- override the chatter option function, so only the Dark Brotherhood Spree Contracts can be started
local function OverwritePopulateChatterOption(interaction)
	local PopulateChatterOption = interaction.PopulateChatterOption
	interaction.PopulateChatterOption = function(self, index, fun, txt, type, ...)
		-- check if the current target is the contract book
		if not contractBook[lastInteractableName] then
			PopulateChatterOption(self, index, fun, txt, type, ...)
			return
		end
		-- the player has to be on the DB map
		if GetZoneId(GetUnitZoneIndex("player")) ~= 826 then
			return PopulateChatterOption(self, index, fun, txt, type, ...)
		end
		-- check if the current dialog starts the Dark Brotherhood Spree Contract
		local offerText = GetOfferedQuestInfo()
		-- if dialog[string.sub(offerText,10,15)] then
		if dialog[string.sub(offerText,10,21)] then
			-- if it is a different quest, only display the goodbye option
			if type ~= CHATTER_GOODBYE then
				return
			end
			PopulateChatterOption(self, 1, fun, txt, type, ...)
			return
		end
		PopulateChatterOption(self, index, fun, txt, type, ...)
	end
end

OverwritePopulateChatterOption(GAMEPAD_INTERACTION)
OverwritePopulateChatterOption(INTERACTION) -- keyboard