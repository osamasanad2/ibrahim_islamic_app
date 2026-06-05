#!/usr/bin/env python3
"""
Download all 604 Mushaf (Quran page) images for offline use.
Downloads from the GitHub QuranHub repository and organizes them.

Usage:
  python scripts/fetch_mushaf_pages.py                    # default: ~/.ibrahim_app/mushaf_pages/
  python scripts/fetch_mushaf_pages.py --output /path/to/dir
  python scripts/fetch_mushaf_pages.py --parallel 8       # 8 concurrent downloads
"""

import argparse
import concurrent.futures
import os
import sys
import time
import urllib.request

BASE_URL = "https://raw.githubusercontent.com/QuranHub/quran-pages-images/main/easyquran.com/hafs-tajweed"
TOTAL_PAGES = 604
DEFAULT_OUTPUT = os.path.expanduser("~/.ibrahim_app/mushaf_pages")


def download_page(page_num: int, output_dir: str) -> tuple[int, bool, str]:
    filename = f"page_{page_num}.jpg"
    filepath = os.path.join(output_dir, filename)

    if os.path.exists(filepath) and os.path.getsize(filepath) > 1000:
        return page_num, True, "already cached"

    url = f"{BASE_URL}/{page_num}.jpg"
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "IbrahimApp/1.0"})
        with urllib.request.urlopen(req, timeout=30) as response:
            data = response.read()
            if len(data) < 1000:
                return page_num, False, f"too small ({len(data)} bytes)"
            with open(filepath, "wb") as f:
                f.write(data)
        return page_num, True, f"{len(data) / 1024:.1f} KB"
    except Exception as e:
        return page_num, False, str(e)


def main():
    parser = argparse.ArgumentParser(description="Download Mushaf page images for offline use")
    parser.add_argument("--output", default=DEFAULT_OUTPUT, help="Output directory")
    parser.add_argument("--parallel", type=int, default=4, help="Parallel downloads (default: 4)")
    parser.add_argument("--resume", action="store_true", help="Skip existing files")
    args = parser.parse_args()

    output_dir = args.output
    os.makedirs(output_dir, exist_ok=True)

    start_time = time.time()
    success = 0
    failed = 0

    print(f"Downloading {TOTAL_PAGES} Mushaf pages to: {output_dir}")
    print(f"Parallel downloads: {args.parallel}")
    print("-" * 60)

    with concurrent.futures.ThreadPoolExecutor(max_workers=args.parallel) as executor:
        futures = {
            executor.submit(download_page, i, output_dir): i
            for i in range(1, TOTAL_PAGES + 1)
        }

        for future in concurrent.futures.as_completed(futures):
            page_num, ok, msg = future.result()
            if ok:
                success += 1
            else:
                failed += 1
            elapsed = time.time() - start_time
            done = success + failed
            pct = done / TOTAL_PAGES * 100
            status = "OK" if ok else "FAIL"
            print(f"[{pct:5.1f}%] Page {page_num:3d}/{TOTAL_PAGES} [{status}] {msg}  ({elapsed:.0f}s)")

    elapsed = time.time() - start_time
    print("-" * 60)
    print(f"Done! {success} succeeded, {failed} failed in {elapsed:.0f}s")

    total_size = sum(
        os.path.getsize(os.path.join(output_dir, f))
        for f in os.listdir(output_dir)
        if f.endswith(".jpg")
    )
    print(f"Total size: {total_size / 1024 / 1024:.1f} MB")

    return 1 if failed > 0 else 0


if __name__ == "__main__":
    sys.exit(main())
