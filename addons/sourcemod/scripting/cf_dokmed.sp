#include <cf_include>
#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>
#include <tf_player_collisions>
#include <fakeparticles>

#define DOKMED			"cf_dokmed"
#define COCAINUM		"dokmed_cocainum"
#define SURGERY			"dokmed_surprise_surgery"
#define MEDIGUN			"dokmed_medigun_passives"

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
#define PARTICLE_TELEPORT_FLASH_4		"duck_collect_sparkles_green"

#define PARTICLE_TELEPORT_BEAM_RED		"spell_lightningball_hit_red"
#define PARTICLE_TELEPORT_BEAM_BLUE		"spell_lightningball_hit_blue"
#define PARTICLE_TELEPORT_FLASH_BLUE_1	"electrocuted_gibbed_blue_2"
#define PARTICLE_TELEPORT_FLASH_BLUE_2	"electrocuted_gibbed_blue_3"
#define PARTICLE_TELEPORT_FLASH_BLUE_3	"electrocuted_blue_flash"
#define PARTICLE_TELEPORT_FLASH_BLUE_4	"electrocuted_blue_5"
#define PARTICLE_TELEPORT_FLASH_RED_1	"electrocuted_gibbed_red_2"
#define PARTICLE_TELEPORT_FLASH_RED_2	"electrocuted_gibbed_red_3"
#define PARTICLE_TELEPORT_FLASH_RED_3	"electrocuted_red_flash"
#define PARTICLE_TELEPORT_FLASH_RED_4	"electrocuted_red_5"
#define PARTICLE_TELEPORT_CHARGEUP_BLUE	"dxhr_lightningball_parent_blue"
#define PARTICLE_TELEPORT_CHARGEUP_RED	"dxhr_lightningball_parent_red"
#define PARTICLE_TELEPORT_WARNING_RED	"eyeboss_team_red"
#define PARTICLE_TELEPORT_WARNING_BLUE	"eyeboss_team_blue"

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
		
	if (StrContains(abilityName, MEDIGUN) != -1)
		Medigun_CycleBuff(client);
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

int Surgery_WarningParticle[MAXPLAYERS + 1] = { -1, ... };

float Surgery_Destination[MAXPLAYERS + 1][3];
float Surgery_TeleTime[MAXPLAYERS + 1] = { 0.0, ... };
float Surgery_DMG[MAXPLAYERS + 1] = { 0.0, ... };
float Surgery_DMGRadius[MAXPLAYERS + 1] = { 0.0, ... };
float Surgery_DMGFalloffStart[MAXPLAYERS + 1] = { 0.0, ... };
float Surgery_DMGFalloffMax[MAXPLAYERS + 1] = { 0.0, ... };
float Surgery_HealingRadius[MAXPLAYERS + 1] = { 0.0, ... };
float Surgery_HealingAmt[MAXPLAYERS + 1] = { 0.0, ... };
float Surgery_HealingOverheal[MAXPLAYERS + 1] = { 0.0, ... };
float Surgery_RecentlyTeleported[MAXPLAYERS + 1] = { 0.0, ... };

