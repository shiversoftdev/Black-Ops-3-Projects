mb_itemspawn()
{
    self mb_init();
    mb_itemcleanup();
    self.mb_item = spawn("script_model", self mb_trace(self.mb_distance));
    self.mb_item thread mb_data_debug();
    self.mb_item setmodel("p7_zm_vending_jugg");
    return self.mb_item;
}

mb_itemcleanup()
{
    if(isdefined(self.mb_item))
    {
        self.mb_item delete();
    }
}

mb_item_perm()
{
    if(IsInArray(self.mb_item_perms, self.mb_item))
    {
        return self.mb_item.id;
    }

    id = self.mbitemid;
    self.mbitemid++;

    self.mb_item_perms[id] = self.mb_item;
    self.mb_item.id = id;

    return id;
}

mb_retrieve(i)
{
    self mb_init();
    if(self.mb_item is defined)
    {
        if(!isinarray(self.mb_item_perms, self.mb_item))
        {
            mb_itemcleanup();
        }
    }
    self.mb_item = self.mb_item_perms[i];
    self.mb_item thread mb_data_debug();
    return self.mb_item;
}

mb_init()
{
    if(self.mb_init is true)
    {
        return;
    }
    self.mb_init = true;
    self.mb_distance = 300;
    self.mbitemid = 0;
    self.mb_item_perms = [];
}

mb_clear()
{
    mb_init();
    self.mb_item = undefined;
}

mb_perkplacer()
{
    self endon(#disconnect);
    level endon(#end_game);
    level endon(#game_ended);
    level endon(#zbr_devgui);
    
    if(self.mb_item is undefined)
    {
        mb_itemspawn();
    }

    item = self.mb_item;
    while(self GetToggleState("Object Placer"))
    {
        item dontinterpolate();
        item.origin = self mb_trace(self.mb_distance);
        wait 0.05;
    }

    id = mb_item_perm();
    iPrintLnBold("Item placed.");
}

mb_changepitch()
{
    self endon(#disconnect);
    level endon(#end_game);
    level endon(#game_ended);
    level endon(#zbr_devgui);

    if(self.mb_item is undefined)
    {
        mb_itemspawn();
    }
    
    item = self.mb_item;

    response = self [[ level.zbr_get_keyboard_response ]]("Enter new pitch", "0", 128);

    item.angles = (item.angles[0], float(response), item.angles[2]);
}

mb_changemodel()
{
    self endon(#disconnect);
    level endon(#end_game);
    level endon(#game_ended);
    level endon(#zbr_devgui);

    if(self.mb_item is undefined)
    {
        mb_itemspawn();
    }
    
    item = self.mb_item;
    response = self [[ level.zbr_get_keyboard_response ]]("Enter new model", "unknown", 128);

    switch(response)
    {
        case "jugg":
            response = "p7_zm_vending_jugg";
        break;
        case "dt":
            response = "p7_zm_vending_doubletap2";
        break;
        case "speed":
            response = "p7_zm_vending_sleight";
        break;
        case "staminup":
            response = "p7_zm_vending_marathon";
        break;
        case "ww":
        case "widows":
            response = "p7_zm_vending_widows_wine";
        break;
        case "mulekick":
            response = "p7_zm_vending_three_gun";
        break;
        case "deadshot":
            response = "p7_zm_vending_ads";
        break;
        case "qr":
            response = "p7_zm_vending_revive";
        break;
        case "cherry":
            response = "p7_zm_vending_nuke";
        break;
        case "pap":
            response = "p7_zm_vending_packapunch_on";
        break;
    }
    item setmodel(response);
}

mb_trace(distance)
{
    return bullettrace(self GetEye(), self GetEye() + anglesToForward(self getplayerangles()) * distance, 0, self.mb_item)["position"];
}

mb_data_debug()
{
    level endon(#zbr_devgui);
    self notify(#mb_data_debug);
    self endon(#mb_data_debug);
    self endon(#death);
    if(!isdefined(self.id))
    {
        self.id = "?";
    }
    for(;;)
    {
        print3d(self.origin + (0, 0, 15), self.id + ": " + self.origin, (0, 1, 1), 1, 0.3, 2);
        print3d(self.origin + (0, 0, 5), "" + self.angles, (0, 1, 1), 1, 0.3, 2);
        wait 0.05;
    }
}