#include <cf_include>
#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>

#define ORBITAL		"cf_orbital"
#define HEIGHT		"orbital_height_advantage"
#define TRACER		"orbital_tracer"
#define THRUSTER	"orbital_thruster"
#define GRAVITY		"orbital_gravity"
#define TASER		"orbital_taser"

int lgtModel;
int glowModel;
int laserModel;

#define PARTICLE_GRAVITY_RED		"teleporter_red_charged_level3"
#define PARTICLE_GRAVITY_BLUE		"teleporter_blue_charged_level3"
#define PARTICLE_THRUSTER_ATTACHMENT	"explosion_trailFire"
#define PARTICLE_THRUSTER_BLASTOFF		"heavy_ring_of_fire"
#define PARTICLE_TASER_RED				"drg_cow_rockettrail_normal"
#define PARTICLE_TASER_BLUE				"drg_cow_rockettrail_normal_blue"
#define PARTICLE_TASER_BLAST_RED				"drg_cow_explosion_sparkles_charged"
#define PARTICLE_TASER_BLAST_BLUE				"drg_cow_explosion_sparkles_charged_blue"
#define SOUND_TASER_BLAST		"misc/halloween/spell_lightning_ball_impact.wav"
#define MODEL_TASER		"models/weapons/w_models/w_drg_ball.mdl"

public void OnMapStart()
{
	lgtModel = PrecacheModel("materials/sprites/lgtning.vmt");
	glowModel = PrecacheModel("materials/sprites/glow02.vmt");
	laserModel = PrecacheModel("materials/sprites/laser.vmt");
	PrecacheModel(MODEL_TASER);
	
	PrecacheSound(SOUND_TASER_BLAST);
}

DynamicHook g_DHookRocketExplode;
public void OnPluginStart()
{
	GameData gamedata = LoadGameConfigFile("chaos_fortress");
	g_DHookRocketExplode = DHook_CreateVirtual(gamedata, "CTFBaseRocket::Explode");
	delete gamedata;
}

public void CF_OnAbility(int client, char pluginName[255], char abilityName[255])
{
	if (StrContains(abilityName, THRUSTER) != -1)
		Thruster_Activate(client, abilityName);
		
	if (StrContains(abilityName, GRAVITY) != -1)
		Gravity_Toggle(client, abilityName);
		
	if (StrContains(abilityName, TASER) != -1)
		Taser_Activate(client, abilityName);
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

float Tracer_NextBeam[MAXPLAYERS + 1] = { 0.0, ... };

public Action Tracer_PreThink(int client)
{
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if (!IsValidEntity(weapon) || GetGameTime() < Tracer_NextBeam[client])
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
				alpha = RoundFloat(a / 2.0);	//Don't make the beam super solid/bright if it's the user, otherwise it covers like half of your screen and is super annoying when actually trying to snipe
				
			SpawnBeam_Vectors(startPos, endPos, 0.11, r, 120, b, alpha, glowModel, 4.0, 4.0, 1, 0.1, i);
			if (FullCharge)
				SpawnBeam_Vectors(startPos, endPos, 0.11, r, 120, b, alpha, lgtModel, 2.0, 2.0, 1, 0.25, i);
			else
				SpawnBeam_Vectors(startPos, endPos, 0.11, r, 120, b, alpha, laserModel, 4.0, 4.0, 1, 0.1, i);
		}
	}
	
	Tracer_NextBeam[client] = GetGameTime() + 0.04;
	
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
	
	if (currentVel[2] < 0.0)
		currentVel[2] = velocity;
	else
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
		
		SetEntityGravity(client, CF_GetArgF(client, ORBITAL, abilityName, "gravity"));
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
	SetEntityGravity(client, 1.0);
	
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
	
	Gravity_SetVelocity(client);
	
	return Plugin_Continue;
}

//If this is not here, movement is really jittery and weird while hovering, which is bad as a sniper for obvious reasons:
public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	if (Gravity_Active[client])
		Gravity_SetVelocity(client);
		
	return Plugin_Continue;
}

