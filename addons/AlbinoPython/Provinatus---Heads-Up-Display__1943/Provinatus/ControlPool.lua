-- TODO this smells bad. Should prolly use Zos object pool
ProvinatusControlPool = ZO_Object:Subclass()

function ProvinatusControlPool:New(...)
  self.Active = 0
  self.Controls = {}
  return ZO_Object.New(self)
end

function ProvinatusControlPool:GetControl()
  self.Active = self.Active + 1
  if not self.Controls[self.Active] then
    self.Controls[self.Active] = WINDOW_MANAGER:CreateControl(nil, Provinatus.TopLevelWindow, CT_TEXTURE)
  end

  return self.Controls[self.Active]
end

function ProvinatusControlPool:ClearInactive()
  for i = self.Active + 1, #self.Controls do
    if self.Controls[i] and self.Controls[i]:GetAlpha() ~= 0 then
      self.Controls[i]:SetAlpha(0)
      if self.Controls[i].AnimationControl then
        self.Controls[i].AnimationControl:SetAlpha(0)
      end
    end
  end

  self.Active = 0
end
