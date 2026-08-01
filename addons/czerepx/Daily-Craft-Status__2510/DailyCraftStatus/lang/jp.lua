-- Japanese localization

local _addon = _G["DailyCraftStatus"]

-- these strings need to match game strings 
-- thanks to: Calamath
_addon.langQuestInfo = 
{
	["deliver"] = "届ける",
	["craft"] = { "生産する", "作る" }, 
	["material"] = { "材料" },
	["questnames"] = {
		--quest name unique substring followed by status character (or any string actually) 
		{"鍛冶","鍛冶 "},   -- blacksmithing
		{"仕立","仕立 "},   -- clothier
		{"木工","木工 "},   -- woodworking
		{"宝飾","宝飾 "},   -- jewelry crafting
		{"錬金術","錬金 "}, -- alchemy
		{"付呪","付呪 "},   -- enchanting
		{"調理","調理 "}   -- provisioning
	}
}	


-- addon strings for translation
_addon.translation = 
{
	["Lock"] = "ロック",
	["Save"] = "保存",
	["Unlock"] = "ロック解除",
}