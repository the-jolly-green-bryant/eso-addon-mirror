local STZ = SUGAS_TEST_ZONE
STZ.Notice = STZ.Notice or {}
local Notice = STZ.Notice

function Notice:ShowDenied(projectName)
    local name = tostring(projectName or "This project")
    local soundId = SOUNDS ~= nil and SOUNDS.NEGATIVE_CLICK or nil

    if type(ZO_Alert) == "function" then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, soundId,
            string.format("%s is locked to approved testers.", name))
    end

    STZ:Log(string.format(
        "[STZ] %s is locked. Follow %s for the stable Release Candidate (%s), or wait for the official release of version %s.",
        name,
        tostring(STZ.Config.notice.authorName),
        tostring(STZ.Config.notice.releaseCandidateText),
        tostring(STZ.Config.notice.stableReleaseText)
    ))
end
