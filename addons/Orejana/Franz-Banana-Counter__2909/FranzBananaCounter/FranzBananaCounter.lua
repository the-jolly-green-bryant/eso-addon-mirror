FBC={}

FBC.name = "FranzBananaCounter"
local GS = GetString
local franzsucht = true
local banane = 33755
local bananencounter_gruppe = 0
local bananencounter_gruppe_heute = 0
local bananencounter_franz_heute = 0
local bananencounter_franz = 0
local eigeneraccount = GetDisplayName()
local bananencounter_heute = 0
local heutiges_datum = os.date("%x")
local zuletzt_gespeichertes_datum = "Datum"
local OnLootReceived = FBC.OnLootReceived
local gruppenliste = {}


function FBC:Initialize()
	FBC.savedVariables = ZO_SavedVars:NewAccountWide("FBCSavedVariables", 1, nil, {})
	bananencounter_gruppe = FBC.savedVariables.bananeTotal or 0
	bananencounter_franz = FBC.savedVariables.bananeFranz or 0
	bananencounter_gruppe_heute = FBC.savedVariables.bananeGruppeHeute or 0
	bananencounter_franz_heute = FBC.savedVariables.bananeFranzHeute or 0
	zuletzt_gespeichertes_datum = FBC.savedVariables.gespeichertes_datum or "Datum"
	gruppenliste = FBC.savedVariables.gruppenliste or {}
	EVENT_MANAGER:RegisterForEvent(FBC.name, EVENT_LOOT_RECEIVED, FBC.OnLootReceived)
end


function FBC.OnLootReceived(eventCode, receivedBy, itemName, quantity, itemSound, lootType, self, isPickpocketLoot, questItemIcon, itemId)
	if itemId == banane then
		local charname = zo_strformat("<<C:1>>", receivedBy)
		bananencounter_gruppe = bananencounter_gruppe + quantity
		FBC.savedVariables.bananeTotal = bananencounter_gruppe
		--d(charname.." hat "..quantity.." Banane(n) gelootet.")
		d(zo_strformat("<<C:1>> hat <<2[keine Bananen/eine Banane/$d Bananen]>> gelootet.", charname, quantity))
		if self then
			bananencounter_franz = bananencounter_franz + quantity
			FBC.savedVariables.bananeFranz = bananencounter_franz
		end
		if heutiges_datum == zuletzt_gespeichertes_datum then
			bananencounter_gruppe_heute = bananencounter_gruppe_heute + quantity
			FBC.savedVariables.bananeGruppeHeute = bananencounter_gruppe_heute
			if gruppenliste[charname] == nil then 
				gruppenliste[charname] = 0
			end
			gruppenliste[charname] = gruppenliste[charname] + quantity
			FBC.savedVariables.gruppenliste = gruppenliste
			if self then
				bananencounter_franz_heute = bananencounter_franz_heute + quantity
				FBC.savedVariables.bananeFranzHeute = bananencounter_franz_heute
			end
		else
			gruppenliste = {}
			gruppenliste[charname] = 0
			gruppenliste[charname] = gruppenliste[charname] + quantity
			bananencounter_franz_heute = 0
			if self then bananencounter_franz_heute = quantity end
			bananencounter_gruppe_heute = quantity
			FBC.savedVariables.bananeFranzHeute = bananencounter_franz_heute
			FBC.savedVariables.bananeGruppeHeute = bananencounter_gruppe_heute
			zuletzt_gespeichertes_datum = heutiges_datum
			FBC.savedVariables.gespeichertes_datum = heutiges_datum
		end
	end
end

function FBC.bananengruppeall()
	ZO_ChatWindowTextEntryEditBox:SetText("/party ")
	--StartChatInput(eigeneraccount.." und ihre/seine Gruppenmitglieder haben insgesamt schon "..bananencounter_gruppe.." Bananen gelootet.")
	StartChatInput(zo_strformat("<<C:1>> und ihre/seine Gruppenmitglieder haben insgesamt <<2[noch keine Bananen/erst eine Banane/schon $d Bananen]>> gelootet.", eigeneraccount, bananencounter_gruppe))
end

function FBC.bananenfranzall()
	ZO_ChatWindowTextEntryEditBox:SetText("/party ")
	--StartChatInput(eigeneraccount.." hat insgesamt schon "..bananencounter_franz.." Bananen gelootet.")
	StartChatInput(zo_strformat("<<C:1>> hat insgesamt <<2[noch keine Bananen/erst eine Banane/schon $d Bananen]>> gelootet.", eigeneraccount, bananencounter_franz))
end

