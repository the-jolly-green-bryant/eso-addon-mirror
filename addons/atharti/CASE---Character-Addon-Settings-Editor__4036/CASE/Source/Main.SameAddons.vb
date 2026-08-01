Imports System.IO
Imports System.Text.RegularExpressions

Partial Public Class MainWindow
    Private Sub EnableSameAddons(sourceName As String, targetNames As List(Of String))
        Try
            ' Find AddOnSettings.txt
            Dim parentDirectory As String = Directory.GetParent(selectedPath).FullName
            Dim filePath As String = Path.Combine(parentDirectory, "AddOnSettings.txt")
            If Not File.Exists(filePath) Then
                LogMessage("AddOnSettings.txt Not found, cannot enable same addons.", logBox:=LogBox2, logType:=LogType.Warning)
                Return
            End If
            Dim lines As List(Of String) = File.ReadAllLines(filePath).ToList()
            Dim serverPrefix As String = If(ServerEU.Checked, "#EU Megaserver-", "#NA Megaserver-")
            Dim sourceBlockHeaderPattern As String = "^#(EU|NA) Megaserver-" & Regex.Escape(sourceName) & "$"
            Dim sourceBlockStart As Integer = -1
            Dim sourceBlockEnd As Integer = -1
            ' Find source block
            For i = 0 To lines.Count - 1
                If Regex.IsMatch(lines(i), sourceBlockHeaderPattern) Then
                    sourceBlockStart = i
                    ' Find end of block
                    sourceBlockEnd = lines.Count - 1
                    For j = i + 1 To lines.Count - 1
                        If Regex.IsMatch(lines(j), "^#(EU|NA) Megaserver-.*$") Then
                            sourceBlockEnd = j - 1
                            Exit For
                        End If
                    Next
                    Exit For
                End If
            Next
            If sourceBlockStart = -1 Then
                LogMessage("Source block not found in AddOnSettings.txt for " & sourceName, logBox:=LogBox2, logType:=LogType.Warning)
                Return
            End If
            Dim sourceBlock As List(Of String) = lines.GetRange(sourceBlockStart, sourceBlockEnd - sourceBlockStart + 1)
            ' For each target character
            For Each targetName In targetNames
                If targetName = sourceName Then Continue For
                Dim targetHeader As String = serverPrefix & targetName
                ' Find if target block exists
                Dim targetBlockStart As Integer = -1
                Dim targetBlockEnd As Integer = -1
                For i = 0 To lines.Count - 1
                    If lines(i).Trim() = targetHeader Then
                        targetBlockStart = i
                        targetBlockEnd = lines.Count - 1
                        For j = i + 1 To lines.Count - 1
                            If Regex.IsMatch(lines(j), "^#(EU|NA) Megaserver-.*$") Then
                                targetBlockEnd = j - 1
                                Exit For
                            End If
                        Next
                        Exit For
                    End If
                Next
                ' Prepare new block for target
                Dim newBlock As New List(Of String)(sourceBlock)
                newBlock(0) = targetHeader ' Replace header
                If targetBlockStart <> -1 Then
                    ' Replace existing block
                    lines.RemoveRange(targetBlockStart, targetBlockEnd - targetBlockStart + 1)
                    lines.InsertRange(targetBlockStart, newBlock)
                    LogMessage($"Updated AddOnSettings.txt block for {targetName}.", logBox:=LogBox2, logType:=LogType.Normal)
                Else
                    ' Append at end (no extra blank line)
                    lines.AddRange(newBlock)
                    LogMessage($"Added AddOnSettings.txt block for {targetName}.", logBox:=LogBox2, logType:=LogType.Normal)
                End If
            Next
            File.WriteAllLines(filePath, lines)
            LogMessage("AddOnSettings.txt updated for selected characters.", logBox:=LogBox2, logType:=LogType.Info)
        Catch ex As Exception
            LogMessage("Error updating AddOnSettings.txt: " & ex.Message, logBox:=LogBox2, logType:=LogType.Error)
        End Try
    End Sub
End Class
