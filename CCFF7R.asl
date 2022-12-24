state("CCFF7R-Win64-Shipping")
{
  bool Loading1: 0x73D0988;           //1 during Room Transition, 0 when Room is loaded
  bool Loading2: 0x04D8D5F0, 0x7D;    //1 when cutscene is loaded
  byte SaveMenu: 0x5179F30;           //1 when Save Icon shown, only for Save / Load Menu
  double IGT: 0x71B3FB8;              //IGT
  uint EXP: 0x71B3F04;                //EXP (Default Value on Title Screen is 489)
  byte Chapter: 0x71B4BA4;            //Gives current chapter number (0 during prologue and some loading screens)
  uint Enemy1HP: 0x7195028;           //First enemy current HP
  uint Enemy1MaxHP: 0x71A3828;        //First enemy maximum HP
  uint Enemy2HP: 0x7195768;           //Second enemy current HP
  uint Enemy2MaxHP: 0x71A3F68;        //Second enemy maximum HP
  uint Enemy3HP: 0x7195EA8;           //Third enemy current HP
  uint Enemy3MaxHP: 0x71A46A8;        //Third enemy maximum HP -- highest needed for boss splits
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
  //Initiates variables in case the game crashes or gets closed
  vars.crash = false;
  vars.timer = 0;

  //Autosplitter Settings
  //-------------------------------------------
  //Difficulty Selection
  settings.Add("difficulty", true, "Select difficulty:");
    settings.Add("normal", true, "Normal", "difficulty");
    settings.Add("hard", false, "Hard", "difficulty");
  
  //Boss List -- Boss indexes 1 (Vajra twins) and 6 (Machine trio) require exception splits due to multiple enemies needing to be killed
  vars.BossNames = new List<String>()
  {
    "Behemoth", "Vajradhara Twins", "Ifrit", "Guard Spider", "Bahamut",
    "G Eraser", "Machine Trio", "G Warrior", "Bahamut Fury", "Genesis I",
    "Angeal Penance", "General's Tank", "Prototype Guard Scorpion", "Sephiroth I", "Sephiroth II",
    "G Eliminator", "Hollander", "G Regicide", "Genesis Avatar"
  };

  //Boss Split Selection
  settings.Add("bosses", false, "Boss Splits");
    settings.CurrentDefaultParent = "bosses";
    for (int i = 0; i < 19; i++)
    {
      settings.Add("boss" + i.ToString(), false, "" + vars.BossNames[i]);
    }
    settings.CurrentDefaultParent = null;

  //Chapter End Split Selection
  settings.Add("chapters", false, "Split on chapter completion.");
    settings.SetToolTip("chapters", "Splits right before the end of chapter static image.");
    settings.CurrentDefaultParent = "chapters";
    settings.Add("ch1", false, "Prologue");
    for (int i = 2; i < 11; i++)
    {
      settings.Add("ch" + i.ToString(), false, "Chapter " + (i-1).ToString());
    }
    settings.CurrentDefaultParent = null;
}

init
{
  //Genesis Defeated Flag
  vars.GenesisDefeated = false;

  //Boss HP Lists
  vars.BossHPNormal = new List<uint>()
  {
     7870,  5075, 12860,   7225, 11740, 
    11900, 10230,  8290,  16000, 17800,
    31800, 22860, 52180,  52820, 21520,
    65300, 78830, 95800, 400000
  };

  vars.BossHPHard = new List<uint>()
  {
      7870,   5075,  12860,    7225, 11740,
     11900,  11253,   9119,   24000, 48060,
    101760,  89154, 182630,  223956, 93827,
    305604, 467461, 440680, 2232000
  };

  //Completed Boss Splits
  vars.CompletedBossList = new List<uint>();

  //Completed Chapter Splits
  vars.CompletedChapterList = new List<byte>();
}

start
{
  //Starts the timer automatically once the innitial Saving process has finished. Also checks for EXP to be the default value or over an expected threshold (NG+ only)
  if (current.EXP == 489 || current.EXP > 75000)
  {
    return current.Loading1;
  }
}

