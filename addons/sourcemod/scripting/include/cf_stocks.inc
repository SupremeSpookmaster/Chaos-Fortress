#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <entity>
#include <tf2attributes>
#include <tf2items>
#include <morecolors>
#include <tf2_stocks>
#include <cfgmap>
#include <queue>
#include <clientprefs>
#include <tf_econ_data>
#include <tf_custom_attributes>
#include <tf2utils>
#include <dhooks>
#include <collisionhook>
#include <cf_include>

#define EXPLOSION_PARTICLE_LARGE_1 "fireSmoke_collumn_mvmAcres"
#define EXPLOSION_PARTICLE_LARGE_2 "hightower_explosion"

#define EXPLOSION_PARTICLE_SMALL_1 "ExplosionCore_MidAir"
#define EXPLOSION_PARTICLE_SMALL_2 "ExplosionCore_buildings"
#define EXPLOSION_PARTICLE_SMALL_3 "ExplosionCore_Wall"
#define EXPLOSION_PARTICLE_SMALL_4 "rd_robot_explosion"

#define CRIT1	"player/crit_hit.wav"
#define CRIT2	"player/crit_hit2.wav"
#define CRIT3	"player/crit_hit3.wav"
#define CRIT4	"player/crit_hit4.wav"
#define CRIT5	"player/crit_hit5.wav"

#define MINICRIT1	"player/crit_hit_mini.wav"
#define MINICRIT2	"player/crit_hit_mini2.wav"
#define MINICRIT3	"player/crit_hit_mini3.wav"
#define MINICRIT4	"player/crit_hit_mini4.wav"
#define MINICRIT5	"player/crit_hit_mini5.wav"

//#define EF_NODRAW	32

float OFF_THE_MAP[3] = {1182792704.0, 1182792704.0, -964690944.0};

float PhysProp_CurrentSpeed[2049] = { 0.0, ... };

enum ViewmodelSequence
{
	VMS_Melee_Swing_1 = 8,
	VMS_Melee_Swing_2,
	VMS_Melee_Swing_3,
	VMS_Melee_Idle,
	VMS_Melee_Draw,
	VMS_Melee_Swing_4,
	VMS_Melee_Swing_5,
	VMS_Melee_Swing_6,
	VMS_Jarate_Draw,
	VMS_Jarate_Idle,
	VMS_Jarate_Throw
};

enum ParticleAttachment_t {
	PATTACH_ABSORIGIN = 0,
	PATTACH_ABSORIGIN_FOLLOW,
	PATTACH_CUSTOMORIGIN,
	PATTACH_POINT,
	PATTACH_POINT_FOLLOW,
	PATTACH_WORLDORIGIN,
	PATTACH_ROOTBONE_FOLLOW
};

#define PARTICLE_DISPATCH_FROM_ENTITY		(1<<0)
#define PARTICLE_DISPATCH_RESET_PARTICLES	(1<<1)

stock float ApproachAngle(float target, float value, float speed)
{
	target = anglemod(target);
	value = anglemod(value);
	
	float delta = target - value;

	// Speed is assumed to be positive
	if (speed < 0)
		speed = -speed;

	if (delta < -180)
		delta += 360;
	else if (delta > 180)
		delta -= 360;

	if (delta > speed)
		value += speed;
	else if (delta < -speed)
		value -= speed;
	else 
		value = target;

	return value;
}

stock float anglemod(float angle)
{
	angle = fmodf(angle, 360.0);
	
	if (angle > 180) 
	{
		angle -= 360;
	}
	if (angle < -180)
	{
		angle += 360;
	}
	
	return angle;
}

stock float fmodf(float num, float denom)
{
	return num - denom * RoundToFloor(num / denom);
}

stock float GetDifference(float a, float b)
{
	if (a < 0.0)
		a *= -1.0;
	if (b < 0.0)
		b *= -1.0;
		
	float returnVal = a - b;
	if (returnVal < 0.0)
		returnVal *= -1.0;
		
	return returnVal;
}

stock float GetAngleDifference(float target, float value)
{
	target = anglemod(target);
	value = anglemod(value);
	
	float delta = target - value;

	if (delta < -180)
		delta += 360;
	else if (delta > 180)
		delta -= 360;

	return delta;
}

stock void Overlay_Apply(int client, const char[] overlay, int Methods = 0)
{
	if(Methods == 1 || Methods == 2)
	{
		int flags = GetCommandFlags("r_screenoverlay");
		SetCommandFlags("r_screenoverlay", flags & ~FCVAR_CHEAT);
		if(overlay[0])
		{
			ClientCommand(client, "r_screenoverlay \"%s\"", overlay);
		}
		else
		{
			ClientCommand(client, "r_screenoverlay off");
		}
		SetCommandFlags("r_screenoverlay", flags);
	}
	if(Methods == 0 || Methods == 2)
	{
		SetEntPropString(client, Prop_Send, "m_szScriptOverlayMaterial", overlay);
	}
}

