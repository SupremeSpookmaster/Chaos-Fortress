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

//4096 is as high as I can go here before the compiler starts failing due to memory limitations.
//Therefore, CF imposes a hard-cap of 4096 sounds existing at a time.
//This comes out to a maximum of 170 sounds in use per character for a 24-player server, or 128 for a 32-player server.
//Realistically, this limitation should only be a problem for 100-player servers, which I don't intend for CF to ever support.
int i_SoundLevel[4096] = { 100, ... };
int i_SoundChannel[4096] = { 7, ... };
int i_SoundMinPitch[4096] = { 100, ... };
int i_SoundMaxPitch[4096] = { 100, ... };
int i_SoundTimes[4096] = { 1, ... };
int i_SoundPlayMode[4096] = { 0, ... };

bool b_SoundExists[4096] = { false, ... };
bool b_SoundIsGlobal[4096] = { false, ... };

float f_SoundVolume[4096] = { 1.0, ... };
float f_SoundChance[4096] = { 1.0, ... };

char s_SoundFile[4096][255];

methodmap CFSound __nullable__
{
	public CFSound()
	{
		for (int i = 0; i < 4096; i++)
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

	public bool SetFile(char snd[255])
	{ 
		if (!CFS_CheckDoesSoundExist(snd))
			return false;

		strcopy(s_SoundFile[this.index], 255, snd);
		PrecacheSound(snd);
		return true;
	}

	public void GetFile(char[] output, int size) { strcopy(output, size, s_SoundFile[this.index]); }

	public bool Play(int source)
	{
		if (GetRandomFloat() > this.f_Chance)
			return false;

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
						EmitSoundToAll(file, this.b_Global ? SOUND_FROM_PLAYER : source, CF_SndChans[this.i_Channel], level, _, this.f_Volume, GetRandomInt(this.i_MinPitch, this.i_MaxPitch));
					}
					case 1:	//Self only
					{
						EmitSoundToClient(source, file, _, CF_SndChans[this.i_Channel], level, _, this.f_Volume, GetRandomInt(this.i_MinPitch, this.i_MaxPitch));
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
							EmitSoundToClient(i, file, this.b_Global ? SOUND_FROM_PLAYER : source, CF_SndChans[this.i_Channel], level, _, this.f_Volume, GetRandomInt(this.i_MinPitch, this.i_MaxPitch));
						}
					}
				}
			}
			else
				EmitSoundToAll(file, this.b_Global ? SOUND_FROM_PLAYER : source, CF_SndChans[this.i_Channel], this.i_Level, _, this.f_Volume, GetRandomInt(this.i_MinPitch, this.i_MaxPitch));
		}

		return true;
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

//4096 is as high as I can go here before the compiler starts failing due to memory limitations.
//Therefore, CF imposes a hard-cap of 4096 sound cues existing at a time. Furthermore, each individual sound cue only supports up to 64 sounds.
//This comes out to a maximum of 170 sound cues in use per character for a 24-player server, or 128 for a 32-player server.
//Realistically, this limitation should only be a problem for 100-player servers, which I don't intend for CF to ever support.
bool b_CueExists[4096] = { false, ... };

int i_CueNumSounds[4096] = { 0, ... };

char s_CueName[4096][255];

CFSound g_CueSounds[4096][64];

methodmap CFSoundCue __nullable__
{
	public CFSoundCue()
	{
		for (int i = 0; i < 4096; i++)
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
		if (this.i_NumSounds >= 64)
			return;

		g_CueSounds[this.index][this.i_NumSounds] = sound;
		this.i_NumSounds++;
	}

	public void ClearSounds()
	{
		for (int i = 0; i < this.i_NumSounds; i++)
			g_CueSounds[this.index][i].Destroy();

		this.i_NumSounds = 0;
	}

	public void DebugSounds(int client)
	{
		for (int i = 0; i < this.i_NumSounds; i++)
		{
			CFSound snd = g_CueSounds[this.index][i];
			if (snd.b_Exists)
			{
				char sndFile[255];
				snd.GetFile(sndFile, 255);
				CPrintToChat(client, "{unusual}Cue has sound {yellow}%s\nLevel: %i | Channel: %i | MinPitch: %i | MaxPitch: %i | Times: %i", sndFile, snd.i_Level, snd.i_Channel, snd.i_MinPitch, snd.i_MaxPitch, snd.i_Times);
				CPrintToChat(client, "PlayMode: %i | Volume: %.2f | Chance: %.2f | Global: %i", snd.i_PlayMode, snd.f_Volume, snd.f_Chance, snd.b_Global);
			}
		}
	}

	public void Destroy()
	{
		b_CueExists[this.index] = false;
		this.SetCue("");
		this.ClearSounds();
	}
}

