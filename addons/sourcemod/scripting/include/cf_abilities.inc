float f_UltChargeRequired[MAXPLAYERS + 1] = { 0.0, ... };
float f_UltCharge[MAXPLAYERS + 1] = { 0.0, ... };
float f_UltChargeOnRegen[MAXPLAYERS + 1] = { 0.0, ... };
float f_UltChargeOnDamage[MAXPLAYERS + 1] = { 0.0, ... };
float f_UltChargeOnHurt[MAXPLAYERS + 1] = { 0.0, ... };
float f_UltChargeOnHeal[MAXPLAYERS + 1] = { 0.0, ... };
float f_UltChargeOnKill[MAXPLAYERS + 1] = { 0.0, ... };
float f_UltCD[MAXPLAYERS + 1] = { 0.0, ... };
float f_UltCDEndTime[MAXPLAYERS + 1] = { 0.0, ... };
float f_M2CD[MAXPLAYERS + 1] = { 0.0, ... };
float f_M2CDEndTime[MAXPLAYERS + 1] = { 0.0, ... };
float f_M3CD[MAXPLAYERS + 1] = { 0.0, ... };
float f_M3CDEndTime[MAXPLAYERS + 1] = { 0.0, ... };
float f_ReloadCD[MAXPLAYERS + 1] = { 0.0, ... };
float f_ReloadCDEndTime[MAXPLAYERS + 1] = { 0.0, ... };
float f_M2Cost[MAXPLAYERS + 1] = { 0.0, ... };
float f_M3Cost[MAXPLAYERS + 1] = { 0.0, ... };
float f_ReloadCost[MAXPLAYERS + 1] = { 0.0, ... };
float f_ResourceMax[MAXPLAYERS + 1] = { 0.0, ... };
float f_Resources[MAXPLAYERS + 1] = { 0.0, ... };
float f_ResourcesOnRegen[MAXPLAYERS + 1] = { 0.0, ... };
float f_ResourcesOnDamage[MAXPLAYERS + 1] = { 0.0, ... };
float f_ResourcesOnHurt[MAXPLAYERS + 1] = { 0.0, ... };
float f_ResourcesOnHeal[MAXPLAYERS + 1] = { 0.0, ... };
float f_ResourcesOnKill[MAXPLAYERS + 1] = { 0.0, ... };

char s_UltName[MAXPLAYERS + 1][255];
char s_M2Name[MAXPLAYERS + 1][255];
char s_M3Name[MAXPLAYERS + 1][255];
char s_ReloadName[MAXPLAYERS + 1][255];
char s_ResourceName[MAXPLAYERS + 1][255];
char s_ResourceName_Plural[MAXPLAYERS + 1][255];

bool b_CharacterHasUlt[MAXPLAYERS + 1] = { false, ... };
bool b_UsingResources[MAXPLAYERS + 1] = { false, ... };
bool b_M2IsHeld[MAXPLAYERS + 1] = { false, ... };
bool b_M3IsHeld[MAXPLAYERS + 1] = { false, ... };
bool b_ReloadIsHeld[MAXPLAYERS + 1] = { false, ... };
bool b_ResourceIsUlt[MAXPLAYERS + 1] = { false, ... };
bool b_UseHUD[MAXPLAYERS + 1] = { false, ... };
bool b_HasM2[MAXPLAYERS + 1] = { false, ... };
bool b_HasM3[MAXPLAYERS + 1] = { false, ... };
bool b_HasReload[MAXPLAYERS + 1] = { false, ... };
bool b_HoldingReload[MAXPLAYERS + 1] = { false, ... };
bool b_HoldingM2[MAXPLAYERS + 1] = { false, ... };
bool b_HoldingM3[MAXPLAYERS + 1] = { false, ... };
bool b_ForceEndHeldM2[MAXPLAYERS + 1] = { false, ... };
bool b_ForceEndHeldM3[MAXPLAYERS + 1] = { false, ... };
bool b_ForceEndHeldReload[MAXPLAYERS + 1] = { false, ... };

