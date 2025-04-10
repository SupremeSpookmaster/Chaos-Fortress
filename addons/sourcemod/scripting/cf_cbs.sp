#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>

#define CBS				"cf_cbs"
#define DRAW			"cbs_special_draw"
#define BLAST			"cbs_explosive_arrow"
#define VOLLEY			"cbs_thousand_volley"
#define MELEE			"cbs_random_melee"

#define SOUND_ARROW_DRAW		")weapons/bow_shoot_pull.wav"
#define SOUND_ARROW_SHOOT		")weapons/bow_shoot.wav"
#define SOUND_EXPLOSIVE_LOOP	")misc/halloween/hwn_bomb_fuse.wav"
#define SOUND_ARROW_WHOOSH		")weapons/fx/nearmiss/arrow_nearmiss.wav"
#define PARTICLE_VOLLEY_BEGIN_RED	"drg_cow_explosioncore_charged"
#define PARTICLE_VOLLEY_BEGIN_BLUE	"drg_cow_explosioncore_charged_blue"
#define PARTICLE_VOLLEY_ACTIVE_RED	"dxhr_lightningball_parent_red"
#define PARTICLE_VOLLEY_ACTIVE_BLUE	"dxhr_lightningball_parent_blue"
#define PARTICLE_VOLLEY_FIRE_RED	"raygun_projectile_red"
#define PARTICLE_VOLLEY_FIRE_BLUE	"raygun_projectile_blue"

#define PARTICLE_EXPLOSIVE_RED	"superrare_burning1"
#define PARTICLE_EXPLOSIVE_BLUE	"superrare_burning2"
#define PARTICLE_VOLLEY_RED		"raygun_projectile_red_crit"
#define PARTICLE_VOLLEY_BLUE	"raygun_projectile_blue_crit"

int i_SniperMelees[] = { 3, 171, 232, 264, 401, 939, 1013, 1123, 30758 };

public void OnMapStart()
{
	PrecacheSound(SOUND_ARROW_DRAW);
	PrecacheSound(SOUND_ARROW_SHOOT);
	PrecacheSound(SOUND_EXPLOSIVE_LOOP);
	PrecacheSound(SOUND_ARROW_WHOOSH);
}

Handle g_hCTFCreateArrow;

public void OnPluginStart()
{
	GameData gamedata = LoadGameConfigFile("chaos_fortress");
	
	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "CTFProjectile_Arrow::Create");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
	PrepSDKCall_AddParameter(SDKType_QAngle, SDKPass_ByRef);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Pointer);
	g_hCTFCreateArrow = EndPrepSDKCall();
	
	if(!g_hCTFCreateArrow)
		LogError("[Gamedata] Could not find CTFProjectile_Arrow::Create");
		
	delete gamedata;
}

public void CF_OnAbility(int client, char pluginName[255], char abilityName[255])
{
	if (!StrEqual(pluginName, CBS))
		return;
	
	if (StrContains(abilityName, DRAW) != -1)
		Draw_Activate(client, abilityName);
		
	if (StrContains(abilityName, BLAST) != -1)
		Explosive_Activate(client, abilityName);
		
	if (StrContains(abilityName, VOLLEY) != -1)
		Volley_Activate(client, abilityName);
}

bool b_BlastBolt = false;

bool b_IsVolleyArrow[2049] = { false, ... };
bool b_IsHeavyDraw[2049] = { false, ... };
bool b_DrawActive[MAXPLAYERS + 1] = { false, ... };

float f_DrawChargeStartTime[MAXPLAYERS + 1] = { 0.0, ... };
float f_NextShootTime[MAXPLAYERS + 1] = { 0.0, ... };

char s_DrawAtts[MAXPLAYERS + 1][255];
char s_DrawAbility[MAXPLAYERS + 1][255];
char s_DrawPlugin[MAXPLAYERS + 1][255];
char s_DrawEndSound[MAXPLAYERS + 1][255];