public void Surgery_Activate(int client, char ability[255])
{
	float dist = CF_GetArgF(client, DOKMED, ability, "distance");
	float delay = CF_GetArgF(client, DOKMED, ability, "delay");
	
	CF_CheckTeleport(client, dist, false, Surgery_Destination[client]);
	
	Surgery_Cancel(client);
	Surgery_TeleTime[client] = GetGameTime() + delay;
	
	Surgery_DMGRadius[client] = CF_GetArgF(client, DOKMED, ability, "damage_radius");
	Surgery_DMG[client] = CF_GetArgF(client, DOKMED, ability, "damage_amt");
	Surgery_DMGFalloffStart[client] = CF_GetArgF(client, DOKMED, ability, "damage_falloff_start");
	Surgery_DMGFalloffMax[client] = CF_GetArgF(client, DOKMED, ability, "damage_falloff_max");
	Surgery_HealingRadius[client] = CF_GetArgF(client, DOKMED, ability, "healing_radius");
	Surgery_HealingAmt[client] = CF_GetArgF(client, DOKMED, ability, "healing_amt");
	Surgery_HealingOverheal[client] = CF_GetArgF(client, DOKMED, ability, "healing_overheal");
	
	if (delay <= 0.0)
	{
		Surgery_Teleport(client);
	}
	else
	{
		int mode = CF_GetArgI(client, DOKMED, ability, "speed_mode");
		float amt = CF_GetArgF(client, DOKMED, ability, "speed_amt");
		CF_ApplyTemporarySpeedChange(client, mode, amt, delay, 0, 0.0, false);
		
		TFTeam team = TF2_GetClientTeam(client);
		float scale = CF_GetCharacterScale(client);
		
		CF_AttachParticle(client, team == TFTeam_Red ? PARTICLE_TELEPORT_CHARGEUP_RED : PARTICLE_TELEPORT_CHARGEUP_BLUE, "root", _, delay, _, _, scale * 50.0);
		Surgery_WarningParticle[client] = EntIndexToEntRef(SpawnParticle(Surgery_Destination[client], team == TFTeam_Red ? PARTICLE_TELEPORT_WARNING_RED : PARTICLE_TELEPORT_WARNING_BLUE, delay));
	
		RequestFrame(Surgery_DelayedTeleport, GetClientUserId(client));
		CF_PlayRandomSound(client, "", "sound_surgery_chargeup");
	}
}

public void Surgery_DelayedTeleport(int id)
{
	int client = GetClientOfUserId(id);
	if (!IsValidMulti(client) || Surgery_TeleTime[client] <= 0.0)
		return;
		
	if (GetGameTime() >= Surgery_TeleTime[client])
	{
		Surgery_Teleport(client);
		Surgery_Cancel(client);
		return;
	}
		
	RequestFrame(Surgery_DelayedTeleport, id);
}

public void Surgery_Teleport(int client)
{
	float currentLoc[3];
	GetClientAbsOrigin(client, currentLoc);
	TFTeam team = TF2_GetClientTeam(client);
		
	CF_Teleport(client, 0.0, false, NULL_VECTOR, true, Surgery_Destination[client], true);
	RequestFrame(Surgery_Telefrag, GetClientUserId(client));
	
	SpawnShaker(Surgery_Destination[client], 8, 100, 4, 4, 4);
	Overlay_Flash(client, GetRandomInt(1, 1000) != 777 ? "lights/white005" : "models/player/medic/medic_head_red", 0.1);
		
	Handle victims = CF_GenericAOEDamage(client, client, client, Surgery_DMG[client], DMG_GENERIC | DMG_CLUB | DMG_ALWAYSGIB, Surgery_DMGRadius[client], Surgery_Destination[client], Surgery_DMGFalloffStart[client], Surgery_DMGFalloffMax[client], _, false);
	delete victims;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidMulti(i, true, true, true, team) && i != client)
		{
			float pos[3];
			GetClientAbsOrigin(i, pos);
			if (GetVectorDistance(pos, Surgery_Destination[client]) <= Surgery_HealingRadius[client])
			{
				CF_HealPlayer(i, client, RoundFloat(Surgery_HealingAmt[client]), Surgery_HealingOverheal[client]);
				CF_AttachParticle(i, team == TFTeam_Red ? PARTICLE_HEALING_BURST_RED : PARTICLE_HEALING_BURST_BLUE, "root", _, 2.0);
				EmitSoundToClient(i, SOUND_FLASK_HEAL);
			}
		}
	}
		
	float scale = CF_GetCharacterScale(client);
	currentLoc[2] += 40.0 * scale;	
	Surgery_Destination[client][2] += 40.0 * scale;
	
	SpawnParticle_ControlPoints(currentLoc, Surgery_Destination[client], team == TFTeam_Red ? PARTICLE_TELEPORT_BEAM_RED : PARTICLE_TELEPORT_BEAM_BLUE, 2.0);
	SpawnParticle(Surgery_Destination[client], team == TFTeam_Red ? PARTICLE_TELEPORT_FLASH_RED_1 : PARTICLE_TELEPORT_FLASH_BLUE_1, 2.0);
	SpawnParticle(Surgery_Destination[client], team == TFTeam_Red ? PARTICLE_TELEPORT_FLASH_RED_2 : PARTICLE_TELEPORT_FLASH_BLUE_2, 2.0);
	SpawnParticle(Surgery_Destination[client], team == TFTeam_Red ? PARTICLE_TELEPORT_FLASH_RED_3 : PARTICLE_TELEPORT_FLASH_BLUE_3, 2.0);
	SpawnParticle(Surgery_Destination[client], team == TFTeam_Red ? PARTICLE_TELEPORT_FLASH_RED_4 : PARTICLE_TELEPORT_FLASH_BLUE_4, 2.0);
	
	CF_PlayRandomSound(client, "", "sound_surgery_teleport");
	CF_PlayRandomSound(client, "", "sound_surgery_teleport_dialogue");
	
	Surgery_RecentlyTeleported[client] = GetGameTime() + 0.5;
}

