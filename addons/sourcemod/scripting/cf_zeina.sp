/*
	Zeina, original character in the irln world, expidonsan.
*/

#include <sourcemod>
#include <tf2_stocks>
#include <sdkhooks>
#include <cf_include>
#include <dhooks>
#include <tf2utils>
#include <tf2items>
#include <tf2attributes>

#define LASERBEAM	"sprites/laserbeam.vmt"

#define MAXENTITIES	2048

#define SENSAL_LASER_THICKNESS	10
#define PARTICLE_ROCKET_MODEL	"models/weapons/w_models/w_drg_ball.mdl"

#define ABILITY_SLASH			"zeina_slash_melee"
#define ABILITY_DASH			"zeina_dash"
#define ABILITY_BEACON			"zaina_beacon"
#define ABILITY_SILVESTER_WINGS			"zaina_wings_fly"
#define ABILITY_WINGS_PICKUP			"zaina_pickup_player"

static const char SyctheHitSound[][] =
{
	"ambient/machines/slicer1.wav",
	"ambient/machines/slicer2.wav",
	"ambient/machines/slicer3.wav",
	"ambient/machines/slicer4.wav",
};

static const char TeleportSound[][] =
{
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav",
};

enum
{
	Kill_Sycthe,
	Kill_Laser
}

char PluginName[255];
int g_Ruina_BEAM_Combine_Black;
int g_Ruina_BEAM_Combine_Blue;

#define MAX_EXPI_ENERGY_EFFECTS 5

int ZeinaSlashWeapon[MAXPLAYERS+1] = {-1, ...};
int i_ExpidonsaEnergyEffect[MAXENTITIES][MAX_EXPI_ENERGY_EFFECTS];
float ZeinaMaxDurationSlash[MAXPLAYERS+1] = {-1.0, ...};
float ZeinaMaxDurationSlash_Warmup[MAXPLAYERS+1] = {-1.0, ...};
int i_OwnerEntityEnvLaser[MAXENTITIES];
int ShieldAttachedToBeacon[MAXENTITIES] = {0, ...};
int ShieldEntRef[MAXPLAYERS+1] = {-1, ...};
float SvAirAccelerate_Replicate[MAXPLAYERS+1] = {-1.0, ...};
float SvAccelerate_Replicate[MAXPLAYERS+1] = {-1.0, ...};
float SvAirAccelerate_Client[MAXPLAYERS+1] = {10.0, ...};
float SvAccelerate_Client[MAXPLAYERS+1] = {10.0, ...};
ConVar CvarAirAcclerate; //sv_airaccelerate
ConVar CvarAcclerate; //sv_accelerate
bool AllyOnlyPickUpOne[MAXPLAYERS +1];
float ZeinaFlightDuration[MAXENTITIES];
float ZeinaFlightDurationExtend[MAXENTITIES];
bool FlightModeWas[MAXENTITIES];

int LaserToConnectPickup[MAXPLAYERS +1] = {-1, ...};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	GetPluginFilename(null, PluginName, sizeof(PluginName));
	
	int pos = FindCharInString(PluginName, '/', true);
	if(pos != -1)
		strcopy(PluginName, sizeof(PluginName), PluginName[pos + 1]);
	
	pos = FindCharInString(PluginName, '\\', true);
	if(pos != -1)
		strcopy(PluginName, sizeof(PluginName), PluginName[pos + 1]);
	
	pos = FindCharInString(PluginName, '.', true);
	if(pos != -1)
		PluginName[pos] = '\0';
	
	return APLRes_Success;
}

public void OnPluginStart()
{

	CvarAirAcclerate = FindConVar("sv_airaccelerate");
	if(CvarAirAcclerate)
		CvarAirAcclerate.Flags &= ~(FCVAR_NOTIFY | FCVAR_REPLICATED);

	CvarAcclerate = FindConVar("sv_accelerate");
	if(CvarAcclerate)
		CvarAcclerate.Flags &= ~(FCVAR_NOTIFY | FCVAR_REPLICATED);
}

public void OnMapStart()
{
	PrecacheModel(LASERBEAM);


	PrecacheSound("misc/halloween/spell_teleport.wav");
	g_Ruina_BEAM_Combine_Black 	= PrecacheModel("materials/sprites/combineball_trail_black_1.vmt", true);
	g_Ruina_BEAM_Combine_Blue 	= PrecacheModel("materials/sprites/combineball_trail_blue_1.vmt", true);
	PrecacheModel("models/props_moonbase/moon_gravel_crystal_blue.mdl");
	PrecacheModel("models/props_moonbase/moon_gravel_crystal_red.mdl");
	PrecacheSound("ambient/explosions/explode_3.wav");

	PrecacheSound("weapons/rescue_ranger_charge_01.wav");
	PrecacheSound("weapons/rescue_ranger_charge_02.wav");

	for(int i; i < sizeof(SyctheHitSound); i++)
	{
		PrecacheSound(SyctheHitSound[i]);
	}

	for(int i; i < sizeof(TeleportSound); i++)
	{
		PrecacheSound(TeleportSound[i]);
	}
	for(int i; i< MAXPLAYERS +1; i++)
	{
		ZeinaMaxDurationSlash_Warmup[i] = 0.0;
		ZeinaMaxDurationSlash[i] = 0.0;
	}
	for (int i = 0; i <= MaxClients; i++)
	{
		SvAirAccelerate_Client[i] = CvarAirAcclerate.FloatValue;
		SvAccelerate_Client[i] = CvarAcclerate.FloatValue;
	}
	for(int i; i< MAXENTITIES; i++)
	{
		ExpidonsaRemoveEffects(i);
	}
}
stock void ExpidonsaRemoveEffects(int iNpc)
{
	for(int loop = 0; loop<MAX_EXPI_ENERGY_EFFECTS; loop++)
	{
		int entity = EntRefToEntIndex(i_ExpidonsaEnergyEffect[iNpc][loop]);
		if(IsValidEntity(entity) && entity != 0)
		{
			RemoveEntity(entity);
		}
		i_ExpidonsaEnergyEffect[iNpc][loop] = INVALID_ENT_REFERENCE;
	}
}
public void CF_OnAbility(int client, char pluginName[255], char abilityName[255])
{
	if(!StrEqual(pluginName, PluginName, false))
		return;
	
	if(StrContains(abilityName, ABILITY_SLASH) != -1)
	{
		ZeinaSlashActivate(client, abilityName);
	}
	else if(StrContains(abilityName, ABILITY_DASH) != -1)
	{
		ZeinaDashActivate(client, abilityName);
	}
	else if(StrContains(abilityName, ABILITY_BEACON) != -1)
	{
		ZeinaBeaconActivate(client, abilityName);
	}
	else if(StrContains(abilityName, ABILITY_SILVESTER_WINGS) != -1)
	{
		ZeinaWingsActivate(client, abilityName);
	}
	else if(StrContains(abilityName, ABILITY_WINGS_PICKUP) != -1)
	{
		ZeinaPickupAlly(client);
	}
}

public void CF_OnCharacterCreated(int client)
{
	ExpidonsaRemoveEffects(client);
	if(IsValidEntity(LaserToConnectPickup[client]))
		RemoveEntity(LaserToConnectPickup[client]);
	if(CF_HasAbility(client, PluginName, ABILITY_SILVESTER_WINGS))
	{
		if(!IsFakeClient(client))
		{
			SDKUnhook(client, SDKHook_PreThinkPost, ZeinalOnPreThinkPost);
			SDKHook(client, SDKHook_PreThinkPost, ZeinalOnPreThinkPost);

			SDKUnhook(client, SDKHook_PostThink, ZeinalOnPostThink);
			SDKHook(client, SDKHook_PostThink, ZeinalOnPostThink);
			
			SDKUnhook(client, SDKHook_PostThinkPost, ZeinalOnPostThinkPost);
			SDKHook(client, SDKHook_PostThinkPost, ZeinalOnPostThinkPost);
		}
	}
}
public void CF_OnCharacterRemoved(int client, CF_CharacterRemovalReason reason)
{
	ExpidonsaRemoveEffects(client);
	if(IsValidEntity(LaserToConnectPickup[client]))
		RemoveEntity(LaserToConnectPickup[client]);
	if(!IsFakeClient(client))
	{
		SDKUnhook(client, SDKHook_PreThinkPost, ZeinalOnPreThinkPost);
		SDKUnhook(client, SDKHook_PostThink, ZeinalOnPostThink);
		SDKUnhook(client, SDKHook_PostThinkPost, ZeinalOnPostThinkPost);
	}

	//0 is treated as default.
	SvAirAccelerate_Client[client] = SvAirAccelerate_Client[0];
	SvAccelerate_Client[client] = SvAccelerate_Client[0];
}