stock void Overlay_Flash(int client, const char[] overlay, float duration)
{
	Overlay_Apply(client, overlay, 0);
	CreateTimer(duration, EndOverlayFlash, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
}

public Action EndOverlayFlash(Handle flashed, int id)
{
	int client = GetClientOfUserId(id);
	if (IsValidClient(client))
	{
		Overlay_Apply(client, "");
	}
	
	return Plugin_Continue;
}

stock void GetVelocityInDirection(float angles[3], float velocity, float output[3])
{
	float buffer[3];
	GetAngleVectors(angles, buffer, NULL_VECTOR, NULL_VECTOR);
	
	for (int i = 0; i < 3; i++)
	  output[i] = buffer[i] * velocity;
}

/**
 * Checks if a client is valid.
 *
 * @param client			The client to check.
 *
 * @return					True if the client is valid, false otherwise.
 */
stock bool IsValidClient(int client)
{
	if(client <= 0 || client > MaxClients)
	{
		return false;
	}
	
	if(!IsClientInGame(client))
	{
		return false;
	}

	return true;
}

/**
 * Checks if a client is valid and meets various given criteria.
 *
 * @param client			The client to check.
 * @param checkAlive		Do we need to check if the client is alive?
 * @param isAlive			If checkAlive is true: do we need the client to be alive?
 * @param checkTeam			Do we need to check the client's team?
 * @param targetTeam		If checkTeam is true: which team do we need the client to be on?
 *
 * @return					True if the client is valid and meets all given criteria, false otherwise.
 */
stock bool IsValidMulti(int client, bool checkAlive = true, bool isAlive = true, bool checkTeam = false, TFTeam targetTeam = TFTeam_Red)
{
	if(!IsValidClient(client))
	{
		return false;
	}
	
	if(checkAlive)
	{
		if (isAlive != IsPlayerAlive(client))
		{
			return false;
		}
	}
	
	if (checkTeam)
	{
		if (targetTeam != TF2_GetClientTeam(client))
		{
			return false;
		}
	}

	return true;
}

/**
 * Returns a KeyValues object from a given file path.
 *
 * @param path				The file path (EX: data/chaos_fortress/game_rules.cfg)
 * @param throwError		Do we want to throw an error if the kv does not exist?
 * @param error				The error to throw if throwError == true.
 *
 * @return					A KeyValues object created from the given path, null if invalid and throwError is not true.
 */
stock KeyValues GetKeyValuesFromPath(char path[255], bool throwError, char error[255])
{
	char file[255];
	BuildPath(Path_SM, file, PLATFORM_MAX_PATH, path);
	KeyValues kv = new KeyValues("");
	FileToKeyValues(kv, file);
 	
 	if (!kv.GotoFirstSubKey())
 	{
 		delete kv;
 		
 		if (throwError)
 		{
 			ThrowError(error);
 		}
 		else
 		{
 			return null;
 		}
 	}
 	
 	return kv;
}

stock TF2_GetNameOfClass(TFClassType class, char name[255], int maxlen)
{
	switch (class)
	{
		case TFClass_Scout: Format(name, maxlen, "scout");
		case TFClass_Soldier: Format(name, maxlen, "soldier");
		case TFClass_Pyro: Format(name, maxlen, "pyro");
		case TFClass_DemoMan: Format(name, maxlen, "demoman");
		case TFClass_Heavy: Format(name, maxlen, "heavy");
		case TFClass_Engineer: Format(name, maxlen, "engineer");
		case TFClass_Medic: Format(name, maxlen, "medic");
		case TFClass_Sniper: Format(name, maxlen, "sniper");
		case TFClass_Spy: Format(name, maxlen, "spy");
	}
}

/**
 * Returns a KeyValues object from a given file path, at a given section.
 *
 * @param path				The file path (EX: data/chaos_fortress/game_rules.cfg)
 * @param section			The section to go to.
 * @param throwError		Do we want to throw an error if the kv or section does not exist?
 * @param error				The error to throw if throwError == true.
 *
 * @return					A KeyValues object created from the given path, pre-navigated to the given section, null if invalid and throwError is not true.
 */
stock KeyValues GetKeyValuesAtSection(char path[255], char section[255], bool throwError, char error[255])
{
	char file[255];
	BuildPath(Path_SM, file, PLATFORM_MAX_PATH, path);
	KeyValues kv = new KeyValues("");
	FileToKeyValues(kv, file);
 	
 	if (!kv.JumpToKey(section))
 	{
 		delete kv;
 		
 		if (throwError)
 		{
 			ThrowError(error);
 		}
 		else
 		{
 			return null;
 		}
 	}
 	
 	return kv;
}

/**
 * Checks if a file exists.
 *
 * @param path			The file to check.
 *
 * @return					True if it exists, false otherwise.
 */
stock bool CheckFile(char path[255])
{
	bool exists = false;
	
	if (FileExists(path))
	{
		exists = true;
	}
	else
	{
		if (FileExists(path, true))
		{
			exists = true;
		}
	}
	
	return exists;
}

stock void CopyMenu(Menu &dest, Menu source)
{
	if (source == null || source == INVALID_HANDLE || dest == null || dest == INVALID_HANDLE)
		return;
		
	char title[255];
	source.GetTitle(title, 255);
	dest.SetTitle(title);
	
	int items = GetMenuItemCount(source);
	
	char item[255]; char info[255];
	int style;
	for (int i = 0; i < items; i++)
	{
		GetMenuItem(source, i, info, 255, style, item, 255);
		
		AddMenuItem(dest, info, item, style);
	}
}

/**
  * Creates a model entity and forces an animation on it.
  *
  * @param model		The model to be used.
  * @param animation	Name of the animation sequence to force.
  * @param spawnLoc		The location to spawn the model at.
  * @param spawnAng		The model's starting angles.
  * @param skin			The skin to be used for the model.
  * @param rate			Animation playback rate.
  * @param life		    How long should the model exist for? (0.0 or below = infinite)
  *
  * @return				The entity index of the created model, -1 if invalid.
  */
stock int SpawnDummyModel(char model[255], char animation[255], float spawnLoc[3], float spawnAng[3], char skin[255], float rate = 1.0, float life = 0.0)
{
	int ReturnValue = -1;
	
	ReturnValue = CreateEntityByName("prop_dynamic_override");
	
	if(IsValidEntity(ReturnValue))
	{
		TeleportEntity(ReturnValue, spawnLoc, NULL_VECTOR, NULL_VECTOR);
	
		DispatchKeyValue(ReturnValue, "skin", skin);
		DispatchKeyValue(ReturnValue, "model", model);	
		
		DispatchKeyValueVector(ReturnValue, "angles", spawnAng);
		
		DispatchSpawn(ReturnValue);
		ActivateEntity(ReturnValue);
		
		SetVariantString(animation);
		AcceptEntityInput(ReturnValue, "SetAnimation");
		DispatchKeyValueFloat(ReturnValue, "playbackrate", rate);
		
		if (life > 0.0)
		{
			CreateTimer(life, Timer_RemoveEntity, EntIndexToEntRef(ReturnValue), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	else
	{
		ReturnValue = -1;
	}
	
	return ReturnValue;
}

stock void ChangeModelAnimation(int model, char animation[255], float rate)
{
	if (IsValidEntity(model))
	{
		SetVariantString(animation);
		AcceptEntityInput(model, "SetAnimation");
		DispatchKeyValueFloat(model, "playbackrate", rate);
	}
}

stock void ChangeModelSkin(int model, char skin[255])
{
	if (IsValidEntity(model))
	{
		DispatchKeyValue(model, "skin", skin);
	}
}

public Action Timer_RemoveEntity(Handle removeEnt, int entityId)
{
	int entity = EntRefToEntIndex(entityId);
	if (IsValidEntity(entity) && entity > MaxClients)
	{
		TeleportEntity(entity, OFF_THE_MAP, NULL_VECTOR, NULL_VECTOR);
		AcceptEntityInput(entity, "Kill");
		RemoveEntity(entity);
	}
	return Plugin_Continue;
}

//int GAT_User = -1;
stock Handle getAimTrace(int client, TraceEntityFilter customTrace, int data = -1)
{
	if (!IsValidClient(client))
	{
		return null;
	}
	
	float eyePos[3];
	float eyeAng[3];
	GetClientEyePosition(client, eyePos);
	GetClientEyeAngles(client, eyeAng);
	
	Handle trace;
	
	//GAT_User = client;
	
	trace = TR_TraceRayFilterEx(eyePos, eyeAng, MASK_SHOT, RayType_Infinite, customTrace, data);
	
	return trace;
}

public bool Trace_OnlyHitWorld(entity, contentsMask)
{
	return entity == 0;
}

public bool CFTrace_OnlyHitEnemies(int entity, int contentsMask, int user)
{
	return CF_IsValidTarget(entity, grabEnemyTeam(user));
}

public bool Trace_HitSolids(entity, contentsMask, user)
{
	return Brush_Is_Solid(entity);
}

public bool TraceEntityFilterPlayer_GAT(entity, contentsMask)
{
	return entity > MaxClients;
}

stock void GetAngleToPoint(int ent, float TargetLoc[3], float DummyAngles[3], const float Output[3], float xOff = 0.0, float yOff = 0.0, float zOff = 0.0)
{
	float ang[3], pos[3], fVecFinal[3], fFinalPos[3];

	GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
	GetEntPropVector(ent, Prop_Send, "m_angRotation", ang);	

	pos[0] += xOff;
	pos[1] += yOff;
	pos[2] += zOff;

	AddInFrontOf(TargetLoc, DummyAngles, 7.0, fVecFinal);
	MakeVectorFromPoints(pos, fVecFinal, fFinalPos);

	GetVectorAngles(fFinalPos, ang);

	Output = ang;
}

stock void AddInFrontOf(float fVecOrigin[3], float fVecAngle[3], float fUnits, float fOutPut[3])
{
	float fVecView[3]; GetViewVector(fVecAngle, fVecView);
	
	fOutPut[0] = fVecView[0] * fUnits + fVecOrigin[0];
	fOutPut[1] = fVecView[1] * fUnits + fVecOrigin[1];
	fOutPut[2] = fVecView[2] * fUnits + fVecOrigin[2];
}

stock void GetViewVector(float fVecAngle[3], float fOutPut[3])
{
	fOutPut[0] = Cosine(fVecAngle[1] / (180 / FLOAT_PI));
	fOutPut[1] = Sine(fVecAngle[1] / (180 / FLOAT_PI));
	fOutPut[2] = -Sine(fVecAngle[0] / (180 / FLOAT_PI));
}

/**
 * Gives an entity an outline.
 *
 * @param iEnt		Entity to outline.
 * @param team		Entity's team.
 
 * @error Invalid entity index.
 
 * @return The entity index of the outline itself.
 */
stock int TF2_CreateGlow(int iEnt, int team)
{
	char oldEntName[64];
	GetEntPropString(iEnt, Prop_Data, "m_iName", oldEntName, sizeof(oldEntName));
	
	char strName[126], strClass[64];
	GetEntityClassname(iEnt, strClass, sizeof(strClass));
	Format(strName, sizeof(strName), "%s%i", strClass, iEnt);
	DispatchKeyValue(iEnt, "targetname", strName);
	
	int ent = CreateEntityByName("tf_glow");
	DispatchKeyValue(ent, "targetname", "RainbowGlow");
	DispatchKeyValue(ent, "target", strName);
	DispatchKeyValue(ent, "Mode", "0");
	DispatchSpawn(ent);
	
	AcceptEntityInput(ent, "Enable");
	
	SetEntPropString(iEnt, Prop_Data, "m_iName", oldEntName);
	
	switch(team)
	{
		case 0:
		SetVariantColor(view_as<int>({200, 200, 200, 255}));
		
		case 1:
		SetVariantColor(view_as<int>({0, 255, 0, 205}));
		
		case 2:
		SetVariantColor(view_as<int>({184, 56, 59, 255}));
		
		default:
		SetVariantColor(view_as<int>({88, 133, 162, 255}));
	}
	AcceptEntityInput(ent, "SetGlowColor");
	
	return ent;
}


stock int AttachWorldTextToEntity(int entity, char message[255], char point[255], float duration = 0.0, float xOff = 0.0, float yOff = 0.0, float zOff = 0.0)
{
	int ReturnValue = -1;
	
	if (IsValidEntity(entity))
	{
		int part1 = CreateEntityByName("point_worldtext");
		if (IsValidEdict(part1))
		{
			ReturnValue = part1;
			
			float pos[3];
			if (HasEntProp(entity, Prop_Data, "m_vecAbsOrigin"))
			{
				GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
			}
			else if (HasEntProp(entity, Prop_Send, "m_vecOrigin"))
			{
				GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
			}
			
			pos[0] += xOff;
			pos[1] += yOff;
			pos[2] += zOff;
			
			TeleportEntity(part1, pos, NULL_VECTOR, NULL_VECTOR);
			
			DispatchKeyValue(part1, "message", message);
	
			static char sColor[32];
			FormatEx(sColor, sizeof(sColor), "255 255 255 255"); //TODO: make this customizable
			DispatchKeyValue(part1, "color", sColor);
			DispatchSpawn(part1);
			SetEdictFlags(part1, (GetEdictFlags(part1) & ~FL_EDICT_ALWAYS));  
			DispatchKeyValue(part1, "targetname", "parented_text");
			DispatchKeyValue(part1, "orientation", "1");	//TODO: Make this customizable
			DispatchKeyValue(part1, "textsize", "10");	//TODO: Make this customizable	
			
			SetVariantString("!activator");
			AcceptEntityInput(part1, "SetParent", entity, part1);
			SetVariantString(point);
			AcceptEntityInput(part1, "SetParentAttachmentMaintainOffset", part1, part1);
			DispatchKeyValue(part1, "targetname", "present");
			DispatchSpawn(part1);
			ActivateEntity(part1);
			AcceptEntityInput(part1, "Start");
			
			if (duration > 0.0)
			{
				CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(part1), TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
	
	return ReturnValue;
}

stock int AttachModelToEntity(char model[255], char point[255], int parent, float life = 0.0, char skin[255] = "0", float xOff = 0.0, float yOff = 0.0, float zOff = 0.0, float xRot = 0.0, float yRot = 0.0, float zRot = 0.0)
{
	int ReturnValue = -1;
	
	ReturnValue = CreateEntityByName("prop_dynamic_override");
	
	if(IsValidEntity(ReturnValue))
	{
		float pos[3], ang[3];
		if (HasEntProp(parent, Prop_Data, "m_vecAbsOrigin"))
		{
			GetEntPropVector(parent, Prop_Data, "m_vecAbsOrigin", pos);
		}
		else if (HasEntProp(parent, Prop_Send, "m_vecOrigin"))
		{
			GetEntPropVector(parent, Prop_Send, "m_vecOrigin", pos);
		}
		
		TeleportEntity(ReturnValue, pos, NULL_VECTOR, NULL_VECTOR);
	
		DispatchKeyValue(ReturnValue, "skin", skin);
		DispatchKeyValue(ReturnValue, "model", model);	
		
		SetVariantString("!activator");
		AcceptEntityInput(ReturnValue, "SetParent", parent, ReturnValue);
		SetVariantString(point);
		AcceptEntityInput(ReturnValue, "SetParentAttachmentMaintainOffset", ReturnValue, ReturnValue);
		DispatchKeyValue(ReturnValue, "targetname", "present");
		
		DispatchSpawn(ReturnValue);
		ActivateEntity(ReturnValue);
		
		GetEntPropVector(ReturnValue, Prop_Send, "m_vecOrigin", pos);
		
		pos[0] += xOff;
		pos[1] += yOff;
		pos[2] += zOff;
		
		GetEntPropVector(ReturnValue, Prop_Send, "m_angRotation", ang);
		
		ang[0] += xRot;
		ang[1] += yRot;
		ang[2] += zRot;
		
		TeleportEntity(ReturnValue, pos, ang, NULL_VECTOR);
		
		if (life > 0.0)
		{
			CreateTimer(life, Timer_RemoveEntity, EntIndexToEntRef(ReturnValue), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	else
	{
		ReturnValue = -1;
	}
	
	return ReturnValue;
}

stock int AttachPhysModelToEntity(char model[255], char point[255], int parent, bool invincible, float health, float life = 0.0, char skin[255] = "0", float xOff = 0.0, float yOff = 0.0, float zOff = 0.0, float xRot = 0.0, float yRot = 0.0, float zRot = 0.0)
{
	int ReturnValue = -1;
	
	ReturnValue = CreateEntityByName("prop_physics_multiplayer");
	
	if(IsValidEntity(ReturnValue))
	{
		float pos[3], ang[3];
		if (HasEntProp(parent, Prop_Data, "m_vecAbsOrigin"))
		{
			GetEntPropVector(parent, Prop_Data, "m_vecAbsOrigin", pos);
		}
		else if (HasEntProp(parent, Prop_Send, "m_vecOrigin"))
		{
			GetEntPropVector(parent, Prop_Send, "m_vecOrigin", pos);
		}
		
		TeleportEntity(ReturnValue, pos, NULL_VECTOR, NULL_VECTOR);
	
		DispatchKeyValue(ReturnValue, "skin", skin);
		DispatchKeyValue(ReturnValue, "model", model);	
		
		SetVariantString("!activator");
		AcceptEntityInput(ReturnValue, "SetParent", parent, ReturnValue);
		SetVariantString(point);
		AcceptEntityInput(ReturnValue, "SetParentAttachmentMaintainOffset", ReturnValue, ReturnValue);
		DispatchKeyValue(ReturnValue, "targetname", "present");
		
		DispatchSpawn(ReturnValue);
		ActivateEntity(ReturnValue);
		
		GetEntPropVector(ReturnValue, Prop_Send, "m_vecOrigin", pos);
		
		if (invincible)
		{
			SetEntProp(ReturnValue, Prop_Data, "m_takedamage", 0, 1);
		}
		else
		{
			char healthChar[16];
			Format(healthChar, sizeof(healthChar), "%i", RoundFloat(health));
			DispatchKeyValue(ReturnValue, "Health", healthChar);
			SetEntityHealth(ReturnValue, RoundFloat(health));
		}
		
		pos[0] += xOff;
		pos[1] += yOff;
		pos[2] += zOff;
		
		GetEntPropVector(ReturnValue, Prop_Send, "m_angRotation", ang);
		
		ang[0] += xRot;
		ang[1] += yRot;
		ang[2] += zRot;
		
		TeleportEntity(ReturnValue, pos, ang, NULL_VECTOR);
		
		if (life > 0.0)
		{
			CreateTimer(life, Timer_RemoveEntity, EntIndexToEntRef(ReturnValue), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	else
	{
		ReturnValue = -1;
	}
	
	return ReturnValue;
}

public void PhysProp_MoveToTargetPosition(int ent, float targPos[3], float angOverride[3])
{
	if (ent < MaxClients + 1 || ent > 2048)
	return;
	
	if (!IsValidEntity(ent))
	return;
	
	float DroneLoc[3], Velocity[3], Angles[3];
	GetEntPropVector(ent, Prop_Send, "m_vecOrigin", DroneLoc);
	GetEntPropVector(ent, Prop_Send, "m_angRotation", Angles);
	 
	for (int vel = 0; vel < 3; vel++)
	{
		Velocity[vel] = 0.0;
	}
	
	float TargetSpeed = 900.0;
	
	PhysProp_ChangeSpeed(ent, 20.0, TargetSpeed);
	
	float dist = GetVectorDistance(DroneLoc, targPos);
	
	float fVecFinal[3], fFinalPos[3], DummyAngles[3];
	DummyAngles = Angles;
		
	AddInFrontOf(targPos, DummyAngles, 7.0, fVecFinal);
	MakeVectorFromPoints(DroneLoc, fVecFinal, fFinalPos);
		
	GetVectorAngles(fFinalPos, Angles);
		
	GetAngleVectors(Angles, Velocity, NULL_VECTOR, NULL_VECTOR);
	float mult = (dist/140.0);
	
	if (mult > 1.0)
	{
		mult = 1.0;
	}
		
	float FinalVelScale = PhysProp_CurrentSpeed[ent] * mult;
	ScaleVector(Velocity, FinalVelScale);
		
	TeleportEntity(ent, NULL_VECTOR, angOverride, Velocity);
}

public void PhysProp_ChangeSpeed(int ent, float mod, float maximum)
{
	if (ent < MaxClients + 1 || ent > 2048)
	return;
	
	if (!IsValidEntity(ent))
	return;
	
	if (PhysProp_CurrentSpeed[ent] > maximum)
	{
		PhysProp_CurrentSpeed[ent] += -mod;
	}
	else if (PhysProp_CurrentSpeed[ent] < maximum)
	{
		PhysProp_CurrentSpeed[ent] += mod;
	}
	
	
	if (PhysProp_CurrentSpeed[ent] < 0.0)
	{
		PhysProp_CurrentSpeed[ent] = 0.0;
	}
	
	if (PhysProp_CurrentSpeed[ent] > maximum)
	{
		PhysProp_CurrentSpeed[ent] = maximum;
	}
}

public void PhysProp_MoveToTargetPosition_Preview(int ent, int client, float angOverride[3], float maxDistance)
{
	if (ent < MaxClients + 1 || ent > 2048)
	return;
	
	if (!IsValidEntity(ent) || !IsValidClient(client))
	return;
	
	float vecView[3], vecFwd[3], vecPos[3], vecVel[3];
	GetClientEyeAngles(client, vecView);
	GetAngleVectors(vecView, vecFwd, NULL_VECTOR, NULL_VECTOR);
	GetClientEyePosition(client, vecPos);
	vecPos[0]+=vecFwd[0] * 140.0;
	vecPos[1]+=vecFwd[1] * 140.0;
	vecPos[2]+=vecFwd[2] * 140.0;
	GetEntPropVector(ent, Prop_Send, "m_vecOrigin", vecFwd);
	
	if (GetVectorDistance(vecFwd, vecPos) > maxDistance && maxDistance > 0.0)
	{
		TeleportEntity(ent, vecPos, angOverride, NULL_VECTOR);
	}
	else
	{
		SubtractVectors(vecPos, vecFwd, vecVel);
		ScaleVector(vecVel, 5.0);
		TeleportEntity(ent, NULL_VECTOR, angOverride, vecVel);
	}
}

stock int SpawnParticle(float origin[3], char particle[255], float duration = 0.0, bool start = true)
{
	int Effect = CreateEntityByName("info_particle_system");
	if (IsValidEdict(Effect))
	{
		TeleportEntity(Effect, origin, NULL_VECTOR, NULL_VECTOR);
		DispatchKeyValue(Effect, "effect_name", particle);
		DispatchKeyValue(Effect, "targetname", "present");
		DispatchSpawn(Effect);

		if (start)
		{
			ActivateEntity(Effect);
			AcceptEntityInput(Effect, "Start");
		}
		
		if (duration > 0.0)
		{
			CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(Effect), TIMER_FLAG_NO_MAPCHANGE);
		}
		
		return Effect;
	}
	
	return -1;
}

/**
 * Spawns a shaker at a given location.
 *
 * @param spawnLoc		The shaker's origin.
 * @param amp			The shaker's amplitude.
 * @param radius		The shaker's radius.
 * @param duration		The shaker's duration.
 * @param frequency		The shaker's frequency.
 * @param spawnflags	The shaker's spawn flags.
 *
 * @error Invalid client index.
 */
stock void SpawnShaker(float spawnLoc[3], int amp, int radius, int duration, int frequency, int spawnflags)
{
	int shaker = CreateEntityByName("env_shake");
	if(shaker != -1)
	{
		char StrConversion[16] = "";
		
		Format(StrConversion, sizeof(StrConversion), "%i", amp);
		DispatchKeyValue(shaker, "amplitude", StrConversion);
		
		Format(StrConversion, sizeof(StrConversion), "%i", radius);
		DispatchKeyValue(shaker, "radius", StrConversion);
		
		Format(StrConversion, sizeof(StrConversion), "%i", duration);
		DispatchKeyValue(shaker, "duration", StrConversion);
		
		Format(StrConversion, sizeof(StrConversion), "%i", frequency);
		DispatchKeyValue(shaker, "frequency", StrConversion);
		
		Format(StrConversion, sizeof(StrConversion), "%i", spawnflags);
		DispatchKeyValue(shaker, "spawnflags", StrConversion);
		
		DispatchKeyValueVector(shaker, "origin", spawnLoc);
		
		DispatchSpawn(shaker);
		AcceptEntityInput(shaker, "StartShake");
		
		CreateTimer(float(duration), Timer_RemoveEntity, EntIndexToEntRef(shaker), TIMER_FLAG_NO_MAPCHANGE);
	}
}

stock int GetIntFromConfigMap(ConfigMap map, char[] path, int defaultValue)
{
	char value[255];
	map.Get(path, value, sizeof(value));
	
	if (StrEqual(value, ""))
	{
		return defaultValue;
	}
	
	return StringToInt(value);
}

stock float GetFloatFromConfigMap(ConfigMap map, char[] path, float defaultValue)
{
	char value[255];
	map.Get(path, value, sizeof(value));
	
	if (StrEqual(value, ""))
	{
		return defaultValue;
	}
	
	return StringToFloat(value);
}

stock bool GetBoolFromConfigMap(ConfigMap map, char[] path, bool defaultValue)
{
	char value[255];
	map.Get(path, value, sizeof(value));
	
	if (StrEqual(value, ""))
	{
		return defaultValue;
	}
	
	return (StringToInt(value) != 0);
}

stock bool IsCharSoundscript(char character)
{
	if (IsCharAlpha(character) || IsCharNumeric(character) || character == '_' || character == '/' || character == '\\' || character == '.')
		return false;
	
	return true;
}

/**
 * Attaches a particle to an entity, and returns the entity index of the particle.
 *
 * @param entity      Entity index to attach the particle to.
 * @param type			Name of the particle to attach.
 * @param point 	The attachment point to attach the particle to.
 * @param duration	Optional particle lifespan. 0.0 or below: infinite.
 * @param xOff		Optional X-axis offset, in hammer units.
 * @param yOff		Optional Y-axis offset, in hammer units.
 * @param zOff		Optional Z-axis offset, in hammer units.
 *
 * @return			The entity index of the particle attached via this method.
 *
 * @error               Invalid entity index.
 */
stock int AttachParticleToEntity(int entity, char type[255], char point[255], float duration = 0.0, float xOff = 0.0, float yOff = 0.0, float zOff = 0.0)
{
	int ReturnValue = -1;
	
	if (IsValidEntity(entity))
	{
		int part1 = CreateEntityByName("info_particle_system");
		if (IsValidEdict(part1))
		{
			ReturnValue = part1;
			
			char name[16];
			FormatEx(name, sizeof(name), "target%d", entity);
			DispatchKeyValue(entity, "targetname", name);
			DispatchKeyValue(part1, "targetname", "tf2particle");
			DispatchKeyValue(part1, "parentname", name);
			DispatchKeyValue(part1, "effect_name", type);
			
			float pos[3];
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
			pos[0] += xOff;
			pos[1] += yOff;
			pos[2] += zOff;

			TeleportEntity(part1, pos, NULL_VECTOR, NULL_VECTOR);
			DispatchKeyValue(part1, "effect_name", type);
			SetVariantString("!activator");
			AcceptEntityInput(part1, "SetParent", entity, part1);
			SetVariantString(point);
			AcceptEntityInput(part1, "SetParentAttachmentMaintainOffset", part1, part1);
			DispatchKeyValue(part1, "targetname", "present");

			DispatchSpawn(part1);
			ActivateEntity(part1);
			AcceptEntityInput(part1, "Start");
			
			if (duration > 0.0)
			{
				CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(part1), TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
	
	return ReturnValue;
}

/**
 * Checks if a client is invisible. This includes the following checks:
 * The client's model is models/empty.mdl.
 * They have 0 alpha in their render color.
 * Their render mode is RENDER_NONE.
 * They are under one of the following TF2 conditions: TFCond_Cloaked, TFCond_Stealthed, or TFCond_StealthedUserBuffFade.
 *
 * @param client		The client to check.
 *
 * @return			True if the client is "invisible" by these tests, false otherwise.
 */
stock bool IsPlayerInvis(int client)
{
	if (!IsValidClient(client))
		return false;
		
	//Check for empty model:
	char model[255];
	GetEntPropString(client, Prop_Data, "m_ModelName", model, sizeof(model));
	
	if (StrContains(model, "empty.mdl") != -1)
		return true;
		
	//Check for zero alpha:
	int r, g, b, a;
	GetEntityRenderColor(client, r, g, b, a);
	if (a == 0)
		return true;
	
	//Check for RENDERFX_NONE and TF2's invisibility conditions:
	return GetEntityRenderMode(client) == RENDER_NONE || TF2_IsPlayerInCondition(client, TFCond_Cloaked) || TF2_IsPlayerInCondition(client, TFCond_Stealthed) || TF2_IsPlayerInCondition(client, TFCond_StealthedUserBuffFade);
}

/**
 * Borrowed from PC Gamer on AlliedMods and then *slightly* modified for Chaos Fortress. Credit goes to the original author.
 * Creates a wearable, given a set of inputs.
 *
 * @param client		The client to give the wearable to.
 * @param itemindex		The wearable's index.
 * @param classname		The wearable's classname
 * @param atts			The wearable's item attributes.
 * @param paint			The wearable's paint, 1-29.
 * @param style			Optional style override parameter for cosmetic wearables.
 * @param visible		True for the wearable to be visible, false to hide it.
 * @param lifespan		Optional lifespan for the wearable, 0.0 or below for infinite.
 *
 * @return			The wearable's item index.
 */
stock int CreateWearable(int client, int itemindex, char classname[255] = "tf_wearable", char atts[255] = "", int paint = 0, int style = 0, bool visible = true, float lifespan = 0.0)
{
	int hat = CreateEntityByName(classname);
	
	if (!IsValidEntity(hat))
	{
		return -1;
	}
	
	char entclass[64];
	GetEntityNetClass(hat, entclass, sizeof(entclass));
	SetEntData(hat, FindSendPropInfo(entclass, "m_iItemDefinitionIndex"), itemindex);
	SetEntData(hat, FindSendPropInfo(entclass, "m_bInitialized"), 1); 	
	SetEntData(hat, FindSendPropInfo(entclass, "m_iEntityLevel"), 77);
	SetEntData(hat, FindSendPropInfo(entclass, "m_iEntityQuality"), 7);
	SetEntProp(hat, Prop_Send, "m_bValidatedAttachedEntity", 1);
	
	if (paint > 0 && visible)
	{
		switch(paint)
		{
		case 1:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 3100495.0); //A color similar to slate
				TF2Attrib_SetByDefIndex(hat, 261, 3100495.0);
			}
		case 2:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 8208497.0); //A deep commitment to purple
				TF2Attrib_SetByDefIndex(hat, 261, 8208497.0);
			}
		case 3:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 1315860.0); //A distinctive lack of hue
				TF2Attrib_SetByDefIndex(hat, 261, 1315860.0);
			}
		case 4:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 12377523.0); //A mann's mint
				TF2Attrib_SetByDefIndex(hat, 261, 12377523.0);
			}
		case 5:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 2960676.0); //After eight
				TF2Attrib_SetByDefIndex(hat, 261, 2960676.0);
			}
		case 6:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 8289918.0); //Aged Moustache Grey
				TF2Attrib_SetByDefIndex(hat, 261, 8289918.0);
			}
		case 7:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 15132390.0); //An Extraordinary abundance of tinge
				TF2Attrib_SetByDefIndex(hat, 261, 15132390.0);
			}
		case 8:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 15185211.0); //Australium gold
				TF2Attrib_SetByDefIndex(hat, 261, 15185211.0);
			}
		case 9:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 14204632.0); //Color no 216-190-216
				TF2Attrib_SetByDefIndex(hat, 261, 14204632.0);
			}
		case 10:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 15308410.0); //Dark salmon injustice
				TF2Attrib_SetByDefIndex(hat, 261, 15308410.0);
			}
		case 11:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 8421376.0); //Drably olive
				TF2Attrib_SetByDefIndex(hat, 261, 8421376.0);
			}
		case 12:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 7511618.0); //Indubitably green
				TF2Attrib_SetByDefIndex(hat, 261, 7511618.0);
			}
		case 13:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 13595446.0); //Mann co orange
				TF2Attrib_SetByDefIndex(hat, 261, 13595446.0);
			}
		case 14:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 10843461.0); //Muskelmannbraun
				TF2Attrib_SetByDefIndex(hat, 261, 10843461.0);
			}
		case 15:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 5322826.0); //Noble hatters violet
				TF2Attrib_SetByDefIndex(hat, 261, 5322826.0);
			}
		case 16:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 12955537.0); //Peculiarly drab tincture
				TF2Attrib_SetByDefIndex(hat, 261, 12955537.0);
			}
		case 17:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 16738740.0); //Pink as hell
				TF2Attrib_SetByDefIndex(hat, 261, 16738740.0);
			}
		case 18:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 6901050.0); //Radigan conagher brown
				TF2Attrib_SetByDefIndex(hat, 261, 6901050.0);
			}
		case 19:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 3329330.0); //A bitter taste of defeat and lime
				TF2Attrib_SetByDefIndex(hat, 261, 3329330.0);
			}
		case 20:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 15787660.0); //The color of a gentlemanns business pants
				TF2Attrib_SetByDefIndex(hat, 261, 15787660.0);
			}
		case 21:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 8154199.0); //Ye olde rustic colour
				TF2Attrib_SetByDefIndex(hat, 261, 8154199.0);
			}
		case 22:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 4345659.0); //Zepheniahs greed
				TF2Attrib_SetByDefIndex(hat, 261, 4345659.0);
			}
		case 23:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 6637376.0); //An air of debonair
				TF2Attrib_SetByDefIndex(hat, 261, 2636109.0);
			}
		case 24:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 3874595.0); //Balaclavas are forever
				TF2Attrib_SetByDefIndex(hat, 261, 1581885.0);
			}
		case 25:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 12807213.0); //Cream spirit
				TF2Attrib_SetByDefIndex(hat, 261, 12091445.0);
			}
		case 26:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 4732984.0); //Operators overalls
				TF2Attrib_SetByDefIndex(hat, 261, 3686984.0);
			}
		case 27:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 12073019.0); //Team spirit
				TF2Attrib_SetByDefIndex(hat, 261, 5801378.0);
			}
		case 28:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 8400928.0); //The value of teamwork
				TF2Attrib_SetByDefIndex(hat, 261, 2452877.0);
			}
		case 29:
			{
				TF2Attrib_SetByDefIndex(hat, 142, 11049612.0); //Waterlogged lab coat
				TF2Attrib_SetByDefIndex(hat, 261, 8626083.0);
			}
		}
	}
	
	char attribs[32][32];
	int count = ExplodeString(atts, ";", attribs, 32, 32);

	if(count % 2)
		--count;
		
	for(int i; i < count; i += 2)
	{
		int attrib = StringToInt(attribs[i]);
		if(attrib)
		{
			TF2Attrib_SetByDefIndex(hat, attrib, StringToFloat(attribs[i + 1]));
		}
	}
	
	if (style > 0)
	{
		TF2Attrib_SetByDefIndex(hat, 542, float(style));
	}
	
	DispatchSpawn(hat);
	
	if (!visible)
	{
		SetEntityRenderMode(hat, RENDER_NONE);
		DispatchKeyValue(hat, "modelscale", "0.00001");
	}
	
	if (lifespan > 0.0)
	{
		CreateTimer(lifespan, Timer_RemoveEntity, EntIndexToEntRef(hat), TIMER_FLAG_NO_MAPCHANGE);
	}
	
	return hat;
} 

