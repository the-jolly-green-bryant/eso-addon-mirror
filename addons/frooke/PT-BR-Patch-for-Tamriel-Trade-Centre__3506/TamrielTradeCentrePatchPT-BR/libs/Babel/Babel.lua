-- Title: Babel
-- Author: Dusty82
-- Description: Genera il database inglese per migliorare l'integrazione con gli addon

Babel = {
    name = "Babel",
    author = "Dusty82",
	version = "0.1",
	displayName = "Babel",
	menuName = "BabelMenu",
	savedVars = {
		language = "",
		APIVersion = 0,
		UpdateNeeded = false,
		UpdateCompleted = false,
		Data = {
			Items =  {},
			Sets = {},
		},
	},
}

local function CloseMsgBox()
	ZO_Dialogs_ReleaseDialog("BabelDialog", false)
end

local function ShowMsgBox(title, msg, btnText, callback)
	local confirmDialog = 
	{
		title = { text = title },
		mainText = { text = msg },
		buttons = 
		{
			{
				text = btnText, 
				callback = callback
			}
		}
   }

   ZO_Dialogs_RegisterCustomDialog("BabelDialog", confirmDialog)
   CloseMsgBox()
   ZO_Dialogs_ShowDialog("BabelDialog")
end

-- ShowMsgBox("Babel", "E' necessario aggiornare il database di Babel, premi ok per procedere", SI_DIALOG_CONFIRM)


function Babel.getItemName(itemLink)
	local itemID = select(4, ZO_LinkHandler_ParseLink(itemLink))
	local itemType = GetItemLinkItemType(itemLink)
	if Babel.savedVars.Data.Items[itemType] == nil then return nil end
	item=Babel.savedVars.Data.Items[itemType][tonumber(itemID)]
	return item
end

function Babel.Menu()
    local LAM = LibAddonMenu2
	local panelName = "BabelMenu"
    local panelData = {
        type = "panel",
        name = Babel.displayName,
        displayName = Babel.displayName,
        author = Babel.author,
		version = Babel.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LAM:RegisterAddonPanel(panelName, panelData)
	
    local optionsTable = {}

	table.insert(optionsTable, {
		type = "header",
		name = "Atualizar",
	})
 
 	table.insert(optionsTable, {
		type = "description",
		text = "Atualize o banco de dados em caso de problemas ou atualização da versão do jogo.",
		width = "half",
	})

	table.insert(optionsTable, {
		type = "button",
		name = "Atualizar",
		tooltip = "Atualize o banco de dados em caso de problemas ou atualização da versão do jogo.",
        func = function()
			Babel.savedVars.UpdateNeeded = true
			Babel.savedVars.UpdateCompleted = false
			Babel.savedVars.language = zo_strformat("<<z:1>>", GetCVar("language.2"))
			SetCVar("language.2", "en")
		end,
		warning = "Atenção: \nEsta opção irá recarregar automaticamente a interface do usuário!",
		width = "half",
    })

    LAM:RegisterOptionControls(panelName, optionsTable)
end

function Babel.Update()
	Babel.savedVars.Data.Items =  {}
	Babel.savedVars.Data.Sets = {}

	for itemId = 1, 300000 do
		local itemLink = ZO_LinkHandler_CreateLink('', nil, ITEM_LINK_TYPE, itemId, 364, 50, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
		local itemName = GetItemLinkName(itemLink)
		
		if itemName and itemName ~= "" and not string.match(itemName, "_") then
			local itemType = GetItemLinkItemType(itemLink)
			local hasSet, setName, _, _, _, setId = GetItemLinkSetInfo(itemLink)

			if Babel.savedVars.Data.Items[itemType] == nil then
				Babel.savedVars.Data.Items[itemType] = {}
			end

			if hasSet then
				Babel.savedVars.Data.Sets[setId] = setName
			end
			
			Babel.savedVars.Data.Items[itemType][itemId] = ZO_CachedStrFormat("<<z:1>>", itemName)
		end
	end
	
end

local function OnActivated(eventCode)
    EVENT_MANAGER:UnregisterForEvent(Babel.name, EVENT_PLAYER_ACTIVATED)

	if Babel.savedVars.UpdateNeeded then
		Babel.Update()
		Babel.savedVars.UpdateNeeded = false
		Babel.savedVars.UpdateCompleted = true
		Babel.savedVars.APIVersion = GetAPIVersion()
		ReloadUI("ingame")
	end
	
	if Babel.savedVars.UpdateCompleted then
		Babel.savedVars.UpdateCompleted = false
		SetCVar("language.2", Babel.savedVars.language)
	end

	if Babel.savedVars.APIVersion ~= GetAPIVersion() then
		d("Você precisa atualizar o banco de dados \"Babel\"!\NÃO abra as configurações, vá para o menu addon na seção Babel e pressione o botão \"Atualizar\".")
	end
end

EVENT_MANAGER:RegisterForEvent(Babel.name, EVENT_PLAYER_ACTIVATED, OnActivated)

local function OnLoaded(eventCode, addonName)
	if addonName == Babel.name then
		EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_ADD_ON_LOADED)
		
		Babel.savedVars = ZO_SavedVars:NewAccountWide("BabelSavedVariables", 1, nil, Babel.savedVars)

		if GetCVar("language.2") == "en" then
			return
		end
		
		Babel.Menu()
	end
end

EVENT_MANAGER:RegisterForEvent(Babel.name, EVENT_ADD_ON_LOADED, OnLoaded)
