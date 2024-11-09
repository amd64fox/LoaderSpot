import re
import json
import aiohttp
import asyncio
from tqdm import tqdm
from typing import Optional, Tuple, List, Dict
from dataclasses import dataclass
from enum import Enum
import threading


class Platform(Enum):
    WIN_X86 = "Win-x86"
    WIN_X64 = "Win-x64"
    WIN_ARM64 = "Win-arm64"
    MACOS_INTEL = "macOS-intel"
    MACOS_ARM64 = "macOS-arm64"


@dataclass
class SpotifyVersion:
    version: str
    start_number: int
    end_number: int


class UrlGenerator:
    BASE_URL = "https://upgrade.scdn.co/upgrade/client/"
    PLATFORM_PATHS = {
        Platform.WIN_X86: "win32-x86/spotify_installer-{version}-{number}.exe",
        Platform.WIN_X64: "win32-x86_64/spotify_installer-{version}-{number}.exe",
        Platform.WIN_ARM64: "win32-arm64/spotify_installer-{version}-{number}.exe",
        Platform.MACOS_INTEL: "osx-x86_64/spotify-autoupdate-{version}-{number}.tbz",
        Platform.MACOS_ARM64: "osx-arm64/spotify-autoupdate-{version}-{number}.tbz",
    }

    @staticmethod
    def generate_url(platform: Platform, version: str, number: int) -> str:
        return f"{UrlGenerator.BASE_URL}{UrlGenerator.PLATFORM_PATHS[platform].format(version=version, number=number)}"


async def check_url(
    session: aiohttp.ClientSession, url: str, platform: Platform
) -> Optional[Tuple[str, Platform]]:
    try:
        async with session.get(url) as response:
            if response.status == 200:
                return str(response.url), platform
    except aiohttp.ClientError:
        pass
    return None


async def fetch_versions_json() -> dict:
    async with aiohttp.ClientSession() as session:
        async with session.get(
            "https://raw.githubusercontent.com/amd64fox/LoaderSpot/refs/heads/main/versions.json"
        ) as response:
            if response.status == 200:
                try:
                    return json.loads(await response.text())
                except json.JSONDecodeError:
                    return {}
            return {}


async def submit_to_google_form(version: str, comment: str = "from LoaderSpot") -> None:
    form_url = "https://docs.google.com/forms/u/0/d/e/1FAIpQLSdqIxSjqt2PcjBlQzhvwqc4QckfWuq5qqWsrdpoTidQHsPGpw/formResponse"
    data = {"entry.1104502920": version, "entry.1319854718": comment}

    async with aiohttp.ClientSession() as session:
        try:
            await session.post(form_url, data=data)
        except Exception:
            pass


async def check_version_and_submit(version: str) -> None:
    try:
        versions_json = await fetch_versions_json()
        version_exists = any(
            ver_data.get("fullversion") == version
            for ver_data in versions_json.values()
        )

        if not version_exists:
            await submit_to_google_form(version)

    except Exception:
        pass


def validate_version(version: str) -> bool:
    return bool(re.match(r"^\d+\.\d+\.\d+\.\d+\.g[0-9a-f]{8}$", version))


def validate_number(number: str, min_val: int, max_val: int) -> bool:
    return number.isdigit() and min_val <= int(number) <= max_val


def get_valid_input(prompt: str, validator: callable, error_message: str) -> str:
    while True:
        value = input(prompt)
        if validator(value):
            return value
        print(error_message)


def get_version_input() -> str:
    while True:
        version = input("Spotify version, for example 1.1.68.632.g2b11de83: ")
        if validate_version(version):
            return version
        print("Invalid version format")


def calculate_total_urls(
    start_number: int, end_number: int, selected_platforms: List[Platform]
) -> int:
    return (end_number - start_number + 1) * len(selected_platforms)


async def search_installers(
    version_info: SpotifyVersion, selected_platforms: List[Platform]
) -> Dict[Platform, List[str]]:
    async with aiohttp.ClientSession() as session:
        tasks = []
        total_urls = calculate_total_urls(
            version_info.start_number, version_info.end_number, selected_platforms
        )

        for platform in selected_platforms:
            for number in range(version_info.start_number, version_info.end_number + 1):
                url = UrlGenerator.generate_url(platform, version_info.version, number)
                tasks.append(check_url(session, url, platform))

        results: Dict[Platform, List[str]] = {platform: [] for platform in Platform}

        with tqdm(total=total_urls) as pbar:
            for task in asyncio.as_completed(tasks):
                if result := await task:
                    url, platform = result
                    results[platform].append(url)
                pbar.update(1)

        return results


def display_results(results: Dict[Platform, List[str]]) -> None:
    found_any = False
    for platform in Platform:
        if urls := results[platform]:
            found_any = True
            print(f"\n{platform.value}:")
            for url in urls:
                print(url)

    if not found_any:
        print("\nNothing found, consider increasing the search range")


def get_platform_choices() -> List[Platform]:
    print("\nSelect the link type for the search:")
    for i, platform in enumerate(Platform, 1):
        print(f"[{i}] {platform.value}")
    print("[6] All platforms")

    while True:
        choices = input("Enter the number(s): ").strip().split(",")

        if not all(choice.strip() in "123456" for choice in choices):
            print("Invalid input. Please enter numbers between 1 and 6")
            continue

        if "6" in choices:
            return list(Platform)

        selected = []
        for choice in choices:
            platform_index = int(choice.strip()) - 1
            if 0 <= platform_index < len(Platform):
                selected.append(list(Platform)[platform_index])

        if selected:
            return selected

        print("Please select at least one valid platform")


async def main(version_spoti: str = "") -> None:
    if not version_spoti:
        version_spoti = get_version_input()

    version_check_thread = threading.Thread(
        target=lambda: asyncio.run(check_version_and_submit(version_spoti)), daemon=True
    )
    version_check_thread.start()

    start_number = int(
        get_valid_input(
            "Start search from: ",
            lambda x: validate_number(x, 0, 20000),
            "Number should be between 0 and 20000",
        )
    )
    end_number = int(
        get_valid_input(
            "End search at: ",
            lambda x: validate_number(x, start_number, 20000),
            f"Number should be between {start_number} and 20000",
        )
    )

    version_info = SpotifyVersion(version_spoti, start_number, end_number)
    selected_platforms = get_platform_choices()

    print("\nSearching...\n")
    results = await search_installers(version_info, selected_platforms)
    display_results(results)

    print("\nChoose an option:")
    print("[1] Perform the search with a new version")
    print("[2] Perform the search again with the same version")
    print("[3] Exit")

    choice = input("Enter the number: ")

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
        print("Invalid choice. Exiting the program.")


if __name__ == "__main__":
    asyncio.run(main())
