-- Title: TTCBr
-- Author: Dusty82
-- Description: Genera il database inglese per migliorare l'integrazione con gli addon

TTCBr = {
    name = "TamrielTradeCentreBr",
    author = "Dusty82/Telmatoscopus",
	version = "0.2",
	displayName = "Tamriel Trade Centre BR",
	menuName = "TTCBrMenu",
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
	ZO_Dialogs_ReleaseDialog("TTCBrDialog", false)
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

   ZO_Dialogs_RegisterCustomDialog("TTCBrDialog", confirmDialog)
   CloseMsgBox()
   ZO_Dialogs_ShowDialog("TTCBrDialog")
end

-- ShowMsgBox("TTCBr", "E' necessario aggiornare il database di TTCBr, premi ok per procedere", SI_DIALOG_CONFIRM)


function TTCBr.getItemName(itemLink)
	local itemID = select(4, ZO_LinkHandler_ParseLink(itemLink))
	local itemType = GetItemLinkItemType(itemLink)
	if TTCBr.savedVars.Data.Items[itemType] == nil then return nil end
	item=TTCBr.savedVars.Data.Items[itemType][tonumber(itemID)]
	return item
end

function TTCBr.Menu()
    local LAM = LibAddonMenu2
	local panelName = "TTCBrMenu"
    local panelData = {
        type = "panel",
        name = TTCBr.displayName,
        displayName = TTCBr.displayName,
        author = TTCBr.author,
		version = TTCBr.version,
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
			TTCBr.savedVars.UpdateNeeded = true
			TTCBr.savedVars.UpdateCompleted = false
			TTCBr.savedVars.language = zo_strformat("<<z:1>>", GetCVar("language.2"))
			SetCVar("language.2", "en")
		end,
		warning = "Atenção: \nEsta opção irá recarregar automaticamente a interface do usuário!",
		width = "half",
    })

    LAM:RegisterOptionControls(panelName, optionsTable)
end

function TTCBr.Update()
	TTCBr.savedVars.Data.Items =  {}
	TTCBr.savedVars.Data.Sets = {}

	for itemId = 1, 300000 do
		local itemLink = ZO_LinkHandler_CreateLink('', nil, ITEM_LINK_TYPE, itemId, 364, 50, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
		local itemName = GetItemLinkName(itemLink)
		
		if itemName and itemName ~= "" and not string.match(itemName, "_") then
			local itemType = GetItemLinkItemType(itemLink)
			local hasSet, setName, _, _, _, setId = GetItemLinkSetInfo(itemLink)

			if TTCBr.savedVars.Data.Items[itemType] == nil then
				TTCBr.savedVars.Data.Items[itemType] = {}
			end

			if hasSet then
				TTCBr.savedVars.Data.Sets[setId] = setName
			end
			
			TTCBr.savedVars.Data.Items[itemType][itemId] = ZO_CachedStrFormat("<<z:1>>", itemName)
		end
	end
	
end

local function OnActivated(eventCode)
    EVENT_MANAGER:UnregisterForEvent(TTCBr.name, EVENT_PLAYER_ACTIVATED)

	if TTCBr.savedVars.UpdateNeeded then
		TTCBr.Update()
		TTCBr.savedVars.UpdateNeeded = false
		TTCBr.savedVars.UpdateCompleted = true
		TTCBr.savedVars.APIVersion = GetAPIVersion()
		ReloadUI("ingame")
	end
	
	if TTCBr.savedVars.UpdateCompleted then
		TTCBr.savedVars.UpdateCompleted = false
		SetCVar("language.2", TTCBr.savedVars.language)
	end

	if TTCBr.savedVars.APIVersion ~= GetAPIVersion() then
		d("Você precisa atualizar o banco de dados \"TTCBr\"!\NÃO abra as configurações, vá para o menu addon na seção TTCBr e pressione o botão \"Atualizar\".")
	end
end

EVENT_MANAGER:RegisterForEvent(TTCBr.name, EVENT_PLAYER_ACTIVATED, OnActivated)

local function OnLoaded(eventCode, addonName)
	if addonName == TTCBr.name then
		EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_ADD_ON_LOADED)
		
		TTCBr.savedVars = ZO_SavedVars:NewAccountWide("TTCBrSavedVariables", 1, nil, TTCBr.savedVars)

		if GetCVar("language.2") == "en" then
			return
		end
		
		TTCBr.Menu()
	end
end

EVENT_MANAGER:RegisterForEvent(TTCBr.name, EVENT_ADD_ON_LOADED, OnLoaded)
