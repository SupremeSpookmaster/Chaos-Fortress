/**
 * READ THIS IF YOU ARE ARTVIN (or just interested in knowing what this plugin does)
 * 
 * This plugin manages all abilities for the Zeina rework.
 * It ALSO manages the rework to the Barrier effect. 
 * Thus, all of the abilities designed for Barrier - granting allies Barrier, granting yourself Barrier, spawning with additional Barrier, etc - are rewritten in here.
 * Sensal has been changed to use these new Barrier abilities as well.
 */

#include <cf_include>
#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>
#include <fakeparticles>
#include <worldtext>

#define ZEINA		"cf_zeina_rework"
#define BULLET		"zeina_barrier_bullet"
#define INFO		"zeina_barrier_visor"

#define MODEL_DRG			"models/weapons/w_models/w_drg_ball.mdl"

#define SPR_BULLET_TRAIL_1_RED	"materials/effects/repair_claw_trail_red.vmt"
#define SPR_BULLET_TRAIL_1_BLUE	"materials/effects/repair_claw_trail_blue.vmt"
#define SPR_BULLET_TRAIL_2		"materials/effects/electro_beam.vmt"
#define SPR_BULLET_HEAD			"materials/effects/softglow.vmt"

#define PARTICLE_BULLET_GIVE_BARRIER_RED		"repair_claw_heal_red3"
#define PARTICLE_BULLET_GIVE_BARRIER_BLUE		"repair_claw_heal_blue3"
#define PARTICLE_BULLET_IMPACT_RED				"drg_cow_muzzleflash_normal"
#define PARTICLE_BULLET_IMPACT_BLUE				"drg_cow_muzzleflash_normal_blue"

#define SOUND_BULLET_IMPACT			")weapons/batsaber_hit_world1.wav"
#define SOUND_GIVE_BARRIER			")weapons/rescue_ranger_charge_02.wav"
#define SOUND_BULLET_BEGIN_HOMING	")buttons/button19.wav"
#define SOUND_BARRIER_BLOCKDAMAGE	")physics/metal/metal_box_impact_bullet1.wav"
#define SOUND_BARRIER_BREAK			")physics/metal/metal_box_break2.wav"

public void OnMapStart()
{
	PrecacheModel(MODEL_DRG);
	PrecacheModel(SPR_BULLET_TRAIL_1_RED);
	PrecacheModel(SPR_BULLET_TRAIL_1_BLUE);
	PrecacheModel(SPR_BULLET_TRAIL_2);
	PrecacheModel(SPR_BULLET_HEAD);

	PrecacheSound(SOUND_BULLET_IMPACT);
	PrecacheSound(SOUND_GIVE_BARRIER);
	PrecacheSound(SOUND_BULLET_BEGIN_HOMING);
	PrecacheSound(SOUND_BARRIER_BLOCKDAMAGE);
	PrecacheSound(SOUND_BARRIER_BREAK);
}

public void OnPluginStart()
{
}

int Text_Owner[2048] = { -1, ... };
//Prevents a point_worldtext entity from being seen by anyone other than its owner.
public Action Text_Transmit(int entity, int client)
{
	SetEdictFlags(entity, GetEdictFlags(entity)&(~FL_EDICT_ALWAYS));
	if (client != GetClientOfUserId(Text_Owner[entity]))
 	{
 		return Plugin_Handled;
	}
 		
	return Plugin_Continue;
}

float f_Barrier[MAXPLAYERS + 1] = { 0.0, ... };
float f_NextBarrierTime[MAXPLAYERS + 1] = { 0.0, ... };

int i_BarrierWorldText[MAXPLAYERS + 1] = { -1, ... };
int i_BarrierWorldTextOwner[2048] = { -1, ... };

bool b_HasBarrierGoggles[MAXPLAYERS + 1] = { false, ... };

int numGoggles = 0;

