#pragma once
#include "protection.h"
#include "ds.hpp"
#include "callspoof.h"
#include "asset_protection.h"
#include "gscu_hashing.h"
#include "b64.h"
#include <fstream>

#if !IS_PATCH_ONLY

#define __STRINGIFY(x) #x
#define __TOSTRING(x) __STRINGIFY(x)
#define REGISTER_PROFILE_VAR(name, structtype, push_func, callback) zbr::profile::profile.__register_prop(CONST32(__TOSTRING(name)), offsetof(zbr_profile_vars, name), sizeof(structtype), push_func, callback)

#define ZBR_PATCH_JUMPSLOWDOWN 1
#define ZBR_PATCH_FAST_SPRINTLEAP 1
#define ZBR_PATCH_FAST_SPRINTLERPIN 1
#define ZBR_PATCH_SLIDESLOWDOWN 1
#define ZBR_PATCH_CANSLIDETHENSPRINT 1
#define ZBR_PATCH_INSTANT_SLIDE 1
#define ZBR_PATCH_SLIDE_PRESERVE_MOMENTUM 1
#define ZBR_PATCH_FASTSWAP 1
#define ZBR_PATCH_FASTADS 1
#define ZBR_PATCH_FASTJUMP 1
#define ZBR_PATCH_SLIDEANGLES 1
#define ZBR_PATCH_DEADSHOT 1
#define ZBR_EXTEND_CLIENTFX 1
#define ZBR_LAZYSTRINGS 1
//#define ZBR_DEBUG_POOL_OVERRUNS 1

#define ZBR_FAST_SPRINTLEAP_MS 500
#define ZBR_FAST_SPRINTLERPIN_MS 10
#define ZBR_FASTSWAP_MULTIPLIER 0.4444
#define ZBR_FASTADS_MULTIPLIER 2.15
#define ZBR_DEADSHOT_REDUCE_SPREAD 0.3333

#define ZBR_BHOP_GRACE 67
#define ZBR_BHOP_FRICTION_MIN_VELSQ 10000

#define ZBR_ZONE_CHARACTERS_DEFAULT "zbr_default_characters"
#define ZBR_ZONE_CHARACTERS_CONTENTID 0
#define ZBR_ZONE_FREEFLAGS_HACK 0x80000000

#define PATH_ZONE_ROOT "..\\..\\workshop\\content\\311210\\" WORKSHOP_ID
#define PATH_ZONE_DEFAULTPROFILE PATH_ZONE_ROOT "\\defaultprofile"
#define PATH_ZONE_DEFAULTSTATS PATH_ZONE_DEFAULTPROFILE "\\loadouts_zm_offline_0.cgp"

#define PATH_MODSTATS_ROOT "players\\311210\\" WORKSHOP_ID
#define PATH_NAMEFILE PATH_MODSTATS_ROOT "\\playername.txt"
#define PATH_MODSTATS_ZM PATH_MODSTATS_ROOT "\\loadouts_zm_offline_0.cgp"
#define PATH_MODSTATS_ZM_VERSION1 PATH_MODSTATS_ROOT "\\stats-v1.txt"
#define PATH_MODSTATS_ZM_VERSION1_1 PATH_MODSTATS_ROOT "\\stats-v1.cgp"
#define PATH_ZBR_PROFILE_DATA PATH_MODSTATS_ROOT "\\zbr_profile.cgp"
#define PATH_ZBR_GAMESETTINGS "players\\zbr_000.dat"
#define PATH_ZBR_GAMESETTINGS_CUSTOM(slot) (std::string("players\\zbr_cg_") + std::to_string((int)slot) + ".dat").c_str()

#define DEFAULT_PLAYERNAME "ZBR Player"
#define DEFAULT_LOADOUTS_CRC32 -557551242

#define ZBR_MAX_3DDAMAGE_EVENTS 128
#define DAMAGE_TYPE_ANY 0;
#define DAMAGE_TYPE_EXPLOSIVE 1;
#define DAMAGE_TYPE_REDUCED 2;
#define DAMAGE_TYPE_KT_MARKED 3;
#define DAMAGE_TYPE_ZOMBIES 4;
#define DAMAGE_TYPE_CRITICAL 5
#define TEAM_MAX 9

// this is really low BUT remember: headshot multipliers can be up to 5x, and roles/class mods will bump/adjust this dps value (this is just a normalizer baseline)
#define DPS_GLOBAL_TARGET_BURST_R20 25000
#define DPS_GLOBAL_TARGET_BURST_HEAD_R20 55000
#define DPS_STDBOOST_COMP (2/3.75) 

// this number adjusts all weapons scaled by weapons unified. This can reduce all pvp damage for all guns at once.
#define ZBR_GLOBAL_WU_SCALAR 1.0

#define ZBR_GAMESETTINGS_RECHECKTICKS 15000
#define ZBR_CHARACTER_INACTIVE 0x20

struct zbr_cosmetics_data
{
    unsigned __int32 hat : 6;
    unsigned __int32 pad : 26;
    unsigned __int32 pad2 : 32;
};

// UI_WorldPosToLUIPos 2819320 (needs spoof call)
// CL_ParseSnapshot 1366FF0 (needs spoof call)
// SV_WriteSnapshotToClient 2262300
// linked list entry for setupUITextUncached: 365C718 (const char* name, const subroutine* sub, const __int64 nextEntry)
// UI_LuaCall_UIElement_setupUITextUncached 2818720
// UI_ToElement: 270DEB0
// element->renderFunction: +0x118
// UIElement_UITextUncachedRender: 280CA50
#define ZBR_GAMEMODE_MAXLEN 15
struct zbr_lobby_state
{
    zbr_cosmetics_data cosmetics[8];
    bool is_dirty;
    unsigned char team_size;
    unsigned __int32 lobby_key; // all host to client and client to host communications need this field. TODO: clients can be remotely disconnected from host if they recieve a lobby state remotely. need to ensure its the host.
    __int32 characterlist[8];
    unsigned __int32 whoami;
    char gamemode[ZBR_GAMEMODE_MAXLEN+1];

    zbr_lobby_state()
    {
        is_dirty = false;
        team_size = 1;
        srand(time(0));
        lobby_key = (((((rand() * rand() * rand() * rand()) % 187469) * (rand() * rand() * rand() * rand())) % 187469) * rand()) % 187469;
        
        for (int i = 0; i < 8; i++)
        {
            characterlist[i] = ZBR_CHARACTER_INACTIVE;
            cosmetics[i] = zbr_cosmetics_data();
        }
        whoami = 0;
        memset(gamemode, 0, ZBR_GAMEMODE_MAXLEN+1);
        strcat_s(gamemode, "zbr");
    }
};

