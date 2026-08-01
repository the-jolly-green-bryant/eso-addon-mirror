Imports System.IO

Partial Public Class MainWindow
    Private Sub ButtonCompareAddons_Click(sender As Object, e As EventArgs) Handles ButtonCompareAddons.Click

        Dim parentDirectory As String = Directory.GetParent(selectedPath).FullName
        Dim addonsPath As String = Path.Combine(parentDirectory, "AddOns")
        Dim savedVarsPath As String = selectedPath

        If Not Directory.Exists(addonsPath) OrElse Not Directory.Exists(savedVarsPath) Then
            MessageBox.Show("AddOns or SavedVariables folder not found in the expected location.")
            Return
        End If

        ' Recursively collect all manifest files (*.txt, *.addon) from AddOns
        Dim manifestFiles = Directory.GetFiles(addonsPath, "*.txt", SearchOption.AllDirectories).Concat(
                            Directory.GetFiles(addonsPath, "*.addon", SearchOption.AllDirectories))
        Dim manifestNamesNormalized As New HashSet(Of String)(manifestFiles.Select(Function(f) Path.GetFileNameWithoutExtension(f).Trim().ToLowerInvariant()))

        ' List of SavedVariables files to always ignore (case-insensitive, without extension)
        Dim ignoreFiles As New HashSet(Of String)(New String() {"ZO_Ingame", "ZO_InternalIngame", "ZO_Pregame"}.Select(Function(f) f.ToLowerInvariant()))

        ' HarvestMap base and backup file names
        Dim harvestMapBases As String() = {"HarvestMapAD", "HarvestMapDC", "HarvestMapDLC", "HarvestMapEP", "HarvestMapNF"}
        Dim harvestMapBackups As String() = harvestMapBases.Select(Function(f) f & "-backup").ToArray()
        Dim harvestMapBasesNormalized = harvestMapBases.Select(Function(f) f.ToLowerInvariant()).ToList()
        Dim harvestMapBackupsNormalized = harvestMapBackups.Select(Function(f) f.ToLowerInvariant()).ToList()

        ' Get SavedVariables file names
        Dim savedVarFiles = Directory.GetFiles(savedVarsPath, "*.lua")
        Dim savedVarNamesNormalized = savedVarFiles.Select(Function(f) Path.GetFileNameWithoutExtension(f).Trim().ToLowerInvariant()).ToList()

        ' If a base file is present, ignore its backup file
        Dim ignoreHarvestBackups As New HashSet(Of String)(ignoreFiles)
        For i = 0 To harvestMapBases.Length - 1
            If savedVarNamesNormalized.Contains(harvestMapBasesNormalized(i)) Then
                ignoreHarvestBackups.Add(harvestMapBackupsNormalized(i))
            End If
        Next

        ' Determine redundant files
        Dim redundantOriginalNames As New List(Of String)
        Dim redundantFilePaths As New List(Of String)
        For Each filePath In savedVarFiles
            Dim originalName = Path.GetFileNameWithoutExtension(filePath)
            Dim normalizedName = originalName.Trim().ToLowerInvariant()
            If ignoreHarvestBackups.Contains(normalizedName) Then Continue For
            If Not manifestNamesNormalized.Contains(normalizedName) Then
                redundantOriginalNames.Add(originalName)
                redundantFilePaths.Add(filePath)
            End If
        Next

        If redundantFilePaths.Count = 0 Then
            LogMessage("No redundant SavedVariables files found.", logBox:=LogBox, logType:=LogType.Warning)
            MessageBox.Show("No redundant SavedVariables files found.")
            Return
        End If

        ' ------------------ CONFIRMATION DIALOG ------------------
        Dim confirmMessage As String = "The following SavedVariables files will be deleted:" &
                               Environment.NewLine & Environment.NewLine &
                               String.Join(", ", redundantOriginalNames) &
                               Environment.NewLine & Environment.NewLine &
                               "Do you want to continue?"
        Dim confirmResult As DialogResult = MessageBox.Show(confirmMessage, "Confirm Deletion", MessageBoxButtons.YesNo, MessageBoxIcon.Warning)
        If confirmResult = DialogResult.No Then Return
        ' ----------------------------------------------------------

        ' Proceed with deletion
        Dim deletedFiles As New List(Of String)()
        For Each filePath In redundantFilePaths
            Try
                File.Delete(filePath)
                LogMessage($"Deleted redundant SavedVariables file: {Path.GetFileName(filePath)}", logBox:=LogBox, logType:=LogType.Normal)
                deletedFiles.Add(Path.GetFileName(filePath))
            Catch ex As Exception
                LogMessage($"Failed to delete file {Path.GetFileName(filePath)}: {ex.Message}", logBox:=LogBox, logType:=LogType.Warning)
            End Try
        Next

        LogMessage($"Total redundant SavedVariables files deleted: {deletedFiles.Count}", logBox:=LogBox, logType:=LogType.Info)
        MessageBox.Show($"Deleted {deletedFiles.Count} redundant SavedVariables file(s).", "Redundant SavedVariables Deleted")
        PopulateSTransferControls()
        UpdateAccountsFromTheFile()

        ' Show detailed report if enabled
        If CheckBoxDetailedReport.Checked AndAlso deletedFiles.Count > 0 Then
            Dim reportForm As New DeletionLogForm()
            Dim tree = reportForm.Controls.OfType(Of System.Windows.Forms.TreeView)().FirstOrDefault()
            If tree IsNot Nothing Then
                tree.Nodes.Clear()
                Dim fileNode = tree.Nodes.Add("Deleted SavedVariables Files")
                For Each file In deletedFiles
                    fileNode.Nodes.Add(file)
                Next
                tree.ExpandAll()
            End If
            reportForm.ShowDialog(Me)
        End If
    End Sub

End Class
