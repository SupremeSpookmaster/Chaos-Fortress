#include <cf_include>
#include <sdkhooks>
#include <tf2_stocks>
#include <cf_stocks>

#define CBS				"cf_cbs"
#define DRAW			"cbs_special_draw"
#define BLAST			"cbs_explosive_arrow"
#define VOLLEY			"cbs_thousand_volley"
#define MELEE			"cbs_random_Melee"

#define SOUND_ARROW_DRAW		"weapons/bow_shoot_pull.wav"
#define SOUND_ARROW_SHOOT		"weapons/bow_shoot.wav"

public void OnMapStart()
{
	PrecacheSound(SOUND_ARROW_DRAW);
	PrecacheSound(SOUND_ARROW_SHOOT);
}

public void OnPluginStart()
{
}

public void CF_OnAbility(int client, char pluginName[255], char abilityName[255])
{
	if (!StrEqual(pluginName, CBS))
		return;
	
	if (StrContains(abilityName, DRAW) != -1)
		Draw_Activate(client, abilityName);
}

bool b_DrawActive[MAXPLAYERS + 1] = { false, ... };

float f_DrawChargeStartTime[MAXPLAYERS + 1] = { 0.0, ... };
float f_NextShootTime[MAXPLAYERS + 1] = { 0.0, ... };

char s_DrawAtts[MAXPLAYERS + 1][255];

public void Draw_Activate(int client, char abilityName[255])
{
	if (!Draw_IsHoldingHuntsman(client))
		return;
		
	int huntsman = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	
	if (!b_DrawActive[client])
		GetAttribStringFromWeapon(huntsman, s_DrawAtts[client]);
		
	TF2Attrib_RemoveAll(huntsman);
	
	char attribs[255];
	CF_GetArgS(client, CBS, abilityName, "attributes", attribs, sizeof(attribs));
	
	SetWeaponAttribsFromString(huntsman, attribs);
	
	RequestFrame(Draw_ForceDraw, GetClientUserId(client));
	b_DrawActive[client] = true;
	f_DrawChargeStartTime[client] = 0.0;
	EmitSoundToClient(client, SOUND_ARROW_DRAW);
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
		
		if (!resupply)
		{
			CreateTimer(0.2, Draw_RevertAtts, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
			EmitSoundToClient(client, SOUND_ARROW_SHOOT);
		}
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
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if (!IsValidClient(owner) || !b_DrawActive[owner])
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
	
	DataPack pack = new DataPack();
	WritePackCell(pack, EntIndexToEntRef(entity));
	WritePackFloatArray(pack, vel, sizeof(vel));
	WritePackFloatArray(pack, ang, sizeof(ang));
	WritePackFloatArray(pack, pos, sizeof(pos));
	WritePackFloat(pack, damage);
	RequestFrame(Draw_ApplyVelocity, pack);
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
	
	delete pack;
	
	if (IsValidEntity(entity))
	{
		TeleportEntity(entity, pos, ang, vel);
		SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, damage, true);
	}
}

public Action CF_OnAbilityCheckCanUse(int client, char plugin[255], char ability[255], CF_AbilityType type, bool &result)
{
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
	}
}

public void CF_OnCharacterCreated(int client)
{
}

public void CF_OnCharacterRemoved(int client)
{
	if (b_DrawActive[client])
	{
		SetForceButtonState(client, false, IN_ATTACK);
	}
	
	b_DrawActive[client] = false;
}