GlobalForward g_OnAbility;
GlobalForward g_OnUltUsed;
GlobalForward g_OnM2Used;
GlobalForward g_OnM3Used;
GlobalForward g_OnReloadUsed;
GlobalForward g_OnHeldStart;
GlobalForward g_OnHeldEnd;
GlobalForward g_OnHeldEnd_Ability;

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
	CreateNative("CF_DoAbility", Native_CF_DoAbility);
	CreateNative("CF_ActivateAbilitySlot", Native_CF_ActivateAbilitySlot);
	CreateNative("CF_EndHeldAbilitySlot", Native_CF_EndHeldAbilitySlot);
	CreateNative("CF_EndHeldAbility", Native_CF_EndHeldAbility);
}

public void CFA_MakeForwards()
{
	g_OnAbility = new GlobalForward("CF_OnAbility", ET_Ignore, Param_Cell, Param_String, Param_String);
	g_OnUltUsed = new GlobalForward("CF_OnUltUsed", ET_Event, Param_Cell);
	g_OnM2Used = new GlobalForward("CF_OnM2Used", ET_Event, Param_Cell);
	g_OnM3Used = new GlobalForward("CF_OnM3Used", ET_Event, Param_Cell);
	g_OnReloadUsed = new GlobalForward("CF_OnReloadUsed", ET_Event, Param_Cell);
	g_OnHeldStart = new GlobalForward("CF_OnHeldStart", ET_Event, Param_Cell, Param_Cell);
	g_OnHeldEnd = new GlobalForward("CF_OnHeldEnd", ET_Event, Param_Cell, Param_Cell);
	g_OnHeldEnd_Ability = new GlobalForward("CF_OnHeldEnd_Ability", ET_Event, Param_Cell, Param_String, Param_String);
}

Handle HudSync;

#define NOPE		"replay/record_fail.wav"

