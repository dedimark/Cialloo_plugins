#include <sourcemod>
#include <qqbot>

public void OnPluginStart()
{
    RegConsoleCmd("sm_qqgmsg", Cmd_QQGMsg, "Send message to qq group.");
    RegConsoleCmd("sm_qqowner", Cmd_QQOwner, "Send message to host owner.");
}

public Action Cmd_QQOwner(int client, int args)
{
    char steamid[32], message[256], qqmsg[512];
    GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
    GetCmdArgString(message, sizeof(message));
    FormatEx(qqmsg, sizeof(qqmsg), "%N: %s", client, message);
    MessageToQQFriend("2376157715", qqmsg);
    LogMessage("%N send a group message: %s\nSteamID: %s", client, message, steamid);
    return Plugin_Handled;
}

public Action Cmd_QQGMsg(int client, int args)
{
    char steamid[32], message[256], qqmsg[512];
    GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
    GetCmdArgString(message, sizeof(message));
    FormatEx(qqmsg, sizeof(qqmsg), "%N: %s", client, message);
    MessageToQQGroup("285620437", qqmsg);
    LogMessage("%N send a group message: %s\nSteamID: %s", client, message, steamid);
    return Plugin_Handled;
}