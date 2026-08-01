Imports System.IO
Imports System.Text.RegularExpressions

Partial Public Class MainWindow
    Private Async Sub ScanLuaFiles()

        ' Always reset before touching range
        ProgressBar1.Value = 0
        ProgressBar1.Minimum = 0
        ProgressBar1.Maximum = 1

        DataGridViewCharacters.Rows.Clear()
        OldCharBox.Items.Clear()
        OldIDBox.Items.Clear()
        CachedBox.Items.Clear()

        Try
            Dim files = GetLuaFiles()
            Dim characterOccurrences As New Dictionary(Of String, Integer)
            Dim characterIdOccurrences As New Dictionary(Of String, Integer)
            characterMap.Clear()

            If files.Length = 0 Then
                LogMessage("No Lua files found in folder: " & selectedPath, logBox:=LogBox, logType:=LogType.Warning)
                MessageBox.Show("Expected files are missing, probably a wrong folder.")
                Return
            End If

            ' Only extract characters from ZO_Ingame.lua once
            Dim zoIngamePath = Path.Combine(selectedPath, "ZO_Ingame.lua")
            If File.Exists(zoIngamePath) Then
                LogMessage($"Extracting Data from: {Path.GetFileName(zoIngamePath)}", logBox:=LogBox, logType:=LogType.Normal)
                Dim characters = ExtractCharactersFromLuaFile(zoIngamePath)
                For Each kvp In characters
                    If Not characterMap.ContainsKey(kvp.Key) Then
                        characterMap.Add(kvp.Key, kvp.Value)
                        characterOccurrences(kvp.Key) = 0
                        characterIdOccurrences(kvp.Value) = 0
                        LogMessage($"Found character: {kvp.Key} (ID: {kvp.Value}) in {Path.GetFileName(zoIngamePath)}", logBox:=LogBox, logType:=LogType.Normal)
                    End If
                Next
            Else
                LogMessage("ZO_Ingame.lua not found for character extraction.", logBox:=LogBox, logType:=LogType.Warning)
            End If
            If ProgressBar1.Value < ProgressBar1.Maximum Then
                ProgressBar1.Value += 1
            Else
                ProgressBar1.Value = ProgressBar1.Maximum
            End If

            SetupProgressBar(0, files.Length + 1)
            LogMessage($"Started scanning {files.Length} Lua files in: {selectedPath}", logBox:=LogBox, logType:=LogType.Info)

            ' Build a single regex for all character names and IDs
            Dim allTerms = characterMap.Keys.Concat(characterMap.Values).Distinct().ToList()
            Dim pattern = String.Join("|", allTerms.Select(Function(term) Regex.Escape(term)))
            Dim allTermsRegex As Regex = Nothing
            If pattern.Length > 0 Then
                allTermsRegex = New Regex(pattern, RegexOptions.Compiled)
            End If

            ' Second pass: count occurrences using regex, sequentially for progress bar responsiveness
            For Each filePath In files
                LogMessage($"Counting occurrences in: {Path.GetFileName(filePath)}", logBox:=LogBox, logType:=LogType.Normal)
                Await Task.Run(Sub()
                                   Dim fileContent = System.IO.File.ReadAllText(filePath)
                                   If allTermsRegex IsNot Nothing Then
                                       Dim matches = allTermsRegex.Matches(fileContent)
                                       SyncLock characterOccurrences
                                           For Each match As Match In matches
                                               Dim value = match.Value
                                               If characterOccurrences.ContainsKey(value) Then
                                                   characterOccurrences(value) += 1
                                               End If
                                               If characterIdOccurrences.ContainsKey(value) Then
                                                   characterIdOccurrences(value) += 1
                                               End If
                                           Next
                                       End SyncLock
                                   End If
                               End Sub)
                If ProgressBar1.Value < ProgressBar1.Maximum Then
                    ProgressBar1.Value += 1
                Else
                    ProgressBar1.Value = ProgressBar1.Maximum
                End If
            Next

            ' Display results
            LogMessage($"Scan complete. {characterMap.Count} unique characters found.", logBox:=LogBox, logType:=LogType.Info)
            For Each kvp In characterMap
                Dim characterName = kvp.Key
                Dim characterId = kvp.Value
                Dim nameOccurrences = 0
                If characterOccurrences.ContainsKey(characterName) Then
                    nameOccurrences = characterOccurrences(characterName)
                End If
                Dim idOccurrences = 0
                If characterIdOccurrences.ContainsKey(characterId) Then
                    idOccurrences = characterIdOccurrences(characterId)
                End If
                ' Add to DataGridView
                DataGridViewCharacters.Rows.Add(False, characterName, characterId, nameOccurrences + idOccurrences)
                OldCharBox.Items.Add(characterName)
                OldIDBox.Items.Add(characterId)
                LogMessage($"Character '{characterName}' (ID: {characterId}) total occurrences: {nameOccurrences + idOccurrences}", logBox:=LogBox, logType:=LogType.Normal)
            Next

            If DataGridViewCharacters.Rows.Count = 0 Then
                LogMessage("No characters found in the Lua files.", logBox:=LogBox, logType:=LogType.Warning)
                MessageBox.Show("No characters found in the Lua files.")
            Else
                GroupBox2.Text = "Characters Found: " & DataGridViewCharacters.Rows.Count
                LogMessage($"Characters found: {DataGridViewCharacters.Rows.Count}", logBox:=LogBox, logType:=LogType.Info)
            End If

        Catch ex As Exception When TypeOf ex Is IOException OrElse TypeOf ex Is UnauthorizedAccessException
            LogMessage("File access error: " & ex.Message, logBox:=LogBox, logType:=LogType.Error)
            MessageBox.Show("An error occurred while accessing files: " & ex.Message)
        Catch ex As Exception
            LogMessage("Unexpected error: " & ex.Message, logBox:=LogBox, logType:=LogType.Error)
            MessageBox.Show("An unexpected error occurred: " & ex.Message)
        Finally
            ProgressBar1.Value = ProgressBar1.Minimum
        End Try
        PopulateSTransferControls()
        UpdateAccountsFromTheFile()
        LogMessage("Finished scanning SavedVariables.", logBox:=LogBox, logType:=LogType.Info)
        AccNameNew.Clear()
        OldCharBox.SelectedIndex = -1
        OldCharBox.Text = "Select Character"
        NewCharName.Clear()
        OldIDBox.SelectedIndex = -1
        OldIDBox.Text = "Select Character ID"
        NewCharID.Clear()
    End Sub
End Class