bool SpookPack_Casting[MAXPLAYERS+1] = {false, ...};

stock void SpookPack_CastEffect(int client)
{
	if (!IsValidMulti(client, true, true, false))
		return;
		
	TF2_RemoveWeaponSlot(client, 5);
	int spellbook = CF_SpawnWeapon(client, "tf_weapon_spellbook", 1070, 100, 5, 5, 0, 0, "178 ; 0.0");
	SpookPack_Casting[client] = true;
	FakeClientCommand(client, "use tf_weapon_spellbook");
			
	SetEntProp(spellbook, Prop_Send, "m_iSpellCharges", 1);
	SetEntProp(spellbook, Prop_Send, "m_iSelectedSpellIndex", 0);	
	CreateTimer(0.3, delete_spellbook, client, TIMER_FLAG_NO_MAPCHANGE);
}

public void SpookPack_OnEntityCreated(int entity, const char[] classname)
{
	if (StrContains(classname, "fireball") != -1)
	{
		SDKHook(entity, SDKHook_SpawnPost, DeleteFireball);
	}
}

public Action DeleteFireball(int ent)
{
	if (!IsValidEdict(ent))
		return Plugin_Continue;
		
	int owner = GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	if (SpookPack_Casting[owner])
	{
		TeleportEntity(ent, OFF_THE_MAP, NULL_VECTOR, NULL_VECTOR);
		AcceptEntityInput(ent, "Kill");
		RemoveEntity(ent);
		SpookPack_Casting[owner] = false;
	}
	
	return Plugin_Continue;
}

