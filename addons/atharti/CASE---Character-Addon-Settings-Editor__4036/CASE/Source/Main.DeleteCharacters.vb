Imports System.IO
Imports System.Text.RegularExpressions

Partial Public Class MainWindow
    Private Sub ButtonDelete_Click(sender As Object, e As EventArgs) Handles ButtonDelete.Click
        Dim characterList As New List(Of String)
        For Each row As DataGridViewRow In DataGridViewCharacters.Rows
            If Convert.ToBoolean(row.Cells(0).Value) Then
                characterList.Add(row.Cells(1).Value.ToString) ' Character name
                characterList.Add(row.Cells(2).Value.ToString) ' Character ID
            End If
        Next

        If characterList.Count = 0 Then
            MessageBox.Show("No characters selected for deletion.")
            Return
        End If

        ' Build a list of selected characters for display
        Dim charDisplayList As New List(Of String)
        For Each row As DataGridViewRow In DataGridViewCharacters.Rows
            If Convert.ToBoolean(row.Cells(0).Value) Then
                Dim charName = row.Cells(1).Value.ToString()
                Dim charID = row.Cells(2).Value.ToString()
                charDisplayList.Add($"{charName} (ID: {charID})")
            End If
        Next

        Dim charDisplayText As String = String.Join(Environment.NewLine, charDisplayList)

        ' Confirmation dialog with character list
        Dim confirmResult As DialogResult = MessageBox.Show(
    "Are you sure you want to delete the following characters?" & Environment.NewLine & Environment.NewLine & charDisplayText,
    "Confirm Deletion",
    MessageBoxButtons.YesNo,
    MessageBoxIcon.Warning
)


        If confirmResult = DialogResult.No Then
            ' User clicked No, cancel deletion
            Return
        End If

        Try
            Dim files = Directory.GetFiles(selectedPath, "*.lua")
            ProgressBar1.Minimum = 0
            ProgressBar1.Maximum = files.Length * 2 ' Include second pass
            ProgressBar1.Value = 0
            ProgressBar1.Visible = True
            Dim checkedCount = 0
            For Each row As DataGridViewRow In DataGridViewCharacters.Rows
                If Convert.ToBoolean(row.Cells(0).Value) Then checkedCount += 1
            Next
            LogMessage("Starting deletion of " & checkedCount & " character(s) from " & files.Length & " Lua files.", logBox:=LogBox, logType:=LogType.Normal)
            deletionLog.Clear()

            For Each file In files
                LogMessage("Processing file: " & Path.GetFileName(file), logBox:=LogBox, logType:=LogType.Normal)
                Dim lines = IO.File.ReadAllLines(file).ToList
                Dim deletedBlocks = 0
                Dim deletedItems As New List(Of String)
                Dim newLines = RemoveCharacterBlocksRecursive(lines, characterList, deletedBlocks, deletedItems, file)
                IO.File.WriteAllLines(file, newLines)
                LogMessage("Finished file: " & Path.GetFileName(file) & ". Deleted blocks: " & deletedBlocks, logBox:=LogBox, logType:=LogType.Normal)
                ProgressBar1.Value += 1
                If deletedItems.Count > 0 Then
                    deletionLog(Path.GetFileName(file)) = deletedItems
                End If
            Next

            ' Second pass: Remove indexed character blocks (numeric keys, nested tables) and reindex
            For Each file In files
                LogMessage("Second pass (indexed blocks): " & Path.GetFileName(file), logBox:=LogBox, logType:=LogType.Normal)
                Dim lines = IO.File.ReadAllLines(file).ToList
                Dim deletedBlocks2 = 0
                Dim deletedItems2 As New List(Of String)
                Dim newLines2 = RemoveIndexedCharacterBlocksAndReindex(lines, characterList, deletedBlocks2, deletedItems2)
                IO.File.WriteAllLines(file, newLines2)
                LogMessage("Second pass finished: " & Path.GetFileName(file) & ". Deleted indexed blocks: " & deletedBlocks2, logBox:=LogBox, logType:=LogType.Normal)
                ProgressBar1.Value += 1
                If deletedItems2.Count > 0 Then
                    If deletionLog.ContainsKey(Path.GetFileName(file)) Then
                        deletionLog(Path.GetFileName(file)).AddRange(deletedItems2)
                    Else
                        deletionLog(Path.GetFileName(file)) = deletedItems2
                    End If
                End If
            Next

            LogMessage("Selected characters deleted successfully.", logBox:=LogBox, logType:=LogType.Info)
            MessageBox.Show("Selected characters deleted successfully.")

            ' Show report after both passes, asynchronously to avoid UI freeze
            If CheckBoxDetailedReport.Checked AndAlso deletionLog.Count > 0 Then
                BeginInvoke(Sub()
                                Dim reportForm As New DeletionLogForm
                                Dim tree = reportForm.Controls.OfType(Of System.Windows.Forms.TreeView).FirstOrDefault
                                If tree IsNot Nothing Then
                                    tree.Nodes.Clear()
                                    For Each kvp In deletionLog
                                        Dim fileNode = tree.Nodes.Add(kvp.Key)
                                        For Each line In kvp.Value
                                            fileNode.Nodes.Add(line)
                                        Next
                                    Next
                                    tree.ExpandAll()
                                End If
                                AddHandler reportForm.FormClosed, Sub(sender2, e2)
                                                                      ScanLuaFiles()
                                                                      FindMostPopularName()
                                                                      FindAddOnSettingsFile()
                                                                  End Sub
                                reportForm.ShowDialog(Me)
                            End Sub)
            Else
                ' If no report, rescan immediately
                ScanLuaFiles()
                FindMostPopularName()
                FindAddOnSettingsFile()
            End If
        Catch ex As Exception
            MessageBox.Show("An error occurred while deleting character names/IDs: " & ex.Message)
        End Try
    End Sub


    ' Improved: Recursively process lines to remove any string-keyed block matching characterList at any nesting level
    ' Preserves all keys and structure, only removes the intended character blocks
    Private Function RemoveCharacterBlocksRecursive(lines As List(Of String), characterList As List(Of String), ByRef deletedBlocks As Integer, ByRef deletedItems As List(Of String), Optional currentFile As String = Nothing) As List(Of String)
        Dim newLines As New List(Of String)()
        Dim i As Integer = 0
        While i < lines.Count
            Dim line As String = lines(i)
            Dim leadingWhitespace As String = Regex.Match(line, "^\s*").Value
            Dim stringKeyBlockMatch As Match = Regex.Match(line, "^\s*\[""([^""]+)""\]\s*=")
            If stringKeyBlockMatch.Success Then
                Dim keyName As String = stringKeyBlockMatch.Groups(1).Value
                Dim isNameChangeBlock As Boolean = (keyName = "NameChange" AndAlso Not String.IsNullOrEmpty(currentFile) AndAlso Path.GetFileName(currentFile).Equals("ZO_Ingame.lua", StringComparison.OrdinalIgnoreCase))
                Dim shouldDeleteBlock As Boolean = characterList.Contains(keyName)
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
                    If isNameChangeBlock Then
                        For k As Integer = i To blockStartIdx - 1
                            newLines.Add(lines(k))
                        Next
                        newLines.Add(lines(blockStartIdx))
                        Dim j As Integer = blockStartIdx + 1
                        While j < blockEndIdx
                            Dim entryLine As String = lines(j)
                            Dim entryLeadingWhitespace As String = Regex.Match(entryLine, "^\s*").Value
                            Dim entryMatch As Match = Regex.Match(entryLine, "^\s*\[""(\d{16})""\]\s*=\s*""(.*?)""[\,\s]*$")
                            If entryMatch.Success Then
                                Dim entryId As String = entryMatch.Groups(1).Value
                                Dim entryName As String = entryMatch.Groups(2).Value
                                If characterList.Contains(entryId) OrElse characterList.Contains(entryName) Then
                                    deletedBlocks += 1
                                    deletedItems.Add(entryLine)
                                    j += 1
                                    Continue While
                                End If
                            End If
                            newLines.Add(entryLeadingWhitespace & entryLine.TrimStart())
                            j += 1
                        End While
                        newLines.Add(lines(blockEndIdx))
                        i = blockEndIdx + 1
                        Continue While
                    ElseIf shouldDeleteBlock Then
                        deletedBlocks += 1
                        For j As Integer = i To blockEndIdx
                            deletedItems.Add(lines(j))
                        Next
                        i = blockEndIdx + 1
                        Continue While
                    Else
                        For k As Integer = i To blockStartIdx
                            newLines.Add(lines(k))
                        Next
                        If blockEndIdx > blockStartIdx + 1 Then
                            Dim innerContent As List(Of String) = lines.GetRange(blockStartIdx + 1, blockEndIdx - blockStartIdx - 1)
                            Dim processedInner As List(Of String) = RemoveCharacterBlocksRecursive(innerContent, characterList, deletedBlocks, deletedItems, currentFile)
                            For Each innerLine In processedInner
                                Dim innerLeadingWhitespace As String = Regex.Match(innerLine, "^\s*").Value
                                newLines.Add(innerLeadingWhitespace & innerLine.TrimStart())
                            Next
                        End If
                        newLines.Add(lines(blockEndIdx))
                        i = blockEndIdx + 1
                        Continue While
                    End If
                End If
            End If
            newLines.Add(leadingWhitespace & line.TrimStart())
            i += 1
        End While
        Return newLines
    End Function

    ' Remove indexed character blocks (numeric keys, nested tables) and decrement only keys above deleted ones
    Private Function RemoveIndexedCharacterBlocksAndReindex(
        lines As List(Of String),
        characterList As List(Of String),
        ByRef deletedBlocks As Integer,
        ByRef deletedItems As List(Of String),
        Optional depth As Integer = 0
    ) As List(Of String)
        Const MaxDepth As Integer = 10
        Dim newLines As New List(Of String)()
        Dim i As Integer = 0
        While i < lines.Count
            Dim line As String = lines(i)
            Dim leadingWhitespace As String = Regex.Match(line, "^\s*").Value
            ' Handle string-keyed tables recursively
            Dim stringKeyMatch As Match = Regex.Match(line, "^\s*\[""([^""]+)""\]\s*=")
            If stringKeyMatch.Success Then
                ' Find the start and end of the block
                Dim blockStart As Integer = i
                Dim blockEnd As Integer = -1
                Dim braceCount As Integer = 0
                Dim foundBrace As Boolean = False
                For j As Integer = i To lines.Count - 1
                    If lines(j).Contains("{") Then
                        blockStart = j
                        foundBrace = True
                        Exit For
                    End If
                Next
                If foundBrace Then
                    braceCount = 0
                    For j As Integer = blockStart To lines.Count - 1
                        braceCount += lines(j).Count(Function(c) c = "{"c)
                        braceCount -= lines(j).Count(Function(c) c = "}"c)
                        If braceCount = 0 Then
                            blockEnd = j
                            Exit For
                        End If
                    Next
                End If
                If foundBrace AndAlso blockEnd > blockStart Then
                    Dim blockLen As Integer = blockEnd - blockStart - 1
                    Dim blockContent As List(Of String) = If(blockLen > 0, lines.GetRange(blockStart + 1, blockLen), New List(Of String)())
                    Dim processedInner As List(Of String) = RemoveIndexedCharacterBlocksAndReindex(blockContent, characterList, deletedBlocks, deletedItems, depth + 1)
                    ' Write out the block
                    For m As Integer = i To blockStart
                        newLines.Add(lines(m))
                    Next
                    newLines.AddRange(processedInner)
                    newLines.Add(lines(blockEnd))
                    i = blockEnd + 1
                    Continue While
                End If
            End If
            ' Numeric-keyed table: process all numeric blocks at this level as a group
            Dim numericKeyMatch As Match = Regex.Match(line, "^\s*\[(\d+)\]\s*=")
            If numericKeyMatch.Success Then
                ' Use a tuple as an array of objects (since VB.NET doesn't support named tuples in this context)
                Dim numericBlocks As New List(Of Object)()
                Dim deletedKeys As New List(Of Integer)()
                Dim scanIdx As Integer = i
                While scanIdx < lines.Count
                    Dim numMatch As Match = Regex.Match(lines(scanIdx), "^\s*\[(\d+)\]\s*=")
                    If numMatch.Success Then
                        Dim key As Integer = Integer.Parse(numMatch.Groups(1).Value)
                        ' Find block start (line with {)
                        Dim blockStart As Integer = scanIdx
                        Dim blockEnd As Integer = -1
                        Dim braceCount As Integer = 0
                        Dim foundBrace As Boolean = False
                        For j As Integer = scanIdx To lines.Count - 1
                            If lines(j).Contains("{") Then
                                blockStart = j
                                foundBrace = True
                                Exit For
                            End If
                        Next
                        If foundBrace Then
                            braceCount = 0
                            For j As Integer = blockStart To lines.Count - 1
                                braceCount += lines(j).Count(Function(c) c = "{"c)
                                braceCount -= lines(j).Count(Function(c) c = "}"c)
                                If braceCount = 0 Then
                                    blockEnd = j
                                    Exit For
                                End If
                            Next
                        End If
                        If blockEnd > blockStart Then
                            Dim blockLines = New List(Of String)()
                            For k = scanIdx To blockEnd
                                blockLines.Add(lines(k))
                            Next
                            ' Check if this block should be deleted
                            Dim blockContent = If(blockEnd > blockStart, lines.GetRange(blockStart + 1, blockEnd - blockStart), New List(Of String)())
                            Dim foundInBlock As Boolean = False
                            For Each blockLine In blockContent
                                For Each charKey In characterList
                                    If blockLine.Contains(charKey) Then
                                        foundInBlock = True
                                        Exit For
                                    End If
                                Next
                                If foundInBlock Then Exit For
                            Next
                            If Not foundInBlock AndAlso blockContent.Count > 0 AndAlso depth < MaxDepth Then
                                blockContent = RemoveIndexedCharacterBlocksAndReindex(blockContent, characterList, deletedBlocks, deletedItems, depth + 1)
                            End If
                            If foundInBlock Then
                                deletedKeys.Add(key)
                            End If
                            numericBlocks.Add(New Object() {key, scanIdx, blockEnd, blockLines, foundInBlock})
                            scanIdx = blockEnd + 1
                        Else
                            Exit While
                        End If
                    Else
                        Exit While
                    End If
                End While
                ' Write all numeric blocks, skipping deleted, and decrement keys above deleted ones
                For Each blockObj In numericBlocks
                    Dim arr = CType(blockObj, Object())
                    Dim key As Integer = CInt(arr(0))
                    Dim startIdx As Integer = CInt(arr(1))
                    Dim endIdx As Integer = CInt(arr(2))
                    Dim blockLines As List(Of String) = CType(arr(3), List(Of String))
                    Dim toDelete As Boolean = CBool(arr(4))
                    If toDelete Then
                        deletedBlocks += 1
                        For Each l In blockLines
                            deletedItems.Add(l)
                        Next
                    Else
                        Dim decrement = deletedKeys.Where(Function(dk) dk < key).Count()
                        Dim newKey = key - decrement
                        Dim headerLine = blockLines(0)
                        Dim headerMatch = Regex.Match(headerLine, "^\s*\[(\d+)\]\s*=")
                        If headerMatch.Success AndAlso decrement > 0 Then
                            Dim newHeader = Regex.Replace(headerLine, "^\s*\[\d+\]\s*=", leadingWhitespace & "[" & newKey.ToString() & "] =")
                            blockLines(0) = newHeader
                        End If
                        newLines.AddRange(blockLines)
                    End If
                Next
                If numericBlocks.Count > 0 Then
                    i = CType(CType(numericBlocks(numericBlocks.Count - 1), Object())(2), Integer) + 1
                    Continue While
                End If
            End If
            newLines.Add(leadingWhitespace & line.TrimStart())
            i += 1
        End While
        Return newLines
    End Function

End Class
