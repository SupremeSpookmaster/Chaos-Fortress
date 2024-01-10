#include <cf_include>
#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>

#define MERC		"cf_mercenary"
#define SPRINT		"merc_sprint"
#define FRAG		"merc_frag"

#define SPRINT_PARTICLE_RED		"scout_dodge_red"
#define SPRINT_PARTICLE_BLUE	"scout_dodge_blue"

public void OnMapStart()
{
	
}

public void CF_OnAbility(int client, char pluginName[255], char abilityName[255])
{
	if (!StrEqual(pluginName, MERC))
		return;
		
	if (StrContains(abilityName, SPRINT) != -1)
		Sprint_Begin(client, abilityName);
	
	if (StrContains(abilityName, FRAG) != -1)
		Frag_Throw(client, abilityName);
}

public void CF_OnHeldEnd_Ability(int client, bool resupply, char pluginName[255], char abilityName[255])
{
	if (StrContains(abilityName, SPRINT) != -1)
	{
		Sprint_End(client, false, resupply);
	}
}

public void CF_OnPlayerKilled(int victim, int inflictor, int attacker, int deadRinger)
{
	if (!deadRinger && IsValidClient(victim))
	{
		Sprint_End(victim);
		Frag_NoJarate(victim);
	}
}

float Sprint_MaxTime[MAXPLAYERS + 1] = { 0.0, ... };
float Sprint_StartTime[MAXPLAYERS + 1] = { 0.0, ... };
float Sprint_CD[MAXPLAYERS + 1] = { 0.0, ... };
float Sprint_MinCD[MAXPLAYERS + 1] = { 0.0, ... };
float Sprint_MaxCD[MAXPLAYERS + 1] = { 0.0, ... };
float Sprint_Potency[MAXPLAYERS + 1] = { 0.0, ... };
float Sprint_SpeedAdded[MAXPLAYERS + 1] = { 0.0, ... };

int Sprint_Particle[MAXPLAYERS + 1] = { -1, ... };

bool Sprint_Active[MAXPLAYERS + 1] = { false, ... };

CF_AbilityType Sprint_Slot[MAXPLAYERS + 1] = { CF_AbilityType_M2, ... };

public void Sprint_Begin(int client, char abilityName[255])
{
	if (!IsValidMulti(client))
		return;
		
	Sprint_MaxTime[client] = CF_GetArgF(client, MERC, abilityName, "max_duration");
	Sprint_CD[client] = CF_GetArgF(client, MERC, abilityName, "cooldown");
	Sprint_MinCD[client] = CF_GetArgF(client, MERC, abilityName, "min_cd");
	Sprint_MaxCD[client] = CF_GetArgF(client, MERC, abilityName, "max_cd");
	Sprint_Potency[client] = CF_GetArgF(client, MERC, abilityName, "potency");
	Sprint_Slot[client] = CF_GetAbilitySlot(client, MERC, abilityName);
	
	Sprint_Active[client] = true;
	Sprint_StartTime[client] = GetGameTime();
	
	Sprint_ApplyAttributes(client);
	SDKUnhook(client, SDKHook_PreThink, Sprint_PreThink);
	SDKHook(client, SDKHook_PreThink, Sprint_PreThink);
}

void Sprint_End(int client, bool TimeLimit = false, bool resupply = false)
{
	if (!Sprint_Active[client])
		return;
	
	Sprint_Active[client] = false;
	
	if (!resupply)
	{
		float useTime = GetGameTime() - Sprint_StartTime[client];
		float cd = useTime * Sprint_CD[client];
		
		if (cd > Sprint_MaxCD[client])
			cd = Sprint_MaxCD[client];
			
		if (cd < Sprint_MinCD[client])
			cd = Sprint_MinCD[client];
		
		if (TimeLimit)
		{
			switch(Sprint_Slot[client])
			{
				case CF_AbilityType_M2:
				{
					CF_EndHeldAbilitySlot(client, 2, false);
				}
				case CF_AbilityType_M3:
				{
					CF_EndHeldAbilitySlot(client, 3, false);
				}
				case CF_AbilityType_Reload:
				{
					CF_EndHeldAbilitySlot(client, 4, false);
				}
			}
		}
	
		CF_ApplyAbilityCooldown(client, cd, Sprint_Slot[client], true);
		CF_PlayRandomSound(client, "", "sound_merc_sprint_end");
	}

	Sprint_RemoveAttributes(client, resupply);
	SDKUnhook(client, SDKHook_PreThink, Sprint_PreThink);
}

public void Sprint_RemoveAttributes(int client, bool resupply)
{
	int particle = EntRefToEntIndex(Sprint_Particle[client]);
	if (IsValidEntity(particle) && particle > MaxClients && particle < 2049)
	{
		RemoveEntity(particle);
		Sprint_Particle[client] = -1;
	}
	
	if (!resupply)
	{
		float speed = CF_GetCharacterSpeed(client);
		speed -= Sprint_SpeedAdded[client];
		CF_SetCharacterSpeed(client, speed);
		Sprint_SpeedAdded[client] = 0.0;
	}
}

public void Sprint_ApplyAttributes(int client)
{
	Sprint_RemoveAttributes(client, false);
	
	int particle = CF_AttachParticle(client, TF2_GetClientTeam(client) == TFTeam_Red ? SPRINT_PARTICLE_RED : SPRINT_PARTICLE_BLUE, "root", _, _, _, _, 75.0);
	if (IsValidEntity(particle))
	{
		Sprint_Particle[client] = EntIndexToEntRef(particle);
	}
	
	float speed = CF_GetCharacterSpeed(client);
	CF_ApplyTemporarySpeedChange(client, 1, Sprint_Potency[client], 0.0, 0, 9999.0, false);
	float newSpeed = CF_GetCharacterSpeed(client);
	Sprint_SpeedAdded[client] = newSpeed - speed;
	
	CF_PlayRandomSound(client, "", "sound_merc_sprint_start");
}

