Imports System.IO
Imports System.Text.RegularExpressions

Partial Public Class MainWindow
    ' ----------------- AddOnSettings Functions -----------------
    Private Function FindAddOnSettingsFile() As String
        Try
            Dim parentDirectory As String = Directory.GetParent(selectedPath).FullName
            Dim filePath As String = Path.Combine(parentDirectory, "AddOnSettings.txt")
            If File.Exists(filePath) Then
                Dim lines() As String = File.ReadAllLines(filePath)
                Dim charNames As New List(Of String)
                Dim pattern As String = "#(EU|NA) Megaserver-(.+)"
                Dim regex As New Regex(pattern)
                Dim totalCount As Integer = 0
                For Each line As String In lines
                    Dim match As Match = regex.Match(line)
                    If match.Success Then
                        Dim serverPrefix As String = match.Groups(1).Value
                        Dim charName As String = match.Groups(2).Value.Trim()
                        ' Add prefix to character name
                        charNames.Add($"#{serverPrefix} - {charName}")
                        totalCount += 1
                    End If
                Next
                CachedBox.Items.Clear()
                CachedBox.Items.AddRange(charNames.ToArray())
                GroupBox4.Text = $"AddOnSettings.txt: {totalCount}"
                UpdateDeleteCachedButtonState()
                Return filePath
            Else
                MessageBox.Show("AddonSettings.txt file not found.", "File Not Found", MessageBoxButtons.OK, MessageBoxIcon.Warning)
                UpdateDeleteCachedButtonState()
                Return Nothing
            End If
        Catch ex As Exception
            LogMessage("An error occurred: " & ex.Message, logBox:=LogBox, logType:=LogType.Error)
            MessageBox.Show("An error occurred: " & ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error)
            UpdateDeleteCachedButtonState()
            Return Nothing
        End Try
    End Function

    Private Sub DeleteCached_Click(sender As Object, e As EventArgs) Handles DeleteCached.Click
        Try
            Dim parentDirectory As String = Directory.GetParent(selectedPath).FullName
            Dim filePath As String = Path.Combine(parentDirectory, "AddOnSettings.txt")
            If Not File.Exists(filePath) Then
                MessageBox.Show("File not found.", "File Not Found", MessageBoxButtons.OK, MessageBoxIcon.Warning)
                Return
            End If

            Dim lines() As String = File.ReadAllLines(filePath)
            Dim newLines As New List(Of String)
            Dim charactersToDelete As New HashSet(Of String)()
            Dim charDisplayList As New List(Of String)()

            ' Collect characters to delete and prepare display list
            For Each item In CachedBox.CheckedItems
                Dim charName As String = item.ToString()
                ' Extract character name after the server prefix (UI only)
                If charName.Contains(" - ") Then
                    charName = charName.Substring(charName.IndexOf(" - ") + 3).Trim()
                End If
                charactersToDelete.Add(charName)
                charDisplayList.Add(charName)
            Next

            If charDisplayList.Count = 0 Then
                MessageBox.Show("No characters selected for deletion.", "Info", MessageBoxButtons.OK, MessageBoxIcon.Information)
                Return
            End If

            ' Confirmation dialog with characters listed
            Dim confirmMessage As String = "Are you sure you want to delete the following characters?" &
                                       Environment.NewLine & Environment.NewLine &
                                       String.Join(Environment.NewLine, charDisplayList)

            Dim confirmResult As DialogResult = MessageBox.Show(
            confirmMessage,
            "Confirm Deletion",
            MessageBoxButtons.YesNo,
            MessageBoxIcon.Warning
        )

            If confirmResult = DialogResult.No Then
                ' User canceled deletion
                Return
            End If

            ' Proceed with deletion
            Dim skipLines As Boolean = False
            Dim deletedBlocks As New List(Of List(Of String))() ' Each block is a list of lines
            Dim currentBlock As List(Of String) = Nothing

            For Each line As String In lines
                Dim shouldSkip As Boolean = False
                If line.StartsWith("#EU") OrElse line.StartsWith("#NA") Then
                    skipLines = False
                End If

                For Each charName In charactersToDelete
                    If line.Contains(charName) Then
                        shouldSkip = True
                        skipLines = True
                        currentBlock = New List(Of String)()
                        currentBlock.Add(line)
                        Exit For
                    End If
                Next

                If shouldSkip Then Continue For

                If skipLines Then
                    If currentBlock Is Nothing Then currentBlock = New List(Of String)()
                    currentBlock.Add(line)
                    ' End of block: next line is a new server or end of file
                    If line.StartsWith("#EU") OrElse line.StartsWith("#NA") Then
                        deletedBlocks.Add(New List(Of String)(currentBlock))
                        currentBlock = Nothing
                        skipLines = False
                    End If
                    Continue For
                ElseIf currentBlock IsNot Nothing Then
                    deletedBlocks.Add(New List(Of String)(currentBlock))
                    currentBlock = Nothing
                End If

                newLines.Add(line)
            Next

            ' Add any remaining block at EOF
            If currentBlock IsNot Nothing AndAlso currentBlock.Count > 0 Then
                deletedBlocks.Add(currentBlock)
            End If

            ' Write the updated file
            File.WriteAllLines(filePath, newLines)

            ' Log deleted blocks
            For Each block In deletedBlocks
                If block.Count > 0 Then
                    LogMessage($"Deleted cached character block: {block(0)}", logBox:=LogBox, logType:=LogType.Normal)
                End If
            Next
            LogMessage($"Total deleted cached character blocks: {deletedBlocks.Count}", logBox:=LogBox, logType:=LogType.Info)

            MessageBox.Show("Selected characters have been deleted successfully.", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information)

            ' Show detailed report if enabled
            If CheckBoxDetailedReport.Checked AndAlso deletedBlocks.Count > 0 Then
                Dim reportForm As New DeletionLogForm()
                Dim tree = reportForm.Controls.OfType(Of System.Windows.Forms.TreeView)().FirstOrDefault()
                If tree IsNot Nothing Then
                    tree.Nodes.Clear()
                    Dim fileNode = tree.Nodes.Add("AddOnSettings.txt")
                    For Each block In deletedBlocks
                        If block.Count > 0 Then
                            Dim blockNode = fileNode.Nodes.Add(block(0)) ' First line as summary
                            For i As Integer = 1 To block.Count - 1
                                blockNode.Nodes.Add(block(i))
                            Next
                        End If
                    Next
                    tree.ExpandAll()
                End If
                reportForm.ShowDialog(Me)
            End If
        Catch ex As Exception
            LogMessage("An error occurred: " & ex.Message, logBox:=LogBox, logType:=LogType.Error)
            MessageBox.Show("An error occurred: " & ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error)
        Finally
            FindAddOnSettingsFile()
        End Try
    End Sub


    Private Sub RedundantAddons_Click(sender As Object, e As EventArgs) Handles RedundantAddons.Click
        Try
            Dim parentDirectory As String = Directory.GetParent(selectedPath).FullName
            Dim filePath As String = Path.Combine(parentDirectory, "AddOnSettings.txt")
            If Not File.Exists(filePath) Then
                MessageBox.Show("AddOnSettings.txt file not found.", "File Not Found", MessageBoxButtons.OK, MessageBoxIcon.Warning)
                Return
            End If

            Dim addonsFolderPath As String = Path.Combine(parentDirectory, "AddOns")
            Dim txtFiles As String() = Directory.GetFiles(addonsFolderPath, "*.txt", SearchOption.AllDirectories).
    Select(Function(f) Path.GetFileNameWithoutExtension(f)).ToArray()

            Dim addonFiles As String() = Directory.GetFiles(addonsFolderPath, "*.addon", SearchOption.AllDirectories).
    Select(Function(f) Path.GetFileNameWithoutExtension(f)).ToArray()

            Dim allFiles As String() = txtFiles.Concat(addonFiles).ToArray()

            Dim lines() As String = File.ReadAllLines(filePath)
            Dim newLines As New List(Of String)
            Dim deletedLines As New List(Of String)

            ProgressBar1.Minimum = 0
            ProgressBar1.Maximum = lines.Length
            ProgressBar1.Value = 0
            ProgressBar1.Visible = True

            For i As Integer = 0 To lines.Length - 1
                Dim line As String = lines(i).Trim()
                If i < 4 OrElse line.StartsWith("#EU Megaserver") OrElse line.StartsWith("#NA Megaserver") Then
                    newLines.Add(line)
                    ProgressBar1.Value += 1
                    Continue For
                End If

                Dim addonName As String = line.Split(" "c)(0).Trim()
                Dim matchFound As Boolean = allFiles.Any(Function(file) String.Equals(addonName, file, StringComparison.OrdinalIgnoreCase))
                If Not matchFound Then
                    deletedLines.Add(line)
                    ProgressBar1.Value += 1
                    Continue For
                End If

                newLines.Add(line)
                ProgressBar1.Value += 1
                If ProgressBar1.Value > ProgressBar1.Maximum Then ProgressBar1.Value = ProgressBar1.Maximum
            Next

            File.WriteAllLines(filePath, newLines)

            If deletedLines.Count > 0 Then
                LogMessage($"Total deleted lines: {deletedLines.Count}", logBox:=LogBox, logType:=LogType.Info)
                MessageBox.Show($"Deleted {deletedLines.Count} line(s) of old addon data", "Old Addon Data", MessageBoxButtons.OK, MessageBoxIcon.Information)
                ' Show detailed report if enabled
                If CheckBoxDetailedReport.Checked Then
                    Dim reportForm As New DeletionLogForm()
                    Dim tree = reportForm.Controls.OfType(Of System.Windows.Forms.TreeView)().FirstOrDefault()
                    If tree IsNot Nothing Then
                        tree.Nodes.Clear()
                        Dim fileNode = tree.Nodes.Add(Path.GetFileName(filePath))
                        For Each line In deletedLines
                            fileNode.Nodes.Add(line)
                        Next
                        tree.ExpandAll()
                    End If
                    reportForm.ShowDialog(Me)
                End If
            Else
                LogMessage("No old addon data found to delete.", logBox:=LogBox, logType:=LogType.Warning)
                MessageBox.Show("No old addon data found.", "Old Addon Data", MessageBoxButtons.OK, MessageBoxIcon.Information)
            End If
        Catch ex As Exception
            LogMessage("An error occurred: " & ex.Message, logBox:=LogBox, logType:=LogType.Error)
            MessageBox.Show("An error occurred: " & ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error)
        Finally
            ProgressBar1.Value = 0
        End Try
    End Sub
End Class