public Action delete_spellbook(Handle Fusion_delete_spellbook_handle, int client)
{
	if (IsValidClient(client))
	{
		int melee = GetPlayerWeaponSlot(client, 2);
		if (IsValidEdict(melee))
		{
			char weapon[255], command[255];
			GetEntityClassname(melee, weapon, 255);
			Format(command, sizeof(command), "use %s", weapon);
			FakeClientCommand(client, command);
			TF2_RemoveWeaponSlot(client, 5);
		}
	}	
	
	return Plugin_Continue;
}

stock void ForceViewmodelAnimation(int client, int sequence)
{
    int ent = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
    if (!IsValidEdict(ent)) 
    	return;
    
    SetEntProp(ent, Prop_Send, "m_nSequence", sequence);
}

stock void HidePlayerWeapon(int client, float duration)
{
	int ent = TF2_GetActiveWeapon(client);
	if (!IsValidEdict(ent))
		return;
		
	SetEntProp(ent, Prop_Send, "m_bBeingRepurposedForTaunt", 1);
	SetEntityRenderMode(ent, RENDER_TRANSALPHA);
	SetEntityRenderColor(ent, 0, 0, 0, 0);
	if (duration > 0.0)
	{
		CreateTimer(duration, UnhideWeapon, EntIndexToEntRef(ent), TIMER_FLAG_NO_MAPCHANGE);
	}
} 

stock bool IsPlayerHoldingWeapon(int client, int slot)
{
	int ent = TF2_GetActiveWeapon(client);
	return GetPlayerWeaponSlot(client, slot) == ent;
}

public Action UnhideWeapon(Handle unhide, int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (IsValidEdict(ent))
	{
		SetEntProp(ent, Prop_Send, "m_bBeingRepurposedForTaunt", 0);
		SetEntityRenderMode(ent, RENDER_TRANSALPHA);
		SetEntityRenderColor(ent, 255, 255, 255, 255);
	}
	
	return Plugin_Continue;
}

stock int TF2_GetActiveWeapon(int client)
{
	return GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
}

stock void StringToLower(char input[255])
{
	for (int i = 0; i < sizeof(input); i++)
	{
		input[i] = CharToLower(input[i]);
	}
}

stock void GetAttribStringFromWeapon(int weapon, char output[255])
{
	if (!IsValidEntity(weapon))
		return;
		
	int indices[20];
	TF2Attrib_ListDefIndices(weapon, indices, sizeof(indices));
	
	for (int i = 0; i < sizeof(indices); i++)
	{
		if (indices[i] <= 3018)	//Anything above 3018 is a custom attribute, so we need to ignore them to avoid going over the attribute limit.
		{
			Address addy = TF2Attrib_GetByDefIndex(weapon, indices[i]);
				
			if (addy != Address_Null)
			{
				if (i != 0)
				{
					Format(output, 255, "%s ; %i ; %f", output, indices[i], TF2Attrib_GetValue(addy));
				}
				else
				{
					Format(output, 255, "%i ; %f", indices[i], TF2Attrib_GetValue(addy));
				}
			}
		}
	}
}

stock void SetWeaponAttribsFromString(int weapon, char attributes[255])
{
	if (!IsValidEntity(weapon))
		return;
		
	char atts[32][32];
	int count = ExplodeString(attributes, ";", atts, 32, 32);

	if(count % 2)
		--count;
		
	for (int i; i < count; i += 2)
	{
		int attrib = StringToInt(atts[i]);
		float val = StringToFloat(atts[i + 1]);
		
		if(attrib)
		{
			TF2Attrib_SetByDefIndex(weapon, attrib, val);
		}
	}
}

//Credit to Zombie Riot:
stock void SetForceButtonState(int client, bool apply, int button_flag)
{
	int Buttons = GetEntProp(client, Prop_Data, "m_afButtonForced");

	if(apply)
	{
		Buttons |= button_flag;
	}
	else
	{
		Buttons &= ~button_flag;
	}
	
	SetEntProp(client, Prop_Data, "m_afButtonForced", Buttons);
}

//Below is borrowed from DarthNinja
stock void SetAmmo(int client, int weapon, int newAmmo)
{
	if (IsValidEntity(weapon))
	{
		int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		SetEntData(client, iAmmoTable+iOffset, newAmmo, 4, true);
	}
}

stock int GetAmmo(int client, int weapon)
{
	int value = -1;
	if (IsValidEntity(weapon))
	{
		int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		value = GetEntData(client, iAmmoTable+iOffset);
	}
	
	return value;
}

stock void SetClip(int client, int weapon, int newAmmo)
{
	if (IsValidEntity(weapon))
	{
		int iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
		SetEntData(weapon, iAmmoTable, newAmmo, 4, true);
	}
}

stock GetClip(int weapon)
{
    if (IsValidEntity(weapon))
    {
        return GetEntProp(weapon, Prop_Send, "m_iClip1");
    }
    return 0;
} 
//Above is borrowed from DarthNinja

/**
 * Retrieves the client's enemy team.
 *
 * @param client      The client to check.
 *
 * @error		Invalid client index.
 *
 * @return		The client's enemy team (TFTeam value).
 */
stock TFTeam grabEnemyTeam(int client) //Grabs a client's opposing team and returns it.
{
	TFTeam targTeam = TFTeam_Red;
	
	if (IsValidClient(client))
	{
		TFTeam userTeam = TF2_GetClientTeam(client);
		
		if (userTeam == TFTeam_Red)
		{
			targTeam = TFTeam_Blue;
		}
	}
	
	return targTeam;
}

stock float GetAttributeValue(int entity, int attribute, float defaultVal)
{
	if (!IsValidEntity(entity))
		return defaultVal;
		
	Address addy = TF2Attrib_GetByDefIndex(entity, attribute);
	if (addy == Address_Null)
		return defaultVal;
		
	return TF2Attrib_GetValue(addy);
}

//Thanks, Artvin:
stock float[] GetWorldSpaceCenter(int client)
{
	float v[3]; v = GetAbsOrigin(client);
	
	float max_space[3];
	GetEntPropVector(client, Prop_Data, "m_vecMaxs", max_space);
	v[2] += max_space[2] / 2;
	
	return v;
}

