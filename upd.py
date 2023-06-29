import aiohttp
import asyncio
import json
import argparse
from bs4 import BeautifulSoup

parser = argparse.ArgumentParser()
parser.add_argument("-v", required=True)
parser.add_argument("-s", required=True)
parser.add_argument("-u", required=True)

args = parser.parse_args()
version = args.v
source = args.s
u = args.u


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


async def send_request(json_data):
    url = u + json_data
    async with aiohttp.ClientSession() as session:
        async with session.get(url) as response:
            if response.status == 200:
                data = await response.text()
                soup = BeautifulSoup(data, "html.parser")
                system_response = soup.find(
                    "div",
                    style="text-align:center;font-family:monospace;margin:50px auto 0;max-width:600px",
                ).text
                print(f"Ответ от Google apps script: {system_response}")


async def main():
    start_number = 0
    before_enter = 5500

    numbers = start_number
    find_url = []

    win32 = "https://upgrade.scdn.co/upgrade/client/win32-x86/spotify_installer-{version}-{numbers}.exe"
    win64 = "https://upgrade.scdn.co/upgrade/client/win32-x86_64/spotify_installer-{version_spoti}-{numbers}.exe"
    win_arm64 = "https://upgrade.scdn.co/upgrade/client/win32-arm64/spotify_installer-{version}-{numbers}.exe"
    osx = "https://upgrade.scdn.co/upgrade/client/osx-x86_64/spotify-autoupdate-{version}-{numbers}.tbz"
    osx_arm64 = "https://upgrade.scdn.co/upgrade/client/osx-arm64/spotify-autoupdate-{version}-{numbers}.tbz"

    async with aiohttp.ClientSession() as session:
        tasks = []

        url_templates = [win32, win64, win_arm64, osx, osx_arm64]
        platform_names = ["WIN32", "WIN64", "WIN-ARM64", "OSX", "OSX-ARM64"]

        for url_template, platform_name in zip(url_templates, platform_names):
            numbers = start_number
            while numbers <= before_enter:
                url = url_template.format(version=version, numbers=numbers)
                tasks.append(check_url(session, url, platform_name))
                numbers += 1

        results = []

        for task in asyncio.as_completed(tasks):
            result = await task
            if result is not None:
                find_url.append(result)
    if find_url:
        platform_urls = {}
        for item in find_url:
            if isinstance(item, tuple):
                url, platform_name = item
                if platform_name not in platform_urls:
                    platform_urls[platform_name] = str(
                        url
                    )  # Преобразование URL в строку
            else:
                if "unknown" not in platform_urls:
                    platform_urls["unknown"] = "unknown"
        platform_urls["version"] = version
        platform_urls["source"] = source
        req_ver = json.dumps(platform_urls)
        print(f"Версия {version} отправлена")
        await send_request(req_ver)
    else:
        print(f"Версия {version} не найдена")
        data = {"unknown": "unknown", "version": version}
        req_ver = json.dumps(data)
        await send_request(req_ver)


asyncio.run(main())
