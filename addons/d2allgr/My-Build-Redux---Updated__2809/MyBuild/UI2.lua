-- The MIT License (MIT)
-- Copyright (c) 2015 Eugene Aksenov
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.

-------------------------------------------------------------------------------
-- Helper functions for user interface
-------------------------------------------------------------------------------

MyBuild.UI2 = {}

local WM = WINDOW_MANAGER

function MyBuild.UI2.Label(text, font, parent, width, height)
    local label = WM:CreateControl("", parent, CT_LABEL)
    label:SetText(text)
    label:SetFont(font)
    if width and height then
        label:SetDimensions(width, height)
    end
    label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    return label
end

function MyBuild.UI2.Box(parent, width, height)
    local box = WM:CreateControl("", parent, CT_CONTROL)
    box:SetDimensions(width, height)
    return box
end

-- added by tenderlunar_yp
function MyBuild.UI2.Texture(parent, width, height)
    local texture = WM:CreateControl("", parent, CT_TEXTURE)
    texture:SetDimensions(width, height)
    return texture
end
-- added by tenderlunar_yp

function MyBuild.UI2.Offset(elem, x, y)
    local parent = elem:GetParent()
    elem:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    return elem
end

