TextColor = {
    Normal = "000000",
    Hover = "800000"
}

Assets = {{"Hoja de la Noche", "CerconeAddon/Assets/Grimoire/NB.dds"}, {"Arcanista", "CerconeAddon/Assets/Grimoire/Arcanista.dds"},
          {"Nigromante", "CerconeAddon/Assets/Grimoire/Necromancer.dds"}, {"Caballero Dragón", "CerconeAddon/Assets/Grimoire/DK.dds"},
          {"Brujo", "CerconeAddon/Assets/Grimoire/Sorcerer.dds"}, {"Templario Oscuro", "CerconeAddon/Assets/Grimoire/Templar.dds"},
          {"Guardián", "CerconeAddon/Assets/Grimoire/Warden.dds"},
          {"Ingeniería de Clockwork", "CerconeAddon/Assets/Grimoire/IngClockwork.dds"},
          {"Sastrería", "CerconeAddon/Assets/Grimoire/Sastreria.dds"}, {"Alquimia", "CerconeAddon/Assets/Grimoire/Alquimia.dds"},
          {"Herrería", "CerconeAddon/Assets/Grimoire/Herreria.dds"},
          {"Arte de la Guerra", "CerconeAddon/Assets/Grimoire/Arte_de_la_Guerra.dds"},
          {"Linaje Indómito", "CerconeAddon/Assets/Grimoire/Linaje_Indomito.dds"},
          {"Monturas Exóticas", "CerconeAddon/Assets/Grimoire/Monturas_Exoticas.dds"},
          {"Linaje Cercone", "CerconeAddon/Assets/Grimoire/Linaje_Cercone.dds"},
          {"Habilidades de la orden", "CerconeAddon/Assets/Grimoire/Habilidades_de_la_Orden.dds"}}

-- Función para formatear la descripción en varias líneas
function CerconeAddon.FormatDescriptionMultiline(description)
    if not description then
        return ""
    end

    local parts = {}

    local formattedLine = description:gsub("^%s*([^:]+):", "|c" .. TextColor.Hover .. "%1:|r")
    -- Dividir por líneas
    for line in description:gmatch("[^\n]+") do
        -- Procesar cada línea independientemente
        table.insert(parts, formattedLine)
    end

    -- Unir las líneas procesadas
    return formattedLine
end

function CerconeAddon.SelectLogoNTitle(title)
    local logoControl = GetControl("LogoRamas")
    for i = 1, #Assets do
        if title == Assets[i][1] then
            logoControl:SetTexture(Assets[i][2])
            break
        end
    end
    GetControl("GrimorioTitulo"):SetText(title)
end

function CerconeAddon.AssignText(item, i)
    -- Controles
    local subtitleControl = GetControl("GrimorioNombreRama" .. i)
    local descriptionControl = GetControl("GrimorioDescripcion" .. i)
    local valuesControl = GetControl("GrimorioValores" .. i)

    -- Formateamos el texto de la descripción con color
    local description = CerconeAddon.FormatDescriptionMultiline(item.Descripcion)

    -- Verificamos el tamaño de la descripción y valores para cambiar las dimensiones del control
    local descLength = string.len(description)
    local valLength = string.len(item.Valores or "")

    local descXmlWidth = descriptionControl:GetWidth()
    local valXmlWidth = valuesControl:GetWidth()

    descriptionControl:SetDimensions(descXmlWidth, descLength >= 240 and 150 or 110)
    valuesControl:SetDimensions(valXmlWidth, valLength >= 390 and 180 or 60)

    -- Asignamos el texto a los controles
    if i == 1 or i == 4 then
        subtitleControl:SetText(item.NombreRama or "")
    end
    descriptionControl:SetText(description or "")
    valuesControl:SetText(item.Valores or "")
end

function FilterData(filter, vista)
    local filteredData1 = {}
    local filteredData2 = {}

    -- Filtramos la data por el nombre de la lección
    for _, item in ipairs(CerconeGrimoireData) do
        if item.Nombre == filter then
            table.insert(filteredData1, item)
        end
    end

    -- Guardamos el rango de la data filtrada
    CerconeAddon.maxFilteredData = #filteredData1

    local subTitle = ""
    local helper = 0
    -- Filtramos la data por bloque
    for _, item in ipairs(filteredData1) do
        if item.NombreRama ~= subTitle then
            helper = helper + 1
            subTitle = item.NombreRama
        end

        if vista[1] == helper or vista[2] == helper then
            table.insert(filteredData2, item)
        end
    end

    return filteredData2
end

