local L = CookeryWizLanguage.language

CookeryWizPage = {}
CookeryWizPage.chapter = nil
CookeryWizPage.title = nil
CookeryWizPage.templateName = nil

CookeryWizPage.traceEnabled = false

local function trace(msg)
  if CookeryWizPage.traceEnabled then
    CookeryWizUtils:Trace(msg)
  end
end

---------------------------------------------------------------------
-- Function: New
--
-- This function is called to create an instance of a page
---------------------------------------------------------------------
function CookeryWizPage:New(chapter, title)
  o = {}
  o.chapter = chapter
  o.title = title
  o.templateName = "CookeryWizPageTemplate"
  chapter:AddPageTemplate(o.templateName)
  setmetatable(o, self)
  self.__index = self
  return o    
end

---------------------------------------------------------------------
-- Function: GetChapter
--
-- This function is called to get the chapter that the page belongs to
---------------------------------------------------------------------
function CookeryWizPage:GetChapter()
  return self.chapter
end

---------------------------------------------------------------------
-- Function: SetTemplate
--
-- This function is called to set the template used for this chapter
-- If not set then it defaults to the standard template
-- NOTE: template is an object already created via XML or in code
---------------------------------------------------------------------
function CookeryWizPage:SetTemplate(templateName)
  self.templateName = templateName
  self.chapter:AddPageTemplate(templateName)
end

---------------------------------------------------------------------
-- Function: GetTemplate
--
-- This function is called to get the template used for this chapter
---------------------------------------------------------------------
function CookeryWizPage:GetTemplate()
  return self.templateName
end