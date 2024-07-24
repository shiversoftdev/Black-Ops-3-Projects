#define MIRG_NONE = 0;
#define MIRG_ANY = 0xFFFFFFFF;
#define MIRG_IS_MIRG = 1;
#define MIRG_UPGRADED = 2;
#define MIRG_CHARGED_1 = 4;
#define MIRG_CHARGED_2 = 8;
#define MIRG_CHARGED_ANY = MIRG_CHARGED_1 | MIRG_CHARGED_2;

monitor_mirg2000()
{
    if(!isdefined(level.var_5e75629a)) return;
    self endon("disconnect");
    self endon("bled_out");
    self endon("spawned_player");
    for(;;)
	{
		self waittill("grenade_launcher_fire", grenade, weapon);
		if(!is_wonder_weapon(weapon)) continue;
		if(!isdefined(grenade)) continue;
		if(!isdefined(self.chargeshotlevel)) continue;
        grenade thread watch_death_and_explode(self, weapon, self.chargeshotlevel);
	}
}

get_mirg_flags(weapon)
{
    if(!isdefined(weapon)) return MIRG_NONE;
    switch(weapon)
    {
        case level.var_5e75629a:
            return MIRG_IS_MIRG;
        case level.var_a367ea52:
            return MIRG_IS_MIRG | MIRG_CHARGED_1;
        case level.var_7d656fe9:
            return MIRG_IS_MIRG | MIRG_CHARGED_2;
        case level.var_a4052592:
            return MIRG_UPGRADED;
        case level.var_5c210a9a:
            return MIRG_UPGRADED | MIRG_CHARGED_1;
        case level.var_361e9031:
            return MIRG_UPGRADED | MIRG_CHARGED_2;
        default:
            return MIRG_NONE;
    }
}

is_wonder_weapon(weapon, flags = MIRG_ANY)
{
    return get_mirg_flags(weapon) & flags;
}

watch_death_and_explode(player, w_weapon, charge_level = 0)
{
    if(!isdefined(player)) return;
    player endon("disconnect");
    self waittill("death");
    f_shot = (charge_level > 1)? serious::do_mirg_big_shot: serious::do_mirg_small_shot;
    self thread [[ f_shot ]](self.origin, player, w_weapon);
}

do_mirg_small_shot(v_position = (0,0,0), e_attacker, w_weapon)
{
    e_attacker endon("disconnect");
    a_e_players = array::filter(getplayers(), 0, serious::is_valid_bow_enemy);
    arrayremovevalue(a_e_players, e_attacker, true);
	n_range_sq = get_mirg_affector_range_sq();
    sorted_targets = array::get_all_closest(v_position, a_e_players, undefined, undefined, n_range_sq);
	foreach(e_player in sorted_targets)
	{
        if(isdefined(e_player.var_3f6ea790) && e_player.var_3f6ea790) continue;
		if(!within_mirg_z_range(e_player.origin, v_position, n_range_sq)) continue;
        return e_attacker mirg_affect_player(e_player);
	}
}

within_mirg_z_range(v_start, v_end, n_range_sq, n_max_height_diff = 72)
{
	n_height_diff = abs(v_end[2] - v_start[2]);
	return distance2dsquared(v_start, v_end) <= n_range_sq && n_height_diff <= n_max_height_diff;
}

get_mirg_affector_range_sq(big_shot = 0)
{
	return (big_shot && (self.chargeshotlevel > 2))? 22500 : 7225;
}

do_mirg_big_shot(v_position = (0,0,0), e_attacker, w_weapon)
{
    e_attacker endon("disconnect");
    v_pos = getclosestpointonnavmesh(v_position, 80);
    if(!isdefined(v_pos)) return;
    b_upgraded = is_wonder_weapon(w_weapon, MIRG_UPGRADED);
    n_timeout = e_attacker.chargeshotlevel;
    n_timeout *= b_upgraded ? 5 : 3;
    n_range_sq = e_attacker get_mirg_affector_range_sq(true);
	while(n_timeout > 0)
	{
		a_e_players = array::filter(getplayers(), 0, serious::is_valid_bow_enemy);
        arrayremovevalue(a_e_players, e_attacker, true);
        sorted_targets = array::get_all_closest(v_position, a_e_players, undefined, undefined, n_range_sq);
		foreach(e_player in sorted_targets)
        {
            if(isdefined(e_player.var_3f6ea790) && e_player.var_3f6ea790) continue;
            if(!within_mirg_z_range(e_player.origin, v_position, n_range_sq)) continue;
            e_attacker thread mirg_affect_player(e_player);
        }
		wait(0.25);
        n_timeout -= 0.25;
	}
}

mirg_affect_player(e_player)
{
	self endon("disconnect");
	e_player endon("disconnect");
    e_player endon("bled_out");
    e_player.var_3f6ea790 = 1;
    e_player dodamage(MIRG_2000_AOE_TICK_DMG * CLAMPED_ROUND_NUMBER, e_player.origin, self, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
    wait 0.2;
    e_player.var_3f6ea790 = 0;
}
