--ROOT
CerconeAddon = {}
CerconeAddon.name = "CerconeAddon"
CerconeAddon.haveDuelUI=false
--Funcion para cerrar panel de pjInfo
function HideMarkTextures()
  local textureNames = {
      "MarkClass1", "MarkClass2", "MarkClass3", "MarkClass4", "MarkClass5", "MarkClass6", "MarkClass7", "MarkClass8", "MarkClass9",
      "MarkWar1", "MarkWar2", "MarkWar3", "MarkWar4", "MarkWar5", "MarkWar6",
      "MarkProf1", "MarkProf2", "MarkProf3",
      "MarkLCf1", "MarkLCf2", "MarkLCf3"
  }
  for _, textureName in ipairs(textureNames) do
      local texture = WINDOW_MANAGER:GetControlByName(textureName)
      if texture then
          texture:SetHidden(true)
      end
  end
end
---Metodo
function ClosePjUI()
  local panel = WINDOW_MANAGER:GetControlByName("CerconePjSimpleUI")
  if panel then
    HideMarkTextures()
    panel:SetHidden(true)
  else
      d("No se encontró el control 'CerconePjSimpleUI'")
  end
end
function MarkClassSkillsFromValue(classSkills)
  local numOfSkills = tonumber(classSkills)
  if(numOfSkills>0)then
    MarkClass1:SetHidden(false)
  end
  if(numOfSkills>1)then
    MarkClass2:SetHidden(false)
  end
  if(numOfSkills>2)then
    MarkClass3:SetHidden(false)
  end
  if(numOfSkills>3)then
    MarkClass4:SetHidden(false)
  end
  if(numOfSkills>4)then
    MarkClass5:SetHidden(false)
  end
  if(numOfSkills>5)then
    MarkClass6:SetHidden(false)
  end
  if(numOfSkills>6)then
    MarkClass7:SetHidden(false)
  end
  if(numOfSkills>7)then
    MarkClass8:SetHidden(false)
  end
  if(numOfSkills>8)then
    MarkClass9:SetHidden(false)
  end
end
function MarkWarSkillsFromValue(classSkills)
  local numOfSkills = tonumber(classSkills)
  if(numOfSkills>0)then
    MarkWar1:SetHidden(false)
  end
  if(numOfSkills>1)then
    MarkWar2:SetHidden(false)
  end
  if(numOfSkills>2)then
    MarkWar3:SetHidden(false)
  end
  if(numOfSkills>3)then
    MarkWar4:SetHidden(false)
  end
  if(numOfSkills>4)then
    MarkWar5:SetHidden(false)
  end
  if(numOfSkills>5)then
    MarkWar6:SetHidden(false)
  end
end
function MarkProfskillsFromValue(classSkills)
  local numOfSkills = tonumber(classSkills)
  if(numOfSkills>0)then
    MarkProf1:SetHidden(false)
  end
  if(numOfSkills>1)then
    MarkProf2:SetHidden(false)
  end
  if(numOfSkills>2)then
    MarkProf3:SetHidden(false)
  end
end
function MarkLCskillsFromValue(classSkills)
  local numOfSkills = tonumber(classSkills)
  if(numOfSkills>0)then
    MarkLCf1:SetHidden(false)
  end
  if(numOfSkills>1)then
    MarkLCf2:SetHidden(false)
  end
  if(numOfSkills>2)then
    MarkLCf3:SetHidden(false)
  end
end
---BUSQUEDA
function  SearchpjByName(namePj)
  local searchTerm = string.lower(namePj) -- Convertir a minúsculas para una búsqueda sin distinción de mayúsculas/minúsculas
  local matches = {} -- Almacenará los resultados coincidentes
  for index, pjInfo in ipairs(CerconePjData) do
      local pjName = string.lower(pjInfo.Personaje) -- Convertir a minúsculas para comparar
      -- Verificar si el nombre de personaje contiene el término de búsqueda
      if string.find(pjName, searchTerm, 1, true) then
          -- Añadir el resultado a la lista de coincidencias
          table.insert(matches, {ID = pjInfo.ID, Personaje = pjInfo.Personaje, Index = index})
      end
  end
  -- Verificar si se encontraron coincidencias
  if #matches > 0 then
      -- Imprimir los resultados
      return matches[1].Index;
  else
      d("No se encontraron coincidencias para el término de búsqueda: " .. namePj)
  end
  
