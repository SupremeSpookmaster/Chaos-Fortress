#define NPC_NAME	"cf_base_npc"

Function CFNPC_Logic[2049] = { INVALID_FUNCTION, ... };
Handle CFNPC_LogicPlugin[2049] = { null, ... };

float CFNPC_Speed[2049] = { 0.0, ... };
float CFNPC_ThinkRate[2049] = { 0.0, ... };
float CFNPC_NextThinkTime[2049] = { 0.0, ... };
float CFNPC_EndTime[2049] = { 0.0, ... };

char CFNPC_Model[2049][255];

GlobalForward g_OnCFNPCCreated;
GlobalForward g_OnCFNPCDestroyed;

void CFNPC_MakeForwards()
{
	g_OnCFNPCCreated = new GlobalForward("CF_OnCFNPCCreated", ET_Ignore, Param_Cell);
	g_OnCFNPCDestroyed = new GlobalForward("CF_OnCFNPCDestroyed", ET_Ignore, Param_Cell);

	CEntityFactory CFNPC_Factory = new CEntityFactory(NPC_NAME, CFNPC_OnCreate, CFNPC_OnDestroy);
	CFNPC_Factory.DeriveFromNPC();
	CFNPC_Factory.Install();
}

void CFNPC_MakeNatives()
{
	//Constructors:
	CreateNative("CFNPC.CFNPC", Native_CFNPCConstructor);

	//Index:
	CreateNative("CFNPC.Index.get", Native_CFNPCGetIndex);

	//Logic and LogicPlugin:
	CreateNative("CFNPC.g_Logic.set", Native_CFNPCSetLogic);
	CreateNative("CFNPC.g_LogicPlugin.get", Native_CFNPCGetLogicPlugin);
	CreateNative("CFNPC.g_LogicPlugin.set", Native_CFNPCSetLogicPlugin);

	//Team:
	CreateNative("CFNPC.i_Team.set", Native_CFNPCSetTeam);
	CreateNative("CFNPC.i_Team.get", Native_CFNPCGetTeam);

	//Skin:
	CreateNative("CFNPC.i_Skin.set", Native_CFNPCSetSkin);
	CreateNative("CFNPC.i_Skin.get", Native_CFNPCGetSkin);

	//Scale:
	CreateNative("CFNPC.f_Scale.set", Native_CFNPCSetScale);
	CreateNative("CFNPC.f_Scale.get", Native_CFNPCGetScale);

	//Speed:
	CreateNative("CFNPC.f_Speed.set", Native_CFNPCSetSpeed);
	CreateNative("CFNPC.f_Speed.get", Native_CFNPCGetSpeed);

	//Think Rate and Next Think Time:
	CreateNative("CFNPC.f_ThinkRate.set", Native_CFNPCSetThinkRate);
	CreateNative("CFNPC.f_ThinkRate.get", Native_CFNPCGetThinkRate);
	CreateNative("CFNPC.f_NextThinkTime.set", Native_CFNPCSetNextThinkTime);
	CreateNative("CFNPC.f_NextThinkTime.get", Native_CFNPCGetNextThinkTime);

	//End Time:
	CreateNative("CFNPC.f_EndTime.set", Native_CFNPCSetEndTime);
	CreateNative("CFNPC.f_EndTime.get", Native_CFNPCGetEndTime);

	//Model:
	CreateNative("CFNPC.SetModel", Native_CFNPCSetModel);
	CreateNative("CFNPC.GetModel", Native_CFNPCGetModel);

	//Health and Max Health:
	CreateNative("CFNPC.i_Health.set", Native_CFNPCSetHealth);
	CreateNative("CFNPC.i_Health.get", Native_CFNPCGetHealth);
	CreateNative("CFNPC.i_MaxHealth.set", Native_CFNPCSetMaxHealth);
	CreateNative("CFNPC.i_MaxHealth.get", Native_CFNPCGetMaxHealth);
}

void CFNPC_OnCreate(int npc)
{
	Call_StartForward(g_OnCFNPCCreated);
	Call_PushCell(npc);
	Call_Finish();
}

void CFNPC_OnDestroy(int npc)
{
	Call_StartForward(g_OnCFNPCDestroyed);
	Call_PushCell(npc);
	Call_Finish();

	SDKUnhook(npc, SDKHook_OnTakeDamagePost, CFNPC_PostDamage);
}

