#!/usr/bin/env python3
"""Fetch complete Quran from GitHub JSON dataset and bundle locally."""

import json
import urllib.request
import os

BASE = 'https://raw.githubusercontent.com/penggguna/QuranJSON/master/surah'
OUT = os.path.join(os.path.dirname(__file__), '..', 'assets', 'quran', 'quran_full.json')

def fetch(url):
    with urllib.request.urlopen(url, timeout=30) as r:
        return json.loads(r.read())

def main():
    all_surahs = []
    total_ayahs = 0

    for num in range(1, 115):
        print(f'Fetching surah {num}/114...')
        url = f'{BASE}/{num}.json'
        try:
            data = fetch(url)
        except Exception as e:
            print(f'  ERROR: {e}')
            continue

        verses = data.get('verses', [])
        ayahs = []
        for v in verses:
            ayahs.append({
                'number': v['number'],
                'text': v['text'],
                'translation_en': v.get('translation_en', ''),
            })

        surah = {
            'number': data['number_of_surah'],
            'name': data['name'],
            'name_arabic': data['name_translations']['ar'],
            'name_english': data['name_translations']['en'],
            'revelation_type': data['place'],
            'ayahs': ayahs,
        }
        all_surahs.append(surah)
        total_ayahs += len(ayahs)
        print(f'  -> {len(ayahs)} ayahs')

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, 'w', encoding='utf-8') as f:
        json.dump(all_surahs, f, ensure_ascii=False, indent=2)

    print(f'\nDone! {len(all_surahs)} surahs, {total_ayahs} ayahs')
    print(f'Saved to: {OUT}')
    print(f'Size: {os.path.getsize(OUT) / 1024 / 1024:.1f} MB')

if __name__ == '__main__':
    main()