int i_SurgeryChecker = -1;

bool b_SurgeryFragged[2049] = { false, ... };

public bool Surgery_TelefragCheck(entity, mask) 
{
	if (!HasEntProp(entity, Prop_Send, "m_iTeamNum"))
		return false;
		
	int entTeam = GetEntProp(entity, Prop_Send, "m_iTeamNum");
	int userTeam = GetEntProp(i_SurgeryChecker, Prop_Send, "m_iTeamNum");
	
	if (entTeam != userTeam)
	{
		b_SurgeryFragged[entity] = true;
		return true;
	}
	
	return false;
} 

//This should only happen if something moves to the player's exact teleport location before the delay goes off.
//Therefore: kill anyone on the enemy team who the player is touching.
public void Surgery_Telefrag(int id)
{
	int client = GetClientOfUserId(id);
	if (!IsValidMulti(client))
		return;
	
	float scale = CF_GetCharacterScale(client);
	if (CheckPlayerWouldGetStuck(client, scale))
	{
		float pos[3], mins[3] = { -24.5, -24.5, 0.0 }, maxs[3] = { 24.5,  24.5, 83.0};
		GetClientAbsOrigin(client, pos);
	
		ScaleVector(mins, scale);
		ScaleVector(maxs, scale);
	    
		i_SurgeryChecker = client;
		TR_TraceHullFilter(pos, pos, mins, maxs, MASK_PLAYERSOLID, Surgery_TelefragCheck);
		
		for (int i = 1; i < 2049; i++)
		{
			if (b_SurgeryFragged[i])
			{
				b_SurgeryFragged[i] = false;
				ForceGuaranteedDamage(i, 99999999.0, client, client, client, DMG_CLUB | DMG_BLAST | DMG_ALWAYSGIB);
			}
		}
	}
}

public bool Surgery_CheckTeleport(int client, char ability[255])
{
	float dist = CF_GetArgF(client, DOKMED, ability, "distance");
	
	return CF_CheckTeleport(client, dist, false);
}

public void Surgery_Cancel(int client)
{
	Surgery_TeleTime[client] = 0.0;
	int particle = EntRefToEntIndex(Surgery_WarningParticle[client]);
	if (IsValidEntity(particle))
		RemoveEntity(particle);
}

