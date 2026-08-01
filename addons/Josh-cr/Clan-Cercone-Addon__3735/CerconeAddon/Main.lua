-- Main.lua
CerconeAddon = {}
CerconeAddon.name = "CerconeAddon"
CerconeAddon.haveDuelUI = false
-- Cargar funciones de otros archivos
--dofile("UIFunctions.lua")
--dofile("SlashCommands.lua")

-- Se carga la biblioteca de mensajes de chat
local LibChatMessage = LibChatMessage

-- Crear una instancia de ChatProxy con etiquetas
local chat = LibChatMessage("|cFF0020CerconeAddon|r", "|cFF0020CA|r")  

-- Método de arranque
function CerconeAddon.OnAddOnLoaded(eventCode, addOnName)
  if(addOnName ~= CerconeAddon.name) then return end
  CerconeAddon.ClosePjUI()
  CerconeAddon.haveDuelUI = false
  CerconeAddon.InitializeKeybindings()
  CerconeAddon.ShowGrimorio()
  CerconeAddon.ShowMissionBoard()
end

function CerconeAddon.NB1KeyBindToggle()
    local panel = WINDOW_MANAGER:GetControlByName("CerconePjDuel")
    if panel then
        local isHidden = panel:IsHidden()
        panel:SetHidden(not isHidden)
        if isHidden then
            CerconeAddon.OnCombatMenuOpen()
        else
            CerconeAddon.OnCombatMenuClose()
        end
    else
        chat:Print("No se encontró el control 'CerconePjDuel'")
    end
end

function CerconeAddon.ArbriGrimorio()
    local panel = WINDOW_MANAGER:GetControlByName("GrimorioIndice")
    local panel2 = WINDOW_MANAGER:GetControlByName("Grimorio")
    if panel then
        panel:SetHidden(not panel:IsHidden())  
        if not panel2:IsHidden() then
            panel:SetHidden(true)
        end
        panel2:SetHidden(true)
        
        if not panel:IsHidden() then PlaySound("BOOK_OPEN") else PlaySound("BOOK_CLOSE") end
    else
        chat:Print("No se encontró el control 'GrimorioIndice'")
    end

    SetGameCameraUIMode(not panel:IsHidden())
end

function CerconeAddon.ArbriTablon()
    local panel = WINDOW_MANAGER:GetControlByName("Tablon")
    if panel then
        local isHidden = panel:IsHidden()
        panel:SetHidden(not isHidden)
        CerconeAddon.ShowMissionBoard()
    else
        chat:Print("No se encontró el control 'Tablon'")
    end

    SetGameCameraUIMode(not panel:IsHidden())
end

function CerconeAddon.InitializeKeybindings()
    ZO_CreateStringId("SI_BINDING_NAME_CERCONEADDON_NB1TOGGLE", "Cercone Combate")
    ZO_CreateStringId("SI_BINDING_NAME_CERCONEADDON_GRIMORIO", "Cercone Grimorio")
    ZO_CreateStringId("SI_BINDING_NAME_CERCONEADDON_TABLON", "Cercone Tablon")
    ZO_CreateStringId("SI_BINDING_NAME_CERCONEADDON_PJINFO", "Cercone Pergamino")
end
-- Registro del addon
EVENT_MANAGER:RegisterForEvent(CerconeAddon.name, EVENT_ADD_ON_LOADED, CerconeAddon.OnAddOnLoaded)