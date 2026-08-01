-- Initialize RG table if not already done
local RG = _G["RoseGuilds"] or {}
_G["RoseGuilds"] = RG

-- Don't load on NA
if GetWorldName() == "NA Megaserver" then return end

-- Create Icons table
RG.Icons = {}
RG.Icons.playerIcons = {}
RG.Icons.texturePriorities = {}

local function NormalizeIconPriority(priority)
    if type(priority) == "number" then
        return priority
    end

    return 0
end

local function GetDefaultTexturePriority(self, texturePath)
    if self.texturePriorities and texturePath then
        local texturePriority = self.texturePriorities[texturePath]
        if type(texturePriority) == "number" then
            return texturePriority
        end
    end

    return 0
end

function RG.Icons:AddPlayerIcon(username, texturePath, priority)
    if type(username) ~= "string" or username == "" then
        return
    end
    if type(texturePath) ~= "string" or texturePath == "" then
        return
    end

    self.playerIcons[username] = {
        texturePath = texturePath,
        priority = NormalizeIconPriority(priority) + GetDefaultTexturePriority(self, texturePath),
    }
end

function RG.Icons:SetTexturePriority(texturePath, priority)
    if texturePath then
        self.texturePriorities[texturePath] = NormalizeIconPriority(priority)
    end
end

function RG.Icons:GetPlayerIconData(username)
    return self.playerIcons[username]
end

function RG.Icons:GetPlayerIcon(username)
    local iconData = self.playerIcons[username]
    if type(iconData) == "table" then
        return iconData.texturePath
    end

    return iconData
end

function RG.Icons:GetPlayerIconWithPriority(username)
    local iconData = self.playerIcons[username]
    if type(iconData) == "table" then
        return iconData.texturePath, NormalizeIconPriority(iconData.priority)
    end

    if type(iconData) == "string" then
        return iconData, 0
    end

    return nil, nil
end

function RG.Icons:GetStatic(username)
    return self:GetPlayerIcon(username)
end

function RG.Icons:ShowIconAboveHead(username, control)
    if not RG or not RG.savedVars then return end
    if not RG.savedVars.IconAboveHeadVisible then
        control:SetHidden(true)
        return
    end
    local iconPath = self:GetPlayerIcon(username)
    if iconPath then
        control:SetTexture(iconPath)
        control:SetDimensions(RG.savedVars.IconAboveHeadSize, RG.savedVars.IconAboveHeadSize)
        control:SetHidden(false)
    else
        control:SetHidden(true)
    end
end

function RG.Icons:HasPlayerIcon(username)
    return self.playerIcons[username] ~= nil
end

function RG.Icons:HasStatic(username)
    return self:HasPlayerIcon(username)
end

function RG.Icons:GetAllPlayerIcons()
    local icons = {}
    for username, iconData in pairs(self.playerIcons) do
        if type(iconData) == "table" then
            icons[username] = iconData.texturePath
        else
            icons[username] = iconData
        end
    end

    return icons
end

_G["RoseGuilds_Icons"] = RG.Icons

return RG.Icons
