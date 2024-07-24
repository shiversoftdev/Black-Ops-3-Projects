using t7dwidm_protect.Cheats;
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
using System.Diagnostics;
using System.ExThreads;
using System.IO;
using System.Text.Json;
using System.Net;

namespace t7dwidm_protect
{
    public partial class MainForm : Form, IThemeableControl
    {
        bool DEBUG = false;
        private bool SpendingVials;
        private bool SpendingKeys;
        private Action UpdateProtection;
        private bool SuspendUIUpdates = false;
        private static string UpdatesURL = "https://raw.githubusercontent.com/shiversoftdev/t7patch/main/version";
        private PlayerSettings Settings = new PlayerSettings();

        public MainForm()
        {
            InitializeComponent();
            UIThemeManager.OnThemeChanged(this, OnThemeChanged_Implementation);
            this.SetThemeAware();
            Text = "T7Patch 2.03 - By Serious";
            this.InnerForm.TitleBarTitle = Text;
            MaximizeBox = false;
            MinimizeBox = false;
            UpdateProtection = __updateprotection;
            if (!File.Exists("settings.json"))
            {
                CommitSettings();
            }
            LoadSettings();
            new Task(() => 
            {
                PollProcesses();
            }).Start();
            NameChangeTimer.Tick += NameChangeTimer_Tick;
            netpasstimer.Tick += Netpasstimer_Tick;
            label3.Cursor = Cursors.Hand;
            DoubleBuffered = true;

            try
            {
                string lv = "2.0.04";
                ulong local_version = ParseVersion(lv);
                ulong remote_version = 0;
                Console.WriteLine($"Checking client version... (our version is {local_version:X})");
                using (WebClient client = new WebClient())
                {
                    string downloadString = client.DownloadString(UpdatesURL);
                    remote_version = ParseVersion(downloadString.ToLower().Trim());
                }
                if (local_version < remote_version)
                {
                    SMC.UI.Core.Controls.CErrorDialog.Show("Info", "A new version of the patch is available!\n\nDownload now: https://gsc.dev/s/patch");
                }
            }
            catch
            {
                // we dont care if we cant update tbf
                Console.WriteLine($"Error updating client... ignoring update");
            }
        }

        private static ulong ParseVersion(string vstr)
        {
            ulong result = 0;
            string[] numbers = vstr.Split('.');
            int index = 0;
            for (int i = 0; i < numbers.Length; i++, index++)
            {
                int real_index = numbers.Length - 1 - i;
                ulong num = ushort.Parse(numbers[real_index]);
                result += num << (index * 16);
            }
            return result;
        }

        private void Netpasstimer_Tick(object sender, EventArgs e)
        {
            Settings.NetworkPassword = cThemedTextbox2.Text;
            CommitSettings();
            if (BlackOps3.IsGamePresent() && moduleHandle != null)
            {
                BlackOps3.Game.Call(moduleHandle["SetNetworkPassword"], Settings.NetworkPassword);
            }
            netpasstimer.Stop();
        }

        private void NameChangeTimer_Tick(object sender, EventArgs e)
        {
            Settings.Playername = cThemedTextbox1.Text;
            if(Settings.Playername.Length >= 16)
            {
                Settings.Playername = Settings.Playername.Substring(0, 15);
            }
            CommitSettings();
            if (BlackOps3.IsGamePresent() && moduleHandle != null)
            {
                BlackOps3.Game.Call(moduleHandle["SetPlayerName"], Settings.Playername);
            }
            NameChangeTimer.Stop();
        }

        private void CommitSettings()
        {
            var serializeOptions = new JsonSerializerOptions
            {
                PropertyNamingPolicy = new LowerNamePol(),
                PropertyNameCaseInsensitive = true,
                WriteIndented = true
            };
            File.WriteAllBytes("settings.json", Encoding.ASCII.GetBytes(JsonSerializer.Serialize(Settings, typeof(PlayerSettings), serializeOptions)));
        }

        private void LoadSettings()
        {
            var serializeOptions = new JsonSerializerOptions
            {
                PropertyNamingPolicy = new LowerNamePol(),
                PropertyNameCaseInsensitive = true,
                WriteIndented = true
            };
            Settings = (PlayerSettings)JsonSerializer.Deserialize(File.ReadAllBytes("settings.json"), typeof(PlayerSettings), serializeOptions);

            if(Settings.Playername.Length >= 16)
            {
                Settings.Playername = Settings.Playername.Substring(0, 15);
            }

            SuspendUIUpdates = true;
            cThemedTextbox1.Text = Settings.Playername;
            FriendsOnlyCB.Checked = Settings.IsFriendsOnly;
            cThemedTextbox2.Text = Settings.NetworkPassword;
            // MtlpatchEnablerCB.Checked = Settings.IsMTLPatchEnabled;
            SuspendUIUpdates = false;
        }

