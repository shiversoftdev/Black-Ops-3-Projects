#include "zbr.h"
#include "Offsets.h"
#include "mh.h"
#include "protection.h"
#include "DiscordRP.h"
#include "builtins.h"
#include "lua\hapi.h"
#include "lua\lapi.h"
#include "lua\lstate.h"
#include "gscu_hashing.h"

// sub_2C53864
// 2C46A18 (global death functions)??

// r_autoLodScale
// r_fog, r_fog_disable -- anticheat should not let this be set ever
// sm_showTris, r_showTris, r_norefresh, r_dobjLimit, r_brushLimit, r_modelLimit

// r_showTris kinda cool

#if !IS_PATCH_ONLY

#include "curl/curl.h"

std::unordered_map<__int32, __int32> ___zbr_gamesettings_fields;
bool ___zbr_gamesettings_init = false;
zbr_lobby_state zbr::lobbystate{};
zbr_game_state zbr::gamestate{};
zbr_gamesettings zbr::gamesettings::settings;
zbr_gamesettings zbr::gamesettings::custom_settings;
std::unordered_map<int, int> zbr::teams::team_counts{};
ZBR_HND_STATS zbr::stats::next_handle{0};
std::unordered_map<ZBR_HND_STATS, zbr_stats_buffer> zbr::stats::buffers{};
bool zbr::characters::enabled = false;
bool zbr::profile::profile_initialized = false;
bool zbr::profile::profile_flush_failed = false;
zbr_profile_vars zbr::profile::profile;
char lm_buff[0x20000];

#define Dvar_SetFromStringByName(dvar, value, createdefault) ((void(__fastcall*)(const char*, const char*, bool))PTR_Dvar_SetFromStringByName)(dvar, value, createdefault)

bool zbr::fs::exists(const char* filename)
{
	if (!std::filesystem::exists(filename))
	{
		return false;
	}
	if (INVALID_FILE_ATTRIBUTES == GetFileAttributes(filename) && GetLastError() == ERROR_FILE_NOT_FOUND)
	{
		return false;
	}
	return true;
}

bool zbr::is_duos() // yes this is retarded, I am not changing it.
{
	return lobbystate.team_size >= 2;
}

auto FIELD_IS_DUOS = PACKAGE_FIELD;
auto FIELD_LOBBYKEY = PACKAGE_FIELD;
auto FIELD_NOREPLY = PACKAGE_FIELD;
auto FIELD_CHARACTER0 = PACKAGE_FIELD;
auto FIELD_CHARACTER1 = PACKAGE_FIELD;
auto FIELD_CHARACTER2 = PACKAGE_FIELD;
auto FIELD_CHARACTER3 = PACKAGE_FIELD;
auto FIELD_CHARACTER4 = PACKAGE_FIELD;
auto FIELD_CHARACTER5 = PACKAGE_FIELD;
auto FIELD_CHARACTER6 = PACKAGE_FIELD;
auto FIELD_CHARACTER7 = PACKAGE_FIELD;
auto FIELD_WHOAMI = PACKAGE_FIELD;
auto FIELD_GAMETYPE = PACKAGE_FIELD;
auto FIELD_COSMETIC0 = PACKAGE_FIELD;
auto FIELD_COSMETIC1 = PACKAGE_FIELD;
auto FIELD_COSMETIC2 = PACKAGE_FIELD;
auto FIELD_COSMETIC3 = PACKAGE_FIELD;
auto FIELD_COSMETIC4 = PACKAGE_FIELD;
auto FIELD_COSMETIC5 = PACKAGE_FIELD;
auto FIELD_COSMETIC6 = PACKAGE_FIELD;
auto FIELD_COSMETIC7 = PACKAGE_FIELD;

// BUG: characterlist[0] is not populated by the host
bool zbr::package_lobbystate(LobbyMsg* msg, unsigned char& no_reply, unsigned __int32 target_index)
{
	zbr_lobby_state tmp = lobbystate;
	tmp.is_dirty = true;
	tmp.whoami = target_index;

	// do this so we dont unpackage bad data
	bool res = Protection::LobbyMsgRW_PackageUChar(msg, FIELD_IS_DUOS, (char*)&tmp.team_size);
	res = res && Protection::LobbyMsgRW_PackageUInt(msg, FIELD_LOBBYKEY, (unsigned int*)&tmp.lobby_key);
	res = res && Protection::LobbyMsgRW_PackageUChar(msg, FIELD_NOREPLY, (char*)&no_reply);
	
	res = res && Protection::LobbyMsgRW_PackageUInt(msg, FIELD_CHARACTER0, (unsigned int*)&tmp.characterlist[0]);
	res = res && Protection::LobbyMsgRW_PackageUInt(msg, FIELD_CHARACTER1, (unsigned int*)&tmp.characterlist[1]);
	res = res && Protection::LobbyMsgRW_PackageUInt(msg, FIELD_CHARACTER2, (unsigned int*)&tmp.characterlist[2]);
	res = res && Protection::LobbyMsgRW_PackageUInt(msg, FIELD_CHARACTER3, (unsigned int*)&tmp.characterlist[3]);
	res = res && Protection::LobbyMsgRW_PackageUInt(msg, FIELD_CHARACTER4, (unsigned int*)&tmp.characterlist[4]);
	res = res && Protection::LobbyMsgRW_PackageUInt(msg, FIELD_CHARACTER5, (unsigned int*)&tmp.characterlist[5]);
	res = res && Protection::LobbyMsgRW_PackageUInt(msg, FIELD_CHARACTER6, (unsigned int*)&tmp.characterlist[6]);
	res = res && Protection::LobbyMsgRW_PackageUInt(msg, FIELD_CHARACTER7, (unsigned int*)&tmp.characterlist[7]);

	res = res && Protection::LobbyMsgRW_PackageUInt64(msg, FIELD_COSMETIC0, (unsigned __int64*)&tmp.cosmetics[0]);
	res = res && Protection::LobbyMsgRW_PackageUInt64(msg, FIELD_COSMETIC1, (unsigned __int64*)&tmp.cosmetics[1]);
	res = res && Protection::LobbyMsgRW_PackageUInt64(msg, FIELD_COSMETIC2, (unsigned __int64*)&tmp.cosmetics[2]);
	res = res && Protection::LobbyMsgRW_PackageUInt64(msg, FIELD_COSMETIC3, (unsigned __int64*)&tmp.cosmetics[3]);
	res = res && Protection::LobbyMsgRW_PackageUInt64(msg, FIELD_COSMETIC4, (unsigned __int64*)&tmp.cosmetics[4]);
	res = res && Protection::LobbyMsgRW_PackageUInt64(msg, FIELD_COSMETIC5, (unsigned __int64*)&tmp.cosmetics[5]);
	res = res && Protection::LobbyMsgRW_PackageUInt64(msg, FIELD_COSMETIC6, (unsigned __int64*)&tmp.cosmetics[6]);
	res = res && Protection::LobbyMsgRW_PackageUInt64(msg, FIELD_COSMETIC7, (unsigned __int64*)&tmp.cosmetics[7]);

	res = res && Protection::LobbyMsgRW_PackageUInt(msg, FIELD_WHOAMI, (unsigned int*)&tmp.whoami);
	res = res && Protection::LobbyMsgRW_PackageString(msg, FIELD_GAMETYPE, tmp.gamemode, ZBR_GAMEMODE_MAXLEN);

	if (res)
	{
		lobbystate = tmp;
	}

	return res;
}

void zbr::send_characters_to_vm()
{
	if (!*(char*)OFF_s_runningUILevel)
	{
		return;
	}

	// lui event that we have recieved a new lobbystate
	// if frontend, we will notify the script of the changes and it can go through and query for each character index
	LuaScopedEventThrowaway _this{};

	((void(__fastcall*)(LuaScopedEventThrowaway&, __int64, int, ...))PTR_LuaScopedEvent_ctor)(_this, *(__int64*)PTR_UI_luaVM, 2, "CoD", "LobbyCharacterEvent");

	if (!_this.fixed[0x35])
	{
		((void(__fastcall*)(const char*, int, __int64))PTR_Lua_SetTableInt)("whoami", lobbystate.whoami, *(__int64*)&_this);
		((void(__fastcall*)(const char*, int, __int64))PTR_Lua_SetTableInt)("c0", lobbystate.characterlist[0], *(__int64*)&_this);
		((void(__fastcall*)(const char*, int, __int64))PTR_Lua_SetTableInt)("c1", lobbystate.characterlist[1], *(__int64*)&_this);
		((void(__fastcall*)(const char*, int, __int64))PTR_Lua_SetTableInt)("c2", lobbystate.characterlist[2], *(__int64*)&_this);
		((void(__fastcall*)(const char*, int, __int64))PTR_Lua_SetTableInt)("c3", lobbystate.characterlist[3], *(__int64*)&_this);
		((void(__fastcall*)(const char*, int, __int64))PTR_Lua_SetTableInt)("c4", lobbystate.characterlist[4], *(__int64*)&_this);
		((void(__fastcall*)(const char*, int, __int64))PTR_Lua_SetTableInt)("c5", lobbystate.characterlist[5], *(__int64*)&_this);
		((void(__fastcall*)(const char*, int, __int64))PTR_Lua_SetTableInt)("c6", lobbystate.characterlist[6], *(__int64*)&_this);
		((void(__fastcall*)(const char*, int, __int64))PTR_Lua_SetTableInt)("c7", lobbystate.characterlist[7], *(__int64*)&_this);
	}

	_this.fixed[0x35] = 1;
	((void(__fastcall*)(LuaScopedEventThrowaway&))PTR_LuaScoredEvent_dtor)(_this);
}

void send_gametype_to_lobbyvm()
{
	Dvar_SetFromStringByName("zbr_gametype", zbr::lobbystate.gamemode, true);

	if (!*(char*)OFF_s_runningUILevel)
	{
		return;
	}

	LuaScopedEventThrowaway _this{};

	((void(__fastcall*)(LuaScopedEventThrowaway&, __int64, int, ...))PTR_LuaScopedEvent_ctor)(_this, *(__int64*)PTR_UI_luaVM, 2, "CoD", "GametypeUpdateEvent");

	if (!_this.fixed[0x35])
	{
	}

	_this.fixed[0x35] = 1;
	((void(__fastcall*)(LuaScopedEventThrowaway&))PTR_LuaScoredEvent_dtor)(_this);
}

void zbr::handle_lobbystate(LobbyMsg* msg)
{
	unsigned char no_reply = 0;
	if (zbr::package_lobbystate(msg, no_reply, lobbystate.whoami))
	{
		// we good ig
		
		send_characters_to_vm();
		send_gametype_to_lobbyvm();

		if (!no_reply)
		{
			send_client_reliable(); // we got info from the host, lets let them know about our info
		}
	}
}

auto FIELD_HASCHARACTERCONTENT = PACKAGE_FIELD;
auto FIELD_SELECTEDCHARACTER = PACKAGE_FIELD;
auto FIELD_WHO = PACKAGE_FIELD;
auto FIELD_SELECTEDWEAPON = PACKAGE_FIELD;
auto FIELD_COSMETICS = PACKAGE_FIELD;

bool zbr::package_clientreliable(LobbyMsg* msg, zbr_client_reliable& reliable)
{
	bool res = Protection::LobbyMsgRW_PackageUInt(msg, FIELD_LOBBYKEY, (unsigned int*)&reliable.lobby_key);

	if (!res || reliable.lobby_key != lobbystate.lobby_key)
	{
		return false;
	}

	res = Protection::LobbyMsgRW_PackageUChar(msg, FIELD_HASCHARACTERCONTENT, (char*)&reliable.has_content);
	res = res && Protection::LobbyMsgRW_PackageInt(msg, FIELD_SELECTEDCHARACTER, (__int32*)&reliable.selected_character);
	res = res && Protection::LobbyMsgRW_PackageXuid(msg, FIELD_WHO, (unsigned __int64*)&reliable.who);
	res = res && Protection::LobbyMsgRW_PackageInt(msg, FIELD_SELECTEDWEAPON, (__int32*)&reliable.selected_weapon);
	res = res && Protection::LobbyMsgRW_PackageUInt64(msg, FIELD_SELECTEDWEAPON, (unsigned __int64*)&reliable.cosmetics);
	return res;
}

void zbr::handle_clientreliable(LobbyMsg* msg)
{
	if (!DiscordRP::AmIHost())
	{
		return;
	}

	zbr_client_reliable reliable{ 0 };
	if (zbr::package_clientreliable(msg, reliable))
	{
		zbr::gamestate.zbr_character_index[reliable.who] = reliable.has_content ? reliable.selected_character : -1;
		zbr::gamestate.spawn_weapons[reliable.who] = reliable.selected_weapon;
		zbr::gamestate.zbr_cosmetics[reliable.who] = reliable.cosmetics;
		/*char xuid[32]{ 0 };
		sprintf(xuid, "%llu", reliable.who);*/

		zbr::update_lobbystate_character_array();
		zbr::send_characters_to_vm();

		/*GSCBuiltins::Scr_AddInt(0, zbr::gamestate.zbr_character_index[reliable.who]);
		GSCBuiltins::Scr_AddString(0, xuid);*/
		// TODO
		// can cause a crash in frontend
		// Scr_NotifyLevelWithArgs(0, FNV32("zbr_character_update"), 2);
	}
}

void zbr::handle_emoterpc(LobbyMsg* msg)
{
	/*if (!DiscordRP::AmIHost())
	{
		return;
	}*/

	zbr_client_reliable reliable{ 0 };
	int what;
	unsigned int who;
	if (zbr::package_clientemoterpc(msg, what, who))
	{
		if (DiscordRP::AmIHost())
		{
			send_emote_to_vm(who, what);
			DiscordRP::ReplicateEmoteRequest(who, what);
		}
		else
		{
			send_emote_to_vm(who, what);
		}

		/*GSCBuiltins::Scr_AddInt(0, zbr::gamestate.zbr_character_index[reliable.who]);
		GSCBuiltins::Scr_AddString(0, xuid);*/
		// TODO
		// can cause a crash in frontend
		// Scr_NotifyLevelWithArgs(0, FNV32("zbr_character_update"), 2);
	}
}

void zbr::send_emote_to_vm(unsigned int who, int what)
{
	if (who == zbr::lobbystate.whoami)
	{
		return;
	}

	if (!who)
	{
		who = zbr::lobbystate.whoami;
	}

	if (!*(char*)OFF_s_runningUILevel)
	{
		return;
	}

	LuaScopedEventThrowaway _this{};

	((void(__fastcall*)(LuaScopedEventThrowaway&, __int64, int, ...))PTR_LuaScopedEvent_ctor)(_this, *(__int64*)PTR_UI_luaVM, 2, "CoD", "LobbyCharacterEmote");

	if (!_this.fixed[0x35])
	{
		((void(__fastcall*)(const char*, int, __int64))PTR_Lua_SetTableInt)("who", who, *(__int64*)&_this);
		((void(__fastcall*)(const char*, int, __int64))PTR_Lua_SetTableInt)("what", what, *(__int64*)&_this);
	}

	_this.fixed[0x35] = 1;
	((void(__fastcall*)(LuaScopedEventThrowaway&))PTR_LuaScoredEvent_dtor)(_this);
}

void zbr::populate_cosmetics(zbr_cosmetics_data& data)
{
	data = zbr_cosmetics_data();
	data.hat = zbr::profile::get_int32(CONST32(ZBR_STRINGIFY(PROFILE_VAR_HAT)));
}

void zbr::update_lobbystate_character_array()
{
	for (int i = 0; i < 8; i++)
	{
		lobbystate.characterlist[i] = ZBR_CHARACTER_INACTIVE;
	}

	LobbyType sessionType = LobbyType::LOBBY_TYPE_AUTO;

	if (Protection::LobbySession_GetControllingLobbySession(LOBBY_MODULE_CLIENT))
	{
		sessionType = LOBBY_TYPE_GAME;
	}
	else
	{
		sessionType = LOBBY_TYPE_PRIVATE;
	}

	const auto session = Protection::LobbySession_GetSession(sessionType);
	__int64 xuid = 0;

	for (int i = 0; i < 8; i++)
	{
		const auto client = Protection::LobbySession_GetClientByClientNum(session, i);
		if (client->activeClient)
		{
			const auto adr = Protection::LobbySession_GetClientNetAdrByIndex(sessionType, i);
			xuid = client->activeClient->fixedClientInfo.xuid;

			if (xuid == Offsets::GetXUID())
			{
				lobbystate.characterlist[i] = zbr::characters::get_selected_character();
				zbr::populate_cosmetics(lobbystate.cosmetics[i]);
				continue;
			}

			if (zbr::gamestate.zbr_character_index.find(xuid) != zbr::gamestate.zbr_character_index.end())
			{
				lobbystate.characterlist[i] = zbr::gamestate.zbr_character_index[xuid];
				lobbystate.cosmetics[i] = zbr::gamestate.zbr_cosmetics[xuid];
			}
			else
			{
				lobbystate.characterlist[i] = 1;
				lobbystate.cosmetics[i] = zbr_cosmetics_data();
			}
		}
	}

	DiscordRP::RepLobbystateReal(true);
}