public int Native_CFNPCConstructor(Handle plugin, int numParams)
{
	char model[255], logicPlugin[255];
	float pos[3], ang[3];

	GetNativeString(1, model, sizeof(model));
	TFTeam team = GetNativeCell(2);
	int health = GetNativeCell(3);
	int maxHealth = GetNativeCell(4);
	int skin = GetNativeCell(5);
	float scale = GetNativeCell(6);
	float speed = GetNativeCell(7);
	Function logic = GetNativeFunction(8);
	GetNativeString(9, logicPlugin, sizeof(logicPlugin));
	float thinkRate = GetNativeCell(10);
	GetNativeArray(11, pos, sizeof(pos));
	GetNativeArray(12, ang, sizeof(ang));
	float lifespan = GetNativeCell(13);

	int ent = CreateEntityByName(NPC_NAME);
	if (IsValidEntity(ent))
	{
		CFNPC npc = view_as<CFNPC>(ent);

		npc.g_Logic = logic;
		npc.g_LogicPlugin = GetPluginHandle(logicPlugin);
		npc.i_Team = team;
		npc.i_Health = health;
		npc.i_MaxHealth = maxHealth;
		npc.SetModel(model);
		npc.i_Skin = skin;
		npc.f_Scale = scale;
		npc.f_Speed = speed;
		npc.f_ThinkRate = thinkRate;
		if (lifespan > 0.0)
			npc.f_EndTime = GetGameTime() + lifespan;
		else
			npc.f_EndTime = 0.0;

		DispatchSpawn(ent);
		ActivateEntity(ent);

		SetEntProp(ent, Prop_Send, "m_bGlowEnabled", false);
		SetEntProp(ent, Prop_Data, "m_bSequenceLoops", true);
		SetEntProp(ent, Prop_Data, "m_bloodColor", -1);

		TeleportEntity(ent, pos, ang);

		RequestFrame(CFNPC_InternalLogic, EntIndexToEntRef(ent));

		SDKHook(ent, SDKHook_OnTakeDamagePost, CFNPC_PostDamage);

		return ent;
	}

	return -1;
}

public void CFNPC_PostDamage(int victim, int attacker, int inflictor, float damage, int damagetype, int weapon, const float damageForce[3], const float damagePosition[3])
{
	Event event = CreateEvent("npc_hurt");
	if(event != null) 
	{
		event.SetInt("entindex", victim);
		event.SetInt("health", view_as<CFNPC>(victim).i_Health);
		event.SetInt("damageamount", RoundToFloor(damage));
		event.SetBool("crit", (damagetype & DMG_ACID) == DMG_ACID);

		if(IsValidClient(attacker))
		{
			event.SetInt("attacker_player", GetClientUserId(attacker));
			event.SetInt("weaponid", 0);
		}

		event.Fire();
	}

	if (view_as<CFNPC>(victim).i_Health < 1)
	{
		RemoveEntity(victim);
	}
}

public void CFNPC_InternalLogic(int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (!IsValidEntity(ent))
		return;

	CFNPC npc = view_as<CFNPC>(ent);

	float gt = GetGameTime();
	if (CFNPC_Logic[ent] != INVALID_FUNCTION && npc.g_LogicPlugin != null && gt >= npc.f_NextThinkTime)
	{
		Call_StartFunction(npc.g_LogicPlugin, CFNPC_Logic[ent]);
		Call_PushCell(npc.Index);
		Call_Finish();

		npc.f_NextThinkTime = gt + npc.f_ThinkRate;
	}

	if (gt >= npc.f_EndTime && npc.f_EndTime > 0.0)
	{
		RemoveEntity(ent);
		return;
	}

	RequestFrame(CFNPC_InternalLogic, ref);
}

public int Native_CFNPCGetIndex(Handle plugin, int numParams) { return GetNativeCell(1); }

public int Native_CFNPCSetLogic(Handle plugin, int numParams) 
{ 
	CFNPC_Logic[GetNativeCell(1)] = GetNativeFunction(2); 
	return 0; 
}

public any Native_CFNPCGetLogicPlugin(Handle plugin, int numParams) { return CFNPC_LogicPlugin[GetNativeCell(1)]; }
public int Native_CFNPCSetLogicPlugin(Handle plugin, int numParams) 
{ 
	CFNPC_LogicPlugin[GetNativeCell(1)] = GetNativeCell(2); 
	return 0; 
}

public any Native_CFNPCGetTeam(Handle plugin, int numParams) { return view_as<TFTeam>(GetEntProp(GetNativeCell(1), Prop_Send, "m_iTeamNum")); }
public int Native_CFNPCSetTeam(Handle plugin, int numParams) 
{
	int ent = GetNativeCell(1);
	int team = GetNativeCell(2);

	if (team <= view_as<int>(TFTeam_Blue))
		SetEntProp(ent, Prop_Send, "m_iTeamNum", team);
	else
		SetEntProp(ent, Prop_Send, "m_iTeamNum", 4);

	return 0; 
}

