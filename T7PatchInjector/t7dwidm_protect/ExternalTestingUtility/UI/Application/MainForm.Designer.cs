
namespace t7dwidm_protect
{
    partial class MainForm
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
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(MainForm));
            this.NameChangeTimer = new System.Windows.Forms.Timer(this.components);
            this.InnerForm = new Refract.UI.Core.Controls.CBorderedForm();
            this.label5 = new System.Windows.Forms.Label();
            this.cThemedTextbox2 = new SMC.UI.Core.Controls.CThemedTextbox();
            this.label3 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.FriendsOnlyCB = new System.Windows.Forms.CheckBox();
            this.label1 = new System.Windows.Forms.Label();
            this.cThemedTextbox1 = new SMC.UI.Core.Controls.CThemedTextbox();
            this.panel1 = new System.Windows.Forms.Panel();
            this.StatusLabel = new System.Windows.Forms.Label();
            this.netpasstimer = new System.Windows.Forms.Timer(this.components);
            this.InnerForm.ControlContents.SuspendLayout();
            this.SuspendLayout();
            // 
            // NameChangeTimer
            // 
            this.NameChangeTimer.Interval = 500;
            // 
            // InnerForm
            // 
            this.InnerForm.BackColor = System.Drawing.Color.DodgerBlue;
            // 
            // InnerForm.ControlContents
            // 
            this.InnerForm.ControlContents.Controls.Add(this.label5);
            this.InnerForm.ControlContents.Controls.Add(this.cThemedTextbox2);
            this.InnerForm.ControlContents.Controls.Add(this.label3);
            this.InnerForm.ControlContents.Controls.Add(this.label2);
            this.InnerForm.ControlContents.Controls.Add(this.FriendsOnlyCB);
            this.InnerForm.ControlContents.Controls.Add(this.label1);
            this.InnerForm.ControlContents.Controls.Add(this.cThemedTextbox1);
            this.InnerForm.ControlContents.Controls.Add(this.panel1);
            this.InnerForm.ControlContents.Controls.Add(this.StatusLabel);
            this.InnerForm.ControlContents.Dock = System.Windows.Forms.DockStyle.Fill;
            this.InnerForm.ControlContents.Enabled = true;
            this.InnerForm.ControlContents.Font = new System.Drawing.Font("Segoe UI", 9.75F);
            this.InnerForm.ControlContents.Location = new System.Drawing.Point(0, 32);
            this.InnerForm.ControlContents.Name = "ControlContents";
            this.InnerForm.ControlContents.Size = new System.Drawing.Size(396, 164);
            this.InnerForm.ControlContents.TabIndex = 1;
            this.InnerForm.ControlContents.Visible = true;
            this.InnerForm.Dock = System.Windows.Forms.DockStyle.Fill;
            this.InnerForm.Location = new System.Drawing.Point(0, 0);
            this.InnerForm.Name = "InnerForm";
            this.InnerForm.Size = new System.Drawing.Size(400, 200);
            this.InnerForm.TabIndex = 0;
            this.InnerForm.TitleBarTitle = "T7Patch 1.06 - by serious";
            this.InnerForm.UseTitleBar = true;
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Font = new System.Drawing.Font("Segoe UI", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label5.ForeColor = System.Drawing.SystemColors.Control;
            this.label5.Location = new System.Drawing.Point(6, 40);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(120, 17);
            this.label5.TabIndex = 12;
            this.label5.Text = "Network Password:";
            // 
            // cThemedTextbox2
            // 
            this.cThemedTextbox2.BorderColor = System.Drawing.Color.Red;
            this.cThemedTextbox2.Location = new System.Drawing.Point(132, 37);
            this.cThemedTextbox2.MaxLength = 15;
            this.cThemedTextbox2.Name = "cThemedTextbox2";
            this.cThemedTextbox2.PasswordChar = '*';
            this.cThemedTextbox2.Size = new System.Drawing.Size(153, 25);
            this.cThemedTextbox2.TabIndex = 11;
            this.cThemedTextbox2.UseSystemPasswordChar = true;
            this.cThemedTextbox2.TextChanged += new System.EventHandler(this.cThemedTextbox2_TextChanged);
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Font = new System.Drawing.Font("Segoe UI", 9.75F, System.Drawing.FontStyle.Underline, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label3.ForeColor = System.Drawing.SystemColors.Control;
            this.label3.Location = new System.Drawing.Point(242, 111);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(75, 17);
            this.label3.TabIndex = 10;
            this.label3.Text = "Learn more";
            this.label3.Click += new System.EventHandler(this.label3_Click);
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Font = new System.Drawing.Font("Segoe UI", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label2.ForeColor = System.Drawing.SystemColors.Control;
            this.label2.Location = new System.Drawing.Point(6, 111);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(242, 17);
            this.label2.TabIndex = 9;
            this.label2.Text = "Have you tried Zombie Blood Rush yet? ";
            // 
            // FriendsOnlyCB
            // 
            this.FriendsOnlyCB.AutoSize = true;
            this.FriendsOnlyCB.Checked = true;
            this.FriendsOnlyCB.CheckState = System.Windows.Forms.CheckState.Checked;
            this.FriendsOnlyCB.ForeColor = System.Drawing.Color.White;
            this.FriendsOnlyCB.Location = new System.Drawing.Point(291, 39);
            this.FriendsOnlyCB.Name = "FriendsOnlyCB";
            this.FriendsOnlyCB.Size = new System.Drawing.Size(99, 21);
            this.FriendsOnlyCB.TabIndex = 8;
            this.FriendsOnlyCB.Text = "Friends Only";
            this.FriendsOnlyCB.UseVisualStyleBackColor = true;
            this.FriendsOnlyCB.CheckedChanged += new System.EventHandler(this.FriendsOnlyCB_CheckedChanged);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("Segoe UI", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label1.ForeColor = System.Drawing.SystemColors.Control;
            this.label1.Location = new System.Drawing.Point(6, 9);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(94, 17);
            this.label1.TabIndex = 7;
            this.label1.Text = "Change Name:";
            // 
            // cThemedTextbox1
            // 
            this.cThemedTextbox1.BorderColor = System.Drawing.Color.Red;
            this.cThemedTextbox1.Location = new System.Drawing.Point(132, 6);
            this.cThemedTextbox1.MaxLength = 15;
            this.cThemedTextbox1.Name = "cThemedTextbox1";
            this.cThemedTextbox1.Size = new System.Drawing.Size(258, 25);
            this.cThemedTextbox1.TabIndex = 6;
            this.cThemedTextbox1.TextChanged += new System.EventHandler(this.cThemedTextbox1_TextChanged);
            // 
            // panel1
            // 
            this.panel1.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.panel1.BackColor = System.Drawing.SystemColors.ControlDarkDark;
            this.panel1.Location = new System.Drawing.Point(0, 131);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(400, 1);
            this.panel1.TabIndex = 1;
            // 
            // StatusLabel
            // 
            this.StatusLabel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.StatusLabel.AutoSize = true;
            this.StatusLabel.Font = new System.Drawing.Font("Segoe UI", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.StatusLabel.ForeColor = System.Drawing.SystemColors.ControlLightLight;
            this.StatusLabel.Location = new System.Drawing.Point(5, 136);
            this.StatusLabel.Name = "StatusLabel";
            this.StatusLabel.Size = new System.Drawing.Size(179, 21);
            this.StatusLabel.TabIndex = 0;
            this.StatusLabel.Text = "No game process found.";
            // 
            // netpasstimer
            // 
            this.netpasstimer.Interval = 1500;
            // 
            // MainForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(400, 200);
            this.Controls.Add(this.InnerForm);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "MainForm";
            this.Text = "Serious\' MP Tool";
            this.InnerForm.ControlContents.ResumeLayout(false);
            this.InnerForm.ControlContents.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private Refract.UI.Core.Controls.CBorderedForm InnerForm;
        private System.Windows.Forms.Label StatusLabel;
        private System.Windows.Forms.Panel panel1;
        private SMC.UI.Core.Controls.CThemedTextbox cThemedTextbox1;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.CheckBox FriendsOnlyCB;
        private System.Windows.Forms.Timer NameChangeTimer;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label5;
        private SMC.UI.Core.Controls.CThemedTextbox cThemedTextbox2;
        private System.Windows.Forms.Timer netpasstimer;
    }
}

