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
}

public void CFA_MakeForwards()
{
	
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
		
		AtLeastOne = true;
		delete subsection;
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
		
		AtLeastOne = true;
		delete subsection;
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
		
		AtLeastOne = true;
		delete subsection;
	}
	
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
				amt = f_UltChargeRequired[client] * amt;
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
				amt = f_ResourceMax[client] * amt;
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