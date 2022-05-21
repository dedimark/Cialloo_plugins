#include <sourcemod>
#include <clientprefs>

bool g_bIsHudOpen[MAXPLAYERS];

Handle g_hClientTimer[MAXPLAYERS] = INVALID_HANDLE;

Handle g_hud;

Handle g_hClientpref = INVALID_HANDLE;

float g_fClientSpeed[MAXPLAYERS];

float g_arrayVelocity[MAXPLAYERS][3];

float g_fXY[MAXPLAYERS][2];

int g_iRGBA[MAXPLAYERS][4];

public Plugin myinfo =
{
    name = "surf-speed-hud",
    author = "达达",
    description = "show speed to client in surf",
    version = "1.1.0",
    url = "https://www.cialloo.com"
};

public OnPluginStart()
{
    RegConsoleCmd("sm_speed", Command_Speed, "");
    RegConsoleCmd("sm_speedx", Command_SpeedX);
    RegConsoleCmd("sm_speedy", Command_SpeedY);
    RegConsoleCmd("sm_speedr", Command_SpeedR);
    RegConsoleCmd("sm_speedg", Command_SpeedG);
    RegConsoleCmd("sm_speedb", Command_SpeedB);
    RegConsoleCmd("sm_speeda", Command_SpeedA);

    g_hClientpref = RegClientCookie("influx_speedhud", "influx_speedhud", CookieAccess_Public);
    g_hud = CreateHudSynchronizer();

    for(new i = 1; i < MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			OnClientCookiesCached(i);
		}
	}
}

public OnClientCookiesCached(int client)
{
    char strCookie[128];
    GetClientCookie(client, g_hClientpref, strCookie, 128);

    if(strCookie[3] == '\0')
    {
        SetClientCookie(client, g_hClientpref, "0,-1.0, 0.3, 255, 255, 255, 255");
    } else {
        char strPieces[7][16];
        ExplodeString(strCookie, ",", strPieces, 7, 16);
        g_fXY[client][0] = StringToFloat(strPieces[1]);
        g_fXY[client][1] = StringToFloat(strPieces[2]);
        g_iRGBA[client][0] = StringToInt(strPieces[3]);
        g_iRGBA[client][1] = StringToInt(strPieces[4]);
        g_iRGBA[client][2] = StringToInt(strPieces[5]);
        g_iRGBA[client][3] = StringToInt(strPieces[6]);
    }
}

public OnClientPutInServer(int client)
{
    char strCookie[128], strPieces[7][8];
    GetClientCookie(client, g_hClientpref, strCookie, 128);
    ExplodeString(strCookie, ",", strPieces, 7, 16);
    
    int i = StringToInt(strPieces[0]);

    if(i == 1)
    {
        g_bIsHudOpen[client] = false;
        Command_Speed(client, 1);
    } else {
        g_bIsHudOpen[client] = true;
        Command_Speed(client, 1);
    }
}