public void CFS_CreateSounds(int client, ConfigMap map)
{
	CFCharacter chara = GetCharacterFromClient(client);
	if (chara == null)
		return;

	chara.ClearSoundCues();
	if (map == null)
		return;

	StringMapSnapshot snap = map.Snapshot();
	for (int i = 0; i < snap.Length; i++)
	{
		char key[255];
		snap.GetKey(i, key, 255);

		ConfigMap subsection = map.GetSection(key);
		if (subsection != null)
		{
			CFSoundCue cue = new CFSoundCue();
			if (cue.index == -1)
				continue;

			cue.SetCue(key);
			chara.AddSoundCue(cue);

			StringMapSnapshot subSnap = subsection.Snapshot();
			for (int j = 0; j < subSnap.Length; j++)
			{
				char subKey[255];
				subSnap.GetKey(j, subKey, 255);
				CFSound sound = new CFSound();
				if (sound.index == -1)
				{
					delete subSnap;
					continue;
				}

				char file[255];

				if (StrContains(subKey, ".") != -1)
				{
					file = subKey;

					char path[255];
					strcopy(path, sizeof(path), subKey);
					ReplaceString(path, sizeof(path), ".", "\\.");
					Format(path, sizeof(path), "%s.%s", key, path);

					ConfigMap sndSec = map.GetSection(path);
					if (sndSec != null)
					{
						sound.f_Volume = GetFloatFromCFGMap(sndSec, "volume", 1.0);
						sound.f_Chance = GetFloatFromCFGMap(sndSec, "chance", 1.0);

						sound.b_Global = GetBoolFromCFGMap(sndSec, "global", false);
				
						sound.i_Channel = GetIntFromCFGMap(sndSec, "channel", 7);
						sound.i_Level = GetIntFromCFGMap(sndSec, "level", 100);
						sound.i_PlayMode = GetIntFromCFGMap(sndSec, "source", 0);
						sound.i_MinPitch = GetIntFromCFGMap(sndSec, "pitch_min", 100);
						sound.i_MaxPitch = GetIntFromCFGMap(sndSec, "pitch_max", 100);
						sound.i_Times = GetIntFromCFGMap(sndSec, "times", 1);
					}
				}
				else
					subsection.Get(subKey, file, sizeof(file));

				if (sound.SetFile(file))
					cue.AddSound(sound);
				else
					sound.Destroy();
			}
			delete subSnap;
		}
	}

	delete snap;

	//chara.DebugCues();
}

public bool CFS_CheckDoesSoundExist(char snd[255])
{
	if (!snd[0])
		return false;
		
	char checkFile[255];
	Format(checkFile, sizeof(checkFile), "sound/");

	for (int i = 0; i < sizeof(snd); i++)
	{
		char character = snd[i];
		if (!IsCharSoundscript(character))
			Format(checkFile, sizeof(checkFile), "%s%c", checkFile, character);
	}

	return CheckFile(checkFile);
}

GlobalForward g_SoundHook;

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
				CFCharacter chara = GetCharacterFromClient(entity);
				if (chara == null)
					return Plugin_Continue;

				float gameTime = GetGameTime();
				if (gameTime >= chara.f_LastSoundHook && gameTime >= chara.f_SilenceEndTime)
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
						
					if (chara.PlayRandomSound(SoundA))
					{
						played = true;
					}
					else
					{
						char repl[255];
						Format(repl, sizeof(repl), "%s", strSound);
						played = chara.PlaySoundReplacement(repl);
					}
						
					if (!played)
					{
						played = chara.PlayRandomSound("sound_replace_all");
					}
					
					chara.f_LastSoundHook = GetGameTime() + 0.01;
						
					if (played)
						return Plugin_Handled;
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

public void Native_CF_GetRandomSound(Handle plugin, int numParams)
{
	char Sound[255], Output[255];
	int client = GetNativeCell(1);
	int len = GetNativeCell(4);
	CFCharacter chara = GetCharacterFromClient(client);
	if (chara == null)
	{
		SetNativeString(3, "", len);
		return;
	}

	GetNativeString(2, Sound, sizeof(Sound));

	CFSound snd = chara.GetRandomSound(Sound);
	if (snd == null)
	{
		SetNativeString(3, "", len);
		return;
	}

	snd.GetFile(Output, 255);
	SetNativeString(3, Output, len, false);
}

public any Native_CF_PlayRandomSound(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	CFCharacter chara = GetCharacterFromClient(client);
	if (chara == null)
		return false;

	int source = GetNativeCell(2);
	char Sound[255];
	GetNativeString(3, Sound, 255);

	CFSound snd = chara.GetRandomSound(Sound);
	if (snd == null)
		return false;

	return snd.Play(source);
}

public Native_CF_SilenceCharacter(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	float duration = GetNativeCell(2);
	
	CFCharacter chara = GetCharacterFromClient(client);
	if (chara != null)
		chara.f_SilenceEndTime = GetGameTime() + duration;
}