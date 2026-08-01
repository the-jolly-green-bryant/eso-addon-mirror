Imports System.IO
Imports System.Text.RegularExpressions

Partial Public Class MainWindow
    Private Sub ButtonSelectFolder_Click(sender As Object, e As EventArgs) Handles ButtonSelectFolder.Click
        Using folderBrowser As New FolderBrowserDialog()
            folderBrowser.Description = "Select your SavedVariables folder"
            folderBrowser.ShowNewFolderButton = False

            If folderBrowser.ShowDialog() = DialogResult.OK Then
                selectedPath = folderBrowser.SelectedPath
                Dim luaFiles = GetLuaFiles()
                GroupBox1.Text = "Files Found: " & luaFiles.Length
                If luaFiles.Length = 0 Then
                    MessageBox.Show("Expected files are missing, probably a wrong folder.")
                    If TabControl1.TabPages.Contains(STransfer) Then
                        STransfer.Enabled = False
                    End If
                    Return
                End If
                ' Only proceed if Lua files exist
                ScanLuaFiles()
                FindMostPopularName()
                FindAddOnSettingsFile()
                ' Backup folder check
                Dim parentDir As String = IO.Path.GetDirectoryName(selectedPath.TrimEnd(IO.Path.DirectorySeparatorChar))
                If TabControl1.TabPages.Contains(STransfer) Then
                    STransfer.Enabled = True
                End If
            Else
                MessageBox.Show("No folder was selected.")
                If TabControl1.TabPages.Contains(STransfer) Then
                    STransfer.Enabled = False
                End If
            End If
        End Using
        UpdateSTransferTabAndButton()
    End Sub


    Private Function ExtractCharactersFromLuaFile(filePath As String) As Dictionary(Of String, String)
        Dim characters As New Dictionary(Of String, String)()
        Dim fullPath = Path.Combine(selectedPath, "ZO_Ingame.lua")
        If Not System.IO.File.Exists(fullPath) Then
            MessageBox.Show("File does not exist: " & fullPath, "File Not Found", MessageBoxButtons.OK, MessageBoxIcon.Error)
            Throw New FileNotFoundException("ZO_Ingame.lua was not found!", fullPath)
        End If

        Dim content = System.IO.File.ReadAllText(fullPath)
        Dim idMatches = idRegex.Matches(content)

        For Each idMatch As Match In idMatches
            If idMatch.Groups.Count > 1 Then
                Dim characterId = idMatch.Groups(1).Value
                Dim remainingContent = content.Substring(idMatch.Index + idMatch.Length)
                Dim equalsMatch = nameRegex.Match(remainingContent)
                If equalsMatch.Success Then
                    Dim characterName = equalsMatch.Groups(1).Value
                    If Not String.IsNullOrEmpty(characterId) AndAlso Not String.IsNullOrEmpty(characterName) Then
                        If Not characters.ContainsKey(characterName) Then characters.Add(characterName, characterId)
                    End If
                End If
            End If
        Next
        Return characters
    End Function

End Class
