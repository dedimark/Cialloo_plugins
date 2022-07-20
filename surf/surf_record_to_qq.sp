#include <sourcemod>
#include <qqbot>
#include <influx/core>

public void Influx_OnTimerFinishPost( int client, int runid, int mode, int style, float time, float prev_pb, float prev_best, int flags )
{
    if(time < prev_best || prev_best < 3.0)
    {
        char steamid[64], stylename[64], runname[64], mapname[MAX_NAME_LENGTH], message[1024];
        GetCurrentMap(mapname, sizeof(mapname));
        GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
        Influx_GetStyleName(style, stylename, sizeof(stylename));
        Influx_GetRunName(runid, runname, sizeof(runname));

        FormatEx(message, sizeof(message),
        "\
        # New Surf Record! #\n\
        玩家: %N\n\
        Steamid: %s\n\
        地图: %s\n\
        时间: %.3f\n\
        模式: %s\n\
        线路: %s", 
        client, 
        steamid,
        mapname, 
        time, 
        stylename, 
        runname);

        MessageToQQGroup("285620437", message);
    }
}