void Barrier_CheckGoggles(int id)
{
	int client = GetClientOfUserId(id);
	if (!IsValidMulti(client))
		return;

	bool goggles = CF_HasAbility(client, ZEINA, INFO);
	if (goggles && numGoggles <= 0)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsValidMulti(i))
				continue;

			Barrier_AssignWorldText(i);
		}
	}

	b_HasBarrierGoggles[client] = goggles;
	numGoggles += view_as<int>(goggles);
}

int Barrier_GetWorldText(int client) { return EntRefToEntIndex(i_BarrierWorldText[client]); }

/**
 * Gives the target some Barrier.
 * 
 * @param target		The client to give Barrier to.
 * @param giver			The client who is providing the Barrier. This player will gain ult charge and resources relative to the amount of Barrier provided, using CF_ResourceType_Healing.
 * @param amount		The amount of Barrier to provide.
 * @param percentage	The maximum percentage of the client's health that the Barrier given by this instance can provide (<= 0.0: no percentage-based limit).
 * 						EX: This is 0.5, the client has 100 max HP. This instance will only fill the user's Barrier up to a max of 50.
 * @param max			Barrier hard-cap (<= 0.0: no hard-cap). If this is 50, this instance will only fill the target's Barrier up to 50.
 * 						Between "percentage" and "max", whichever value results in the lower total max Barrier is chosen.
 * 						EX: "percentage" is 0.5, and the target has 100 max HP, but "max" is equal to 25. This instance will only fill up to 25 Barrier.
 * @param attributes	If true: use "health from healers" bonuses/penalties when calculating the amount of Barrier to provide.
 * 
 * @error	Invalid target.
 */
void Barrier_GiveBarrier(int target, int giver, float amount, float percentage = 0.0, float max = 0.0, bool attributes = false)
{
	if (GetGameTime() < f_NextBarrierTime[target])
		return;

	if (f_Barrier[target] >= max && max > 0.0)
		return;

	float maxHP = float(TF2Util_GetEntityMaxHealth(target));
	if (f_Barrier[target] >= maxHP * percentage && percentage > 0.0)
		return;

	if (attributes)
		amount *= GetTotalAttributeValue(target, 854, 1.0) * GetTotalAttributeValue(target, 69, 1.0) * GetTotalAttributeValue(target, 70, 1.0);

	f_Barrier[target] += amount;
	float amountGiven = amount;

	float cap = max;
	if (percentage > 0.0 && percentage * maxHP < max)
		cap = percentage * maxHP;

	if (f_Barrier[target] > cap)
	{
		float diff = f_Barrier[target] - cap;
		amountGiven -= diff;
		f_Barrier[target] = cap;
	}

	int pitch = GetRandomInt(120, 140);

	if (IsValidClient(giver) && giver != target)
	{
		CF_GiveSpecialResource(giver, amountGiven, CF_ResourceType_Healing);
		CF_GiveUltCharge(giver, amountGiven, CF_ResourceType_Healing);
		CF_GiveHealingPoints(giver, amountGiven);
		
		EmitSoundToClient(giver, SOUND_GIVE_BARRIER, target, _, 80, _, 0.6, pitch);

		float pos[3];
		CF_WorldSpaceCenter(target, pos);
		pos[2] += 40.0 * CF_GetCharacterScale(target);
		
		char barrierText[16];
		Format(barrierText, sizeof(barrierText), "+%i", RoundFloat(amountGiven));
		int text = WorldText_Create(pos, NULL_VECTOR, barrierText, 15.0, _, _, _, 200, 200, 200, 255);
		if (IsValidEntity(text))
		{
			Text_Owner[text] = GetClientUserId(giver);
			SDKHook(text, SDKHook_SetTransmit, Text_Transmit);
			
			WorldText_MimicHitNumbers(text);
		}
	}

	EmitSoundToAll(SOUND_GIVE_BARRIER, target, _, 80, _, 0.4, pitch);

	Barrier_Update(target, true);
}

