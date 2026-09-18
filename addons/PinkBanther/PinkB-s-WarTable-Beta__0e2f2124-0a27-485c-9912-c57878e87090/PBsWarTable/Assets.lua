-- Explicit manifest entries are required as well as runtime texture paths.
local A={legacyRoot="PBsWarTable/",names={"soldier","scout","guardian"},size=128,retryTicks=10}
A.sizes={elder_scroll={256,256},alliance_dominion={256,256},alliance_covenant={256,256},alliance_pact={256,256},board_material={1024,1024},war_room={1024,512},frame={256,128},soldier_wood={256,256},scout_wood={256,256},guardian_wood={256,256},card_material={512,128},button_material={512,128}}
PBWT.Assets=A
function A.Initialize()
    A.roots={A.legacyRoot}
    local manager=GetAddOnManager and GetAddOnManager()
    if manager and manager.GetAddOnRootDirectoryPath then
        for i=1,manager:GetNumAddOns() do
            if manager:GetAddOnInfo(i)=="PBsWarTable" then
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
function A.PieceKind(kind)
    local full=PBWT.Records and PBWT.Records.Data().presentation=='full'
    return full and (kind..'_wood') or kind
end
function A.Path(kind,index) return (A.roots or {A.legacyRoot})[index or 1].."assets/"..kind..".dds" end
function A.IsUsable(control)
    if not control.IsTextureLoaded or not control:IsTextureLoaded() then return false end
    local w,h=control:GetTextureFileDimensions()
    local size=A.sizes[control.pbwtKind]
    return w==(size and size[1] or A.size) and h==(size and size[2] or A.size)
end
function A.Apply(control,kind,retry)
    if control.pbwtKind==kind and not retry then return end
    control.pbwtKind,control.pbwtRoot,control.pbwtTicks,control.pbwtDone=kind,1,0,false
    control:SetHidden(true)
    control:SetTexture(A.Path(kind,1))
end
function A.Poll(control)
    if A.IsUsable(control) then control.pbwtDone=true; return true,true end
    if control.pbwtDone then return false,true end
    control.pbwtTicks=control.pbwtTicks+1
    if control.pbwtTicks>=A.retryTicks then
        control.pbwtTicks=0
        if control.pbwtRoot<#(A.roots or {A.legacyRoot}) then
            control.pbwtRoot=control.pbwtRoot+1
            control:SetTexture(A.Path(control.pbwtKind,control.pbwtRoot))
        else control.pbwtDone=true end
    end
    return false,control.pbwtDone
end