public void CFA_MapStart()
{
	HudSync = CreateHudSynchronizer();
	
	CreateTimer(0.1, CFA_HUDTimer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	
	PrecacheSound(NOPE);
}

public Action CFA_HUDTimer(Handle timer)
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (CF_IsPlayerCharacter(client) && b_UseHUD[client])
		{
			if (IsPlayerAlive(client))
			{
				char HUDText[255];
				
				if (b_CharacterHasUlt[client])
				{
					if (CF_GetAbilityCooldown(client, CF_AbilityType_Ult) < 0.1)
					{
						CF_GiveUltCharge(client, f_UltChargeOnRegen[client]/10.0, CF_ResourceType_Percentage);
					}
					
					Format(HUDText, sizeof(HUDText), "%s: %iPUTAPERCENTAGEHERE %s\n", s_UltName[client], RoundToFloor((f_UltCharge[client]/f_UltChargeRequired[client]) * 100.0), f_UltCharge[client] >= f_UltChargeRequired[client] ? "(READY, CALL FOR MEDIC)" : "");
				}
				
				if (b_UsingResources[client] && !b_ResourceIsUlt[client])
				{
					CF_GiveSpecialResource(client, 1.0, CF_ResourceType_Regen);
					Format(HUDText, sizeof(HUDText), "%s\n%s: %i/%i\n", HUDText, f_Resources[client] != 1.0 ? s_ResourceName_Plural[client] : s_ResourceName[client], RoundFloat(f_Resources[client]), RoundFloat(f_ResourceMax[client]));
				}
				
				if (b_HasM2[client])
				{
					if (b_UsingResources[client] && f_M2Cost[client] > 0.0)
					{
						if (b_ResourceIsUlt[client])
						{
							Format(HUDText, sizeof(HUDText), "%s[%.2fPUTAPERCENTAGEHERE Ult.]", HUDText, (f_M2Cost[client]/f_UltChargeRequired[client]) * 100.0);
						}
						else
						{
							Format(HUDText, sizeof(HUDText), "%s[%i %s]", HUDText, RoundFloat(f_M2Cost[client]), f_M2Cost[client] != 1.0 ? s_ResourceName_Plural[client] : s_ResourceName[client]);
						}
					}
					
					float remCD = CF_GetAbilityCooldown(client, CF_AbilityType_M2);
					if (remCD > 0.0)
					{
						Format(HUDText, sizeof(HUDText), "%s %s [%.1f]\n", HUDText, s_M2Name[client], remCD);
					}
					else
					{
						Format(HUDText, sizeof(HUDText), "%s %s %s\n", HUDText, s_M2Name[client], b_M2IsHeld[client] ? (b_HoldingM2[client] ? "[ACTIVE]" : "[Hold M2]") : "[M2]");
					}
				}
				
				if (b_HasM3[client])
				{
					if (b_UsingResources[client] && f_M3Cost[client] > 0.0)
					{
						if (b_ResourceIsUlt[client])
						{
							Format(HUDText, sizeof(HUDText), "%s[%.2fPUTAPERCENTAGEHERE Ult.]", HUDText, (f_M3Cost[client]/f_UltChargeRequired[client]) * 100.0);
						}
						else
						{
							Format(HUDText, sizeof(HUDText), "%s[%i %s]", HUDText, RoundFloat(f_M3Cost[client]), f_M3Cost[client] != 1.0 ? s_ResourceName_Plural[client] : s_ResourceName[client]);
						}
					}
					
					float remCD = CF_GetAbilityCooldown(client, CF_AbilityType_M3);
					if (remCD > 0.0)
					{
						Format(HUDText, sizeof(HUDText), "%s %s [%.1f]\n", HUDText, s_M3Name[client], remCD);
					}
					else
					{
						Format(HUDText, sizeof(HUDText), "%s %s %s\n", HUDText, s_M3Name[client], b_M3IsHeld[client] ? (b_HoldingM3[client] ? "[ACTIVE]" : "[Hold M3]") : "[M3]");
					}
				}
				
				if (b_HasReload[client])
				{
					if (b_UsingResources[client] && f_ReloadCost[client] > 0.0)
					{
						if (b_ResourceIsUlt[client])
						{
							Format(HUDText, sizeof(HUDText), "%s[%.2fPUTAPERCENTAGEHERE Ult.]", HUDText, (f_ReloadCost[client]/f_UltChargeRequired[client]) * 100.0);
						}
						else
						{
							Format(HUDText, sizeof(HUDText), "%s[%i %s]", HUDText, RoundFloat(f_ReloadCost[client]), f_ReloadCost[client] != 1.0 ? s_ResourceName_Plural[client] : s_ResourceName[client]);
						}
					}
					
					float remCD = CF_GetAbilityCooldown(client, CF_AbilityType_Reload);
					if (remCD > 0.0)
					{
						Format(HUDText, sizeof(HUDText), "%s %s [%.1f]\n", HUDText, s_ReloadName[client], remCD);
					}
					else
					{
						Format(HUDText, sizeof(HUDText), "%s %s %s\n", HUDText, s_ReloadName[client], b_ReloadIsHeld[client] ? (b_HoldingReload[client] ? "[ACTIVE]" : "[Hold R]") : "[R]");
					}
				}
				
				ReplaceString(HUDText, sizeof(HUDText), "PUTAPERCENTAGEHERE", "%%");
				SetHudTextParams(-1.0, 0.8, 0.1, 255, 255, 255, 255);
				ShowSyncHudText(client, HudSync, HUDText);
			}
		}
	}
	
	return Plugin_Continue;
}

public void CFA_PlayerKilled(int attacker)
{
	if (CF_IsPlayerCharacter(attacker))
	{
		CF_GiveSpecialResource(attacker, 1.0, CF_ResourceType_Kill);
		CF_GiveUltCharge(attacker, 1.0, CF_ResourceType_Kill);
	}
}

public bool CFA_InitializeUltimate(int client, ConfigMap map)
{
	ConfigMap subsection = map.GetSection("character.ultimate_stats");
	if (subsection != null)
	{
		subsection.Get("name", s_UltName[client], 255);
		f_UltChargeRequired[client] = GetFloatFromConfigMap(subsection, "charge", 0.0);
		f_UltChargeOnRegen[client] = GetFloatFromConfigMap(subsection, "on_regen", 0.0);
		f_UltChargeOnDamage[client] = GetFloatFromConfigMap(subsection, "on_damage", 0.0);
		f_UltChargeOnHurt[client] = GetFloatFromConfigMap(subsection, "on_hurt", 0.0);
		f_UltChargeOnHeal[client] = GetFloatFromConfigMap(subsection, "on_heal", 0.0);
		f_UltChargeOnKill[client] = GetFloatFromConfigMap(subsection, "on_kill", 0.0);
		f_UltCD[client] = GetFloatFromConfigMap(subsection, "cooldown", 0.0);
		
		b_CharacterHasUlt[client] = true;
		
		delete subsection;
	}
	else
	{
		b_CharacterHasUlt[client] = false;
	}
	
	return b_CharacterHasUlt[client];
}

