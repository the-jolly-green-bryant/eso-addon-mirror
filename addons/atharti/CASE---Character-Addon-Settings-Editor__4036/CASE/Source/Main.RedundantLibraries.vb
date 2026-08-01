Imports System.IO
Imports System.Text.RegularExpressions

Partial Public Class MainWindow
    Private Sub RedundantLibraries_Click(sender As Object, e As EventArgs) Handles RedundantLibraries.Click
        If String.IsNullOrEmpty(selectedPath) Then
            MessageBox.Show("No SavedVariables folder selected.")
            Return
        End If

        Dim parentDir = Path.GetDirectoryName(selectedPath.TrimEnd(Path.DirectorySeparatorChar))
        Dim addonsDir = Path.Combine(parentDir, "AddOns")
        If Not Directory.Exists(addonsDir) Then
            MessageBox.Show("AddOns folder not found.")
            Return
        End If

        Dim libraryPaths As New Dictionary(Of String, String)(StringComparer.OrdinalIgnoreCase)

        ' Scan up to 5 levels deep
        Dim addonFolders = Directory.GetDirectories(addonsDir, "*", SearchOption.AllDirectories)
        Dim filteredFolders As New List(Of String)
        For Each folder In addonFolders
            Dim relativeDepth = folder.Count(Function(c) c = Path.DirectorySeparatorChar) - addonsDir.Count(Function(c) c = Path.DirectorySeparatorChar)
            If relativeDepth <= 5 Then
                filteredFolders.Add(folder)
            End If
        Next
        addonFolders = filteredFolders.ToArray()

        Dim depRegex As New Regex("## (DependsOn|PCDependsOn):(.+)", RegexOptions.IgnoreCase)
        Dim isLibRegex As New Regex("## IsLibrary:\s*true", RegexOptions.IgnoreCase)
        Dim depNameRegex As New Regex("([A-Za-z0-9_\-\.]+)", RegexOptions.Compiled)

        ' First pass: classify libraries and addons
        Dim addonManifests As New List(Of String)()
        For Each folder In addonFolders
            Dim folderName = Path.GetFileName(folder)
            Dim manifestPath As String = Nothing

            Dim txtFiles = Directory.GetFiles(folder, folderName & ".txt")
            If txtFiles.Length > 0 Then
                manifestPath = txtFiles(0)
            Else
                Dim addonFiles = Directory.GetFiles(folder, folderName & ".addon")
                If addonFiles.Length > 0 Then
                    manifestPath = addonFiles(0)
                End If
            End If

            If manifestPath Is Nothing Then Continue For

            Dim lines = File.ReadAllLines(manifestPath)
            Dim isLibrary = False
            For Each line In lines
                If isLibRegex.IsMatch(line) Then
                    isLibrary = True
                    Exit For
                End If
            Next

            If isLibrary Then
                ' Skip libraries whose name contains parent addon's folder name
                Dim parentAddonName = Path.GetFileName(Path.GetDirectoryName(folder))
                If Not folderName.ToLower().Contains(parentAddonName.ToLower()) Then
                    libraryPaths(folderName) = folder
                End If
            Else
                addonManifests.Add(manifestPath)
            End If
        Next

        ' Second pass: collect all manifests (addon + library)
        Dim allManifests As New List(Of String)()
        allManifests.AddRange(addonManifests)

        For Each kvp In libraryPaths
            Dim libraryName = kvp.Key
            Dim folderPath = kvp.Value

            Dim txtPath = Path.Combine(folderPath, libraryName & ".txt")
            Dim addonPath = Path.Combine(folderPath, libraryName & ".addon")

            If File.Exists(txtPath) Then
                allManifests.Add(txtPath)
            ElseIf File.Exists(addonPath) Then
                allManifests.Add(addonPath)
            End If
        Next

        ' Build dependency graph
        Dim depGraph As New Dictionary(Of String, List(Of String))(StringComparer.OrdinalIgnoreCase)
        For Each manifestPath In allManifests
            Dim manifestName = Path.GetFileNameWithoutExtension(manifestPath)
            Dim dependencies As New List(Of String)
            Dim lines = File.ReadAllLines(manifestPath)
            For Each line In lines
                Dim depMatch = depRegex.Match(line)
                If depMatch.Success Then
                    Dim depLine = depMatch.Groups(2).Value
                    For Each dep As String In depLine.Split(New Char() {" "c, ChrW(9)}, StringSplitOptions.RemoveEmptyEntries)
                        Dim depName = dep.Split(New Char() {"<"c, ">"c, "="c, "~"c}, StringSplitOptions.RemoveEmptyEntries)(0).Trim()
                        If depName.Length > 0 AndAlso Not depName.Equals(manifestName, StringComparison.OrdinalIgnoreCase) Then
                            dependencies.Add(depName)
                        End If
                    Next
                End If
            Next
            depGraph(manifestName) = dependencies
        Next

        ' Mark used libraries starting from all addons
        Dim used As New HashSet(Of String)(StringComparer.OrdinalIgnoreCase)
        Dim stack As New Stack(Of String)
        For Each manifestPath In addonManifests
            stack.Push(Path.GetFileNameWithoutExtension(manifestPath))
        Next

        While stack.Count > 0
            Dim current = stack.Pop()
            If Not used.Contains(current) Then
                used.Add(current)
                If depGraph.ContainsKey(current) Then
                    For Each dep In depGraph(current)
                        stack.Push(dep)
                    Next
                End If
            End If
        End While

        ' Manual exclusion: libraries that should never be marked as redundant
        Dim alwaysKeep As New HashSet(Of String)(StringComparer.OrdinalIgnoreCase) From {"libAddonKeybinds", "NodeDetection"}

        ' Find redundant libraries
        Dim redundantLibs As New List(Of String)
        For Each libName In libraryPaths.Keys
            If Not used.Contains(libName) AndAlso Not alwaysKeep.Contains(libName) Then
                redundantLibs.Add(libName)
            End If
        Next
        redundantLibs.Sort()

        If redundantLibs.Count = 0 Then
            MessageBox.Show("Redundant Libraries are not found!", "CASE — Redundant Libraries", MessageBoxButtons.OK, MessageBoxIcon.Information)
            Return
        End If

        ' Display redundant libraries in Libraries form
        Dim libForm As Libraries = Nothing
        If Application.OpenForms().OfType(Of Libraries)().Any() Then
            libForm = Application.OpenForms().OfType(Of Libraries)().First()
        Else
            libForm = New Libraries()
        End If

        libForm.LibraryPaths = libraryPaths

        libForm.LibList.Items.Clear()
        For Each libName As String In redundantLibs

            libForm.LibList.Items.Add(libName)
        Next

        If Not Application.OpenForms().OfType(Of Libraries)().Any() Then
            libForm.Show()
        Else
            libForm.BringToFront()
        End If
    End Sub
End Class
