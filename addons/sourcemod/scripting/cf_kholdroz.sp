#include <cf_include>
#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>
#include <fakeparticles>
#include <pnpc>

#define KHOLDROZ		"cf_kholdroz"
#define BEAM			"kholdroz_aurora_beam"
#define BOLT			"kholdroz_frostbolt"

#define SPR_SNOW_TRAIL			"materials/effects/softglow.vmt"
#define SPR_SNOWFLAKE			"materials/chaos_fortress/sprites/snowflake.vmt"//"materials/effects/softglow.vmt"
#define SPR_GLOW				"materials/sprites/glow02.vmt"
#define SPR_AURORABEAM			"materials/chaos_fortress/sprites/aurora_beam.vmt"
#define SPR_AURORAMIST			"materials/chaos_fortress/sprites/aurora_mist.vmt"

#define MODEL_DRG				"models/weapons/w_models/w_drg_ball.mdl"
#define MODEL_AB_PARTICLEBODY	"models/props_c17/canister01a.mdl"
#define MODEL_BOLT				"models/workshop/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder.mdl"

#define PARTICLE_SNOW_AURA_RED		"utaunt_glitter_teamcolor_red"
#define PARTICLE_SNOW_AURA_BLUE		"utaunt_glitter_parent_silver"
#define PARTICLE_FROZEN_AURA		"utaunt_snowring_space_parent"
#define PARTICLE_FROZEN_PROC		"xms_snowburst"
#define PARTICLE_ABSOLUTE_ZERO_AURA	"utaunt_chillingmist_parent"
#define PARTICLE_COLDSNAP_1			"xms_snowburst_child01"
#define PARTICLE_COLDSNAP_2			"xms_snowburst_child02"
#define PARTICLE_BOLT_IMPACT		"snow_steppuff01"

#define SOUND_AB_START				")weapons/flame_thrower_airblast_rocket_redirect.wav"
#define SOUND_AB_LOOP_1				")misc/halloween/merasmus_float.wav"
#define SOUND_AB_LOOP_2				")npc/stalker/laser_burn.wav"
#define SOUND_AB_LOOP_3				")npc/headcrab/headcrab_burning_loop2.wav"
#define SOUND_AB_STOP				")weapons/flame_thrower_bb_end.wav"
#define SOUND_FROZEN_1				")weapons/icicle_freeze_victim_01.wav"
#define SOUND_FROZEN_2				")weapons/icicle_melt_01.wav"
#define SOUND_UNFROZEN				")player/flame_out.wav"
#define SOUND_ICICLE_HIT			")weapons/icicle_melt_01.wav"
#define SOUND_COLDSNAP_1			")weapons/demo_charge_hit_flesh3.wav"
#define SOUND_COLDSNAP_2			")weapons/breadmonster/throwable/bm_throwable_smash.wav"
#define SOUND_BOLT_CHARGE_START_1	")weapons/icicle_freeze_victim_01.wav"
#define SOUND_BOLT_CHARGE_FINISH_1	")"
#define SOUND_BOLT_IMPACT			")weapons/bottle_break.wav"

static char g_FrozenVulnSFX[][] = {
	")weapons/icicle_hit_world_01.wav",
	")weapons/icicle_hit_world_02.wav",
	")weapons/icicle_hit_world_03.wav"
};

static char g_BoltHitSFX[][] = {
	")weapons/fx/rics/arrow_impact_flesh.wav",
	")weapons/fx/rics/arrow_impact_flesh2.wav",
	")weapons/fx/rics/arrow_impact_flesh3.wav",
	")weapons/fx/rics/arrow_impact_flesh4.wav"
};

static char g_BoltHitMetalSFX[][] = {
	")weapons/fx/rics/arrow_impact_metal.wav",
	")weapons/fx/rics/arrow_impact_metal2.wav",
	")weapons/fx/rics/arrow_impact_metal4.wav"
};

int i_AuroraBeam, i_AuroraMist;

public void OnMapStart()
{
	PrecacheModel("materials/sprites/laserbeam.vmt");
	PrecacheModel(SPR_SNOW_TRAIL);
	PrecacheModel(SPR_SNOWFLAKE);
	PrecacheModel(SPR_GLOW);
	i_AuroraBeam = PrecacheModel(SPR_AURORABEAM);
	i_AuroraMist = PrecacheModel(SPR_AURORAMIST);
	PrecacheModel(MODEL_BOLT);

	PrecacheModel(MODEL_DRG);
	PrecacheModel(MODEL_AB_PARTICLEBODY);

	PrecacheParticleEffect(PARTICLE_SNOW_AURA_RED);
	PrecacheParticleEffect(PARTICLE_SNOW_AURA_BLUE);

	PrecacheSound(SOUND_AB_START);
	PrecacheSound(SOUND_AB_LOOP_1);
	PrecacheSound(SOUND_AB_LOOP_2);
	PrecacheSound(SOUND_AB_LOOP_3);
	PrecacheSound(SOUND_AB_STOP);
	PrecacheSound(SOUND_FROZEN_1);
	PrecacheSound(SOUND_FROZEN_2);
	PrecacheSound(SOUND_UNFROZEN);
	PrecacheSound(SOUND_ICICLE_HIT);
	PrecacheSound(SOUND_COLDSNAP_1);
	PrecacheSound(SOUND_COLDSNAP_2);
	PrecacheSound(SOUND_BOLT_CHARGE_START_1);
	//PrecacheSound(SOUND_BOLT_CHARGE_FINISH_1);
	PrecacheSound(SOUND_BOLT_IMPACT);

	for (int i = 0; i < sizeof(g_FrozenVulnSFX); i++) { PrecacheSound(g_FrozenVulnSFX[i]); }
	for (int i = 0; i < sizeof(g_BoltHitSFX); i++) { PrecacheSound(g_BoltHitSFX[i]); }
	for (int i = 0; i < sizeof(g_BoltHitMetalSFX); i++) { PrecacheSound(g_BoltHitMetalSFX[i]); }

	CFStocks_Precache();
}

public void OnPluginStart()
{
}

bool b_FrostboltIcon, b_AuroraIcon;

#define STATUS_CRYO_BUILDUP		"Cryo Buildup"
#define STATUS_FROZEN			"Frozen"

bool b_IceDamage[MAXPLAYERS + 1] = { false, ... };
bool b_TakingDamageFromFreezeBurst[2049] = { false, ... };

