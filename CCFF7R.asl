state("CCFF7R-Win64-Shipping")
{
  bool Loading1: 0x73D0988;           //1 during Room Transition, 0 when Room is loaded
  bool Loading2: 0x04D8D5F0, 0x7D;    //1 when cutscene is loaded
  byte Chapter: 0x71B4BA4;            //Gives current chapter number (0 during prologue and some loading screens)
  uint BattleState: 0x717AD5C;        //Battle state incrementing from 0-7
  uint LevelId: 0x717A5AC;            //Sometimes 0
  uint CursedRing: 0x71B5068;         //Cursed ring chest attempts

  uint ZackHP: 0x718DC28;             //Zacks current HP

  uint EnemyId1: 0x7194F38;           //Add 0x0740 to get next enemy id
  uint EnemyId2: 0x7195678;
  uint EnemyId3: 0x7195DB8;
  uint EnemyId4: 0x71964F8;
}


startup
{
  //Asks the user to set his timer to game time on livesplit if it isn't already
  if (timer.CurrentTimingMethod == TimingMethod.RealTime) // Taken and reworded from FF7R Autosplitter
  {
    var timingMessage = MessageBox.Show 
    (
      "This game uses Time without Loads (Game Time) as the main timing method.\n"+
      "LiveSplit is currently set to show Real Time (RTA).\n"+
      "Would you like to set the timing method to Game Time? This is required for the run to be verified.",
      "LiveSplit | CCFF7R",
      MessageBoxButtons.YesNo,MessageBoxIcon.Question
    );
    if (timingMessage == DialogResult.Yes)
    {
      timer.CurrentTimingMethod = TimingMethod.GameTime;
    }
  }

  vars.Location = 0;                      // Var to ignore 0's
  vars.Chapter = 0;                       // Var to ignore 0's
  vars.DecendedMtn = false;               // Required for ascend mt nibel split
  vars.Repeatables = new List<string>();  // Splits that can be repeated will be added and checked here

  //// Settings
  // Bosses
  settings.Add("bosses", false, "Bosses");
  settings.CurrentDefaultParent = "bosses";
  settings.Add("e13", false, "Behemoth");
  settings.Add("e90,93", false, "Vajradhara Twins");
  settings.Add("e196", false, "Ifrit");
  settings.Add("e25", false, "Guard Spider");
  settings.Add("e9", false, "Bahamut");
  settings.Add("e107", false, "G Eraser");
  settings.Add("e57,61,64", false, "Machine Trio");
  settings.Add("e115", false, "G Warrior");
  settings.Add("e10", false, "Bahamut Fury");
  settings.Add("e137", false, "Genesis I");
  settings.Add("e149", false, "A-Griffon");
  settings.Add("e204", false, "Angeal Penance");
  settings.Add("e336", false, "General's Tank");
  settings.Add("e278", false, "Prototype Guard Scorpion");
  settings.Add("e295", false, "Sephiroth I");
  settings.Add("e296", false, "Sephiroth II");
  settings.Add("e122", false, "G Eliminator");
  settings.Add("e183", false, "Hollander");
  settings.Add("e124", false, "G Regicide");
  settings.Add("e206", false, "Genesis Avatar");
  settings.Add("e139", false, "Genesis II");
  settings.CurrentDefaultParent = null;

  // Chapters
  settings.Add("chapters", false, "Chapters");
  settings.CurrentDefaultParent = "chapters";
  settings.Add("c1", false, "Prologue");
  for (int i = 2; i < 11; i++)
  {
    settings.Add("c" + i.ToString(), false, "Chapter " + (i-1).ToString());
  }
  settings.CurrentDefaultParent = null;

  // Misc
  settings.Add("misc", false, "Misc");
  settings.CurrentDefaultParent = "misc";
  settings.Add("cursedring", false, "Cursed Ring");
  settings.Add("l90", false, "Enter Fort Wutai");
  settings.Add("e92,92,92", false, "Clear Fort Wutai");
  settings.Add("e178,178", false, "Mission 7-1-1");
  settings.Add("e257,257,52", false, "Mission 7-1-2");
  settings.Add("e257,257,257,179", false, "Mission 7-1-3");
  settings.Add("e52,107", false, "Mission 7-2-1");
  settings.Add("e283", false, "Mission 7-2-2");
  settings.Add("e286,286,286", false, "Wallet Worms");
  settings.Add("l61,56", false, "Mt. Nibel Descent");
  settings.Add("l65", false, "Shinra Manor Safe");
  settings.Add("l62,60", false, "Mt. Nibel Ascent");
  settings.Add("l67", false, "Save Cloud");
  settings.Add("e111,119", false, "Gongaga Hilltop");
  settings.CurrentDefaultParent = null;
}

update 
{
  // Reset vars on reset
  if(timer.CurrentPhase == TimerPhase.NotRunning){
    vars.Location = 0;
    vars.Chapter = 0;
    vars.DecendedMtn = false;
    vars.Repeatables.Clear();
	}
}

