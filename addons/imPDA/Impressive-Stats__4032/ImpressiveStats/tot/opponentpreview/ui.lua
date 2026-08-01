function IMP_STATS_TributeOpponentPreview_OnMoveStop(control)
    assert(control ~= nil, 'No preview control')
    local point, relativeTo, relativePoint, offsetX, offsetY = select(2, control:GetAnchor(0))

    IMP_STATS_TRIBUTE_MANAGER.settings.opponentPreview = IMP_STATS_TRIBUTE_MANAGER.settings.opponentPreview or {}
    IMP_STATS_TRIBUTE_MANAGER.settings.opponentPreview.anchor = {point, nil, relativePoint, offsetX, offsetY}
end

local function ShowEditNoteDialog()
    local name, playerType = GetTributePlayerInfo(TRIBUTE_PLAYER_PERSPECTIVE_OPPONENT)
    IMP_STATS_NOTES_MANAGER:ShowEditNoteDialog(name)
end

-- ----------------------------------------------------------------------------

function IMP_STATS_TributeOpponentPreview_NoteIcon_OnMouseEnter(control)
    local name, playerType = GetTributePlayerInfo(TRIBUTE_PLAYER_PERSPECTIVE_OPPONENT)

    local note = IMP_STATS_NOTES_MANAGER:GetNote(name)

    if note then
        ZO_Tooltips_ShowTextTooltip(control, LEFT, note)
    end
end

function IMP_STATS_TributeOpponentPreview_NoteIcon_OnMouseExit(control)
    ZO_Tooltips_HideTextTooltip()
end

function IMP_STATS_TributeOpponentPreview_NoteIcon_OnClicked(control)
    ShowEditNoteDialog()
end

-- ----------------------------------------------------------------------------

function IMP_STATS_TributeOpponentPreview_AddNoteIcon_OnMouseEnter(control)
    ZO_Tooltips_ShowTextTooltip(control, LEFT, 'Add note')
end

function IMP_STATS_TributeOpponentPreview_AddNoteIcon_OnMouseExit(control)
    ZO_Tooltips_HideTextTooltip()
end

function IMP_STATS_TributeOpponentPreview_AddNoteIcon_OnClicked(control)
    ShowEditNoteDialog()
end