        private void PollProcesses()
        {
            while(true)
            {
                UpdateProtection?.Invoke();
                System.Threading.Thread.Sleep(250);
            }
        }

        private static byte[] ExtractResource(String filename)
        {
            System.Reflection.Assembly a = System.Reflection.Assembly.GetExecutingAssembly();
            using (Stream resFilestream = a.GetManifestResourceStream(filename))
            {
                if (resFilestream == null) return null;
                byte[] ba = new byte[resFilestream.Length];
                resFilestream.Read(ba, 0, ba.Length);
                return ba;
            }
        }

        ProcessModuleEx moduleHandle = null;

        private List<int> pidsOwned = new List<int>();
        private void __updateprotection()
        {
            try
            {
                if (BlackOps3.Game != null)
                {

                    // check if the game has exited
                    if (BlackOps3.Game.BaseProcess.HasExited)
                    {
                        throw new Exception("Black Ops 3 process");
                    }

                    do
                    {
                        // protect a new process if found
                        if (!pidsOwned.Contains(BlackOps3.Game.BaseProcess.Id))
                        {
                            if (BlackOps3.Game.GetValue<long>(BlackOps3.Game[BlackOps3.Constants.OFF_GAME_READY]) == 0)
                            {
                                break;
                            }

                            if(!(BlackOps3.Game["zbr.dll"] is null)) // dont inject when its a zbr process
                            {
                                break;
                            }

                            //if((BlackOps3.Game.GetValue<byte>(BlackOps3.Game[0x162E4410]) & 1) != 1) // ui loaded once
                            //{
                            //    break;
                            //}

                            //// disable voice packet dispatching
                            BlackOps3.SetDvar("maxvoicepacketsperframe", "0");

                            //// disable callvote
                            BlackOps3.SetDvar("sv_mapswitch", "0");

                            var bytes = ExtractResource("t7dwidm_protect.t7patch.dll");
                            var bytes2 = ExtractResource("t7dwidm_protect.zbr2.dll");
                            if (true)
                            {
                                try
                                {
                                    File.WriteAllBytes("t7patch.dll", bytes);
                                }
                                catch
                                {

                                }
                                try
                                {
                                    File.WriteAllBytes("zbr2.dll", bytes2);
                                }
                                catch
                                {

                                }
                                bytes = ExtractResource("t7dwidm_protect.discord_game_sdk.dll");
                                File.WriteAllBytes(Path.Combine(Path.GetDirectoryName(BlackOps3.Game.BaseProcess.MainModule.FileName), "discord_game_sdk.dll"), bytes);
                                moduleHandle = BlackOps3.Game.LoadAndRegisterDllRemote(Path.Combine(Environment.CurrentDirectory, "t7patch.dll"));
                                BlackOps3.Game.LoadAndRegisterDllRemote(Path.Combine(Environment.CurrentDirectory, "zbr2.dll"));
                            }
                            else
                            {
                                var hModule = BlackOps3.Game.MapModule(bytes, new ModuleLoadOptions() { ClearHeader = false, ExecMain = true, MainThreadType = ExCallThreadType.XCTT_QUAPC });
                                moduleHandle = ProcessModuleEx.FromMappedModule(hModule, bytes);
                            }
                            BlackOps3.Game.Call(moduleHandle["zbr_run_gamemode_lui"], "serious_anticrash_2023");
                            BlackOps3.Game.Call(moduleHandle["SetPlayerName"], Settings.Playername);
                            BlackOps3.Game.Call(moduleHandle["SetFriendsOnly"], Settings.IsFriendsOnly);
                            BlackOps3.Game.Call(moduleHandle["SetNetworkPassword"], Settings.NetworkPassword);

                            StatusLabel.Text = "Protected Process with ID: " + BlackOps3.Game.BaseProcess.Id;
                            pidsOwned.Add(BlackOps3.Game.BaseProcess.Id);
                            UIThemeManager.ApplyTheme(Orange());
                        }
                    } while (false);
                }
            }
            catch(Exception e)
            {
                moduleHandle = null;
                if(!e.ToString().Contains("Black Ops 3 process"))
                {
                    File.AppendAllText("errors.txt", e.ToString() + "\n\n");

                    if(UIThemeManager.CurrentTheme.AccentColor != Red().AccentColor)
                    {
                        StatusLabel.Text = "An error has occurred.";
                        UIThemeManager.ApplyTheme(Red());
                    }
                }
                else
                {
                    if (UIThemeManager.CurrentTheme.AccentColor != UIThemeInfo.Default().AccentColor)
                    {
                        StatusLabel.Text = "No game process found.";
                        UIThemeManager.ApplyTheme(UIThemeInfo.Default());
                    }
                }
            }
        }

