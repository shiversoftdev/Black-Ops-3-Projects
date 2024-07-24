#define HIT_QUEUE_CHECK_INTERVAL = 60;
#define VIEWABLE_TARGETS_INTERVAL = 1;

#define SHAA_TAGDIST_MAXCONSIDER = 5; // 5 units from the tag is as long as we will consider a hit when reviewing hit discrepencies. 
#define SHAA_ACC_PCT_SUSPICIOUS = 0.25; // if the distance of the shot from the bone is SHAA_TAGDIST_MAXCONSIDER * SHAA_ACC_PCT_SUSPICIOUS or less, this is a bit suspicious.

/*  Anti-aimbot

    General strategy: 
        Collect frame snapshots of data about where a player is looking when they fire their weapon.
        Compare snapshots to a persistant statistics array for anomalies, both against a predefined constraints array from data model training and against previous stats
            - A player isnt going to just randomly go from 50% efficiency to 90% then back to 50% and be legitimate. 
            - Similarly, a player isnt just going to randomly have their shots converge around a specific tag with a average offset delta of (0, 0, 0), or any consistant origin for that matter
            - Use anomaly analysis to increase a confidence indicator about whether the player is cheating or not. Find a reasonable threshold to kick at. (ie: if we are 85% sure that a player is cheating, boot them.)
            - Note that we need to remember that we only want to include player engagements in the snapshot, and equally, we need to account for togglers.
            - Confidence indicator is shared across all anti-cheat analysis functions, so if we are 50% sure that they are using aimbot and 60% sure that they are using esp, we may arithmatically conclude that they are a cheater.
            - There will be fine tuning here, but in general, server analysis needs to require a very high confidence constraint because we also have client analysis that can trigger 100% certainty events.
            - We should eventually ask the other players in the game if they believe that the player is cheating if we reach a certain threshold. Confirmation from players would be the best way to increase accuracy.
        
        Indicators:
            - Frequent shots at players through objects
            - Bone offset deltas converging around the bone or around a specific point with high accuracy
            - Frequently hitting near 0 length delta offsets from bones
            - Extremely large deltas between the fire angles and their previous server cached angles (anti-aim + silent users)
            - Extremely large angle deltas between many frames for cached server angles, along with invalid view angles (anti-aim)
*/

/*  Anti-ESP

    General strategy:
        - Monitor how frequently players are within the FOV of the subject of analysis.
        - ESP players tend to both look closer to non-viewable players as well as keep them within their view frequently.
        - ESP players also tend to move directly to the other players much more frequently (distance convergence rates will be higher)
*/

#define AA_FRAME_MIN_ANALYSIS_SHOTS = 10; // minimum number of shots before analysis can run on a frame context for a player
#define AA_FRAME_DEQUEUE_MIN_SHOTS = 100; // minimum number of shots before a frame can be dequeued and applied to the persistant statistics array


#define SH_FIELD_ACCURACY = 0;
#define SH_FIELD_DISTANCE = 1;
#define SH_FIELD_TIME = 2;
#define SH_HIT_SUSPICIOUS_THROUGH_WALL = 3;

#define THRESHOLD_CHEATER_KICK = 0.90; // 90% sure that this person is a cheater

#define BONE_J_HELMET = 0;
#define BONE_J_HEAD = 1;
#define BONE_J_NECK = 2;
#define BONE_J_SPINEUPPER = 3;
#define BONE_J_SPINELOWER = 4;
#define BONE_J_SHOULDER_LE = 5;
#define BONE_J_SHOULDER_RI = 6;
#define BONE_J_HIP_LE = 7;
#define BONE_J_KNEE_LE = 8;
#define BONE_J_KNEE_RI = 9;
#define BONE_J_ELBOW_LE = 10;
#define BONE_J_ELBOW_RI = 11;
#define BONE_J_ANKLE_LE = 12;
#define BONE_J_ANGLE_RI = 13;
#define BONE_COUNT = 14;

