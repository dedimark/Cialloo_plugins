#include <sourcemod>

public Plugin myinfo =
{
    name = "helps",
    author = "cialloo",
    description = "dump sourcemod command detail",
    version = "1.0",
    url = "https://www.cialloo.com"
};

public void OnPluginStart()
{
    RegConsoleCmd("sm_helps", Cmd_Helps, "Send command description to player.");
}

public Action Cmd_Helps(int client, int args)
{
    Menu menu = new Menu(Menu_Helps);
    menu.SetTitle("Cialloo command helps");

    int flag;
    char cmdName[64], description[128], show[256];
    Handle cmdIterator = GetCommandIterator();

    while(ReadCommandIterator(cmdIterator, cmdName, sizeof(cmdName), flag, description, sizeof(description)))
    {
        if(CheckCommandAccess(client, cmdName, flag))
        {
            FormatEx(show, sizeof(show), "%s - %s", cmdName, description);
            menu.AddItem(cmdName, show);
        }
    }

    menu.DisplayAt(client, 0, MENU_TIME_FOREVER);
    delete cmdIterator;
    return Plugin_Changed;
}

public int Menu_Helps(Menu menu, MenuAction action, int client, int item)
{
    if(action == MenuAction_Select)
    {
        char cmd[64];
        menu.GetItem(item, cmd, sizeof(cmd));
        ClientCommand(client, cmd);
    }
    else if(action == MenuAction_End)
    {
        delete menu;
    }
}