<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class DeletionLogForm
    Inherits System.Windows.Forms.Form

    <System.Diagnostics.DebuggerNonUserCode()>
    Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        Try
            If disposing AndAlso components IsNot Nothing Then
                components.Dispose()
            End If
        Finally
            MyBase.Dispose(disposing)
        End Try
    End Sub
    Private components As System.ComponentModel.IContainer

    <System.Diagnostics.DebuggerStepThrough()> _
    Private Sub InitializeComponent()
        TreeView1 = New TreeView()
        ExCol = New Button()
        SuspendLayout()
        ' 
        ' TreeView1
        ' 
        TreeView1.Dock = DockStyle.Fill
        TreeView1.Location = New Point(0, 0)
        TreeView1.Name = "TreeView1"
        TreeView1.Size = New Size(800, 450)
        TreeView1.TabIndex = 0
        ' 
        ' ExCol
        ' 
        ExCol.Anchor = AnchorStyles.Top Or AnchorStyles.Right
        ExCol.Font = New Font("Segoe UI", 9.75F, FontStyle.Regular, GraphicsUnit.Point, CByte(204))
        ExCol.Location = New Point(749, 12)
        ExCol.Name = "ExCol"
        ExCol.Size = New Size(24, 48)
        ExCol.TabIndex = 1
        ExCol.Text = "▼▲"
        ExCol.UseVisualStyleBackColor = True
        ' 
        ' DeletionLogForm
        ' 
        AutoScaleDimensions = New SizeF(7F, 15F)
        AutoScaleMode = AutoScaleMode.Font
        ClientSize = New Size(800, 450)
        Controls.Add(ExCol)
        Controls.Add(TreeView1)
        Name = "DeletionLogForm"
        StartPosition = FormStartPosition.CenterParent
        Text = "CASE — Detailed Report Window"
        ResumeLayout(False)
    End Sub

    Friend WithEvents TreeView1 As TreeView
    Friend WithEvents ExCol As Button
End Class