end
-- Función para mostrar el panel de PJs
function ShowSimpleData(name)
  local numPj= SearchpjByName(name)
  local index = tonumber(numPj)
  HideMarkTextures()
  if index and index >= 1 and index <= #CerconePjData then
    local pj = CerconePjData[index]
    d("Abriendo menu simple de: "..pj.Personaje)
    local panel = WINDOW_MANAGER:GetControlByName("CerconePjSimpleUI")
    --Cambia el titulo de Panel por el nombre del personaje
    if panel then
      --Data general
      PjName:SetText(pj.Personaje)      
      PjRaza:SetText("Raza: "..pj.DataGeneral.Raza)
      PjRango:SetText("Rango: "..pj.DataGeneral.Rango)
      PjNacimiento:SetText("Nacimiento: "..pj.DataGeneral.Nacimiento)
      PjOrden:SetText("Orden: "..pj.DataGeneral.Orden)
      PjConvertido:SetText("Convertido: "..pj.DataGeneral.FechaConvercion)
      PjEspecializacion:SetText("Especializacion: "..pj.DataGeneral.Especializacion)
      PjSire:SetText("Sire: "..pj.DataGeneral.Sire)
      PjMeritos:SetText("Total Meritos: "..pj.Meritos.TotalMeritos)
      PjArmadura:SetText("Armadura: "..pj.DataGeneral.Armadura)
      PjMisiones:SetText("Misiones: "..pj.Meritos.Misiones)
      PjHP:SetText("HP: "..pj.HP)
      PjDef:SetText("Defensa: "..pj.Defensa)
      PjMagicka:SetText("Magicka: "..pj.Magicka)
      --habilidades no combatientes
      PjExploracion:SetText("Exploracion: +"..pj.HabilidadesNOCombatientes.Exploracion)
      PjInvestigacion:SetText("Investigacion: +"..pj.HabilidadesNOCombatientes.Investigacion)
      PjInutilizar:SetText("Inutilizar Mecanismo: +"..pj.HabilidadesNOCombatientes.InutilizarM)
      PjSigilo:SetText("Sigilo: +"..pj.HabilidadesNOCombatientes.Sigilo)
      PjPersuacion:SetText("Persuacion: +"..pj.HabilidadesNOCombatientes.Persuacion)
      PjIntimidacion:SetText("Intimidacion: +"..pj.HabilidadesNOCombatientes.Intimidacion)
      PjEngano:SetText("Engaño : +"..pj.HabilidadesNOCombatientes.Engano)
      PjVoluntad:SetText("Voluntad : +"..pj.HabilidadesNOCombatientes.Voluntad)
      PjPercepcion:SetText("Percepcion : +"..pj.HabilidadesNOCombatientes.Percepcion)
      PjFuerza:SetText("Fuerza : +"..pj.HabilidadesNOCombatientes.Fuerza)
      --Academia
      PjClaseAc:SetText(pj.DataGeneral.Clase..":")
      PjProfesion:SetText(pj.DataGeneral.Profesion..":")
      --Seteo Marcas
      MarkClassSkillsFromValue(pj.HabilidadesCombatientes.LeccionesClase)
      MarkWarSkillsFromValue(pj.HabilidadesCombatientes.ArteDeGuerra)
      MarkProfskillsFromValue(pj.ProfLevel)
      MarkLCskillsFromValue(pj.HabilidadesCombatientes.LinajeCercone)

      panel:SetHidden(false)
    else
        d("No se encontró el control 'CerconePjSimpleUI'")
    end
  else
    d("Sin resultados")
  end
end


--FUNCIONES DE BUSQUEDA PJ
function CerconeAddon.ClosePjUI()
  ClosePjUI()
end

function CerconeAddon.AddHp()
  local currentText = PjHPDuel:GetText()
  if currentText == "--" then
        d("Seleccione un personaje antes de usar este comando.")
        return
    end
  local currentHP = tonumber(string.match(currentText, "%d+"))
  if currentHP then
      local newHP = currentHP + 1
      PjHPDuel:SetText("HP: " .. newHP)
  else
      d("El valor actual no es válido.")
  end
end
function CerconeAddon.DiscHp()
  local currentText = PjHPDuel:GetText()
  if currentText == "--" then
        d("Seleccione un personaje antes de usar este comando.")
        return
    end
  local currentHP = tonumber(string.match(currentText, "%d+"))
  if currentHP then
      local newHP = currentHP - 1
      PjHPDuel:SetText("HP: " .. newHP)
  else
      d("El valor actual no es válido.")
  end
end

function CerconeAddon.AddDef()
  local currentText = PjDefDuel:GetText()
  if currentText == "--" then
        d("Seleccione un personaje antes de usar este comando.")
        return
    end
  local currentHP = tonumber(string.match(currentText, "%d+"))
  if currentHP then
      local newHP = currentHP + 1
      PjDefDuel:SetText("Def: " .. newHP)
  else
      d("El valor actual no es válido.")
  end