//TODO: Find out if this works as intended during the beta test, remove it if it doesn't.
public Action PlayerCollisions_OnCheckCollision(int client, int other, bool &result)
{
	float gt = GetGameTime();
	
	if (Surgery_RecentlyTeleported[client] >= gt)
	{
		result = false;
		Surgery_RecentlyTeleported[client] = gt + 0.2;
		return Plugin_Changed;
	}
	
	return Plugin_Continue;
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

enum MedigunBuff
{
    MedigunBuff_Speed = 0,
    MedigunBuff_Res,
    MedigunBuff_DMG,
    MedigunBuff_None
};

MedigunBuff Medigun_CurrentBuff[MAXPLAYERS + 1] = { MedigunBuff_None, ... };

Handle Medigun_Healers[MAXPLAYERS + 1] = { null, ... };

CF_AbilityType Medigun_Slot[MAXPLAYERS + 1] = { CF_AbilityType_None, ... };

char Medigun_Name[MAXPLAYERS + 1][3][255];

float Medigun_Coefficient[MAXPLAYERS + 1][3];
float Medigun_SelfHeal[MAXPLAYERS + 1] = { 0.0, ... };
float Medigun_HealBucket[MAXPLAYERS + 1] = { 0.0, ... };
float Medigun_HealCap[MAXPLAYERS + 1] = { 0.0, ... };

int Medigun_Target[MAXPLAYERS + 1] = { -1, ... };
int Medigun_SelfParticle[MAXPLAYERS + 1] = { -1, ... };
int Medigun_TargetParticle[MAXPLAYERS + 1] = { -1, ... };

bool Medigun_Active[MAXPLAYERS + 1] = { false, ... };
bool Medigun_BlockUber[MAXPLAYERS + 1] = { false, ... };
bool b_FadingOut[2049] = { false, ... };

public void Medigun_Check(int client)
{
	if (!CF_HasAbility(client, DOKMED, MEDIGUN))
		return;
		
	Medigun_Coefficient[client][0] = CF_GetArgF(client, DOKMED, MEDIGUN, "speed");
	Medigun_Coefficient[client][1] = CF_GetArgF(client, DOKMED, MEDIGUN, "resistance");
	Medigun_Coefficient[client][2] = CF_GetArgF(client, DOKMED, MEDIGUN, "damage");
	Medigun_SelfHeal[client] = CF_GetArgF(client, DOKMED, MEDIGUN, "self_heal");
	Medigun_HealCap[client] = CF_GetArgF(client, DOKMED, MEDIGUN, "self_overheal");
	Medigun_BlockUber[client] = CF_GetArgI(client, DOKMED, MEDIGUN, "block_uber") != 0;
	
	CF_GetArgS(client, DOKMED, MEDIGUN, "speed_name", Medigun_Name[client][0], 255);
	CF_GetArgS(client, DOKMED, MEDIGUN, "resistance_name", Medigun_Name[client][1], 255);
	CF_GetArgS(client, DOKMED, MEDIGUN, "damage_name", Medigun_Name[client][2], 255);
	
	int slot = CF_GetArgI(client, DOKMED, MEDIGUN, "slot") - 1;
	
	if (slot > -1 && slot < 11)
		Medigun_Slot[client] = view_as<CF_AbilityType>(slot);
	
	Medigun_Active[client] = true;
	
	Medigun_CycleBuff(client);
	SDKUnhook(client, SDKHook_PreThink, Medigun_PreThink);
	SDKHook(client, SDKHook_PreThink, Medigun_PreThink);
}

public Action Medigun_PreThink(int client)
{
	if (!IsPlayerHoldingWeapon(client, 1))
		return Plugin_Continue;
	
	int medigun = GetPlayerWeaponSlot(client, 1);
	if (!IsValidEntity(medigun))
		return Plugin_Continue;
		
	char classname[255];
	GetEntityClassname(medigun, classname, sizeof(classname));
	
	if (StrContains(classname, "medigun") == -1)
		return Plugin_Continue;
	
	if (Medigun_BlockUber[client])
		SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", 0.0);
		
	int target = GetEntPropEnt(medigun, Prop_Send, "m_hHealingTarget");
	int current = Medigun_GetTarget(client);
	if (target != current)
	{
		Medigun_TargetChanged(client, current, target);
	}
	
	if (IsValidMulti(current))
	{
		Medigun_HealBucket[client] += Medigun_SelfHeal[client] / 63.0;
		if (Medigun_HealBucket[client] >= 1.0)
		{
			int heals = RoundToFloor(Medigun_HealBucket[client]);
			float remainder = Medigun_HealBucket[client] - float(heals);
			
			CF_HealPlayer(client, client, heals, Medigun_HealCap[client]);
			Medigun_HealBucket[client] = remainder;
		}
	}
	
	return Plugin_Continue;
}

public int Medigun_GetTarget(int client) { return GetClientOfUserId(Medigun_Target[client]); }

public void Medigun_TargetChanged(int client, int currentTarget, int newTarget)
{
	Medigun_Detach(client, currentTarget);
	
	if (IsValidMulti(newTarget))
		Medigun_Attach(client, newTarget);
}

public void Medigun_Detach(int client, int target)
{
	Medigun_RemoveParticles(client);
		
	Medigun_Target[client] = -1;
	Medigun_HealBucket[client] = 0.0;
	
	if(IsValidClient(target))
		Medigun_RemoveFromList(target, client);
}

public void Medigun_Attach(int client, int target)
{
	DataPack pack = new DataPack();
	WritePackCell(pack, GetClientUserId(client));
	WritePackCell(pack, GetClientUserId(target));
	RequestFrame(Medigun_AttachParticlesDelayed, pack);
	
	Medigun_Target[client] = GetClientUserId(target);
	Medigun_AddToList(target, client);
}

public void Medigun_AddToList(int client, int target)
{
	if (Medigun_Healers[client] == null)
		Medigun_Healers[client] = CreateArray(16);
		
	PushArrayCell(Medigun_Healers[client], target);
}

public void Medigun_RemoveFromList(int client, int target)
{
	if (Medigun_Healers[client] == null)
		return;
		
	for (int i = 0; i < GetArraySize(Medigun_Healers[client]); i++)
	{
		int healer = GetArrayCell(Medigun_Healers[client], i);
		if (healer == target)
			RemoveFromArray(Medigun_Healers[client], i);
	}
	
	if (GetArraySize(Medigun_Healers[client]) < 1)
		delete Medigun_Healers[client];
}

public void Medigun_AttachParticlesDelayed(DataPack pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	int target = GetClientOfUserId(ReadPackCell(pack));
	delete pack;
	
	if (IsValidMulti(client) && IsValidMulti(target))
		Medigun_AttachParticles(client, target);
}

public void Medigun_RemoveParticles(int client)
{
	int particle = EntRefToEntIndex(Medigun_SelfParticle[client]);
	if (IsValidEntity(particle))
	{
		b_FadingOut[particle] = true;
		RequestFrame(Medigun_FadeOut, EntIndexToEntRef(particle));
	}
		
	particle = EntRefToEntIndex(Medigun_TargetParticle[client]);
	if (IsValidEntity(particle))
	{
		b_FadingOut[particle] = true;
		RequestFrame(Medigun_FadeOut, EntIndexToEntRef(particle));
	}
}

public void Medigun_FadeOut(int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (!IsValidEntity(ent))
		return;
	
	int r, g, b, a;
	GetEntityRenderColor(ent, r, g, b, a);
	
	a -= 3;
	if (a < 1)
	{
		RemoveEntity(ent);
		return;
	}
	else
		SetEntityRenderColor(ent, r, g, b, a);
		
	RequestFrame(Medigun_FadeOut, ref);
}

public void Medigun_FadeIn(int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (!IsValidEntity(ent))
		return;
		
	if (b_FadingOut[ent])
		return;
		
	int r, g, b, a;
	GetEntityRenderColor(ent, r, g, b, a);
	
	a += 6;
	if (a > 255)
		a = 255;

	SetEntityRenderColor(ent, r, g, b, a);
	if (a == 255)
		return;
		
	RequestFrame(Medigun_FadeIn, ref);
}

public void Medigun_AttachParticles(int client, int target)
{
	int skin;
	int r;
	int b;
	switch(Medigun_CurrentBuff[client])
	{
		case MedigunBuff_Res:
		{
			skin = 0;
		}
		case MedigunBuff_Speed:
		{
			skin = 1;
		}
		case MedigunBuff_DMG:
		{
			skin = 2;
		}
	}
	
	if (TF2_GetClientTeam(client) == TFTeam_Red)
	{
		r = 255;
		b = 180;
	}
	else
	{
		r = 180;
		b = 255;
	}
	
	Medigun_SelfParticle[client] = EntIndexToEntRef(FPS_AttachFakeParticleToEntity(client, "root", "models/fake_particles/chaos_fortress/player_aura.mdl", skin, "rotate", 0.75, _, r, 180, b, 0));
	Medigun_TargetParticle[client] = EntIndexToEntRef(FPS_AttachFakeParticleToEntity(target, "root", "models/fake_particles/chaos_fortress/player_aura.mdl", skin, "rotate", 0.75, _, r, 180, b, 0));
	
	RequestFrame(Medigun_FadeIn, Medigun_SelfParticle[client]);
	RequestFrame(Medigun_FadeIn, Medigun_TargetParticle[client]);
}

public void Medigun_CycleBuff(int client)
{
	if (!Medigun_Active[client] || Medigun_AllDisabled(client))
		return;
		
	int current = view_as<int>(Medigun_CurrentBuff[client]);
	bool success = false;
	while (!success)
	{
		current++;
		if (current > 2)
			current = 0;
			
		if (Medigun_Coefficient[client][current] != 0.0)
		{
			Medigun_CurrentBuff[client] = view_as<MedigunBuff>(current);
			CF_ChangeAbilityTitle(client, Medigun_Slot[client], Medigun_Name[client][current]);
			
			int target = Medigun_GetTarget(client);
			if (IsValidMulti(target))
			{
				Medigun_RemoveParticles(client);
				Medigun_AttachParticles(client, target);
			}
			success = true;
		}
	}
}

public bool Medigun_AllDisabled(int client)
{
	for (int i = 0; i < 3; i++)
	{
		if (Medigun_Coefficient[client][i] != 0.0)
			return false;
	}
	
	return true;
}

public float Medigun_GetResMult(int victim)
{
	float ReturnValue = 1.0;
	
	if (Medigun_Active[victim] && Medigun_CurrentBuff[victim] == MedigunBuff_Res && IsValidMulti(Medigun_Target[victim]))
		ReturnValue *= (1.0 - Medigun_Coefficient[victim][1]);
		
	if (Medigun_Healers[victim] != null)
	{
		for (int i = 0; i < GetArraySize(Medigun_Healers[victim]); i++)
		{
			int healer = GetArrayCell(Medigun_Healers[victim], i);
			if (Medigun_CurrentBuff[healer] == MedigunBuff_Res)
				ReturnValue *= (1.0 - Medigun_Coefficient[healer][1]);
		}
	}
	
	return ReturnValue;
}

public float Medigun_GetDMGMult(int victim)
{
	float ReturnValue = 1.0;
	
	if (Medigun_Active[victim] && Medigun_CurrentBuff[victim] == MedigunBuff_DMG && IsValidMulti(Medigun_Target[victim]))
		ReturnValue += Medigun_Coefficient[victim][2];
		
	if (Medigun_Healers[victim] != null)
	{
		for (int i = 0; i < GetArraySize(Medigun_Healers[victim]); i++)
		{
			int healer = GetArrayCell(Medigun_Healers[victim], i);
			if (Medigun_CurrentBuff[healer] == MedigunBuff_DMG)
				ReturnValue += Medigun_Coefficient[healer][2];
		}
	}
	
	return ReturnValue;
}

public Action CF_OnTakeDamageAlive_Resistance(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int &damagecustom)
{
	float mult = Medigun_GetResMult(victim);
	if (mult != 1.0)
	{
		damage *= mult;
		return Plugin_Changed;
	}
	
	return Plugin_Continue;
}

public Action CF_OnTakeDamageAlive_Bonus(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int &damagecustom)
{
	float mult = Medigun_GetDMGMult(victim);
	if (mult != 1.0)
	{
		damage *= mult;
		return Plugin_Changed;
	}
	
	return Plugin_Continue;
}

public void CF_OnCharacterCreated(int client)
{
	Surgery_Cancel(client);
	Medigun_Check(client);
	Medigun_Detach(client, Medigun_GetTarget(client));
}

public void CF_OnCharacterRemoved(int client)
{
	delete Medigun_Healers[client];
	
	Surgery_Cancel(client);
	Medigun_CurrentBuff[client] = MedigunBuff_None;
	Medigun_Active[client] = false;
	Medigun_Detach(client, Medigun_GetTarget(client));
}

public void OnEntityDestroyed(int entity)
{
	if (entity > 0 && entity < 2049)
		b_FadingOut[entity] = false;
}