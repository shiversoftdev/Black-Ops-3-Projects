player_monitor_cherry()
{
    if(!isdefined(level._custom_perks["specialty_electriccherry"])) return;
    self endon("bled_out");
    self endon("spawned_player");
	self endon("disconnect");
    level endon("game_ended");
	for(;;)
	{
		self waittill("reload_start");
        wait 0.025;
        if(!self hasPerk("specialty_electriccherry"))
        {
            continue;
        }
		current_weapon = self getcurrentweapon();
		n_clip_current = 1;
		n_clip_max = 10;
		n_fraction = n_clip_current / n_clip_max;
		perk_radius = math::linear_map(n_fraction, 1, 0, 32, 256);
		perk_dmg = math::linear_map(n_fraction, 1, 0, 1, PVP_ELECTRIC_CHERRY_DMG * CLAMPED_ROUND_NUMBER);
		a_players = getplayers();
        a_players = util::get_array_of_closest(self.origin, a_players, undefined, undefined, perk_radius);
        arrayremovevalue(a_players, self, true);
        if(!isdefined(a_players) || a_players.size < 1)
        {
            continue;
        }
        foreach(player in a_players)
        {
            if(player.sessionstate != "playing")
            {
                continue;
            }
            if(!BulletTracePassed(player geteye(), self geteye(), false, player))
            {
                continue;
            }
            if(player.team == self.team)
            {
                continue;
            }
            if(player.health > perk_dmg) player thread electric_cherry_stun();
            player thread electric_cherry_shock_fx();
            player dodamage(perk_dmg, self.origin, self, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
        }
	}
}

electric_cherry_shock_fx()
{
	self playsound("zmb_elec_jib_zombie");
    self thread playFXTimedOnTag(level._effect["tesla_shock"], "j_head", 2);
}

electric_cherry_stun(b_novisual = false)
{
	self endon("bled_out");
    self endon("disconnect");
	self notify("stun_zombie");
	self endon("stun_zombie");

	if(self.sessionstate != "playing" || self.health <= 0) return;
    self set_move_speed_scale(0.5, true);
    if(!self util::is_bot() && !b_novisual) self SetElectrified(2);
    wait 2;
    self set_move_speed_scale(1);
}