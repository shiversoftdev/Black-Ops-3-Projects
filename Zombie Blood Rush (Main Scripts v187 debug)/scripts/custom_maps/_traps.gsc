#define ACID_TRAP_DPS_UNSHIELDED = 75000; // 75,000 damage per second to unshielded players, meaning you can get through it if you can pass through in < 1s
#define ACID_TRAP_TICKRATE = 0.25;
zm_alcatraz_island_acid_trap_damage()
{
    self endon("acid_trap_finished");
	while(true)
	{
		wait ACID_TRAP_TICKRATE;
		foreach(ent in getplayers())
        {
            if(ent istouching(self) && ent.sessionstate == "playing")
            {
                if(ent hasperk("specialty_armorvest"))
                {
                    ent dodamage(50, ent.origin, self, self, "none", "MOD_UNKNOWN", 0, level.weaponnone);
                }
                else
                {
                    ent dodamage(int(ACID_TRAP_DPS_UNSHIELDED * ACID_TRAP_TICKRATE), ent.origin, self, self, "none", "MOD_UNKNOWN", 0, level.weaponnone);
                }
            }
        }

        foreach(zombie in getaiteamarray(level.zombie_team))
        {
            if(isalive(zombie) && zombie istouching(self))
            {
                zombie dodamage(int(ACID_TRAP_DPS_UNSHIELDED * ACID_TRAP_TICKRATE), zombie.origin, self, self, "none", "MOD_UNKNOWN", 0, level.weaponnone);
            }
        }
	}
}