public void ZeinalOnPostThink(int client)
{
	if(SvAirAccelerate_Replicate[client] != SvAirAccelerate_Client[client])
	{
		char IntToStringDo[4];
		FloatToString(SvAirAccelerate_Client[client], IntToStringDo, sizeof(IntToStringDo));
		CvarAirAcclerate.ReplicateToClient(client, IntToStringDo); //set down
		SvAirAccelerate_Replicate[client] = SvAirAccelerate_Client[client];
	}
	if(SvAccelerate_Replicate[client] != SvAccelerate_Client[client])
	{
		char IntToStringDo[4];
		FloatToString(SvAccelerate_Client[client], IntToStringDo, sizeof(IntToStringDo));
		CvarAcclerate.ReplicateToClient(client, IntToStringDo); //set down
		SvAccelerate_Replicate[client] = SvAccelerate_Client[client];
	}
}
public void ZeinalOnPreThinkPost(int client)
{
	CvarAirAcclerate.FloatValue = SvAirAccelerate_Client[client];
	CvarAcclerate.FloatValue = SvAccelerate_Client[client];
}

public void ZeinalOnPostThinkPost(int client)
{
	CvarAirAcclerate.FloatValue = SvAirAccelerate_Client[0];
	CvarAcclerate.FloatValue = SvAccelerate_Client[0];
}

public Action TF2_CalcIsAttackCritical(int client, int weapon, char[] classname, bool &result)
{
	if(ZeinaSlashWeapon[client] == EntIndexToEntRef(weapon) && ZeinaMaxDurationSlash[client] > GetGameTime())
	{
		if(ZeinaMaxDurationSlash_Warmup[client] > GetGameTime()) //Prevent abuse by swining beforehand.
			return Plugin_Continue;

		//This is the correct weapon.
		ZeinaSlashWeapon[client] = -1;
		CF_PlayRandomSound(client, client, "sound_zeina_slash");
		TF2_RemoveCondition(client, TFCond_CritOnDamage);
		ZeinaInitiateSlash(client, ABILITY_SLASH);
		DataPack pack2 = new DataPack();
		CreateDataTimer(0.25, ZeinaSlashEndTimer, pack2, TIMER_FLAG_NO_MAPCHANGE);
		WritePackCell(pack2, EntIndexToEntRef(client));
		WritePackCell(pack2, EntIndexToEntRef(weapon));
	}
	return Plugin_Continue;
}

void ZeinaSlashActivate(int client, char abilityName[255])
{
	/*
		TODO:
		make their melee not hit anything, noly the custom trace should do something.
	*/
	int MeleeWeapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
	if(MeleeWeapon == -1)
		return;
	//how did it fail?
	float TimeDuration = CF_GetArgF(client, PluginName, abilityName, "duration_max");
	//The crit is only visual.
	//But just incase.
	TF2Attrib_SetByDefIndex(MeleeWeapon, 1, 0.0);

	float timeUntill = CF_GetArgF(client, PluginName, abilityName, "ready_up");
	SetEntPropFloat(MeleeWeapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + timeUntill + 0.25); 
	ZeinaSlashWeapon[client] = EntIndexToEntRef(MeleeWeapon);
	ZeinaMaxDurationSlash_Warmup[client] = GetGameTime() + 10.0; //Prevent abuse by swining beforehand.
	ZeinaMaxDurationSlash[client] = GetGameTime() + TimeDuration;

	DataPack pack = new DataPack();
	CreateDataTimer(timeUntill, ZeinaSlashGiveCrit, pack, TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack, EntIndexToEntRef(client));
	WritePackCell(pack, EntIndexToEntRef(MeleeWeapon));
	WritePackFloat(pack, TimeDuration);

	DataPack pack2 = new DataPack();
	CreateDataTimer(TimeDuration, ZeinaSlashEndTimer, pack2, TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack2, EntIndexToEntRef(client));
	WritePackCell(pack2, EntIndexToEntRef(MeleeWeapon));


	int model = GetEntProp(MeleeWeapon, Prop_Send, "m_iWorldModelIndex");
	int entity = -1;
	while((entity = FindEntityByClassname(entity, "tf_wearable*")) != -1)
	{
		if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == client
		&& GetEntProp(entity, Prop_Send, "m_nModelIndex") == model)
		{
			char classname[36];
			GetEntityClassname(entity, classname, sizeof(classname));
			if(!StrEqual(classname, "tf_wearable_vm", false))
				AddConnectingEffects_Zeina(client, entity, 0, false);
		//	else
		//		AddConnectingEffects_Zeina(client, entity, 0, true);
		}
	}
}

void ZeinaAbilityEndSlash(int client)
{
	ExpidonsaRemoveEffects(client);
}
public Action ZeinaSlashEndTimer(Handle timer, DataPack pack)
{
	ResetPack(pack);
	int client = EntRefToEntIndex(ReadPackCell(pack));
	if (!IsValidEntity(client))
		return Plugin_Stop;

	ZeinaSlashWeapon[client] = -1;
	ZeinaAbilityEndSlash(client);
	TF2_RemoveCondition(client, TFCond_CritOnDamage);
	int Weapon = EntRefToEntIndex(ReadPackCell(pack));
	if(IsValidEntity(Weapon))
		TF2Attrib_SetByDefIndex(Weapon, 1, 1.0);

	return Plugin_Stop;
}
public Action ZeinaSlashGiveCrit(Handle timer, DataPack pack)
{
	ResetPack(pack);
	int client = EntRefToEntIndex(ReadPackCell(pack));
	int Weapon = EntRefToEntIndex(ReadPackCell(pack));
	if (!IsValidEntity(client))
		return Plugin_Stop;

	if (!IsPlayerAlive(client))
		return Plugin_Stop;

	//somehow changed weapons, maybe tried to abuse, block.
	int weaponActive = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weaponActive != Weapon)
		return Plugin_Stop;

	int model = GetEntProp(weaponActive, Prop_Send, "m_iWorldModelIndex");
	int entity = -1;
	while((entity = FindEntityByClassname(entity, "tf_wearable*")) != -1)
	{
		if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == client
		&& GetEntProp(entity, Prop_Send, "m_nModelIndex") == model)
		{
			char classname[36];
			GetEntityClassname(entity, classname, sizeof(classname));
			if(!StrEqual(classname, "tf_wearable_vm", false))
				AddConnectingEffects_Zeina(client, entity, 1, false);
		//	else
		//		AddConnectingEffects_Zeina(client, entity, 1, true);
		}
	}

	ZeinaMaxDurationSlash_Warmup[client] = 0.0; //Prevent abuse by swining beforehand.
	float Duration = ReadPackFloat(pack);
	//Grant crits now, anti abuse, as usual.
	TF2_AddCondition(client, TFCond_CritOnDamage, Duration, client);

	return Plugin_Continue;
}

ArrayList SensalHitList;

