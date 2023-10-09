#include <cf_include>
#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>

#define ORBITAL		"cf_orbital"
#define HEIGHT		"orbital_height_advantage"
#define TRACER		"orbital_tracer"
#define THRUSTER	"orbital_thruster"
#define GRAVITY		"orbital_gravity"

int lgtModel;
int glowModel;
int laserModel;

#define PARTICLE_GRAVITY_RED		"teleporter_red_charged_level3"
#define PARTICLE_GRAVITY_BLUE		"teleporter_blue_charged_level3"
#define PARTICLE_THRUSTER_ATTACHMENT	"explosion_trailFire"
#define PARTICLE_THRUSTER_BLASTOFF		"heavy_ring_of_fire"

public void OnMapStart()
{
	lgtModel = PrecacheModel("materials/sprites/lgtning.vmt");
	glowModel = PrecacheModel("materials/sprites/glow02.vmt");
	laserModel = PrecacheModel("materials/sprites/laser.vmt");
}

public void OnPluginStart()
{
}

public void CF_OnAbility(int client, char pluginName[255], char abilityName[255])
{
	if (StrContains(abilityName, THRUSTER) != -1)
		Thruster_Activate(client, abilityName);
		
	if (StrContains(abilityName, GRAVITY) != -1)
		Gravity_Toggle(client, abilityName);
}

public Action CF_OnTakeDamageAlive_Bonus(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int &damagecustom)
{
	if (!IsValidClient(attacker) || !IsValidClient(victim))
		return Plugin_Continue;
		
	Action ReturnValue = Plugin_Continue;
	
	if (CF_HasAbility(attacker, ORBITAL, HEIGHT))
	{
		float minDist = CF_GetArgF(attacker, ORBITAL, HEIGHT, "start");
		
		float user[3], vic[3];
		GetClientAbsOrigin(attacker, user);
		GetClientAbsOrigin(victim, vic);
		
		float dist = user[2] - vic[2];
		if (dist >= minDist)
		{
			float maxDist = CF_GetArgF(attacker, ORBITAL, HEIGHT, "end") - minDist;
			float maxBonus = CF_GetArgF(attacker, ORBITAL, HEIGHT, "max_bonus");
			dist -= minDist;
			
			damage *= 1.0 + ((dist / maxDist) * maxBonus);
			ReturnValue = Plugin_Changed;
		}
	}
	
	return ReturnValue;
}

public void TF2_OnConditionAdded(int client, TFCond condition)
{
	if (condition == TFCond_Zoomed && CF_HasAbility(client, ORBITAL, TRACER))
		SDKHook(client, SDKHook_PreThink, Tracer_PreThink);
}

public void TF2_OnConditionRemoved(int client, TFCond condition)
{
	if (condition == TFCond_Zoomed && CF_HasAbility(client, ORBITAL, TRACER))
		SDKUnhook(client, SDKHook_PreThink, Tracer_PreThink);
}

public Action Tracer_PreThink(int client)
{
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if (!IsValidEntity(weapon))
		return Plugin_Stop;
		
	float charge = GetChargePercent(weapon);
	bool FullCharge = HasFullCharge(client);
		
	float startPos[3], endPos[3];
	GetClientEyePosition(client, startPos);
	startPos[2] -= 5.0;
	
	Handle trace = getAimTrace(client, FullCharge ? false : true);
	TR_GetEndPosition(endPos, trace);
	delete trace;
	
	int r = 255;
	int b = 0;
	int a = RoundFloat(255.0 * charge);
	if (TF2_GetClientTeam(client) == TFTeam_Blue)
	{
		r = 0;
		b = 255;
	}
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			int alpha = a;
			if (i == client)
				alpha = RoundFloat(a / 3.0);	//Don't make the beam super solid/bright if it's the user, otherwise it covers like half of your screen and is super annoying when actually trying to snipe
				
			SpawnBeam_Vectors(startPos, endPos, 0.1, r, 120, b, alpha, glowModel, 4.0, 4.0, 1, 0.1, i);
			if (FullCharge)
				SpawnBeam_Vectors(startPos, endPos, 0.1, r, 120, b, alpha, lgtModel, 2.0, 2.0, 1, 0.5, i);
			else
				SpawnBeam_Vectors(startPos, endPos, 0.1, r, 120, b, alpha, laserModel, 4.0, 4.0, 1, 0.1, i);
		}
	}
	
	return Plugin_Continue;
}

