#using scripts\codescripts\struct;
#using scripts\shared\fx_shared;
#using scripts\codescripts\struct;
#using scripts\core\_multi_extracam;
#using scripts\mp\_devgui;
#using scripts\shared\_character_customization;
#using scripts\shared\_weapon_customization_icon;
#using scripts\shared\ai\archetype_damage_effects;
#using scripts\shared\ai\systems\destructible_character;
#using scripts\shared\ai\zombie;
#using scripts\shared\animation_shared;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\custom_class;
#using scripts\shared\end_game_taunts;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\lui_shared;
#using scripts\shared\music_shared;
#using scripts\shared\player_shared;
#using scripts\shared\postfx_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;
#using scripts\shared\_character_customization;
#using scripts\core\zbr_emotes;

#namespace core_frontend_fx;

#precache( "client_fx", "light/fx_light_spot_zbr" );

function main()
{
    level._charactercustomizationsetup = level.charactercustomizationsetup;
    level.charactercustomizationsetup = &character_setup;
	visionsetnaked(0, "zm_zbr_frontend", 0);
    // wait 10;
    while(GetPlayers(0).size < 1)
    {
        wait 0.05;
    }
	visionsetnaked(0, "zm_zbr_frontend", 0);
    // GetPlayers(0)[0] thread no_xcam();
    // foreach(ent in getentarray(0))
    // {
    //     data = "";
    //     if(isdefined(ent.name))
    //     {
    //         data += "name: " + ent.name + " ";
    //     }
    //     if(isdefined(ent.script_noteworthy))
    //     {
    //         data += "sn: " + ent.script_noteworthy+ " ";
    //     }
    //     if(isdefined(ent.targetname))
    //     {
    //         data += "tn: " + ent.targetname+ " ";
    //     }
    //     if(isdefined(ent.target))
    //     {
    //         data += "t: " + ent.target + " ";
    //     }
    //     if(isdefined(ent.script_string))
    //     {
    //         data += "ss: " + ent.script_string + " ";
    //     }
    //     iPrintLnBold(data);
    // }
	thread watch_emote_bind();
	thread watch_lobby_emote();
}

function watch_lobby_emote()
{
	while(!isdefined(level.zbr_frontend_characters))
	{
		wait 0.05;
	}
	for(;;)
	{
		level waittill("zbr_character_emote", data);
		toks = strtok(data, ";");
		who = int(toks[0]);
		wat = int(toks[1]);
		if(who < 0 || who > 7)
		{
			continue;
		}
		if(wat < 0 || wat > level.zbr_emote_array.size)
		{
			continue;
		}
		data_struct = zbr_character(who);
		param1 = level.zbr_emote_array[wat];
		data_struct.currentanimation = param1;
		thread end_game_taunts::previewgesture(0, data_struct.charactermodel, data_struct.customization.anim_name, param1);
	}
}

function watch_emote_bind()
{
	while(!isdefined(level.zbr_frontend_characters))
	{
		wait 0.05;
	}
	pressed = 0;
	for(;;)
	{
		new_pressed = [[ &sys::isprofilebuild ]](0x5084F53C);
		if((new_pressed != 0) != (pressed != 0))
		{
			pressed = new_pressed;
			if(pressed)
			{
				emote_local_player(pressed);
			}
		}
		wait 0.05;
	}
}

function emote_local_player(mask)
{
	data_struct = zbr_character(0);

	index = 0;
	if(mask & 1)
	{
		index = 0;
	}
	else if(mask & 2)
	{
		index = 1;
	}
	else if(mask & 4)
	{
		index = 2;
	}
	else if(mask & 8)
	{
		index = 3;
	}
	else if(mask & 16)
	{
		index = 4;
	}

	emote = [[ &sys::isprofilebuild ]](0x7E144B24, index);

	if(emote < 0 || emote >= level.zbr_emote_array.size)
	{
		return;
	}

	param1 = level.zbr_emote_array[emote];
	data_struct.currentanimation = param1;
	[[ &sys::isprofilebuild ]](0x48154CA8, emote);
	end_game_taunts::previewgesture(0, data_struct.charactermodel, data_struct.customization.anim_name, param1);
	//data_struct render_frontend_character();
}

function private no_xcam()
{
    while(true)
    {
        StopMainCamXCam(0);
        wait 0.05;
    }
}

function streamer_change(hint, data_struct)
{
	if(isdefined(hint))
	{
		setstreamerrequest(0, hint);
	}
	else
	{
		clearstreamerrequest(0);
	}
	level notify("streamer_change", data_struct);
}