void ZeinaInitiateSlash(int client, char abilityName[255])
{
	float diameter = 20.0;
	int r = 50;
	int g = 50;
	int b = 200;
	if(GetClientTeam(client) == 2)
	{
		r = 200;
		g = 0;
		b = 0;
	}

	static float belowBossEyes[3];
	GetBeamDrawStartPoint(client, belowBossEyes);
	float pos2[3];
	float vecForward[3];
	float Angles[3];
	GetClientEyeAngles(client, Angles);
	GetAngleVectors(Angles, vecForward, NULL_VECTOR, NULL_VECTOR);

	float VectorForward = 150.0; //a really high number.
	pos2[0] = belowBossEyes[0] + vecForward[0] * VectorForward;
	pos2[1] = belowBossEyes[1] + vecForward[1] * VectorForward;
	pos2[2] = belowBossEyes[2] + vecForward[2] * VectorForward;

	
	//Makes sure that it hits anything where you can see
	Handle trace;
	trace = TR_TraceRayFilterEx(belowBossEyes, pos2, MASK_ALL, RayType_EndPoint, Zeina_HitWorldOnly, client);	// 1073741824 is CONTENTS_LADDER?
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(pos2, trace);
	}
	delete trace;
	float hullMin[3];
	float hullMax[3];
	hullMin[0] = -float(SENSAL_LASER_THICKNESS);
	hullMin[1] = hullMin[0];
	hullMin[2] = hullMin[0];
	hullMax[0] = -hullMin[0];
	hullMax[1] = -hullMin[1];
	hullMax[2] = -hullMin[2];

	SensalHitList = new ArrayList();

	CF_StartLagCompensation(client);
	trace = TR_TraceHullFilterEx(belowBossEyes, pos2, hullMin, hullMax, MASK_ALL, Zeina_BEAM_TraceUsers, client);	// 1073741824 is CONTENTS_LADDER?
	
	CF_EndLagCompensation(client);
	delete trace;
	int colorLayer4[4];
	SetColorRGBA(colorLayer4, r, g, b, 200);
	int colorLayer3[4];
	SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, 60);
	int colorLayer2[4];
	SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, 60);
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 60);
	TE_SetupBeamPoints(belowBossEyes, pos2, g_Ruina_BEAM_Combine_Blue, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.2 * 1.25), ClampBeamWidth(diameter * 0.1 * 1.0), 0, 1.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(belowBossEyes, pos2, g_Ruina_BEAM_Combine_Blue, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3 * 1.25), ClampBeamWidth(diameter * 0.2 * 1.0), 0, 1.0, colorLayer2, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(belowBossEyes, pos2, g_Ruina_BEAM_Combine_Blue, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 0.4 * 1.25), ClampBeamWidth(diameter * 0.5 * 1.0), 0, 1.0, colorLayer3, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(belowBossEyes, pos2, g_Ruina_BEAM_Combine_Blue, 0, 0, 0, 0.33, ClampBeamWidth(diameter * 1.25), ClampBeamWidth(diameter * 0.6 * 1.0), 0, 1.0, colorLayer4, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(belowBossEyes, pos2, g_Ruina_BEAM_Combine_Black, 0, 0, 0, 0.33, ClampBeamWidth(diameter * 0.8), ClampBeamWidth(diameter * 0.5* 0.8), 0, 5.0, {255,255,255,255}, 0);
	TE_SendToAll(0.0);
	float playerPos[3];
	float damage_enemy = CF_GetArgF(client, PluginName, abilityName, "slash_damage_enemy");
	int length = SensalHitList.Length;
	for(int i; i < length; i++)
	{
		int victim = SensalHitList.Get(i);
		if(IsValidTarget(client, victim))
		{
			float vicPos[3];
			CF_WorldSpaceCenter(victim, vicPos);

			if(CF_HasLineOfSight(belowBossEyes, vicPos))
			{
				GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", playerPos, 0);
				SDKHooks_TakeDamage(victim, client, client, damage_enemy / 3.0, DMG_CLUB | DMG_CRIT, -1, NULL_VECTOR, playerPos, false);
			}
		}
	}

	delete SensalHitList;
	ZeinaAbilityEndSlash(client);
}

bool Zeina_BEAM_TraceUsers(int entity, int contentsMask, int client)
{
	if(entity == 0)
		return true;

	if (IsValidTarget(client, entity))
	{
		SensalHitList.Push(entity);
	}
	return false;
}

stock void SetColorRGBA(int color[4], int r, int g, int b, int a)
{
	color[0] = abs(r)%256;
	color[1] = abs(g)%256;
	color[2] = abs(b)%256;
	color[3] = abs(a)%256;
}

stock int abs(int x)
{
	return x < 0 ? -x : x;
}
stock float ClampBeamWidth(float w) { return w > 128.0 ? 128.0 : w; }

static void GetBeamDrawStartPoint(int client, float startPoint[3])
{
	GetClientEyePosition(client, startPoint);
	float angles[3];
	GetClientEyeAngles(client, angles);
	startPoint[2] -= 25.0;
}


void AddConnectingEffects_Zeina(int client, int weaponentity, int Mode, bool Invert)
{
	ExpidonsaRemoveEffects(client);
	int r = 150;
	int g = 150;
	int b = 200;
	if(GetClientTeam(client) == 2)
	{
		r = 200;
		g = 200;
		b = 15;
	}
	//Mode 0 means that its still charging.
	if(Mode == 0)
	{
		r = 100;
		g = 100;
		b = 100;
	}
	int particle_1 = InfoTargetParentAt({1.0,1.0,0.0}, "", 0.0); //This is the root bone basically
	int particle_2 = InfoTargetParentAt({1.0,1.0,0.0}, "", 0.0); //This is the root bone basically
	if(Invert)
	{
		SetParent(weaponentity, particle_1, "duelrea_left_spike", {-8.0,2.0,-1.0}, true);
		SetParent(weaponentity, particle_2, "duelrea_right_spike", {-8.0,2.0,-1.0}, true);
	}
	else
	{
		SetParent(weaponentity, particle_1, "duelrea_left_spike");
		SetParent(weaponentity, particle_2, "duelrea_right_spike");
	}

	int Laser_4_i = ConnectWithBeamClient(particle_1, particle_2, r, g, b, 1.25, 1.25, 100.0, LASERBEAM, client, Invert);
	
	i_ExpidonsaEnergyEffect[client][0] = EntIndexToEntRef(particle_1);
	i_ExpidonsaEnergyEffect[client][1] = EntIndexToEntRef(particle_2);
	i_ExpidonsaEnergyEffect[client][2] = EntIndexToEntRef(Laser_4_i);
}


stock int ConnectWithBeamClient(int iEnt, int iEnt2, int iRed=255, int iGreen=255, int iBlue=255,
							float fStartWidth=0.8, float fEndWidth=0.8, float fAmp=1.35, char[] Model = "sprites/laserbeam.vmt", int ClientToHideFirstPerson = 0, bool firstpersonhide = false)
{
	int iBeam = CreateEntityByName("env_beam");
	if(iBeam <= MaxClients)
		return -1;

	if(!IsValidEntity(iBeam))
		return -1;

	SetEntityModel(iBeam, Model);
	char sColor[16];
	Format(sColor, sizeof(sColor), "%d %d %d", iRed, iGreen, iBlue);

	DispatchKeyValue(iBeam, "rendercolor", sColor);
	DispatchKeyValue(iBeam, "life", "0");

	DispatchSpawn(iBeam);

	if(ClientToHideFirstPerson > 0)
	{
		AddEntityToThirdPersonTransitMode(ClientToHideFirstPerson, iBeam, firstpersonhide);
	}

	SetEntPropEnt(iBeam, Prop_Send, "m_hAttachEntity", EntIndexToEntRef(iEnt));

	SetEntPropEnt(iBeam, Prop_Send, "m_hAttachEntity", EntIndexToEntRef(iEnt2), 1);

	SetEntProp(iBeam, Prop_Send, "m_nNumBeamEnts", 2);
	SetEntProp(iBeam, Prop_Send, "m_nBeamType", 2);

	SetEntPropFloat(iBeam, Prop_Data, "m_fWidth", fStartWidth);
	SetEntPropFloat(iBeam, Prop_Data, "m_fEndWidth", fEndWidth);

	SetEntPropFloat(iBeam, Prop_Data, "m_fAmplitude", fAmp);

	SetVariantFloat(32.0);
	AcceptEntityInput(iBeam, "Amplitude");
	AcceptEntityInput(iBeam, "TurnOn");

	SetVariantInt(0);
	AcceptEntityInput(iBeam, "TouchType");

	SetVariantString("0");
	AcceptEntityInput(iBeam, "damage");

	return iBeam;
}


stock int InfoTargetParentAt(float position[3], const char[] todo_remove_massreplace_fix, float duration = 0.1)
{
	int info = CreateEntityByName("info_teleport_destination");
	if (info != -1)
	{
		if(todo_remove_massreplace_fix[0])
		{
			PrintToChatAll("an info target had a name, please report this to admins!!!!");
			ThrowError("shouldnt have a name, but does, fix it!");
		}
		TeleportEntity(info, position, NULL_VECTOR, NULL_VECTOR);
		SetEntPropFloat(info, Prop_Data, "m_flSimulationTime", GetGameTime());
		
		DispatchSpawn(info);

		//if it has no effect name, then it should always display, as its for other reasons.
		if (duration > 0.0)
			CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(info), TIMER_FLAG_NO_MAPCHANGE);
	}
	return info;
}

void AddEntityToThirdPersonTransitMode(int client, int entity, bool firstpersonhide)
{
	i_OwnerEntityEnvLaser[entity] = EntIndexToEntRef(client);
	if(firstpersonhide)
		SDKHook(entity, SDKHook_SetTransmit, ThirdersonTransmitEnvLaser_firstpersonhide); //This is for first person!
	else
		SDKHook(entity, SDKHook_SetTransmit, ThirdersonTransmitEnvLaser); //This is for third person!
}

