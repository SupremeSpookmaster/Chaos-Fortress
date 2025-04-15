int CF_SndChans[10] = {
	SNDCHAN_AUTO,
	SNDCHAN_BODY,
	SNDCHAN_ITEM,
	SNDCHAN_REPLACE,
	SNDCHAN_STATIC,
	SNDCHAN_STREAM,
	SNDCHAN_USER_BASE,
	SNDCHAN_VOICE,
	SNDCHAN_VOICE_BASE,
	SNDCHAN_WEAPON
};

int i_SoundLevel[2048] = { 100, ... };
int i_SoundChannel[2048] = { 7, ... };
int i_SoundMinPitch[2048] = { 100, ... };
int i_SoundMaxPitch[2048] = { 100, ... };
int i_SoundTimes[2048] = { 1, ... };
int i_SoundPlayMode[2048] = { 0, ... };

bool b_SoundExists[2048] = { false, ... };
bool b_SoundIsGlobal[2048] = { false, ... };

float f_SoundVolume[2049] = { 1.0, ... };
float f_SoundChance[2048] = { 1.0, ... };

char s_SoundFile[2048][255];

methodmap CFSound __nullable__
{
	public CFSound()
	{
		for (int i = 0; i < 2048; i++)
		{
			if (!b_SoundExists[i])
			{
				b_SoundExists[i] = true;
				return view_as<CFSound>(i);
			}
		}

		CPrintToChatAll("{red}TOO MANY SOUNDS EXIST AT THE SAME TIME! SCREENSHOT THIS AND SEND TO A DEV!");
		return view_as<CFSound>(-1);
	}

	property int index
	{
		public get() { return view_as<int>(this); }
	}

	property int i_Level
	{
		public get() { return i_SoundLevel[this.index]; }
		public set(int value) { i_SoundLevel[this.index] = value; }
	}

	property int i_Channel
	{
		public get() { return i_SoundChannel[this.index]; }
		public set(int value) { i_SoundChannel[this.index] = value; }
	}

	property int i_MinPitch
	{
		public get() { return i_SoundMinPitch[this.index]; }
		public set(int value) { i_SoundMinPitch[this.index] = value; }
	}

	property int i_MaxPitch
	{
		public get() { return i_SoundMaxPitch[this.index]; }
		public set(int value) { i_SoundMaxPitch[this.index] = value; }
	}

	property int i_Times
	{
		public get() { return i_SoundTimes[this.index]; }
		public set(int value) { i_SoundTimes[this.index] = value; }
	}

	property int i_PlayMode
	{
		public get() { return i_SoundPlayMode[this.index]; }
		public set(int value) { i_SoundPlayMode[this.index] = value; }
	}

	property float f_Volume
	{
		public get() { return f_SoundVolume[this.index]; }
		public set(float value) { f_SoundVolume[this.index] = value; }
	}

	property float f_Chance
	{
		public get() { return f_SoundChance[this.index]; }
		public set(float value) { f_SoundChance[this.index] = value; }
	}

	property bool b_Exists
	{
		public get() { return b_SoundExists[this.index]; }
	}

	property bool b_Global
	{
		public get() { return b_SoundIsGlobal[this.index]; }
		public set(bool value) { b_SoundIsGlobal[this.index] = value; }
	}

	public void SetFile(char[] cue) { strcopy(s_SoundFile[this.index], 255, cue); }
	public void GetFile(char[] output, int size) { strcopy(output, size, s_SoundFile[this.index]); }

	public bool Play(int source)
	{
		char file[255];
		this.GetFile(file, 255);

		for (int plays = 0; plays < this.i_Times; plays++)
		{
			int level = this.i_Level;

			if (IsValidClient(source))
			{
				level -= CF_GetDialogueReduction(source);

				TFTeam targTeam = TFTeam_Unassigned;

				switch(this.i_PlayMode)
				{
					case 0:	//Everyone
					{
						EmitSoundToAll(file, this.b_Global ? SOUND_FROM_PLAYER : source, CF_SndChans[this.i_Channel], this.i_Level, _, this.f_Volume, GetRandomInt(this.i_MinPitch, this.i_MaxPitch));
					}
					case 1:	//Self only
					{
						EmitSoundToClient(source, file, _, CF_SndChans[this.i_Channel], this.i_Level, _, this.f_Volume, GetRandomInt(this.i_MinPitch, this.i_MaxPitch));
					}
					case 2: //Allies only
					{
						targTeam = TF2_GetClientTeam(source);
					}
					case 3:	//Enemies only
					{
						targTeam = grabEnemyTeam(source);
					}
				}
				
				if (targTeam != TFTeam_Unassigned)
				{
					for (int i = 1; i <= MaxClients; i++)
					{
						if (IsValidMulti(i, false, _, true, targTeam) && i != source)
						{
							EmitSoundToClient(i, file, this.b_Global ? SOUND_FROM_PLAYER : source, CF_SndChans[this.i_Channel], this.i_Level, _, this.f_Volume, GetRandomInt(this.i_MinPitch, this.i_MaxPitch));
						}
					}
				}
			}
			else
				EmitSoundToAll(file, this.b_Global ? SOUND_FROM_PLAYER : source, CF_SndChans[this.i_Channel], this.i_Level, _, this.f_Volume, GetRandomInt(this.i_MinPitch, this.i_MaxPitch));
		}
	}

	public void Destroy()
	{
		this.i_Level = 100;
		this.i_Channel = 7;
		this.i_MinPitch = 100;
		this.i_MaxPitch = 100;
		this.i_Times = 1;
		this.i_PlayMode = 0;

		this.b_Global = false;

		this.f_Volume = 1.0;
		this.f_Chance = 1.0;

		this.SetFile("");

		b_SoundExists[this.index] = false;
	}
}

