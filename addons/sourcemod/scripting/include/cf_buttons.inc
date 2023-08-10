bool b_M2Down[MAXPLAYERS + 1] = { false, ... };
bool b_M3Down[MAXPLAYERS + 1] = { false, ... };
bool b_ReloadDown[MAXPLAYERS + 1] = { false, ... };
bool b_TabDown[MAXPLAYERS + 1] = { false, ... };
bool b_JumpDown[MAXPLAYERS + 1] = { false, ... };
bool b_CrouchDown[MAXPLAYERS + 1] = { false, ... };

GlobalForward g_OnRunCmd;
GlobalForward g_OnM2;
GlobalForward g_OnM3;
GlobalForward g_OnReload;
GlobalForward g_OnTab;
GlobalForward g_OnJump;
GlobalForward g_OnCrouch;
GlobalForward g_OnCallForMedic;

public void CFB_MakeForwards()
{
	g_OnRunCmd = new GlobalForward("CF_OnPlayerRunCmd", ET_Event, Param_CellByRef, Param_CellByRef, Param_CellByRef, Param_CellByRef);
	g_OnM2 = new GlobalForward("CF_OnPlayerM2", ET_Event, Param_CellByRef, Param_CellByRef, Param_CellByRef, Param_CellByRef);
	g_OnM3 = new GlobalForward("CF_OnPlayerM3", ET_Event, Param_CellByRef, Param_CellByRef, Param_CellByRef, Param_CellByRef);
	g_OnReload = new GlobalForward("CF_OnPlayerReload", ET_Event, Param_CellByRef, Param_CellByRef, Param_CellByRef, Param_CellByRef);
	g_OnTab = new GlobalForward("CF_OnPlayerTab", ET_Event, Param_CellByRef, Param_CellByRef, Param_CellByRef, Param_CellByRef);
	g_OnJump = new GlobalForward("CF_OnPlayerJump", ET_Event, Param_CellByRef, Param_CellByRef, Param_CellByRef, Param_CellByRef);
	g_OnCrouch = new GlobalForward("CF_OnPlayerCrouch", ET_Event, Param_CellByRef, Param_CellByRef, Param_CellByRef, Param_CellByRef);
	g_OnCallForMedic = new GlobalForward("CF_OnPlayerCallForMedic", ET_Ignore, Param_Cell);
	
	AddCommandListener(CFB_OnCallForMedic, "voicemenu");
}

public void CFB_MakeNatives()
{
	CreateNative("CF_GetM2Status", Native_CF_GetM2Status);
	CreateNative("CF_GetM3Status", Native_CF_GetM3Status);
	CreateNative("CF_GetReloadStatus", Native_CF_GetReloadStatus);
	CreateNative("CF_GetTabStatus", Native_CF_GetTabStatus);
	CreateNative("CF_GetJumpStatus", Native_CF_GetJumpStatus);
	CreateNative("CF_GetCrouchStatus", Native_CF_GetCrouchStatus);
}

public Native_CF_GetM2Status(Handle plugin, int numParams)
{
	bool ReturnValue = false;
	
	int client = GetNativeCell(1);
	
	if (IsValidClient(client))
	{
		ReturnValue = b_M2Down[client];
	}
	
	return ReturnValue;
}

public Native_CF_GetM3Status(Handle plugin, int numParams)
{
	bool ReturnValue = false;
	
	int client = GetNativeCell(1);
	
	if (IsValidClient(client))
	{
		ReturnValue = b_M3Down[client];
	}
	
	return ReturnValue;
}

public Native_CF_GetReloadStatus(Handle plugin, int numParams)
{
	bool ReturnValue = false;
	
	int client = GetNativeCell(1);
	
	if (IsValidClient(client))
	{
		ReturnValue = b_ReloadDown[client];
	}
	
	return ReturnValue;
}

public Native_CF_GetTabStatus(Handle plugin, int numParams)
{
	bool ReturnValue = false;
	
	int client = GetNativeCell(1);
	
	if (IsValidClient(client))
	{
		ReturnValue = b_TabDown[client];
	}
	
	return ReturnValue;
}

public Native_CF_GetJumpStatus(Handle plugin, int numParams)
{
	bool ReturnValue = false;
	
	int client = GetNativeCell(1);
	
	if (IsValidClient(client))
	{
		ReturnValue = b_JumpDown[client];
	}
	
	return ReturnValue;
}