int i_FrozenAura[2049] = { -1, ... };
int i_ColdSnapSlot[2049] = { 0, ... };

float f_ImmuneToCryoBuildupUntil[2049] = { 0.0, ... };

CF_SpeedModifier g_FrozenSpeedPenalty[MAXPLAYERS + 1] = { null, ... };

Handle g_CryoDecayTimer[2049] = { null, ... };

public void Cryo_ApplyBuildup(int victim, int attacker, float amt)
{	
	//If the victim currently or recently has/had the Frozen debuff: do not apply any Cryo Buildup.
	if (CF_HasStatusEffect(victim, STATUS_FROZEN) || GetGameTime() < f_ImmuneToCryoBuildupUntil[victim])
		return;

	//The victim already has some Cryo Buildup; set the debuff's applicant to the attacker, then increase the buildup amount.
	if (CF_HasStatusEffect(victim, STATUS_CRYO_BUILDUP))
	{
		CF_SetStatusEffectApplicant(victim, STATUS_CRYO_BUILDUP, attacker);
		CF_SetStatusEffectActiveValue(victim, STATUS_CRYO_BUILDUP, CF_GetStatusEffectActiveValue(victim, STATUS_CRYO_BUILDUP) + amt);

		//If CF_OnStatusEffectActiveValueChanged_Post does NOT detect that we went above 100% Cryo Buildup: reset the decay timer.
		if (CF_HasStatusEffect(victim, STATUS_CRYO_BUILDUP))
			Cryo_ResetDecayTimer(victim);
	}
	else	//The victim does not already have Cryo Buildup; apply it and start the decay timer.
	{
		CF_ApplyStatusEffect(victim, STATUS_CRYO_BUILDUP, _, attacker, amt);
		Cryo_ResetDecayTimer(victim);
	}
}

public void Cryo_ResetDecayTimer(int victim)
{
	Cryo_ClearDecayTimer(victim);
	Cryo_StartDecayTimer(victim, CF_GetStatusEffectArgF(STATUS_CRYO_BUILDUP, "duration", 3.0));
}

public void Cryo_StartDecayTimer(int victim, float delay)
{
	DataPack pack = new DataPack();
	g_CryoDecayTimer[victim] = CreateDataTimer(delay, Cryo_Decay, pack, TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack, EntIndexToEntRef(victim));
	WritePackCell(pack, victim);
}

public Action Cryo_Decay(Handle timer, DataPack pack)
{
	ResetPack(pack);
	int victim = EntRefToEntIndex(ReadPackCell(pack));
	int cell = ReadPackCell(pack);

	g_CryoDecayTimer[cell] = null;

	if (IsValidEntity(victim) && CF_HasStatusEffect(victim, STATUS_CRYO_BUILDUP))
	{
		CF_SetStatusEffectActiveValue(victim, STATUS_CRYO_BUILDUP, CF_GetStatusEffectActiveValue(victim, STATUS_CRYO_BUILDUP) - CF_GetStatusEffectArgF(STATUS_CRYO_BUILDUP, "decay_rate", 0.05));
		if (CF_GetStatusEffectActiveValue(victim, STATUS_CRYO_BUILDUP) <= 0.0)
			CF_RemoveStatusEffect(victim, STATUS_CRYO_BUILDUP);
		else
			Cryo_StartDecayTimer(victim, 0.1);
	}

	return Plugin_Continue;
}

public void Cryo_ClearDecayTimer(int entity)
{
	delete g_CryoDecayTimer[entity];
	g_CryoDecayTimer[entity] = null;
}

public void Cryo_ApplyFrozen(int entity, int applicant)
{
	CF_RemoveStatusEffect(entity, STATUS_CRYO_BUILDUP);
	CF_ApplyStatusEffect(entity, STATUS_FROZEN, CF_GetStatusEffectArgF(STATUS_FROZEN, "duration", 6.0), applicant);
	Cryo_ClearDecayTimer(entity);
}

//This forward is called whenever a status effect's "Active Value" changes.
//Here, we use it to detect when the Active Value of Cryo Buildup has been changed.
//If we detect that it has reached 100%: we remove the Cryo Buildup status effect and apply the Frozen status effect.
public void CF_OnStatusEffectActiveValueChanged_Post(int entity, char[] effect, int applicant, float newValue)
{
	if (StrEqual(effect, STATUS_CRYO_BUILDUP) && newValue >= 1.0)
	{
		Cryo_ApplyFrozen(entity, applicant);
	}
}