stock float[] GetAbsOrigin(int client)
{
	float v[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", v);
	return v;
}

stock float[] GetOrigin(int client)
{
	float v[3];
	GetEntPropVector(client, Prop_Data, "m_vecOrigin", v);
	return v;
}

stock bool IsBehindAndFacingTarget(int owner, int target)
{
	float vecToTarget[3];
	SubtractVectors(GetWorldSpaceCenter(target), GetWorldSpaceCenter(owner), vecToTarget);

	vecToTarget[2] = 0.0;
	NormalizeVector(vecToTarget, vecToTarget);
	
	float vecEyeAngles[3];
	
	if(owner <= MaxClients)
		GetClientEyeAngles(owner, vecEyeAngles);
	else
		GetEntPropVector(owner, Prop_Data, "m_angRotation", vecEyeAngles);
		
	float vecOwnerForward[3];
	GetAngleVectors(vecEyeAngles, vecOwnerForward, NULL_VECTOR, NULL_VECTOR);
	vecOwnerForward[2] = 0.0;
	NormalizeVector(vecOwnerForward, vecOwnerForward);
	
	if(target <= MaxClients)
		GetClientEyeAngles(target, vecEyeAngles);
	else
		GetEntPropVector(target, Prop_Data, "m_angRotation", vecEyeAngles);

	float vecTargetForward[3];
	GetAngleVectors(vecEyeAngles, vecTargetForward, NULL_VECTOR, NULL_VECTOR);
	vecTargetForward[2] = 0.0;
	NormalizeVector(vecTargetForward, vecTargetForward);
	
	float flPosVsTargetViewDot = GetVectorDotProduct(vecToTarget, vecTargetForward);
	float flPosVsOwnerViewDot = GetVectorDotProduct(vecToTarget, vecOwnerForward);
	float flViewAnglesDot = GetVectorDotProduct(vecTargetForward, vecOwnerForward);
	
	return ( flPosVsTargetViewDot > 0.0 && flPosVsOwnerViewDot > 0.5 && flViewAnglesDot > -0.3 );
}

stock void WritePackFloatArray(DataPack pack, const float[] arr, int size)
{
	for (int i = 0; i < size; i++)
	{
		WritePackFloat(pack, arr[i]);
	}
}

stock void ReadPackFloatArray(DataPack pack, float[] arr, int size)
{
	for (int i = 0; i < size; i++)
	{
		arr[i] = ReadPackFloat(pack);
	}
}

stock DynamicHook DHook_CreateVirtual(GameData gd, const char[] name)
{
	DynamicHook hook = DynamicHook.FromConf(gd, name);
	if (!hook)
		LogError("Failed to create virtual: %s", name);
	
	return hook;
}

/**
 * Checks if a client is invulnerable.
 *
 * @param client	The client to check.
 *
 * @return		True if the client is invulnerable, false otherwise.
 */
stock bool IsInvuln(int client) //Borrowed from Batfoxkid. Checks if the client is invulnerable.
{
	if(!IsValidClient(client))
	return true;
	
	return (TF2_IsPlayerInCondition(client, TFCond_Ubercharged) ||
		TF2_IsPlayerInCondition(client, TFCond_UberchargedCanteen) ||
		TF2_IsPlayerInCondition(client, TFCond_UberchargedHidden) ||
		TF2_IsPlayerInCondition(client, TFCond_UberchargedOnTakeDamage) ||
		TF2_IsPlayerInCondition(client, TFCond_Bonked) ||
		TF2_IsPlayerInCondition(client, TFCond_HalloweenGhostMode) ||
		!GetEntProp(client, Prop_Data, "m_takedamage"));
}

/**
 * Spawns a 2-point particle (IE medigun beam, dispenser beam, etc) and connects it through 2 entities.
 * 
 * @param startEnt		The entity to start from.
 * @param startPoint	The point to attach the starting entity to.
 * @param startXOff		Starting point X-axis offset.
 * @param startYOff		Starting point Y-axis offset.
 * @param startZOff		Starting point Z-axis offset.
 * @param endEnt		The entity to end at.
 * @param endPoint		The point to attach the end entity to.
 * @param endXOff		Ending point X-axis offset.
 * @param endYOff		Ending point Y-axis offset.
 * @param endZOff		Ending point Z-axis offset.
 * @param effect		The particle to connect.
 * @param returnStart	Return parameter for the particle created at the start of the effect.
 * @param returnEnd		Return parameter for the particle created at the end of the effect.
 * @param duration		The duration of the effect. <= 0.0: infinite.
 */
stock void AttachParticle_ControlPoints(int startEnt, char startPoint[255], float startXOff, float startYOff, float startZOff, int endEnt, char endPoint[255], float endXOff, float endYOff, float endZOff, char effect[255], int &returnStart, int &returnEnd, float duration = 0.0)
{
	float startPos[3], endPos[3];
	CF_WorldSpaceCenter(startEnt, startPos);
	CF_WorldSpaceCenter(endEnt, endPos);

	int particle = SpawnParticle(startPos, effect, duration, false);
	int particle2 = SpawnParticle(endPos, effect, duration, false);

	float offsets[3];
	offsets[0] = startXOff;
	offsets[1] = startYOff;
	offsets[2] = startZOff;
	SetParent(startEnt, particle, startPoint, offsets, true);

	offsets[0] = endXOff;
	offsets[1] = endYOff;
	offsets[2] = endZOff;
	SetParent(endEnt, particle2, endPoint, offsets, true);

	char szCtrlParti[128];
	Format(szCtrlParti, sizeof(szCtrlParti), "tf2ctrlpart%i", EntIndexToEntRef(particle2));
	DispatchKeyValue(particle, "targetname", szCtrlParti);

	DispatchKeyValue(particle2, "cpoint1", szCtrlParti);

	ActivateEntity(particle2);
	AcceptEntityInput(particle2, "start");

	returnStart = particle;
	returnEnd = particle2;
}

stock bool AreVectorsEqual(const float vVec1[3], const float vVec2[3])
{
	return (vVec1[0] == vVec2[0] && vVec1[1] == vVec2[1] && vVec1[2] == vVec2[2]);
} 

//Thanks Artvin/BatFox:
stock void SetParent(int iParent, int iChild, const char[] szAttachment = "", const float vOffsets[3] = {0.0,0.0,0.0}, bool maintain_anyways = false)
{
	SetVariantString("!activator");
	AcceptEntityInput(iChild, "SetParent", iParent, iChild);
	
	if (szAttachment[0] != '\0') // Use at least a 0.01 second delay between SetParent and SetParentAttachment inputs.
	{
		if (szAttachment[0]) // do i even have anything?
		{
			SetVariantString(szAttachment); // "head"

			if (maintain_anyways || !AreVectorsEqual(vOffsets, view_as<float>({0.0,0.0,0.0}))) // NULL_VECTOR
			{
				if(!maintain_anyways)
				{
					float Vecpos[3];

					Vecpos = vOffsets;
					CF_SetLocalOrigin(iChild, Vecpos);
				}
				AcceptEntityInput(iChild, "SetParentAttachmentMaintainOffset", iParent, iChild);
			}
			else
			{
				AcceptEntityInput(iChild, "SetParentAttachment", iParent, iChild);
			}
		}
	}
}

/**
 * Removes all entities from an ArrayList, and then deletes the ArrayList.
 * All cells must contain entity references, not just indices, or this will not work.
 * 
 * @param list		The ArrayList.
 */
stock void RemoveArrayList(ArrayList list)
{
	if (list == null)
		return;

	for (int i = 0; i < GetArraySize(list); i++)
	{
		int ent = EntRefToEntIndex(GetArrayCell(list, i));
		if (IsValidEntity(ent))
			RemoveEntity(ent);
	}

	delete list;
}

stock void SpawnParticle_ControlPoints(float StartPos[3], float EndPos[3], char particleType[255], float duration)
{
	 int particle  = CreateEntityByName("info_particle_system");
	 int particle2 = CreateEntityByName("info_particle_system");
	 int ent = SpawnParticle(StartPos, "");
	 int controlpoint = SpawnParticle(EndPos, "");
 
	 if (IsValidEdict(particle) && IsValidEdict(particle2) && IsValidEdict(ent) && IsValidEdict(controlpoint))
	 {
		  TeleportEntity(particle, StartPos, NULL_VECTOR, NULL_VECTOR); 
		  TeleportEntity(particle2, EndPos, NULL_VECTOR, NULL_VECTOR);
		  
		  char tName[128];
		  Format(tName, sizeof(tName), "target%i", ent);
		  DispatchKeyValue(ent, "targetname", tName);
		  
		  char cpName[128];
		  Format(cpName, sizeof(cpName), "Xtarget%i", controlpoint);
		  
		  DispatchKeyValue(particle2, "targetname", cpName);
		  
		  DispatchKeyValue(particle, "targetname", "tf2particle");
		  DispatchKeyValue(particle, "parentname", tName);
		  DispatchKeyValue(particle, "effect_name", particleType);
		  DispatchKeyValue(particle, "cpoint1", cpName);
		  
		  DispatchSpawn(particle);
		  SetVariantString(tName);
		  AcceptEntityInput(particle, "SetParent", particle, particle, 0);
		  
		  SetVariantString("flag");
		  AcceptEntityInput(particle, "SetParentAttachment", particle, particle, 0);
		  
		  ActivateEntity(particle);
		  AcceptEntityInput(particle, "start");
		  
		  CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
		  CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(particle2), TIMER_FLAG_NO_MAPCHANGE);
		  CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(controlpoint), TIMER_FLAG_NO_MAPCHANGE);
		  CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(ent), TIMER_FLAG_NO_MAPCHANGE);
	 }
} 

/**
 * Spawns a TE beam based on vector points.
 *
 * @param TO-DO: FILL THIS IN
 *
 */
stock void SpawnBeam_Vectors(float StartLoc[3], float EndLoc[3], float beamTiming, int r, int g, int b, int a, int modelIndex, float width=2.0, float endwidth=2.0, int fadelength=1, float amp=15.0, int target = -1)
{
	int color[4];
	color[0] = r;
	color[1] = g;
	color[2] = b;
	color[3] = a;
	
	TE_SetupBeamPoints(StartLoc, EndLoc, modelIndex, 0, 0, 0, beamTiming, width, endwidth, fadelength, amp, color, 0);
	
	if (!IsValidClient(target))
	{
		TE_SendToAll();
	}
	else
	{
		TE_SendToClient(target);
	}
}

stock void spawnRing_Vector(float center[3], float range, float modif_X, float modif_Y, float modif_Z, int modelIndex, int r, int g, int b, int alpha, int fps, float life, float width, float amp, int speed, float endRange = 0.0, int target = 0) //Spawns a TE beam ring at a client's/entity's location
{
	center[0] += modif_X;
	center[1] += modif_Y;
	center[2] += modif_Z;
	
	int color[4];
	color[0] = r;
	color[1] = g;
	color[2] = b;
	color[3] = alpha;
	
	if (endRange == 0.0)
	{
		endRange = range + 0.5;
	}
	
	TE_SetupBeamRingPoint(center, range, endRange, modelIndex, modelIndex, 0, fps, life, width, amp, color, speed, 0);
	
	if (IsValidClient(target))
	{
		TE_SendToClient(target);
	}
	else
	{
		TE_SendToAll();
	}
}

stock float GetDistanceToGround(float location[3])
{
	float angles[3], otherLoc[3];
	angles[0] = 90.0;
	angles[1] = 0.0;
	angles[2] = 0.0;
	
	Handle trace = TR_TraceRayFilterEx(location, angles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer_GAT);
	TR_GetEndPosition(otherLoc, trace);
	//CloseHandle(trace);
	delete trace;
	
	return GetVectorDistance(location, otherLoc);
}

stock float GetDistanceToCeiling(float location[3])
{
	float angles[3], otherLoc[3];
	angles[0] = -90.0;
	angles[1] = 0.0;
	angles[2] = 0.0;
	
	Handle trace = TR_TraceRayFilterEx(location, angles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer_GAT);
	TR_GetEndPosition(otherLoc, trace);
	//CloseHandle(trace);
	delete trace;
	
	return GetVectorDistance(location, otherLoc);
}

stock float GetDistanceToWall(float location[3], float angles[3])
{
	float otherLoc[3];
	
	Handle trace = TR_TraceRayFilterEx(location, angles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer_GAT);
	TR_GetEndPosition(otherLoc, trace);
	//CloseHandle(trace);
	delete trace;
	
	return GetVectorDistance(location, otherLoc);
}

stock void ForceGuaranteedDamage(int victim, float damage, int attacker = 0, int inflictor = 0, int weapon = 0, int damagetype = DMG_GENERIC)
{
	bool IsClient = IsValidClient(victim);
	if (IsClient)
		RemoveAllInvuln(victim);
	
	DataPack pack = new DataPack();
	WritePackCell(pack, view_as<int>(IsClient));
	WritePackCell(pack, IsClient ? GetClientUserId(victim) : EntIndexToEntRef(victim));
	WritePackFloat(pack, damage);
	WritePackCell(pack, IsValidClient(attacker) ? GetClientUserId(attacker) : 0);
	WritePackCell(pack, inflictor);
	WritePackCell(pack, weapon);
	WritePackCell(pack, damagetype);
	RequestFrame(Force_DamageOnDelay, pack);
}

public void Force_DamageOnDelay(DataPack pack)
{
	ResetPack(pack);
	bool IsClient = view_as<bool>(ReadPackCell(pack));
	int victim = ReadPackCell(pack);
	if (IsClient)
		victim = GetClientOfUserId(victim);
	else
		victim = EntRefToEntIndex(victim);
		
	float damage = ReadPackFloat(pack);
	int attacker = ReadPackCell(pack);
	if (attacker != 0)
		attacker = GetClientOfUserId(attacker);
	int inflictor = ReadPackCell(pack);
	int weapon = ReadPackCell(pack);
	int damagetype = ReadPackCell(pack);
	delete pack;
	
	
	if (IsClient && !IsValidMulti(victim))
		return;
	if (!IsValidEntity(victim))
		return;
		
	SDKHooks_TakeDamage(victim, inflictor, attacker, damage, damagetype, weapon);
}

public void RemoveAllInvuln(int client)
{
	TF2_RemoveCondition(client, TFCond_UberBlastResist);
	TF2_RemoveCondition(client, TFCond_UberchargedHidden);
	TF2_RemoveCondition(client, TFCond_Ubercharged);
	TF2_RemoveCondition(client, TFCond_UberchargedCanteen);
	TF2_RemoveCondition(client, TFCond_UberchargedOnTakeDamage);
	TF2_RemoveCondition(client, TFCond_PreventDeath);
	TF2_RemoveCondition(client, TFCond_DodgeChance);
	TF2_RemoveCondition(client, TFCond_ObscuredSmoke);
	SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
}

int i_StuckCheckUser = -1;

stock bool CheckPlayerWouldGetStuck(int client, float scale)
{
	float mins[3] = { -24.5, -24.5, 0.0 }, maxs[3] = { 24.5,  24.5, 83.0}, pos[3];
	
	ScaleVector(mins, scale);
	ScaleVector(maxs, scale);
	
	GetClientAbsOrigin(client, pos);
    
	i_StuckCheckUser = client;
	TR_TraceHullFilter(pos, pos, mins, maxs, MASK_PLAYERSOLID, Trace_StuckCheck);
	return TR_GetEntityIndex() != -1;
}

stock bool CheckPlayerWouldGetStuckAtPos(int client, float scale, float pos[3])
{
	float mins[3] = { -24.5, -24.5, 0.0 }, maxs[3] = { 24.5,  24.5, 83.0};
	
	ScaleVector(mins, scale);
	ScaleVector(maxs, scale);
	
	i_StuckCheckUser = client;
	TR_TraceHullFilter(pos, pos, mins, maxs, MASK_PLAYERSOLID, Trace_StuckCheck);
	return TR_GetEntityIndex() != -1;
}

public bool Trace_StuckCheck(entity, mask) 
{
	if (entity <= MaxClients)
		return !IsValidMulti(entity, true, _, true, TF2_GetClientTeam(i_StuckCheckUser));
		
	char classname[255];
	GetEntityClassname(entity, classname, sizeof(classname));
	
	if (StrContains(classname, "tf_projectile") != -1)
		return false;
		
	return true;
} 

stock Handle GetPluginHandle(char plugin[255])
{
	char buffer[PLATFORM_MAX_PATH];
	Handle iter = GetPluginIterator();
	while (MorePlugins(iter))
	{
		Handle plug = ReadPlugin(iter);
		GetPluginFilename(plug, buffer, sizeof(buffer));
		
		int highest = -1;
		for(int i = strlen(buffer)-1; i > 0; i--)
		{
			if(buffer[i] == '/' || buffer[i] == '\\')
			{
				highest = i;
				break;
			}
		}
		
		ReplaceString(buffer, sizeof(buffer), ".smx", "");
		
		if(StrEqual(buffer[highest+1], plugin))
		{
			delete iter;
			return plug;
		}
	}
	
	delete iter;
	return INVALID_HANDLE;
}