bool b_CueExists[2048] = { false, ... };

int i_CueNumSounds[2048] = { 0, ... };

char s_CueName[2048][255];

CFSound g_CueSounds[2048][2048];

methodmap CFSoundCue __nullable__
{
	public CFSoundCue()
	{
		for (int i = 0; i < 2048; i++)
		{
			if (!b_CueExists[i])
			{
				b_CueExists[i] = true;
				return view_as<CFSoundCue>(i);
			}
		}

		CPrintToChatAll("{red}TOO MANY SOUND CUES EXIST AT THE SAME TIME! SCREENSHOT THIS AND SEND TO A DEV!");
		return view_as<CFSoundCue>(-1);
	}

	property int index
	{
		public get() { return view_as<int>(this); }
	}

	property bool b_Exists
	{
		public get() { return b_CueExists[this.index]; }
	}

	property int i_NumSounds
	{
		public get() { return i_CueNumSounds[this.index]; }
		public set(int value) { i_CueNumSounds[this.index] = value; }
	}

	public void SetCue(char[] cue) { strcopy(s_CueName[this.index], 255, cue); }
	public void GetCue(char[] output, int size) { strcopy(output, size, s_CueName[this.index]); }

	public CFSound GetRandomSound()
	{
		if (this.i_NumSounds < 1)
			return null;

		return g_CueSounds[this.index][GetRandomInt(0, this.i_NumSounds - 1)];
	}

	public void AddSound(CFSound sound)
	{
		g_CueSounds[this.index][this.i_NumSounds] = sound;
		this.i_NumSounds++;
	}

	public void ClearSounds()
	{
		for (int i = 0; i < this.i_NumSounds; i++)
			g_CueSounds[this.index][i].Destroy();

		this.i_NumSounds = 0;
	}

	public void Destroy()
	{
		b_CueExists[this.index] = false;
		this.SetCue("");
		this.ClearSounds();
	}
}

GlobalForward g_SoundHook;

float f_LastSoundHook[MAXPLAYERS + 1] = { 0.0, ... };
float f_Silenced[MAXPLAYERS + 1] = { 0.0, ... };

public void CFS_MapChange()
{
	for (int i = 0; i <= MaxClients; i++)
	{
		f_LastSoundHook[i] = 0.0;
		f_Silenced[i] = 0.0;
	}
}

public void CFS_OnPluginStart()
{
	g_SoundHook = new GlobalForward("CF_SoundHook", ET_Event, Param_String, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_CellByRef);
	AddNormalSoundHook(view_as<NormalSHook>(NormalSoundHook));
}

public void CFS_MakeNatives()
{
	CreateNative("CF_GetRandomSound", Native_CF_GetRandomSound);
	CreateNative("CF_PlayRandomSound", Native_CF_PlayRandomSound);
	CreateNative("CF_SilenceCharacter", Native_CF_SilenceCharacter);
}

