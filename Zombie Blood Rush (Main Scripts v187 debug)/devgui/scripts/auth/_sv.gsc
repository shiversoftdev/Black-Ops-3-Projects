#define STR_XUID = "TODO playerxuid";
#define __XUID__ = self [[ level.__PROTECTED__getdstat ]](STR_XUID);

// TODO obfuscate
autoexec __entrypoint()
{
    level.__PROTECTED__getdstat = sys::getdstat;
}

