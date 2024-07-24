/////////////
// Credits //
/////////////
// Serious - Creator. https://www.youtube.com/anthonything
// NOTE: If you use any of these functions in your project, please credit me. Thanks!
// Extinct: Misc code snippets, testing.
// ItsFebiven: Misc code snippets, testing.
// nice_sprite: Misc UI help, Gum UI on customs, gameplay testing.
// SyGnUs: Gameplay testing, chatting.
// Candy, Snowy, Daltax, Leaf, ssno, AMS, Kai, Orbis, Taleb, Raspperz: Gameplay testing
// D3V Team LeakMod
// Mod Tools Discord Members: ollie, mikey, kyle, jarik, scob, harry, approved, jbird, Ian -- Various help in porting to modtools
// gunji: killcam GSC snippets
// My youtube subs, and anyone else I forgot about at this current point in time.

/////////////////////////////////
// Tuneable Gameplay Variables //
/////////////////////////////////
#region Tunables

// note: may eventually want to abstract this. otherwise map devs can mess with stuff
// scrvm_readonly -- a =>> b; makes a variable readonly and cannot be modified after this point
// implement gscu features?
autoexec(0) ___apply_gamesettings()
{
    if(DEBUG_DEVELOPER)
    {
        setdvar("developer", 1);
    }
    level.zbrgs_pvp_damage_scalar = compiler::getgamesetting(#pvp_damage_scalar);
    level.zbrgs_no_wager_totems = compiler::getgamesetting(#no_wager_totems);
    level.zbrgs_force_host = compiler::getgamesetting(#force_host);
    level.zbrgs_spawn_delay = compiler::getgamesetting(#spawn_delay);
    level.zbrgs_zombie_maxlifetime = compiler::getgamesetting(#zombie_maxlifetime);
    level.zbrgs_win_numpoints = compiler::getgamesetting(#win_numpoints);
    level.zbrgs_outgoing_pve_damage = compiler::getgamesetting(#outgoing_pve_damage);
    level.zbrgs_incoming_pve_damage = compiler::getgamesetting(#incoming_pve_damage);
    level.zbrgs_super_sprinters_enabled = compiler::getgamesetting(#super_sprinters_enabled);
    level.zbrgs_dmg_convt_efficiency = compiler::getgamesetting(#dmg_convt_efficiency);
    level.zbrgs_objective_win_time = compiler::getgamesetting(#objective_win_time);
    level.zbrgs_gm_start_round = compiler::getgamesetting(#gm_start_round);
    level.zbrgs_player_midround_respawn_delay = compiler::getgamesetting(#player_midround_respawn_delay);
    level.zbrgs_starting_points_cm = compiler::getgamesetting(#starting_points_cm);
    level.zbrgs_disable_gums_cm = compiler::getgamesetting(#disable_gums_cm);
    level.zbrgs_spawn_reduce_points = compiler::getgamesetting(#spawn_reduce_points);
    level.zbrgs_max_points_override = compiler::getgamesetting(#max_points_override);
    level.zbrgs_ZHUNT_EGGER_RESISTANCE = compiler::getgamesetting(#zhunt_egger_resistance);
    level.zbrgs_headshots_only = compiler::getgamesetting(#headshots_only);
    
    level.zbrgs_max_respawn_score = int(WIN_NUMPOINTS * 0.8);

    level.zbrgs_sudden_death_mode = compiler::getgamesetting(#sudden_death_mode);
    level.zbrgs_sudden_death_rounds = compiler::getgamesetting(#sudden_death_rounds);
    level.zbrgs_sudden_death_time = compiler::getgamesetting(#sudden_death_time);
}

// When set to true, enables team based ZBR
// default value: false
#define ZBR_TEAMS = GetDvarInt("zbr_teams_enabled") ?? false;

// Adjusts the size of teams when ZBR_TEAMS is enabled. Must be between 2 and 4.
// default value: 2
#define ZBR_TEAMSIZE = GetDvarInt("zbr_teams_size") ?? 2;

// Determines whether to use the old hud or the new hud
// default value: true
#define USE_NEW_HUD = false;

// Maximum number of points a player can respawn with
// default value: 80% of max score
#define MAX_RESPAWN_SCORE = level.zbrgs_max_respawn_score;

#define PVP_DAMAGE_SCALAR = level.zbrgs_pvp_damage_scalar;
#define NO_WAGER_TOTEMS = level.zbrgs_no_wager_totems;
#define FORCE_HOST = level.zbrgs_force_host;
#define SPAWN_DELAY = 2;
#define ZOMBIE_MAXLIFETIME = level.zbrgs_zombie_maxlifetime;
#define WIN_NUMPOINTS = level.zbrgs_win_numpoints;
#define OUTGOING_PVE_DAMAGE = level.zbrgs_outgoing_pve_damage;
#define INCOMING_PVE_DAMAGE = level.zbrgs_incoming_pve_damage;
#define SUPER_SPRINTERS_ENABLED = level.zbrgs_super_sprinters_enabled;
#define DMG_CONVT_EFFICIENCY = level.zbrgs_dmg_convt_efficiency;
#define OBJECTIVE_WIN_TIME = level.zbrgs_objective_win_time;
#define GM_START_ROUND = level.zbrgs_gm_start_round;
#define CLAMPED_ROUND_NUMBER = int(min(25, level.round_number));
#define PLAYER_MIDROUND_RESPAWN_DELAY = level.zbrgs_player_midround_respawn_delay;
#define STARTING_POINTS_CM = level.zbrgs_starting_points_cm;
#define DISABLE_GUMS_CM = level.zbrgs_disable_gums_cm;
#define SPAWN_REDUCE_POINTS = level.zbrgs_spawn_reduce_points;
#define MAX_POINTS_OVERRIDE = level.zbrgs_max_points_override;
#define ZHUNT_EGGER_RESISTANCE = level.zbrgs_ZHUNT_EGGER_RESISTANCE;
#define HEADSHOTS_ONLY = level.zbrgs_headshots_only;
#define PVP_HEADSHOTS_ONLY = (HEADSHOTS_ONLY & 1);
#define PVE_HEADSHOTS_ONLY = (HEADSHOTS_ONLY & 2);

// When true, disables the turned AAT
// default value: true
#define DISABLE_TURNED = false;

// When set to true, zm_island will not load. This is due to incompatibility issues and will be fixed in the future
// default value: false
#define DISABLE_ISLAND = false;

// Base value to start zm damage at, only if the zombie damage is defaulted.
// default value: 45
#define ZOMBIE_BASE_DMG = 45;

// Capactity for the player hit buffer, which prevents exponential damage from kicking in and regenerates over time.
// default value: 90
#define HIT_BUFFER_CAPACITY = 90;

// Maximum damage a zombie can do to a player
// default value: 5000
#define MAX_HIT_VALUE = 5000;

// Exponent used to adjust zombie death award values, raised to the power of the round number, times the round number
// default value: 1.1
#define EXPONENT_SCOREINC = 1.1;

// Round number times this number, times the zombie melee damage (ZOMBIE_BASE_DMG) will be the final damage
// default value: 4
#define EXPONENT_DMGINC = 4;

// Exponent used to calculate the spawn delay for a zombie, used as input to the original 3arc algorithm
// default value: 0.85
#define EXPONENT_SPAWN_DELAY_MULT = 0.85;

// Speed at which zombie move speed increases per round
// default value: 5
#define GM_ZM_SPEED_MULT = 5;

// Defines the round at which between round time approaches 0
// default value: 15
#define GM_ROUND_DELAY_FULL_RND = 15;

// Time in seconds, that the game should wait between rounds, when the round delay is at its longest.
// default value: 5
#define GM_BETWEEN_ROUND_DELAY_START = 8;

// Global scalar for zombie damage on origins
// default value: 0.8
#define ORIGINS_ZOMBIE_DAMAGE = 0.8;

// Exponent used to calculate the price of objects, raised to the power of the round.
// default value: 1.08
#define EXPONENT_PURCHASE_COST_INC = 1.08;

// The amount of hero weapon energy to give the player per kill
// default value: 25
#define GADGET_PWR_PER_KILL = 25;

// Damage multiplier used against the round number to scale PvP damage. This is also known as standard boost. Does not apply to all weapons.
// default value: 0.1
#define WEP_DMG_BOOST_PER_ROUND = 0.1;

// Defines the maximum melee damage a player can do in one hit, excluding pop shocks and sword flay.
// default value: 20000
#define MAX_MELEE_DAMAGE = 20000;

// number of rounds between point changes (helps with saving hintstring space)
// default value: 5
#define ROUND_DELTA_SCALAR = 5;

// Multiplier to use against level.round_number when giving trailing players points
// default value: 1250
#define MIN_ROUND_PTS_MULT = 1250;

// Lowest round to start giving minimum points to trailing players
// default value: 5
#define MIN_ROUND_PTR_BEGIN = 5;

// Time in seconds for which the objective text will remain visible
// default value: 15
#define OBJECTIVE_SHOW_TIME = 15;

// Time in seconds for which the objective text will remain decoding
// default value: 2
#define OBJECTIVE_DECODE_TIME = 2;

// Time between player dying and respawning when a player has objective state set
// default value: 20
#define PLAYER_RESPAWN_DELAY = int(PLAYER_MIDROUND_RESPAWN_DELAY * 0.5);

// Thundergun velocity at minimum
// default value: 500
#define TGUN_LAUNCH_MIN_VELOCITY = 500;

// Thundergun velocity at maximum
// default value: 2500
#define TGUN_LAUNCH_MAX_VELOCITY = 2500;

// Thundergun damage at closest point
// default value: 850
#define TGUN_BASE_DMG_PER_ROUND = 850;

// Thundergun max damage. Will never exceed this value.
// default value: 15000
#define TGUN_MAX_DAMAGE = 15000;

// Damage from thundergun when the player impacts a surface at a high velocity, per hundred units per second (velocity)
// default value: 100
#define TGUN_IMPACT_DMG_PER_HUNDRED_U_S = 100;

// Damage done by the explosion of the idgun to other players
// default value: 300
#define IDGUN_PVP_EXPLODE_DMG_PER_ROUND = 300;

// Damage done by the idgun per frame to other players inside the vortex
// default value: 90
#define IDGUN_DMG_PER_FRAME = 90;

// Multiplier for idgun damage
// default value: 0.1
#define IDGUN_DMG_BOOST_PER_ROUND = 0.1;

// Pull velocity done by the idgun per frame to other players at the center of the vortex
// default value: 30
#define IDGUN_PULL_VELOCITY_PER_FRAME = 30;

// Damage scalar applied to the upgraded idgun
// default value: 1.5
#define IDGUN_SCALAR_UPGRADED = 1.5;

// The amount of shock damage to do to a player when they are affected by the SOE ground slam (or grav spikes on zm_castle) from the blue sword, multiplied by the round number
// default value: 1750
#define ZM_ZOD_SWORD_SHOCK_DMG = 1750;

// The amount of seeker damage to do to a player when they are attacked by the seeker glaive, multiplied by the round number
// default value: 1400
#define GLAIVE_SEEKER_DAMAGE = 1400;

// The distance players get thrown when affected by major damage from the grav spikes
// default value: 1000
#define ZM_CASTLE_THROWBACK_MAJOR = 500;

// The distance players get thrown when affected by minor damage from the grav spikes
// default value: 300
#define ZM_CASTLE_THROWBACK_MINOR = 100;

// Damage inflicted per second by the placed spikes trap
// default value: 10000
#define ZM_SPIKES_DPS = 20000;

// Time to wait between ticks of the placed trap
// default value: 0.1
#define ZM_SPIKES_TICKDELAY = 0.1;

// Defines the slam damage for grav spikes, scaled by round number
// default value: 750
#define ZM_SPIKES_SLAM_DMG = 750;

// Damage that the dragonshield projectile does, multiplied by the round number.
// default value: 350
#define ZM_DRAGSHIELD_DMG = 350;

// Damage scaled by round number done to players, linear mapped by cherry power
// default value: 500
#define PVP_ELECTRIC_CHERRY_DMG = 500;

// Damage that the wavegun alt fire does, scaled by the round number
// default value: 800
#define MOON_WAVEGUN_ALTFIRE_DMG = 800;

// Radius to start doing damage to players with bhb
// default value: 250
#define BLACKHOLEBOMB_MIN_DMG_RADIUS = 250;

// AAT deadwire damage scaled by the round number
// default value: 350
#define AAT_DEADWIRE_PVP_DAMAGE = 350;

// AAT blast furnace damage scaled by the round (in total)
// default value: 1500
#define AAT_BLASTFURNACE_PVP_DAMAGE = 1500;

// AAT thunderwall damage scaled by the round
// default value: 500
#define AAT_THUNDERWALL_PVP_DAMAGE = 500;

// AAT fireworks damage scaled by the round
// default value: 300
#define AAT_FIREWORKS_PVP_DAMAGE = 300;

// AAT turned blast damage scaled by the round number
// default value: 200
#define AAT_TURNED_PVP_DAMAGE = 200;

// pop shocks pvp damage scaled by the round
// default value: 3000
#define BGB_POPSHOCKS_PVP_DAMAGE = 3000;

// maximum activations for the burned out gobblegum
// default value: 5
#define BGB_BURNEDOUT_MAX = 5;

// damage done over time by the burned out gobblegum to players, scaled by the round number
// default value: 1500
#define BGB_BURNEDOUT_PVP_DAMAGE = 1500;

// One inch punch velocity at minimum
// default value: 500
#define OIP_LAUNCH_MIN_VELOCITY = 500;

// One inch punch velocity at maximum
// default value: 5000
#define OIP_LAUNCH_MAX_VELOCITY = 5000;

// Applied globally across all melee types that are not explicitly overriden
// default value: 3
#define MELEE_DMG_SCALAR = 3;

// Defines the duration, in seconds, of the fire staff burn duration
// default value: 8
#define STAFF_FIRE_DMG_DURATION = 8;

// Defines the percent reduction for zombie damage when a round resets, and inversely, the percent to increase zombie damage when the global scalar is not 100%. This is also the damage increase players receive against zombies when a round resets, etc.
// default value: 0.25
#define GM_ZDMG_RUBBERBAND_PERCENT = 0.25;

// Defines the percent value that the damage for the annihilator is increased, per round.
// default value: 0.08
#define ANNIHILATOR_DMG_PERCENT_PER_ROUND = 0.08;

// Defines the multiplier that double points will apply to pvp related points
// default value: 1.35
#define DOUBLEPOINTS_PVP_SCALAR = 1.35;

// Defines the damage multiplier for pvp when instakill is active
// default value: 1.25
#define INSTAKILL_DMG_PVP_MULTIPLIER = 1.25;

// Defines the damage scalar for the lightning staff damage per tick
// default value: 1.0f
#define STAFF_LIGHTNING_DMG_SCALAR = 1.0f;

// Defines the water staff's damage per second, scaled by round. Upgraded staff does 1.35x
// default value: 300
#define STAFF_WATER_DPS = 50;

// Defines the radius that the air staff tornado will succ players.
// default value: 225
#define STAFF_AIR_SUCC_RADIUS = 225;

// Pull velocity done by the air staff per frame to other players at the center of the vortex
// default value: 70
#define STAFF_AIR_PULL_VELOCITY_PER_FRAME = 70;

// Damage done by the air staff per tick (.1s) to other players inside the vortex
// default value: 50
#define STAFF_AIR_DMG_PER_TICK = 20;

// Damage percent added to the air staff damage per round
// default value: 0.05
#define STAFF_AIR_DMG_BONUS_PER_ROUND = 0.05;

// Defines the damage done to nearby players when a fire rune breaks, scaled by the round number
// default value: 200
#define BOW_FIRE_ROCK_BREAK_DMG = 200;

// Defines the damage done to the player trapped by a fire rune, scaled by the round number, done in ticks of 0.1s, for 3.8 seconds
// default value: 15
#define BOW_FIRE_DMG_PER_TICK = 15;

// Defines the damage done to the player who walks over a fire rune geyser, scaled by the round number, in total.
// default value: 1000
#define BOW_GEYSER_FIRE_TOTAL = 1000;

// Defines the damage done to players within radius of a storm bow shot, scaled by the round
// default value: 200
#define BOW_STORM_SHOCK_DAMAGE = 200;

// Defines the damage done per round as push damage when hit by the wolf bow push
// default value: 100
#define BOW_WOLF_PUSH_DAMAGE = 100;

// Defines the percent of health taken from all enemy players when a nuke is grabbed
// default value: 0.08
#define NUKE_HEALTH_PERCENT = 0.08;

// Damage multiplier for when a player is frozen by a bgb, multiplied by final damage result.
// default value: 0.08
#define BGB_FROZEN_DAMAGE_REDUX = 0.08;

// Percent of health to do as damage to anyone marked during killing time
// default value: 0.35
#define BGB_KILLINGTIME_MARKED_PCT = 0.35;

// Time in ms that a player will receive credit for damage inflicted by a fall after attacking their victim.
// default value: 7500
#define MOD_FALL_GRACE_PERIOD = 7500;

// Total damage a single skull from the bow can do, scaled by the round number.
// default value: 75
#define BOW_DEMONGATE_SKULL_TOTALDAMAGE = 75;

// Number of skulls to spawn for pvp damage per shot
// default value: 4
#define BOW_DEMONGATE_SKULL_COUNT = 4;

// Scalar for explosive knockback
// default value: 200
#define EXPLOSIVE_KNOCKBACK_SCALAR = 200;

// Damage done per 0.25s tick for the skull, scaled by the round number
// default value: 250
#define SKULL_DMG_PER_TICK = 250;

// Score awarded to a player who mesmerizes another player, given every 0.25s
// default value: 100
#define SKULL_MESMERIZE_SCORE_PER_TICK = 100;

// Reduction to damage done by juggernaut perk. Cannot be greater than 1, nor less than 0.
// default value: 0.2
#define PERK_JUGGERNAUT_REDUCTION = 0.2;

// default damage a trap does, per hit
// default value: 10000
#define TRAP_DEFAULT_DAMAGE = 10000;

// default damage done to a player with jugg per hit, scaled by round number
// default value: 250
#define TRAP_FIRE_ROUND_DAMAGE = 250;

// default damage a trap does, per hit
// default value: 75000
#define TRAP_FIRE_DEFAULT_DAMAGE = 75000;

// Defines the minimum door price to get the automatic door price reduction
// default value: 500
#define DOOR_REDUCE_MIN_PRICE = 500;

// Defines the minimum door price to get a second reduction to price. A door may only get up to two reductions in price.
// default value: 2500
#define DOOR_REDUCE_TWICE_MIN_PRICE = 2500;

// Defines the amount to reduce a door's price by if it meets the minimum price requirements
// default value: 250
#define DOOR_REDUCE_AMOUNT = 250;

// Time scalar to auto-bleedout. (Duration of the deathcam)
// default value: 0.07
#define N_BLEEDOUT_BASE = 0.07;

// Time in seconds that a player is slowed by widows wine effects when not cocooned
// default value: 5
#define WIDOWS_WINE_SLOW_TIME = 5;

// Time in seconds that a player is slowed by widows wine effects when cocooned
// default value: 7
#define WIDOWS_WINE_COCOON_TIME = 7;

// Velocity applied to players when wind staff hits them
// default value: 7000
#define WIND_STAFF_LAUNCH_VELOCITY = 7000;

// Mirg2000 damage per tick of AOE (.25s), scaled by round number
// default value: 125
#define MIRG_2000_AOE_TICK_DMG = 125;

// Time in seconds that a player shrinks for when attacked by shrink ray.
// default value: 4
#define SHRINK_RAY_SHRINK_TIME = 4;

// Multiplier for damage done by a player who has been affected by shrink ray. Does not apply to explosives.
// default value: 5
#define SHRINK_RAY_DAMAGE_MULT = 5;

// The round when wager modifiers may no longer be obtained.
// default value: 5
#define WAGER_COMMIT_ROUND = 5;

// Number of seconds that the round may have fewer than 5 AI active before all ai will die and the round will advance.
// default value: 60
#define ROUND_NO_AI_TIMEOUT = 60;

// Damage per second of the genesis turret, scaled by the round number
// default value: 5000
#define GENESIS_TURRET_DPS = 5000;

// Defines the root damage percent taken from lightning staff damage
// default value: 0.0
#define STAFF_LIGHTNING_NERF_PCT_MIN = 0.0;

// Defines the max damage percent taken from lightning staff damage, after rapid shots.
// default value: 0.30
#define STAFF_LIGHTNING_NERF_PCT_MAX = 0.20;

// Defines the number of lightning staff shots to achieve max nerf percent
// default value: 3
#define STAFF_LIGHTNING_NERF_NUMSHOTS = 6;

// Defines the number of seconds to wait before restoring lightning staff damage. Only resets when a player is not firing.
// default value: 1.0
#define STAFF_LIGHTNING_NERF_REGEN_DELAY = 1.0;

// Defines the movement speed boost given to players in a losing state against an objective holder
// default value: 1.15
#define GM_MOVESPEED_BOOSTER_MP = 1.15;

// Time, in seconds, that fear in the headlights is active
// default value: 20
#define BGB_FITH_ACTIVE_TIME = 20;

// If true, will enable early spawns for players who are defeated during a round
// default value: false
#define USE_MIDROUND_SPAWNS = true;

// Defines the percent of range forgiveness given to a thundergun shot when calculating its expected damage
// default value: 0.05
#define THUNDERGUN_FORGIVENESS_PCT = 0.05;

// Time in seconds that a player will be forced to prone when bgb crawlspace is used.
// default value: 3
#define BGB_CRAWL_SPACE_TIME = 3;

// Percent to reduce spawn points by when a player dies with phoenix up
// default value: 0.35
#define BGB_PHOENIX_SPAWN_REDUCE_POINTS = 0.35;

// Amount of points to give per activation of extra credit
// default value: 2500
#define BGB_EXTRA_CREDIT_VALUE = 2500;

// Percent to reduce spawn points by when a player goes down with coagulant
// default value: 0.5
#define BGB_COAGULANT_SPAWN_REDUCE_POINTS = 0.5;

// Scalar to apply for damage done to zombies when a player has the arms grace effect active
// default value: 5.0
#define BGB_ARMS_GRACE_ZM_DMG = 5.0;

// Time in seconds that the arms grace effect will be active after respawning
// default value: 60
#define BGB_ARMS_GRACE_DURATION = 60;

// Scalar to apply for damage done to players when a player has the arms grace effect active
// default value: 1.35
#define BGB_ARMS_GRACE_PVP_DMG = 1.10;

// Defines the amount of points, scaled by the round number, to award players who purchase a perk with unquenchable
// default value: 600
#define BGB_UNQUENCHABLE_CASHBACK_RD = 600;

// Defines the speed scale players will move at when undead man walking is active
// default value: 0.5
#define BGB_UMW_SPEED_SCALE = 0.5;

// Defines the amount of damage reduction applied to the fire staff
// default value: 0.35
#define FIRE_STAFF_DMG_REDUCTION = 0.35;

// Time in seconds to remove from a player's objective progress when using a teleporter
// default value: 25
#define GM_TELEPORT_STRAT_PENALTY = 25;

// Number of tac grenades to remove after awarding the weapon on respawn
// default value: 1
#define TAC_GRENADE_REDUCTION = 1;

// percent chance that a zombie drops a live grenade when the wager is active
// default value: 5
#define WAGER_DROPNADE_CHANCE = 5;

// percent body shot damage reduction (and 1/2 of the headshot increase). Should be between 0 and 1.
// default value: 0.95
#define WAGER_HEADSHOT_DMG_PCT = 0.95;

// From which distance this modifier is strongest
// default value: 50;
#define WAGER_PROXIMITY_START_DIST = 50;

// From which distance this modifier is weakest
// default value: 300;
#define WAGER_PROXIMITY_END_DIST = 300;

// Multiplier on damage done to you in close proximity when proximity is wagered
// default value: 2.0
#define WAGER_PROXIMITY_BOOST = 2.0;

// percent of the enemy player's points to leech per second when in proximity to them
// default value: 0.025
#define WAGER_GM4_DOT_PCT = 0.025;

// percent chance to award bonus points to enemy players who attack you
// default value: 10
#define WAGER_BONUSMP_CHANCE = 10;

// percent increase to player points for wager
// default value: 0.05
#define WAGER_BONUSMP_PCT = 0.05;

// maximum number of points a player will hold for a blood hunter drop
// default value: 80000
#define WAGER_MAX_BH_POINTS = 80000;

// percent increase of movement speed per blood hunter stack
// default value: 0.035;
#define WAGER_BH_MOVESPEED_STACK = 0.015;

// percent increase of damage per blood hunter stack (additive)
// default value: 0.075
#define WAGER_GB_DMG_STACK = 0.075;

// damage per round for friendly keeper against players using up attack
// default value: 1500
#define DMG_KEEPER_ATK_UP = 1500;

// damage per round for friendly keeper against players using any other attack
// default value: 750
#define DMG_KEEPER_ATK_ELSE = 750;

// maximum number of chompers from the demon bow on der eisendrache (global)
// default value: 10
#define MAX_DEMON_CHOMPERS = 10;

// number of seconds to pull off of objective time for reaching objective
// default value: 2
#define GM_TIMEBONUS_OBJ_REACHED = 2;

// number of seconds to pull off of objective time for each 20% interval reached while holding objective
// default value: 3
#define GM_TIMEBONUS_OBJ_HELD = 3;

// Percent to reduce spawn points by when a player downs with quick revive
// default value: 0.25
#define QUICKREVIVE_REDUCE_POINTS = 0.25;

// health for the SOE sword when it is deployed
// default value: 2500
#define SOE_SWORD_HEALTH = 2500;

// the health of beasts on shadows of evil (per round). must be > 0.
// default value: 200
#define BEAST_MODE_HEALTH = 200;

// the amount of damage done by beasts when shocking
// default value: 100
#define BEAST_MODE_SHOCK_DMG = 100;

// the amount of damage done by beasts when meleeing
// default value: 500
#define BEAST_MODE_MELEE_DAMAGE = 500;

// damage per second of banana colada multiplied by the round number
// defaut value: 100
#define PERK_BC_DOT_PER_SEC = 100;

// defines the percent yield all players recieve from an objective leader for minimum points respawn.
// default value: 0.30
#define RUBBERBAND_RATIO = 0.30;

// defines the maximum number of idgun portals that can exist per player
// default value: 2
#define MAX_IDGUN_VORTEX_COUNT = 2;

// defines the number of seconds a player must wait before using another teleporter in shadows of evil to not incur an objective timer penalty
// default value: 10
#define ZM_ZOD_TELEPORT_GRACE = 10;

// Defines the damage per round of the dragon whelp on Gorod Krovi
// default value: 1250
#define DRAGON_WHELP_DMG = 1250;

// Defines the health of the dragon whelp on Gorod Krovi
// default value: 10000
#define DRAGON_WHELP_HEALTH = 10000;

// Defines the round at which the dragon gauntlet on gorod krovi is automatically unlocked
// default value: 10
#define DRAGON_GAUNTLET_UNLOCK_ROUND = 10;

// Defines the damage multiplier to use when calculating aat damage for lucky crit users
// default value: 1.15
#define AAT_INCREASED_DAMAGE_SCALAR = 1.15;

// Defines the maximum number of powerups per round, per person, per team. (default is 2 for solos, 4 for duos, etc.)
// default value: 2
#define MAX_POWERUPS_PER_ROUND = 2;

// When true, uses the new spawning unified system
// default value: true
#define USE_NEW_SPAWNS = true;

// Defines the round at which spawning unified will no longer tether players to the spawns they have discovered
// default value: 10
#define SU_RAND_SPAWNS_ROUND = 10;

// Multiplier value for deadshot headshots against zombies
// default value: 2.0
#define DEADSHOT_MULTIPLIER_PVE = 2.0;

// Multiplier for deadshot headshots against players
// default value: 1.05
#define DEADSHOT_MULTIPLIER_PVP = 1.05;

// When true, mulekick is removed.
// default value: true
#define REMOVE_MULEKICK = true;

// Defines the number of points of damage required to consume a charge of danger closest
// default value: 50000
#define DANGERCLOSEST_HP = 50000;

// Defines the number of points of damage required to completely reduce phd flopper's effects
// default value: 75000
#define PHDFLOPPER_HP = 75000;

// defines the percentage of the phd flopper health recovered per second
// default value: 0.01667 (1.667%)
#define PHDFLOPPER_RECOVERY_PER_SECOND = 0.01667;

// when true, disables wager fx
// default value: true
#define WAGER_FX_DISABLED = true;

// defines the minimum protection from explosives from phd flopper
// default value: 0.25 (25%)
#define PHDFLOPPER_REDUXMIN = 0.25;

#define SUDDEN_DEATH_MODE = level.zbrgs_sudden_death_mode;
#define SUDDEN_DEATH_DISABLED = 0;
#define SUDDEN_DEATH_ROUNDBASED = 1;
#define SUDDEN_DEATH_TIMEBASED = 2;
#define SUDDEN_DEATH_ROUNDS = level.zbrgs_sudden_death_rounds;
#define SUDDEN_DEATH_TIME = level.zbrgs_sudden_death_time;

#endregion

///////////////////////////
// Static Math variables //
///////////////////////////
#region NONTUNABLES

// linear calculation of step delta for lightning nerf
#define STAFF_LIGHTNING_NERF_PCT_STEP = (STAFF_LIGHTNING_NERF_PCT_MAX - STAFF_LIGHTNING_NERF_PCT_MIN) / max(STAFF_LIGHTNING_NERF_NUMSHOTS, 1);

// throttle timer for spawns. do not mess with this because you can crash.
#define SPAWN_THROTTLE_QUEUE_TIME = 1.05;

// True if current injection method is workshop
// default value: false
#define ZBR_IS_WORKSHOP = GetDvarInt("zbr_is_workshop", false);

#endregion

////////////////////////////////
// Development only variables //
////////////////////////////////
#region Development Variables

// When false, disables all development features
// default value: false
#define IS_DEBUG = true;

// defines the absolute maximum number of players for ZBR. must match what is defined in clientfieldmodels
// default value: 4
#define ZBR_MAX_PLAYERS = 8;

// When true, spawns 7 bots instead of 3
// default value: false
#define TEST_EIGHT_PLAYERS = false;

// When true, sets developer dvar to 2
// default value: false
#define STABILITY_PASS = false;

// When true, will respawn players infinitely after being killed. Debugging only.
// default value: false
#define DEBUG_SPAWN_TEST = false;

// When true, exits the game immediately after ending instead of waiting for outro cutscene 
// default value: false
#define DEV_EXIT = true;

// When true, sets the host player to become invulnerable
// default value: false
#define DEV_GODMODE = false;

// When true, gives the host player 25000 starting points
// default value: false
#define DEV_POINTS = true;

// When true, gives all players 25000 starting points
// default value: false
#define DEV_POINTS_ALL = true;

// When true, spawns in 3 test clients
// default value: false
#define DEV_BOTS = true;

// When true, dev bots are ignored by zombies and take no damage from them
// default value: false
#define DEV_BOTS_IGNORE_ZM_DMG = true;

// When true, enables development hud features
// default value: false
#define DEV_HUD = true;

// When true, creates a dev hud for the current zone
// default value: false
#define DEBUG_ZONE = true;

// When true, iprints the closes poi spawn to the player's origin and blacklist status
// default value: false
#define DEBUG_POI_SPAWNER = false;

// When true, spawns a model at each spawn location in the map
// default value: false
#define DEV_ZONE_SPAWNERS = false;

// When true, allows the host to fly with the grenade button and sprint
// default value: false
#define DEV_NOCLIP = true;

// When true, allows the host player to see enemy players through walls
// default value: false
#define DEV_SIGHT = true;

// When true, forces the host player to be on a team which is not allies
// default value: false
#define DEBUG_TEAMS = false;

// When true, uses the DEV_POINTS_TO_WIN variable instead of WIN_NUMPOINTS for objective logic
// default value: false
#define DEV_USE_PTW = false;

// The number of points to win when DEV_USE_PTW is true
// default value: 50000
#define DEV_POINTS_TO_WIN = 50000;

// When enabled, prints the weapon used to damage a player
// default value: false
#define DEV_DMG_DEBUG = false;

// When enabled, prints the weapon used to damage a player
// default value: false
#define DEV_DMG_DEBUG_FIRST = true;

// When enabled, prints the weapon used to damage a player
// default value: false
#define DEV_DMG_DEBUG_FINAL = false;

// When enabled, prints the damage, score, health, and maxhealth of the victim, to the victim
// default value: false
#define DEV_HEALTH_DEBUG = false;

// Award the host a thundergun when they spawn
// default value: false
#define DEBUG_THUNDERGUN = false;

// Award the host an idgun when they spawn
// default value: false
#define DEBUG_IDGUN = false;

// When true, a host player can pull themself with the servant
// default value: false
#define DEBUG_SELF_PULL = false;

// When true, the host player is awarded a wave gun on spawn
// default value: false
#define DEBUG_WAVE_GUN = false;

// When true, the host player is awarded all the perks on spawn
// default value: false
#define DEBUG_ALL_PERKS = false;

// When true, host player will have unlimited ammo
// default value: false
#define DEV_AMMO = false;

// When true, widows wine grenades will do 1 damage (for testing the slow effect)
// default value: false
#define DEBUG_WW_DAMAGE = false;

// When true, awards the host player a soe sword by default
// default value: false
#define DEBUG_SOE_SWORD = false;

// When true, awards the host player a soe upgraded sword by default
// default value: false
#define DEBUG_SOE_SUPERSWORD = false;

// When true, awards the host player grav spikes on zm_castle
// default value: false
#define DEBUG_CASTLE_SPIKES = false;

// if true, upgrades stalingrad dragon strike
// default value: false
#define DEBUG_STALINGRAD_UG_DS = false;

// if true, will award the host with black hole bombs when they spawn.
// default value: false
#define DEBUG_BLACKHOLEBOMB = false;

// adjusts the start round for development
// default value: 3
#define DEBUG_START_ROUND = 3;

// delete all the spawn adjusting logic temporarily
// default value: false
#define DEBUG_REVERT_SPAWNS = false;

// disable all changes to zm_island
// default value: false
#define DEBUG_ISLAND_NOCHANGES = false;

// if true, all players are on the allies team
// default value: false
#define DEBUG_ALL_FRIENDS = false;

// if true, the game mode hud will not be drawn
// default value: false
#define DEBUG_NO_GM_HUD = false;

// if true, the game mode will not initialize roundNext logic
// default value: false
#define DEBUG_NO_ROUNDNEXT = false;

// if true, ignores critical game logic. Only used for last resort debugging
// default value: false
#define DEBUG_NO_GM_THREADED = false;

// if true, will not attempt to return loadouts when a player respawns
// default value: false
#define DEBUG_NO_LOADOUTS = false;

// if true, when on zm_tomb, awards the host player g strike grenades on spawn
// default value: false
#define DEBUG_G_STRIKE = false;

// if true, when on zm_tomb, completes the one inch punch box challenge
// default value: false
#define DEBUG_OIP = true;

// if true, all staffs will be upgraded by default.
// default value: false
#define DEBUG_UPGRADED_STAFFS = false;

// if true, the host will acquire an annihilator on spawn automatically
// default value: false
#define DEBUG_ANNIHILATOR = false;

// if true, the host will acquire the wolf bow on spawn automatically
// default value: false
#define DEBUG_WOLF_BOW = false;

// if true, the host will acquire the fire bow on spawn automatically
// default value: false
#define DEBUG_FIRE_BOW = false;

// if true, the host will acquire the storm bow on spawn automatically
// default value: false
#define DEBUG_STORM_BOW = false;

// if true, the host will acquire the raygun on spawn automatically
// default value: false;
#define DEBUG_RAYGUN = false;

// if true, the host will acquire the raygun mk.3 on spawn automatically. Set to > 1 for upgraded mark 3.
// default value: false;
#define DEBUG_RAYGUN_MK3 = false;

// if true, the host will acquire the skull bow on spawn automatically
// default value: false
#define DEBUG_SKULL_BOW = false;

// if true, awards host shrink ray on spawn (shang only), if 2, awards upgraded
// default value: false
#define DEBUG_SHRINK_RAY = false;

// When true, all players are awarded all the perks on spawn
// default value: false
#define DEBUG_ALL_PERKS_ALL = false;

// When true, the host player is awarded nesting dolls on spawn
// default value: false
#define DEBUG_GIVE_NESTING_DOLLS = false;

// When true, the host player is awarded monkeys on spawn
// default value: false
#define DEBUG_GIVE_MONKEYS = false;

// When true, the host player is awarded octobombs on spawn
// default value: false
#define DEBUG_GIVE_OCTOBOMB = false;

// When true, allows elo application in debug environment. No use in open source release.
// default value: false
#define DEBUG_ALLOW_ELO = false;

// When true, gives the host player a mirg2000 on spawn. If greater than 1, awards an upgraded mirg2000.
// default value: false
#define DEBUG_GIVE_MIRG = false;

// Bots will spawn with this level of wager tier completed automatically.
// default value: 0
#define DEBUG_WAGER_FX = 0;

// When true, bots may not move
// default value: false
#define DEBUG_BOTS_FREEZE = false;

// When true, spawns the ZBR icon in game on the host player
// default value: false
#define DEV_ICON_CAPTURE = false;

// When true, forces wagers to be disabled
// default value: false
#define DEV_NO_WAGERS = false;

// When true, forces host to spawn with a tesla gun
// default value: false
#define DEBUG_TESLA_GUN = false;

// When true, the host can hold ads and melee to teleport a random bot to them.
// default value: false
#define DEBUG_BOT_TELEPORT = false;

// When true, the host can hold ads and melee to kick a random bot
// default value: false
#define DEBUG_BOT_KICK = false;

// When true, poi spawn system will be enabled by default
// default value: false
#define DEV_FORCE_POI_SPAWNS = false;

// When true, all PAP machines will have a default actor attached to their origin and angles
// default value: false
#define DEBUG_PAP_ANGLES = false;

// When true, all mystery boxes will have a default actor attached to their origin and angles
// default value: false
#define DEBUG_BOX_ANGLES = false;

// When true, all wall weapons will have a default actor attached to their origin and angles
// default value: false
#define DEBUG_WALL_ANGLES = false;

// When true, all perks will have a default actor attached to their origin and angles
// default value: false
#define DEBUG_PERK_ANGLES = false;

// When true, all gum machines will have a default actor attached to their origin and angles
// default value: false
#define DEBUG_GUM_ANGLES = false;

// When true, the host can pickup entities by using their ads button
// default value: false
#define DEV_FORGEMODE = false;

// When set to anything except undefined, gives the host the selected bgb on spawn
// default value: undefined
#define DEV_BGB = undefined;

// When set to anything except undefined, gives all players the selected bgb on spawn
// default value: undefined
#define DEV_BGB_ALL = undefined;

// When true, the host player will see normal spectator screen
// default: false;
#define DEV_DISABLE_HOST_SPEC_FIX = false;

// When true, allows the host to skip the current round by holding use
// default value: false
#define DEBUG_NEXT_ROUND = false;

// When defined, awards the host this weapon on spawn
// default value: undefined
#define DEBUG_WEAPON = undefined;

// When true, will print debugging info to notepad when players die
// default value: false
#define DEBUG_DEATHS = true;

// When true, killcams will be used in zbr
// default value: false
#define DEBUG_USE_KILLCAMS = true;

// When true, the host will be able to cycle through all valid upgraded weapons in the level with the use button
// default value: false
#define DEBUG_MAP_WEAPONS = false;

// When true, spawns a custom map gum machine on the host player
// default value: false
#define DEBUG_HOST_CM_BGBM = false;

// When true, enables developer 1 dvar and draws debugged traces
// default value: false
#define DEBUG_TRACES = false;

// When true, prints bgbm logic prints
// default value: false
#define DEBUG_BGBM_VISUALS = false;

// When true, emit information about the weapon in hand for the host to the console
// default value: false
#define DEV_WEAPONBALANCING = false;

// when true, the host has aimbot
// default value: false
#define DEBUG_AIMBOT = false;

// when true, emits periodic updates about the entities list for the server
// default value: false
#define DEBUG_GENT_DATA = false;

// when true, prints info to the console about spawning unified. Ignores IS_DEBUG
// default value: false
#define DEBUG_SPAWNING_UNIFIED = false;

// when true, spawn protection never ends
// default value: false
#define DEBUG_SPAWN_PROTECTION = false;

// when set to anything except -1, changes the bots to match the character index in zbr custom characters.
// default value: -1
#define DEV_BOTCHARACTER = 2;

// when true, enables debug mode for oldschool
// default value: false
#define DEBUG_GM_OS = false;

// when true, enables the EMP grenade
// default value: true
#define ZBR_ENABLE_EMP = true;

// when true, allows self damage
// default value: false
#define DEBUG_FORCE_ALLOW_SELFDMG = false;

// when true, enables real developer in script
// default value: false
#define DEBUG_DEVELOPER = (IS_DEBUG && false);

// when true, marks all the spawners for zombies
// default value: false
#define DEBUG_ZSPAWNS_NP = (DEBUG_DEVELOPER && true);

#endregion

// add your custom maps here
// NOTE: Most custom maps are made by devs who only add 1 zone, or only put spawns in 1 zone.
//       this means that to generate spawns on this map, I have to do some really annoying nav query stuff that produces 
//       weird artifacts sometimes and may not be 100% reliable. 
//       If you are a map creator and enjoy this game mode,
//       make sure you take the time to place player spawns. They are kind of important.
//       
custom_maps()
{
    level.gm_oob_monitors = [ serious::zm_stalingrad_oob_check2 ];
    level.var_3f8c8095 = undefined; // disables all the robit weapon inspections
    if(isfunctionptr(level.cb_spawnlogic))
    {
        level [[ level.cb_spawnlogic ]]();
    }
    gm_generate_spawns();
    return;

    // TODO
    // switch(level.script)
    // {
    //     case "zm_diner":
    //         arr = getentarray("ee_pap_gen_reward_door", "targetname");
    //         if(isdefined(arr))
    //         {
    //             foreach(ent in arr)
    //             {
    //                 ent connectPaths();
    //                 ent delete();
    //             }
    //         }
    //         unlock_all_debris();
    //         gm_generate_spawns(); // generate spawn points for this map, using the POI system
    //     break;

    //     case "zm_pdp_dungeon":
    //         open_all_doors();
    //         str_prefix = "electric_door_";
    //         a_str_values = ["a", "b", "c", "d"];
    //         for(i = 0; i < a_str_values.size; i++)
    //         {
    //             str_value = str_prefix + a_str_values[i];
    //             ents = getentarray(str_value, "targetname");
    //             for(j = 0; j < ents.size; j++)
    //             {
    //                 ents[j] delete();
    //             }
    //         }
    //         gm_generate_spawns(); // generate spawn points for this map, using the POI system
    //     break;

    //     case "zm_mchalloween":
    //         unlock_all_debris();
    //         open_all_doors();
    //         getent("gun_trig", "targetname") delete();
    //         gm_generate_spawns(); // generate spawn points for this map, using the POI system
    //     break;
    // }
}

// a list of terms, which if found in a zone name, automatically blacklists the zone from allowing spawns
// Note: due to performance reasons, you probably dont want to make this list too big.
get_blacklist_zone_terms()
{
    return array
    (
        "boss",
        "arena",
        "egg",
        "secret",
        "fight"
    );
}

// a list of zone names, that when encountered, are automatically blacklisted
get_additional_blacklist()
{
    return [];
}

// runs on player spawn, intented to be used for custom weapon monitors.
custom_weapon_callbacks()
{
    if(isfunctionptr(level.cb_player_weapons))
    {
        self thread [[ level.cb_player_weapons ]]();
    }
}

// runs after blackscreen is passed, one time.
custom_weapon_init()
{
    if(isfunctionptr(level.cb_init_weapons))
    {
        level thread [[ level.cb_init_weapons ]]();
    }
    kill_bad_perks_and_mods();
}

custom_gm_threaded()
{
    if(isfunctionptr(level.cb_gm_threaded))
    {
        level thread [[ level.cb_gm_threaded ]]();
    }
}

// runs after default roundnext
custom_round_next()
{
    if(isfunctionptr(level.cb_roundnext))
    {
        level thread [[ level.cb_roundnext ]]();
    }
}

gm_adjust_custom_weapon(w_weapon, f_result, n_mod_dmg, i_originalDamage, str_meansofdeath = "MOD_NONE", e_attacker = undefined)
{
    // implement any additional weapon weapon damage scalars here
    // you can return a float because the damage callback will automatically 
    if(level.script == "zm_kyassuruz")
    {
        if(issubstr(w_weapon.rootweapon.name, "bow"))
        {
            if(str_meansofdeath == "MOD_PROJECTILE_SPLASH")
            {
                return 1100 * CLAMPED_ROUND_NUMBER;
            }
            return 2100 * CLAMPED_ROUND_NUMBER;
        }
    }
    
    if(level.script == "zm_nazi_zombie_school")
    {
        if(w_weapon.rootweapon.name == "s2_m30_up")
        {
            return f_result / 3;
        }
    }

    // TODO: commented this out
    // correction heuristic for explosives in custom maps. This is not perfect.
    // is_explosive = str_meansofdeath == "MOD_PROJECTILE" || str_meansofdeath == "MOD_PROJECTILE_SPLASH" || str_meansofdeath == "MOD_GRENADE" || str_meansofdeath == "MOD_GRENADE_SPLASH" || str_meansofdeath == "MOD_EXPLOSIVE";
    // if(is_explosive && (abs(n_mod_dmg - 75) <= 2))
    // {
    //     return i_originalDamage * (f_result / n_mod_dmg);
    // }

    if(str_meansofdeath != "MOD_UNKNOWN")
    {
        return f_result * level.f_unregistered_weapon_scalar;
    }

    return f_result; // return a float or an int, representing the final damage to do. Only applies to players.
}

// blacklist poi spawns by their origin
point_bad_by_location(v_point)
{
    if(isdefined(level.fn_zbr_check_bad_point))
    {
        return [[ level.fn_zbr_check_bad_point ]](v_point);
    }
    switch(level.script)
    {
        case "zm_nazi_zombie_school":
        if(distance2D(v_point, (-654.56, -577.878, -463.785)) <= 250)
        {
            return true;
        }
        if(distance2D(v_point, (111.989, 952.621, -15)) <= 250)
        {
            return true;
        }
        break;

        case "zm_town_hd":
        if(distance2d(v_point, (963, 670, 12)) < 200)
        {
            return true;
        }
        break;

        case "zm_westernz":
        if(distance2d(v_point, (44, -90, 8)) < 150)
        {
            return true;
        }
        break;

        case "zm_coast":
        if(distance2d(v_point, (-301, -2106, 276)) <= 300)
        {
            return true;
        }
        break;
    }
    return false;
}

kill_bad_perks_and_mods(){}