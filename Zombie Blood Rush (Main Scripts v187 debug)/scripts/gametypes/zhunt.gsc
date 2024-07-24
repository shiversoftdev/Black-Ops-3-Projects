zhunt_init_gametype()
{
    level.zhunt_hunter_team = "axis";
    level.zhunt_egg_team = "allies";
    level.zbrgs_max_respawn_score = MAX_POINTS_OVERRIDE;
    
    level.fn_override_win_condition = function() =>
    {
        // TODO: check the win state here
    };

    // eggers get a guaranteed point spawn state to protect them from falling behind
    level.fn_custom_min_points = function(min_points_base) =>
    {
        if(self zhunt_is_egger())
        {
            return int(7000 + CLAMPED_ROUND_NUMBER * 1000);
        }
        return 500;
    };

    level.fn_zbr_gametype_postdamage_scale = serious::zhunt_adjust_pvp;

    level.fn_zbr_custom_teamsinit = function() => 
    {
        level.gm_id = 1; // axis
    };

    level.fn_zbr_select_team_auto = function() => 
    {
        if(self istestclient())
        {
            self.gm_id = 1;
            return;
        }

        self.gm_id = compiler::getexpectedteam(self getxuid(false));
            
        if(self.gm_id > 0)
        {
            self.gm_id--;
        }

        if(self.gm_id > 1)
        {
            self.gm_id = 1;
        }

        if(self.gm_id < 0)
        {
            self.gm_id = 1;
        }
    };

    level.fn_zbr_custom_objectives = function() => 
    {
        obj = [];

        if(self zhunt_is_egger())
        {
            obj[0] = "Your points are now your health";
            obj[1] = "Kill other players before they kill you.";
            obj[2] = "Complete the main quest before you run out of lives to win.";
        }
        else
        {
            self iPrintLnBold(self getgmteam()); // TODO
            obj[0] = "Your points are now your health";
            obj[1] = "Kill the runners to deplenish their lives.";
            obj[2] = "Prevent the runners from completing the main quest to win.";
        }

        return obj;
    };

    level.fn_gm_createhud_gametype = function() => 
    {
        teammates = self get_zbr_teammates();
        enemies = self get_zbr_enemies();

        y_pos_base = ((self issplitscreen()) ? (BASE_OFFSET - 55) : BASE_OFFSET);
        y_pos_base += teammates.size * -15;

        if(!isdefined(self._bars[self GetEntityNumber()]))
        {
            self._bars[self GetEntityNumber()] = self CreateProgressBarSplit("LEFT", "LEFT", 17, y_pos_base, 50, HUD_BOX_HEIGHT, self GM_GetPlayerColor(), 1);
            self._bars[self GetEntityNumber()].player = self;
            self._bars[self GetEntityNumber()].box = self CreateCheckBox("LEFT", "LEFT", 69, y_pos_base, HUD_BOX_HEIGHT, self GM_GetPlayerColor(true), 1);
        }
        else
        {
            self._bars[self GetEntityNumber()].bg.y = y_pos_base;
            self._bars[self GetEntityNumber()].box.bg.y = y_pos_base;
        }
        
        self UpdateGMProgress(self);

        // start at base offset, our team is always the bottom
        teams = gm_get_all_teams();
        team_offsets = [];
        team_offsets[self getgmteam()] = 0;

        // calc preallocated spaces for other teams
        previous_team = team_offsets[self getgmteam()];
        foreach(team in teams)
        {
            if(team == (self getgmteam())) continue;
            plrs = get_zbr_team_players(team);
            team_offsets[team] = previous_team + (plrs.size * -10) + int(-5);
            previous_team = team_offsets[team];
        }

        team_offsets[self getgmteam()] -= 10;

        foreach(player in level.players)
        {
            if(player == self) continue;
            y_pos = y_pos_base + team_offsets[player getgmteam()];
            if(!isdefined(self._bars[player GetEntityNumber()]))
            {
                self._bars[player GetEntityNumber()] = self CreateProgressBarSplit("LEFT", "LEFT", 17, y_pos, 50, HUD_BOX_HEIGHT, player GM_GetPlayerColor(), 1);
                self._bars[player GetEntityNumber()].player = player;
                self._bars[player GetEntityNumber()].box = self CreateCheckBox("LEFT", "LEFT", 69, y_pos, HUD_BOX_HEIGHT, player GM_GetPlayerColor(true), 1);
            }
            else
            {
                self._bars[player GetEntityNumber()].bg.y = y_pos;
                self._bars[player GetEntityNumber()].box.bg.y = y_pos;
            }
            team_offsets[player getgmteam()] += -10;
            self UpdateGMProgress(player);
        }
    };
}

zhunt_is_egger()
{
    return self getgmteam() == level.zhunt_egg_team;
}

zhunt_is_hunter()
{
    return self getgmteam() == level.zhunt_hunter_team;
}

zhunt_hunter_count()
{
    count = 0;
    foreach(player in getplayers())
    {
        if(player zhunt_is_hunter())
        {
            count++;
        }
    }
    return count;
}

zhunt_egger_count()
{
    count = 0;
    foreach(player in getplayers())
    {
        if(player zhunt_is_egger())
        {
            count++;
        }
    }
    return count;
}

zhunt_egger_team_differential()
{
    diff = zhunt_hunter_count() - (zhunt_egger_count() - 1);
    return int(max(1, min(diff, 7)));
}

zhunt_adjust_pvp(eInflictor, attacker, result, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime)
{
    if(self zhunt_is_egger())
    {
        count = zhunt_egger_team_differential();
        if(count >= 1)
        {
            result /= count;
        }
        result *= ZHUNT_EGGER_RESISTANCE;
        return int(result);
    }
    return result;
}