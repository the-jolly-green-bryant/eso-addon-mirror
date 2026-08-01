
ImmersiveHair = {}
local addon = ImmersiveHair
addon.name = "ImmersiveHair"
addon.version = "1.0"
addon.saved = {}
HAIRGROW_MESSAGES = {
    "You feel the days passing by...",
}
BEARDGROW_MESSAGES = {
    "You feel your chin iching...",
}
local HAIR_STAGES = {"Shortest", "Stage 1", "Stage 2"}
local BEARD_STAGES = {"Shortest","Short", "Stage 1", "Stage 2", "Stage 3"}
function GetRandomHairPassBy()
  return HAIRGROW_MESSAGES[math.random(1, #HAIRGROW_MESSAGES)]
end
function GetRandomBeardPassBy()
  return BEARDGROW_MESSAGES[math.random(1, #BEARDGROW_MESSAGES)]
end
function addon.ApplyHairStage(stage)
    if stage == "Humid" then
        UseCollectible(524)
    elseif stage == "Tied" then
        UseCollectible(addon.saved.hairStages['Tied'])
    else
        local collectibleId = addon.saved.hairStages[stage]
        if collectibleId then
            UseCollectible(collectibleId)
        end
    end

end
function addon.ApplyBeardStage(stage)
    local collectibleId = addon.saved.beardStages[stage]
    if collectibleId then
        UseCollectible(collectibleId)
    end
end

function addon.SetHairStage(stage)
    addon.saved.currentStage = stage
    addon.saved.lastChanged = GetTimeStamp()
    addon.ApplyHairStage(stage)
end

function addon.SetBeardStage(stage)
    if GetUnitGender("player") == GENDER_MALE then
        addon.saved.currentStageBeard = stage
        addon.saved.lastChangedBeard = GetTimeStamp()
        addon.ApplyBeardStage(stage)
    end
end
function addon.CheckBeardGrowth()
    local last = addon.saved.lastChangedBeard or 0
    local now = GetTimeStamp()
    local growthTime = addon.saved.beardTime or 30
    local delta = now - last
    --d("BEARD: ".. tostring(delta) .."//".. tostring(growthTime  * 30 ))
    local stage = addon.saved.currentStageBeard or "Shortest"
    local idx = 0
    for i, s in ipairs(BEARD_STAGES) do
        if s == stage then
            idx = i
            break
        end
    end

    if idx < #BEARD_STAGES and delta >= growthTime * 30 then
        addon.SetBeardStage(BEARD_STAGES[idx + 1])

        --d(string.format("[Immersive Hair] Hair grew to %s", HAIR_STAGES[idx + 1]))
	ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, GetRandomBeardPassBy())
    end
end
local swimmingState = false

local function CheckSwimming()
    local currentlySwimming = IsUnitSwimming("player")
    if currentlySwimming and not swimmingState then
        --d("[ImmersiveHair] Player is now swimming")

        if addon.saved.enableHumidHair then
            local stage = addon.saved.currentStage
            if stage ~= "Shortest" then
                addon.ApplyHairStage("Humid")
            end
        end
    elseif not currentlySwimming and swimmingState then
        --d("[ImmersiveHair] Player stopped swimming")
    end
    swimmingState = currentlySwimming
end
local function StartSwimmingMonitor()
    EVENT_MANAGER:UnregisterForUpdate("ImmersiveHairSwimmingCheck")
    EVENT_MANAGER:RegisterForUpdate("ImmersiveHairSwimmingCheck", 1000, CheckSwimming) -- every 1 sec
end



function addon.CheckHairGrowth()

    local last = addon.saved.lastChanged or 0
    local now = GetTimeStamp()
    local growthTime = addon.saved.growthTime or 60
    local delta = now - last
    --d("HAIR: ".. tostring(delta) .."//".. tostring(growthTime  * 60 ))
    local stage = addon.saved.currentStage or "Shortest"
    local idx = 0
    for i, s in ipairs(HAIR_STAGES) do
        if s == stage then
            idx = i
            break
        end
    end
    --d(tostring(delta) .. "//" .. tostring(growthTime * 60))
    if idx < #HAIR_STAGES and delta >= growthTime * 60 then
        addon.SetHairStage(HAIR_STAGES[idx + 1])
        --d(string.format("[Immersive Hair] Hair grew to %s", HAIR_STAGES[idx + 1]))
	ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, GetRandomHairPassBy())
    end
end
local HAIR_TIED = false
SLASH_COMMANDS["/beardshave"] = function()
    addon.SetBeardStage("Shortest")
    d("[Immersive Hair] You've shaved your beard.")
end
SLASH_COMMANDS["/beardtrim"] = function()
    if addon.saved.currentStageBeard == "Shortest" then
        d("[Immersive Hair] Your facial hair is already too short!")
    elseif addon.saved.currentStageBeard == "Short" then
        addon.SetBeardStage("Shortest")
        d("[Immersive Hair] You've trimmed your facial hair.")
    elseif addon.saved.currentStageBeard == "Stage 1" then
        addon.SetBeardStage("Short")
        d("[Immersive Hair] You've trimmed your facial hair.")
    elseif addon.saved.currentStageBeard == "Stage 2" then
        addon.SetBeardStage("Stage 1")
        d("[Immersive Hair] You've trimmed your facial hair.")
    elseif addon.saved.currentStageBeard == "Stage 3" then
        addon.SetBeardStage("Stage 2")
        d("[Immersive Hair] You've trimmed your facial hair.")
    end


end
SLASH_COMMANDS["/beardlongest"] = function()
    addon.SetBeardStage("Stage 3")
    d("[Immersive Hair] You hair is longer now.")
end
SLASH_COMMANDS["/haircomb"] = function()
    addon.ApplyHairStage(addon.saved.currentStage)
end
SLASH_COMMANDS["/hairtied"] = function()
    if HAIR_TIED then
        addon.ApplyHairStage(addon.saved.currentStage)
        HAIR_TIED = false
    else
        d(addon.saved.currentStage)
        if addon.saved.currentStage ~= "Shortest" then
            addon.ApplyHairStage('Tied')
            HAIR_TIED = true
        elseif addon.saved.currentStage ~= "Shortest" then
            d('[Immersive Hair] Your Hair is too short to be tied!')
        end

    end
end
SLASH_COMMANDS["/haircut"] = function()
    addon.SetHairStage("Shortest")
    d("[Immersive Hair] You've cut your hair.")
end
SLASH_COMMANDS["/hairtrim"] = function()
    if addon.saved.currentStage == "Shortest" then
        d("[Immersive Hair] Your hair is already too short!")
    elseif addon.saved.currentStage == "Stage 1" then
        addon.SetHairStage("Shortest")
        d("[Immersive Hair] Your trimmed your hair.")
    elseif addon.saved.currentStage == "Stage 2" then
        addon.SetHairStage("Stage 1")
        d("[Immersive Hair] Your trimmed your hair.")
    --elseif addon.saved.currentStage == "Stage 3" then
    --    addon.SetHairStage("Stage 2")
    --    d("[Immersive Hair] Your trimmed your hair.")
    end
end
SLASH_COMMANDS["/hairlongest"] = function()
    addon.SetHairStage("Stage 2")
    addon.saved.currentStage = "Stage 2"
    d("[Immersive Hair] You hair is longer now.")
end
SLASH_COMMANDS["/showhair"] = function()
    if not ZO_COLLECTIBLE_DATA_MANAGER then
        d("[ImmersiveHair]  ZO_COLLECTIBLE_DATA_MANAGER not available.")
        return
    end

    d("[ImmersiveHair]  Unlocked Hair Styles:")
    local count = 0

    for _, categoryData in ZO_COLLECTIBLE_DATA_MANAGER:CategoryIterator() do
        if categoryData:GetName() == "Appearance" then
            for _, subCategoryData in categoryData:SubcategoryIterator() do
                if subCategoryData:GetName() == "Hair Styles" then
                    for _, collectibleData in subCategoryData:CollectibleIterator() do
                        if collectibleData:IsUnlocked() then
                            local name = collectibleData:GetFormattedName()
                            local id = collectibleData:GetId()
                            d(string.format("• %s (ID: %d)", name, id))
                            count = count + 1
                        end
                    end
                end
            end
        end
    end

    if count == 0 then
        d("[ImmersiveHair]  No unlocked hair styles found.")
    else
        d(string.format("[ImmersiveHair] %d hair styles listed.", count))
    end
end
local function OnLoad(_, addonName)
    if addonName ~= addon.name then return end
    f_hair = {
        ["Stage 1"] = 542,
        ["Stage 2"] = 543,
        ["Shortest"] = 519,
        ["Tied"] = 544,

    }
    m_hair = {
        ["Shortest"] = 576,
        ["Stage 1"] = 582,
        ["Stage 2"] = 583,
        ["Tied"] = 578,
    }
    local hs = f_hair
    if GetUnitGender("player") == GENDER_MALE then
        hs = m_hair
    end
    addon.saved = ZO_SavedVars:NewCharacterIdSettings("ImmersiveHair_SavedVariables", 1, nil, {
        currentStage = "Shortest",
        currentStageBeard = "Shortest",
        lastChanged = GetTimeStamp(),
        lastChangedBeard = GetTimeStamp(),
        growthTime = 60,
        beardTime = 30,
        hairStages = hs,
        beardStages = {
            ["Shortest"] = 622,
            ["Short"] = 706,
            ["Stage 1"] = 698,
            ["Stage 2"] = 717,
            ["Stage 3"] = 660,
        }
    })

    for _, stage in ipairs(HAIR_STAGES) do
        addon.saved.hairStages[stage] = addon.saved.hairStages[stage] or nil
    end


    EVENT_MANAGER:RegisterForUpdate(addon.name .. "_HairGrowth", addon.saved.growthTime*1000, addon.CheckHairGrowth)
    if GetUnitGender("player") == GENDER_MALE then
        EVENT_MANAGER:RegisterForUpdate(addon.name .. "_BeardGrowth", addon.saved.beardTime*1000, addon.CheckBeardGrowth)
    end

    StartSwimmingMonitor()
    addon.LoadSettings()
end

EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnLoad)