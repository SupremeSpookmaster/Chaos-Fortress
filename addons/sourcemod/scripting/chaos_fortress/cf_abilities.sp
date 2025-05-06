float f_CancelTemporarySpeedMod[MAXPLAYERS + 1] = { 0.0, ... };
float f_NextShieldCollisionForward[2049][2049];
float f_ChargeRetain = 0.0;
float f_FakeMediShieldHP[2049] = { 0.0, ... };
float f_FakeMediShieldMaxHP[2049] = { 0.0, ... };

bool b_UseHUD[MAXPLAYERS + 1] = { false, ... };
bool b_IsFakeHealthKit[2049] = { false, ... };
bool b_IsMedigunShield[2049] = { false, ... };

bool critHit, miniCritHit, headshotKill;

GlobalForward g_OnAbility;
GlobalForward g_OnUltUsed;
GlobalForward g_OnM2Used;
GlobalForward g_OnM3Used;
GlobalForward g_OnReloadUsed;
GlobalForward g_OnHeldStart;
GlobalForward g_OnHeldEnd;
GlobalForward g_OnHeldEnd_Ability;
GlobalForward g_ResourceGiven;
GlobalForward g_UltChargeGiven;
GlobalForward g_ResourceApplied;
GlobalForward g_UltChargeApplied;
GlobalForward g_ProjectileTeamChanged;
GlobalForward g_PassFilter;
GlobalForward g_ShouldCollide;
GlobalForward g_FakeMediShieldCollision;
GlobalForward g_FakeMediShieldDamaged;
GlobalForward g_AttemptAbility;
GlobalForward g_SimulatedSpellCast;
GlobalForward g_ForcedVMAnimEnd;
GlobalForward g_OnHUDDisplayed;
GlobalForward g_SentryFiredForward;

Handle SDKStartLagCompensation;
Handle SDKFinishLagCompensation;
Handle SDKPlayTaunt;
Address CStartLagCompensationManager;
Address CEndLagCompensationManager;
Address SDKGetCurrentCommand;

int i_GenericProjectileOwner[2049] = { -1, ... };
int i_HealingDone[MAXPLAYERS + 1] = { 0, ... };
int i_HUDR[MAXPLAYERS + 1] = { 255, ... };
int i_HUDG[MAXPLAYERS + 1] = { 255, ... };
int i_HUDB[MAXPLAYERS + 1] = { 255, ... };
int i_HUDA[MAXPLAYERS + 1] = { 255, ... };

char s_ProjectileLogicPlugin[2049][255];
Function g_ProjectileLogic[2049] = { INVALID_FUNCTION, ... };
Handle g_HomingTimer[2049] = { null, ... };

bool b_ProjectileCanCollideWithAllies[2049] = { false, ... };
bool b_IsProjectile[2049] = { false, ... };
bool b_IsPhysProp[2049] = { false, ... };

CF_AbilityType i_HeldBlocked[MAXPLAYERS + 1] = { CF_AbilityType_None, ... };

public void CFA_MakeNatives()
{
	CreateNative("CF_GiveUltCharge", Native_CF_GiveUltCharge);
	CreateNative("CF_SetUltCharge", Native_CF_SetUltCharge);
	CreateNative("CF_GetUltCharge", Native_CF_GetUltCharge);
	CreateNative("CF_ApplyAbilityCooldown", Native_CF_ApplyAbilityCooldown);
	CreateNative("CF_GetAbilityCooldown", Native_CF_GetAbilityCooldown);
	CreateNative("CF_GiveSpecialResource", Native_CF_GiveSpecialResource);
	CreateNative("CF_SetSpecialResource", Native_CF_SetSpecialResource);
	CreateNative("CF_GetSpecialResource", Native_CF_GetSpecialResource);
	CreateNative("CF_GetMaxSpecialResource", Native_CF_GetMaxSpecialResource);
	CreateNative("CF_SetMaxSpecialResource", Native_CF_SetMaxSpecialResource);
	CreateNative("CF_DoAbility", Native_CF_DoAbility);
	CreateNative("CF_ActivateAbilitySlot", Native_CF_ActivateAbilitySlot);
	CreateNative("CF_EndHeldAbilitySlot", Native_CF_EndHeldAbilitySlot);
	CreateNative("CF_EndHeldAbility", Native_CF_EndHeldAbility);
	CreateNative("CF_HasAbility", Native_CF_HasAbility);
	CreateNative("CF_GetArgI", Native_CF_GetArgI);
	CreateNative("CF_GetArgF", Native_CF_GetArgF);
	CreateNative("CF_GetArgS", Native_CF_GetArgS);
	CreateNative("CF_GetAbilitySlot", Native_CF_GetAbilitySlot);
	CreateNative("CF_GetAbilityConfigMapPath", Native_CF_GetAbilityConfigMapPath);
	CreateNative("CF_IsAbilitySlotBlocked", Native_CF_IsAbilitySlotBlocked);
	CreateNative("CF_BlockAbilitySlot", Native_CF_BlockAbilitySlot);
	CreateNative("CF_UnblockAbilitySlot", Native_CF_UnblockAbilitySlot);
	CreateNative("CF_HealPlayer", Native_CF_HealPlayer);
	CreateNative("CF_HealPlayer_WithAttributes", Native_CF_HealPlayer_WithAttributes);
	CreateNative("CF_FireGenericRocket", Native_CF_FireGenericRocket);
	CreateNative("CF_GenericAOEDamage", Native_CF_GenericAOEDamage);
	CreateNative("CF_CreatePickup", Native_CF_CreatePickup);
	CreateNative("CF_CreateShieldWall", Native_CF_CreateShieldWall);
	CreateNative("CF_GetShieldWallHealth", Native_CF_GetShieldWallHealth);
	CreateNative("CF_GetShieldWallMaxHealth", Native_CF_GetShieldWallMaxHealth);
	CreateNative("CF_CheckIsSlotBlocked", Native_CF_CheckIsSlotBlocked);
	CreateNative("CF_ApplyTemporarySpeedChange", Native_CF_ApplyTemporarySpeedChange);
	CreateNative("CF_ToggleHUD", Native_CF_ToggleHUD);
	CreateNative("CF_Teleport", Native_CF_Teleport);
	CreateNative("CF_CheckTeleport", Native_CF_CheckTeleport);
	CreateNative("CF_ChangeAbilityTitle", Native_CF_ChangeAbilityTitle);
	CreateNative("CF_GetAbilityTitle", Native_CF_GetAbilityTitle);
	CreateNative("CF_ChangeSpecialResourceTitle", Native_CF_ChangeSpecialResourceTitle);
	CreateNative("CF_GetSpecialResourceTitle", Native_CF_GetSpecialResourceTitle);
	CreateNative("CF_SetHUDColor", Native_CF_SetHUDColor);
	CreateNative("CF_WorldSpaceCenter", Native_CF_WorldSpaceCenter);
	CreateNative("CF_IsValidTarget", Native_CF_IsValidTarget);
	CreateNative("CF_GetClosestTarget", Native_CF_GetClosestTarget);
	CreateNative("CF_SimulateSpellbookCast", Native_CF_SimulateSpellbookCast);
	CreateNative("CF_ForceViewmodelAnimation", Native_CF_ForceViewmodelAnimation);
	CreateNative("CF_SetAbilityStocks", Native_CF_SetAbilityStocks);
	CreateNative("CF_SetAbilityMaxStocks", Native_CF_SetAbilityMaxStocks);
	CreateNative("CF_GetAbilityStocks", Native_CF_GetAbilityStocks);
	CreateNative("CF_GetAbilityMaxStocks", Native_CF_GetAbilityMaxStocks);
	CreateNative("CF_SetLocalOrigin", Native_CF_SetLocalOrigin);
	CreateNative("CF_StartLagCompensation", Native_CF_StartLagCompensation);
	CreateNative("CF_EndLagCompensation", Native_CF_EndLagCompensation);
	CreateNative("CF_DoAbilitySlot", Native_CF_DoAbilitySlot);
	CreateNative("CF_DoBulletTrace", Native_CF_DoBulletTrace);
	CreateNative("CF_TraceShot", Native_CF_TraceShot);
	CreateNative("CF_FireGenericBullet", Native_CF_FireGenericBullet);
	CreateNative("CF_HasLineOfSight", Native_CF_HasLineOfSight);
	CreateNative("CF_InitiateHomingProjectile", Native_CF_InitiateHomingProjectile);
	CreateNative("CF_TerminateHomingProjectile", Native_CF_TerminateHomingProjectile);
	CreateNative("CF_SetAbilityTypeSlot", Native_CF_SetAbilityTypeSlot);
	CreateNative("CF_GetAbilityTypeSlot", Native_CF_GetAbilityTypeSlot);
	CreateNative("CF_ForceTaunt", Native_CF_ForceTaunt);
	CreateNative("CF_ForceWeaponTaunt", Native_CF_ForceWeaponTaunt);
	CreateNative("CF_GetSpecialResourceIsMetal", Native_CF_GetSpecialResourceIsMetal);
	CreateNative("CF_SetSpecialResourceIsMetal", Native_CF_SetSpecialResourceIsMetal);
	CreateNative("CF_AddCondition", Native_CF_AddCondition);
	CreateNative("CF_RemoveCondition", Native_CF_RemoveCondition);
}

Handle g_hSDKWorldSpaceCenter;
DynamicHook g_DHookRocketExplode;
DynamicHook g_DHookSentryFireBullet;
Handle g_hSetLocalOrigin;
/*Handle g_hSDKResetSequence;
Handle g_hSDKLookupSequence;
Handle g_hSDKGetSequenceDuration;
Handle g_hSDKGetModelPtr;*/

public void CFA_MakeForwards()
{
	g_OnAbility = new GlobalForward("CF_OnAbility", ET_Ignore, Param_Cell, Param_String, Param_String);
	g_OnUltUsed = new GlobalForward("CF_OnUltUsed", ET_Event, Param_Cell);
	g_OnM2Used = new GlobalForward("CF_OnM2Used", ET_Event, Param_Cell);
	g_OnM3Used = new GlobalForward("CF_OnM3Used", ET_Event, Param_Cell);
	g_OnReloadUsed = new GlobalForward("CF_OnReloadUsed", ET_Event, Param_Cell);
	g_OnHeldStart = new GlobalForward("CF_OnHeldStart", ET_Event, Param_Cell, Param_Cell);
	g_OnHeldEnd = new GlobalForward("CF_OnHeldEnd", ET_Event, Param_Cell, Param_Cell, Param_Cell);
	g_OnHeldEnd_Ability = new GlobalForward("CF_OnHeldEnd_Ability", ET_Event, Param_Cell, Param_Cell, Param_String, Param_String);
	g_ResourceGiven = new GlobalForward("CF_OnSpecialResourceGiven", ET_Event, Param_Cell, Param_FloatByRef);
	g_UltChargeGiven = new GlobalForward("CF_OnUltChargeGiven", ET_Event, Param_Cell, Param_FloatByRef);
	g_ResourceApplied = new GlobalForward("CF_OnSpecialResourceApplied", ET_Event, Param_Cell, Param_Float, Param_FloatByRef);
	g_UltChargeApplied = new GlobalForward("CF_OnUltChargeApplied", ET_Event, Param_Cell, Param_Float, Param_FloatByRef);
	g_ProjectileTeamChanged = new GlobalForward("CF_OnGenericProjectileTeamChanged", ET_Ignore, Param_Cell, Param_Cell);
	g_PassFilter = new GlobalForward("CF_OnPassFilter", ET_Event, Param_Cell, Param_Cell, Param_CellByRef);
	g_ShouldCollide = new GlobalForward("CF_OnShouldCollide", ET_Event, Param_Cell, Param_Cell, Param_CellByRef);
	g_FakeMediShieldCollision = new GlobalForward("CF_OnFakeMediShieldCollision", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	g_FakeMediShieldDamaged = new GlobalForward("CF_OnFakeMediShieldDamaged", ET_Event, Param_Cell, Param_Cell, Param_Cell, Param_FloatByRef, Param_CellByRef, Param_Cell);
	g_AttemptAbility = new GlobalForward("CF_OnAbilityCheckCanUse", ET_Event, Param_Cell, Param_String, Param_String, Param_Cell, Param_CellByRef);
	g_SimulatedSpellCast = new GlobalForward("CF_OnSimulatedSpellUsed", ET_Ignore, Param_Cell, Param_Cell);
	g_ForcedVMAnimEnd = new GlobalForward("CF_OnForcedVMAnimEnd", ET_Ignore, Param_Cell, Param_String);
	g_OnHUDDisplayed = new GlobalForward("CF_OnHUDDisplayed", ET_Ignore, Param_Cell, Param_String, Param_CellByRef, Param_CellByRef, Param_CellByRef, Param_CellByRef);
	g_SentryFiredForward = new GlobalForward("CF_OnSentryFire", ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Array, Param_Array, Param_Array, Param_Array, Param_CellByRef);
	
	GameData gd = LoadGameConfigFile("chaos_fortress");
	
	//WorldSpaceCenter:
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(gd, SDKConf_Virtual, "CBaseEntity::WorldSpaceCenter");
	PrepSDKCall_SetReturnInfo(SDKType_Vector, SDKPass_ByRef);
	if ((g_hSDKWorldSpaceCenter = EndPrepSDKCall()) == null) SetFailState("Failed to create SDKCall for CBaseEntity::WorldSpaceCenter offset!");
	
	//CTFBaseRocket::Explode:
	g_DHookRocketExplode = DHook_CreateVirtual(gd, "CTFBaseRocket::Explode");

	//CBaseEntity::FireBullets
	g_DHookSentryFireBullet = DHook_CreateVirtual(gd, "CBaseEntity::FireBullets");
	g_DHookSentryFireBullet.AddParam(HookParamType_Int);
	
	//SetLocalOrigin
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(gd, SDKConf_Signature, "CBaseEntity::SetLocalOrigin");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
	g_hSetLocalOrigin = EndPrepSDKCall();
	if(!g_hSetLocalOrigin)
		LogError("[Gamedata] Could not find CBaseEntity::SetLocalOrigin");

	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(gd, SDKConf_Signature, "CLagCompensationManager::StartLagCompensation");
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Pointer);
	SDKStartLagCompensation = EndPrepSDKCall();
	if(!SDKStartLagCompensation)
		LogError("[Gamedata] Could not find CLagCompensationManager::StartLagCompensation");
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(gd, SDKConf_Signature, "CLagCompensationManager::FinishLagCompensation");
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	SDKFinishLagCompensation = EndPrepSDKCall();
	if(!SDKFinishLagCompensation)
		LogError("[Gamedata] Could not find CLagCompensationManager::FinishLagCompensation");

	DHook_CreateDetour(gd, "CLagCompensationManager::StartLagCompensation", _, DHook_StartLagCompensation);
	DHook_CreateDetour(gd, "CLagCompensationManager::FinishLagCompensation", _, DHook_EndLagCompensation);

	SDKGetCurrentCommand = view_as<Address>(gd.GetOffset("GetCurrentCommand"));
	if(SDKGetCurrentCommand == view_as<Address>(-1))
		LogError("[Gamedata] Could not find GetCurrentCommand");

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(gd, SDKConf_Signature, "CTFPlayer::PlayTauntSceneFromItem");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	SDKPlayTaunt = EndPrepSDKCall();
	if(SDKPlayTaunt == INVALID_HANDLE)
		LogError("Could not find CTFPlayer::PlayTauntSceneFromItem.");
	
	delete gd;
}

public void CFA_OGF()
{
	CFA_ScanProjectiles();
}

public void CFA_ScanProjectiles()
{
	int entity = -1;
	while ((entity = FindEntityByClassname(entity, "tf_projectile_*")) != -1)
	{
		if (i_GenericProjectileOwner[entity] != -1)
		{
			int currentOwner = GetClientOfUserId(i_GenericProjectileOwner[entity]);
			int newOwner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
			
			if (newOwner != currentOwner && IsValidClient(currentOwner) && IsValidClient(newOwner))
			{
				if (TF2_GetClientTeam(currentOwner) != TF2_GetClientTeam(newOwner))
				{
					Call_StartForward(g_ProjectileTeamChanged);
					
					Call_PushCell(entity);
					Call_PushCell(TF2_GetClientTeam(newOwner));
					
					Call_Finish();
				}
				
				i_GenericProjectileOwner[entity] = GetClientUserId(newOwner);
			}
		}
	}
}

public void CFA_AddHealingPoints(int client, int amt)
{
	i_HealingDone[client] += amt;
}

public void CFA_Disconnect(int client)
{
	i_HealingDone[client] = 0;
	CFCharacter chara = GetCharacterFromClient(client);
	if (chara != null)
		chara.f_UltCharge = 0.0;
}

public void CFA_OnEntityDestroyed(int entity)
{
	i_GenericProjectileOwner[entity] = -1;
	b_IsFakeHealthKit[entity] = false;
	b_IsMedigunShield[entity] = false;
	b_IsProjectile[entity] = false;
	b_IsPhysProp[entity] = false;
	f_FakeMediShieldHP[entity] = 0.0;
	f_FakeMediShieldMaxHP[entity] = 0.0;
	b_ProjectileCanCollideWithAllies[entity] = false;
	strcopy(s_ProjectileLogicPlugin[entity], 255, "");
	g_ProjectileLogic[entity] = INVALID_FUNCTION;
	delete g_HomingTimer[entity];
	g_HomingTimer[entity] = null;
}

#if defined _pnpc_included_
public void PNPC_OnPNPCProjectileExplode(int rocket, int owner, int launcher, bool &result)
{
	if (!StrEqual(s_ProjectileLogicPlugin[rocket], "") && g_ProjectileLogic[rocket] != INVALID_FUNCTION)
		result = false;

	return;
}
#endif

void CFA_UpdateMadeCharacter(int client)
{
	f_CancelTemporarySpeedMod[client] = GetGameTime() + 0.5;
}

public Action GetOwner(int ent)
{
	if (!IsValidEntity(ent))
		return Plugin_Continue;
		
	int owner = GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	if (IsValidClient(owner))
		i_GenericProjectileOwner[ent] = GetClientUserId(owner);
	
	return Plugin_Continue;
}

Handle HudSync;

#define NOPE				"replay/record_fail.wav"
#define HEAL_DEFAULT		"items/smallmedkit1.wav"
#define HEAL_DEFAULT_MODEL	"models/items/medkit_medium.mdl"

#define SOUND_SPEED_APPLY		"weapons/discipline_device_power_up.wav"
#define SOUND_SPEED_REMOVE		"weapons/discipline_device_power_down.wav"

#define PARTICLE_CRIT		"crit_text"
#define PARTICLE_MINICRIT	"minicrit_text"

static char g_CritHits[][] = {
	")player/crit_hit.wav",
	")player/crit_hit2.wav",
	")player/crit_hit3.wav",
	")player/crit_hit4.wav",
	")player/crit_hit5.wav"
};

static char g_MiniCritHits[][] = {
	")player/crit_hit_mini.wav",
	")player/crit_hit_mini2.wav",
	")player/crit_hit_mini3.wav",
	")player/crit_hit_mini4.wav",
	")player/crit_hit_mini5.wav"
};

static char g_CritHits_Victim[][] = {
	")player/crit_received1.wav",
	")player/crit_received2.wav",
	")player/crit_received3.wav"
};

public void CFA_MapStart()
{
	HudSync = CreateHudSynchronizer();
	
	PrecacheSound(NOPE);
	PrecacheSound(HEAL_DEFAULT);
	PrecacheModel(HEAL_DEFAULT_MODEL);
	
	PrecacheSound(SOUND_SPEED_APPLY);
	PrecacheSound(SOUND_SPEED_REMOVE);
	
	int entity = FindEntityByClassname(MaxClients + 1, "tf_player_manager");
	if(IsValidEntity(entity))
		SDKHook(entity, SDKHook_ThinkPost, ScoreThink);

	for (int i = 0; i < (sizeof(g_CritHits));   i++) { PrecacheSound(g_CritHits[i]);   }
	for (int i = 0; i < (sizeof(g_MiniCritHits));   i++) { PrecacheSound(g_MiniCritHits[i]);   }
	for (int i = 0; i < (sizeof(g_CritHits_Victim));   i++) { PrecacheSound(g_CritHits_Victim[i]);   }
		
	//MODEL_NONE = PrecacheModel("models/empty.mdl");
}

public void ScoreThink(int entity)
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsValidClient(client))
		{
			SetEntProp(client, Prop_Send, "m_iHealPoints", i_HealingDone[client]);
		}
	}
}

public void CFA_StockLogic(int client, CFAbility ability, CF_AbilityType type)
{
	if (ability.i_MaxStocks < 1 || ability.i_Stocks >= ability.i_MaxStocks || CF_GetAbilityCooldown(client, type) > 0.0)
		return;

	ability.i_Stocks++;
	if (ability.i_Stocks < ability.i_MaxStocks)
		CF_ApplyAbilityCooldown(client, ability.f_Cooldown, type, true, false);
}

public Action CFA_HUDTimer(Handle timer)
{
	int rState = CF_GetRoundState();
	
	for (int client = 1; client <= MaxClients; client++)
	{
		bool wouldBeStuck, tooPoor, CanUse;
		float remCD;
		
		if (!CF_IsPlayerCharacter(client))
			continue;

		if (!IsPlayerAlive(client))
			continue;

		CFCharacter chara = GetCharacterFromClient(client);
		if (chara == null)
			continue;
		
		bool showHUD = GetClientButtons(client) & IN_SCORE == 0 && b_UseHUD[client];
		char HUDText[255];

		for (int i = 0; i < 4; i++)
		{
			CF_AbilityType type = view_as<CF_AbilityType>(i);
			bool resourcesNext = type == CF_AbilityType_Ult;

			char name[255], namePlural[255];

			chara.GetResourceName(name, 255);
			chara.GetResourceNamePlural(namePlural, 255);

			CFAbility ability = GetAbilityFromClient(client, type);
			if (ability != null)
			{
				char title[255], button[64];
				ability.GetName(title, sizeof(title));
				switch(type)
				{
					case CF_AbilityType_Ult:
					{
						button = "(READY, CALL FOR MEDIC)";
					}
					case CF_AbilityType_M2:
					{
						button = "M2";
					}
					case CF_AbilityType_M3:
					{
						button = "Spec. Attack";
					}
					case CF_AbilityType_Reload:
					{
						button = "Reload";
					}
				}

				remCD = CF_GetAbilityCooldown(client, type);
				if (remCD < 0.1 && type == CF_AbilityType_Ult && rState == 1)
				{
					CF_GiveUltCharge(client, chara.f_UltChargeOnRegen/10.0, CF_ResourceType_Percentage);
				}
				
				if (showHUD)
				{
					CanUse = CF_CanPlayerUseAbilitySlot(client, type, wouldBeStuck, tooPoor);

					if (type == CF_AbilityType_Ult)
					{	
						if (!CanUse && !tooPoor && !wouldBeStuck)
						{
							Format(HUDText, sizeof(HUDText), "%s: %i[PERCENT] [BLOCKED]\n", title, RoundToFloor((chara.f_UltCharge/chara.f_UltChargeRequired) * 100.0));
						}
						else if (wouldBeStuck && !tooPoor)
						{
							Format(HUDText, sizeof(HUDText), "%s: %i[PERCENT] [BLOCKED; YOU WOULD GET STUCK]\n", title, RoundToFloor((chara.f_UltCharge/chara.f_UltChargeRequired) * 100.0));
						}
						else
						{
							Format(HUDText, sizeof(HUDText), "%s: %i[PERCENT] %s\n", title, RoundToFloor((chara.f_UltCharge/chara.f_UltChargeRequired) * 100.0), chara.f_UltCharge >= chara.f_UltChargeRequired ? button : "");
						}
					}
					else
					{
						CFA_StockLogic(client, ability, type);

						if (ability.b_HeldAbility)
						{
							if (ability.b_CurrentlyHeld)
								button = "ACTIVE";
							else
								Format(button, sizeof(button), "HOLD %s", button);
						}
						Format(button, sizeof(button), "[%s]", button);

						char suffix[255];
						if (ability.i_MaxStocks > 0)
							Format(suffix, sizeof(suffix), "[%i/%i]", ability.i_Stocks, ability.i_MaxStocks);

						if (!CanUse && !tooPoor && !wouldBeStuck && remCD < 0.1)
						{
							Format(button, sizeof(button), "[BLOCKED]");
						}
						else if (wouldBeStuck && !tooPoor)
						{
							Format(button, sizeof(button), "[BLOCKED; YOU WOULD GET STUCK]");
						}
						else
						{
							if (chara.b_UsingResources && ability.f_ResourceCost > 0.0)
							{
								if (chara.b_ResourceIsUlt)
								{
									Format(suffix, sizeof(suffix), "%s [%.2f[PERCENT] Ult.]", suffix, (ability.f_ResourceCost/chara.f_UltChargeRequired) * 100.0);
								}
								else
								{
									if (chara.b_ResourceIsPercentage && chara.f_MaxResources > 0.0)
										Format(suffix, sizeof(suffix), "%s [%i[PERCENT] %s]", suffix, RoundToFloor((ability.f_ResourceCost/chara.f_MaxResources) * 100.0), ability.f_ResourceCost != 1.0 ? namePlural : name);
									else
										Format(suffix, sizeof(suffix), "%s [%i %s]", suffix, RoundToFloor(ability.f_ResourceCost), ability.f_ResourceCost != 1.0 ? namePlural : name);
								}
							}
									
							if (remCD > 0.0)
								Format(suffix, sizeof(suffix), "%s (%.1f)", suffix, remCD);
						}

						Format(HUDText, sizeof(HUDText), "%s %s %s %s\n", HUDText, button, title, suffix);
					}
				}
			}

			if (resourcesNext && chara.b_UsingResources && !chara.b_ResourceIsUlt)
			{
				if (GetGameTime() >= chara.f_NextResourceRegen)
				{
					CF_GiveSpecialResource(client, 1.0, CF_ResourceType_Regen);
					chara.f_NextResourceRegen = GetGameTime() + chara.f_ResourceRegenInterval;
				}
						
				if (showHUD)
				{
					if (chara.f_MaxResources > 0.0)
					{
						if (chara.b_ResourceIsPercentage)
							Format(HUDText, sizeof(HUDText), "%s\n%s: %i[PERCENT]\n", HUDText, CF_GetSpecialResource(client) != 1.0 ? namePlural : name, RoundToFloor((CF_GetSpecialResource(client)/chara.f_MaxResources) * 100.0));
						else
							Format(HUDText, sizeof(HUDText), "%s\n%s: %i/%i\n", HUDText, CF_GetSpecialResource(client) != 1.0 ? namePlural : name, RoundToFloor(CF_GetSpecialResource(client)), RoundToFloor(chara.f_MaxResources));
					}
					else
					{
						Format(HUDText, sizeof(HUDText), "%s\n%s: %i\n", HUDText, CF_GetSpecialResource(client) != 1.0 ? namePlural : name, RoundToFloor(CF_GetSpecialResource(client)));
					}
				}
			}
		}
					
		if (showHUD)
		{
			int r = i_HUDR[client];
			int g = i_HUDG[client];
			int b = i_HUDB[client];
			int a = i_HUDA[client];

			if (r == 255 && g == 255 && b == 255)
			{
				r = 255;
				g = 160;
				b = 160;
				if (TF2_GetClientTeam(client) == TFTeam_Blue)
				{
					b = 255;
					r = 160;
				}
			}

			Call_StartForward(g_OnHUDDisplayed);

			Call_PushCell(client);
			Call_PushStringEx(HUDText, sizeof(HUDText), SM_PARAM_STRING_UTF8|SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
			Call_PushCellRef(r);
			Call_PushCellRef(g);
			Call_PushCellRef(b);
			Call_PushCellRef(a);

			Call_Finish();
			
			ReplaceString(HUDText, sizeof(HUDText), "[PERCENT]", "%%");
			SetHudTextParams(-1.0, 0.7, 0.1, r, g, b, a);
			ShowSyncHudText(client, HudSync, HUDText);
		}
	}
	
	return Plugin_Continue;
}

public bool IsPhysProp(int ent) { return b_IsPhysProp[ent]; }

public void CFA_PlayerKilled(int attacker, int victim)
{
	if (CF_IsPlayerCharacter(attacker) && attacker != victim)
	{
		CF_GiveSpecialResource(attacker, 1.0, CF_ResourceType_Kill);
		CF_GiveUltCharge(attacker, 1.0, CF_ResourceType_Kill);
		
		CF_PlayRandomSound(attacker, attacker, "sound_kill");
	}
	
	bool played = false;
	if (attacker == victim)
		played = CF_PlayRandomSound(attacker, attacker, "sound_suicide");

	if (!played)
		played = CF_PlayRandomSound(victim, attacker, "sound_killed");

	if (played)
		CF_SilenceCharacter(victim, 0.2);
}

public bool CFA_InitializeUltimate(int client, ConfigMap map, bool IsNewCharacter)
{
	bool success = false;
	ConfigMap subsection = map.GetSection("character.ultimate_stats");
	if (subsection != null)
	{
		CFCharacter chara = GetCharacterFromClient(client);
		chara.f_UltChargeRequired = GetFloatFromCFGMap(subsection, "charge", 0.0);
		chara.f_UltChargeOnRegen = GetFloatFromCFGMap(subsection, "on_regen", 0.0);
		chara.f_UltChargeOnDamage = GetFloatFromCFGMap(subsection, "on_damage", 0.0);
		chara.f_UltChargeOnHurt = GetFloatFromCFGMap(subsection, "on_hurt", 0.0);
		chara.f_UltChargeOnHeal = GetFloatFromCFGMap(subsection, "on_heal", 0.0);
		chara.f_UltChargeOnKill = GetFloatFromCFGMap(subsection, "on_kill", 0.0);
		chara.f_UltChargeOnBuildingDamage = GetFloatFromCFGMap(subsection, "on_damage_building", 0.0);
		chara.f_UltChargeOnDestruction = GetFloatFromCFGMap(subsection, "on_kill_building", 0.0);

		CFC_CreateAbility(client, subsection, CF_AbilityType_Ult, IsNewCharacter);
		success = true;
	}
	else
		DestroyAbility(client, CF_AbilityType_Ult);
	
	return success;
}

public bool CFA_InitializeAbilities(int client, ConfigMap map, bool NewChar)
{
	CFA_InitializeResources(client, map, NewChar);
	
	bool AtLeastOne = false;
	
	ConfigMap subsection = map.GetSection("character.m2_ability");
	if (subsection != null)
	{
		CFC_CreateAbility(client, subsection, CF_AbilityType_M2, NewChar);
		AtLeastOne = true;
	}
	else
		DestroyAbility(client, CF_AbilityType_M2);
	
	subsection = map.GetSection("character.m3_ability");
	if (subsection != null)
	{
		CFC_CreateAbility(client, subsection, CF_AbilityType_M3, NewChar);
		AtLeastOne = true;
	}
	else
		DestroyAbility(client, CF_AbilityType_M3);
	
	subsection = map.GetSection("character.reload_ability");
	if (subsection != null)
	{
		CFC_CreateAbility(client, subsection, CF_AbilityType_Reload, NewChar);
		AtLeastOne = true;
	}
	else
		DestroyAbility(client, CF_AbilityType_Reload);
	
	return AtLeastOne;
}

public void CFA_InitializeResources(int client, ConfigMap map, bool NewChar)
{
	CFCharacter chara = GetCharacterFromClient(client);
	if (chara == null)
		return;

	ConfigMap subsection = map.GetSection("character.special_resource");
	chara.b_UsingResources = subsection != null;
	if (chara.b_UsingResources)
	{
		chara.b_ResourceIsUlt = GetBoolFromCFGMap(subsection, "is_ult", false);
		
		if (!chara.b_ResourceIsUlt)
		{
			chara.b_ResourceIsPercentage = GetBoolFromCFGMap(subsection, "percentage", false);
			chara.b_ResourceIsMetal = GetBoolFromCFGMap(subsection, "is_metal", false);
			
			char name[255], namePlural[255];
			subsection.Get("name", name, 255);
			subsection.Get("name_plural", namePlural, 255);
			chara.SetResourceName(name);
			chara.SetResourceNamePlural(namePlural);

			float start = GetFloatFromCFGMap(subsection, "start", 0.0);
			float preserve = GetFloatFromCFGMap(subsection, "preserve", 0.0) * CF_GetSpecialResource(client);

			chara.f_MaxResources = GetFloatFromCFGMap(subsection, "max", 0.0);
			chara.f_ResourceRegenInterval = GetFloatFromCFGMap(subsection, "regen_interval", 0.1);
			chara.f_NextResourceRegen = GetGameTime() + chara.f_ResourceRegenInterval;
			
			bool IgnoreResupply = GetBoolFromCFGMap(subsection, "ignore_resupply", true);
			
			if (!IgnoreResupply || NewChar)
			{
				if (preserve > start && !NewChar)
				{
					CF_SetSpecialResource(client, preserve);
				}
				else
				{
					CF_SetSpecialResource(client, start);
				}
			}
			else
			{
				chara.f_NextResourceRegen = GetGameTime() + 0.2;
			}
			
			chara.f_ResourcesOnRegen = GetFloatFromCFGMap(subsection, "on_regen", 0.0);
			chara.f_ResourcesOnDamage = GetFloatFromCFGMap(subsection, "on_damage", 0.0);
			chara.f_ResourcesOnHurt = GetFloatFromCFGMap(subsection, "on_hurt", 0.0);
			chara.f_ResourcesOnHeal = GetFloatFromCFGMap(subsection, "on_heal", 0.0);
			chara.f_ResourcesOnKill = GetFloatFromCFGMap(subsection, "on_kill", 0.0);
			chara.f_ResourcesOnBuildingDamage = GetFloatFromCFGMap(subsection, "on_damage_building", 0.0);
			chara.f_ResourcesOnDestruction = GetFloatFromCFGMap(subsection, "on_kill_building", 0.0);
			
			chara.f_ResourcesToTriggerSound = GetFloatFromCFGMap(subsection, "sound_amt", 0.0);
			chara.f_ResourcesSinceLastGain = 0.0;
		}
	}
}

public void CFA_SetChargeRetain(float amt)
{
	f_ChargeRetain = amt;
}

public void CFA_ReduceUltCharge_CharacterSwitch(int client)
{
	CFCharacter chara = GetCharacterFromClient(client);
	float newCharge = chara.f_UltChargeRequired * f_ChargeRetain;
	
	if (newCharge > chara.f_UltCharge)
		newCharge = chara.f_UltCharge;
		
	CF_SetUltCharge(client, newCharge, true);
}

public void CFA_MapEnd()
{
	for (int i = 0; i <= MaxClients; i++)
	{
		CFCharacter chara = GetCharacterFromClient(i);
		if (chara != null)
			chara.Destroy(true);
	}

	for (int i = 0; i < 2049; i++)
	{
		for (int j = 0; j < 2049; j++)
			f_NextShieldCollisionForward[i][j] = 0.0;

		f_FakeMediShieldHP[i] = 0.0;
		f_FakeMediShieldMaxHP[i] = 0.0;
		b_IsFakeHealthKit[i] = false;
		b_IsMedigunShield[i] = false;
		b_ProjectileCanCollideWithAllies[i] = false;
		i_GenericProjectileOwner[i] = -1;
		b_IsProjectile[i] = false;
		b_IsPhysProp[i] = false;
		g_HomingTimer[i] = null;
	}
}

public void CFA_ToggleHUD(int client, bool toggle)
{
	if (!IsValidClient(client))
		return;
		
	b_UseHUD[client] = toggle;
}

public void CF_OnPlayerCallForMedic(int client)
{
	if (!CF_IsPlayerCharacter(client))
		return;
		
	if (GetAbilityFromClient(client, CF_AbilityType_Ult) == null)
		return;
		
	if (CF_GetRoundState() != 1)
	{
		Nope(client);
		return;
	}
	
	CF_AttemptAbilitySlot(client, CF_AbilityType_Ult);
}

public Action CF_OnPlayerM2(int client, int &buttons, int &impulse, int &weapon)
{
	if (!CF_IsPlayerCharacter(client))
		return Plugin_Continue;
		
	CFAbility ab = GetAbilityFromClient(client, CF_AbilityType_M2);
	if (ab == null)
		return Plugin_Continue;
		
	if (ab.b_HeldAbility)
	{
		CF_AttemptHeldAbility(client, CF_AbilityType_M2, IN_ATTACK2);
	}
	else
	{
		CF_AttemptAbilitySlot(client, CF_AbilityType_M2);
	}
	
	return Plugin_Continue;
}

public Action CF_OnPlayerM3(int client, int &buttons, int &impulse, int &weapon)
{
	if (!CF_IsPlayerCharacter(client))
		return Plugin_Continue;
		
	CFAbility ab = GetAbilityFromClient(client, CF_AbilityType_M3);
	if (ab == null)
		return Plugin_Continue;
		
	if (ab.b_HeldAbility)
	{
		CF_AttemptHeldAbility(client, CF_AbilityType_M3, IN_ATTACK3);
	}
	else
	{
		CF_AttemptAbilitySlot(client, CF_AbilityType_M3);
	}

	return Plugin_Continue;
}

public Action CF_OnPlayerReload(int client, int &buttons, int &impulse, int &weapon)
{
	if (!CF_IsPlayerCharacter(client))
		return Plugin_Continue;
		
	CFAbility ab = GetAbilityFromClient(client, CF_AbilityType_Reload);
	if (ab == null)
		return Plugin_Continue;
	
	if (ab.b_HeldAbility)
	{
		CF_AttemptHeldAbility(client, CF_AbilityType_Reload, IN_RELOAD);
	}
	else
	{
		CF_AttemptAbilitySlot(client, CF_AbilityType_Reload);
	}
		
	return Plugin_Continue;
}

public void CF_AttemptHeldAbility(int client, CF_AbilityType type, int button)
{
	if (!CF_CanPlayerUseAbilitySlot(client, type))
	{
		Nope(client);
		return;
	}
	
	Action result;
	Call_StartForward(g_OnHeldStart);
	
	Call_PushCell(client);
	Call_PushCell(type);
	
	Call_Finish(result);

	if (result != Plugin_Stop && result != Plugin_Handled)
	{
		CFAbility ab = GetAbilityFromClient(client, type);

		int slot = view_as<int>(type) + 1;
		if (ab.b_HeldAbilityBlocksOthers)
			i_HeldBlocked[client] = type;

		ab.b_CurrentlyHeld = true;

		char soundSlot[255];
		
		switch(type)
		{
			case CF_AbilityType_M2:
			{
				soundSlot = "sound_heldstart_m2";
			}
			case CF_AbilityType_M3:
			{
				soundSlot = "sound_heldstart_m3";
			}
			case CF_AbilityType_Reload:
			{
				soundSlot = "sound_heldstart_reload";
			}
		}

		DataPack pack = new DataPack();
		RequestFrame(CF_HeldAbilityFrame, pack);
		WritePackCell(pack, GetClientUserId(client));
		WritePackCell(pack, type);
		WritePackCell(pack, button);
		
		CF_ActivateAbilitySlot(client, slot);
		CF_PlayRandomSound(client, client, soundSlot);
	}
	else
	{
		Nope(client);
	}
}

public void CF_HeldAbilityFrame(DataPack pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	CF_AbilityType type = ReadPackCell(pack);
	int button = ReadPackCell(pack);

	if (!IsValidMulti(client))
	{
		delete pack;
		return;
	}

	CFAbility ab = GetAbilityFromClient(client, type);
	if (ab == null)
	{
		delete pack;
		return;
	}

	bool b_HoldingButton = (GetClientButtons(client) & button != 0) && ab.b_CurrentlyHeld && CF_CanPlayerUseAbilitySlot(client, type);

	if (!b_HoldingButton)
	{
		delete pack;
		EndHeldAbility(client, type, true);
		return;
	}

	RequestFrame(CF_HeldAbilityFrame, pack);
}

void EndHeldAbility(int client, CF_AbilityType type, bool TriggerCallback, bool resupply = false)
{
	if (!IsValidClient(client))
		return;
		
	int slot = view_as<int>(type) + 1;
	if (TriggerCallback)
	{
		CF_EndHeldAbilitySlot(client, slot, resupply);
	}
	else
	{
		CFAbility ab = GetAbilityFromClient(client, type);
		if (ab == null)
			return;

		if (!AbilityUsesStocks(client, type))
			CF_ApplyAbilityCooldown(client, ab.f_Cooldown, type, true, false);
			
		CFCharacter chara = GetCharacterFromClient(client);
		if (chara.b_UsingResources && !resupply)
		{
			if (chara.b_ResourceIsUlt)
			{
				CF_GiveUltCharge(client, -ab.f_ResourceCost, CF_ResourceType_Generic);
			}
			else
			{
				CF_GiveSpecialResource(client, -ab.f_ResourceCost, CF_ResourceType_Generic);
			}
		}
			
		if (!resupply)
		{
			switch(type)
			{
				case CF_AbilityType_M2:
					CF_PlayRandomSound(client, client, "sound_heldend_m2");
				case CF_AbilityType_M3:
					CF_PlayRandomSound(client, client, "sound_heldend_m3");
				case CF_AbilityType_Reload:
					CF_PlayRandomSound(client, client, "sound_heldend_reload");
			}

			SubtractStock(client, type);
		}
			
		ab.b_CurrentlyHeld = false;
		if (ab.b_HeldAbilityBlocksOthers)
			i_HeldBlocked[client] = CF_AbilityType_None;

		Call_StartForward(g_OnHeldEnd);
			
		Call_PushCell(client);
		Call_PushCell(type);
		Call_PushCell(resupply);
			
		Call_Finish();
	}
}

bool AbilityUsesStocks(int client, CF_AbilityType type)
{
	CFAbility ab = GetAbilityFromClient(client, type);
	if (ab == null)
		return false;

	return ab.i_MaxStocks > 0;
}

void SubtractStock(int client, CF_AbilityType type)
{
	if (!AbilityUsesStocks(client, type))
		return;

	CFAbility ab = GetAbilityFromClient(client, type);
	if (ab == null)
		return;

	ab.i_Stocks--;
	if (CF_GetAbilityCooldown(client, type) <= 0.0)
		CF_ApplyAbilityCooldown(client, ab.f_Cooldown, type, true);
}

public void ResetHeldButtonStats(int client)
{
	for (int i = 0; i < 5; i++)
	{
		CFAbility ab = GetAbilityFromClient(client, view_as<CF_AbilityType>(i));
		if (ab != null)
			ab.b_CurrentlyHeld = false;
	}
}

public void CF_AttemptAbilitySlot(int client, CF_AbilityType type)
{
	if (!CF_CanPlayerUseAbilitySlot(client, type))
	{
		Nope(client);
		return;
	}
	
	int slot = view_as<int>(type) + 1;
	CFAbility ab = GetAbilityFromClient(client, type);
	CFCharacter chara = GetCharacterFromClient(client);
	if (ab == null || chara == null)
		return;

	float cooldown = ab.f_Cooldown;
	float cost = ab.f_ResourceCost;
	char soundSlot[255];
	Action result;
	GlobalForward toCall;
	
	switch(type)
	{
		case CF_AbilityType_Ult:
		{
			cost = chara.f_UltChargeRequired;
			toCall = g_OnUltUsed;
		}
		case CF_AbilityType_M2:
		{
			soundSlot = "sound_m2";
			toCall = g_OnM2Used;
		}
		case CF_AbilityType_M3:
		{
			soundSlot = "sound_m3";
			toCall = g_OnM3Used;
		}
		case CF_AbilityType_Reload:
		{
			soundSlot = "sound_reload";
			toCall = g_OnReloadUsed;
		}
	}
	
	Call_StartForward(toCall);
	
	Call_PushCell(client);
	
	Call_Finish(result);
	
	if (result != Plugin_Stop && result != Plugin_Handled)
	{
		CF_ActivateAbilitySlot(client, slot);
		
		if (type == CF_AbilityType_Ult)
		{
			CF_SetUltCharge(client, 0.0, true);
			bool played = CF_PlayRandomSound(client, client, "sound_ultimate_activation");
			
			if (!played)
			{
				played = CF_PlayRandomSound(client, client, "sound_ultimate_activation_self");
				
				bool played2 = CF_PlayRandomSound(client, client, "sound_ultimate_activation_friendly");
				if (!played)
					played = played2;
					
				played2 = CF_PlayRandomSound(client, client, "sound_ultimate_activation_hostile");
				if (!played)
					played = played2;
			}
			
			//TODO: Convert ult radius into a g_Character stat and just read it here
			char path[255];
			chara.GetConfigMapPath(path, 255);
			ConfigMap map = new ConfigMap(path);
			if (map != null)
			{
				float distance = GetFloatFromCFGMap(map, "character.ultimate_stats.radius", 999999.0);
				float pos[3];
				GetClientAbsOrigin(client, pos);
				
				for (int i = 1; i <= MaxClients; i++)
				{
					if (i != client && IsValidMulti(i, true, true))
					{ 
						float otherPos[3];
						GetClientAbsOrigin(i, otherPos);
						
						if (GetVectorDistance(pos, otherPos, true) <= Pow(distance, 2.0))
						{
							bool otherPlayed = false;
							
							if (TF2_GetClientTeam(i) == TF2_GetClientTeam(client))
							{
								otherPlayed = CF_PlayRandomSound(i, i, "sound_ultimate_react_friendly");
							}
							else
							{
								otherPlayed = CF_PlayRandomSound(i, i, "sound_ultimate_react_hostile");
							}
							
							if (otherPlayed)
								CF_SilenceCharacter(i, 2.0);
						}
					}
				}
				
				DeleteCfg(map);
			}
			
			if (played)
				CF_SilenceCharacter(client, 1.0);
		}
		else
		{
			CF_PlayRandomSound(client, client, soundSlot);
		}

		if (type != CF_AbilityType_Ult && chara.b_UsingResources)
		{
			if (chara.b_ResourceIsUlt)
				CF_GiveUltCharge(client, -cost);
			else
				CF_GiveSpecialResource(client, -cost);
		}
		
		if (!AbilityUsesStocks(client, type))
			CF_ApplyAbilityCooldown(client, cooldown, type, true, false);
	}
	else
	{
		Nope(client);
	}
}

bool CF_CanPlayerUseAbilitySlot(int client, CF_AbilityType type, bool &BlockedByResize = false, bool &BlockedByTooFewResources = false, float &remCD = 0.0)
{
	BlockedByResize = false;
	BlockedByTooFewResources = false;

	CFAbility ab = GetAbilityFromClient(client, type);
	if (ab == null)
		return false;

	bool UsingStocks = AbilityUsesStocks(client, type);
	remCD = CF_GetAbilityCooldown(client, type);
	
	if (remCD > 0.0 && (!UsingStocks || ab.i_Stocks < 1))
		return false;
	
	if (i_HeldBlocked[client] != CF_AbilityType_None && i_HeldBlocked[client] != type)
		return false;
		
	if (TF2_IsPlayerStunned(client))
		return false;

	if (ab.b_Blocked)
		return false;

	if (ab.b_RequireGrounded && GetEntityFlags(client) & FL_ONGROUND == 0)
		return false;

	if (ab.i_Stocks < 1 && UsingStocks)
		return false;

	int acWep = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

	if (ab.i_WeaponSlot > -1 && (!IsValidEntity(acWep) || GetPlayerWeaponSlot(client, ab.i_WeaponSlot) != acWep))
		return false;

	if (ab.i_AmmoRequirement > 0 && (!IsValidEntity(acWep) || ab.i_AmmoRequirement < GetClip(acWep)))
		return false;

	if (type != CF_AbilityType_Ult && !HasEnoughResources(client, ab.f_ResourceCost, type))
	{
		BlockedByTooFewResources = true;
		return false;
	}

	CFCharacter chara = GetCharacterFromClient(client);
	if (type == CF_AbilityType_Ult && !HasEnoughResources(client, chara.f_UltChargeRequired, type))
	{
		BlockedByTooFewResources = true;
		return false;
	}

	if (ab.f_Scale > 0.0 && CheckPlayerWouldGetStuck(client, ab.f_Scale))
	{
		BlockedByResize = true;
		return false;
	}
	
	return !CF_CheckIsSlotBlocked(client, ab.i_AbilitySlot);
}

public bool HasEnoughResources(int client, float cost, CF_AbilityType type)
{
	CFCharacter chara = GetCharacterFromClient(client);
	if(chara.b_UsingResources || type == CF_AbilityType_Ult)
	{
		float available = (chara.b_ResourceIsUlt || type == CF_AbilityType_Ult) ? chara.f_UltCharge : CF_GetSpecialResource(client);
		if (cost > available)
		{
			return false;
		}
	}
	
	return true;
}

public Native_CF_GiveUltCharge(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return;
		
	float amt = GetNativeCell(2);
	CF_ResourceType type = GetNativeCell(3);
	bool IgnoreCD = GetNativeCell(4);
	
	if (CF_GetAbilityCooldown(client, CF_AbilityType_Ult) > 0.0 && !IgnoreCD)
		return;
	
	CFCharacter chara = GetCharacterFromClient(client);
	if (type != CF_ResourceType_Generic)
	{
		switch(type)
		{
			case CF_ResourceType_Regen:
			{
				amt *= chara.f_UltChargeOnRegen;
			}
			case CF_ResourceType_DamageDealt:
			{
				amt *= chara.f_UltChargeOnDamage;
			}
			case CF_ResourceType_DamageTaken:
			{
				amt *= chara.f_UltChargeOnHurt;
			}
			case CF_ResourceType_Healing:
			{
				amt *= chara.f_UltChargeOnHeal;
			}
			case CF_ResourceType_Kill:
			{
				amt *= chara.f_UltChargeOnKill;
			}
			case CF_ResourceType_Percentage:
			{
				amt = chara.f_UltChargeRequired * amt * 0.01;
			}
			case CF_ResourceType_BuildingDamage:
			{
				amt *= chara.f_UltChargeOnBuildingDamage;
			}
			case CF_ResourceType_Destruction:
			{
				amt *= chara.f_UltChargeOnDestruction;
			}
		}
	}
	
	Call_StartForward(g_UltChargeGiven);
	
	Call_PushCell(client);
	Call_PushFloatRef(amt);
	
	Action result;
	Call_Finish(result);

	if (result != Plugin_Handled && result != Plugin_Stop)
		CF_SetUltCharge(client, chara.f_UltCharge + amt, IgnoreCD);
}

public Native_CF_SetUltCharge(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!IsValidClient(client))
		return;
		
	float amt = GetNativeCell(2);
	
	bool IgnoreCD = GetNativeCell(3);
	
	CFCharacter chara = GetCharacterFromClient(client);

	if (CF_GetAbilityCooldown(client, CF_AbilityType_Ult) > 0.0 && !IgnoreCD)
		return;
	
	Call_StartForward(g_UltChargeApplied);
	
	Call_PushCell(client);
	Call_PushFloat(chara.f_UltCharge);
	Call_PushFloatRef(amt);
	
	Action result;
	Call_Finish(result);
	
	if (result != Plugin_Handled && result != Plugin_Stop)
	{
		if (amt < 0.0)
			amt = 0.0;
			
		if (amt >= chara.f_UltChargeRequired)
		{
			amt = chara.f_UltChargeRequired;
		}
		
		float oldCharge = chara.f_UltCharge;
		chara.f_UltCharge = amt;

		if (oldCharge < chara.f_UltChargeRequired && chara.f_UltCharge >= chara.f_UltChargeRequired)
		{
			CF_PlayRandomSound(client, client, "sound_ultimate_ready");
		}
	}
}