void zbr::send_client_reliable()
{
	LobbyMsg lobbyMsg{ 0 };
	zbr_client_reliable reliable{ 0 };
	reliable.lobby_key = lobbystate.lobby_key;
	reliable.has_content = (unsigned char)zbr::characters::enabled;
	reliable.selected_character = zbr::characters::get_selected_character();
	reliable.who = **(INT64**)s_playerData_ptr;
	reliable.selected_weapon = zbr::profile::get_int32(CONST32(ZBR_STRINGIFY(PROFILE_VAR_SPAWNWEAPON)));
	zbr::populate_cosmetics(reliable.cosmetics);

	memset(lm_buff, 0, sizeof(lm_buff));

	if (Protection::LobbyMsgRW_PrepWriteMsg(&lobbyMsg, lm_buff, sizeof(lm_buff), MESSAGE_TYPE_ZBR_CLIENTRELIABLE) && zbr::package_clientreliable(&lobbyMsg, reliable))
	{
		__int32 msgConfig[0x30]{ 0 }; // way bigger than needed but im not figuring out this struct
		msgConfig[0] = getframetime();
		msgConfig[1] = 1;
		msgConfig[2] = 13;
		auto lobby_session = (__int64)Protection::LobbySession_GetSession(1);
		__int32 channel = LobbyNetChan_GetLobbyChannel(*(unsigned __int32*)(lobby_session + 4), 3);
		LobbyMsgTransport_SendToHostReliably(0, lobby_session, LOBBY_MODULE_HOST, &lobbyMsg.msg, (MsgType)lobbyMsg.msgType, channel, msgConfig);
	}
}

void zbr::damage3d_push_event(int x, int y, int z, int amount, int repmask, int damage_type)
{
	damage3d_event damage{};

	if (amount > 8388607)
	{
		amount = 8388607;
	}
	
	if (amount < -8388608)
	{
		amount = -8388608;
	}

	damage.amount.set(amount);
	damage.x = (int16_t)x;
	damage.y = (int16_t)y;
	damage.z = (int16_t)z;
	damage.damage_type = damage_type;
	damage.repmask = repmask;
	gamestate.damage3d_pending.push_back(damage);
}

void zbr::damage3d_handle_snapshot(__int32 controller_index, damage3d_event* events, unsigned int count)
{
	if (!zbr::profile::using_damage_numbers())
	{
		return;
	}

	// push info to LUI
	for (unsigned int i = 0; i < count; i++)
	{
		LuaScopedEventThrowaway _this{};
		auto damage_event = events[i];

		((void(__fastcall*)(LuaScopedEventThrowaway&, __int64, int, ...))PTR_LuaScopedEvent_ctor)(_this, *(__int64*)PTR_UI_luaVM, 2, "CoD", "Damage3dEvent");

		if (!_this.fixed[0x35])
		{
			// 2 bytes, 2 chars per byte, 3 offsets, 1 null character
			char pos_buff[2 * 2 * 3 + 1]{0};
			damage3d_pack_origin(damage_event.x, damage_event.y, damage_event.z, pos_buff);
			//Offsets::Log("DAMAGE EVENT: (%d, %d, %d) -> %s", (int)damage_event.x, (int)damage_event.y, (int)damage_event.z, pos_buff);

			((void(__fastcall*)(const char*, int, __int64))PTR_Lua_SetTableInt)("client", damage_event.repmask, *(__int64*)&_this);
			((void(__fastcall*)(const char*, const char*, __int64))PTR_Lua_SetTableString)("packed_origin", pos_buff, *(__int64*)&_this);
			((void(__fastcall*)(const char*, int, __int64))PTR_Lua_SetTableInt)("amount", damage_event.amount.get(), *(__int64*)&_this);
			((void(__fastcall*)(const char*, int, __int64))PTR_Lua_SetTableInt)("type", damage_event.damage_type, *(__int64*)&_this);
		}
		
		_this.fixed[0x35] = 1;
		((void(__fastcall*)(LuaScopedEventThrowaway&))PTR_LuaScoredEvent_dtor)(_this);
	}
}

void zbr::damage3d_get_events(damage3d_event* events, unsigned int& count, int clientIndex)
{
	// 1. add pending events (up to max count) and then remove its mask index
	count = 0;
	for (int i = 0; i < gamestate.damage3d_pending.size() && count < ZBR_MAX_3DDAMAGE_EVENTS; i++)
	{
		damage3d_event* curr = &gamestate.damage3d_pending.at(i);
		
		if (!(curr->repmask & (1 << clientIndex)))
		{
			continue;
		}

		curr->repmask &= ~(1 << clientIndex);
		events[count++] = *curr;
	}

	// 2. remove stale events from the queue
	int newcount = 0;
	for (int i = 0; i < gamestate.damage3d_pending.size(); i++)
	{
		if (!gamestate.damage3d_pending.at(i).repmask)
		{
			continue;
		}

		if (i == newcount)
		{
			newcount++;
			continue;
		}

		gamestate.damage3d_pending.at(newcount++) = gamestate.damage3d_pending.at(i);
	}

	while (newcount < gamestate.damage3d_pending.size())
	{
		gamestate.damage3d_pending.pop_back();
	}
}

#define BYTE_LOW_TO_CHAR(x) (unsigned char)((unsigned int)((x) & 0xF) + (unsigned int)'A')
#define BYTE_TOP_TO_CHAR(x) (unsigned char)((unsigned int)(((x) >> 4) & 0xF) + (unsigned int)'A')
void zbr::damage3d_pack_origin(int16_t x, int16_t y, int16_t z, char* pos_buff)
{
	pos_buff[0] = BYTE_LOW_TO_CHAR(x);
	pos_buff[1] = BYTE_TOP_TO_CHAR(x);
	pos_buff[2] = BYTE_LOW_TO_CHAR(x >> 8);
	pos_buff[3] = BYTE_TOP_TO_CHAR(x >> 8);

	pos_buff[4] = BYTE_LOW_TO_CHAR(y);
	pos_buff[5] = BYTE_TOP_TO_CHAR(y);
	pos_buff[6] = BYTE_LOW_TO_CHAR(y >> 8);
	pos_buff[7] = BYTE_TOP_TO_CHAR(y >> 8);

	pos_buff[8] = BYTE_LOW_TO_CHAR(z);
	pos_buff[9] = BYTE_TOP_TO_CHAR(z);
	pos_buff[10] = BYTE_LOW_TO_CHAR(z >> 8);
	pos_buff[11] = BYTE_TOP_TO_CHAR(z >> 8);

	pos_buff[12] = 0;
}

#define INT16_FROM_TEXT(s) (int16_t)(((unsigned int)*(s) - (unsigned int)'A') + (((unsigned int)*(s + 1) - (unsigned int)'A') << 4) + (((unsigned int)*(s + 2) - (unsigned int)'A') << 8) + (((unsigned int)*(s + 3) - (unsigned int)'A') << 12))
void zbr::damage3d_unpack_origin(const char* text, float* outBuff)
{
	outBuff[0] = (float)INT16_FROM_TEXT(text);
	outBuff[1] = (float)INT16_FROM_TEXT(text + 4);
	outBuff[2] = (float)INT16_FROM_TEXT(text + 8);
}

MDT_Define_FASTCALL(PTR_Dvar_CanSetConfigDvar, Dvar_CanSetConfigDvar_hook, BOOL, ())
{
	return true;
}

MDT_Define_FASTCALL(PTR_Dvar_ValueInDomain, Dvar_ValueInDomain_hook, BOOL, ())
{
	return true;
}

MDT_Define_FASTCALL(PTR_Dvar_CanChangeValue, Dvar_CanChangeValue_hook, BOOL, ())
{
	return true;
}

void zbr::dvar_bypass_writeable(bool writeable)
{
	VMP_EXTRA_LIGHT_START("Toggle writeable dvars");
	DetourTransactionBegin();
	DetourUpdateThread(GetCurrentThread());

	if (writeable)
	{
		MDT_Activate(Dvar_CanSetConfigDvar_hook);
		MDT_Activate(Dvar_ValueInDomain_hook);
		MDT_Activate(Dvar_CanChangeValue_hook);
	}
	else
	{
		MDT_Deactivate(Dvar_CanSetConfigDvar_hook);
		MDT_Deactivate(Dvar_ValueInDomain_hook);
		MDT_Deactivate(Dvar_CanChangeValue_hook);
	}
	DetourTransactionCommit();
	VMP_EXTRA_LIGHT_END();
}

void zbr::teams::reset()
{
	ALOG("RESETTING TEAMS"); // TODO
	gamestate.expected_teams.clear();
	update_team_counts();
}

void zbr::teams::autobalance()
{
	update_team_counts();

	if (lobbystate.team_size <= 1)
	{
		return;
	}

	std::vector<__int64> balance_players{};

	// 1. find all teams above capacity and drop members until the requirements are met
	for (int i = 1; i < TEAM_MAX + 1; i++)
	{
		if (i == 3)
		{
			continue;
		}

		if (team_counts[i] > lobbystate.team_size)
		{
			for (auto it = gamestate.expected_teams.begin(); it != gamestate.expected_teams.end() && (team_counts[i] > lobbystate.team_size); it++)
			{
				if (it->second == i)
				{
					balance_players.push_back(it->first);
					team_counts[i]--;
				}
			}
		}
	}

	for (auto it = balance_players.begin(); it != balance_players.end(); it++)
	{
		gamestate.expected_teams[*it] = -1;
		update_requested_team(*it, get_free_team());
	}

	// 2. find all players in the session that dont have expected teams and assign them
	auto lobbySession = ((__int64(__fastcall*)(__int32))PTR_LobbyHostData_GetSession)(1);
	for (int i = 0; i < 18; i++)
	{
		auto xuid = *(__int64*)(lobbySession + 248 + (i * 48));

		if (!xuid)
		{
			continue;
		}

		get_requested_team(xuid);
	}
}

void zbr::teams::update_requested_team(__int64 player, int team)
{
	if (team < 1 || team > TEAM_MAX)
	{
		team = 1;
	}
	gamestate.expected_teams[player] = team;
	update_team_counts();
}

int zbr::teams::get_requested_team(__int64 player)
{
	if (gamestate.expected_teams.find(player) == gamestate.expected_teams.end())
	{
		auto team = zbr::teams::get_free_team();
		update_requested_team(player, team);
		return team;
	}
	return gamestate.expected_teams[player];
}

int zbr::teams::get_free_team()
{
	if (lobbystate.team_size == 1)
	{
		return -1;
	}

	update_team_counts();

	auto expected = lobbystate.team_size;

	// first, try finding a partially full team

	for (int i = 1; i < TEAM_MAX + 1; i++)
	{
		if (i == 3)
		{
			continue;
		}
		if (team_counts[i] > 0 && team_counts[i] < expected)
		{
			return i;
		}
	}

	// now just find any empty team
	for (int i = 1; i < TEAM_MAX + 1; i++)
	{
		if (i == 3)
		{
			continue;
		}
		if (team_counts[i] < expected)
		{
			return i;
		}
	}

	return -1;
}

void zbr::teams::update_team_counts()
{
	auto lobbySession = ((__int64(__fastcall*)(__int32))PTR_LobbyHostData_GetSession)(1);

	team_counts.clear();
	for (int i = 1; i < TEAM_MAX + 1; i++)
	{
		if (i == 3)
		{
			continue;
		}
		team_counts[i] = 0;
	}
		
	if (!lobbySession)
	{
		return;
	}

	for (int i = 0; i < 18; i++)
	{
		auto xuid = *(__int64*)(lobbySession + 248 + (i * 48));

		if (!xuid)
		{
			continue;
		}

		if (gamestate.expected_teams.find(xuid) == gamestate.expected_teams.end())
		{
			continue;
		}

		if (team_counts.find(gamestate.expected_teams[xuid]) == team_counts.end())
		{
			team_counts[gamestate.expected_teams[xuid]] = 0;
		}

		team_counts[gamestate.expected_teams[xuid]]++;
	}
}

ZBR_HND_STATS zbr::stats::create_buffer()
{
	PROTECT_LIGHT_START();
	if (!zbr::stats::next_handle)
	{
		zbr::stats::next_handle = rand();
	}

	ZBR_HND_STATS handle = zbr::stats::next_handle;

	zbr::stats::buffers[handle] = zbr_stats_buffer();
	zbr::stats::buffers[handle].buff = (unsigned char*)malloc(ZBR_MAX_STATBUFF_SIZE);
	memset(zbr::stats::buffers[handle].buff, 0, ZBR_MAX_STATBUFF_SIZE);
	zbr::stats::buffers[handle].buff_size.set(ZBR_DEFAULT_STATBUFF_SIZE);
	zbr::stats::buffers[handle].version.set(ZBR_STATS_VERSION);

	auto first_stat = (zbr_stat_pair*)zbr::stats::buffers[handle].buff;
	init_stat_in_buffer(first_stat, ZBR_STAT_INFO);

	zbr::stats::next_handle++;
	return handle;
	PROTECT_LIGHT_END();
}

bool zbr::stats::assign_buffer(ZBR_HND_STATS hnd_buff, __int64 xuid)
{
	PROTECT_LIGHT_START();

	zbr_stat_pair* stat = NULL;
	if (!get_stat_in_buffer(hnd_buff, ZBR_STAT_XUID0, stat))
	{
		auto val = stat->value.xuid.get();
		if (!val)
		{
			stat->value.xuid.set(xuid);
			mark_buffer_dirty(hnd_buff);
			return true;
		}

		if (val == xuid)
		{
			return true;
		}
	}

	if (!get_stat_in_buffer(hnd_buff, ZBR_STAT_XUID1, stat))
	{
		auto val = stat->value.xuid.get();
		if (!val)
		{
			stat->value.xuid.set(xuid);
			mark_buffer_dirty(hnd_buff);
			return true;
		}

		if (val == xuid)
		{
			return true;
		}
	}

	if (!get_stat_in_buffer(hnd_buff, ZBR_STAT_XUID2, stat))
	{
		auto val = stat->value.xuid.get();
		if (!val)
		{
			stat->value.xuid.set(xuid);
			mark_buffer_dirty(hnd_buff);
			return true;
		}

		if (val == xuid)
		{
			return true;
		}
	}

	if (!get_stat_in_buffer(hnd_buff, ZBR_STAT_XUID3, stat))
	{
		auto val = stat->value.xuid.get();
		if (!val)
		{
			stat->value.xuid.set(xuid);
			mark_buffer_dirty(hnd_buff);
			return true;
		}

		if (val == xuid)
		{
			return true;
		}
	}

	return false;
	PROTECT_LIGHT_END();
}

void zbr::stats::mark_buffer_dirty(ZBR_HND_STATS hnd_buff)
{
	PROTECT_LIGHT_START();
	if (buffers.find(hnd_buff) == buffers.end())
	{
		return;
	}
	buffers[hnd_buff].dirty = true;
	update_checksums(hnd_buff, true);
	PROTECT_LIGHT_END();
}