//TODO: CF_DoAbility, CF_ActivateAbilitySlot, add ult charge to every currently-detected event

public bool CFA_InitializeAbilities(int client, ConfigMap map)
{
	CFA_InitializeResources(client, map);
	
	bool AtLeastOne = false;
	
	ConfigMap subsection = map.GetSection("character.m2_ability");
	if (subsection != null)
	{
		subsection.Get("name", s_M2Name[client], 255);
		f_M2CD[client] = GetFloatFromConfigMap(subsection, "cooldown", 0.0);
		CF_ApplyAbilityCooldown(client, GetFloatFromConfigMap(subsection, "starting_cd", 0.0), CF_AbilityType_M2, true);
		b_M2IsHeld[client] = GetBoolFromConfigMap(subsection, "held", false);
		if (b_UsingResources[client])
		{
			f_M2Cost[client] = GetFloatFromConfigMap(subsection, "cost", 0.0);
		}
		
		b_HasM2[client] = true;
		AtLeastOne = true;
		delete subsection;
	}
	else
	{
		b_HasM2[client] = false;
	}
	
	subsection = map.GetSection("character.m3_ability");
	if (subsection != null)
	{
		subsection.Get("name", s_M3Name[client], 255);
		f_M3CD[client] = GetFloatFromConfigMap(subsection, "cooldown", 0.0);
		CF_ApplyAbilityCooldown(client, GetFloatFromConfigMap(subsection, "starting_cd", 0.0), CF_AbilityType_M3, true);
		b_M3IsHeld[client] = GetBoolFromConfigMap(subsection, "held", false);
		if (b_UsingResources[client])
		{
			f_M3Cost[client] = GetFloatFromConfigMap(subsection, "cost", 0.0);
		}
		
		b_HasM3[client] = true;
		AtLeastOne = true;
		delete subsection;
	}
	else
	{
		b_HasM3[client] = false;
	}
	
	subsection = map.GetSection("character.reload_ability");
	if (subsection != null)
	{
		subsection.Get("name", s_ReloadName[client], 255);
		f_ReloadCD[client] = GetFloatFromConfigMap(subsection, "cooldown", 0.0);
		CF_ApplyAbilityCooldown(client, GetFloatFromConfigMap(subsection, "starting_cd", 0.0), CF_AbilityType_Reload, true);
		b_ReloadIsHeld[client] = GetBoolFromConfigMap(subsection, "held", false);
		if (b_UsingResources[client])
		{
			f_ReloadCost[client] = GetFloatFromConfigMap(subsection, "cost", 0.0);
		}
		b_HasReload[client] = true;
		
		AtLeastOne = true;
		delete subsection;
	}
	else
	{
		b_HasReload[client] = false;
	}
	
	if (!AtLeastOne)
		b_UsingResources[client] = false;
	
	return AtLeastOne;
}

