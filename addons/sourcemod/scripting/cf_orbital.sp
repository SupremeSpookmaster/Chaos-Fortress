#include <cf_include>
#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>

//TODO: Replace all of the GetRandomSounds with PlayRandomSound, then change the sound source in the config so it only plays to the user.
//		- Reasoning: Adds greater customization.

#define ORBITAL		"cf_orbital"
#define HEIGHT		"orbital_height_advantage"
#define TRACER		"orbital_tracer"
#define THRUSTER	"orbital_thruster"
#define GRAVITY		"orbital_gravity"
#define TASER		"orbital_taser"
#define STRIKE		"orbital_strike"
#define SHOOT_VFX	"orbital_vfx"

int lgtModel;
int glowModel;
int laserModel;

#define PARTICLE_GRAVITY_RED			"teleporter_red_charged_level3"
#define PARTICLE_GRAVITY_BLUE			"teleporter_blue_charged_level3"
#define PARTICLE_THRUSTER_ATTACHMENT	"explosion_trailFire"
#define PARTICLE_THRUSTER_BLASTOFF		"heavy_ring_of_fire"
#define PARTICLE_TASER_RED				"drg_cow_rockettrail_normal"
#define PARTICLE_TASER_BLUE				"drg_cow_rockettrail_normal_blue"
#define PARTICLE_TASER_BLAST_RED		"drg_cow_explosion_sparkles_charged"
#define PARTICLE_TASER_BLAST_BLUE		"drg_cow_explosion_sparkles_charged_blue"
#define PARTICLE_TRACER_RED				"raygun_projectile_red"
#define PARTICLE_TRACER_BLUE			"raygun_projectile_blue"
#define PARTICLE_TRACER_RED_FULL		"raygun_projectile_red_crit"
#define PARTICLE_TRACER_BLUE_FULL		"raygun_projectile_blue_crit"
#define PARTICLE_SHOOT_BLUE				"drg_cow_explosioncore_charged_blue"
#define PARTICLE_SHOOT_RED				"drg_cow_explosioncore_charged"
#define PARTICLE_STRIKE_BLAST_BLUE				"drg_cow_explosioncore_charged_blue"
#define PARTICLE_STRIKE_BLAST_RED				"drg_cow_explosioncore_charged"
#define PARTICLE_STRIKE_WARNING_AURA_RED		"utaunt_tarotcard_red_vortex"
#define PARTICLE_STRIKE_WARNING_RED				"sparks_powerline_red"
#define PARTICLE_STRIKE_WARNING_AURA_BLUE		"utaunt_tarotcard_blue_vortex"
#define PARTICLE_STRIKE_WARNING_BLUE			"sparks_powerline_blue"

#define SOUND_TASER_BLAST				"misc/halloween/spell_lightning_ball_impact.wav"
#define SOUND_GRAVITY_LOOP				"player/taunt_bumper_car_go_loop.wav"
#define SOUND_STRIKE_BLAST				"weapons/cow_mangler_explode.wav"
#define SOUND_STRIKE_BLAST_2			"weapons/cow_mangler_explosion_charge_01.wav"
#define SOUND_STRIKE_WARNING			"ambient_mp3/alarms/doomsday_lift_alarm.mp3"

#define MODEL_TASER						"models/weapons/w_models/w_drg_ball.mdl"

