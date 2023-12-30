#define EF_BONEMERGE			(1 << 0)
#define EF_BONEMERGE_FASTCULL	(1 << 7)
#define EF_PARENT_ANIMATES		(1 << 9)
	
int i_ClientAnimator[MAXPLAYERS + 1] = { -1, ... };

public void CFA_ApplyAnimatorOnDelay(DataPack pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	char animator[255], model[255];
	ReadPackString(pack, animator, sizeof(animator));
	ReadPackString(pack, model, sizeof(model));
	delete pack;
	
	CFA_ApplyAnimator(client, animator, model);
}

//TODO: Remove "dummy" from the equation, apply nodraw to the client, parent phys to the client.

public void CFA_ApplyAnimator(int client, char anim_model[255], char vis_model[255])
{
	CFA_RemoveAnimator(client);
	int animator = CreateEntityByName("prop_dynamic_override");
	if (IsValidEntity(animator))
	{
		//Step 1: Create and hide the animator, and give it the proper model.
		//SetEntPropEnt(animator, Prop_Data, "m_hOwnerEntity", client);
		SetEntityModel(animator, anim_model);
		
		//SetEntPropEnt(dummy, Prop_Data, "m_hOwnerEntity", client);
		//SetEntityModel(dummy, vis_model);
		
		//SDKHook(animator, SDKHook_SetTransmit, Animator_Transmit);
		SetEntityRenderMode(client, RENDER_TRANSALPHA);
		SetEntityRenderColor(client, 0, 0, 0, 0);
		
		//Step 2: Spawn the animator.
		DispatchSpawn(animator);		
		AcceptEntityInput(animator, "Enable");
		
		//DispatchSpawn(dummy);		
		//AcceptEntityInput(dummy, "Enable");
		
		//Step 3: Teleport the animator the client's position.
		float pos[3], ang[3];
		GetClientAbsOrigin(client, pos);
		GetClientAbsAngles(client, ang);
		TeleportEntity(animator, pos, ang, NULL_VECTOR);
		
		SetEntProp(animator, Prop_Send, "m_CollisionGroup", 11);
		//SetEntProp(client, Prop_Send, "m_fEffects", EF_NODRAW);
		//TeleportEntity(dummy, pos, ang, NULL_VECTOR);
		
		//Step 4: Parent the client to the animator using bonemerge.
		
		/*SetEntProp(client, Prop_Send, "m_fEffects", EF_BONEMERGE|EF_PARENT_ANIMATES);
		SetVariantString("!activator");
		AcceptEntityInput(client, "SetParent", animator, client);
		SetVariantString("root");
		AcceptEntityInput(client, "SetParentAttachmentMaintainOffset");
		*/
		//Step 5: Copy the client's current sequence to the animator.
		
		//Step 6: FUCKING PRAY.
		i_ClientAnimator[client] = EntIndexToEntRef(animator);
		SDKUnhook(client, SDKHook_PreThink, CFA_PreThink);
		SDKHook(client, SDKHook_PreThink, CFA_PreThink);
	}
	else
	{
		i_ClientAnimator[client] = -1;
	}
}

public Action CFA_PreThink(int client)
{
	int animator = CFA_GetAnimator(client);
	if (!IsValidEntity(animator))
	{
		SDKUnhook(client, SDKHook_PreThink, CFA_PreThink);
		return Plugin_Stop;
	}
		
	float pos[3], ang[3];
	GetClientAbsOrigin(client, pos);
	GetClientAbsAngles(client, ang);
		
	int val = GetEntProp(animator, Prop_Send, "m_ubInterpolationFrame");
	TeleportEntity(animator, pos, ang, NULL_VECTOR);
	SetEntProp(animator, Prop_Send, "m_ubInterpolationFrame", val);
	
	val = GetEntProp(client, Prop_Send, "m_nSequence");
	SetEntProp(animator, Prop_Send, "m_nSequence", val);
	
	val = GetEntProp(client, Prop_Send, "m_nSkin");
	SetEntProp(animator, Prop_Send, "m_nSkin", val);
	
	SetEntPropFloat(animator, Prop_Send, "m_flPlaybackRate", GetEntPropFloat(client, Prop_Send, "m_flPlaybackRate"));
	
	return Plugin_Continue;
}

public void CFA_RemoveAnimator(int client)
{
	int animator = CFA_GetAnimator(client);
	if (IsValidEntity(animator))
	{
		AcceptEntityInput(client, "ClearParent");
		TeleportEntity(animator, OFF_THE_MAP, NULL_VECTOR, NULL_VECTOR);
		RemoveEntity(animator);
	}
}

public int CFA_GetAnimator(int client) { return EntRefToEntIndex(i_ClientAnimator[client]); }