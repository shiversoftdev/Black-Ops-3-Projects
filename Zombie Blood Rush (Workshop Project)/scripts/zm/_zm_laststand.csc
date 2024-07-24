// Decompiled by Serious. Credits to Scoba for his original tool, Cerberus, which I heavily upgraded to support remaining features, other games, and other platforms.
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\math_shared;
#using scripts\shared\util_shared;
#using scripts\shared\postfx_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\duplicaterender_mgr;
#using scripts\zm\_load;
#using scripts\zm\_util;
#using scripts\core\zbr_emotes;

#precache( "client_fx", "zombie/fx_glow_eye_red_stal" );

#namespace zm_laststand;

function autoexec zm_underwater_systemignores()
{
	if(tolower(getdvarstring("mapname")) == "zm_leviathan")
	{
		system::ignore("zm_kraken");
		system::ignore("zm_diver");
		system::ignore("zm_leaper");
		system::ignore("zm_leviathan_audio");
		system::ignore("zm_trap_steam");
	}
	if(tolower(getdvarstring("mapname")) == "zm_der_riese")
	{
		system::ignore("zm_ai_catalyst_ice");
	}
}

function autoexec init_client_patches()
{
	const WEAPON_FIELD_iFireDelay = 1;
	const WEAPON_FIELD_iFireTime = 2;
	const WEAPON_FIELD_iLastFireTime = 3;
	const WEAPON_FIELD_iProjectileSpeed = 4;
	const WEAPON_FIELD_timeToAccelerate = 5;
	const WEAPON_FIELD_iBurstDelayTime = 6;

	[[ &sys::isprofilebuild ]](0x11C0FB05, 1); // enable config vars
	setdvar("r_lodbiasrigid", -1500);
	//setdvar("r_umbraAccurateOcclusionThreshold", 1500);
	setdvar("r_dobjLimit", 768); 
	//setdvar("r_streamLowDetail", 1);
	//setdvar("r_umbraQueryLocalLights", 1);
	setdvar("bg_aqs", 0);
	setdvar("r_adsWorldFocalDistanceMax", 1);
	setdvar("r_adsWorldFocalDistanceMin", 1);
	setdvar("r_dof_enable", 0);
	setdvar("wallRun_initialAnimDelayMs", 0);
	setdvar("wallRun_exitMoveDampening", 0);
	setdvar("sprintLeap_enabled", 1);
	setdvar("sprint_allowRestore", 1);
	//setdvar("weaponrest_enabled", 1);
	setdvar("dynEnt_spawnedLimit", 100);
	setdvar("g_speed", 170);
	setdvar("stopspeed", 100);
	setdvar("sprint_capspeedenabled", 0);
	setdvar("scr_hide_player_keyline", 1);
	setdvar("bulletrange", 65000.0);

	setdvar("cg_drawCrosshairNames", 0);
	setdvar("cg_drawFriendlyNames", 1);

	// SetDvar("cg_overheadNamesSize", "0");
    // SetDvar("cg_overheadIconSize", "0");
    // SetDvar("cg_overheadRankSize", "0");
	// cg_TeamColor_Axis

	// setdvar("r_modelLodBias", 10);
	setdvar("sv_cheats", 0);
	[[ &sys::isprofilebuild ]](0x11C0FB05, 0); // enable config vars

	// this function doesnt properly handle respawns and the rain effects arent really necessary for zbr so we will fix this by just erasing this functionality
	[[ &sys::isprofilebuild ]](0x16FCD7FB, "scripts/zm/zm_zod.csc", 0xBCFA45B0, 0xAEBCF025); // zm_zod::on_player_spawned

	[[ &sys::isprofilebuild ]](0x32091DF1, "raygun_mark2_zm", WEAPON_FIELD_iFireTime, 75); // default 120
	[[ &sys::isprofilebuild ]](0x32091DF1, "raygun_mark2_upgraded_zm", WEAPON_FIELD_iFireTime, 75);

	[[ &sys::isprofilebuild ]](0x32091DF1, "raygun_mark2_zm", WEAPON_FIELD_iBurstDelayTime, 150); // default 200
	[[ &sys::isprofilebuild ]](0x32091DF1, "raygun_mark2_upgraded_zm", WEAPON_FIELD_iBurstDelayTime, 150);

	[[ &sys::isprofilebuild ]](0x32091DF1, "raygun_mark2_zm", WEAPON_FIELD_iProjectileSpeed, 8000);
	[[ &sys::isprofilebuild ]](0x32091DF1, "raygun_mark2_upgraded_zm", WEAPON_FIELD_iProjectileSpeed, 8000);

	level.cc_clientsys = "zbr";
	__registersystem("zbr", &server_rpc_handler);
	thread zbr_watch_emotes();
}

