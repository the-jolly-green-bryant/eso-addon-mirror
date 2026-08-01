
ZO_CreateStringId("SI_BINDING_NAME_RPNIP_SHOW_PETS", "Show My Pets")
ImmersivePets = ImmersivePets or {}
local isPetUIOpen = false
ImmersivePets.Encyclopedia = ImmersivePets.Encyclopedia or {}
RPN_PetDB = RPN_PetDB or {}
local winRef = nil

local AdoptedPets = {
    pets = {}, -- Lista de pets adotados
    stories = {}, -- Histórias personalizadas dos pets
    favorites = {}, -- Pets favoritos
    lastAdopted = nil, -- Último pet adotado
    totalEncounters = 0, -- Total de encontros
    totalAdoptions = 0 -- Total de adoções
}

-- Constants
ZONE_DISPLAY_TYPE_DUNGEON = 2
ZONE_DISPLAY_TYPE_RAID = 3
ZONE_DISPLAY_TYPE_SOLO = 1
ZONE_DISPLAY_TYPE_GROUP_DELVE = 4
ZONE_DISPLAY_TYPE_GROUP_AREA = 5
ZONE_DISPLAY_TYPE_PUBLIC_DUNGEON = 6
ZONE_DISPLAY_TYPE_DELVE = 7
ZONE_DISPLAY_TYPE_HOUSING = 8
ZONE_DISPLAY_TYPE_BATTLEGROUND = 9
ZONE_DISPLAY_TYPE_ZONE_STORY = 10
ZONE_DISPLAY_TYPE_COMPANION = 11
ZONE_DISPLAY_TYPE_ENDLESS_DUNGEON = 12

local function OpenGoldDonationMail()
    SCENE_MANAGER:Show("mailSend")

    zo_callLater(function()
        ZO_MailSendToField:SetText("@caon420")
        ZO_MailSendSubjectField:SetText("Thanks for the Addon!")

    end, 100) -- Delay to ensure the mail UI is visible
end

local panelData = {
    type = "panel",
    name = "RolePlayNeeds - Immersive Pets",
    author = "@matheusbk2 and @caon420",
    version = "0.3",
    registerForRefresh = true,
}

local optionsData = {
    {
        type = "slider",
        name = "Adoption Chance (%)",
        tooltip = "Chance for a pet to approach you when exploring.",
        min = 0,
        max = 100,
        step = 0.25,
        getFunc = function() return RPN_PetDB.adoptChance end,
        setFunc = function(value) RPN_PetDB.adoptChance = value end,
        default = 25,
    },
    {
        type = "checkbox",
        name = "Environment-Based Encounters",
        tooltip = "Pets appear based on their subcategory: Exotic in wilderness, Domestic in cities, Daedric in dungeons. When OFF, any pet can appear anywhere.",
        getFunc = function() return RPN_PetDB.environmentBased end,
        setFunc = function(value) RPN_PetDB.environmentBased = value end,
        default = true,
    },
    {
        type = "slider",
        name = "Cooldown (minutes)",
        tooltip = "Minimum time between pet encounters.",
        min = 1,
        max = 15,
        step = 1,
        getFunc = function() return RPN_PetDB.cooldownMinutes end,
        setFunc = function(value) RPN_PetDB.cooldownMinutes = value end,
        default = 15,
    },
    {
        type = "header",
        name = "\n",
    },
    {
        type = "description",
        text = "If you enjoy this addon, consider supporting the creators for more of the RolePlayNeeds Series: \n \n |cFFFFFFhttps://www.patreon.com/c/RolePlayNeeds|r \n\n https://discord.gg/qgKkdYSs",
        width = "full",
    },
    {
        type = "button",
        name = "Copy Patreon Link",
        tooltip = "Click to copy the support link in your chat.",
        func = function()
            StartChatInput("https://www.patreon.com/c/RolePlayNeeds")
        end,
        width = "half",
    },
        {
        type = "button",
        name = "Copy Discord Invite",
        tooltip = "Click to copy Discord Invite link in your chat.",
        func = function()
            StartChatInput("https://discord.gg/qgKkdYSs")
        end,
        width = "half",
    },
    {
        type = "button",
        name = "Donate Gold",
        tooltip = "Click to Say 'Thanks My Dude!' Any form of appreciation is appreciated. :)",
        func = function()
            OpenGoldDonationMail()
        end,
        width = "half",
    }
}


local SUBCATEGORY_TO_ENVIRONMENT = {
    -- WILDERNESS - Pets selvagens e voadores
    ["Exotic"] = "wilderness",
    ["Flying Pets"] = "wilderness",
    ["Mascotes Alados"] = "wilderness",
    ["Exótico"] = "wilderness",
    -- CITY - Pets domésticos e de inventário
    ["Domestic"] = "city",
    ["Doméstico"] = "city",
    ["Inventário"] = "city",
    ["Inventory"] = "city",
    -- DUNGEON - Pets daédricos
    ["Daedric"] = "dungeon",
    ["Daédrico"] = "dungeon"
}