public bool HasFullCharge(int client)
{
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if (!HasEntProp(weapon, Prop_Send, "m_flChargedDamage"))
		return false;
		
	return GetChargePercent(weapon) >= 1.0;
}

public float GetChargePercent(int weapon)
{
	if (!HasEntProp(weapon, Prop_Send, "m_flChargedDamage"))
		return 0.0;
		
	return GetEntPropFloat(weapon, Prop_Send, "m_flChargedDamage") / 150.0;
}

public void Thruster_Activate(int client, char abilityName[255])
{
	float velocity = CF_GetArgF(client, ORBITAL, abilityName, "velocity");
	
	float currentVel[3], pos[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", currentVel);
	GetClientAbsOrigin(client, pos);
	
	currentVel[2] += velocity;
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, currentVel);
	
	CF_PlayRandomSound(client, "", "sound_thruster_activate");
	CF_AttachParticle(client, PARTICLE_THRUSTER_ATTACHMENT, "root", _, 3.0);
	SpawnParticle(pos, PARTICLE_THRUSTER_BLASTOFF, 3.0);
}

bool Gravity_Active[MAXPLAYERS + 1] = { false, ... };

float Gravity_Cost[MAXPLAYERS + 1] = { 0.0, ... };

int Gravity_Wearable[MAXPLAYERS + 1] = { -1, ... };
int Gravity_Particle[MAXPLAYERS + 1] = { -1, ... };

public void Gravity_Toggle(int client, char abilityName[255])
{
	if (!Gravity_Active[client])
	{
		Gravity_Disable(client, false);
		
		Gravity_Cost[client] = CF_GetArgF(client, ORBITAL, abilityName, "drain");
		
		char atts[255];
		Format(atts, sizeof(atts), "610 ; %.4f", CF_GetArgF(client, ORBITAL, abilityName, "control"));
		Gravity_Wearable[client] = EntIndexToEntRef(CF_AttachWearable(client, view_as<int>(CF_ClassToken_Sniper), false, 0, 0, false, atts));
		Gravity_Particle[client] = EntIndexToEntRef(CF_AttachParticle(client, TF2_GetClientTeam(client) == TFTeam_Red ? PARTICLE_GRAVITY_RED : PARTICLE_GRAVITY_BLUE, "root"));
		
		CF_PlayRandomSound(client, "", "sound_gravity_enabled");
		
		SDKHook(client, SDKHook_PreThink, Gravity_PreThink);
		Gravity_Active[client] = true;
	}
	else
	{
		Gravity_Disable(client, true);
	}
}

public void Gravity_Disable(int client, bool playSound)
{
	int wearable = EntRefToEntIndex(Gravity_Wearable[client]);
	if (IsValidEntity(wearable))
	{
		TF2_RemoveWearable(client, wearable);
	}
	
	int particle = EntRefToEntIndex(Gravity_Particle[client]);
	if (IsValidEntity(particle))
	{
		RemoveEntity(particle);
	}
	
	SDKUnhook(client, SDKHook_PreThink, Gravity_PreThink);
	
	Gravity_Active[client] = false;
	
	if (playSound)
		CF_PlayRandomSound(client, "", "sound_gravity_disabled");
}

public Action Gravity_PreThink(int client)
{
	float resource = CF_GetSpecialResource(client);
	if (resource < Gravity_Cost[client])
	{
		Gravity_Disable(client, true);
		SDKUnhook(client, SDKHook_PreThink, Gravity_PreThink);
		return Plugin_Stop;
	}
	
	CF_SetSpecialResource(client, resource - Gravity_Cost[client]);
	
	float currentVel[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", currentVel);
	
	if (currentVel[2] < 0.0)
		currentVel[2] = 0.0;
		
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, currentVel);
	
	return Plugin_Continue;
}

public void CF_OnCharacterCreated(int client)
{
	if (Gravity_Active[client])
		Gravity_Disable(client, true);
}

public void CF_OnCharacterRemoved(int client)
{
	if (Gravity_Active[client])
		Gravity_Disable(client, true);
}