__int32 zbr::stats::load_from_raw(const char* buffer, __int32 buff_size, ZBR_HND_STATS& out_handle)
{
	PROTECT_LIGHT_START();

	out_handle = NULL;
	if (buff_size > ZBR_MAX_RAWSIZE)
	{
		return ZBR_STATS_ERROR_BADBUFFER;
	}

	char mutable_buff[ZBR_MAX_RAWSIZE]{};
	memcpy(mutable_buff, buffer, buff_size);
	rolling_symmetrical_encrypt(mutable_buff, buff_size);
	if (*(__int64*)buffer != ZBR_STAT_BUFF_MAGIC)
	{
		return ZBR_STATS_ERROR_BADBUFFER;
	}

	auto _out_handle = create_buffer();
	auto stats = buffers[_out_handle];

	stats.version = *(fuzzy_int32*)(mutable_buff + 8);

	// do any repositioning or whatever here for new versions
	// zbr_stats_upgrade(stats)

	stats.buff_size = *(fuzzy_int32*)(mutable_buff + 8 + sizeof(fuzzy_int32));

	auto val = stats.buff_size.get();

	if (val <= 0 || val > ZBR_MAX_STATBUFF_SIZE)
	{
		return ZBR_STATS_ERROR_BADBUFFER;
	}

	memcpy(stats.buff, mutable_buff + 8 + sizeof(fuzzy_int32) + sizeof(fuzzy_int32), val);
	__int32 result = validate_stats_buffer(_out_handle);

	if (result)
	{
		return result;
	}

	out_handle = _out_handle;
	return 0;
	PROTECT_LIGHT_END();
}

/*
	stats buffer will have 3 integrity mechanisms
	1. checksum0: checksum over all stats except checksum0 and checksum1
	2. checksum1: checksum over all stats including checksum0
	3. authorization_key: 
		1. special key saved in stats buffer, 2 part key. half (public) stored in stats buffer, half (private) stored in steam cloud file for zbr (players\311210\.??)
		2. keys file will have kvps only, containing XUID and the other key pair half (private). 
*/

__int32 zbr::stats::validate_stats_buffer(ZBR_HND_STATS hnd_buff)
{
	PROTECT_LIGHT_START();

	if (buffers.find(hnd_buff) == buffers.end())
	{
		return ZBR_STATS_ERROR_BADHANDLE;
	}
	
	// TODO: check signatures and such

	return 0;
	PROTECT_LIGHT_END();
}

__int32 zbr::stats::update_checksums(ZBR_HND_STATS hnd_buff, bool skip_validation)
{
	PROTECT_LIGHT_START();

	if (buffers.find(hnd_buff) == buffers.end())
	{
		return ZBR_STATS_ERROR_BADHANDLE;
	}

	if (!skip_validation)
	{
		auto res = validate_stats_buffer(hnd_buff);
		if (res)
		{
			return res;
		}
	}

	// TODO: setup 

	return 0;
	PROTECT_LIGHT_END();
}

__int32 zbr::stats::save_to_raw(ZBR_HND_STATS hnd_buff, char* buffer, __int32 buff_size)
{
	PROTECT_LIGHT_START();
	// TODO
	return 0;
	PROTECT_LIGHT_END();
}

int zbr::stats::get_stat_size(ZBR_STAT_INDEX stat_type)
{
	switch (stat_type)
	{
		case ZBR_STAT_INFO:
		case ZBR_STAT_XUID0:
		case ZBR_STAT_XUID1:
		case ZBR_STAT_XUID2:
		case ZBR_STAT_XUID3:
			return sizeof(fuzzy_int32) * 2;
	}
	return sizeof(fuzzy_int32);
}

void zbr::stats::init_stat_in_buffer(zbr_stat_pair* stat, ZBR_STAT_INDEX stat_type)
{
	PROTECT_LIGHT_START();
	stat->key.set(stat_type);
	switch (stat_type)
	{
		case ZBR_STAT_INFO:
			stat->value.info.num_stats.set(0);
			stat->value.info.next_stat.set(sizeof(zbr_stat_pair) - sizeof(__zbr_stat_value) + get_stat_size(ZBR_STAT_INFO));
			return;
		case ZBR_STAT_XUID0:
		case ZBR_STAT_XUID1:
		case ZBR_STAT_XUID2:
		case ZBR_STAT_XUID3:
			stat->value.xuid.set(0);
			return;
	}
	stat->value.i32.set(0);
	PROTECT_LIGHT_END();
}

__int32 zbr::stats::get_stat_in_buffer(ZBR_HND_STATS hnd_buff, ZBR_STAT_INDEX stat_type, zbr_stat_pair*& stat_pointer)
{
	PROTECT_LIGHT_START();
	stat_pointer = NULL;

	if (buffers.find(hnd_buff) == buffers.end())
	{
		return ZBR_STATS_ERROR_BADHANDLE;
	}

	auto buff_ptr = buffers[hnd_buff].buff;
	auto buff_size = buffers[hnd_buff].buff_size.get();
	auto first_stat = (zbr_stat_pair*)buff_ptr;
	auto stat = first_stat;
	auto stat_key_value = (ZBR_STAT_INDEX)stat->key.get();
	if (stat_key_value != ZBR_STAT_INFO)
	{
		return ZBR_STATS_ERROR_BADBUFFER;
	}

	auto num_stats = first_stat->value.info.num_stats.get();
	PROTECT_LIGHT_END();

	for (int i = 0; i < num_stats; i++)
	{
		PROTECT_LIGHT_START();
		stat = (zbr_stat_pair*)((char*)stat + sizeof(zbr_stat_pair) - sizeof(__zbr_stat_value) + get_stat_size(stat_key_value));

		if ((__int64)stat - (__int64)buff_ptr > buff_size)
		{
			break; // out of bounds
		}

		stat_key_value = (ZBR_STAT_INDEX)stat->key.get();
		if (stat_key_value == stat_type)
		{
			if ((((__int64)stat - (__int64)buff_ptr + sizeof(zbr_stat_pair) - sizeof(__zbr_stat_value) + get_stat_size(stat_key_value)) > buff_size))
			{
				return ZBR_STATS_ERROR_BADBUFFER;
			}
			stat_pointer = stat;
			return 0;
		}
		PROTECT_LIGHT_END();
	}

	PROTECT_LIGHT_START();
	auto next = first_stat->value.info.next_stat.get();
	auto desired_size = sizeof(zbr_stat_pair) - sizeof(__zbr_stat_value) + get_stat_size(stat_type);
	if (next + desired_size >= (buff_size - sizeof(zbr_stat_pair)))
	{
		auto res = resize_buffer(hnd_buff, ZBR_STATBUFF_INCREASE_SIZE);
		if (res)
		{
			return res;
		}
	}

	stat = (zbr_stat_pair*)((char*)buff_ptr + next);
	first_stat->value.info.next_stat.set(next + desired_size);
	first_stat->value.info.num_stats.set(num_stats + 1);
	init_stat_in_buffer(stat, stat_type);
	stat_pointer = stat;
	mark_buffer_dirty(hnd_buff);

	return 0;
	PROTECT_LIGHT_END();
}

__int32 zbr::stats::resize_buffer(ZBR_HND_STATS hnd_buff, unsigned __int32 delta)
{
	PROTECT_LIGHT_START();

	if (buffers.find(hnd_buff) == buffers.end())
	{
		return ZBR_STATS_ERROR_BADHANDLE;
	}

	auto buff_size = buffers[hnd_buff].buff_size.get();
	if (buff_size + delta > ZBR_MAX_STATBUFF_SIZE)
	{
		return ZBR_STATS_ERROR_BUFFERFULL;
	}

	buffers[hnd_buff].buff_size.set(buff_size + delta);
	PROTECT_LIGHT_END();
}

void zbr::stats::rolling_symmetrical_encrypt(char* buffer, __int32 buff_size)
{
	unsigned __int32 key_xor = ZBR_STAT_CRYPT_CONST;
	for (int i = 0; i < buff_size; i++)
	{
		key_xor = _rotr(key_xor, 1);
		unsigned char use = (key_xor >> (i % 4)) & 0xFF;
		buffer[i] ^= use;
	}
}


char zoneInfoName[512]{ 0 };
unsigned __int32 zbr::zone::loading_custom_zone = 0;
unsigned __int32 zbr::zone::unloading_custom_zone = 0;
std::unordered_map<int, int> zone_id_mappings;
void zbr::zone::load_custom_from_disk(const char* name, int contentid)
{
	strcpy_s(zoneInfoName, name);

	((void(__fastcall*)())REBASE(0x214A8E0))(); // Com_SyncThreads

	if (zone_id_mappings.find(contentid) != zone_id_mappings.end())
	{
		// unload the original id
		//ALOG("Unloading custom zone %s", zoneInfoName);
		//auto free_zone_index = zone_id_mappings[contentid];
		//auto free_zone = REBASE(0x99913E4) + 176 * free_zone_index;
		//((__int32*)free_zone)[0] = ZBR_ZONE_FREEFLAGS_HACK;
		//
		//// unloading_custom_zone++;

		//__int64 fzoneinfo[7]{ 0 };
		//fzoneinfo[0] = (__int64)zoneInfoName;
		//fzoneinfo[3] = ZBR_ZONE_FREEFLAGS_HACK;

		//// DB_UnloadXAssets
		//((void(__fastcall*)(__int64*, unsigned __int32, __int64))REBASE(0x14255A0))(fzoneinfo, 1, 0);
		//
		//zone_id_mappings.erase(contentid);
		//ALOG("Custom zone %s unloaded sucessfully.", zoneInfoName);
		ALOG("WARNING: tried to reload zone %s when it is a custom zone.", zoneInfoName);
		return;
	}

	// hook build_usermods_fspath. have a queue of expected zonefile names (use some bullshit random number for the fast file name mapped to the full path we calculate), and then have a return address check that looks for this and compares.

	__int64 zoneinfo[7]{ 0 };
	zoneinfo[0] = (__int64)zoneInfoName;
	zoneinfo[1] = 0;

	zbr::zone::loading_custom_zone++;

	ALOG("Loading custom zone %s", zoneInfoName);
	/**(unsigned char*)REBASE(0x36841E3) = 1;

	auto original_value = *(__int32*)REBASE(0x168ED8BC);
	if (original_value)
	{
		*(__int32*)REBASE(0x168ED8BC) = 0;
	}*/

	((void(__fastcall*)(__int64*, __int32, __int32, __int32))REBASE(0x14236A0))(zoneinfo, 1, 1, 0); // DB_LoadXAssets

	for (int i = *(__int32*)REBASE(0x941097C); i >= 0; i--) // g_zonecount
	{
		if (!strcmp((const char*)(REBASE(0x998FBC0) + (24 * 4 * i) - 0x40), zoneInfoName))
		{
			zone_id_mappings[contentid] = i;
			break;
		}
	}

	// zone_id_mappings[contentid] = g_zonecount;
	
	zbr::zone::load_bg_cache(0, zone_id_mappings[contentid]);
	zbr::zone::load_bg_cache(1, zone_id_mappings[contentid]);

	SPOOFED_CALL(((void(__fastcall*)())REBASE(0x113F8D0))); // CG_VisionSetMyChanges

	if (!((bool(__fastcall*)())REBASE(0x283A7B0))()) // CL_AllLocalClientsDisconnected
	{
		SPOOFED_CALL(((void(__fastcall*)())REBASE(0x127FDC0))); // CG_WeaponMyChanges
	}

	((void(__fastcall*)())REBASE(0x1B89970))(); // Actor_BehaviorTree_MyChanges
	((void(__fastcall*)())REBASE(0x1CD4AC0))(); // Material_LoadBuiltInComputeShaders

	/**(unsigned char*)REBASE(0x36841E3) = 0;
	if (original_value)
	{
		*(__int32*)REBASE(0x168ED8BC) = 1;
	}*/
	ALOG("Loading custom zone %s finished.", zoneInfoName);
	
	//auto flags = 0;

	//for (int i = *(__int32*)REBASE(0x941097C); i >= 0; i--) // g_zonecount
	//{
	//	auto zone = REBASE(0x99913E4) + 176 * i;
	//	auto zflags = *(__int32*)zone;
	//	ALOG("ZONE %d (%s): %X (%d)", i, REBASE(0x998FBC0) + (24 * 4 * i) - 0x40, zflags, (((__int32(__fastcall*)(__int32))REBASE(0x1421E70))(zflags)));
	//	flags |= zflags;
	//}

	//ALOG("TOTAL FLAGS: %X", flags);
}

int zbr::zone::get_zone_id(int contentid)
{
	if (zone_id_mappings.find(contentid) == zone_id_mappings.end())
	{
		return -1;
	}
	return zone_id_mappings[contentid];
}

struct cache_register_info_t
{
	void* v4; // 48 (+0x0)
	unsigned int* v5; // 40 (+0x8)
	void* v5_2; // 38 (+0x10)
	void** v6; // 30 (+0x18)
	unsigned char trash[0x38]; // 28 (+0x20)
	unsigned int v7; // +0x10 (+0x60)
	unsigned int v8;
};

unsigned __int32 zbr::zone::__DEBUG__ = 0;
void zbr::zone::load_bg_cache(int inst, int index)
{
	cache_register_info_t info{ 0 };
	info.v4 = (void*)REBASE(0x2F9A5C8);
	info.v5_2 = info.v4;
	info.v7 = inst;
	info.v5 = &info.v7;
	info.v6 = &info.v4;
	info.v8 = 0;

	ALOG("^6Loading bg_cache changes for zone %d (inst: %d)", index, inst);
	zbr::zone::__DEBUG__ = 1;
	auto old = *(unsigned __int32*)(REBASE(0x998FBC0) + (24 * 4 * index));
	*(unsigned __int32*)(REBASE(0x998FBC0) + (24 * 4 * index)) = 0x80000000;
	((void(__fastcall*)(unsigned int, unsigned __int32, unsigned __int32, cache_register_info_t*))REBASE(0x14204A0))(85, 0x80000000, 0, &info); // DB_EnumXAssetsAdvanced
	*(unsigned __int32*)(REBASE(0x998FBC0) + (24 * 4 * index)) = old;
	zbr::zone::__DEBUG__ = 0;
}

bool has_loaded_assets = false;
bool zbr::zone::should_load_cc = ZBR_CROWD_CONTROL;
void zbr::zone::load_custom_assets_initial()
{
	if (has_loaded_assets)
	{
		return;
	}
	has_loaded_assets = true;

	if (!move_initial_content())
	{
		return;
	}

	char path[256]{ 0 };
	((void(__fastcall*)(const char*, const char*, int, char*, int, const char*))REBASE(0x20D57A0))(ZBR_ZONE_CHARACTERS_DEFAULT, ".ff", 256, path, 1, (const char*)REBASE(0x1678CD24));
	
	zbr::zone::load_custom_from_disk(ZBR_ZONE_CHARACTERS_DEFAULT, ZBR_ZONE_CHARACTERS_CONTENTID);
	zbr::characters::enabled = true;
}