split 
{
  // Encounter splits
  if(current.ZackHP > 0 && current.BattleState == 6 && old.BattleState != 6){
    if(settings["e13"] && current.EnemyId1 == 13) { return true; }
    if(settings["e92,92,92"] && current.EnemyId1 == 92 && current.EnemyId2 == 92 && current.EnemyId3 == 92) { return true; }
    if(settings["e90,93"] && current.EnemyId1 == 90 && current.EnemyId2 == 93) { return true; }
    if(settings["e196"] && current.EnemyId1 == 196) { return true; }
    if(settings["e25"] && current.EnemyId1 == 25) { return true; }
    if(settings["e9"] && current.EnemyId1 == 9) { return true; }
    if(settings["e178,178"] && current.EnemyId1 == 178 && current.EnemyId2 == 178) { return true; }
    if(settings["e257,257,52"] && current.EnemyId1 == 257 && current.EnemyId2 == 257 && current.EnemyId3 == 52) { return true; }
    if(settings["e257,257,257,179"] && current.EnemyId1 == 257 && current.EnemyId2 == 257 && current.EnemyId3 == 257 && current.EnemyId4 == 179) { return true; }
    if(settings["e107"] && current.EnemyId1 == 107) { return true; }
    if(settings["e57,61,64"] && current.EnemyId1 == 57 && current.EnemyId2 == 61 && current.EnemyId3 == 64) { return true; }
    if(settings["e52,107"] && current.EnemyId1 == 52 && current.EnemyId2 == 107) { return true; }
    if(settings["e283"] && current.EnemyId1 == 283) { return true; }
    if(settings["e286,286,286"] && current.EnemyId1 == 286 && current.EnemyId2 == 286 && current.EnemyId3 == 286) { return true; }
    if(settings["e115"] && current.EnemyId1 == 115) { return true; }
    if(settings["e10"] && current.EnemyId1 == 10) { return true; }
    if(settings["e137"] && current.EnemyId1 == 137) { return true; }
    if(settings["e149"] && current.EnemyId1 == 149) { return true; }
    if(settings["e204"] && current.EnemyId1 == 204) { return true; }
    if(settings["e336"] && current.EnemyId1 == 336) { return true; }
    if(settings["e278"] && current.EnemyId1 == 278) { return true; }
    if(settings["e295"] && current.EnemyId1 == 295) { return true; }
    if(settings["e296"] && current.EnemyId1 == 296) { return true; }
    if(settings["e122"] && current.EnemyId1 == 122) { return true; }
    if(settings["e111,119"] && current.EnemyId1 == 111 && current.EnemyId2 == 119) { return true; }
    if(settings["e183"] && current.EnemyId1 == 183) { return true; }
    if(settings["e124"] && current.EnemyId1 == 124) { return true; }
    if(settings["e206"] && current.EnemyId1 == 206) { return true; }
    if(settings["e139"] && current.EnemyId1 == 139) { return true; }
  }

  // Location splits
  if(settings["l90"] && !vars.Repeatables.Contains("l90") && current.LevelId == 90) {
    vars.Repeatables.Add("l90");
    return true; 
  }
  if(settings["l61,56"] && !vars.Repeatables.Contains("l61,56") && current.LevelId == 56 && vars.Location == 61) {
    vars.Repeatables.Add("l61,56");
    return true;
  }
  if(settings["l65"] && !vars.Repeatables.Contains("l65") && current.LevelId == 65) {
    vars.Repeatables.Add("l65");
    return true; 
  }
  if(settings["l62,60"] && vars.DecendedMtn == true && !vars.Repeatables.Contains("l62,60") && current.LevelId == 60) {
    vars.Repeatables.Add("l62,60");
    return true; 
  }
  if(settings["l67"] && !vars.Repeatables.Contains("l67") && current.LevelId == 67) {
    vars.Repeatables.Add("l67");
    return true; 
  }


  // Chapter splits
  if(current.Chapter > vars.Chapter && settings["c"+current.Chapter.ToString()]){
    vars.Chapter = current.Chapter;
    return true;
  }


  // Unique splits
  if(settings["cursedring"] && current.CursedRing == 20 && old.CursedRing == 19){ return true; }


  // Cutscenes push us from 62->60 so we need to have descended Mt Nibel before allowing the split
  if(current.LevelId == 56 && vars.Location == 61){
    print("Decent complete!!!");
    vars.DecendedMtn = true;
  }

  // LevelId switches between 0 and the level, ignore 0's
  if(current.LevelId != 0 && current.LevelId != vars.Location) {
    print("Location: " + current.LevelId.ToString());
    vars.Location = current.LevelId;
  }
}

start { return current.LevelId == 21; }
isLoading { return current.Loading1 || current.Loading2; }