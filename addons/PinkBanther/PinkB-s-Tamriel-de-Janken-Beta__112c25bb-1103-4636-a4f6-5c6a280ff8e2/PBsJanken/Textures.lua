PBJ = PBJ or {}
local Textures={legacyRoot="PBsJanken/"}
PBJ.Textures=Textures
-- Textures load asynchronously, so a candidate is retried for this many ticks
-- before the next root is tried.
local RETRY_TICKS=10
function Textures:Initialize()
    self.root=self.legacyRoot
    self.rootSource="従来パス"
    self.roots={self.legacyRoot}
    local manager=GetAddOnManager and GetAddOnManager()
    if not manager or not manager.GetAddOnRootDirectoryPath then return end
    for index=1,manager:GetNumAddOns() do
        local name=manager:GetAddOnInfo(index)
        if name=="PBsJanken" then
            local root=manager:GetAddOnRootDirectoryPath(index)
            if type(root)=="string" and root~="" then
                root=root:gsub("\\","/"):gsub("/*$","/")
                self.root=root
                self.rootSource="ゲームの格納先API"
                if root~=self.legacyRoot then self.roots={self.legacyRoot,root} end
            end
            return
        end
    end
end
function Textures:Path(name,rootIndex)
    local roots=self.roots or {self.legacyRoot}
    local root=roots[rootIndex or 1] or self.legacyRoot
    return root.."assets/"..name..".dds"
end
-- Point a texture control at an image. Repeated calls with the same name keep
-- the candidate the control is already trying.
function Textures:Apply(control,name)
    if control.pbjName==name then return end
    control.pbjName=name
    control.pbjRoot=1
    control.pbjWait=0
    control:SetTexture(self:Path(name,1))
end
-- Called while the screen is open: report whether the image is usable and move
-- on to the next candidate path when it is not.
function Textures:Poll(control,expectedSize)
    if Textures.IsUsable(control,expectedSize) then return true end
    local roots=self.roots or {self.legacyRoot}
    if not control.pbjName or #roots<2 then return false end
    control.pbjWait=(control.pbjWait or 0)+1
    if control.pbjWait<RETRY_TICKS then return false end
    control.pbjWait=0
    control.pbjRoot=(control.pbjRoot or 1)%#roots+1
    control:SetTexture(self:Path(control.pbjName,control.pbjRoot))
    return false
end
function Textures.IsUsable(control,expectedSize)
    if not control.IsTextureLoaded or not control:IsTextureLoaded() then return false end
    local width,height=control:GetTextureFileDimensions()
    return width==expectedSize and height==expectedSize
end
function Textures.Status(control,expectedSize)
    if not control.IsTextureLoaded or not control:IsTextureLoaded() then return "未読込" end
    local width,height=control:GetTextureFileDimensions()
    if expectedSize and (width~=expectedSize or height~=expectedSize) then
        return string.format("寸法不一致 %s×%s",tostring(width),tostring(height))
    end
    return string.format("読込済 %s×%s",tostring(width),tostring(height))
end