bool cached_moved = false;
bool zbr::zone::move_initial_content()
{
	if (cached_moved)
	{
		return cached_moved;
	}

	char path[256]{ 0 };
	char xpath[256]{ 0 };
	char path2[256]{ 0 };
	char override_path[256]{ 0 };
	((void(__fastcall*)(const char*, const char*, int, char*, int, const char*))REBASE(0x20D57A0))(ZBR_ZONE_CHARACTERS_DEFAULT, ".override", 256, override_path, 1, (const char*)REBASE(0x1678CD24));
	((void(__fastcall*)(const char*, const char*, int, char*, int, const char*))REBASE(0x20D57A0))(ZBR_ZONE_CHARACTERS_DEFAULT, ".ff", 256, path, 1, (const char*)REBASE(0x1678CD24));
	((void(__fastcall*)(const char*, const char*, int, char*, int, const char*))REBASE(0x20D57A0))(ZBR_ZONE_CHARACTERS_DEFAULT, ".xpak", 256, xpath, 1, (const char*)REBASE(0x1678CD24));

	// ensure they have the fast file
	((void(__fastcall*)(const char*, const char*, int, char*, int, const char*))REBASE(0x20D57A0))(ZBR_ZONE_CHARACTERS_DEFAULT, ".ff", 256, path2, 1, ZBR_CHARACTERS_CONTENTID);
	if (!zbr::fs::exists(path2))
	{
		ALOG("zbr::zone::move_initial_content: FAILED TO FIND REQUIRED CONTENT...");
		return false; // characters not enabled
	}

	DWORD flags = 0;
	bool gotVolumeInfo = GetVolumeInformationA(NULL, NULL, 0, NULL, 0, &flags, NULL, 0);
	bool canHardlink = gotVolumeInfo && (flags & FILE_SUPPORTS_HARD_LINKS);
	bool needsUpdateDLC1 = false;

	if (zbr::fs::exists(path))
	{		
		ALOG("zbr::zone::move_initial_content: found existing zone content");
		if (!zbr::fs::exists(override_path) && canHardlink)
		{
			ALOG("zbr::zone::move_initial_content: couldnt find override specifier. deleting...");
			needsUpdateDLC1 = true;
			DeleteFile(path);
			DeleteFile(xpath);
		}

		if (!canHardlink && zbr::fs::exists(path))
		{
			ifstream existingInfo;
			existingInfo.open(path);

			if (!existingInfo.is_open())
			{
				ALOG("zbr::zone::move_initial_content: FAILED to read existing fastfile info...");
				return false; // how?
			}

			existingInfo.ignore(16);
			__int64 existingTimestamp = 0;
			existingInfo.read((char*)&existingTimestamp, 8);
			existingInfo.close();

			ifstream dlcInfo;
			dlcInfo.open(path2);
			if (!dlcInfo.is_open())
			{
				ALOG("zbr::zone::move_initial_content: FAILED to read info about the dlc...");
				return false; // how?
			}


			dlcInfo.ignore(16);
			__int64 dlcTimestamp = 0;
			dlcInfo.read((char*)&dlcTimestamp, 8);
			dlcInfo.close();

			if (dlcTimestamp != existingTimestamp)
			{
				needsUpdateDLC1 = true;
				ALOG("zbr::zone::move_initial_content: deleting outdated content...");
				DeleteFile(path);
				DeleteFile(xpath);
			}
		}
	}
	else
	{
		needsUpdateDLC1 = true;
	}

	if (needsUpdateDLC1 && !zbr::fs::exists(override_path))
	{
		bool failedHL = false;
		if (canHardlink)
		{
			auto r = CreateHardLinkA(path, path2, 0);

			if (!r)
			{
				ALOG("zbr::zone::move_initial_content: Redirector fastfile creation FAILED %d...", GetLastError());
				failedHL = true;
			}
			else
			{
				ALOG("zbr::zone::move_initial_content: Redirector creation for fast file succeeded.");
			}
		}
		
		if(failedHL || !canHardlink)
		{
			ALOG("zbr::zone::move_initial_content: Reparse points not supported. Defaulting to copy operation (fastfile).");
			auto r = CopyFile(path2, path, false);

			if (!r)
			{
				ALOG("zbr::zone::move_initial_content: Copy DLC for fastfile FAILED %d...", GetLastError());
				return false;
			}
			ALOG("zbr::zone::move_initial_content: Copy DLC for fast file succeeded.");
		}
		
		((void(__fastcall*)(const char*, const char*, int, char*, int, const char*))REBASE(0x20D57A0))(ZBR_ZONE_CHARACTERS_DEFAULT, ".xpak", 256, path2, 1, ZBR_CHARACTERS_CONTENTID);

		if (!zbr::fs::exists(path2))
		{
			ALOG("zbr::zone::move_initial_content: XPAK data not found in DLC.");
			return false; // characters not enabled
		}

		failedHL = false;
		if (canHardlink)
		{
			auto r = CreateHardLinkA(xpath, path2, 0);

			if (!r)
			{
				ALOG("zbr::zone::move_initial_content: Redirector xpak creation FAILED %d...", GetLastError());
				failedHL = true;
			}
			ALOG("zbr::zone::move_initial_content: Redirector creation for xpak succeeded.");
		}
		
		if(failedHL || !canHardlink)
		{
			ALOG("zbr::zone::move_initial_content: Reparse points not supported. Defaulting to copy operation (xpak).");
			auto r = CopyFile(path2, xpath, false);

			if (!r)
			{
				ALOG("zbr::zone::move_initial_content: Copy DLC for xpak FAILED %d...", GetLastError());
				return false;
			}
			ALOG("zbr::zone::move_initial_content: Copy DLC for xpak succeeded.");
		}
	}	

	return cached_moved = true;
}

int zbr::zone::lhascontent(void* lua_state)
{
	auto s = (lua_State*)lua_state;
	lua_pushboolean(s, move_initial_content());
	return 1;
}

void zbr::zone::extend_xasset_pool(AssetPool pool, int num_to_add)
{
	if (num_to_add <= 0)
	{
		return;
	}

	__int64 pool_pointer = (__int64)(ASSETPOOL_BEGIN + (0x20 * (int)pool));
	__int32 asset_size = *(__int32*)(pool_pointer + 0x8);
	__int32 asset_count = *(__int32*)(pool_pointer + 0xC);
	*(__int32*)(pool_pointer + 0xC) = asset_count + num_to_add;

	auto new_memory = (char*)VirtualAlloc(0, asset_size * num_to_add, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE);

	if (!new_memory)
	{
		return;
	}

	*(__int64*)((*(__int64*)pool_pointer) + (asset_size * (asset_count - 1))) = (__int64)new_memory;

	for (int i = 0; i < num_to_add; i++)
	{
		*(__int64*)(new_memory + (asset_size * i)) = (__int64)(new_memory + (asset_size * (i + 1)));
	}

	*(__int64*)(new_memory + (asset_size * (num_to_add - 1))) = 0;

	if (!*(__int64*)(pool_pointer + 0x18))
	{
		*(__int64*)(pool_pointer + 0x18) = (__int64)new_memory;
	}
}

int zbr::characters::get_character_index(__int64 xuid)
{
	if (gamestate.zbr_character_index.find(xuid) == gamestate.zbr_character_index.end())
	{
		if (xuid == **(INT64**)s_playerData_ptr)
		{
			return zbr::characters::get_selected_character();
		}
		return -1;
	}
	return gamestate.zbr_character_index[xuid];
}

int zbr::characters::get_selected_character()
{
	zbr::profile::profile_init();
	return zbr::profile::profile.character;
}

void zbr::characters::on_character_changed()
{
	zbr::send_client_reliable();
}

void zbr::characters::send_emote_rpc(int emote)
{
	LobbyMsg lobbyMsg{ 0 };

	memset(lm_buff, 0, sizeof(lm_buff));

	unsigned int whoami = lobbystate.whoami;
	if (Protection::LobbyMsgRW_PrepWriteMsg(&lobbyMsg, lm_buff, sizeof(lm_buff), MESSAGE_TYPE_ZBR_CHARACTERRPC) && zbr::package_clientemoterpc(&lobbyMsg, emote, whoami))
	{
		__int32 msgConfig[0x30]{ 0 }; // way bigger than needed but im not figuring out this struct
		msgConfig[0] = getframetime();
		msgConfig[1] = 1;
		msgConfig[2] = 13;
		auto lobby_session = (__int64)Protection::LobbySession_GetSession(1);
		__int32 channel = LobbyNetChan_GetLobbyChannel(*(unsigned __int32*)(lobby_session + 4), 3);
		LobbyMsgTransport_SendToHostReliably(0, lobby_session, LOBBY_MODULE_HOST, &lobbyMsg.msg, (MsgType)lobbyMsg.msgType, channel, msgConfig);
	}
}

bool zbr::package_clientemoterpc(LobbyMsg* msg, int& what, unsigned int& whoami)
{
	bool res = Protection::LobbyMsgRW_PackageUInt(msg, FIELD_WHOAMI, (unsigned int*)&whoami);
	res = res && Protection::LobbyMsgRW_PackageUInt(msg, FIELD_WHOAMI, (unsigned int*)&what);
	return res;
}

int zbr::profile::lget(void* lua_state)
{
	lua_State* s = (lua_State*)lua_state;

	if (!zbr::profile::profile_init())
	{
		// ALOG("lget: BAD PROFILE");
		lua_pushnil(s); // default
		return 1;
	}

	const char* setting = lua_tostring(s, -1);
	auto hashval = GSCUHashing::canon_hash(setting);

	if (profile.props.find(hashval) == profile.props.end())
	{
		// ALOG("lget: BAD PROP");
		lua_pushnil(s); // default
		return 1;
	}

	switch (profile.props[hashval].type)
	{
		case ZBR_PDATA_INT:
			// ALOG("lget: GOOD PROP, RETURNING");
			lua_pushinteger(s, *(__int32*)((char*)&profile + profile.props[hashval].off));
		return 1;
	}

	// ALOG("lget: BAD PROP 2");
	lua_pushnil(s); // default
	return 1;
}

__int32 zbr::profile::get_int32(unsigned __int32 hashval)
{
	if (profile.props.find(hashval) == profile.props.end())
	{
		return 0;
	}
	return *(__int32*)((char*)&profile + profile.props[hashval].off);
}

int zbr::profile::lset(void* lua_state)
{
	lua_State* s = (lua_State*)lua_state;

	if (!zbr::profile::profile_init())
	{
		// ALOG("lset: BAD PROFILE");
		return 1;
	}

	const char* setting = lua_tostring(s, -2);
	auto hashval = GSCUHashing::canon_hash(setting);

	if (profile.props.find(hashval) == profile.props.end())
	{
		// ALOG("lset: BAD PROP");
		return 1;
	}

	switch (profile.props[hashval].type)
	{
		case ZBR_PDATA_INT:
		{
			// ALOG("lset: GOOD PROP");
			*(__int32*)((char*)&profile + profile.props[hashval].off) = (int)lua_tonumber(s, -1);
			profile_flush();
		}
		break;
	}

	if (profile.props[hashval].callback)
	{
		((void(__fastcall*)())profile.props[hashval].callback)();
	}

	return 1;
}

bool zbr::profile::using_damage_numbers()
{
	const auto hashval = CONST32(__TOSTRING(PROFILE_VAR_BDAMAGENUMBERS));

	if (profile.props.find(hashval) == profile.props.end())
	{
		return true;
	}

	return *(__int32*)((char*)&profile + profile.props[hashval].off);
}

bool zbr::profile::profile_init()
{
	if (profile_initialized)
	{
		return true;
	}

	REGISTER_PROFILE_VAR(PROFILE_VAR_CHARACTER, __int32, ZBR_PDATA_INT, zbr::characters::on_character_changed);
	REGISTER_PROFILE_VAR(PROFILE_VAR_BDAMAGENUMBERS, __int32, ZBR_PDATA_INT, NULL);
	REGISTER_PROFILE_VAR(PROFILE_VAR_FAVORITE_EMOTE, __int32, ZBR_PDATA_INT, NULL);
	REGISTER_PROFILE_VAR(PROFILE_VAR_EMOTE1, __int32, ZBR_PDATA_INT, NULL);
	REGISTER_PROFILE_VAR(PROFILE_VAR_EMOTE2, __int32, ZBR_PDATA_INT, NULL);
	REGISTER_PROFILE_VAR(PROFILE_VAR_EMOTE3, __int32, ZBR_PDATA_INT, NULL);
	REGISTER_PROFILE_VAR(PROFILE_VAR_EMOTE4, __int32, ZBR_PDATA_INT, NULL);
	REGISTER_PROFILE_VAR(PROFILE_VAR_SPAWNWEAPON, __int32, ZBR_PDATA_INT, zbr::send_client_reliable);
	REGISTER_PROFILE_VAR(PROFILE_VAR_HAT, __int32, ZBR_PDATA_INT, zbr::send_client_reliable);

	if (!zbr::fs::exists(PATH_ZBR_PROFILE_DATA))
	{
		// ALOG("profile_init: NONE EXISTS");
		if (!profile_flush())
		{
			// ALOG("profile_init: CREATE FAILED");
			return false;
		}
	}

	// ALOG("profile_init: SUCCESS");
	profile_initialized = true;
	profile_load();

	zbr::populate_cosmetics(zbr::lobbystate.cosmetics[0]);

	return true;
}

bool zbr::profile::profile_flush()
{
	if (profile_flush_failed)
	{
		return false;
	}
	std::ofstream ofs;
	ofs.open(PATH_ZBR_PROFILE_DATA, std::ofstream::out | std::ofstream::binary);

	if (!ofs.is_open())
	{
		// ALOG("profile_flush: FAILED");
		profile_flush_failed = true;
		return false;
	}

	for (auto it = profile.props.begin(); it != profile.props.end(); it++)
	{
		__int32 k = it->first;
		auto v = it->second;
		
		ofs.write((char*)&k, sizeof(__int32));
		ofs.write((char*)&v.size, sizeof(__int32));
		ofs.write((const char*)((char*)&profile + v.off), v.size);

		if (ofs.fail())
		{
			// ALOG("profile_flush: FAILED 2");
			profile_flush_failed = true;
			return false;
		}
	}

	// ALOG("profile_flush: SUCCESS");

	ofs.close();
	return true;
}

bool zbr::profile::profile_load()
{
	std::ifstream ifs;
	ifs.open(PATH_ZBR_PROFILE_DATA, std::ifstream::in | std::ifstream::binary);

	if (!ifs.is_open())
	{
		// ALOG("profile_load: LOAD FAILED 1");
		return false;
	}

	while (!ifs.eof())
	{
		__int32 propid;
		__int32 sizeofprop;

		ifs.read((char*)&propid, sizeof(__int32));
		ifs.read((char*)&sizeofprop, sizeof(__int32));

		if (ifs.fail())
		{
			// ALOG("profile_load: LOAD FAILED 2");
			break;
		}

		if (profile.props.find(propid) == profile.props.end())
		{
			// ALOG("profile_load: IGNORING BAD PROP (NOT FOUND)");
			ifs.ignore(sizeofprop);
			continue;
		}

		if ((__int32)profile.props[propid].off + (__int32)profile.props[propid].size > (__int32)sizeof(zbr_profile_vars))
		{
			// ALOG("profile_load: IGNORING BAD PROP (SIZE OOB)");
			ifs.ignore(sizeofprop);
			continue;
		}

		if ((__int32)profile.props[propid].size != sizeofprop)
		{
			// ALOG("profile_load: IGNORING BAD PROP (SIZE DOESNT MATCH)");
			ifs.ignore(sizeofprop);
			continue;
		}

		ifs.read((char*)&profile + profile.props[propid].off, profile.props[propid].size);
	}

	// ALOG("profile_load: FINISHED");
	ifs.close();
	return true;
}

int zbr::lget_buildid(void* lua_state)
{
	auto s = (lua_State*)lua_state;
	const char* str = ZBR_VERS ZBR_BUILDID;
	lua_pushlstring(s, str, strlen(str));
	return 1;
}

void zbr::testing::dotests()
{
	/*fuzzy_int32 bah;
	bah.set(1337);

	ALOG("TESTING V1: %d", bah.get());*/
}

#define k_EItemStateNone 0
#define k_EItemStateSubscribed 1
#define k_EItemStateLegacyItem 2
#define k_EItemStateInstalled 4
#define k_EItemStateNeedsUpdate 8
#define k_EItemStateDownloading	16
#define k_EItemStateDownloadPending 32
#define STEAM_INSTALLED_AND_UPDATED(x) ((x & k_EItemStateInstalled) && !((k_EItemStateNeedsUpdate | k_EItemStateDownloading | k_EItemStateDownloadPending) & x))

#define ZBR_UPDATE_GOOD 0
#define ZBR_UPDATE_UPDATE_CHARACTERS 1
#define ZBR_UPDATE_UPDATE_BUILD 2

int zbr::lcheck_updates(void* state)
{
	auto s = (lua_State*)state;
	auto steamugc = *(__int64*)REBASE(0x10BBCC00);

	auto characters = (*(__int64(__fastcall**)(__int64, __int64))(*(__int64*)steamugc + 0x1C8))(steamugc, ZBR_CHARACTERS_CONTENTIDINT);
	if (!STEAM_INSTALLED_AND_UPDATED(characters))
	{
		lua_pushinteger(s, ZBR_UPDATE_UPDATE_CHARACTERS);
		return 1;
	}


	auto build = (*(__int64(__fastcall**)(__int64, __int64))(*(__int64*)steamugc + 0x1C8))(steamugc, WORKSHOP_ID_INT);
	if (!STEAM_INSTALLED_AND_UPDATED(build))
	{
		lua_pushinteger(s, ZBR_UPDATE_UPDATE_BUILD);
		return 1;
	}

	char override_path[256]{ 0 };
	((void(__fastcall*)(const char*, const char*, int, char*, int, const char*))REBASE(0x20D57A0))(ZBR_ZONE_CHARACTERS_DEFAULT, ".override", 256, override_path, 1, (const char*)REBASE(0x1678CD24));
	
	char path2[256]{ 0 };
	((void(__fastcall*)(const char*, const char*, int, char*, int, const char*))REBASE(0x20D57A0))(ZBR_ZONE_CHARACTERS_DEFAULT, ".vers", 256, path2, 1, ZBR_CHARACTERS_CONTENTID);
	if (!zbr::fs::exists(override_path))
	{
		if (!zbr::fs::exists(path2))
		{
			lua_pushinteger(s, ZBR_UPDATE_UPDATE_CHARACTERS);
			return 1;
		}
		else
		{
			std::ifstream ifs;
			ifs.open(path2);

			if (!ifs.is_open())
			{
				lua_pushinteger(s, ZBR_UPDATE_UPDATE_CHARACTERS);
				return 1;
			}

			std::string output;
			ifs >> output;

			if (strcmp(output.c_str(), ZBR_ADDITIONAL_ASSETS_VERSION))
			{
				lua_pushinteger(s, ZBR_UPDATE_UPDATE_CHARACTERS);
				return 1;
			}

			ifs.close();
		}
	}

	lua_pushinteger(s, ZBR_UPDATE_GOOD);
	return 1;
}