void Barrier_RemoveBarrier(int target, float amount)
{
	f_Barrier[target] -= amount;

	if (f_Barrier[target] <= 0.0)
	{
		f_Barrier[target] = 0.0;
	}

	Barrier_Update(target, false);
}

void Barrier_Update(int client, bool gained)
{
	int text = Barrier_GetWorldText(client);

	if (gained)
	{
		if (numGoggles > 0 && !IsValidEntity(text))
			Barrier_AssignWorldText(client);

		//TODO: Make shield bubble
	}
	else if (f_Barrier[client] <= 0.0)
	{
		if (IsValidEntity(text))
		{
			SetParent(text, text);
			WorldText_MimicHitNumbers(text);
			i_BarrierWorldText[client] = -1;
		}

		//TODO: Remove bubble
	}

	if (IsValidEntity(text))
	{
		char current[255];
		Format(current, sizeof(current), "%i", RoundToFloor(f_Barrier[client]));
		WorldText_SetMessage(text, current);
	}
}

void Barrier_AssignWorldText(int client)
{
	if (f_Barrier[client] <= 0.0 || IsValidEntity(Barrier_GetWorldText(client)))
		return;

	char current[255];
	Format(current, sizeof(current), "%i", RoundToFloor(f_Barrier[client]));

	float pos[3], ang[3];
	CF_WorldSpaceCenter(client, pos);
	pos[2] += 50.0 * CF_GetCharacterScale(client);
	GetClientAbsAngles(client, ang);
			
	int text = WorldText_Create(pos, ang, current, 16.0 * CF_GetCharacterScale(client), _, _, FONT_TF2_BULKY, TF2_GetClientTeam(client) == TFTeam_Red ? 255 : 120, 120, TF2_GetClientTeam(client) == TFTeam_Blue ? 255 : 120, 255);
	if (IsValidEntity(text))
	{
		SetParent(client, text);
		i_BarrierWorldText[client] = EntIndexToEntRef(text);
		i_BarrierWorldTextOwner[text] = GetClientUserId(client);
		
		SetEdictFlags(text, GetEdictFlags(text) &~ FL_EDICT_ALWAYS);
		SDKHook(text, SDKHook_SetTransmit, Barrier_TextTransmit);
	}
}

public Action Barrier_TextTransmit(int text, int client)
{
	//First: block the transmit for anyone who doesn't have the goggles:
	if (!b_HasBarrierGoggles[client])
		return Plugin_Handled;

	int owner = GetClientOfUserId(i_BarrierWorldTextOwner[text]);
	if (!IsValidClient(owner))
	{
		return Plugin_Handled;
	}

	//Second: block the transmit if the target is invisible and the viewer is an enemy:
	if (IsPlayerInvis(owner) && CF_IsValidTarget(owner, TF2_GetClientTeam(client)))
		return Plugin_Handled;

	//Last: block the transmit if the text belongs to this client, and they are not taunting or in third person:
	if (client == owner && !(GetEntProp(client, Prop_Send, "m_nForceTauntCam") || TF2_IsPlayerInCondition(client, TFCond_Taunting)))
		return Plugin_Handled;

	return Plugin_Continue;
}

int Bullet_MagOwner = -1;
int Bullet_User = -1;

int i_BulletTrail[2048] = { -1, ... };

float f_BulletDMG[2048] = { 0.0, ... };
float f_BulletBarrier[2048] = { 0.0, ... };
float f_BulletBarrierPercentage[2048] = { 0.0, ... };
float f_BulletBarrierMax[2048] = { 0.0, ... };
float f_BulletSelfBarrier[2048] = { 0.0, ... };
float f_BulletSelfBarrierPercentage[2048] = { 0.0, ... };
float f_BulletSelfBarrierMax[2048] = { 0.0, ... };

