import aiohttp
import asyncio
import json
import re
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
                print(f"Ответ от GAS: {system_response}")


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


async def pre_version(latest_urls):
    message = f'Версия {version} {"отправлена" if latest_urls else "не найдена"}'
    print(message)

    if not latest_urls:
        latest_urls = {"unknown": "unknown", "version": version}

    latest_urls["version"] = version
    latest_urls["source"] = source

    req_ver = json.dumps(latest_urls, ensure_ascii=False, indent=2)
    await send_request(req_ver)


def get_urls(find_url):
    platform_urls = {}
    version_pattern = re.compile(r"-([0-9]+)\.(exe|tbz)")

    for url, platform in find_url:
        match = version_pattern.search(str(url))
        if match:
            version_number = int(match.group(1))
            if platform in platform_urls:
                # Если найдено больше одного url для платформы, то выбираем с самой большой ревизией
                current_version = int(
                    version_pattern.search(platform_urls[platform]).group(1)
                )
                if version_number > current_version:
                    platform_urls[platform] = str(url)
            else:
                platform_urls[platform] = str(url)

    return platform_urls


async def main():
    start_number = 0
    before_enter = 1000
    additional_searches = 8  # Максимальное кол-во шагов для дополнительного поиска
    increment = 1000  # Размер шага

    numbers = start_number
    find_url = []

    root_url = "https://upgrade.scdn.co/upgrade/client/"
    platform_templates = {
        "WIN32": "win32-x86/spotify_installer-{version}-{numbers}.exe",
        "WIN64": "win32-x86_64/spotify_installer-{version}-{numbers}.exe",
        "WIN-ARM64": "win32-arm64/spotify_installer-{version}-{numbers}.exe",
        "OSX": "osx-x86_64/spotify-autoupdate-{version}-{numbers}.tbz",
        "OSX-ARM64": "osx-arm64/spotify-autoupdate-{version}-{numbers}.tbz",
    }

    async with aiohttp.ClientSession() as session:
        tasks = []
        platform_names = list(platform_templates.keys())

        for platform_name in platform_names:
            numbers = start_number
            while numbers <= before_enter:
                url = root_url + platform_templates[platform_name].format(
                    version=version, numbers=numbers
                )
                tasks.append(check_url(session, url, platform_name))
                numbers += 1

        results = []
        for task in asyncio.as_completed(tasks):
            result = await task
            if result is not None:
                find_url.append(result)

        # Дополнительный поиск
        for i in range(additional_searches):
            if len(get_urls(find_url)) < len(
                platform_names
            ):  # Если не найдены все платформы
                start_number = before_enter + 1
                before_enter += increment
                tasks = []
                for platform_name in platform_names:
                    numbers = start_number
                    while numbers <= before_enter:
                        url = root_url + platform_templates[platform_name].format(
                            version=version, numbers=numbers
                        )
                        tasks.append(check_url(session, url, platform_name))
                        numbers += 1

                for task in asyncio.as_completed(tasks):
                    result = await task
                    if result is not None:
                        find_url.append(result)
                latest_urls = get_urls(find_url)
                if len(latest_urls) == len(platform_names):
                    await pre_version(latest_urls)
                    return

    if find_url:
        latest_urls = get_urls(find_url)
        await pre_version(latest_urls)
    else:
        await pre_version(False)


asyncio.run(main())