public void CFA_UltMessage(int client)
{
	CFCharacter chara = GetCharacterFromClient(client);
	CFAbility ab = GetAbilityFromClient(client, CF_AbilityType_Ult);
	if (chara == null || ab == null)
		return;

	float charge = chara.f_UltCharge / chara.f_UltChargeRequired;
	char message[255], ultName[255];
	ab.GetName(ultName, 255);
	TFTeam team = TF2_GetClientTeam(client);
	Format(message, sizeof(message), "%s%N{default}: My {olive}%s{default} is ", (team == TFTeam_Red ? "{red}" : "{blue}"), client, ultName);

	if (charge >= 1.0)
	{
		Format(message, sizeof(message), "%s{green}FULLY CHARGED{default}!", message);
		CF_PlayRandomSound(client, client, "sound_ultimate_ready");
	}
	else
	{
		Format(message, sizeof(message), "%s{yellow}%iPCNTG{default} charged!", message, RoundToFloor(100.0 * charge));
		ReplaceString(message, sizeof(message), "PCNTG", "%%");
		CF_PlayRandomSound(client, client, "sound_ultimate_not_ready_callout");
	}

	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidMulti(i, false, _, true, team))
			CPrintToChat(i, message);
	}

	CF_PlayRandomSound(client, client, "sound_ultimate_ready");
}

public any Native_CF_GetUltCharge(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return 0.0;
	
	return GetCharacterFromClient(client).f_UltCharge;
}

public Native_CF_GiveSpecialResource(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return;
		
	CFCharacter chara = GetCharacterFromClient(client);

	if (!chara.b_UsingResources || chara.b_ResourceIsUlt)
		return;
		
	float amt = GetNativeCell(2);
	CF_ResourceType type = GetNativeCell(3);
	
	if (type != CF_ResourceType_Generic)
	{
		switch(type)
		{
			case CF_ResourceType_Regen:
			{
				amt *= chara.f_ResourcesOnRegen;
			}
			case CF_ResourceType_DamageDealt:
			{
				amt *= chara.f_ResourcesOnDamage;
			}
			case CF_ResourceType_DamageTaken:
			{
				amt *= chara.f_ResourcesOnHurt;
			}
			case CF_ResourceType_Healing:
			{
				amt *= chara.f_ResourcesOnHeal;
			}
			case CF_ResourceType_Kill:
			{
				amt *= chara.f_ResourcesOnKill;
			}
			case CF_ResourceType_Percentage:
			{
				amt = chara.f_MaxResources * amt * 0.01;
			}
			case CF_ResourceType_BuildingDamage:
			{
				amt *= chara.f_ResourcesOnBuildingDamage;
			}
			case CF_ResourceType_Destruction:
			{
				amt *= chara.f_ResourcesOnDestruction;
			}
		}
	}
	
	Call_StartForward(g_ResourceGiven);
	
	Call_PushCell(client);
	Call_PushFloatRef(amt);
	
	Action result;
	Call_Finish(result);
	
	if (result != Plugin_Handled && result != Plugin_Stop && amt != 0.0)
		CF_SetSpecialResource(client, CF_GetSpecialResource(client) + amt);
}

public Native_CF_SetSpecialResource(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return;
		
	CFCharacter chara = GetCharacterFromClient(client);

	if (!chara.b_UsingResources || chara.b_ResourceIsUlt)
		return;
		
	float amt = GetNativeCell(2);
	
	Call_StartForward(g_ResourceApplied);
	
	Call_PushCell(client);
	Call_PushFloat(CF_GetSpecialResource(client));
	Call_PushFloatRef(amt);
	
	Action result;
	Call_Finish(result);
	
	if (result != Plugin_Handled && result != Plugin_Stop)
	{
		if (amt < 0.0)
			amt = 0.0;
			
		if (amt >= chara.f_MaxResources && chara.f_MaxResources > 0.0)
		{
			amt = chara.f_MaxResources;
		}
		
		float oldResources = CF_GetSpecialResource(client);

		chara.f_Resources = amt;
		if (chara.b_ResourceIsMetal)
			SetEntProp(client, Prop_Send, "m_iAmmo", RoundFloat(chara.f_Resources), 4, 3);
		
		if (amt != oldResources)
		{
			if (amt > oldResources && chara.f_ResourcesToTriggerSound > 0.0)
			{
				float diff = amt - oldResources;
				chara.f_ResourcesSinceLastGain += diff;
				if (chara.f_ResourcesSinceLastGain >= chara.f_ResourcesToTriggerSound)
				{
					chara.f_ResourcesSinceLastGain -= chara.f_ResourcesToTriggerSound;
					
					CF_PlayRandomSound(client, client, "sound_resource_gained");
				}
			}
			
			/*CF_ActivateAbilitySlot(client, 7);
			
			if (amt > oldResources)
				CF_ActivateAbilitySlot(client, 5);
			else
				CF_ActivateAbilitySlot(client, 6);*/
		}
	}
}

public any Native_CF_GetSpecialResource(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return 0.0;
		
	CFCharacter chara = GetCharacterFromClient(client);

	if (!chara.b_UsingResources || chara.b_ResourceIsUlt)
		return 0.0;
	
	if (chara.b_ResourceIsMetal)
		return float(GetEntProp(client, Prop_Data, "m_iAmmo", 4, 3));
		
	return chara.f_Resources;
}

public any Native_CF_GetMaxSpecialResource(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return 0.0;
		
	CFCharacter chara = GetCharacterFromClient(client);
	if (!chara.b_UsingResources || chara.b_ResourceIsUlt)
		return 0.0;
	
	return chara.f_MaxResources;
}

public Native_CF_SetMaxSpecialResource(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	float amt = GetNativeCell(2);
	
	if (!CF_IsPlayerCharacter(client))
		return;
		
	CFCharacter chara = GetCharacterFromClient(client);

	if (!chara.b_UsingResources || chara.b_ResourceIsUlt)
		return;
	
	chara.f_MaxResources = amt;
}

public Native_CF_ApplyAbilityCooldown(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return;
		
	float cd = GetNativeCell(2);
	CF_AbilityType type = GetNativeCell(3);
	bool override = GetNativeCell(4);
	bool delay = GetNativeCell(5);
	
	float gameTime = GetGameTime();
	
	if (delay)
	{
		DataPack pack = new DataPack();
		RequestFrame(ApplyCDOnDelay, pack);
		WritePackCell(pack, GetClientUserId(client));
		WritePackFloat(pack, gameTime);
		WritePackCell(pack, type);
		WritePackFloat(pack, cd);
		WritePackCell(pack, override);
	}
	else
	{
		CFAbility ab = GetAbilityFromClient(client, type);
		if (ab != null)
			ab.f_NextUseTime = (override || GetGameTime() >= ab.f_NextUseTime) ? gameTime + cd : ab.f_NextUseTime + cd;
	}
}

public void ApplyCDOnDelay(DataPack pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	float gameTime = ReadPackFloat(pack);
	CF_AbilityType type = ReadPackCell(pack);
	float cd = ReadPackFloat(pack);
	bool override = ReadPackCell(pack);
	delete pack;
	
	if (!IsValidClient(client))
		return;

	CFAbility ab = GetAbilityFromClient(client, type);
	if (ab != null)
		ab.f_NextUseTime = (override || GetGameTime() >= ab.f_NextUseTime) ? gameTime + cd : ab.f_NextUseTime + cd;
}

public any Native_CF_GetAbilityCooldown(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return 0.0;

	CF_AbilityType type = GetNativeCell(2);
	
	float gameTime = GetGameTime();
	CFAbility ab = GetAbilityFromClient(client, type);
	if (ab == null)
		return 0.0;

	return gameTime >= ab.f_NextUseTime ? 0.0 : ab.f_NextUseTime - gameTime;
}

public Native_CF_DoAbility(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return;
		
	char abName[255], pluginName[255];
	GetNativeString(2, pluginName, sizeof(pluginName));
	GetNativeString(3, abName, sizeof(abName));
	
	Call_StartForward(g_OnAbility);
		
	Call_PushCell(client);
	Call_PushString(pluginName);
	Call_PushString(abName);
	
	Call_Finish();
}

public Native_CF_DoAbilitySlot(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return;

	CFCharacter chara = GetCharacterFromClient(client);

	if (chara.g_Effects == null)
		return;

	int slot = GetNativeCell(2);
	char pluginName[255], abName[255];
	for (int i = 0; i < GetArraySize(chara.g_Effects); i++)
	{
		CFEffect effect = view_as<CFEffect>(GetArrayCell(chara.g_Effects, i));
		if (effect.i_AbilitySlot == slot)
		{
			effect.GetPluginName(pluginName, 255);
			effect.GetAbilityName(abName, 255);
			CF_DoAbility(client, pluginName, abName);
		}
	}
}

public Native_CF_ActivateAbilitySlot(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int slot = GetNativeCell(2);
	
	if (!CF_IsPlayerCharacter(client))
		return;

	CFAbility ab = GetAbilityFromClient(client, view_as<CF_AbilityType>(slot - 1));
	if (ab == null)
		return;
		
	if (!ab.b_HeldAbility)
		SubtractStock(client, view_as<CF_AbilityType>(slot - 1));

	CF_DoAbilitySlot(client, ab.i_AbilitySlot);
}

public any Native_CF_CheckIsSlotBlocked(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int slot = GetNativeCell(2);
	
	if (!CF_IsPlayerCharacter(client))
		return true;
		
	bool result = ScanAllAbilities(client, slot);
	
	return result;
}

public bool ScanAllAbilities(int client, int slot)
{	
	bool result = false;
		
	CFCharacter chara = GetCharacterFromClient(client);
	for (int i = 0; i < GetArraySize(chara.g_Effects); i++)
	{
		CFEffect effect = view_as<CFEffect>(GetArrayCell(chara.g_Effects, i));
		if (effect == null || effect.i_AbilitySlot != slot)
			continue;

		char abName[255], plugName[255];
		effect.GetPluginName(plugName, 255);
		effect.GetAbilityName(abName, 255);

		Call_StartForward(g_AttemptAbility);
			
		Call_PushCell(client);
		Call_PushString(plugName);
		Call_PushString(abName);
		Call_PushCell(view_as<CF_AbilityType>(slot - 1));
		Call_PushCellRef(result);
			
		Action diditwork;
		Call_Finish(diditwork);
			
		if (diditwork == Plugin_Changed && !result)
		{
			return true;
		}
	}
	
	return false;
}

public Native_CF_EndHeldAbilitySlot(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return;
		
	int slot = GetNativeCell(2);
	bool resupply = GetNativeCell(3);
	
	char pluginName[255], abName[255];
		
	CFCharacter chara = GetCharacterFromClient(client);

	if (chara.g_Effects != null)
	{
		for (int i = 0; i < GetArraySize(chara.g_Effects); i++)
		{
			CFEffect effect = view_as<CFEffect>(GetArrayCell(chara.g_Effects, i));
			if (effect.i_AbilitySlot == slot)
			{
				effect.GetAbilityName(abName, 255)
				effect.GetPluginName(pluginName, 255);

				Call_StartForward(g_OnHeldEnd_Ability);
			
				Call_PushCell(client);
				Call_PushCell(resupply);
				Call_PushString(pluginName);
				Call_PushString(abName);
			
				Call_Finish();
			}
		}
	}
	
	EndHeldAbility(client, view_as<CF_AbilityType>(slot - 1), false, resupply);
}

public Native_CF_EndHeldAbility(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return;
		
	char pluginName[255], abName[255];
	GetNativeString(2, pluginName, sizeof(pluginName));
	GetNativeString(3, abName, sizeof(abName));
	bool resupply = GetNativeCell(4);
	
	Call_StartForward(g_OnHeldEnd_Ability);
			
	Call_PushCell(client);
	Call_PushCell(resupply);
	Call_PushString(pluginName);
	Call_PushString(abName);
		
	Call_Finish();
}

public void Nope(int client)
{
	EmitSoundToClient(client, NOPE);
}

public Native_CF_HasAbility(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return false;
		
	char targetPlugin[255], targetAbility[255];
		
	GetNativeString(2, targetPlugin, sizeof(targetPlugin));
	GetNativeString(3, targetAbility, sizeof(targetAbility));
		
	CFEffect effect = GetEffectFromAbility(client, targetPlugin, targetAbility);
	if (effect == null)
		return false;

	return effect.b_Exists;
}

public CFEffect GetEffectFromAbility(int client, char[] plugin, char[] ability)
{
	CFCharacter chara = GetCharacterFromClient(client);
	if (chara != null && chara.g_Effects != null)
	{
		char pluginName[255]; char abName[255];
		for (int i = 0; i < GetArraySize(chara.g_Effects); i++)
		{
			CFEffect effect = GetEffect(client, i);
			effect.GetPluginName(pluginName, 255);
			effect.GetAbilityName(abName, 255);

			if (!StrEqual(plugin, pluginName) || !StrEqual(ability, abName))
				continue;

			return effect;
		}
	}

	return null;
}

public CFEffect GetEffect(int client, int slot)
{
	return view_as<CFEffect>(GetArrayCell(GetCharacterFromClient(client).g_Effects, slot));
}

public Native_CF_GetArgI(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int defaultVal = GetNativeCell(5);
	
	if (!CF_IsPlayerCharacter(client))
		return defaultVal;
		
	if (GetCharacterFromClient(client).g_Effects == null)
		return defaultVal;

	char targetPlugin[255], targetAbility[255], argName[255];
		
	GetNativeString(2, targetPlugin, sizeof(targetPlugin));
	GetNativeString(3, targetAbility, sizeof(targetAbility));
	GetNativeString(4, argName, sizeof(argName));

	CFEffect effect = GetEffectFromAbility(client, targetPlugin, targetAbility);
	if (effect != null)
		return effect.GetArgI(argName, defaultVal);
	
	return defaultVal;
}

public any Native_CF_GetArgF(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	float defaultVal = GetNativeCell(5);
	
	if (!CF_IsPlayerCharacter(client))
		return defaultVal;

	if (GetCharacterFromClient(client).g_Effects == null)
		return defaultVal;
		
	char targetPlugin[255], targetAbility[255], argName[255];
		
	GetNativeString(2, targetPlugin, sizeof(targetPlugin));
	GetNativeString(3, targetAbility, sizeof(targetAbility));
	GetNativeString(4, argName, sizeof(argName));
		
	CFEffect effect = GetEffectFromAbility(client, targetPlugin, targetAbility);
	if (effect != null)
		return effect.GetArgF(argName, defaultVal);
	
	return defaultVal;
}

public any Native_CF_GetAbilitySlot(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return CF_AbilityType_None;
		
	char targetPlugin[255], targetAbility[255];
		
	GetNativeString(2, targetPlugin, sizeof(targetPlugin));
	GetNativeString(3, targetAbility, sizeof(targetAbility));

	CFEffect effect = GetEffectFromAbility(client, targetPlugin, targetAbility);
	if (effect != null)
		return view_as<CF_AbilityType>(effect.i_AbilitySlot - 1);
	
	return CF_AbilityType_None;
}

public Native_CF_GetArgS(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int size = GetNativeCell(6);
	
	char defaultValue[255];
	GetNativeString(7, defaultValue, 255);

	if (!CF_IsPlayerCharacter(client))
	{
		SetNativeString(5, defaultValue, size, false);
		return;
	}
		
	char targetPlugin[255], targetAbility[255], argName[255];
		
	GetNativeString(2, targetPlugin, sizeof(targetPlugin));
	GetNativeString(3, targetAbility, sizeof(targetAbility));
	GetNativeString(4, argName, sizeof(argName));

	CFEffect effect = GetEffectFromAbility(client, targetPlugin, targetAbility);
	if (effect != null)
	{
		char result[255];
		effect.GetArgS(argName, result, 255, defaultValue);
		SetNativeString(5, result, size, false);
		return;
	}

	SetNativeString(5, defaultValue, size, false);
}

public Native_CF_GetAbilityConfigMapPath(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int length = GetNativeCell(6);
	
	if (!CF_IsPlayerCharacter(client))
	{
		SetNativeString(5, "", length);
		return;
	}
		
	char targetPlugin[255], targetAbility[255], section[255];

	GetNativeString(2, targetPlugin, sizeof(targetPlugin));
	GetNativeString(3, targetAbility, sizeof(targetAbility));
	GetNativeString(4, section, sizeof(section));

	CFEffect effect = GetEffectFromAbility(client, targetPlugin, targetAbility);
	if (effect != null)
	{
		char path[255], abIndex[255];
		effect.GetAbilityIndex(abIndex, 255);
		Format(path, sizeof(path), "character.abilities.%s.%s", abIndex, section);
		SetNativeString(5, path, length);
		return;
	}

	SetNativeString(5, "", length);
}

public any Native_CF_IsAbilitySlotBlocked(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	CF_AbilityType type = GetNativeCell(2);
	
	if (!CF_IsPlayerCharacter(client))
		return false;

	CFAbility ab = GetAbilityFromClient(client, type);
	if (ab == null)
		return false;

	return ab.b_Blocked;
}

public Native_CF_BlockAbilitySlot(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	CF_AbilityType type = GetNativeCell(2);
	
	if (!CF_IsPlayerCharacter(client))
		return;

	CFAbility ab = GetAbilityFromClient(client, type);
	if (ab != null)
		ab.b_Blocked = true;
}

public Native_CF_UnblockAbilitySlot(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	CF_AbilityType type = GetNativeCell(2);
	
	if (!CF_IsPlayerCharacter(client))
		return;

	CFAbility ab = GetAbilityFromClient(client, type);
	if (ab != null)
		ab.b_Blocked = false;
}

public Native_CF_SetHUDColor(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int r = GetNativeCell(2);
	int g = GetNativeCell(3);
	int b = GetNativeCell(4);
	int a = GetNativeCell(5);
	
	if (!CF_IsPlayerCharacter(client))
		return;
		
	if (r >= 0)
		i_HUDR[client] = r;
	if (g >= 0)
		i_HUDG[client] = g;
	if (b >= 0)
		i_HUDB[client] = b;	
	if (a >= 0)
		i_HUDA[client] = a;
}

public Native_CF_HealPlayer(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int healer = GetNativeCell(2);
	int amt = GetNativeCell(3);
	float hpMult = GetNativeCell(4);
	
	if (!IsValidMulti(client))
		return;
		
	int maxHP = TF2Util_GetEntityMaxHealth(client);
	int totalMax = RoundFloat(float(maxHP) * hpMult);
	int current = GetEntProp(client, Prop_Send, "m_iHealth");
	
	int healingDone = amt;
	
	if (current < totalMax)
	{
		int newHP = current + amt;
		if (newHP > totalMax)
		{
			int diff = newHP - totalMax;
			newHP -= diff;
			healingDone -= diff;
		}
		
		SetEntProp(client, Prop_Send, "m_iHealth", newHP);
	}
	else
	{
		healingDone = 0;
	}
	
	if (healingDone > 0 && IsValidClient(healer) && healer != client)
	{
		CFA_GiveChargesForHealing(healer, float(healingDone));
		
		CFA_AddHealingPoints(healer, healingDone);
	}
}

public Native_CF_HealPlayer_WithAttributes(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int healer = GetNativeCell(2);
	int amt = GetNativeCell(3);
	float hpMult = GetNativeCell(4);
	
	if (!IsValidMulti(client))
		return;

	float multiplier = GetTotalAttributeValue(client, 854, 1.0) * GetTotalAttributeValue(client, 69, 1.0) * GetTotalAttributeValue(client, 70, 1.0);
	float amtFloat = float(amt);
	amtFloat *= multiplier;
	amt = RoundFloat(amtFloat);
	
	CF_HealPlayer(client, healer, amt, hpMult);
}

public void CFA_GiveChargesForHealing(int healer, float healingDone)
{
	CF_GiveUltCharge(healer, healingDone, CF_ResourceType_Healing);
	CF_GiveSpecialResource(healer, healingDone, CF_ResourceType_Healing);
}

public Native_CF_FireGenericRocket(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!IsValidClient(client))
		return -1;
	
	float dmg = GetNativeCell(2);
	float velocity = GetNativeCell(3);
	bool crit = GetNativeCell(4);
	bool allowAlliedCollisions = GetNativeCell(5);
	char pluginName[255];
	GetNativeString(6, pluginName, sizeof(pluginName));
	Function logic = GetNativeFunction(7);
	float forwardDistance = 20.0 * CF_GetCharacterScale(client);
	
	int rocket = CreateEntityByName("tf_projectile_rocket");
	
	if (IsValidEntity(rocket))
	{
		int iTeam = GetClientTeam(client);
		
		SetEntPropEnt(rocket, Prop_Send, "m_hOwnerEntity", client);
		SetEntProp(rocket,    Prop_Send, "m_bCritical", view_as<int>(crit));
		SetEntProp(rocket,    Prop_Send, "m_iTeamNum",     iTeam, 1);
		SetEntData(rocket, FindSendPropInfo("CTFProjectile_Rocket", "m_nSkin"), (iTeam-2), 1, true);
		SetEntDataFloat(rocket, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected") + 4, dmg, true);
		
		SetVariantInt(iTeam);
		AcceptEntityInput(rocket, "TeamNum", -1, -1, 0);
		
		SetVariantInt(iTeam);
		AcceptEntityInput(rocket, "SetTeam", -1, -1, 0); 
		
		DispatchSpawn(rocket);
			
		float spawnLoc[3], angles[3], rocketVel[3], vBuffer[3];
		GetClientEyePosition(client, spawnLoc);
		GetClientEyeAngles(client, angles);
			
		GetAngleVectors(angles, vBuffer, NULL_VECTOR, NULL_VECTOR);
		
		rocketVel[0] = vBuffer[0]*velocity;
		rocketVel[1] = vBuffer[1]*velocity;
		rocketVel[2] = vBuffer[2]*velocity;
			
		if (forwardDistance != 0.0)
		{
			float fLen = forwardDistance * Sine( DegToRad( angles[0] + 90.0 ) );
			spawnLoc[0] = spawnLoc[0] + fLen * Cosine( DegToRad( angles[1] + 0.0) );
			spawnLoc[1] = spawnLoc[1] + fLen * Sine( DegToRad( angles[1] + 0.0) );
			spawnLoc[2] = spawnLoc[2] + forwardDistance * Sine( DegToRad( -1 * (angles[0] + 0.0)) );
		}
		TeleportEntity(rocket, spawnLoc, angles, rocketVel);
		
		b_ProjectileCanCollideWithAllies[rocket] = allowAlliedCollisions;
		s_ProjectileLogicPlugin[rocket] = pluginName;
		g_ProjectileLogic[rocket] = logic;
		
		if (!StrEqual(pluginName, "") && logic != INVALID_FUNCTION)
		{
			SDKHook(rocket, SDKHook_TouchPost, GenericProjectile_OnTouch);
			g_DHookRocketExplode.HookEntity(Hook_Pre, rocket, GenericProjectile_Explode);
		}
		
		return rocket;
	}
	
	return -1;
}