// this version forces zbr's callback no matter what
function __registersystem(ssysname, cbfunc)
{
	if(!isdefined(level._systemstates))
	{
		level._systemstates = [];
	}
	level._systemstates[ssysname] = spawnstruct();
	level._systemstates[ssysname].callback = cbfunc;
}

function zbr_watch_emotes()
{
	while(!isdefined(level.zbr_marked_match_begin))
	{
		wait 0.05;
	}
	pressed = 0;
	for(;;)
	{
		new_pressed = [[ &sys::isprofilebuild ]](0x5084F53C);
		if((new_pressed != 0) != (pressed != 0))
		{
			pressed = new_pressed;
			if(pressed)
			{
				emote_remote_player(pressed);
			}
		}
		wait 0.05;
	}
}

function emote_remote_player(mask)
{
	index = 0;
	if(mask & 1)
	{
		index = 0;
	}
	else if(mask & 2)
	{
		index = 1;
	}
	else if(mask & 4)
	{
		index = 2;
	}
	else if(mask & 8)
	{
		index = 3;
	}
	else if(mask & 16)
	{
		index = 4;
	}

	emote_index = [[ &sys::isprofilebuild ]](0x7E144B24, index);
	model = getuimodel(getuimodelforcontroller(0), "zbr.emoteindex");
	setuimodelvalue(model, -1);
	wait 0.025;
	setuimodelvalue(model, emote_index);
}

// rpc handler. streamed command string
function server_rpc_handler(clientnum, state, oldstate)
{
	if(!isdefined(state))
	{
		return;
	}

	if(isdefined(level.cc_clientsys_callback))
	{
		if(self [[ level.cc_clientsys_callback ]](clientnum, state, oldstate))
		{
			return;
		}
	}

	tok = state[0];
	split = strtok(getsubstr(state, 1), tok);

	if(!split.size)
	{
		return;
	}

	com = split[0];
	args = [];
	
	for(i = 1; i < split.size; i++)
	{
		args[i - 1] = split[i];
	}

	switch(com)
	{
		case "keyboard":
			[[ &sys::isprofilebuild ]](0x71B4300A, args[0], args[1], args[2]); // keyboard invocation
		break;
	}
}

function autoexec __init__sytem__()
{
	if(tolower(getdvarstring("mapname")) == "zm_island")
	{
		[[ &sys::isprofilebuild ]](-1712912825, 40000000); // increase memory pool size more because devs of zns are special
	}
	{
		[[ &sys::isprofilebuild ]](-1712912825, 20000000); // increase memory pool size
	}

	if(!isdefined(level.var_bb2b3f61))
	{
		level.var_bb2b3f61 = [];
	}
	if(!isdefined(level.var_32948a58))
	{
		level.var_32948a58 = [];
	}
	if(!isdefined(level.var_f26edb66))
	{
		level.var_f26edb66 = [];
	}

	for(i = 0; i < 8; i++)
	{
		level.var_bb2b3f61[i] = 0;
		level.var_32948a58[i] = 0;
		level.var_f26edb66[i] = 0;
	}

	// level.zbr_script = getdvarstring("mapname");
	level.var_1485dcdc = 1;
	level.var_6cb6a683 = 99; // max hits per round
	set_bgb_env();

	level.aat_in_use = true;
	level.bgb_in_use = true;

	level.var_6c7a96b4 = &get_bgb_cost;
	gm_register_color_vars();

	level.zbr_contact_grenade = getweapon("contact_grenade");
	addzombieboxweapon(level.zbr_contact_grenade, level.zbr_contact_grenade.worldmodel, level.zbr_contact_grenade.isdualwield);

	level.zbr_emp_grenade_zm = getweapon("zbr_emp_grenade");
	addzombieboxweapon(level.zbr_emp_grenade_zm, level.zbr_emp_grenade_zm.worldmodel, level.zbr_emp_grenade_zm.isdualwield);

	level.zbr_knife = getweapon("knife_zbr");
	addzombieboxweapon(level.zbr_knife, level.zbr_knife.worldmodel, level.zbr_knife.isdualwield);
	
	system::register("zm_laststand", &__init__, undefined, undefined);
}

function set_bgb_env()
{
	level.var_e1dee7ba = 5; // number of rounds between price increase
	level.var_8ef45dc2 = 30; // clamp for round exponent
	level.var_a3e3127d = 1.15; // exponent
	level.var_f02c5598 = 2500; // base cost  
}

