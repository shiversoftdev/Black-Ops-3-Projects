using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Zombie_Blood_Rush.Properties;

namespace Zombie_Blood_Rush
{
    public partial class MessageDialog : Form
    {
        public MessageDialog(string Title, string Message)
        {
            InitializeComponent();
            MouseDown += Form1_MouseDown;
            BottomBorder.MouseDown += Form1_MouseDown;
            TopBorder.MouseDown += Form1_MouseDown;
            LeftBorder.MouseDown += Form1_MouseDown;
            RightBorder.MouseDown += Form1_MouseDown;
            MessageTitle.MouseDown += Form1_MouseDown;
            MessageContents.MouseDown += Form1_MouseDown;
            MessageTitle.Text = Title;
            Text = Title;
            MessageContents.Text = Message;
            Icon = Resources.zbr_ico2;
        }

        public const int WM_NCLBUTTONDOWN = 0xA1;
        public const int HT_CAPTION = 0x2;

        [System.Runtime.InteropServices.DllImport("user32.dll")]
        public static extern int SendMessage(IntPtr hWnd, int Msg, int wParam, int lParam);
        [System.Runtime.InteropServices.DllImport("user32.dll")]
        public static extern bool ReleaseCapture();

        private void Form1_MouseDown(object sender, System.Windows.Forms.MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                ReleaseCapture();
                SendMessage(Handle, WM_NCLBUTTONDOWN, HT_CAPTION, 0);
            }
        }

        private void label1_Click(object sender, EventArgs e)
        {
            DialogResult = DialogResult.Cancel;
            Close();
        }

        private void OkButton_Click(object sender, EventArgs e)
        {
            DialogResult = DialogResult.OK;
            Close();
        }
    }
}
