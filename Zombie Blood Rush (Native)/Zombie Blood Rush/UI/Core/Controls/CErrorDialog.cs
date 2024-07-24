using Refract.UI.Core.Interfaces;
using Refract.UI.Core.Singletons;
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

namespace SMC.UI.Core.Controls
{
    public partial class CErrorDialog : Form, IThemeableControl
    {
        public CErrorDialog(string title, string description)
        {
            InitializeComponent();
            UIThemeManager.OnThemeChanged(this, OnThemeChanged_Implementation);
            this.SetThemeAware();
            MaximizeBox = true;
            MinimizeBox = true;
            Text = title;
            InnerForm.TitleBarTitle = title;
            ErrorRTB.Text = description;
            Icon = Resources.zbr_ico2;
        }

        private void OnThemeChanged_Implementation(UIThemeInfo themeData)
        {
            return;
        }

        public IEnumerable<Control> GetThemedControls()
        {
            yield return InnerForm;
            yield return ErrorRTB;
            yield return AcceptButton;
        }

        private void AcceptButton_Click(object sender, EventArgs e)
        {
            DialogResult = DialogResult.OK;
            Close();
        }

        private void button1_Click(object sender, EventArgs e)
        {

        }

        public static void Show(string title, string description)
        {
            new CErrorDialog(title, description).ShowDialog();
        }
    }
}
