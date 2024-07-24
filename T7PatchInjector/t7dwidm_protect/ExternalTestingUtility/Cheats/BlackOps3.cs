using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static t7dwidm_protect.Cheats.BlackOps3.Constants;
using static System.ExCallThreadType;

namespace t7dwidm_protect.Cheats
{
    internal static class BlackOps3
    {
        internal static class Constants
        {
            //public const ulong OFF_DEBUGTARGET = 0x143A606;
            public const ulong OFF_GAME_READY = 0x168ED8C8;
            public const ulong OFF_DVAR_SETFROMSTRINGBYNAME = 0x22C7500;
            //public const ulong OFF_CL_HandleVoiceTypePacket = 0x1359310;
        }


        private static ProcessEx __game;
        internal static ProcessEx Game
        {
            get
            {
                if (__game is null || __game.BaseProcess is null || __game.BaseProcess.HasExited)
                {
                    __game = "blackops3";
                    if (__game == null || (__game.BaseProcess?.HasExited ?? true))
                    {
                        throw new Exception("Black Ops 3 process not found.");
                    }
                    __game.SetDefaultCallType(XCTT_QUAPC);
                    __game.RPCThreadTimeoutMS = 10000;
                }
                if (!__game.Handle)
                {
                    __game.OpenHandle(ProcessEx.PROCESS_ACCESS, true);
                }
                return __game;
            }
        }

        public static bool IsGamePresent()
        {
            try
            {
                _ = Game.BaseProcess;
            }
            catch
            {
                return false;
            }
            return true;
        }

        public static void SetDvar(string name, string value)
        {
            if (name is null || value is null) return;
            var f = Game[OFF_DVAR_SETFROMSTRINGBYNAME];
            Game.Call<long>(f, name, value, true);
        }

        #region typedef
        #endregion
    }
}