function character_setup(localclientnum)
{
    if(isdefined(level._charactercustomizationsetup))
    {
        [[ level._charactercustomizationsetup ]](localclientnum);
    }
    lui::createcustomcameramenu("Main", localclientnum, &lobby_main, 1);
    lui::createcustomcameramenu("Pregame_Main", localclientnum, &lobby_main, 1);
}

function zbr_cam(localclientnum)
{
    // iPrintLnBold("zbr cam");
    StopMainCamXCam(localclientnum);
    // playmaincamxcam(localclientnum, "zm_lobby_cam", 0, "cam1", "", (-211.486, 2162.52, 91.86 + 70), (-5.389, 66.632, 0));
	visionsetnaked(localclientnum, "zm_zbr_frontend", 0);
	// playmaincamxcam(localclientnum, "zm_lobby_cam", 0, "cam1", "", (-4325.3, 1881.68, 10 + 70), (6.8344, 96.7579, 0));
    // GetPlayers(localclientnum)[0] camerasetposition((-255.47, 2359.61, 79.958 + 70));
    // GetPlayers(localclientnum)[0] camerasetlookat((-10.47, 77.35, 0));
}

function zbr_uncam(localclientnum)
{
    // self camerasetlookat();
}

function zm_lobby_room(localclientnum)
{
	s_scene = struct::get_script_bundle("scene", "cin_fe_zm_forest_vign_sitting");
	s_params = spawnstruct();
	s_params.scene = s_scene.name;
	s_params.sessionmode = 0;
	// character_customization::loadequippedcharacteronmodel(localclientnum, level.zm_lobby_data_struct, level.zm_debug_index, s_params);
	thread frontend_characters();
}

function pulse_controller_color()
{
	level endon("end_controller_pulse");
	delta_t = -0.01;
	t = 1;
	while(true)
	{
		setallcontrollerslightbarcolor((1 * t, 0.2 * t, 0));
		t = t + delta_t;
		if(t < 0.2 || t > 0.99)
		{
			delta_t = delta_t * -1;
		}
		wait(0.016);
	}
}