public void OnMapStart()
{
	lgtModel = PrecacheModel("materials/sprites/lgtning.vmt");
	glowModel = PrecacheModel("materials/sprites/glow02.vmt");
	laserModel = PrecacheModel("materials/sprites/laser.vmt");
	PrecacheModel(MODEL_TASER);
	
	PrecacheSound(SOUND_TASER_BLAST);
	PrecacheSound(SOUND_GRAVITY_LOOP);
	PrecacheSound(SOUND_STRIKE_BLAST);
	PrecacheSound(SOUND_STRIKE_BLAST_2);
	PrecacheSound(SOUND_STRIKE_WARNING);
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
		
	if (StrContains(abilityName, SHOOT_VFX) != -1)
		VFX_Activate(client, abilityName);
		
	if (StrContains(abilityName, STRIKE) != -1)
		Strike_Activate(client, abilityName);
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

bool Tracer_FullyCharged[MAXPLAYERS + 1] = { false, ... };

public void TF2_OnConditionAdded(int client, TFCond condition)
{
	if (condition == TFCond_Zoomed && CF_HasAbility(client, ORBITAL, TRACER))
		Tracer_Activate(client);
}

public void TF2_OnConditionRemoved(int client, TFCond condition)
{
	if (condition == TFCond_Zoomed && CF_HasAbility(client, ORBITAL, TRACER))
		Tracer_Disable(client);
}

public void Tracer_Activate(int client)
{
	Tracer_FullyCharged[client] = false;
	SDKHook(client, SDKHook_PreThink, Tracer_PreThink);
	
	char snd[255], conf[255];
	CF_GetPlayerConfig(client, conf, sizeof(conf));
	if (CF_GetRandomSound(conf, "sound_tracer_scope", snd, sizeof(snd)) != KeyValType_Null)
	{
		PrecacheSound(snd);
		EmitSoundToClient(client, snd);
	}
}

public void Tracer_Disable(int client)
{
	SDKUnhook(client, SDKHook_PreThink, Tracer_PreThink);
	
	char snd[255], conf[255];
	CF_GetPlayerConfig(client, conf, sizeof(conf));
	if (CF_GetRandomSound(conf, "sound_tracer_unscope", snd, sizeof(snd)) != KeyValType_Null)
	{
		PrecacheSound(snd);
		EmitSoundToClient(client, snd);
	}
}

float Tracer_NextBeam[MAXPLAYERS + 1] = { 0.0, ... };

public Action Tracer_PreThink(int client)
{
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if (!IsValidEntity(weapon))
	{
		Tracer_Disable(client);
		return Plugin_Stop;
	}
		
	float charge = GetChargePercent(weapon);
	bool FullCharge = HasFullCharge(client);
		
	float startPos[3], endPos[3];
	
	GetClientEyePosition(client, startPos);
	startPos[2] -= 5.0;
	
	if (FullCharge && !Tracer_FullyCharged[client])
	{
		Tracer_FullyCharged[client] = true;
		
		char snd[255], conf[255];
		CF_GetPlayerConfig(client, conf, sizeof(conf));
		if (CF_GetRandomSound(conf, "sound_tracer_fully_charged", snd, sizeof(snd)) != KeyValType_Null)
		{
			PrecacheSound(snd);
			EmitSoundToClient(client, snd);
		}
	}
	
	if (GetGameTime() >= Tracer_NextBeam[client])
	{
		Handle trace = getAimTrace(client, false, true);
		TR_GetEndPosition(endPos, trace);
		delete trace;
		
		int r = 255;
		int b = 0;
		int a = RoundFloat(160.0 * charge);
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
					alpha = RoundFloat(a / 4.0);	//Don't make the beam super solid/bright if it's the user, otherwise it covers like half of your screen and is super annoying when actually trying to snipe
					
				SpawnBeam_Vectors(startPos, endPos, 0.11, r, 120, b, alpha, glowModel, 4.0, 4.0, 1, 0.1, i);
				if (FullCharge)
					SpawnBeam_Vectors(startPos, endPos, 0.11, r, 120, b, alpha, lgtModel, 2.0, 2.0, 1, 0.25, i);
				else
					SpawnBeam_Vectors(startPos, endPos, 0.11, r, 120, b, alpha, laserModel, 4.0, 4.0, 1, 0.1, i);
			}
		}
		
		Tracer_NextBeam[client] = GetGameTime() + 0.08;
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
		
		char snd[255], conf[255];
		CF_GetPlayerConfig(client, conf, sizeof(conf));
		if (CF_GetRandomSound(conf, "sound_gravity_on", snd, sizeof(snd)) != KeyValType_Null)
		{
			PrecacheSound(snd);
			EmitSoundToClient(client, snd);
		}
		
		SDKHook(client, SDKHook_PreThink, Gravity_PreThink);
		Gravity_Active[client] = true;
		
		SetEntityGravity(client, CF_GetArgF(client, ORBITAL, abilityName, "gravity"));
		EmitSoundToClient(client, SOUND_GRAVITY_LOOP, _, _, 80);
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
	StopSound(client, 0, SOUND_GRAVITY_LOOP);
	
	Gravity_Active[client] = false;
	SetEntityGravity(client, 1.0);
	
	if (playSound)
	{
		char snd[255], conf[255];
		CF_GetPlayerConfig(client, conf, sizeof(conf));
		if (CF_GetRandomSound(conf, "sound_gravity_off", snd, sizeof(snd)) != KeyValType_Null)
		{
			PrecacheSound(snd);
			EmitSoundToClient(client, snd);
		}
	}
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
	
	if (currentVel[2] < 1.0)
		currentVel[2] = 1.0;
		
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
		RemoveEntity(particle);
		
	Taser_Particle[entity] = EntIndexToEntRef(AttachParticleToEntity(entity, newTeam == TFTeam_Red ? PARTICLE_TASER_RED : PARTICLE_TASER_BLUE, "", 10.0));
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
		
		DataPack pack = new DataPack();
		CreateDataTimer(0.2, Taser_VFX, pack, TIMER_FLAG_NO_MAPCHANGE);
		WritePackCell(pack, GetClientUserId(ent));
		WritePackFloat(pack, Taser_Duration[taser]);
	}
	
	RemoveEntity(taser);
}

