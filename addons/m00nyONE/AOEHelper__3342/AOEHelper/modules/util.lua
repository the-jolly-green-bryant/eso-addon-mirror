local startLoadTime = GetGameTimeMilliseconds()
AOEHelper = AOEHelper or {}

function AOEHelper.filterName(unfiltered)
    local i, _ = string.find(unfiltered, "%^")
    if i == nil then
        return unfiltered
    end
    return string.sub(unfiltered, 1, i-1)
end

-- donate to me if you want to
function AOEHelper.donate()
    -- show message window
    SCENE_MANAGER:Show('mailSend')
    -- wait 200 ms async
    zo_callLater(
            function()
                -- fill out messagebox
                ZO_MailSendToField:SetText("@m00nyONE")
                ZO_MailSendSubjectField:SetText("Donation for AOEHelper")
                QueueMoneyAttachment(1)
                ZO_MailSendBodyField:TakeFocus()
            end,
            200)
end

-- get boss name
function AOEHelper.GetBossName()
    local bossName = ""
    for i = 1, MAX_BOSSES do
        bossName = GetUnitName("boss" .. i)
        if bossName ~= "" then break end
    end
    return bossName
end

local endLoadTime = GetGameTimeMilliseconds()
AOEHelper.loadTime = AOEHelper.loadTime + (endLoadTime - startLoadTime)