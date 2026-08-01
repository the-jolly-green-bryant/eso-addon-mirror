-- UIFunctions.lua
local LibChatMessage = LibChatMessage
local chat = LibChatMessage("|cFF0020CerconeAddon|r", "|cFF0020CA|r")  

Estilos = {
  ["Custodes"] = "CerconeAddon/Assets/MissionBoard/PergaminoCustodes.dds",
  ["Clan"] = "CerconeAddon/Assets/MissionBoard/PergaminodelClan.dds",
  ["Frumentarii"] = "CerconeAddon/Assets/MissionBoard/PergaminoFrumentarii.dds",
  ["Indomito"] = "CerconeAddon/Assets/MissionBoard/PergaminoIndomito.dds",
  ["Inquisidores"] = "CerconeAddon/Assets/MissionBoard/PergaminoInquisidores.dds",
  ["Sanguinaris"] = "CerconeAddon/Assets/MissionBoard/PergaminoSanguinaris.dds",
}

CerconeAddon.currentPage = 0
CerconeAddon.Missions = {}

function CerconeAddon.ShowMissionBoard(page)
  CerconeAddon.currentPage = page or 1
  CerconeAddon.Missions = {}
  local boardData = CerconeTablonMisiones
  if not page then page = 1 end
  if not boardData or #boardData == 0 then
    chat:Print("No hay misiones.")
    return
  end

  local totalPages = 0

  for i, mission in pairs(boardData) do

    if mission.Texto ~= "" then
      totalPages = mission.Pagina > totalPages and mission.Pagina or totalPages
    end
    if mission.Pagina > page then break end

    local scroll = GetControl("Pergamino" .. mission.Slot)
    local title = GetControl("T" .. mission.Slot)
    local text = GetControl("Texto" .. mission.Slot)
    local requirements = GetControl("Req" .. mission.Slot)
    local button = GetControl("P" .. mission.Slot .. "Boton")

    scroll:SetHidden(true)
    button:SetHidden(true)
    title:SetText("")
    text:SetText("")
    requirements:SetText("")

    if mission.Pagina == page and mission.Texto ~= "" then
      scroll:SetTexture(Estilos[mission.Estilo])
      title:SetText(mission.Titulo)
      text:SetText(mission.Texto)
      requirements:SetText(mission.Requisitos)

      CerconeAddon.Missions[mission.Slot] = {
        Estilo = mission.Estilo,
        Titulo = mission.Titulo,
        Texto = mission.Texto,
        Requisitos = mission.Requisitos,
      }

      scroll:SetHidden(false)
      button:SetHidden(false)
    end
  end

  local nextButton = GetControl("FlechaDER")
  local prevButton = GetControl("FlechaIZQ")

  if totalPages > page then
    nextButton:SetHidden(false)
  elseif totalPages == page then
    nextButton:SetHidden(true)
  end

  if page > 1 then
    prevButton:SetHidden(false)
  else
    prevButton:SetHidden(true)
  end
end

function CerconeAddon.ChangePage(value)
  local page = CerconeAddon.currentPage + value
  CerconeAddon.ShowMissionBoard(page)
end

function CerconeAddon.SelectMission(slot)
  local panel = GetControl("Mision")
  local mGrande = GetControl("MGrande")

  local title = GetControl("MisionT")
  local text = GetControl("MisionTexto")
  local requirements = GetControl("MisionReq")

  title:SetText(CerconeAddon.Missions[slot].Titulo)
  text:SetText(CerconeAddon.Missions[slot].Texto)
  requirements:SetText(CerconeAddon.Missions[slot].Requisitos)
  mGrande:SetTexture(Estilos[CerconeAddon.Missions[slot].Estilo])

  panel:SetDrawTier(DT_HIGH)
  PlaySound(SOUNDS.BOOK_PAGE_TURN)
  panel:SetHidden(false)
end

function CerconeAddon.CloseMissionPanel()
  local panel = GetControl("Mision")
  panel:SetHidden(true)
  panel:SetDrawTier(DT_LOW)
  
  local title = GetControl("MisionT")
  local text = GetControl("MisionTexto")
  local requirements = GetControl("MisionReq")

  title:SetText("")
  text:SetText("")
  requirements:SetText("")
  PlaySound(SOUNDS.BOOK_PAGE_TURN)
end