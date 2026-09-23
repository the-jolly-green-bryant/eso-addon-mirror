-- Console packages require explicit manifest entries, legacy DXT5 textures and add-on paths.
-- Try the stable manifest-relative path first, then the manager-provided root as a fallback.
local A={legacyRoot="PBsTradeGame/",retryTicks=10,controls=setmetatable({},{__mode="k"})}
A.sizes={coin={128,64},coin_plinth={512,128},treasury={2048,1024},crest={256,256},
    atlas={1024,1024},wood_frame={512,256},band_glow={128,32},band_tip_left={128,32},band_tip_right={128,32},
    chapter_1={1024,512},chapter_2={1024,512},chapter_3={1024,512},chapter_4={1024,512},chapter_5={1024,512}}
PBTrade.Assets=A
function A.Initialize()
    A.roots={A.legacyRoot}
    local manager=GetAddOnManager and GetAddOnManager()
    if manager and manager.GetAddOnRootDirectoryPath then
        for i=1,manager:GetNumAddOns() do
            if manager:GetAddOnInfo(i)==PBTrade.Config.addonId then
                local root=manager:GetAddOnRootDirectoryPath(i)
                if type(root)=="string" and root~="" then
                    root=root:gsub("\\","/"):gsub("/+$","").."/"
                    if root~=A.legacyRoot then A.roots[#A.roots+1]=root end
                end
                break
            end
        end
    end
end
function A.Path(name,index) return (A.roots or {A.legacyRoot})[index or 1].."assets/"..name..".dds" end
function A.Apply(control,name)
    control.pbtradeAsset=name; control.pbtradeRoot=1; control.pbtradeTicks=0; control.pbtradeDone=false
    control.pbtradeExpected=A.sizes[name]
    control:SetTexture(A.Path(name,1)); A.controls[control]=true
end
function A.IsUsable(control)
    if not control.IsTextureLoaded or not control:IsTextureLoaded() then return false end
    local expected=A.sizes[control.pbtradeAsset]
    if not expected or not control.GetTextureFileDimensions then return true end
    local width,height=control:GetTextureFileDimensions()
    return width==expected[1] and height==expected[2]
end
function A.Poll(control)
    if control.pbtradeDone then return end
    if A.IsUsable(control) then control.pbtradeDone=true; return end
    control.pbtradeTicks=control.pbtradeTicks+1
    if control.pbtradeTicks<A.retryTicks then return end
    control.pbtradeTicks=0
    if control.pbtradeRoot<#(A.roots or {A.legacyRoot}) then
        control.pbtradeRoot=control.pbtradeRoot+1
        control:SetTexture(A.Path(control.pbtradeAsset,control.pbtradeRoot))
    else control.pbtradeDone=true end
end
function A.PollAll()
    for control in pairs(A.controls) do A.Poll(control) end
end
return A