function lobby_main(localclientnum, menu_name, state)
{
	level notify("new_lobby");
	setpbgactivebank(localclientnum, 1);
	if(isdefined(state) && !strstartswith(state, "cpzm") && !strstartswith(state, "doa"))
	{
		if(isdefined(level.frontendspecialfx))
		{
			killfx(localclientnum, level.frontendspecialfx);
		}
	}
	if(!isdefined(state) || state == "room2")
	{
		streamer_change("core_frontend_zm_lobby");
		camera_ent = struct::get("mainmenu_frontend_camera");
		zbr_cam(localclientnum);
	}
	else
	{
		if(state == "room1")
		{
			streamer_change("core_frontend_zm_lobby");
			camera_ent = struct::get("room1_frontend_camera");
			setallcontrollerslightbarcolor((1, 0.4, 0));
			level thread pulse_controller_color();
			zbr_cam(localclientnum);
		}
		else
		{
			if(state == "mp_theater")
			{
                zbr_uncam(localclientnum);
				streamer_change("frontend_theater");
				camera_ent = struct::get("frontend_theater");
				if(isdefined(camera_ent))
				{
					playmaincamxcam(localclientnum, "ui_cam_frontend_theater", 0, "cam1", "", camera_ent.origin, camera_ent.angles);
				}
			}
			else
			{
				if(state == "mp_freerun")
				{
                    zbr_uncam(localclientnum);
					streamer_change("frontend_freerun");
					camera_ent = struct::get("frontend_freerun");
					if(isdefined(camera_ent))
					{
						playmaincamxcam(localclientnum, "ui_cam_frontend_freerun", 0, "cam1", "", camera_ent.origin, camera_ent.angles);
					}
				}
				else
				{
					if(strstartswith(state, "doa"))
					{
                        zbr_uncam(localclientnum);
					}
					else
					{
						if(strstartswith(state, "cpzm"))
						{
                            zbr_uncam(localclientnum);
						}
						else
						{
							if(strstartswith(state, "cp"))
							{
                                zbr_uncam(localclientnum);
							}
							else
							{
								if(strstartswith(state, "mp"))
								{
                                    zbr_uncam(localclientnum);
								}
								else
								{
									if(strstartswith(state, "zm"))
									{
										streamer_change("core_frontend_zm_lobby");
										zbr_cam(localclientnum);
										zm_lobby_room(localclientnum);
									}
									else
									{
                                        zbr_uncam(localclientnum);
										streamer_change();
									}
								}
							}
						}
					}
				}
			}
		}
	}
	if(!isdefined(state) || state != "room1")
	{
		setallcontrollerslightbarcolor();
		level notify(#"end_controller_pulse");
	}
}

#using_animtree("all_player");

function dfrontend_create_character(id, origin, angles)
{
	level.zbr_frontend_characters[id] = frontend_create_character(id, origin, angles);
}

function frontend_create_character(id, origin, angles, scale = 1.0)
{
	model = util::spawn_model(0, "tag_origin", origin, angles);
	model.targetname = "zbr_frontend_character_" + id;
	model useanimtree(#animtree);
	model.data_struct = character_customization::create_character_data_struct(model, 0);
	model hide();
	
	customization = spawnstruct();
	customization.charactertype = 9; // our characterindex
	customization.charactermode = 0; // zombies

	customization.body = spawnstruct();
	customization.body.selectedindex = 2;
	customization.body.colors = [];

	customization.head = 0;
	customization.helmet = spawnstruct();
	customization.helmet.selectedindex = 0;
	customization.helmet.colors = [];

	customization.showcaseweapon = spawnstruct();
	customization.showcaseweapon.weaponname = "melee_knuckles_mp";
	customization.showcaseweapon.attachmentinfo = "";
	customization.showcaseweapon.weaponrenderoptions = "";
	customization.anim_name = "pb_cac_brass_knuckles_showcase";

	model.data_struct.customization = customization;
	model.data_struct.charactermodel setscale(scale);
	model.data_struct.scale_override = scale;
	model.data_struct.id = id;

	return model.data_struct;
}

function zbr_character(id)
{
	return level.zbr_frontend_characters[id];
}

// note: this is gonna be an issue since we dont load the fast file instantly
function frontend_characters()
{
	if(isdefined(level.zbr_frontend_characters))
	{
		return;
	}
	// level.xcam_origin = (-4325.3, 2021.68, 25);
	// level.xcam_angles = (-30, 125 + 96.7579, 42);

	level.zbr_frontend_character_origins = [];

	level.debug_frontend_create_character = &dfrontend_create_character;

	level.zbr_frontend_characters = [];
	level.zbr_frontend_characters[level.zbr_frontend_characters.size] = frontend_create_character(0, (-4345.3, 2101.68, 33), (0, -90, 0));
	level.zbr_frontend_characters[level.zbr_frontend_characters.size] = frontend_create_character(1, (-4385.3, 2125.68, 33), (0, -70, 0), 0.85);
	level.zbr_frontend_characters[level.zbr_frontend_characters.size] = frontend_create_character(2, (-4325.3, 2131.68, 33), (0, -90, 0), 0.85);
	level.zbr_frontend_characters[level.zbr_frontend_characters.size] = frontend_create_character(3, (-4307.3, 2095, 33), (0, -100, 0), 0.60);
	level.zbr_frontend_characters[level.zbr_frontend_characters.size] = frontend_create_character(4, (-4385.3, 2090, 33), (0, -55, 0), 0.60);
	level.zbr_frontend_characters[level.zbr_frontend_characters.size] = frontend_create_character(5, (-4323.3, 2075, 33), (0, -95, 0), 0.45);
	level.zbr_frontend_characters[level.zbr_frontend_characters.size] = frontend_create_character(6, (-4356.3, 2075, 33), (0, -65, 0), 0.45);
	level.zbr_frontend_characters[level.zbr_frontend_characters.size] = frontend_create_character(7, (-4337.3, 2068.68, 33), (0, -90, 0), 0.35);

	data = get_pb_and_pbi([[ &sys::isprofilebuild ]](0x25C8D5CF, 0));
	character = zbr_character(0);
	character.customization.body.selectedindex = data.bodyindex;
	character.customization.charactertype = data.charactertype;
	character.spotlight = playfx(0, "light/fx_light_spot_zbr", level.zbr_frontend_characters[0].origin + (-15, -65, 50), level.zbr_frontend_characters[0].angles + (0, 0, 0));
	character.spotlight2 = playfx(0, "light/fx_light_spot_zbr", level.zbr_frontend_characters[0].origin + (15, -35, 80), level.zbr_frontend_characters[0].angles + (0, 0, 0));

	character thread render_frontend_character();
	character thread watch_character_update_host();

	level thread watch_host_info_update();
}

function update_character_attachments(index, hideall = false)
{
	if(!isdefined(level.zbr_character_attachments))
	{
		level.zbr_character_attachments = [];
	}

	if(!isdefined(level.zbr_character_attachments[index]))
	{
		level.zbr_character_attachments[index] = [];
	}

	foreach(attach in level.zbr_character_attachments[index])
	{
		if(isdefined(attach.submodels))
		{
			foreach(mod in attach.submodels)
			{
				mod delete();
			}
		}
		attach delete();
	}
	level.zbr_character_attachments[index] = [];

	if(hideall)
	{
		return;
	}

	if(isdefined(level.zbr_whoami) && level.zbr_whoami != 0)
	{
		if(level.zbr_whoami == index)
		{
			index = 0;
		}
		else if(0 == index)
		{
			index = level.zbr_whoami;
		}
	}

	cosmetics = [[ &sys::isprofilebuild ]](0x5928C1FE, index);

	character = self.charactermodel;

	body_index = self.customization.body.selectedindex;
	character_index = self.customization.charactertype;

	if(!isdefined(cosmetics))
	{
		return;
	}

	if(!isdefined(self.scale_override))
	{
		self.scale_override = 1.0;
	}
	
	if(cosmetics.hat)
	{
		hat_data = zbr_cosmetics::get_hat(cosmetics.hat, body_index, character_index);
		if(isdefined(hat_data))
		{
			hat = spawn(0, character.origin, "script_model");
			hat SetModel(hat_data.model);
			hat setscale(hat_data.scale * self.scale_override);
			
			hat thread fakelinkto_rel(character, hat_data.tag, hat_data.offset * self.scale_override, hat_data.angles);
			level.zbr_character_attachments[index]["hat"] = hat;
		}
	}
}

function fakelinkto_rel(ent, tag, offset, angles)
{
	self endon("death");
	ent endon("death");
	for(;;)
	{
		tagangles = (ent gettagangles(tag));
		self.origin = (ent gettagorigin(tag)) + [[ &sys::isprofilebuild ]](0x6DEACC1B, offset, tagangles); // localtoworld
		self.angles = tagangles + angles;
		wait 0.025;
	}
}

function watch_host_info_update()
{
	for(;;)
	{
		level waittill("zbr_characterlist_update", characterlist);
		_tokens = strtok(characterlist, ";");
		tokens = [];
		for(i = 1; i < _tokens.size; i++)
		{
			tokens[i - 1] = _tokens[i];
		}

		whoami = int(_tokens[0]);
		level.zbr_whoami = whoami;
		if(whoami != 0)
		{
			tmp = tokens[0];
			tokens[0] = tokens[whoami];
			tokens[whoami] = tmp;
		}
		for(i = 1; i < tokens.size; i++)
		{
			character = int(tokens[i]);
			if(character == 0x20 && isdefined(zbr_character(i).charactermodel))
			{
				zbr_character(i) update_character_attachments(i, true);
				zbr_character(i).charactermodel hide();
				continue;
			}
			data = get_pb_and_pbi(character);
			zbr_character(i).customization.body.selectedindex = data.bodyindex;
			zbr_character(i).customization.charactertype = data.charactertype;
			zbr_character(i) thread render_frontend_character();
		}
	}
}

function watch_character_update_host()
{
	for(;;)
	{
		level waittill("zbr_character_change", index);
		index = int(index);
		data = get_pb_and_pbi(index);
		self.customization.body.selectedindex = data.bodyindex;
		self.customization.charactertype = data.charactertype;
		self render_frontend_character();
	}
}

function get_pb_and_pbi(index)
{
	stru = spawnstruct();

    if(index > -1)
    {
        stru.charactertype = 9;
        stru.bodyindex = index;
    }
    else if (index < -1)
    {
        index = int(abs(index) - 2);
        stru.charactertype = index;
        stru.bodyindex = 0;
    }
    else if(index == -1)
	{
		stru.charactertype = randomint(4);
		stru.bodyindex = 0;
	}
    
    return stru;
}

function render_frontend_character()
{
	customization = self.customization;

	params = spawnstruct();
	params.anim_name = customization.anim_name;

	character_customization::set_character(self, customization.charactertype);
	character_customization::set_character_mode(self, customization.charactermode);
	character_customization::set_body(self, customization.charactermode, customization.charactertype, customization.body.selectedindex, customization.body.colors);
	character_customization::set_head(self, customization.charactermode, customization.head);
	character_customization::set_helmet(self, customization.charactermode, customization.charactertype, customization.helmet.selectedindex, customization.helmet.colors);
	character_customization::set_showcase_weapon(self, customization.charactermode, 0, undefined, customization.charactertype, customization.showcaseweapon.weaponname, customization.showcaseweapon.attachmentinfo, customization.showcaseweapon.weaponrenderoptions, 0, 0);
	character_customization::update(0, self, params);
	if(isdefined(self.charactermodel))
	{
		self.charactermodel show();
		self.charactermodel sethighdetail(1, 1);
		self update_character_attachments(self.id);
	}
}