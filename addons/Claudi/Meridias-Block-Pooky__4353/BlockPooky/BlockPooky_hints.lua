--[[ basic initialization -------------------------------------------------------------------------------------------]]
BlockPooky = BlockPooky or {}
local BlockPooky = BlockPooky

BlockPooky.lastDcCast = 0
BlockPooky.lastRoaCast = 0
BlockPooky.lastVigorCast = 0

--[[ hints implementation -------------------------------------------------------------------------------------------]]

function BlockPooky.DcReadyHint(gameTimeMs)
    if BlockPooky.config.dcHint then
        if BlockPooky.lastDcCast ~=0 and gameTimeMs - BlockPooky.lastDcCast > 25000 then
            BlockPooky.lastDcCast = 0
            BlockPooky.MessageThePooky(BlockPooky.config.messages.dcReady)
        end
    end
end

function BlockPooky.RoaReadyHint(gameTimeMs)
    if BlockPooky.config.roaHint then
        if BlockPooky.lastRoaCast ~=0 and gameTimeMs - BlockPooky.lastRoaCast > 8000 then
            BlockPooky.lastRoaCast = 0
            BlockPooky.MessageThePooky(BlockPooky.config.messages.roaReady)
        end
    end
end

local vigorHint_active=false
function BlockPooky.UpdateCastVigorHint(gameTimeMs)
    if BlockPooky.config.vigorHint then
        if BlockPooky.lastVigorCast ~=0 then
            local lastCastTimeMs = gameTimeMs - BlockPooky.lastVigorCast
            if vigorHint_active then
                if lastCastTimeMs > 20000 then
                    vigorHint_active = false
                    VigorIndicator:SetHidden(not BlockPooky.config.lockedUI)
                    BlockPooky.lastVigorCast = 0
                elseif lastCastTimeMs > 12000 then
                    vigorHint_active = false
                    VigorIndicator:SetHidden(not BlockPooky.config.lockedUI)
                end
            else
                if lastCastTimeMs >= 16000 then
                    vigorHint_active = true
                    VigorIndicator:SetHidden(false)
                elseif lastCastTimeMs >= 8000 then
                    vigorHint_active = true
                    VigorIndicator:SetHidden(false)
                end
            end
        elseif vigorHint_active then
            vigorHint_active = false
            VigorIndicator:SetHidden(not BlockPooky.config.lockedUI)
        end
    elseif vigorHint_active then
        vigorHint_active = false
        VigorIndicator:SetHidden(not BlockPooky.config.lockedUI)
    end
end

function BlockPooky.OnVigorIndicatorMoveStop()
    BlockPooky.config.vigorUI.left = VigorIndicator:GetLeft()
    BlockPooky.config.vigorUI.top = VigorIndicator:GetTop()
end

function BlockPooky.ResetHintsPosition()
    if VigorIndicator:GetAnchor() ~= nil then
        VigorIndicator:ClearAnchors()
    end
    VigorIndicator:SetAnchor(BOTTOM, GuiRoot, CENTER, 0, 0)
    BlockPooky.OnVigorIndicatorMoveStop()
end

function BlockPooky.RestoreHintsPosition()
    -- vigorHint
    left = BlockPooky.config.vigorUI.left
    top = BlockPooky.config.vigorUI.top
    if (left ~= nil and top ~= nil and left > 0 and top > 0) then
        if VigorIndicator:GetAnchor() ~= nil then
            VigorIndicator:ClearAnchors()
        end
        VigorIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    else
        BlockPooky.ResetHintsPosition()
    end
end

function BlockPooky.SetVigorHintColor()
    if BlockPooky.config.vigorUI.color~=nil then
        VigorIndicatorLabel:SetColor(unpack(BlockPooky.config.vigorUI.color))
    end
end