public Action ThirdersonTransmitEnvLaser(int entity, int client)
{
	if(client > 0 && client <= MaxClients)
	{
		int owner = EntRefToEntIndex(i_OwnerEntityEnvLaser[entity]);
		if(owner == client)
		{
			if(TF2_IsPlayerInCondition(client, TFCond_Taunting) || GetEntProp(client, Prop_Send, "m_nForceTauntCam"))
			{
				return Plugin_Continue;
			}
		}
		else if(GetEntPropEnt(client, Prop_Send, "m_hObserverTarget") != owner || GetEntProp(client, Prop_Send, "m_iObserverMode") != 4)
		{
			return Plugin_Continue;
		}
	}
	return Plugin_Stop;
}

public Action ThirdersonTransmitEnvLaser_firstpersonhide(int entity, int client)
{
	if(client > 0 && client <= MaxClients)
	{
		int owner = EntRefToEntIndex(i_OwnerEntityEnvLaser[entity]);

		if(owner == client)
		{
			if(TF2_IsPlayerInCondition(client, TFCond_Taunting) || GetEntProp(client, Prop_Send, "m_nForceTauntCam"))
				return Plugin_Stop;
		}
		else if(GetEntPropEnt(client, Prop_Send, "m_hObserverTarget") != owner || GetEntProp(client, Prop_Send, "m_iObserverMode") != 4)
		{
			return Plugin_Stop;
		}
	}
	return Plugin_Continue;
}

float DashDuration[MAXPLAYERS+1];
float DashDurationStop[MAXPLAYERS+1];
float DashSpeed[MAXPLAYERS+1];