public void GenericProjectile_OnTouch(int rocket, int other)
{
	if (!CollisionGroupIsSolid(other, true))
		return;

	Handle plugin = GetPluginHandle(s_ProjectileLogicPlugin[rocket]);
	if (plugin != null)
	{
		float pos[3];
		GetEntPropVector(rocket, Prop_Send, "m_vecOrigin", pos);

		Call_StartFunction(plugin, g_ProjectileLogic[rocket]);
			
		Call_PushCell(rocket);
		Call_PushCell(GetEntPropEnt(rocket, Prop_Send, "m_hOwnerEntity"));
		Call_PushCell(GetEntProp(rocket, Prop_Send, "m_iTeamNum"));
		Call_PushCell(other);
		Call_PushArray(pos, 3);
			
		Call_Finish();
	}
}

public MRESReturn GenericProjectile_Explode(int rocket)
{
	/*if (!StrEqual(s_ProjectileLogicPlugin[rocket], "") && g_ProjectileLogic[rocket] != INVALID_FUNCTION)
	{
		Handle plugin = GetPluginHandle(s_ProjectileLogicPlugin[rocket]);
		if (plugin != null)
		{
			MRESReturn ReturnValue = MRES_Ignored;
			
			Call_StartFunction(plugin, g_ProjectileLogic[rocket]);
			
			Call_PushCell(rocket);
			Call_PushCell(GetEntPropEnt(rocket, Prop_Send, "m_hOwnerEntity"));
			Call_PushCell(GetEntProp(rocket, Prop_Send, "m_iTeamNum"));
			
			Call_Finish(ReturnValue);
			
			return ReturnValue;
		}
	}*/
	
	//return MRES_Ignored;
	return MRES_Supercede;
}

int entityBeingTraced = -1;
public bool CF_AOETrace(entity, contentsmask)
{
	if (!CF_DefaultTrace(entity, contentsmask))
		return false;
		
	return entity != entityBeingTraced;
}

ArrayList AOE_Hits = null;

public Native_CF_GenericAOEDamage(Handle plugin, int numParams)
{
	int attacker = GetNativeCell(1);
	
	if (!IsValidEntity(attacker))
		return;
		
	int inflictor = GetNativeCell(2);
	int weapon = GetNativeCell(3);
	float dmg = GetNativeCell(4);
	int damageType = GetNativeCell(5);
	float radius = GetNativeCell(6);
	float groundZero[3];
	GetNativeArray(7, groundZero, sizeof(groundZero));
	float falloffStart = GetNativeCell(8);
	float falloffMax = GetNativeCell(9);
	bool skipDefault = GetNativeCell(10);
	bool includeUser = GetNativeCell(11);
	bool ignoreInvuln = GetNativeCell(12);
	char pluginName[255], hitPlugin[255];
	GetNativeString(13, pluginName, sizeof(pluginName));
	Function logic = GetNativeFunction(14);
	GetNativeString(15, hitPlugin, sizeof(hitPlugin));
	Function hitLogic = GetNativeFunction(16);

	delete AOE_Hits;
	AOE_Hits = CreateArray(255);
	
	#if defined _pnpc_included_
	PNPC_Explosion(groundZero, radius, dmg, falloffStart, radius, falloffMax, inflictor, weapon, attacker, damageType, skipDefault, ignoreInvuln, includeUser, logic, pluginName, hitLogic, hitPlugin);
	#else
	TR_EnumerateEntitiesSphere(groundZero, radius, PARTITION_NON_STATIC_EDICTS, GenericAOE_Trace, attacker);
	
	for (int i = 0; i < GetArraySize(AOE_Hits); i++)
	{
		int victim = EntRefToEntIndex(GetArrayCell(AOE_Hits, i));
		if (IsValidEntity(victim))
		{
			if (IsValidClient(victim))
			{
				if (!IsPlayerAlive(victim) || (IsInvuln(victim) && !ignoreInvuln) || (victim == attacker && !includeUser))
					continue;
			}

			if (!GetEntProp(victim, Prop_Data, "m_takedamage") && !ignoreInvuln)
				continue;
			
			float vicLoc[3];
			GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", vicLoc);
			if (CF_IsPlayerCharacter(victim))
				vicLoc[2] += 40.0 * CF_GetCharacterScale(victim);

			float dist = GetVectorDistance(groundZero, vicLoc);

			if (dist > radius)
				continue;
			
			bool passed = true;
					
			if (!skipDefault)
			{
				entityBeingTraced = victim;
				Handle trace = TR_TraceRayFilterEx(groundZero, vicLoc, MASK_PLAYERSOLID_BRUSHONLY, RayType_EndPoint, CF_AOETrace);
				passed = !TR_DidHit(trace);
				delete trace;
			}
			
			float realDMG = dmg;
			if (dist > falloffStart)
			{
				realDMG *= 1.0 - (((dist - falloffStart) / (radius - falloffStart)) * falloffMax);
			}
						
			//If the weapon is valid and the victim is a building or prop_physics, deal damage multiplied by building damage attributes:
			if (IsValidEntity(weapon))
			{
				char classname[255];
				GetEntityClassname(victim, classname, sizeof(classname));

				if (GetEntSendPropOffs(weapon, "m_AttributeList") > 0 && (StrEqual(classname, "obj_sentrygun") || StrEqual(classname, "obj_dispenser")
				|| StrEqual(classname, "obj_teleporter") || StrContains(classname, "prop_physics") != -1))
				{
					realDMG *= GetAttributeValue(weapon, 137, 1.0) * GetAttributeValue(weapon, 775, 1.0);
				}
			}

			if (logic != INVALID_FUNCTION && !StrEqual(pluginName, ""))
			{
				Call_StartFunction(GetPluginHandle(pluginName), logic);
				Call_PushCell(victim);
				Call_PushCellRef(attacker);
				Call_PushCellRef(inflictor);
				Call_PushCellRef(weapon);
				Call_PushFloatRef(realDMG);
				Call_Finish(passed);
			}
					
			if (passed)
			{
				if (hitLogic != INVALID_FUNCTION && !StrEqual(hitPlugin, ""))
				{
					Call_StartFunction(GetPluginHandle(hitPlugin), hitLogic);
					Call_PushCell(victim);
					Call_PushCellRef(attacker);
					Call_PushCellRef(inflictor);
					Call_PushCellRef(weapon);
					Call_PushFloatRef(realDMG);
					Call_Finish();
				}

				SDKHooks_TakeDamage(victim, inflictor, attacker, realDMG, damageType, weapon, _, groundZero, false);
			}
		}
	}
	
	delete AOE_Hits;
	#endif
}

public bool GenericAOE_Trace(int entity, int attacker)
{
	if (!HasEntProp(entity, Prop_Send, "m_iTeamNum"))
		return true;
		
	int targTeam = GetEntProp(attacker, Prop_Send, "m_iTeamNum");
	
	if (GetEntProp(entity, Prop_Send, "m_iTeamNum") != targTeam || (entity == attacker))
	{
		PushArrayCell(AOE_Hits, EntIndexToEntRef(entity));
		return true;
	}
	
	return true;
}

public Action CH_ShouldCollide(int ent1, int ent2, bool &result)
{
	Action ReturnVal = Plugin_Continue;
	bool CallForward = true;
	
	//First test: only allow simulated health kits to collide with the world.
	if (b_IsFakeHealthKit[ent1] || b_IsFakeHealthKit[ent2])
	{
		bool block = ent1 != 0 && ent2 != 0;
		
		if (block)
		{
			result = false;
			ReturnVal = Plugin_Changed;
			CallForward = false;
		}
	}
	
	//Second test: only allow simulated medigun shields to collide with entities on the opposite team.
	if (b_IsMedigunShield[ent1] || b_IsMedigunShield[ent2])
	{
		bool block = MediShield_Collision(ent1, ent2);
		
		if (block)
		{
			result = false;
			ReturnVal = Plugin_Changed;
			CallForward = false;
		}
	}

	//Third test: don't allow projectiles to collide with each other:
	if (b_IsProjectile[ent1] || b_IsProjectile[ent2])
	{
		if (b_IsProjectile[ent1] && b_IsProjectile[ent2])
		{
			result = false;
			ReturnVal = Plugin_Changed;
			CallForward = false;
		}
		//Fourth test: don't allow projectiles to collide with phys props which have m_takedamage disabled:
		else if ((b_IsPhysProp[ent2] && !GetEntProp(ent2, Prop_Data, "m_takedamage")) || (b_IsPhysProp[ent1] && !GetEntProp(ent1, Prop_Data, "m_takedamage")))
		{
			result = false;
			ReturnVal = Plugin_Changed;
			CallForward = false;
		}
	}
	
	if (CallForward)
	{
		Call_StartForward(g_ShouldCollide);
		
		Call_PushCell(ent1);
		Call_PushCell(ent2);
		Call_PushCellRef(result);
		
		Call_Finish(ReturnVal);
	}
	
	return ReturnVal;
}

public void MediShield_CollisionForward(int ent1, int ent2, int owner)
{
	float gt = GetGameTime();
	if (gt > f_NextShieldCollisionForward[ent1][ent2])
	{
		Call_StartForward(g_FakeMediShieldCollision);
		
		Call_PushCell(ent1);
		Call_PushCell(ent2);
		Call_PushCell(owner);
		
		Call_Finish();
		
		f_NextShieldCollisionForward[ent1][ent2] = gt + 0.2;
	}
}

public void MediShield_DamageForward(int shield, int attacker, int inflictor, float &damage, int &damagetype, int owner)
{
	Call_StartForward(g_FakeMediShieldDamaged);
	
	Call_PushCell(shield);
	Call_PushCell(attacker);
	Call_PushCell(inflictor);
	Call_PushFloatRef(damage);
	Call_PushCellRef(damagetype);
	Call_PushCell(owner);
	
	Action returnVal;
	Call_Finish(returnVal);
}

public Action CH_PassFilter(int ent1, int ent2, bool &result)
{
	Action ReturnVal = Plugin_Continue;
	bool CallForward = true;

	if (ent1 < 0 || ent1 > 2048 || ent2 < 0 || ent2 > 2048)
		return Plugin_Continue;

	//First test: don't allow projectiles to collide with each other:
	if (b_IsProjectile[ent1] && b_IsProjectile[ent2])
	{
		result = false;
		ReturnVal = Plugin_Changed;
		CallForward = false;
	}
	//Second test: don't allow TF2 projectiles to collide with their owners or players who are on their owner's team:
	else if (IsValidClient(GetClientOfUserId(i_GenericProjectileOwner[ent1])))
	{
		TFTeam team = view_as<TFTeam>(GetEntProp(ent1, Prop_Send, "m_iTeamNum"));
		int owner = GetEntPropEnt(ent1, Prop_Send, "m_hOwnerEntity");
		if (ent2 == owner || (CF_IsValidTarget(ent2, team) && !b_ProjectileCanCollideWithAllies[ent1]))
		{
			result = false;
			ReturnVal = Plugin_Changed;
			CallForward = false;
		}
	}
	else if (IsValidClient(GetClientOfUserId(i_GenericProjectileOwner[ent2])))
	{
		TFTeam team = view_as<TFTeam>(GetEntProp(ent2, Prop_Send, "m_iTeamNum"));
		int owner = GetEntPropEnt(ent2, Prop_Send, "m_hOwnerEntity");
		if (ent1 == owner || (CF_IsValidTarget(ent1, team) && !b_ProjectileCanCollideWithAllies[ent2]))
		{
			result = false;
			ReturnVal = Plugin_Changed;
			CallForward = false;
		}
	}
	
	//Third test: don't allow fake health kits to collide with ANYTHING except for world geometry.
	if (b_IsFakeHealthKit[ent1] || b_IsFakeHealthKit[ent2])
	{
		bool block = ent1 != 0 && ent2 != 0;
		
		if (block)
		{
			result = false;
			ReturnVal = Plugin_Changed;
			CallForward = false;
		}
	}
	
	//Fourth test: only allow simulated medigun shields to collide with entities on the opposite team.
	if (b_IsMedigunShield[ent1] || b_IsMedigunShield[ent2])
	{
		bool block = MediShield_Collision(ent1, ent2);
		
		if (block)
		{
			result = false;
			ReturnVal = Plugin_Changed;
			CallForward = false;
		}
	}
		
	if (CallForward)
	{
		Call_StartForward(g_PassFilter);
		
		Call_PushCell(ent1);
		Call_PushCell(ent2);
		Call_PushCellRef(result);
		
		Call_Finish(ReturnVal);
	}
	
	return ReturnVal;
}

public Native_CF_CreateShieldWall(Handle plugin, int numParams)
{
	int owner = GetNativeCell(1);
	char model[255], skin[16];
	GetNativeString(2, model, sizeof(model));
	GetNativeString(3, skin, sizeof(skin));
	float scale = GetNativeCell(4);
	float health = GetNativeCell(5);
	float pos[3], ang[3];
	GetNativeArray(6, pos, sizeof(pos));
	GetNativeArray(7, ang, sizeof(ang));
	float lifespan = GetNativeCell(8);
	
	int prop = CreateEntityByName("prop_physics_multiplayer");
	if (IsValidEntity(prop))
	{
		DispatchKeyValue(prop, "targetname", "shield"); 
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
		char healthChar[16];
		Format(healthChar, sizeof(healthChar), "%i", RoundFloat(health));
		DispatchKeyValue(prop, "Health", healthChar);
		SetEntityHealth(prop, RoundFloat(health));
		f_FakeMediShieldHP[prop] = health;
		f_FakeMediShieldMaxHP[prop] = health;
		
		char scalechar[16];
		Format(scalechar, sizeof(scalechar), "%f", scale);
		DispatchKeyValue(prop, "modelscale", scalechar);
		
		b_IsMedigunShield[prop] = true;
		SetEntityGravity(prop, 0.0);
		
		SDKHook(prop, SDKHook_OnTakeDamage, Shield_OnTakeDamage);
		SDKHook(prop, SDKHook_Touch, Shield_OnTouch);
		
		if (lifespan > 0.0)
		{
			CreateTimer(lifespan, Timer_RemoveEntity, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE);
		}
		
		TeleportEntity(prop, pos, ang, NULL_VECTOR);
		
		for (int i = 0; i <= 2048; i++)
		{
			f_NextShieldCollisionForward[prop][i] = 0.0;
		}
	}
	
	return prop;
}

public Action Shield_OnTouch(int shield, int collider)
{
	int owner = GetEntPropEnt(shield, Prop_Data, "m_hOwnerEntity");
	MediShield_CollisionForward(shield, collider, owner);
	return Plugin_Continue;
}

public Action Shield_OnTakeDamage(int prop, int &attacker, int &inflictor, float &damage, int &damagetype) 
{
	int owner = GetEntPropEnt(prop, Prop_Data, "m_hOwnerEntity");
	
	if (IsValidClient(owner) && IsValidMulti(attacker, false, _, true, TF2_GetClientTeam(owner)))
	{
		damage = 0.0;
	}
	else
	{
		MediShield_DamageForward(prop, attacker, inflictor, damage, damagetype, owner);
	}
	
	f_FakeMediShieldHP[prop] -= damage;
	if (f_FakeMediShieldHP[prop] < 0.0)
	{
		RemoveEntity(prop);
	}
	
	damage = 0.0;
	
	return Plugin_Changed;
}

bool MediShield_Collision(int ent1, int ent2)
{
	//Neither entity is a medigun shield, don't modify collision.
	if (!b_IsMedigunShield[ent1] && !b_IsMedigunShield[ent2])
		return false;
		
	//Block collision if a medigun shield is colliding with the world.
	if (b_IsMedigunShield[ent1] && ent2 == 0 || b_IsMedigunShield[ent2] && ent1 == 0)
		return true;
		
	int team1 = GetEntProp(ent1, Prop_Send, "m_iTeamNum");
	int team2 = GetEntProp(ent2, Prop_Send, "m_iTeamNum");
	
	//The entity being collided with is not the world, block collision if the entities are on the same team.
	return team1 == team2;
}

public any Native_CF_GetShieldWallHealth(Handle plugin, int numParams)
{
	int shield = GetNativeCell(1);
	
	if (!IsValidEntity(shield))
		return 0.0;
		
	if (!b_IsMedigunShield[shield])
		return 0.0;
		
	return f_FakeMediShieldHP[shield];
}

public Native_CF_ChangeAbilityTitle(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	CF_AbilityType type = GetNativeCell(2);
	char newName[255];
	GetNativeString(3, newName, sizeof(newName));
	
	if (!CF_IsPlayerCharacter(client) || type > CF_AbilityType_Reload)
		return;

	CFAbility ab = GetAbilityFromClient(client, type);
	if (ab != null)
		ab.SetName(newName);
}

public Native_CF_GetAbilityTitle(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	CF_AbilityType type = GetNativeCell(2);
	
	if (!CF_IsPlayerCharacter(client))
		return;

	CFAbility ab = GetAbilityFromClient(client, type);
	if (ab != null)
	{
		char name[255];
		ab.GetName(name, 255);
		SetNativeString(3, name, 255);
	}
	
	SetNativeString(3, "", 255);
}

public Native_CF_ChangeSpecialResourceTitle(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	char newName[255], newNamePlural[255];
	GetNativeString(2, newName, sizeof(newName));
	GetNativeString(3, newNamePlural, sizeof(newNamePlural));
	
	if (!CF_IsPlayerCharacter(client))
		return;
		
	CFCharacter chara = GetCharacterFromClient(client);
	chara.SetResourceName(newName);
	chara.SetResourceNamePlural(newNamePlural);
}

public Native_CF_GetSpecialResourceTitle(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return;
		
	char name[255], namePlural[255];
	CFCharacter chara = GetCharacterFromClient(client);
	chara.GetResourceName(name, 255);
	chara.GetResourceNamePlural(namePlural, 255);
	SetNativeString(2, name, 255);
	SetNativeString(3, namePlural, 255);
}

public any Native_CF_CheckTeleport(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	float distance = GetNativeCell(2); 
	bool directional = GetNativeCell(3);
	float override[3];
	GetNativeArray(5, override, sizeof(override));
	bool UseOverride = GetNativeCell(6);
	
	if (!IsValidMulti(client))
		return false;
		
	float pos[3];
	bool result = DPT_TryTeleport(client, distance, directional, pos, false, override, UseOverride);
	SetNativeArray(4, pos, sizeof(pos));
	return result;
}

