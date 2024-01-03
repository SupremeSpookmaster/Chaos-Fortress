#include <cf_include>
#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>

#define DOKMED			"cf_dokmed"
#define COCAINUM		"dokmed_cocainum"
#define SURGERY			"dokmed_surprise_surgery"

#define MODEL_FLASK_RED					"models/passtime/flasks/flask_bottle_red.mdl"
#define MODEL_FLASK_BLUE				"models/props_halloween/flask_bottle.mdl"

#define PARTICLE_FLASK_TRAIL_RED		"healshot_trail_red"
#define PARTICLE_FLASK_TRAIL_BLUE		"healshot_trail_blue"
#define PARTICLE_FLASK_SHATTER			"peejar_impact_milk"
#define PARTICLE_HEALING_RED			"healthgained_red"
#define PARTICLE_HEALING_BLUE			"healthgained_blu"
#define PARTICLE_HEALING_BURST_RED		"spell_overheal_red"
#define PARTICLE_HEALING_BURST_BLUE		"spell_overheal_blue"
#define PARTICLE_HEALING_AURA_RED		"medic_healradius_red_buffed"
#define PARTICLE_HEALING_AURA_BLUE		"medic_healradius_blue_buffed"
#define PARTICLE_POISON_RED				"healthlost_red"
#define PARTICLE_POISON_BLUE			"healthlost_blu"
#define PARTICLE_TELEPORT_BEAM			"merasmus_zap"
#define PARTICLE_TELEPORT_FLASH_1		"merasmus_tp_flash02"
#define PARTICLE_TELEPORT_FLASH_2		"merasmus_spawn_flash"
#define PARTICLE_TELEPORT_FLASH_3		"merasmus_spawn_flash2"

#define SOUND_FLASK_SHATTER				"physics/glass/glass_sheet_break1.wav"
#define SOUND_FLASK_HEAL				"items/smallmedkit1.wav"
#define SOUND_FLASK_POISON				"items/powerup_pickup_plague_infected.wav"
#define SOUND_FLASK_POISON_LOOP			"items/powerup_pickup_plague_infected_loop.wav"

int laserModel;

public void OnMapStart()
{
	PrecacheModel(MODEL_FLASK_RED);
	PrecacheModel(MODEL_FLASK_BLUE);
	
	PrecacheSound(SOUND_FLASK_SHATTER);
	PrecacheSound(SOUND_FLASK_HEAL);
	PrecacheSound(SOUND_FLASK_POISON);
	PrecacheSound(SOUND_FLASK_POISON_LOOP);
	
	laserModel = PrecacheModel("materials/sprites/laser.vmt");
}

DynamicHook g_DHookRocketExplode;

public void OnPluginStart()
{
	GameData gamedata = LoadGameConfigFile("chaos_fortress");
	g_DHookRocketExplode = DHook_CreateVirtual(gamedata, "CTFBaseRocket::Explode");
	delete gamedata;
}

public Action CF_OnTakeDamageAlive_Pre(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int &damagecustom)
{
	if (!IsValidEntity(weapon))
		return Plugin_Continue;
		
	float mult = TF2CustAttr_GetFloat(weapon, "crossbow damage multiplier", 1.0);
	if (mult != 1.0)
	{
		damage *= mult;
		return Plugin_Changed;
	}
	
	return Plugin_Continue;
}

public void CF_OnAbility(int client, char pluginName[255], char abilityName[255])
{
	if (!StrEqual(pluginName, DOKMED))
		return;
	
	if (StrContains(abilityName, COCAINUM) != -1)
		Cocainum_Activate(client, abilityName);
		
	if (StrContains(abilityName, SURGERY) != -1)
		Surgery_Activate(client, abilityName);
}

int Flask_SpeedMode[2049] = { 0, ... };
int Flask_SpeedMaxMode[2049] = { 0, ... };
int i_FlaskParticle[2049] = { -1, ... };

float Flask_Radius[2049] = { 0.0, ... };
float Flask_HealInst[2049] = { 0.0, ... };
float Flask_HealTicks[2049] = { 0.0, ... };
float Flask_HealInterval[2049] = { 0.0, ... };
float Flask_HealDuration[2049] = { 0.0, ... };
float Flask_HealOverheal[2049] = { 0.0, ... };
float Flask_HealTicksOverheal[2049] = { 0.0, ... };
float Flask_SpeedAmt[2049] = { 0.0, ... };
float Flask_SpeedDuration[2049] = { 0.0, ... };
float Flask_SpeedMax[2049] = { 0.0, ... };
float Flask_DMGInst[2049] = { 0.0, ... };
float Flask_DMGTicks[2049] = { 0.0, ... };
float Flask_DMGInterval[2049] = { 0.0, ... };
float Flask_DMGDuration[2049] = { 0.0, ... };