local ENCOUNTER_MESSAGES = {
    wilderness = {
        "A wild %s emerges from the undergrowth, watching you with curious eyes.",
        "You spot a %s in its natural habitat. It seems drawn to your presence.",
        "A %s cautiously approaches from the wilderness, sensing your gentle nature.",
        "From the forest depths, a %s appears, tilting its head with interest.",
    },
    city = {
        "A friendly %s trots up to you, looking well-cared for but seeking companionship.",
        "You notice a %s that seems to have been wandering the streets. It approaches hopefully.",
        "A tame %s appears, wagging its tail and looking for a new home.",
        "A domesticated %s crosses your path, purring softly and seeking attention.",
    },
    dungeon = {
        "From the shadows emerges a %s, its otherworldly presence both beautiful and terrifying.",
        "A %s materializes nearby, drawn by the dark energies of this place.",
        "You sense a %s watching from the realm between realms. It seems... interested.",
        "Ancient magic stirs as a %s phases into existence, curious about your presence.",
    },
    any = {
        "A %s approaches you with gentle curiosity, sensing your kind nature.",
        "You notice a %s watching you intently. It seems to want companionship.",
        "A %s appears nearby, tilting its head as if asking to join you.",
        "Something stirs nearby as a %s emerges, drawn to your adventurous spirit.",
    }
}


function containsItemInList(item, list)
    for _, value in ipairs(list) do
        if value == item then
            return true
        end
    end
    return false
end

local function GetAdoptedPetNames()
    local names = {}
    if RPN_PetDB.adoptedPets then
        if RPN_PetDB.adoptedPets.pets then
            if next(RPN_PetDB.adoptedPets.pets) then
                for petName in pairs(RPN_PetDB.adoptedPets.pets) do
                    table.insert(names, petName)
                end
            end
        end
    end

    return names
end


