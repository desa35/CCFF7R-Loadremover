state("CCFF7R-Win64-Shipping")
{
  bool Loading1: 0x73D0988;           //1 during Room Transition, 0 when Room is loaded
  bool Loading2: 0x04D8D5F0, 0x7D;    //1 when cutscene is loaded
  byte SaveMenu: 0x5179F30;           //1 when Save Icon shown, only for Save / Load Menu
  double IGT: 0x71B3FB8;              //IGT
  uint EXP: 0x71B3F04;                //EXP (Default Value on Title Screen is 489)

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
}

start
{
  //Starts the timer automatically once the innitial Saving process has finished. Also checks for EXP to be the default value or over an expected threshold (NG+ only)
  if (current.EXP == 489 || current.EXP > 75000)
  {
    return current.Loading1;
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
}