public void Cocainum_Activate(int client, char abilityName[255])
{
	float vel = CF_GetArgF(client, DOKMED, abilityName, "velocity");
	int bottle = CF_FireGenericRocket(client, 0.0, vel, false, true);
	if (IsValidEntity(bottle))
	{
		Flask_Radius[bottle] = CF_GetArgF(client, DOKMED, abilityName, "radius");
		Flask_HealInst[bottle] = CF_GetArgF(client, DOKMED, abilityName, "healing_instant");
		Flask_HealTicks[bottle] = CF_GetArgF(client, DOKMED, abilityName, "healing_delayed");
		Flask_HealInterval[bottle] = CF_GetArgF(client, DOKMED, abilityName, "healing_interval");
		Flask_HealDuration[bottle] = CF_GetArgF(client, DOKMED, abilityName, "healing_duration");
		Flask_HealOverheal[bottle] = CF_GetArgF(client, DOKMED, abilityName, "healing_overheal");
		Flask_HealTicksOverheal[bottle] = CF_GetArgF(client, DOKMED, abilityName, "healing_ticks_overheal");
		Flask_SpeedMode[bottle] = CF_GetArgI(client, DOKMED, abilityName, "speed_mode");
		Flask_SpeedAmt[bottle] = CF_GetArgF(client, DOKMED, abilityName, "speed_amt");
		Flask_SpeedDuration[bottle] = CF_GetArgF(client, DOKMED, abilityName, "speed_duration");
		Flask_SpeedMaxMode[bottle] = CF_GetArgI(client, DOKMED, abilityName, "speed_maxmode");
		Flask_SpeedMax[bottle] = CF_GetArgF(client, DOKMED, abilityName, "speed_max");
		Flask_DMGInst[bottle] = CF_GetArgF(client, DOKMED, abilityName, "damage_instant");
		Flask_DMGTicks[bottle] = CF_GetArgF(client, DOKMED, abilityName, "damage_delayed");
		Flask_DMGInterval[bottle] = CF_GetArgF(client, DOKMED, abilityName, "damage_interval");
		Flask_DMGDuration[bottle] = CF_GetArgF(client, DOKMED, abilityName, "damage_duration");
		
		TFTeam team = TF2_GetClientTeam(client);
		SetEntityModel(bottle, team == TFTeam_Red ? MODEL_FLASK_RED : MODEL_FLASK_BLUE);
		i_FlaskParticle[bottle] = EntIndexToEntRef(AttachParticleToEntity(bottle, team == TFTeam_Red ? PARTICLE_FLASK_TRAIL_RED : PARTICLE_FLASK_TRAIL_BLUE, ""));
		
		float randAng[3];
		for (int i = 0; i < 3; i++)
			randAng[i] = GetRandomFloat(0.0, 360.0);
			
		TeleportEntity(bottle, NULL_VECTOR, randAng, NULL_VECTOR);
		SetEntityMoveType(bottle, MOVETYPE_FLYGRAVITY);
		
		g_DHookRocketExplode.HookEntity(Hook_Pre, bottle, Bottle_Shatter);
		RequestFrame(Bottle_Spin, EntIndexToEntRef(bottle));
		
		CF_PlayRandomSound(client, "", "sound_cocainum_toss");
	}
}

public void CF_OnGenericProjectileTeamChanged(int entity, TFTeam newTeam)
{
	int oldParticle = EntRefToEntIndex(i_FlaskParticle[entity]);
	if (IsValidEntity(oldParticle))
		RemoveEntity(oldParticle);
		
	SetEntityModel(entity, newTeam == TFTeam_Red ? MODEL_FLASK_RED : MODEL_FLASK_BLUE);
	i_FlaskParticle[entity] = EntIndexToEntRef(AttachParticleToEntity(entity, newTeam == TFTeam_Red ? PARTICLE_FLASK_TRAIL_RED : PARTICLE_FLASK_TRAIL_BLUE, ""));
	SetEntityRenderColor(entity, newTeam == TFTeam_Red ? 255 : 120, 120, newTeam == TFTeam_Blue ? 255 : 120, 255);
}

public void Bottle_Spin(int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (IsValidEntity(ent))
	{
		float currentAng[3];
		GetEntPropVector(ent, Prop_Send, "m_angRotation", currentAng);

		for (int i = 0; i < 2; i++)
		{
			currentAng[i] += 6.0;
		}
		
		TeleportEntity(ent, NULL_VECTOR, currentAng, NULL_VECTOR);
		
		RequestFrame(Bottle_Spin, ref);
	}
}

