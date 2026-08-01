local L = CookeryWizLanguage.language

local CHAPTER_TEMPLATE_NAME = "CookeryWizChapterTemplate"

CookeryWizChapter = {}
CookeryWizChapter.book = nil
CookeryWizChapter.title = nil
CookeryWizChapter.template = nil

CookeryWizChapter.pageTemplates = {}
CookeryWizChapter.pages = {}

CookeryWizChapter.traceEnabled = false

local function trace(msg)
  if CookeryWizChapter.traceEnabled then
    CookeryWizUtils:Trace(msg)
  end
end

---------------------------------------------------------------------
-- Function: New
--
-- This function is called to create an instance of a chapter
---------------------------------------------------------------------
function CookeryWizChapter:New(book, name, title)
  o = {}
  o.book = book
  o.name = name
  o.title = title
  o.templateName = CHAPTER_TEMPLATE_NAME
  book:AddChapterTemplate(o.templateName)
  setmetatable(o, self)
  self.__index = self
  return o    
end

---------------------------------------------------------------------
-- Function: SetTemplate
--
-- This function is called to set the template used for this chapter
-- If not set then it defaults to the standard template
-- NOTE: template is an object already created via XML or in code
---------------------------------------------------------------------
function CookeryWizChapter:SetTemplate(templateName)
  self.templateName = templateName
end

---------------------------------------------------------------------
-- Function: GetTemplate
--
-- This function is called to get the template used for this chapter
---------------------------------------------------------------------
function CookeryWizChapter:GetTemplate()
  return self.templateName
end

---------------------------------------------------------------------
-- Function: GetBook
--
-- This function is called to get the book that the chapter belongs to
---------------------------------------------------------------------
function CookeryWizChapter:GetBook()
  return self.book
end

---------------------------------------------------------------------
-- Function: AddPageTemplate
--
-- This function is called to add a template used for a page
-- If the template already exists it will not be added again
---------------------------------------------------------------------
function CookeryWizChapter:AddPageTemplate(templateName)
  local found = false
  
  local pageTemplates = self.pageTemplates
  
  for i = 1, #pageTemplates do    
    if pageTemplates[i].name == templateName then
      found  = true
      break
    end
  end
  
  if not found then
    local pageTemplate = {}
    pageTemplate.name = templateName
    --pageTemplate.instance = CreateControlFromVirtual(name, parent, templateName) 
    pageTemplates[#pageTemplates + 1] = pageTemplate
  end
end