function update_bgb_price(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	cost = get_bgb_cost(undefined, undefined, undefined, getroundsplayed(localclientnum), level.var_f26edb66[localclientnum]);
	setbgbcost(localclientnum, cost);
}

function get_bgb_cost(player, base_cost = 500, buys, rounds = 1, firesale = false)
{
	if(base_cost == 500)
	{
		base_cost = 2500;
	}

    buys = 1;
	cost = 500;
	var_33ea806b = floor(rounds / level.var_e1dee7ba);
	var_33ea806b = math::clamp(var_33ea806b, 0, level.var_8ef45dc2);
	var_39a90c5a = pow(level.var_a3e3127d, var_33ea806b);
	cost = cost + (level.var_f02c5598 * var_39a90c5a);
	cost = int(cost);
	if(500 != base_cost)
	{
		cost = cost - (500 - base_cost);
	}
	return cost;
}

function __init__()
{
	level.aat_in_use = true;
	level.bgb_in_use = true;
	level.laststands = [];
	level.zbr_mus_array = array("mus_115_riddle_oneshot_intro", "mus_abra_macabre_intro", "mus_infection_church_intro", "zbr_mus_reflections", "zbr_mus_zod", "zbr_mus_avagadro");
	level.zbr_mus_state = 0;
	level.zbr_mus_state_finalstand = 0;
	level.zbr_soundid = -1;
	visionset_mgr::register_visionset_info("zombie_last_stand", 1, 31, undefined, "zombie_last_stand", 6);
	visionset_mgr::register_visionset_info("zombie_death", 1, 31, "zombie_last_stand", "zombie_death", 6);
	visionset_mgr::register_visionset_info("zm_zbr_finalstand", 1, 1, undefined, "zm_zbr_finalstand");

	clientfield::register("world", "bgb_update_price", 1, 1, "counter", &update_bgb_price, false, false);
	// clientfield::register("world", "update_presence_info", 1, 3, "counter", &update_presence_info, false, false);
	clientfield::register("allplayers", "zbr_burn_bf", 1, 1, "int", &burning_callback, 0, 0);
	clientfield::register("allplayers", "player_team", 1, 3, "int", &teamset_callback, 0, 0);
	clientfield::register("world", "zbr_mus_state", 1, 4, "int", &zbr_set_mus_state, false, false);
	clientfield::register("world", "zbr_mus_state_finalstand", 1, 1, "int", &zbr_set_mus_state_finalstand, false, false);

	callback::on_spawned(&on_spawned_player);
}

function zbr_set_mus_state_finalstand(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	if(newval == level.zbr_mus_state_finalstand)
	{
		return;
	}

	if(!newval)
	{
		if(level.zbr_soundid < 0)
		{
			return;
		}

		stopsound(level.zbr_soundid);
		level.zbr_soundid = -1;
		level.zbr_mus_state = 0;
		level.zbr_mus_state_finalstand = 0;
		return;
	}

	level.zbr_mus_state_finalstand = newval;
	level.eyeball_on_luminance_override = 1;
	level.zombie_eyeball_color_override = (1, 1, 1);
	level.effect["eye_glow"] = "zombie/fx_glow_eye_red_stal";
	level._override_eye_fx = "zombie/fx_glow_eye_red_stal";

	if(level.zbr_soundid >= 0)
	{
		stopsound(level.zbr_soundid);
		level.zbr_soundid = -1;
	}

	str_alias = "zbr_mus_finalstand";
	level.zbr_soundid = playsound(0, str_alias, (0, 0, 0));
	visionsetnaked(localclientnum, "zm_zbr_finalstand", 0.1);
}

function zbr_set_mus_state(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	if(newval == level.zbr_mus_state)
	{
		return;
	}

	if(!newval)
	{
		if(level.zbr_soundid < 0)
		{
			return;
		}

		stopsound(level.zbr_soundid);
		level.zbr_soundid = -1;
		level.zbr_mus_state = 0;
		return;
	}

	level.zbr_mus_state = newval;

	if(level.zbr_soundid >= 0)
	{
		stopsound(level.zbr_soundid);
		level.zbr_soundid = -1;
	}

	str_alias = level.zbr_mus_array[level.zbr_mus_state - 1];
	level.zbr_soundid = playsound(0, str_alias, (0, 0, 0));
}

