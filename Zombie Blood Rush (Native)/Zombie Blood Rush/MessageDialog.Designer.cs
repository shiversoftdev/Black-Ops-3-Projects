
namespace Zombie_Blood_Rush
{
    partial class MessageDialog
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(MessageDialog));
            this.label1 = new System.Windows.Forms.Label();
            this.LeftBorder = new System.Windows.Forms.Panel();
            this.RightBorder = new System.Windows.Forms.Panel();
            this.TopBorder = new System.Windows.Forms.Panel();
            this.BottomBorder = new System.Windows.Forms.Panel();
            this.MessageTitle = new System.Windows.Forms.Label();
            this.MessageContents = new System.Windows.Forms.RichTextBox();
            this.OkButton = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // label1
            // 
            this.label1.Cursor = System.Windows.Forms.Cursors.Hand;
            this.label1.Font = new System.Drawing.Font("Segoe UI", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label1.ForeColor = System.Drawing.Color.Turquoise;
            this.label1.Location = new System.Drawing.Point(367, 0);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(33, 29);
            this.label1.TabIndex = 0;
            this.label1.Text = "x";
            this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.label1.Click += new System.EventHandler(this.label1_Click);
            // 
            // LeftBorder
            // 
            this.LeftBorder.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left)));
            this.LeftBorder.BackColor = System.Drawing.Color.Turquoise;
            this.LeftBorder.ForeColor = System.Drawing.Color.Turquoise;
            this.LeftBorder.Location = new System.Drawing.Point(0, 0);
            this.LeftBorder.Name = "LeftBorder";
            this.LeftBorder.Size = new System.Drawing.Size(3, 200);
            this.LeftBorder.TabIndex = 1;
            // 
            // RightBorder
            // 
            this.RightBorder.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.RightBorder.BackColor = System.Drawing.Color.Turquoise;
            this.RightBorder.ForeColor = System.Drawing.Color.Turquoise;
            this.RightBorder.Location = new System.Drawing.Point(397, 0);
            this.RightBorder.Name = "RightBorder";
            this.RightBorder.Size = new System.Drawing.Size(3, 200);
            this.RightBorder.TabIndex = 2;
            // 
            // TopBorder
            // 
            this.TopBorder.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.TopBorder.BackColor = System.Drawing.Color.Turquoise;
            this.TopBorder.ForeColor = System.Drawing.Color.Turquoise;
            this.TopBorder.Location = new System.Drawing.Point(0, 0);
            this.TopBorder.Name = "TopBorder";
            this.TopBorder.Size = new System.Drawing.Size(400, 3);
            this.TopBorder.TabIndex = 3;
            // 
            // BottomBorder
            // 
            this.BottomBorder.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.BottomBorder.BackColor = System.Drawing.Color.Turquoise;
            this.BottomBorder.ForeColor = System.Drawing.Color.Turquoise;
            this.BottomBorder.Location = new System.Drawing.Point(0, 197);
            this.BottomBorder.Name = "BottomBorder";
            this.BottomBorder.Size = new System.Drawing.Size(400, 3);
            this.BottomBorder.TabIndex = 4;
            // 
            // MessageTitle
            // 
            this.MessageTitle.AutoSize = true;
            this.MessageTitle.Font = new System.Drawing.Font("Segoe UI", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.MessageTitle.ForeColor = System.Drawing.Color.Turquoise;
            this.MessageTitle.Location = new System.Drawing.Point(9, 8);
            this.MessageTitle.Name = "MessageTitle";
            this.MessageTitle.Size = new System.Drawing.Size(104, 21);
            this.MessageTitle.TabIndex = 5;
            this.MessageTitle.Text = "Message Title";
            // 
            // MessageContents
            // 
            this.MessageContents.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(24)))), ((int)(((byte)(24)))), ((int)(((byte)(24)))));
            this.MessageContents.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.MessageContents.Cursor = System.Windows.Forms.Cursors.IBeam;
            this.MessageContents.ForeColor = System.Drawing.Color.Turquoise;
            this.MessageContents.Location = new System.Drawing.Point(25, 48);
            this.MessageContents.Name = "MessageContents";
            this.MessageContents.ReadOnly = true;
            this.MessageContents.Size = new System.Drawing.Size(349, 111);
            this.MessageContents.TabIndex = 6;
            this.MessageContents.Text = "Message contents. You have done something to warrant a message. This is what the " +
    "message has to say about that.";
            // 
            // OkButton
            // 
            this.OkButton.Cursor = System.Windows.Forms.Cursors.Hand;
            this.OkButton.FlatAppearance.BorderColor = System.Drawing.Color.Turquoise;
            this.OkButton.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(80)))), ((int)(((byte)(80)))), ((int)(((byte)(80)))));
            this.OkButton.FlatAppearance.MouseOverBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(45)))), ((int)(((byte)(45)))), ((int)(((byte)(45)))));
            this.OkButton.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.OkButton.ForeColor = System.Drawing.Color.Turquoise;
            this.OkButton.Location = new System.Drawing.Point(160, 165);
            this.OkButton.Name = "OkButton";
            this.OkButton.Size = new System.Drawing.Size(80, 26);
            this.OkButton.TabIndex = 7;
            this.OkButton.Text = "Accept";
            this.OkButton.TextAlign = System.Drawing.ContentAlignment.TopCenter;
            this.OkButton.UseVisualStyleBackColor = true;
            this.OkButton.Click += new System.EventHandler(this.OkButton_Click);
            // 
            // MessageDialog
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 17F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(24)))), ((int)(((byte)(24)))), ((int)(((byte)(24)))));
            this.ClientSize = new System.Drawing.Size(400, 200);
            this.Controls.Add(this.OkButton);
            this.Controls.Add(this.MessageContents);
            this.Controls.Add(this.MessageTitle);
            this.Controls.Add(this.BottomBorder);
            this.Controls.Add(this.TopBorder);
            this.Controls.Add(this.RightBorder);
            this.Controls.Add(this.LeftBorder);
            this.Controls.Add(this.label1);
            this.Font = new System.Drawing.Font("Segoe UI", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.ForeColor = System.Drawing.SystemColors.ControlLightLight;
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "MessageDialog";
            this.ShowIcon = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "MessageDialog";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Panel LeftBorder;
        private System.Windows.Forms.Panel RightBorder;
        private System.Windows.Forms.Panel TopBorder;
        private System.Windows.Forms.Panel BottomBorder;
        private System.Windows.Forms.Label MessageTitle;
        private System.Windows.Forms.RichTextBox MessageContents;
        private System.Windows.Forms.Button OkButton;
    }
}