public Action Command_Speed(int client, int args)
{
    if(IsClientInGame(client))
    {
        if(!g_bIsHudOpen[client])
        {
            g_bIsHudOpen[client] = true;
            g_hClientTimer[client] = CreateTimer(0.1, Timer_ShowHudSpeed, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

            char strCookie[128], strPieces[7][16];
            GetClientCookie(client, g_hClientpref, strCookie, 128);
            ExplodeString(strCookie, ",", strPieces, 7, 16);
            g_fXY[client][0] = StringToFloat(strPieces[1]);
            g_fXY[client][1] = StringToFloat(strPieces[2]);
            g_iRGBA[client][0] = StringToInt(strPieces[3]);
            g_iRGBA[client][1] = StringToInt(strPieces[4]);
            g_iRGBA[client][2] = StringToInt(strPieces[5]);
            g_iRGBA[client][3] = StringToInt(strPieces[6]);
            FormatEx(strPieces[0], 16, "1");
            FormatEx(strCookie, 128, "%s,%s,%s,%s,%s,%s,%s", strPieces[0], strPieces[1], strPieces[2], strPieces[3], strPieces[4], strPieces[5], strPieces[6])

            SetClientCookie(client, g_hClientpref, strCookie);
            //PrintToChat(client, "\x03已打开中央码表");
        } else if(g_bIsHudOpen[client]) {
            g_bIsHudOpen[client] = false;
            //PrintToChat(client, "\x03已关闭中央码表");
            if(g_hClientTimer[client] != INVALID_HANDLE)
            {
                KillTimer(g_hClientTimer[client]);
                g_hClientTimer[client] = INVALID_HANDLE;
            }

            char strCookie[128], strPieces[7][16];
            GetClientCookie(client, g_hClientpref, strCookie, 128);
            ExplodeString(strCookie, ",", strPieces, 7, 16);
            FormatEx(strPieces[0], 16, "0");
            FormatEx(strCookie, 128, "%s,%s,%s,%s,%s,%s,%s", strPieces[0], strPieces[1], strPieces[2], strPieces[3], strPieces[4], strPieces[5], strPieces[6]);
            
            SetClientCookie(client, g_hClientpref, strCookie);
        }
    }

    return Plugin_Handled;
}

public Action Command_SpeedX(int client, int args)
{
    int i = GetCmdArgs();
    if(i != 1)
    {
        ReplyToCommand(client, "请输入一个0.0到1.0的小数(-1.0表示中间值)");
        return Plugin_Handled;
    }
    
    char Xbuffer[8];
    GetCmdArg(1, Xbuffer, 8);

    float fX = StringToFloat(Xbuffer);

    if((fX > 1.0 || fX < 0.0) && fX != -1.0)
    {
        ReplyToCommand(client, "请输入一个0.0到1.0的小数(-1.0表示中间值)");
        return Plugin_Handled;
    }

    char strCookie[128], strPieces[7][16];
    GetClientCookie(client, g_hClientpref, strCookie, 128);
    ExplodeString(strCookie, ",", strPieces, 7, 16);
    g_fXY[client][0] = fX;
    FormatEx(strPieces[1], 16, "%f", fX);
    FormatEx(strCookie, 128, "%s,%s,%s,%s,%s,%s,%s", strPieces[0], strPieces[1], strPieces[2], strPieces[3], strPieces[4], strPieces[5], strPieces[6]);
    SetClientCookie(client, g_hClientpref, strCookie);

    return Plugin_Handled;
}

public Action Command_SpeedY(int client, int args)
{
    int i = GetCmdArgs();
    if(i != 1)
    {
        ReplyToCommand(client, "请输入一个0.0到1.0的小数(-1.0表示中间值)");
        return Plugin_Handled;
    }
    
    char Ybuffer[8];
    GetCmdArg(1, Ybuffer, 8);

    float fY = StringToFloat(Ybuffer);

    if((fY > 1.0 || fY < 0.0) && fY != -1.0)
    {
        ReplyToCommand(client, "请输入一个0.0到1.0的小数(-1.0表示中间值)");
        return Plugin_Handled;
    }

    char strCookie[128], strPieces[7][16];
    GetClientCookie(client, g_hClientpref, strCookie, 128);
    ExplodeString(strCookie, ",", strPieces, 7, 16);
    g_fXY[client][1] = fY;
    FormatEx(strPieces[2], 16, "%f", fY);
    FormatEx(strCookie, 128, "%s,%s,%s,%s,%s,%s,%s", strPieces[0], strPieces[1], strPieces[2], strPieces[3], strPieces[4], strPieces[5], strPieces[6]);
    SetClientCookie(client, g_hClientpref, strCookie);

    return Plugin_Handled
}

public Action Command_SpeedR(int client, int args)
{
    int i = GetCmdArgs();
    if(i != 1)
    {
        ReplyToCommand(client, "请输入一个0到255的整数");
        return Plugin_Handled;
    }
    
    char Rbuffer[8];
    GetCmdArg(1, Rbuffer, 8);

    int iR = StringToInt(Rbuffer);

    if(iR > 255 || iR < 0)
    {
        ReplyToCommand(client, "请输入一个0到255的整数");
        return Plugin_Handled;
    }

    char strCookie[128], strPieces[7][16];
    GetClientCookie(client, g_hClientpref, strCookie, 128);
    ExplodeString(strCookie, ",", strPieces, 7, 16);
    g_iRGBA[client][0] = iR;
    FormatEx(strPieces[3], 16, "%d", iR);
    FormatEx(strCookie, 128, "%s,%s,%s,%s,%s,%s,%s", strPieces[0], strPieces[1], strPieces[2], strPieces[3], strPieces[4], strPieces[5], strPieces[6]);
    SetClientCookie(client, g_hClientpref, strCookie);

    return Plugin_Handled
}

public Action Command_SpeedG(int client, int args)
{
    int i = GetCmdArgs();
    if(i != 1)
    {
        ReplyToCommand(client, "请输入一个0到255的整数");
        return Plugin_Handled;
    }
    
    char Gbuffer[8];
    GetCmdArg(1, Gbuffer, 8);

    int iG = StringToInt(Gbuffer);

    if(iG > 255 || iG < 0)
    {
        ReplyToCommand(client, "请输入一个0到255的整数");
        return Plugin_Handled;
    }

    char strCookie[128], strPieces[7][16];
    GetClientCookie(client, g_hClientpref, strCookie, 128);
    ExplodeString(strCookie, ",", strPieces, 7, 16);
    g_iRGBA[client][1] = iG;
    FormatEx(strPieces[4], 16, "%d", iG);
    FormatEx(strCookie, 128, "%s,%s,%s,%s,%s,%s,%s", strPieces[0], strPieces[1], strPieces[2], strPieces[3], strPieces[4], strPieces[5], strPieces[6]);
    SetClientCookie(client, g_hClientpref, strCookie);

    return Plugin_Handled
}

public Action Command_SpeedB(int client, int args)
{
    int i = GetCmdArgs();
    if(i != 1)
    {
        ReplyToCommand(client, "请输入一个0到255的整数");
        return Plugin_Handled;
    }
    
    char Bbuffer[8];
    GetCmdArg(1, Bbuffer, 8);

    int iB = StringToInt(Bbuffer);

    if(iB > 255 || iB < 0)
    {
        ReplyToCommand(client, "请输入一个0到255的整数");
        return Plugin_Handled;
    }

    char strCookie[128], strPieces[7][16];
    GetClientCookie(client, g_hClientpref, strCookie, 128);
    ExplodeString(strCookie, ",", strPieces, 7, 16);
    g_iRGBA[client][2] = iB;
    FormatEx(strPieces[5], 16, "%d", iB);
    FormatEx(strCookie, 128, "%s,%s,%s,%s,%s,%s,%s", strPieces[0], strPieces[1], strPieces[2], strPieces[3], strPieces[4], strPieces[5], strPieces[6]);
    SetClientCookie(client, g_hClientpref, strCookie);

    return Plugin_Handled
}

public Action Command_SpeedA(int client, int args)
{
    int i = GetCmdArgs();
    if(i != 1)
    {
        ReplyToCommand(client, "请输入一个0到255的整数");
        return Plugin_Handled;
    }
    
    char Abuffer[8];
    GetCmdArg(1, Abuffer, 8);

    int iA = StringToInt(Abuffer);

    if(iA > 255 || iA < 0)
    {
        ReplyToCommand(client, "请输入一个0到255的整数");
        return Plugin_Handled;
    }

    char strCookie[128], strPieces[7][16];
    GetClientCookie(client, g_hClientpref, strCookie, 128);
    ExplodeString(strCookie, ",", strPieces, 7, 16);
    g_iRGBA[client][3] = iA;
    FormatEx(strPieces[6], 16, "%d", iA);
    FormatEx(strCookie, 128, "%s,%s,%s,%s,%s,%s,%s", strPieces[0], strPieces[1], strPieces[2], strPieces[3], strPieces[4], strPieces[5], strPieces[6]);
    SetClientCookie(client, g_hClientpref, strCookie);

    return Plugin_Handled
}

public Action Timer_ShowHudSpeed(Handle timer, int client)
{
    if(g_bIsHudOpen[client] && IsClientInGame(client))
    {
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", g_arrayVelocity[client]);
        g_fClientSpeed[client] = SquareRoot(g_arrayVelocity[client][0]*g_arrayVelocity[client][0] + g_arrayVelocity[client][1]*g_arrayVelocity[client][1]);
        SetHudTextParams(g_fXY[client][0], g_fXY[client][1], 0.1, g_iRGBA[client][0], g_iRGBA[client][1], g_iRGBA[client][2], g_iRGBA[client][3]);
        ShowSyncHudText(client, g_hud, "%i", RoundToZero(g_fClientSpeed[client]));
    } else {
        if(g_hClientTimer[client] != INVALID_HANDLE)
        {
            g_bIsHudOpen[client] = false;
            KillTimer(g_hClientTimer[client]);
            g_hClientTimer[client] = INVALID_HANDLE;
        }
    }

    return Plugin_Handled;
}