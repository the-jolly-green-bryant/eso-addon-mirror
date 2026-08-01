Public Class DeletionLogForm
    Private expanded As Boolean = True

    Private Sub ExCol_Click(sender As Object, e As EventArgs) Handles ExCol.Click
        If expanded Then
            TreeView1.CollapseAll()
            ExCol.Text = "▲▼"
        Else
            TreeView1.ExpandAll()
            ExCol.Text = "▼▲"
        End If
        expanded = Not expanded
    End Sub

    Private Sub Form2_Resize(sender As Object, e As EventArgs) Handles MyBase.Resize
        ExCol.Top = 1 ' 10px from the top edge
        ExCol.Left = Me.ClientSize.Width - ExCol.Width - 20
    End Sub

    Private Sub DeletionLogForm_Load(sender As Object, e As EventArgs) Handles MyBase.Load
        Me.Icon = Icon.ExtractAssociatedIcon(Application.ExecutablePath)
    End Sub
End Class