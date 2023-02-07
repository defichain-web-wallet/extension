from pydrive.auth import GoogleAuth
from pydrive.drive import GoogleDrive
import os
import json
import argparse
import subprocess
import shutil
import pathlib


DIR = pathlib.Path(__file__).parent.resolve()
EXT = "tar"


def get_version():
    manifest_json_file_path = f"{DIR}/../web/manifest.json"
    with open(manifest_json_file_path, "r") as f:
        manifest = json.loads(f.read())
        return manifest["version"]


def update_manifest(version):
    manifest_json_file_path = f"{DIR}/../web/manifest.json"
    with open(manifest_json_file_path, "r") as f:
        manifest = json.loads(f.read())
        manifest["version"]: version
    with open(manifest_json_file_path, "w") as f:
        f.write(json.dumps(manifest))


def check_git():
    command = "git status"
    branch_state = subprocess.run(
        command, universal_newlines=True, shell=True, stdout=subprocess.PIPE).stdout
    branch_clean = "nothing to commit, working tree clean" in branch_state
    if not branch_clean:
        result = input("Branch not clean, continue? (Y/n) ").lower()
        while result != "y" and result != "n" and result != "":
            result = input("Branch not clean, continue? (Y/n) ").lower()
        if result == "n":
            print("aborting...")
            exit(1)


def get_sufix(version):
    command = f"git tag -l \"{version}*\""
    tags = subprocess.run(command, universal_newlines=True,
                          shell=True, stdout=subprocess.PIPE).stdout.splitlines()
    tag_sufix_list = [-1]
    for tag in tags:
        data = tag.split("-")
        if len(data) > 1:
            sufix = data[1]
            number = int(sufix)
            tag_sufix_list.append(number)
    tag_sufix_list.sort()
    return tag_sufix_list[-1] + 1


def commit():
    command = "git commit -a -m \"[SCRIPT] - updating manifest json\""
    subprocess.run(command, universal_newlines=True, shell=True)


def create_tag(name):
    command = f"git tag \"{name}\""
    subprocess.run(command, universal_newlines=True, shell=True)


def push():
    command = f"git push origin --tags"
    subprocess.run(command, universal_newlines=True, shell=True)


def build():
    command = "flutter build web --csp --web-renderer html"
    result = subprocess.run(command, universal_newlines=True, shell=True)
    if result.returncode > 0:
        exit(result.returncode)
    return result


def pack_archive(name):
    shutil.make_archive(name, f"{EXT}", f"{DIR}/../build/web")


def upload_archive(name):
    gauth = GoogleAuth()
    drive = GoogleDrive(gauth)
    gfile = drive.CreateFile({
        'parents': [
            {
                'id': '1U9QjBLkdPoRNy12m5qwwGnv4M1WAJWwb',
                'kind': 'drive#fileLink',
                'teamDriveId': '0AJdXE0_Xbq2yUk9PVA'
            }],
        'supportsAllDrives': True,
        'corpora': 'teamDrive',
        'teamDriveId': '0AJdXE0_Xbq2yUk9PVA',
        'includeTeamDriveItems': True,
        'supportsTeamDrives': True
    })
    gfile.SetContentFile(f"{name}.{EXT}")
    gfile.Upload(param={'supportsTeamDrives': True})


def delete_archive(name):
    os.remove(f"{name}.{EXT}")


def run(version):
    check_git()
    update_manifest(version)
    commit()
    sufix = get_sufix(version)
    name = f"{version}-{sufix}"
    create_tag(name)
    push()
    build()
    pack_archive(name)
    upload_archive(name)
    delete_archive(name)


if __name__ == "__main__":
    version = get_version()
    parser = argparse.ArgumentParser()
    parser.add_argument("--version", help="new version", default=version)
    args = parser.parse_args()
    run(args.version)