public Action Taser_VFX(Handle tased, DataPack pack)
{
	ResetPack(pack);
	
	int client = GetClientOfUserId(ReadPackCell(pack));
	float time = ReadPackFloat(pack);
	
	//delete pack;
	
	if (!IsValidMulti(client))
		return Plugin_Continue;
		
	for (int i = 0; i < 2; i++)
	{
		float pos[3];
		GetClientAbsOrigin(client, pos);
		pos[0] += GetRandomFloat(-15.0, 15.0);
		pos[1] += GetRandomFloat(-15.0, 15.0);
		pos[2] += GetRandomFloat(0.0, 90.0);
		
		SpawnParticle(pos, TF2_GetClientTeam(client) == TFTeam_Red ? PARTICLE_TASER_BLAST_BLUE : PARTICLE_TASER_BLAST_RED, 1.0);
	}
	
	time -= 0.2;
	if (time > 0.0)
	{
		DataPack pack2 = new DataPack();
		CreateDataTimer(0.2, Taser_VFX, pack2, TIMER_FLAG_NO_MAPCHANGE);
		WritePackCell(pack2, GetClientUserId(client));
		WritePackFloat(pack2, time);
	}
	
	return Plugin_Continue;
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

public void VFX_Activate(int client, char abilityName[255])
{
	if (HasFullCharge(client))
	{
		float startPos[3], endPos[3];
		GetClientEyePosition(client, startPos);
		startPos[2] -= 5.0;
		
		Handle trace = getAimTrace(client);
		TR_GetEndPosition(endPos, trace);
		delete trace;
		
		TFTeam team = TF2_GetClientTeam(client);
		
		int r = 255;
		int b = 0;
		if (team == TFTeam_Blue)
		{
			b = 255;
			r = 0;
		}
		
		SpawnBeam_Vectors(startPos, endPos, 0.66, r, 120, b, 255, glowModel, 12.0, 12.0, 5, 0.1);
		SpawnBeam_Vectors(startPos, endPos, 0.66, r, 120, b, 255, lgtModel, 8.0, 8.0, 5, 5.0);
		SpawnBeam_Vectors(startPos, endPos, 0.66, r, 120, b, 255, laserModel, 8.0, 8.0, 5, 0.33);
		
		SpawnParticle(endPos, team == TFTeam_Red ? PARTICLE_SHOOT_RED : PARTICLE_SHOOT_BLUE, 2.0);
		
		char snd[255], conf[255];
		CF_GetPlayerConfig(client, conf, sizeof(conf));
		if (CF_GetRandomSound(conf, "sound_orbital_shoot_full", snd, sizeof(snd)) != KeyValType_Null)
		{
			PrecacheSound(snd);
			EmitSoundToClient(client, snd, _, _, 120, _, _, GetRandomInt(80, 90));
		}
		SpawnShaker(startPos, 12, 120, 3, 4, 4);
	}
}

public void Strike_Activate(int client, char abilityName[255])
{
	float delay = CF_GetArgF(client, ORBITAL, abilityName, "delay");
	float duration = CF_GetArgF(client, ORBITAL, abilityName, "duration");
	float interval = CF_GetArgF(client, ORBITAL, abilityName, "interval");
	float damage = CF_GetArgF(client, ORBITAL, abilityName, "damage");
	float radius = CF_GetArgF(client, ORBITAL, abilityName, "radius");
	float falloffStart = CF_GetArgF(client, ORBITAL, abilityName, "falloff_start");
	float falloffMax = CF_GetArgF(client, ORBITAL, abilityName, "falloff_max");

	float groundZero[3];
	Handle trace = getAimTrace(client);
	TR_GetEndPosition(groundZero, trace);
	delete trace;

	DataPack pack = new DataPack();
	CreateDataTimer(delay - 0.1, Strike_DealDamage, pack, TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack, GetClientUserId(client));
	WritePackFloat(pack, duration);
	WritePackFloat(pack, interval);
	WritePackFloat(pack, damage);
	WritePackFloat(pack, radius);
	WritePackFloat(pack, falloffStart);
	WritePackFloat(pack, falloffMax);
	WritePackCell(pack, TF2_GetClientTeam(client));
	for (int i = 0; i < 3; i++)
	{
		WritePackFloat(pack, groundZero[i]);
	}

	WritePackFloat(pack, GetGameTime() + delay);

	float endTime = GetGameTime() + delay + duration;
	DataPack vfxPack = new DataPack();
	CreateDataTimer(0.1, Strike_VFX, vfxPack, TIMER_FLAG_NO_MAPCHANGE);
	WritePackFloat(vfxPack, GetGameTime() + delay);
	WritePackFloat(vfxPack, endTime);
	WritePackFloat(vfxPack, groundZero[0]);
	WritePackFloat(vfxPack, groundZero[1]);
	WritePackFloat(vfxPack, groundZero[2]);
	WritePackFloat(vfxPack, radius);
	WritePackCell(vfxPack, TF2_GetClientTeam(client));
	WritePackFloat(vfxPack, 0.0);
	WritePackFloat(vfxPack, GetGameTime());

	EmitSoundToAll(SOUND_STRIKE_WARNING, _, SNDCHAN_STATIC, 120, _, _, _, _, groundZero);
}

public Action Strike_VFX(Handle vfx, DataPack pack)
{
	ResetPack(pack);

	float startTime = ReadPackFloat(pack);
	float endTime = ReadPackFloat(pack);
	float groundZero[3];
	for (int i = 0; i < 3; i++)
	{
		groundZero[i] = ReadPackFloat(pack);
	}

	float radius = ReadPackFloat(pack);
	TFTeam team = ReadPackCell(pack);
	float rotation = ReadPackFloat(pack);
	float CalledAt = ReadPackFloat(pack);

	float gameTime = GetGameTime();

	int r = 255;
	int b = 0;
	int a = 255;
	if (team == TFTeam_Blue)
	{
		r = 0;
		b = 255;
	}

	if (gameTime < startTime)
	{
		float difference = startTime - gameTime;
		float delayTime = startTime - CalledAt;
		float mult = difference/delayTime;
		
		if (mult > 1.0)
			mult = 1.0;
		if (mult < 0.0)
			mult = 0.0;
			
		a = RoundFloat(255.0 * (1.0 - mult))
	}
	
	for (int i = 0; i < 8; i++)
	{
		float angle = (float(i) * 45.0) + rotation;

		float tempAngles[3], endLoc[3], Direction[3], skyLoc[3];
		tempAngles[0] = 0.0;
		tempAngles[1] = angle;
		tempAngles[2] = 0.0;
			
		GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(Direction, radius);
		AddVectors(groundZero, Direction, endLoc);

		skyLoc[0] = endLoc[0];
		skyLoc[1] = endLoc[1];
		skyLoc[2] = 9999.0;

		SpawnBeam_Vectors(skyLoc, endLoc, 0.1, r, 120, b, a, laserModel, 5.0, 5.0, 1, 0.1);
		SpawnBeam_Vectors(skyLoc, endLoc, 0.1, r, 120, b, a / 4, laserModel, 10.0, 10.0, 1, 0.1);
		SpawnBeam_Vectors(skyLoc, endLoc, 0.1, r, 120, b, a / 4, glowModel, 15.0, 15.0, 1, 0.1);
	}

	spawnRing_Vector(groundZero, radius * 2.0, 0.0, 0.0, 0.0, laserModel, r, 120, b, a, 1, 0.1, 16.0, 0.0, 1);

	if (gameTime < endTime)
	{
		DataPack vfxPack2 = new DataPack();
		CreateDataTimer(0.1, Strike_VFX, vfxPack2, TIMER_FLAG_NO_MAPCHANGE);
		WritePackFloat(vfxPack2, startTime);
		WritePackFloat(vfxPack2, endTime);
		WritePackFloat(vfxPack2, groundZero[0]);
		WritePackFloat(vfxPack2, groundZero[1]);
		WritePackFloat(vfxPack2, groundZero[2]);
		WritePackFloat(vfxPack2, radius);
		WritePackCell(vfxPack2, team);
		WritePackFloat(vfxPack2, rotation + 5.0);
		WritePackFloat(vfxPack2, CalledAt);
	}
	else
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			StopSound(i, SNDCHAN_STATIC, SOUND_STRIKE_WARNING);
		}
	}

	return Plugin_Continue;
}

