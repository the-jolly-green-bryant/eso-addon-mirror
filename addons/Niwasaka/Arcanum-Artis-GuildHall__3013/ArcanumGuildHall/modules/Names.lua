local ArcanumGuildHall = _G["ArcanumGuildHall"]

local function findPlayerNameObject(control)
    if not control then
        return nil
    end

    for i = 1, control:GetNumChildren() do
        local child = control:GetChild(i)
        if child then
            local childName = child:GetName()
            if childName and childName:find("DisplayName") then
                return child
            end
        end
    end

    return nil
end

local function updateNameColor(control, playerData)
    local data = control and control.dataEntry and control.dataEntry.data
    local rankIndex = data and data.rankIndex

    if GUILD_ROSTER_MANAGER.guildId ~= ArcanumGuildHall.guildId or not playerData or not playerData.online or not rankIndex then
        return
    end

    local displayNameControl = findPlayerNameObject(control)
    if not displayNameControl then
        return
    end

    local rankName = GetGuildRankCustomName(ArcanumGuildHall.guildId, rankIndex) or ""
    local rankColor = rankName:match("|c(%x%x%x%x%x%x)")
    if not rankColor then
        return
    end

    local color = ZO_ColorDef:New(rankColor)
    if color and color.r and color.g and color.b then
        displayNameControl:SetColor(color:UnpackRGB())
    end
end

function ArcanumGuildHall:InitializeNames()
    if self.namesHookRegistered then
        return
    end
    self.namesHookRegistered = true

    ZO_PostHook("ZO_SocialList_ColorRow", function(control, playerData, ...)
        if self.db.colorizeNames then
            updateNameColor(control, playerData)
        end
    end)
end