public void Bullet_Activate(int client, char abilityName[255])
{
	float velocity = CF_GetArgF(client, ZEINA, abilityName, "velocity", 1200.0);
	
	int bullet = CF_FireGenericRocket(client, 0.0, velocity, false, true, ZEINA, Bullet_OnImpact);
	if (IsValidEntity(bullet))
	{
		TFTeam team = TF2_GetClientTeam(client);

		SetEntityModel(bullet, MODEL_DRG);
		SetEntityRenderMode(bullet, RENDER_TRANSALPHA);
		SetEntityRenderColor(bullet, _, _, _, 1);

		float pos[3];
		CF_WorldSpaceCenter(bullet, pos);
		pos[2] -= 20.0 * CF_GetCharacterScale(client);
		TeleportEntity(bullet, pos);

		ParticleBody bulletTrail = FPS_CreateParticleBody(pos, NULL_VECTOR);
		int color[3];
		color[0] = 255;
		color[1] = 255;
		color[2] = 255;

		if (team == TFTeam_Red)
			bulletTrail.AddTrail(SPR_BULLET_TRAIL_1_RED, 0.5, 10.0, 0.0, color, 255, RENDER_TRANSALPHA, 3);
		else
			bulletTrail.AddTrail(SPR_BULLET_TRAIL_1_BLUE, 0.5, 10.0, 0.0, color, 255, RENDER_TRANSALPHA, 3);

		color[0] = team == TFTeam_Red ? 255 : 120;
		color[1] = 120;
		color[2] = team == TFTeam_Blue ? 255 : 120;
		bulletTrail.AddSprite(SPR_BULLET_HEAD, 0.05, color, 255, RENDER_TRANSALPHA);

		SetParent(bullet, bulletTrail.Index);
		i_BulletTrail[bullet] = EntIndexToEntRef(bulletTrail.Index);

		float startPos[3], endPos[3], ang[3];
		GetClientEyeAngles(client, ang);
		GetClientEyePosition(client, startPos);
		GetPointInDirection(startPos, ang, 99999.0, endPos);
		CF_HasLineOfSight(startPos, endPos, _, endPos);

		float mins[3];
		mins[0] = -8.0;
		mins[1] = mins[0];
		mins[2] = mins[0];
				
		float maxs[3];
		maxs[0] = -mins[0];
		maxs[1] = -mins[1];
		maxs[2] = -mins[2];
		
		CF_StartLagCompensation(client);
		Bullet_User = client;
		TR_TraceHullFilter(startPos, endPos, mins, maxs, MASK_SHOT, Bullet_OnlyAllies);
		CF_EndLagCompensation(client);

		int target = TR_GetEntityIndex();

		if (IsValidMulti(target))
		{
			Bullet_Magnetize(bullet, target);
		}
		else
		{
			float magRad = CF_GetArgF(client, ZEINA, abilityName, "radius", 60.0);
			if (magRad > 0.0)
			{
				DataPack pack = new DataPack();
				RequestFrame(Bullet_CheckMagnetize, pack);
				WritePackCell(pack, EntIndexToEntRef(bullet));
				WritePackFloat(pack, magRad);
			}

			float spread = CF_GetArgF(client, ZEINA, abilityName, "spread", 3.0);

			if (spread > 0.0)
			{
				float vel[3];
				for (int i = 0; i < 3; i++)
					ang[i] += GetRandomFloat(-spread, spread);

				GetVelocityInDirection(ang, velocity, vel);
				TeleportEntity(bullet, _, ang, vel);
			}
		}

		float lifespan = CF_GetArgF(client, ZEINA, abilityName, "lifespan", 0.65);
		if (lifespan > 0.0)
			CreateTimer(lifespan, Timer_RemoveEntity, EntIndexToEntRef(bullet), TIMER_FLAG_NO_MAPCHANGE);

		f_BulletDMG[bullet] = CF_GetArgF(client, ZEINA, abilityName, "damage", 10.0);

		f_BulletBarrier[bullet] = CF_GetArgF(client, ZEINA, abilityName, "barrier", 10.0);
		f_BulletBarrierPercentage[bullet] = CF_GetArgF(client, ZEINA, abilityName, "barrier_percentage", 0.5);
		f_BulletBarrierMax[bullet] = CF_GetArgF(client, ZEINA, abilityName, "barrier_max", 200.0);

		f_BulletSelfBarrier[bullet] = CF_GetArgF(client, ZEINA, abilityName, "barrier_self", 5.0);
		f_BulletSelfBarrierPercentage[bullet] = CF_GetArgF(client, ZEINA, abilityName, "barrier_percentage_self", 0.5);
		f_BulletSelfBarrierMax[bullet] = CF_GetArgF(client, ZEINA, abilityName, "barrier_max_self", 200.0);
	}
}