struct zbr_client_reliable
{
    unsigned int lobby_key;
    unsigned char has_content;
    __int32 selected_character;
    unsigned __int64 who;
    __int32 selected_weapon;
    zbr_cosmetics_data cosmetics;
};

struct LuaScopedEventThrowaway
{
    unsigned char fixed[0x60];
};

struct int24
{
    unsigned char up;
    unsigned char mid;
    unsigned char low;

    void set(int value)
    {
        up = ((value & 0x80000000) >> 24) | ((value >> 16) & 0x7F);
        mid = (value >> 8) & 0xFF;
        low = value & 0xFF;
    }

    int get()
    {
        return low | (mid << 8) | ((up & 0x7F) << 16) | ((up & 0x80) << 24);
    }
};

struct damage3d_event
{
    int16_t x;
    int16_t y;
    int16_t z;
    int24 amount;
    unsigned char damage_type;
    int16_t reserved;

    int repmask;
};

struct zbr_game_state
{
    std::vector<damage3d_event> damage3d_pending;
    std::unordered_map<__int64, int> expected_teams;
    std::unordered_map<__int64, int> spawn_weapons;
    std::unordered_map<__int64, int> zbr_character_index;
    std::unordered_map<__int64, zbr_cosmetics_data> zbr_cosmetics;
    __int32 team_size;
};

// note: dont use these, they dont work right now
struct fuzzy_int32
{
    __int64 value;

    /*
        Fuzzy Algorithm:

        N bits for data, N bits for 'fuzz'
    */

    void set(__int32 target)
    {
        __int32 fuzz = ((__int16)rand() << 16) | (__int16)rand();
        value = 0;
        for (int i = 0; i < 8; i++)
        {
            unsigned char rb0 = (fuzz >> (i * 4 + 0)) & 1;
            unsigned char rb1 = (fuzz >> (i * 4 + 1)) & 1;
            unsigned char rb2 = (fuzz >> (i * 4 + 2)) & 1;
            unsigned char rb3 = (fuzz >> (i * 4 + 3)) & 1;

            unsigned char db0 = (target >> (i * 4 + 3)) & 1;
            unsigned char db1 = (target >> (i * 4 + 2)) & 1;
            unsigned char db2 = (target >> (i * 4 + 1)) & 1;
            unsigned char db3 = (target >> (i * 4 + 0)) & 1;

            if (i % 2)
            {
                auto tmp = db1;
                db1 = db3;
                db3 = db1;
            }

            value |= (__int64)rb0 << (i * 8);
            if (rb0)
            {
                value |= (__int64)rb1 << (i * 8 + 1);

                if (rb1)
                {
                    value |= (__int64)db1 << (i * 8 + 2);
                    if (db1)
                    {
                        value |= (__int64)db2 << (i * 8 + 3);
                        if (db2)
                        {
                            value |= (__int64)db0 << (i * 8 + 4);
                            if (db0)
                            {
                                value |= (__int64)rb2 << (i * 8 + 5);
                                if (rb2)
                                {
                                    value |= (__int64)rb3 << (i * 8 + 6);
                                    value |= (__int64)db3 << (i * 8 + 7);
                                }
                                else
                                {
                                    value |= (__int64)db3 << (i * 8 + 6);
                                    value |= (__int64)rb3 << (i * 8 + 7);
                                }
                            }
                            else
                            {
                                value |= (__int64)rb2 << (i * 8 + 5);
                                value |= (__int64)db3 << (i * 8 + 6);
                                value |= (__int64)rb3 << (i * 8 + 7);
                            }
                        }
                        else
                        {
                            value |= (__int64)rb2 << (i * 8 + 4);
                            if (rb2)
                            {
                                value |= (__int64)db0 << (i * 8 + 5);
                                value |= (__int64)rb3 << (i * 8 + 6);
                                value |= (__int64)db3 << (i * 8 + 7);
                            }
                            else
                            {
                                value |= (__int64)rb3 << (i * 8 + 5);
                                if (rb3)
                                {
                                    value |= (__int64)db3 << (i * 8 + 6);
                                    value |= (__int64)db0 << (i * 8 + 7);
                                }
                                else
                                {
                                    value |= (__int64)db3 << (i * 8 + 6);
                                    value |= (__int64)db0 << (i * 8 + 7);
                                }
                            }
                        }
                    }
                    else
                    {
                        value |= (__int64)rb2 << (i * 8 + 3);
                        if (rb2)
                        {
                            value |= (__int64)db3 << (i * 8 + 4);
                            value |= (__int64)rb3 << (i * 8 + 5);
                            if (rb3)
                            {
                                value |= (__int64)db2 << (i * 8 + 6);
                                value |= (__int64)db0 << (i * 8 + 7);
                            }
                            else
                            {
                                value |= (__int64)db0 << (i * 8 + 6);
                                value |= (__int64)db2 << (i * 8 + 7);
                            }
                        }
                        else
                        {
                            value |= (__int64)db2 << (i * 8 + 4);
                            value |= (__int64)db0 << (i * 8 + 5);
                            value |= (__int64)db3 << (i * 8 + 6);
                            value |= (__int64)rb3 << (i * 8 + 7);
                        }
                    }
                }
                else
                {
                    value |= (__int64)db0 << (i * 8 + 2);
                    value |= (__int64)rb2 << (i * 8 + 3);
                    if (rb2)
                    {
                        value |= (__int64)db2 << (i * 8 + 4);
                        value |= (__int64)rb3 << (i * 8 + 5);
                        if (rb3)
                        {
                            value |= (__int64)db1 << (i * 8 + 6);
                            value |= (__int64)db3 << (i * 8 + 7);
                        }
                        else
                        {
                            value |= (__int64)db3 << (i * 8 + 6);
                            value |= (__int64)db1 << (i * 8 + 7);
                        }
                    }
                    else
                    {
                        value |= (__int64)db1 << (i * 8 + 4);
                        if (db1)
                        {
                            value |= (__int64)db2 << (i * 8 + 5);
                            if (db2)
                            {
                                value |= (__int64)db3 << (i * 8 + 6);
                                value |= (__int64)rb3 << (i * 8 + 7);
                            }
                            else
                            {
                                value |= (__int64)rb3 << (i * 8 + 6);
                                value |= (__int64)db3 << (i * 8 + 7);
                            }
                        }
                        else
                        {
                            value |= (__int64)db3 << (i * 8 + 5);
                            value |= (__int64)rb3 << (i * 8 + 6);
                            value |= (__int64)db2 << (i * 8 + 7);
                        }
                    }
                }
            }
            else
            {
                value |= (__int64)db0 << (i * 8 + 1);

                if (db0)
                {
                    value |= (__int64)rb1 << (i * 8 + 2);
                    if (rb1)
                    {
                        value |= (__int64)db1 << (i * 8 + 3);
                        if (db1)
                        {
                            value |= (__int64)rb2 << (i * 8 + 4);
                            value |= (__int64)rb3 << (i * 8 + 5);
                            if (rb3)
                            {
                                value |= (__int64)db2 << (i * 8 + 6);
                                value |= (__int64)db3 << (i * 8 + 7);
                            }
                            else
                            {
                                value |= (__int64)db3 << (i * 8 + 6);
                                value |= (__int64)db2 << (i * 8 + 7);
                            }
                        }
                        else
                        {
                            value |= (__int64)db2 << (i * 8 + 4);
                            if (db2)
                            {
                                value |= (__int64)rb2 << (i * 8 + 5);
                                if (rb2)
                                {
                                    value |= (__int64)rb3 << (i * 8 + 6);
                                    value |= (__int64)db3 << (i * 8 + 7);
                                }
                                else
                                {
                                    value |= (__int64)db3 << (i * 8 + 6);
                                    value |= (__int64)rb3 << (i * 8 + 7);
                                }
                            }
                            else
                            {
                                value |= (__int64)db3 << (i * 8 + 5);
                                value |= (__int64)rb2 << (i * 8 + 6);
                                value |= (__int64)rb3 << (i * 8 + 7);
                            }
                        }
                    }
                    else
                    {
                        value |= (__int64)db2 << (i * 8 + 3);
                        if (db2)
                        {
                            value |= (__int64)db3 << (i * 8 + 4);
                            value |= (__int64)db1 << (i * 8 + 5);
                            value |= (__int64)rb2 << (i * 8 + 6);
                            value |= (__int64)rb3 << (i * 8 + 7);
                        }
                        else
                        {
                            value |= (__int64)db1 << (i * 8 + 4);
                            value |= (__int64)rb2 << (i * 8 + 5);
                            if (rb2)
                            {
                                value |= (__int64)rb3 << (i * 8 + 6);
                                value |= (__int64)db3 << (i * 8 + 7);
                            }
                            else
                            {
                                value |= (__int64)db3 << (i * 8 + 6);
                                value |= (__int64)rb3 << (i * 8 + 7);
                            }
                        }
                    }
                }
                else
                {
                    value |= (__int64)db1 << (i * 8 + 2);
                    value |= (__int64)rb1 << (i * 8 + 3);
                    if (rb1)
                    {
                        value |= (__int64)db3 << (i * 8 + 4);
                        value |= (__int64)rb2 << (i * 8 + 5);
                        if (rb2)
                        {
                            value |= (__int64)rb3 << (i * 8 + 6);
                            value |= (__int64)db2 << (i * 8 + 7);
                        }
                        else
                        {
                            value |= (__int64)db2 << (i * 8 + 6);
                            value |= (__int64)rb3 << (i * 8 + 7);
                        }
                    }
                    else
                    {
                        value |= (__int64)rb2 << (i * 8 + 4);
                        if (rb2)
                        {
                            value |= (__int64)rb3 << (i * 8 + 5);
                            if (rb3)
                            {
                                value |= (__int64)db3 << (i * 8 + 6);
                                value |= (__int64)db2 << (i * 8 + 7);
                            }
                            else
                            {
                                value |= (__int64)db2 << (i * 8 + 6);
                                value |= (__int64)db3 << (i * 8 + 7);
                            }
                        }
                        else
                        {
                            value |= (__int64)db3 << (i * 8 + 5);
                            value |= (__int64)rb3 << (i * 8 + 6);
                            value |= (__int64)db2 << (i * 8 + 7);
                        }
                    }
                }
            }
        }
    }

