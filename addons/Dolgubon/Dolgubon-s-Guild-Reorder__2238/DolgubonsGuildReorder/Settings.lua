DolgubonsGuildReorder = DolgubonsGuildReorder or {}
DolgubonsGuildReorder.settings = {}

function DolgubonsGuildReorder.setupSettings()
	DolgubonsGuildReorder.settings.panel =  
	{
		type = "panel",
		name = "Dolgubon's Guild Re-order",
		registerForRefresh = true,
		displayName = "|c8080FF Dolgubon's Guild Re-order|r",
		author = "@Dolgubon",
		registerForRefresh = true,
		registerForDefaults = true,
	}

	
	local LAM = LibStub and LibStub:GetLibrary("LibAddonMenu-2.0") or LibAddonMenu2
	LAM:RegisterAddonPanel("DolgubonsGuildReorderPanel",DolgubonsGuildReorder.settings.panel)

	DolgubonsGuildReorder.settings.options = DolgubonsGuildReorder.settings.getOptionsTable()

	LAM:RegisterOptionControls("DolgubonsGuildReorderPanel", DolgubonsGuildReorder.settings.options)

end

local function swapGuildOrder(oldSpot, newSpot)
	local guildAtNewSpot = DolgubonsGuildReorder.keyOrder[newSpot]
	local oldGuild = DolgubonsGuildReorder.keyOrder[oldGuild]

	DolgubonsGuildReorder.savedVarsAccountWide.guildOrder[oldSpot] = guildAtNewSpot
	DolgubonsGuildReorder.savedVarsAccountWide.guildOrder[newSpot] =  oldGuild

	DolgubonsGuildReorder:reloadKeyOrder()
end


function DolgubonsGuildReorder.settings.getOptionsTable()
	local guildNames = {}
	local guildIds = {}
	for i = 1, 7 do
		local guildName = GetGuildName(GetGuildId(i))
		if guildName ~= "" then
			guildNames[#guildNames + 1] = guildName
		end
		guildIds[guildName] = i
	end
	local optionsTable  = {

	}

	for i = 1, #guildNames do
		table.insert(optionsTable ,
			{
				type = "dropdown",
				name = "Guild "..i..":",
				tooltip = "Select the guild chat that you want to select when you type /g"..i,
				choices = guildNames,
				getFunc = function() return GetGuildName(GetGuildId(DolgubonsGuildReorder.keyOrder[i])) end,
				setFunc = function(value) 

					local oldSpot = DolgubonsGuildReorder.savedVarsAccountWide.guildOrder[guildIds[value]]
					DolgubonsGuildReorder.savedVarsAccountWide.guildOrder[DolgubonsGuildReorder.keyOrder[i]] = oldSpot
					DolgubonsGuildReorder.savedVarsAccountWide.guildOrder[guildIds[value]] = i 
					-- local oldSpot = DolgubonsGuildReorder.savedVarsAccountWide.guildOrder[guildIds[value]]
					-- swapGuildOrder(oldSpot, i )
					DolgubonsGuildReorder:reloadKeyOrder()
					
				end,
				requiresReload = true,
			}
		)
	end
	return optionsTable 
end