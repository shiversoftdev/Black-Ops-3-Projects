monitor_thundergun_pvp()
{
    if(!isdefined(level.weaponzmthundergun)) return;
    self endon("disconnect");
    self notify("monitor_thundergun_pvp");
    self endon("monitor_thundergun_pvp");

    if(IS_DEBUG && DEBUG_THUNDERGUN && self ishost())
    {
        wait SPAWN_DELAY;
        self takeAllWeapons();
        self giveWeapon(GetWeapon("thundergun"));
        self switchToWeapon(GetWeapon("thundergun"));
        self giveMaxAmmo(GetWeapon("thundergun"));
    }

	for(;;)
	{
		self waittill("weapon_fired");
		currentWeapon = self GetCurrentWeapon();
		if(currentWeapon == GetWeapon("thundergun") || currentWeapon == GetWeapon("thundergun_upgraded"))
		{
			self thread thundergun_fired(currentWeapon);
		}
	}
}

thundergun_fired(weapon)
{
	players = self thundergun_get_enemies_in_range();
	foreach(player in players)
    {
        player thread ThundergunKnockback(self, weapon);
    }
}

thundergun_get_enemies_in_range()
{
	view_pos = self GetWeaponMuzzlePoint();
	zombies = Array::get_all_closest(view_pos, getplayers(), undefined, undefined, level.zombie_vars["thundergun_knockdown_range"]);
	if(!isdefined(zombies))
	{
		return [];
	}

    to_knock = [];

	knockdown_range_squared = level.zombie_vars["thundergun_knockdown_range"] * level.zombie_vars["thundergun_knockdown_range"];
	gib_range_squared = level.zombie_vars["thundergun_gib_range"] * level.zombie_vars["thundergun_gib_range"];
	fling_range_squared = level.zombie_vars["thundergun_fling_range"] * level.zombie_vars["thundergun_fling_range"];
	cylinder_radius_squared = (level.zombie_vars["thundergun_cylinder_radius"] * 0.5) * (level.zombie_vars["thundergun_cylinder_radius"] * 0.5);
	forward_view_angles = self GetWeaponForwardDir();
	end_pos = view_pos + VectorScale(forward_view_angles, level.zombie_vars["thundergun_knockdown_range"]);
	for(i = 0; i < zombies.size; i++)
	{
		if(!isdefined(zombies[i]) || !isalive(zombies[i]) || zombies[i] == self || zombies[i].sessionstate != "playing")
		{
			continue;
		}
        if(zombies[i].team == self.team)
        {
            continue;
        }
		test_origin = zombies[i] GetCentroid();
		test_range_squared = DistanceSquared(view_pos, test_origin);
		if(test_range_squared > knockdown_range_squared)
		{
			return to_knock;
		}
		normal = VectorNormalize(test_origin - view_pos);
		dot = VectorDot(forward_view_angles, normal);
		if(0 > dot)
		{
			continue;
		}
		radial_origin = PointOnSegmentNearestToPoint(view_pos, end_pos, test_origin);
		if(DistanceSquared(test_origin, radial_origin) > cylinder_radius_squared)
		{
			continue;
		}
		if(0 == (zombies[i] damageConeTrace(view_pos, self)))
		{
			continue;
		}
		to_knock[to_knock.size] = zombies[i];
	}

    return to_knock;
}

ThundergunKnockback(attacker, weapon, damage_override = -1)
{
    alpha = min(1, distance(attacker.origin, self.origin) / level.zombie_vars["thundergun_knockdown_range"]);
    d = min(1.0, (1.0 - alpha) + THUNDERGUN_FORGIVENESS_PCT);
    velocity = LerpFloat(TGUN_LAUNCH_MIN_VELOCITY, TGUN_LAUNCH_MAX_VELOCITY, d);
    angles = VectorNormalize(anglesToForward(attacker getPlayerAngles()));
    
    final_velocity = angles * velocity;
    final_velocity_clamped = (final_velocity[0], final_velocity[1], max(min(final_velocity[2], 400), -400));

    self setOrigin(self getOrigin() + (0,0,10));
    self setVelocity(final_velocity_clamped);
    self.launch_magnitude_extra = 200;
    self.v_launch_direction_extra = vectorNormalize(final_velocity_clamped);
    self.gm_thundergunned = true;
    self dodamage(int(TG_Clamp(d * d * ((damage_override == -1) ? TGUN_BASE_DMG_PER_ROUND : damage_override) * CLAMPED_ROUND_NUMBER, self)), self.origin, attacker, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
    self.gm_thundergunned = false;
    if(damage_override == -1)
    {
        self thread TG_ImpactDamage(attacker);
    }
}

TG_Clamp(damage, victim)
{
    if(damage >= TGUN_MAX_DAMAGE)
    {
        damage = TGUN_MAX_DAMAGE;
    }
    
    if(!isdefined(victim) || !isdefined(victim.health))
    {
        return 0;
    }

    if(damage < victim.health)
    {
        return damage;
    }

    return int(victim.health - 1);
}

TG_ImpactDamage(attacker)
{
    self endon("bled_out");
    self endon("death");
    self notify("TG_ImpactDamage");
    self endon("TG_ImpactDamage");
    self endon("disconnect");
    level endon("end_game");

    self.tgun_lifted = true;
    wait .025;
    waittillframeend;
    sv = self getVelocity();
    svd = Distance2D((0,0,0), sv);

    for(;;)
    {
        wait 0.1;
        nv = self getVelocity();
        nvd = Distance2D((0,0,0), nv);

        if(nvd <= 100 && self isOnGround())
        {
            self.tgun_lifted = false;
            return;
        }
            
        if(nvd < svd)
        {
            dval = abs(nvd - svd);

            if(self.origin[2] <= -20000)
                self doDamage(self.maxhealth + 1, self.origin, attacker);

            if(dval >= 200)
            {
                self doDamage(int(min(5000, dval / 100 * TGUN_IMPACT_DMG_PER_HUNDRED_U_S)), self.origin, attacker, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
            }
        }
        
        sv = nv;
        svd = nvd;
    }
}