    __int32 get()
    {
        __int32 result = 0;

        for (int i = 0; i < 8; i++)
        {
            unsigned char workByte = ((unsigned __int64)value >> (i * 8)) & 0xFF;
            unsigned char db0 = 0, db1 = 0, db2 = 0, db3 = 0;
            if (workByte & 1) // rb0
            {
                if ((workByte >> 1) & 1)
                {
                    db1 = (workByte >> 2) & 1;
                    if (db1)
                    {
                        db2 = (workByte >> 3) & 1;
                        if (db2)
                        {
                            db0 = (workByte >> 4) & 1;
                            if (db0)
                            {
                                if ((workByte >> 5) & 1)
                                {
                                    db3 = (workByte >> 7) & 1;
                                }
                                else
                                {
                                    db3 = (workByte >> 6) & 1;
                                }
                            }
                            else
                            {
                                db3 = (workByte >> 6) & 1;
                            }
                        }
                        else
                        {
                            if ((workByte >> 4) & 1)
                            {
                                db0 = (workByte >> 5) & 1;
                                db3 = (workByte >> 7) & 1;
                            }
                            else
                            {
                                if ((workByte >> 5) & 1)
                                {
                                    db3 = (workByte >> 7) & 1;
                                    db0 = (workByte >> 6) & 1;
                                }
                                else
                                {
                                    db3 = (workByte >> 6) & 1;
                                    db0 = (workByte >> 7) & 1;
                                }
                            }
                        }
                    }
                    else
                    {
                        if ((workByte >> 3) & 1)
                        {
                            db3 = (workByte >> 4) & 1;
                            if ((workByte >> 5) & 1)
                            {
                                db0 = (workByte >> 7) & 1;
                                db2 = (workByte >> 6) & 1;
                            }
                            else
                            {
                                db0 = (workByte >> 6) & 1;
                                db2 = (workByte >> 7) & 1;
                            }
                        }
                        else
                        {
                            db2 = (workByte >> 4) & 1;
                            db0 = (workByte >> 5) & 1;
                            db3 = (workByte >> 6) & 1;
                        }
                    }
                }
                else
                {
                    db0 = (workByte >> 2) & 1;
                    if ((workByte >> 3) & 1)
                    {
                        db2 = (workByte >> 4) & 1;
                        if ((workByte >> 5) & 1)
                        {
                            db1 = (workByte >> 6) & 1;
                            db3 = (workByte >> 7) & 1;
                        }
                        else
                        {
                            db3 = (workByte >> 6) & 1;
                            db1 = (workByte >> 7) & 1;
                        }
                    }
                    else
                    {
                        db1 = (workByte >> 4) & 1;
                        if (db1)
                        {
                            db2 = (workByte >> 5) & 1;
                            if (db2)
                            {
                                db3 = (workByte >> 6) & 1;
                            }
                            else
                            {
                                db3 = (workByte >> 7) & 1;
                            }
                        }
                        else
                        {
                            db3 = (workByte >> 5) & 1;
                            db2 = (workByte >> 7) & 1;
                        }
                    }
                }
            }
            else
            {
                db0 = (workByte >> 1) & 1;
                if (db0)
                {
                    if ((workByte >> 2) & 1)
                    {
                        db1 = (workByte >> 3) & 1;
                        if (db1)
                        {
                            if ((workByte >> 5) & 1)
                            {
                                db2 = (workByte >> 6) & 1;
                                db3 = (workByte >> 7) & 1;
                            }
                            else
                            {
                                db2 = (workByte >> 7) & 1;
                                db3 = (workByte >> 6) & 1;
                            }
                        }
                        else
                        {
                            db2 = (workByte >> 4) & 1;
                            if (db2)
                            {
                                if ((workByte >> 5) & 1)
                                {
                                    db3 = (workByte >> 7) & 1;
                                }
                                else
                                {
                                    db3 = (workByte >> 6) & 1;
                                }
                            }
                            else
                            {
                                db3 = (workByte >> 5) & 1;
                            }
                        }
                    }
                    else
                    {
                        db2 = (workByte >> 3) & 1;
                        if (db2)
                        {
                            db3 = (workByte >> 4) & 1;
                            db1 = (workByte >> 5) & 1;
                        }
                        else
                        {
                            db1 = (workByte >> 4) & 1;
                            if ((workByte >> 5) & 1)
                            {
                                db3 = (workByte >> 7) & 1;
                            }
                            else
                            {
                                db3 = (workByte >> 6) & 1;
                            }
                        }
                    }
                }
                else
                {
                    db1 = (workByte >> 2) & 1;
                    if ((workByte >> 3) & 1)
                    {
                        db3 = (workByte >> 4) & 1;
                        if ((workByte >> 5) & 1)
                        {
                            db2 = (workByte >> 7) & 1;
                        }
                        else
                        {
                            db2 = (workByte >> 6) & 1;
                        }
                    }
                    else
                    {
                        if ((workByte >> 4) & 1)
                        {
                            if ((workByte >> 5) & 1)
                            {
                                db2 = (workByte >> 7) & 1;
                                db3 = (workByte >> 6) & 1;
                            }
                            else
                            {
                                db2 = (workByte >> 6) & 1;
                                db3 = (workByte >> 7) & 1;
                            }
                            
                        }
                        else
                        {
                            db3 = (workByte >> 5) & 1;
                            db2 = (workByte >> 7) & 1;
                        }
                    }
                }
            }

            if (i % 2)
            {
                auto tmp = db1;
                db1 = db3;
                db3 = db1;
            }

            result |= ((__int32)(db0 | (db1 << 1) | (db2 << 2) | (db3 << 3))) << (i * 4);
        }

        return result;
    }
};