public MRESReturn Bottle_Shatter(int bottle)
{
	float gt = GetGameTime();
	
	int owner = GetEntPropEnt(bottle, Prop_Send, "m_hOwnerEntity");
	TFTeam team = view_as<TFTeam>(GetEntProp(bottle, Prop_Send, "m_iTeamNum"));

	float pos[3], clientPos[3];
	GetEntPropVector(bottle, Prop_Send, "m_vecOrigin", pos);
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidMulti(i, true, true, true, team))
		{
			GetClientAbsOrigin(i, clientPos);
			
			if (GetVectorDistance(pos, clientPos) <= Flask_Radius[bottle])
			{
				CF_AttachParticle(i, team == TFTeam_Red ? PARTICLE_HEALING_BURST_RED : PARTICLE_HEALING_BURST_BLUE, "root", _, 2.0);
				
				EmitSoundToClient(i, SOUND_FLASK_HEAL);
				
				CF_ApplyTemporarySpeedChange(i, Flask_SpeedMode[bottle], Flask_SpeedAmt[bottle], Flask_SpeedDuration[bottle], Flask_SpeedMaxMode[bottle], Flask_SpeedMax[bottle], true);
				
				CF_HealPlayer(i, owner, RoundFloat(Flask_HealInst[bottle]), Flask_HealOverheal[bottle]);
				if (Flask_HealDuration[bottle] > 0.0)
				{
					DataPack pack = new DataPack();
					WritePackCell(pack, GetClientUserId(i));
					WritePackCell(pack, IsValidClient(owner) ? GetClientUserId(owner) : -1);
					WritePackCell(pack, RoundFloat(Flask_HealTicks[bottle]));
					WritePackFloat(pack, Flask_HealTicksOverheal[bottle]);
					WritePackFloat(pack, Flask_HealInterval[bottle]);
					WritePackFloat(pack, gt + Flask_HealInterval[bottle]);
					WritePackFloat(pack, gt + Flask_HealDuration[bottle]);
					RequestFrame(Flask_HealOverTime, pack);
				}
				
				float higher = Flask_HealDuration[bottle];
				if (Flask_SpeedDuration[bottle] > higher)
					higher = Flask_SpeedDuration[bottle];
					
				if (higher > 0.0)
					CF_AttachParticle(i, team == TFTeam_Red ? PARTICLE_HEALING_AURA_RED : PARTICLE_HEALING_AURA_BLUE, "root", _, higher);
			}
		}
	}
	
	Handle victims = CF_GenericAOEDamage(owner, bottle, bottle, Flask_DMGInst[bottle], DMG_GENERIC, Flask_Radius[bottle], pos, 99999.0, 0.0, false, false);
	
	for (int i = 0; i < GetArraySize(victims); i++)
	{
		int vic = GetArrayCell(victims, i);
		if (IsValidMulti(vic))
		{
			EmitSoundToClient(vic, SOUND_FLASK_POISON);
				
			if (Flask_DMGDuration[bottle] > 0.0)
			{
				EmitSoundToClient(vic, SOUND_FLASK_POISON_LOOP);
				DataPack pack = new DataPack();
				WritePackCell(pack, GetClientUserId(vic));
				WritePackCell(pack, IsValidClient(owner) ? GetClientUserId(owner) : -1);
				WritePackFloat(pack, Flask_DMGTicks[bottle]);
				WritePackFloat(pack, Flask_DMGInterval[bottle]);
				WritePackFloat(pack, gt + Flask_DMGInterval[bottle]);
				WritePackFloat(pack, gt + Flask_DMGDuration[bottle]);
				RequestFrame(Flask_DMGOverTime, pack);
			}
		}
	}
		
	delete victims;
	
	EmitSoundToAll(SOUND_FLASK_SHATTER, bottle, SNDCHAN_STATIC, _, _, _, GetRandomInt(80, 110));
	SpawnParticle(pos, PARTICLE_FLASK_SHATTER, 2.0);
	
	spawnRing_Vector(pos, 1.0, 0.0, 0.0, 0.0, laserModel, team == TFTeam_Red ? 255 : 160, 160, team == TFTeam_Red ? 160 : 255, 255, 1, 0.25, 16.0, 0.1, 1, Flask_Radius[bottle] * 2.0);
	//Un-comment and remove the spawnRing_Vector line if a better team-colored burst particle is ever found:
	//SpawnParticle(pos, team == TFTeam_Red ? PARTICLE_HEALING_AURA_RED : PARTICLE_HEALING_AURA_BLUE, 2.0);
	
	RemoveEntity(bottle);
	
	return MRES_Supercede;
}