stock void GetPointInDirection(float startPos[3], float ang[3], float distance, float endPos[3])
{
	float buffer[3];
	GetAngleVectors(ang, buffer, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(buffer, distance);
	AddVectors(startPos, buffer, endPos);
}

stock void GetPointFromAngles(float startLoc[3], float angles[3], float distance, float output[3], TraceEntityFilter filter, int traceFlags)
{
	float endLoc[3];
	
	TR_TraceRayFilter(startLoc, angles, traceFlags, RayType_Infinite, filter);
	TR_GetEndPosition(endLoc);
	output = ConstrainDistance(startLoc, endLoc, distance);
}

stock float[] ConstrainDistance(float startPos[3], float endPos[3], float distance)
{	
	if (GetVectorDistance(startPos, endPos, true) >= Pow(distance, 2.0))
	{
		float constraint = distance/GetVectorDistance(startPos, endPos);
		
		for (int i = 0; i < 3; i++)
		{
			endPos[i] = ((endPos[i] - startPos[i]) * constraint) + startPos[i];
		}
	}
	
	return endPos;
}

stock bool IsPayloadCart(int ent)
{
	int observer_of_the_train = FindEntityByClassname(-1, "team_train_watcher");
	if (!IsValidEntity(observer_of_the_train))
		return false;
		
	char the_train[255], the_ent[255];
	GetEntPropString(observer_of_the_train, Prop_Data, "m_iszTrain", the_train, sizeof(the_train));
	GetEntPropString(ent, Prop_Data, "m_iName", the_ent, sizeof(the_ent));
	
	return StrEqual(the_train, the_ent);
}

stock float fmax(float n1, float n2)
{
	return n1 > n2 ? n1 : n2;
}
stock float fmin(float n1, float n2)
{
	return n1 < n2 ? n1 : n2;
}

/**
 * Plays a crit sound effect to a client.
 *
 * @param client		Client to play to.
 *
 */
public void PlayCritSound(int client)
{
	switch(GetRandomInt(1, 5))
	{
		case 1:
		{
			PrecacheSound(CRIT1);
			EmitSoundToClient(client, CRIT1);
		}
		case 2:
		{
			PrecacheSound(CRIT2);
			EmitSoundToClient(client, CRIT2);
		}
		case 3:
		{
			PrecacheSound(CRIT3);
			EmitSoundToClient(client, CRIT3);
		}
		case 4:
		{
			PrecacheSound(CRIT4);
			EmitSoundToClient(client, CRIT4);
		}
		case 5:
		{
			PrecacheSound(CRIT5);
			EmitSoundToClient(client, CRIT5);
		}
	}
}

/**
 * Plays a mini-crit sound effect to a client.
 *
 * @param client		Client to play to.
 *
 */
public void PlayMiniCritSound(int client)
{
	switch(GetRandomInt(1, 5))
	{
		case 1:
		{
			PrecacheSound(MINICRIT1);
			EmitSoundToClient(client, MINICRIT1);
		}
		case 2:
		{
			PrecacheSound(MINICRIT2);
			EmitSoundToClient(client, MINICRIT2);
		}
		case 3:
		{
			PrecacheSound(MINICRIT3);
			EmitSoundToClient(client, MINICRIT3);
		}
		case 4:
		{
			PrecacheSound(MINICRIT4);
			EmitSoundToClient(client, MINICRIT4);
		}
		case 5:
		{
			PrecacheSound(MINICRIT5);
			EmitSoundToClient(client, MINICRIT5);
		}
	}
}

stock void AttachParticle_TE(int entity, char particle[255])
{
	TE_SetupParticleEffect(particle, PATTACH_ABSORIGIN_FOLLOW, entity);
	TE_WriteNum("m_bControlPoint1", entity);	
	TE_SendToAll();
}

stock void RemoveParticle_TE(int entity, char particle[255])
{
	TE_Start("EffectDispatch");
	TE_WriteNum("entindex", entity);
	TE_WriteNum("m_nHitBox", GetParticleEffectIndex(particle));
	TE_WriteNum("m_iEffectName", GetEffectIndex("ParticleEffectStop"));
	TE_SendToAll();
}

stock PrecacheEffect(const String:sEffectName[])
{
	static table = INVALID_STRING_TABLE;
	
	if (table == INVALID_STRING_TABLE)
	{
		table = FindStringTable("EffectDispatch");
	}
	
	new bool:save = LockStringTables(false);
	AddToStringTable(table, sEffectName);
	LockStringTables(save);
}

stock PrecacheParticleEffect(const String:sEffectName[])
{
	static table = INVALID_STRING_TABLE;
	
	if (table == INVALID_STRING_TABLE)
	{
		table = FindStringTable("ParticleEffectNames");
	}
	
	new bool:save = LockStringTables(false);
	AddToStringTable(table, sEffectName);
	LockStringTables(save);
}

stock TE_SetupParticleEffect(const String:sParticleName[], ParticleAttachment_t:iAttachType, entity)//, const Float:fOrigin[3] = NULL_VECTOR, const Float:fAngles[3] = NULL_VECTOR, const Float:fStart[3] = NULL_VECTOR, iAttachmentPoint = -1, bool:bResetAllParticlesOnEntity = false)
{
	TE_Start("EffectDispatch");
	
	TE_WriteNum("m_nHitBox", GetParticleEffectIndex(sParticleName));
	
	new fFlags;
	if(entity > 0)
	{
		new Float:fEntityOrigin[3];
		GetEntPropVector(entity, Prop_Data, "m_vecOrigin", fEntityOrigin);
		TE_WriteFloatArray("m_vOrigin[0]", fEntityOrigin, 3);

		if(iAttachType != PATTACH_WORLDORIGIN)
		{
			TE_WriteNum("entindex", entity);
			fFlags |= PARTICLE_DISPATCH_FROM_ENTITY;
		}
	}
	
	TE_WriteNum("m_fFlags", fFlags);
	TE_WriteNum("m_nDamageType", _:iAttachType);
	TE_WriteNum("m_nAttachmentIndex", -1);
	
	TE_WriteNum("m_iEffectName", GetEffectIndex("ParticleEffect"));
}

stock int GetParticleEffectIndex(const char[] sEffectName)
{
	static int table = INVALID_STRING_TABLE;
	
	if (table == INVALID_STRING_TABLE)
	{
		table = FindStringTable("ParticleEffectNames");
	}
	
	int iIndex = FindStringIndex(table, sEffectName);
	if(iIndex != INVALID_STRING_INDEX)
		return iIndex;
	
	// This is the invalid string index
	return 0;
}

stock int GetEffectIndex(const char[] sEffectName)
{
	static int table = INVALID_STRING_TABLE;
	
	if (table == INVALID_STRING_TABLE)
	{
		table = FindStringTable("EffectDispatch");
	}
	
	int iIndex = FindStringIndex(table, sEffectName);
	if(iIndex != INVALID_STRING_INDEX)
		return iIndex;
	
	// This is the invalid string index
	return 0;
}

/**
 * Spawns a small explosion particle at a given location. This does NOT deal damage.
 *
 * @param DetLoc		Explosion location.
 * @param SFX		Explosion sound.
 *
 * @error		Incomplete explosion origin data.
 */
stock void SpawnSmallExplosion(float DetLoc[3], char SFX[255] = "")
{
	int littleBoom = CreateEntityByName("info_particle_system");
	
	if (IsValidEdict(littleBoom))
	{
		float pos[3];
		pos[0] += DetLoc[0] + GetRandomFloat(-80.0, 80.0);
		pos[1] += DetLoc[1] + GetRandomFloat(-80.0, 80.0);
		pos[2] += DetLoc[2] + GetRandomFloat(0.0, 80.0);
		TeleportEntity(littleBoom, pos, NULL_VECTOR, NULL_VECTOR);
		
		char particleName[255];
		
		switch(GetRandomInt(1, 4))
		{
			case 1:
			{
				particleName = EXPLOSION_PARTICLE_SMALL_1;
			}
			case 2:
			{
				particleName = EXPLOSION_PARTICLE_SMALL_2;
			}
			case 3:
			{
				particleName = EXPLOSION_PARTICLE_SMALL_3;
			}
			case 4:
			{
				particleName = EXPLOSION_PARTICLE_SMALL_4;
			}
		}
		
		DispatchKeyValue(littleBoom, "effect_name", particleName);
		DispatchKeyValue(littleBoom, "targetname", "present");
		DispatchSpawn(littleBoom);
		ActivateEntity(littleBoom);
		AcceptEntityInput(littleBoom, "Start");
		
		CreateTimer(1.2, Timer_RemoveEntity, EntIndexToEntRef(littleBoom), TIMER_FLAG_NO_MAPCHANGE);
		
		if (SFX[0])
		{
			EmitSoundToAll(SFX, littleBoom, _, 120);
		}
	}
}

stock int SpawnPropDynamic(char model[255], float pos[3], float ang[3], int skin = 0, float scale = 1.0, char sequence[255] = "ref", float rate = 1.0)
{
	int prop = CreateEntityByName("prop_dynamic_override");
	
	if (IsValidEntity(prop))
	{
		SetEntityModel(prop, model);
					
		char scalechar[16];
		Format(scalechar, sizeof(scalechar), "%f", scale);
		DispatchKeyValue(prop, "modelscale", scalechar);
		DispatchKeyValue(prop, "StartDisabled", "false");
					
		DispatchSpawn(prop);
					
		AcceptEntityInput(prop, "Enable");
		
		SetVariantString(sequence);
		AcceptEntityInput(prop, "SetAnimation");
		DispatchKeyValueFloat(prop, "playbackrate", rate);
		char skinchar[16];
		Format(skinchar, sizeof(skinchar), "%i", skin);
		DispatchKeyValue(prop, "skin", skinchar);
		
		TeleportEntity(prop, pos, ang, NULL_VECTOR);
	}
	
	return prop;
}

stock void MakeEntityFadeOut(int entity, int rate, bool remove = true)
{
	SetEntityRenderMode(entity, RENDER_TRANSALPHA);
	
	DataPack pack = new DataPack();
	WritePackCell(pack, EntIndexToEntRef(entity));
	WritePackCell(pack, rate);
	WritePackCell(pack, remove);
	RequestFrame(Fade_Out, pack);
}

stock void Fade_Out(DataPack pack)
{
	ResetPack(pack);
	int entity = EntRefToEntIndex(ReadPackCell(pack));
	int rate = ReadPackCell(pack);
	bool remove = ReadPackCell(pack);
	
	if (!IsValidEntity(entity))
	{
		delete pack;
		return;
	}
	
	int r, g, b, a;
	GetEntityRenderColor(entity, r, g, b, a);
	a -= rate;
	if (a < 0)
		a = 0;
		
	SetEntityRenderColor(entity, r, g, b, a);
	
	if (a == 0)
	{
		if (remove)
			RemoveEntity(entity);
		
		delete pack;
	}
	else
		RequestFrame(Fade_Out, pack);
}

//These two beam stocks were borrowed from Zombie Riot and then modified.
stock int SpawnNewBeam(char model[255], int r, int g, int b, int a, float width, float pos[3], int owner = 0) 
{
	int beam = CreateEntityByName("env_beam");
	if (IsValidEntity(beam))
	{
		SetEntityModel(beam, model);
		SetEntityRenderColor(beam, r, g, b, a);
		
		SetEntProp(beam, Prop_Send, "m_nBeamType", 2);
		SetEntPropFloat(beam, Prop_Data, "m_fWidth", width);
		SetEntPropFloat(beam, Prop_Data, "m_fEndWidth", width);

		SetEntPropEnt(beam, Prop_Data, "m_hOwnerEntity", owner);

		DispatchSpawn(beam);
		ActivateEntity(beam);
		
		TeleportEntity(beam, pos);
	}
	
	return beam;
}

stock void ConnectBeam(int beam, int target) 
{
	if (!IsValidEntity(beam) || !IsValidEntity(target))
		return;

	SetEntPropEnt(beam, Prop_Send, "m_hAttachEntity", EntIndexToEntRef(beam));
	SetEntPropEnt(beam, Prop_Send, "m_hAttachEntity", EntIndexToEntRef(target), 1);
	SetEntProp(beam, Prop_Send, "m_nNumBeamEnts", 2);

	AcceptEntityInput(beam, "TurnOn");
}

/**
 * Spawns a big explosion particle at a given location. This does NOT deal damage.
 *
 * @param DetLoc		Explosion location.
 * @param SFX		Explosion sound.
 *
 * @error		Incomplete explosion origin data.
 */
stock void SpawnBigExplosion(float DetLoc[3], char SFX[255] = "")
{
	int littleBoom = CreateEntityByName("info_particle_system");
	
	if (IsValidEdict(littleBoom))
	{
		float pos[3];
		pos[0] += DetLoc[0] + GetRandomFloat(-80.0, 80.0);
		pos[1] += DetLoc[1] + GetRandomFloat(-80.0, 80.0);
		pos[2] += DetLoc[2] + GetRandomFloat(0.0, 80.0);
		TeleportEntity(littleBoom, pos, NULL_VECTOR, NULL_VECTOR);
		
		char particleName[255];
		
		switch(GetRandomInt(1, 4))
		{
			case 1:
			{
				particleName = EXPLOSION_PARTICLE_LARGE_1;
			}
			case 2:
			{
				particleName = EXPLOSION_PARTICLE_LARGE_2;
			}
		}
		
		DispatchKeyValue(littleBoom, "effect_name", particleName);
		DispatchKeyValue(littleBoom, "targetname", "present");
		DispatchSpawn(littleBoom);
		ActivateEntity(littleBoom);
		AcceptEntityInput(littleBoom, "Start");
		
		CreateTimer(4.0, Timer_RemoveEntity, EntIndexToEntRef(littleBoom), TIMER_FLAG_NO_MAPCHANGE);
		
		if (SFX[0])
		{
			EmitSoundToAll(SFX, littleBoom, _, 120);
		}
	}
}

stock void SpawnSpriteExplosion(float pos[3], int sound = 0)
{
	DataPack pack_boom = new DataPack();
	pack_boom.WriteFloat(pos[0]);
	pack_boom.WriteFloat(pos[1]);
	pack_boom.WriteFloat(pos[2]);
	pack_boom.WriteCell(sound);
	RequestFrame(Stock_MakeExplosionFrameLater, pack_boom);
}

//Thank you CookieCat!
stock void ScaleHitboxSize(int entity, float multiplier)
{
	float mins[3], maxs[3];
	GetEntPropVector(entity, Prop_Send, "m_vecMins", mins);
	GetEntPropVector(entity, Prop_Send, "m_vecMaxs", maxs);
	ScaleVector(mins, multiplier);
	ScaleVector(maxs, multiplier);
	
	SetHitboxSize(entity, mins, maxs);
}

stock void SetHitboxSize(int entity, const float mins[3], const float maxs[3])
{
	SetEntPropVector(entity, Prop_Send, "m_vecMins", mins);
	SetEntPropVector(entity, Prop_Send, "m_vecMaxs", maxs);
	SetEntPropVector(entity, Prop_Send, "m_vecMinsPreScaled", mins);
	SetEntPropVector(entity, Prop_Send, "m_vecMaxsPreScaled", maxs);
	SetEntPropVector(entity, Prop_Send, "m_vecSpecifiedSurroundingMins", mins);
	SetEntPropVector(entity, Prop_Send, "m_vecSpecifiedSurroundingMaxs", maxs);
	SetEntPropVector(entity, Prop_Send, "m_vecSpecifiedSurroundingMinsPreScaled", mins);
	SetEntPropVector(entity, Prop_Send, "m_vecSpecifiedSurroundingMaxsPreScaled", maxs);
}

stock int SpawnPhysicsProp(char model[255], int owner, char skin[16], float health, bool invincible, float scale, float pos[3], float ang[3], float vel[3], float lifespan = 0.0)
{
	int prop = CreateEntityByName("prop_physics_multiplayer");
	if (IsValidEntity(prop))
	{
		DispatchKeyValue(prop, "targetname", "phys"); 
		PrecacheModel(model);
		DispatchKeyValue(prop, "model", model);
		
		DispatchSpawn(prop);
		
		ActivateEntity(prop);
		
		if (IsValidClient(owner))
		{
			SetEntPropEnt(prop, Prop_Data, "m_hOwnerEntity", owner);
			SetEntProp(prop, Prop_Send, "m_iTeamNum", GetClientTeam(owner));
		}
		
		DispatchKeyValue(prop, "skin", skin);
		
		if (invincible)
		{
			SetEntProp(prop, Prop_Data, "m_takedamage", 0, 1);
		}
		else
		{
			char healthChar[16];
			Format(healthChar, sizeof(healthChar), "%i", RoundFloat(health));
			DispatchKeyValue(prop, "Health", healthChar);
			SetEntityHealth(prop, RoundFloat(health));
		}
		
		char scalechar[16];
		Format(scalechar, sizeof(scalechar), "%f", scale);
		DispatchKeyValue(prop, "modelscale", scalechar);
		
		if (lifespan > 0.0)
		{
			CreateTimer(lifespan, Timer_RemoveEntity, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE);
		}
		
		TeleportEntity(prop, pos, ang, vel);
	}
	
	return prop;
}

public void Stock_MakeExplosionFrameLater(DataPack pack)
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
			PrecacheSound("ambient/explosions/explode_3.wav");
			EmitAmbientSound("ambient/explosions/explode_3.wav", vec_pos);
		}
		
		DispatchKeyValueVector(ent, "origin", vec_pos);
		DispatchKeyValue(ent, "spawnflags", "64");
						
		DispatchKeyValue(ent, "rendermode", "5");
		DispatchKeyValue(ent, "fireballsprite", "spirites/zerogxplode.spr");
										
		DispatchKeyValueFloat(ent, "DamageForce", 0.0);								
		SetEntProp(ent, Prop_Data, "m_iMagnitude", 0); 
		SetEntProp(ent, Prop_Data, "m_iRadiusOverride", 0); 
									
		DispatchSpawn(ent);
		ActivateEntity(ent);
									
		AcceptEntityInput(ent, "explode");
		AcceptEntityInput(ent, "kill");
	}		
	delete pack;
}

