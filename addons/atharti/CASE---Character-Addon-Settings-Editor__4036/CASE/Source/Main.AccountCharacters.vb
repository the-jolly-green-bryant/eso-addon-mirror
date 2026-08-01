Imports System.IO
Imports System.Text.RegularExpressions

Partial Public Class MainWindow
    ' Reads ZO_Ingame.lua and shows a MessageBox listing accounts and their characters
    Public Sub ShowAccountsAndCharactersFromZOIngame(selectedPath As String)
        Dim zoIngamePath = Path.Combine(selectedPath, "ZO_Ingame.lua")
        If Not File.Exists(zoIngamePath) Then
            MessageBox.Show("ZO_Ingame.lua not found in selected folder.")
            Return
        End If
        Dim lines = File.ReadAllLines(zoIngamePath).ToList()
        Dim accountPattern As New Regex("^\s*\[""([^""]+)""\]\s*=\s*\{?\s*$")
        Dim charPattern As New Regex("^\s*\[""([^""]+)""\]\s*=\s*\{?\s*$")
        Dim accounts As New Dictionary(Of String, List(Of String))()
        For i = 0 To lines.Count - 1
            Dim accMatch = accountPattern.Match(lines(i))
            If accMatch.Success Then
                Dim acc = accMatch.Groups(1).Value
                ' Only process if this is an AccountTarget.Items block (account table)
                If acc.StartsWith("@") OrElse acc = "AccountTarget.Items" Then
                    ' Find block start
                    Dim braceLevel = 0
                    If Not lines(i).TrimEnd().EndsWith("{") Then
                        While i + 1 < lines.Count AndAlso Not lines(i + 1).TrimStart().StartsWith("{")
                            i += 1
                        End While
                        If i + 1 < lines.Count AndAlso lines(i + 1).TrimStart().StartsWith("{") Then
                            i += 1
                        End If
                    End If
                    braceLevel += 1
                    Dim j = i + 1
                    Dim chars As New List(Of String)()
                    While j < lines.Count AndAlso braceLevel > 0
                        braceLevel += lines(j).Count(Function(c) c = "{"c)
                        braceLevel -= lines(j).Count(Function(c) c = "}"c)
                        If braceLevel = 1 Then
                            Dim charMatch = charPattern.Match(lines(j))
                            If charMatch.Success Then
                                Dim charKey = charMatch.Groups(1).Value
                                chars.Add(charKey)
                            End If
                        End If
                        j += 1
                    End While
                    If acc <> "AccountTarget.Items" Then
                        accounts(acc) = chars
                    End If
                End If
            End If
        Next
        ' Build message
        Dim msg As New System.Text.StringBuilder()
        For Each acc In accounts.Keys.OrderBy(Function(a) a)
            msg.AppendLine(acc & ":")
            For Each ch In accounts(acc).OrderBy(Function(c) c)
                msg.AppendLine("    " & ch)
            Next
        Next
        If msg.Length = 0 Then
            MessageBox.Show("No accounts or characters found in ZO_Ingame.lua.")
        Else
            MessageBox.Show(msg.ToString(), "Accounts and Characters (ZO_Ingame.lua)")
        End If
    End Sub

    ' Reads ZO_Ingame.lua and returns a Dictionary(Of String, String) mapping character -> account
    Public Function GetCharacterToAccountMapFromZOIngame(selectedPath As String) As Dictionary(Of String, String)
        Dim zoIngamePath = Path.Combine(selectedPath, "ZO_Ingame.lua")
        Dim charToAccount As New Dictionary(Of String, String)()
        If Not File.Exists(zoIngamePath) Then Return charToAccount
        Dim lines = File.ReadAllLines(zoIngamePath).ToList()
        Dim accountPattern As New Regex("^\s*\[""(@[^""]+)""\]\s*=\s*\{?\s*$")
        Dim charPattern As New Regex("^\s*\[""([^""]+)""\]\s*=\s*\{?\s*$")
        For i = 0 To lines.Count - 1
            Dim accMatch = accountPattern.Match(lines(i))
            If accMatch.Success Then
                Dim acc = accMatch.Groups(1).Value
                Dim braceLevel = 0
                If Not lines(i).TrimEnd().EndsWith("{") Then
                    While i + 1 < lines.Count AndAlso Not lines(i + 1).TrimStart().StartsWith("{")
                        i += 1
                    End While
                    If i + 1 < lines.Count AndAlso lines(i + 1).TrimStart().StartsWith("{") Then
                        i += 1
                    End If
                End If
                braceLevel += 1
                Dim j = i + 1
                While j < lines.Count AndAlso braceLevel > 0
                    braceLevel += lines(j).Count(Function(c) c = "{"c)
                    braceLevel -= lines(j).Count(Function(c) c = "}"c)
                    If braceLevel = 1 Then
                        Dim charMatch = charPattern.Match(lines(j))
                        If charMatch.Success Then
                            Dim charKey = charMatch.Groups(1).Value
                            If Not charToAccount.ContainsKey(charKey) Then
                                charToAccount(charKey) = acc
                            End If
                        End If
                    End If
                    j += 1
                End While
            End If
        Next
        Return charToAccount
    End Function
End Class
