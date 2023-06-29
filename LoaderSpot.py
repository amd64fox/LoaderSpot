import re
import aiohttp
import asyncio
from tqdm import tqdm


async def check_url(session, url, platform_name):
    try:
        async with session.get(url) as response:
            if response.status == 200:
                if platform_name:
                    return response.url, platform_name
                else:
                    return response.url
    except aiohttp.ClientError:
        pass
    return None


async def main(version_spoti=""):
    if not version_spoti:
        while not re.match(r"^\d+\.\d+\.\d+\.\d+\.g[0-9a-f]{8}$", version_spoti):
            version_spoti = input("Spotify version, for example 1.1.68.632.g2b11de83: ")

    start_number = ""
    while not start_number.isdigit() or not 0 <= int(start_number) <= 20000:
        start_number = input("Start search from: ")

    before_enter = ""
    while not before_enter.isdigit() or not 1 <= int(before_enter) <= 20000:
        before_enter = input("End search at: ")

    numbers = int(start_number)
    find_url = []

    win32 = "https://upgrade.scdn.co/upgrade/client/win32-x86/spotify_installer-{version_spoti}-{numbers}.exe"
    win64 = "https://upgrade.scdn.co/upgrade/client/win32-x86_64/spotify_installer-{version_spoti}-{numbers}.exe"
    win_arm64 = "https://upgrade.scdn.co/upgrade/client/win32-arm64/spotify_installer-{version_spoti}-{numbers}.exe"
    osx = "https://upgrade.scdn.co/upgrade/client/osx-x86_64/spotify-autoupdate-{version_spoti}-{numbers}.tbz"
    osx_arm64 = "https://upgrade.scdn.co/upgrade/client/osx-arm64/spotify-autoupdate-{version_spoti}-{numbers}.tbz"

    print("\nSelect the link type for the search:")
    print("[1] WIN32")
    print("[2] WIN64")  
    print("[3] WIN-ARM64")
    print("[4] OSX")
    print("[5] OSX-ARM64")
    print("[6] All platforms")

    choices = []
    while not choices:
        choice = input("Enter the number(s): ")
        choice_list = choice.split(",")
        for c in choice_list:
            c = c.strip()
            if c == "1":
                choices.append("1")
            elif c == "2":
                choices.append("2")
            elif c == "3":
                choices.append("3")
            elif c == "4":
                choices.append("4")
            elif c == "5":
                choices.append("5") 
            elif c == "6":
                choices = ["1", "2", "3", "4", "5"]
                break
            else:
                print("Value should be in the range from 1 to 6")

    print("\nSearching...\n")

    async with aiohttp.ClientSession() as session:
        tasks = []

        if "6" in choices:  # Updated condition to include option 6
            url_templates = [win32, win64, win_arm64, osx, osx_arm64]
            platform_names = ["WIN32", "WIN64", "WIN-ARM64", "OSX", "OSX-ARM64"]
            for url_template, platform_name in zip(url_templates, platform_names):
                numbers = int(start_number)
                while numbers <= int(before_enter):
                    url = url_template.format(
                        version_spoti=version_spoti, numbers=numbers
                    )
                    tasks.append(check_url(session, url, platform_name))
                    numbers += 1
        else:
            for choice in choices:
                if choice == "1":
                    url_template = win32
                    platform_name = "WIN32"
                elif choice == "2":
                    url_template = win64 
                    platform_name = "WIN64" 
                elif choice == "3":
                    url_template = win_arm64
                    platform_name = "WIN-ARM64"
                elif choice == "4":
                    url_template = osx
                    platform_name = "OSX"
                elif choice == "5":
                    url_template = osx_arm64
                    platform_name = "OSX-ARM64"
                numbers = int(start_number)
                while numbers <= int(before_enter):
                    url = url_template.format(version_spoti=version_spoti, numbers=numbers)
                    tasks.append(check_url(session, url, platform_name))
                    numbers += 1

        results = []

        with tqdm(total=len(tasks)) as pbar:
            for task in asyncio.as_completed(tasks):
                result = await task
                if result is not None:
                    find_url.append(result)
                pbar.update(1)

    print("\nSearch completed:\n")
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

        sorting_order = ["WIN32", "WIN64", "WIN-ARM64", "OSX", "OSX-ARM64"]

        for platform_name in sorting_order:
            if platform_name in platform_urls:
                print(f"{platform_name}:")
                for url in platform_urls[platform_name]:
                    print(url)
                print()
    else:
        print("Nothing found, consider increasing the search range\n")

    choice = input("Choose an option:\n"
                   "[1] Perform the search with a new version\n"
                   "[2] Perform the search again with the same version\n"
                   "[3] Exit\n"
                   "Enter the number: ")

    if choice == "1":
        print("\n")
        await main()
    elif choice == "2":
        print("\n")
        print(f"Search version: {version_spoti}")
        await main(version_spoti)
    elif choice == "3":
        return
    else:
        print("Invalid choice. Exiting the code.")


asyncio.run(main())
