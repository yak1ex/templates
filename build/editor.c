#include <windows.h>
#include <shlwapi.h>
#include <strsafe.h>

#define NUM_APP 2

LPWSTR lpszKey[NUM_APP][2] = {
    { L"SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\Hidemaru", L"DisplayIcon" },
    { L"SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\Notepad++", L"DisplayIcon" }
};

LPWSTR lpszFallbackExe[NUM_APP] = {
    L"hidemaru.exe",
    L"notepad++.exe"
};

LPWSTR lpszAppSpec[][NUM_APP] = {
    { L"\"%1\"", L"\"%1\"" },
    { L"\"%1\" \"%2\"", L"\"%1\" \"%2\"",  },
    { L"\"%1\" /j%3 \"%2\"", L"\"%1\" -n%3 \"%2\"" }
};

#define BUFSIZE 2048

BOOL GetScoopInstalledPathW(LPWSTR lpw, DWORD dwLen, LPWSTR lpwExe)
{
    WCHAR wszBuf[BUFSIZE];
    LPWSTR const lpwExeExt = L".exe";

    HRESULT hr = StringCbCopyW( wszBuf, sizeof(wszBuf), lpwExe );
    if ( FAILED( hr ) ) return FALSE;

    BOOL b = PathFindOnPathW( wszBuf, 0 );
    if ( ! b ) return FALSE;

    LPWSTR lpw1 = wszBuf, lpw2 = lpwExeExt, lpwPos = wszBuf;
    while ( *lpw1 && *lpw2 ) {
        if ( *lpw1 == *lpw2 ) { ++lpw1; ++lpw2; }
        else { ++lpw1; lpw2 = lpwExeExt; lpwPos = lpw1; }
    }
    if ( *lpw1 || *lpw2 ) return FALSE;

    StringCbCopyW( lpwPos, sizeof(wszBuf) - (lpwPos - wszBuf) * sizeof(wszBuf[0]), L".shim" );

    HANDLE hFile;
    hFile = CreateFileW( wszBuf, GENERIC_READ, FILE_SHARE_READ, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL , 0 );
    if ( hFile == INVALID_HANDLE_VALUE ) return FALSE;

    CHAR szBuf[BUFSIZE];
    DWORD dwRead;
    LPSTR lpStart = 0, lpWork;
    BOOL fRead = ReadFile( hFile, szBuf, sizeof(szBuf) - 1, &dwRead, 0 );
    CloseHandle( hFile );
    if ( !fRead ) return FALSE;

    szBuf[dwRead] = 0;
    lpWork = szBuf;
    while ( *lpWork ) {
        if ( *lpWork == '"' ) {
            if ( lpStart ) {
                *lpWork = 0;
                break;
            } else {
                lpStart = lpWork + 1;
            }
        }
        ++lpWork;
    }
    if ( ! lpStart ) return FALSE;

    return MultiByteToWideChar( CP_UTF8, 0, lpStart, -1, lpw, dwLen ) != 0;
}

/* https://msdn.microsoft.com/en-us/library/windows/desktop/aa376389(v=vs.85).aspx */
BOOL IsUserAdmin(VOID)
{
    BOOL b;
    SID_IDENTIFIER_AUTHORITY NtAuthority = SECURITY_NT_AUTHORITY;
    PSID AdministratorsGroup;
    b = AllocateAndInitializeSid(
        &NtAuthority,
        2,
        SECURITY_BUILTIN_DOMAIN_RID,
        DOMAIN_ALIAS_RID_ADMINS,
        0, 0, 0, 0, 0, 0,
        &AdministratorsGroup);
    if ( b )
    {
        if (!CheckTokenMembership( NULL, AdministratorsGroup, &b))
        {
             b = FALSE;
        }
        FreeSid(AdministratorsGroup);
    }

    return(b);
}

int WINAPI WinMain(HINSTANCE hInst, HINSTANCE hPrevInst, LPSTR lpszCmdLine, int nCmdShow)
{
    LPWSTR *pszArglist, szCommandLine;
    int nArgs, nApp;
    STARTUPINFOW si;
    PROCESS_INFORMATION pi;
    WCHAR szBuf[1024];
    DWORD dwLen = sizeof(szBuf);

    nApp = (IsUserAdmin() != 0);
    if(RegGetValueW(HKEY_LOCAL_MACHINE, lpszKey[nApp][0], lpszKey[nApp][1], RRF_RT_REG_SZ, 0, szBuf, &dwLen) != ERROR_SUCCESS)
    {
        if(!GetScoopInstalledPathW(szBuf, sizeof(szBuf)/sizeof(szBuf[0]), lpszFallbackExe[nApp])) {
            StringCbCopyW(szBuf, sizeof(szBuf), lpszFallbackExe[nApp]);
        }
    }
    pszArglist = CommandLineToArgvW(GetCommandLineW(), &nArgs);
    if(nArgs > 3) nArgs = 3;
    pszArglist[0] = szBuf;
    FormatMessageW(
        FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_ARGUMENT_ARRAY | FORMAT_MESSAGE_FROM_STRING,
        lpszAppSpec[nArgs-1][nApp],
        0,
        0,
        (LPWSTR)&szCommandLine,
        1024,
        (void*)pszArglist
    );
    OutputDebugStringW(szCommandLine);
    ZeroMemory(&si, sizeof(si));
    si.cb = sizeof(si);
    CreateProcessW(NULL, szCommandLine, NULL, NULL, FALSE, 0, NULL, NULL, &si, &pi);
    LocalFree(szCommandLine);
    LocalFree(pszArglist);

    return IsUserAdmin();
}
