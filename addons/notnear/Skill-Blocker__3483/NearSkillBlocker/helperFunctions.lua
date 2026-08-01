local addon = NEAR_SB
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

function NEAR_SB.AddMessage(message)
	local prefix = string.format('%s%s %s', addon.shortTitle, ':', "|cFFFFFF")
	CHAT_SYSTEM:AddMessage(string.format('%s%s', prefix, message))
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Slash command functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
NEAR_SB.slash_commands = {}

function NEAR_SB.slash_commands.suppressBlock()
	local sv = NEAR_SB.ASV
	local cmdMessageType = sv.cmdMessageType

	local str = { GetString(NEARSB_suppressblock_enabled), GetString(NEARSB_suppressblock_disabled) }

	sv.suppressBlock = not sv.suppressBlock

	if cmdMessageType == 1 then
		addon.AddMessage(str[sv.suppressBlock and 1 or 2])
	elseif cmdMessageType == 2 then
		local sound = sv.cmdMessageSound and SOUNDS.GENERAL_ALERT_ERROR or nil
		ZO_Alert(UI_ALERT_CATEGORY_ALERT, sound, str[sv.suppressBlock and 1 or 2])
	end
end

function NEAR_SB.slash_commands.blockPvP()
	local sv = NEAR_SB.ASV
	local cmdMessageType = sv.cmdMessageType

	local str = { GetString(NEARSB_blockpvp_enabled), GetString(NEARSB_blockpvp_disabled) }

	sv.blockPvP = not sv.blockPvP

	if cmdMessageType == 1 then
		addon.AddMessage(str[sv.blockPvP and 1 or 2])
	elseif cmdMessageType == 2 then
		local sound = sv.cmdMessageSound and SOUNDS.GENERAL_ALERT_ERROR or nil
		ZO_Alert(UI_ALERT_CATEGORY_ALERT, sound, str[sv.blockPvP and 1 or 2])
	end
end

function NEAR_SB.RegisterSlashCommands()
	-- suppressBlock
	SLASH_COMMANDS["/sb/suppressblock"] = addon.slash_commands.suppressBlock
	-- blockPvP
	SLASH_COMMANDS["/sb/blockpvp"] = addon.slash_commands.blockPvP
end