public Action Sprint_PreThink(int client)
{
	if (GetGameTime() >= (Sprint_StartTime[client] + Sprint_MaxTime[client]))
		Sprint_End(client, true);
		
	return Plugin_Continue;
}

float Frag_DMG[MAXPLAYERS + 1] = { 0.0, ... };
float Frag_Velocity[MAXPLAYERS + 1] = { 0.0, ... };
bool Frag_HasJarate[MAXPLAYERS + 1] = { false, ... };

public void Frag_Throw(int client, char abilityName[255])
{
	if (!IsValidMulti(client))
		return;
		
	Frag_DMG[client] = CF_GetArgF(client, MERC, abilityName, "damage");
	Frag_Velocity[client] = CF_GetArgF(client, MERC, abilityName, "velocity");
	Frag_HasJarate[client] = CF_GetArgI(client, MERC, abilityName, "is_jarate") != 0;
	
	if (!Frag_HasJarate[client])
	{
		CreateTimer(0.18, Frag_ThrowOnDelay, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		CF_DoAbility(client, "cf_generic_abilities", "generic_weapon_frag");
		SDKHook(client, SDKHook_WeaponCanSwitchTo, Frag_BlockWeaponSwitch);
	}
}

public Action Frag_BlockWeaponSwitch(int client, int weapon)
{
	if (!IsValidEntity(weapon))
		return Plugin_Continue;
		
	if (!Frag_HasJarate[client])
	{
		SDKUnhook(client, SDKHook_WeaponCanSwitchTo, Frag_BlockWeaponSwitch);
		return Plugin_Continue;
	}
		
	char classname[255];
	GetEntityClassname(weapon, classname, sizeof(classname));
	
	if (StrEqual(classname, "tf_weapon_jar"))
		return Plugin_Continue;
		
	return Plugin_Handled;
}

public void CF_OnCharacterCreated(int client)
{
	Frag_NoJarate(client);
	Sprint_SpeedAdded[client] = 0.0;
}

public void Frag_NoJarate(int client)
{
	Frag_HasJarate[client] = false;
	SDKUnhook(client, SDKHook_WeaponCanSwitchTo, Frag_BlockWeaponSwitch);
}

public Action CF_OnPlayerRunCmd(int client, int &buttons, int &impulse, int &weapon)
{
	if (Frag_HasJarate[client])
	{
		int wep = TF2_GetActiveWeapon(client);
		if (IsValidEntity(wep))
		{
			char classname[255];
			GetEntityClassname(wep, classname, sizeof(classname));
			
			if (StrEqual(classname, "tf_weapon_jar"))
			{
				buttons |= IN_ATTACK;
				return Plugin_Changed;
			}
		}
	}
	
	return Plugin_Continue;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (StrEqual(classname, "tf_projectile_jar"))
	{
		SDKHook(entity, SDKHook_SpawnPost, Frag_JarSpawn);
	}
}

public Action Frag_JarSpawn(int jar)
{
	int creator = GetEntPropEnt(jar, Prop_Send, "m_hOwnerEntity");
	
	if (!IsValidClient(creator))
		return Plugin_Continue;
		
	if (Frag_HasJarate[creator])
	{
		Frag_Activate(creator);
		Frag_NoJarate(creator);
		RemoveEntity(jar);
	}
	
	return Plugin_Continue;
}

public Action Frag_ThrowOnDelay(Handle throwIt, int id)
{
	int client = GetClientOfUserId(id);
	
	if (IsValidMulti(client))
			Frag_Activate(client);
	
	return Plugin_Continue;
}

public void Frag_Activate(int client)
{
	if (!IsValidClient(client))
		return;
		
	int grenade = CreateEntityByName("tf_projectile_pipe");
	if (IsValidEntity(grenade))
	{
		int team = GetClientTeam(client);
		SetEntPropEnt(grenade, Prop_Send, "m_hOwnerEntity", client);
		SetEntProp(grenade,    Prop_Send, "m_bCritical", 0);
		SetEntProp(grenade,    Prop_Send, "m_iTeamNum",     team, 1);
		SetEntPropFloat(grenade, Prop_Send, "m_flDamage", Frag_DMG[client]);
		int offs = FindSendPropInfo("CTFGrenadePipebombProjectile", "m_bDefensiveBomb") - 4;
		SetEntDataFloat(grenade, offs, Frag_DMG[client]);
		SetEntData(grenade, FindSendPropInfo("CTFGrenadePipebombProjectile", "m_nSkin"), (team-2), 1, true);
		
		DispatchSpawn(grenade);

		float pos[3], vecAngles[3], vecVelocity[3];
		GetClientEyeAngles(client, vecAngles);
		GetClientEyePosition(client, pos);
		vecAngles[0] -= 8.0;
		
		vecVelocity[0] = Cosine(DegToRad(vecAngles[0]))*Cosine(DegToRad(vecAngles[1]))*Frag_Velocity[client];
		vecVelocity[1] = Cosine(DegToRad(vecAngles[0]))*Sine(DegToRad(vecAngles[1]))*Frag_Velocity[client];
		vecVelocity[2] = Sine(DegToRad(vecAngles[0])) * Frag_Velocity[client];
		vecVelocity[2] *= -1;
		
		TeleportEntity(grenade, pos, vecAngles, vecVelocity);
		CF_PlayRandomSound(client, "", "sound_merc_grenade");
	}
}