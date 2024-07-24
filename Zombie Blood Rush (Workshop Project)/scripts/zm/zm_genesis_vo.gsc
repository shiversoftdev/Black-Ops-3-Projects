#using scripts\zm\craftables\_zm_craftables;
#using scripts\zm\_zm_zonemgr;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_timer;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_sidequests;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm;
#using scripts\shared\ai\margwa;
#using scripts\shared\vehicle_ai_shared;
#using scripts\shared\util_shared;
#using scripts\shared\system_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\array_shared;
#using scripts\codescripts\struct;
#namespace zm_genesis_vo;
function autoexec __init__sytem__()
{
	system::register("zm_genesis_vo", &__init__, undefined, undefined);
}
function __init__()
{
	level.a_e_speakers = [];
}
function function_1399b96f(str_key, var_8d8f9222, n_number, b_randomize){}
function function_1f9abb06(str_key, var_d44b84c3, b_randomize){}
function function_8ac5430(var_b20e186c, v_position){}
function function_13bbcb98(str_vo_line, n_wait, b_wait_if_busy, n_priority, var_43802352){}
function function_672fc476(var_cbd11028, var_e21e86b8, b_wait_if_busy, n_priority, var_43802352){}
function function_c62826c9(var_c35eec70, n_wait, b_wait_if_busy, n_priority, var_43802352){}
function function_9db3bdd7(var_c35eec70, n_wait, b_wait_if_busy, n_priority, var_43802352){}
function function_4974f895(var_c35eec70, n_wait, b_wait_if_busy, n_priority){}
function function_7b697614(str_vo_alias, n_delay, b_wait_if_busy, n_priority, var_d1295208, var_248b6239, var_a5d9e5f7){return false;}
function function_b3baa665(){}
function vo_clear(){}
function function_502f946b(var_7a483c9a){}
function function_2426269b(v_pos, n_range){}
function function_897246e4(str_vo_alias, n_wait, b_wait_if_busy, n_priority, var_d1295208, var_248b6239){}
function function_63c44c5a(var_cbd11028, var_e21e86b8, b_wait_if_busy, n_priority, var_d1295208, var_248b6239){}
function function_7aa5324a(var_cbd11028, var_e21e86b8, b_wait_if_busy, n_priority, var_d1295208){}
function function_c23e3a71(var_49fefccd, n_index, var_f781d8ce, b_wait_if_busy, var_7e649f23, var_d1295208){}
function custom_get_mod_type(impact, mod, weapon, zombie, instakill, dist, player){}
function function_6b96bf38(){}
function function_ef84a69b(){}
function function_7d7d3760(){}
function function_a272201f(var_3ef9e565){}
function function_5803cf05(n_max, var_6e653641){}
function function_7091d990(){}
function function_edee8c1e(){}
function function_5b684ae5(){}
function function_52f36cdc(str_type, var_ecf98bb6){}
function function_73ee0fdd(str_type, var_ecf98bb6){}
function function_20aa8fb0(){}
function function_3fecec4e(){}
function function_bc8dac38(e_player, str_type_override){}
function function_593460bf(){}
function function_3939d375(){}
function function_7e1a463f(){}
function function_1ac8eab3(){}
function function_fbd71326(){}
function function_b254fea1(){}
function function_59a4b1e6(){}
function function_1af15c36(){}
function function_dccb9cbe(){}
function function_d4efe48a(){}
function function_30fcd603(){}
function function_7e2041d5(){}
function function_c3d7d23e(){}
function function_cc2b9e13(var_2afa3837, var_8c599c54, var_b25c16bd){}
function function_8271d5e3(str_type, n_percentage, n_rest){}
function function_dfd59b6d(str_type, var_614a7182){}
function function_6a2d6df(str_type, var_614a7182){}
function function_f7879c72(e_attacker){}
function function_5ebe7974(){}
function function_5a86ac8d(){}
function function_9926a1d1(var_d016ff72){}
function function_a800aae9(){}
function function_79eeee03(str_enemy){}
function function_c74d1a57(){}
function function_98ebb22a(){}
function function_58758962(str_who){}
function corruption_engine_vo(){}
function function_e658d896(){}
function function_2b0fa0c0(){}
function function_2a22bd54(){}
function function_78d4f20e(){}
function function_4821b1a3(str_who){}
function function_10b9b50e(var_3c13e11b){}
function function_36734069(){}
function function_2050fb34(){}
function function_bbeae714(var_d95a0cf3){}
function function_e5bc23b9(str_type){}
function function_60f0dfbc(){}
function function_e6873e6a(){}
function function_f24af040(){}
function function_4eab9dac(){}
function function_a2bd8b29(){}
function function_a8d63dab(var_141eb752){}
function function_ee206f01(){}
function function_89b21fad(){}
function function_92425254(){}
function function_a5e16a1e(){}
function function_21783178(var_fc7f95e3){}
function function_dfe962f(){}
function function_efdd99e2(e_player){}
function function_ab35cb95(){}
function function_14ee80c6(){}
function teleporter_sophia_nag(){}
function function_60fe98c4(){}
function function_47713f03(e_player){}
function function_e644549c(var_af2df8a3){}
function function_af6a23e7(){}
function function_5f2a1c13(){}
function function_8c5fea67(e_player){}
function function_a9c857(){}
function function_a0326f63(){}
function function_e4bc2634(){}
function function_c4c3abad(){}
function function_273b3233(){}
function function_d96c6f7(){}
function function_9907a7c3(){}
function function_dfd31c20(){}
function function_e1bf753b(){}
function function_57f3d77(){}
function function_632967ad(){}
function function_209da490(n_val){}
function function_b780637(n_val){}
function function_9104f6c3(var_9485d9b7){}
function function_b28d80bd(var_9485d9b7){}
function function_cb9eba2(n_val){}
function function_f030bece(n_val){}
function function_a012e4e0(n_val){}