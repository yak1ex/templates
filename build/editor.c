#include <windows.h>
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

/* based on https://learn.microsoft.com/en-us/windows/win32/procthread/creating-a-child-process-with-redirected-input-and-output */
BOOL GetScoopInstalledPathW(LPWSTR lpw, DWORD dwLen, LPWSTR lpwExe)
{
    HANDLE hReader, hWriter;
    {
        /* Set the bInheritHandle flag so pipe handles are inherited. */
        SECURITY_ATTRIBUTES saAttr = {
            sizeof(SECURITY_ATTRIBUTES), /* nLength */
            NULL, /* lpSecurityDescriptor */
            TRUE /* bInheritHandle */
        };
        /* Create a pipe for the child process's STDOUT. */
        if ( ! CreatePipe( &hReader, &hWriter, &saAttr, 0) ) {
            return FALSE;
        }
    }
    /* Ensure the read handle to the pipe for STDOUT is not inherited. */
    if ( ! SetHandleInformation(hReader, HANDLE_FLAG_INHERIT, 0) ) {
        CloseHandle( hWriter );
        CloseHandle( hReader );
        return FALSE;
    }

    /* Create the child process. */
    {

        /* Set up members of the STARTUPINFO structure.
           This structure specifies the STDIN and STDOUT handles for redirection. */
        PROCESS_INFORMATION piProcInfo;
        STARTUPINFOW siStartInfo;

        /* Set up members of the PROCESS_INFORMATION structure. */
        ZeroMemory( &piProcInfo, sizeof(PROCESS_INFORMATION) );
        ZeroMemory( &siStartInfo, sizeof(STARTUPINFO) );
        siStartInfo.cb = sizeof(STARTUPINFO);
        siStartInfo.hStdOutput = hWriter;
        siStartInfo.dwFlags |= STARTF_USESTDHANDLES | STARTF_USESHOWWINDOW;

        /* Create the child process.  */
        {
            WCHAR buf[2048];
            StringCbPrintfW( buf, sizeof(buf),  L"cmd.exe /c scoop which %s", lpwExe );

            if ( ! CreateProcessW(NULL,
                                  buf,             /* command line */
                                  NULL,            /* process security attributes */
                                  NULL,            /* primary thread security attributes */
                                  TRUE,            /* handles are inherited */
                                  0,               /* creation flags */
                                  NULL,            /* use parent's environment */
                                  NULL,            /* use parent's current directory */
                                  &siStartInfo,    /* STARTUPINFO pointer */
                                  &piProcInfo) ) { /* receives PROCESS_INFORMATION */
                /* If an error occurs, exit the application.  */
                CloseHandle( hWriter );
                CloseHandle( hReader );
                return FALSE;
            }
        }

        /* Close handles to the child primary thread. */
        CloseHandle( piProcInfo.hThread );
        /* Close handles to the stdout pipes no longer needed by the child process.
           If they are not explicitly closed, there is no way to recognize that the child process has ended. */
        CloseHandle( hWriter );

        /* Wait the child process. */
        WaitForSingleObject( piProcInfo.hProcess, INFINITE );
        CloseHandle( piProcInfo.hProcess );
    }

    {
        CHAR chBuf[BUFSIZE];
        DWORD dwRead;
        if ( ! ReadFile( hReader, chBuf, BUFSIZE, &dwRead, NULL) ) {
            CloseHandle( hReader );
            return FALSE;
        }
        CloseHandle( hReader );
        if ( dwRead && chBuf[dwRead - 1] == '\n' ) --dwRead;
        if ( dwRead && chBuf[dwRead - 1] == '\r' ) --dwRead;
        chBuf[dwRead] = 0;
        if ( chBuf[0] == '~' ) {
            DWORD dwLenHome = GetEnvironmentVariableW( L"USERPROFILE", lpw, dwLen );
            if ( ! dwLenHome ) {
                CloseHandle( hReader );
                return FALSE;
            }
            if ( ! MultiByteToWideChar( CP_ACP, 0, chBuf + 1, -1, lpw + dwLenHome, dwLen - dwLenHome ) ) {
                CloseHandle( hReader );
                return FALSE;
            }
        } else {
            if ( ! MultiByteToWideChar( CP_ACP, 0, chBuf, -1, lpw, dwLen ) ) {
                CloseHandle( hReader );
                return FALSE;
            }
        }
    }

    return TRUE;
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