struct fuzzy_float
{
    fuzzy_int32 i32;

    void set(float target)
    {
        i32.set(*(__int32*)&target);
    }

    float get()
    {
        __int32 val = i32.get();
        return *(float*)&val;
    }
};

struct fuzzy_int64
{
    fuzzy_int32 i32l;
    fuzzy_int32 i32h;

    void set(__int64 value)
    {
        i32l.set(*(__int32*)&value);
        i32h.set(*((__int32*)&value + 1));
    }

    __int64 get()
    {
        __int32 data[2];
        data[0] = i32l.get();
        data[1] = i32h.get();
        return *(__int64*)data;
    }
};

#define ZBR_DEFAULT_STATBUFF_SIZE 0x2000
#define ZBR_STATBUFF_INCREASE_SIZE 0x1000
#define ZBR_MAX_STATBUFF_SIZE 0xF000
#define ZBR_MAX_RAWSIZE 0xFFFF
#define ZBR_STATS_VERSION 1
#define ZBR_STATS_ERROR_BADHANDLE 0x80000000
#define ZBR_STATS_ERROR_BADBUFFER 0x80000001
#define ZBR_STATS_ERROR_BUFFERFULL 0x80000002
#define ZBR_STAT_CRYPT_CONST 0x3E8F92BA
#define ZBR_STAT_BUFF_MAGIC 0x72627A636967616D
struct zbr_stats_buffer
{
    fuzzy_int32 version;
    fuzzy_int32 buff_size;
    bool dirty;
    unsigned char* buff;
};

typedef __int32 ZBR_HND_STATS;

enum ZBR_STAT_INDEX
{
    ZBR_STAT_INFO = 0,
    ZBR_STAT_XUID0 = 1,
    ZBR_STAT_XUID1 = 2,
    ZBR_STAT_XUID2 = 3,
    ZBR_STAT_XUID3 = 4,
    ZBR_STAT_CHECKSUM0 = 5,
    ZBR_STAT_CHECKSUM1 = 6,
    ZBR_STAT_COUNT
};

struct zbr_stat_info_header
{
    fuzzy_int32 num_stats;
    fuzzy_int32 next_stat;
};

union __zbr_stat_value
{
    fuzzy_int32 i32;
    fuzzy_float f32;
    fuzzy_int64 i64;

    fuzzy_int64 xuid;
    zbr_stat_info_header info;
    fuzzy_int32 checksum;
};

struct zbr_stat_pair
{
    fuzzy_int32 key;
    __zbr_stat_value value;
};

enum ZBR_PROFILE_DATA_TYPE
{
    ZBR_PDATA_INT
};

struct zbr_profile_var_info
{
    size_t off;
    size_t size;
    ZBR_PROFILE_DATA_TYPE type;
    void* callback;
};

#define PROFILE_VAR_CHARACTER character
#define PROFILE_VAR_BDAMAGENUMBERS b_damagenumbers
#define PROFILE_VAR_FAVORITE_EMOTE favorite_emote
#define PROFILE_VAR_EMOTE1 emote1
#define PROFILE_VAR_EMOTE2 emote2
#define PROFILE_VAR_EMOTE3 emote3
#define PROFILE_VAR_EMOTE4 emote4
#define PROFILE_VAR_SPAWNWEAPON spawnweapon
#define PROFILE_VAR_HAT hat

struct zbr_profile_vars
{
    // when adding fields do not forget to REGISTER_PROFILE_VAR in profile_init!
    __int32 PROFILE_VAR_CHARACTER;
    __int32 PROFILE_VAR_BDAMAGENUMBERS;
    __int32 PROFILE_VAR_FAVORITE_EMOTE;
    __int32 PROFILE_VAR_EMOTE1;
    __int32 PROFILE_VAR_EMOTE2;
    __int32 PROFILE_VAR_EMOTE3;
    __int32 PROFILE_VAR_EMOTE4;
    __int32 PROFILE_VAR_SPAWNWEAPON;
    __int32 PROFILE_VAR_HAT;