public KeyValType GetRand(char Config[255], char Sound[255], char Output[255])
{
	if (!Config[0])	//This check should not be necessary, but the plugin throws errors if it's not here.
		return KeyValType_Null;

	ConfigMap cfgMap = new ConfigMap(Config);
	
	if (cfgMap == null)
		return KeyValType_Null;
		
	char snd[255];
		
	Format(snd, sizeof(snd), "character.sounds.%s", Sound);
	ConfigMap newMap = cfgMap.GetSection(snd);
	
	if (newMap == null)
	{
		DeleteCfg(cfgMap);
		return KeyValType_Null;
	}
		
	StringMapSnapshot snap = newMap.Snapshot();
	
	int chosen = GetRandomInt(0, snap.Length - 1);
	
	char key[255];
	snap.GetKey(chosen, key, sizeof(key));
	delete snap;
	
	#if defined DEBUG_SOUNDS
	PrintToServer("CF_GetRandomSound retrieved a ConfigMap with the following path: %s.%s", snd, key);
	#endif
	
	char OldKey[255];
	Format(OldKey, sizeof(OldKey), "%s", key);
	KeyValType ReturnValue = KeyValType_Null;
	if (StrContains(key, ".") != -1)
	{
		ReplaceString(key, sizeof(key), ".", "\\.");
		Format(Output, sizeof(Output), "%s", OldKey);
		ReturnValue = KeyValType_Section;
		#if defined DEBUG_SOUNDS
		PrintToServer("CF_GetRandomSound retrieved a ConfigMap which contained a '.' in its path. New path: %s.%s", snd, key);
		PrintToServer("The key itself is currently %s", key);
		#endif
	}
	else
	{
		newMap.Get(key, Output, sizeof(Output));
		ReturnValue = KeyValType_Value;
	}
	
	/*char fullPath[255];
	Format(fullPath, sizeof(fullPath), "character.sounds.%s.%s", Sound, key);
	PrintToServer("Full path should be %s.", fullPath);

	KeyValType ReturnValue = KeyValType_Null;
	
	switch(newMap.GetKeyValType(key))
	{
		case KeyValType_Value: //This works as intended.
		{
			newMap.Get(key, Output, sizeof(Output));
			
			//#if defined DEBUG_SOUNDS
			PrintToServer("CF_GetRandomSound retrieved a ConfigMap with KeyValType_Value, the value is %s.", Output);
			//#endif
			
			ReturnValue = KeyValType_Value;
		}
		case KeyValType_Section:
		{
			Format(Output, sizeof(Output), "%s", OldKey);
			
			//#if defined DEBUG_SOUNDS
			PrintToServer("CF_GetRandomSound retrieved a ConfigMap with KeyValType_Section, the section name is %s.", Output);
			//#endif
			
			ReturnValue = KeyValType_Section;
		}
		default:
		{
			//#if defined DEBUG_SOUNDS
			PrintToServer("CF_GetRandomSound retrieved a ConfigMap with KeyValType_Null, meaning the section does not exist. This should not be possible.");
			//#endif
		}
	}*/
	
	DeleteCfg(cfgMap);
	return ReturnValue;
}

