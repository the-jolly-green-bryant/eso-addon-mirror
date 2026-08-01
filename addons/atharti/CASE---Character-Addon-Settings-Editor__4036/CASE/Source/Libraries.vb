Public Class Libraries
    Public Property LibraryPaths As Dictionary(Of String, String)
    Private Sub Libraries_Load(sender As Object, e As EventArgs) Handles MyBase.Load
        Me.Icon = Icon.ExtractAssociatedIcon(Application.ExecutablePath)
        ' After populating LibList in Libraries.vb, check all by default and update button text
        For i As Integer = 0 To LibList.Items.Count - 1
            LibList.SetItemChecked(i, True)
        Next
        LibRemove.Text = $"Delete ({LibList.CheckedItems.Count}) Libraries"

        ' Add handler for item check event
        AddHandler LibList.ItemCheck, AddressOf LibList_ItemCheck_UpdateButton
        LibRemove.Enabled = (LibList.CheckedItems.Count > 0)
    End Sub

    Private Sub LibList_ItemCheck_UpdateButton(sender As Object, e As ItemCheckEventArgs)
        Dim checkedCount As Integer = LibList.CheckedItems.Count
        If e.NewValue = CheckState.Checked Then
            checkedCount += 1
        ElseIf e.NewValue = CheckState.Unchecked Then
            checkedCount -= 1
        End If
        LibRemove.Text = $"Delete ({checkedCount}) Libraries"
        LibRemove.Enabled = (checkedCount > 0)
    End Sub

    Private Sub LibRemove_Click(sender As Object, e As EventArgs) Handles LibRemove.Click
        If LibList.CheckedItems.Count = 0 Then
            MessageBox.Show("No libraries selected for deletion.")
            Return
        End If
        ' Get AddOns folder path
        Dim mainForm = Application.OpenForms().OfType(Of MainWindow)().FirstOrDefault()
        Dim selectedPath = mainForm.selectedPath
        Dim parentDir = IO.Path.GetDirectoryName(selectedPath.TrimEnd(IO.Path.DirectorySeparatorChar))
        Dim addonsDir = IO.Path.Combine(parentDir, "AddOns")

        Dim toDelete As New List(Of String)
        For Each libName As String In LibList.CheckedItems
            If LibraryPaths IsNot Nothing AndAlso LibraryPaths.ContainsKey(libName) Then
                Dim libFolder = LibraryPaths(libName)
                If IO.Directory.Exists(libFolder) Then
                    Try
                        IO.Directory.Delete(libFolder, True)
                        toDelete.Add(libName)
                    Catch ex As Exception
                        MessageBox.Show($"Failed to delete {libName}: {ex.Message}")
                    End Try
                Else
                    MessageBox.Show($"Library folder not found: {libFolder}")
                End If
            Else
                MessageBox.Show($"Path for library '{libName}' not found.")
            End If
        Next

        If toDelete.Count > 0 Then
            MessageBox.Show("Removed libraries:" & Environment.NewLine & String.Join(Environment.NewLine, toDelete), "Libraries Removed", MessageBoxButtons.OK, MessageBoxIcon.Information)
            Me.Close()
            If mainForm IsNot Nothing Then
                For Each libName As String In toDelete
                    mainForm.LogBox.SelectionStart = mainForm.LogBox.TextLength
                    mainForm.LogBox.SelectionLength = 0
                    mainForm.LogBox.SelectionColor = Color.Green
                    mainForm.LogBox.AppendText(Environment.NewLine & $"[{DateTime.Now:HH:mm:ss}] Library '{libName}' was removed.")
                    mainForm.LogBox.SelectionColor = mainForm.LogBox.ForeColor
                    mainForm.PopulateSTransferControls()
                    mainForm.UpdateAccountsFromTheFile()
                Next
                mainForm.LogBox.ScrollToCaret()
            End If
        End If

        ' Remove deleted items from LibList
        For Each libName As String In toDelete
            LibList.Items.Remove(libName)
        Next

        LibRemove.Text = $"Delete ({LibList.CheckedItems.Count}) Libraries"

    End Sub
End Class