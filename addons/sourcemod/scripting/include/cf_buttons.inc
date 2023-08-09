bool b_M2Down[MAXPLAYERS + 1] = { false, ... };
bool b_M3Down[MAXPLAYERS + 1] = { false, ... };
bool b_ReloadDown[MAXPLAYERS + 1] = { false, ... };

GlobalForward g_OnRunCmd;
GlobalForward g_OnM2;
GlobalForward g_OnM3;
GlobalForward g_OnReload;

public void CFB_MakeForwards()
{
	g_OnRunCmd = new GlobalForward("CF_OnPlayerRunCmd", ET_Event, Param_CellByRef, Param_CellByRef, Param_CellByRef, Param_CellByRef);
	g_OnM2 = new GlobalForward("CF_OnPlayerM2", ET_Event, Param_CellByRef, Param_CellByRef, Param_CellByRef, Param_CellByRef);
	g_OnM3 = new GlobalForward("CF_OnPlayerM3", ET_Event, Param_CellByRef, Param_CellByRef, Param_CellByRef, Param_CellByRef);
	g_OnReload = new GlobalForward("CF_OnPlayerReload", ET_Event, Param_CellByRef, Param_CellByRef, Param_CellByRef, Param_CellByRef);
}

public void CFB_MakeNatives()
{
	CreateNative("CF_GetM2Status", Native_CF_GetM2Status);
	CreateNative("CF_GetM3Status", Native_CF_GetM3Status);
	CreateNative("CF_GetReloadStatus", Native_CF_GetReloadStatus);
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
	
	b_M2Down[client] = (buttons & IN_ATTACK2 != 0);
	b_M3Down[client] = (buttons & IN_ATTACK3 != 0);
	b_ReloadDown[client] = (buttons & IN_RELOAD != 0);
	
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