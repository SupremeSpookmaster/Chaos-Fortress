# *Introducing (eventually because this is not done yet) Chaos Fortress: TF2 with custom classes!*
***Chaos Fortress*** is just like normal TF2, but with a twist: instead of playing as one of the nine mercenaries, players step into the shoes of one of many custom characters, each with their own unique kit. Some of these characters are designed to function like souped up versions of the nine mercenaries, while others act more as wildcards, going their own directions entirely. To top it all off, all of these characters have access to powerful Ultimate Abilities, which charge very slowly over time, or by dealing damage. In short: **it's a lot like *Overwatch*, but in TF2 and with different characters, on top of also being very dev-friendly for those who want to make their own characters**.

***Chaos Fortress*** is a game mode inspired by one of my previous developer ventures: **Boss VS Boss**. It was an old, private game mode, centered around **[the highly talented Batfoxkid's _FF2 Rewrite_](https://github.com/Batfoxkid/Freak-Fortress-2-Rewrite)**, in which every player took control of a Freak Fortress boss and fought alongside their team to kill everybody on the enemy team in the Arena game mode. In addition to being every bit as insane as it sounds, most of the bosses in BvB could get VERY complex, which made the game mode nightmarishly unfriendly to beginners. This, in addition to many other issues such as lag, a plethora of bugs, and a ton of poor game design practices, eventually drove me to wipe the slate clean, taking the concept a step further to turn it into something simpler and more akin to a modern class-based shooter. And so, ***Chaos Fortress*** was born!
 
## *Installation Guide:*
  1. Install all of the **[prerequisites](https://github.com/SupremeSpookmaster/Chaos-Fortress#prerequisites)**.
  2. Download the **latest release Installation Build. (LINK PENDING)**
  3. Extract the zip file directly to your server's sourcemod folder.
  4. ***Chaos Fortress*** should now be installed on your server!
  5. Configure the game mode to your heart's content. *(Optional)*

## *Update Guide*
  1. Download the **latest release Update Build. (LINK PENDING)**
  2. Extract the zip file directly to your server's sourcemod folder.
  3. ***Chaos Fortress*** should now be updated on your server!

## *Prerequisites:*
- **[SourceMod 1.11+](https://www.sourcemod.net/downloads.php)**
- **[TF2Attributes 1.7.0+](https://github.com/FlaminSarge/tf2attributes)**
- **[TF2Items](https://github.com/asherkin/TF2Items)**

## *Making Custom Characters*
***Chaos Fortress*** comes with a number of pre-made custom characters, but what if that's not enough? What if you want *more*? Don't worry, because Chaos Fortress has you covered: ***if you know how to make a Freak Fortress boss, you'll know how to make a Chaos Fortress character!*** And even if you don't, don't worry; it's not very difficult to figure out if you're experienced with SourceMod development. Most of my experience as a SourceMod developer comes from making Freak Fortress bosses, and I knew most of the developers who might take an interest in this game mode would be similar, so I was very careful to keep the development process for ***Chaos Fortress*** characters as close to that of ***Freak Fortress*** characters as possible.
  - Look at **[example_character.cfg](addons/sourcemod/configs/chaos_fortress/example_character.cfg)** to see an example of a ***Chaos Fortress*** character CFG.
    - *This file doubles as a character CFG template. Feel free to use it to speed up the development of your characters!*
  - Look at **[FILE PENDING]** to see an example of a ***Chaos Fortress*** character plugin.
  - Look at **[FILE PENDING]** for a ***Chaos Fortress*** character plugin template to speed up the development of your characters!
  - Character plugins do not require a special file extension or directory. Just drop the compiled SMX in your server's plugins folder and it will work.
    - *For the sake of organization, you are recommended to put your character plugins in a sub-folder, such as plugins/chaos_fortress. Again, this is just a recommendation, and is not mandatory.*
  - Please note that despite the similarities in their development process, FF2 plugins and configs will ***not*** work for ***Chaos Fortress*** characters.
  - **I *HIGHLY* recommend you refer to the [_Developer Forwards and Natives_ wiki page](https://github.com/SupremeSpookmaster/Chaos-Fortress/wiki/Developer-Forwards-and-Natives) and follow its guidance if you intend to write character plugins.**
    - *Ignoring this wiki page will not break ***Chaos Fortress***, but it will harm your server's organization and may result in awkward issues stemming from plugin execution order. **Ignore at your own peril!***

## *Configuring Active Characters and Packs*
Let's say you want to add or remove a character, or you have a handful of characters you want to be able to activate or deactivate on demand. This is exactly what the character packs system is for.
  - Look at **[characters.cfg](addons/sourcemod/data/chaos_fortress/characters.cfg)** for an example of how to use the character packs system.
  - All characters must be located in **addons/sourcemod/configs/chaos_fortress**.
      - *Sub-directories **are** allowed.*
   
## *Game Mode Configuration Options*
All configurable options specific to this game mode are described in and can be controlled in **[game_rules.cfg](addons/sourcemod/data/chaos_fortress/game_rules.cfg)**.

## *Credits*
In no particular order, all help is greatly appreciated:
  - **[Spookmaster](https://github.com/SupremeSpookmaster)** (Lead Dev, Game Mode Creator, All Default Characters)
  - **[Artvin](https://github.com/artvin01)** and **[Batfoxkid](https://github.com/Batfoxkid)** (Creators of ***[TF2 Zombie Riot](https://github.com/artvin01/TF2-Zombie-Riot)***, which I borrowed code from at certain points, general advice and support)
  - **[Zabaniya001, AKA Suza](https://github.com/Zabaniya001/Zabaniya001)** (Various tips and tricks, help regarding code cleanliness and performance, lots of help with unfamiliar coding territory)