local petCache = {
    wilderness = {},
    city = {},
    dungeon = {},
    all = {} -- Nova categoria para quando environmentBased = false
}
local cacheLastUpdate = 0
local CACHE_DURATION = 300
local function GeneratePetCache(allowRepeated)

    local now = GetTimeStamp()
    
    -- Verifica se o cache ainda é válido
    if now - cacheLastUpdate < CACHE_DURATION then
        local hasValidCache = false
        for _, pets in pairs(petCache) do
            if next(pets) then
                hasValidCache = true
                break
            end
        end
        -- if hasValidCache then
        --     return petCache
        -- end
    end
    
    -- Limpa o cache
    for category in pairs(petCache) do
        petCache[category] = {}
    end
    
    if not ZO_COLLECTIBLE_DATA_MANAGER then
        d("[Pet System] ERROR: ZO_COLLECTIBLE_DATA_MANAGER not available")
        return petCache
    end
    
    -- Identifica categorias que contêm pets
    local petCategories = {}
    for _, categoryData in ZO_COLLECTIBLE_DATA_MANAGER:CategoryIterator() do
        for _, subCategoryData in categoryData:SubcategoryIterator() do
            for _, collectibleData in subCategoryData:CollectibleIterator() do
                if collectibleData:IsCategoryType(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET) then
                    petCategories[categoryData:GetName()] = true
                    break
                end
            end
        end
    end
    
    local totalPets = 0
    local categoryStats = {}
    
    -- Processa pets organizados por subcategoria
    for _, categoryData in ZO_COLLECTIBLE_DATA_MANAGER:CategoryIterator() do
        if petCategories[categoryData:GetName()] then
            for _, subCategoryData in categoryData:SubcategoryIterator() do
                local subCategoryName = subCategoryData:GetName()
                local environment = SUBCATEGORY_TO_ENVIRONMENT[subCategoryName] or "wilderness" -- Default para wilderness ao invés de uncategorized
                
                for _, collectibleData in subCategoryData:CollectibleIterator() do
                    if collectibleData:IsCategoryType(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET) and 
                       collectibleData:IsUnlocked() then

                        local petId = collectibleData:GetId()
                        local petNickname = GetCollectibleNickname(petId)
                        local petName = collectibleData:GetFormattedName()
                        local adoptedPets = GetAdoptedPetNames()
                        local hasPet = containsItemInList(petName, adoptedPets)
                        if allowRepeated or not hasPet then
                            local petData = {
                                id = petId,
                                nickname = petNickname,
                                subCategory = subCategoryName,
                                category = categoryData:GetName()
                            }
                            
                            -- Adiciona na categoria específica
                            petCache[environment][petName] = petData
                            
                            -- SEMPRE adiciona na categoria 'all' para quando environmentBased = false
                            petCache.all[petName] = petData
                            totalPets = totalPets + 1
                            categoryStats[environment] = (categoryStats[environment] or 0) + 1
                            


                        end
                    end
                end
            end
        end
    end
    
    cacheLastUpdate = now
    
    ---- Log das estatísticas
    --d("[Pet System] Cache updated:")
    --for environment, count in pairs(categoryStats) do
    --    d("  " .. environment .. ": " .. count .. " pets")
    --end
    --d("  Total: " .. totalPets .. " pets")
    --d("  All pets pool: " .. (#petCache.all and "available" or "empty"))
    
    return petCache
end

local function SaveAdoptedPets()
    if not RPN_PetDB then return end
    RPN_PetDB.adoptedPets = AdoptedPets
end

local function LoadAdoptedPets()
    if RPN_PetDB and RPN_PetDB.adoptedPets then
        AdoptedPets = RPN_PetDB.adoptedPets
        -- Garantir que todas as tabelas existam
        AdoptedPets.pets = AdoptedPets.pets or {}
        AdoptedPets.stories = AdoptedPets.stories or {}
        AdoptedPets.favorites = AdoptedPets.favorites or {}
        AdoptedPets.totalEncounters = AdoptedPets.totalEncounters or 0
        AdoptedPets.totalAdoptions = AdoptedPets.totalAdoptions or 0
    end
end


--local function ShowEncyclopediaEntry(petName)
--    local petRecord = AdoptedPets.pets[petName]
--    if not petRecord then
--        d("[Enciclopédia] Pet não encontrado: " .. petName)
--        return
--    end
--
--    --local favoriteStatus = petRecord.isFavorite and " ⭐" or ""
--
--    --d("=== 📖 ENCICLOPÉDIA DE PETS - " .. petName .. favoriteStatus .. " ===")
--    --d("|cFFD700Nome:|r " .. petRecord.name)
--    --d("|cFFD700Categoria:|r " .. (petRecord.category or "Desconhecida"))
--    --d("|cFFD700Subcategoria:|r " .. (petRecord.subCategory or "Desconhecida"))
--    --d("|cFFD700Ambiente de Encontro:|r " .. (petRecord.environment or "Desconhecido"))
--    --d("|cFFD700Data de Adoção:|r " .. (petRecord.adoptionDate or "Desconhecida"))
--    --d("|cFFD700Total de Encontros:|r " .. (petRecord.encounters or 1))
--
--    if petRecord.story then
--        d("|cFFD700História:|r")
--        d("|cCCCCCC" .. petRecord.story .. "|r")
--    end
--
--    d("=== Fim da Entrada ===")
--end

--local function ShowFullEncyclopedia()
--    local totalPets = 0
--    local favoriteCount = 0
--
--    for _ in pairs(AdoptedPets.pets) do
--        totalPets = totalPets + 1
--    end
--
--    for _, pet in pairs(AdoptedPets.pets) do
--        if pet.isFavorite then
--            favoriteCount = favoriteCount + 1
--        end
--    end
--
--    d("=== 📚 ENCICLOPÉDIA COMPLETA DE PETS ===")
--    d("|cFFD700Total de Pets Adotados:|r " .. totalPets)
--    d("|cFFD700Pets Favoritos:|r " .. favoriteCount)
--    d("|cFFD700Total de Encontros:|r " .. AdoptedPets.totalEncounters)
--    d("|cFFD700Último Pet Adotado:|r " .. (AdoptedPets.lastAdopted or "Nenhum"))
--    d("")
--
--    if totalPets == 0 then
--        d("|cFF6666Sua enciclopédia está vazia. Comece a adotar pets para preenchê-la!|r")
--        return
--    end
--
--    -- Organizar pets por categoria
--    local petsByCategory = {}
--    for petName, petData in pairs(AdoptedPets.pets) do
--        local category = petData.category or "all"
--        if not petsByCategory[category] then
--            petsByCategory[category] = {}
--        end
--        table.insert(petsByCategory[category], {name = petName, data = petData})
--    end
--
--    -- Mostrar pets organizados
--    for category, pets in pairs(petsByCategory) do
--        d("|cFF9966=== " .. category .. " ===|r")
--
--        -- Ordenar por data de adoção (mais recente primeiro)
--        table.sort(pets, function(a, b)
--            return (a.data.adoptionTime or 0) > (b.data.adoptionTime or 0)
--        end)
--
--        for _, pet in ipairs(pets) do
--            local favoriteIcon = pet.data.isFavorite and "⭐ " or ""
--            local encounterText = pet.data.encounters > 1 and " (" .. pet.data.encounters .. " encontros)" or ""
--            d("  " .. favoriteIcon .. pet.name .. encounterText)
--        end
--        d("")
--    end
--
--    d("Use /petinfo <nome> para ver detalhes de um pet específico")
--    d("Use /petfavorite <nome> para marcar/desmarcar como favorito")
--end

--
--local function InvokePetByName(petName)
--    local allowRepeat = false
--    if not petName or petName == "" then
--        d("[Invocação] Nome do pet não especificado")
--        return false
--    end
--
--    -- Verificar se o pet está na enciclopédia
--    local petRecord = AdoptedPets.pets[petName]
--    if petRecord then
--        -- Pet está registrado, usar o ID salvo
--        UseCollectible(petRecord.id)
--        d("[Invocação] Invocando pet registrado: " .. petName)
--        return true
--    else
--        -- Pet não está registrado, tentar encontrar através do cache
--        local cache = GeneratePetCache(allowRepeat)
--        for _, pets in pairs(cache) do
--            local petData = pets[petName]
--            if petData and petData.id then
--                UseCollectible(petData.id)
--                d("[Invocação] Invocando pet não registrado: " .. petName)
--                return true
--            end
--        end
--    end
--
--    d("[Invocação] Pet não encontrado: " .. petName)
--    return false
--end

local function ClearAllControls(parent)
    if not parent then return end
    
    -- Obter todos os filhos antes de começar a remover
    local children = {}
    local numChildren = parent:GetNumChildren()
    
    if numChildren and numChildren > 0 then
        for i = 1, numChildren do
            local child = parent:GetChild(i)
            if child then
                table.insert(children, child)
            end
        end
    end
    
    -- Agora remover todos os filhos
    for _, child in ipairs(children) do
        if child and child.SetParent then
            child:SetHidden(true)
            child:ClearAnchors()
            child:SetParent(nil)
        end
    end
end

local function ReleasePet(petName)
    if not petName or petName == "" then
        --d("[Pet System] Invalid pet name.")
        return
    end

    if RPN_PetDB.adoptedPets and RPN_PetDB.adoptedPets.pets then
        if RPN_PetDB.adoptedPets.pets[petName] then
            RPN_PetDB.adoptedPets.pets[petName] = nil
            d("[Pet System] Released pet: " .. petName)

            -- Atualiza UI se estiver aberta
            ShowPets()
            ShowPets()
        else
            d("[Pet System] Pet not found: " .. petName)
        end
    else
        --d("[Pet System] No adopted pets to release.")
    end
end

local petToRelease = nil
ZO_Dialogs_RegisterCustomDialog("RPN_CONFIRM_RELEASE_PET", {
    title = { text = "Release Pet?" },
    mainText = { text = "Are you sure you want to release this pet? This cannot be undone!" },
    buttons = {
        {
            text = "Confirm Release",
            callback = function()
                ReleasePet(petToRelease)
            end
        },
        {
            text = "Cancel",
            callback = function()
                petToRelease = nil
            end
        }
    }
})

local windowCount = 0
local function CreateEncyclopediaWindow()

    if winRef then
        if winRef.scrollChild then
            ClearAllControls(winRef.scrollChild)
        end
        winRef:SetHidden(true)
        winRef:ClearAnchors()
        winRef:SetParent(nil)
        winRef = nil
    end

    local windowName = "ImmersivePets_EncyclopediaWindow_" .. windowCount
    windowCount = windowCount + 1
    local ImmersivePets_EncyclopediaWindow = WINDOW_MANAGER:CreateTopLevelWindow(windowName)
    local win = ImmersivePets_EncyclopediaWindow
    if not win then
        d("[ERROR] Failed to create main window")
        return
    end
    win:SetDimensions(500, 600)
    win:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    win:SetMovable(true)
    win:SetMouseEnabled(true)
    win:SetClampedToScreen(true)
    winRef = win
    -- Fundo
    local bg = WINDOW_MANAGER:CreateControl(nil, win, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.1, 0.1, 0.1, 0.9)
    bg:SetEdgeColor(1, 1, 1, 0.5)

    -- Cabeçalho
    local header = WINDOW_MANAGER:CreateControl(nil, win, CT_CONTROL)
    header:SetDimensions(500, 40)
    header:SetAnchor(TOPLEFT, win, TOPLEFT, 0, 0)
    header:SetAnchor(TOPRIGHT, win, TOPRIGHT, 0, 0)
    
    local headerBg = WINDOW_MANAGER:CreateControl(nil, header, CT_BACKDROP)
    headerBg:SetAnchorFill()
    headerBg:SetCenterColor(0.2, 0.2, 0.2, 0.9)
    headerBg:SetEdgeColor(0.8, 0.8, 0.8, 0.5)

    -- Título
    local title = WINDOW_MANAGER:CreateControl(nil, header, CT_LABEL)
    title:SetFont("ZoFontWinH2")
    title:SetText("My Pets")
    title:SetAnchor(CENTER, header, CENTER, 0, 0)

    -- Botão fechar
    local close = WINDOW_MANAGER:CreateControlFromVirtual(nil, header, "ZO_DefaultButton")
    close:SetDimensions(30, 30)
    close:SetAnchor(TOPRIGHT, header, TOPRIGHT, -5, 5)
    close:SetText("X")
    close:SetHandler("OnClicked", function() 
        if win then
            win:SetHidden(true)
            isPetUIOpen = false
        end 
    end)

    -- Botão reset
    local resetBtn = WINDOW_MANAGER:CreateControlFromVirtual(nil, header, "ZO_DefaultButton")
    resetBtn:SetDimensions(120, 30)
    resetBtn:SetAnchor(TOPLEFT, header, TOPLEFT, 5, 5)
    resetBtn:SetText("Reset")
    resetBtn:SetHandler("OnClicked", function()
        ZO_Dialogs_ShowDialog("RPN_CONFIRM_RESET_UI")
    end)

    -- Área de scroll
    local scrollName = "ImmersivePets_ScrollContainer_" .. windowCount
    local scroll = WINDOW_MANAGER:CreateControlFromVirtual(scrollName, win, "ZO_ScrollContainer")
    if not scroll then
        d("[ERROR] Failed to create scroll container")
        return
    end
    
    scroll:SetAnchor(TOPLEFT, header, BOTTOMLEFT, 0, 5)
    scroll:SetAnchor(BOTTOMRIGHT, win, BOTTOMRIGHT, 0, 0)
    
    win.scrollChild = scroll:GetNamedChild("ScrollChild")
    if not win.scrollChild then
        d("[ERROR] Failed to get scrollChild")
        return
    end
    
    win.scrollChild:SetResizeToFitDescendents(true)
    win.scrollChild:SetWidth(460)

    -- Função de atualização melhorada
    function win:UpdateContent()
        if not self or not self.scrollChild then
            d("[ERROR] Failed to update content - invalid window or scrollChild")
            return
        end

        -- Limpeza completa e segura dos controles
        ClearAllControls(self.scrollChild)

        local y = 0
        local rowHeight = 64
        local padding = 10
        local petCount = 0

        -- Criar array ordenado de pets para garantir ordem consistente
        local petArray = {}
        for petName, petData in pairs(AdoptedPets.pets) do
            if petData and petData.id then
                table.insert(petArray, {name = petName, data = petData})
                petCount = petCount + 1
            end
        end

        -- Ordenar por data de adoção (mais recente primeiro)
        table.sort(petArray, function(a, b)
            return (a.data.adoptionTime or 0) > (b.data.adoptionTime or 0)
        end)

        -- Se não há pets, mostrar mensagem
        if petCount == 0 then
            local emptyLabel = WINDOW_MANAGER:CreateControl(nil, self.scrollChild, CT_LABEL)
            if emptyLabel then
                emptyLabel:SetFont("ZoFontGame")
                emptyLabel:SetText("No pets adopted yet. Start exploring to find companions!")
                emptyLabel:SetAnchor(CENTER, self.scrollChild, CENTER, 0, 50)
                emptyLabel:SetColor(0.7, 0.7, 0.7, 1)
            end
            
            if self.scrollChild.SetHeight then
                self.scrollChild:SetHeight(150)
            end
            return
        end

        -- Adicionar os pets organizados
        for _, pet in ipairs(petArray) do
            local petName = pet.name
            local petNickname = pet.data.nickname
            local petData = pet.data
            
            local row = WINDOW_MANAGER:CreateControl(nil, self.scrollChild, CT_CONTROL)
            if row then
                row:SetDimensions(460, rowHeight)
                row:SetAnchor(TOPLEFT, self.scrollChild, TOPLEFT, 0, y)


                local release = WINDOW_MANAGER:CreateControlFromVirtual(nil, row, "ZO_DefaultButton")
                if release then
                    release:SetDimensions(30, 30)
                    release:SetAnchor(LEFT, row, LEFT, 5, 0)
                    release:SetText("X")
                    release:SetHandler("OnClicked", function()
                        petToRelease = petName
                        ZO_Dialogs_ShowDialog("RPN_CONFIRM_RELEASE_PET")
                    end)
                end


                local icon = WINDOW_MANAGER:CreateControl(nil, row, CT_TEXTURE)
                if icon then
                    icon:SetDimensions(48, 48)
                    icon:SetAnchor(LEFT, row, LEFT, 50, 0)
                    local iconPath = select(3, GetCollectibleInfo(petData.id))
                    icon:SetTexture(iconPath or "EsoUI/Art/Collections/collections_tabIcon_pets_up.dds")
                end

                local label = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
                if label and icon then
                    label:SetFont("ZoFontGame")
                    label:SetText(petNickname .. "\n" .. '(' .. petName .. ')')
                    label:SetAnchor(LEFT, icon, RIGHT, 10, 0)
                end


                local btn = WINDOW_MANAGER:CreateControlFromVirtual(nil, row, "ZO_DefaultButton")
                if btn then
                    btn:SetDimensions(80, 30)
                    btn:SetAnchor(RIGHT, row, RIGHT, 0, 0)
                    btn:SetText("Summon")
                    btn:SetHandler("OnClicked", function() 
                        if petData.id then
                            UseCollectible(petData.id) 
                        end
                    end)
                end

                y = y + rowHeight + padding
            end
        end


        if self.scrollChild.SetHeight then
            self.scrollChild:SetHeight(math.max(y, 100))
        end
        
        --d("[UI] Encyclopedia updated with " .. petCount .. " pets")
    end


    win:UpdateContent()
    win:SetHidden(false)

end

local function RegisterPetAdoption(petName, petData, environment, isManual)
    if not petName or not petData then 
        d("[ERROR] Invalid pet data for registration")
        return false 
    end
    
    local adoptionTime = GetTimeStamp()
    local adoptionDate = GetDateStringFromTimestamp(adoptionTime)
    

    local templates = ENCOUNTER_MESSAGES[environment] or ENCOUNTER_MESSAGES.any
    local storyTemplate = templates[math.random(1, #templates)]
    local customStory = string.format(storyTemplate, petName)

    local existingPet = AdoptedPets.pets[petName]
    if existingPet then
        existingPet.encounters = existingPet.encounters + 1
        existingPet.lastSeen = adoptionTime

    else
        -- Registrar nova adoção
        AdoptedPets.pets[petName] = {
            id = petData.id,
            name = petName,
            nickname = petData.nickname,
            subCategory = petData.subCategory,
            category = petData.category,
            environment = environment,
            adoptionDate = adoptionDate,
            adoptionTime = adoptionTime,
            story = customStory,
            encounters = 1,
            lastSeen = adoptionTime,
            isManual = isManual or false,
            isFavorite = false
        }
        AdoptedPets.totalAdoptions = AdoptedPets.totalAdoptions + 1
        d("[My Pets] New Pet: " .. petName)
    end
    
    AdoptedPets.lastAdopted = petName
    AdoptedPets.totalEncounters = AdoptedPets.totalEncounters + 1

    SaveAdoptedPets()
    return true
end



local function ClearEncyclopedia(confirmCode)
    if confirmCode ~= "CONFIRMAR_RESET" then

        return false
    end

    local backupSettings = {}
    if RPN_PetDB then
        backupSettings = {
            adoptChance = RPN_PetDB.adoptChance,
            environmentBased = RPN_PetDB.environmentBased,
            cooldownMinutes = RPN_PetDB.cooldownMinutes,

        }
    end
    

    AdoptedPets = {
        pets = {},
        stories = {},
        favorites = {},
        lastAdopted = nil,
        totalEncounters = 0,
        totalAdoptions = 0
    }
    
    -- Restaurar configurações
    if RPN_PetDB then
        for key, value in pairs(backupSettings) do
            RPN_PetDB[key] = value
        end
        RPN_PetDB.adoptedPets = AdoptedPets
    end
    
    -- Fechar e recriar a janela completamente
    if winRef then
        winRef:SetHidden(true)
        winRef = nil
    end
    

    
    return true
end

ZO_Dialogs_RegisterCustomDialog("RPN_CONFIRM_RESET_UI", {
    title = { text = "Reset Pet Data" },
    mainText = { text = "Are you sure you want to reset ALL pet records? This cannot be undone!" },
    buttons = {
        {
            text = "Confirm Reset",
            callback = function()
                isPetUIOpen = false
                ClearEncyclopedia("CONFIRMAR_RESET")
                ShowPets()

            end
        },
        {
            text = "Cancel",
        }
    }
})

local function InitializeEncyclopedia()
    LoadAdoptedPets()
end



local lastEncounterTime = 0
local updateCounter = 0



local function NormalizeZoneName(name)
    if not name or name == "" then return "" end
    
    name = name:gsub("[\r\n]+", " ")
    name = name:gsub("[%(%)%[%]]", " ")
    name = name:gsub("%s+", " ")
    return name:match("^%s*(.-)%s*$") or ""
end

local function IsPlayerInCity()
    local zoneIndex = GetUnitZoneIndex("player")
    local zoneName = NormalizeZoneName(GetZoneNameByIndex(zoneIndex))
    local subzoneName = NormalizeZoneName(GetMapName())
    


    if subzoneName ~= zoneName and subzoneName ~= "" then
        return true
    end
    
    return false
end

local function GetCurrentEnvironment()

    if IsUnitInCombat("player") then
        return nil
    end
    

    local dungeonDifficulty = GetCurrentZoneDungeonDifficulty()
    if dungeonDifficulty > DUNGEON_DIFFICULTY_NONE then
        return "dungeon"
    end
    

    if IsPlayerInCity() then
        return "city"
    end

    return "wilderness"
end



local function SelectPetForEnvironment(targetEnvironment)
    local allowRepeat = false
    local cache = GeneratePetCache(allowRepeat)
    

    if RPN_PetDB.environmentBased == false then
        local availablePets = cache.all or {}
        if not next(availablePets) then
            return nil, nil, "any"
        end
        
        -- Seleciona um pet aleatório de todos os disponíveis
        local petNames = {}
        for name in pairs(availablePets) do
            table.insert(petNames, name)
        end
        
        if #petNames == 0 then return nil, nil, "any" end
        
        local selectedName = petNames[math.random(1, #petNames)]
        local selectedData = availablePets[selectedName]
        return selectedName, selectedData, "any"
    end
    

    if not targetEnvironment then
        targetEnvironment = "wilderness"
    end
    

    local availablePets = cache[targetEnvironment] or {}

    local count = 0
    for _ in pairs(availablePets) do
        count = count + 1
    end
    if not next(availablePets) then
        return nil, nil, nil
    end
    
    -- Seleciona um pet aleatório
    local petNames = {}
    for name in pairs(availablePets) do
        table.insert(petNames, name)
    end
    
    if #petNames == 0 then return nil, nil, nil end
    
    local selectedName = petNames[math.random(1, #petNames)]
    local selectedData = availablePets[selectedName]
    return selectedName, selectedData, targetEnvironment
end

SLASH_COMMANDS["/mypet"] = function()
    local activeCollectibleId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET)

    if not activeCollectibleId or activeCollectibleId == 0 then
        return
    end

    local name, description, iconFile, unlocked, _, _, _, isActive = GetCollectibleInfo(activeCollectibleId)

    if unlocked then
        d(string.format(" Active Pet: %s", name))
        d(string.format(" Active Pet: %s", activeCollectibleId))
    end
end

local function GetActivePetName()
     local activeCollectibleId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET)

    if not activeCollectibleId or activeCollectibleId == 0 then
        --d(" You don't have any pet summoned.")
        return
    end

    local name, description, iconFile, unlocked, _, _, _, isActive = GetCollectibleInfo(activeCollectibleId)
    if unlocked then
        return name, activeCollectibleId
    end

    return name, activeCollectibleId
end

local function AdoptPetByName(petName)
    local activePetName, activePetId = GetActivePetName()
    if not petName or petName == "" then return false end
    local allowRepeat = false
    local cache = GeneratePetCache(allowRepeat)
    
    -- Procura em todas as categorias (incluindo 'all')
    for _, pets in pairs(cache) do
        local petData = pets[petName]
        if petData and petData.id then
            UseCollectible(petData.id)
            return true
        end
    end
    
    return false
end



local function CreateEncounterDialog(petName, petData, environment)
    local activePetName, activePetId = GetActivePetName()
    if not petName or petName == "" then 
        d("[Pet System] Invalid pet name for dialog")
        return 
    end
    
    local messages = ENCOUNTER_MESSAGES[environment] or ENCOUNTER_MESSAGES.any
    local messageTemplate = messages[math.random(1, #messages)]
    local message = string.format(messageTemplate, petName)
    
    -- Gerar ID único para o diálogo
    local dialogId = "RPN_PET_DIALOG_" .. GetTimeStamp() .. "_" .. math.random(1000, 9999)
    
    -- Determinar título baseado no environment
    local titleText = "A Mystical Encounter"
    if environment == "wilderness" then
        titleText = "A Wilderness Encounter"
    elseif environment == "city" then
        titleText = "A City Encounter"
    elseif environment == "dungeon" then
        titleText = "A Dungeon Encounter"
    end
    AdoptPetByName(petName)
    
    ZO_Dialogs_RegisterCustomDialog(dialogId, {
        title = { text = titleText },
        mainText = { text = message },
        buttons = {
            {
                text = "Welcome, friend",
                callback = function()
                    RegisterPetAdoption(petName, petData, environment, false)
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, "Your new companion seems content to join your journey!")
                    ShowPets()
                    ShowPets()
                    if not isPetUIOpen then
                        ShowPets()
                    end
                    
                end
            },
            {
                text = "Not today",
                callback = function()
                    local rejectionMsg = "The creature understands and returns to its realm."
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, rejectionMsg)
                    if not activePetName then

                        AdoptPetByName(petName)
                    else AdoptPetByName(activePetName)
                    end

                end
            },
        }
    })

    zo_callLater(function()
        ZO_Dialogs_ShowDialog(dialogId)
    end, 500)
end



local function TryPetEncounter()

    
    local now = GetTimeStamp()
    local cooldownSeconds = (RPN_PetDB.cooldownMinutes or 2) * 60
    

    if now - lastEncounterTime < cooldownSeconds then 
        --d("[Pet System] Still in cooldown")
        return 
    end
    

    if IsUnitInCombat("player") then 
        --d("[Pet System] In combat, skipping")
        return 
    end
    
    local environment = GetCurrentEnvironment()
    if not environment then 
        d("[Pet System] No valid environment detected")
        return 
    end
    
    --d("[Pet System] Trying encounter in: " .. environment .. " (environmentBased: " .. tostring(RPN_PetDB.environmentBased) .. ")")
    
    lastEncounterTime = now
    
    local petName, petData, petEnvironment = SelectPetForEnvironment(environment)
    
    if not petName then 
        d("[Pet System] No pets available for encounter")
        return 
    end
    
    local chance = RPN_PetDB.adoptChance or 25
    local roll = math.random(1, 100)

    if roll <= chance then
        CreateEncounterDialog(petName, petData, petEnvironment)
        return true
    end
end


local function IsAnyMainUIOpen()
    return not SCENE_MANAGER:IsShowing("hud")
end

local function OnUpdate()
    local isMainUIOpen = IsAnyMainUIOpen()
    if not isMainUIOpen then
        updateCounter = updateCounter + 1
        if updateCounter >= RPN_PetDB.cooldownMinutes*60 then -- A cada 60 segundos (500ms * 120)
            updateCounter = 0
            TryPetEncounter()
        end
    end
end




local function OnAddonLoaded(event, addonName)
    if addonName ~= "ImmersivePets" then return end
    
    EVENT_MANAGER:UnregisterForEvent("ImmersivePets", EVENT_ADD_ON_LOADED)
    

    RPN_PetDB = ZO_SavedVars:New("RPN_PetSettings", 3, nil, {
        adoptChance = 50,
        environmentBased = true,
        cooldownMinutes = 2,
        autoEncounters = true,
    })
    

    local LAM = LibAddonMenu2
    if LAM then
        LAM:RegisterAddonPanel("RPN_PetPanel", panelData)
        LAM:RegisterOptionControls("RPN_PetPanel", optionsData)
    end
    

    local allowRepeat = false
    GeneratePetCache(allowRepeat)
    EVENT_MANAGER:RegisterForUpdate("ImmersivePets_Update", 500, OnUpdate)


    InitializeEncyclopedia()

    d("Immersive Pets v0.3 loaded - Integrated subcategory system active!")
end

function ShowPets()
    if isPetUIOpen then
        if winRef then
            winRef:SetHidden(true)

        end
        isPetUIOpen = false
        if CHAT_SYSTEM then
            CHAT_SYSTEM:Minimize()
        end
    else
        CreateEncyclopediaWindow()
        isPetUIOpen = true
        SetGameCameraUIMode(true)


    end
end
EVENT_MANAGER:RegisterForEvent("ImmersivePets", EVENT_ADD_ON_LOADED, OnAddonLoaded)


SLASH_COMMANDS["/petencounter"] = function()
    local env = GetCurrentEnvironment()

    d("[Pet System] Forcing encounter...")
    lastEncounterTime = 0 -- Reset cooldown
    local found = TryPetEncounter()
    if found then
        d('Pet Found!')
    else
        d('Pet Escaped!')
    end
end

SLASH_COMMANDS["/adopt"] = function(args)
    AdoptPetByName(args)
    ShowPets()
    ShowPets()
end
SLASH_COMMANDS["/mypets"] = ShowPets
SLASH_COMMANDS["/petlocation"] = function()
    local zoneIndex = GetUnitZoneIndex("player")
    local zoneName = GetZoneNameByIndex(zoneIndex)
    local mapName = GetMapName()
    local currentEnv = GetCurrentEnvironment()
    local dungeonDiff = GetCurrentZoneDungeonDifficulty()
    
    d("=== Location Information ===")
    d("Zone Index: " .. zoneIndex)
    d("Zone Name: " .. tostring(NormalizeZoneName(zoneName)))
    d("Map Name: " .. tostring(NormalizeZoneName(mapName)))
    d("Dungeon Difficulty: " .. tostring(dungeonDiff))
    d("Detected Environment: " .. (currentEnv or "none"))
end