Imports System.IO
Imports System.Text
Imports System.Text.RegularExpressions

Public Class MainWindow
    Friend selectedPath As String = String.Empty
    Private isAllSelected As Boolean = True
    Private characterMap As New Dictionary(Of String, String)() ' Class-level declaration
    Private ReadOnly idRegex As New Regex("\[""(\d{16})""\]", RegexOptions.Compiled)
    Private ReadOnly nameRegex As New Regex("=\s*""(.*?)""", RegexOptions.Compiled)
    ' Make deletionLog accessible to all methods
    Private deletionLog As New Dictionary(Of String, List(Of String))()

    ' Helper: Read all Lua files in selectedPath
    Private Function GetLuaFiles() As String()
        If String.IsNullOrEmpty(selectedPath) Then Return New String() {}
        Return Directory.GetFiles(selectedPath, "*.lua")
    End Function

    ' Helper: Setup ProgressBar
    Private Sub SetupProgressBar(minValue As Integer, maxValue As Integer)
        ' Always reset Value before changing range
        ProgressBar1.Value = 0
        ProgressBar1.Minimum = minValue
        ProgressBar1.Maximum = Math.Max(maxValue, minValue + 1)
    End Sub
    ' --- CheckedListBox ItemCheck handlers ---
    Private Sub CachedBox_ItemCheck(sender As Object, e As ItemCheckEventArgs)
        Dim checkedCount As Integer = CachedBox.CheckedItems.Count
        If e.NewValue = CheckState.Checked Then
            checkedCount += 1
        ElseIf e.NewValue = CheckState.Unchecked Then
            checkedCount -= 1
        End If
        DeleteCached.Enabled = (checkedCount > 0)
    End Sub

    ' Helper to update DeleteCached button state after programmatic changes
    Private Sub UpdateDeleteCachedButtonState()
        DeleteCached.Enabled = (CachedBox.CheckedItems.Count > 0)
    End Sub

    ' Helper: Enable/disable STransfer tab and TransferSettings button
    Private Sub UpdateSTransferTabAndButton()
        ' Enable STransfer tab only if selectedPath is set and Lua files exist
        Dim hasPath As Boolean = Not String.IsNullOrEmpty(selectedPath)
        Dim hasLuaFiles As Boolean = False
        If hasPath Then
            Try
                hasLuaFiles = Directory.GetFiles(selectedPath, "*.lua").Length > 0
            Catch
                hasLuaFiles = False
            End Try
        End If
        ' STransfer tab
        If TabControl1.TabPages.Contains(STransfer) Then
            STransfer.Enabled = hasPath AndAlso hasLuaFiles
        End If
        ' TransferSettings button
        Dim settingsListChecked As Boolean = SettingsList.CheckedItems.Count > 0
        Dim settingsTargetChecked As Boolean = SettingsTarget.CheckedItems.Count > 0
        TransferSettings.Enabled = settingsListChecked AndAlso settingsTargetChecked
        GroupBox12.Enabled = Not String.IsNullOrEmpty(selectedPath)
    End Sub

    Private Sub SettingsList_ItemCheck(sender As Object, e As ItemCheckEventArgs)
        ' Delay update until after the check state changes
        Me.BeginInvoke(New MethodInvoker(AddressOf UpdateSTransferTabAndButton))
        Me.BeginInvoke(New MethodInvoker(AddressOf UpdateGroupBox6Text))
    End Sub
    Private Sub SettingsTarget_ItemCheck(sender As Object, e As ItemCheckEventArgs)
        ' Prevent checking the source character
        Dim itemText = SettingsTarget.Items(e.Index).ToString()
        If SettingsSource.SelectedItem IsNot Nothing AndAlso itemText = SettingsSource.SelectedItem.ToString() Then
            e.NewValue = e.CurrentValue ' Prevent checking/unchecking
            Return
        End If
        Me.BeginInvoke(New MethodInvoker(AddressOf UpdateSTransferTabAndButton))
    End Sub

    ' --- Form Load ---
    Private Sub MainWindow_Load(sender As Object, e As EventArgs) Handles MyBase.Load
        Me.Icon = Icon.ExtractAssociatedIcon(Application.ExecutablePath)
        Dim appIcon As Icon = Icon.ExtractAssociatedIcon(Application.ExecutablePath)
        ImageList1.Images.Add(appIcon)
        ' Add spaces to text to create padding
        SCleanup.Text = "       " & SCleanup.Text ' Add spaces before text
        STransfer.Text = "       " & STransfer.Text

        TabControl1.ImageList = ImageList1
        SCleanup.ImageIndex = 0
        STransfer.ImageIndex = 0

        ' --- Initial button states ---
        ButtonDelete.Enabled = False

        UpdateDeleteCachedButtonState()

        ' --- Configure LogBoxes ---
        LogBox.Multiline = True
        LogBox.ReadOnly = True
        LogBox.ScrollBars = ScrollBars.Vertical

        LogBox2.Multiline = True
        LogBox2.ReadOnly = True
        LogBox2.ScrollBars = ScrollBars.Vertical



        ' --- Disable SAccountWide tab controls and related GroupBoxes by default ---

        AccountSource.Enabled = False
        GroupBox5.Enabled = False

        ' --- Disable SCleanup tab controls by default ---
        LogBox.Enabled = False
        GroupBox2.Enabled = False
        GroupBox3.Enabled = False
        GroupBox4.Enabled = False
        CheckBoxDetailedReport.Enabled = False

        ' --- Add event handlers ---
        ' CachedBox
        AddHandler CachedBox.ItemCheck, AddressOf CachedBox_ItemCheck

        ' Update buttons
        AddHandler AccNameOld.TextChanged, AddressOf UpdateAcc_EnableHandler
        AddHandler AccNameNew.TextChanged, AddressOf UpdateAcc_EnableHandler
        AddHandler OldCharBox.SelectedIndexChanged, AddressOf UpdateChar_EnableHandler
        AddHandler NewCharName.TextChanged, AddressOf UpdateChar_EnableHandler
        AddHandler OldIDBox.SelectedIndexChanged, AddressOf UpdateID_EnableHandler
        AddHandler NewCharID.TextChanged, AddressOf UpdateID_EnableHandler

        ' Path-dependent buttons
        AddHandler ButtonSelectFolder.Click, AddressOf UpdatePathDependentButtons

        ' STransfer tab controls
        AddHandler SettingsList.ItemCheck, AddressOf SettingsList_ItemCheck
        AddHandler SettingsTarget.ItemCheck, AddressOf SettingsTarget_ItemCheck




        ' --- Initial state updates ---
        UpdateAcc_EnableHandler(Nothing, Nothing)
        UpdateChar_EnableHandler(Nothing, Nothing)
        UpdateID_EnableHandler(Nothing, Nothing)
        UpdatePathDependentButtons(Nothing, Nothing)
        UpdateSTransferTabAndButton()

    End Sub


    ' Enable/disable Remove Old Addon Data and Delete Redundant SavedVariables buttons
    Private Sub UpdatePathDependentButtons(sender As Object, e As EventArgs)
        ' --- Check for selected path and Lua files ---
        Dim hasPath As Boolean = Not String.IsNullOrEmpty(selectedPath)
        Dim hasLuaFiles As Boolean = False
        If hasPath Then
            Try
                hasLuaFiles = Directory.GetFiles(selectedPath, "*.lua").Length > 0
            Catch
                hasLuaFiles = False
            End Try
        End If
        Dim enableControls As Boolean = hasPath AndAlso hasLuaFiles

        ' --- Enable/disable SCleanup tab controls ---
        LogBox.Enabled = enableControls
        GroupBox2.Enabled = enableControls
        GroupBox3.Enabled = enableControls
        GroupBox4.Enabled = enableControls
        CheckBoxDetailedReport.Enabled = enableControls
        RedundantAddons.Enabled = enableControls
        ButtonCompareAddons.Enabled = enableControls
        OldCharBox.Enabled = enableControls
        OldIDBox.Enabled = enableControls
        AccNameOld.Enabled = enableControls
        AccNameNew.Enabled = enableControls
        NewCharName.Enabled = enableControls
        NewCharID.Enabled = enableControls
        GroupBox5.Enabled = enableControls

        ' --- Enable/disable SAccountWide tab controls ---

        AccountSource.Enabled = enableControls

        ' --- Backup folder check ---
        Dim parentDir As String = Nothing
        Dim backupDir As String = Nothing
        If hasPath Then
            parentDir = IO.Path.GetDirectoryName(selectedPath.TrimEnd(IO.Path.DirectorySeparatorChar))
            backupDir = IO.Path.Combine(parentDir, "CASE_BACKUP_SavedVariables")
        End If
    End Sub


    ' --- Enable/disable Update buttons ---
    Private Sub UpdateAcc_EnableHandler(sender As Object, e As EventArgs)
        UpdateAcc.Enabled = (AccNameOld.Text.Trim() <> "" AndAlso AccNameNew.Text.Trim() <> "")
    End Sub
    Private Sub UpdateChar_EnableHandler(sender As Object, e As EventArgs)
        UpdateChar.Enabled = (OldCharBox.SelectedItem IsNot Nothing AndAlso NewCharName.Text.Trim() <> "")
    End Sub
    Private Sub UpdateID_EnableHandler(sender As Object, e As EventArgs)
        UpdateID.Enabled = (OldIDBox.SelectedItem IsNot Nothing AndAlso NewCharID.Text.Trim() <> "")
    End Sub

    Private Sub FindMostPopularName()

        Dim files As String() = System.IO.Directory.GetFiles(selectedPath, "*.lua")
        Dim wordCount As New Dictionary(Of String, Integer)() ' To hold word counts

        For Each file As String In files
            Dim lines As String() = System.IO.File.ReadAllLines(file)

            ' Check if the file has at least 5 lines
            If lines.Length >= 5 Then
                Dim line As String = lines(4).Trim() ' Get the 5th line (0-based index)

                ' Split the line into words
                Dim words As String() = line.Split({" "c}, StringSplitOptions.RemoveEmptyEntries)
                For Each word As String In words
                    If word.Contains("@"c) Then ' Check if the word contains @
                        ' Clean the word of any extra characters (brackets and quotes)
                        Dim cleanWord As String = word.Trim("["c, "]"c, """"c) ' Remove brackets and quotes

                        If wordCount.ContainsKey(cleanWord) Then
                            wordCount(cleanWord) += 1
                        Else
                            wordCount(cleanWord) = 1
                        End If
                    End If
                Next
            End If
        Next

        ' Determine the most popular word
        Dim mostPopularWord As String = String.Empty
        Dim highestCount As Integer = 0

        For Each kvp As KeyValuePair(Of String, Integer) In wordCount
            If kvp.Value > highestCount Then
                highestCount = kvp.Value
                mostPopularWord = kvp.Key
            End If
        Next

        ' Display the found word in AccNameOld textbox
        If Not String.IsNullOrEmpty(mostPopularWord) Then
            AccNameOld.Text = mostPopularWord ' Display the most popular word
        Else
            AccNameOld.Text = String.Empty ' Clear the textbox if no word was found
        End If
    End Sub
    ' --- STransfer Tab Controls Population ---
    Public Sub PopulateSTransferControls()
        ' SettingsList: CheckedListBox for Lua files (checked ON by default)
        SettingsList.Items.Clear()
        Dim luaFiles = GetLuaFiles()
        For Each filePath In luaFiles
            Dim fileName = Path.GetFileName(filePath)
            SettingsList.Items.Add(fileName, True)
        Next

        ' SettingsSource: ComboBox for character names (keys only, no IDs)
        SettingsSource.Items.Clear()
        For Each characterName In characterMap.Keys
            SettingsSource.Items.Add(characterName)
        Next
        If SettingsSource.Items.Count > 0 Then
            SettingsSource.SelectedIndex = 0
        End If

        ' SettingsTarget: CheckedListBox for all character names (unchecked by default)
        SettingsTarget.Items.Clear()
        For Each characterName In characterMap.Keys
            SettingsTarget.Items.Add(characterName, False)
        Next
        UpdateSTransferTabAndButton()
        UpdateGroupBox6Text()
    End Sub



    ' Prevent selection highlight in DataGridViewCharacters
    Private Sub DataGridViewCharacters_SelectionChanged(sender As Object, e As EventArgs) Handles DataGridViewCharacters.SelectionChanged
        DataGridViewCharacters.ClearSelection()
    End Sub

    Private Sub DataGridViewCharacters_CellMouseDown(sender As Object, e As DataGridViewCellMouseEventArgs) Handles DataGridViewCharacters.CellMouseDown
        DataGridViewCharacters.ClearSelection()
    End Sub

    Private Sub DataGridViewCharacters_Enter(sender As Object, e As EventArgs) Handles DataGridViewCharacters.Enter
        DataGridViewCharacters.ClearSelection()
    End Sub

    ' Enable Delete Settings button when any checkbox is checked in DataGridViewCharacters
    Private Sub DataGridViewCharacters_CellValueChanged(sender As Object, e As DataGridViewCellEventArgs) Handles DataGridViewCharacters.CellValueChanged
        If e.ColumnIndex = 0 Then ' Checkbox column
            Dim checkedCount As Integer = 0
            For Each row As DataGridViewRow In DataGridViewCharacters.Rows
                If Convert.ToBoolean(row.Cells(0).Value) Then checkedCount += 1
            Next
            ButtonDelete.Enabled = (checkedCount > 0)
        End If
    End Sub

    ' Also handle when user clicks checkbox (for immediate feedback)
    Private Sub DataGridViewCharacters_CurrentCellDirtyStateChanged(sender As Object, e As EventArgs) Handles DataGridViewCharacters.CurrentCellDirtyStateChanged
        If DataGridViewCharacters.IsCurrentCellDirty Then
            DataGridViewCharacters.CommitEdit(DataGridViewDataErrorContexts.Commit)
        End If
    End Sub


    Private Sub SelectionSwitch_Click(sender As Object, e As EventArgs) Handles SelectionSwitch.Click
        If Not isAllSelected Then
            For i As Integer = 0 To SettingsList.Items.Count - 1
                SettingsList.SetItemChecked(i, True)
            Next
            SelectionSwitch.Text = "Select: NONE"
            isAllSelected = True
        Else
            For i As Integer = 0 To SettingsList.Items.Count - 1
                SettingsList.SetItemChecked(i, False)
            Next
            SelectionSwitch.Text = "Select: ALL"
            isAllSelected = False
        End If
    End Sub

    ' Update GroupBox6 text with checked count in SettingsList
    Private Sub UpdateGroupBox6Text()
        Dim checkedCount As Integer = SettingsList.CheckedItems.Count
        GroupBox6.Text = $"Select Addons: {checkedCount}"
    End Sub
End Class
