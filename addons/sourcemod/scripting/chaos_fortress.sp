//#define DEBUG_CHARACTER_CREATION
//#define DEBUG_ROUND_STATE
//#define DEBUG_KILLSTREAKS
//#define DEBUG_ONTAKEDAMAGE
//#define DEBUG_BUTTONS
//#define DEBUG_GAMERULES
//#define DEBUG_SOUNDS
//#define USE_PREVIEWS

//#define TESTING
//
//	- IMMEDIATE PLANS (things I am currently focusing on):
//		- Orbital Sniper:
//			- orbital_ult for ultimate
//			- Use the voicefx plugin's DSP things for his voice to reduce downloads
//
//	- BALANCE CHANGES (things to keep in mind for balancing)
//		- Mercenary:
//			- Required ult charge may be a bit low?
//		- Spookmaster Bones:
//			- Required ult charge is definitely too low, skeletons spawned by ult kills allow ults to snowball into each other.
//			- Any kill will grant a soul, not just melee. This encourages sitting at a distance and fishing for souls risk-free with Skull Servants instead of getting in and fighting.
//				- Make players drop timed soul pickups that the SB player needs to manually pick up to gain the soul. Upon being picked up, these souls begin to heal the user for 75 hp over the span of 3s.
//					- This is a fairly drastic change. Only do this if people think SB is overpowered (which is entirely possible).
//		- Orbital Sniper:
//			- There's not a lot of viable counterplay against an Orbital hugging the skybox. 
//				- This will be solved with future characters who also have decent ranged choices.
//
//	- MANDATORY TO-DO LIST (these MUST be done before the initial release):
//	- TODO: Everything that happens on client disconnect (possibly already covered, not sure).
//	- TODO: Check includes to see if I will need to add anything to the prerequisites section of the readme before launch.
//	- TODO: Finalize the wiki by updating each page with all of the changes.
//	- TODO: Detect healing from base game sources (mediguns, dispensers, crusader's crossbow bolts, mad milk) and give resources/ult charge for it.
//	- TODO: Separate the "description" section of "menu_display" into "desc_brief" and "desc_detailed".
//	- TODO: Make natives which share the names of FF2's natives and do the same things, so porting FF2 plugins is as simple as just changing the include file and recompiling.
//
//	- OPTIONAL TO-DO LIST (these do not need to be done for the initial release, but would be nice future additions):
//	- Translations
//
//	- MINOR BUGS (bugs which have no impact on gameplay and just sort of look bad):
//	- For some reason, players get equipped with the heavy's Apparatchik's Apparel cosmetic????????????????????????? It's invisible while alive but becomes visible on death. This has no effect on gameplay but it's really ugly. Honestly baffling.
//	- CF_PlayRandomSound and CF_GetRandomSound sometimes spit errors at the console and I have no clue why. It's not super frequent and it doesn't cause any lag, but I'm not sure I feel comfortable publishing CF with this.
//		- Most likely linked to the error pasted below.
//
//	- MAJOR BUGS (bugs which impact gameplay or character creation in any significant way):
//	- The "preserve" variable of cf_generic_wearable does not work. This may actually not be possible without an enormous workaround due to interference from TF2's source code, I am not sure.
//	- ORBITAL SNIPER: Rifle inexplicably cannot pick up ammo...
//	- ORBITAL SNIPER: Rifle tracer gets blocked by trigger brushes (spawn doors, control points, etc).
//
/*
L 10/19/2023 - 15:36:13: [SM] Exception reported: invalid handle 0 (error: 4)
L 10/19/2023 - 15:36:13: [SM] Blaming: chaos_fortress.smx
L 10/19/2023 - 15:36:13: [SM] Call stack trace:
L 10/19/2023 - 15:36:13: [SM]   [0] SMCParser.GetErrorString
L 10/19/2023 - 15:36:13: [SM]   [1] Line 122, C:\Users\micha\OneDrive\Desktop\Chaos Fortress\addons\sourcemod\scripting\include\cfgmap.inc::ConfigMap.ConfigMap
L 10/19/2023 - 15:36:13: [SM]   [2] Line 34, cf_sounds::GetRand
L 10/19/2023 - 15:36:13: [SM]   [3] Line 358, cf_sounds::Native_CF_GetRandomSound
L 10/19/2023 - 15:36:13: [SM]   [5] CF_GetRandomSound
L 10/19/2023 - 15:36:13: [SM]   [6] Line 156, C:\Users\micha\OneDrive\Desktop\Chaos Fortress\addons\sourcemod\scripting\cf_orbital.sp::Tracer_Disable
L 10/19/2023 - 15:36:13: [SM]   [7] Line 170, C:\Users\micha\OneDrive\Desktop\Chaos Fortress\addons\sourcemod\scripting\cf_orbital.sp::Tracer_PreThink
*/