bool networking_init = false;
void zbr::network::init()
{
	if (networking_init)
	{
		return;
	}

	networking_init = true;

	gamesettings::init();
	___register_callback(zbr::gamesettings::___run_network_frame);

	CreateThread(NULL, NULL, zbr::network::___worker, NULL, NULL, NULL);
}

DWORD WINAPI zbr::network::___worker(_In_ LPVOID lpParameter)
{
	for (;;)
	{
		for (auto it = ___callbacks.begin(); it != ___callbacks.end(); ++it)
		{
			((void(__fastcall*)()) * it)();
		}
		Sleep(16);
	}
	return 0;
}

std::vector<void*> zbr::network::___callbacks;
void zbr::network::___register_callback(void* cb)
{
	___callbacks.push_back(cb);
}

__int64 gs_network_last_checked = 0;
void zbr::gamesettings::___run_network_frame()
{
	__int64 current = GetTickCount64();
	if (current - gs_network_last_checked > ZBR_GAMESETTINGS_RECHECKTICKS)
	{
		gs_network_last_checked = current;
		
		// check for latest settings

		// if our network request succeeds, grab latest settings and cache
		// if not, load from cache
		// TODO: we should automatically write cache into zone folder in our build toolchain
		// TODO: implement timestamps and gamesettings version hashes to be sent to the server with game/stats deltas.
		//		 server will track gamesettings hash valid ranges and if a game delta is submitted with an invalid match (custom settings), reject stats deltas 
		//		 (NOTE: This may or may not be implemented depending on whether we want to grant players xp and stats in custom games)
	}
}

bool gamesettings_init = false;
bool zbr::gamesettings::using_custom_settings = false;
void zbr::gamesettings::init()
{
	if (gamesettings_init)
	{
		return;
	}
	gamesettings_init = true;
}

void zbr::gamesettings::cache()
{
	std::ofstream ofs;
	ofs.open(PATH_ZBR_GAMESETTINGS, std::ofstream::out | std::ofstream::binary);

	if(!ofs.is_open())
	{
		return;
	}

	ofs << settings.encode();
	ofs.close();
}

bool zbr::gamesettings::load(zbr_gamesettings& storage, const char* path)
{
	std::ifstream ifs;
	ifs.open(path);

	if(!ifs.is_open())
	{
		return false;
	}

	std::string data;
	ifs >> data;

	storage = zbr_gamesettings(); // clear to defaults hardcoded in cpp
	storage.read(zbr::gamesettings::settings.encode()); // load any defaults from the active gamesettings first
	storage.read(data); // load any deltas we have in the custom gs

	ifs.close();
	return true;
}

zbr_gamesettings* zbr::gamesettings::active_settings()
{
	if(using_custom_settings)
	{
		return &zbr::gamesettings::custom_settings;
	}
	return &zbr::gamesettings::settings;
}

int zbr::gamesettings::lget(void* lua_state)
{
	lua_State* s = (lua_State*)lua_state;

	const char* setting = lua_tostring(s, -2);
	bool is_default = lua_toboolean(s, -1);

	if (is_default)
	{
		auto member = zbr::gamesettings::settings.get_member(setting);
		if (!member)
		{
			lua_pushnil(s); // default
			return 1;
		}
		if (member->type == ZBR_GS___int32)
		{
			lua_pushinteger(s, member->i32());
			return 1;
		}
		lua_pushnumber(s, member->f());
		return 1;
	}
	else
	{
		auto settings = active_settings();
		auto member = settings->get_member(setting);
		if (!member)
		{
			lua_pushnil(s); // default
			return 1;
		}
		if (member->type == ZBR_GS___int32)
		{
			lua_pushinteger(s, member->i32());
			return 1;
		}
		lua_pushnumber(s, member->f());
		return 1;
	}

	return 1;
}

int zbr::gamesettings::lset(void* lua_state)
{
	lua_State* s = (lua_State*)lua_state;

	using_custom_settings = true;

	const char* setting = lua_tostring(s, -2);
	
	auto settings = active_settings();
	auto member = settings->get_member(setting);

	if (!member)
	{
		return 1;
	}

	if (member->type == ZBR_GS___int32)
	{
		member->value.___int32 = (int)lua_tonumber(s, -1);
		return 1;
	}

	member->value._float = (float)lua_tonumber(s, -1);
	return 1;
}

void debug_printall_cm(const char* xmodel)
{
	/*auto cm_staticmodels = *(cStaticModel_s**)(*(__int64*)REBASE(0x16817F88) + 0xB0);
	auto num_models = *(__int32*)(*(__int64*)REBASE(0x16817F88) + 0xA8);

	auto xmodel_ref = DB_FindXAssetHeader(xasset_xmodel, xmodel, false, 0);

	ALOG("LOOKING AT CLIPMAP...");
	while (num_models)
	{
		if (cm_staticmodels->xmodel == xmodel_ref)
		{
			scr_vec3_t angles{ 0, 0, 0 };
			AxisToAngles(cm_staticmodels->invScaledAxis, &angles);

			ALOG("FOUND (cm) %s {%u, (%.1f, %.1f, %.1f), [(%.1f, %.1f, %.1f), (%.1f, %.1f, %.1f), (%.1f, %.1f, %.1f)], (%.1f, %.1f, %.1f), (%.1f, %.1f, %.1f), %u} A2D: (%.1f, %.1f, %.1f)", xmodel, cm_staticmodels->contents,
				cm_staticmodels->origin.x, cm_staticmodels->origin.y, cm_staticmodels->origin.z,
				cm_staticmodels->invScaledAxis[0].x, cm_staticmodels->invScaledAxis[0].y, cm_staticmodels->invScaledAxis[0].z,
				cm_staticmodels->invScaledAxis[1].x, cm_staticmodels->invScaledAxis[1].y, cm_staticmodels->invScaledAxis[1].z,
				cm_staticmodels->invScaledAxis[2].x, cm_staticmodels->invScaledAxis[2].y, cm_staticmodels->invScaledAxis[2].z,
				cm_staticmodels->absmin.x, cm_staticmodels->absmin.y, cm_staticmodels->absmin.z,
				cm_staticmodels->absmax.x, cm_staticmodels->absmax.y, cm_staticmodels->absmax.z,
				cm_staticmodels->targetname,
				angles.x, angles.y, angles.z
			);

			cm_staticmodels->absmin = cm_staticmodels->absmin - cm_staticmodels->origin;
			cm_staticmodels->absmax = cm_staticmodels->absmax - cm_staticmodels->origin;
			cm_staticmodels->origin = { 0, 0, 0 };
		}

		cm_staticmodels++;
		num_models--;
	}*/
}

void debug_printall_gfx(const char* xmodel)
{
	/*ALOG("LOOKING AT GFXMAP...");
	auto smodelcount = *(__int32*)(*(__int64*)REBASE(0xF4E2C20) + 0x2FC);
	auto smodel_ref = *(GfxStaticModelDrawInst**)(*(__int64*)REBASE(0xF4E2C20) + 0x438);

	auto xmodel_ref = DB_FindXAssetHeader(xasset_xmodel, xmodel, false, 0);

	while (smodelcount)
	{
		if (smodel_ref->model == xmodel_ref)
		{
			scr_vec3_t angles{ 0, 0, 0 };
			AxisToAngles(smodel_ref->placement.axis, &angles);
			ALOG("FOUND (gfx) %s {(%.1f, %.1f, %.1f), [(%.1f, %.1f, %.1f), (%.1f, %.1f, %.1f), (%.1f, %.1f, %.1f)], %f, (%.1f, %.1f, %.1f), (%.1f, %.1f, %.1f), (%.1f, %.1f, %.1f), %u, %u, %f, %f} A2D: (%.1f, %.1f, %.1f), smid: %u",
				xmodel,
				smodel_ref->placement.origin.x, smodel_ref->placement.origin.y, smodel_ref->placement.origin.z,
				smodel_ref->placement.axis[0].x, smodel_ref->placement.axis[0].y, smodel_ref->placement.axis[0].z,
				smodel_ref->placement.axis[1].x, smodel_ref->placement.axis[1].y, smodel_ref->placement.axis[1].z,
				smodel_ref->placement.axis[2].x, smodel_ref->placement.axis[2].y, smodel_ref->placement.axis[2].z, smodel_ref->placement.scale,
				smodel_ref->center.x, smodel_ref->center.y, smodel_ref->center.z,
				smodel_ref->mins.x, smodel_ref->mins.y, smodel_ref->mins.z,
				smodel_ref->maxs.x, smodel_ref->maxs.y, smodel_ref->maxs.z,
				(unsigned __int32)smodel_ref->flags,
				(unsigned __int32)smodel_ref->umbraGateId,
				smodel_ref->invScaleSq, smodel_ref->scaledRadius,
				angles.x, angles.y, angles.z,
				smodel_ref->smid
			);

			smodel_ref->mins = smodel_ref->mins - smodel_ref->center;
			smodel_ref->maxs = smodel_ref->maxs - smodel_ref->center;
			smodel_ref->center = smodel_ref->placement.origin = { 0, 0, 0 };

		}

		smodel_ref++;
		smodelcount--;
	}*/
}

char zbr::dynamicmap::dynmapstr[DYNMAP_BUF_SIZE];
unsigned __int32 zbr::dynamicmap::current_dyn_map;
const char* zbr::get_map_bonus_ents()
{
	auto var = Dvar_FindVar("mapname");

	if (!var)
	{
		return "";
	}

	const char* mapname = Dvar_GetVariantString(var);

	dynamicmap::prepare();

	if (dynamicmap::prepare_ents(fnv1a(mapname)))
	{
		for (auto it = dynamicmap::mystery_boxes.begin(); it != dynamicmap::mystery_boxes.end(); it++)
		{
			dynamicmap::create_box_mapent(it->origin, it->angles);
		}

		for (auto it = dynamicmap::pap_locations.begin(); it != dynamicmap::pap_locations.end(); it++)
		{
			dynamicmap::create_pap(it->origin, it->angles);
		}
	}

	return zbr::dynamicmap::dynmapstr;
}

unsigned __int32 zbr::dynamicmap::current_dyn_map_int;
void zbr::dynamicmap::prepare()
{
	auto var = Dvar_FindVar("mapname");

	if (!var)
	{
		return;
	}

	const char* mapname = Dvar_GetVariantString(var);
	auto map = fnv1a(mapname);

	if (map != current_dyn_map_int)
	{
		mystery_boxes.clear();
		pap_locations.clear();
	}

	switch (fnv1a(mapname))
	{
		case FNV32("zm_map"):
		case FNV32("mp_nuketown_x"):
		{
			pap_locations.push_back({ "-4.8 995 140", "90 -90 0" });
			mystery_boxes.push_back({ { 0, 0, 0 }, { 0, 0, 0} });
		}
		break;
		case FNV32("mp_crucible"):
		{
			//pap_locations.push_back({ "-167.73 -3408.31 94.4845", "0 180 0" });
		}
		break;
	}
}

cStaticModel_s* custom_models = 0;
void zbr::dynamicmap::mod_static_models()
{
	auto var = Dvar_FindVar("mapname");

	if (!var)
	{
		return;
	}

	const char* mapname = Dvar_GetVariantString(var);
	auto map = fnv1a(mapname);
	dynamicmap::prepare();

	if (zbr::dynamicmap::prepare_cm(map))
	{
		for (auto it = dynamicmap::mystery_boxes.begin(); it != dynamicmap::mystery_boxes.end(); it++)
		{
			dynamicmap::create_box_sm(it->origin, it->angles);
		}
	}

	if (*(cStaticModel_s**)(*(__int64*)REBASE(0x16817F88) + 0xB0) != custom_models)
	{
		if (custom_models)
		{
			free(custom_models);
			custom_models = 0;
		}

		if (!*(cStaticModel_s**)(*(__int64*)REBASE(0x16817F88) + 0xB0))
		{
			return;
		}

		auto count = *(__int32*)(*(__int64*)REBASE(0x16817F88) + 0xA8);
		custom_models = (cStaticModel_s*)malloc(sizeof(cStaticModel_s) * (count + static_models.size()));

		auto ptr = *(cStaticModel_s**)(*(__int64*)REBASE(0x16817F88) + 0xB0);
		for (int i = 0; i < count; i++)
		{
			custom_models[i] = ptr[i];
		}

		for (int i = count; i < (count + static_models.size()); i++)
		{
			custom_models[i] = static_models[i - count];
		}

		*(cStaticModel_s**)(*(__int64*)REBASE(0x16817F88) + 0xB0) = custom_models;
		*(__int32*)(*(__int64*)REBASE(0x16817F88) + 0xA8) = (count + static_models.size());
	}

	debug_printall_cm("p7_cinder_block");
}

GfxStaticModelDrawInst* custom_gfx_models = 0;
GfxVisArray custom_vis_arrays[5]{ 0 };
void zbr::dynamicmap::mod_gfx_static_models()
{
	auto var = Dvar_FindVar("mapname");

	if (!var)
	{
		return;
	}

	const char* mapname = Dvar_GetVariantString(var);
	auto map = fnv1a(mapname);
	dynamicmap::prepare();

	if (prepare_gfx(map))
	{
		for (auto it = dynamicmap::mystery_boxes.begin(); it != dynamicmap::mystery_boxes.end(); it++)
		{
			create_box_gfx(it->origin, it->angles);
		}
	}

	if (*(GfxStaticModelDrawInst**)(*(__int64*)REBASE(0xF4E2C20) + 0x438) != custom_gfx_models)
	{
		if (custom_gfx_models)
		{
			free(custom_gfx_models);
			custom_gfx_models = 0;
		}

		if (!*(GfxStaticModelDrawInst**)(*(__int64*)REBASE(0xF4E2C20) + 0x438))
		{
			return;
		}

		auto smodelcount = *(__int32*)(*(__int64*)REBASE(0xF4E2C20) + 0x2FC);
		custom_gfx_models = (GfxStaticModelDrawInst*)malloc(sizeof(GfxStaticModelDrawInst) * (smodelcount + static_models_gfx.size()));

		auto ptr = *(GfxStaticModelDrawInst**)(*(__int64*)REBASE(0xF4E2C20) + 0x438);
		for (int i = 0; i < smodelcount; i++)
		{
			custom_gfx_models[i] = ptr[i];
		}

		for (int i = smodelcount; i < (smodelcount + static_models_gfx.size()); i++)
		{
			custom_gfx_models[i] = static_models_gfx[i - smodelcount];
		}

		*(GfxStaticModelDrawInst**)(*(__int64*)REBASE(0xF4E2C20) + 0x438) = custom_gfx_models;
		*(__int32*)(*(__int64*)REBASE(0xF4E2C20) + 0x2FC) = (smodelcount + static_models_gfx.size());


		// change dpvs smodelVisData for all controllers
		auto visarrays = (GfxVisArray*)(*(__int64*)REBASE(0xF4E2C20) + 0x328);
		auto visarraysaved = (GfxVisArray*)(*(__int64*)REBASE(0xF4E2C20) + 0x3E8);

		for (int i = 0; i < 5; i++)
		{
			GfxVisArray* vac = (i < 4) ? (visarrays + i) : visarraysaved;
			if (custom_vis_arrays[i].visData != vac->visData)
			{
				if (custom_vis_arrays[i].visData)
				{
					free(custom_vis_arrays[i].visData);
					custom_vis_arrays[i].visData = 0;
					custom_vis_arrays[i].visDataCount = 0;
				}

				if (!vac->visData)
				{
					continue;
				}

				custom_vis_arrays[i].visData = (unsigned char*)malloc(static_models_gfx.size() + vac->visDataCount);
				custom_vis_arrays[i].visDataCount = static_models_gfx.size() + vac->visDataCount;
				memcpy(custom_vis_arrays[i].visData, vac->visData, vac->visDataCount);
				memset(custom_vis_arrays[i].visData + vac->visDataCount, 0, static_models_gfx.size());

				vac->visData = custom_vis_arrays[i].visData;
				vac->visDataCount = custom_vis_arrays[i].visDataCount;
			}
		}
	}

	debug_printall_gfx("p7_cinder_block");
}

