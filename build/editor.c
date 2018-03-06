#include <windows.h>

#define NUM_APP 2

LPWSTR lpszKey[NUM_APP][2] = {
    { L"SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\Hidemaru", L"DisplayIcon" },
    { L"SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\Notepad++", L"DisplayIcon" }
};

LPWSTR lpszAppSpec[][NUM_APP] = {
    { L"\"%1\"", L"\"%1\"" },
    { L"\"%1\" \"%2\"", L"\"%1\" \"%2\"",  },
    { L"\"%1\" /j%3 \"%2\"", L"\"%1\" -n%3 \"%2\"" }
};

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
    if(b) 
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
    RegGetValueW(HKEY_LOCAL_MACHINE, lpszKey[nApp][0], lpszKey[nApp][1], RRF_RT_REG_SZ, 0, szBuf, &dwLen);
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