stock bool TF2_IsPlayerStunned(int client)
{
	return (TF2_IsPlayerInCondition(client, TFCond_Dazed)
	|| TF2_IsPlayerInCondition(client, TFCond_FreezeInput) || TF2_IsPlayerInCondition(client, TFCond_Taunting));
}

//EVERYTHING below this is borrowed from Dynamic Defaults by Sarysa, then modified for Chaos Fortress.
//All credit for the following code goes to him, the CF_Teleport natives would not be possible otherwise. 

#define MAX_PLAYERS_ARRAY 36
#define MAX_PLAYERS (MAX_PLAYERS_ARRAY < (MaxClients + 1) ? MAX_PLAYERS_ARRAY : (MaxClients + 1))
#define MAX_ENTITY_CLASSNAME_LENGTH 48

int DPT_Player;
stock bool DPT_TracePlayersAndBuildings(entity, contentsMask)
{
	if (IsValidMulti(entity) && GetClientTeam(entity) != GetClientTeam(DPT_Player))
		return true;
	else if (IsValidMulti(entity))
		return false;
		
	return IsValidEntity(entity);
}

stock bool DPT_TraceWallsOnly(entity, contentsMask)
{
	return false;
}
 
stock bool DPT_TryTeleport(int client, float range, bool directional, float output[3], bool IgnoreSafety = false, float override[3] = NULL_VECTOR, bool UseOverride = false)
{
	float sizeMultiplier = GetEntPropFloat(client, Prop_Send, "m_flModelScale");
	static float startPos[3];
	static float endPos[3];
	static float testPos[3];
	static float eyeAngles[3];
	GetClientEyePosition(client, startPos);
	GetClientEyeAngles(client, eyeAngles);
	
	if (directional && !UseOverride)
	{
		bool GoingLeft = GetClientButtons(client) & IN_MOVELEFT != 0;
		bool GoingRight = GetClientButtons(client) & IN_MOVERIGHT != 0;
		bool GoingBack = GetClientButtons(client) & IN_BACK != 0;
		
		int pitch = 0;
		int yaw = 1;
		
		if (GoingLeft && !GoingRight && !GoingBack)
		{
			eyeAngles[yaw] += 90.0;
		}
	
		if (GoingRight && !GoingLeft && !GoingBack)
		{
			eyeAngles[yaw] += -90.0;
		}
		
		if (GoingBack && !GoingLeft && !GoingRight)
		{
			eyeAngles[pitch] += 180.0;
		}
	}
	
	DPT_Player = client;
	
	if (!UseOverride)
	{
		TR_TraceRayFilter(startPos, eyeAngles, MASK_PLAYERSOLID, RayType_Infinite, DPT_TracePlayersAndBuildings);
		TR_GetEndPosition(endPos);
		
		// don't even try if the distance is less than 82
		float distance = GetVectorDistance(startPos, endPos);
		if (distance < 82.0)
		{
			return false;
		}
			
		if (distance > range)
			constrainDistance(startPos, endPos, distance, range);
		else // shave just a tiny bit off the end position so our point isn't directly on top of a wall
			constrainDistance(startPos, endPos, distance, distance - 1.0);
	}
	else
	{
		endPos = override;
	}
	
	// now for the tests. I go 1 extra on the standard mins/maxs on purpose.
	bool found = false;
	for (int x = 0; x < 3; x++)
	{
		if (found)
			break;
	
		float xOffset;
		if (x == 0)
			xOffset = 0.0;
		else if (x == 1)
			xOffset = 12.5 * sizeMultiplier;
		else
			xOffset = 25.0 * sizeMultiplier;
		
		if (endPos[0] < startPos[0])
			testPos[0] = endPos[0] + xOffset;
		else if (endPos[0] > startPos[0])
			testPos[0] = endPos[0] - xOffset;
		else if (xOffset != 0.0)
			break; // super rare but not impossible, no sense wasting on unnecessary tests
	
		for (int y = 0; y < 3; y++)
		{
			if (found)
				break;

			float yOffset;
			if (y == 0)
				yOffset = 0.0;
			else if (y == 1)
				yOffset = 12.5 * sizeMultiplier;
			else
				yOffset = 25.0 * sizeMultiplier;

			if (endPos[1] < startPos[1])
				testPos[1] = endPos[1] + yOffset;
			else if (endPos[1] > startPos[1])
				testPos[1] = endPos[1] - yOffset;
			else if (yOffset != 0.0)
				break; // super rare but not impossible, no sense wasting on unnecessary tests
		
			for (int z = 0; z < 3; z++)
			{
				if (found)
					break;

				float zOffset;
				if (z == 0)
					zOffset = 0.0;
				else if (z == 1)
					zOffset = 41.5 * sizeMultiplier;
				else
					zOffset = 83.0 * sizeMultiplier;

				if (endPos[2] < startPos[2])
					testPos[2] = endPos[2] + zOffset;
				else if (endPos[2] > startPos[2])
					testPos[2] = endPos[2] - zOffset;
				else if (zOffset != 0.0)
					break; // super rare but not impossible, no sense wasting on unnecessary tests

				// before we test this position, ensure it has line of sight from the point our player looked from
				// this ensures the player can't teleport through walls
				if (!UseOverride)
				{
					static float tmpPos[3];
					TR_TraceRayFilter(endPos, testPos, MASK_PLAYERSOLID, RayType_EndPoint, DPT_TraceWallsOnly);
					TR_GetEndPosition(tmpPos);
					if (testPos[0] != tmpPos[0] || testPos[1] != tmpPos[1] || testPos[2] != tmpPos[2])
						continue;
				}
					
				found = IsSpotSafe(client, testPos, sizeMultiplier);
			}
		}
	}
	
	if (!found && !IgnoreSafety)
	{
		return false;
	}
		
	output = testPos;
	return true;
}

stock constrainDistance(const float startPoint[3], float endPoint[3], float distance, float maxDistance)
{
	float constrainFactor = maxDistance / distance;
	endPoint[0] = ((endPoint[0] - startPoint[0]) * constrainFactor) + startPoint[0];
	endPoint[1] = ((endPoint[1] - startPoint[1]) * constrainFactor) + startPoint[1];
	endPoint[2] = ((endPoint[2] - startPoint[2]) * constrainFactor) + startPoint[2];
}

bool ResizeTraceFailed;
int ResizeMyTeam;

stock bool IsSpotSafe(client, float playerPos[3], float sizeMultiplier)
{
	ResizeTraceFailed = false;
	ResizeMyTeam = GetClientTeam(client);
	static float mins[3];
	static float maxs[3];
	mins[0] = -24.0 * sizeMultiplier;
	mins[1] = -24.0 * sizeMultiplier;
	mins[2] = 0.0;
	maxs[0] = 24.0 * sizeMultiplier;
	maxs[1] = 24.0 * sizeMultiplier;
	maxs[2] = 82.0 * sizeMultiplier;

	// the eight 45 degree angles and center, which only checks the z offset
	if (!Resize_TestResizeOffset(playerPos, mins[0], mins[1], maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, mins[0], 0.0, maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, mins[0], maxs[1], maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, 0.0, mins[1], maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, 0.0, 0.0, maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, 0.0, maxs[1], maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, maxs[0], mins[1], maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, maxs[0], 0.0, maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, maxs[0], maxs[1], maxs[2])) return false;

	// 22.5 angles as well, for paranoia sake
	if (!Resize_TestResizeOffset(playerPos, mins[0], mins[1] * 0.5, maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, mins[0], maxs[1] * 0.5, maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, maxs[0], mins[1] * 0.5, maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, maxs[0], maxs[1] * 0.5, maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, mins[0] * 0.5, mins[1], maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, maxs[0] * 0.5, mins[1], maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, mins[0] * 0.5, maxs[1], maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, maxs[0] * 0.5, maxs[1], maxs[2])) return false;

	// four square tests
	if (!Resize_TestSquare(playerPos, mins[0], maxs[0], mins[1], maxs[1], maxs[2])) return false;
	if (!Resize_TestSquare(playerPos, mins[0] * 0.75, maxs[0] * 0.75, mins[1] * 0.75, maxs[1] * 0.75, maxs[2])) return false;
	if (!Resize_TestSquare(playerPos, mins[0] * 0.5, maxs[0] * 0.5, mins[1] * 0.5, maxs[1] * 0.5, maxs[2])) return false;
	if (!Resize_TestSquare(playerPos, mins[0] * 0.25, maxs[0] * 0.25, mins[1] * 0.25, maxs[1] * 0.25, maxs[2])) return false;
	
	return true;
}