public void CFA_InitializeResources(int client, ConfigMap map)
{
	ConfigMap subsection = map.GetSection("character.special_resource");
	if (subsection != null)
	{
		b_ResourceIsUlt[client] = GetBoolFromConfigMap(subsection, "is_ult", false);
		
		if (!b_ResourceIsUlt[client])
		{
			subsection.Get("name", s_ResourceName[client], 255);
			subsection.Get("name_plural", s_ResourceName_Plural[client], 255);
			float start = GetFloatFromConfigMap(subsection, "start", 0.0);
			float preserve = GetFloatFromConfigMap(subsection, "preserve", 0.0) * f_Resources[client];
			f_ResourceMax[client] = GetFloatFromConfigMap(subsection, "max", 0.0);
			
			if (preserve > start)
			{
				CF_SetSpecialResource(client, preserve);
			}
			else
			{
				CF_SetSpecialResource(client, start);
			}
			
			f_ResourcesOnRegen[client] = GetFloatFromConfigMap(subsection, "on_regen", 0.0);
			f_ResourcesOnDamage[client] = GetFloatFromConfigMap(subsection, "on_damage", 0.0);
			f_ResourcesOnHurt[client] = GetFloatFromConfigMap(subsection, "on_hurt", 0.0);
			f_ResourcesOnHeal[client] = GetFloatFromConfigMap(subsection, "on_heal", 0.0);
			f_ResourcesOnKill[client] = GetFloatFromConfigMap(subsection, "on_kill", 0.0);
		}
		
		b_UsingResources[client] = true;
		
		delete subsection;
	}
	else
	{
		b_UsingResources[client] = false;
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
		
	if (!b_CharacterHasUlt[client])
		return;
	
	CF_AttemptAbilitySlot(client, CF_AbilityType_Ult);
}

public Action CF_OnPlayerM2(int client, int &buttons, int &impulse, int &weapon)
{
	if (!CF_IsPlayerCharacter(client))
		return Plugin_Continue;
		
	if (!b_HasM2[client])
		return Plugin_Continue;
		
	if (b_M2IsHeld[client])
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
		
	if (!b_HasM3[client])
		return Plugin_Continue;
		
	if (b_M3IsHeld[client])
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
		
	if (!b_HasReload[client])
		return Plugin_Continue;
	
	if (b_ReloadIsHeld[client])
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
		int slot;
		char soundSlot[255];
		
		switch(type)
		{
			case CF_AbilityType_M2:
			{
				slot = 2;
				soundSlot = "sound_heldstart_m2";
				SDKUnhook(client, SDKHook_PreThink, CFA_HeldM2PreThink);
				SDKHook(client, SDKHook_PreThink, CFA_HeldM2PreThink);
				b_HoldingM2[client] = true;
			}
			case CF_AbilityType_M3:
			{
				slot = 3;
				soundSlot = "sound_heldstart_m3";
				SDKUnhook(client, SDKHook_PreThink, CFA_HeldM3PreThink);
				SDKHook(client, SDKHook_PreThink, CFA_HeldM3PreThink);
				b_HoldingM3[client] = true;
			}
			case CF_AbilityType_Reload:
			{
				slot = 4;
				soundSlot = "sound_heldstart_reload";
				SDKUnhook(client, SDKHook_PreThink, CFA_HeldReloadPreThink);
				SDKHook(client, SDKHook_PreThink, CFA_HeldReloadPreThink);
				b_HoldingReload[client] = true;
			}
		}
		
		CF_ActivateAbilitySlot(client, slot);
		//CF_PlayRandomSound(client, "", soundSlot);
	}
	else
	{
		Nope(client);
	}
}

public Action CFA_HeldM2PreThink(int client)
{
	b_HoldingM2[client] = (GetClientButtons(client) & IN_ATTACK2 != 0) && !b_ForceEndHeldM2[client] && CF_CanPlayerUseAbilitySlot(client, CF_AbilityType_M2);
	
	if (!b_HoldingM2[client])
	{
		Call_StartForward(g_OnHeldEnd);
		
		Call_PushCell(client);
		Call_PushCell(CF_AbilityType_M2);
		
		Call_Finish();
		
		CF_EndHeldAbilitySlot(client, 2);
		
		CF_ApplyAbilityCooldown(client, f_M2CD[client], CF_AbilityType_M2, true);
		if (b_UsingResources[client])
		{
			if (b_ResourceIsUlt[client])
			{
				CF_GiveUltCharge(client, -f_M2Cost[client], CF_ResourceType_Generic);
			}
			else
			{
				CF_GiveSpecialResource(client, -f_M2Cost[client], CF_ResourceType_Generic);
			}
		}
		
		//CF_PlayRandomSound(client, "", "sound_heldend_m2");
		b_ForceEndHeldM2[client] = false;
		SDKUnhook(client, SDKHook_PreThink, CFA_HeldM2PreThink);
	}
	
	//TODO: If the player respawns or dies for any reason during a held ability, a bunch of shit will break. Make a method to reset all held variables and call it in MakeCharacter and PlayerKilled.
	return Plugin_Continue;
}

public Action CFA_HeldM3PreThink(int client)
{
	b_HoldingM3[client] = (GetClientButtons(client) & IN_ATTACK3 != 0) && !b_ForceEndHeldM3[client] && CF_CanPlayerUseAbilitySlot(client, CF_AbilityType_M3);
	
	if (!b_HoldingM3[client])
	{
		Call_StartForward(g_OnHeldEnd);
		
		Call_PushCell(client);
		Call_PushCell(CF_AbilityType_M3);
		
		Call_Finish();
		
		CF_EndHeldAbilitySlot(client, 3);
		
		CF_ApplyAbilityCooldown(client, f_M3CD[client], CF_AbilityType_M3, true);
		if (b_UsingResources[client])
		{
			if (b_ResourceIsUlt[client])
			{
				CF_GiveUltCharge(client, -f_M3Cost[client], CF_ResourceType_Generic);
			}
			else
			{
				CF_GiveSpecialResource(client, -f_M3Cost[client], CF_ResourceType_Generic);
			}
		}
		
		//CF_PlayRandomSound(client, "", "sound_heldend_m3");
		b_ForceEndHeldM3[client] = false;
		SDKUnhook(client, SDKHook_PreThink, CFA_HeldM3PreThink);
	}
	
	return Plugin_Continue;
}