unsigned __int32 zbr::dynamicmap::current_dyn_map_cm;
std::vector<cStaticModel_s> zbr::dynamicmap::static_models;
std::vector<GfxStaticModelDrawInst> zbr::dynamicmap::static_models_gfx;
unsigned __int32 zbr::dynamicmap::current_dyn_map_gfx;
std::vector<transform_t> zbr::dynamicmap::mystery_boxes;
std::vector<strtransform_t> zbr::dynamicmap::pap_locations;
bool zbr::dynamicmap::prepare_cm(unsigned __int32 mapname)
{
	if (mapname == current_dyn_map_cm)
	{
		return false;
	}

	current_dyn_map_cm = mapname;
	static_models.clear();
	return true;
}

bool zbr::dynamicmap::prepare_gfx(unsigned __int32 mapname)
{
	if (mapname == current_dyn_map_gfx)
	{
		return false;
	}

	current_dyn_map_gfx = mapname;
	static_models_gfx.clear();
	return true;
}

bool zbr::dynamicmap::prepare_ents(unsigned __int32 mapname)
{
	if (mapname == current_dyn_map)
	{
		return false;
	}
	current_dyn_map = mapname;
	memset(dynmapstr, 0, DYNMAP_BUF_SIZE);
	return true;
}

void zbr::dynamicmap::create_pap(const char* origin, const char* angles)
{
	strcat_s(dynmapstr, "\n{\n\"script_string\" \"zclassic_perks_start_room\"\n\"invalid_s_m_i_d\" \"6\"\n\"zbarriertearAnim3\" \"o_zombie_base_packapunch_flag_up\"\n\"zbarriertearAnim2\" \"o_zombie_base_packapunch_working_take_gun\"\n\"zbarriertearAnim1\" \"o_zombie_base_packapunch_poweron\"\n\"zbarrierboardModel3\" \"p7_zm_vending_packapunch_sign_wait\"\n\"zbarrierboardModel2\" \"p7_zm_vending_packapunch_on\"\n\"zbarrierboardModel1\" \"p7_zm_vending_packapunch\"\n\"zbarrierboardAnim3\" \"o_zombie_base_packapunch_flag_down\"\n\"zbarrierboardAnim2\" \"o_zombie_base_packapunch_working_eject_gun\"\n\"zbarrierboardAnim1\" \"o_zombie_base_packapunch_poweron\"\n\"type\" \"zmcore_packapunch\"\n\"_color\" \"0.3 0.3 1\"\n\"zbarriertearAnim6\" \"o_zombie_base_packapunch_poweron\"\n\"zbarriertearAnim5\" \"o_zombie_base_packapunch_worldgun_dw_taken\"\n\"zbarriertearAnim4\" \"o_zombie_base_packapunch_worldgun_taken\"\n\"zbarrierboardModel6\" \"p7_zm_vending_packapunch_on\"\n\"zbarrierboardModel5\" \"tag_origin_animate\"\n\"zbarrierboardModel4\" \"tag_origin_animate\"\n\"zbarrierboardAnim6\" \"o_zombie_base_packapunch_working_loop\"\n\"zbarrierboardAnim5\" \"o_zombie_base_packapunch_worldgun_dw_ejected\"\n\"zbarrierboardAnim4\" \"o_zombie_base_packapunch_worldgun_ejected\"\n\"zbarrierNumBoards\" \"6\"\n\"targetname\" \"zm_pack_a_punch\"\n\"origin\" \"");
	strcat_s(dynmapstr, origin);
	strcat_s(dynmapstr, "\"\n\"angles\" \"");
	strcat_s(dynmapstr, angles);
	strcat_s(dynmapstr, "\"\n\"classname\" \"zbarrier_zmcore_packapunch\"\n\"guid\" \"A71AF866\"\n}");
}

#define BOX_MODEL(_origin, _angles, mdl, scale) create_static_misc_model(origin + util::rotate_point(angles, _origin), angles + _angles, mdl, scale)
void zbr::dynamicmap::create_box_mapent(scr_vec3_t origin, scr_vec3_t angles)
{
	BOX_MODEL(scr_vec3_t(40, -4, 4), scr_vec3_t(0, 260, 0), "p7_cinder_block", "1");
	BOX_MODEL(scr_vec3_t(0, -7, 9), scr_vec3_t(0, 270, 0), "p7_debris_wood_plank_old_96", "1");
	BOX_MODEL(scr_vec3_t(0, 7, 9), scr_vec3_t(0, 270, 0), "p7_debris_wood_plank_old_96", "1");
	BOX_MODEL(scr_vec3_t(-40, -4, 4), scr_vec3_t(0, 285, 0), "p7_cinder_block", "1");
	BOX_MODEL(scr_vec3_t(32, 4, 4), scr_vec3_t(0, 255, 0), "p7_cinder_block", "1");
	BOX_MODEL(scr_vec3_t(-12, 4, 4), scr_vec3_t(0, 240, 0), "p7_cinder_block", "1");
	BOX_MODEL(scr_vec3_t(12, -4, 4), scr_vec3_t(0, 315, 0), "p7_cinder_block", "1");
	BOX_MODEL(scr_vec3_t(-32, 4, 4), scr_vec3_t(0, 255, 0), "p7_cinder_block", "1");
}
#undef BOX_MODEL

#define BOX_SM(_origin, _angles, xmodel, scale) zbr::dynamicmap::create_sm(origin + zbr::util::rotate_point(angles, _origin), angles + _angles, 1, xmodel, scale, 0)
void zbr::dynamicmap::create_box_sm(scr_vec3_t origin, scr_vec3_t angles)
{
	BOX_SM(scr_vec3_t(40, -4, 4), scr_vec3_t(0, 260, 0), "p7_cinder_block", 1);
	BOX_SM(scr_vec3_t(0, -7, 9), scr_vec3_t(0, 270, 0), "p7_debris_wood_plank_old_96", 1);
	BOX_SM(scr_vec3_t(0, 7, 9), scr_vec3_t(0, 270, 0), "p7_debris_wood_plank_old_96", 1);
	BOX_SM(scr_vec3_t(-40, -4, 4), scr_vec3_t(0, 285, 0), "p7_cinder_block", 1);
	BOX_SM(scr_vec3_t(32, 4, 4), scr_vec3_t(0, 255, 0), "p7_cinder_block", 1);
	BOX_SM(scr_vec3_t(-12, 4, 4), scr_vec3_t(0, 240, 0), "p7_cinder_block", 1);
	BOX_SM(scr_vec3_t(12, -4, 4), scr_vec3_t(0, 315, 0), "p7_cinder_block", 1);
	BOX_SM(scr_vec3_t(-32, 4, 4), scr_vec3_t(0, 255, 0), "p7_cinder_block", 1);
}
#undef BOX_SM

#define BOX_SM(_origin, _angles, xmodel, scale) zbr::dynamicmap::create_gfx_sm(origin + zbr::util::rotate_point(angles, _origin), angles + _angles, xmodel, scale, 0)
void zbr::dynamicmap::create_box_gfx(scr_vec3_t origin, scr_vec3_t angles)
{
	BOX_SM(scr_vec3_t(40, -4, 4), scr_vec3_t(0, 260, 0), "p7_cinder_block", 1);
	BOX_SM(scr_vec3_t(0, -7, 9), scr_vec3_t(0, 270, 0), "p7_debris_wood_plank_old_96", 1);
	BOX_SM(scr_vec3_t(0, 7, 9), scr_vec3_t(0, 270, 0), "p7_debris_wood_plank_old_96", 1);
	BOX_SM(scr_vec3_t(-40, -4, 4), scr_vec3_t(0, 285, 0), "p7_cinder_block", 1);
	BOX_SM(scr_vec3_t(32, 4, 4), scr_vec3_t(0, 255, 0), "p7_cinder_block", 1);
	BOX_SM(scr_vec3_t(-12, 4, 4), scr_vec3_t(0, 240, 0), "p7_cinder_block", 1);
	BOX_SM(scr_vec3_t(12, -4, 4), scr_vec3_t(0, 315, 0), "p7_cinder_block", 1);
	BOX_SM(scr_vec3_t(-32, 4, 4), scr_vec3_t(0, 255, 0), "p7_cinder_block", 1);
}
#undef BOX_SM

void zbr::dynamicmap::create_gfx_sm(scr_vec3_t origin, scr_vec3_t angles, const char* xmodel, float scale, __int32 targetname)
{
	GfxStaticModelDrawInst gfxm;
	gfxm.cachedLod[0] = gfxm.cachedLod[1] = gfxm.cachedLod[2] = gfxm.cachedLod[3] = 0xFF;
	gfxm.hidden = 0;
	gfxm.numPosedBones = 0;

	gfxm.placement.origin = origin;
	AnglesToAxis(&angles, gfxm.placement.axis);
	gfxm.placement.scale = scale;

	gfxm.model = DB_FindXAssetHeader(xasset_xmodel, xmodel, false, 0);

	gfxm.center = origin;
	gfxm.mins = origin + util::rotate_point(angles, *(scr_vec3_t*)(gfxm.model + 0xF4) * scale);
	gfxm.maxs = origin + util::rotate_point(angles, *(scr_vec3_t*)(gfxm.model + 0x100) * scale);

	scr_vec3_t diff = *(scr_vec3_t*)(gfxm.model + 0x100) * scale - *(scr_vec3_t*)(gfxm.model + 0xF4) * scale;

	gfxm.flags = 0;
	gfxm.umbraGateId = -1;
	gfxm.invScaleSq = (1 / scale) * (1 / scale);
	gfxm.smid = 0; // todo?
	gfxm.scaledRadius = sqrt(diff.x * diff.x + diff.y * diff.y + diff.z * diff.z);

	static_models_gfx.push_back(gfxm);
}

void zbr::dynamicmap::create_sm(scr_vec3_t origin, scr_vec3_t angles, __int32 contents, const char* xmodel, float scale, __int32 targetname)
{
	cStaticModel_s box;
	box.xmodel = DB_FindXAssetHeader(xasset_xmodel, xmodel, false, 0);
	box.contents = contents;
	box.origin = origin;
	AnglesToAxis(&angles, box.invScaledAxis);
	box.absmin = origin + util::rotate_point(angles, *(scr_vec3_t*)(box.xmodel + 0xF4) * scale);
	box.absmax = origin + util::rotate_point(angles, *(scr_vec3_t*)(box.xmodel + 0x100) * scale);
	box.numBoneMtxs = 0;
	box.targetname = targetname;
	static_models.push_back(box);
}

void zbr::dynamicmap::create_static_misc_model(scr_vec3_t origin, scr_vec3_t angles, const char* model, const char* modelscale)
{
	strcat_s(dynmapstr, "\n{\nguid \"4321\"\n\"classname\" \"misc_model\"\n\"angles\" \"");
	create_formatted_vec3(angles);
	strcat_s(dynmapstr, "\"\n\"model\" \"");
	strcat_s(dynmapstr, model);
	strcat_s(dynmapstr, "\"\n\"origin\" \"");
	create_formatted_vec3(origin);
	strcat_s(dynmapstr, "\"\n\"lightingstate1\" \"1\"\n\"lightingstate2\" \"1\"\n\"lightingstate3\" \"1\"\n\"lightingstate4\" \"1\"\n\"modelscale\" \"");
	strcat_s(dynmapstr, modelscale);
	strcat_s(dynmapstr, "\"\n\"static\" \"1\"\n}");
	
}

void zbr::dynamicmap::create_formatted_vec3(scr_vec3_t vec)
{
	char buf[64]{ 0 };
	sprintf_s(buf, "%.1f %.1f %.1f", vec.x, vec.y, vec.z);
	strcat_s(dynmapstr, buf);
}


void zbr::util::rotate_points(scr_vec3_t angles, scr_vec3_t* const & points, int count)
{
	float cosa = cos(angles.z);
	float sina = sin(angles.z);
	float cosb = cos(angles.x);
	float sinb = sin(angles.x);
	float cosc = cos(angles.y);
	float sinc = sin(angles.y);

	float Axx = cosa * cosb;
	float Axy = cosa * sinb * sinc - sina * cosc;
	float Axz = cosa * sinb * cosc + sina * sinc;

	float Ayx = sina * cosb;
	float Ayy = sina * sinb * sinc + cosa * cosc;
	float Ayz = sina * sinb * cosc - cosa * sinc;

	float Azx = -sinb;
	float Azy = cosb * sinc;
	float Azz = cosb * cosc;

	for (int i = 0; i < count; i++)
	{
		points[i].x = Axx * points[i].x + Axy * points[i].y + Axz * points[i].z;
		points[i].y = Ayx * points[i].x + Ayy * points[i].y + Ayz * points[i].z;
		points[i].z = Azx * points[i].x + Azy * points[i].y + Azz * points[i].z;
	}
}

scr_vec3_t zbr::util::rotate_point(scr_vec3_t angles, scr_vec3_t point)
{
	zbr::util::rotate_points(angles, &point, 1);
	return point;
}

int zbr::table::load_from_disk(const char* path, zbr_table& data)
{
	std::ifstream ifs;
	ifs.open(path, std::ifstream::in | std::ifstream::binary);
	
	if (!ifs.is_open())
	{
		return 1;
	}

	__int32 tmp = 0;
	ifs.read((char*)&tmp, 4);

	if (tmp != ZBR_TABLE_MAGIC)
	{
		return 2;
	}

	data.deserialize(ifs);

	ifs.close();

	return 0;
}

int zbr::table::write_to_disk(const char* path, zbr_table& data)
{
	std::ofstream ofs;
	ofs.open(path, std::ofstream::out | std::ofstream::binary);
	
	if (!ofs.is_open())
	{
		return 1;
	}

	__int32 tmp = ZBR_TABLE_MAGIC;
	ofs.write((const char*)&tmp, sizeof(__int32));
	data.serialize(ofs);
	ofs.close();

	return 0;
}

char scratchbuf[1024]{ 0 };
bool zbr::table::csv_to_table(const char* id, zbr_table& table)
{
	char buf[256]{ 0 };
	((void(__fastcall*)(const char*, const char*, int, char*, int, const char*))REBASE(0x20D57A0))(id, ".csv", 256, buf, 1, (const char*)REBASE(0x1678CD24));

	std::ifstream ifs;
	ifs.open(buf, std::ifstream::in);

	if (!ifs.is_open())
	{
		return false;
	}

	table.init();

	int r = 0;
	int colcount = 0;
	do
	{
		ifs.getline(scratchbuf, 1024);
		
		char* tok = strtok(scratchbuf, ",");
		int c = 0;
		while (tok)
		{
			if (!r)
			{
				if (!strstr(tok, "#"))
				{
					++colcount;
				}
				
				goto next;
			}

			if (strstr(tok, "#"))
			{
				--c;
				goto next;
			}
			
			table.ensure(r, colcount);
			if (strstr(tok, "."))
			{
				float floatval = atof(tok);
				table.set_float(r - 1, c, floatval);
			}
			else
			{
				int intval = atoi(tok);
				table.set_int(r - 1, c, intval);
			}

		next:
			++c;
			tok = strtok(NULL, ",");
		}

		++r;
	} 
	while (!ifs.eof());

	ifs.close();
	return true;
}

bool zbr::table::table_to_csv(const char* id, zbr_table& table, const char** headers)
{
	// TODO
	return false;
}

