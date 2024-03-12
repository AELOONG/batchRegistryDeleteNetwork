from __future__ import print_function
import winreg
import traceback
# import ctypes
from ctypes import windll
# import sys
from sys import executable, version_info
from typing import List, Tuple
from os import system


def strToInt(__x: str, default: int) -> int:
    if __x != None and __x != '':
        return int(__x)
    else:
        return default


def is_admin():
    try:
        return windll.shell32.IsUserAnAdmin()
    except:
        return False


if __name__ == '__main__':
    reg_network_path = r'SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles'
    idx_min = 1
    del_key_list: List[Tuple[str, str]] = []

    if is_admin() == False:
        if version_info[0] == 3:
            windll.shell32.ShellExecuteW(
                None, "runas", executable, __file__, None, 1)
        else:  # in python2.x
            windll.shell32.ShellExecuteW(
                None, u"runas", unicode(executable), unicode(__file__), None, 1)
        exit(0)

    try:
        key = winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, rf'{reg_network_path}')
        try:
            key_num = winreg.QueryInfoKey(key)[0]

            for i in range(0, key_num):
                sub_key_name = winreg.EnumKey(key, i)

                sub_key = winreg.OpenKey(
                    winreg.HKEY_LOCAL_MACHINE, rf'{reg_network_path}\{sub_key_name}')
                try:
                    name, REG_SZ = winreg.QueryValueEx(sub_key, 'ProfileName')
                except WindowsError:
                    winreg.CloseKey(sub_key)
                    continue
                winreg.CloseKey(sub_key)

                # 如: 网络 20
                if name[0:2] == '网络' and strToInt(name[3:], 0) >= idx_min:
                    del_key_list.append((name, sub_key_name))
        except WindowsError as err:
            print(traceback.format_exc())

        for del_key in del_key_list:
            winreg.DeleteKey(key, del_key[1])
            print(f'Delete {del_key[0]}, {del_key[1]}')

        winreg.CloseKey(key)
    except WindowsError as err:
        print(traceback.format_exc())

    system("pause")