function FBC.bananengruppeheute()
	if heutiges_datum == zuletzt_gespeichertes_datum then
		ZO_ChatWindowTextEntryEditBox:SetText("/party ")
		--StartChatInput(eigeneraccount.." und ihre/seine Gruppenmitglieder haben heute schon "..bananencounter_gruppe_heute.." Bananen gelootet.")
		StartChatInput(zo_strformat("<<C:1>> und ihre/seine Gruppenmitglieder haben heute <<2[noch keine Bananen/erst eine Banane/schon $d Bananen]>> gelootet.", eigeneraccount, bananencounter_gruppe_heute))
	else
		ZO_ChatWindowTextEntryEditBox:SetText("/party ")
		StartChatInput(eigeneraccount.." und ihre/seine Gruppenmitglieder haben heute noch keine Bananen gelootet.")
	end
	
end

function FBC.bananenfranzheute()
	if heutiges_datum == zuletzt_gespeichertes_datum then
		ZO_ChatWindowTextEntryEditBox:SetText("/party ")
		--StartChatInput(eigeneraccount.." hat heute schon "..bananencounter_franz_heute.." Bananen gelootet.")
		StartChatInput(zo_strformat("<<C:1>> hat heute <<2[noch keine Bananen/erst eine Banane/schon $d Bananen]>> gelootet.", eigeneraccount, bananencounter_franz_heute))
	else
		ZO_ChatWindowTextEntryEditBox:SetText("/party ")
		StartChatInput(eigeneraccount.." hat heute noch keine Bananen gelootet.")
	end
end

local function portionierterChat(textPortionen, derkanal)

	StartChatInput(textPortionen[1])

	local function OutputNextLine(eventCode, channelType, fromName, text, isCustomerService, fromDisplayName)
		if channelType == derkanal then
			if text == textPortionen[1] then
				table.remove(textPortionen, 1)
				if #textPortionen>0 then
					StartChatInput(textPortionen[1])
				else
					EVENT_MANAGER:UnregisterForEvent(FBC.name,EVENT_CHAT_MESSAGE_CHANNEL)
				end
			else
			end
		end
	end
	EVENT_MANAGER:RegisterForEvent(FBC.name,EVENT_CHAT_MESSAGE_CHANNEL, OutputNextLine)
end

function FBC.bananenrangliste()
	if heutiges_datum ~= zuletzt_gespeichertes_datum then
		ausgabe = "Die Gruppe hat heute noch keine Bananen gelootet."
		ZO_ChatWindowTextEntryEditBox:SetText("/party ")
		StartChatInput(ausgabe)
	else
		local sortierteListe = {}
		for i, v in pairs(gruppenliste) do
			if IsCharacterInGroup(i) then
				if #sortierteListe == 0 then
					table.insert(sortierteListe, i) 
				else
					local eingefuegt = false
					for j, w in ipairs(sortierteListe) do
						if gruppenliste[w] <= v then table.insert(sortierteListe, j, i) eingefuegt = true break end
					end
					if not eingefuegt then table.insert(sortierteListe, i) end
				end
			end
		end
		local ausgabe = "Bananen: "
		local ausgabe_zwischenspeichern = {""}
		for i, v in ipairs(sortierteListe) do
			ausgabe_zwischenspeichern[#ausgabe_zwischenspeichern] = ausgabe
			
			local ausgabe_h = ausgabe..v..": "..gruppenliste[v]
			if i < #sortierteListe then ausgabe_h = ausgabe_h..", " end
			
			if #ausgabe_h > 440 then
				ausgabe_zwischenspeichern[#ausgabe_zwischenspeichern+1] = ""
				ausgabe = ""
			else
				ausgabe = ausgabe_h
				ausgabe_zwischenspeichern[#ausgabe_zwischenspeichern] = ausgabe
			end
		end
		ZO_ChatWindowTextEntryEditBox:SetText("/party ")
		if ausgabe_zwischenspeichern ~= {""} then
			portionierterChat(ausgabe_zwischenspeichern, CHAT_CHANNEL_PARTY)		
		end
	end
end

function FBC.franztest42()
	if franzsucht then
		EVENT_MANAGER:UnregisterForEvent(FBC.name, EVENT_LOOT_RECEIVED)
		d("Franz zählt jetzt keine Bananen mehr.")
	else
		EVENT_MANAGER:RegisterForEvent(FBC.name, EVENT_LOOT_RECEIVED, FBC.OnLootReceived)
		d("Franz zählt jetzt wieder Bananen.")
	end
	franzsucht = not franzsucht
end

function FBC.OnAddOnLoaded(event, addonName)
  if addonName == FBC.name then
    FBC:Initialize()
  end
end


EVENT_MANAGER:RegisterForEvent(FBC.name, EVENT_ADD_ON_LOADED, FBC.OnAddOnLoaded)

SLASH_COMMANDS["/franz"] = FBC.franztest42
SLASH_COMMANDS["/bananengruppealle"] = FBC.bananengruppeall
SLASH_COMMANDS["/bananenfranzalle"] = FBC.bananenfranzall
SLASH_COMMANDS["/bananengruppe"] = FBC.bananengruppeheute
SLASH_COMMANDS["/bananenfranz"] = FBC.bananenfranzheute
SLASH_COMMANDS["/bananenrangliste"] = FBC.bananenrangliste