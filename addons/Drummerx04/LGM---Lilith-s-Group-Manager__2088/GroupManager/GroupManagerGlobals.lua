-- Just an easy place to slap in things that need to be defined before other shit

LGM = {
   name = "GroupManager",
   ChatFilter = {},
   ActionResults = {
      [ACTION_RESULT_BLOCKED_DAMAGE] = "Blocked",
      [ACTION_RESULT_CRITICAL_DAMAGE] = "Crit",

      [ACTION_RESULT_DAMAGE] = "Hit",
      [ACTION_RESULT_DAMAGE_SHIELDED] = "Shielded",

      [ACTION_RESULT_DOT_TICK] = "DOT",
      [ACTION_RESULT_DOT_TICK_CRITICAL] = "DOT Crit",
      [ACTION_RESULT_FALL_DAMAGE] = "Fall",

      [ACTION_RESULT_CRITICAL_HEAL] = "Heal",
      [ACTION_RESULT_HEAL] = "Heal",
      [ACTION_RESULT_HOT_TICK] = "Heal",
      [ACTION_RESULT_HOT_TICK_CRITICAL] = "Heal",

      --[ACTION_RESULT_KILLED_BY_SUBZONE] = "KILLED_BY_SUBZONE",
      --[ACTION_RESULT_RESURRECT] = "RESURRECT",
      --[ACTION_RESULT_DIED] = "DIED",
      --[ACTION_RESULT_KILLING_BLOW] = "KILLING_BLOW",
      --[ACTION_RESULT_PRECISE_DAMAGE] = "PRECISE_DAMAGE",
      --      [ACTION_RESULT_RESIST] = "RESIST",
      --[ACTION_RESULT_WRECKING_DAMAGE] = "WRECKING_DAMAGE",
      --[ACTION_RESULT_EFFECT_DURATION_GAINED] = "Resurrect Trigger"
      --[ACTION_RESULT_BEGIN] = "Resurrect"
      --[ACTION_RESULT_EFFECT_FADED] = "Resurrect timeout"
   }
}




do
   local meta = {
      __index = {
         push = function(self, value)

            self[self.front] = value
            self.front = self.front + 1
            if not value.heal then
               self.damageCount = self.damageCount + 1
            end
            if self.damageCount > self.maxSize then
               --Remove the last
               self:pop()
               if self[self.back].heal then -- also remove an extra heal row if present
                  self:pop()
               end
            end
            local time = GetGameTimeMilliseconds()
            self.time = time
            value.time = time
         end,
         pop = function(self)
            local ret = self[self.back]
            self[self.back] = nil
            self.back = self.back + 1
            if not ret.heal then
               --decrement damageCount if row is damage
               self.damageCount = self.damageCount - 1
            end
            return ret
         end,
         trim = function(self) -- remove head/tail of queue if it is a heal row
            local row = self[self.back]
            if row and row.heal then -- trim back
               self[self.back] = nil
               self.back = self.back + 1
            end
            row = self:peek()
            if row and row.heal then -- trim front
               self[self.front - 1] = nil
               self.front = self.front - 1
            end
            row = self:peek()
            return self:size() > 0 and row and not row.heal
         end,
         ammend = function(self, newId)
            for i=1,self.shieldCount do
               local t = self[self.front - i]
               if t and t.res == ACTION_RESULT_DAMAGE_SHIELDED then
                  t.aId = newId
               end
            end
            self.shieldCount = 0
         end,
         iter = function(self, maxRows)
            local curr
            if maxRows and maxRows < self:size() then
               curr = self.front - maxRows
            else
               curr = self.back
            end
            return function()
               local ret = self[curr]
               curr = curr + 1
               return ret
            end
         end,
         size = function(self)
            return self.front - self.back
         end,
         peek = function(self)
            return self[self.front - 1]
         end

      },
   }

   function LGM.NewDamageQueue(maxSize)
      return setmetatable({front = 1, back = 1, maxSize = maxSize, damageCount = 0, shieldCount = 0}, meta)
   end

end

function LGM.SetupCharacterInfoBox(box, row, characterInfo)
   if characterInfo then
      box:ClearAnchors()
      box:SetAnchor(BOTTOM, row, TOP, 0,0)
      GetControl(box, "ClassIcon"):SetTexture(GetClassIcon(characterInfo.class) or "/esoui/art/miscellaneous/help_icon.dds")
      GetControl(box, "Name"):SetText(characterInfo.characterName or "")
      GetControl(box, "Zone"):SetText(characterInfo.formattedZone or "Unknown")
      box:SetHidden(false)
   end
end

function LGM.SetChatScan(enabled)
   if enabled then
      d("LGM: Chat Invites Active")
      EVENT_MANAGER:RegisterForEvent(LGM.name, EVENT_CHAT_MESSAGE_CHANNEL, LGM.ChatUpdate)
   else
      d("LGM: Chat Invites Disabled")
      EVENT_MANAGER:UnregisterForEvent(LGM.name, EVENT_CHAT_MESSAGE_CHANNEL)
   end
end