public void Bullet_OnImpact(int entity, int owner, int team, int other, float pos[3])
{
	if (IsValidMulti(other, true, true, true, TF2_GetClientTeam(owner)))
	{
		Barrier_GiveBarrier(other, owner, f_BulletBarrier[entity], f_BulletBarrierPercentage[entity], f_BulletBarrierMax[entity]);
		Barrier_GiveBarrier(owner, owner, f_BulletSelfBarrier[entity], f_BulletSelfBarrierPercentage[entity], f_BulletSelfBarrierMax[entity]);

		SpawnParticle(pos, team == 2 ? PARTICLE_BULLET_GIVE_BARRIER_RED : PARTICLE_BULLET_GIVE_BARRIER_BLUE, 0.2);
		RemoveEntity(entity);
		return;
	}
	else if (CF_IsValidTarget(other, grabEnemyTeam(owner)))
	{
		SDKHooks_TakeDamage(other, entity, owner, f_BulletDMG[entity], DMG_BULLET);
	}

	SpawnParticle(pos, team == 2 ? PARTICLE_BULLET_IMPACT_RED : PARTICLE_BULLET_IMPACT_BLUE, 0.2);
	int pitch = GetRandomInt(80, 110);
	EmitSoundToAll(SOUND_BULLET_IMPACT, entity, _, _, _, 0.6, pitch);
	EmitSoundToAll(SOUND_BULLET_IMPACT, entity, _, _, _, 0.6, pitch);

	RemoveEntity(entity);
}

public void Bullet_CheckMagnetize(DataPack pack)
{
	ResetPack(pack);
	int ent = EntRefToEntIndex(ReadPackCell(pack));
	float rad = ReadPackFloat(pack);

	if (!IsValidEntity(ent))
	{
		delete pack;
		return;
	}

	float pos[3];
	CF_WorldSpaceCenter(ent, pos);

	TFTeam team = view_as<TFTeam>(GetEntProp(ent, Prop_Send, "m_iTeamNum"));

	Bullet_MagOwner = GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	int closest = CF_GetClosestTarget(pos, false, _, rad, team, ZEINA, Bullet_DontCountOwner);
	if (IsValidMulti(closest, true, true, true, team))
	{
		Bullet_Magnetize(ent, closest);
		delete pack;
		return;
	}

	RequestFrame(Bullet_CheckMagnetize, pack);
}

public void Bullet_Magnetize(int bullet, int target)
{
	CF_InitiateHomingProjectile(bullet, target, 360.0, 360.0);

	int trail = EntRefToEntIndex(i_BulletTrail[bullet]);
	if (IsValidEntity(trail))
	{
		SetParent(trail, trail);

		int color[3];
		color[0] = 255;
		color[1] = 255;
		color[2] = 255;

		view_as<ParticleBody>(trail).AddTrail(SPR_BULLET_TRAIL_2, 0.5, 10.0, 0.0, color, 255, RENDER_TRANSALPHA, 3);

		SetParent(bullet, trail);
	}

	EmitSoundToAll(SOUND_BULLET_BEGIN_HOMING, bullet, _, _, _, _, GetRandomInt(120, 140));
	EmitSoundToAll(SOUND_BULLET_BEGIN_HOMING, bullet, _, _, _, _, GetRandomInt(120, 140));
}

public bool Bullet_DontCountOwner(int ent) { return ent != Bullet_MagOwner; }