public void Draw_Activate(int client, char abilityName[255])
{
	if (!Draw_IsHoldingHuntsman(client))
		return;
		
	int huntsman = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	
	if (!b_DrawActive[client])
		GetAttribStringFromWeapon(huntsman, s_DrawAtts[client]);
		
	TF2Attrib_RemoveAll(huntsman);
	
	char attribs[255], start_sound[255];
	CF_GetArgS(client, CBS, abilityName, "attributes", attribs, sizeof(attribs));
	CF_GetArgS(client, CBS, abilityName, "post_ability", s_DrawAbility[client], 255);
	CF_GetArgS(client, CBS, abilityName, "post_plugin", s_DrawPlugin[client], 255);
	CF_GetArgS(client, CBS, abilityName, "end_sound", s_DrawEndSound[client], 255);
	CF_GetArgS(client, CBS, abilityName, "start_sound", start_sound, sizeof(start_sound));
	
	CF_PlayRandomSound(client, "", start_sound);
	
	SetWeaponAttribsFromString(huntsman, attribs);
	
	RequestFrame(Draw_ForceDraw, GetClientUserId(client));
	b_DrawActive[client] = true;
	f_DrawChargeStartTime[client] = 0.0;
	EmitSoundToClient(client, SOUND_ARROW_DRAW);
	
	TF2_AddCondition(client, TFCond_FocusBuff);
}

public void Draw_ForceDraw(int id)
{
	int client = GetClientOfUserId(id);
	if (!IsValidMulti(client))
		return;
		
	SetForceButtonState(client, true, IN_ATTACK);
}

