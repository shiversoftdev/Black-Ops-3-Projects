using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.IO;
using System.IO.Compression;
using System.Media;
using System.Net;
using Zombie_Blood_Rush.Properties;
using SMC.UI.Core.Controls;

namespace Zombie_Blood_Rush
{
    public partial class MainForm : Form
    {
        private const int PID_XOR_KEY = 0x4357FC1D;
        private const string VERSION_NUM = "1.05";
        private const string VERSION = "version_" + VERSION_NUM;
        private delegate void UpdateDelegate();
        private UpdateDelegate AskUpdateDelegate;
        public MainForm()
        {
            InitializeComponent();
            MouseDown += Form1_MouseDown;
            panel1.MouseDown += Form1_MouseDown;
            RightBorder.MouseDown += Form1_MouseDown;
            LeftBorder.MouseDown += Form1_MouseDown;
            TopBorder.MouseDown += Form1_MouseDown;
            label3.MouseDown += Form1_MouseDown;
            AskUpdateDelegate = AskUpdate;
            Icon = Resources.zbr_ico2;
            CloseHandle = closehandle;
            ModLoaded = modloaded;
            FailedToLoad = failedtoload;
            foreach (Control c in Controls)
            {
                if(c is CustomButton button)
                {
                    button.BackColor = Color.FromArgb(128, 0, 0, 0);
                    button.FlatAppearance.MouseOverBackColor = Color.FromArgb(0, 0, 0, 0);
                    button.FlatAppearance.MouseDownBackColor = Color.FromArgb(200, 0, 0, 0);
                }
            }
            new Task(() =>
            {
                try
                {
                    using (WebClient client = new WebClient())
                    {
                        string downloadString = client.DownloadString("https://gsc.dev/zbr/t7_version");
                        if (!downloadString.ToLower().Contains("version_")) throw new Exception();
                        if(downloadString != VERSION)
                        {
                            AskUpdateDelegate.Invoke();
                        }
                    }
                }
                catch
                {

                }
            }).Start();

            label4.Text = "v" + VERSION_NUM;
        }