void ZeinaDashActivate(int client, char abilityName[255])
{
	if(IsValidEntity(ShieldEntRef[client]))
		return;
	//No dash during fly.

	CF_PlayRandomSound(client, client, "sound_zeina_dash");
	float Dur_charge = CF_GetArgF(client, PluginName, abilityName, "duration_charge");
	float Dur_Stop = CF_GetArgF(client, PluginName, abilityName, "duration_stop");

	DashDurationStop[client] = GetGameTime() + Dur_Stop;
	/*
		Docode to freeze player in place movement wise
	*/
	SetEntityMoveType(client, MOVETYPE_NONE);
	SDKUnhook(client, SDKHook_PreThink, ZeinaDashThink);
	SDKHook(client, SDKHook_PreThink, ZeinaDashThink);
	TF2_AddCondition(client, TFCond_MegaHeal, Dur_charge + 0.1);
	DashSpeed[client] = CF_GetArgF(client, PluginName, abilityName, "charge_speed");
	DashDuration[client] = GetGameTime() + Dur_charge;
}
public Action ZeinaDashThink(int client)
{
	float gametime = GetGameTime();
	if (!IsPlayerAlive(client))
	{
		SDKUnhook(client, SDKHook_PreThink, ZeinaDashThink);
		return Plugin_Stop;
	}

	if(gametime >= DashDuration[client])
	{
		SetEntityMoveType(client, MOVETYPE_WALK);
		CF_PlayRandomSound(client, client, "sound_zeina_dash");
		static float EntLoc[3];
				
		GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", EntLoc);

		static float anglesB[3];
		GetClientEyeAngles(client, anglesB);
		static float velocity[3];
		GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
		float knockback = DashSpeed[client];
		ScaleVector(velocity, knockback);
		if ((GetEntityFlags(client) & FL_ONGROUND) != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
			velocity[2] = fmax(velocity[2], 300.0);
		else
			velocity[2] += 150.0; // a little boost to alleviate arcing issues
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
		SDKUnhook(client, SDKHook_PreThink, ZeinaDashThink);
		SDKUnhook(client, SDKHook_PreThink, ZeinaDashThinkStop);
		SDKHook(client, SDKHook_PreThink, ZeinaDashThinkStop);
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action ZeinaDashThinkStop(int client)
{
	float gametime = GetGameTime();
	if (!IsPlayerAlive(client))
	{
		SDKUnhook(client, SDKHook_PreThink, ZeinaDashThinkStop);
		return Plugin_Stop;
	}

	if(gametime >= DashDurationStop[client])
	{
		CF_PlayRandomSound(client, client, "sound_zeina_dash_stop");
		static float EntLoc[3];
				
		GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", EntLoc);

		static float anglesB[3];
		GetClientEyeAngles(client, anglesB);
		static float velocity[3];
		GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
		float knockback = 300.0;
		ScaleVector(velocity, knockback);
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
		SDKUnhook(client, SDKHook_PreThink, ZeinaDashThinkStop);
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

bool IsValidAlly(int attacker, int victim)
{
	if(victim < 0 || victim > MAXENTITIES || !CF_IsValidTarget(victim, TFTeam_Unassigned))
		return false;

	int team = GetEntProp(attacker, Prop_Send, "m_iTeamNum");
	if(victim <= MaxClients)
	{
		if(!IsPlayerAlive(victim))
			return false;

		if(GetClientTeam(victim) != team)
			return false;
	}
	else
	{
		if(GetEntProp(victim, Prop_Data, "m_takedamage") == 0)
			return false;
		
		char classname[255];
		GetEntityClassname(victim, classname, sizeof(classname));

		if ((StrContains(classname, "obj_") != -1) && (StrContains(classname, "npc") != -1))
			return false;
		
		int team2 = GetEntProp(victim, Prop_Send, "m_iTeamNum");
		if(team2 != 0)
			return false;
	}
	return true;
}
bool IsValidTarget(int attacker, int victim)
{
	if(victim < 0 || victim > MAXENTITIES || !CF_IsValidTarget(victim, TFTeam_Unassigned))
		return false;
	
	int team = GetClientTeam(attacker);
	if(victim <= MaxClients)
	{
		if(!IsPlayerAlive(victim))
			return false;

		if(GetClientTeam(victim) == team)
			return false;
	}
	else
	{
		if(GetEntProp(victim, Prop_Data, "m_takedamage") == 0)
			return false;
		
		char classname[255];
		GetEntityClassname(victim, classname, sizeof(classname));

		if ((StrContains(classname, "obj_") != -1) && (StrContains(classname, "npc") != -1))
			return false;
		
		int team2 = GetEntProp(victim, Prop_Send, "m_iTeamNum");
		if(team2 == 0)
			return false;
		
	}

	return true;
}

//its a timer that applies this every 0.1 seconds and gives itself as the owner!

float ZeinaBeaconApplying[MAXENTITIES] = {-1.0, ...};
int ZeinaBeacon_CurrentProtectingIndex[MAXENTITIES];
float ZeinaBeaconResGive[MAXENTITIES] = {0.0, ...};
float ZeinaBeaconResGiveToOwner[MAXENTITIES] = {0.0, ...};
float ZeinaBeaconHadAlly[MAXENTITIES] = {0.0, ...};

void ZeinaBeaconActivate(int client, char abilityName[255])
{
	float Radius = CF_GetArgF(client, PluginName, abilityName, "beacon_radius");
	int Health = CF_GetArgI(client, PluginName, abilityName, "beacon_health");
	float Duration = CF_GetArgF(client, PluginName, abilityName, "beacon_duration");
	float BlockPercentage = CF_GetArgF(client, PluginName, abilityName, "beacon_block_percentage");
	float BlockPercentageSelf = CF_GetArgF(client, PluginName, abilityName, "beacon_block_percentage_self");
	
	int prop = Beacon_CreateProp(client);

	float pos2[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", pos2);
	ParticleEffectAt(pos2, "npc_boss_bomb_alert", 0.5);

	ZeinaBeaconResGive[prop] = BlockPercentage;
	ZeinaBeaconResGiveToOwner[prop] = BlockPercentageSelf;
	SetEntProp(prop, Prop_Data, "m_iHealth", Health);
	SetEntProp(prop, Prop_Data, "m_iMaxHealth", Health);

	DataPack pack2 = new DataPack();
	CreateDataTimer(0.1, ZeinaBeaconThink, pack2, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	WritePackCell(pack2, EntIndexToEntRef(prop));
	WritePackFloat(pack2, GetGameTime() + Duration);
	WritePackFloat(pack2, GetGameTime());
	WritePackFloat(pack2, Radius);
	WritePackFloat(pack2, BlockPercentage);
	WritePackFloat(pack2, BlockPercentageSelf);
}

public Action ZeinaBeaconThink(Handle timer, DataPack pack)
{
	ResetPack(pack);
	int Beacon = EntRefToEntIndex(ReadPackCell(pack));
	if (!IsValidEntity(Beacon))
		return Plugin_Stop;
		
	float Duration = ReadPackFloat(pack);
	if(Duration < GetGameTime())
	{
		DestroyBeaconFancy(Beacon);
		return Plugin_Stop;
	}
	float CooldownVisualAndSound = ReadPackFloat(pack);
	
	float Radius = ReadPackFloat(pack);
	static float EntLoc[3];
	static float EntLocSave[3];
	GetEntPropVector(Beacon, Prop_Data, "m_vecAbsOrigin", EntLoc);
	EntLocSave = EntLoc;
	EntLoc[2] += 10.0;

	int Owner = GetEntPropEnt(Beacon, Prop_Send, "m_hOwnerEntity");
	for (int i = 1; i < 2049; i++)
	{
		if (!IsValidAlly(Beacon, i))
			continue;

		float theirPos[3];
		CF_WorldSpaceCenter(i, theirPos);
		if (GetVectorDistance(EntLoc, theirPos) <= Radius)
		{
			ZeinaBeaconApplying[i] = GetGameTime() + 0.25;
			ZeinaBeacon_CurrentProtectingIndex[i] = EntIndexToEntRef(Beacon);
			if(Owner != i)
				ZeinaBeaconHadAlly[i] = GetGameTime() + 0.25;
		}
	}

	if(CooldownVisualAndSound < GetGameTime())
	{
		pack.Position--;
		pack.Position--;
		pack.WriteFloat(GetGameTime() + 0.9);
		int r = 50;
		int g = 50;
		int b = 200;
		if(SaveTeam == 2)
		{
			r = 200;
			g = 0;
			b = 0;
		}
		spawnRing_Vectors(EntLocSave, 1.0, 0.0, 0.0, 2.0, "materials/sprites/laserbeam.vmt", r, g, b, 200, 1, 0.35, 5.0, 8.0, 3, Radius * 2.0);	
		EmitSoundToAll("misc/halloween/spell_teleport.wav", Beacon, SNDCHAN_STATIC, 65, _, 0.7, 135);
	}
	
	return Plugin_Continue;
}
public int Beacon_CreateProp(int client)
{
	int prop = CreateEntityByName("prop_dynamic_override");
	if (IsValidEntity(prop))
	{
		TFTeam team = TF2_GetClientTeam(client);
		SetEntPropEnt(prop, Prop_Send, "m_hOwnerEntity", client);
		SetEntProp(prop, Prop_Send, "m_iTeamNum", team);
		
		int SaveTeam = GetEntProp(prop, Prop_Send, "m_iTeamNum");
		if(SaveTeam == 2)
		{
			SetEntityModel(prop, "models/props_moonbase/moon_gravel_crystal_red.mdl");
		}
		else
		{
			SetEntityModel(prop, "models/props_moonbase/moon_gravel_crystal_blue.mdl");
		}
		
		DispatchSpawn(prop);
	
		AcceptEntityInput(prop, "Enable");
		
		float pos[3], ang[3];
		GetClientEyeAngles(client, ang);
		GetClientAbsOrigin(client, pos);
		pos[2] += 20.0;
		ang[0] = 0.0;
		ang[2] = 0.0; //if somehow.

		SetEntPropFloat(prop, Prop_Send, "m_flModelScale", 2.0); 


		TeleportEntity(prop, pos, ang, NULL_VECTOR);
	}
	int prop2 = CreateEntityByName("prop_dynamic_override");
	if (IsValidEntity(prop2))
	{
		TFTeam team = TF2_GetClientTeam(client);
		SetEntPropEnt(prop2, Prop_Send, "m_hOwnerEntity", client);
		SetEntProp(prop2, Prop_Send, "m_iTeamNum", team);
		
		int SaveTeam = GetEntProp(prop2, Prop_Send, "m_iTeamNum");

		SetEntityModel(prop2, "models/effects/resist_shield/resist_shield.mdl");
		DispatchSpawn(prop2);
	
		ShieldAttachedToBeacon[prop] = EntIndexToEntRef(prop2);
		if(SaveTeam == 2)
		{
			SetEntProp(prop2, Prop_Send, "m_nSkin", 0);
		}
		else
		{
			SetEntProp(prop2, Prop_Send, "m_nSkin", 1);
		}

		AcceptEntityInput(prop2, "Enable");
		
		float pos[3], ang[3];
		GetClientEyeAngles(client, ang);
		GetClientAbsOrigin(client, pos);
		pos[2] -= 10.0;
		ang[0] = 0.0;
		ang[2] = 0.0; //if somehow.

		SetEntPropFloat(prop2, Prop_Send, "m_flModelScale", 0.9); 


		SetEntityRenderMode(prop2, RENDER_TRANSCOLOR);
		TeleportEntity(prop2, pos, ang, NULL_VECTOR);
	}
	
	
	return prop;
}

public Action CF_OnTakeDamageAlive_Resistance(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int &damagecustom)
{
	if (!IsValidClient(victim))
		return Plugin_Continue;
		
	if(ZeinaBeaconApplying[victim] < GetGameTime())
		return Plugin_Continue;
	
	int BeaconProtect = EntRefToEntIndex(ZeinaBeacon_CurrentProtectingIndex[victim]);
	if(!IsValidEntity(BeaconProtect) || BeaconProtect == 0)
		return Plugin_Continue;

	//Beacon is valid, and they are being protected

	//Am i the owner of the beacon? If yes, recieve much less resistance.
	int Owner = GetEntPropEnt(BeaconProtect, Prop_Send, "m_hOwnerEntity");

	float DamageResistance = ZeinaBeaconResGive[BeaconProtect];

	if(Owner == victim)
		DamageResistance = ZeinaBeaconResGiveToOwner[BeaconProtect];
		
	int dmg_through_armour = RoundToCeil(damage * (DamageResistance));
	switch(GetRandomInt(1,2))
	{
		case 1:
			EmitSoundToAll("weapons/rescue_ranger_charge_01.wav", victim, SNDCHAN_AUTO, 60, _, 0.15, GetRandomInt(95,105));
		
		case 2:
			EmitSoundToAll("weapons/rescue_ranger_charge_02.wav", victim, SNDCHAN_AUTO, 60, _, 0.15, GetRandomInt(95,105));
	}						
	int BeaconHealth = GetEntProp(BeaconProtect, Prop_Data, "m_iHealth");
	if(ZeinaBeaconHadAlly[BeaconProtect] < GetGameTime())
		BeaconHealth /= 3;

	int BeaconMaxHealth = GetEntProp(BeaconProtect, Prop_Data, "m_iMaxHealth");

	if((RoundToCeil(damage * (((DamageResistance * -1.0) + 1.0))) >= BeaconHealth))
	{
		int damage_recieved_after_calc;
		damage_recieved_after_calc = RoundToCeil(damage) - BeaconHealth;
		damage = float(damage_recieved_after_calc);
		DestroyBeaconFancy(BeaconProtect);
	}
	else
	{
		BeaconHealth -= RoundToCeil(damage * (((DamageResistance * -1.0) + 1.0)));
		damage = 0.0;
		damage += float(dmg_through_armour);
		if(ZeinaBeaconHadAlly[BeaconProtect] < GetGameTime())
			BeaconHealth *= 3;
	}

	SetEntProp(BeaconProtect, Prop_Data, "m_iHealth", BeaconHealth);
	
	int ShieldRemove = EntRefToEntIndex(ShieldAttachedToBeacon[BeaconProtect]);
	if(IsValidEntity(ShieldRemove) && ShieldRemove != 0)
	{
		// Set shield alpha lower the lower HP it has.
		int alpha = (BeaconHealth) * 255 / (BeaconMaxHealth);

		if(alpha > 255)
			alpha = 255;

		if(alpha < 1)
			alpha = 1;
		
		SetEntityRenderColor(ShieldRemove, 255, 255, 255, alpha);
	}

	int team = GetEntProp(victim, Prop_Data, "m_iTeamNum");
	int red = 50;
	int green = 50;
	int blue = 200;
	if(team == 2)
	{
		red = 200;
		green = 50;
		blue = 50;
	}
	int colorLayer4[4];
	float diameter = float(5 * 3);
	SetColorRGBA(colorLayer4, red, green, blue, 200);
	float PosUser[3];
	float PosBeacon[3];
	CF_WorldSpaceCenter(victim, PosUser);
	CF_WorldSpaceCenter(BeaconProtect, PosBeacon);
	//we set colours of the differnet laser effects to give it more of an effect
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 100);
	TE_SetupBeamPoints(PosBeacon, PosUser, g_Ruina_BEAM_Combine_Black, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.5), ClampBeamWidth(diameter * 0.8), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	int glowColor[4];
	SetColorRGBA(glowColor, red, green, blue, 200);
	TE_SetupBeamPoints(PosBeacon, PosUser, g_Ruina_BEAM_Combine_Blue, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.2), ClampBeamWidth(diameter * 0.2), 0, 0.5, glowColor, 0);
	TE_SendToAll(0.0);

	return Plugin_Changed;
}

void DestroyBeaconFancy(int beacon)
{
	float VecOrigin[3];
	GetEntPropVector(beacon, Prop_Data, "m_vecAbsOrigin", VecOrigin);
	VecOrigin[2] += 15.0;
	DataPack pack = new DataPack();
	pack.WriteFloat(VecOrigin[0]);
	pack.WriteFloat(VecOrigin[1]);
	pack.WriteFloat(VecOrigin[2]);
	pack.WriteCell(1);
	RequestFrame(MakeExplosionFrameLater, pack);
	int ShieldRemove = EntRefToEntIndex(ShieldAttachedToBeacon[beacon]);
	if(IsValidEntity(ShieldRemove) && ShieldRemove != 0)
		RemoveEntity(ShieldRemove);

	RemoveEntity(beacon);
}


public void MakeExplosionFrameLater(DataPack pack)
{
	pack.Reset();
	float vec_pos[3];
	vec_pos[0] = pack.ReadFloat();
	vec_pos[1] = pack.ReadFloat();
	vec_pos[2] = pack.ReadFloat();
	int Do_Sound = pack.ReadCell();
	
	int ent = CreateEntityByName("env_explosion");
	if(ent != -1)
	{
	//	SetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity", client);
		
		if(Do_Sound == 1)
		{		
			EmitAmbientSound("ambient/explosions/explode_3.wav", vec_pos, _, 75, _,0.7, GetRandomInt(75, 110));
		}
		
		DispatchKeyValueVector(ent, "origin", vec_pos);
		DispatchKeyValue(ent, "spawnflags", "581");
						
		DispatchKeyValue(ent, "rendermode", "0");
		DispatchKeyValue(ent, "fireballsprite", "spirites/zerogxplode.spr");
										
		DispatchKeyValueFloat(ent, "DamageForce", 0.0);								
		SetEntProp(ent, Prop_Data, "m_iMagnitude", 0); 
		SetEntProp(ent, Prop_Data, "m_iRadiusOverride", 0); 
									
		DispatchSpawn(ent);
		ActivateEntity(ent);
									
		AcceptEntityInput(ent, "explode");
		AcceptEntityInput(ent, "kill");
	}		
	SpawnSmallExplosionNotRandom(vec_pos);
	delete pack;
}


public void SpawnSmallExplosionNotRandom(float DetLoc[3])
{
	TE_Particle(EXPLOSION_PARTICLE_SMALL_1, DetLoc, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
}


stock void TE_Particle(const char[] Name, float origin[3]=NULL_VECTOR, float start[3]=NULL_VECTOR, float angles[3]=NULL_VECTOR, int entindex=-1, int attachtype= 0, int attachpoint=-1, bool resetParticles=true, int customcolors=0, float color1[3]=NULL_VECTOR, float color2[3]=NULL_VECTOR, int controlpoint=-1, int controlpointattachment=-1, float controlpointoffset[3]=NULL_VECTOR, float delay=0.0, int clientspec = 0)
{
	// find string table
	int tblidx = FindStringTable("ParticleEffectNames");
	if (tblidx == INVALID_STRING_TABLE)
	{
//		LogError2("[Plugin] Could not find string table: ParticleEffectNames");
		return;
	}

	// find particle index
	static char tmp[256];
	int count = GetStringTableNumStrings(tblidx);
	int stridx = INVALID_STRING_INDEX;
	for(int i; i<count; i++)
	{
		ReadStringTable(tblidx, i, tmp, sizeof(tmp));
		if(StrEqual(tmp, Name, false))
		{
			stridx = i;
			break;
		}
	}

	if(stridx == INVALID_STRING_INDEX)
	{
//		LogError2("[Boss] Could not find particle: %s", Name);
		return;
	}
	
	TE_Start("TFParticleEffect");
	TE_WriteFloat("m_vecOrigin[0]", origin[0]);
	TE_WriteFloat("m_vecOrigin[1]", origin[1]);
	TE_WriteFloat("m_vecOrigin[2]", origin[2]);
	TE_WriteFloat("m_vecStart[0]", start[0]);
	TE_WriteFloat("m_vecStart[1]", start[1]);
	TE_WriteFloat("m_vecStart[2]", start[2]);
	TE_WriteVector("m_vecAngles", angles);
	TE_WriteNum("m_iParticleSystemIndex", stridx);

//must include -1, or else it freaks out!!!!
//	if(entindex != -1)
	TE_WriteNum("entindex", entindex);

	if(attachtype != -1)
		TE_WriteNum("m_iAttachType", attachtype);

	if(attachpoint != -1)
		TE_WriteNum("m_iAttachmentPointIndex", attachpoint);

	TE_WriteNum("m_bResetParticles", resetParticles ? 1:0);
	if(customcolors)
	{
		TE_WriteNum("m_bCustomColors", customcolors);
		TE_WriteVector("m_CustomColors.m_vecColor1", color1);
		if(customcolors == 2)
			TE_WriteVector("m_CustomColors.m_vecColor2", color2);
	}

	if(controlpoint != -1)
	{
		TE_WriteNum("m_bControlPoint1", controlpoint);
		if(controlpointattachment != -1)
		{
			TE_WriteNum("m_ControlPoint1.m_eParticleAttachment", controlpointattachment);
			TE_WriteFloat("m_ControlPoint1.m_vecOffset[0]", controlpointoffset[0]);
			TE_WriteFloat("m_ControlPoint1.m_vecOffset[1]", controlpointoffset[1]);
			TE_WriteFloat("m_ControlPoint1.m_vecOffset[2]", controlpointoffset[2]);
		}
	}

	if(clientspec == 0)
		TE_SendToAll(delay);
	else
	{
		TE_SendToClient(clientspec, delay);
	}
}


stock void spawnRing_Vectors(float center[3], float range, float modif_X, float modif_Y, float modif_Z, char sprite[255], int r, int g, int b, int alpha, int fps, float life, float width, float amp, int speed, float endRange = -69.0, int client = 0) //Spawns a TE beam ring at a client's/entity's location
{
	float PosUse[3];
	PosUse = center;
	PosUse[0] += modif_X;
	PosUse[1] += modif_Y;
	PosUse[2] += modif_Z;
			
	int ICE_INT = PrecacheModel(sprite);
		
	int color[4];
	color[0] = r;
	color[1] = g;
	color[2] = b;
	color[3] = alpha;
		
	if (endRange == -69.0)
	{
		endRange = range + 0.5;
	}
	
	TE_SetupBeamRingPoint(PosUse, range, endRange, ICE_INT, ICE_INT, 0, fps, life, width, amp, color, speed, 0);
	if(client > 0)
	{
		TE_SendToClient(client);
	}
	else
	{
		TE_SendToAll();
	}
}


bool ZeinaWingsActivate(int client, char abilityName[255])
{
	int entity = -1;
	if(!abilityName[0])
		return false;	// Update model, no new one
	
	if(IsValidEntity(ShieldEntRef[client]))
	{
		TF2_RemoveWearable(client, EntRefToEntIndex(ShieldEntRef[client]));
	}

	// Remove overheal decay along with our shield
	entity = CF_AttachWearable(client, 57, "tf_wearable", true, 0, 0, _, "107 ; 1.5 ; 610 ; -15.0");
	if(entity == -1)
		return false;
	
	TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.01);

	char model[255];
	CF_GetArgS(client, PluginName, abilityName, "model", model, sizeof(model));
	
	//CF issue, model doesnt hav ea model name somehow.
	if(model[0])
	{
		SetEntProp(entity, Prop_Send, "m_nModelIndex", PrecacheModel(model));
	}
	CF_ChangeAbilityTitle(client, CF_AbilityType_Reload, "Leash Ally (hold ->)");
	CF_ApplyAbilityCooldown(client, 0.0, CF_AbilityType_Reload, true, false);
	ShieldEntRef[client] = EntIndexToEntRef(entity);
	FlightModeWas[client] = true;

	float pos2[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", pos2);
	ParticleEffectAt(pos2, "hammer_impact_button_dust", 1.0);

	if(GetClientTeam(client) == 2)
	{
		ParticleEffectAt(pos2, "utaunt_poweraura_yellow_start", 1.0);
	}
	else
	{
		ParticleEffectAt(pos2, "utaunt_poweraura_blue_start", 1.0);
	}

	CF_PlayRandomSound(client, client, "sound_fly_activate_sound");

	ZeinaFlightDuration[client] = GetGameTime() + CF_GetArgF(client, PluginName, abilityName, "flight_duration");
	ZeinaFlightDurationExtend[client] = CF_GetArgF(client, PluginName, abilityName, "flight_duration_extend");
	SDKUnhook(client, SDKHook_PreThink, ZeinaFlightThink);
	SDKHook(client, SDKHook_PreThink, ZeinaFlightThink);
	SetEntityMoveType(client, MOVETYPE_FLY);
	SvAirAccelerate_Client[client] = CF_GetArgF(client, PluginName, abilityName, "air_accelerate_flight");
	SvAccelerate_Client[client] = CF_GetArgF(client, PluginName, abilityName, "accelerate_flight");

	static float anglesB[3];
	GetClientEyeAngles(client, anglesB);
	static float velocity[3];
	GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
	float knockback = 300.0;
	ScaleVector(velocity, knockback);
	velocity[2] = 400.0;
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
	SetAlphaBodyGroup(client, entity, abilityName);
	AllyOnlyPickUpOne[client] = true;

	return true;
}

void SetAlphaBodyGroup(int client, int entity, char abilityName[255])
{
	TFTeam num = TF2_GetClientTeam(client);

	char team[32];
	if(num != TFTeam_Red && num != TFTeam_Blue)	// Note: If any FFA mode, add logic here
	{
		strcopy(team, sizeof(team), "_ffa");
	}
	else if(num == TFTeam_Red)
	{
		strcopy(team, sizeof(team), "_red");
	}
	else
	{
		strcopy(team, sizeof(team), "_blue");
	}

	char arg[255];

	FormatEx(arg, sizeof(arg), "alpha%s", team);
	int alpha = CF_GetArgI(client, PluginName, abilityName, arg);
	if(alpha != -1)
		SetEntityRenderColor(entity, 255, 255, 255, alpha);

	FormatEx(arg, sizeof(arg), "bodygroup%s", team);
	int bodygroup = CF_GetArgI(client, PluginName, abilityName, arg);
	if(bodygroup != -1)
	{
		SetVariantInt(bodygroup);
		AcceptEntityInput(entity, "SetBodyGroup");
	}
}
public Action ZeinaFlightThink(int client)
{
	if (!IsPlayerAlive(client))
	{
		if(IsValidEntity(ShieldEntRef[client]))
		{
			TF2_RemoveWearable(client, EntRefToEntIndex(ShieldEntRef[client]));
		}

		ShieldEntRef[client] = -1;

		SvAirAccelerate_Client[client] = SvAirAccelerate_Client[0];
		SvAccelerate_Client[client] = SvAccelerate_Client[0];
		SDKUnhook(client, SDKHook_PreThink, ZeinaFlightThink);
		
		CF_ChangeAbilityTitle(client, CF_AbilityType_Reload, "Sub Wings");
		CF_ApplyAbilityCooldown(client, 0.0, CF_AbilityType_Reload, true, false);
		return Plugin_Stop;
	}
	if(ZeinaFlightDuration[client] < GetGameTime())
	{
		if(IsValidEntity(ShieldEntRef[client]))
		{
			TF2_RemoveWearable(client, EntRefToEntIndex(ShieldEntRef[client]));
		}

		SetEntityMoveType(client, MOVETYPE_WALK);
		SDKUnhook(client, SDKHook_PreThink, ZeinaFlightThink);
		
		static float anglesB[3];
		GetClientEyeAngles(client, anglesB);
		static float velocity[3];
		GetAngleVectors(anglesB, velocity, NULL_VECTOR, NULL_VECTOR);
		float knockback = 300.0;
		ScaleVector(velocity, knockback);
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
		SvAirAccelerate_Client[client] = SvAirAccelerate_Client[0];
		SvAccelerate_Client[client] = SvAccelerate_Client[0];

		TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.01);
		CF_ChangeAbilityTitle(client, CF_AbilityType_Reload, "Sub Wings");
		CF_ApplyAbilityCooldown(client, 0.0, CF_AbilityType_Reload, true, false);
		return Plugin_Stop;
	}
	else
	{
		//If we are toughing the ground, do not fly.
		
		int buttons = GetClientButtons(client);
		if (buttons & IN_DUCK != 0)
		{	
			float currentVel[3];
			GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", currentVel);
			currentVel[2] = -300.0;
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, currentVel);
		}
		else if (buttons & IN_JUMP != 0)
		{
			float currentVel[3];
			GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", currentVel);
			currentVel[2] = 300.0;
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, currentVel);
		}
		float playerPos[3];
		GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", playerPos, 0);
		float playerPosend[3];
		playerPosend = playerPos;
		playerPosend[2] -= 16.0;
		float hullMin[3];
		float hullMax[3];
		hullMin = {-24.0,-24.0, 0.0};
		hullMax = {24.0,24.0, 1.0};

		Handle trace;
		trace = TR_TraceHullFilterEx(playerPos, playerPosend, hullMin, hullMax, MASK_SOLID, Zeina_TouchGround, client);	// 1073741824 is CONTENTS_LADDER?
		if (TR_DidHit(trace))
		{
			//when on ground, gimp movementspeed!!!
			SetEntityMoveType(client, MOVETYPE_WALK);
			if(FlightModeWas[client])
				TF2Attrib_SetByDefIndex(EntRefToEntIndex(ShieldEntRef[client]), 107, 1.0);

			FlightModeWas[client] = false;
		}
		else
		{
			SetEntityMoveType(client, MOVETYPE_FLY);
			if(!FlightModeWas[client])
				TF2Attrib_SetByDefIndex(EntRefToEntIndex(ShieldEntRef[client]), 107, 1.5);
			FlightModeWas[client] = true;
		}
		delete trace;
	}
	return Plugin_Continue;
}
bool Zeina_TouchGround(int entity, int contentsMask, int client)
{
	int targTeam = GetEntProp(entity, Prop_Send, "m_iTeamNum");
	int MyTeam = GetEntProp(client, Prop_Send, "m_iTeamNum");
	if(targTeam == MyTeam)
		return false;

	return true;
}


float TextTrottle[MAXPLAYERS +1];
int CurrentlyPickingUpAlly[MAXPLAYERS +1];
int TempSaveTeam;
void ZeinaPickupAlly(int client)
{
	if(!IsValidEntity(ShieldEntRef[client]))
	{
		//nope, only while flying.
		return;
	}

	if(!AllyOnlyPickUpOne[client])
	{
		if(IsValidEntity(LaserToConnectPickup[client]))
			RemoveEntity(LaserToConnectPickup[client]);

		SDKUnhook(client, SDKHook_PreThink, ZeinalMoveAllyToMe);
		int CarryThis = EntRefToEntIndex(CurrentlyPickingUpAlly[client]);
		if(IsValidClient(CarryThis))
		{
			PrintCenterText(CarryThis, "");
		}
		PrintCenterText(client, "");
		CurrentlyPickingUpAlly[client] = -1;
		return;
	}
	SDKUnhook(client, SDKHook_PreThink, ZeinaTryPickupAlly);
	SDKHook(client, SDKHook_PreThink, ZeinaTryPickupAlly);
}

void ZeinaTryPickupAlly(int client)
{
	if(!IsValidEntity(ShieldEntRef[client]))
	{
		//nope, only while flying.
		SDKUnhook(client, SDKHook_PreThink, ZeinaTryPickupAlly);
		return;
	}
	if(!AllyOnlyPickUpOne[client])
		SDKUnhook(client, SDKHook_PreThink, ZeinaTryPickupAlly);

	if(!IsPlayerAlive(client))
		SDKUnhook(client, SDKHook_PreThink, ZeinaTryPickupAlly);

	int buttons = GetClientButtons(client);
	if (!(buttons & IN_RELOAD != 0))
		SDKUnhook(client, SDKHook_PreThink, ZeinaTryPickupAlly);

	CurrentlyPickingUpAlly[client] = -1;
	int SaveTeam = GetEntProp(client, Prop_Send, "m_iTeamNum");
	SetEntProp(client, Prop_Send, "m_iTeamNum", 0);
	//So it lag comps allies.
	
	static float belowBossEyes[3];
	GetClientEyePosition(client, belowBossEyes);
	float pos2[3];
	float vecForward[3];
	float Angles[3];
	GetClientEyeAngles(client, Angles);
	GetAngleVectors(Angles, vecForward, NULL_VECTOR, NULL_VECTOR);
	CF_PlayRandomSound(client, client, "sound_zeina_pickup_ally");
	//Try pickupAlly
	
	float VectorForward = 500.0; //a really high number.
	pos2[0] = belowBossEyes[0] + vecForward[0] * VectorForward;
	pos2[1] = belowBossEyes[1] + vecForward[1] * VectorForward;
	pos2[2] = belowBossEyes[2] + vecForward[2] * VectorForward;
	CF_StartLagCompensation(client);
	Handle trace;
	TempSaveTeam = SaveTeam;
	trace = TR_TraceRayFilterEx(belowBossEyes, pos2, MASK_ALL, RayType_EndPoint, Zeina_FindTraceAlly, client);	// 1073741824 is CONTENTS_LADDER?
	CF_EndLagCompensation(client);
	SetEntProp(client, Prop_Send, "m_iTeamNum", SaveTeam);
	
	TextTrottle[client] = GetGameTime();
	if (TR_DidHit(trace))
	{
		int target = TR_GetEntityIndex(trace);	
		if(IsValidClient(target))
		{
			CurrentlyPickingUpAlly[client] = EntIndexToEntRef(target);
			SDKUnhook(client, SDKHook_PreThink, ZeinalMoveAllyToMe);
			SDKHook(client, SDKHook_PreThink, ZeinalMoveAllyToMe);
			int r = 100;
			int g = 100;
			int b = 200;
			if(GetClientTeam(client) == 2)
			{
				r = 200;
				g = 200;
				b = 15;
			}
			SDKUnhook(client, SDKHook_PreThink, ZeinaTryPickupAlly);
			int Laser_4_i = ConnectWithBeamClient(client, target, r, g, b, 2.25, 2.25, 5.0, LASERBEAM);

			CF_DoAbility(client, "cf_sensal", "sensal_ability_barrier_portal");
			ZeinaFlightDuration[client] += ZeinaFlightDurationExtend[client];
			//extend!
			LaserToConnectPickup[client] = EntIndexToEntRef(Laser_4_i);
			SetEntProp(client, Prop_Data, "m_iHammerID", CurrentlyPickingUpAlly[client] + 1000);
			CF_DoAbility(client, "cf_sensal", "sensal_ability_ally");
			CF_ChangeAbilityTitle(client, CF_AbilityType_Reload, "Let Go of Ally");
			AllyOnlyPickUpOne[client] = false;
			//We found our target to fly with!
			RequestFrame(SetCDBackReload, EntIndexToEntRef(client));
			TextTrottle[target] = GetGameTime();
			delete trace;
			return;
		}
	}
	RequestFrame(SetCDBackReloadfast, EntIndexToEntRef(client));
	delete trace;
}

void SetCDBackReloadfast(int ref)
{
	int client = EntRefToEntIndex(ref);
	if(!IsValidClient(client))
		return;
	CF_ApplyAbilityCooldown(client, 0.2, CF_AbilityType_Reload, true, false);
}
void SetCDBackReload(int ref)
{
	int client = EntRefToEntIndex(ref);
	if(!IsValidClient(client))
		return;
	CF_ApplyAbilityCooldown(client, 0.5, CF_AbilityType_Reload, true, false);
}
bool Zeina_FindTraceAlly(int entity, int contentsMask, int client)
{
	if(entity == 0)
		return false;
		
	if(entity == client)
		return false;

	if(!IsValidClient(entity))
		return false;

	int targTeam = GetEntProp(entity, Prop_Send, "m_iTeamNum");
	int MyTeam = TempSaveTeam;
	if(targTeam == MyTeam)
		return true;

	return false;
}
bool Zeina_HitWorldOnly(int entity, int contentsMask, int client)
{
	if(entity == 0)
		return true;
	
	return false;
}

void ZeinalMoveAllyToMe(int client)
{
	if(!IsValidEntity(ShieldEntRef[client]))
	{
		PrintCenterText(client, "");
		//nope, only while flying.
		SDKUnhook(client, SDKHook_PreThink, ZeinalMoveAllyToMe);
		if(IsValidEntity(LaserToConnectPickup[client]))
			RemoveEntity(LaserToConnectPickup[client]);
		TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.01);
		return;
	}
	int CarryThis = EntRefToEntIndex(CurrentlyPickingUpAlly[client]);
	if(!IsValidClient(CarryThis))
	{
		PrintCenterText(client, "");
		//nope, only while flying.
		SDKUnhook(client, SDKHook_PreThink, ZeinalMoveAllyToMe);
		if(IsValidEntity(LaserToConnectPickup[client]))
			RemoveEntity(LaserToConnectPickup[client]);
		return;
	}
	if(!IsPlayerAlive(CarryThis))
	{
		PrintCenterText(client, "");
		PrintCenterText(CarryThis, "");
		//nope, only while flying.
		SDKUnhook(client, SDKHook_PreThink, ZeinalMoveAllyToMe);
		if(IsValidEntity(LaserToConnectPickup[client]))
			RemoveEntity(LaserToConnectPickup[client]);
		return;
	}

	int buttons = GetClientButtons(CarryThis);
	if (buttons & IN_JUMP != 0)
	{
		PrintCenterText(CarryThis, "");
		//nope, only while flying.
		SDKUnhook(client, SDKHook_PreThink, ZeinalMoveAllyToMe);
		if(IsValidEntity(LaserToConnectPickup[client]))
			RemoveEntity(LaserToConnectPickup[client]);
	}
	if(TextTrottle[CarryThis] < GetGameTime())
	{
		TextTrottle[CarryThis] = GetGameTime() + 0.5;
		PrintCenterText(CarryThis, "Press [JUMP] to release yourself Manually!");
	}
	if(TextTrottle[client] < GetGameTime())
	{
		TextTrottle[client] = GetGameTime() + 0.5;
		PrintCenterText(client, "Press [R] To release your target early!");
	}
	float vecView[3];
	float vecFwd[3];
	float vecPos[3];
	float vecVel[3];

	GetClientEyeAngles(client, vecView);
	GetAngleVectors(vecView, vecFwd, NULL_VECTOR, NULL_VECTOR);

	GetEntPropVector(client, Prop_Send, "m_vecOrigin", vecPos);

	float gDistance = 2.0;
	vecPos[0]+=vecFwd[0]*gDistance;
	vecPos[1]+=vecFwd[1]*gDistance;
	vecPos[2]+=vecFwd[2]*gDistance;

	GetEntPropVector(CarryThis, Prop_Send, "m_vecOrigin", vecFwd);

	SubtractVectors(vecPos, vecFwd, vecVel);
	ScaleVector(vecVel, 10.0);
	
	TeleportEntity(CarryThis, NULL_VECTOR, NULL_VECTOR, vecVel);
	return;
}

stock int ParticleEffectAt(float position[3], const char[] effectName, float duration)
{
	int particle = CreateEntityByName("info_particle_system");
	if (particle != -1)
	{
		TeleportEntity(particle, position, NULL_VECTOR, NULL_VECTOR);
		SetEntPropFloat(particle, Prop_Data, "m_flSimulationTime", GetGameTime());
		DispatchKeyValue(particle, "effect_name", effectName);

		DispatchSpawn(particle);
		if(effectName[0])
		{
			ActivateEntity(particle);
			AcceptEntityInput(particle, "start");
		}

		SetEdictFlags(particle, (GetEdictFlags(particle) & ~FL_EDICT_ALWAYS));

		if (duration > 0.0)
		{
			char buffer[64];
			FormatEx(buffer, sizeof(buffer), "OnUser4 !self:Kill::%.2f:1,0,1", duration);
			SetVariantString(buffer);
			AcceptEntityInput(particle, "AddOutput");
			AcceptEntityInput(particle, "FireUser4");
		}
	}
	return particle;
}