split
{
  //Ending Split on defeating Genesis II -- ALWAYS ACTIVE
  if (current.Chapter == 10 && ((settings["normal"] && current.Enemy1MaxHP == 118999) || (settings["hard"] && current.Enemy1MaxHP == 713994)) && current.Enemy1HP < 1 && !vars.GenesisDefeated)
  {
    vars.GenesisDefeated = true;
    return true;
  }

  //Boss Splits
  if (settings["bosses"])
  {
    for (int i = 0; i < 19; i++)
    {
      if (i == 1) //Vajra Twins Split
      {
        if (!vars.CompletedBossList.Contains(current.Enemy1MaxHP) && //Check if this HP value is used already
            settings["boss" + i.ToString()] && current.Chapter == 1 && //Check if we want to split on this boss index and if we're in the right chapter
            current.Enemy1MaxHP == 5075 && current.Enemy2MaxHP == 5075 && //Check that both twins are present
            current.Enemy1HP < 1 && current.Enemy2HP < 1 //Check if the boss is defeated
           )
        {
          vars.CompletedBossList.Add(current.Enemy1MaxHP);
          return true;
        }
      }
      else if (i == 6) //Machine Trio Split
      {
        if (!vars.CompletedBossList.Contains(current.Enemy1MaxHP) && //Check if this HP value is used already
            settings["boss" + i.ToString()] && current.Chapter == 3 && //Check if we want to split on this boss index and if we're in the right chapter
            ((settings["normal"] && current.Enemy1MaxHP == 10230 && current.Enemy2MaxHP == 9800 && current.Enemy3MaxHP == 8780) ||
            (settings["hard"] && current.Enemy1MaxHP == 11253 && current.Enemy2MaxHP == 10780 && current.Enemy3MaxHP == 9658)) && //Check that all three machines are present. HP differs by difficulty
            current.Enemy1HP < 1 && current.Enemy2HP < 1 && current.Enemy3HP < 1 //Check if the boss is defeated
           )
        {
          vars.CompletedBossList.Add(current.Enemy1MaxHP);
          return true;
        }
      }
      else if (current.Enemy1MaxHP != 5075 && current.Enemy1MaxHP != 10230 && current.Enemy1MaxHP != 11253 && //Check that we're not in one of the exceptional splits
               !vars.CompletedBossList.Contains(current.Enemy1MaxHP) && //Check if this HP value is used already
               settings["boss" + i.ToString()] && //Check if we want to split on this boss index
               ((settings["normal"] && vars.BossHPNormal.Contains(current.Enemy1MaxHP)) || (settings["hard"] && vars.BossHPHard.Contains(current.Enemy1MaxHP))) && //Check if this HP values matches a boss HP
               current.Enemy1HP < 1 //Check if the boss is defeated
              )
      {
        vars.CompletedBossList.Add(current.Enemy1MaxHP);
        return true;
      }
    }
  }

  //Chapter Splits
  if (current.Chapter != 0 && settings["ch" + current.Chapter.ToString()] && !vars.CompletedChapterList.Contains(current.Chapter))
  {
    vars.CompletedChapterList.Add(current.Chapter);
    return true;
  }
}

isLoading
{
  //Stops the Game Time whenever a Room or Cutscene gets loaded as well as when the game gets exited
  return current.Loading1 || current.Loading2 || vars.crash || current.IGT <= 540;
}

exit
{
  //Changes variable to stop Game Time and starts a 60 second timer to give the runner time to restart the run
  vars.crash = true;
  vars.timer = 0;
  timer.IsGameTimePaused = true;
}

update
{
  //Starts a 60 second countdown in which the player can resume their game before the timer continues. Timer starts early if IGT above 1 minute is detected
  vars.timer++;
  if (vars.timer >= 3600 || current.IGT >= 3600)
  {
    vars.crash = false;
  }

  //Reset variables when the timer is reset.
	if(timer.CurrentPhase == TimerPhase.NotRunning)
	{
		vars.CompletedChapterList.Clear();
    vars.CompletedBossList.Clear();
    vars.GenesisDefeated = false;
	}

	//Uncomment debug information in the event of an update.
	//print(modules.First().ModuleMemorySize.ToString());
}