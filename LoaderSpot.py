import re
import requests
from concurrent.futures import ThreadPoolExecutor


def check_url(url, platform_name):
    try:
        response = requests.get(url)
        if response.status_code == 200:
            if platform_name:
                return response.url, platform_name
            else:
                return response.url
        else:
            print(f"\nInvalid link: {url}")
        response.close()
    except requests.exceptions.RequestException:
        pass
    return None


version_spoti = ""
while not re.match(r"^\d+\.\d+\.\d+\.\d+\.g[0-9a-f]{8}$", version_spoti):
    version_spoti = input("Spotify version, for example 1.1.68.632.g2b11de83: ")

start_number = ""
while not start_number.isdigit() or not 0 <= int(start_number) <= 20000:
    start_number = input("Start search from: ")

before_enter = ""
while not before_enter.isdigit() or not 1 <= int(before_enter) <= 20000:
    before_enter = input("End search at: ")

max_workers_req = ""
while True:
    max_workers_req = input("Number of threads: ")
    try:
        max_workers = int(max_workers_req)
        if 1 <= max_workers <= 150:
            break
        else:
            print("Value should be in the range from 1 to 150")
    except ValueError:
        print("Invalid value, please enter an integer")

numbers = int(start_number)
find_url = []

win32 = "https://upgrade.scdn.co/upgrade/client/win32-x86/spotify_installer-{version_spoti}-{numbers}.exe"
win_arm64 = "https://upgrade.scdn.co/upgrade/client/win32-arm64/spotify_installer-{version_spoti}-{numbers}.exe"
osx = "https://upgrade.scdn.co/upgrade/client/osx-x86_64/spotify-autoupdate-{version_spoti}-{numbers}.tbz"
osx_arm64 = "https://upgrade.scdn.co/upgrade/client/osx-arm64/spotify-autoupdate-{version_spoti}-{numbers}.tbz"

print("Select the link type for the search:")
print("[1] WIN32")
print("[2] WIN-ARM64")
print("[3] OSX")
print("[4] OSX-ARM64")
print("[5] ALL")

choice = None
while choice not in ["1", "2", "3", "4", "5"]:
    choice = input("Enter the number: ")

    if choice == "1":
        url_template = win32
        platform_name = "WIN32"
    elif choice == "2":
        url_template = win_arm64
        platform_name = "WIN-ARM64"
    elif choice == "3":
        url_template = osx
        platform_name = "OSX"
    elif choice == "4":
        url_template = osx_arm64
        platform_name = "OSX-ARM64"
    elif choice == "5":
        url_templates = [win32, win_arm64, osx, osx_arm64]
        platform_names = ["WIN32", "WIN-ARM64", "OSX", "OSX-ARM64"]
    else:
        print("Value should be in the range from 1 to 5")

print("Searching...")

with ThreadPoolExecutor(max_workers=max_workers) as executor:
    tasks = []

    if choice == "5":
        for url_template, platform_name in zip(url_templates, platform_names):
            numbers = int(start_number)
            while numbers <= int(before_enter):
                url = url_template.format(version_spoti=version_spoti, numbers=numbers)
                tasks.append(executor.submit(check_url, url, platform_name))
                numbers += 1
    else:
        while numbers <= int(before_enter):
            url = url_template.format(version_spoti=version_spoti, numbers=numbers)
            tasks.append(executor.submit(check_url, url, platform_name))
            numbers += 1

    for task in tasks:
        result = task.result()
        if result is not None:
            find_url.append(result)

print("\nSearch completed.\n")
if find_url:
    platform_urls = {}
    for item in find_url:
        if isinstance(item, tuple):
            url, platform_name = item
            if platform_name not in platform_urls:
                platform_urls[platform_name] = []
            platform_urls[platform_name].append(url)
        else:
            if "Unknown" not in platform_urls:
                platform_urls["Unknown"] = []
            platform_urls["Unknown"].append(item)

    for platform_name, urls in platform_urls.items():
        print(f"{platform_name}:")
        for url in urls:
            print(url)
        print()
else:
    print("Nothing found, consider increasing the search range.")

print("\n")
input("Press Enter to exit")
