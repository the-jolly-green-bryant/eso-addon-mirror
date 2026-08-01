ProvinatusPinIterator = ZO_Object:Subclass()

function ProvinatusPinIterator:New(...)
  self.PinHandlers = {}
  self.PostProcessors = {}
  self.Icons = {}
  self.DisplaySettings = Provinatus.SavedVars.Display
  self.ControlPool = ProvinatusControlPool:New()
  return ZO_Object.New(self)
end

function ProvinatusPinIterator:AddPinTypeHandler(PinType, Handler)
  self.PinHandlers[PinType] = Handler
end

function ProvinatusPinIterator:AddPostProcessor(PinType, PostProcessor)
  self.PostProcessors[PinType] = PostProcessor
end

function ProvinatusPinIterator:Update()
  local Elements = {}
  for _, Data in ZO_WorldMap_GetPinManager():ActiveObjectIterator(
    {
      [1] = function(CurrentData)
        local X = CurrentData.normalizedX
        local Y = CurrentData.normalizedY
        return X >= 0 and X <= 1 and Y >= 0 and Y <= 1 and self.PinHandlers[CurrentData.m_PinType]
      end
    }
  ) do
    if self.PinHandlers[Data.m_PinType] then
      local Element = self.PinHandlers[Data.m_PinType](Data)
      if Element then
        Element.Data = Data
        table.insert(Elements, Element)
      end
    end
  end

  for Element, Icon in pairs(self:DrawIcons(Elements)) do
    if self.PostProcessors[Element.Data.m_PinType] then
      self.PostProcessors[Element.Data.m_PinType](Element, Icon)
    end
  end
end

function ProvinatusPinIterator:DrawIcons(Elements)
  local RenderedElements = {}
  for i = 1, #Elements do
    local Element = Elements[i]
    local Projection = Provinatus.Projection:Project(Element.X, Element.Y)
    Element.Projection = Projection

    local Icon = self.ControlPool:GetControl()
    if not self.DisplaySettings.ShowDistant and Projection.DistanceM >= self.DisplaySettings.MaxDistance then
      Icon:SetAlpha(0)
    elseif self.DisplaySettings.Fade then
      Icon:SetAlpha(Provinatus:Fade(Projection.Distance))
    else
      Icon:SetAlpha(Element.Alpha)
    end

    Icon:SetAnchor(CENTER, Provinatus.TopLevelWindow, CENTER, Projection.XProjected, Projection.YProjected)
    Icon:SetDimensions(Element.Size, Element.Size)
    Icon:SetTexture(Element.Texture)
    RenderedElements[Element] = Icon
  end

  self.ControlPool:ClearInactive()
  return RenderedElements
end
