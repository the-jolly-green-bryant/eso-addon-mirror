local function findPlayerNameObject(control)
    for i = 1, control:GetNumChildren() do
        local child = control:GetChild(i)

        if child:GetName():find("DisplayName") then
            return child
        end
    end
end

local function updateNameColor(control, playerData)
    local rankIndex = control.dataEntry.data.rankIndex
    if GUILD_ROSTER_MANAGER.guildId ~= Livgardet.guildId or not playerData.online or not rankIndex then
        return
    end

    local displayNameControl = findPlayerNameObject(control)

    local rankName = GetGuildRankCustomName(664190, rankIndex) or ""
    local rankColor = rankName:sub(3, 8)
    local color = ZO_ColorDef:New(rankColor)

    if (displayNameControl and color.r and color.g and color.b) then
        displayNameControl:SetColor(color:UnpackRGB())
    end
end

function Livgardet:InitializeNames()
    ZO_PostHook("ZO_SocialList_ColorRow", function(control, playerData, _, _, _)
        if self.db.colorizeNames then
            updateNameColor(control, playerData)
        end
    end)
end
