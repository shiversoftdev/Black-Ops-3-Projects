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

namespace SMC.UI.Core.Controls
{
    public partial class CPleaseWaitDialog : Form, IThemeableControl
    {
        private bool AllowClose = false;
        public EventHandler OperationComplete { get; private set; }
        public CPleaseWaitDialog(string title, string description)
        {
            InitializeComponent();
            UIThemeManager.OnThemeChanged(this, OnThemeChanged_Implementation);
            this.SetThemeAware();
            MaximizeBox = true;
            MinimizeBox = true;
            Text = title;
            InnerForm.TitleBarTitle = title;
            ErrorRTB.Text = description;
            FormClosing += CPleaseWaitDialog_FormClosing;
            InnerForm.SetExitHidden(true);
            InnerForm.SetDraggable(false);
            OperationComplete = CloseFormInternal;
        }

        private void CPleaseWaitDialog_FormClosing(object sender, FormClosingEventArgs e)
        {
            if(!AllowClose)
            {
                e.Cancel = true;
                return;
            }
        }

        private void CloseFormInternal(object sender, EventArgs e)
        {
            AllowClose = true;
            Close();
        }

        private void OnThemeChanged_Implementation(UIThemeInfo themeData)
        {
            return;
        }

        public IEnumerable<Control> GetThemedControls()
        {
            yield return InnerForm;
            yield return ErrorRTB;
        }

        private void AcceptButton_Click(object sender, EventArgs e)
        {
            Close();
        }

        private void button1_Click(object sender, EventArgs e)
        {

        }
    }
}