public void Flask_DMGOverTime(DataPack pack)
{
	ResetPack(pack);
	
	int client = GetClientOfUserId(ReadPackCell(pack));
	int attacker = ReadPackCell(pack);
	
	if (attacker != -1)
		attacker = GetClientOfUserId(attacker);
		
	float dmg = ReadPackFloat(pack);
	float interval = ReadPackFloat(pack);
	float nextHit = ReadPackFloat(pack);
	float endTime = ReadPackFloat(pack);
	
	delete pack;
	
	float gt = GetGameTime();
	
	if (!IsValidClient(client))
		return;
		
	if (!IsPlayerAlive(client) || gt > endTime)
	{
		StopSound(client, SNDCHAN_AUTO, SOUND_FLASK_POISON_LOOP);
		return;
	}
		
	if (gt >= nextHit)
	{
		if (IsValidClient(attacker))
			SDKHooks_TakeDamage(client, attacker, attacker, dmg, DMG_GENERIC);
		else
			SDKHooks_TakeDamage(client, 0, 0, dmg, DMG_GENERIC);

		float scale = CF_GetCharacterScale(client);
		TFTeam team = TF2_GetClientTeam(client);
		CF_AttachParticle(client, team == TFTeam_Red ? PARTICLE_POISON_RED : PARTICLE_POISON_BLUE, "root", _, 2.0, _, _, scale * 80.0);
		
		nextHit = gt + interval;
	}
	
	DataPack pack2 = new DataPack();
	WritePackCell(pack2, GetClientUserId(client));
	WritePackCell(pack2, IsValidClient(attacker) ? GetClientUserId(attacker) : -1);
	WritePackFloat(pack2, dmg);
	WritePackFloat(pack2, interval);
	WritePackFloat(pack2, nextHit);
	WritePackFloat(pack2, endTime);
	RequestFrame(Flask_DMGOverTime, pack2);
}

public void Flask_HealOverTime(DataPack pack)
{
	ResetPack(pack);
	
	int client = GetClientOfUserId(ReadPackCell(pack));
	int healer = ReadPackCell(pack);
	
	if (healer != -1)
		healer = GetClientOfUserId(healer);
		
	int amt = ReadPackCell(pack);
	float overheal = ReadPackFloat(pack);
	float interval = ReadPackFloat(pack);
	float nextHeal = ReadPackFloat(pack);
	float endTime = ReadPackFloat(pack);
	
	delete pack;
	
	float gt = GetGameTime();
	
	if (!IsValidMulti(client) || gt > endTime)
		return;
		
	if (gt >= nextHeal)
	{
		CF_HealPlayer(client, healer, amt, overheal);
		nextHeal = gt + interval;
	}
	
	DataPack pack2 = new DataPack();
	WritePackCell(pack2, GetClientUserId(client));
	WritePackCell(pack2, IsValidClient(healer) ? GetClientUserId(healer) : -1);
	WritePackCell(pack2, amt);
	WritePackFloat(pack2, overheal);
	WritePackFloat(pack2, interval);
	WritePackFloat(pack2, nextHeal);
	WritePackFloat(pack2, endTime);
	RequestFrame(Flask_HealOverTime, pack2);
}

public void Surgery_Activate(int client, char ability[255])
{
	float dist = CF_GetArgF(client, DOKMED, ability, "distance");
	
	float currentLoc[3], endLoc[3];
	
	float scale = CF_GetCharacterScale(client);
	GetClientAbsOrigin(client, currentLoc);
	
	CF_Teleport(client, dist, false, endLoc);
	
	currentLoc[2] += 40.0 * scale;
	endLoc[2] += 40.0 * scale;
	SpawnParticle_ControlPoints(currentLoc, endLoc, PARTICLE_TELEPORT_BEAM, 2.0);
	SpawnParticle(endLoc, PARTICLE_TELEPORT_FLASH_1, 2.0);
	SpawnParticle(endLoc, PARTICLE_TELEPORT_FLASH_2, 2.0);
	SpawnParticle(endLoc, PARTICLE_TELEPORT_FLASH_3, 2.0);
}

public bool Surgery_CheckTeleport(int client, char ability[255])
{
	float dist = CF_GetArgF(client, DOKMED, ability, "distance");
	
	return CF_CheckTeleport(client, dist, false);
}

public Action CF_OnAbilityCheckCanUse(int client, char plugin[255], char ability[255], CF_AbilityType type, bool &result)
{
	if (!StrEqual(plugin, DOKMED))
		return Plugin_Continue;
		
	if (StrContains(ability, SURGERY) != -1)
	{
		result = Surgery_CheckTeleport(client, ability);
		return Plugin_Changed;
	}
	
	return Plugin_Continue;
}

public void CF_OnCharacterCreated(int client)
{	
}

public void CF_OnCharacterRemoved(int client)
{
}