zbr_table zbr::weapons::bal_table;
zbr_table zbr::weapons::class_table;
zbr_table zbr::weapons::role_table;
zbr_wudev_selection zbr::weapons::selection;
std::unordered_map<unsigned __int32, unsigned __int32> name_to_index;
bool zbr::weapons::load(const char* id, bool allow_create)
{
	if (!load_shared(allow_create))
	{
		return true;
	}

	char path[256]{ 0 };
	((void(__fastcall*)(const char*, const char*, int, char*, int, const char*))REBASE(0x20D57A0))(id, ".wud", 256, path, 1, (const char*)REBASE(0x1678CD24));
	
	if (!zbr::fs::exists(path))
	{
		if (!allow_create)
		{
			return false;
		}

		bal_table.init();
		bal_table.ensure(1, (unsigned __int32)WUBCN_SIZE);
		
		if (table::write_to_disk(path, bal_table))
		{
			return false;
		}
		
		return postload();
	}

	if (table::load_from_disk(path, bal_table))
	{
		return false;
	}

	bal_table.ensure(1, (unsigned __int32)WUBCN_SIZE);

	return postload();
}

bool zbr::weapons::load_shared(bool allow_create)
{
	char path[256]{ 0 };
	((void(__fastcall*)(const char*, const char*, int, char*, int, const char*))REBASE(0x20D57A0))("classes", ".wud", 256, path, 1, (const char*)REBASE(0x1678CD24));

	if (!zbr::fs::exists(path))
	{
		if (!allow_create)
		{
			Com_Error(2, "Unable to load weapon classes. Please reinstall ZBR from the workshop.");
			return false;
		}

		class_table.init();
		class_table.ensure(1, ZWC_SIZE);

		if (table::write_to_disk(path, class_table))
		{
			Com_Error(2, "Unable to create weapon classes.");
			return false;
		}
	}
	else
	{
		if (table::load_from_disk(path, class_table))
		{
			Com_Error(2, "Unable to load weapon classes. Please reinstall ZBR from the workshop.");
			return false;
		}
	}

	((void(__fastcall*)(const char*, const char*, int, char*, int, const char*))REBASE(0x20D57A0))("roles", ".wud", 256, path, 1, (const char*)REBASE(0x1678CD24));

	if (!zbr::fs::exists(path))
	{
		if (!allow_create)
		{
			Com_Error(2, "Unable to load weapon roles. Please reinstall ZBR from the workshop.");
			return false;
		}

		role_table.init();
		role_table.ensure(1, ZWR_SIZE);

		if (table::write_to_disk(path, role_table))
		{
			Com_Error(2, "Unable to create weapon roles.");
			return false;
		}
	}
	else
	{
		if (table::load_from_disk(path, role_table))
		{
			Com_Error(2, "Unable to load weapon roles. Please reinstall ZBR from the workshop.");
			return false;
		}
	}

	return true;
}

void zbr::weapons::dev_save(const char* name)
{
	char path[256]{ 0 };
	((void(__fastcall*)(const char*, const char*, int, char*, int, const char*))REBASE(0x20D57A0))(name, ".wud", 256, path, 1, (const char*)REBASE(0x1678CD24));
	table::write_to_disk(path, bal_table);

	((void(__fastcall*)(const char*, const char*, int, char*, int, const char*))REBASE(0x20D57A0))("classes", ".wud", 256, path, 1, (const char*)REBASE(0x1678CD24));
	table::write_to_disk(path, class_table);

	((void(__fastcall*)(const char*, const char*, int, char*, int, const char*))REBASE(0x20D57A0))("roles", ".wud", 256, path, 1, (const char*)REBASE(0x1678CD24));
	table::write_to_disk(path, role_table);
}

bool zbr::weapons::postload()
{
	// loaded disk data successfully, build lookup info, etc
	name_to_index.clear();

	for (unsigned int r = 1; r < bal_table.rows(); r++)
	{
		__int32 name;
		bal_table.get_int(r, WUBCN_HASHEDNAME, name);
		name_to_index[name] = r;
	}

	selection.name[0] = 0;
	selection.row = 0;

	zbr::weapons::update_weapon_stats();

	return true;
}

char weapon_debug_str[128];
void zbr::weapons::debug_select(__int64 index)
{
	__int64* weaponvariants = PTR_WeaponDefVariants;
	int numDefs = BG_GetNumWeaponsResult;
	auto name = *(char**)weaponvariants[index];
	strcpy_s(selection.name, name);

	if (!zbr::weapons::name_to_row(name, selection.row))
	{
		add_weapon(index, selection.row);
	}

	selection.wdindex = (__int32)index;
	selection.numattacks = 0;
	selection.numattacksburst = 0;
	selection.numattackssustain = 0;
	selection.numattacksdtburst = 0;
	selection.numattacksdtsustain = 0;
	selection.simulation_active = false;
}

void zbr::weapons::add_weapon(__int64 index, unsigned __int32& row)
{
	bal_table.add_rows(1);
	row = bal_table.rows() - 1;

	__int64* weaponvariants = PTR_WeaponDefVariants;
	auto name = *(char**)weaponvariants[index];

	auto hash = fnv1a(name);
	bal_table.set_int(row, WUBCN_HASHEDNAME, hash);
	name_to_index[hash] = row;
}

bool zbr::weapons::name_to_row(const char* name, unsigned __int32& row)
{
	auto hash = fnv1a(name);

	auto found = name_to_index.find(hash);
	if (found == name_to_index.end())
	{
		row = 0;
		return false;
	}

	row = found->second;
	return true;
}

const char* DEBUG_I_TO_ROLENAME(int _role)
{	
	switch (_role)
	{
	case 0: return "none";
	case 1: return "kuda";
	case 2: return "icr";
	case 3: return "kn44";
	case 4: return "m8a7";
	case 5: return "dmg";
	case 6: return "sheiva";
	case 7: return "hvk";
	case 8: return "m14";
	case 9: return "stg";
	case 10: return "famas";
	case 11: return "galil";
	case 12: return "garand";
	case 13: return "peacekeeper";
	case 14: return "m16";
	case 15: return "vmp";
	case 16: return "sten";
	case 17: return "vesper";
	case 18: return "weevil";
	case 19: return "ak74";
	case 20: return "hg40";
	case 21: return "mp40";
	case 22: return "razor";
	case 23: return "ppsh";
	case 24: return "tommy";
	case 25: return "pharo";
	case 26: return "locus";
	case 27: return "drakon";
	case 28: return "svg";
	case 29: return "krm";
	case 30: return "brecci";
	case 31: return "argus";
	case 32: return "haymaker";
	case 33: return "energy";
	case 34: return "rk5";
	case 35: return "lcar";
	case 36: return "pistol_energy";
	case 37: return "pistol";
	case 38: return "revolver";
	case 39: return "";
	}

	return "u";
}

const char* DEBUG_I_TO_CLASSNAME(int _class)
{
	switch (_class)
	{
	case 0: return "none";
	case 1: return "smg";
	case 2: return "ar";
	case 3: return "sniper";
	case 4: return "shotgun";
	case 5: return "pistol";
	case 6: return "lmg";
	}
	return "u";
}

char weapon_debug_str_l1[256];
char weapon_debug_str_l2[256];
char weapon_debug_str_l3[256];
char weapon_debug_str_l4[256];
void zbr::weapons::debug_draw()
{
	if (!selection.row)
	{
		return;
	}

	sprintf(weapon_debug_str, "%s(%u) - sim(%d|%d|%d|%d|%d)", selection.name, selection.row, selection.numattacks, selection.numattacksburst, selection.numattackssustain, selection.numattacksdtburst, selection.numattacksdtsustain);

	auto res = mods.find(selection.wdindex);

	int _role;
	int _class;
	bal_table.get_int(selection.row, WUBCN_ROLE, _role);
	bal_table.get_int(selection.row, WUBCN_CLASS, _class);

	float gen_bm, gen_hm, gen_hdm;
	bal_table.get_float(selection.row, WUBCN_GBMP, gen_bm);
	bal_table.get_float(selection.row, WUBCN_GHMP, gen_hm);
	bal_table.get_float(selection.row, WUBCN_GHDMP, gen_hdm);

	float tune_bm, tune_hm, tune_hdm;
	bal_table.get_float(selection.row, WUBCN_TBMP, tune_bm);
	bal_table.get_float(selection.row, WUBCN_THMP, tune_hm);
	bal_table.get_float(selection.row, WUBCN_THDMP, tune_hdm);

	if (res != mods.end())
	{
		
	}

	unsigned __int64 font1 = ((unsigned __int64(__fastcall*)())REBASE(0x1CAC8E0))();
	if (!font1) return;
	float scale = 0.45f;
	float color[4] = { 0.0f, 1.0f, 0.0f, 1.0f };
	((void(__fastcall*)(const char*, unsigned __int32, unsigned __int64, float, float, float, float, float, const float*, unsigned __int32))REBASE(0x1CD98D0))(weapon_debug_str, 0x7FFFFFFF, font1, 40.0, (float)((__int32*)(font1))[2] * scale + 180.0, scale, scale, 0.0f, color, 0);

	sprintf(weapon_debug_str_l1, "td(%s|%s|cbm: %.2f|chm: %.2f|chd: %.2f|tbm: %.2f|thm: %.2f|thd: %.2f|)", DEBUG_I_TO_CLASSNAME(_class), DEBUG_I_TO_ROLENAME(_role), 
		gen_bm, gen_hm, gen_hdm, 
		tune_bm, tune_hm, tune_hdm);
	((void(__fastcall*)(const char*, unsigned __int32, unsigned __int64, float, float, float, float, float, const float*, unsigned __int32))REBASE(0x1CD98D0))(weapon_debug_str_l1, 0x7FFFFFFF, font1, 40.0, (float)((__int32*)(font1))[2] * scale + 200.0, scale, scale, 0.0f, color, 0);

	auto modref = zbr::weapons::mods.find((unsigned short)(selection.wdindex & 511));

	if (modref == zbr::weapons::mods.end())
	{
		return;
	}

	int burst_shots;
	bal_table.get_int(selection.row, WUBCN_BURST, burst_shots);

	burst_shots = max(4, burst_shots);

	int burst_dt_shots;
	bal_table.get_int(selection.row, WUBCN_DTBURST, burst_dt_shots);

	burst_dt_shots = max(4, burst_dt_shots);

	int sus_shots;
	bal_table.get_int(selection.row, WUBCN_SUST, sus_shots);

	sus_shots = max(10, sus_shots);

	int sus_dt_shots;
	bal_table.get_int(selection.row, WUBCN_DTSUST, sus_dt_shots);

	sus_dt_shots = max(10, sus_dt_shots);

	__int64* weaponvariants = PTR_WeaponDefVariants;
	auto num_weapons = BG_GetNumWeaponsResult;
	auto variant = weaponvariants[selection.wdindex];
	auto WeaponDef = *(__int64*)(variant + 0x18);
	float damage_per_attack = ((__int32*)(WeaponDef + 0x928))[0];
	int dmpa;
	bal_table.get_int(selection.row, WUBCN_DMGATT, dmpa);

	int dmpa2;
	bal_table.get_int(selection.row, WUBCN_DMGATT2, dmpa2);
	damage_per_attack = ((float)dmpa + dmpa2) / 2;

	sprintf(weapon_debug_str_l2, "c1(bb: %d|bbdt: %d|2b: %d|2bdt: %d|sb: %d|sbdt: %d|2s: %d|2sdt: %d|)", 
		(int)(damage_per_attack * (float)burst_shots / 4 * modref->second.bodymod * modref->second.hitloc[HITLOC_TORSO_UPR]),
		(int)(damage_per_attack * (float)burst_dt_shots / 4 * modref->second.bodymod * modref->second.hitloc[HITLOC_TORSO_UPR]),
		(int)(damage_per_attack * (float)burst_shots / 4 * modref->second.headmod * modref->second.hitloc[HITLOC_HEAD]),
		(int)(damage_per_attack * (float)burst_dt_shots / 4 * modref->second.headmod * modref->second.hitloc[HITLOC_HEAD]),
		(int)(damage_per_attack * (float)sus_shots / 10 * modref->second.bodymod * modref->second.hitloc[HITLOC_TORSO_UPR]),
		(int)(damage_per_attack * (float)sus_dt_shots / 10 * modref->second.bodymod * modref->second.hitloc[HITLOC_TORSO_UPR]),
		(int)(damage_per_attack * (float)sus_shots / 10 * modref->second.headmod * modref->second.hitloc[HITLOC_HEAD]),
		(int)(damage_per_attack * (float)sus_dt_shots / 10 * modref->second.headmod * modref->second.hitloc[HITLOC_HEAD]));
	((void(__fastcall*)(const char*, unsigned __int32, unsigned __int64, float, float, float, float, float, const float*, unsigned __int32))REBASE(0x1CD98D0))(weapon_debug_str_l2, 0x7FFFFFFF, font1, 40.0, (float)((__int32*)(font1))[2] * scale + 220.0, scale, scale, 0.0f, color, 0);

	damage_per_attack *= 3;
	sprintf(weapon_debug_str_l3, "c20(bb: %d|bbdt: %d|2b: %d|2bdt: %d|sb: %d|sbdt: %d|2s: %d|2sdt: %d|)",
		(int)(damage_per_attack * (float)burst_shots / 4 * modref->second.bodymod * modref->second.hitloc[HITLOC_TORSO_UPR]),
		(int)(damage_per_attack * (float)burst_dt_shots / 4 * modref->second.bodymod * modref->second.hitloc[HITLOC_TORSO_UPR]),
		(int)(damage_per_attack * (float)burst_shots / 4 * modref->second.headmod * modref->second.hitloc[HITLOC_HEAD]),
		(int)(damage_per_attack * (float)burst_dt_shots / 4 * modref->second.headmod * modref->second.hitloc[HITLOC_HEAD]),
		(int)(damage_per_attack * (float)sus_shots / 10 * modref->second.bodymod * modref->second.hitloc[HITLOC_TORSO_UPR]),
		(int)(damage_per_attack * (float)sus_dt_shots / 10 * modref->second.bodymod * modref->second.hitloc[HITLOC_TORSO_UPR]),
		(int)(damage_per_attack * (float)sus_shots / 10 * modref->second.headmod * modref->second.hitloc[HITLOC_HEAD]),
		(int)(damage_per_attack * (float)sus_dt_shots / 10 * modref->second.headmod * modref->second.hitloc[HITLOC_HEAD]));
	((void(__fastcall*)(const char*, unsigned __int32, unsigned __int64, float, float, float, float, float, const float*, unsigned __int32))REBASE(0x1CD98D0))(weapon_debug_str_l3, 0x7FFFFFFF, font1, 40.0, (float)((__int32*)(font1))[2] * scale + 240.0, scale, scale, 0.0f, color, 0);


	sprintf(weapon_debug_str_l4, "r1(%d:%f), r2(%d:%f), r3(%d:%f)", ((__int32*)(WeaponDef + 0x928))[0], ((float*)(WeaponDef + 0x940))[0],
		((__int32*)(WeaponDef + 0x928))[1], ((float*)(WeaponDef + 0x940))[1],
		((__int32*)(WeaponDef + 0x928))[2], ((float*)(WeaponDef + 0x940))[2]		
		);
	((void(__fastcall*)(const char*, unsigned __int32, unsigned __int64, float, float, float, float, float, const float*, unsigned __int32))REBASE(0x1CD98D0))(weapon_debug_str_l4, 0x7FFFFFFF, font1, 40.0, (float)((__int32*)(font1))[2] * scale + 260.0, scale, scale, 0.0f, color, 0);
}

