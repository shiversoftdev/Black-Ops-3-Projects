// Decompiled by Serious. Credits to Scoba for his original tool, Cerberus, which I heavily upgraded to support remaining features, other games, and other platforms.
#using scripts\shared\aat_shared;
#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;

#namespace zm_aat_turned;

function autoexec __init__sytem__()
{
	system::register("zm_aat_turned", &__init__, undefined, undefined);
}


function __init__()
{
	if(!(isdefined(level.aat_in_use) && level.aat_in_use))
	{
		return;
	}
	aat::register("zm_aat_turned", "zmui_zm_aat_turned", "t7_icon_zm_aat_turned");
	clientfield::register("actor", "zm_aat_turned", 1, 1, "int", &zm_aat_turned_cb, 0, 0);
    clientfield::register("allplayers", "zm_aat_turned", 1, 1, "int", &zm_aat_turned_cb_plr, 0, 0);
}

function zm_aat_turned_cb_plr(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
    if(isdefined(self.fx_aat_turned_eyes))
    {
        stopfx(localclientnum, self.fx_aat_turned_eyes);
        self.fx_aat_turned_eyes = undefined;
    }
    if(isdefined(self.fx_aat_turned_torso))
    {
        stopfx(localclientnum, self.fx_aat_turned_torso);
        self.fx_aat_turned_torso = undefined;
    }
	if(newval)
	{
		self.fx_aat_turned_eyes = playfxontag(localclientnum, "zombie/fx_glow_eye_green", self, "j_eyeball_le");
		self.fx_aat_turned_torso = playfxontag(localclientnum, "zombie/fx_aat_turned_spore_torso_zmb", self, "j_spine4");
        SetFXTeam(localclientnum, self.fx_aat_turned_torso, self.team);
        SetFXTeam(localclientnum, self.fx_aat_turned_eyes, self.team);
	}
}

function zm_aat_turned_cb(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
    if(isdefined(self.fx_aat_turned_eyes))
    {
        stopfx(localclientnum, self.fx_aat_turned_eyes);
        self.fx_aat_turned_eyes = undefined;
    }
    if(isdefined(self.fx_aat_turned_torso))
    {
        stopfx(localclientnum, self.fx_aat_turned_torso);
        self.fx_aat_turned_torso = undefined;
    }
	if(newval)
	{
		self setdrawname(makelocalizedstring("zmui_zm_aat_turned"), 1);
		self.fx_aat_turned_eyes = playfxontag(localclientnum, "zombie/fx_glow_eye_green", self, "j_eyeball_le");
		self.fx_aat_turned_torso = playfxontag(localclientnum, "zombie/fx_aat_turned_spore_torso_zmb", self, "j_spine4");
        SetFXTeam(localclientnum, self.fx_aat_turned_torso, self.team);
        SetFXTeam(localclientnum, self.fx_aat_turned_eyes, self.team);
        self thread watch_turned_death(localclientnum);
	}
}

function watch_turned_death(localclientnum)
{
    self notify("watch_turned_death");
    self endon("watch_turned_death");
    self waittill("death");
    if(isdefined(self.fx_aat_turned_eyes))
    {
        stopfx(localclientnum, self.fx_aat_turned_eyes);
        self.fx_aat_turned_eyes = undefined;
    }
    if(isdefined(self.fx_aat_turned_torso))
    {
        stopfx(localclientnum, self.fx_aat_turned_torso);
        self.fx_aat_turned_torso = undefined;
    }
}