end
function CerconeAddon.DiscDefp()
  local currentText = PjDefDuel:GetText()
  if currentText == "--" then
        d("Seleccione un personaje antes de usar este comando.")
        return
    end
  local currentHP = tonumber(string.match(currentText, "%d+"))
  if currentHP then
      local newHP = currentHP - 1
      PjDefDuel:SetText("Def: " .. newHP)
  else
      d("El valor actual no es válido.")
  end
end

function CerconeAddon.AddMag()
  local currentText = PjMagickaDuel:GetText()
  if currentText == "--" then
        d("Seleccione un personaje antes de usar este comando.")
        return
    end
  local currentHP = tonumber(string.match(currentText, "%d+"))
  if currentHP then
      local newHP = currentHP + 1
      PjMagickaDuel:SetText("Mag: " .. newHP)
  else
      d("El valor actual no es válido.")
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
      d("El valor actual no es válido.")
  end
end



SLASH_COMMANDS["/pjinfo"] = function(name)
  ShowSimpleData(name)
end

SLASH_COMMANDS["/cerrarpj"] = function(extra)
  ClosePjUI()
end

SLASH_COMMANDS["/selectpj"] = function(namePj)
  local numPj=SearchpjByName(namePj)
  local index = tonumber(numPj)
  HideMarkTextures()
  if index and index >= 1 and index <= #CerconePjData then
    local pj = CerconePjData[index]
    local maxLength = 19
    local displayName = pj.Personaje    
    -- Verificar si la longitud del nombre es mayor a 12 caracteres
    if string.len(displayName) > maxLength then
        displayName = string.sub(displayName, 1, maxLength-3) .. "..."
    end
    d("Abriendo menu de combate para: "..pj.Personaje)
    PjHPDuel:SetText("HP: "..pj.HP)
    PjDefDuel:SetText("Def: "..pj.Defensa)
    PjMagickaDuel:SetText("Mag: "..pj.Magicka)
    PjNameDuel:SetText(displayName)
  else
    d("El número proporcionado no es válido. Debe estar entre 1 y " .. #CerconePjData)
  end
end

SLASH_COMMANDS["/sethp"] = function(hpValue)
  -- Convierte el valor de HP a un número
  local newHP = tonumber(hpValue)  
  -- Verifica si el valor es válido
  if newHP then
      -- Asigna el nuevo valor de HP al campo
      PjHPDuel:SetText("HP: "..newHP)
      d("Se ha asignado un nuevo valor de HP: " .. newHP)
  else
      d("El valor proporcionado no es válido.")
  end
end

SLASH_COMMANDS["/setdef"] = function(defValue)
  -- Convierte el valor de HP a un número
  local newHP = tonumber(defValue)  
  -- Verifica si el valor es válido
  if newHP then
      -- Asigna el nuevo valor de HP al campo
      PjDefDuel:SetText("Def: "..defValue)
      d("Se ha asignado un nuevo valor de Defensa: " .. newHP)
  else
      d("El valor proporcionado no es válido.")
  end
end

SLASH_COMMANDS["/setmagic"] = function(magickValue)
  -- Convierte el valor de HP a un número
  local newHP = tonumber(magickValue)  
  -- Verifica si el valor es válido
  if newHP then
      -- Asigna el nuevo valor de HP al campo
      PjMagickaDuel:SetText("Mag: "..magickValue)
      d("Se ha asignado un nuevo valor de Magica: " .. newHP)
  else
      d("El valor proporcionado no es válido.")
  end
end

--Metodos binding
CerconeAddon.NB1KeyBindToggle= function ()
  local panel = WINDOW_MANAGER:GetControlByName("CerconePjDuel")
    if panel then
        local isHidden = panel:IsHidden()
        CerconeAddon.haveDuelUI=isHidden;
        panel:SetHidden(not isHidden)
    else
        d("No se encontró el control 'CerconePjDuel'")
    end
end
--Metodo de arranque
function CerconeAddon.OnAddOnLoaded(eventCode, addOnName)
  if(addOnName ~= CerconeAddon.name) then return end  
  ClosePjUI()
  CerconeAddon.haveDuelUI=false
end

--Registro de Variables
ZO_CreateStringId("SI_BINDING_NAME_CERCONEADDON_NB1TOGGLE", "CerconePjs")  
 
--Registro del addon
EVENT_MANAGER:RegisterForEvent(CerconeAddon.name, EVENT_ADD_ON_LOADED, CerconeAddon.OnAddOnLoaded)