public bool Bullet_OnlyAllies(entity, contentsMask)
{
	return entity != Bullet_User && IsValidMulti(entity, true, true, true, TF2_GetClientTeam(Bullet_User)); 
}

public void CF_OnAbility(int client, char pluginName[255], char abilityName[255])
{
	if (!StrEqual(pluginName, ZEINA))
		return;
	
	if (StrContains(abilityName, BULLET) != -1)
	{
		Bullet_Activate(client, abilityName);
	}
}

public void CF_OnCharacterCreated(int client)
{
	f_NextBarrierTime[client] = 0.0;
	RequestFrame(Barrier_CheckGoggles, GetClientUserId(client));
}

public void CF_OnCharacterRemoved(int client, CF_CharacterRemovalReason reason)
{
	if (reason == CF_CRR_DEATH || reason == CF_CRR_DISCONNECT || reason == CF_CRR_ROUNDSTATE_CHANGED || reason == CF_CRR_SWITCHED_CHARACTER)
	{
		Barrier_RemoveBarrier(client, f_Barrier[client] + 1.0);
		f_NextBarrierTime[client] = 0.0;
		
		if (b_HasBarrierGoggles[client])
		{
			b_HasBarrierGoggles[client] = false;
			numGoggles--;

			if (numGoggles <= 0)
			{
				for (int i = 1; i <= MaxClients; i++)
				{
					int text = Barrier_GetWorldText(i);
					if (IsValidEntity(text))
					{
						i_BarrierWorldTextOwner[text] = -1;
						RemoveEntity(text);
					}
					
					i_BarrierWorldText[i] = -1;
				}
			}
		}
	}
}

public void OnEntityDestroyed(int entity)
{
	if (entity < 0 || entity > 2048)
		return;

	if (i_BulletTrail[entity] != -1)
	{
		int trail = EntRefToEntIndex(i_BulletTrail[entity]);
		if (IsValidEntity(trail))
		{
			SetParent(trail, trail);
			ParticleBody pBod = view_as<ParticleBody>(trail);
			pBod.Fade_Rate = 8.0;
			pBod.Fading = true;
		}

		i_BulletTrail[entity] = -1;
	}

	i_BarrierWorldTextOwner[entity] = -1;
}

public Action CF_OnTakeDamageAlive_Resistance(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int &damagecustom)
{
    if (!IsValidClient(victim) || f_Barrier[victim] <= 0.0)
		return Plugin_Continue;

	if (damage >= f_Barrier[victim])
	{
		EmitSoundToAll(SOUND_BARRIER_BREAK, victim);
    	EmitSoundToClient(attacker, SOUND_BARRIER_BREAK);

		//Prevent victims from gaining Barrier for 2s after their Barrier breaks.
		//This allows Barrier to still fully negate overflow damage (I have 1 Barrier, I will still take 0 damage from a 999999 damage attack), 
		//without making the Barrier Gun monstrously OP by allowing it to make people immortal by constantly spamming +2 Barrier.
		f_NextBarrierTime[victim] = GetGameTime() + 2.0;
	}
	else
	{
		int pitch = 160 - RoundFloat(ClampFloat((f_Barrier[victim] / 200.0) * 100.0, 0.0, 100.0));
		EmitSoundToAll(SOUND_BARRIER_BLOCKDAMAGE, victim, _, _, _, _, pitch);
		EmitSoundToClient(attacker, SOUND_BARRIER_BLOCKDAMAGE, _, _, _, _, _, pitch);
	}

	//TODO: Make Barrier vfx flash
	Barrier_RemoveBarrier(victim, damage);

	damage = 0.0;

	return Plugin_Changed;
}

public void CF_OnHUDDisplayed(int client, char HUDText[255], int &r, int &g, int &b, int &a)
{
	if (f_Barrier[client] > 0.0)
	{
		Format(HUDText, sizeof(HUDText), "BARRIER: %i\n%s", RoundFloat(f_Barrier[client]), HUDText);
	}
}