//This forward is called whenever a status effect is applied.
//Here, we use it to detect when the Frozen status effect is applied, so that we can start VFX, deal damage, apply debuff conditions, etc.
public void CF_OnStatusEffectApplied_Post(int entity, char[] effect, int applicant)
{
	if (StrEqual(effect, STATUS_FROZEN))
	{
		b_TakingDamageFromFreezeBurst[entity] = true;

		if (IsValidClient(entity))
		{
			i_FrozenAura[entity] = EntIndexToEntRef(CF_AttachParticle(entity, PARTICLE_FROZEN_AURA, "root"));
			SDKHooks_TakeDamage(entity, applicant, applicant, CF_GetStatusEffectArgF(STATUS_FROZEN, "burst_damage", 30.0), DMG_PREVENT_PHYSICS_FORCE);

			float speedPenalty = 1.0 - CF_GetStatusEffectArgF(STATUS_FROZEN, "speed_penalty", 0.25);
			if (speedPenalty != 1.0)
				g_FrozenSpeedPenalty[entity] = CF_ApplyTemporarySpeedChange(entity, 1, speedPenalty, 0.0, 0, 0.0, false);
		}
		else
		{
			i_FrozenAura[entity] = EntIndexToEntRef(AttachParticleToEntity(entity, PARTICLE_FROZEN_AURA, "root"));
			SDKHooks_TakeDamage(entity, applicant, applicant, CF_GetStatusEffectArgF(STATUS_FROZEN, "burst_damage_non_player", 60.0), DMG_PREVENT_PHYSICS_FORCE);
		}

		b_TakingDamageFromFreezeBurst[entity] = false;

		float pos[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
		SpawnParticle(pos, PARTICLE_FROZEN_PROC, 0.2);

		EmitSoundToAll(SOUND_FROZEN_1, entity, _, 110, _, _, 90);
		EmitSoundToAll(SOUND_FROZEN_2, entity, _, 110, _, _, 90);
		if (IsValidClient(applicant))
		{
			EmitSoundToClient(applicant, SOUND_FROZEN_1);
			EmitSoundToClient(applicant, SOUND_FROZEN_2);
		}
	}

	if (StrEqual(effect, STATUS_CRYO_BUILDUP) && CF_GetStatusEffectActiveValue(entity, STATUS_CRYO_BUILDUP) >= 1.0)
	{
		Cryo_ApplyFrozen(entity, applicant);
	}
}

//This forward is called whenever a status effect is removed.
//Here, we use it to terminate VFX, as well as to give a window of immunity to Cryo Buildup to make it fairer to fight against.
public void CF_OnStatusEffectRemoved(int entity, char[] effect, int applicant)
{
	if (StrEqual(effect, STATUS_FROZEN))
	{
		f_ImmuneToCryoBuildupUntil[entity] = GetGameTime() + CF_GetStatusEffectArgF(STATUS_FROZEN, "immunity_time", 3.0);
		EmitSoundToAll(SOUND_UNFROZEN, entity, _, 110, _, _, 80);

		if (IsValidClient(entity) && g_FrozenSpeedPenalty[entity].b_Exists)
			g_FrozenSpeedPenalty[entity].Destroy();

		int particle = EntRefToEntIndex(i_FrozenAura[entity]);
		if (IsValidEntity(particle))
			RemoveEntity(particle);
	}
}

public Action CF_OnCalcAttackInterval(int client, int weapon, int slot, char classname[255], float &rate)
{
	if (!CF_HasStatusEffect(client, STATUS_FROZEN))
		return Plugin_Continue;

	rate *= (1.0 + CF_GetStatusEffectArgF(STATUS_FROZEN, "rate_penalty", 0.2));
	return Plugin_Changed;
}

public Action CF_OnTakeDamageAlive_Bonus(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int &damagecustom)
{
	Action ReturnValue = Plugin_Continue;

	if (CF_HasStatusEffect(victim, STATUS_FROZEN))
	{
		bool doMult = !b_TakingDamageFromFreezeBurst[victim];

		if (IsValidClient(attacker) && !b_IceDamage[attacker] && IsValidEntity(weapon))
		{
			float mult = TF2CustAttr_GetFloat(weapon, "damage against frozen multiplier", 1.0);
			if (mult != 1.0)
			{
				damage *= mult;
				ReturnValue = Plugin_Changed;
				doMult = false;
			}

			if (TF2CustAttr_GetInt(weapon, "remove frozen", 0) != 0)
				CF_RemoveStatusEffect(victim, STATUS_FROZEN);

			if (TF2CustAttr_GetInt(weapon, "cold snap fx", 0) != 0)
			{
				EmitSoundToAll(SOUND_COLDSNAP_1, victim, _, 110);
				EmitSoundToAll(SOUND_COLDSNAP_2, victim, _, 110);
				if (IsValidClient(victim))
					PlayCritVictimSound(victim);

				EmitSoundToClient(attacker, SOUND_COLDSNAP_1);
				EmitSoundToClient(attacker, SOUND_COLDSNAP_2);
				PlayCritSound(attacker);

				float pos[3];
				GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", pos);
				SpawnParticle(pos, PARTICLE_COLDSNAP_1, 0.2);
				SpawnParticle(pos, PARTICLE_COLDSNAP_2, 0.2);
			}

			if (IsValidClient(victim))
			{
				i_ColdSnapSlot[attacker] = TF2CustAttr_GetInt(weapon, "cold snap ability", 0);
				RequestFrame(ColdSnap_Reset, GetClientUserId(attacker));
			}
		}

		if (doMult)
		{
			damage *= (1.0 + CF_GetStatusEffectArgF(STATUS_FROZEN, "vulnerability", 0.2));
			ReturnValue = Plugin_Changed;

			if (IsValidClient(victim))
				EmitSoundToClient(victim, g_FrozenVulnSFX[GetRandomInt(0, sizeof(g_FrozenVulnSFX) - 1)]);
			if (IsValidClient(attacker))
				EmitSoundToClient(attacker, g_FrozenVulnSFX[GetRandomInt(0, sizeof(g_FrozenVulnSFX) - 1)]);
		}
	}

	return ReturnValue;
}

public void ColdSnap_Reset(int id)
{
	int client = GetClientOfUserId(id);
	if (IsValidClient(client))
		i_ColdSnapSlot[client] = 0;
}

public void CF_OnPlayerKilled(int victim, int inflictor, int attacker, int deadRinger)
{
	if (deadRinger > 0 || !IsValidClient(attacker) || i_ColdSnapSlot[attacker] == 0)
		return;

	CF_DoAbilitySlot(attacker, i_ColdSnapSlot[attacker]);
}

float f_ABWidth[MAXPLAYERS + 1] = { 0.0, ... };
float f_ABRange[MAXPLAYERS + 1] = { 0.0, ... };
float f_ABDamage[MAXPLAYERS + 1] = { 0.0, ... };
float f_ABInterval[MAXPLAYERS + 1] = { 0.0, ... };
float f_ABNextHit[MAXPLAYERS + 1] = { 0.0, ... };
float f_ABDrainInterval[MAXPLAYERS + 1] = { 0.0, ... };
float f_ABNextDrain[MAXPLAYERS + 1] = { 0.0, ... };
float f_ABCost[MAXPLAYERS + 1] = { 0.0, ... };
float f_ABRegenStopgap[MAXPLAYERS + 1] = { 0.0, ... };
float f_ABAttackStopgap[MAXPLAYERS + 1] = { 0.0, ... };
float f_ABBuildup[MAXPLAYERS + 1] = { 0.0, ... };
float f_ABNextRing[MAXPLAYERS + 1] = { 0.0, ... };

float f_ABSlowDownMult[2049] = { 0.0, ... };

int i_ABWeapon[MAXPLAYERS + 1] = { -1, ... };
int i_ABBeamEnt[MAXPLAYERS + 1] = { -1, ... };
int i_ABStartEnt[MAXPLAYERS + 1] = { -1, ... };
int i_ABEndEnt[MAXPLAYERS + 1] = { -1, ... };
int i_ABCanister[MAXPLAYERS + 1] = { -1, ... };
int i_ABTrail[2049] = { -1, ... };
int i_ABTargetColors[2049][3];

bool b_ABActive[MAXPLAYERS + 1] = { false, ... };

public void AB_Fire(int client, char abilityName[255])
{
	float startPos[3], ang[3];
	GetClientEyePosition(client, startPos);
	GetClientEyeAngles(client, ang);

	i_ABWeapon[client] = EntIndexToEntRef(TF2_GetActiveWeapon(client));
	f_ABWidth[client] = CF_GetArgF(client, KHOLDROZ, abilityName, "width", 20.0);
	f_ABRange[client] = CF_GetArgF(client, KHOLDROZ, abilityName, "range", 120.0);
	f_ABDamage[client] = CF_GetArgF(client, KHOLDROZ, abilityName, "damage", 6.0);
	f_ABInterval[client] = CF_GetArgF(client, KHOLDROZ, abilityName, "hit_interval", 6.0);
	f_ABNextHit[client] = GetGameTime() + f_ABInterval[client];
	f_ABDrainInterval[client] = CF_GetArgF(client, KHOLDROZ, abilityName, "drain_interval", 6.0);
	f_ABNextDrain[client] = GetGameTime() + f_ABDrainInterval[client];
	f_ABCost[client] = CF_GetArgF(client, KHOLDROZ, abilityName, "cost", 5.0);
	f_ABRegenStopgap[client] = CF_GetArgF(client, KHOLDROZ, abilityName, "regen_stopgap", 3.0);
	f_ABAttackStopgap[client] = CF_GetArgF(client, KHOLDROZ, abilityName, "attack_stopgap", 1.2);
	f_ABBuildup[client] = CF_GetArgF(client, KHOLDROZ, abilityName, "cryo_buildup", 0.06);

	b_AuroraIcon = true;
	CF_FireGenericLaser(client, startPos, ang, f_ABWidth[client], f_ABRange[client], f_ABDamage[client], DMG_ENERGYBEAM, AB_GetWeapon(client), client, KHOLDROZ, _, AB_OnHit, AB_DrawLaser);
	b_AuroraIcon = false;
	b_IceDamage[client] = false;

	CF_SetTimeUntilResourceRegen(client, CF_GetTimeUntilResourceRegen(client) + f_ABDrainInterval[client] + 0.5);
	SetEntPropFloat(AB_GetWeapon(client), Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + 999.0);

	b_ABActive[client] = true;

	EmitSoundToAll(SOUND_AB_START, client, _, _, _, _, 120);
	EmitSoundToAll(SOUND_AB_LOOP_1, client, _, 105, _, _, GetRandomInt(60, 90));
	EmitSoundToAll(SOUND_AB_LOOP_1, client, _, 105, _, _, GetRandomInt(110, 140));
	EmitSoundToAll(SOUND_AB_LOOP_2, client, _, 90, _, 0.3, 60);
	EmitSoundToAll(SOUND_AB_LOOP_3, client, _, 110);
}

float vec_ABRingTargPos[2049][3];

float f_ABRingTravelTime = 1.0;

public void AB_ShootRing(int client, float startPos[3], float ang[3], float endPos[3])
{
	int x, y;

	int color[4];
	color[0] = TF2_GetClientTeam(client) == TFTeam_Red ? 255 : 180;
	color[1] = 180;
	color[2] = TF2_GetClientTeam(client) == TFTeam_Blue ? 255 : 180;
	color[3] = 140;

	if (SpawnRing_Controllable(startPos, ang, f_ABWidth[client] * 0.25, i_AuroraMist, _, _, f_ABRingTravelTime, 12.0, 0.0, color, 10, _, x, y))
	{
		float dummy[3];
		GetAngleBetweenPoints(startPos, endPos, dummy);

		dummy[0] += 90.0;
		GetPointInDirection(endPos, dummy, f_ABWidth[client] * 0.75, vec_ABRingTargPos[x]);

		dummy[0] -= 180.0;
		GetPointInDirection(endPos, dummy, f_ABWidth[client] * 0.75, vec_ABRingTargPos[y]);

		RequestFrame(AB_MoveRing, EntIndexToEntRef(x));
		RequestFrame(AB_MoveRing, EntIndexToEntRef(y));
	}
}

public void AB_MoveRing(int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (!IsValidEntity(ent))
		return;

	float currentPos[3], buffer[3];
	GetEntPropVector(ent, Prop_Data, "m_vecAbsOrigin", currentPos);
	SubtractVectors(vec_ABRingTargPos[ent], currentPos, buffer);

	ScaleVector(buffer, (GetTickInterval() / f_ABRingTravelTime) * 4.0);

	AddVectors(currentPos, buffer, currentPos);

	TeleportEntity(ent, currentPos);

	RequestFrame(AB_MoveRing, ref);
}

public void AB_OnHit(int victim, int attacker)
{
	b_IceDamage[attacker] = true;
	Cryo_ApplyBuildup(victim, attacker, f_ABBuildup[attacker]);
}

public void AB_DrawLaser(int client, float startPos[3], float endPos[3], float ang[3], float width)
{	
	int start = AB_GetStartEnt(client);
	int end = AB_GetEndEnt(client);
	int can = AB_GetCanister(client);
	int beam = AB_GetBeamEnt(client);

	if (!IsValidEntity(beam) || !IsValidEntity(start) || !IsValidEntity(end) || !IsValidEntity(can))
	{
		AB_CreateLaser(client, startPos, endPos, ang);
		return;
	}

	float originalStart[3], originalEnd[3];
	originalStart = startPos;
	originalEnd = endPos;

	startPos[2] -= 17.5 * CF_GetCharacterScale(client);
	endPos[2] -= 17.5 * CF_GetCharacterScale(client);

	//AB_ShootRing(client, startPos, ang, endPos);
	
	GetPointInDirection(startPos, ang, 20.0, startPos);
	GetPointInDirection(endPos, ang, 20.0, endPos);

	TeleportEntitySmoothly(start, startPos);
	TeleportEntitySmoothly(end, endPos);

	float canPos[3], canEndPos[3], canAng[3];
	float originalDist = GetVectorDistance(originalStart, originalEnd);
	float canDist = fmin(80.0, originalDist);
	GetPointInDirection(startPos, ang, canDist, canPos);
	CF_HasLineOfSight(startPos, canPos, _, canPos, client);
	GetPointInDirection(endPos, ang, canDist, canEndPos);
	CF_HasLineOfSight(canPos, canEndPos, _, canEndPos, client);

	//This shrinks the canister (and therefore the snow particle) so that it doesn't clip through walls. 
	//The trade-off is that the particle gets way too bright if the distance is too short, but that's preferable to having wallhacks against Kholdroz just because he fired Aurora Beam in a narrow space.
	char scalechar[16];
	float scale = fmin(f_ABRange[client] / 59.121, GetVectorDistance(canPos, canEndPos) / 59.121);
	Format(scalechar, sizeof(scalechar), "%f", scale);
	DispatchKeyValue(can, "modelscale", scalechar);

	canAng = ang;
	canAng[0] -= 90.0;
	TeleportEntitySmoothly(can, canPos, canAng);
	SetEntityRenderMode(can, RENDER_NONE);

	int r = 255, b = 200;
	if (TF2_GetClientTeam(client) == TFTeam_Blue)
	{
		r = 200;
		b = 255;
	}

	int currentR, currentG, currentB, currentA;
	GetEntityRenderColor(beam, currentR, currentG, currentB, currentA);

	currentR += 4;
	if (currentR > r)
		currentR = r;
	currentG += 4;
	if (currentG > 200)
		currentG = 200;
	currentB += 4;
	if (currentB > b)
		currentB = b;

	SetEntityRenderColor(beam, currentR, currentG, currentB, 90 + RoundToFloor((Sine(GetGameTime() * 4.0) * 30.0)));

	//float amplitude = GetEntPropFloat(beam, Prop_Data, "m_fAmplitude");
    SetEntPropFloat(beam, Prop_Data, "m_fAmplitude", 0.5);

	//These are backwards on purpose!
	SetEntPropFloat(beam, Prop_Data, "m_fEndWidth", (f_ABWidth[client] * 0.1) + (Sine(GetGameTime() * 3.0) * (f_ABWidth[client] * 0.05)));
	SetEntPropFloat(beam, Prop_Data, "m_fWidth", (f_ABWidth[client]) + (Sine(GetGameTime() * 3.0) * (f_ABWidth[client] * 0.1)));

	if (GetGameTime() >= f_ABNextRing[client])
	{
		AB_ShootRing(client, startPos, ang, endPos);
		f_ABNextRing[client] = GetGameTime() + 0.1;
	}
}

public void AB_SlowDown(int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (!IsValidEntity(ent))
		return;

	float vel[3];
	GetEntPropVector(ent, Prop_Data, "m_vecVelocity", vel);
	ScaleVector(vel, f_ABSlowDownMult[ent]);
	vel[0] += GetRandomFloat(-vel[0] * 0.1, vel[0] * 0.1);
	vel[1] += GetRandomFloat(-vel[1] * 0.1, vel[1] * 0.1);

	TeleportEntity(ent, _, _, vel);

	RequestFrame(AB_SlowDown, ref);
}

public void AB_DeleteOnContact(int projectile, int owner, int team, int entity)
{
	if (CF_IsValidTarget(entity, grabEnemyTeam(owner)))
		return;

	RemoveEntity(projectile);
}

public void AB_FadeSnowflake(int sprite)
{
	int color[3];
	int a;
	GetEntityRenderColor(sprite, color[0], color[1], color[2], a);

	for (int i = 0; i < 3; i++)
		color[i] = RoundFloat(LerpCurve(float(color[i]), float(i_ABTargetColors[sprite][i]), 3.0, 6.0));
	
	SetEntityRenderColor(sprite, color[0], color[1], color[2], a);
}

public void AB_CreateLaser(int client, float startPos[3], float endPos[3], float ang[3])
{
	//AB_ShootRing(client, startPos, ang, endPos);

	AB_RemoveLaser(client);

	int start, end;
	int beam = CreateEnvBeam(-1, -1, startPos, endPos, _, _, end, start, 200, 200, 200, 20, SPR_AURORABEAM, 0.1, 0.1, _, 0.0, 22.5);
	if (IsValidEntity(beam) && IsValidEntity(start) && IsValidEntity(start))
	{
		i_ABBeamEnt[client] = EntIndexToEntRef(beam);
		i_ABStartEnt[client] = EntIndexToEntRef(start);
		i_ABEndEnt[client] = EntIndexToEntRef(end);

		RequestFrame(AB_HoldLaser, GetClientUserId(client));
	}

	GetAngleBetweenPoints(startPos, endPos, ang);
	ang[0] -= 90.0;

	int canister = SpawnPropDynamic(MODEL_AB_PARTICLEBODY, startPos, ang, _, GetVectorDistance(startPos, endPos) / 59.121);	//59.121 is the height of the canister in HU.
	if (IsValidEntity(canister))
	{
		i_ABCanister[client] = EntIndexToEntRef(canister);
		AttachAura(canister, TF2_GetClientTeam(client) == TFTeam_Red ? PARTICLE_SNOW_AURA_RED : PARTICLE_SNOW_AURA_BLUE);
		SetEntityRenderMode(canister, RENDER_TRANSALPHA);
		SetEntityRenderColor(canister, 1, 1, 1, 0);
	}
}

public void AB_HoldLaser(int id)
{
	int client = GetClientOfUserId(id);

	if (!IsValidMulti(client) || !b_ABActive[client] || !IsValidEntity(AB_GetWeapon(client)))
	{
		AB_Terminate(client);
		return;
	}

	float startPos[3], ang[3];
	GetClientEyePosition(client, startPos);
	GetClientEyeAngles(client, ang);

	float gt = GetGameTime();

	SetEntPropFloat(AB_GetWeapon(client), Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + 999.0);

	if (gt >= f_ABNextDrain[client] && CF_GetMaxSpecialResource(client) > 0.0)
	{
		float current = CF_GetSpecialResource(client);
		if (current < f_ABCost[client])
		{
			CF_EndHeldAbility(client, KHOLDROZ, BEAM, false);
			return;
		}

		CF_SetSpecialResource(client, current - f_ABCost[client]);
		CF_SetTimeUntilResourceRegen(client, CF_GetTimeUntilResourceRegen(client) + f_ABDrainInterval[client] + 0.5);
		f_ABNextDrain[client] = gt + f_ABDrainInterval[client];
	}

	if (gt >= f_ABNextHit[client])
	{
		b_AuroraIcon = true;
		CF_FireGenericLaser(client, startPos, ang, f_ABWidth[client], f_ABRange[client], f_ABDamage[client], DMG_ENERGYBEAM|DMG_PREVENT_PHYSICS_FORCE, AB_GetWeapon(client), client, KHOLDROZ, _, AB_OnHit, AB_DrawLaser);
		b_AuroraIcon = false;
		b_IceDamage[client] = false;
		f_ABNextHit[client] = gt + f_ABInterval[client];
	}
	else
		CF_FireGenericLaser(client, startPos, ang, f_ABWidth[client], f_ABRange[client], _, _, _, _, KHOLDROZ, _, _, AB_DrawLaser);

	RequestFrame(AB_HoldLaser, id);
}

public void AB_Terminate(int client)
{
	AB_RemoveLaser(client);

	if (b_ABActive[client])
	{
		CF_SetTimeUntilResourceRegen(client, CF_GetTimeUntilResourceRegen(client) + f_ABRegenStopgap[client]);

		if (IsValidEntity(AB_GetWeapon(client)))
			SetEntPropFloat(AB_GetWeapon(client), Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + f_ABAttackStopgap[client]);

		EmitSoundToAll(SOUND_AB_STOP, client, _, _, _, _, 120);
		StopSound(client, SNDCHAN_AUTO, SOUND_AB_LOOP_1);
		StopSound(client, SNDCHAN_AUTO, SOUND_AB_LOOP_1);
		StopSound(client, SNDCHAN_AUTO, SOUND_AB_LOOP_2);
		StopSound(client, SNDCHAN_AUTO, SOUND_AB_LOOP_3);
	}

	b_ABActive[client] = false;
}

public void AB_RemoveLaser(int client)
{
	int ent = AB_GetBeamEnt(client);
	if (IsValidEntity(ent))
	{
		RequestFrame(AB_DissipateBeam, EntIndexToEntRef(ent));
	}

	ent = AB_GetStartEnt(client);
	if (IsValidEntity(ent))
		CreateTimer(3.0, Timer_RemoveEntity, EntIndexToEntRef(ent), TIMER_FLAG_NO_MAPCHANGE);

	ent = AB_GetEndEnt(client);
	if (IsValidEntity(ent))
		CreateTimer(3.0, Timer_RemoveEntity, EntIndexToEntRef(ent), TIMER_FLAG_NO_MAPCHANGE);

	ent = AB_GetCanister(client);
	if (IsValidEntity(ent))
		RemoveEntity(ent);

	i_ABBeamEnt[client] = -1;
	i_ABStartEnt[client] = -1;
	i_ABEndEnt[client] = -1;
	i_ABCanister[client] = -1;
}

void AB_DissipateBeam(int ref)
{
	int beam = EntRefToEntIndex(ref);
	
	if (!IsValidEntity(beam))
	{
		return;
	}

	int r, g, b, a;
	GetEntityRenderColor(beam, r, g, b, a);
	a = RoundFloat(LerpCurve(float(a), 0.0, 6.0, 12.0));
	if (a <= 0)
	{
		RemoveEntity(beam);
		return;
	}

	SetEntityRenderColor(beam, r, g, b, a);

	float amplitude = GetEntPropFloat(beam, Prop_Data, "m_fAmplitude");
    if (amplitude > 0.0)
    {
        amplitude = LerpCurve(amplitude, 0.0, 0.25, 0.5);
        SetEntPropFloat(beam, Prop_Data, "m_fAmplitude", amplitude);
    }

	float width = GetEntPropFloat(beam, Prop_Data, "m_fWidth");
    if (width > 0.0)
    {
        width = LerpCurve(amplitude, 0.0, 1.0, 2.0);
        SetEntPropFloat(beam, Prop_Data, "m_fWidth", width);
    	SetEntPropFloat(beam, Prop_Data, "m_fEndWidth", width);
    }

	RequestFrame(AB_DissipateBeam, ref);
}

int AB_GetWeapon(int client) { return EntRefToEntIndex(i_ABWeapon[client]); }
int AB_GetBeamEnt(int client) { return EntRefToEntIndex(i_ABBeamEnt[client]); }
int AB_GetStartEnt(int client) { return EntRefToEntIndex(i_ABStartEnt[client]); }
int AB_GetEndEnt(int client) { return EntRefToEntIndex(i_ABEndEnt[client]); }
int AB_GetCanister(int client) { return EntRefToEntIndex(i_ABCanister[client]); }

float f_BoltChargeTime[MAXPLAYERS + 1] = { 0.0, ... };
float f_BoltChargeStartTime[MAXPLAYERS + 1] = { 0.0, ... };
float f_BoltChargeCost[MAXPLAYERS + 1] = { 0.0, ... };
float f_BoltBaseVel[MAXPLAYERS + 1] = { 0.0, ... };
float f_BoltBonusVel[MAXPLAYERS + 1] = { 0.0, ... };
float f_BoltBaseDMG[MAXPLAYERS + 1] = { 0.0, ... };
float f_BoltBonusDMG[MAXPLAYERS + 1] = { 0.0, ... };
float f_BoltDMG[2049] = { 0.0, ... };
float f_BoltHSMult[2049] = { 1.0, ... };
float f_BoltFrozenMult[2049] = { 1.0, ... };
float f_BoltBaseCryo[MAXPLAYERS + 1] = { 0.0, ... };
float f_BoltBonusCryo[MAXPLAYERS + 1] = { 0.0, ... };
float f_BoltCryo[2049] = { 0.0, ... };
float f_BoltCryoHSMult[2049] = { 1.0, ... };
float f_BoltChargeAmt[2049] = { 0.0, ... };

bool b_BoltCanHeadshot[2049] = { false, ... };
bool b_BoltFullCharge[MAXPLAYERS + 1] = { false, ... };

int i_BoltProp[MAXPLAYERS + 1] = { -1, ... };

Handle g_BoltChargeTimer[MAXPLAYERS + 1] = { null, ... };

public void Bolt_StartCharging(int client, char ability[255])
{
	f_BoltChargeTime[client] = CF_GetArgF(client, KHOLDROZ, ability, "charge_time", 1.2);
	f_BoltChargeStartTime[client] = GetGameTime();

	f_BoltChargeCost[client] = (CF_GetArgF(client, KHOLDROZ, ability, "charge_cost", 10.0) / f_BoltChargeTime[client]) * 0.1;

	f_BoltBaseVel[client] = CF_GetArgF(client, KHOLDROZ, ability, "velocity_base", 1200.0);
	f_BoltBonusVel[client] = CF_GetArgF(client, KHOLDROZ, ability, "velocity_bonus", 600.0);

	b_BoltCanHeadshot[client] = CF_GetArgI(client, KHOLDROZ, ability, "can_headshot", 1) != 0;

	f_BoltBaseDMG[client] = CF_GetArgF(client, KHOLDROZ, ability, "damage_base", 30.0);
	f_BoltBonusDMG[client] = CF_GetArgF(client, KHOLDROZ, ability, "damage_bonus", 60.0);

	f_BoltHSMult[client] = CF_GetArgF(client, KHOLDROZ, ability, "damage_hs_mult", 1.5);
	f_BoltFrozenMult[client] = CF_GetArgF(client, KHOLDROZ, ability, "damage_frozen_mult", 1.5);

	f_BoltBaseCryo[client] = CF_GetArgF(client, KHOLDROZ, ability, "cryo_base", 0.1);
	f_BoltBonusCryo[client] = CF_GetArgF(client, KHOLDROZ, ability, "cryo_bonus", 0.25);
	f_BoltCryoHSMult[client] = CF_GetArgF(client, KHOLDROZ, ability, "cryo_hs_mult", 3.0);

	EmitSoundToAll(SOUND_BOLT_CHARGE_START_1, client, _, 110, _, _, GetRandomInt(120, 140));

	if (f_BoltChargeTime[client] > 0.0)
	{
		b_BoltFullCharge[client] = false;

		Bolt_KillChargeTimer(client);

		DataPack pack = new DataPack();
		g_BoltChargeTimer[client] = CreateDataTimer(0.1, Bolt_ChargeLogic, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		WritePackCell(pack, GetClientUserId(client));
		WritePackCell(pack, client);

		float pos[3], ang[3];
		GetClientEyeAngles(client, ang);
		Bolt_GetPropLocation(client, pos);
		ang[0] += 90.0;

		int prop = SpawnPropDynamic(MODEL_BOLT, pos, ang);
		if (IsValidEntity(prop))
		{
			i_BoltProp[client] = EntIndexToEntRef(prop);
			AttachAura(prop, TF2_GetClientTeam(client) == TFTeam_Red ? PARTICLE_SNOW_AURA_RED : PARTICLE_SNOW_AURA_BLUE);
			RequestFrame(Bolt_MovePropToLocation, GetClientUserId(client));
		}
	}
	else
	{
		Bolt_Fire(client);
	}
}

public void Bolt_GetPropLocation(int client, float endOutput[3])
{
	float pos[3], ang[3];
	GetClientEyePosition(client, pos);
	GetClientEyeAngles(client, ang);

	GetPointInDirection(pos, ang, 60.0, endOutput);
	endOutput[2] -= 20.0;
}

public void Bolt_MovePropToLocation(int id)
{
	int client = GetClientOfUserId(id);
	if (!IsValidMulti(client))
		return;

	int prop = EntRefToEntIndex(i_BoltProp[client]);
	if (!IsValidEntity(prop))
		return;

	float currentPos[3], targPos[3], ang[3], buffer[3];
	GetClientEyeAngles(client, ang);
	Bolt_GetPropLocation(client, targPos);
	GetEntPropVector(prop, Prop_Data, "m_vecAbsOrigin", currentPos);
	SubtractVectors(targPos, currentPos, buffer);
	ScaleVector(buffer, (GetTickInterval() / 1.0) * 12.0);

	AddVectors(currentPos, buffer, currentPos);

	ang[0] += 90.0;

	float rand = 8.0 - (Bolt_GetChargePercentage(client) * 7.0);
	if (rand > 0.0)
	{
		float dummy[3];
		dummy = ang;
		for (int i = 0; i < 3; i++)
			dummy[i] += GetRandomFloat(-rand, rand);

		SubtractVectors(ang, dummy, dummy);
		ScaleVector(dummy, (GetTickInterval() / 1.0) * 24.0);

		AddVectors(ang, dummy, ang);
	}

	TeleportEntity(prop, currentPos, ang);

	float scale = Bolt_GetPropScale(client);
	char scalechar[16];
	Format(scalechar, sizeof(scalechar), "%f", scale);
	DispatchKeyValue(prop, "modelscale", scalechar);

	RequestFrame(Bolt_MovePropToLocation, id);
}

public Action Bolt_ChargeLogic(Handle timer, DataPack pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	int cell = ReadPackCell(pack);

	if (!IsValidMulti(client))
	{
		g_BoltChargeTimer[cell] = null;
		return Plugin_Stop;
	}

	if (f_BoltChargeCost[client] > 0.0)
	{
		CF_SetTimeUntilResourceRegen(client, 1.0);

		if (!b_BoltFullCharge[client])
		{
			if (f_BoltChargeCost[client] > CF_GetSpecialResource(client))
				f_BoltChargeStartTime[client] += 0.1;
			else
				CF_GiveSpecialResource(client, -f_BoltChargeCost[client]);
		}
	}

	if (!b_BoltFullCharge[client] && Bolt_GetChargePercentage(client) >= 1.0)
	{
		b_BoltFullCharge[client] = true;
		EmitSoundToAll(SOUND_BOLT_CHARGE_FINISH_1, client, _, 110);
	}

	return Plugin_Continue;
}

public void Bolt_Fire(int client)
{
	int bolt = CF_FireGenericRocket(client, 0.0, 0.0, _, _, KHOLDROZ, Bolt_OnHit);
	if (IsValidEntity(bolt))
	{
		float charge = Bolt_GetChargePercentage(client);

		float pos[3], ang[3], vel[3];
		GetClientEyePosition(client, pos);
		GetClientEyeAngles(client, ang);
		GetPointInDirection(pos, ang, 60.0, pos);

		GetVelocityInDirection(ang, f_BoltBaseVel[client] + (charge * f_BoltBonusVel[client]), vel);

		SetEntityModel(bolt, MODEL_DRG);
		TeleportEntity(bolt, pos, ang, vel);

		f_BoltDMG[bolt] = f_BoltBaseDMG[client] + (charge * f_BoltBonusDMG[client]);
		f_BoltCryo[bolt] = f_BoltBaseCryo[client] + (charge * f_BoltBonusCryo[client]);
		f_BoltFrozenMult[bolt] = f_BoltFrozenMult[client];
		b_BoltCanHeadshot[bolt] = b_BoltCanHeadshot[client];
		f_BoltHSMult[bolt] = f_BoltHSMult[client];
		f_BoltCryoHSMult[bolt] = f_BoltCryoHSMult[client];
		f_BoltChargeAmt[bolt] = charge;

		int prop = EntRefToEntIndex(i_BoltProp[client]);
		if (IsValidEntity(prop))
		{
			ang[0] += 90.0;
			TeleportEntity(prop, pos, ang);
			
			SetParent(bolt, prop);
			i_BoltProp[client] = -1;
		}
	}

	Bolt_KillChargeTimer(client);
}

public void Bolt_OnHit(int bolt, int owner, int team, int other, float pos[3])
{
	int pitch = 120 - RoundFloat(40.0 * f_BoltChargeAmt[bolt]);

	if (CF_IsValidTarget(other, grabEnemyTeam(owner)))
	{
		bool frozen = CF_HasStatusEffect(other, STATUS_FROZEN);
		bool player = IsValidClient(other);

		float dmg = f_BoltDMG[bolt];
		if (frozen)
			dmg *= f_BoltFrozenMult[bolt];

		float cryo = f_BoltCryo[bolt];

		bool hs = b_BoltCanHeadshot[bolt];
		if (hs)
		{
			float ang[3], endPos[3];
			GetEntPropVector(bolt, Prop_Send, "m_angRotation", ang);
			GetPointInDirection(pos, ang, 40.0, endPos);

			CF_TraceShot(owner, other, pos, endPos, hs);

			if (hs)
				SpawnParticle(pos, "minicrit_text", 0.2);
		}

		if (hs)
		{
			dmg *= f_BoltHSMult[bolt];
			cryo *= f_BoltCryoHSMult[bolt];

			PlayMiniCritSound(owner);
			if (player)
				PlayMiniCritSound(other);
		}

		int snd = GetRandomInt(0, (player ? sizeof(g_BoltHitSFX) : sizeof(g_BoltHitMetalSFX)) - 1);
		EmitSoundToClient(owner, (player ? g_BoltHitSFX[snd] : g_BoltHitMetalSFX[snd]), _, _, _, _, _, pitch);
		EmitSoundToAll((player ? g_BoltHitSFX[snd] : g_BoltHitMetalSFX[snd]), other, _, _, _, _, pitch);

		Cryo_ApplyBuildup(other, owner, cryo);

		b_FrostboltIcon = true;
		SDKHooks_TakeDamage(other, bolt, owner, dmg, DMG_BULLET);
		b_FrostboltIcon = false;
	}

	EmitSoundToAll(SOUND_BOLT_IMPACT, bolt, _, _, _, _, pitch);
	SpawnParticle(pos, PARTICLE_BOLT_IMPACT, 0.2);
	RemoveEntity(bolt);
}

public void Bolt_KillChargeTimer(int client)
{
	delete g_BoltChargeTimer[client];
	g_BoltChargeTimer[client] = null;
}

public void Bolt_Terminate(int client)
{
	Bolt_KillChargeTimer(client);
	int prop = EntRefToEntIndex(i_BoltProp[client]);
	if (IsValidEntity(prop))
		RemoveEntity(prop);
}

public float Bolt_GetPropScale(int client) { return 1.0 + (Bolt_GetChargePercentage(client) * 1.2); }

public float Bolt_GetChargePercentage(int client)
{
	float gt = GetGameTime();
	if ((gt >= f_BoltChargeStartTime[client] + f_BoltChargeTime[client]) || f_BoltChargeTime[client] <= 0.0)
		return 1.0;
	
	return (gt - f_BoltChargeStartTime[client]) / f_BoltChargeTime[client];
}

public void CF_OnCharacterCreated(int client)
{
	AB_Terminate(client);
	Bolt_Terminate(client);
}

public void CF_OnCharacterRemoved(int client)
{
	AB_Terminate(client);
	Bolt_Terminate(client);
	i_ColdSnapSlot[client] = 0;
}

public void CF_OnAbility(int client, char pluginName[255], char abilityName[255])
{
	if (!StrEqual(pluginName, KHOLDROZ))
		return;
	
	if (StrContains(abilityName, BEAM) != -1)
		AB_Fire(client, abilityName);

	if (StrContains(abilityName, BOLT) != -1)
		Bolt_StartCharging(client, abilityName);
}

public void CF_OnHeldEnd_Ability(int client, bool resupply, char pluginName[255], char abilityName[255])
{
	if (!StrEqual(pluginName, KHOLDROZ))
		return;

	if (StrContains(abilityName, BEAM) != -1)
		AB_Terminate(client);
	if (StrContains(abilityName, BOLT) != -1 && g_BoltChargeTimer[client] != null)
		Bolt_Fire(client);
}

public void OnEntityDestroyed(int entity)
{
	if (entity < 0 || entity > 2048)
		return;

	if (i_ABTrail[entity] != -1)
	{
		int trail = EntRefToEntIndex(i_ABTrail[entity]);
		if (IsValidEntity(trail))
		{
			SetParent(trail, trail);
		}

		i_ABTrail[entity] = -1;
	}
}

#if defined _pnpc_included_

public void PNPC_OnPlayerRagdoll(int victim, int attacker, int inflictor, bool &freeze, bool &cloaked, bool &ash, bool &gold, bool &shocked, bool &burning, bool &gib)
{
	if (b_IceDamage[attacker])
	{
		freeze = true;
		b_IceDamage[attacker] = false;
	}
}

#endif

public void CF_OnHUDDisplayed(int client, char HUDText[255], int &r, int &g, int &b, int &a)
{
	if (g_BoltChargeTimer[client] != null)
	{
		float charge = Bolt_GetChargePercentage(client);

		Format(HUDText, sizeof(HUDText), "CHARGING FROSTBOLT: %i[PERCENT]\n \n\n%s", RoundToFloor(100.0 * charge), HUDText);
	}
}

public Action CF_OnPlayerKilled_Pre(int &victim, int &inflictor, int &attacker, char weapon[255], char console[255], int &custom, int deadRinger, int &critType, int &damagebits)
{
	if (b_FrostboltIcon)
	{
		Format(weapon, sizeof(weapon), "huntsman");
		Format(console, sizeof(console), "Frostbolt");

		return Plugin_Changed;
	}
	else if (b_AuroraIcon)
	{
		Format(weapon, sizeof(weapon), "merasmus_decap");
		Format(console, sizeof(console), "Aurora Beam");

		return Plugin_Changed;
	}

	return Plugin_Continue;
}

public Action CF_OnAbilityCheckCanUse(int client, char plugin[255], char ability[255], CF_AbilityType type, bool &result)
{
	if (!StrEqual(plugin, KHOLDROZ))
		return Plugin_Continue;

	if (StrContains(ability, BEAM) != -1 && g_BoltChargeTimer[client] != null)
	{
		result = false;
		return Plugin_Changed;
	}

	return Plugin_Continue;
}