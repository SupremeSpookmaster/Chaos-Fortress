/**
 * Gets a random sound from a given boss config.
 *
 * @param Config 				The config to grab the sound from.Can be a direct path such as "configs/chaos_fortress/character.cfg"", or just the name of the cfg, such as "character"
 * @param Sound					The sound section to grab from, such as "sound_kill".
 *
 * @return	A ConfigMap directed to the chosen sound, null if the config or sound do not exist.
 */
public ConfigMap CF_GetRandomSound(char Config[255], char Sound[255])
{
	if (!CheckFile(Config))
		Format(Config, sizeof(Config), "configs/chaos_fortress/%s.cfg", Config);
		
	if (!CheckFile(Config))
		return null;
		
	ConfigMap conf = new ConfigMap(Config);
	
	if (conf == null)
		return null;
		
	//TODO: man I'm so much more tired than I thought I was, do the rest of this tomorrow
}

/**
 * Plays a random sound from a client's boss config, as specified by the settings below.
 *
 * @param source				The source to play the sound from. If this is a valid client, Config is automatically filled out and can be skipped.
 * @param Config				The config to grab the sound from. Ignored if source is a valid client.
 * @param Sound					The sound section to grab from, such as "sound_kill".
 * @param OtherCharacter		The optional name of other character involved in the interaction which triggered the sound, used by sound_kill and sound_killed.
 * @param damage				The optional damage dealt to trigger this sound, used by sound_bighit.
 * @param UltLoc				The optional location the Ultimate Ability which triggered this sound was located, used for sound_ultimate_react sounds.
 * @param UltUser				The optional user of the Ultimate Ability which triggered this sound, used for sound_ultimate_react sounds.
 *
 */
void CF_PlayRandomSound(int source, char[] Sound, char[] OtherCharacter = "", float damage = 0.0, float UltLoc[3] = {0.0, ...}, int UltUser = -1)
{

}