    zbr_profile_vars()
    {
        PROFILE_VAR_CHARACTER = -1;
        PROFILE_VAR_BDAMAGENUMBERS = 1;
        PROFILE_VAR_FAVORITE_EMOTE = 0;
        PROFILE_VAR_EMOTE1 = 1;
        PROFILE_VAR_EMOTE2 = 2;
        PROFILE_VAR_EMOTE3 = 3;
        PROFILE_VAR_EMOTE4 = 4;
        PROFILE_VAR_SPAWNWEAPON = 0;
        PROFILE_VAR_HAT = 0;

        emitsize = 0;
    }

    std::unordered_map<__int32, zbr_profile_var_info> props;
    size_t emitsize;
    void __register_prop(__int32 name, size_t off, size_t size, ZBR_PROFILE_DATA_TYPE type, void* callback)
    {
        if (props.find(name) != props.end())
        {
            return;
        }

        props[name] = zbr_profile_var_info();
        props[name].off = off;
        props[name].size = size;
        props[name].type = type;
        props[name].callback = callback;
        emitsize += size + sizeof(__int32);
    }
};

enum ZBR_GAMESETTING_TYPES
{
    ZBR_GS___int32,
    ZBR_GS_float
};

union ZBR_GAMESETTING_VALUE
{
    float _float;
    __int32 ___int32;
};

struct zbr_gamesetting
{
    ZBR_GAMESETTING_TYPES type;
    ZBR_GAMESETTING_VALUE value;
    unsigned __int32 name;

    __int32 i32()
    {
        switch(type)
        {
            case ZBR_GS___int32: return value.___int32;
            case ZBR_GS_float: return (__int32)value._float;
        }
        return value.___int32;
    }

    float f()
    {
        switch(type)
        {
            case ZBR_GS___int32: return (float)value.___int32;
            case ZBR_GS_float: return value._float;
        }
        return value._float;
    }
};

#define ZBR_GAMESETTINGS_SIZE (offsetof(zbr_gamesettings, tail) + sizeof(__int32))
#define ZBR_GAMESETTING(name, type, defaultvalue) zbr_gamesetting name = {ZBR_GS_ ## type, { ._ ## type = defaultvalue }, FNV32(__TOSTRING(name))}
extern std::unordered_map<__int32, __int32> ___zbr_gamesettings_fields;
extern bool ___zbr_gamesettings_init;
struct zbr_gamesettings
{
    unsigned __int32 size;
    unsigned __int32 version;
    
    zbr_gamesetting head;

    // all public fields here
    
    // Adjusts the pvp damage across the entire game
    // default value: 1.0
    ZBR_GAMESETTING(pvp_damage_scalar, float, 1.0f);

#if ZBR_IS_Z4C_BUILD
    // When true, wager totems wont spawn
    // default value: false
    ZBR_GAMESETTING(no_wager_totems, __int32, true);
#else
    // When true, wager totems wont spawn
    // default value: false
    ZBR_GAMESETTING(no_wager_totems, __int32, false);
#endif

    // When set to true, forces you to gain host in public matches
    // default value: true
    ZBR_GAMESETTING(force_host, __int32, true);

    // The delay, in seconds, before applying any game mode logic to a player once spawned
    // default value: 2
    ZBR_GAMESETTING(spawn_delay, float, 2.0f);

    // Maximum time, in seconds, that a zombie may walk the earth
    // default value: 45
    ZBR_GAMESETTING(zombie_maxlifetime, float, 45.0);

    // Defines the mode of sudden death. 0 = off, 1 = rounds, 2 = time, 3 = both
    // default value: 3 = both
    ZBR_GAMESETTING(sudden_death_mode, __int32, 3);

    // Defines the number of rounds that may elapse before sudden death kicks in
    // default value: 30
    ZBR_GAMESETTING(sudden_death_rounds, __int32, 30);

    // Defines the time, in minutes, that may elapse before sudden death kicks in
    // default value: 1 * 60 + 1 (1h)
    ZBR_GAMESETTING(sudden_death_time, __int32, (0 * 60 + 61));

    // Number of points a player must have to win the game
    // default value: 100000
    ZBR_GAMESETTING(win_numpoints, __int32, 100000);

    // Global scalar to outgoing zombie damage
    // default value: 1.0
    ZBR_GAMESETTING(outgoing_pve_damage, float, 1.0);

    // Global scalar to incoming zombie damage
    // default value: 1.0
    ZBR_GAMESETTING(incoming_pve_damage, float, 1.0);

    // Are super sprinters enabled
    // default value: true
    ZBR_GAMESETTING(super_sprinters_enabled, __int32, true);

    // Efficiency operand used against the net damage done to a player when converting to point awards
    // default value: 0.7
    ZBR_GAMESETTING(dmg_convt_efficiency, float, 0.7);

    // Time in seconds that a player must hold (at least) the points to win as their score to win the game.
    // default value: 120
    ZBR_GAMESETTING(objective_win_time, __int32, 120);

    // Round to start the game mode at. Does not affect buy power scalars.
    // default value: 3
    ZBR_GAMESETTING(gm_start_round, __int32, 3);

    // Defines the time in seconds to wait before attempting to respawn a player mid round. Requires USE_MIDROUND_SPAWNS = true
    // default value: 45
    ZBR_GAMESETTING(player_midround_respawn_delay, __int32, 45);

    // Defines the number of points you spawn with at minimum
    // default value: 500
    ZBR_GAMESETTING(starting_points_cm, __int32, 500);

    // If true, disables gobblegum machines
    // default value: false
    ZBR_GAMESETTING(disable_gums_cm, __int32, false);

    // Multiplier to use when respawning a player and granting their max points
    // default value: 0.75
    ZBR_GAMESETTING(spawn_reduce_points, float, 0.75);

    // Override for the max points possible for a player's inventory. Default is 3 * points to win.
    // default value: 0 (disabled)
    ZBR_GAMESETTING(max_points_override, __int32, 0);

    // Defines the resistance eggers get in zhunt
    // default value: 0.5
    ZBR_GAMESETTING(zhunt_egger_resistance, float, 0.5);

    // Determines if headshots only is active, rejecting any non-headshot damage
    // default value: 0
    ZBR_GAMESETTING(headshots_only, __int32, 0);

    unsigned __int32 tail = 0x72627A;

    // all private fields here
    
    zbr_gamesettings()
    {
        size = ZBR_GAMESETTINGS_SIZE;
        version = 0;
        head = zbr_gamesetting();
        init();
    }

    void init()
    {
        if(___zbr_gamesettings_init)
        {
            return;
        }

        ___zbr_gamesettings_init = true;

        __int32 off = offsetof(zbr_gamesettings, head) + sizeof(zbr_gamesetting);
        while (off < offsetof(zbr_gamesettings, tail))
        {
            ___zbr_gamesettings_fields[((zbr_gamesetting*)((const char*)this + off))->name] = off;
            off += sizeof(zbr_gamesetting);
        }
    }