public Native_CF_Teleport(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	float distance = GetNativeCell(2); 
	bool directional = GetNativeCell(3);
	bool IgnoreSafety = GetNativeCell(5);
	float override[3];
	GetNativeArray(6, override, sizeof(override));
	bool UseOverride = GetNativeCell(7);
	
	if (!IsValidMulti(client))
		return;
		
	float pos[3];
	bool result = DPT_TryTeleport(client, distance, directional, pos, IgnoreSafety, override, UseOverride);
	SetNativeArray(4, pos, sizeof(pos));
	
	if (result)
	{
		float eyeAngles[3];
		GetClientEyeAngles(client, eyeAngles);
		
		int buttons = GetClientButtons(client);
		if (buttons & IN_DUCK != 0)
		{
			if (directional)
			{
				bool left = buttons & IN_LEFT != 0 && buttons & IN_RIGHT == 0;
				bool right = buttons & IN_RIGHT != 0 && buttons & IN_LEFT == 0;
				
				float flipmod = 0.0;
				
				if (left)
				{
					flipmod = 90.0;
				}
				else if (right)
				{
					flipmod = -90.0;
				}
				
				if (flipmod > 0.0)
				{
					eyeAngles[1] += -flipmod * 2.0;
				}
				else
				{
					if (buttons & IN_BACK != 0 && buttons & IN_FORWARD == 0)
					{
						eyeAngles[0] += 180.0;
					}
					else
					{
						eyeAngles[1] += 180.0;
					}
				}
			}
			else
			{
				eyeAngles[1] += 180.0;
			}
		}
		
		TeleportEntity(client, pos, eyeAngles, NULL_VECTOR);
	}
}

public any Native_CF_GetShieldWallMaxHealth(Handle plugin, int numParams)
{
	int shield = GetNativeCell(1);
	
	if (!IsValidEntity(shield))
		return 0.0;
		
	if (!b_IsMedigunShield[shield])
		return 0.0;
		
	return f_FakeMediShieldMaxHP[shield];
}

public Native_CF_ApplyTemporarySpeedChange(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int mode = GetNativeCell(2);
	float amt = GetNativeCell(3);
	float duration = GetNativeCell(4);
	int maxMode = GetNativeCell(5);
	float maxSpeed = GetNativeCell(6);
	bool sound = GetNativeCell(7);
	
	if (!CF_IsPlayerCharacter(client))
		return;
		
	float baseSpeed = CF_GetCharacterBaseSpeed(client);
	float currentSpeed = CF_GetCharacterSpeed(client);

	float targetSpeed;
	switch (mode)
	{
		case 1:
			targetSpeed = currentSpeed + ((baseSpeed * amt) - baseSpeed);
		case 2:
			targetSpeed = currentSpeed * amt;
		default:
			targetSpeed = currentSpeed + amt;
	}
		
	if (maxMode != 0)
	{
		float targetMax = maxSpeed;
		if (maxMode == 1)
			targetMax *= baseSpeed;

		//We only cap targetSpeed if it is faster than the user's current speed, because that means this speed change is meant to be a buff.
		//We don't want buffs to slow people down just because they already have a stronger buff active.
		if (targetSpeed > targetMax && targetSpeed > currentSpeed)
			targetSpeed = targetMax;
	}
	
	float speedGained = targetSpeed - currentSpeed;
	if (speedGained != 0.0)
	{
		CF_SetCharacterSpeed(client, targetSpeed);
		
		if (duration > 0.0)
		{
			DataPack pack = new DataPack();
			WritePackCell(pack, GetClientUserId(client));
			WritePackFloat(pack, speedGained);
			WritePackFloat(pack, GetGameTime() + duration);
			WritePackCell(pack, sound);
			RequestFrame(TempSpeed_Check, pack);
		}
	}
	
	if (sound)
		EmitSoundToClient(client, SOUND_SPEED_APPLY);
}

public void TempSpeed_Check(DataPack pack)
{
	ResetPack(pack);
	
	int client = GetClientOfUserId(ReadPackCell(pack));
	float speedGained = ReadPackFloat(pack);
	float endTime = ReadPackFloat(pack);
	bool sound = ReadPackCell(pack);
	
	//f_CancelTemporarySpeedMod is used so that we don't revert speed if the client becomes a new character before the speed is set to revert.
	if (!CF_IsPlayerCharacter(client) || GetGameTime() < f_CancelTemporarySpeedMod[client])
	{
		delete pack;
		return;
	}
	
	if (GetGameTime() >= endTime)
	{
		float current = CF_GetCharacterSpeed(client);
		CF_SetCharacterSpeed(client, current - speedGained);
		
		if (sound)
			EmitSoundToClient(client, SOUND_SPEED_REMOVE);
		
		delete pack;
		return;
	}
	
	RequestFrame(TempSpeed_Check, pack);
}

public Native_CF_ToggleHUD(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	bool toggle = GetNativeCell(2);
	
	CFA_ToggleHUD(client, toggle);
}

public Native_CF_WorldSpaceCenter(Handle plugin, int numParams)
{
	int entity = GetNativeCell(1);
	float output[3];
	GetNativeArray(2, output, sizeof(output));
	
	if (!IsValidEntity(entity))
		return;
		
	SDKCall(g_hSDKWorldSpaceCenter, entity, output);
	SetNativeArray(2, output, sizeof(output));
}

public Native_CF_CreatePickup(Handle plugin, int numParams)
{
	int owner = GetNativeCell(1);
	float radius = GetNativeCell(2);
	float lifespan = GetNativeCell(3);

	char model[255], physModel[255], filterPlugin[255], pickupPlugin[255], sequence[255];
	Function pickupFunction = GetNativeFunction(4);
	GetNativeString(5, pickupPlugin, 255);

	float pos[3], ang[3], vel[3];
	GetNativeArray(6, pos, 3);
	GetNativeArray(7, ang, 3);
	GetNativeArray(8, vel, 3);

	float scale = GetNativeCell(9);
	
	GetNativeString(10, model, 255);
	GetNativeString(11, sequence, 255);
	GetNativeString(12, physModel, 255);

	int skin = GetNativeCell(13);
	Function filterFunction = GetNativeFunction(14);
	GetNativeString(15, filterPlugin, 255);

	int phys = SpawnPhysProp(owner, physModel, pos, ang, vel, _, _, _, _, _, _, true);
	if (!IsValidEntity(phys))
		return -1;

	if (!StrEqual(model, ""))
	{
		int prop = CreateEntityByName("prop_dynamic_override");
		if (!IsValidEntity(prop))
			return -1;

		SetEntPropEnt(prop, Prop_Data, "m_hOwnerEntity", owner);
		SetEntityModel(prop, model);
		char scalechar[16];
		Format(scalechar, sizeof(scalechar), "%f", scale);
		DispatchKeyValue(prop, "modelscale", scalechar);
		DispatchKeyValue(prop, "StartDisabled", "false");
						
		DispatchSpawn(prop);
						
		AcceptEntityInput(prop, "Enable");
		TeleportEntity(prop, pos, ang, NULL_VECTOR);
			
		DispatchKeyValue(prop, "spawnflags", "1");
		SetVariantString("!activator");
		AcceptEntityInput(prop, "SetParent", phys);
			
		SetVariantString(sequence);
		AcceptEntityInput(prop, "SetAnimation");
		DispatchKeyValueFloat(prop, "playbackrate", 1.0);
		char skinchar[16];
		Format(skinchar, sizeof(skinchar), "%i", skin);
		DispatchKeyValue(prop, "skin", skinchar);

		SetEntProp(phys, Prop_Send, "m_fEffects", 32);

		if (lifespan > 0.0)
			CreateTimer(lifespan, Pickup_BeginFade, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE);
	}

	b_IsFakeHealthKit[phys] = true;

	if (lifespan > 0.0)
		CreateTimer(lifespan, Pickup_BeginFade, EntIndexToEntRef(phys), TIMER_FLAG_NO_MAPCHANGE);

	DataPack pack = new DataPack();
	CreateDataTimer(0.1, Pickup_Scan, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack, IsValidClient(owner) ? GetClientUserId(owner) : -1);
	WritePackCell(pack, EntIndexToEntRef(phys));
	WritePackFunction(pack, filterFunction);
	WritePackString(pack, filterPlugin);
	WritePackFunction(pack, pickupFunction);
	WritePackString(pack, pickupPlugin);
	WritePackFloat(pack, radius);

	return phys;
}