public Native_CF_GetCrouchStatus(Handle plugin, int numParams)
{
	bool ReturnValue = false;
	
	int client = GetNativeCell(1);
	
	if (IsValidClient(client))
	{
		ReturnValue = b_CrouchDown[client];
	}
	
	return ReturnValue;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	if (!IsValidClient(client))
		return Plugin_Continue;
	
	Action ReturnValue = CFB_CallForward(g_OnRunCmd, client, buttons, impulse, weapon); //NOTE TO SELF: This might be a very, very bad idea since it means we're calling a forward every frame for every player. Could get VERY expensive. The rest of the game mode is fairly light so it shouldn't be en enormous problem, but if it starts to get bad later on in development then definitely REMOVE this.
	Action newValue;

	if (ReturnValue != Plugin_Handled && ReturnValue != Plugin_Stop && (buttons & IN_ATTACK2 != 0) && !CF_GetM2Status(client))
	{
		newValue = CFB_CallForward(g_OnM2, client, buttons, impulse, weapon);
		if (newValue > ReturnValue)
		{
			ReturnValue = newValue;
		}
	}
	
	if (ReturnValue != Plugin_Handled && ReturnValue != Plugin_Stop && (buttons & IN_ATTACK3 != 0) && !CF_GetM3Status(client))
	{
		newValue = CFB_CallForward(g_OnM3, client, buttons, impulse, weapon);
		if (newValue > ReturnValue)
		{
			ReturnValue = newValue;
		}
	}
	
	if (ReturnValue != Plugin_Handled && ReturnValue != Plugin_Stop && (buttons & IN_RELOAD != 0) && !CF_GetReloadStatus(client))
	{
		newValue = CFB_CallForward(g_OnReload, client, buttons, impulse, weapon);
		if (newValue > ReturnValue)
		{
			ReturnValue = newValue;
		}
	}
	
	if (ReturnValue != Plugin_Handled && ReturnValue != Plugin_Stop && (buttons & IN_SCORE != 0) && !CF_GetTabStatus(client))
	{
		newValue = CFB_CallForward(g_OnTab, client, buttons, impulse, weapon);
		if (newValue > ReturnValue)
		{
			ReturnValue = newValue;
		}
	}
	
	if (ReturnValue != Plugin_Handled && ReturnValue != Plugin_Stop && (buttons & IN_JUMP != 0) && !CF_GetJumpStatus(client))
	{
		newValue = CFB_CallForward(g_OnJump, client, buttons, impulse, weapon);
		if (newValue > ReturnValue)
		{
			ReturnValue = newValue;
		}
	}
	
	if (ReturnValue != Plugin_Handled && ReturnValue != Plugin_Stop && (buttons & IN_DUCK != 0) && !CF_GetCrouchStatus(client))
	{
		newValue = CFB_CallForward(g_OnCrouch, client, buttons, impulse, weapon);
		if (newValue > ReturnValue)
		{
			ReturnValue = newValue;
		}
	}
	
	b_M2Down[client] = (buttons & IN_ATTACK2 != 0);
	b_M3Down[client] = (buttons & IN_ATTACK3 != 0);
	b_ReloadDown[client] = (buttons & IN_RELOAD != 0);
	b_TabDown[client] = (buttons & IN_SCORE != 0);
	b_JumpDown[client] = (buttons & IN_JUMP != 0);
	b_CrouchDown[client] = (buttons & IN_DUCK != 0);
	
	return ReturnValue;
}

public Action CFB_CallForward(GlobalForward forwardToCall, int &client, int &buttons, int &impulse, int &weapon)
{
	Call_StartForward(forwardToCall);
	
	Call_PushCellRef(client);
	Call_PushCellRef(buttons);
	Call_PushCellRef(impulse);
	Call_PushCellRef(weapon);
	
	Action ReturnValue;
	Call_Finish(ReturnValue);
	return ReturnValue;
}

public Action CFB_OnCallForMedic(int client, const char[] command, int args)
{
	if (!IsValidClient(client))
		return Plugin_Continue;
	
	char arg1[8], arg2[8];
	int num1, num2;
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	num1 = StringToInt(arg1);
	num2 = StringToInt(arg2);
	
	if (num1 != 0 || num2 != 0) // voicemenu 0 0 only, thank you CookieCat!
		return Plugin_Continue;
	
	Call_StartForward(g_OnCallForMedic);
	Call_PushCell(client);
	Call_Finish();
	
	return Plugin_Continue;
}