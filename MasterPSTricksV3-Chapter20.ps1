#When you launch PowerShell, one of the things that happens is that your profile is loaded. Your profile is basically its own script that runs to setup and configure your environment before you start using it. I use mine to define some custom aliases, functions, import some modules, and set my prompt up. You can see what your profile is doing by running notepad $profile. This will open your profile in notepad (but you can use the ISE or Visual Studio Code or Notepad++ etc. if you prefer). 
#There is more than one profile used by PowerShell depending on how you’re running PowerShell, and $profile will always refer to the one that’s currently applied to you. If you run that command above and are told that there’s no such file, it means don’t have anything configured in your PowerShell profile. 
#Keep in mind, there could be a lot of other reasons that your console loads slowly. This is just a quick way to clear out any dumb code from your profile. 


$profile