function CerconeAddon.ShowGrimorioPage(title, vista)
    local i = 1
    local vistaBackup = CerconeAddon.currentVista

    CerconeAddon.currentVista = vista
    CerconeAddon.currentTitle = title
    -- Filtramos la data de acuerdo al titulo
    CerconeAddon.filteredData = {}
    CerconeAddon.filteredData = FilterData(title, vista)

    if #CerconeAddon.filteredData == 0 then
        -- d("No se encontraron más datos para el título: " .. title)
        CerconeAddon.currentVista = vistaBackup
        return
    end

    PlaySound("Book_PageTurn")

    -- Limpiar la data del grimorio
    GetControl("GrimorioTitulo"):SetText("")
    GetControl("GrimorioNombreRama1"):SetText("")
    GetControl("GrimorioNombreRama4"):SetText("")
    GetControl("LogoRamas"):SetTexture("EsoUI/Art/Other/transparentPixel.dds")
    for j = 1, 6 do
        GetControl("GrimorioDescripcion" .. j):SetText("")
        GetControl("GrimorioValores" .. j):SetText("")
    end
    local subTitle = ""

    if vista[2] < 2 then
        GetControl("GrimorioTitulo"):SetText(title)
        CerconeAddon.SelectLogoNTitle(title)
        -- Datos para la vista principal del titulo
        i = 4
        for _, item in pairs(CerconeAddon.filteredData) do
            if item.Nombre == title then
                if item.NombreRama ~= subTitle and subTitle ~= "" then
                    break
                end
                if i > 6 then
                    break
                end
                CerconeAddon.AssignText(item, i)
                subTitle = item.NombreRama
                i = i + 1
            end
        end
    else
        -- Datos en las páginas
        for _, item in pairs(CerconeAddon.filteredData) do
            if item.Nombre == title then
                if i > 6 then
                    break
                end
                if item.NombreRama ~= subTitle and subTitle ~= "" then
                    i = 4
                end
                CerconeAddon.AssignText(item, i)
                subTitle = item.NombreRama
                i = i + 1
            end
        end
    end

    local grimoire = GetControl("Grimorio")
    local grimIndex = GetControl("GrimorioIndice")

    -- Calcular posición centrada
    local screenWidth, screenHeight = GuiRoot:GetDimensions()
    local windowWidth, windowHeight = grimoire:GetDimensions()
    local offsetX = (screenWidth - windowWidth) / 2
    local offsetY = (screenHeight - windowHeight) / 2

    -- Aplicar posición
    grimoire:ClearAnchors()
    grimoire:SetAnchor(CENTER, grimIndex, CENTER, 0, 0)
    grimoire:SetHidden(false)
end

function CerconeAddon.BackToIndex()
    GetControl("Grimorio"):SetHidden(true)
    GetControl("GrimorioIndice"):SetHidden(false)
    CerconeAddon.ShowGrimorio()
end

function CalculatePagesPerTitle(currentTitle)
    local pages = 0
    local currentSubtitle = ""
    for _, item in pairs(CerconeGrimoireData) do
        if item.Nombre == currentTitle then

            if item.NombreRama ~= currentSubtitle or currentSubtitle == "" then
                pages = pages + 1
            end
            currentSubtitle = item.NombreRama
            currentTitle = item.Nombre
        end
    end

    if pages % 2 == 1 then
        pages = pages + 1
    end

    return pages
end

function CerconeAddon.ShowGrimorio()
    local indexData = CerconeGrimoireData
    if not indexData or #indexData == 0 then
        d("No hay datos para mostrar en el índice")
        return
    end

    -- Índice
    local tituloControl = GetControl("Indice_Titulo")
    if tituloControl then
        tituloControl:SetText("Índice")
    end

    local usedTitle = ""
    local storedPages = 0
    for i, item in pairs(indexData) do
        if not item.Z then
            break
        end

        if usedTitle ~= item.Nombre then
            GetControl("Indice_Titulo" .. item.Z):SetText(item.Nombre or "")
            local pages = CalculatePagesPerTitle(item.Nombre)
            GetControl("Indice_TPagina" .. item.Z):SetText(storedPages + pages)
            storedPages = storedPages + pages
            if storedPages % 2 == 1 then
                storedPages = storedPages + 1
            end
        end

        usedTitle = item.Nombre
    end

    -- Agregar efectos de hover a los ítems del índice
    for i = 1, 100 do
        if not GetControl("Indice_Titulo" .. i) then
            break
        end
        CerconeAddon.AddHoverEffect(GetControl("Indice_Titulo" .. i):GetName(), TextColor.Normal, TextColor.Hover)
    end
end

function CerconeAddon.NavigateGrimorio(direction)

    local newVista = {}

    if direction == 0 then
        newVista[1] = CerconeAddon.currentVista[1] - 2
        newVista[2] = CerconeAddon.currentVista[2] - 2
    elseif direction == 1 then
        newVista[1] = CerconeAddon.currentVista[1] + 2
        newVista[2] = CerconeAddon.currentVista[2] + 2
    end

    CerconeAddon.ShowGrimorioPage(CerconeAddon.currentTitle, newVista)
end

function CerconeAddon.AddHoverEffect(label, normalColor, hoverColor)
    local labelControl = GetControl(label)
    if not labelControl then
        d("|cFF0000Error:|r Control no encontrado: " .. label)
        return
    end

    -- Habilitamos el MouseEnabled para el control
    labelControl:SetMouseEnabled(true)

    -- Convertir los colores hexadecimales a formato ZO
    local function ParseColor(hexColor)
        hexColor = hexColor:gsub("#", "")
        local r, g, b = tonumber(hexColor:sub(1, 2), 16), tonumber(hexColor:sub(3, 4), 16),
            tonumber(hexColor:sub(5, 6), 16)
        return r, g, b
    end

    labelControl:SetHandler("OnMouseEnter", function()
        local r, g, b = ParseColor(hoverColor)
        labelControl:SetColor(r / 255, g / 255, b / 255, 1) -- Cambia el color al pasar el mouse
    end)

    labelControl:SetHandler("OnMouseExit", function()
        local r, g, b = ParseColor(normalColor)
        labelControl:SetColor(r / 255, g / 255, b / 255, 1) -- Vuelve al color normal al salir del mouse
    end)

    labelControl:SetHandler("OnMouseUp", function()
        CerconeAddon.ShowGrimorioPage(labelControl:GetText(), {0, 1})
        GetControl("GrimorioIndice"):SetHidden(true)
    end)
end