bool PlayRand(int source, char Config[255], char Sound[255])
{
	if (!IsValidMulti(source))
		return false;

	char ourConf[255];
	strcopy(ourConf, 255, Config);
	if (CF_IsPlayerCharacter(source) && StrEqual(ourConf, ""))
	{
		CF_GetPlayerConfig(source, ourConf, sizeof(ourConf));
	}
	
	char snd[255] = ""; char checkFile[255];
	Format(checkFile, sizeof(checkFile), "sound/");
	KeyValType kvType = GetRand(ourConf, Sound, snd);//CF_GetRandomSound(ourConf, Sound, snd, sizeof(snd));
	for (int i = 0; i < sizeof(snd); i++)
	{
		char character = snd[i];
		if (!IsCharSoundscript(character))
			Format(checkFile, sizeof(checkFile), "%s%c", checkFile, character);
	}

	if (!CheckFile(checkFile))
		return false;
	
	if (!snd[0])
		return false;

	PrecacheSound(snd);

	int playMode = 0;
	
	int level = 100;
	float volume = 1.0;
	int channel = 7;
	bool global = false;
	int maxPitch = 100;
	int minPitch = 100;
	int times = 1;

	bool CanPlay = true;
	
	if (kvType == KeyValType_Section)
	{
		char path[255], tempSnd[255];
			
		tempSnd = snd;
		ReplaceString(tempSnd, sizeof(tempSnd), ".", "\\.");
			
		Format(path, sizeof(path), "character.sounds.%s.%s", Sound, tempSnd);
			
		ConfigMap cfgMap = new ConfigMap(ourConf);
		if (cfgMap == null)
			return false;

		ConfigMap section = cfgMap.GetSection(path);
		//ConfigMap echoSection = section.GetSection("echo");
			
		if (section != null)
		{			
			level = GetIntFromCFGMap(section, "level", 100);
			playMode = GetIntFromCFGMap(section, "source", 0);
				
			volume = GetFloatFromCFGMap(section, "volume", 1.0);
			channel = GetIntFromCFGMap(section, "channel", 7);
			global = GetBoolFromCFGMap(section, "global", false);
				
			float chance = GetFloatFromCFGMap(section, "chance", 1.0);
			
			minPitch = GetIntFromCFGMap(section, "pitch_min", 100);
			maxPitch = GetIntFromCFGMap(section, "pitch_max", 100);
			times = GetIntFromCFGMap(section, "times", 1);
				
			CanPlay = GetRandomFloat(0.0, 1.0) <= chance;
		}
		else
		{
			CanPlay = false;
		}
		
		if (CanPlay)
			level -= CF_GetDialogueReduction(source);
		
		DeleteCfg(cfgMap);
	}
	
	if (CanPlay)
	{
		TFTeam targTeam = TFTeam_Unassigned;
		
		for (int plays = 0; plays < times; plays++)
		{
			switch(playMode)
			{
				case 0:	//Everyone
				{
					EmitSoundToAll(snd, global ? SOUND_FROM_PLAYER : source, CF_SndChans[channel], level, _, volume, GetRandomInt(minPitch, maxPitch));
				}
				case 1:	//Self only
				{
					EmitSoundToClient(source, snd, _, CF_SndChans[channel], level, _, volume, GetRandomInt(minPitch, maxPitch));
				}
				case 2: //Allies only
				{
					targTeam = TF2_GetClientTeam(source);
				}
				case 3:	//Enemies only
				{
					targTeam = grabEnemyTeam(source);
				}
			}
			
			if (targTeam != TFTeam_Unassigned)
			{
				for (int i = 1; i <= MaxClients; i++)
				{
					if (IsValidMulti(i, false, _, true, targTeam) && i != source)
					{
						EmitSoundToClient(i, snd, global ? SOUND_FROM_PLAYER : source, CF_SndChans[channel], level, _, volume, GetRandomInt(minPitch, maxPitch));
					}
				}
			}
		}
	}
	
	return CanPlay;
}

public Action Sound_Echo(Handle echo, DataPack pack)
{
	ResetPack(pack);
	
	int playMode = ReadPackCell(pack);
	int source = ReadPackCell(pack);
	int level = ReadPackCell(pack);
	float volume = ReadPackFloat(pack);
	int channel = ReadPackCell(pack);
	bool global = ReadPackCell(pack);
	int numEchoes = ReadPackCell(pack);
	float echoDelay = ReadPackFloat(pack);
	int levelReduction = ReadPackCell(pack);
	float volumeReduction = ReadPackFloat(pack);
	int minPitch = ReadPackCell(pack);
	int maxPitch = ReadPackCell(pack);
	char snd[255];
	ReadPackString(pack, snd, sizeof(snd));
	
	volume -= volumeReduction;
	level -= levelReduction;
	numEchoes--;
	
	TFTeam targTeam = TFTeam_Unassigned;
		
	switch(playMode)
	{
		case 0:	//Everyone
		{
			EmitSoundToAll(snd, global || !IsValidEntity(source) ? SOUND_FROM_PLAYER : source, CF_SndChans[channel], level, _, volume, GetRandomInt(minPitch, maxPitch));
		}
		case 1:	//Self only
		{
			if (IsValidClient(source))
			{
				EmitSoundToClient(source, snd, _, CF_SndChans[channel], level, _, volume, GetRandomInt(minPitch, maxPitch));
			}
		}
		case 2: //Allies only
		{
			if (IsValidClient(source))
			{
				targTeam = TF2_GetClientTeam(source);
			}
		}
		case 3:	//Enemies only
		{
			if (IsValidClient(source))
			{
				targTeam = grabEnemyTeam(source);
			}
		}
	}
		
	if (targTeam != TFTeam_Unassigned)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidMulti(i, false, _, true, targTeam) && i != source)
			{
				EmitSoundToClient(i, snd, global || !IsValidEntity(source) ? SOUND_FROM_PLAYER : source, CF_SndChans[channel], level, _, volume, GetRandomInt(minPitch, maxPitch));
			}
		}
	}
	
	if (numEchoes > 0)
	{
		DataPack pack2 = new DataPack();
		CreateDataTimer(echoDelay, Sound_Echo, pack2, TIMER_FLAG_NO_MAPCHANGE);
		WritePackCell(pack2, playMode);
		WritePackCell(pack2, source);
		WritePackCell(pack2, level);
		WritePackFloat(pack2, volume);
		WritePackCell(pack2, channel);
		WritePackCell(pack2, global);
		WritePackCell(pack2, numEchoes);
		WritePackFloat(pack2, echoDelay);
		WritePackCell(pack2, levelReduction);
		WritePackFloat(pack2, volumeReduction);
		WritePackCell(pack2, minPitch);
		WritePackCell(pack2, maxPitch);
		WritePackString(pack2, snd);
	}
	
	return Plugin_Continue;
}