        private void AskUpdate()
        {
            var result = new CErrorDialog("Update Available", "An update to the game mode is available. Click accept to view the new update, or the 'x' to ignore.").ShowDialog();
            if(result == DialogResult.OK)
            {
                Process.Start("https://gsc.dev/s/t7zbr");
            }
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

        private void Form1_Load(object sender, EventArgs e)
        {
        }

        private void label2_Click(object sender, EventArgs e)
        {
            Environment.Exit(0);
        }

        private void label1_Click(object sender, EventArgs e)
        {
            Process.Start("https://www.youtube.com/anthonything");
        }

        private void label3_Click(object sender, EventArgs e)
        {

        }

        Random r = new Random();
        ProcessEx bo3;
        byte[] data;
        // Load mod
        private void button1_Click(object sender, EventArgs e)
        {
            bo3 = "blackops3";
            if(bo3 == null)
            {
                new CErrorDialog("Loading Failed", "Black Ops 3 does not appear to be running. Please load the mod while in a pregame lobby of zombies.").ShowDialog();
                return;
            }
            bo3.OpenHandle(ProcessEx.PROCESS_ACCESS, true);

            if(bo3.GetValue<byte>(bo3[0x1507BC08]) == 0x8C)
            {
                new CErrorDialog("Loading Failed", "You already loaded the mod. Please restart BO3 to inject again.").ShowDialog();
                return;
            }

            // Load the dll
            System.Reflection.Assembly a = System.Reflection.Assembly.GetExecutingAssembly();
            string fileName = "Zombie_Blood_Rush.local_rc.embedded.dll";
            
            using (Stream resFilestream = a.GetManifestResourceStream(fileName))
            {
                if (resFilestream == null)
                {
                    string msg = "";
                    foreach(var n in System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceNames())
                    {
                        msg += n + "\n";
                    }
                    throw new Exception(msg);
                }
                data = new byte[resFilestream.Length];
                resFilestream.Read(data, 0, data.Length);
            }

            // Decompress it
            data = Decompress(data);

            data[0x5C] = (_2v2btn == sender) ? (byte)1 : (byte)0;

            // Write the expected pid
            BitConverter.GetBytes(bo3.BaseProcess.Id ^ PID_XOR_KEY).CopyTo(data, 0x58);

            //// Generate a name and write it to disk
            //string dllNewName = new string(Enumerable.Repeat("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789", 8).Select(s => s[r.Next(s.Length)]).ToArray()) + ".dll";
            //string tfile = Path.Combine(Path.GetTempPath(), dllNewName);
            //File.WriteAllBytes(tfile, data);
            //File.SetLastWriteTime(tfile, new DateTime(r.Next(2019, 2022), r.Next(1, 13), r.Next(1, 28), r.Next(1, 12), r.Next(1, 60), r.Next(1, 60)));
            //File.SetAttributes(tfile, FileAttributes.Hidden | FileAttributes.ReadOnly | FileAttributes.Temporary | FileAttributes.System);

            //var result = Injector.Inject(bo3.OpenHandle(), tfile);
            //bo3?.CloseHandle();
            //switch (result)
            //{
            //    case DllInjectionStatus.AlreadyExists:
            //        new MessageDialog("Loading Failed", "Mod loading failed, please restart Black Ops 3 and try again.").ShowDialog();
            //        return;
            //    case DllInjectionStatus.InjectionFailed:
            //        new MessageDialog("Loading Failed", "Mod loading failed, please restart Black Ops 3 and try again. This error is rare, and should be sent to the developer.").ShowDialog();
            //        return;
            //    case DllInjectionStatus.ProcessWriteFailed:
            //        new MessageDialog("Loading Failed", "Process denied access to load mod. Please try running this program as administrator.").ShowDialog();
            //        return;
            //    case DllInjectionStatus.RemoteAllocationFailed:
            //        new MessageDialog("Loading Failed", "Mod loading failed (allocation), please restart Black Ops 3 and try again.").ShowDialog();
            //        return;
            //    case DllInjectionStatus.Success:
            //        new Task(() => 
            //        {
            //            using (Stream resFilestream = a.GetManifestResourceStream("Zombie_Blood_Rush.local_rc.injected.wav"))
            //            {
            //                var soundplayer = new SoundPlayer(resFilestream);
            //                soundplayer.PlaySync();
            //            }
            //        }).Start();
            //        new MessageDialog("Mod Loaded", "Mod loaded. Enjoy!").ShowDialog();
            //        break;
            //}
            StartBlockingOperation("Please Wait...", "Loading mod... This may take a minute...", (ax, ex) => { this.Invoke(CloseHandle); }, new Task(() =>
            {
                try
                {
                    bo3.MapModule(data, new ModuleLoadOptions() { ExecMain = true });
                    bo3.SetValue<byte>(bo3[0x1507BC08], 0x8C);
                    System.Threading.Thread.Sleep(3000);
                    new Task(() =>
                    {
                        using (Stream resFilestream = a.GetManifestResourceStream("Zombie_Blood_Rush.local_rc.injected.wav"))
                        {
                            var soundplayer = new SoundPlayer(resFilestream);
                            soundplayer.PlaySync();
                        }
                    }).Start();
                    this.Invoke(ModLoaded);
                }
                catch
                {
                    this.Invoke(FailedToLoad);
                }
            }));

            //try
            //{
            //    bo3.MapModule(data, new ModuleLoadOptions() { ExecMain = true });
            //    bo3.SetValue<byte>(bo3[0x1507BC08], 0x8C);
            //    System.Threading.Thread.Sleep(3000);
            //    new Task(() =>
            //    {
            //        using (Stream resFilestream = a.GetManifestResourceStream("Zombie_Blood_Rush.local_rc.injected.wav"))
            //        {
            //            var soundplayer = new SoundPlayer(resFilestream);
            //            soundplayer.PlaySync();
            //        }
            //    }).Start();
            //    new MessageDialog("Mod Loaded", "Mod loaded. Enjoy!").ShowDialog();
            //}
            //catch
            //{
            //    new MessageDialog("Loading Failed", "Mod loading failed, please restart Black Ops 3 and try again. This error is rare, and should be sent to the developer.").ShowDialog();
            //}
            //finally
            //{
            //    bo3?.CloseHandle();
            //}
        }

        private Action ModLoaded, FailedToLoad, CloseHandle;

        private void closehandle()
        {
            bo3?.CloseHandle();
        }

        private void failedtoload()
        {
            new CErrorDialog("Loading Failed", "Mod loading failed, please restart Black Ops 3 and try again. This error is rare, and should be sent to the developer.").ShowDialog();
        }

        private void modloaded()
        {
            new CErrorDialog("Mod Loaded", "Mod loaded. Enjoy!").ShowDialog();
        }

        private object __tlock = new object();
        private bool CanExecuteNow = true;
        private void StartBlockingOperation(string title, string message, EventHandler onFinished, Task taskToRun)
        {
            if (taskToRun == null) return;
            lock (__tlock)
            {
                if (!CanExecuteNow)
                {
                    var watch = new Timer();
                    watch.Tick += (s, e) =>
                    {
                        StartBlockingOperation(title, message, onFinished, taskToRun);
                        watch.Stop();
                    };
                    watch.Interval = 5000;
                    watch.Start();
                    return;
                }
                CanExecuteNow = false;
            }
            var diag = new CPleaseWaitDialog(title, message);
            new Task(() => {
                taskToRun.RunSynchronously();
                onFinished?.Invoke(this, null);
                diag.OperationComplete?.Invoke(this, null);
            }).Start();
            diag.ShowDialog();
            lock (__tlock)
            {
                CanExecuteNow = true;
            }
        }

        private static byte[] Decompress(byte[] data)
        {
            MemoryStream input = new MemoryStream();
            using (var compressStream = new MemoryStream(data))
            using (var compressor = new DeflateStream(compressStream, CompressionMode.Decompress))
            {
                compressor.CopyTo(input);
                compressor.Close();
                return input.ToArray();
            }
        }

        private void button2_Click(object sender, EventArgs e)
        {
            Process.Start("https://github.com/shiversoftdev/t7-zbr");
        }

        private void button3_Click(object sender, EventArgs e)
        {
            Process.Start("https://gsc.dev/zbr/t7_players_guide.txt");
        }

        private void label4_Click(object sender, EventArgs e)
        {
            Process.Start("https://gsc.dev/zbr/t7_changelog.txt");
        }
    }

    public class CustomButton : Button
    {
        public CustomButton()
            : base()
        {
            // Prevent the button from drawing its own border
            FlatAppearance.BorderSize = 0;
            FlatStyle = System.Windows.Forms.FlatStyle.Flat;
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            base.OnPaint(e);

            // Draw Border using color specified in Flat Appearance
            Pen pen = new Pen(FlatAppearance.BorderColor, 1);
            Rectangle rectangle = new Rectangle(0, 0, Size.Width - 1, Size.Height - 1);
            e.Graphics.DrawRectangle(pen, rectangle);
        }
    }
}
