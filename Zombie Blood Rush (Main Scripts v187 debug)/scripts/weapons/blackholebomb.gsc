bhb_hook()
{
    self endon("death");
    if((level.script != "zm_moon") && isdefined(level.__black_hole_bomb_poi_override))
    {
        self [[level.__black_hole_bomb_poi_override]]();
    }
    if(!isdefined(self._black_hole_bomb_player) || !isdefined(self._black_hole_bomb_player.sessionstate) || self._black_hole_bomb_player.sessionstate != "playing") return;
    owner = self._black_hole_bomb_player;
    if(!isdefined(owner))
    {
        return;
    }
    owner endon("disconnect");
    owner endon("bled_out");
    owner thread start_timed_pvp_vortex(self.origin, 2056, 10, undefined, undefined, owner, level.var_453e74a0, 0, undefined, 0, 0, 0);
}