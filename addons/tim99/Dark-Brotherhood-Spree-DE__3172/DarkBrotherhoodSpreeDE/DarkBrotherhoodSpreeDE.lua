-- little hack to get the current interactable name
local lastInteractableName
ZO_PreHook(INTERACTIVE_WHEEL_MANAGER,"StartInteraction",function()local b,c=GetGameCameraInteractableActionInfo()lastInteractableName=c end)

local contractBook 	= {["Zum Tode auserkoren"]= true,}
local tipBoard 		= {["Brett für Aufträge"] = true,}

-- first few characters of the quest dialog that AREN'T spree contracts
local dialogDB = {
	["an würd"]=true,	["ie Köni"]=true,	["önigin "]=true,	["ch möch"]=true,	["ch befü"]=true,	["önig Ae"] =true,	[" Azura-A"]=true,
	["egend si"]=true,	["n meiner"]=true,	["uf meine"]=true,	["in Verbr"]=true,	["ch kann "]=true,	["ie Weber"]=true,	["ei Jone "]=true,
	["an dreht"]=true,	["s gibt d"]=true,	["ein Verl"]=true,	["chluss m"]=true,	["eden Tag"]=true,	["iner der"]=true,	["rgendein"]=true,
	["ulkwaste"]=true,	["ch habe "]=true,	["ieser si"]=true,	["'ren-ja "]=true,	["aulenzer"]=true,	["ie Halle"]=true,	["s gibt S"]=true,
	["ch wurde"]=true,	["as Gasth"]=true,	["ie gute "]=true,	["ch bin f"]=true,	["ir wurde"]=true,	["ch bin s"]=true,	["in Spion"]=true,
	["ch kann "]=true,	["ch werde"]=true,	["in Feigl"]=true,	["eine Beu"]=true,	["aus Dore"]=true,	["ein Aufs"]=true,	["ch habe "]=true,
	["er mäch"] =true,	["in eifer"]=true,	["in Aufwi"]=true,	["n der Ba"]=true,	["ch bin g"]=true,	["ie Saat "]=true,	["ie Feier"]=true,
	["ein Verw"]=true,	["in achtl"]=true,	["in glorr"]=true,	["ch zeige"]=true,	["ch halte"]=true,	["eine Leu"]=true,	["ein Lieb"]=true,
	["atrinend"]=true,	["erdammt "]=true,	["ch verli"]=true,	["rauche S"]=true,	["ie Milch"]=true,
}
-- first few characters of the covetous countess quest dialog and the prequest
local dialogTG = {
	["ochgesch"]=true,	
	["s gibt e"]=true,
	--["nscheine"]=true,
}
-- override the chatter option function, so only the desired quests can be started
local function OverwritePopulateChatterOption(interaction)
	local PopulateChatterOption = interaction.PopulateChatterOption
	interaction.PopulateChatterOption = function(self, index, fun, txt, type, ...)
		local ZoneId=GetZoneId(GetUnitZoneIndex("player"))
		if ZoneId==826 then --DB map
			-- check if the current target is the contract book
			if not contractBook[lastInteractableName] then
				PopulateChatterOption(self, index, fun, txt, type, ...)
				return
			end
			-- check if the current dialog starts the Dark Brotherhood Spree Contract
			local offerText = GetOfferedQuestInfo()
			if dialogDB[string.sub(offerText,5,12)] then
				-- if it is a different quest, only display the goodbye option
				if type ~= CHATTER_GOODBYE then return end
				PopulateChatterOption(self, 1, fun, txt, type, ...)
				return
			end
			PopulateChatterOption(self, index, fun, txt, type, ...)
		elseif ZoneId==821 then --TG map
			-- check if the current target is the tip board
			if not tipBoard[lastInteractableName] then
				PopulateChatterOption(self, index, fun, txt, type, ...)
				return
			end
			-- check if the current dialog starts the Covetous Countess quest
			local offerText = GetOfferedQuestInfo()
			if not dialogTG[string.sub(offerText,5,12)] then
				-- if it is a different quest, only display the goodbye option
				if type ~= CHATTER_GOODBYE then return end
				PopulateChatterOption(self, 1, fun, txt, type, ...)
				return
			end
			PopulateChatterOption(self, index, fun, txt, type, ...)
			lastInteractableName = nil -- set this variable to nil, so the next dialog step isn't manipulated
		else
			return PopulateChatterOption(self, index, fun, txt, type, ...)
		end
	end
end
OverwritePopulateChatterOption(GAMEPAD_INTERACTION)
OverwritePopulateChatterOption(INTERACTION) -- keyboard
