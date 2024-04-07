#!/usr/bin/env python3

import os
import subprocess
import argparse
import sys

files = [
    "vendor/kk/",
    "device/softwinner/cupid-p2/BoardConfig.mk",
    "device/softwinner/cupid-p2/cupid_p2.mk",
    "frameworks/base/Android.bp",
]

if sys.version_info >= (3, 5):
    # Python 3.5 及以上版本的 API
    import subprocess

    def run_command(command):
        subprocess.run(command, check=True)

else:
    # Python 3.4 及以下版本的 API
    import subprocess

    def run_command(command):
        subprocess.Popen(command).wait()


def rsync_sync(source, target):
    if not os.path.exists(source):
        print("[*] source not exists: %s" % (source))
        return

    command = ["rsync", "-avzh", "--delete"]
    if not os.path.exists(target):
        try:
            if os.path.isfile(source):
                target_parent_dir = os.path.dirname(target)
                os.makedirs(target_parent_dir, exist_ok=True)
            else:
                os.makedirs(target, exist_ok=True)
        except OSError as e:
            print("[*] 无法创建目标目录:", e)
            return

    command.append(source)
    command.append(target)
    try:
        run_command(command)
        print("[*] 同步完成！")
    except subprocess.CalledProcessError as e:
        print("[*] 同步失败:", e)


def main():
    parser = argparse.ArgumentParser(description="使用 rsync 工具同步两个文件")
    parser.add_argument("source", help="源目录的路径")
    parser.add_argument("target", help="目标目录的路径")
    args = parser.parse_args()

    for file in files:
        source_file = os.path.join(args.source, file)
        target_file = os.path.join(args.target, file)
        rsync_sync(source_file, target_file)


if __name__ == "__main__":
    main()
