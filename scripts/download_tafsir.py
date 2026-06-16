#!/usr/bin/env python3
"""Download full tafsir for Ibn Kathir, Tabari, and Sa'di from Quran.com API."""
import json
import os
import re
import html
import time
import urllib.request
import urllib.error
from concurrent.futures import ThreadPoolExecutor, as_completed

API_BASE = "https://api.quran.com/api/v4"
HEADERS = {
    "Accept": "application/json",
    "User-Agent": "IbrahimIslamicApp/1.0"
}
MAX_WORKERS = 15
REQUEST_DELAY = 0.1  # delay between batches to avoid rate limiting

# Surah ayah counts
SURAH_AYAH_COUNT = [
    0, 7, 286, 200, 176, 120, 165, 206, 75, 129, 109,
    123, 111, 43, 52, 99, 128, 111, 110, 98, 135,
    112, 78, 118, 64, 77, 227, 93, 88, 69, 60,
    34, 30, 73, 54, 45, 83, 182, 88, 75, 85,
    54, 53, 89, 59, 37, 35, 38, 29, 18, 45,
    60, 49, 62, 55, 78, 96, 29, 22, 24, 13,
    14, 11, 11, 18, 12, 12, 30, 52, 52, 44,
    28, 28, 20, 56, 40, 31, 50, 40, 46, 42,
    29, 19, 36, 25, 22, 17, 19, 26, 30, 20,
    15, 21, 11, 8, 8, 19, 5, 8, 8, 11,
    11, 8, 3, 9, 5, 4, 7, 3, 6, 3,
    5, 4, 5, 6
]

TAFSIRS = {
    14: {
        'id': 6,
        'slug': 'tafsir_ibn_kathir',
        'name': 'تفسير ابن كثير',
        'author': 'الإمام ابن كثير الدمشقي',
    },
    15: {
        'id': 7,
        'slug': 'tafsir_tabari',
        'name': 'تفسير الطبري (جامع البيان)',
        'author': 'الإمام محمد بن جرير الطبري',
    },
    91: {
        'id': 23,
        'slug': 'tafsir_saadi',
        'name': 'تفسير السعدي (تيسير الكريم الرحمن)',
        'author': 'الشيخ عبد الرحمن بن ناصر السعدي',
    },
}

def clean_html(text):
    """Strip HTML tags and clean text."""
    if not text:
        return ''
    # Remove HTML tags
    text = re.sub(r'<[^>]+>', '', text)
    # Decode HTML entities
    text = html.unescape(text)
    # Clean multiple newlines
    text = re.sub(r'\n{3,}', '\n\n', text)
    # Clean multiple spaces
    text = re.sub(r' {3,}', ' ', text)
    # Remove leading/trailing whitespace
    text = text.strip()
    return text

def fetch_tafsir(tafsir_id, surah, ayah, retries=3):
    """Fetch tafsir for a specific ayah."""
    url = f"{API_BASE}/tafsirs/{tafsir_id}/by_ayah/{surah}:{ayah}"
    for attempt in range(retries):
        try:
            req = urllib.request.Request(url, headers=HEADERS)
            with urllib.request.urlopen(req, timeout=30) as resp:
                data = json.loads(resp.read().decode())
                text = data.get('tafsir', {}).get('text', '')
                return clean_html(text)
        except Exception as e:
            if attempt < retries - 1:
                time.sleep(2 ** attempt)
            else:
                print(f"  Failed surah={surah} ayah={ayah}: {e}")
                return ''
    return ''

def download_surah(tafsir_id, surah_num, ayah_count):
    """Download tafsir for entire surah with parallel requests."""
    print(f"  Surah {surah_num} ({ayah_count} ayahs)...")
    ayah_texts = {}
    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
        futures = {}
        for ayah in range(1, ayah_count + 1):
            future = executor.submit(fetch_tafsir, tafsir_id, surah_num, ayah)
            futures[future] = ayah
        for future in as_completed(futures):
            ayah = futures[future]
            try:
                text = future.result()
                if text:
                    ayah_texts[ayah] = text
            except Exception as e:
                print(f"  Error surah={surah_num} ayah={ayah}: {e}")
    time.sleep(REQUEST_DELAY)
    return ayah_texts

def build_surah_text(ayah_texts, ayah_count):
    """Combine ayah tafsirs into continuous text."""
    parts = []
    for ayah in range(1, ayah_count + 1):
        if ayah in ayah_texts and ayah_texts[ayah]:
            parts.append(ayah_texts[ayah])
    return '\n\n'.join(parts)