    zbr_gamesetting* get_member(const char* name)
    {
        auto name_hash = fnv1a(name);
        if (___zbr_gamesettings_fields.find(name_hash) == ___zbr_gamesettings_fields.end())
        {
            return NULL;
        }
        return (zbr_gamesetting *)((char*)this + ___zbr_gamesettings_fields[name_hash]);
    }

    zbr_gamesetting* get_member(unsigned int name)
    {
        if (___zbr_gamesettings_fields.find(name) == ___zbr_gamesettings_fields.end())
        {
            return NULL;
        }
        return (zbr_gamesetting*)((char*)this + ___zbr_gamesettings_fields[name]);
    }

    void read(std::string b64v)
    {
        auto decoded = base64_decode(b64v);
        auto settings = (zbr_gamesettings*)decoded.data();
        
        if (settings->size > ZBR_GAMESETTINGS_SIZE)
        {
            ALOG("Tried to overrun buffer in zbr_gamesettings");
            return;
        }

        memcpy(this, settings, settings->size);
    }

    std::string encode()
    {
        this->size = ZBR_GAMESETTINGS_SIZE;
        return base64_encode((BYTE*)this, ZBR_GAMESETTINGS_SIZE);
    }
};

#define __MNAME(x) #x
#define MNAME(x) "pf" __MNAME(x)
#define PACKAGE_FIELD MNAME(__LINE__)

#define DYNMAP_BUF_SIZE 32 * 1024

struct transform_t
{
    scr_vec3_t origin;
    scr_vec3_t angles;
};

struct strtransform_t
{
    const char* origin;
    const char* angles;
};

#define ZBR_TABLE_MAGIC 0x7472627A
struct zbr_table
{
private:
    unsigned __int32 __allocrows;
    unsigned __int32 __alloccols;
    unsigned __int32 __rows;
    unsigned __int32 __cols;
    __int32* data;

public:

    zbr_table(int r, int c)
    {
        data = (__int32*)malloc(4 * (__rows = __allocrows = r) * (__cols = __alloccols = c));
    }

    zbr_table()
    {
        data = 0;
        init();
    }

    void free()
    {
        __allocrows = __alloccols = __rows = __cols = 0;
        if (data)
        {
            ::free(data);
        }
        data = 0;
    }

    void init()
    {
        if (data)
        {
            free();
        }
        data = (__int32*)malloc(4);
    }

    bool get_int(int r, int c, __int32& outval)
    {
        if (!data || r >= __rows || r < 0 || c >= __cols || c < 0)
        {
            outval = 0;
            return false;
        }
        outval = data[r * __alloccols + c];
        return true;
    }

    bool get_float(int r, int c, float& outval)
    {
        if (!data || r >= __rows || r < 0 || c >= __cols || c < 0)
        {
            outval = 0;
            return false;
        }
        outval = *(float*)(data + (r * __alloccols + c));
        return true;
    }

    bool set_int(int r, int c, __int32 val)
    {
        if (!data || r >= __rows || r < 0 || c < 0 || c >= __cols)
        {
            return false;
        }
        data[r * __alloccols + c] = val;
        return true;
    }

    bool set_float(int r, int c, float val)
    {
        if (!data || r >= __rows || r < 0 || c < 0 || c >= __cols)
        {
            return false;
        }
        *(float*)(data + (r * __alloccols + c)) = val;
        return true;
    }

    unsigned __int32 rows()
    {
        return __rows;
    }

    unsigned __int32 cols()
    {
        return __cols;
    }

    bool add_rows(unsigned __int32 count)
    {
        if (!data)
        {
            return false;
        }

        if (__rows + count <= __allocrows)
        {
            __rows += count;
            return true;
        }

        unsigned __int32 newrows = ((__allocrows + count) & ~15) + 16;

        __int32* buff = (__int32*)malloc(4 * newrows * __alloccols);
        memcpy(buff, data, 4 * __allocrows * __alloccols);

        ::free(data);
        data = buff;
        __allocrows = newrows;
        __rows += count;
        return true;
    }

    bool add_cols(unsigned __int32 count)
    {
        if (!data)
        {
            return false;
        }

        if (__cols + count <= __alloccols)
        {
            __cols += count;
            return true;
        }

        unsigned __int32 newcols = ((__alloccols + count) & ~15) + 16;

        __int32* buff = (__int32*)malloc(4 * __allocrows * newcols);

        for (int r = 0; r < __allocrows; r++)
        {
            memcpy(buff + r * newcols, data + r * __alloccols, 4 * __alloccols);
        }

        ::free(data);
        data = buff;
        __alloccols = newcols;
        __cols += count;
        return true;
    }

    bool condense()
    {
        if (!data)
        {
            return false;
        }

        if (__allocrows == __rows && __alloccols == __cols)
        {
            return true;
        }

        __int32* buff = (__int32*)malloc(4 * __rows * __cols);
        for (int r = 0; r < __rows; r++)
        {
            memcpy(buff + r * __cols, data + r * __alloccols, 4 * __cols);
        }

        ::free(data);
        data = buff;
        __allocrows = __rows;
        __alloccols = __cols;
        return true;
    }

    void ensure(unsigned int r, unsigned int c)
    {
        if (c > __cols)
        {
            add_cols(c - __cols);
        }
        if (r > __rows)
        {
            add_rows(r - __rows);
        }
    }

    void serialize(std::ofstream& ofs)
    {
        if (!data || !condense())
        {
            __int32 tmp = 0;
            ofs.write((const char*)&tmp, 4);
            ofs.write((const char*)&tmp, 4);
            return;
        }

        ofs.write((const char*)&__rows, 4);
        ofs.write((const char*)&__cols, 4);
        ofs.write((const char*)data, __rows * __cols * 4);
    }

    void deserialize(std::ifstream& ifs)
    {
        unsigned __int32 r = 0;
        unsigned __int32 c = 0;
        
        ifs.read((char*)&r, 4);
        ifs.read((char*)&c, 4);

        init();
        ensure(r, c);
        condense();

        ifs.read((char*)data, r * c * 4);
    }
};

struct zbr_wudev_selection
{
    char name[128];
    unsigned __int32 row;
    unsigned __int32 wdindex;
    unsigned __int32 numattacks;
    unsigned __int32 numattacksburst;
    unsigned __int32 numattackssustain;
    unsigned __int32 numattacksdtburst;
    unsigned __int32 numattacksdtsustain;
    bool simulation_active;
    bool simulating_burst;
    bool simulating_sustain;
    bool simulating_dtburst;
    bool simulating_dtsustain;
    bool isboltaction;
    bool ispressed = false;
    int key_event_pressed;
    int dwindex;
    bool bIsDualWield;
    unsigned __int32 oldfiretype;
};