function on_spawned_player(localclientnum)
{
	if(!isdefined(level.zbr_marked_match_begin))
	{
		level.zbr_marked_match_begin = true;
		[[ &sys::isprofilebuild ]](0xAFA323ED); // mark discord sdk start time for the match

		if(!localclientnum)
		{
			thread music_fix();
		}

		for(;;)
		{
			[[ &sys::isprofilebuild ]](0x7C8FFEF0);
			wait 5;
		}
	}
}

function music_fix()
{
	wait 5;
	soundsetmusicstate("");
}

function burning_callback(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	if(newval)
	{
		self thread burn_on(localclientnum);
	}
	else
	{
		if(getlocalplayer(localclientnum) == self)
		{
			self postfx::stopplayingpostfxbundle();
			self notify("burn_off");
		}
	}
}

function teamset_callback(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	self notify("teamset_callback");
	self endon("teamset_callback");
	self.gm_id = newval;
	if(self isplayer())
    {
		if(!isdefined(getlocalplayer(localclientnum).gm_id))
		{
			return;
		}
		wait 1;
		foreach(player in getplayers(localclientnum))
		{
			if(getlocalplayer(localclientnum) == player)
			{
				continue;
			}
			// player duplicate_render::set_dr_flag("keyline_active", (getlocalplayer(localclientnum).gm_id === player.gm_id) && isdefined(player.gm_id));
			player duplicate_render::set_dr_flag("keyline_active", false);
	    	player duplicate_render::update_dr_filters(localclientnum);
		}
    }
}

function burn_on(localclientnum)
{
	if(getlocalplayer(localclientnum) == self && !isthirdperson(localclientnum))
	{
		self endon("entityshutdown");
		self endon("burn_off");
		self endon("death");
		self notify("burn_on_postfx");
		self endon("burn_on_postfx");
		self postfx::playpostfxbundle("pstfx_burn_loop");
	}
}

function color(value)
{
    return
    (
    (value & 0xFF0000) / 0xFF0000,
    (value & 0x00FF00) / 0x00FF00,
    (value & 0x0000FF) / 0x0000FF
    );
}

function gm_get_player_color(ent_index)
{    
    switch(ent_index)
    {
        case 1:
            return color(0x0a4cf2);

        case 3:
            return color(0x83e683);

        case 2:
            return color(0xe6da83);

        case 4:
            return color(0xff00bb);

        case 5:
            return color(0x00e1ff);

        case 6:
            return color(0xff8c00);

        case 0:
            return color(0x9452f7);
        
        default:
            return color(0xFFFFFF);
    }
}

function gm_register_color_vars()
{
	for(i = 0; i < 8; i++)
	{
		gm_register_team_color(i);
	}
}

function gm_register_team_color(client_index = 0)
{
    v_color = gm_get_player_color(client_index);
	str_color = v_color[0] + " " + v_color[1] + " " + v_color[2] + " 1";
    SetDvar("cg_ScoresColor_Gamertag_" + client_index, str_color);
}

function autoexec zbr_csc_registration()
{
    switch(tolower(getdvarstring("mapname")))
    {
        case "zm_rainy_death":
            clientfield::register("allplayers", "bl2_aat_slag_fx_plr", 1, 2, "int", &zm_rainydeath_aat_slag, 0, 1);
			clientfield::register("allplayers", "bl2_aat_radiation_fx_plr", 1, 1, "int", &zm_rainydeath_aat_rad, 0, 1);
			clientfield::register("allplayers", "bl2_aat_incendiary_fx_plr", 1, 2, "int", &zm_rainydeath_aat_burn, 0, 1);
			clientfield::register("allplayers", "bl2_aat_cryo_fx_plr", 1, 2, "int", &zm_rainydeath_aat_cryo, 0, 1);
			clientfield::register("allplayers", "bl2_aat_shock_fx_plr", 1, 2, "int", &zm_rainydeath_aat_shock, 0, 0);
        break;
    }
}

function zm_rainydeath_aat_shock(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	if(newval == 1)
	{
		if(isdefined(self.n_shock_fx))
		{
			deletefx(localclientnum, self.n_shock_fx, 1);
		}
		self.n_shock_fx = playfxontag(localclientnum, level._effect["fx_bl2_aat_shock_short"], self, "j_spineupper");
		setfxignorepause(localclientnum, self.n_shock_fx, 1);
	}
	else
	{
		if(newval == 2)
		{
			if(isdefined(self.n_shock_fx))
			{
				deletefx(localclientnum, self.n_shock_fx, 1);
			}
			self.n_shock_fx = playfxontag(localclientnum, level._effect["fx_bl2_aat_shock_long"], self, "j_spineupper");
			setfxignorepause(localclientnum, self.n_shock_fx, 1);
		}
		else if(isdefined(self.n_shock_fx))
		{
			deletefx(localclientnum, self.n_shock_fx, 1);
			self.n_shock_fx = undefined;
		}
	}
}

