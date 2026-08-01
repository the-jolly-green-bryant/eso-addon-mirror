Partial Public Class MainWindow
    ' ----------------- Logging Functions -----------------
    Public Enum LogType
        Info
        Warning
        [Error]
        Normal
    End Enum

    ''' <summary>
    ''' Logs a message to the specified RichTextBox with optional color flags.
    ''' </summary>
    ''' <param name="message">Message to log</param>
    ''' <param name="logBox">RichTextBox to write to (default: LogBox)</param>
    ''' <param name="logType">Flag indicating type of message for color</param>
    Public Sub LogMessage(message As String, Optional logBox As RichTextBox = Nothing, Optional logType As LogType = LogType.Normal)
        If String.IsNullOrEmpty(message) Then Return

        ' Default log box
        If logBox Is Nothing Then logBox = Me.LogBox ' <-- assign your default RichTextBox here

        ' Ensure UI thread
        If logBox.InvokeRequired Then
            logBox.BeginInvoke(Sub() LogMessage(message, logBox, logType))
        Else
            Dim timestamp = DateTime.Now.ToString("HH:mm:ss")
            If logBox.TextLength > 0 Then logBox.AppendText(Environment.NewLine)

            logBox.SelectionStart = logBox.TextLength
            logBox.SelectionLength = 0

            ' Assign color based on flag
            Select Case logType
                Case LogType.Info
                    logBox.SelectionColor = Color.Green
                Case LogType.Warning
                    logBox.SelectionColor = Color.Orange
                Case LogType.Error
                    logBox.SelectionColor = Color.Red
                Case Else
                    logBox.SelectionColor = Color.Black
            End Select

            logBox.AppendText("[" & timestamp & "] " & message)
            logBox.SelectionColor = logBox.ForeColor
            logBox.ScrollToCaret()
        End If
    End Sub
End Class
