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
//	- IMMEDIATE PLANS:
//		- Spookmaster Bones:
//			- Make him quieter.
//		- Orbital Sniper:
//			- Make custom sounds and implement them. Remove the DSP effect attribute once this is done.
//		- Count Heavnich:
//			- Optional: properly implement mega deflector weapon sounds.
//		- Demopan:
//			- Figure out a way to let custom damage sources deal damage to shields.
//			- Include shields in the generic AOE native.
//			- Include shields in the default trace.
//			- Tinker with shield charge attributes.
//		- Future Development:
//			- Look into using the m_afButtonForced property.
//
//	- BALANCE CHANGES (things to keep in mind for balancing)
//		////////////////////////////////////////////
//		- Mercenary:
//			- None! (Pending public opinion during beta)
//		////////////////////////////////////////////
//		- Spookmaster Bones:
//			- Any kill will grant a soul, not just melee. This encourages sitting at a distance and fishing for souls risk-free with Skull Servants instead of getting in and fighting.
//				- Make players drop timed soul pickups that the SB player needs to manually pick up to gain the soul. Upon being picked up, these souls immediately heal the user for 75 HP.
//					- This is a fairly drastic change. Only do this if people think SB is overpowered.
//					- Thanks to all of the work we just put into fake health kits, this should be super easy to implement!
//		////////////////////////////////////////////
//		- Orbital Sniper:
//			- There's not a lot of viable counterplay against an Orbital hugging the skybox, besides having another Orbital counter-snipe them.
//				- This will be solved with future characters who also have decent ranged choices.
//		////////////////////////////////////////////
//		- Count Heavnich:
//			- "Chow Down" might be too strong compared to "Share Sandvich", resulting in players never using Share.
//		////////////////////////////////////////////
//		- Demopan:
//			- Using Profit Blast to blast jump *might* give him too much mobility for a tank.
//
//	- MANDATORY TO-DO LIST (these MUST be done before the initial release):
//	- TODO: Rewrite the DoAbility system so that the forward can be used to prevent an ability from being activated
//	- TODO: Disable random crits on the beta test server (melee characters like Spookmaster and Demopan are utterly busted with random crits).
//	- TODO: Test all game modes (except for CTF which won't be officially supported):
//		- [X] Payload
//		- [ ] Payload Race
//		- [ ] Control Points
//		- [ ] King of the Hill
//	- TODO: Everything that happens on client disconnect (possibly already covered, not sure).
//	- TODO: Check includes to see if I will need to add anything to the prerequisites section of the readme before launch.
//	- TODO: Finalize the wiki by updating each page with all of the changes.
//	- TODO: Add support for translations. This will be a huge pain in the ass, but does not need to be done until public release.
//
//	- OPTIONAL TO-DO LIST (these do not need to be done for the initial release, but would be nice future additions):
//	- Separate the "description" section of "menu_display" into "desc_brief" and "desc_detailed".
//	- Make natives which share the names of FF2's natives and do the same things, so porting FF2 plugins is as simple as just changing the include file and recompiling.
//
//	- MINOR BUGS (bugs which have no impact on gameplay and just sort of look bad):
//	- For some reason, players get equipped with the heavy's Apparatchik's Apparel cosmetic????????????????????????? It's invisible while alive but becomes visible on death. This has no effect on gameplay but it's really ugly. Honestly baffling.
//	- Certain hats, when equipped via the wearable system, usually do not visually appear on bots (but they do work *sometimes*). Count Heavnich's "Noble Amassment of Hats" is an example of such a hat. 
//	- COUNT HEAVNICH: I don't know how, but "Chow Down" *sometimes* still causes you to T-pose when it ends. This is fixed immediately by switching weapons, and has no permanent side effects. It does look very unprofessional, though, so I am inclined to find a fix if possible.
//	- DEMOPAN: Becoming übercharged on BLU team causes your cosmetics to use the RED team's über texture.
//
//	- MAJOR BUGS (bugs which impact gameplay or character creation in any significant way):
//	- DEVELOPMENT: The "preserve" variable of cf_generic_wearable does not work. This may actually not be possible without an enormous workaround due to interference from TF2's source code, I am not sure.
//			- Scrap this feature entirely and remove all mentions of it from the code. This will be a giant pain in the ass but does not need to be done until public release.
//	- DEVELOPMENT: I don't know what I did, but suddenly friendly projectiles cannot pass through medigun shields. What the fuck.
//			- Once this is fixed, medigun shields will FINALLY be done.
//	- GAMEPLAY: The game is having that issue again where it becomes EXTREMELY laggy as soon as the round starts.
//			- Current Theory: None. There's not a memory leak, so it can't be that, and all of my other theories are disproven by the fact that the game runs fine in the pre-round.
//
//	- PRESUMED UNFIXABLE (major bugs which I don't believe can be fixed with my current SourceMod expertise. The best thing you can do is classify these as exploits and punish them as such):
//		- DEMOPAN: Enemies can get stuck in his shield if they walk into it while it is held. Sadly, the only known way to fix this results in the shield becoming completely useless while held, and doesn't even solve the problem because you can still get players stuck by releasing the shield at just the right moment.

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

#include "chaos_fortress/cf_core.sp"

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
	HookEvent("player_healed", PlayerHealed);
	
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

public Action PlayerHealed(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	int patient = GetClientOfUserId(hEvent.GetInt("patient"));
	int healer = hEvent.GetInt("healer");
	int amount = GetClientOfUserId(hEvent.GetInt("amount"));

	if (IsValidClient(healer) && healer != patient)
	{
		CFA_GiveChargesForHealing(healer, float(amount));
		CFA_AddHealingPoints(healer, amount);
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
	CFA_Disconnect(client);
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