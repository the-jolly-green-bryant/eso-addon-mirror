AntiDK = AntiDK or {}

-- Player tracking is now handled in AntiDK_Func.lua
-- This file is kept for legacy compatibility

AntiDK.Players = AntiDK.Players or {}
function AntiDK:OnTargetChanged(...)
    local ec, unitTag = ...
    if AntiDK.RememberTargetablePlayer then
        AntiDK:RememberTargetablePlayer(unitTag)
    end
end