        internal static UIThemeInfo Orange()
        {
            UIThemeInfo theme = new UIThemeInfo();
            theme.BackColor = Color.FromArgb(28, 28, 28);
            theme.TextColor = Color.WhiteSmoke;
            theme.AccentColor = Color.DarkOrange;
            theme.TitleBarColor = Color.FromArgb(36, 36, 36);
            theme.ButtonFlatStyle = FlatStyle.Flat;
            theme.ButtonHoverColor = Color.FromArgb(50, 50, 50);
            theme.LightBackColor = Color.FromArgb(36, 36, 36);
            theme.ButtonActive = Color.DarkOrange;
            theme.TextInactive = Color.Gray;
            return theme;
        }

        internal static UIThemeInfo Red()
        {
            UIThemeInfo theme = new UIThemeInfo();
            theme.BackColor = Color.FromArgb(28, 28, 28);
            theme.TextColor = Color.WhiteSmoke;
            theme.AccentColor = Color.Red;
            theme.TitleBarColor = Color.FromArgb(36, 36, 36);
            theme.ButtonFlatStyle = FlatStyle.Flat;
            theme.ButtonHoverColor = Color.FromArgb(50, 50, 50);
            theme.LightBackColor = Color.FromArgb(36, 36, 36);
            theme.ButtonActive = Color.Red;
            theme.TextInactive = Color.Gray;
            return theme;
        }

        public IEnumerable<Control> GetThemedControls()
        {
            yield return InnerForm;
            yield return StatusLabel;
            yield return label1;
            yield return cThemedTextbox1;
            yield return FriendsOnlyCB;
            yield return label3;
            yield return cThemedTextbox2;
        }

        private void OnThemeChanged_Implementation(UIThemeInfo currentTheme)
        {
            label3.ForeColor = currentTheme.AccentColor;
        }

        private void RPCExample3_Click(object sender, EventArgs e)
        {
        }

        private void ExampleRPC4_Click(object sender, EventArgs e)
        {
        }

        private void button1_Click(object sender, EventArgs e)
        {
        }

        private void cThemedTextbox1_TextChanged(object sender, EventArgs e)
        {
            if (SuspendUIUpdates) return;
            NameChangeTimer.Stop();
            NameChangeTimer.Start();
        }

        private void FriendsOnlyCB_CheckedChanged(object sender, EventArgs e)
        {
            if (SuspendUIUpdates) return;
            Settings.IsFriendsOnly = FriendsOnlyCB.Checked;
            CommitSettings();
            if (BlackOps3.IsGamePresent() != null && moduleHandle != null)
            {
                BlackOps3.Game.Call(moduleHandle["SetFriendsOnly"], Settings.IsFriendsOnly);
            }
        }

        private void label3_Click(object sender, EventArgs e)
        {
            Process.Start("https://steamcommunity.com/sharedfiles/filedetails/?id=2696008055");
        }

        private void cThemedTextbox2_TextChanged(object sender, EventArgs e)
        {
            if (SuspendUIUpdates) return;
            netpasstimer.Stop();
            netpasstimer.Start();
        }

        //private void MtlpatchEnablerCB_CheckedChanged(object sender, EventArgs e)
        //{
        //    if (SuspendUIUpdates) return;
        //    Settings.IsMTLPatchEnabled = MtlpatchEnablerCB.Checked;
        //    CommitSettings();
        //    if (BlackOps3.IsGamePresent() != null && moduleHandle != null)
        //    {
        //        BlackOps3.Game.Call(moduleHandle["SetEnableMTLP"], Settings.IsMTLPatchEnabled);
        //    }
        //}
    }

    public class PlayerSettings
    {
        public string Playername { get; set; }
        public bool IsFriendsOnly { get; set; }
        public bool IsMTLPatchEnabled { get; set; }
        public string NetworkPassword { get; set; }

        public PlayerSettings()
        {
            Playername = "";
            IsFriendsOnly = true;
            IsMTLPatchEnabled = false;
            NetworkPassword = "";
        }
    }

    internal class LowerNamePol : JsonNamingPolicy
    {
        public override string ConvertName(string name) =>
            name.ToLower();
    }
}