#define PLUGIN_NAME           		  "Chaos Fortress"

#define PLUGIN_AUTHOR         "Spookmaster"
#define PLUGIN_DESCRIPTION    "Team Fortress 2 with custom classes!"
#define PLUGIN_VERSION        "0.2.0"
#define PLUGIN_URL            "https://github.com/SupremeSpookmaster/Chaos-Fortress"

#pragma semicolon 1

public Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_DESCRIPTION,
	version = PLUGIN_VERSION,
	url = PLUGIN_URL
};

#include <cf_core>

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CF_MakeNatives();
	return APLRes_Success;
}

public void OnPluginStart()
{
	HookEvent("post_inventory_application", PlayerReset);
	//HookEvent("player_spawn", PlayerReset);
	HookEvent("player_death", PlayerKilled);
	HookEvent("teamplay_waiting_begins", Waiting);
	HookEvent("teamplay_round_start", Waiting);
	HookEvent("teamplay_setup_finished", RoundStart);
	HookEvent("teamplay_round_win", RoundEnd);
	HookEvent("teamplay_round_stalemate", RoundEnd);
	HookEvent("player_changeclass", ClassChange);
	
	RegAdminCmd("cf_reloadrules", CF_ReloadRules, ADMFLAG_KICK, "Chaos Fortress: Reloads the settings in game_rules.cfg.");
	RegAdminCmd("cf_reloadcharacters", CF_ReloadCharacters, ADMFLAG_KICK, "Chaos Fortress: Reloads the character packs, as defined in characters.cfg.");
	
	CF_OnPluginStart();
}

#define SND_ADMINCOMMAND		"ui/cyoa_ping_in_progress.wav"

public OnMapStart()
{
	CF_MapStart();
	PrecacheSound(SND_ADMINCOMMAND);
}

public Action PlayerKilled(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	int victim = GetClientOfUserId(hEvent.GetInt("userid"));
	int inflictor = hEvent.GetInt("inflictor_entindex");
	int attacker = GetClientOfUserId(hEvent.GetInt("attacker"));
	
	bool ringer = false; 
	if (GetEventInt(hEvent, "death_flags") & TF_DEATHFLAG_DEADRINGER)
	{
		ringer = true;
	}
	
	if (IsValidClient(victim))
	{
		CF_PlayerKilled(victim, inflictor, attacker, ringer);
	}
	
	return Plugin_Continue;
}

public void Waiting(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	CF_Waiting();
}

public void ClassChange(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	int client = GetClientOfUserId(hEvent.GetInt("userid"));
	CF_ResetMadeStatus(client);
}

public void RoundStart(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	CF_RoundStart();
}

public void RoundEnd(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	CF_RoundEnd();
}

public void PlayerReset(Event gEvent, const char[] sEvName, bool bDontBroadcast)
{    
	int client = GetClientOfUserId(gEvent.GetInt("userid"));
	
	if (IsValidClient(client))
	{
		//Do it twice in a row because otherwise your viewmodels get screwed the first time you spawn.
		//I have no clue why. Yes, I tried delaying the class change by a frame. No, it did not work.
		//Yes, I am aware this is EXTREMELY suboptimal, no I am not happy I had to do it, but I'm sick of trying to make this thing work seamlessly so I just tossed in a hack and called it a day.
		CF_MakeCharacter(client, false);
		CF_MakeCharacter(client);
	}
	
	#if defined DEBUG_CHARACTER_CREATION
	if (CF_IsPlayerCharacter(client))
	{
		char buffer[255];
		CF_GetPlayerConfig(client, buffer, 255);
		
		CPrintToChatAll("%N spawned with the following character config: %s.", client, buffer);
	}
	else
	{
		CPrintToChatAll("%N spawned but is not a character, and therefore does not have a config.", client);
	}
	#endif
}

public Action CF_ReloadRules(int client, int args)
{	
	if (IsValidClient(client))
	{
		CPrintToChat(client, "{indigo}[Chaos Fortress] {default}Reloaded data/chaos_fortress/game_rules.cfg. {olive}View your console{default} to see the new game rules.");
		EmitSoundToClient(client, SND_ADMINCOMMAND);
		CF_SetGameRules(client);
	}	
	
	return Plugin_Continue;
}