public void Gravity_SetVelocity(int client)
{
	float currentVel[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", currentVel);
	
	if (currentVel[2] < 0.0)
		currentVel[2] = 0.0;
		
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, currentVel);
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

float Taser_DMG[2049] = { 0.0, ... };
float Taser_Slow[2049] = { 0.0, ... };
float Taser_Duration[2049] = { 0.0, ... };

int Taser_Particle[2049] = { -1, ... };

bool Taser_Active[2049] = { false, ... };

public void Taser_Activate(int client, char abilityName[255])
{
	float damage = CF_GetArgF(client, ORBITAL, abilityName, "damage");
	float velocity = CF_GetArgF(client, ORBITAL, abilityName, "velocity");
	float lifespan = CF_GetArgF(client, ORBITAL, abilityName, "lifespan");
	float slow = CF_GetArgF(client, ORBITAL, abilityName, "slow");
	float duration = CF_GetArgF(client, ORBITAL, abilityName, "duration");
	
	int projectile = CF_FireGenericRocket(client, 0.0, velocity, false);
	if (!IsValidEntity(projectile))
		return;
		
	SetEntityModel(projectile, MODEL_TASER);
	SetEntityRenderMode(projectile, RENDER_NONE);
	
	Taser_Particle[projectile] = EntIndexToEntRef(AttachParticleToEntity(projectile, TF2_GetClientTeam(client) == TFTeam_Red ? PARTICLE_TASER_RED : PARTICLE_TASER_BLUE, "", lifespan));
	
	Taser_DMG[projectile] = damage;
	Taser_Slow[projectile] = slow;
	Taser_Duration[projectile] = duration;
	Taser_Active[projectile] = true;
	g_DHookRocketExplode.HookEntity(Hook_Pre, projectile, DontExplode);
	
	if (lifespan > 0.0)
		CreateTimer(lifespan, Timer_RemoveEntity, EntIndexToEntRef(projectile), TIMER_FLAG_NO_MAPCHANGE);
}

public MRESReturn DontExplode(int projectile)
{
	Taser_Collide(projectile, 0);
	return MRES_Supercede;
}

public void CF_OnGenericProjectileTeamChanged(int entity, TFTeam newTeam)
{
	int particle = EntRefToEntIndex(Taser_Particle[entity]);
	if (IsValidEntity(particle))
	{
		RemoveEntity(particle);
		Taser_Particle[entity] = EntIndexToEntRef(AttachParticleToEntity(entity, newTeam == TFTeam_Red ? PARTICLE_TASER_RED : PARTICLE_TASER_BLUE, "", 10.0));
	}
}

public Action CF_OnPassFilter(int ent1, int ent2, bool &result)
{
	bool myResult = Taser_CheckHit(ent1, ent2);
	if (!myResult)
	{
		result = myResult;
		return Plugin_Changed;
	}
	
	return Plugin_Continue;
}

public bool Taser_CheckHit(int ent1, int ent2)
{
	bool Blocked = false;
	
	if (Taser_Active[ent1])
	{
		Taser_Collide(ent1, ent2);
		Blocked = true;
	}
		
	if (Taser_Active[ent2])
	{
		Taser_Collide(ent2, ent1);
		Blocked = true;
	}
	
	return !Blocked;
}

//Need a CH_ShouldCollide filter for world collision
public void Taser_Collide(int taser, int ent)
{
	int owner = GetEntPropEnt(taser, Prop_Send, "m_hOwnerEntity");
	if (IsValidClient(owner))
	{
		float pos[3];
		GetEntPropVector(taser, Prop_Send, "m_vecOrigin", pos);
		SpawnParticle(pos, TF2_GetClientTeam(owner) == TFTeam_Red ? PARTICLE_TASER_BLAST_RED : PARTICLE_TASER_BLAST_BLUE, 2.0);
		EmitSoundToAll(SOUND_TASER_BLAST, taser, SNDCHAN_STATIC);
	}
	
	if (IsValidMulti(ent))
	{
		SDKHooks_TakeDamage(ent, taser, IsValidClient(owner) ? owner : 0, Taser_DMG[taser]);
		char atts[255];
		Format(atts, sizeof(atts), "107 ; %.4f", 1.0 - Taser_Slow[taser]);
		CF_AttachWearable(ent, view_as<int>(CF_ClassToken_Sniper), false, 0, 0, false, atts, Taser_Duration[taser]);
		TF2_AddCondition(ent, TFCond_SpeedBuffAlly, 0.001);
		CreateTimer(Taser_Duration[taser] + 0.1, Taser_Unslow, GetClientUserId(ent), TIMER_FLAG_NO_MAPCHANGE);
	}
	
	RemoveEntity(taser);
}

public Action Taser_Unslow(Handle unslow, int id)
{
	int client = GetClientOfUserId(id);
	if (IsValidClient(client))
	{
		TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.001);
	}
	
	return Plugin_Continue;
}

public void OnEntityDestroyed(int entity)
{
	if (entity >= 0 && entity < 2049)
		Taser_Active[entity] = false;
}