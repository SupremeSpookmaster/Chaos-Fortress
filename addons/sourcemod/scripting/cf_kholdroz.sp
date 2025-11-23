#include <cf_include>
#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>
#include <fakeparticles>

#define KHOLDROZ		"cf_kholdroz"
#define BEAM			"kholdroz_aurora_beam"

#define SPR_SNOW_TRAIL			"materials/effects/softglow.vmt"
#define SPR_SNOWFLAKE			"materials/chaos_fortress/sprites/snowflake.vmt"//"materials/effects/softglow.vmt"
#define SPR_GLOW				"materials/sprites/glow02.vmt"
#define SPR_AURORABEAM			"materials/chaos_fortress/sprites/aurora_beam.vmt"

#define MODEL_DRG				"models/weapons/w_models/w_drg_ball.mdl"
#define MODEL_AB_PARTICLEBODY	"models/props_c17/canister01a.mdl"

#define PARTICLE_SNOW_AURA_RED		"utaunt_glitter_teamcolor_red"
#define PARTICLE_SNOW_AURA_BLUE		"utaunt_glitter_parent_silver"

public void OnMapStart()
{
	PrecacheModel("materials/sprites/laserbeam.vmt");
	PrecacheModel(SPR_SNOW_TRAIL);
	PrecacheModel(SPR_SNOWFLAKE);
	PrecacheModel(SPR_GLOW);
	PrecacheModel(SPR_AURORABEAM);

	PrecacheModel(MODEL_DRG);
	PrecacheModel(MODEL_AB_PARTICLEBODY);

	PrecacheParticleEffect(PARTICLE_SNOW_AURA_RED);
	PrecacheParticleEffect(PARTICLE_SNOW_AURA_BLUE);
}

public void OnPluginStart()
{
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

	CF_FireGenericLaser(client, startPos, ang, f_ABWidth[client], f_ABRange[client], f_ABDamage[client], DMG_ENERGYBEAM, AB_GetWeapon(client), client, KHOLDROZ, _, AB_OnHit, AB_DrawLaser);
	CF_SetTimeUntilResourceRegen(client, CF_GetTimeUntilResourceRegen(client) + f_ABDrainInterval[client] + 0.5);
	SetEntPropFloat(AB_GetWeapon(client), Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + 999.0);

	b_ABActive[client] = true;
}

public void AB_OnHit(int victim, int attacker)
{
	//TODO: CRYO BUILDUP
}

public void AB_DrawLaser(int client, float startPos[3], float endPos[3], float ang[3], float width)
{	
	int start = AB_GetStartEnt(client);
	int end = AB_GetEndEnt(client);
	int can = AB_GetCanister(client);
	int beam = AB_GetBeamEnt(client);

	if (!IsValidEntity(beam) || !IsValidEntity(start) || !IsValidEntity(end) || !IsValidEntity(can))
	{
		AB_CreateLaser(client, startPos, endPos);
		return;
	}

	startPos[2] -= 17.5 * CF_GetCharacterScale(client);
	endPos[2] -= 17.5 * CF_GetCharacterScale(client);
	
	GetPointInDirection(startPos, ang, 20.0, startPos);
	GetPointInDirection(endPos, ang, 20.0, endPos);

	TeleportEntitySmoothly(start, startPos);
	TeleportEntitySmoothly(end, endPos);

	float canPos[3], canAng[3];
	GetPointInDirection(startPos, ang, 80.0, canPos);

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

public void AB_CreateLaser(int client, float startPos[3], float endPos[3])
{
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

	float ang[3];
	GetAngleBetweenPoints(startPos, endPos, ang);
	ang[0] -= 90.0;

	int canister = SpawnPropDynamic(MODEL_AB_PARTICLEBODY, startPos, ang, _, f_ABRange[client] / 59.121);	//59.121 is the height of the canister in HU.
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
		CF_FireGenericLaser(client, startPos, ang, f_ABWidth[client], f_ABRange[client], f_ABDamage[client], DMG_ENERGYBEAM|DMG_PREVENT_PHYSICS_FORCE, AB_GetWeapon(client), client, KHOLDROZ, _, AB_OnHit, AB_DrawLaser);
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
	}
	
	b_ABActive[client] = false;
	//TODO sounds
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

public void CF_OnCharacterCreated(int client)
{
	AB_Terminate(client);
}

public void CF_OnCharacterRemoved(int client)
{
	AB_Terminate(client);
}

public void CF_OnAbility(int client, char pluginName[255], char abilityName[255])
{
	if (!StrEqual(pluginName, KHOLDROZ))
		return;
	
	if (StrContains(abilityName, BEAM) != -1)
		AB_Fire(client, abilityName);
}

public void CF_OnHeldEnd_Ability(int client, bool resupply, char pluginName[255], char abilityName[255])
{
	if (!StrEqual(pluginName, KHOLDROZ))
		return;

	if (StrContains(abilityName, BEAM) != -1)
	{
		AB_Terminate(client);
	}
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