void zbr::weapons::debug_simulate(bool enabled, bool lh)
{
	__int64* weaponvariants = PTR_WeaponDefVariants;
	auto variant = weaponvariants[selection.wdindex];
	auto WeaponDef = *(__int64*)(variant + 0x18);

	if (enabled)
	{
		selection.numattacks = 0;
		selection.numattacksburst = 0;
		selection.numattackssustain = 0;
		selection.numattacksdtburst = 0;
		selection.numattacksdtsustain = 0;
		selection.simulation_active = true;
		selection.simulating_burst = true;
		selection.simulating_sustain = true;
		selection.simulating_dtburst = false;
		selection.simulating_dtsustain = false;
		selection.key_event_pressed = 200;
		selection.bIsDualWield = *(unsigned char*)(WeaponDef + 0xE8C);
		selection.dwindex = *(__int32*)(variant + 0x180);

		if (selection.bIsDualWield)
		{
			selection.key_event_pressed = lh ? 200 : 201;
		}

		// TODO: charge shot weapons like bows (or maybe we just do those by hand... kinda do not feel like dealing with the weapondef)

		selection.oldfiretype = *(__int32*)(WeaponDef + 0x80);
		switch (*(__int32*)(WeaponDef + 0x80))
		{
			case 1:
				*(__int32*)(WeaponDef + 0x80) = 0;
				break;
			case 2:
				*(__int32*)(WeaponDef + 0x80) = 3;
				break;
			case 8:
				*(__int32*)(WeaponDef + 0x80) = 9;
				break;
		}

		selection.isboltaction = *(unsigned char*)(WeaponDef + 0xE68);
		selection.ispressed = true;

		SPOOFED_CALL(((void(__fastcall*)(__int32 localclientnum, unsigned __int32 evt1, unsigned __int32 evt2, unsigned __int32 time))PTR_CL_KeyEvent), 0, (unsigned __int32)selection.key_event_pressed, (unsigned __int32)1, (unsigned __int32)GetTickCount());
	}
	else
	{
		selection.simulation_active = false;
		selection.simulating_burst = false;
		selection.simulating_sustain = false;
		selection.simulating_dtburst = false;
		selection.simulating_dtsustain = false;

		*(__int32*)(WeaponDef + 0x80) = selection.oldfiretype;

		bal_table.set_int(selection.row, WUBCN_BURST, selection.numattacksburst);
		bal_table.set_int(selection.row, WUBCN_SUST, selection.numattackssustain);
		bal_table.set_int(selection.row, WUBCN_DTBURST, selection.numattacksdtburst);
		bal_table.set_int(selection.row, WUBCN_DTSUST, selection.numattacksdtsustain);

		int damage = 0;
		int damage2 = 0;
		float hmod = 1.0;
		switch (*(__int32*)(WeaponDef + 0x6C)) // weapontype
		{
			case 0: // bullet
				damage = *(__int32*)(WeaponDef + 0x928);
				damage2 = damage * 2;
				hmod = 1.0; // (*(float**)(WeaponDef + 0x13B0))[HITLOC_HEAD];
				break;
			case 1: // grenade
				damage = damage2 = *(__int32*)(WeaponDef + 0xFB4); // inner expl
				break;
			case 2: // projectile

				damage2 = *(__int32*)(WeaponDef + 0x928); // impact
				damage = *(__int32*)(WeaponDef + 0xFB4); // explo
				
				if (damage < 10)
				{
					damage = damage2;
				}

				break;
		}

		// shotcount for spread weapons
		if (*(__int32*)(WeaponDef + 0x70) == 3 || *(__int32*)(WeaponDef + 0x70) == 0xD)
		{
			damage *= *(__int32*)(WeaponDef + 0x900);
			damage2 *= *(__int32*)(WeaponDef + 0x900);
		}

		bal_table.set_int(selection.row, WUBCN_DMGATT, damage);
		bal_table.set_int(selection.row, WUBCN_DMGATT2, damage2);
		bal_table.set_int(selection.row, WUBCN_DWNAME, selection.bIsDualWield ? fnv1a(*(char**)weaponvariants[selection.dwindex]) : 0);

		bal_table.set_float(selection.row, WUBCN_TBMP, 1.0);
		bal_table.set_float(selection.row, WUBCN_THMP, 1.0);
		bal_table.set_float(selection.row, WUBCN_THDMP, 1.0);

		
		bool is_highburst_adjust = false;
		
	redo:
		auto dps_1 = (float)max(is_highburst_adjust ? damage : 0, max(4, selection.numattacksburst) * damage / 4.0f);
		auto dps_2 = (float)max(is_highburst_adjust ? damage2 : 0, max(4, selection.numattacksdtburst) * damage2 / 4.0f);
		auto dps_3 = (float)max(10, selection.numattackssustain) * damage / 10.0f;
		auto dps_4 = (float)max(10, selection.numattacksdtsustain) * damage / 10.0f;

		auto dps_av = (dps_1 + dps_2 + dps_3 + dps_4) / 4;

		auto hdps_av = hmod * dps_av;

		if (abs(dps_av) < 0.001)
		{
			dps_av = 1;
		}

		if (!is_highburst_adjust && ((dps_av / 3) < ((damage + damage2) / 2))) // if anywhere from 1 to 2 shots equal the dps of the weapon
		{
			is_highburst_adjust = true;
		}

		float target_mp = 1.0f;
		float target_mp_head = 1.0f;

		// for weapons that have damage numbers > than their dps average, we need to pull them down to where their burst damage number isnt meeting standard dps, but rather their average is.
		// this is because you can have weapons doing 48k per shot at 1 shot per second which is *technically* 48k dps but in reality the engagement dps is much greater because we can shoot 48k instantly
		// for these weapons, we will adjust their instantaneous damage to be a different global cap. classes should adjust for risk in their global modifiers.
		// max instantaneous damage should be roughly 1/2 of target global dps (this would require 2 shots to achieve true dps)
		if (is_highburst_adjust)
		{
			target_mp = (dps_av / 3) / ((damage + damage2) / 2);
			target_mp_head = (hdps_av / 3) / (hmod * ((damage + damage2) / 2)) * 0.7;
		}

		bal_table.set_float(selection.row, WUBCN_GBMP, target_mp * DPS_GLOBAL_TARGET_BURST_R20 * DPS_STDBOOST_COMP / dps_av);
		bal_table.set_float(selection.row, WUBCN_GHMP, target_mp_head* DPS_GLOBAL_TARGET_BURST_HEAD_R20 * DPS_STDBOOST_COMP / hdps_av);
		bal_table.set_float(selection.row, WUBCN_GHDMP, 1.0);

		bal_table.set_int(selection.row, WUBCN_ROLE, ZWR_NONE);
		bal_table.set_int(selection.row, WUBCN_CLASS, ZWC_NONE);

		zbr::weapons::update_weapon_stats();

		SPOOFED_CALL(((void(__fastcall*)(__int32 localclientnum, unsigned __int32 evt1, unsigned __int32 evt2, unsigned __int32 time))PTR_CL_KeyEvent), 0, (unsigned __int32)selection.key_event_pressed, (unsigned __int32)0, (unsigned __int32)GetTickCount());
	}
}

// should automatically recalculate all the weapon info for all loaded balancing weapons
// this is the part of postload that generates reverse index matching etc
std::unordered_map<unsigned __int16, zbr_weapon_mod_table> zbr::weapons::mods;
void zbr::weapons::update_weapon_stats()
{
	mods.clear();

	__int64* weaponvariants = PTR_WeaponDefVariants;
	auto num_weapons = BG_GetNumWeaponsResult;

	for (int i = 0; i < num_weapons; i++)
	{
		auto variant = weaponvariants[i];
		auto index = i;
		auto WeaponDef = *(__int64*)(variant + 0x18);
		auto name = *(char**)variant;

		if (!name)
		{
			continue;
		}

		if (strstr(name, "dualoptic"))
		{
			int j = *(__int32*)(variant + 0x180);
			variant = weaponvariants[j];
			index = j;
			WeaponDef = *(__int64*)(variant + 0x18);
			name = *(char**)variant;
		}

		unsigned int row;
		if (!zbr::weapons::name_to_row(*(char**)variant, row))
		{
			continue;
		}

		auto mod = zbr_weapon_mod_table();

		// apply class data first
		int _class;
		if (bal_table.get_int(row, WUBCN_CLASS, _class))
		{
			mod._class = _class;

			if (_class == 3) // sniper
			{
				*(__int32*)(WeaponDef + 0x70) = 0; // rifle
				*(unsigned char*)(WeaponDef + 0xE65) = 1; // IsRifleBullet
				*(float*)(WeaponDef + 0x1258) = 0.0; // fAdsSpread
				*(unsigned char*)(WeaponDef + 0xEBF) = 1; // IsSniperWeapon
			}

			if (_class == 4) // shotgun
			{
				auto numshots = *(__int32*)(WeaponDef + 0x900);
				auto damage = ((__int32*)(WeaponDef + 0x928))[0];
				if (numshots > 4)
				{
					((__int32*)(WeaponDef + 0x928))[0] = (int)(damage * ((float)numshots / 4));
					*(__int32*)(WeaponDef + 0x900) = 4; // shotguns are now more consistent
				}
			}

			if (!class_table.get_float(_class, WCCN_BMP, mod.bodymod))
			{
				mod.bodymod = 1.0;
			}

			if (!class_table.get_float(_class, WCCN_HMP, mod.headmod))
			{
				mod.headmod = 1.0;
			}

			if (!class_table.get_float(_class, WCCN_HDMP, mod.hdmod))
			{
				mod.hdmod = 1.0;
			}
		}

		// fetch role data and copy into applicable spots
		int role;
		if (bal_table.get_int(row, WUBCN_ROLE, role))
		{
			mod._role = role;
			for (int j = HITLOC_NONE; j < HITLOC_NUM; j++)
			{
				if (!role_table.get_float(role, j + WRCN_MP_NONE, mod.hitloc[j]))
				{
					mod.hitloc[j] = 1.0;
				}
			}
		}

		float tmod;
		if (!bal_table.get_float(row, WUBCN_GBMP, tmod))
		{
			tmod = 1.0;
		}

		mod.bodymod *= tmod;

		if (!bal_table.get_float(row, WUBCN_TBMP, tmod))
		{
			tmod = 1.0;
		}

		mod.bodymod *= tmod;

		if (!bal_table.get_float(row, WUBCN_GHMP, tmod))
		{
			tmod = 1.0;
		}

		mod.headmod *= tmod;

		if (!bal_table.get_float(row, WUBCN_THMP, tmod))
		{
			tmod = 1.0;
		}

		mod.headmod *= tmod;

		if (!bal_table.get_float(row, WUBCN_GHDMP, tmod))
		{
			tmod = 1.0;
		}

		mod.hdmod *= tmod;

		if (!bal_table.get_float(row, WUBCN_THDMP, tmod))
		{
			tmod = 1.0;
		}

		mod.hdmod *= tmod;

		zbr::weapons::mods[(unsigned __int16)(i & 511)] = mod;

		if (bal_table.get_int(row, WUBCN_CLASS, _class) && _class)
		{
			float ranges[6];
			float damages[6];

			float tmp;
			if (!class_table.get_float(_class, WCCN_RANGE1, tmp) || abs(tmp) < 0.01)
			{
				goto skiprange;
			}

			// range1 is max damage
			ranges[0] = tmp;
			damages[0] = 1.0;

			if (!class_table.get_float(_class, WCCN_RANGE2, ranges[1]) || !class_table.get_float(_class, WCCN_RANGE2MP, damages[1]))
			{
				ranges[1] = ranges[0];
				damages[1] = damages[0];
			}

			if (!class_table.get_float(_class, WCCN_RANGE3, ranges[2]) || !class_table.get_float(_class, WCCN_RANGE3MP, damages[2]))
			{
				ranges[2] = ranges[1];
				damages[2] = damages[1];
			}

			if (!class_table.get_float(_class, WCCN_MAXRANGE, ranges[3]) || !class_table.get_float(_class, WCCN_MAXRANGEMP, damages[3]))
			{
				ranges[3] = ranges[2];
				damages[3] = damages[2];
			}

			ranges[5] = ranges[4] = ranges[3];
			damages[5] = damages[4] = damages[3];

			if (bal_table.get_int(row, WUBCN_ROLE, role) && role)
			{
				float rangemult;
				if (role_table.get_float(role, WRCN_RANGE1, rangemult))
				{
					ranges[0] *= rangemult;
				}
				if (role_table.get_float(role, WRCN_RANGE2, rangemult))
				{
					ranges[1] *= rangemult;
				}
				if (role_table.get_float(role, WRCN_RANGE3, rangemult))
				{
					ranges[2] *= rangemult;
				}
				if (role_table.get_float(role, WRCN_MAXRANGE, rangemult))
				{
					ranges[3] *= rangemult;
					ranges[5] = ranges[4] = ranges[3];
				}
			}

			variant = weaponvariants[i];
			index = i;
			WeaponDef = *(__int64*)(variant + 0x18);
			name = *(char**)variant;

			float dmgv1 = *(__int32*)(WeaponDef + 0x928); // range is 0x940

			for (int j = 0; j < 6; j++)
			{
				if (j)
				{
					((__int32*)(WeaponDef + 0x928))[j] = damages[j] * dmgv1;
				}
				((float*)(WeaponDef + 0x940))[j] = ranges[j];
			}
		}

		skiprange:;
	}
}

__int64 next_exec = 0;
void zbr::weapons::debug_simulate_frame()
{
	if (next_exec > GetTickCount64())
	{
		return;
	}

	next_exec = GetTickCount64();
	if (!selection.simulation_active)
	{
		next_exec += 10;
		return;
	}

	if (selection.isboltaction)
	{
		if (selection.ispressed)
		{
			SPOOFED_CALL(((void(__fastcall*)(__int32 localclientnum, unsigned __int32 evt1, unsigned __int32 evt2, unsigned __int32 time))PTR_CL_KeyEvent), 0, (unsigned __int32)selection.key_event_pressed, (unsigned __int32)0, (unsigned __int32)GetTickCount());
			selection.ispressed = false;
			next_exec += 10;
			return;
		}

		SPOOFED_CALL(((void(__fastcall*)(__int32 localclientnum, unsigned __int32 evt1, unsigned __int32 evt2, unsigned __int32 time))PTR_CL_KeyEvent), 0, (unsigned __int32)selection.key_event_pressed, (unsigned __int32)1, (unsigned __int32)GetTickCount());
		selection.ispressed = true;
		next_exec += 10;
		return;
	}
}

void zbr::weapons::debug_simulate_fired(__int64 gent, int gametime, int _event, int shotcount)
{
	if (!selection.simulation_active)
	{
		return;
	}

	selection.numattacks++;
	
	if (selection.simulating_burst)
	{
		selection.numattacksburst++;
	}

	if (selection.simulating_sustain)
	{
		selection.numattackssustain++;
	}

	if (selection.simulating_dtburst)
	{
		selection.numattacksdtburst++;
	}

	if (selection.simulating_dtsustain)
	{
		selection.numattacksdtsustain++;
	}
}

void* soundalloc_increase = 0;
void zbr::zone::expand_sounds()
{
	if (!soundalloc_increase)
	{
		auto ptr = *(__int64*)REBASE(0x1811AD00);
		auto osize = *(__int64*)REBASE(0x1811AD08);
		//ALOG("1234567: %p %d", ptr, osize);

		soundalloc_increase = malloc(0x50000000);
		//ALOG("12345678: %p", soundalloc_increase);
		memcpy(soundalloc_increase, (void*)ptr, osize);
		*(__int64*)REBASE(0x1811AD00) = (__int64)soundalloc_increase;
		*(__int64*)REBASE(0x1811AD08) = 0x50000000;

		auto delta = (__int64)soundalloc_increase - ptr;
		for (int i = 0; i < 128; i++)
		{
			auto addy = REBASE(0x1811AD10) + i * 0x68;
			if (*(__int64*)(0x40 + addy))
			{
				*(__int64*)(0x40 + addy) += delta;
				*(__int64*)(0x48 + addy) += delta;
			}
		}
	}
}

void zbr::gamesettings::make_hunted(zbr_gamesettings& out_settings)
{
	out_settings = zbr_gamesettings();
	out_settings.dmg_convt_efficiency.value._float = 0.0;
	out_settings.sudden_death_mode.value.___int32 = 0;
	out_settings.spawn_reduce_points.value._float = 1.0;
	out_settings.max_points_override.value.___int32 = 100000;
	out_settings.win_numpoints.value.___int32 = 100000;
	out_settings.no_wager_totems.value.___int32 = true;
}

void zbr::gamesettings::on_gametype_changed()
{
	switch (fnv1a(lobbystate.gamemode))
	{
		case FNV32("zbr"):
			Dvar_SetFromStringByName("zbr_teams_enabled", "0", true);
			Dvar_SetFromStringByName("zbr_teams_size", "1", true);
			zbr::lobbystate.team_size = 1;
			gamesettings::settings = zbr_gamesettings();
		break;
		case FNV32("zhunt"):
			Dvar_SetFromStringByName("zbr_teams_enabled", "1", true);
			Dvar_SetFromStringByName("zbr_teams_size", "7", true);
			zbr::lobbystate.team_size = 7;
			zbr::gamesettings::make_hunted(gamesettings::settings);
		break;
	}

	gamesettings::custom_settings = gamesettings::settings;
}
#endif