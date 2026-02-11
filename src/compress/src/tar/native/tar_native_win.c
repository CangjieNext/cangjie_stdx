/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

#include <windows.h>
#include <wchar.h>
#include <time.h>
#include <stdint.h>

static wchar_t *ToWString(const char *str) {
    int len = MultiByteToWideChar(CP_UTF8, 0, str, -1, NULL, 0);
    wchar_t *wstr = (wchar_t *)malloc(len * sizeof(wchar_t));
    if (!wstr) {
        return NULL;
    }
    MultiByteToWideChar(CP_UTF8, 0, str, -1, wstr, len);
    return wstr;
}

static FILETIME ToFileTime(time_t t) {
    LONGLONG ll = ((LONGLONG)t + 11644473600LL) * 10000000LL;
    FILETIME ft;
    ft.dwLowDateTime  = (DWORD)ll;
    ft.dwHighDateTime = (DWORD)(ll >> 32);
    return ft;
}

extern int CJ_TAR_SetModificationTime(const char *path, int64_t timestamp) {
    wchar_t *wpath = ToWString(path);
    if (wpath == NULL) {
        return -1;
    }
    HANDLE hFile = CreateFileW(wpath, FILE_WRITE_ATTRIBUTES, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
    free(wpath);
    if (hFile == INVALID_HANDLE_VALUE) {
        return -1;
    }

    FILETIME ft = ToFileTime((time_t)timestamp);
    int ok = SetFileTime(hFile, NULL, NULL, &ft);
    CloseHandle(hFile);
    if (!ok) {
        return -1;
    }
    return 0;
}

extern int CJ_TAR_SetAccessTime(const char *path, int64_t timestamp) {
    wchar_t *wpath = ToWString(path);
    if (wpath == NULL) {
        return -1;
    }
    HANDLE hFile = CreateFileW(wpath, FILE_WRITE_ATTRIBUTES, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
    free(wpath);
    if (hFile == INVALID_HANDLE_VALUE) {
        return -1;
    }

    FILETIME ft = ToFileTime((time_t)timestamp);
    int ok = SetFileTime(hFile, NULL, &ft, NULL);
    CloseHandle(hFile);
    if (!ok) {
        return -1;
    }
    return 0;
}

extern int CJ_TAR_SetChangeTime(const char *path, int64_t timestamp) {
    wchar_t* wpath = ToWString(path);
    HANDLE hFile = CreateFileW(wpath, FILE_WRITE_ATTRIBUTES, FILE_SHARE_READ, NULL, OPEN_EXISTING, 0, NULL);
    free(wpath);
    if (hFile == INVALID_HANDLE_VALUE) {
        return -1;
    }

    FILETIME ft = ToFileTime((time_t)timestamp);
    int ok = SetFileTime(hFile, &ft, NULL, NULL);
    CloseHandle(hFile);
    if (!ok) {
        return -1;
    }
    return 0;
}
