#namespace zbr_cosmetics;
function autoexec __init__()
{
    level.zbr_emote_array = array(
		"t7_loot_gesture_boast_clucked_up",
		"t7_loot_gesture_threaten_heart_attack",
		"t7_loot_gesture_boast_chickens_dont_dance_vol1",
		"t7_loot_gesture_boast_dip_low",
		"t7_loot_gesture_boast_disconnected",
		"t7_loot_gesture_boast_finger_wag",
		"t7_loot_gesture_boast_gun_show",
		"t7_loot_gesture_boast_hail_seizure",
		"t7_loot_gesture_boast_king_kong",
		"t7_loot_gesture_boast_laughing_at_you",
		"t7_loot_gesture_boast_make_it_rain",
		"t7_loot_gesture_boast_poplock",
		"t7_loot_gesture_boast_see_me_swervin",
		"t7_loot_gesture_boast_shoulder_shrug",
		"t7_loot_gesture_boast_so_fresh",
		"t7_loot_gesture_boast_three_amigos",
		"t7_loot_gesture_boast_yogging",
		"t7_loot_gesture_goodgame_bow",
		"t7_loot_gesture_goodgame_bunny_hop",
		"t7_loot_gesture_goodgame_but_that_flip_though"
	);
	
	setup_cosmetics();
}

// begin cosmetics
function setup_cosmetics()
{
	const Dempsey = 0;
	const Nikolai = 1;
	const Richtofen = 2;
	const Takeo = 3;
	const Floyd = 5;
	const Jack = 6;
	const Jessica = 7;
	const Nero = 8;
	const CustomCharacter = 9;
	const Battery = 0;
	const Ruin = 1;
	const Capybara = 2;

	level.zbr_cosmetic_hats = [];
	register_hat(1, "p7_hat_top_magician_zbr");
	register_hat_override(1, Dempsey, 0, (-0.5, 0.55, 0));
	register_hat_override(1, Nikolai, 0, (1, 0, 0), undefined, 1.3);
	register_hat_override(1, Richtofen, 0, (-0.45, 0.35, 0));
	register_hat_override(1, Takeo, 0, (-0.5, 0.55, 0));
	register_hat_override(1, Floyd, 0, (1.8, 0.55, 0), undefined, 1.05);
	register_hat_override(1, Jack, 0, (1.8, 0.55, 0), undefined, 1.05);
	register_hat_override(1, Jessica, 0, (-0.45, 0.35, 0));
	register_hat_override(1, Nero, 0, (-0.45, 0.35, 0), undefined, 1.1);
	register_hat_override(1, CustomCharacter, Battery, (-0.5, 0.55, 0), undefined, 1.05);
	register_hat_override(1, CustomCharacter, Ruin, (-0.5, 0.55, 0));
	register_hat_override(1, CustomCharacter, Capybara, (1.8, 0.55, 0), undefined, 1.05);

	register_hat(2, "zbr_hat_snapback_long");
	dhat = register_hat_override(2, Dempsey, 0, (-1.5, 0, 0), undefined, 0.87);
	dhat = register_hat_override(2, Nikolai, 0, (0, -0.2, 0), undefined, 1);
	dhat = register_hat_override(2, Richtofen, 0, (-1.5, -0.2, 0), undefined, 0.87);
	dhat = register_hat_override(2, Takeo, 0, (-1.5, -0.1, 0), undefined, 0.9);
	dhat = register_hat_override(2, Floyd, 0, (0.98, -0.1, 0), undefined, 0.9);
	dhat = register_hat_override(2, Jack, 0, (0, -0.23, -0.05), undefined, 0.91);
	dhat = register_hat_override(2, Jessica, 0, (-1.5, -0.1, 0), undefined, 0.9);
	dhat = register_hat_override(2, Nero, 0, (-0.9, -0.5, 0), undefined, 0.95);
	dhat = register_hat_override(2, CustomCharacter, Ruin, (-1.5, -0.1, 0), undefined, 0.9);
	dhat = register_hat_override(2, CustomCharacter, Battery, (-0.9, 0, 0), undefined, 0.95);
	dhat = register_hat_override(2, CustomCharacter, Capybara, (2.5, 1, 0.5), undefined, 1.85);

	register_hat(3, "zbr_krusty_krab");
	register_hat_override(3, Dempsey, 0, (0.95, 0, 0), undefined, 0.65);
	register_hat_override(3, Nikolai, 0, (1.95, 0, 0), undefined, 0.65);
	register_hat_override(3, Richtofen, 0, (0.95, 0, 0), undefined, 0.65);
	register_hat_override(3, Takeo, 0, (0.95, 0, 0), undefined, 0.65);
	register_hat_override(3, Floyd, 0, (1.95, 0, 0), undefined, 0.65);
	register_hat_override(3, Jack, 0, (2.35, 0, 0), undefined, 0.65);
	register_hat_override(3, Jessica, 0, (0.95, 0, 0), undefined, 0.65);
	register_hat_override(3, Nero, 0, (0.95, 0, 0), undefined, 0.65);
	register_hat_override(3, CustomCharacter, Ruin, (0.95, 0, 0), undefined, 0.65);
	register_hat_override(3, CustomCharacter, Battery, (0.95, 0, 0), undefined, 0.65);
	register_hat_override(3, CustomCharacter, Capybara, (1.75, 0, 0), undefined, 0.85);
}

function register_hat(id, model, tag = "j_helmet", offset = (0, 0, 0), angles = (0, 0, 0), scale = 1)
{
	hat = spawnstruct();
	hat.id = id;
	hat.model = model;
	hat.tag = tag;
	hat.offset = offset;
	hat.angles = angles;
	hat.scale = scale;
	hat.character_settings = [];
	level.zbr_cosmetic_hats[id] = hat;
}

function register_hat_override(id, character, body, offset, angles, scale)
{
	base_hat = level.zbr_cosmetic_hats[id];

	hat = spawnstruct();
	hat.id = base_hat.id;
	hat.model = base_hat.model;
	hat.tag = base_hat.tag;
	hat.offset = base_hat.offset;
	hat.angles = base_hat.angles;
	hat.scale = base_hat.scale;

	if(isdefined(offset))
	{
		hat.offset = offset;
	}

	if(isdefined(angles))
	{
		hat.angles = angles;
	}

	if(isdefined(scale))
	{
		hat.scale = scale;
	}
	
	if(!isdefined(base_hat.character_settings))
	{
		base_hat.character_settings = [];
	}

	if(!isdefined(base_hat.character_settings[character]))
	{
		base_hat.character_settings[character] = [];
	}

	base_hat.character_settings[character][body] = hat;
	return hat;
}

function get_hat(id, body, character)
{
	hat = level.zbr_cosmetic_hats[id];

	if(!isdefined(hat) || !isdefined(character) || !isdefined(hat.character_settings) || !isdefined(hat.character_settings[character]) || !isdefined(hat.character_settings[character][body]))
	{
		return hat;
	}

	return hat.character_settings[character][body];
}
// end cosmetics