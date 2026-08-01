<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()>
Partial Class MainWindow
    Inherits System.Windows.Forms.Form

    'Form overrides dispose to clean up the component list.
    <System.Diagnostics.DebuggerNonUserCode()>
    Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        Try
            If disposing AndAlso components IsNot Nothing Then
                components.Dispose()
            End If
        Finally
            MyBase.Dispose(disposing)
        End Try
    End Sub

    'Required by the Windows Form Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Windows Form Designer
    'It can be modified using the Windows Form Designer.  
    'Do not modify it using the code editor.
    <System.Diagnostics.DebuggerStepThrough()>
    Private Sub InitializeComponent()
        components = New ComponentModel.Container()
        Dim DataGridViewCellStyle1 As DataGridViewCellStyle = New DataGridViewCellStyle()
        ButtonSelectFolder = New Button()
        FolderBrowserDialog1 = New FolderBrowserDialog()
        GroupBox1 = New GroupBox()
        CheckBoxDetailedReport = New CheckBox()
        GroupBox2 = New GroupBox()
        ButtonDelete = New Button()
        DataGridViewCharacters = New DataGridView()
        colCheck = New DataGridViewCheckBoxColumn()
        colName = New DataGridViewTextBoxColumn()
        colId = New DataGridViewTextBoxColumn()
        colOcc = New DataGridViewTextBoxColumn()
        RedundantAddons = New Button()
        ButtonCompareAddons = New Button()
        BackgroundWorker1 = New ComponentModel.BackgroundWorker()
        StatusStrip1 = New StatusStrip()
        ProgressBar1 = New ToolStripProgressBar()
        ToolStripStatusLabel1 = New ToolStripStatusLabel()
        AccNameOld = New TextBox()
        AccNameNew = New TextBox()
        OldCharBox = New ComboBox()
        NewCharName = New TextBox()
        UpdateAcc = New Button()
        UpdateChar = New Button()
        OldIDBox = New ComboBox()
        NewCharID = New TextBox()
        GroupBox3 = New GroupBox()
        UpdateID = New Button()
        GroupBox4 = New GroupBox()
        DeleteCached = New Button()
        CachedBox = New CheckedListBox()
        LogBox = New RichTextBox()
        TabControl1 = New TabControl()
        SCleanup = New TabPage()
        GroupBox5 = New GroupBox()
        AccountSource = New ComboBox()
        DeleteAccount = New Button()
        GroupBox12 = New GroupBox()
        RedundantLibraries = New Button()
        STransfer = New TabPage()
        LogBox2 = New RichTextBox()
        GroupBox8 = New GroupBox()
        DetailedTransfer = New CheckBox()
        SameAddons = New CheckBox()
        ServerNA = New RadioButton()
        ServerEU = New RadioButton()
        SettingsTarget = New CheckedListBox()
        TransferSettings = New Button()
        GroupBox7 = New GroupBox()
        SettingsSource = New ComboBox()
        GroupBox6 = New GroupBox()
        SelectionSwitch = New Button()
        SettingsList = New CheckedListBox()
        ImageList1 = New ImageList(components)
        GroupBox1.SuspendLayout()
        GroupBox2.SuspendLayout()
        CType(DataGridViewCharacters, ComponentModel.ISupportInitialize).BeginInit()
        StatusStrip1.SuspendLayout()
        GroupBox3.SuspendLayout()
        GroupBox4.SuspendLayout()
        TabControl1.SuspendLayout()
        SCleanup.SuspendLayout()
        GroupBox5.SuspendLayout()
        GroupBox12.SuspendLayout()
        STransfer.SuspendLayout()
        GroupBox8.SuspendLayout()
        GroupBox7.SuspendLayout()
        GroupBox6.SuspendLayout()
        SuspendLayout()
        ' 
        ' ButtonSelectFolder
        ' 
        ButtonSelectFolder.Location = New Point(6, 22)
        ButtonSelectFolder.Name = "ButtonSelectFolder"
        ButtonSelectFolder.Size = New Size(241, 26)
        ButtonSelectFolder.TabIndex = 1
        ButtonSelectFolder.Text = "Select Your SavedVariables Folder"
        ButtonSelectFolder.UseVisualStyleBackColor = True
        ' 
        ' GroupBox1
        ' 
        GroupBox1.Controls.Add(CheckBoxDetailedReport)
        GroupBox1.Controls.Add(ButtonSelectFolder)
        GroupBox1.Location = New Point(6, 6)
        GroupBox1.Name = "GroupBox1"
        GroupBox1.Size = New Size(254, 79)
        GroupBox1.TabIndex = 5
        GroupBox1.TabStop = False
        GroupBox1.Text = "Files Found: 0"
        ' 
        ' CheckBoxDetailedReport
        ' 
        CheckBoxDetailedReport.AutoSize = True
        CheckBoxDetailedReport.Font = New Font("Segoe UI", 9F)
        CheckBoxDetailedReport.Location = New Point(6, 54)
        CheckBoxDetailedReport.Name = "CheckBoxDetailedReport"
        CheckBoxDetailedReport.Size = New Size(154, 19)
        CheckBoxDetailedReport.TabIndex = 2
        CheckBoxDetailedReport.Text = "Detailed Report Window"
        CheckBoxDetailedReport.UseVisualStyleBackColor = True
        ' 
        ' GroupBox2
        ' 
        GroupBox2.BackColor = SystemColors.Control
        GroupBox2.Controls.Add(ButtonDelete)
        GroupBox2.Controls.Add(DataGridViewCharacters)
        GroupBox2.ForeColor = SystemColors.ControlText
        GroupBox2.Location = New Point(266, 6)
        GroupBox2.Name = "GroupBox2"
        GroupBox2.Size = New Size(436, 430)
        GroupBox2.TabIndex = 6
        GroupBox2.TabStop = False
        GroupBox2.Text = "Characters Found: 0"
        ' 
        ' ButtonDelete
        ' 
        ButtonDelete.BackColor = SystemColors.Control
        ButtonDelete.Font = New Font("Segoe UI", 9F, FontStyle.Regular, GraphicsUnit.Point, CByte(0))
        ButtonDelete.Location = New Point(7, 395)
        ButtonDelete.Name = "ButtonDelete"
        ButtonDelete.Size = New Size(422, 26)
        ButtonDelete.TabIndex = 5
        ButtonDelete.Text = "Delete Settings"
        ButtonDelete.UseVisualStyleBackColor = True
        ' 
        ' DataGridViewCharacters
        ' 
        DataGridViewCharacters.AllowUserToAddRows = False
        DataGridViewCharacters.AllowUserToDeleteRows = False
        DataGridViewCharacters.AllowUserToResizeRows = False
        DataGridViewCharacters.BackgroundColor = SystemColors.ButtonHighlight
        DataGridViewCharacters.ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.AutoSize
        DataGridViewCharacters.Columns.AddRange(New DataGridViewColumn() {colCheck, colName, colId, colOcc})
        DataGridViewCellStyle1.Alignment = DataGridViewContentAlignment.MiddleLeft
        DataGridViewCellStyle1.BackColor = SystemColors.Window
        DataGridViewCellStyle1.Font = New Font("Segoe UI", 9F)
        DataGridViewCellStyle1.ForeColor = SystemColors.ControlText
        DataGridViewCellStyle1.SelectionBackColor = SystemColors.Window
        DataGridViewCellStyle1.SelectionForeColor = SystemColors.ControlText
        DataGridViewCellStyle1.WrapMode = DataGridViewTriState.False
        DataGridViewCharacters.DefaultCellStyle = DataGridViewCellStyle1
        DataGridViewCharacters.EnableHeadersVisualStyles = False
        DataGridViewCharacters.Location = New Point(7, 19)
        DataGridViewCharacters.MultiSelect = False
        DataGridViewCharacters.Name = "DataGridViewCharacters"
        DataGridViewCharacters.RowHeadersVisible = False
        DataGridViewCharacters.ScrollBars = ScrollBars.Vertical
        DataGridViewCharacters.SelectionMode = DataGridViewSelectionMode.FullRowSelect
        DataGridViewCharacters.Size = New Size(422, 370)
        DataGridViewCharacters.TabIndex = 4
        ' 
        ' colCheck
        ' 
        colCheck.HeaderText = ""
        colCheck.Name = "colCheck"
        colCheck.Width = 30
        ' 
        ' colName
        ' 
        colName.HeaderText = "Character Name"
        colName.Name = "colName"
        colName.ReadOnly = True
        colName.Width = 224
        ' 
        ' colId
        ' 
        colId.AutoSizeMode = DataGridViewAutoSizeColumnMode.None
        colId.HeaderText = "Character ID"
        colId.Name = "colId"
        colId.ReadOnly = True
        colId.Width = 105
        ' 
        ' colOcc
        ' 
        colOcc.AutoSizeMode = DataGridViewAutoSizeColumnMode.None
        colOcc.HeaderText = "#"
        colOcc.Name = "colOcc"
        colOcc.ReadOnly = True
        colOcc.Width = 60
        ' 
        ' RedundantAddons
        ' 
        RedundantAddons.Location = New Point(7, 251)
        RedundantAddons.Name = "RedundantAddons"
        RedundantAddons.Size = New Size(240, 26)
        RedundantAddons.TabIndex = 2
        RedundantAddons.Text = "Remove Old Addon Data"
        RedundantAddons.UseVisualStyleBackColor = True
        ' 
        ' ButtonCompareAddons
        ' 
        ButtonCompareAddons.Location = New Point(7, 54)
        ButtonCompareAddons.Name = "ButtonCompareAddons"
        ButtonCompareAddons.Size = New Size(240, 26)
        ButtonCompareAddons.TabIndex = 3
        ButtonCompareAddons.Text = "Delete Redundant SV .lua"
        ButtonCompareAddons.UseVisualStyleBackColor = True
        ' 
        ' StatusStrip1
        ' 
        StatusStrip1.Items.AddRange(New ToolStripItem() {ProgressBar1, ToolStripStatusLabel1})
        StatusStrip1.Location = New Point(0, 670)
        StatusStrip1.Name = "StatusStrip1"
        StatusStrip1.Size = New Size(717, 22)
        StatusStrip1.TabIndex = 8
        StatusStrip1.Text = "StatusStrip1"
        ' 
        ' ProgressBar1
        ' 
        ProgressBar1.Name = "ProgressBar1"
        ProgressBar1.Size = New Size(625, 16)
        ' 
        ' ToolStripStatusLabel1
        ' 
        ToolStripStatusLabel1.Name = "ToolStripStatusLabel1"
        ToolStripStatusLabel1.Size = New Size(70, 17)
        ToolStripStatusLabel1.Text = "by @Atharti"
        ' 
        ' AccNameOld
        ' 
        AccNameOld.Location = New Point(7, 23)
        AccNameOld.Name = "AccNameOld"
        AccNameOld.PlaceholderText = "Old @Account Name"
        AccNameOld.Size = New Size(137, 23)
        AccNameOld.TabIndex = 0
        ' 
        ' AccNameNew
        ' 
        AccNameNew.Location = New Point(7, 52)
        AccNameNew.Name = "AccNameNew"
        AccNameNew.PlaceholderText = "New @Account Name"
        AccNameNew.Size = New Size(137, 23)
        AccNameNew.TabIndex = 1
        ' 
        ' OldCharBox
        ' 
        OldCharBox.FormattingEnabled = True
        OldCharBox.Location = New Point(150, 23)
        OldCharBox.Name = "OldCharBox"
        OldCharBox.Size = New Size(137, 23)
        OldCharBox.TabIndex = 2
        OldCharBox.Text = "Select Character"
        ' 
        ' NewCharName
        ' 
        NewCharName.Location = New Point(150, 52)
        NewCharName.Name = "NewCharName"
        NewCharName.PlaceholderText = "New Character Name"
        NewCharName.Size = New Size(137, 23)
        NewCharName.TabIndex = 3
        ' 
        ' UpdateAcc
        ' 
        UpdateAcc.Location = New Point(7, 81)
        UpdateAcc.Name = "UpdateAcc"
        UpdateAcc.Size = New Size(137, 26)
        UpdateAcc.TabIndex = 4
        UpdateAcc.Text = "Update @Account"
        UpdateAcc.UseVisualStyleBackColor = True
        ' 
        ' UpdateChar
        ' 
        UpdateChar.Location = New Point(150, 81)
        UpdateChar.Name = "UpdateChar"
        UpdateChar.Size = New Size(137, 26)
        UpdateChar.TabIndex = 5
        UpdateChar.Text = "Update Character Name"
        UpdateChar.UseVisualStyleBackColor = True
        ' 
        ' OldIDBox
        ' 
        OldIDBox.FormattingEnabled = True
        OldIDBox.Location = New Point(293, 23)
        OldIDBox.Name = "OldIDBox"
        OldIDBox.Size = New Size(137, 23)
        OldIDBox.TabIndex = 6
        OldIDBox.Text = "Select ID"
        ' 
        ' NewCharID
        ' 
        NewCharID.Location = New Point(293, 52)
        NewCharID.Name = "NewCharID"
        NewCharID.PlaceholderText = "New Character ID"
        NewCharID.Size = New Size(137, 23)
        NewCharID.TabIndex = 7
        ' 
        ' GroupBox3
        ' 
        GroupBox3.Controls.Add(UpdateID)
        GroupBox3.Controls.Add(NewCharID)
        GroupBox3.Controls.Add(OldIDBox)
        GroupBox3.Controls.Add(UpdateChar)
        GroupBox3.Controls.Add(UpdateAcc)
        GroupBox3.Controls.Add(NewCharName)
        GroupBox3.Controls.Add(OldCharBox)
        GroupBox3.Controls.Add(AccNameNew)
        GroupBox3.Controls.Add(AccNameOld)
        GroupBox3.Location = New Point(265, 442)
        GroupBox3.Name = "GroupBox3"
        GroupBox3.Size = New Size(436, 113)
        GroupBox3.TabIndex = 10
        GroupBox3.TabStop = False
        GroupBox3.Text = "Settings Adoption:"
        ' 
        ' UpdateID
        ' 
        UpdateID.Location = New Point(293, 81)
        UpdateID.Name = "UpdateID"
        UpdateID.Size = New Size(137, 26)
        UpdateID.TabIndex = 8
        UpdateID.Text = "Update ID"
        UpdateID.UseVisualStyleBackColor = True
        ' 
        ' GroupBox4
        ' 
        GroupBox4.Controls.Add(DeleteCached)
        GroupBox4.Controls.Add(RedundantAddons)
        GroupBox4.Controls.Add(CachedBox)
        GroupBox4.Location = New Point(6, 91)
        GroupBox4.Name = "GroupBox4"
        GroupBox4.Size = New Size(254, 282)
        GroupBox4.TabIndex = 2
        GroupBox4.TabStop = False
        GroupBox4.Text = "AddOnSettings.txt"
        ' 
        ' DeleteCached
        ' 
        DeleteCached.Location = New Point(6, 219)
        DeleteCached.Name = "DeleteCached"
        DeleteCached.Size = New Size(241, 26)
        DeleteCached.TabIndex = 1
        DeleteCached.Text = "Remove Old Character Data"
        DeleteCached.UseVisualStyleBackColor = True
        ' 
        ' CachedBox
        ' 
        CachedBox.CheckOnClick = True
        CachedBox.FormattingEnabled = True
        CachedBox.IntegralHeight = False
        CachedBox.Location = New Point(7, 20)
        CachedBox.Name = "CachedBox"
        CachedBox.Size = New Size(241, 193)
        CachedBox.Sorted = True
        CachedBox.TabIndex = 0
        ' 
        ' LogBox
        ' 
        LogBox.BackColor = SystemColors.Window
        LogBox.BorderStyle = BorderStyle.FixedSingle
        LogBox.Location = New Point(6, 560)
        LogBox.Name = "LogBox"
        LogBox.Size = New Size(695, 79)
        LogBox.TabIndex = 11
        LogBox.Text = ""
        ' 
        ' TabControl1
        ' 
        TabControl1.Controls.Add(SCleanup)
        TabControl1.Controls.Add(STransfer)
        TabControl1.Dock = DockStyle.Fill
        TabControl1.ItemSize = New Size(357, 20)
        TabControl1.Location = New Point(0, 0)
        TabControl1.Name = "TabControl1"
        TabControl1.SelectedIndex = 0
        TabControl1.Size = New Size(717, 670)
        TabControl1.SizeMode = TabSizeMode.Fixed
        TabControl1.TabIndex = 13
        ' 
        ' SCleanup
        ' 
        SCleanup.BackColor = SystemColors.Control
        SCleanup.Controls.Add(GroupBox5)
        SCleanup.Controls.Add(GroupBox12)
        SCleanup.Controls.Add(LogBox)
        SCleanup.Controls.Add(GroupBox1)
        SCleanup.Controls.Add(GroupBox2)
        SCleanup.Controls.Add(GroupBox3)
        SCleanup.Controls.Add(GroupBox4)
        SCleanup.Location = New Point(4, 24)
        SCleanup.Name = "SCleanup"
        SCleanup.Padding = New Padding(3)
        SCleanup.Size = New Size(709, 642)
        SCleanup.TabIndex = 0
        SCleanup.Text = "Settings Cleanup"
        ' 
        ' GroupBox5
        ' 
        GroupBox5.Controls.Add(AccountSource)
        GroupBox5.Controls.Add(DeleteAccount)
        GroupBox5.Location = New Point(6, 473)
        GroupBox5.Name = "GroupBox5"
        GroupBox5.Size = New Size(254, 82)
        GroupBox5.TabIndex = 16
        GroupBox5.TabStop = False
        GroupBox5.Text = "@Account Data Removal"
        ' 
        ' AccountSource
        ' 
        AccountSource.FormattingEnabled = True
        AccountSource.Location = New Point(7, 22)
        AccountSource.Name = "AccountSource"
        AccountSource.Size = New Size(240, 23)
        AccountSource.Sorted = True
        AccountSource.TabIndex = 14
        ' 
        ' DeleteAccount
        ' 
        DeleteAccount.Location = New Point(7, 50)
        DeleteAccount.Name = "DeleteAccount"
        DeleteAccount.Size = New Size(240, 26)
        DeleteAccount.TabIndex = 15
        DeleteAccount.Text = "Delete @Account Data"
        DeleteAccount.UseVisualStyleBackColor = True
        ' 
        ' GroupBox12
        ' 
        GroupBox12.Controls.Add(ButtonCompareAddons)
        GroupBox12.Controls.Add(RedundantLibraries)
        GroupBox12.Location = New Point(6, 379)
        GroupBox12.Name = "GroupBox12"
        GroupBox12.Size = New Size(254, 88)
        GroupBox12.TabIndex = 13
        GroupBox12.TabStop = False
        GroupBox12.Text = "Miscellaneous:"
        ' 
        ' RedundantLibraries
        ' 
        RedundantLibraries.Location = New Point(7, 22)
        RedundantLibraries.Name = "RedundantLibraries"
        RedundantLibraries.Size = New Size(240, 26)
        RedundantLibraries.TabIndex = 4
        RedundantLibraries.Text = "Check For Redundant Libraries"
        RedundantLibraries.UseVisualStyleBackColor = True
        ' 
        ' STransfer
        ' 
        STransfer.BackColor = SystemColors.Control
        STransfer.Controls.Add(LogBox2)
        STransfer.Controls.Add(GroupBox8)
        STransfer.Controls.Add(TransferSettings)
        STransfer.Controls.Add(GroupBox7)
        STransfer.Controls.Add(GroupBox6)
        STransfer.Location = New Point(4, 24)
        STransfer.Name = "STransfer"
        STransfer.Padding = New Padding(3)
        STransfer.Size = New Size(709, 618)
        STransfer.TabIndex = 1
        STransfer.Text = "Character Settings Transfer"
        ' 
        ' LogBox2
        ' 
        LogBox2.BackColor = SystemColors.Window
        LogBox2.BorderStyle = BorderStyle.FixedSingle
        LogBox2.Location = New Point(6, 560)
        LogBox2.Name = "LogBox2"
        LogBox2.Size = New Size(695, 79)
        LogBox2.TabIndex = 12
        LogBox2.Text = ""
        ' 
        ' GroupBox8
        ' 
        GroupBox8.Controls.Add(DetailedTransfer)
        GroupBox8.Controls.Add(SameAddons)
        GroupBox8.Controls.Add(ServerNA)
        GroupBox8.Controls.Add(ServerEU)
        GroupBox8.Controls.Add(SettingsTarget)
        GroupBox8.Location = New Point(357, 65)
        GroupBox8.Name = "GroupBox8"
        GroupBox8.Size = New Size(344, 445)
        GroupBox8.TabIndex = 5
        GroupBox8.TabStop = False
        GroupBox8.Text = "To:"
        ' 
        ' DetailedTransfer
        ' 
        DetailedTransfer.AutoSize = True
        DetailedTransfer.Location = New Point(6, 421)
        DetailedTransfer.Name = "DetailedTransfer"
        DetailedTransfer.Size = New Size(154, 19)
        DetailedTransfer.TabIndex = 5
        DetailedTransfer.Text = "Detailed Report Window"
        DetailedTransfer.UseVisualStyleBackColor = True
        ' 
        ' SameAddons
        ' 
        SameAddons.AutoSize = True
        SameAddons.Location = New Point(6, 403)
        SameAddons.Name = "SameAddons"
        SameAddons.Size = New Size(137, 19)
        SameAddons.TabIndex = 4
        SameAddons.Text = "Enable Same Addons"
        SameAddons.UseVisualStyleBackColor = True
        ' 
        ' ServerNA
        ' 
        ServerNA.AutoSize = True
        ServerNA.Location = New Point(235, 421)
        ServerNA.Name = "ServerNA"
        ServerNA.Size = New Size(106, 19)
        ServerNA.TabIndex = 2
        ServerNA.TabStop = True
        ServerNA.Text = "NA Megaserver"
        ServerNA.UseVisualStyleBackColor = True
        ' 
        ' ServerEU
        ' 
        ServerEU.AutoSize = True
        ServerEU.Checked = True
        ServerEU.Location = New Point(235, 403)
        ServerEU.Name = "ServerEU"
        ServerEU.Size = New Size(103, 19)
        ServerEU.TabIndex = 1
        ServerEU.TabStop = True
        ServerEU.Text = "EU Megaserver"
        ServerEU.UseVisualStyleBackColor = True
        ' 
        ' SettingsTarget
        ' 
        SettingsTarget.CheckOnClick = True
        SettingsTarget.FormattingEnabled = True
        SettingsTarget.IntegralHeight = False
        SettingsTarget.Location = New Point(6, 16)
        SettingsTarget.Name = "SettingsTarget"
        SettingsTarget.Size = New Size(332, 381)
        SettingsTarget.Sorted = True
        SettingsTarget.TabIndex = 0
        ' 
        ' TransferSettings
        ' 
        TransferSettings.Location = New Point(359, 521)
        TransferSettings.Name = "TransferSettings"
        TransferSettings.Size = New Size(344, 26)
        TransferSettings.TabIndex = 4
        TransferSettings.Text = "Transfer Addon Settings"
        TransferSettings.UseVisualStyleBackColor = True
        ' 
        ' GroupBox7
        ' 
        GroupBox7.Controls.Add(SettingsSource)
        GroupBox7.Location = New Point(357, 6)
        GroupBox7.Name = "GroupBox7"
        GroupBox7.Size = New Size(344, 60)
        GroupBox7.TabIndex = 2
        GroupBox7.TabStop = False
        GroupBox7.Text = "Copy Settings From:"
        ' 
        ' SettingsSource
        ' 
        SettingsSource.FormattingEnabled = True
        SettingsSource.Location = New Point(6, 22)
        SettingsSource.Name = "SettingsSource"
        SettingsSource.Size = New Size(332, 23)
        SettingsSource.Sorted = True
        SettingsSource.TabIndex = 0
        ' 
        ' GroupBox6
        ' 
        GroupBox6.Controls.Add(SelectionSwitch)
        GroupBox6.Controls.Add(SettingsList)
        GroupBox6.Location = New Point(6, 6)
        GroupBox6.Name = "GroupBox6"
        GroupBox6.Size = New Size(345, 548)
        GroupBox6.TabIndex = 1
        GroupBox6.TabStop = False
        GroupBox6.Text = "Select Addons:"
        ' 
        ' SelectionSwitch
        ' 
        SelectionSwitch.Location = New Point(6, 515)
        SelectionSwitch.Name = "SelectionSwitch"
        SelectionSwitch.Size = New Size(330, 26)
        SelectionSwitch.TabIndex = 1
        SelectionSwitch.Text = "Select: NONE"
        SelectionSwitch.UseVisualStyleBackColor = True
        ' 
        ' SettingsList
        ' 
        SettingsList.CheckOnClick = True
        SettingsList.FormattingEnabled = True
        SettingsList.IntegralHeight = False
        SettingsList.Location = New Point(6, 17)
        SettingsList.Name = "SettingsList"
        SettingsList.Size = New Size(330, 487)
        SettingsList.Sorted = True
        SettingsList.TabIndex = 0
        ' 
        ' ImageList1
        ' 
        ImageList1.ColorDepth = ColorDepth.Depth32Bit
        ImageList1.ImageSize = New Size(16, 16)
        ImageList1.TransparentColor = Color.Transparent
        ' 
        ' MainWindow
        ' 
        AutoScaleDimensions = New SizeF(7F, 15F)
        AutoScaleMode = AutoScaleMode.Font
        ClientSize = New Size(717, 692)
        Controls.Add(TabControl1)
        Controls.Add(StatusStrip1)
        MaximizeBox = False
        MaximumSize = New Size(733, 731)
        MinimumSize = New Size(733, 731)
        Name = "MainWindow"
        StartPosition = FormStartPosition.CenterScreen
        Text = "CASE - Character Addon Settings Editor"
        GroupBox1.ResumeLayout(False)
        GroupBox1.PerformLayout()
        GroupBox2.ResumeLayout(False)
        CType(DataGridViewCharacters, ComponentModel.ISupportInitialize).EndInit()
        StatusStrip1.ResumeLayout(False)
        StatusStrip1.PerformLayout()
        GroupBox3.ResumeLayout(False)
        GroupBox3.PerformLayout()
        GroupBox4.ResumeLayout(False)
        TabControl1.ResumeLayout(False)
        SCleanup.ResumeLayout(False)
        GroupBox5.ResumeLayout(False)
        GroupBox12.ResumeLayout(False)
        STransfer.ResumeLayout(False)
        GroupBox8.ResumeLayout(False)
        GroupBox8.PerformLayout()
        GroupBox7.ResumeLayout(False)
        GroupBox6.ResumeLayout(False)
        ResumeLayout(False)
        PerformLayout()
    End Sub
    Friend WithEvents ButtonSelectFolder As Button
    Friend WithEvents FolderBrowserDialog1 As FolderBrowserDialog
    Friend WithEvents GroupBox1 As GroupBox
    Friend WithEvents GroupBox2 As GroupBox
    Friend WithEvents ButtonDelete As Button
    Friend WithEvents BackgroundWorker1 As System.ComponentModel.BackgroundWorker
    Friend WithEvents StatusStrip1 As StatusStrip
    Friend WithEvents ProgressBar1 As ToolStripProgressBar
    Friend WithEvents ToolStripStatusLabel1 As ToolStripStatusLabel
    Friend WithEvents AccNameOld As TextBox
    Friend WithEvents AccNameNew As TextBox
    Friend WithEvents OldCharBox As ComboBox
    Friend WithEvents NewCharName As TextBox
    Friend WithEvents UpdateAcc As Button
    Friend WithEvents UpdateChar As Button
    Friend WithEvents OldIDBox As ComboBox
    Friend WithEvents NewCharID As TextBox
    Friend WithEvents GroupBox3 As GroupBox
    Friend WithEvents GroupBox4 As GroupBox
    Friend WithEvents CachedBox As CheckedListBox
    Friend WithEvents DeleteCached As Button
    Friend WithEvents RedundantAddons As Button
    Friend WithEvents ButtonCompareAddons As Button
    Friend WithEvents LogBox As RichTextBox
    Friend WithEvents UpdateID As Button
    Friend WithEvents CheckBoxDetailedReport As CheckBox
    Friend WithEvents DataGridViewCharacters As DataGridView
    Friend WithEvents TabControl1 As TabControl
    Friend WithEvents SCleanup As TabPage
    Friend WithEvents STransfer As TabPage
    Friend WithEvents GroupBox6 As GroupBox
    Friend WithEvents SettingsList As CheckedListBox
    Friend WithEvents TransferSettings As Button
    Friend WithEvents GroupBox7 As GroupBox
    Friend WithEvents GroupBox8 As GroupBox
    Friend WithEvents SettingsTarget As CheckedListBox
    Friend WithEvents SettingsSource As ComboBox
    Friend WithEvents LogBox2 As RichTextBox
    Friend WithEvents ServerNA As RadioButton
    Friend WithEvents ServerEU As RadioButton
    Friend WithEvents Label1 As Label
    Friend WithEvents SameAddons As CheckBox
    Friend WithEvents DetailedTransfer As CheckBox
    Friend WithEvents CheckBox2 As CheckBox
    Friend WithEvents CheckedListBox1 As CheckedListBox
    Friend WithEvents SelectionSwitch As Button
    Friend WithEvents colCheck As DataGridViewCheckBoxColumn
    Friend WithEvents colName As DataGridViewTextBoxColumn
    Friend WithEvents colId As DataGridViewTextBoxColumn
    Friend WithEvents colOcc As DataGridViewTextBoxColumn
    Friend WithEvents GroupBox12 As GroupBox
    Friend WithEvents RedundantLibraries As Button
    Friend WithEvents ImageList1 As ImageList
    Friend WithEvents GroupBox5 As GroupBox
    Friend WithEvents AccountSource As ComboBox
    Friend WithEvents DeleteAccount As Button
End Class
