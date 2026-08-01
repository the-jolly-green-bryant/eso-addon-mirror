Imports System.IO
Imports System.Text.RegularExpressions

Partial Public Class MainWindow
    Private Sub TransferSettings_Click(sender As Object, e As EventArgs) Handles TransferSettings.Click

        If SettingsSource.SelectedItem Is Nothing OrElse SettingsTarget.CheckedItems.Count = 0 OrElse SettingsList.CheckedItems.Count = 0 Then
            MessageBox.Show("Please select a source character, at least one target character, and at least one file.")
            Return
        End If
        Dim sourceName = SettingsSource.SelectedItem.ToString
        If Not characterMap.ContainsKey(sourceName) Then
            MessageBox.Show("Source character not found in character list.")
            Return
        End If
        Dim sourceId = characterMap(sourceName)
        Dim targetNames As New List(Of String)
        For Each item In SettingsTarget.CheckedItems
            targetNames.Add(item.ToString)
        Next
        Dim fileNames As New List(Of String)
        For Each item In SettingsList.CheckedItems
            fileNames.Add(item.ToString)
        Next
        Dim filesToEdit = GetLuaFiles.Where(Function(f) fileNames.Contains(Path.GetFileName(f))).ToList

        SetupProgressBar(0, If(filesToEdit.Count > 0, filesToEdit.Count, 1))
        Dim anyFileChanged = False
        Dim settingsEdited = 0
        Dim settingsCreated = 0
        Dim selectedServer = If(ServerEU.Checked, "EU Megaserver", "NA Megaserver")
        Dim transferLog As New Dictionary(Of String, Dictionary(Of String, List(Of String)))
        ' Build character-to-account map from ZO_Ingame.lua for correct placement of new blocks
        Dim charToAccount As Dictionary(Of String, String) = GetCharacterToAccountMapFromZOIngame(selectedPath)

        ProgressBar1.Maximum = If(filesToEdit.Count > 0, filesToEdit.Count, 1)
        For Each filePath In filesToEdit
            Dim fileNameOnly = Path.GetFileName(filePath)
            Dim lines = File.ReadAllLines(filePath).ToList
            Dim fileChanged = False
            LogMessage($"Processing file: {fileNameOnly}", logBox:=LogBox2, logType:=LogType.Normal)
            ' --- Find source block (skip id-to-name lines) ---
            Dim sourceBlock As List(Of String) = Nothing
            Dim sourceBlockStart = -1
            Dim sourceBlockEnd = -1
            Dim sourceHeaderIndent = ""
            Dim sourceKeyType As String = Nothing
            For Each key In New String() {sourceId, sourceName}
                For i = 0 To lines.Count - 1
                    ' Only process blocks where line matches ["actualKey"] = and nothing after = except whitespace
                    Dim keyPattern = "^\s*\[""(" & Regex.Escape(key) & ")""\]\s*=\s*$"
                    If Not Regex.IsMatch(lines(i), keyPattern) Then Continue For
                    Dim m = Regex.Match(lines(i), "^(\s*)\[""([^""\]]+)""\]\s*=")
                    If m.Success AndAlso m.Groups(2).Value = key Then
                        sourceHeaderIndent = m.Groups(1).Value
                        sourceKeyType = If(key = sourceId, "id", "name")
                        ' Find block start (line with {)
                        Dim blockStart = i
                        While blockStart < lines.Count AndAlso Not lines(blockStart).Contains("{")
                            blockStart += 1
                        End While
                        If blockStart >= lines.Count Then Continue For
                        ' Find block end (matching })
                        Dim braceCount = 0
                        Dim blockEnd = blockStart
                        For j = blockStart To lines.Count - 1
                            braceCount += lines(j).Count(Function(c) c = "{"c)
                            braceCount -= lines(j).Count(Function(c) c = "}"c)
                            If braceCount = 0 Then
                                blockEnd = j
                                Exit For
                            End If
                        Next
                        If blockEnd > blockStart Then
                            sourceBlock = lines.GetRange(blockStart, blockEnd - blockStart + 1)
                            sourceBlockStart = blockStart
                            sourceBlockEnd = blockEnd
                            Exit For
                        End If
                    End If
                Next
                If sourceBlock IsNot Nothing Then Exit For
            Next
            If sourceBlock Is Nothing Then
                LogMessage($"Source block not found in {fileNameOnly}. Skipping file.", logBox:=LogBox2, logType:=LogType.Warning)
                ProgressBar1.Value += 1
                Continue For
            End If
            ' --- For each target character ---
            For Each targetName In targetNames
                If targetName = sourceName Then Continue For
                If Not characterMap.ContainsKey(targetName) Then Continue For
                Dim targetId = characterMap(targetName)
                ' DEBUG: Show which account the target character belongs to
                Dim targetAccount As String = Nothing
                If charToAccount.ContainsKey(targetId) Then
                    targetAccount = charToAccount(targetId)
                ElseIf charToAccount.ContainsKey(targetName) Then
                    targetAccount = charToAccount(targetName)
                End If
                Dim clonedBlock = sourceBlock.Select(Function(l)
                                                         Dim line = l.Replace(sourceName, targetName).Replace(sourceId, targetId)
                                                         If Regex.IsMatch(line, "^\s*\[""(EU|NA) Megaserver""\]") Then
                                                             Return Regex.Replace(line, "^\s*\[""(EU|NA) Megaserver""\]", l.Substring(0, l.IndexOf("[")) & "[""" & selectedServer & """]")
                                                         ElseIf Regex.IsMatch(line, "^\s*\[""(EU|NA) Megaserver""\]\s*=") Then
                                                             Return Regex.Replace(line, "^\s*\[""(EU|NA) Megaserver""\]\s*=", l.Substring(0, l.IndexOf("[")) & "[""" & selectedServer & """] =")
                                                         Else
                                                             Return line
                                                         End If
                                                     End Function).ToList
                ' Remove the first line if it is a header (to avoid duplicate)
                If clonedBlock.Count > 0 AndAlso Regex.IsMatch(clonedBlock(0), "^\s*\[""([^""\]]+)""\]\s*=\s*") Then
                    clonedBlock.RemoveAt(0)
                End If
                Dim newBlock = New List(Of String)(clonedBlock)
                ' --- Find target block (skip id-to-name lines) ---
                Dim foundTargetBlock = False
                Dim targetBlockStart = -1
                Dim targetBlockEnd = -1
                For Each tkey In New String() {targetId, targetName}
                    For i = 0 To lines.Count - 1
                        ' Match ["actualKey"] = (with or without {, allow whitespace)
                        Dim keyPattern = "^\s*\[""(" & Regex.Escape(tkey) & ")""\]\s*=\s*(\{)?\s*$"
                        If Not Regex.IsMatch(lines(i), keyPattern) Then Continue For
                        Dim m = Regex.Match(lines(i), "^\s*\[""([^""\]]+)""\]\s*=")
                        If m.Success AndAlso m.Groups(1).Value = tkey Then
                            Dim blockStart = i
                            ' Advance to opening brace if not on this line
                            If Not lines(blockStart).TrimEnd().EndsWith("{") Then
                                While blockStart + 1 < lines.Count AndAlso Not lines(blockStart + 1).TrimStart().StartsWith("{")
                                    blockStart += 1
                                End While
                                If blockStart + 1 < lines.Count AndAlso lines(blockStart + 1).TrimStart().StartsWith("{") Then
                                    blockStart += 1
                                End If
                            End If
                            ' Now at opening brace
                            Dim braceCount = 1
                            Dim blockEnd = blockStart + 1
                            While blockEnd < lines.Count AndAlso braceCount > 0
                                braceCount += lines(blockEnd).Count(Function(c) c = "{"c)
                                braceCount -= lines(blockEnd).Count(Function(c) c = "}"c)
                                blockEnd += 1
                            End While
                            blockEnd -= 1 ' Last line with closing brace
                            If blockEnd > blockStart Then
                                targetBlockStart = i
                                ' Move start to actual opening brace line
                                While targetBlockStart < lines.Count AndAlso Not lines(targetBlockStart).Contains("{")
                                    targetBlockStart += 1
                                End While
                                targetBlockEnd = blockEnd
                                foundTargetBlock = True
                                Exit For
                            End If
                        End If
                    Next
                    If foundTargetBlock Then Exit For
                Next
                If foundTargetBlock AndAlso targetBlockStart >= 0 AndAlso targetBlockEnd >= targetBlockStart Then
                    ' Prepend header for report
                    Dim headerKey = If(sourceKeyType = "id", targetId, targetName)
                    Dim headerLine = sourceHeaderIndent & "[""" & headerKey & """] ="
                    Dim reportBlock = New List(Of String)(newBlock)
                    reportBlock.Insert(0, headerLine)
                    lines.RemoveRange(targetBlockStart, targetBlockEnd - targetBlockStart + 1)
                    lines.InsertRange(targetBlockStart, newBlock)
                    fileChanged = True
                    settingsEdited += 1
                    LogMessage($"Replaced settings For {targetName} In {fileNameOnly}.", logBox:=LogBox2, logType:=LogType.Normal)
                    If Not transferLog.ContainsKey(fileNameOnly) Then transferLog(fileNameOnly) = New Dictionary(Of String, List(Of String))
                    transferLog(fileNameOnly)(targetName & " (edited)") = reportBlock
                End If
                ' If not found, try to insert under the correct account block
                If Not foundTargetBlock Then
                    If targetAccount IsNot Nothing Then
                        ' Find account block header
                        Dim accPattern As New Regex("^\s*\[""" & Regex.Escape(targetAccount) & """\]\s*=\s*(\{)?\s*$")
                        Dim accHeaderLine As Integer = -1
                        For i = 0 To lines.Count - 1
                            If accPattern.IsMatch(lines(i)) Then
                                accHeaderLine = i
                                Exit For
                            End If
                        Next
                        If accHeaderLine <> -1 Then
                            ' Advance to opening brace if not on this line
                            Dim braceLine = accHeaderLine
                            If Not lines(braceLine).TrimEnd().EndsWith("{") Then
                                While braceLine + 1 < lines.Count AndAlso Not lines(braceLine + 1).TrimStart().StartsWith("{")
                                    braceLine += 1
                                End While
                                If braceLine + 1 < lines.Count AndAlso lines(braceLine + 1).TrimStart().StartsWith("{") Then
                                    braceLine += 1
                                End If
                            End If
                            ' Find end of account block
                            Dim braceCount = 1
                            Dim blockEnd = braceLine + 1
                            While blockEnd < lines.Count AndAlso braceCount > 0
                                braceCount += lines(blockEnd).Count(Function(c) c = "{"c)
                                braceCount -= lines(blockEnd).Count(Function(c) c = "}"c)
                                blockEnd += 1
                            End While
                            blockEnd -= 1 ' Last line with closing brace
                            ' Insert before closing brace
                            If blockEnd > braceLine Then
                                Dim headerKey = If(sourceKeyType = "id", targetId, targetName)
                                Dim headerLine = sourceHeaderIndent & "[""" & headerKey & """] ="
                                If newBlock.Count = 0 OrElse Not Regex.IsMatch(newBlock(0), "^\s*\[""([^""\]]+)""\]\s*=\s*$") Then
                                    newBlock.Insert(0, headerLine)
                                End If
                                lines.InsertRange(blockEnd, newBlock)
                                fileChanged = True
                                settingsCreated += 1
                                LogMessage($"Inserted settings For {targetName} In {fileNameOnly} (account {targetAccount}).", logBox:=LogBox2, logType:=LogType.Normal)
                                If Not transferLog.ContainsKey(fileNameOnly) Then transferLog(fileNameOnly) = New Dictionary(Of String, List(Of String))
                                transferLog(fileNameOnly)(targetName & " (created)") = New List(Of String)(newBlock)
                            End If
                        Else
                            LogMessage($"Account block for '{targetAccount}' not found in {fileNameOnly}. Block for {targetName} will NOT be created.", logBox:=LogBox2, logType:=LogType.Warning)
                        End If
                    End If
                End If
            Next
            If fileChanged Then
                File.WriteAllLines(filePath, lines)
                anyFileChanged = True
                LogMessage($"Saved changes to {fileNameOnly}.", logBox:=LogBox2, logType:=LogType.Info)
            End If
            ProgressBar1.Value += 1
        Next
        ProgressBar1.Value = ProgressBar1.Minimum
        ' Show summary if changes were made
        If anyFileChanged Then
            MessageBox.Show($"Settings transfer complete. {settingsEdited} settings edited, {settingsCreated} settings created.", "Transfer Complete")
            LogMessage("Settings transfer successful.", logBox:=LogBox2, logType:=LogType.Info)
            ' Enable same addons if requested
            If SameAddons.Checked Then
                EnableSameAddons(sourceName, targetNames)
            End If
            ' Show detailed report if requested
            If DetailedTransfer.Checked AndAlso transferLog.Count > 0 Then
                Dim reportForm As New DeletionLogForm ' Assuming Form2 is your report form
                Dim tree = reportForm.Controls.OfType(Of System.Windows.Forms.TreeView).FirstOrDefault
                If tree IsNot Nothing Then
                    tree.Nodes.Clear()

                    For Each fileKvp In transferLog
                        Dim fileNode = tree.Nodes.Add(fileKvp.Key)
                        For Each charKvp In fileKvp.Value
                            Dim charNode = fileNode.Nodes.Add(charKvp.Key)
                            For Each line In charKvp.Value
                                charNode.Nodes.Add(line)
                            Next
                        Next
                    Next
                    tree.ExpandAll()
                End If
                reportForm.ShowDialog(Me)
            End If
        Else
            MessageBox.Show("No changes would be made. Check your selections And try again.")
        End If
    End Sub
End Class
