HedningQuotes = {}

HedningQuotes.name = "HedningQuotes"
HedningQuotes.version = 101
HedningQuotes.tempQuotes = {}
HedningQuotes.quotes = {
	"Thats ZoS quality",
	"Even a broken clock is right atleast twice a day",
	"Remember not to die",
	"Remember that you can tap target",
	"You can block this actually",
	"Don't stand in the AoE",
	"You can heavy attack to gain resources",
	"I have 18 characters, you know?",
	"Ehm btw tricki",
	"Ernie from sesame street, was my name",
	"Remember to Rez btw",
	"Just call if you need help",
	"Master crafter all traits",
	"Done almost all dungeons on hard mode, done all trials on veteran",
	"Can do every role and every class combo",
	"I got disconnected",
	"It's not over heating I touched it, it's not hot",
	"First try",
	"Actually I have 14 million gold",
	"Actually I have 20 million gold",
	"Actually I have 17 million gold",
	"Actually I have 7 million gold",
}

function HedningQuotes.ChangeText(text, i)
	if i == 1 then ZO_DeathRecapScrollContainerScrollChildHintsContainerHints1Text:SetText(text)
	elseif i == 2 then ZO_DeathRecapScrollContainerScrollChildHintsContainerHints2Text:SetText(text)
	else ZO_DeathRecapScrollContainerScrollChildHintsContainerHints3Text:SetText(text) end
end

function HedningQuotes:Initialize()
	math.randomseed(os.time())
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_DEAD, function()
			zo_callLater(function()
				local t = HedningQuotes.quotes
				for i = 1, #t - 1 do
					local temp = math.random(i, #t)
					t[i], t[temp] = t[temp], t[i]
				end
				for i = 1, 3 do
					pcall(HedningQuotes.ChangeText, t[i], i)
				end
			end,3000)
	end)
end

function HedningQuotes.OnAddOnLoaded(event, addonName)
  if addonName == HedningQuotes.name then
    HedningQuotes:Initialize()
  end
end

EVENT_MANAGER:RegisterForEvent(HedningQuotes.name, EVENT_ADD_ON_LOADED, HedningQuotes.OnAddOnLoaded)