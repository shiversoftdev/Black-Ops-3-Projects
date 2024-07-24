zbr_doa_auto()
{
    // fix stats issue
    compiler::script_detour("scripts/cp/gametypes/_globallogic_player.gsc", #globallogic_player, #function_33d9b2e3, function() => {});

    level.round_number = 0;
    level._custom_perks = [];
}