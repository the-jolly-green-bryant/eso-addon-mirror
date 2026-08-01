BGMeter = BGMeter or {}
local BGMeter = BGMeter

local Presentation = {}

local pending_show = false

function Presentation.on_player_activated()
    if not pending_show then return end
    pending_show = false
    if BGMeter.UI and BGMeter.UI.window then
        BGMeter.UI.window.show_match(1)
    end
end

function Presentation.publish(match)
    BGMeter.History.push(match)
    BGMeter.Records.evaluate(match)
    BGMeter.Session.record(match)
    if BGMeter.UI and BGMeter.UI.menu then
        BGMeter.UI.menu.refresh_if_visible()
        if BGMeter.UI.menu.mark_unread then BGMeter.UI.menu.mark_unread() end
    end

    BGMeter.Standing.request(match)

    local lr = BGMeter.Match.local_row(match)
    local F = BGMeter.Format
    BGMeter.Log.debug("%s %s -- you: %s dmg, %s heal, %d/%d/%d -- haul %s AP, %s XP",
        tostring(match.name or "Battleground"),
        tostring(match.result or ""),
        lr and F.abbrev(lr.damage) or "0",
        lr and F.abbrev(lr.healing) or "0",
        lr and lr.kills or 0, lr and lr.deaths or 0, lr and lr.assists or 0,
        F.commas(match.haul.apGained), F.commas(match.haul.xpGained))

    if match.haul.vetRankUp then BGMeter.Sound.play("rankup")
    elseif match.result == "WIN" then BGMeter.Sound.play("win")
    elseif match.result == "LOSS" then BGMeter.Sound.play("loss")
    else BGMeter.Sound.play("open") end

    local mode = BGMeter.Prefs.get("auto_open_mode")
    if mode == "instant" and BGMeter.UI and BGMeter.UI.window then
        BGMeter.UI.window.show_match(1)
    elseif mode == "exit" then
        pending_show = true
        BGMeter.Log.debug("results ready -- the window opens when you leave the battleground")
    end
end

BGMeter.Pipeline = BGMeter.Pipeline or {}
BGMeter.Pipeline.presentation = Presentation
