quantum_bomb_init()
{
    if(isdefined(level.quantum_bomb_deregister_result_func))
    {
        [[ level.quantum_bomb_deregister_result_func ]]("pack_or_unpack_current_weapon");
        [[ level.quantum_bomb_deregister_result_func ]]("auto_revive");
        [[ level.quantum_bomb_deregister_result_func ]]("zombie_fling");
    }
    if(isdefined(level.quantum_bomb_register_result_func))
    {
        [[ level.quantum_bomb_register_result_func ]]("player_resurrect", function(position) => 
        {
            playfx(level._effect["quantum_bomb_mystery_effect"], position);

            foreach(player in getplayers())
            {
                if(player.sessionstate != "playing")
                {
                    player [[ level.spawnplayer ]]();
                }
            }

        }, 60, function(position) => 
        {
            foreach(player in getplayers())
            {
                if(player.sessionstate != "playing")
                {
                    return true;
                }
            }
            return false;
        });

        [[ level.quantum_bomb_register_result_func ]]("random_gum", function(position) => 
        {
            playfx(level._effect["quantum_bomb_mystery_effect"], position);

            foreach(player in getplayers())
            {
                if(player.sessionstate != "playing")
                {
                    continue;
                }
                if(distance(player.origin, position) <= 300)
                {
                    return true;
                }
                keys = getArrayKeys(level.bgb);
                bgb = keys[randomint(keys.size)];
                player bgb::give(bgb);
            }

        }, 10, function(position) => 
        {
            foreach(player in getplayers())
            {
                if(player.sessionstate != "playing")
                {
                    continue;
                }
                if(distance(player.origin, position) <= 300)
                {
                    return true;
                }
            }
            return false;
        });

        [[ level.quantum_bomb_register_result_func ]]("zombie_fling", function(position) => 
        {
            playfx(level._effect["zombie_fling_result"], position);
            range = 300;
            range_squared = range * range;
            zombies = util::get_array_of_closest(position, zombie_utility::get_round_enemy_array());
            players = getplayers();
            for(i = 0; i < zombies.size; i++)
            {
                zombie = zombies[i];
                if(!isdefined(zombie) || !isalive(zombie))
                {
                    continue;
                }
                test_origin = zombie.origin + vectorscale((0, 0, 1), 40);
                test_origin_squared = distancesquared(position, test_origin);
                if(test_origin_squared > range_squared)
                {
                    break;
                }
                dist_mult = (range_squared - test_origin_squared) / range_squared;
                fling_vec = vectornormalize(test_origin - position);
                fling_vec = (fling_vec[0], fling_vec[1], abs(fling_vec[2]));
                fling_vec = vectorscale(fling_vec, 100 + (100 * dist_mult));
                zombie quantum_bomb_fling_zombie(self, fling_vec);
                if(i && !i % 10)
                {
                    util::wait_network_frame();
                    util::wait_network_frame();
                    util::wait_network_frame();
                }
            }

            foreach(player in getplayers())
            {
                if(player.sessionstate != "playing" || distance(player.origin, position) > 300)
                {
                    continue;
                }
                player.launch_magnitude_extra = vectorscale(vectorNormalize((player.origin - position) + (0, 0, 100)), 300);
            }

            radiusdamage(position + (0, 0, 5), range, int(CLAMPED_ROUND_NUMBER * 500 / get_round_damage_boost()), int(CLAMPED_ROUND_NUMBER * 500 / get_round_damage_boost() * 0.75), self, "MOD_EXPLOSIVE", level.weaponnone);
        });

        [[ level.quantum_bomb_register_result_func ]]("drop_gun", function(position) => 
        {
            playfx(level._effect["quantum_bomb_mystery_effect"], position);

            foreach(player in getplayers())
            {
                if(player.sessionstate != "playing")
                {
                    continue;
                }
                if(distance(player.origin, position) <= 300)
                {
                    return true;
                }
                player dropitem(player GetCurrentWeapon());
            }

        }, 10, function(position) => 
        {
            foreach(player in getplayers())
            {
                if(player.sessionstate != "playing")
                {
                    continue;
                }
                if(distance(player.origin, position) <= 300)
                {
                    return true;
                }
            }
            return false;
        });
    }
}


quantum_bomb_fling_zombie(player, fling_vec)
{
	if(!isdefined(self) || !isalive(self))
	{
		return;
	}
	self dodamage(self.health + 666, player.origin, player, player, 0, "MOD_UNKNOWN", 0, level.w_quantum_bomb);
	if(self.health <= 0)
	{
		self startragdoll();
		self launchragdoll(fling_vec);
	}
}