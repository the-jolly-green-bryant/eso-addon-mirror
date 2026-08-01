-- Asegúrate de que la biblioteca está cargada
local LibChatMessage = LibChatMessage

-- Crear una instancia de ChatProxy con etiquetas
local chat = LibChatMessage("|cFF0020CerconeAddon|r", "|cFF0020CA|r")  

function CerconeAddon.SelectPjForDuel(namePj)
    
    local panel = WINDOW_MANAGER:GetControlByName("CerconePjDuel")
    
    if not namePj and not panel:IsHidden() then return panel:SetHidden(true) end
    if not namePj then namePj = GetUnitName("player") end 
    
    local numPj = CerconeAddon.SearchpjByName(namePj)
    if not numPj then return end
    
    local index = tonumber(numPj)
    CerconeAddon.AcademyInfo()
    
    if index and index >= 1 and index <= #CerconePjData then
        local pj = CerconePjData[index]
        local maxLength = 19
        local displayName = pj.Personaje
        if string.len(displayName) > maxLength then
            displayName = string.sub(displayName, 1, maxLength - 3) .. "..."
        end
        
        local PjHPDuel = WINDOW_MANAGER:GetControlByName("PjHPDuel")
        local PjDefDuel = WINDOW_MANAGER:GetControlByName("PjDefDuel")
        local PjMagickaDuel = WINDOW_MANAGER:GetControlByName("PjMagickaDuel")
        local PjNameDuel = WINDOW_MANAGER:GetControlByName("PjNameDuel")
        
        if PjHPDuel and PjDefDuel and PjMagickaDuel and PjNameDuel then
            PjHPDuel:SetText("HP: " .. pj.HP)
            PjDefDuel:SetText("Def: " .. pj.Defensa)
            PjMagickaDuel:SetText("Mag: " .. pj.Magicka)
            PjNameDuel:SetText(displayName)

            if panel then
                CerconeAddon.haveDuelUI = true
                panel:SetHidden(false)
                CerconeAddon.OnCombatMenuOpen()
            else
                chat:Print("No se encontró el control 'CerconePjDuel'")
            end
        else
            chat:Print("No se encontraron todos los controles necesarios dentro de 'CerconePjDuel'")
        end

        -- Guardar el nombre del personaje seleccionado
        CerconeAddon.selectedPjName = displayName
    else
        chat:Print("Sin resultados")
    end
end

function CerconeAddon.AddHp()
  local currentText = PjHPDuel:GetText()
  if currentText == "--" then
        chat:Print("Seleccione un personaje antes de usar este comando.")
        return
    end
  local currentHP = tonumber(string.match(currentText, "%d+"))
  if currentHP then
      local newHP = currentHP + 1
      PjHPDuel:SetText("HP: " .. newHP)
  else
      chat:Print("El valor actual no es válido.")
  end
end
function CerconeAddon.DiscHp()
  local currentText = PjHPDuel:GetText()
  if currentText == "--" then
        chat:Print("Seleccione un personaje antes de usar este comando.")
        return
    end
  local currentHP = tonumber(string.match(currentText, "%d+"))
  if currentHP then
      local newHP = currentHP - 1
      PjHPDuel:SetText("HP: " .. newHP)
  else
      chat:Print("El valor actual no es válido.")
  end
end

function CerconeAddon.AddDef()
  local currentText = PjDefDuel:GetText()
  if currentText == "--" then
        chat:Print("Seleccione un personaje antes de usar este comando.")
        return
    end
  local currentHP = tonumber(string.match(currentText, "%d+"))
  if currentHP then
      local newHP = currentHP + 1
      PjDefDuel:SetText("Def: " .. newHP)
  else
      chat:Print("El valor actual no es válido.")
  end
end
function CerconeAddon.DiscDefp()
  local currentText = PjDefDuel:GetText()
  if currentText == "--" then
        chat:Print("Seleccione un personaje antes de usar este comando.")
        return
    end
  local currentHP = tonumber(string.match(currentText, "%d+"))
  if currentHP then
      local newHP = currentHP - 1
      PjDefDuel:SetText("Def: " .. newHP)
  else
      chat:Print("El valor actual no es válido.")
  end
end

function CerconeAddon.AddMag()
  local currentText = PjMagickaDuel:GetText()
  if currentText == "--" then
        chat:Print("Seleccione un personaje antes de usar este comando.")
        return
    end
  local currentHP = tonumber(string.match(currentText, "%d+"))
  if currentHP then
      local newHP = currentHP + 1
      PjMagickaDuel:SetText("Mag: " .. newHP)
  else
      chat:Print("El valor actual no es válido.")
  end
end

function CerconeAddon.DiscMag()
  local currentText = PjMagickaDuel:GetText()
  if currentText == "--" then
        return
    end
  local currentHP = tonumber(string.match(currentText, "%d+"))
  if currentHP then
      local newHP = currentHP - 1
      PjMagickaDuel:SetText("Mag: " .. newHP)
  else
      chat:Print("El valor actual no es válido.")
  end
end

function CerconeAddon.UpdateStat(statType, operation, amount)
    local controlName
    local labelPrefix

    -- Asignar el nombre del control y el prefijo del texto según el tipo de estadística
    if statType == "HP" then
        controlName = "PjHPDuel"
        labelPrefix = "HP: "
    elseif statType == "Def" then
        controlName = "PjDefDuel"
        labelPrefix = "Def: "
    elseif statType == "Mag" then
        controlName = "PjMagickaDuel"
        labelPrefix = "Mag: "
    else
        chat:Print("Tipo de estadística no válido.")
        return
    end

    local currentText = _G[controlName]:GetText()
    if currentText == "--" then
        chat:Print("Seleccione un personaje antes de usar este comando.")
        return
    end

    local currentValue = tonumber(string.match(currentText, "%d+"))
    if currentValue then
        local newValue
        if operation == "add" then
            newValue = currentValue + amount
        elseif operation == "subtract" then
            newValue = currentValue - amount
        else
            chat:Print("Operación no válida.")
            return
        end

        _G[controlName]:SetText(labelPrefix .. newValue)
    else
        chat:Print("El valor actual no es válido.")
    end
end

function CerconeAddon.OnCombatMenuOpen()
    EVENT_MANAGER:RegisterForEvent("CerconeAddonGroupChatListener", EVENT_CHAT_MESSAGE_CHANNEL, CerconeAddon.OnChatMessage)
end

function CerconeAddon.OnCombatMenuClose()
    EVENT_MANAGER:UnregisterForEvent("CerconeAddonGroupChatListener", EVENT_CHAT_MESSAGE_CHANNEL)
end

local function SendMessageToChat(message, chatType)
    local chatType = chatType or CHAT_CHANNEL_SAY
    -- Asegúrate de que chatType es válido
    if chatType == CHAT_CHANNEL_SAY or chatType == CHAT_CHANNEL_GROUP then
        -- Usa la función correcta según la documentación actual
        CHAT_SYSTEM:AddMessage("|cBDBDBD"..tostring(message).."|r",CHAT_CHANNEL_SAY)
    else
        chat:Print("Tipo de chat no válido")
    end
end


function CerconeAddon.OnChatMessage(eventCode, messageType, fromName, text)
    -- if messageType == CHAT_CHANNEL_EMOTE then
    --     if string.find(string.lower(text), "ataque") then
    --         CerconeAddon.UpdateStat("HP","add", 1)
    --         SendMessageToChat("Este es un mensaje de prueba.",CHAT_CHANNEL_SAY)
    --     end
    -- end
end