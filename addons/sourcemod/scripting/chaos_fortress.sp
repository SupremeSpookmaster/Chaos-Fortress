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
//		- Gadgeteer:
//			- Change Toolbox Toss Drones to work via an NPC once the NPC system is done. Sucks to throw all of the work down the drain, but NPCs just work better and don't require ten million workarounds.
//			- Add M3 ability - Support Drone:
//				- Utilizes NPCs.
//				- Teleports a Support Drone to the user's crosshairs (very short max range).
//				- Support Drones automatically move to the weakest ally within a certain range and will heal them at a rate of 20 HP/s. 
//				- All allies within the heal radius who are not the intended target are healed for 10 HP/s.
//				- Support Drones will always heal their intended target for a minimum of 5 seconds. If a different player becomes the "weakest nearby ally", they are ignored until the minimum heal duration has passed.
//				- If there are no valid allies within their detection radius, they will default to attempting to heal their owner. If their owner is not alive, they will find the closest ally.
//				- 250 max HP.
//				- 400 HU/s movement speed.
//				- 120 HU heal radius.
//				- Heals itself at a rate of 10 HP/s.
//				- Cannot be used if the user already has an active Support Drone.
//				- Costs 300 Scrap Metal.
//				- Should use the Robot Destruction "A" robot for the model.
//			- Add R ability - Command Support Drone:
//				- Cannot be used if the user does not have an active Support Drone.
//				- Costs nothing, has no cooldown.
//				- Finds the ally closest to the user's cursor, within 100 HU. If this ally is valid, the Support Drone will immediately drop what it is doing and prioritize that ally.
//			- Write the code for Automation Annihilation.
//		- ALL:
//			- Add parameters for weapons which allow custom weapon models. These will need to cooperate with generic_abilities and CF_ForceViewmodelAnimation. This removes a dependency and allows easier customization.
//			- Fix the weird super-long delay with ForceViewmodelAnimation on SB's Soul Discard. This is most likely an issue with SB's viewmodel anims themselves.
//			- Convert SpawnParticle and AttachParticleToEntity to work via temp ents EVENTUALLY, then recompile all plugins. This will reduce edict usage by a ton. Doesn't need to be done immediately as edict crashes are not a huge concern as of the Fake Particle System fix.
//		- The Gambler:
//			- Begin work.
//		- NPCs:
//			- Figure out why rapidly hitting NPCs in the legs with projectiles causes them to teleport out of the map.
//			- Make NPCs collide with all of the following entities, and make them work as intended when they collide:
//				- Sandman Balls - should deal damage and slow the NPC temporarily, then bounce off and become inert. Damage should be calculated at the moment the ball spawns, and be stored in a global array.
//				- Flying Guillotine - should be deleted on contact and then deal damage, apply bleed, and emit a sound. Damage should be calculated at the moment the cleaver spawns, and be stored in a global array.
//				- Jars (milk, jarate, maybe gas?) - should be deleted on contact and then spawn particle, play sound, and apply milk/jarate effects.
//			- Add natives for basic attacks (should have generic melee, generic projectile, and generic bullets).
//			- Add an option to make NPCs use the body_pitch and body_yaw pose parameters to automatically look towards their target destination.
//			- Fix collision (likely related to bounding box and lag comp).
//			- Add SetGoalEntity.
//			//////// EVERYTHING BELOW HERE REQUIRES THE PORTABLE NPC SYSTEM TO BE A STANDALONE PLUGIN, PORT NPCS TO THE PORTABLE NPC SYSTEM ONCE THE ABOVE ARE FINISHED: //////// 
//			- Make custom melee hitreg so it doesn't sound like you're hitting a wall every time you hit an NPC with melee.
//				- Instead of a custom attribute, just grab the 263 and 264 attributes from all melee weapons at the moment they attack and apply those to a global array, then set the attributes to 0.0 and restore them after running our custom melee logic.
//			- Manually simulate explosions. Can be done by detecting when an explosive entity spawns (rockets, pills, sentry rockets, stickies), then calculating its radius and falloff based on attributes from the thing that fired it. When the entity despawns or collides with something, simulate the explosion manually using those stats. Damage can be grabbed at the time of the explosion. Pills will need to check if they're colliding with a valid enemy. Also don't forget the Loch-n-Load's "disappear on hitting walls" attribute.
//			- Add lag compensation.
//			- Add an option to make NPCs automatically enter their air/swim animations if airborne or in the water.
//			- Add customizable sounds for any number of custom triggers.
//				- Should include: sound_damaged, sound_impact, sound_kill, and sound_killed as officially supported sound cues, then have "CFNPC.PlaySound" as a native to play custom cues.
//			- NPC CFGs should function like FF2 boss CFGs, with sections for equipped models, name, etc. One of these sections should be called "functionality", where devs can add and tweak AI modifiers to control how the NPC behaves.
//			- Make a few basic AI templates. These should be split into categories governing movement and combat.
//				- Chaser (movement): chases the nearest player. Can be customized to specify the target's team as well as whether or not it will predict their movement.
//				- Zoner (movement): runs away from players if they are too close, but will chase them if they are too far. Can be customized to specify the team to flee from/chase, as well as whether it turns away or strafes backwards when fleeing.
//				- Brawler (combat): punches enemies who get too close. Should be customizable to set attack interval, damage, melee range, and melee width.
//				- Gunner (combat): shoots enemies who are within a certain range. Should be customizable in the same way as Brawler, but also include options for spread, clip size, falloff, ramp-up, and reload time.
//				- Barrager (combat): shoots enemies with projectiles. Should be customizable in the same way as gunner, but also include options for explosive projectiles.
//			- NPC behavior should be split into 4 basic categories:
//				- Movement logic.
//				- Combat logic.
//				- "Aspects", AKA passive effects.
//				- "Abilities", AKA special abilities that can only be activated by custom NPC logic.
//				- Movement and combat will typically only be used by extremely basic NPCs, where as aspects and abilities are used to create more complex NPCs.
//			- Allow server owners to configure several settings:
//				- Max NPCs, max gibs, max model attachments per NPC, whether or not NPCs should have visible health bars, whether or not the NPC's remaining HP should be displayed on the user's HUD when the NPC is damaged.
//			- Some day down the road (not immediately), add the Fake Player Model system. Should actually be fairly easy to implement given all of the control we have over animations; we just copy the user's current sequence, pose parameters, and gestures to the NPC every frame, then when we animate the NPC we stop copying until the animation is done.
//
//	- BALANCE CHANGES (things to keep in mind for balancing)
//		////////////////////////////////////////////
//		-ALL:
//			- Ult charge rate may be way too slow across the board. We will find out during the public beta test.
//		////////////////////////////////////////////
//		- Mercenary:
//			- None! (Pending public opinion during beta)
//		////////////////////////////////////////////
//		- Spookmaster Bones:
//			- The red cape is an iconic part of his design, but it is bound to cause team recognition problems for players who are unfamiliar with the character.
//				- Fix the model to use proper team colors if people complain about it a lot.
//			- Turns into an unstoppable monster at max souls. This might just be because of random crits giving him triple damage 60% of the time. Test further after removing random crits.
//			- Any kill will grant a soul, not just melee. This encourages sitting at a distance and fishing for souls risk-free with Skull Servants instead of getting in and fighting.
//				- Make players drop timed soul pickups that the SB player needs to manually pick up to gain the soul. Upon being picked up, these souls immediately heal the user for 75 HP and the player gains 1 Soul to do whatever they want with.
//					- This is a fairly drastic change. Only do this if people think SB is overpowered or boring to play.
//					- Thanks to all of the work we just put into fake health kits, this should be super easy to implement!
//		////////////////////////////////////////////
//		- Orbital Sniper:
//			- Assuming full charge, the rifle's lower and upper damage bounds without external modifiers should be:
//				- LOWEST: 149 (bodyshot, no height advantage bonus)
//				- HIGHEST: 740 (headshot, max height advantage bonus)
//				- This is not a balance issue, just a general note for future reference.
//		////////////////////////////////////////////
//		- Count Heavnich:
//			- "Chow Down" might be too strong compared to "Share Sandvich", resulting in players never using Share.
//				- Maybe make Chow cost two Sandviches, then increase Sandvich base regen rate?
//		////////////////////////////////////////////
//		- Demopan:
//			- Refined Protection, as incredibly cool as it is, REALLY doesn't fit with his playstyle. Like, at all. Would probably be best to put it on a different character and replace Demopan's R ability with something else.
//		////////////////////////////////////////////
//		- Christian Brutal Sniper:
//			- None! (Pending public reception during open beta).
//		////////////////////////////////////////////
//		- Doktor Medick:
//			- He is definitely WAY too tanky for a healer. He regens while healing, can give himself res while healing, and can toss a healing splash that heals an entire crowd PLUS himself for 80 HP, and even if you DO put him in a dire situation, he can try to teleport away. I wager he will be a bit problematic on launch.
//		////////////////////////////////////////////
//		- Gadgeteer:
//			- Notes regarding Drone stats:
//				- Can fire twice per second.
//				- Deals 20 damage per shot, for a total DPS of 40 per Drone, not counting Supercharge.
//				- 100 HP per Drone.
//				- Can detect targets within 800 HU, and will not stop firing as long as that target is within 1100 HU and maintains line-of-sight.
//				- Turns at a rate of 2 degrees per frame (126 per second).
//
//	- MANDATORY TO-DO LIST (these MUST be done before the initial release):
//	- TODO: Write the worldtext helper plugin and use it for Gadgeteer's Drones and MAYBE medigun shields.
//	- TODO: Make Demopan's fancy ult delay an officially supported feature that you can enable or disable by setting "warning_delay" in the ultimate stats section.
//	- TODO: Disable random crits on the beta test server (melee characters like Spookmaster and Demopan are utterly busted with random crits).
//	- TODO: Test all game modes (except for CTF which won't be officially supported):
//		- [X] Payload
//		- [ ] Payload Race
//		- [ ] Control Points
//		- [ ] King of the Hill
//	- TODO: Finalize the wiki by updating each page with all of the changes. This will take several days at the bare minimum.
//	- TODO: Add support for translations. This will be a huge pain in the ass, but does not need to be done until public release.
//	- TODO: Make sure plugin variables automatically get reset on map change. I imagine this will not be a problem, but if it's like ZR and variables don't get reset automatically, it's going to be a nightmare to deal with.
//	- TODO: The following plugins are mandatory for CF to run, and need to be added to the GitHub's prerequisites:
//		- None, currently.
//	- TODO: The current development branch has the following fatal issues which break the plugin, and will need to be fixed in the release branch:
//		- None, currently.
//	- TODO: Implement notes in the #cf-notes channel.
//
//	- OPTIONAL TO-DO LIST (these do not need to be done for the initial release, but would be nice future additions):
//	- Separate the "description" section of "menu_display" into "desc_brief" and "desc_detailed".
//		- "desc_brief" will be what shows up when you first open a character's page in the !characters menu. "desc_detailed" is a secondary menu like the lore button, but with multiple pages of detailed info.
//
//	- MINOR BUGS (bugs which have no impact on gameplay and just sort of look bad):
//	- For some reason, players get equipped with the heavy's Apparatchik's Apparel cosmetic????????????????????????? It's invisible while alive but becomes visible on death and also displays in the 3D player model shown in the HUD. This has no effect on gameplay but it's really ugly. Honestly baffling.
//	- Certain hats, when equipped via the wearable system, do not visually appear on bots (but they do work *sometimes*). Count Heavnich's "Noble Amassment of Hats" is an example of such a hat. 
//	- COUNT HEAVNICH: I don't know how, but "Chow Down" *sometimes* still causes you to T-pose when it ends. This is fixed immediately by switching weapons, and has no permanent side effects. It does look very unprofessional, though, so I am inclined to find a fix if possible.
//	- CF_Teleport can get you stuck in enemy spawn doors. I'm not going to bother fixing this, if you're enough of a scumbag to try to teleport into the enemy's spawn you deserve to get stuck and die.
//	- CF_ForceViewmodelAnimation causes the user to T-Pose if they go through the resupply event mid-sequence. This does not actually do anything, as switching their weapon immediately fixes it. Still looks pretty bad.
//
//	- MAJOR BUGS (bugs which impact gameplay or character creation in any significant way):
//	- DEVELOPMENT: The "preserve" variable of cf_generic_wearable does not work. This feature may actually not be possible without an enormous workaround due to interference from TF2's source code, I am not sure.
//			- Scrap this feature entirely and remove all mentions of it from the code. This will be a giant pain in the ass but does not need to be done until public release.
//	- ALL: All projectiles are affected by every instance of CF_OnGenericProjectileTeamChanged (excluding Gadgeteer) because I forgot to add a filter. Oops.
//	- The x64 update might kill Chaos Fortress before it's even released. Look into leaning away from DHooks.
//	- DEVELOPMENT: Something is leaking edicts again...................................
//
//	- PRESUMED UNFIXABLE (major bugs which I don't believe can be fixed with my current SourceMod expertise. The best thing you can do is classify these as exploits and punish them as such):
//	- DEMOPAN: Enemies can get stuck in his shield if they walk into it while it is held. Demopans can abuse this to intentionally get enemies stuck for free kills. Sadly, the only known way to fix this results in the shield becoming completely useless while held, and doesn't even solve the problem because you can still get players stuck by releasing the shield at just the right moment.
//
//	- THINGS TO KEEP IN MIND FOR FUTURE REFERENCE:
//		- Cool and/or Frequently-Used Particle Effects:
//			- doomsday_tentpole_vanish01 (big, green, pole-shaped flash, could be used for a reskin of SSB's Necrotic Blast)
//			- raygun_projectile_blue, raygun_projectile_red, raygun_projectile_blue_crit, raygun_projectile_red_crit
//			- rd_robot_explosion
//			- eyeboss_tp_vortex, eyeboss_death_vortex
//			- spell_fireball_small_blue, spell_fireball_small_red
//			- merasmus_tp_flash02, merasmus_spawn_flash, merasmus_spawn_flash2
//			- merasmus_dazed_explosion
//			- merasmus_zap
//			- spell_lightningball_hit_red, spell_lightningball_hit_blue
//			- drg_cow_explosioncore_charged, drg_cow_explosioncore_charged_blue
//			- flaregun_trail_red, flaregun_trail_blue
//			- charge_up
//			- crit_text, heal_text, hit_text, minicrit_text, miss_text, mvm_pow_bam, mvm_pow_crack, mvm_pow_crash, mvm_pow_crit, mvm_pow_punch, mvm_pow_smash
//			- duck_collect_green
//			- dxhr_lightningball_parent_red, dxhr_lightningball_parent_blue
//			- eyeboss_team_blue, eyeboss_team_red
//			- green_vortex_rain, green_vortex_rain_3
//			- halloween_pickup_active_green_2, halloween_pickup_active_red_2
//			- hammer_bones_kickup, hammer_dust_kickup
//			- hammer_lock_vanish01, hammer_souls_rising
//			- healthgained_blu, healthgained_blu_2, healthgained_blu_giant, healthgained_blu_giant_2, healthgained_blu_large, healthgained_blu_large_2
//			- healthgained_red, healthgained_red_2, healthgained_red_giant, healthgained_red_giant_2, healthgained_red_large, healthgained_red_large_2
//			- heavy_ring_of_fire
//			- hwn_skeleton_glow_blue, hwn_skeleton_glow_red
//			- scorchshot_trail_red, scorchshot_trail_blue
//			- smoke_marker (blue beacon effect)
//			- spell_lightningball_parent_blue, spell_lightningball_parent_red
//		- Cool and/or Frequently-Used Netprops:
//			- m_flNextPrimaryAttack
//			- m_hOwnerEntity, m_iTeamNum
//			- m_vecOrigin, m_angRotation, m_vecVelocity

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
	HookEvent("player_death", PlayerKilled_Pre, EventHookMode_Pre);
	HookEvent("teamplay_waiting_begins", Waiting);
	HookEvent("teamplay_round_start", Waiting);
	HookEvent("teamplay_setup_finished", RoundStart);
	HookEvent("teamplay_round_win", RoundEnd);
	HookEvent("teamplay_round_stalemate", RoundEnd);
	HookEvent("player_changeclass", ClassChange);
	HookEvent("player_healed", PlayerHealed);
	HookEvent("crossbow_heal", PlayerHealed_Crossbow);
	
	RegAdminCmd("cf_reloadrules", CF_ReloadRules, ADMFLAG_KICK, "Chaos Fortress: Reloads the settings in game_rules.cfg.");
	RegAdminCmd("cf_reloadcharacters", CF_ReloadCharacters, ADMFLAG_KICK, "Chaos Fortress: Reloads the character packs, as defined in characters.cfg.");
	RegAdminCmd("cf_makecharacter", CF_ForceCharacter, ADMFLAG_KICK, "Chaos Fortress: Forces a client to become the specified character.");
	
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