stock bool Resize_TracePlayersAndBuildings(entity, contentsMask)
{
	if (IsValidMulti(entity))
	{
		if (GetClientTeam(entity) != ResizeMyTeam)
		{
			ResizeTraceFailed = true;
		}
	}
	else if (IsValidEntity(entity))
	{
		static char classname[MAX_ENTITY_CLASSNAME_LENGTH];
		GetEntityClassname(entity, classname, sizeof(classname));
		if ((strcmp(classname, "obj_sentrygun") == 0) || (strcmp(classname, "obj_dispenser") == 0) || (strcmp(classname, "obj_teleporter") == 0)
			|| (strcmp(classname, "prop_dynamic") == 0) || (strcmp(classname, "func_physbox") == 0) || (strcmp(classname, "func_breakable") == 0) || (strcmp(classname, "func_door") == 0) || (strcmp(classname, "func_detail") == 0) || (strcmp(classname, "func_moving") == 0) || (strcmp(classname, "func_movelinear") == 0) || (strcmp(classname, "prop_static") == 0) || (strcmp(classname, "prop_physics") == 0))
		{
			ResizeTraceFailed = true;
		}
	}

	return false;
}

stock bool Resize_OneTrace(const float startPos[3], const float endPos[3])
{
	static float result[3];
	TR_TraceRayFilter(startPos, endPos, MASK_PLAYERSOLID, RayType_EndPoint, Resize_TracePlayersAndBuildings);
	if (ResizeTraceFailed)
	{
		return false;
	}
	TR_GetEndPosition(result);
	if (endPos[0] != result[0] || endPos[1] != result[1] || endPos[2] != result[2])
	{
		return false;
	}
	
	return true;
}

// the purpose of this method is to first trace outward, upward, and then back in.
stock bool Resize_TestResizeOffset(const float bossOrigin[3], float xOffset, float yOffset, float zOffset)
{
	static float tmpOrigin[3];
	tmpOrigin[0] = bossOrigin[0];
	tmpOrigin[1] = bossOrigin[1];
	tmpOrigin[2] = bossOrigin[2];
	static float targetOrigin[3];
	targetOrigin[0] = bossOrigin[0] + xOffset;
	targetOrigin[1] = bossOrigin[1] + yOffset;
	targetOrigin[2] = bossOrigin[2];
	
	if (!(xOffset == 0.0 && yOffset == 0.0))
		if (!Resize_OneTrace(tmpOrigin, targetOrigin))
			return false;
		
	tmpOrigin[0] = targetOrigin[0];
	tmpOrigin[1] = targetOrigin[1];
	tmpOrigin[2] = targetOrigin[2] + zOffset;

	if (!Resize_OneTrace(targetOrigin, tmpOrigin))
		return false;
		
	targetOrigin[0] = bossOrigin[0];
	targetOrigin[1] = bossOrigin[1];
	targetOrigin[2] = bossOrigin[2] + zOffset;
		
	if (!(xOffset == 0.0 && yOffset == 0.0))
		if (!Resize_OneTrace(tmpOrigin, targetOrigin))
			return false;
		
	return true;
}

stock bool Resize_TestSquare(const float bossOrigin[3], float xmin, float xmax, float ymin, float ymax, float zOffset)
{
	static float pointA[3];
	static float pointB[3];
	for (int phase = 0; phase <= 7; phase++)
	{
		// going counterclockwise
		if (phase == 0)
		{
			pointA[0] = bossOrigin[0] + 0.0;
			pointA[1] = bossOrigin[1] + ymax;
			pointB[0] = bossOrigin[0] + xmax;
			pointB[1] = bossOrigin[1] + ymax;
		}
		else if (phase == 1)
		{
			pointA[0] = bossOrigin[0] + xmax;
			pointA[1] = bossOrigin[1] + ymax;
			pointB[0] = bossOrigin[0] + xmax;
			pointB[1] = bossOrigin[1] + 0.0;
		}
		else if (phase == 2)
		{
			pointA[0] = bossOrigin[0] + xmax;
			pointA[1] = bossOrigin[1] + 0.0;
			pointB[0] = bossOrigin[0] + xmax;
			pointB[1] = bossOrigin[1] + ymin;
		}
		else if (phase == 3)
		{
			pointA[0] = bossOrigin[0] + xmax;
			pointA[1] = bossOrigin[1] + ymin;
			pointB[0] = bossOrigin[0] + 0.0;
			pointB[1] = bossOrigin[1] + ymin;
		}
		else if (phase == 4)
		{
			pointA[0] = bossOrigin[0] + 0.0;
			pointA[1] = bossOrigin[1] + ymin;
			pointB[0] = bossOrigin[0] + xmin;
			pointB[1] = bossOrigin[1] + ymin;
		}
		else if (phase == 5)
		{
			pointA[0] = bossOrigin[0] + xmin;
			pointA[1] = bossOrigin[1] + ymin;
			pointB[0] = bossOrigin[0] + xmin;
			pointB[1] = bossOrigin[1] + 0.0;
		}
		else if (phase == 6)
		{
			pointA[0] = bossOrigin[0] + xmin;
			pointA[1] = bossOrigin[1] + 0.0;
			pointB[0] = bossOrigin[0] + xmin;
			pointB[1] = bossOrigin[1] + ymax;
		}
		else if (phase == 7)
		{
			pointA[0] = bossOrigin[0] + xmin;
			pointA[1] = bossOrigin[1] + ymax;
			pointB[0] = bossOrigin[0] + 0.0;
			pointB[1] = bossOrigin[1] + ymax;
		}

		for (int shouldZ = 0; shouldZ <= 1; shouldZ++)
		{
			pointA[2] = pointB[2] = shouldZ == 0 ? bossOrigin[2] : (bossOrigin[2] + zOffset);
			if (!Resize_OneTrace(pointA, pointB))
				return false;
		}
	}
		
	return true;
}

//Mother of God this stock name is horrendous. This returns whether or not the entity is a tf_projectile that does NOT explode on impact.
//It filters out spells, jars, cleavers, and rockets. Every other tf_projectile returns true.
//Also returns the entity's classname stored in the given classname buffer for ease-of-use.
stock bool TF2_IsDamageProjectileWithoutImpactExplosion(int entity, char classname[255])
{
	if (!IsValidEntity(entity))
		return false;
		
	GetEntityClassname(entity, classname, sizeof(classname));
	
	return (StrContains(classname, "tf_projectile") != -1 && StrContains(classname, "spell") == -1 && 
	StrContains(classname, "jar") == -1 && StrContains(classname, "rocket") == -1 && StrContains(classname, "cleaver") == -1
	&& StrContains(classname, "energy_ring") == -1);
}

//Returns true if the entity is capable of taking damage (prop_physics, base_boss, living player, buildings).
stock bool Entity_Can_Be_Shot(int entity)
{
	if (!IsValidEntity(entity))
		return false;
		
	if (IsValidClient(entity))
		return IsPlayerAlive(entity);
		
	char classname[255];
	GetEntityClassname(entity, classname, sizeof(classname));
	
	return (StrContains(classname, "prop_physics") != -1) || (StrContains(classname, "base_boss") != -1) || (StrContains(classname, "obj_sentry") != -1)
	|| (StrContains(classname, "obj_dispenser") != -1) || (StrContains(classname, "obj_teleporter") != -1) || (StrContains(classname, "npc") != -1);
}

//Returns true if the entity is a solid brush. Primarily just filters out "info_" and "trigger_" entities, as well as MOST "func_" entities.
//Returns true by default for entities that are not brushes.
stock bool Brush_Is_Solid(int entity)
{
	char entname[255];
	GetEntityClassname(entity, entname, sizeof(entname));
	
	if (StrContains(entname, "info_") != -1 || StrContains(entname, "trigger_") != -1)
	{
		return false;
	}
	
	if (StrContains(entname, "func_") != -1)
	{
		if (!StrEqual("func_brush", entname)
			&& !StrEqual("func_door", entname) && !StrEqual("func_detail", entname) && !StrEqual("func_wall", entname) && !StrEqual("func_rotating", entname)
			&& !StrEqual("func_reflective_glass", entname) && !StrEqual("func_physbox", entname) && !StrEqual("func_movelinear", entname) && !StrEqual("func_door_rotating", entname)
			&& !StrEqual("func_breakable", entname))
		{
			return false;
		}
	}

	return ((GetEntProp(entity, Prop_Send, "m_nSolidType") != 0) && ((GetEntProp(entity, Prop_Send, "m_usSolidFlags") & 4) == 0));
}

stock ArrayList SortListByDistance(float pos[3], ArrayList list)
{
	if (GetArraySize(list) > 0)
	{
		ArrayList ordered = new ArrayList(255);

		while (GetArraySize(list) > 0)
		{
			PushArrayCell(ordered, Sort_GetClosestInList(pos, list));
		}

		return ordered;
	}

	return list;
}

stock int Sort_GetClosestInList(float pos[3], ArrayList &list)
{
	int closestSlot = 0;
	int closestEntity = 0;
	float closestDist = 99999999.0;

	for (int i = 0; i < GetArraySize(list); i++)
	{
		int ent = GetArrayCell(list, i);
		float entPos[3];
		CF_WorldSpaceCenter(ent, entPos);

		float dist = GetVectorDistance(pos, entPos);
		if (dist < closestDist)
		{
			closestEntity = ent;
			closestDist = dist;
			closestSlot = i;
		}
	}

	RemoveFromArray(list, closestSlot);

	return closestEntity;
}

stock bool IsAlly(int me, int them)
{
	if (!HasEntProp(them, Prop_Send, "m_iTeamNum"))
		return false;

	return (GetEntProp(me, Prop_Send, "m_iTeamNum") == GetEntProp(them, Prop_Send, "m_iTeamNum"));
}

stock bool Vector_Is_Null(float vec[3])
{
	for (int i = 0; i < 3; i++)
	{
		if (vec[i] != 0.0)
			return false;
	}

	return true;
}

stock void PreventAllCollisions(int entity)
{
	SetEntityCollisionGroup(entity, 1); //Dont Touch Anything.
	SetEntProp(entity, Prop_Send, "m_usSolidFlags", 12); 
	SetEntProp(entity, Prop_Data, "m_nSolidType", 6);
}

bool HazardResult;
stock bool IsPointHazard(const float pos1[3])
{
	HazardResult = false;
	TR_EnumerateEntities(pos1, pos1, PARTITION_TRIGGER_EDICTS, RayType_EndPoint, TraceEntityEnumerator_EnumerateTriggers);
	return HazardResult;
}

public bool TraceEntityEnumerator_EnumerateTriggers(int entity, int client)
{
	char classname[16];
	if(GetEntityClassname(entity, classname, sizeof(classname)) && !StrContains(classname, "trigger_hurt"))
	{
		if(!GetEntProp(entity, Prop_Data, "m_bDisabled"))
		{
			Handle trace = TR_ClipCurrentRayToEntityEx(MASK_ALL, entity);
			bool didHit = TR_DidHit(trace);
			delete trace;
			
			if (didHit)
			{
				HazardResult = true;
				return false;
			}
		}
	}
	
	return true;
}

stock bool IsABuilding(int entity)
{
	if (!IsValidEntity(entity))
		return false;

	char classname[255];
	GetEntityClassname(entity, classname, sizeof(classname));

	return StrEqual(classname, "obj_sentrygun") || StrEqual(classname, "obj_dispenser") || StrEqual(classname, "obj_teleporter");
}

stock void DHook_CreateDetour(GameData gamedata, const char[] name, DHookCallback preCallback = INVALID_FUNCTION, DHookCallback postCallback = INVALID_FUNCTION)
{
	DynamicDetour detour = DynamicDetour.FromConf(gamedata, name);
	if(detour)
	{
		if(preCallback!=INVALID_FUNCTION && !DHookEnableDetour(detour, false, preCallback))
			LogError("[Gamedata] Failed to enable pre detour: %s", name);

		if(postCallback!=INVALID_FUNCTION && !DHookEnableDetour(detour, true, postCallback))
			LogError("[Gamedata] Failed to enable post detour: %s", name);

		delete detour;
	}
	else
	{
		LogError("[Gamedata] Could not find %s", name);
	}
}

stock Handle CheckedDHookCreateFromConf(Handle game_config, const char[] name) {
    Handle res = DHookCreateFromConf(game_config, name);

    if (res == INVALID_HANDLE) {
        SetFailState("Failed to create detour for %s", name);
    }

    return res;
}

stock float AddToBucket(float &currentValue, float amtToAdd, float overflowPoint)
{
	currentValue += amtToAdd;

	if (currentValue > overflowPoint)
	{
		float timesOver = float(RoundToFloor(currentValue / overflowPoint));
		float excess = timesOver * overflowPoint;
		currentValue -= excess;
		return excess;
	}

	return 0.0;
}