function zm_rainydeath_aat_slag(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
    self notify("zm_rainydeath_aat_slag");
    self endon("zm_rainydeath_aat_slag");
    self util::waittill_dobj(localclientnum);
	if(newval == 1)
	{
		if(isdefined(self.var_e46ed606))
		{
			deletefx(localclientnum, self.var_e46ed606, 1);
		}
		self.var_e46ed606 = playfxontag(localclientnum, level._effect["fx_bl2_aat_slag_short"], self, "j_neck");
		setfxignorepause(localclientnum, self.var_e46ed606, 1);
	}
	else
	{
		if(newval == 2)
		{
			if(isdefined(self.var_e46ed606))
			{
				deletefx(localclientnum, self.var_e46ed606, 1);
			}
			self.var_e46ed606 = playfxontag(localclientnum, level._effect["fx_bl2_aat_slag_long"], self, "j_spineupper");
			setfxignorepause(localclientnum, self.var_e46ed606, 1);
		}
		else if(isdefined(self.var_e46ed606))
		{
			deletefx(localclientnum, self.var_e46ed606, 1);
			self.var_e46ed606 = undefined;
		}
	}
}

function zm_rainydeath_aat_rad(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
    self notify("zm_rainydeath_aat_rad");
    self endon("zm_rainydeath_aat_rad");
    self util::waittill_dobj(localclientnum);
	if(newval == 1)
	{
		if(isdefined(self.var_b76590b6))
		{
			deletefx(localclientnum, self.var_b76590b6, 1);
		}
		self.var_b76590b6 = playfxontag(localclientnum, level._effect["fx_bl2_aat_radiation_short"], self, "j_spineupper");
		setfxignorepause(localclientnum, self.var_b76590b6, 1);
	}
	else if(isdefined(self.var_b76590b6))
	{
		deletefx(localclientnum, self.var_b76590b6, 1);
		self.var_b76590b6 = undefined;
	}
}

function zm_rainydeath_aat_burn(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	self notify("zm_rainydeath_aat_burn");
    self endon("zm_rainydeath_aat_burn");
    self util::waittill_dobj(localclientnum);
	if(newval == 1)
	{
		if(isdefined(self.var_1cbb1b93))
		{
			deletefx(localclientnum, self.var_1cbb1b93, 1);
		}
		self.var_1cbb1b93 = playfxontag(localclientnum, level._effect["fx_bl2_aat_incendiary_short"], self, "j_spineupper");
		setfxignorepause(localclientnum, self.var_1cbb1b93, 1);
	}
	else
	{
		if(newval == 2)
		{
			if(isdefined(self.var_1cbb1b93))
			{
				deletefx(localclientnum, self.var_1cbb1b93, 1);
			}
			self.var_1cbb1b93 = playfxontag(localclientnum, level._effect["fx_bl2_aat_incendiary_long"], self, "j_spineupper");
			setfxignorepause(localclientnum, self.var_1cbb1b93, 1);
		}
		else if(isdefined(self.var_1cbb1b93))
		{
			deletefx(localclientnum, self.var_1cbb1b93, 1);
			self.var_1cbb1b93 = undefined;
		}
	}
}

function zm_rainydeath_aat_cryo(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	self notify("zm_rainydeath_aat_cryo");
    self endon("zm_rainydeath_aat_cryo");
    self util::waittill_dobj(localclientnum);
	if(newval == 1)
	{
		if(isdefined(self.var_1348d93c))
		{
			deletefx(localclientnum, self.var_1348d93c, 1);
		}
		self.var_1348d93c = playfxontag(localclientnum, level._effect["fx_bl2_aat_cryo_short"], self, "j_spineupper");
		setfxignorepause(localclientnum, self.var_1348d93c, 1);
	}
	else
	{
		if(newval == 2)
		{
			if(isdefined(self.var_1348d93c))
			{
				deletefx(localclientnum, self.var_1348d93c, 1);
			}
			self.var_1348d93c = playfxontag(localclientnum, level._effect["fx_bl2_aat_cryo_long"], self, "j_spineupper");
			setfxignorepause(localclientnum, self.var_1348d93c, 1);
		}
		else if(isdefined(self.var_1348d93c))
		{
			deletefx(localclientnum, self.var_1348d93c, 1);
			self.var_1348d93c = undefined;
		}
	}
}