autoexec server_heuristics()
{
    callback::on_connect(function() => 
    {
        self endon("disconnect");
        checked_hits_queue = gettime();
        checked_viewable_targets = gettime();
        self.zbr_hits_queue = [];
        self.last_hit_registered = gettime();
        self.sh_pers_cheater_likelihood = 0;

        self.sh_p_tagdeltamap = [];
        self.sh_f_tagdeltamap = [];

        self.sh_p_num_shots_considered = 0;
        self.sh_f_num_shots_considered = 0;
        
        self.sh_f_frame_drop_time = gettime();
        self.sh_f_sus_shots = 0;

        self.sh_f_selected_victim = -1;
        self.sh_f_shotsatvictim = 0;

        self.sh_p_acc = 0;
        self.sh_f_acc = 0;

        for(i = 0; i < BONE_COUNT; i++)
        {
            self.sh_p_tagdeltamap[i] = (0, 0, 0);
            self.sh_f_tagdeltamap[i] = (0, 0, 0);
        }

        // watch_anticheat_weapon_fired
        self thread [[ function () => 
        {
            self endon("disconnect");

            for(;;)
            {
                // smallest_angle will be > 360 if invalid result
                // note that any critical info needs to be passed from the engine to this context. We have to cache info that was rewinded.
                self waittill("weapon_fired", weapon, view_angles, eye_position, closest_tag_origin, smallest_angle, tag_index, ent_num_victim, v_delta);
                // out_str = "{vangles: " + (view_angles ?? "u");
                // out_str += ", eye: " + (eye_position ?? "u");
                // out_str += ", tagorigin: " + (closest_tag_origin ?? "u");
                // out_str += ", angle: " + (smallest_angle ?? "u");
                // out_str += ", tag: " + (tag_index ?? "u");
                // out_str += ", ent: " + (ent_num_victim ?? "u");
                // out_str += ", d: " + (v_delta ?? "u") + "}";
                // compiler::nprintln(out_str);

                // we should track the position delta between the possible hit location delta and the tag 'attacked'. a cheater's indexes will come very, very close to 0 (within a frame at least)

                // if the angle degrees is greater than 15 we are probably not aiming at a player and can ignore this shot
                // if(smallest_angle >= 15 || tag_index == -1)
                // {
                //     continue;
                // }

                // if(self.sh_f_frame_drop_time >= gettime())
                // {
                //     self sh_aa_eval_frame();
                // }

                // // we can use the consistency of their shots at one particular person to help strengthen our confidence in their cheating
                // if(ent_num_victim == self.sh_f_selected_victim)
                // {
                //     self.sh_f_shotsatvictim++;
                // }
                // else
                // {
                //     self.sh_f_selected_victim = ent_num_victim;
                //     self.sh_f_shotsatvictim = 1;
                // }

                // // update accuracy convergence matrix
                // self.sh_f_tagdeltamap[tag_index] = ((self.sh_f_tagdeltamap[tag_index] * self.sh_frame_num_shots_considered) + v_delta) / (self.sh_frame_num_shots_considered + 1);

                // n_length = distance(v_delta, (0, 0, 0));
                // n_ratio = min(1, n_length / SHAA_TAGDIST_MAXCONSIDER); // this is what we will consider for 'accuracy'

                // // change frame average accuracy
                // self.sh_f_acc = ((self.sh_f_acc * self.sh_frame_num_shots_considered) + (1 - n_ratio)) / (self.sh_frame_num_shots_considered + 1);

                // // note the number of suspicious shots. We will check this later with the total number of considered shots and use this to calculate our confidence for their cheating likelihood.
                // if(n_ratio <= SHAA_ACC_PCT_SUSPICIOUS)
                // {
                //     self.sh_f_sus_shots++;
                // }

                // self.sh_frame_num_shots_considered++;
            }
        }]]();

        for(;;)
        {
            if(gettime() - checked_viewable_targets >= (1000 * VIEWABLE_TARGETS_INTERVAL))
            {
                checked_viewable_targets = gettime();
                self check_viewable_targets_and_update_statistics();
            }
            wait 0.05;
        }
    });

    if(IS_DEBUG && DEBUG_AIMBOT)
    {
        callback::on_spawned(function() =>
        {
            if(!self ishost())
            {
                return;
            }
            self thread dev_aimbot();
        });
    }
}

sh_kick_me()
{
    // TODO (clientfield increment to trigger their client anticheat fast fail, then kick them from match shortly after)
}



// TODO Evaluate frame for discrepencies and make decisions on whether we believe this player to be cheating or not
sh_aa_eval_frame()
{
    self [[ function() =>
    {
        


        self.sh_f_frame_drop_time = gettime() + 10000;
    }]]();
}

// TODO
check_viewable_targets_and_update_statistics()
{

}