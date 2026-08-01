local startLoadTime = GetGameTimeMilliseconds()

AOEHelper = AOEHelper or {}

-- save colors for a boss to saved variables
--[[
    bossName: string
    color = {
        enemyColor: string | nil
        enemyBrightness: number | nil
        friendlyColor: string | nil
        friendlyBrightness: number | nil
    }
]]--
function AOEHelper.SetBossColors(bossName, colors)
    if type(colors) ~= "table" then d("argument is not a table") return end

    if AOEHelper.savedVariables.savedBosses[bossName] == nil then
        AOEHelper.savedVariables.savedBosses[bossName] = {}
    end

    if colors.enemyColor ~= nil then
        AOEHelper.savedVariables.savedBosses[bossName].enemyColor = colors.enemyColor
    end
    if colors.enemyBrightness ~= nil then
        AOEHelper.savedVariables.savedBosses[bossName].enemyBrightness = colors.enemyBrightness
    end
    if colors.friendlyColor ~= nil then
        AOEHelper.savedVariables.savedBosses[bossName].friendlyColor = colors.friendlyColor
    end
    if colors.friendlyBrightness ~= nil then
        AOEHelper.savedVariables.savedBosses[bossName].friendlyBrightness = colors.friendlyBrightness
    end
end

-- get the Colors from a saved boss - if it does not exist it returns nil
--[[
    bossName: string
]]--
function AOEHelper.GetBossColors(bossName)
    if bossName == "" then return nil end
    if AOEHelper.savedVariables.savedBosses[bossName] == nil then return nil end

    local defaultColors = AOEHelper.savedVariables.defaultColors
    local bossColors = AOEHelper.savedVariables.savedBosses[bossName]

    if bossColors.enemyColor == nil then bossColors.enemyColor = defaultColors.enemyColorend end
    if bossColors.enemyBrightness == nil then bossColors.enemyBrightness = defaultColors.enemyBrightness end
    if bossColors.friendlyColor == nil then bossColors.friendlyColor = defaultColors.friendlyColor end
    if bossColors.friendlyBrightness == nil then bossColors.friendlyBrightness = defaultColors.friendlyBrightness end

    return bossColors
end

-- remove a boss from the saved variables
function AOEHelper.DeleteBossColors(bossName)
    if AOEHelper.savedVariables.savedBosses[bossName] == nil then return end
    AOEHelper.savedVariables.savedBosses[bossName] = nil
end


local endLoadTime = GetGameTimeMilliseconds()
AOEHelper.loadTime = AOEHelper.loadTime + (endLoadTime - startLoadTime)