public Action PlayerKilled_Pre(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	int victim = GetClientOfUserId(hEvent.GetInt("userid"));
	int inflictor = hEvent.GetInt("inflictor_entindex");
	int custom = hEvent.GetInt("customkill");
	int critType = hEvent.GetInt("crit_type");
	int bits = hEvent.GetInt("damagebits");
	int attacker = GetClientOfUserId(hEvent.GetInt("attacker"));
	char weapon[255], console[255];
	hEvent.GetString("weapon", weapon, sizeof(weapon), "Generic");
	hEvent.GetString("weapon_logclassname", weapon, sizeof(weapon), "Generic");
	
	bool ringer = false; 
	if (GetEventInt(hEvent, "death_flags") & TF_DEATHFLAG_DEADRINGER)
	{
		ringer = true;
	}
	
	Action result = Plugin_Continue;
	
	if (IsValidClient(victim))
	{
		result = CF_PlayerKilled_Pre(victim, inflictor, attacker, weapon, console, custom, ringer, critType, bits);
		
		hEvent.SetInt("userid", (IsValidClient(victim) ? GetClientUserId(victim) : 0));
		hEvent.SetInt("inflictor_entindex", inflictor);
		hEvent.SetInt("customkill", custom);
		hEvent.SetInt("crit_type", critType);
		
		if (critType > 0 && critType < 3 && ((bits & DMG_CRIT) == 0))
			bits |= DMG_CRIT;
		hEvent.SetInt("damagebits", bits);
		
		hEvent.SetInt("attacker", (IsValidClient(attacker) ? GetClientUserId(attacker) : 0));
		hEvent.SetString("weapon", weapon);
		hEvent.SetString("weapon_logclassname", console);
	}
	
	return result;
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

public Action PlayerHealed_Crossbow(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	int healer = hEvent.GetInt("healer");
	int patient = GetClientOfUserId(hEvent.GetInt("target"));
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
		CF_MakeCharacter(client, _, _, _, "You became: %s");
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

public Action CF_ForceCharacter(int client, int args)
{	
	if (args < 2 || args > 32)
	{
		ReplyToCommand(client, "[Chaos Fortress] Usage: cf_makecharacter <client> <name of character's config> <optional message printed to client's screen>");
		return Plugin_Continue;
	}
		
	char name[32], character[255], message[255];
	GetCmdArg(1, name, sizeof(name));
	GetCmdArg(2, character, sizeof(character));
	if (args >= 3)
	{
		bool prevWasNotAlpha = false;
		for (int i = 3; i <= args; i++)
		{
			char word[32];
			GetCmdArg(i, word, sizeof(word));
			
			if (i == 3)
				Format(message, sizeof(message), "%s", word);
			else if ((!IsCharAlpha(word[0]) && !IsCharNumeric(word[0])) || prevWasNotAlpha)
			{
				Format(message, sizeof(message), "%s%s", message, word);
				prevWasNotAlpha = !prevWasNotAlpha;
			}
			else
				Format(message, sizeof(message), "%s %s", message, word);
		}
	}
	else
		message = "";
	
	if (!CF_CharacterExists(character))
	{
		ReplyToCommand(client, "[Chaos Fortress] Failure: character config ''%s'' does not exist.", character);
		return Plugin_Continue;
	}
	
	if (StrEqual(name, "@all"))
	{
		CF_ForceCharacterOnGroup(character, TFTeam_Unassigned, message);
	}
	else if (StrEqual(name, "@red"))
	{
		CF_ForceCharacterOnGroup(character, TFTeam_Red, message);
	}
	else if (StrEqual(name, "@blue"))
	{
		CF_ForceCharacterOnGroup(character, TFTeam_Blue, message);
	}
	else
	{
		int target = FindTarget(client, name, false, false);
		
		if (!IsValidMulti(target) && IsValidClient(client))
		{
			ReplyToCommand(client, "[Chaos Fortress] Failure: the target must be alive and in-game.");
			return Plugin_Continue;
		}
		
		CF_MakeClientCharacter(target, character, message);
	}

	return Plugin_Continue;
}

public void CF_ForceCharacterOnGroup(char character[255], TFTeam group, char message[255])
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidMulti(i) && (TF2_GetClientTeam(i) == group || group == TFTeam_Unassigned))
		{
			CF_MakeClientCharacter(i, character, message);
		}
	}
}

public void OnClientDisconnect(int client)
{
	CF_UnmakeCharacter(client, false, CF_CRR_DISCONNECT);
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
	Core_OnEntityDestroyed(entity);
}