public Action CF_ReloadCharacters(int client, int args)
{	
	if (IsValidClient(client))
	{
		CPrintToChat(client, "{indigo}[Chaos Fortress] {default}Reloaded data/chaos_fortress/characters.cfg. {olive}View the !characters menu{default} to see the updated character list.");
		EmitSoundToClient(client, SND_ADMINCOMMAND);
		CF_LoadCharacters(client);
	}	
	
	return Plugin_Continue;
}

public void OnClientDisconnect(int client)
{
	CF_UnmakeCharacter(client, false);
	CFC_Disconnect(client);
}

#if defined DEBUG_ONTAKEDAMAGE

public Action CF_OnTakeDamageAlive_Pre(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon,
	float damageForce[3], float damagePosition[3], int &damagecustom)
{
	CPrintToChatAll("Called CF_OnTakeDamageAlive_Pre. Damage is currently %i.", RoundFloat(damage));
	return Plugin_Continue;
}

public Action CF_OnTakeDamageAlive_Bonus(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon,
	float damageForce[3], float damagePosition[3], int &damagecustom)
{
	CPrintToChatAll("Called CF_OnTakeDamageAlive_Bonus. Damage is currently %i.", RoundFloat(damage));
	
	damage *= 2.0;
	
	CPrintToChatAll("Damage is now %i after attempting to double it.", RoundFloat(damage));
	
	return Plugin_Changed;
}

public Action CF_OnTakeDamageAlive_Resistance(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon,
	float damageForce[3], float damagePosition[3], int &damagecustom)
{
	CPrintToChatAll("Called CF_OnTakeDamageAlive_Resistance. Damage is currently %i.", RoundFloat(damage));
	
	damage *= 0.66;
	
	CPrintToChatAll("Damage is now %i after attempting to reduce it by 33%.", RoundFloat(damage));
	
	return Plugin_Changed;
}

public Action CF_OnTakeDamageAlive_Post(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon,
	float damageForce[3], float damagePosition[3], int &damagecustom)
{
	CPrintToChatAll("Called CF_OnTakeDamageAlive_Post. Damage is currently %i.", RoundFloat(damage));
	
	CPrintToChatAll("Gained %i imaginary tokens for dealing %i damage", RoundFloat(damage / 40.0), RoundFloat(damage));
	
	return Plugin_Continue;
}

#endif

#if defined DEBUG_BUTTONS

float DebugButtonsGameTimeToPreventLotsOfAnnoyingSpam = 0.0;
public Action CF_OnPlayerRunCmd(int client, int &buttons, int &impulse, int &weapon)
{
	if (GetGameTime() >= DebugButtonsGameTimeToPreventLotsOfAnnoyingSpam)
	{
		CPrintToChatAll("Detected a button press (this will run every second instead of every frame to prevent excessive chat spam).");
		DebugButtonsGameTimeToPreventLotsOfAnnoyingSpam = GetGameTime() + 1.0;
	}
	
	return Plugin_Continue;
}

public Action CF_OnPlayerM2(int client, int &buttons, int &impulse, int &weapon)
{
	CPrintToChatAll("Detected a right-click.");

	return Plugin_Continue;
}

public Action CF_OnPlayerM3(int client, int &buttons, int &impulse, int &weapon)
{
	CPrintToChatAll("Detected a mouse3.");
	
	return Plugin_Continue;
}

public Action CF_OnPlayerReload(int client, int &buttons, int &impulse, int &weapon)
{
	CPrintToChatAll("Detected a reload.");
	
	return Plugin_Continue;
}

public Action CF_OnPlayerTab(int client, int &buttons, int &impulse, int &weapon)
{
	CPrintToChatAll("Detected a tab.");
	
	return Plugin_Continue;
}

public Action CF_OnPlayerJump(int client, int &buttons, int &impulse, int &weapon)
{
	CPrintToChatAll("Detected a jump.");
	
	return Plugin_Continue;
}

public Action CF_OnPlayerCrouch(int client, int &buttons, int &impulse, int &weapon)
{
	CPrintToChatAll("Detected a crouch.");
	
	return Plugin_Continue;
}

public void CF_OnPlayerCallForMedic(int client)
{
	CPrintToChatAll("Detected a medic call.");
}

#endif

public void OnEntityDestroyed(int entity)
{
	if (!IsValidEntity(entity) || entity < 0 || entity > 2049)
		return;
		
	CFW_OnEntityDestroyed(entity);
	CFC_OnEntityDestroyed(entity);
	CFA_OnEntityDestroyed(entity);
}