enum zbr_wubcn
{
    WUBCN_HASHEDNAME = 0,
    WUBCN_BURST = 1,
    WUBCN_SUST = 2,
    WUBCN_DTBURST = 3,
    WUBCN_DTSUST = 4,
    WUBCN_DMGATT = 5,
    WUBCN_DMGATT2 = 6,
    WUBCN_DWNAME = 7,
    WUBCN_TBMP = 8,
    WUBCN_THMP = 9,
    WUBCN_THDMP = 10,
    WUBCN_GBMP = 11,
    WUBCN_GHMP = 12,
    WUBCN_GHDMP = 13,
    WUBCN_ROLE = 14,
    WUBCN_CLASS = 15,
    WUBCN_SIZE
};

enum zbr_weapon_roles
{
    ZWR_NONE = 0,
    ZWR_SIZE
};

enum zbr_wrcn
{
    WRCN_ROLEID = 0,
    WRCN_MP_NONE = 1,
    WRCN_MP_HELM = 2,
    WRCN_MP_HEAD = 3,
    WRCN_MP_NECK = 4,
    WRCN_MP_TORSO_UP = 5,
    WRCN_MP_TORSO_MI = 6,
    WRCN_MP_TORSO_LO = 7,
    WRCN_MP_RARMUP = 8,
    WRCN_MP_LARMUP = 9,
    WRCN_MP_RARMLO = 10,
    WRCN_MP_LARMLO = 11,
    WRCN_MP_RHAND = 12,
    WRCN_MP_LHAND = 13,
    WRCN_MP_RLEGU = 14,
    WRCN_MP_LLEGU = 15,
    WRCN_MP_RLEGL = 16,
    WRCN_MP_LLEGL = 17,
    WRCN_MP_RFOOT = 18,
    WRCN_MP_LFOOT = 19,
    WRCN_MP_GUN = 20,
    WRCN_MP_SHIELD = 21,
    WRCN_RANGE1 = 22,
    WRCN_RANGE2 = 23,
    WRCN_RANGE3 = 24,
    WRCN_MAXRANGE = 25,
    WRCN_SIZE
};

enum zbr_weapon_classes
{
    ZWC_NONE = 0,
    ZWC_SIZE
};

enum zbr_wccn
{
    WCCN_CLASSID = 0,
    WCCN_BMP = 1,
    WCCN_HMP = 2,
    WCCN_HDMP = 3,
    WCCN_RANGE1 = 4,
    WCCN_RANGE2 = 5,
    WCCN_RANGE2MP = 6,
    WCCN_RANGE3 = 7,
    WCCN_RANGE3MP = 8,
    WCCN_MAXRANGE = 9,
    WCCN_MAXRANGEMP = 10,
    WCCN_SIZE
};

enum hitLocation_t
{
    HITLOC_NONE = 0x0,
    HITLOC_HELMET = 0x1,
    HITLOC_HEAD = 0x2,
    HITLOC_NECK = 0x3,
    HITLOC_TORSO_UPR = 0x4,
    HITLOC_TORSO_MID = 0x5,
    HITLOC_TORSO_LWR = 0x6,
    HITLOC_R_ARM_UPR = 0x7,
    HITLOC_L_ARM_UPR = 0x8,
    HITLOC_R_ARM_LWR = 0x9,
    HITLOC_L_ARM_LWR = 0xA,
    HITLOC_R_HAND = 0xB,
    HITLOC_L_HAND = 0xC,
    HITLOC_R_LEG_UPR = 0xD,
    HITLOC_L_LEG_UPR = 0xE,
    HITLOC_R_LEG_LWR = 0xF,
    HITLOC_L_LEG_LWR = 0x10,
    HITLOC_R_FOOT = 0x11,
    HITLOC_L_FOOT = 0x12,
    HITLOC_GUN = 0x13,
    HITLOC_SHIELD = 0x14,
    HITLOC_NUM = 0x15
};

struct zbr_weapon_mod_table
{
    float headmod;
    float bodymod;
    float hdmod;
    float hitloc[HITLOC_NUM];
    __int32 _class;
    __int32 _role;

    zbr_weapon_mod_table()
    {
        headmod = 1.0;
        bodymod = 1.0;
        hdmod = 1.0;
        _class = 7;
        _role = 47;

        for (int i = 0; i < HITLOC_NUM; i++)
        {
            hitloc[i] = 1.0;
        }
    }
};

namespace zbr
{
    extern zbr_lobby_state lobbystate;
    extern zbr_game_state gamestate;

    bool is_duos();

    bool package_lobbystate(LobbyMsg* msg, unsigned char& no_reply, unsigned __int32 target_index);
    void handle_lobbystate(LobbyMsg* msg);
    void handle_clientreliable(LobbyMsg* msg);
    void handle_emoterpc(LobbyMsg* msg);
    void update_lobbystate_character_array();
    bool package_clientreliable(LobbyMsg* msg, zbr_client_reliable& reliable);
    bool package_clientemoterpc(LobbyMsg* msg, int& what, unsigned int& whoami);
    void send_emote_to_vm(unsigned int who, int what);
    void send_client_reliable();
    void send_characters_to_vm();
    void populate_cosmetics(zbr_cosmetics_data& data);

    void damage3d_push_event(int x, int y, int z, int amount, int repmask, int damage_type);
    void damage3d_handle_snapshot(__int32 controller_index, damage3d_event* events, unsigned int count);
    void damage3d_get_events(damage3d_event* events, unsigned int &count, int clientIndex);
    void damage3d_pack_origin(int16_t x, int16_t y, int16_t z, char* pos_buff);
    void damage3d_unpack_origin(const char* text, float* outBuff);

    namespace teams
    {
        extern std::unordered_map<int, int> team_counts;
        void reset();
        void autobalance();
        void update_requested_team(__int64 player, int team);
        int get_requested_team(__int64 player);
        int get_free_team();
        void update_team_counts();
    }

    namespace stats
    {
        extern ZBR_HND_STATS next_handle;
        extern std::unordered_map<ZBR_HND_STATS, zbr_stats_buffer> buffers;

        // use externally
        ZBR_HND_STATS create_buffer(); // create buffer and get handle to it
        bool assign_buffer(ZBR_HND_STATS hnd_buff, __int64 xuid); // assign a buffer to a player based on their xuid. if the buffer has too many owners or is an error buffer, return false
        void mark_buffer_dirty(ZBR_HND_STATS hnd_buff); // buffer modified, useful for pushing to disk when needed
        __int32 load_from_raw(const char* buffer, __int32 buff_size, ZBR_HND_STATS& out_handle); // call load_from_raw, then assign_buffer(current_xuid). if assign_buffer fails, do something. if buffer is dirty after, may need to do something too.
        __int32 save_to_raw(ZBR_HND_STATS hnd_buff, char* buffer, __int32 buff_size); // will save buffer to disk after signing and validating it. do not save without validating because re-signing allows attackers to call save function with invalid data.

