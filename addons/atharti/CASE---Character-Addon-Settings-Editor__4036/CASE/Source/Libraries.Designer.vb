<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class Libraries
    Inherits System.Windows.Forms.Form

    'Форма переопределяет dispose для очистки списка компонентов.
    <System.Diagnostics.DebuggerNonUserCode()> _
    Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        Try
            If disposing AndAlso components IsNot Nothing Then
                components.Dispose()
            End If
        Finally
            MyBase.Dispose(disposing)
        End Try
    End Sub

    'Является обязательной для конструктора форм Windows Forms
    Private components As System.ComponentModel.IContainer

    'Примечание: следующая процедура является обязательной для конструктора форм Windows Forms
    'Для ее изменения используйте конструктор форм Windows Form.  
    'Не изменяйте ее в редакторе исходного кода.
    <System.Diagnostics.DebuggerStepThrough()> _
    Private Sub InitializeComponent()
        LibRemove = New Button()
        LibList = New CheckedListBox()
        Label1 = New Label()
        SuspendLayout()
        ' 
        ' LibRemove
        ' 
        LibRemove.Location = New Point(12, 133)
        LibRemove.Name = "LibRemove"
        LibRemove.Size = New Size(454, 26)
        LibRemove.TabIndex = 0
        LibRemove.Text = "Delete Libraries"
        LibRemove.UseVisualStyleBackColor = True
        ' 
        ' LibList
        ' 
        LibList.CheckOnClick = True
        LibList.FormattingEnabled = True
        LibList.Location = New Point(12, 26)
        LibList.Name = "LibList"
        LibList.Size = New Size(454, 94)
        LibList.TabIndex = 2
        ' 
        ' Label1
        ' 
        Label1.AutoSize = True
        Label1.Location = New Point(12, 8)
        Label1.Name = "Label1"
        Label1.Size = New Size(358, 15)
        Label1.TabIndex = 3
        Label1.Text = "Libraries that are not listed as dependency for any of your AddOns:"
        ' 
        ' Libraries
        ' 
        AutoScaleDimensions = New SizeF(7F, 15F)
        AutoScaleMode = AutoScaleMode.Font
        ClientSize = New Size(478, 171)
        Controls.Add(Label1)
        Controls.Add(LibList)
        Controls.Add(LibRemove)
        MaximizeBox = False
        MaximumSize = New Size(494, 210)
        MinimizeBox = False
        MinimumSize = New Size(494, 210)
        Name = "Libraries"
        StartPosition = FormStartPosition.CenterScreen
        Text = "CASE — Redundant Libraries"
        ResumeLayout(False)
        PerformLayout()
    End Sub

    Friend WithEvents LibRemove As Button
    Friend WithEvents LibList As CheckedListBox
    Friend WithEvents Label1 As Label
End Class