public any Native_CFNPCGetSkin(Handle plugin, int numParams) { return GetEntProp(GetNativeCell(1), Prop_Send, "m_nSkin"); }
public int Native_CFNPCSetSkin(Handle plugin, int numParams) 
{
	int ent = GetNativeCell(1);
	int skin = GetNativeCell(2);
	CFNPC npc = view_as<CFNPC>(ent);

	if (skin < 0)
	{
		if (npc.i_Team == TFTeam_Red || npc.i_Team == TFTeam_Blue)
			SetEntProp(ent, Prop_Send, "m_nSkin", view_as<int>(npc.i_Team) - 2);
		else
			SetEntProp(ent, Prop_Send, "m_nSkin", 0);
	}
	else
	{
		SetEntProp(ent, Prop_Send, "m_nSkin", skin);
	}

	return 0; 
}

public any Native_CFNPCGetScale(Handle plugin, int numParams) { return GetEntPropFloat(GetNativeCell(1), Prop_Send, "m_flModelScale"); }
public int Native_CFNPCSetScale(Handle plugin, int numParams) 
{
	int ent = GetNativeCell(1);
	float scale = GetNativeCell(2);
	SetEntPropFloat(ent, Prop_Send, "m_flModelScale", scale);

	return 0; 
}

public any Native_CFNPCGetSpeed(Handle plugin, int numParams) { return CFNPC_Speed[GetNativeCell(1)]; }
public int Native_CFNPCSetSpeed(Handle plugin, int numParams) 
{
	int ent = GetNativeCell(1);
	float speed = GetNativeCell(2);
	CFNPC_Speed[ent] = speed;

	return 0; 
}

public any Native_CFNPCGetThinkRate(Handle plugin, int numParams) { return CFNPC_ThinkRate[GetNativeCell(1)]; }
public int Native_CFNPCSetThinkRate(Handle plugin, int numParams) 
{
	int ent = GetNativeCell(1);
	float thinker = GetNativeCell(2);
	CFNPC_ThinkRate[ent] = thinker;

	return 0; 
}

public any Native_CFNPCGetNextThinkTime(Handle plugin, int numParams) { return CFNPC_NextThinkTime[GetNativeCell(1)]; }
public int Native_CFNPCSetNextThinkTime(Handle plugin, int numParams) 
{
	int ent = GetNativeCell(1);
	float nextone = GetNativeCell(2);
	CFNPC_NextThinkTime[ent] = nextone;

	return 0; 
}

public any Native_CFNPCGetEndTime(Handle plugin, int numParams) { return CFNPC_EndTime[GetNativeCell(1)]; }
public int Native_CFNPCSetEndTime(Handle plugin, int numParams) 
{
	int ent = GetNativeCell(1);
	float theend = GetNativeCell(2);
	CFNPC_EndTime[ent] = theend;

	return 0; 
}

public int Native_CFNPCGetModel(Handle plugin, int numParams) { SetNativeString(2, CFNPC_Model[GetNativeCell(1)], GetNativeCell(3)); return 0; }
public int Native_CFNPCSetModel(Handle plugin, int numParams) 
{
	int ent = GetNativeCell(1);
	char newModel[255];
	GetNativeString(2, newModel, sizeof(newModel));
	if (CheckFile(newModel))
	{
		DispatchKeyValue(ent, "model", newModel);
		view_as<CBaseCombatCharacter>(ent).SetModel(newModel);
		
		strcopy(CFNPC_Model[ent], 255, newModel);
	}

	return 0; 
}

public int Native_CFNPCGetHealth(Handle plugin, int numParams) { return GetEntProp(GetNativeCell(1), Prop_Data, "m_iHealth"); }
public int Native_CFNPCSetHealth(Handle plugin, int numParams) 
{
	int ent = GetNativeCell(1);
	int hp = GetNativeCell(2);
	SetEntProp(ent, Prop_Data, "m_iHealth", hp);

	return 0; 
}

public int Native_CFNPCGetMaxHealth(Handle plugin, int numParams) { return GetEntProp(GetNativeCell(1), Prop_Data, "m_iMaxHealth"); }
public int Native_CFNPCSetMaxHealth(Handle plugin, int numParams) 
{
	int ent = GetNativeCell(1);
	int hp = GetNativeCell(2);
	SetEntProp(ent, Prop_Data, "m_iMaxHealth", hp);

	return 0; 
}