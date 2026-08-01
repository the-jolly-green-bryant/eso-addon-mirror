SMUI = {}

local TLW = nil

local function Create_Main_Container()
	SMBuilder.BuildContainer(MAIN_CONTAINER, TLW, MAIN_WIDTH, MAIN_WIDTH, ANCHOR_CENTER, ANCHOR_CENTER)
end

local function Create_Speed_CoolDown()
	local Parent = GetControl(MAIN_CONTAINER)
	SMBuilder.BuildCoolDown("SM_SpeedCoolDown", Parent, "speedcircle.dds", 3.14159, MAIN_WIDTH)
	SMBuilder.BuildSquareTexture("SM_SpeedCover", Parent, "coverimage.dds", MAIN_WIDTH)
end

local function Create_Speed_Container()
	local Parent = GetControl(MAIN_CONTAINER)
	local Width = 0.55 * MAIN_WIDTH
	local Container = SMBuilder.BuildContainer(SPEED_CONTAINER, Parent, Width, MAIN_WIDTH / 2, ANCHOR_BOTTOM, ANCHOR_CENTER)
	local LblWidth = Width - 30
	local Lbl = SMBuilder.BuildSpeedLabel("SM_Speed_Label", COLOR_WHITE, Container, LblWidth, 40)
	SMBuilder.BuildSpeedUnitLabel("SM_Speed_Unit_Label", COLOR_WHITE, Lbl)
end

local function Create_Data_Container()
	SMBuilder.BuildContainer(DATA_CONTAINER, 	GetControl(MAIN_CONTAINER), MAIN_WIDTH, 		MAIN_WIDTH / 2, 		ANCHOR_TOP, ANCHOR_CENTER)
	SMBuilder.BuildContainer(TITLE_CONTAINER, 	GetControl(DATA_CONTAINER), MAIN_WIDTH, 		MAIN_WIDTH * .25 / 2, 	ANCHOR_TOP, ANCHOR_TOP)
	SMBuilder.BuildContainer(PEAK_CONTAINER, 	GetControl(DATA_CONTAINER), MAIN_WIDTH * .35, 	MAIN_WIDTH * .75 / 2, 	ANCHOR_BOTTOM_LEFT, ANCHOR_BOTTOM_LEFT)
	SMBuilder.BuildContainer(MID_CONTAINER, 	GetControl(PEAK_CONTAINER), MAIN_WIDTH * .65, 	MAIN_WIDTH * .75 / 2, 	ANCHOR_LEFT, ANCHOR_RIGHT)
end

local function Create_Title_Components()
	local Container = GetControl(TITLE_CONTAINER)
	local Width, Height = Container:GetWidth(), Container:GetHeight() - 10
	local Title = SMBuilder.BuildLabel("SM_Title_Label", "Speedometer", COLOR_CARIBBEAN, Container, Width, Height, ANCHOR_TOP, ANCHOR_TOP, 14, TEXT_ALIGN_CENTER)
	SMBuilder.BuildDivider("SM_Title_Divider", Title, Width * 0.9)
end

local function Create_Peak_Components()
	local Container = GetControl(PEAK_CONTAINER)
	local Width = Container:GetWidth()
	SMBuilder.BuildLabel("SM_Max_Label", "Max", COLOR_WHITE, Container, Width, 15, ANCHOR_TOP, ANCHOR_TOP, 14, TEXT_ALIGN_CENTER)
	SMBuilder.BuildLabel("SM_MoveType_Label", "Sprint", COLOR_WHITE, GetControl("SM_Max_Label"), Width, 15, ANCHOR_TOP, ANCHOR_BOTTOM, 14, TEXT_ALIGN_CENTER)
	SMBuilder.BuildLabel("SM_PeakSpeed_Label", "88.8", COLOR_WHITE, GetControl("SM_MoveType_Label"), Width, 20, ANCHOR_TOP, ANCHOR_BOTTOM, 18, TEXT_ALIGN_CENTER)
end

local function Create_Mid_Components()
	local Container = GetControl(MID_CONTAINER)
	local Width = Container:GetWidth()
	SMBuilder.BuildLabel("SM_Map_Label", "|c4ecdc4Auridon|r", COLOR_WHITE, Container, Width * .95, 22, ANCHOR_TOP, ANCHOR_TOP, 16, TEXT_ALIGN_CENTER)
	SMBuilder.BuildLabel("SM_Odo_Label", "0000000.0 km", COLOR_WHITE, Container, Width * .95, 38, ANCHOR_BOTTOM, ANCHOR_BOTTOM, 16, TEXT_ALIGN_CENTER)
end

function SMUI.CreateUI()
	TLW = SMBuilder.BuildTLW()
	Create_Main_Container()
	Create_Speed_CoolDown()
	Create_Speed_Container()
	Create_Data_Container()

	Create_Title_Components()
	Create_Peak_Components()
	Create_Mid_Components()
end

function SMUI.SetSpeedValue(Speed, Max)
	local CD = GetControl("SM_SpeedCoolDown")
	local Percent = Speed * 0.5 / Max
	CD:StartFixedCooldown(Percent, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_REMAINING, false)
end

function SMUI.ShowHideUI()
	TLW:SetHidden(Speedometer.SavedVariables.isUIHidden)
end

function SMUI.CreateOptionsButton()
	local name = "SpeedometerUIOptionsButton"
	local dimX = 24
	local dimY = 24
	local relative = GetControl(string.format("SpeedometerUITitleLabel"))
	local anchorX = ANCHOR_LEFT
	local anchorY = ANCHOR_RIGHT
	local Normal = "esoui/art/buttons/edit_save_up.dds"
	local Pressed = "esoui/art/buttons/edit_save_down.dds"
	local Over = "esoui/art/buttons/edit_save_over.dds"
	local Disabled = "esoui/art/buttons/edit_save_disabled.dds"

	local newButton = SMBuilder.CreateButton(name, TLW, relative, dimX, dimY, anchorX, anchorY, Normal, Pressed, Over, Disabled)

	newButton:SetHandler("OnClicked", SMUI.OptionsButtonOnClicked)
	newButton:SetHandler("OnMouseEnter", SMUI.OptionsButtonOnMouseEnter)
	newButton:SetHandler("OnMouseExit", SMBuilder.ButtonOnMouseExit)
end

function SMUI.OptionsButtonOnClicked(self)
	SMSettings.ShowOptions()
end

function SMUI.OptionsButtonOnMouseEnter(self)
	ZO_Tooltips_ShowTextTooltip(self, BOTTOM, "Open Settings")
end


