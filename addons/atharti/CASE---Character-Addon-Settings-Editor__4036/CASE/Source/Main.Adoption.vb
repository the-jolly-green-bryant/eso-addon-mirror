Imports System.IO
Imports System.Text.RegularExpressions

Partial Public Class MainWindow
    ' ----------------- Update Functions -----------------
    Private Sub UpdateAcc_Click(sender As Object, e As EventArgs) Handles UpdateAcc.Click

        Dim oldAccountName = AccNameOld.Text.Trim
        Dim newAccountName = AccNameNew.Text.Trim
        If String.IsNullOrEmpty(oldAccountName) Or String.IsNullOrEmpty(newAccountName) Then
            MessageBox.Show("Please ensure both old and new account names are provided.")
            Return
        End If

        Try
            Dim files = GetLuaFiles()
            SetupProgressBar(0, files.Length)

            ' Dictionary to track replacements per file
            Dim replacementsPerFile As New Dictionary(Of String, Integer)
            Dim totalReplacements As Integer = 0

            For Each filePath In files
                LogMessage($"Processing file for account update: {Path.GetFileName(filePath)}")
                Dim lines = File.ReadAllLines(filePath).ToList
                Dim updated = False
                Dim replacementsInFile As Integer = 0

                For i = 0 To lines.Count - 1
                    Dim line = lines(i)
                    If line.Contains(oldAccountName) Then
                        Dim count As Integer = Regex.Matches(line, Regex.Escape(oldAccountName)).Count
                        line = line.Replace(oldAccountName, newAccountName)
                        updated = True
                        replacementsInFile += count
                    End If
                    lines(i) = line
                Next

                If updated Then
                    File.WriteAllLines(filePath, lines)
                    replacementsPerFile(Path.GetFileName(filePath)) = replacementsInFile
                    totalReplacements += replacementsInFile
                End If

                ProgressBar1.Value += 1
            Next

            ' Show final summary
            If replacementsPerFile.Count = 0 Then
                MessageBox.Show("The old account name was not found in any files. Please provide a correct account name.")
            Else
                Dim summary As String = $"Account '{oldAccountName}' was replaced with '{newAccountName}' in {totalReplacements} occurrence(s) across {replacementsPerFile.Count} file(s)."
                MessageBox.Show(summary, "Account Update Summary", MessageBoxButtons.OK, MessageBoxIcon.Information)
                LogMessage(summary, logBox:=LogBox, logType:=LogType.Info) ' Clone message to log
            End If

        Catch ex As Exception
            LogMessage("An error occurred while updating account names: " & ex.Message, logBox:=LogBox, logType:=LogType.Error)
            MessageBox.Show("An error occurred while updating account names: " & ex.Message)
        Finally
            ProgressBar1.Value = 0
        End Try
        ' ScanLuaFiles()
        FindMostPopularName()
    End Sub


    Private Sub UpdateChar_Click(sender As Object, e As EventArgs) Handles UpdateChar.Click
        Dim oldCharacterName As String = Nothing
        If OldCharBox.SelectedItem IsNot Nothing Then oldCharacterName = OldCharBox.SelectedItem.ToString
        Dim newCharacterName = NewCharName.Text.Trim
        If String.IsNullOrEmpty(oldCharacterName) Or String.IsNullOrEmpty(newCharacterName) Then
            MessageBox.Show("Please ensure both old and new character names are selected/provided.")
            Return
        End If

        Try
            Dim files = GetLuaFiles()
            SetupProgressBar(0, files.Length)

            Dim replacementsPerFile As New Dictionary(Of String, Integer)
            Dim totalReplacements As Integer = 0
            Dim regex As Regex = Nothing

            Try
                regex = New Regex("(" & Regex.Escape(oldCharacterName) & ")", RegexOptions.Compiled)
            Catch ex As Exception
                MessageBox.Show("Regex error: " & ex.Message)
                Return
            End Try

            For Each filePath In files
                LogMessage($"Processing file for character name update: {Path.GetFileName(filePath)}", logBox:=LogBox, logType:=LogType.Normal)
                Dim lines = File.ReadAllLines(filePath).ToList
                Dim updatedLines As New List(Of String)
                Dim replacementsInFile As Integer = 0
                Dim changed As Boolean = False

                For Each line In lines
                    If line.Trim.StartsWith("[=""@") Then
                        updatedLines.Add(line)
                    Else
                        If regex.IsMatch(line) AndAlso Not line.Contains("@" & oldCharacterName) Then
                            Dim count As Integer = regex.Matches(line).Count
                            line = regex.Replace(line, newCharacterName)
                            replacementsInFile += count
                            changed = True
                        End If
                        updatedLines.Add(line)
                    End If
                Next

                If changed Then
                    File.WriteAllLines(filePath, updatedLines)
                    replacementsPerFile(Path.GetFileName(filePath)) = replacementsInFile
                    totalReplacements += replacementsInFile
                End If

                ProgressBar1.Value += 1
            Next

            ' Final summary
            If replacementsPerFile.Count = 0 Then
                LogMessage("No files contained the old character name.", logBox:=LogBox, logType:=LogType.Warning)
                MessageBox.Show("The old character name was not found in any files. Please provide a correct character name.")
            Else
                Dim summary As String = $"Character '{oldCharacterName}' was replaced with '{newCharacterName}' in {totalReplacements} occurrence(s) across {replacementsPerFile.Count} file(s)."
                LogMessage(summary, logBox:=LogBox, logType:=LogType.Info)
                MessageBox.Show(summary, "Character Update Summary", MessageBoxButtons.OK, MessageBoxIcon.Information)
                ScanLuaFiles()
            End If

        Catch ex As Exception
            LogMessage("An error occurred while updating character names: " & ex.Message, logBox:=LogBox, logType:=LogType.Error)
            MessageBox.Show("An error occurred while updating character names: " & ex.Message)
        Finally
            ProgressBar1.Value = 0
        End Try
    End Sub


    Private Sub UpdateID_Click(sender As Object, e As EventArgs) Handles UpdateID.Click
        Dim oldCharacterID As String = Nothing
        If OldIDBox.SelectedItem IsNot Nothing Then oldCharacterID = OldIDBox.SelectedItem.ToString
        Dim newCharacterID = NewCharID.Text.Trim
        If String.IsNullOrEmpty(oldCharacterID) Or String.IsNullOrEmpty(newCharacterID) Then
            MessageBox.Show("Please ensure both old and new character IDs are selected/provided.")
            Return
        End If

        Try
            Dim files = GetLuaFiles()
            If files.Length = 0 Then
                MessageBox.Show("No Lua files found to process.")
                Return
            End If

            SetupProgressBar(0, files.Length)

            Dim replacementsPerFile As New Dictionary(Of String, Integer)
            Dim totalReplacements As Integer = 0

            For Each filePath In files
                LogMessage($"Processing file for character ID update: {Path.GetFileName(filePath)}", logBox:=LogBox, logType:=LogType.Normal)
                Dim fileContent As String = File.ReadAllText(filePath)
                Dim matches = Regex.Matches(fileContent, Regex.Escape(oldCharacterID)).Count

                If matches > 0 Then
                    fileContent = fileContent.Replace(oldCharacterID, newCharacterID)
                    File.WriteAllText(filePath, fileContent)
                    replacementsPerFile(Path.GetFileName(filePath)) = matches
                    totalReplacements += matches
                End If

                If ProgressBar1.Value < ProgressBar1.Maximum Then ProgressBar1.Value += 1
            Next

            ' Final summary
            If replacementsPerFile.Count = 0 Then
                LogMessage("No files contained the old character ID.", logBox:=LogBox, logType:=LogType.Warning)
                MessageBox.Show("The old character ID was not found in any files. Please provide a correct character ID.")
            Else
                Dim summary As String = $"Character ID '{oldCharacterID}' was replaced with '{newCharacterID}' in {totalReplacements} occurrence(s) across {replacementsPerFile.Count} file(s)."
                LogMessage(summary, logBox:=LogBox, logType:=LogType.Info)
                MessageBox.Show(summary, "Character ID Update Summary", MessageBoxButtons.OK, MessageBoxIcon.Information)
                ScanLuaFiles()
            End If

        Catch ex As Exception
            LogMessage("An error occurred while updating character ID: " & ex.Message, logBox:=LogBox, logType:=LogType.Error)
            MessageBox.Show("An error occurred while updating character ID: " & ex.Message)
        Finally
            ProgressBar1.Value = 0
        End Try
    End Sub

End Class