public Action CFA_HeldReloadPreThink(int client)
{
	b_HoldingReload[client] = (GetClientButtons(client) & IN_RELOAD != 0) && !b_ForceEndHeldReload[client] && CF_CanPlayerUseAbilitySlot(client, CF_AbilityType_Reload);
	
	if (!b_HoldingReload[client])
	{
		Call_StartForward(g_OnHeldEnd);
		
		Call_PushCell(client);
		Call_PushCell(CF_AbilityType_Reload);
		
		Call_Finish();
		
		CF_EndHeldAbilitySlot(client, 4);
		
		CF_ApplyAbilityCooldown(client, f_ReloadCD[client], CF_AbilityType_Reload, true);
		if (b_UsingResources[client])
		{
			if (b_ResourceIsUlt[client])
			{
				CF_GiveUltCharge(client, -f_ReloadCost[client], CF_ResourceType_Generic);
			}
			else
			{
				CF_GiveSpecialResource(client, -f_ReloadCost[client], CF_ResourceType_Generic);
			}
		}
		
		//CF_PlayRandomSound(client, "", "sound_heldend_reload");
		b_ForceEndHeldReload[client] = false;
		SDKUnhook(client, SDKHook_PreThink, CFA_HeldReloadPreThink);
	}
	
	return Plugin_Continue;
}

public void CF_AttemptAbilitySlot(int client, CF_AbilityType type)
{
	if (!CF_CanPlayerUseAbilitySlot(client, type))
	{
		Nope(client);
		return;
	}
	
	float cooldown; float cost;
	int slot;
	char soundSlot[255];
	Action result;
	GlobalForward toCall;
	
	switch(type)
	{
		case CF_AbilityType_Ult:
		{
			cooldown = f_UltCD[client];
			cost = f_UltChargeRequired[client];
			slot = 1;
			toCall = g_OnUltUsed;
		}
		case CF_AbilityType_M2:
		{
			cooldown = f_M2CD[client];
			cost = f_M2Cost[client];
			slot = 2;
			soundSlot = "sound_m2";
			toCall = g_OnM2Used;
		}
		case CF_AbilityType_M3:
		{
			cooldown = f_M3CD[client];
			cost = f_M3Cost[client];
			slot = 3;
			soundSlot = "sound_m3";
			toCall = g_OnM3Used;
		}
		case CF_AbilityType_Reload:
		{
			cooldown = f_ReloadCD[client];
			cost = f_ReloadCost[client];
			slot = 4;
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
			//TODO: ult sound
		}
		else
		{
			//CF_PlayRandomSound(client, "", soundSlot);
		}

		if (type == CF_AbilityType_Ult || (b_ResourceIsUlt[client] && b_UsingResources[client]))
		{
			CF_GiveUltCharge(client, -cost);
		}
		else if (b_UsingResources[client])
		{
			CF_GiveSpecialResource(client, -cost);
		}
		
		CF_ApplyAbilityCooldown(client, cooldown, type, true);
	}
	else
	{
		Nope(client);
	}
}