        // use internally
        __int32 get_stat_size(ZBR_STAT_INDEX stat_type);
        void init_stat_in_buffer(zbr_stat_pair* stat, ZBR_STAT_INDEX stat_type);
        __int32 get_stat_in_buffer(ZBR_HND_STATS hnd_buff, ZBR_STAT_INDEX stat_type, zbr_stat_pair*& stat_pointer);
        __int32 resize_buffer(ZBR_HND_STATS hnd_buff, unsigned __int32 delta);
        void rolling_symmetrical_encrypt(char* buffer, __int32 buff_size);
        __int32 validate_stats_buffer(ZBR_HND_STATS hnd_buff);
        __int32 update_checksums(ZBR_HND_STATS hnd_buff, bool skip_validation);
    }

    namespace zone
    {
        extern unsigned __int32 __DEBUG__;
        extern unsigned __int32 loading_custom_zone;
        extern unsigned __int32 unloading_custom_zone;
        extern bool should_load_cc;
        void load_custom_from_disk(const char* name, int flags);
        void extend_xasset_pool(AssetPool pool, int num_to_add);
        void load_custom_assets_initial();
        bool move_initial_content();
        int lhascontent(void* lua_state);
        int get_zone_id(int contentid);
        void load_bg_cache(int inst, int index);
        void expand_sounds();
    }

    namespace fs
    {
        bool exists(const char* filename);
    }

    namespace characters
    {
        extern bool enabled;
        int get_character_index(__int64 xuid); // HOST ONLY
        int get_selected_character(); // CLIENT ONLY
        void on_character_changed(); // CLIENT only
        void send_emote_rpc(int emote); // CLIENT ONLY
    }

    namespace profile
    {
        extern bool profile_initialized;
        extern bool profile_flush_failed;
        extern zbr_profile_vars profile;
        bool profile_init();
        bool profile_load();
        bool profile_flush();
        int lget(void* lua_state);
        int lset(void* lua_state);
        __int32 get_int32(unsigned __int32 hash);
        bool using_damage_numbers();
    }

    namespace network
    {
        extern std::vector<void*> ___callbacks;
        void init();
        DWORD WINAPI ___worker(_In_ LPVOID lpParameter);
        void ___register_callback(void* cb);
    }

    namespace testing
    {
        void dotests();
    }

    // at some point we need to be able to have players login, have a playercount, etc.
    // we also need to be able to track gameids, etc.

    namespace gamesettings
    {
        extern bool using_custom_settings;
        void init();
        void ___run_network_frame();
        extern zbr_gamesettings settings;
        extern zbr_gamesettings custom_settings;
        void cache();
        void on_gametype_changed();
        bool load(zbr_gamesettings& storage, const char* path);
        int lget(void* lua_state);
        int lset(void* lua_state);
        zbr_gamesettings* active_settings();

        // this stuff will have to wait until we have logins and steamauth
        // we need some way to deploy certain commands during live games; especially during tournaments or events.
        // we could, in fact, setup this in combination with the gamesettings system such that we deploy 'gameinfo' { settingsvers, pendingcmds, etc.}
        // we could deploy hotfix scripts (gsc and lua)
        // we could deploy things like game messages and cbufs

        void make_hunted(zbr_gamesettings& out_settings);
    }

    void dvar_bypass_writeable(bool writeable);
    int lget_buildid(void* state);
    int lcheck_updates(void* state);

    namespace dynamicmap
    {
        extern char dynmapstr[DYNMAP_BUF_SIZE];
        extern unsigned __int32 current_dyn_map;
        extern unsigned __int32 current_dyn_map_cm;
        extern unsigned __int32 current_dyn_map_gfx;
        
        extern std::vector<cStaticModel_s> static_models;
        extern std::vector<GfxStaticModelDrawInst> static_models_gfx;

        extern std::vector<transform_t> mystery_boxes;
        extern std::vector<strtransform_t> pap_locations;
        extern unsigned __int32 current_dyn_map_int;
        void prepare();
        bool prepare_ents(unsigned __int32 mapname);
        bool prepare_cm(unsigned __int32 mapname);
        bool prepare_gfx(unsigned __int32 mapname);
        void create_pap(const char* origin, const char* angles);
        void create_box_mapent(scr_vec3_t origin, scr_vec3_t angles);
        void create_box_sm(scr_vec3_t origin, scr_vec3_t angles);
        void create_box_gfx(scr_vec3_t origin, scr_vec3_t angles);
        void create_sm(scr_vec3_t origin, scr_vec3_t angles, __int32 contents, const char* xmodel, float scale, __int32 targetname);
        void create_gfx_sm(scr_vec3_t origin, scr_vec3_t angles, const char* xmodel, float scale, __int32 targetname);
        void create_static_misc_model(scr_vec3_t origin, scr_vec3_t angles, const char* model, const char* modelscale);
        void create_formatted_vec3(scr_vec3_t vec);
        void mod_static_models();
        void mod_gfx_static_models();
    }

    namespace table
    {
        int load_from_disk(const char* path, zbr_table& data);
        int write_to_disk(const char* path, zbr_table& data);
        bool csv_to_table(const char* id, zbr_table& table);
        bool table_to_csv(const char* id, zbr_table& table, const char** headers);
    }

    namespace util
    {
        void rotate_points(scr_vec3_t angles, scr_vec3_t* const & points, int count);
        scr_vec3_t rotate_point(scr_vec3_t angles, scr_vec3_t point);
    }

    namespace weapons
    {
        extern zbr_table bal_table;
        extern zbr_table class_table;
        extern zbr_table role_table;
        extern zbr_wudev_selection selection;
        extern std::unordered_map<unsigned __int16, zbr_weapon_mod_table> mods;
        bool load_shared(bool allow_create);
        bool load(const char* id, bool allow_create);
        bool postload();
        bool name_to_row(const char* name, unsigned __int32& row);
        void add_weapon(__int64 index, unsigned __int32& row);
        void debug_select(__int64 index);
        void debug_draw();
        void dev_save(const char* name);
        void debug_simulate(bool enabled, bool lh);
        void debug_simulate_fired(__int64 gent, int gametime, int _event, int shotcount);
        void debug_simulate_frame();
        void update_weapon_stats();
    }

    const char* get_map_bonus_ents();
}

#endif