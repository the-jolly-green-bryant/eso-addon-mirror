Imports System.IO
Imports System.Text.RegularExpressions

Partial Public Class MainWindow

    Public Sub UpdateAccountsFromTheFile()
        AccountSource.Items.Clear()


        If String.IsNullOrEmpty(selectedPath) Then Return

        Dim zoIngamePath = Path.Combine(selectedPath, "ZO_Ingame.lua")
        If Not File.Exists(zoIngamePath) Then Return

        ' Only match lines like: ["@account"] =   (with nothing after = except whitespace)
        Dim regex As New Regex("^\s*\[""(@[^""]+)""\]\s*=\s*$", RegexOptions.Compiled)
        Try
            For Each line In File.ReadLines(zoIngamePath)
                Dim m = regex.Match(line)
                If m.Success Then
                    Dim account = m.Groups(1).Value
                    If Not AccountSource.Items.Contains(account) Then
                        AccountSource.Items.Add(account)
                    End If
                End If
            Next
            ' Select first item in AccountSource if available
            If AccountSource.Items.Count > 0 Then
                AccountSource.SelectedIndex = 0
            End If
        Catch ex As Exception
            MessageBox.Show("Error reading ZO_Ingame.lua: " & ex.Message)
        End Try
    End Sub


    Private Sub DeleteAccount_Click(sender As Object, e As EventArgs) Handles DeleteAccount.Click
        If AccountSource.SelectedItem Is Nothing Then
            MessageBox.Show("Please select an account to delete.")
            Return
        End If

        Dim accountToRemove As String = AccountSource.SelectedItem.ToString()
        If String.IsNullOrWhiteSpace(accountToRemove) Then
            MessageBox.Show("Invalid account selected.")
            Return
        End If

        ' Confirmation dialog
        Dim confirmResult As DialogResult = MessageBox.Show(
        $"Are you sure you want to delete the account '{accountToRemove}'?",
        "Confirm Deletion",
        MessageBoxButtons.YesNo,
        MessageBoxIcon.Warning
    )

        If confirmResult = DialogResult.No Then
            ' User clicked No, cancel deletion
            Return
        End If

        If String.IsNullOrEmpty(selectedPath) OrElse Not Directory.Exists(selectedPath) Then
            MessageBox.Show("No folder selected or folder does not exist.")
            Return
        End If

        Dim files = Directory.GetFiles(selectedPath, "*.lua")
        ProgressBar1.Minimum = 0
        ProgressBar1.Maximum = files.Length
        ProgressBar1.Value = 0
        Dim totalDeletedBlocks As Integer = 0
        Dim reportData As New Dictionary(Of String, List(Of List(Of String)))

        For Each filePath In files
            Dim lines = File.ReadAllLines(filePath).ToList()
            Dim deletedBlocksInFile As Integer = 0
            Dim deletedItems As New List(Of String)()
            Dim deletedBlocksList As New List(Of List(Of String))()
            Dim newLines = RemoveAccountBlocksRecursiveWithBlocks(lines, accountToRemove, deletedBlocksInFile, deletedItems, deletedBlocksList)
            File.WriteAllLines(filePath, newLines)
            totalDeletedBlocks += deletedBlocksInFile
            LogMessage($"Deleted {deletedBlocksInFile} block(s) for account '{accountToRemove}' in {Path.GetFileName(filePath)}", logBox:=LogBox, logType:=LogType.Normal)
            If deletedBlocksList.Count > 0 Then
                reportData(Path.GetFileName(filePath)) = deletedBlocksList
            End If

            ProgressBar1.Value += 1
        Next

        ProgressBar1.Value = ProgressBar1.Maximum
        ProgressBar1.Value = 0

        ' Log success if any blocks were deleted
        If totalDeletedBlocks > 0 Then
            LogMessage($"Successfully removed account data for '{accountToRemove}' from all files.", LogBox, LogType.Info)

        End If

        ' Refresh UI and data after deletion
        ScanLuaFiles()
        PopulateSTransferControls()
        UpdateAccountsFromTheFile()
        FindMostPopularName()

        If CheckBoxDetailedReport.Checked AndAlso reportData.Count > 0 Then
            Dim reportForm As New DeletionLogForm()
            Dim tree = reportForm.Controls.OfType(Of System.Windows.Forms.TreeView)().FirstOrDefault()
            If tree IsNot Nothing Then
                tree.Nodes.Clear()
                For Each fileKvp In reportData
                    Dim fileNode = tree.Nodes.Add(fileKvp.Key)
                    For Each blockLines In fileKvp.Value
                        Dim blockNode = fileNode.Nodes.Add("#")
                        For Each line In blockLines
                            blockNode.Nodes.Add(line)
                        Next
                    Next
                Next
                tree.ExpandAll()
            End If
            reportForm.ShowDialog(Me)
        Else
            MessageBox.Show($"Deleted {totalDeletedBlocks} block(s) for account '{accountToRemove}' in all files.")
            UpdateAccountsFromTheFile()
        End If
    End Sub


    ' Recursive block removal for account blocks (string-keyed), tracks deleted blocks as lists of lines
    Private Function RemoveAccountBlocksRecursiveWithBlocks(lines As List(Of String), accountName As String, ByRef deletedBlocks As Integer, ByRef deletedItems As List(Of String), ByRef deletedBlocksList As List(Of List(Of String))) As List(Of String)
        Dim newLines As New List(Of String)()
        Dim i As Integer = 0
        While i < lines.Count
            Dim line As String = lines(i)
            Dim stringKeyBlockMatch As Match = Regex.Match(line, "^\s*\[\""([^\""]+)\""\]\s*=")
            If stringKeyBlockMatch.Success Then
                Dim keyName As String = stringKeyBlockMatch.Groups(1).Value
                If keyName = accountName Then
                    ' Found account block, remove it
                    Dim blockStartIdx As Integer = i
                    Dim blockEndIdx As Integer = -1
                    Dim braceCount As Integer = 0
                    Dim foundBrace As Boolean = False
                    For j As Integer = i To lines.Count - 1
                        If lines(j).Contains("{") Then
                            blockStartIdx = j
                            foundBrace = True
                            Exit For
                        End If
                    Next
                    If foundBrace Then
                        braceCount = 0
                        For j As Integer = blockStartIdx To lines.Count - 1
                            braceCount += lines(j).Count(Function(c) c = "{"c)
                            braceCount -= lines(j).Count(Function(c) c = "}"c)
                            If braceCount = 0 Then
                                blockEndIdx = j
                                Exit For
                            End If
                        Next
                    End If
                    If foundBrace AndAlso blockEndIdx >= blockStartIdx Then
                        deletedBlocks += 1
                        Dim blockLines As New List(Of String)()
                        For j As Integer = i To blockEndIdx
                            deletedItems.Add(lines(j))
                            blockLines.Add(lines(j))
                        Next
                        deletedBlocksList.Add(blockLines)
                        i = blockEndIdx + 1
                        Continue While
                    End If
                Else
                    ' Not the account block, but could be nested, so process recursively
                    Dim blockStartIdx As Integer = i
                    Dim blockEndIdx As Integer = -1
                    Dim braceCount As Integer = 0
                    Dim foundBrace As Boolean = False
                    For j As Integer = i To lines.Count - 1
                        If lines(j).Contains("{") Then
                            blockStartIdx = j
                            foundBrace = True
                            Exit For
                        End If
                    Next
                    If foundBrace Then
                        braceCount = 0
                        For j As Integer = blockStartIdx To lines.Count - 1
                            braceCount += lines(j).Count(Function(c) c = "{"c)
                            braceCount -= lines(j).Count(Function(c) c = "}"c)
                            If braceCount = 0 Then
                                blockEndIdx = j
                                Exit For
                            End If
                        Next
                    End If
                    If foundBrace AndAlso blockEndIdx > blockStartIdx Then
                        For k As Integer = i To blockStartIdx
                            newLines.Add(lines(k))
                        Next
                        Dim innerContent As List(Of String) = lines.GetRange(blockStartIdx + 1, blockEndIdx - blockStartIdx - 1)
                        Dim processedInner As List(Of String) = RemoveAccountBlocksRecursiveWithBlocks(innerContent, accountName, deletedBlocks, deletedItems, deletedBlocksList)
                        newLines.AddRange(processedInner)
                        newLines.Add(lines(blockEndIdx))
                        i = blockEndIdx + 1
                        Continue While
                    End If
                End If
            End If
            newLines.Add(line)
            i += 1
        End While
        Return newLines
    End Function
End Class