public Action Pickup_Scan(Handle timer, DataPack pack)
{
	ResetPack(pack);
	int owner = GetClientOfUserId(ReadPackCell(pack));
	int pickup = EntRefToEntIndex(ReadPackCell(pack));
	Function filterFunction = ReadPackFunction(pack);
	char filterPlugin[255], pickupPlugin[255];
	ReadPackString(pack, filterPlugin, 255);
	Function pickupFunction = ReadPackFunction(pack);
	ReadPackString(pack, pickupPlugin, 255);
	float radius = ReadPackFloat(pack);

	if (!IsValidEntity(pickup))
		return Plugin_Stop;

	float pos[3];
	GetEntPropVector(pickup, Prop_Send, "m_vecOrigin", pos);

	int closest = -1;
	float closestDist = 999999.0;
	for (int i = 1; i <= 2048; i++)
	{
		if (!Entity_Can_Be_Shot(i) || i == pickup)
			continue;

		float theirPos[3];
		if (IsValidClient(i))
			GetClientAbsOrigin(i, theirPos);
		else
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", theirPos);
		
		float dist = GetVectorDistance(pos, theirPos);
		if (dist >= closestDist || dist > radius)
			continue;

		bool success = true;
		if (!StrEqual(filterPlugin, "") && filterFunction != INVALID_FUNCTION)
		{
			Call_StartFunction(GetPluginHandle(filterPlugin), filterFunction);

			Call_PushCell(owner);
			Call_PushCell(pickup);
			Call_PushCell(i);

			Call_Finish(success);
		}

		if (success)
		{
			closest = i;
			closestDist = dist;
		}
	}

	if (IsValidEntity(closest))
	{
		Call_StartFunction(GetPluginHandle(pickupPlugin), pickupFunction);

		Call_PushCell(owner);
		Call_PushCell(pickup);
		Call_PushCell(closest);

		Call_Finish();

		RemoveEntity(pickup);

		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public Action Pickup_BeginFade(Handle timer, int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (IsValidEntity(ent))
		MakeEntityFadeOut(ent, 2);

	return Plugin_Continue;
}

float Medigun_HealBucket[MAXPLAYERS + 1] = { 0.0, ... };

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
	{
		SDKUnhook(client, SDKHook_PreThink, Medigun_PreThink);
		return Plugin_Stop;
	}
	
	int target = GetEntPropEnt(medigun, Prop_Send, "m_hHealingTarget");
	if (IsValidEntity(target) && target > 0)
	{
		float amt = Medigun_CalculateHealRate(medigun, client) / 63.0;
		CFA_GiveChargesForHealing(client, amt);
		
		Medigun_HealBucket[client] += amt;
		if (Medigun_HealBucket[client] >= 1.0)
		{
			int heals = RoundToFloor(Medigun_HealBucket[client]);
			float remainder = Medigun_HealBucket[client] - float(heals);
			
			CFA_AddHealingPoints(client, heals);
			Medigun_HealBucket[client] = remainder;
		}
	}
	
	return Plugin_Continue;
}

//Note that this does not account for crit heals.
float Medigun_CalculateHealRate(int medigun, int client)
{
	float BaseHealingRate = 24.0;
	BaseHealingRate *= GetAttributeValue(medigun, 7, 1.0);
	BaseHealingRate *= GetAttributeValue(medigun, 8, 1.0);
	float mastery = 0.25 * GetAttributeValue(medigun, 493, 0.0);
	BaseHealingRate *= (1.0 + mastery);
	
	if (TF2_IsPlayerInCondition(client, TFCond_RuneHaste))
		BaseHealingRate *= 2.0;
		
	if (TF2_IsPlayerInCondition(client, TFCond_KingAura) || TF2_IsPlayerInCondition(client, TFCond_KingRune))
		BaseHealingRate *= 1.5;

	if (GetAttributeValue(medigun, 231, 0.0) > 0.0 && TF2_IsPlayerInCondition(client, TFCond_MegaHeal))
		BaseHealingRate *= 3.0;
		
	return BaseHealingRate;
}

public Native_CF_IsValidTarget(Handle plugin, int numParams)
{
	int entity = GetNativeCell(1);
	TFTeam team = GetNativeCell(2);
	char pluginName[255];
	GetNativeString(3, pluginName, sizeof(pluginName));
	Function filter = GetNativeFunction(4);
	
	if (!IsValidEntity(entity) || IsPayloadCart(entity))
		return false;
		
	if (team != TFTeam_Unassigned)
	{
		if (!HasEntProp(entity, Prop_Send, "m_iTeamNum"))
			return false;
			
		TFTeam entTeam = view_as<TFTeam>(GetEntProp(entity, Prop_Send, "m_iTeamNum"));
		if (team != entTeam)
			return false;
	}

	if (b_IsPhysProp[entity])
	{
		if (!GetEntProp(entity, Prop_Data, "m_takedamage"))
			return false;
	}
	else
	{
		if (!Entity_Can_Be_Shot(entity))
			return false;
	}
	
	if (!StrEqual(pluginName, "") || filter != INVALID_FUNCTION)
	{
		Handle FunctionPlugin = GetPluginHandle(pluginName);
	
		bool result;
			
		if (FunctionPlugin == INVALID_HANDLE)
		{
			result = true;
		}
		else
		{
			Call_StartFunction(FunctionPlugin, filter);
				
			Call_PushCell(entity);
				
			Call_Finish(result);
		}
		
		delete FunctionPlugin;
		
		return result;
	}
	
	return true;
}

public Native_CF_GetClosestTarget(Handle plugin, int numParams)
{
	float pos[3];
	GetNativeArray(1, pos, sizeof(pos));
	
	bool IncludeEntities = GetNativeCell(2);
	
	float closestDist = GetNativeCellRef(3);
	float maxDist = GetNativeCell(4);
	TFTeam team = GetNativeCell(5);
	char pluginName[255];
	GetNativeString(6, pluginName, sizeof(pluginName));
	Function filter = GetNativeFunction(7);
	bool useAbs = GetNativeCell(8);
	
	int closestEnt = -1;
	
	for (int i = 1; i <= (IncludeEntities ? 2048 : MaxClients); i++)
	{
		if (!CF_IsValidTarget(i, team, pluginName, filter))
			continue;
		
		float otherPos[3];
		if (useAbs)
		{
			if (IsValidClient(i))
				GetClientAbsOrigin(i, otherPos);
			else
				GetEntPropVector(i, Prop_Data, "m_vecAbsOrigin", otherPos);
		}
		else
			CF_WorldSpaceCenter(i, otherPos);
		
		float dist = GetVectorDistance(pos, otherPos);
		
		if (maxDist > 0.0 && dist > maxDist)
			continue;
			
		if (dist < closestDist || closestEnt == -1)
		{
			closestDist = dist;
			closestEnt = i;
		}
	}
	
	return closestEnt;
}

bool b_BlockFireballs[MAXPLAYERS + 1] = { false, ... };
bool b_Casting[MAXPLAYERS + 1] = { false, ... };

public Native_CF_SimulateSpellbookCast(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	char atts[255];
	GetNativeString(2, atts, sizeof(atts));
	CF_SpellIndex index = GetNativeCell(3);
	bool instant = GetNativeCell(5);
	if (instant)
	{
		if (StrEqual(atts, ""))
			Format(atts, sizeof(atts), "178 ; 0.0");
		else
			Format(atts, sizeof(atts), "%s ; 178 ; 0.0", atts);
	}
	
	int weapon = TF2_GetActiveWeapon(client);
	if (!IsValidEntity(weapon))
		return;
		
	char classname[255];
	GetEntityClassname(weapon, classname, sizeof(classname));
	Format(classname, sizeof(classname), "use %s", classname);
	
	TF2_RemoveWeaponSlot(client, 5);
	int spellbook = CF_SpawnWeapon(client, "tf_weapon_spellbook", 1070, 77, 7, 5, 0, 0, atts);
	if (!IsValidEntity(spellbook))
		return;
		
	FakeClientCommand(client, "use tf_weapon_spellbook");
			
	b_BlockFireballs[client] = GetNativeCell(4);
	b_Casting[client] = true;
			
	SetEntProp(spellbook, Prop_Send, "m_iSpellCharges", 1);
	SetEntProp(spellbook, Prop_Send, "m_iSelectedSpellIndex", view_as<int>(index));
	
	DataPack pack = new DataPack();
	CreateDataTimer(0.3, DeleteSimulatedSpellbook, pack, TIMER_FLAG_NO_MAPCHANGE);	//TODO: 0.3 is a magic number and will break shit if the user decides to mess with the spellbook's deploy time. Figure out a different way to remove the spellbook after it is done casting. Also need to prevent weapon switching during the cast.
	WritePackCell(pack, GetClientUserId(client));
	WritePackString(pack, classname);
}

public Action DeleteSimulatedSpellbook(Handle deletethebook, DataPack pack)
{
	ResetPack(pack);
	
	int client = GetClientOfUserId(ReadPackCell(pack));
	char command[255];
	ReadPackString(pack, command, sizeof(command));
	
	if (!IsValidMulti(client))
		return Plugin_Continue;
		
	FakeClientCommand(client, command);
	TF2_RemoveWeaponSlot(client, 5);
	
	return Plugin_Continue;
}

public void CFA_OnEntityCreated(int entity, const char[] classname)
{
	if (StrContains(classname, "tf_projectile") != -1)
	{
		SDKHook(entity, SDKHook_SpawnPost, GetOwner);
		b_IsProjectile[entity] = true;
		b_ProjectileCanCollideWithAllies[entity] = StrEqual(classname, "tf_projectile_healing_bolt") || StrEqual(classname, "tf_projectile_arrow");
	}

	if (StrContains(classname, "prop_physics") != -1)
	{
		b_IsPhysProp[entity] = true;
	}
	
	if (StrContains(classname, "tf_projectile_spell") != -1)
	{
		SDKHook(entity, SDKHook_SpawnPost, OnSpellSpawn);
	}
}

public Action OnSpellSpawn(int ent)
{
	if (!IsValidEntity(ent))
		return Plugin_Continue;
		
	int owner = GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	if (!IsValidClient(owner))
		return Plugin_Continue;
	
	if (!b_Casting[owner])
		return Plugin_Continue;
	
	int entity = ent;
	
	if (b_BlockFireballs[owner])
	{	
		entity = -1;
		TeleportEntity(ent, OFF_THE_MAP, NULL_VECTOR, NULL_VECTOR);
		AcceptEntityInput(ent, "Kill");
		RemoveEntity(ent);
			
		b_BlockFireballs[owner] = false;
	}
	
	Call_StartForward(g_SimulatedSpellCast);
	
	Call_PushCell(owner);
	Call_PushCell(entity);
	
	Call_Finish();
	
	b_Casting[owner] = false;
	
	return Plugin_Continue;
}

bool IsCasting(int client) { return b_Casting[client]; }

bool b_VMBlockSwitch[MAXPLAYERS + 1] = { false, ... };

float f_VMAnimEndTime[MAXPLAYERS + 1] = { 0.0, ... };

//TODO: Make this work with custom weapon models.
public Native_CF_ForceViewmodelAnimation(Handle plugin, int numParams)
{
	return 0;
	/*int client = GetNativeCell(1);
	char activity[255];
	GetNativeString(2, activity, sizeof(activity));
	bool hideWeapon = GetNativeCell(3);
	bool blockAttack = GetNativeCell(4);
	bool blockWeaponSwitch = GetNativeCell(5);
	
	int ent = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
	if (!IsValidEntity(ent))
		return;
		
	CBaseAnimating viewmodel = CBaseAnimating(ent);
	int sequence = viewmodel.LookupSequence(activity);
	if (sequence == -1)
		return;
		
	float duration = viewmodel.SequenceDuration(sequence);
	
	viewmodel.ResetSequence(sequence);
	
	float gt = GetGameTime();
	f_VMAnimEndTime[client] = gt + duration;
	b_VMHideWeapon[client] = hideWeapon;
	b_VMBlockSwitch[client] = blockWeaponSwitch;
	b_VMBlockAttack[client] = blockAttack;
	Format(VMAnim_ForcedSequence[client], 255, "%s", activity);
	
	if (blockAttack)
	{
		VMAnim_BlockAttacks(client);
	}
	
	if (hideWeapon)
	{	
		int fakeVM = CreateEntityByName("tf_wearable_vm");
		if (IsValidEntity(fakeVM))
		{
			int team = GetEntProp(client, Prop_Send, "m_iTeamNum");
			
			SetEntProp(ent, Prop_Send, "m_fEffects", GetEntProp(ent, Prop_Send, "m_fEffects") | EF_NODRAW);
			
			SetEntProp(fakeVM, Prop_Send, "m_nModelIndex", GetEntProp(ent, Prop_Send, "m_nModelIndex"));
			SetEntProp(fakeVM, Prop_Send, "m_fEffects", 129);
			SetEntProp(fakeVM, Prop_Send, "m_iTeamNum", team);
			SetEntProp(fakeVM, Prop_Send, "m_nSkin", team-2);
			SetEntProp(fakeVM, Prop_Send, "m_usSolidFlags", 4);
			SetEntityCollisionGroup(fakeVM, 11);
			SetEntProp(fakeVM, Prop_Send, "m_bValidatedAttachedEntity", 1);
				
			DispatchSpawn(fakeVM);
			SetVariantString("!activator");
			ActivateEntity(fakeVM);

			VMAnim_FakeVM[client] = EntIndexToEntRef(fakeVM);

			SDKCall_EquipWearable(client, fakeVM);
		}
	}
	
	RequestFrame(VMAnim_Check, GetClientUserId(client));*/
}

public void VMAnim_BlockAttacks(int client)
{
	for (int i = 0; i <= 5; i++)
	{
		int weapon = GetPlayerWeaponSlot(client, i);
			
		if (IsValidEntity(weapon))
		{
			float nextAttack = GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack");
			if (nextAttack < f_VMAnimEndTime[client])
			{
				nextAttack = f_VMAnimEndTime[client] + 0.1;
				SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", nextAttack);
			}
				
			//TODO: Repeat for secondary and special attacks
		}
	}
}

/*public void VMAnim_Check(int id)
{
	int client = GetClientOfUserId(id);
	if (!IsValidMulti(client))
		return;
		
	float gt = GetGameTime();
	float timePerFrame = 0.01587302;
	
	if (gt + timePerFrame >= f_VMAnimEndTime[client])
	{
		if (b_VMHideWeapon[client])
		{
			int fakeVM = EntRefToEntIndex(VMAnim_FakeVM[client]);
			if (IsValidEntity(fakeVM))
			{
				TF2_RemoveWearable(client, fakeVM);
			}
			int ent = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
			if (IsValidEntity(ent))
			{
				SetEntProp(ent, Prop_Send, "m_fEffects", GetEntProp(ent, Prop_Send, "m_fEffects") &~ EF_NODRAW);
			}
			
			b_VMHideWeapon[client] = false;
		}
		b_VMBlockSwitch[client] = false;
		
		Call_StartForward(g_ForcedVMAnimEnd);
		
		Call_PushCell(client);
		Call_PushString(VMAnim_ForcedSequence[client]);
		
		Call_Finish();
		
		return;
	}
	else	//We do this every frame instead of just once at the start because otherwise other plugins may interfere.
	{
		if (b_VMBlockAttack[client])
			VMAnim_BlockAttacks(client);
	}
	
	RequestFrame(VMAnim_Check, id);
}*/

public Action CFA_WeaponCanSwitch(int client, int weapon)
{
    if (!b_VMBlockSwitch[client])
    	return Plugin_Continue;
    	
    if (GetGameTime() <= f_VMAnimEndTime[client])
    	return Plugin_Handled;
    	
    return Plugin_Continue;
} 

public Native_CF_SetAbilityStocks(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	CF_AbilityType type = GetNativeCell(2);
	int numStocks = GetNativeCell(3);
	bool ignoreMax = GetNativeCell(4);

	if (!CF_IsPlayerCharacter(client))
		return;

	if (!AbilityUsesStocks(client, type))
		return;

	CFAbility ab = GetAbilityFromClient(client, type);
	if (ab == null)
		return;

	ab.i_Stocks = numStocks;
	if (ab.i_Stocks > ab.i_MaxStocks && !ignoreMax)
		ab.i_Stocks = ab.i_MaxStocks;

	if (ab.i_Stocks < ab.i_MaxStocks && CF_GetAbilityCooldown(client, type) <= 0.0)
		CF_ApplyAbilityCooldown(client, ab.f_Cooldown, type, true);
}

public Native_CF_SetAbilityMaxStocks(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	CF_AbilityType type = GetNativeCell(2);
	int numStocks = GetNativeCell(3);

	if (!CF_IsPlayerCharacter(client))
		return;

	CFAbility ab = GetAbilityFromClient(client, type);
	if (ab == null)
		return;

	ab.i_MaxStocks = numStocks;

	if (ab.i_Stocks < ab.i_MaxStocks && CF_GetAbilityCooldown(client, type) <= 0.0)
		CF_ApplyAbilityCooldown(client, ab.f_Cooldown, type, true);
}

public Native_CF_GetAbilityStocks(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	CF_AbilityType type = GetNativeCell(2);
	CFAbility ab = GetAbilityFromClient(client, type);
	if (ab == null)
		return 0;

	return ab.i_Stocks;
}

public Native_CF_GetAbilityMaxStocks(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	CF_AbilityType type = GetNativeCell(2);
	CFAbility ab = GetAbilityFromClient(client, type);
	if (ab == null)
		return 0;

	return ab.i_MaxStocks;
}

public Native_CF_StartLagCompensation(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	SDKCall_StartLagCompensation(client);
}

public Native_CF_EndLagCompensation(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	SDKCall_FinishLagCompensation(client);
}

public Native_CF_SetLocalOrigin(Handle plugin, int numParams)
{
	int index = GetNativeCell(1);
	float localOrigin[3];
	GetNativeArray(2, localOrigin, 3);
	SDKCall_SetLocalOrigin(index, localOrigin);
}

ArrayList BulletTrace_Hits = null;
TFTeam BulletTrace_Team;
char BulletTrace_Plugin[255];
Function BulletTrace_Filter;

public any Native_CF_DoBulletTrace(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	float startPos[3], endPos[3], hitPos[3];
	GetNativeArray(2, startPos, sizeof(startPos));
	GetNativeArray(3, endPos, sizeof(endPos));
	hitPos = endPos;
	int maxPen = GetNativeCell(4);
	BulletTrace_Team = GetNativeCell(5);
	GetNativeString(6, BulletTrace_Plugin, sizeof(BulletTrace_Plugin));
	BulletTrace_Filter = GetNativeFunction(7);

	delete BulletTrace_Hits;
	BulletTrace_Hits = new ArrayList();
	ArrayList returnVal = new ArrayList();

	if (IsValidClient(client))
		CF_StartLagCompensation(client);

	TR_TraceRayFilter(startPos, endPos, MASK_SHOT, RayType_EndPoint, CF_BulletFilter);

	if (GetArraySize(BulletTrace_Hits) < 1)
	{
		delete BulletTrace_Hits;
	}
	else
	{
		delete returnVal;
		returnVal = SortListByDistance(startPos, BulletTrace_Hits);
		delete BulletTrace_Hits;

		for (int i = 0; i < GetArraySize(returnVal); i++)
		{
			int vic = GetArrayCell(returnVal, i);
			TR_TraceRayFilter(startPos, endPos, MASK_SHOT, RayType_EndPoint, CF_OnlyHitTarget, vic);
			if (TR_GetFraction() >= 1.0/*TR_GetHitBoxIndex() == 0 && TR_GetHitGroup() != HITGROUP_GENERIC && TR_GetHitGroup() != HITGROUP_HEAD*/)
			{
				//bool hs;
				//CF_TraceShot(client, vic, startPos, endPos, hs, false);
				//if (!hs)
				//{
					RemoveFromArray(returnVal, i);
				//}
			}
		}

		if (GetArraySize(returnVal) >= maxPen + 1)
		{
			while (GetArraySize(returnVal) > maxPen + 1)
				RemoveFromArray(returnVal, GetArraySize(returnVal) - 1);

			int vic = GetArrayCell(returnVal, GetArraySize(returnVal) - 1);
			CF_TraceShot(client, vic, startPos, endPos, _, false, hitPos);
		}
	}

	SetNativeArray(8, hitPos, sizeof(hitPos));
	if (IsValidClient(client))
		CF_EndLagCompensation(client);

	return returnVal;
}

public bool CF_BulletFilter(int entity, int contentsmask)
{
	if (CF_IsValidTarget(entity, BulletTrace_Team, BulletTrace_Plugin, BulletTrace_Filter))
		PushArrayCell(BulletTrace_Hits, entity);

	return false;
}

public any Native_CF_TraceShot(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int target = GetNativeCell(2);
	float startPos[3], endPos[3], hitPos[3];
	GetNativeArray(3, startPos, sizeof(startPos));
	GetNativeArray(4, endPos, sizeof(endPos));
	hitPos = endPos;
	bool doLagComp = GetNativeCell(6);

	if (!IsValidEntity(target) || target < 0 || target > 2048)
		return 0;

	if (IsValidClient(client) && doLagComp)
		CF_StartLagCompensation(client);

	Handle trace = TR_TraceRayFilterEx(startPos, endPos, MASK_SHOT, RayType_EndPoint, CF_OnlyHitTarget, target);

	if (IsValidClient(client) && doLagComp)
		CF_EndLagCompensation(client);

	bool hs = false;
	if (TR_GetFraction(trace) < 1.0)
	{
		target = TR_GetEntityIndex(trace);
		if (target > 0)
		{
			hs = (TR_GetHitGroup(trace) == HITGROUP_HEAD);
		}
	}

	TR_GetEndPosition(hitPos, trace);
	SetNativeArray(7, hitPos, sizeof(hitPos));
	SetNativeCellRef(5, hs);

	delete trace;

	return 0;
}

public Native_CF_FireGenericBullet(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if (!IsValidClient(client))
		return;
		
	float ang[3];
	GetNativeArray(2, ang, sizeof(ang));
	float damage = GetNativeCell(3);
	float hsMult = GetNativeCell(4);
	float spread = GetNativeCell(5);
	char hitPlugin[255], checkPlugin[255], particle[255];
	GetNativeString(6, hitPlugin, sizeof(hitPlugin));
	Function hitFunction = GetNativeFunction(7);
	float falloffStart = GetNativeCell(8);
	float falloffEnd = GetNativeCell(9);
	float falloffMax = GetNativeCell(10);
	int pierce = GetNativeCell(11);
	TFTeam checkTeam = GetNativeCell(12);
	GetNativeString(13, checkPlugin, sizeof(checkPlugin));
	Function checkFunction = GetNativeFunction(14);
	GetNativeString(15, particle, sizeof(particle));

	float startPos[3], endPos[3], shootPos[3], hitPos[3], shootAng[3];
	GetClientAbsOrigin(client, startPos);
	startPos[2] += 60.0 * CF_GetCharacterScale(client);

	for (int i = 0; i < 3; i++)
		shootAng[i] = ang[i] + GetRandomFloat(-spread, spread);

	GetPointInDirection(startPos, shootAng, 20.0, shootPos);

	GetClientEyePosition(client, startPos);
	GetPointInDirection(startPos, shootAng, 9999.0, endPos);

	if (!CF_HasLineOfSight(startPos, endPos, _, endPos))
	{
		float eyePos[3];
		GetClientEyePosition(client, eyePos);
		UTIL_ImpactTrace(client, eyePos, DMG_BULLET);
	}

	ArrayList victims = CF_DoBulletTrace(client, startPos, endPos, pierce, checkTeam, checkPlugin, checkFunction, hitPos);
	SpawnParticle_ControlPoints(shootPos, hitPos, particle, 2.0);

	bool crit = (TF2_IsPlayerInCondition(client, TFCond_CritCanteen) || TF2_IsPlayerInCondition(client, TFCond_CritMmmph) || TF2_IsPlayerInCondition(client, TFCond_CritOnDamage) || TF2_IsPlayerInCondition(client, TFCond_CritOnFirstBlood) || 
	TF2_IsPlayerInCondition(client, TFCond_CritOnFlagCapture) || TF2_IsPlayerInCondition(client, TFCond_CritOnKill) || TF2_IsPlayerInCondition(client, TFCond_CritOnWin) || TF2_IsPlayerInCondition(client, TFCond_CritRuneTemp) ||
	TF2_IsPlayerInCondition(client, TFCond_Kritzkrieged));

	for (int i = 0; i < GetArraySize(victims); i++)
	{
		int vic = GetArrayCell(victims, i);

		bool hs, allowFalloff = true;
		
		int hsEffect = 2;
		CF_TraceShot(client, vic, startPos, endPos, hs, _, hitPos);
		float damageToDeal = damage * (hs ? hsMult : 1.0);

		if (!StrEqual(hitPlugin, "") && hitFunction != INVALID_FUNCTION)
		{
			Handle FunctionPlugin = GetPluginHandle(hitPlugin);

			if (FunctionPlugin != INVALID_HANDLE)
			{
				Call_StartFunction(FunctionPlugin, hitFunction);

				Call_PushCell(client);
				Call_PushCell(vic);
				Call_PushFloatRef(damageToDeal);
				Call_PushCellRef(allowFalloff);
				Call_PushCellRef(hs);
				Call_PushCellRef(hsEffect);
				Call_PushCellRef(crit);
				Call_PushArray(hitPos, sizeof(hitPos));

				Call_Finish();
			}
		}

		int weapon = TF2_GetActiveWeapon(client);

		if (allowFalloff && falloffMax != 0.0)
		{
			if (IsValidEntity(weapon) && crit)
			{
				allowFalloff = GetAttributeValue(weapon, 868, 0.0) > 0.0;
			}

			if (allowFalloff)
			{
				float dist = GetVectorDistance(startPos, hitPos);

				float mult = 1.0;

				if (dist >= falloffEnd)
					mult = 1.0 - falloffMax;
				else if (dist > falloffStart)
				{
					dist -= falloffStart;
					float maxDist = falloffEnd - falloffStart;
					mult = 1.0 - ((dist / maxDist) * falloffMax);
				}

				damageToDeal *= mult;
			}
		}

		if ((hs && hsEffect > 0) || crit)
		{
			if (hs)
				headshotKill = true;

			if (hsEffect == 1 && !crit)
			{
				EmitSoundToAll(g_MiniCritHits[GetRandomInt(0, sizeof(g_MiniCritHits) - 1)], vic);
				EmitSoundToClient(client, g_MiniCritHits[GetRandomInt(0, sizeof(g_MiniCritHits) - 1)]);
				SpawnParticle(hitPos, PARTICLE_MINICRIT, 2.0);
				miniCritHit = true;
			}
			else if (crit || hsEffect >= 2)
			{
				EmitSoundToAll(g_CritHits_Victim[GetRandomInt(0, sizeof(g_CritHits_Victim) - 1)], vic);
				EmitSoundToClient(client, g_CritHits[GetRandomInt(0, sizeof(g_CritHits) - 1)]);
				SpawnParticle(hitPos, PARTICLE_CRIT, 2.0);
				critHit = true;
			}
		}

		if (crit && !IsABuilding(vic))
		{
			damageToDeal *= 3.0;
			//if (IsValidEntity(weapon))	//TODO
			//	damageToDeal *= GetAttributeValue(weapon, )
		}

		if (IsValidEntity(weapon) && IsABuilding(vic))
		{
			damage *= GetAttributeValue(weapon, 137, 1.0) * GetAttributeValue(weapon, 775, 1.0);
		}

		SDKHooks_TakeDamage(vic, client, client, damageToDeal, DMG_BULLET, (IsValidEntity(weapon) ? weapon : -1), _, hitPos);
		headshotKill = false;
		miniCritHit = false;
		critHit = false;
	}

	delete victims;
}

public any Native_CF_HasLineOfSight(Handle plugin, int numParams)
{
	float start[3], end[3], intersection[3];
	GetNativeArray(1, start, sizeof(start));
	GetNativeArray(2, end, sizeof(end));
	int user = GetNativeCell(5);

	TR_TraceRayFilter(start, end, MASK_SHOT, RayType_EndPoint, CF_LOSTrace, user);

	if (TR_DidHit())
	{
		SetNativeCellRef(3, TR_GetEntityIndex());
		TR_GetEndPosition(intersection);
		SetNativeArray(4, intersection, sizeof(intersection));
		return false;
	}

	return true;
}

public bool CF_OnlyHitTarget(int entity, int contentsMask, int target)
{
	return target == entity;
}

void SDKCall_SetLocalOrigin(int index, float localOrigin[3])
{
	if(g_hSetLocalOrigin)
	{
		SDKCall(g_hSetLocalOrigin, index, localOrigin);
	}
}

void SDKCall_FinishLagCompensation(int client)
{
	if(SDKStartLagCompensation && SDKFinishLagCompensation && SDKGetCurrentCommand != view_as<Address>(-1))
	{
		Address value = CEndLagCompensationManager;
		if(value)
			SDKCall(SDKFinishLagCompensation, value, client);
	}
}

int OffsetLagCompStart_UserInfoReturn()
{
	//Get to CUserCmd				*m_pCurrentCommand;
	static int ReturnInfo;
	if(!ReturnInfo)
		ReturnInfo = (FindSendPropInfo("CTFPlayer", "m_hViewModel") + 76);

	return ReturnInfo;
}
void SDKCall_StartLagCompensation(int client)
{
	if(SDKStartLagCompensation && SDKFinishLagCompensation && SDKGetCurrentCommand != view_as<Address>(-1))
	{
		Address value = CStartLagCompensationManager;
		if(value)
			SDKCall(SDKStartLagCompensation, value, client, (GetEntityAddress(client) + view_as<Address>(OffsetLagCompStart_UserInfoReturn())));
	}
}

static MRESReturn DHook_StartLagCompensation(Address address)
{
	CStartLagCompensationManager = address;
	return MRES_Ignored;
}
static MRESReturn DHook_EndLagCompensation(Address address)
{
	CEndLagCompensationManager = address;
	return MRES_Ignored;
}

public Action CF_OnPlayerKilled_Pre(int &victim, int &inflictor, int &attacker, char weapon[255], char console[255], int &custom, int deadRinger, int &critType, int &damagebits)
{
	Action returnVal = Plugin_Continue;

	if (headshotKill)
	{
		strcopy(console, sizeof(console), "headshot");
		strcopy(weapon, sizeof(weapon), "headshot");
		returnVal = Plugin_Changed;
	}

	if (critHit)
		critType = 2;
	else if (miniCritHit)
		critType = 1;

	return returnVal;
}

public void SentrySpawned(int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (!IsValidEntity(ent))
		return;

	g_DHookSentryFireBullet.HookEntity(Hook_Pre, ent, SentryFired_Pre);
	//g_DHookSentryFireBullet.HookEntity(Hook_Pre, ent, SentryFired_Post);
}

MRESReturn SentryFired_Pre(int sentry, DHookParam hParams)
{
	if (!IsValidEntity(sentry))
		return MRES_Ignored;
	
	int owner = GetEntPropEnt(sentry, Prop_Send, "m_hBuilder")

	int target = GetEntPropEnt(sentry, Prop_Send, "m_hEnemy");
	if (GetEntProp(sentry, Prop_Send, "m_bPlayerControlled"))
		target = GetEntPropEnt(sentry, Prop_Send, "m_hAutoAimTarget");

	int level = GetEntProp(sentry, Prop_Send, "m_iUpgradeLevel");

	float pos1[3], ang1[3], pos2[3], ang2[3];
	if (level > 1)
	{
		GetEntityAttachment(sentry, LookupEntityAttachment(sentry, "muzzle_r"), pos1, ang1);
		GetEntityAttachment(sentry, LookupEntityAttachment(sentry, "muzzle_l"), pos2, ang2);
	}
	else
	{
		GetEntityAttachment(sentry, LookupEntityAttachment(sentry, "muzzle"), pos1, ang1);
	}

	bool result = true;

	Call_StartForward(g_SentryFiredForward);

	Call_PushCell(sentry);
	Call_PushCell(owner);
	Call_PushCell(target);
	Call_PushCell(level);
	Call_PushArray(pos1, 3);
	Call_PushArray(ang1, 3);
	Call_PushArray(pos2, 3);
	Call_PushArray(ang2, 3);
	Call_PushCellRef(result);

	Call_Finish();
	
	return result ? MRES_Ignored : MRES_Supercede;
}

int i_HomingTarget[2049] = { -1, ... };

float f_HomingAngle[2049] = { 0.0, ... };
float f_HomingRate[2049] = { 0.0, ... };
float f_HomingVelocity[2049] = { 0.0, ... };
float f_HomingRotation[2049][3];

bool b_HomingAutoTarget[2049] = { false, ... };

TFTeam g_HomingTeam[2049] = { TFTeam_Unassigned, ... };

Function g_HomingLogic[2049] = { INVALID_FUNCTION, ... };

char s_HomingPlugin[2049][255];

public Native_CF_InitiateHomingProjectile(Handle plugin, int numParams)
{
	int projectile = GetNativeCell(1);

	if (!IsValidEntity(projectile))
		return;

	CF_TerminateHomingProjectile(projectile);

	int target = GetNativeCell(2);
	if (IsValidEntity(target))
		target = EntIndexToEntRef(target);
	i_HomingTarget[projectile] = target;

	f_HomingAngle[projectile] = GetNativeCell(3);
	f_HomingRate[projectile] = GetNativeCell(4);
	b_HomingAutoTarget[projectile] = GetNativeCell(5);
	g_HomingTeam[projectile] = GetNativeCell(6);
	g_HomingLogic[projectile] = GetNativeFunction(7);
	GetNativeString(8, s_HomingPlugin[projectile], 255);

	GetEntPropVector(projectile, Prop_Send, "m_angRotation", f_HomingRotation[projectile]);

	float vel[3];
	GetEntPropVector(projectile, Prop_Data, "m_vecVelocity", vel);
	f_HomingVelocity[projectile] = CF_GetLinearVelocity(vel);

	DataPack pack = new DataPack();
	g_HomingTimer[projectile] = CreateDataTimer(0.1, HP_HomeIn, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack, EntIndexToEntRef(projectile));
	WritePackCell(pack, projectile);
}

int homingCheck = -1;

public bool HP_CheckTarget(int target)
{
	if (!CF_IsValidTarget(target, g_HomingTeam[homingCheck], s_HomingPlugin[homingCheck], g_HomingLogic[homingCheck]))
		return false;

	return HP_CanHome(homingCheck, target);
}

public bool HP_CanHome(int projectile, int target)
{
	if (!IsValidEntity(target))
	{
		return false;
	}

	float pos1[3], pos2[3];
	GetEntPropVector(projectile, Prop_Send, "m_vecOrigin", pos2);
	CF_WorldSpaceCenter(target, pos1);

	if (!CF_HasLineOfSight(pos1, pos2, _, _, projectile))
	{
		return false;
	}

	float ang[3], angLook[3];
	for (int i = 0; i < 3; i++)
		angLook[i] = f_HomingRotation[projectile][i];

	CF_GetVectorAnglesTwoPoints(pos2, pos1, ang);

	ang[0] = CF_FixAngle(ang[0]);
	ang[1] = CF_FixAngle(ang[1]);

	if(!(fabs(angLook[0] - ang[0]) <= f_HomingAngle[projectile] ||
	(fabs(angLook[0] - ang[0]) >= (360.0-f_HomingAngle[projectile]))))
	{
		return false;
	}

	if(!(fabs(angLook[1] - ang[1]) <= f_HomingAngle[projectile] ||
	(fabs(angLook[1] - ang[1]) >= (360.0-f_HomingAngle[projectile]))))
	{
		return false;
	}
		
	return true;
}

public Action HP_HomeIn(Handle plugin, DataPack pack)
{
	ResetPack(pack);

	int projectile = EntRefToEntIndex(ReadPackCell(pack));
	int slot = ReadPackCell(pack);

	if (!IsValidEntity(projectile))
	{
		g_HomingTimer[slot] = null;
		return Plugin_Stop;
	}

	float pos[3];
	GetEntPropVector(projectile, Prop_Send, "m_vecOrigin", pos);

	int target = EntRefToEntIndex(i_HomingTarget[projectile]);
	if (!HP_CanHome(projectile, target))
	{
		if (!b_HomingAutoTarget[projectile])
		{
			g_HomingTimer[slot] = null;
			return Plugin_Stop;
		}

		homingCheck = projectile;
		target = CF_GetClosestTarget(pos, true, _, _, _, "chaos_fortress", HP_CheckTarget);
	}
	
	if (IsValidEntity(target))
	{
		HP_TurnToTarget(projectile, target);
		i_HomingTarget[projectile] = EntIndexToEntRef(target);
	}

	return Plugin_Continue;
}

public void HP_TurnToTarget(int projectile, int target)
{
	static float rocketAngle[3];

	rocketAngle[0] = f_HomingRotation[projectile][0];
	rocketAngle[1] = f_HomingRotation[projectile][1];
	rocketAngle[2] = f_HomingRotation[projectile][2];

	static float tmpAngles[3];
	static float rocketOrigin[3];
	GetEntPropVector(projectile, Prop_Send, "m_vecOrigin", rocketOrigin);

	float pos1[3];
	CF_WorldSpaceCenter(target, pos1);
	GetRayAngles(rocketOrigin, pos1, tmpAngles);

	rocketAngle[0] = ApproachAngle(tmpAngles[0], rocketAngle[0], f_HomingRate[projectile]);
	rocketAngle[1] = ApproachAngle(tmpAngles[1], rocketAngle[1], f_HomingRate[projectile]);
	
	float vecVelocity[3];
	GetAngleVectors(rocketAngle, vecVelocity, NULL_VECTOR, NULL_VECTOR);
	
	vecVelocity[0] *= f_HomingVelocity[projectile];
	vecVelocity[1] *= f_HomingVelocity[projectile];
	vecVelocity[2] *= f_HomingVelocity[projectile];

	f_HomingRotation[projectile][0] = rocketAngle[0];
	f_HomingRotation[projectile][1] = rocketAngle[1];
	f_HomingRotation[projectile][2] = rocketAngle[2];

	TeleportEntity(projectile, NULL_VECTOR, rocketAngle, vecVelocity);
}

public Native_CF_TerminateHomingProjectile(Handle plugin, int numParams)
{
	int projectile = GetNativeCell(1);

	if (IsValidEntity(projectile))
	{
		delete g_HomingTimer[projectile];
		g_HomingTimer[projectile] = null;
	}
}

public Native_CF_SetAbilityTypeSlot(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	CF_AbilityType type = GetNativeCell(2);
	int slot = GetNativeCell(3);

	if (!CF_IsPlayerCharacter(client))
		return;

	CFAbility ab = GetAbilityFromClient(client, type);
	if (ab != null)
		ab.i_AbilitySlot = slot;
}

public int Native_CF_GetAbilityTypeSlot(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	CF_AbilityType type = GetNativeCell(2);

	if (!CF_IsPlayerCharacter(client))
		return -1;

	CFAbility ab = GetAbilityFromClient(client, type);
	if (ab != null)
		return ab.i_AbilitySlot;

	return -1;
}

int i_TauntSpeedWearable[MAXPLAYERS + 1] = { -1, ... };
int i_ForceTauntWeapon[MAXPLAYERS + 1] = { -1, ... };
int i_ForceTauntSlot[MAXPLAYERS + 1] = { -1, ... };

public any Native_CF_ForceTaunt(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int index = GetNativeCell(2);
	float rate = GetNativeCell(3);
	bool interrupt = GetNativeCell(4);

	if (!IsValidMulti(client) || GetEntityFlags(client) & FL_INWATER != 0 || GetEntityFlags(client) & FL_ONGROUND == 0 || (!interrupt && (TF2_IsPlayerStunned(client) || TF2_IsPlayerInCondition(client, TFCond_Taunting))))
		return false;

	static Handle item;
	if(item == INVALID_HANDLE)
	{
		item = TF2Items_CreateItem(OVERRIDE_ALL|PRESERVE_ATTRIBUTES|FORCE_GENERATION);
		TF2Items_SetClassname(item, "tf_wearable_vm");
		TF2Items_SetQuality(item, 6);
		TF2Items_SetLevel(item, 1);
		TF2Items_SetNumAttributes(item, 1);
		TF2Items_SetAttribute(item, 0, 201, rate);
	}

	TF2Items_SetItemIndex(item, index);
	int entity = TF2Items_GiveNamedItem(client, item);
	if(entity != -1)
	{
		if (rate != 1.0)
		{
			char atts[255];
			Format(atts, 255, "201 ; %f", rate);
			i_TauntSpeedWearable[client] = EntIndexToEntRef(CF_AttachWearable(client, view_as<int>(CF_ClassToken_Engineer), "tf_wearable", false, 0, 0, _, atts));
		}

		TF2_RemoveCondition(client, TFCond_Taunting);
			
		static int offset;
		if(!offset)
			offset = GetEntSendPropOffs(entity, "m_Item", true);
			
		if(offset > 0)
		{
			Address address = GetEntityAddress(entity);
			if(address != Address_Null)
			{
				address += view_as<Address>(offset);
				SDKCall(SDKPlayTaunt, client, address);
			}

			AcceptEntityInput(entity, "Kill");
		}

		return true;
	}

	return false;
}

public any Native_CF_ForceWeaponTaunt(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int index = GetNativeCell(2);
	char classname[255];
	GetNativeString(3, classname, 255);
	int slot = GetNativeCell(4);
	float rate = GetNativeCell(5);
	bool interrupt = GetNativeCell(6);
	bool visible = GetNativeCell(7);

	if (!IsValidMulti(client) || GetEntityFlags(client) & FL_INWATER != 0 || GetEntityFlags(client) & FL_ONGROUND == 0 || (!interrupt && (TF2_IsPlayerStunned(client) || TF2_IsPlayerInCondition(client, TFCond_Taunting))))
		return false;

	char atts[255];
	Format(atts, sizeof(atts), "201 ; %f", rate);
	int weapon = CF_SpawnWeapon(client, classname, index, 77, 7, slot, (slot < 2 ? 1 : 0), (slot < 2 ? 1 : 0), atts, _, visible, false)

	if(weapon != -1)
	{
		int acWep = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

		for (int i = 0; i < 5; i++)
		{
			if (GetPlayerWeaponSlot(client, i) == acWep)
			{
				i_ForceTauntSlot[client] = i;
				break;
			}
		}

		TF2_RemoveCondition(client, TFCond_Taunting);

		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
		FakeClientCommand(client, "taunt");
		i_ForceTauntWeapon[client] = EntIndexToEntRef(weapon);
		return true;
	}

	return false;
}

public void TF2_OnConditionRemoved(int client, TFCond condition)
{
	if (condition == TFCond_Taunting && (i_TauntSpeedWearable[client] != -1 || i_ForceTauntWeapon[client] != -1))
	{
		int ent = EntRefToEntIndex(i_TauntSpeedWearable[client]);
		if (IsValidEntity(ent))
			RemoveEntity(ent);

		ent = EntRefToEntIndex(i_ForceTauntWeapon[client]);
		if (IsValidEntity(ent))
		{
			int entity = GetEntPropEnt(ent, Prop_Send, "m_hExtraWearable");
			if(entity != -1)
				TF2_RemoveWearable(client, entity);

			entity = GetEntPropEnt(ent, Prop_Send, "m_hExtraWearableViewModel");
			if(entity != -1)
				TF2_RemoveWearable(client, entity);

			RemovePlayerItem(client, ent);
			AcceptEntityInput(ent, "Kill");

			if (IsPlayerAlive(client))
			{
				int weapon = GetPlayerWeaponSlot(client, i_ForceTauntSlot[client]);
				if (IsValidEntity(weapon))
				{
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
				}
			}
		}

		i_TauntSpeedWearable[client] = -1;
		i_ForceTauntWeapon[client] = -1;
	}

	Cond_Remove(client, condition);
}

public any Native_CF_GetSpecialResourceIsMetal(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	CFCharacter chara = GetCharacterFromClient(client);
	if (chara == null)
		return false;

	if (!chara.b_UsingResources)
		return false;

	return chara.b_ResourceIsMetal;
}

public void Native_CF_SetSpecialResourceIsMetal(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	CFCharacter chara = GetCharacterFromClient(client);
	if (chara == null)
		return;

	if (!chara.b_UsingResources)
		return;

	float current = CF_GetSpecialResource(client);
	chara.b_ResourceIsMetal = GetNativeCell(2);
	if (chara.b_ResourceIsMetal)
	{
		if (GetNativeCell(3))
			CF_SetSpecialResource(client, current);
		else
			CF_SetSpecialResource(client, CF_GetSpecialResource(client));
	}
}

float f_CondEndTime[MAXPLAYERS+1][255];
int i_NumConds[MAXPLAYERS+1] = {0, ...};

public void Native_CF_AddCondition(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	TFCond condition = GetNativeCell(2);
	float duration = GetNativeCell(3);
	int inflictor = GetNativeCell(4);
	bool resetTimer = GetNativeCell(5);

	if (!IsValidMulti(client))
		return;

	#undef TF2_AddCondition

	int condNum = view_as<int>(condition);
	float gt = GetGameTime();

	if (duration == TFCondDuration_Infinite)
	{
		TF2_AddCondition(client, condition, duration, inflictor);

		if (f_CondEndTime[client][condNum] > 0.0)
		{
			f_CondEndTime[client][condNum] = -1.0;
			i_NumConds[client]--;
		}
	}
	else
	{
		if (gt > f_CondEndTime[client][condNum] || resetTimer)
		{
			if (gt > f_CondEndTime[client][condNum])
			{
				TF2_AddCondition(client, condition, _, inflictor);
				i_NumConds[client]++;
			}

			f_CondEndTime[client][condNum] = gt + duration;
		}
		else
		{
			f_CondEndTime[client][condNum] += duration;
		}

		RequestFrame(Conds_Check, GetClientUserId(client));
	}

	#define TF2_AddCondition TFCond_Redirect_Add
}

public void Conds_ClearAll(int client)
{
	if (!IsValidClient(client))
		return;

	for (int i = 0; i < 131; i++)
	{
		if (f_CondEndTime[client][i] <= 0.0)
			continue;
			
		TF2_RemoveCondition(client, view_as<TFCond>(i));
	}
}

public void Conds_Check(int id)
{
	int client = GetClientOfUserId(id);
	if (!IsValidMulti(client))
		return;

	float gt = GetGameTime();
	
	for (int i = 0; i < 131; i++)
	{
		if (gt >= f_CondEndTime[client][i] && f_CondEndTime[client][i] > 0.0)
		{
			TF2_RemoveCondition(client, view_as<TFCond>(i));
		}
	}
	
	if (i_NumConds[client] < 1)
		return;
		
	RequestFrame(Conds_Check, id);
}

public void Native_CF_RemoveCondition(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	TFCond condition = GetNativeCell(2);

	#undef TF2_RemoveCondition
	if (IsPlayerAlive(client))
		TF2_RemoveCondition(client, condition);
	#define TF2_RemoveCondition TFCond_Redirect_Remove

	Cond_Remove(client, condition);
}

public void Cond_Remove(int client, TFCond condition)
{
	float endTime = f_CondEndTime[client][view_as<int>(condition)];
	if (endTime > 0.0)
		i_NumConds[client]--;
		
	f_CondEndTime[client][view_as<int>(condition)] = 0.0;
}