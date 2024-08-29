namespace screenprotector;

partial class frmBlocker {
    /// <summary>
    /// Required designer variable.
    /// </summary>
    private System.ComponentModel.IContainer components = null;

    /// <summary>
    /// Clean up any resources being used.
    /// </summary>
    /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
    protected override void Dispose(bool disposing) {
        if (disposing && (components != null)) {
            components.Dispose();
        }
        base.Dispose(disposing);
    }

    #region Windows Form Designer generated code

    /// <summary>
    /// Required method for Designer support - do not modify
    /// the contents of this method with the code editor.
    /// </summary>
    private void InitializeComponent() {
        pictureBoxBackground = new PictureBox();
        ((System.ComponentModel.ISupportInitialize)pictureBoxBackground).BeginInit();
        SuspendLayout();
        // 
        // pictureBoxBackground
        // 
        pictureBoxBackground.BackColor = Color.White;
        pictureBoxBackground.Dock = DockStyle.Fill;
        pictureBoxBackground.Location = new Point(0, 0);
        pictureBoxBackground.Name = "pictureBoxBackground";
        pictureBoxBackground.Size = new Size(800, 450);
        pictureBoxBackground.TabIndex = 1;
        pictureBoxBackground.TabStop = false;
        // 
        // frmBlocker
        // 
        AutoScaleDimensions = new SizeF(7F, 15F);
        AutoScaleMode = AutoScaleMode.Font;
        ClientSize = new Size(800, 450);
        Controls.Add(pictureBoxBackground);
        FormBorderStyle = FormBorderStyle.None;
        Name = "frmBlocker";
        ShowInTaskbar = false;
        StartPosition = FormStartPosition.Manual;
        Text = "frmBlocker";
        TransparencyKey = Color.White;
        FormClosing += frmBlocker_FormClosing;
        ((System.ComponentModel.ISupportInitialize)pictureBoxBackground).EndInit();
        ResumeLayout(false);
    }

    #endregion

    private PictureBox pictureBoxBackground;
}