public bool PlaySpecificReplacement(int client, char sound[PLATFORM_MAX_PATH])
{
	if (!CF_IsPlayerCharacter(client))
		return false;
		
	char Sound[255], conf[255];
	Format(Sound, sizeof(Sound), "%s", sound);
	StringToLower(Sound);
	CF_GetPlayerConfig(client, conf, sizeof(conf));
	
	if (!conf[0])
		return false;

	ConfigMap map = new ConfigMap(conf);
	if (map == null)
		return false;
		
	ConfigMap map2 = map.GetSection("character.sounds");
	if (map2 == null)
	{
		DeleteCfg(map)
		return false;
	}

	StringMapSnapshot snap = map2.Snapshot();
	
	bool played = false;
	
	for (int i = 0; i < snap.Length; i++)
	{
		char name[255], tempName[255];
		snap.GetKey(i, name, sizeof(name));
		Format(tempName, sizeof(tempName), "%s", name);
		ReplaceString(tempName, sizeof(tempName), "sound_replace_", "");
		
		if (StrContains(Sound, tempName) != -1)
		{
			played = PlayRand(client, "", name);
			break;
		}
	}
	
	DeleteCfg(map);
	delete snap;
	
	return played;
}

public Action NormalSoundHook(int clients[64],int &numClients,char strSound[PLATFORM_MAX_PATH],int &entity,int &channel,float &volume,int &level,int &pitch,int &flags)
{
	Call_StartForward(g_SoundHook);
	
	Call_PushStringEx(strSound, sizeof(strSound), SM_PARAM_STRING_UTF8|SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_PushCellRef(entity);
	Call_PushCellRef(channel);
	Call_PushFloatRef(volume);
	Call_PushCellRef(level);
	Call_PushCellRef(pitch);
	Call_PushCellRef(flags);
	
	Action result = Plugin_Continue;
	Call_Finish(result);

	if (IsValidClient(entity))
	{
		if (result != Plugin_Stop && result != Plugin_Handled)
		{
			if (StrContains(strSound, "vo/") != -1)
			{
				float gameTime = GetGameTime();
				if (gameTime >= f_LastSoundHook[entity] && gameTime >= f_Silenced[entity])
				{
					if (IsCasting(entity) && StrContains(strSound, "sf13_spell_") != -1)
						return Plugin_Handled;
						
					char SoundA[255], SoundB[255];
					Format(SoundB, sizeof(SoundB), "%s", strSound);
					StringToLower(SoundB);
					Format(SoundA, sizeof(SoundA), "sound_replace_%s", SoundB);
					ReplaceString(SoundA, sizeof(SoundA), ".mp3", "");
					ReplaceString(SoundA, sizeof(SoundA), ".wav", "");
						
					bool played = false;
						
					if (PlayRand(entity, "", SoundA))
					{
						played = true;
					}
					else
					{
						played = PlaySpecificReplacement(entity, strSound);
					}
						
					if (!played)
					{
						played = PlayRand(entity, "", "sound_replace_all");
					}
					
					f_LastSoundHook[entity] = GetGameTime() + 0.01;
						
					if (played)
					{
						return Plugin_Handled;
					}
				}
				else
				{
					return Plugin_Handled;
				}
			}
			
			return result;
		}
		
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public any Native_CF_GetRandomSound(Handle plugin, int numParams)
{
	char Config[255], Sound[255], Output[255];
	GetNativeString(1, Config, sizeof(Config));
	GetNativeString(2, Sound, sizeof(Sound));
	KeyValType ReturnVal = GetRand(Config, Sound, Output);
	int len = GetNativeCell(4);
	SetNativeString(3, Output, len, false);
	return ReturnVal;
}

public Native_CF_PlayRandomSound(Handle plugin, int numParams)
{
	int source = GetNativeCell(1);
	char Config[255], Sound[255];
	GetNativeString(2, Config, sizeof(Config));
	GetNativeString(3, Sound, sizeof(Sound));
	return PlayRand(source, Config, Sound);
}

public Native_CF_SilenceCharacter(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	float duration = GetNativeCell(2);
	
	if (IsValidClient(client))
		f_Silenced[client] = GetGameTime() + duration;
}