public bool CF_CanPlayerUseAbilitySlot(int client, CF_AbilityType type)
{
	if (CF_GetAbilityCooldown(client, type) > 0.0)
	{
		return false;
	}
		
	if (b_UsingResources[client] || type == CF_AbilityType_Ult)
	{
		float cost; float available = (b_ResourceIsUlt[client] || type == CF_AbilityType_Ult) ? f_UltCharge[client] : f_Resources[client];
		
		switch(type)
		{
			case CF_AbilityType_Ult:
			{
				cost = f_UltChargeRequired[client];
			}
			case CF_AbilityType_M2:
			{
				cost = f_M2Cost[client];
			}
			case CF_AbilityType_M3:
			{
				cost = f_M3Cost[client];
			}
			case CF_AbilityType_Reload:
			{
				cost = f_ReloadCost[client];
			}
		}
		
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
	
	if (type != CF_ResourceType_Generic)
	{
		switch(type)
		{
			case CF_ResourceType_Regen:
			{
				amt *= f_UltChargeOnRegen[client];
			}
			case CF_ResourceType_DamageDealt:
			{
				amt *= f_UltChargeOnDamage[client];
			}
			case CF_ResourceType_DamageTaken:
			{
				amt *= f_UltChargeOnHurt[client];
			}
			case CF_ResourceType_Healing:
			{
				amt *= f_UltChargeOnHeal[client];
			}
			case CF_ResourceType_Kill:
			{
				amt *= f_UltChargeOnKill[client];
			}
			case CF_ResourceType_Percentage:
			{
				amt = f_UltChargeRequired[client] * amt * 0.01;
			}
		}
	}
	
	CF_SetUltCharge(client, f_UltCharge[client] + amt);
}

public Native_CF_SetUltCharge(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return;
		
	float amt = GetNativeCell(2);
	
	if (amt < 0.0)
		amt = 0.0;
		
	if (amt >= f_UltChargeRequired[client])	//TODO: Trigger sound here
	{
		amt = f_UltChargeRequired[client];
	}
	
	f_UltCharge[client] = amt;
}

public Native_CF_GetUltCharge(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return 0.0;
	
	return f_UltCharge[client];
}

public Native_CF_GiveSpecialResource(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return;
		
	if (b_ResourceIsUlt[client] || !b_UsingResources[client])
		return;
		
	float amt = GetNativeCell(2);
	CF_ResourceType type = GetNativeCell(3);
	
	if (type != CF_ResourceType_Generic)
	{
		switch(type)
		{
			case CF_ResourceType_Regen:
			{
				amt *= f_ResourcesOnRegen[client];
			}
			case CF_ResourceType_DamageDealt:
			{
				amt *= f_ResourcesOnDamage[client];
			}
			case CF_ResourceType_DamageTaken:
			{
				amt *= f_ResourcesOnHurt[client];
			}
			case CF_ResourceType_Healing:
			{
				amt *= f_ResourcesOnHeal[client];
			}
			case CF_ResourceType_Kill:
			{
				amt *= f_ResourcesOnKill[client];
			}
			case CF_ResourceType_Percentage:
			{
				amt = f_ResourceMax[client] * amt * 0.01;
			}
		}
	}
	
	CF_SetSpecialResource(client, f_Resources[client] + amt);
}

public Native_CF_SetSpecialResource(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return;
		
	if (b_ResourceIsUlt[client] || !b_UsingResources[client])
		return;
		
	float amt = GetNativeCell(2);
	
	if (amt < 0.0)
		amt = 0.0;
		
	if (amt >= f_ResourceMax[client])
	{
		amt = f_ResourceMax[client];
	}
	
	f_Resources[client] = amt;
}

public Native_CF_GetSpecialResource(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return 0.0;
		
	if (b_ResourceIsUlt[client] || !b_UsingResources[client])
		return 0.0;
	
	return f_Resources[client];
}

public Native_CF_ApplyAbilityCooldown(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return 0.0;
		
	float cd = GetNativeCell(2);
	CF_AbilityType type = GetNativeCell(3);
	bool override = GetNativeCell(4);
	
	float gameTime = GetGameTime();
	
	switch (type)
	{
		case CF_AbilityType_Ult:
		{
			f_UltCDEndTime[client] = (override || GetGameTime() >= f_UltCDEndTime[client]) ? gameTime + cd : f_UltCDEndTime[client] + cd;
		}
		case CF_AbilityType_M2:
		{
			f_M2CDEndTime[client] = (override || GetGameTime() >= f_M2CDEndTime[client]) ? gameTime + cd : f_M2CDEndTime[client] + cd;
		}
		case CF_AbilityType_M3:
		{
			f_M3CDEndTime[client] = (override || GetGameTime() >= f_M3CDEndTime[client]) ? gameTime + cd : f_M3CDEndTime[client] + cd;
		}
		case CF_AbilityType_Reload:
		{
			f_ReloadCDEndTime[client] = (override || GetGameTime() >= f_ReloadCDEndTime[client]) ? gameTime + cd : f_ReloadCDEndTime[client] + cd;
		}
	}
}

public Native_CF_GetAbilityCooldown(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return 0.0;
		
	CF_AbilityType type = GetNativeCell(2);
	
	float gameTime = GetGameTime();
	
	switch (type)
	{
		case CF_AbilityType_Ult:
		{
			return gameTime >= f_UltCDEndTime[client] ? 0.0 : f_UltCDEndTime[client] - gameTime;
		}
		case CF_AbilityType_M2:
		{
			return gameTime >= f_M2CDEndTime[client] ? 0.0 : f_M2CDEndTime[client] - gameTime;
		}
		case CF_AbilityType_M3:
		{
			return gameTime >= f_M3CDEndTime[client] ? 0.0 : f_M3CDEndTime[client] - gameTime;
		}
		case CF_AbilityType_Reload:
		{
			return gameTime >= f_ReloadCDEndTime[client] ? 0.0 : f_ReloadCDEndTime[client] - gameTime;
		}
	}
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

public Native_CF_ActivateAbilitySlot(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return;
		
	int slot = GetNativeCell(2);
	
	char conf[255], pluginName[255], abName[255];
	CF_GetPlayerConfig(client, conf, sizeof(conf));
	
	ConfigMap map = new ConfigMap(conf);
	if (map == null)
		return;
		
	ConfigMap abilities = map.GetSection("character.abilities");
	delete map;
	if (abilities == null)
		return;
		
	int i = 1;
	char secName[255];
	Format(secName, sizeof(secName), "ability_%i", i);
		
	ConfigMap subsection = abilities.GetSection(secName);
	while (subsection != null)
	{
		if (GetIntFromConfigMap(subsection, "slot", -1) == slot)
		{
			subsection.Get("ability_name", abName, sizeof(abName));
			subsection.Get("plugin_name", pluginName, sizeof(pluginName));
			
			CF_DoAbility(client, pluginName, abName);
		}
		
		i++;
		Format(secName, sizeof(secName), "ability_%i", i);
		delete subsection;
		subsection = abilities.GetSection(secName);
	}
	
	delete abilities;
	if (subsection != null)
		delete subsection;
}

public Native_CF_EndHeldAbilitySlot(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return;
		
	int slot = GetNativeCell(2);
	
	char conf[255], pluginName[255], abName[255];
	CF_GetPlayerConfig(client, conf, sizeof(conf));
	
	ConfigMap map = new ConfigMap(conf);
	if (map == null)
		return;
		
	ConfigMap abilities = map.GetSection("character.abilities");
	delete map;
	if (abilities == null)
		return;
		
	int i = 1;
	char secName[255];
	Format(secName, sizeof(secName), "ability_%i", i);
		
	ConfigMap subsection = abilities.GetSection(secName);
	while (subsection != null)
	{
		if (GetIntFromConfigMap(subsection, "slot", -1) == slot)
		{
			subsection.Get("ability_name", abName, sizeof(abName));
			subsection.Get("plugin_name", pluginName, sizeof(pluginName));
			
			Call_StartForward(g_OnHeldEnd_Ability);
			
			Call_PushCell(client);
			Call_PushString(pluginName);
			Call_PushString(abName);
		
			Call_Finish();
		}
		
		i++;
		Format(secName, sizeof(secName), "ability_%i", i);
		delete subsection;
		subsection = abilities.GetSection(secName);
	}
	
	switch(slot)
	{
		case 2:
		{
			b_ForceEndHeldM2[client] = true;
		}
		case 3:
		{
			b_ForceEndHeldM3[client] = true;
		}
		case 4:
		{
			b_ForceEndHeldReload[client] = true;
		}
	}
	
	delete abilities;
	if (subsection != null)
		delete subsection;
}

public Native_CF_EndHeldAbility(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!CF_IsPlayerCharacter(client))
		return;
		
	char pluginName[255], abName[255];
	GetNativeString(2, pluginName, sizeof(pluginName));
	GetNativeString(3, abName, sizeof(abName));
	
	Call_StartForward(g_OnHeldEnd_Ability);
			
	Call_PushCell(client);
	Call_PushString(pluginName);
	Call_PushString(abName);
		
	Call_Finish();
}

public void Nope(int client)
{
	EmitSoundToClient(client, NOPE);
}