public Action Strike_DealDamage(Handle smackthoserats, DataPack pack)
{
	ResetPack(pack);

	int client = GetClientOfUserId(ReadPackCell(pack));
	float duration = ReadPackFloat(pack);
	float interval = ReadPackFloat(pack);
	float damage = ReadPackFloat(pack);
	float radius = ReadPackFloat(pack);
	float falloffStart = ReadPackFloat(pack);
	float falloffMax = ReadPackFloat(pack);
	TFTeam team = ReadPackCell(pack);

	float groundZero[3];
	for (int i = 0; i < 3; i++)
	{
		groundZero[i] = ReadPackFloat(pack);
	}

	float startTime = ReadPackFloat(pack);
	float endTime = startTime + duration;

	if (GetGameTime() > endTime || !IsValidClient(client))
		return Plugin_Continue;

	CF_GenericAOEDamage(client, client, client, damage, DMG_CLUB|DMG_BLAST|DMG_ALWAYSGIB, radius, groundZero, falloffStart, falloffMax, true, false);

	int r = 255;
	int b = 0;
	if (team == TFTeam_Blue)
	{
		b = 255;
		r = 0;
	}

	for (int i = 0; i < 8; i++)
	{
		float xLoc[3], yLoc[3];
		xLoc[0] = groundZero[0] + GetRandomFloat(-radius, radius);
		xLoc[1] = groundZero[1] + GetRandomFloat(-radius, radius);
		xLoc[2] = groundZero[2];

		float groundDist = GetDistanceToGround(xLoc);
		if (groundDist > 0.0 && groundDist < 9999.0)
			xLoc[2] -= groundDist;

		yLoc[0] = xLoc[0];
		yLoc[1] = xLoc[1];
		yLoc[2] = 9999.0;

		SpawnBeam_Vectors(yLoc, xLoc, 0.66, r, 120, b, 255, lgtModel, 16.0, 15.0, 1, 2.5);
		SpawnBeam_Vectors(yLoc, xLoc, 0.66, r, 120, b, 255, laserModel, 16.0, 15.0, 1, 0.5);
		SpawnBeam_Vectors(yLoc, xLoc, 0.66, r, 120, b, 175, glowModel, 16.0, 15.0, 1, 2.5);
		SpawnBeam_Vectors(yLoc, xLoc, 0.66, r, 120, b, 125, glowModel, 16.0, 15.0, 1, 0.5);

		int particle = SpawnParticle(xLoc, team == TFTeam_Red ? PARTICLE_STRIKE_BLAST_RED : PARTICLE_STRIKE_BLAST_BLUE, 2.0);

		EmitSoundToAll(GetRandomInt(1, 2) == 1 ? SOUND_STRIKE_BLAST : SOUND_STRIKE_BLAST_2, particle, SNDCHAN_STATIC, 90, _, _, GetRandomInt(80, 110));
	}

	DataPack pack2 = new DataPack();
	CreateDataTimer(interval, Strike_DealDamage, pack2, TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack2, GetClientUserId(client));
	WritePackFloat(pack2, duration);
	WritePackFloat(pack2, interval);
	WritePackFloat(pack2, damage);
	WritePackFloat(pack2, radius);
	WritePackFloat(pack2, falloffStart);
	WritePackFloat(pack2, falloffMax);
	WritePackCell(pack2, team);
	for (int i = 0; i < 3; i++)
	{
		WritePackFloat(pack2, groundZero[i]);
	}
	WritePackFloat(pack2, startTime);
	
	return Plugin_Continue;
}