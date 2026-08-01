local A = GuildOrder
local LAM = LibAddonMenu2

local function Donate()
	SCENE_MANAGER:Show('mailSend')
	zo_callLater(function() 
		ZO_MailSendToField:SetText("@andy.s")
		ZO_MailSendSubjectField:SetText("GuildOrder")
		ZO_MailSendBodyField:SetText("Thanks for it! <3")
		ZO_MailSendBodyField:TakeFocus()
	end, 250)
end

function A.BuildMenu(SV, defaults)

	local panel = {
		type = 'panel',
		name = "Guild Order",
		displayName = "Guild Order",
		author = '|cFFFF00@andy.s|r',
		version = string.format('|c00FF00%s|r', A.GetVersion()),
		donation = Donate,
		registerForRefresh = true,
	}

	local guilds = {}
	for i = 1, GetNumGuilds() do
		local id = GetGuildId(i)
		table.insert(guilds, {
			value = i,
			uniqueKey = id,
			text = function()
				-- Colorize based on current Settings->Social
				local color = {ZO_ChatSystem_GetCategoryColorFromChannel(A.GetGuildChannelByGuildId(id))}
				color[4] = 1 -- setting this to 1 makes ZO_ColorDef.FloatsToHex return 6-length hex				
				return string.format("|c%s%s|r", ZO_ColorDef.FloatsToHex(unpack(color)), GetGuildName(id))
			end,
		})
	end

	local rowHeight = 42
	local height = #guilds * rowHeight

	local options = {
		{
			type = "orderlistbox",
			-- Doesn't update on panel refresh :(
			name = function() return GetNumGuilds() == 0 and "You don't have any guilds." or A.requiresReload and "|cFF0000Guild data has changed. /reloadui is required!|r" or "Drag & Drop or Click and use buttons on the right" end,
			listEntries = guilds,
			disableDrag = false,
			disableButtons = false,
			showPosition = true,
			getFunc = function() return guilds end,
			setFunc = function(sortedGuilds)
				guilds = sortedGuilds
				A.SetOrder(sortedGuilds)
			end,
			width = "full",
			isExtraWide = true,
			rowFont = "ZoFontWinH1",
			rowHeight = rowHeight,
			minHeight = height,
			--maxHeight = height,
			disabled = function() return A.requiresReload or GetNumGuilds() == 0 end,
			default = guilds,
		},
		{
			type = "header",
			name = "|cFFFACDConflicts|r",
		},
	}

	-- Custom conflict messages
	local size = #options
	if A.IsConflictEnabled('pChat') or A.IsConflictEnabled('rChat') then
		table.insert(options, {
			type = "description",
			text = '|cFFFF00pChat/rChat:|r guilds in pChat settings and guild numbers in chat (if enabled in\n"Chat Channels" -> "Guild Tweaks") will be in their default order.\n|cFFFFFF/reloadui|r is recommended after changing guild order.',
		})
	end

	-- No conflicts found (doesn't mean there aren't any ;)
	if size == #options then
		table.insert(options, {
			type = "description",
			text = "If you have chat addons, then /reloadui is recommended.",
		})
	end

	-- Default order button
	if #guilds > 0 then
		table.insert(options, {
			type = "button",
			name = "Reset to default order",
			func = function() A.ResetOrder(true) end,
			width = "half",
			isDangerous = true,
			warning = "Requires Reload UI.",
		})
	end

	local name = A.GetName() .. 'Menu'
	A.lamPanel = LAM:RegisterAddonPanel(name, panel)
	LAM:RegisterOptionControls(name, options)

	CALLBACK_MANAGER:RegisterCallback("LAM-RefreshPanel", function(panel)
		if panel == A.lamPanel and A.requiresReload then
			LAM.util.ShowConfirmationDialog("Reload UI is required", "Guild data has changed. Reload UI now?", function()
				ReloadUI()
			end)
		end
	end)

	CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", function(panel)
		if panel == A.lamPanel then
			panel.isCreated = true
		end
	end)
end