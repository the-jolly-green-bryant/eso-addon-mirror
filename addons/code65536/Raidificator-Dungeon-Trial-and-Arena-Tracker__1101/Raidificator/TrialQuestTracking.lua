local LQS = LibQuestStatus
if (not LQS) then return end

local LEJ = LibExtendedJournal
local RCR = Raidificator

local QUEST_ITEMS = {
	[ 55011] = 5087, -- Celestial Warrior's Trophy
	[ 55012] = 5102, -- Celestial Mage's Gem
	[ 55013] = 5743, -- Celestial Serpent's Trophy
	[ 55775] = 5102, -- Celestial Mage's Gem
	[ 55776] = 5087, -- Celestial Warrior's Trophy
	[ 55825] = 5743, -- Celestial Serpent's Trophy
	[ 55931] = 5352, -- Ancient Lunar Talisman
	[ 55932] = 5352, -- Ancient Lunar Talisman
	[112431] = 5894, -- Incomprehensible Artifact
	[112432] = 5894, -- Incomprehensible Artifact
	[134562] = 6090, -- Halo Fragments
	[134563] = 6090, -- Halo Fragments
	[135134] = 6192, -- Z'Maja's Amulet Chain
	[135135] = 6192, -- Z'Maja's Shattered Amulet
	[146070] = 6353, -- Teeth of the False Alkosh
	[146071] = 6353, -- Tongue of the False Alkosh
	[156847] = 6503, -- Amulet of Bats
	[156848] = 6503, -- Bloodstone Chalice
	[171576] = 6654, -- Xalvakka's Head
	[171577] = 6654, -- Xalvakka's Heart
	[182369] = 6783, -- Fleet Queen's Talisman
	[182370] = 6783, -- Coral Heart
	[192614] = 7031, -- Vacant Dreamstone
	[192615] = 7031, -- Whispering Dreamstone
	[203889] = 7212, -- Ghost Light Bottle
	[203890] = 7212, -- Living Glass
	[212231] = 7306, -- Fighters Guild Seal Stamp
	[212232] = 7306, -- Crystal Teardrop
}

local function AddTooltipExtension( tooltip, itemLink )
	local questId = QUEST_ITEMS[GetItemLinkItemId(itemLink)]
	if (questId) then
		local data = LQS.GetServerAndCharacterList(true)[1]

		local results = { }
		local cooldown = 0

		for _, character in ipairs(data.characters) do
			if (character.account == GetDisplayName()) then
				local name = character.name
				if (LQS.IsRepeatableQuestOnCooldownForCharacter(questId, data.server, character.charId)) then
					name = string.format("|cFF0000%s|r", name)
					cooldown = cooldown + 1
				end
				table.insert(results, name)
			end
		end

		if (#results > 0) then
			local extension = LEJ.TooltipExtensionInitialize()
			extension:AddSection(
				string.format("%s (%d/%d)", GetString(SI_RCR_QUEST_COOLDOWN), cooldown, #results),
				table.concat(results, ", ")
			)
			extension:Finalize(tooltip)
		end
	end
end

function RCR.HookTrialItemTooltips( )
	local TooltipHook = function( control, functionName, linkFunction )
		ZO_PostHook(control, functionName, function( self, ... )
			AddTooltipExtension(control, linkFunction(...))
		end)
	end

	local ItemLinkPassthrough = function( itemLink )
		return itemLink
	end

	TooltipHook(PopupTooltip, "SetLink", ItemLinkPassthrough)
	TooltipHook(ItemTooltip, "SetLink", ItemLinkPassthrough)
	TooltipHook(ItemTooltip, "SetBagItem", GetItemLink)
	TooltipHook(ItemTooltip, "SetLootItem", GetLootItemLink)
end