public void CF_OnHeldEnd_Ability(int client, bool resupply, char pluginName[255], char abilityName[255])
{
	if (!StrEqual(pluginName, CBS))
		return;
		
	if (StrContains(abilityName, DRAW) != -1)
	{
		SetForceButtonState(client, false, IN_ATTACK);
		TF2_RemoveCondition(client, TFCond_FocusBuff);
		
		if (!resupply)
		{
			CreateTimer(0.2, Draw_RevertAtts, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
			EmitSoundToClient(client, SOUND_ARROW_SHOOT);
			CF_PlayRandomSound(client, "", s_DrawEndSound[client]);
		}
	}
}

public void Draw_PostAbility(int id)
{
	int client = GetClientOfUserId(id);
	if (IsValidMulti(client) && !StrEqual(s_DrawAbility[client], "") && !StrEqual(s_DrawPlugin[client], ""))
	{
		CF_DoAbility(client, s_DrawPlugin[client], s_DrawAbility[client]);
	}
}

public Action Draw_RevertAtts(Handle revert, int id)
{
	int client = GetClientOfUserId(id);
	if (!IsValidMulti(client))
		return Plugin_Continue;
	
	b_DrawActive[client] = false;

	int huntsman = GetPlayerWeaponSlot(client, 0);
	if (IsValidEntity(huntsman))
	{
		char classname[255];
		GetEntityClassname(huntsman, classname, sizeof(classname));
	
		if (StrEqual(classname, "tf_weapon_compound_bow"))
		{
			TF2Attrib_RemoveAll(huntsman);
			SetWeaponAttribsFromString(huntsman, s_DrawAtts[client]);
		}
	}
	
	return Plugin_Continue;
}

public bool Draw_IsHoldingHuntsman(int client)
{
	if (!IsValidMulti(client) || !CF_IsPlayerCharacter(client))
		return false;

	int acWep = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if (!IsValidEntity(acWep))
		return false;
		
	return Draw_IsAHuntsman(acWep);
}

public bool Draw_IsAHuntsman(int entity)
{
	if (!IsValidEntity(entity))
		return false;
		
	char classname[255];
	GetEntityClassname(entity, classname, sizeof(classname));
	
	return StrEqual(classname, "tf_weapon_compound_bow");
}

public void Draw_OnArrowFired(int entity)
{
	RequestFrame(Draw_DelayedArrowModification, EntIndexToEntRef(entity));
}

public void Draw_DelayedArrowModification(int ref)
{
	int entity = EntRefToEntIndex(ref);
	if (!IsValidEntity(entity))
		return;
	
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if (!IsValidClient(owner) || !b_DrawActive[owner] || b_IsVolleyArrow[entity])
		return;
		
	int huntsman = GetPlayerWeaponSlot(owner, 0);
	if (!Draw_IsAHuntsman(huntsman))
		return;
		
	float velAtt1 = GetAttributeValue(huntsman, 103, 1.0);
	float velAtt2 = GetAttributeValue(huntsman, 104, 1.0);
	float velAtt3 = GetAttributeValue(huntsman, 475, 1.0);
	float pos[3], ang[3], buffer[3], vel[3];
	
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	GetClientEyeAngles(owner, ang);
	GetAngleVectors(ang, buffer, NULL_VECTOR, NULL_VECTOR);
	
	float duration_charged = GetGameTime() - f_DrawChargeStartTime[owner];
	float requiredChargeTime = GetAttributeValue(huntsman, 318, 1.0);
	if (duration_charged > requiredChargeTime)
		duration_charged = requiredChargeTime;
	
	float finalVel = 1875.0 * (1.0 + ((duration_charged / requiredChargeTime) * 0.25)) * velAtt1 * velAtt2 * velAtt3;
	for (int i = 0; i < 3; i++)
	{
		vel[i] = finalVel * buffer[i];
	}
	
	float damage = 50.0 + (70.0 * (duration_charged / requiredChargeTime));
	damage *= GetAttributeValue(huntsman, 2, 1.0);
	if (duration_charged / requiredChargeTime >= 1.0)
		damage *= GetAttributeValue(huntsman, 304, 1.0);
	
	DataPack pack = new DataPack();
	WritePackCell(pack, EntIndexToEntRef(entity));
	WritePackFloatArray(pack, vel, sizeof(vel));
	WritePackFloatArray(pack, ang, sizeof(ang));
	WritePackFloatArray(pack, pos, sizeof(pos));
	WritePackFloat(pack, damage);
	WritePackCell(pack, GetClientUserId(owner));
	RequestFrame(Draw_ApplyVelocity, pack);

	b_IsHeavyDraw[entity] = true;
}

public void Draw_ApplyVelocity(DataPack pack)
{
	ResetPack(pack);
	int entity = EntRefToEntIndex(ReadPackCell(pack));
	float vel[3], ang[3], pos[3];
	ReadPackFloatArray(pack, vel, sizeof(vel));
	ReadPackFloatArray(pack, ang, sizeof(ang));
	ReadPackFloatArray(pack, pos, sizeof(pos));
	float damage = ReadPackFloat(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	
	delete pack;
	
	if (IsValidEntity(entity))
	{
		TeleportEntity(entity, pos, ang, vel);
		SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, damage, true);
	}
	
	if (IsValidMulti(client))
		RequestFrame(Draw_PostAbility, GetClientUserId(client));
}

bool b_ExplosiveActive[MAXPLAYERS + 1] = { false, ... };

float f_ExplosiveBaseDMG[MAXPLAYERS + 1] = { 0.0, ... };
float f_ExplosiveBaseRadius[MAXPLAYERS + 1] = { 0.0, ... };
float f_ExplosiveBaseFalloffStart[MAXPLAYERS + 1] = { 0.0, ... };
float f_ExplosiveBaseFalloffMax[MAXPLAYERS + 1] = { 0.0, ... };
float f_ExplosiveDMG[2049] = { 0.0, ... };
float f_ExplosiveRadius[2049] = { 0.0, ... };
float f_ExplosiveFalloffStart[2049] = { 0.0, ... };
float f_ExplosiveFalloffMax[2049] = { 0.0, ... };

int i_ExplosiveParticle[MAXPLAYERS + 1] = { -1, ... };

public void Explosive_Activate(int client, char abilityName[255])
{
	if (!Draw_IsHoldingHuntsman(client))
		return;

	f_ExplosiveBaseDMG[client] = CF_GetArgF(client, CBS, abilityName, "damage");
	f_ExplosiveBaseRadius[client] = CF_GetArgF(client, CBS, abilityName, "radius");
	f_ExplosiveBaseFalloffStart[client] = CF_GetArgF(client, CBS, abilityName, "falloff_start");
	f_ExplosiveBaseFalloffMax[client] = CF_GetArgF(client, CBS, abilityName, "falloff_max");

	Explosive_DeleteParticle(client);
	i_ExplosiveParticle[client] = EntIndexToEntRef(CF_AttachParticle(client, TF2_GetClientTeam(client) == TFTeam_Red? PARTICLE_EXPLOSIVE_RED : PARTICLE_EXPLOSIVE_BLUE, "effect_hand_R"));
	
	b_ExplosiveActive[client] = true;
	SDKUnhook(client, SDKHook_PreThink, Explosive_CheckHuntsman);
	SDKHook(client, SDKHook_PreThink, Explosive_CheckHuntsman);
	EmitSoundToClient(client, SOUND_EXPLOSIVE_LOOP);
}

public Action Explosive_CheckHuntsman(int client)
{
	if (!Draw_IsHoldingHuntsman(client) || !b_ExplosiveActive[client])
	{
		b_ExplosiveActive[client] = false;
		Explosive_DeleteParticle(client);
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

public void Explosive_DeleteParticle(int client)
{
	int particle = EntRefToEntIndex(i_ExplosiveParticle[client]);
	if (IsValidEntity(particle))
		RemoveEntity(particle);
		
	i_ExplosiveParticle[client] = -1;
	StopSound(client, SNDCHAN_AUTO, SOUND_EXPLOSIVE_LOOP);
	SDKUnhook(client, SDKHook_PreThink, Explosive_CheckHuntsman);
}

public void Explosive_OnArrowFired(int entity)
{
	RequestFrame(Explosive_DelayedArrowModification, EntIndexToEntRef(entity));
}

int i_BlastTrail[2049] = { -1, ... };

public void Explosive_DelayedArrowModification(int ref)
{
	int entity = EntRefToEntIndex(ref);
	if (!IsValidEntity(entity))
		return;
	
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if (!IsValidClient(owner) || !b_ExplosiveActive[owner] || b_IsVolleyArrow[entity])
		return;
		
	int huntsman = GetPlayerWeaponSlot(owner, 0);
	if (!Draw_IsAHuntsman(huntsman))
		return;
	
	float dmgMult = GetAttributeValue(huntsman, 2, 1.0);
	float radMult = GetAttributeValue(huntsman, 99, 1.0);
	float falloffMult = GetAttributeValue(huntsman, 118, 1.0);
	
	f_ExplosiveDMG[entity] = f_ExplosiveBaseDMG[owner] * dmgMult;
	f_ExplosiveRadius[entity] = f_ExplosiveBaseRadius[owner] * radMult;
	f_ExplosiveFalloffStart[entity] = f_ExplosiveBaseFalloffStart[owner] * radMult;
	f_ExplosiveFalloffMax[entity] = f_ExplosiveBaseFalloffMax[owner] * falloffMult;

	i_BlastTrail[entity] = EntIndexToEntRef(AttachParticleToEntity(entity, TF2_GetClientTeam(owner) == TFTeam_Red? PARTICLE_EXPLOSIVE_RED : PARTICLE_EXPLOSIVE_BLUE, "muzzle"));	
	SDKHook(entity, SDKHook_StartTouchPost, Explosive_OnTouch);
	b_ExplosiveActive[owner] = false;
	Explosive_DeleteParticle(owner);	
}

public void CF_OnGenericProjectileTeamChanged(int entity, TFTeam newTeam)
{
	int oldParticle = EntRefToEntIndex(i_BlastTrail[entity]);
	if (!IsValidEntity(oldParticle))
		return;

	RemoveEntity(oldParticle);
	i_BlastTrail[entity] = EntIndexToEntRef(AttachParticleToEntity(entity, newTeam == TFTeam_Red ? PARTICLE_EXPLOSIVE_RED : PARTICLE_EXPLOSIVE_BLUE, "muzzle"));
}

public Action Explosive_OnTouch(int entity, int other)
{
	SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	
	float pos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	
	b_BlastBolt = true;
	CF_GenericAOEDamage(owner, entity, entity, f_ExplosiveDMG[entity], DMG_BLAST | DMG_CLUB | DMG_ALWAYSGIB, f_ExplosiveRadius[entity], pos, f_ExplosiveFalloffStart[entity], f_ExplosiveFalloffMax[entity]);
	b_BlastBolt = false;
	
	SpawnSpriteExplosion(pos, 1);
	RemoveEntity(entity);
	
	return Plugin_Continue;
}

bool b_VolleyActive[MAXPLAYERS + 1] = { false, ... };
bool b_VolleyTargeting[MAXPLAYERS + 1] = { false, ... };
bool b_ArrowWillTriggerVolley[2049] = { false, ... };

float f_VolleyDelay[MAXPLAYERS + 1] = { 0.0, ... };
float f_VolleyInterval[MAXPLAYERS + 1] = { 0.0, ... };
float f_VolleyDuration[MAXPLAYERS + 1] = { 0.0, ... };
float f_VolleySpread[MAXPLAYERS + 1] = { 0.0, ... };
float f_VolleyVelocity[MAXPLAYERS + 1] = { 0.0, ... };
float f_VolleyDamage[MAXPLAYERS + 1] = { 0.0, ... };

int i_VolleyCount[MAXPLAYERS + 1] = { 0, ... };
int i_VolleyOwner[2049] = { -1, ... };

int ActiveVolleys = 0;

public void Volley_Activate(int client, char abilityName[255])
{
	if (!Draw_IsHoldingHuntsman(client))
		return;
		
	f_VolleyDelay[client] = CF_GetArgF(client, CBS, abilityName, "delay");
	f_VolleyInterval[client] = CF_GetArgF(client, CBS, abilityName, "interval");
	f_VolleyDuration[client] = CF_GetArgF(client, CBS, abilityName, "duration");
	i_VolleyCount[client] = CF_GetArgI(client, CBS, abilityName, "count");
	f_VolleySpread[client] = CF_GetArgF(client, CBS, abilityName, "spread");
	f_VolleyVelocity[client] = CF_GetArgF(client, CBS, abilityName, "velocity");
	f_VolleyDamage[client] = CF_GetArgF(client, CBS, abilityName, "damage");
	b_VolleyTargeting[client] = CF_GetArgF(client, CBS, abilityName, "target") > 0;
	
	b_VolleyActive[client] = true;
	TF2_AddCondition(client, TFCond_CritHype);
	SDKHook(client, SDKHook_PreThink, Volley_CheckHuntsman);
}

//Because the user can hold the arrow for as long as they want, don't let them gain ult charge until the arrow has been fired:
public Action CF_OnUltChargeGiven(int client, float &amt)
{
	if (b_VolleyActive[client] && amt > 0.0)
	{
		amt = 0.0;
		return Plugin_Changed;
	}
	
	return Plugin_Continue;
}

public Action Volley_CheckHuntsman(int client)
{
	if (!b_VolleyActive[client])
	{
		TF2_RemoveCondition(client, TFCond_CritHype);
		return Plugin_Stop;
	}
	else
	{
		bool glow = TF2_IsPlayerInCondition(client, TFCond_CritHype);
		bool holding = Draw_IsHoldingHuntsman(client);
		
		if (holding && !glow)
			TF2_AddCondition(client, TFCond_CritHype);
		else if (!holding && glow)
			TF2_RemoveCondition(client, TFCond_CritHype);
	}
	
	return Plugin_Continue;
}

public void Volley_OnArrowFired(int entity)
{
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	
	//If a client has already activated Thousand Volley, don't allow their volley to trigger if another one is already active.
	if (!IsValidClient(owner) || !b_VolleyActive[owner] || ActiveVolleys > 0)
		return;
		
	CreateTimer(f_VolleyDelay[owner], Timer_RemoveEntity, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
	
	SDKHook(entity, SDKHook_StartTouchPost, Volley_OnTouch);
	
	AttachParticleToEntity(entity, TF2_GetClientTeam(owner) == TFTeam_Red ? PARTICLE_VOLLEY_RED : PARTICLE_VOLLEY_BLUE, "muzzle");
	
	b_VolleyActive[owner] = false;
	b_ArrowWillTriggerVolley[entity] = true;
	i_VolleyOwner[entity] = GetClientUserId(owner);
	ActiveVolleys++;
}

public Action Volley_OnTouch(int entity, int other)
{
	SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);
	RemoveEntity(entity);
	
	return Plugin_Continue;
}

public void Volley_Begin(int entity)
{
	int owner = GetClientOfUserId(i_VolleyOwner[entity]);
	if (!IsValidClient(owner))
		return;
		
	float pos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	
	DataPack pack = new DataPack();
	WritePackCell(pack, GetClientUserId(owner));
	WritePackFloatArray(pack, pos, sizeof(pos));
	WritePackFloat(pack, GetGameTime() + f_VolleyDuration[owner]);
	WritePackFloat(pack, 0.0);
	RequestFrame(Volley_ShootArrows, pack);
	
	TFTeam team = TF2_GetClientTeam(owner);
	SpawnParticle(pos, team == TFTeam_Red ? PARTICLE_VOLLEY_BEGIN_RED : PARTICLE_VOLLEY_BEGIN_BLUE, 2.0);
	SpawnParticle(pos, team == TFTeam_Red ? PARTICLE_VOLLEY_ACTIVE_RED : PARTICLE_VOLLEY_ACTIVE_BLUE, f_VolleyDuration[owner]);
}

public void Volley_ShootArrows(DataPack pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	float pos[3];
	ReadPackFloatArray(pack, pos, sizeof(pos));
	float endTime = ReadPackFloat(pack);
	float nextVolley = ReadPackFloat(pack);
	float gt = GetGameTime();
	
	delete pack;
	
	if (!IsValidClient(client))
	{
		ActiveVolleys--;
		return;
	}
	
	if (endTime < gt)
	{
		ActiveVolleys--;
		return;
	}
		
	if (gt >= nextVolley)
	{
		if (b_VolleyTargeting[client])
		{
			//TODO: Turn this into a CF native, should be able to target allies or enemies, should have a radius parameter, should have filter parameters
			ArrayList enemies = new ArrayList(255);

			for (int i = 1; i < 2049 && GetArraySize(enemies) < i_VolleyCount[client]; i++)
			{
				if (!CF_IsValidTarget(i, grabEnemyTeam(client))/* || (IsValidClient(i) && !IsPlayerAlive(i))*/)
					continue;

				float vicPos[3];
				CF_WorldSpaceCenter(i, vicPos);

				TR_TraceRayFilter(pos, vicPos, MASK_SHOT, RayType_EndPoint, CF_LOSTrace, i);
				if (!TR_DidHit())
					PushArrayCell(enemies, i);
			}

			if (GetArraySize(enemies) < 1)
			{
				delete enemies;
			}
			else
			{
				ArrayList victims = SortListByDistance(pos, enemies);
				delete enemies;

				for (int i = 0; i < GetArraySize(victims); i++)
				{
					int vic = GetArrayCell(victims, i);
					float vicPos[3], ang[3];
					CF_WorldSpaceCenter(vic, vicPos);

					MakeVectorFromPoints(pos, vicPos, ang);
					GetVectorAngles(ang, ang);

					int arrow = Volley_MakeArrow(client, pos, ang, f_VolleyVelocity[client], 0.1, 8, client, client);
					if (IsValidEntity(arrow))
					{
						EmitSoundToAll(SOUND_ARROW_WHOOSH, arrow, _, 80, _, _, GetRandomInt(80, 120));
						b_IsVolleyArrow[arrow] = true;
					}
				}

				delete victims;
			}
		}
		else
		{
			float baseAng[3], offsetAng[3];
			baseAng[0] = 90.0;
			baseAng[1] = 0.0;
			baseAng[2] = 0.0;

			for (int i = 0; i < i_VolleyCount[client]; i++)
			{
				for (int vec = 0; vec < 3; vec++)
				{
					offsetAng[vec] = baseAng[vec] + GetRandomFloat(-f_VolleySpread[client], f_VolleySpread[client]);
				}
					
				int arrow = Volley_MakeArrow(client, pos, offsetAng, f_VolleyVelocity[client], 0.1, 8, client, client);
				if (IsValidEntity(arrow))
				{
					EmitSoundToAll(SOUND_ARROW_WHOOSH, arrow, _, 80, _, _, GetRandomInt(80, 120));
					b_IsVolleyArrow[arrow] = true;
				}
			}
		}
		
		nextVolley = gt + f_VolleyInterval[client];
	}
	
	DataPack pack2 = new DataPack();
	WritePackCell(pack2, GetClientUserId(client));
	WritePackFloatArray(pack2, pos, sizeof(pos));
	WritePackFloat(pack2, endTime);
	WritePackFloat(pack2, nextVolley);
	RequestFrame(Volley_ShootArrows, pack2);
}

public int Volley_MakeArrow(int client, float VecOrigin[3], float VecAngles[3], const float fSpeed, const float fGravity, int projectileType, int Owner, int Scorer)
{
	if(g_hCTFCreateArrow)
	{
		int arrow = SDKCall(g_hCTFCreateArrow, VecOrigin, VecAngles, fSpeed, fGravity, projectileType, Owner, Scorer);
		int weapon = GetPlayerWeaponSlot(client, 0);
		
		if (IsValidEntity(arrow) && IsValidEntity(weapon))
		{
			SetEntDataFloat(arrow, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, f_VolleyDamage[client], true);	// Damage
			SetEntPropEnt(arrow, Prop_Send, "m_hOriginalLauncher", weapon);
			SetEntPropEnt(arrow, Prop_Send, "m_hLauncher", weapon);
			SetEntProp(arrow, Prop_Send, "m_bCritical", false);
		}
		
		return arrow;
	}
	
	return -1;
}

public Action CF_OnAbilityCheckCanUse(int client, char plugin[255], char ability[255], CF_AbilityType type, bool &result)
{
	if (!StrEqual(plugin, CBS))
		return Plugin_Continue;
		
	if (StrContains(ability, DRAW) != -1)
	{
		bool holding = Draw_IsHoldingHuntsman(client);
		
		//Test 1: Is the client is holding the huntsman and able to shoot it?
		result = holding && GetGameTime() >= f_NextShootTime[client];
		
		//Test 2: The client is holding the huntsman and is able to shoot it, make sure they aren't already charging it via a normal shot.
		if (result)
			result = holding && (b_DrawActive[client] || GetClientButtons(client) & IN_ATTACK == 0);
			
		return Plugin_Changed;
	}
	
	//Don't allow Thousand Volley to be activated if one is already active.
	if (StrContains(ability, VOLLEY) != -1)
	{
		result = ActiveVolleys < 1;
		return Plugin_Changed;
	}

	return Plugin_Continue;
}

public Action TF2_CalcIsAttackCritical(int client, int weapon, char[]weaponname, bool &result)
{
	if (!StrEqual(weaponname, "tf_weapon_compound_bow"))
		return Plugin_Continue;
		
	f_DrawChargeStartTime[client] = GetEntPropFloat(weapon, Prop_Send, "m_flChargeBeginTime");
	f_NextShootTime[client] = GetGameTime() + (GetAttributeValue(weapon, 318, 1.0) * 2.0);
	
	return Plugin_Continue;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (StrEqual(classname, "tf_projectile_arrow"))
	{
		SDKHook(entity, SDKHook_SpawnPost, Draw_OnArrowFired);
		SDKHook(entity, SDKHook_SpawnPost, Explosive_OnArrowFired);
		SDKHook(entity, SDKHook_SpawnPost, Volley_OnArrowFired);
	}
}

public Action CF_OnTakeDamageAlive_Post(int victim, int attacker, int inflictor, float damage, int weapon)
{
	if (!IsValidMulti(attacker))
		return Plugin_Continue;
		
	if (CF_HasAbility(attacker, CBS, MELEE) && weapon == GetPlayerWeaponSlot(attacker, 2))
	{
		char atts[255];
		CF_GetArgS(attacker, CBS, MELEE, "attributes", atts, sizeof(atts));
		
		TF2_RemoveWeaponSlot(attacker, 2);
		CF_SpawnWeapon(attacker, "tf_weapon_club", i_SniperMelees[GetRandomInt(0, sizeof(i_SniperMelees) - 1)], 77, 7, 2, 0, 0, atts);
	}
	
	return Plugin_Continue;
}

public Action CF_OnShouldCollide(int ent1, int ent2, bool &result)
{
	if (b_IsVolleyArrow[ent1] && b_IsVolleyArrow[ent2])
	{
		result = false;
		return Plugin_Changed;
	}
	
	return Plugin_Continue;
}

public Action CF_OnPassFilter(int ent1, int ent2, bool &result)
{
	if (b_IsVolleyArrow[ent1] && b_IsVolleyArrow[ent2])
	{
		result = false;
		return Plugin_Changed;
	}
	
	return Plugin_Continue;
}

public Action CF_OnPlayerRunCmd(int client, int &buttons, int &impulse, int &weapon)
{
	if (b_DrawActive[client] && buttons & IN_ATTACK2 != 0)
	{
		buttons &= ~IN_ATTACK2;
		return Plugin_Changed;
	}
	
	return Plugin_Continue;
}

public void CF_OnCharacterCreated(int client)
{
}

public void CF_OnCharacterRemoved(int client, CF_CharacterRemovalReason reason)
{
	if (b_DrawActive[client])
	{
		SetForceButtonState(client, false, IN_ATTACK);
	}
	
	b_DrawActive[client] = false;
	b_ExplosiveActive[client] = false;
	b_VolleyActive[client] = false;
	
	Explosive_DeleteParticle(client);
}

public void OnEntityDestroyed(int entity)
{
	if (entity > 0 && entity < 2049)
	{
		if (b_ArrowWillTriggerVolley[entity])
		{
			Volley_Begin(entity);
		}
		
		b_ArrowWillTriggerVolley[entity] = false;
		b_IsVolleyArrow[entity] = false;
		i_VolleyOwner[entity] = -1;
		b_IsHeavyDraw[entity] = false;
	}
}

public Action CF_OnPlayerKilled_Pre(int &victim, int &inflictor, int &attacker, char weapon[255], char console[255], int &custom, int deadRinger, int &critType, int &damagebits)
{
	Action ReturnValue = Plugin_Continue;

	if (IsValidEntity(inflictor) && b_IsHeavyDraw[inflictor])
	{
		critType = 2;
		ReturnValue = Plugin_Changed;
		strcopy(console, sizeof(console), "Heavy Draw");
		strcopy(weapon, sizeof(weapon), "huntsman_flyingburn");
	}

	if (b_BlastBolt)
	{
		if (!b_IsHeavyDraw[inflictor])
			strcopy(console, sizeof(console), "Blast Bolt");
		else
			strcopy(console, sizeof(console), "Heavy Blast Bolt");

		strcopy(weapon, sizeof(weapon), "firedeath");

		ReturnValue = Plugin_Changed;
	}

	return ReturnValue;
}