SURAH_NAMES = [
    '', 'الفاتحة', 'البقرة', 'آل عمران', 'النساء', 'المائدة', 'الأنعام',
    'الأعراف', 'الأنفال', 'التوبة', 'يونس', 'هود', 'يوسف', 'الرعد',
    'إبراهيم', 'الحجر', 'النحل', 'الإسراء', 'الكهف', 'مريم', 'طه',
    'الأنبياء', 'الحج', 'المؤمنون', 'النور', 'الفرقان', 'الشعراء',
    'النمل', 'القصص', 'العنكبوت', 'الروم', 'لقمان', 'السجدة',
    'الأحزاب', 'سبأ', 'فاطر', 'يس', 'الصافات', 'ص', 'الزمر', 'غافر',
    'فصلت', 'الشورى', 'الزخرف', 'الدخان', 'الجاثية', 'الأحقاف',
    'محمد', 'الفتح', 'الحجرات', 'ق', 'الذاريات', 'الطور', 'النجم',
    'القمر', 'الرحمن', 'الواقعة', 'الحديد', 'المجادلة', 'الحشر',
    'الممتحنة', 'الصف', 'الجمعة', 'المنافقون', 'التغابن', 'الطلاق',
    'التحريم', 'الملك', 'القلم', 'الحاقة', 'المعارج', 'نوح',
    'الجن', 'المزمل', 'المدثر', 'القيامة', 'الإنسان', 'المرسلات',
    'النبأ', 'النازعات', 'عبس', 'التكوير', 'الإنفطار', 'المطففين',
    'الإنشقاق', 'البروج', 'الطارق', 'الأعلى', 'الغاشية', 'الفجر',
    'البلد', 'الشمس', 'الليل', 'الضحى', 'الشرح', 'التين', 'العلق',
    'القدر', 'البينة', 'الزلزلة', 'العاديات', 'القارعة', 'التكاثر',
    'العصر', 'الهمزة', 'الفيل', 'قريش', 'الماعون', 'الكوثر',
    'الكافرون', 'النصر', 'المسد', 'الإخلاص', 'الفلق', 'الناس'
]

def process_tafsir(api_tafsir_id, book_info, out_dir):
    """Download and save complete tafsir."""
    print(f"\n{'='*60}")
    print(f"Downloading {book_info['name']}...")
    print(f"{'='*60}")
    
    chapters = []
    total_ayahs_processed = 0
    
    for surah_num in range(1, 115):
        ayah_count = SURAH_AYAH_COUNT[surah_num]
        if ayah_count == 0:
            continue
        
        surah_name = SURAH_NAMES[surah_num] if surah_num < len(SURAH_NAMES) else f'سورة {surah_num}'
        print(f"\n  {surah_num}. {surah_name} ({ayah_count} ayahs)")
        
        ayah_texts = download_surah(api_tafsir_id, surah_num, ayah_count)
        
        if ayah_texts:
            combined_text = build_surah_text(ayah_texts, ayah_count)
            sections = [{'title': '', 'text': combined_text}]
        else:
            sections = []
        
        chapters.append({
            'title': f'{surah_num}. {surah_name}',
            'sections': sections,
        })
        total_ayahs_processed += len(ayah_texts)
        print(f"    Got {len(ayah_texts)}/{ayah_count} ayahs")
    
    # Build book content
    book_content = {
        'id': book_info['id'],
        'title': book_info['name'],
        'chapters': chapters,
    }
    
    out_path = os.path.join(out_dir, f'{book_info["slug"]}.json')
    with open(out_path, 'w', encoding='utf-8') as f:
        json.dump(book_content, f, ensure_ascii=False, indent=1)
    
    file_size = os.path.getsize(out_path) / (1024 * 1024)
    print(f"\n✅ {book_info['name']}: {len(chapters)} surahs, {total_ayahs_processed} ayahs, {file_size:.1f} MB")


def main():
    out_dir = '/tmp/tafsir_downloads'
    os.makedirs(out_dir, exist_ok=True)
    
    for api_id, book_info in TAFSIRS.items():
        process_tafsir(api_id, book_info, out_dir)
    
    print(f"\n{'='*60}")
    print("All tafsirs downloaded!")
    for fn in os.listdir(out_dir):
        size = os.path.getsize(os.path.join(out_dir, fn)) / (1024 * 1024)
        print(f"  {fn}: {size:.1f} MB")

if __name__ == '__main__':
    main()
