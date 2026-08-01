local addon = ImmersiveHair

-- Check if a collectible is a hair style appearance
local function IsHairCollectible(collectibleData)
    if collectibleData then
        local cat = collectibleData:GetParentCategoryData()
        local subCat = collectibleData:GetParentSubcategoryData()
        if not (cat and subCat) then return false end

        return cat:GetName() == "Appearance" and subCat:GetName() == "Hair Styles"
    end
    return false
end

-- Check if a collectible is a facial hair appearance
local function IsBeardCollectible(collectibleData)
    if collectibleData then
        local cat = collectibleData:GetParentCategoryData()
        local subCat = collectibleData:GetParentSubcategoryData()
        if not (cat and subCat) then return false end

        return cat:GetName() == "Appearance" and subCat:GetName() == "Facial Hair"
    end
    return false
end

function addon.LoadSettings()
    local LAM = LibAddonMenu2

    local panel = {
        type = "panel",
        displayName = "ImmersiveHair",
        name = "RolePlayNeeds - Immersive Hair",
        author = "@matheusbk2",
        version = addon.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local options = {
        {
            type = "slider",
            name = "Growth Time (minutes)",
            tooltip = "-- MUST RELOAD UI -- \n How long hair stage takes to grow 1 stage in PLAYING TIME! \n LOGGED OUT time does not affect growth. \n *Beard will grow 2x Faster than this timer)",
            min = 1,
            max = 1440,
            step = 1,
            getFunc = function() return addon.saved.growthTime end,
            setFunc = function(value)
                addon.saved.growthTime = value
                addon.saved.beardTime = value/2

            end,
            default = 360
        },
        {
            type = "dropdown",
            name = "Current Hair Stage (SET STYLE BELOW FIRST!!)",
            tooltip = "Select your current hair stage",
            choices = {"Shortest", "Stage 1", "Stage 2"},
            getFunc = function() return addon.saved.currentStage end,
            setFunc = function(value)
                if addon.saved.currentStage then
                    addon.saved.currentStage = value
                    addon.SetHairStage(value)
                else
                    d('SET STYLES FIRST!')
                end
            end ,
        },
        {
            type = "header",
            name = "Styles:",
        },
        {
            type = "description",
            text = "Select which collectibles are applied at each hair stage. ",
        },
    }
    if GetUnitGender("player") == GENDER_MALE then
        table.insert(options,2,{
            type = "dropdown",
            name = "Facial Hair Stage (SET STYLES BELOW FIRST!!)",
            tooltip = "Select your current facial hair stage (SET STYLES BELOW FIRST!!)",
            choices = {"Shortest", "Stage 1", "Stage 2"},
            getFunc = function() return addon.saved.currentStageBeard end,
            setFunc = function(value)
                if addon.saved.currentStageBeard then
                    addon.saved.currentStageBeard = value
                    addon.SetBeardStage(value)
                else
                    d('SET STYLES FIRST!')
                end
            end ,
        })
    end
    -- Hair Stages
    for _, stage in ipairs({"Shortest", "Stage 1", "Stage 2","Tied"}) do

        if stage == "Tied" then
            table.insert(options, {
                type = "header",
                name = ""
            })
            table.insert(options, {
            type = "description",
            text = "type /hairtied to TIE or UNTIE your hair. It will swap to this preset and back to your current stage (MINIMUM 1).",
            })
        end
        local collectibleIdMap = {}
        local selectedName = ""

        local dropdownEntry = {
            type = "dropdown",
            name = stage .. " Hair Collectible",
            choices = {""}, -- placeholder, filled later
            getFunc = function() return selectedName end,
            setFunc = function(name)
                selectedName = name
                addon.saved.hairStages[stage] = collectibleIdMap[name]
            end,
            width = "full",
        }
        table.insert(options, dropdownEntry)



        zo_callLater(function()
            local newChoices = {}
            collectibleIdMap = {}

            for _, categoryData in ZO_COLLECTIBLE_DATA_MANAGER:CategoryIterator() do
                if categoryData:GetName() == "Appearance" then
                    for _, subCategoryData in categoryData:SubcategoryIterator() do
                        if subCategoryData:GetName() == "Hair Styles" then
                            for _, collectibleData in subCategoryData:CollectibleIterator() do
                                if collectibleData:IsUnlocked()
                                    and collectibleData:IsUsable(GAMEPLAY_ACTOR_CATEGORY_PLAYER)
                                    and collectibleData:IsValidForPlayer() then

                                    local name = collectibleData:GetFormattedName()
                                    collectibleIdMap[name] = collectibleData:GetId()
                                    table.insert(newChoices, name)

                                    if addon.saved.hairStages[stage] == collectibleData:GetId() then
                                        selectedName = name
                                    end
                                end
                            end
                        end
                    end
                end
            end

            dropdownEntry.choices = newChoices
            if LAM and LAM.RefreshControls then
                LAM.RefreshControls(addon.name .. "_Panel")
            end
        end, 500)
    end

    -- Beard Stages (if male)
    if GetUnitGender("player") == GENDER_MALE then
        table.insert(options, {
            type = "header",
            name = "Facial Hair",
        })
        table.insert(options, {
            type = "description",
            text = "Facial hair Styles:",
        })


        for _, stage in ipairs({"Shortest", "Short","Stage 1", "Stage 2","Stage 3"}) do
            local collectibleIdMap = {}
            local selectedName = ""

            local dropdownEntry = {
                type = "dropdown",
                name = stage .. " Facial Hair Collectible",
                choices = {""},
                getFunc = function() return selectedName end,
                setFunc = function(name)
                    selectedName = name
                    addon.saved.beardStages = addon.saved.beardStages or {}
                    addon.saved.beardStages[stage] = collectibleIdMap[name]
                end,
                width = "full",
            }

            table.insert(options, dropdownEntry)

            zo_callLater(function()
                local newChoices = {}
                collectibleIdMap = {}

                for _, categoryData in ZO_COLLECTIBLE_DATA_MANAGER:CategoryIterator() do
                    if categoryData:GetName() == "Appearance" then
                        for _, subCategoryData in categoryData:SubcategoryIterator() do
                            if subCategoryData:GetName() == "Facial Hair" then
                                for _, collectibleData in subCategoryData:CollectibleIterator() do
                                    if collectibleData:IsUnlocked()
                                        and collectibleData:IsUsable(GAMEPLAY_ACTOR_CATEGORY_PLAYER)
                                        and collectibleData:IsValidForPlayer() then

                                        local name = collectibleData:GetFormattedName()
                                        collectibleIdMap[name] = collectibleData:GetId()
                                        table.insert(newChoices, name)

                                        if addon.saved.beardStages
                                            and addon.saved.beardStages[stage] == collectibleData:GetId() then
                                            selectedName = name
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                dropdownEntry.choices = newChoices
                if LAM and LAM.RefreshControls then
                    LAM.RefreshControls(addon.name .. "_Panel")
                end
            end, 500)
        end
    end
    table.insert(options,4, {
        type = "checkbox",
        name = "Enable Humid Hair on Swim",
        tooltip = "Automatically equips collectible 'By Kyne It's Humid!!' when swimming and hair is stage 1 or longer.",
        getFunc = function() return addon.saved.enableHumidHair end,
        setFunc = function(value) addon.saved.enableHumidHair = value end,
        default = false,
    })
    LAM:RegisterAddonPanel(addon.name .. "_Panel", panel)
    LAM:RegisterOptionControls(addon.name .. "_Panel", options)
end
