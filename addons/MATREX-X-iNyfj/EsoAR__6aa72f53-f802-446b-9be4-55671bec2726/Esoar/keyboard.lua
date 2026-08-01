EsoAR = EsoAR or {}
local Esoar = EsoAR

-- Call this function from wherever you handle key input
-- Example: EsoAR:Convert(edit)
function Esoar:Convert(edit)
  -- safety checks
  if not self or not self.chat or not edit then return end
  if self.chat.editing then return end
  if langKeyboard ~= "ar" then return end

  self.chat.editing = true

  local full = edit:GetText() or ""
  if #full == 0 then
    self.chat.editing = false
    return
  end

  local text = string.sub(full, 1, -2)
  local changedText = string.sub(full, -1, -1)

  -- Arabic (101) keyboard layout mapping (QWERTY physical keys)
  if changedText == "`" then changedText = "ذ"
  elseif changedText == "~" then changedText = "ّ"

  -- Number row differences (Arabic layout swaps parentheses)
  elseif changedText == "(" then changedText = ")"
  elseif changedText == ")" then changedText = "("

  -- Top row letters
  elseif changedText == "q" then changedText = "ض"
  elseif changedText == "Q" then changedText = "َ"
  elseif changedText == "w" then changedText = "ص"
  elseif changedText == "W" then changedText = "ً"
  elseif changedText == "e" then changedText = "ث"
  elseif changedText == "E" then changedText = "ُ"
  elseif changedText == "r" then changedText = "ق"
  elseif changedText == "R" then changedText = "ٌ"
  elseif changedText == "t" then changedText = "ف"
  elseif changedText == "T" then changedText = "لإ"
  elseif changedText == "y" then changedText = "غ"
  elseif changedText == "Y" then changedText = "إ"
  elseif changedText == "u" then changedText = "ع"
  elseif changedText == "U" then changedText = "‘"
  elseif changedText == "i" then changedText = "ه"
  elseif changedText == "I" then changedText = "÷"
  elseif changedText == "o" then changedText = "خ"
  elseif changedText == "O" then changedText = "×"
  elseif changedText == "p" then changedText = "ح"
  elseif changedText == "P" then changedText = "؛"
  elseif changedText == "[" then changedText = "ج"
  elseif changedText == "{" then changedText = "<"
  elseif changedText == "]" then changedText = "د"
  elseif changedText == "}" then changedText = ">"
  -- Backslash key stays as-is (\ / |)

  -- Home row letters
  elseif changedText == "a" then changedText = "ش"
  elseif changedText == "A" then changedText = "ِ"
  elseif changedText == "s" then changedText = "س"
  elseif changedText == "S" then changedText = "ٍ"
  elseif changedText == "d" then changedText = "ي"
  elseif changedText == "D" then changedText = "]"
  elseif changedText == "f" then changedText = "ب"
  elseif changedText == "F" then changedText = "["
  elseif changedText == "g" then changedText = "ل"
  elseif changedText == "G" then changedText = "لأ"
  elseif changedText == "h" then changedText = "ا"
  elseif changedText == "H" then changedText = "أ"
  elseif changedText == "j" then changedText = "ت"
  elseif changedText == "J" then changedText = "ـ"
  elseif changedText == "k" then changedText = "ن"
  elseif changedText == "K" then changedText = "،"
  elseif changedText == "l" then changedText = "م"
  elseif changedText == "L" then changedText = "/"
  elseif changedText == ";" then changedText = "ك"
  -- ":" remains ":"
  elseif changedText == "'" then changedText = "ط"
  -- " remains "

  -- Bottom row letters
  elseif changedText == "z" then changedText = "ئ"
  elseif changedText == "Z" then changedText = "~"
  elseif changedText == "x" then changedText = "ء"
  elseif changedText == "X" then changedText = "ْ"
  elseif changedText == "c" then changedText = "ؤ"
  elseif changedText == "C" then changedText = "}"
  elseif changedText == "v" then changedText = "ر"
  elseif changedText == "V" then changedText = "{"
  elseif changedText == "b" then changedText = "لا"
  elseif changedText == "B" then changedText = "لآ"
  elseif changedText == "n" then changedText = "ى"
  elseif changedText == "N" then changedText = "آ"
  elseif changedText == "m" then changedText = "ة"
  elseif changedText == "M" then changedText = "’"
  elseif changedText == "," then changedText = "و"
  elseif changedText == "<" then changedText = ","
  elseif changedText == "." then changedText = "ز"
  elseif changedText == ">" then changedText = "."
  elseif changedText == "/" then changedText = "ظ"
  elseif changedText == "?" then changedText = "؟"
  end

  edit:SetText(text .. changedText)
  self.chat.editing = false
end
