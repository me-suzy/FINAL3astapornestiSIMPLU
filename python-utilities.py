# Python Utilities - Scripturi pentru Debugging și Analiză
# Data: 2025-11-24

"""
Colecție de scripturi Python utile pentru:
- Analiza log-uri
- Procesare text și encoding
- Statistici și raportare
"""

## 1. ANALIZA LOG-URI
## ===================

def analyze_log(log_file='chrome-headless-log.txt'):
    """Analizează fișierul log și afișează statistici"""
    import re
    
    try:
        with open(log_file, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        
        # Statistici generale
        total_lines = content.count('\n')
        
        # Upload-uri
        uploads_success = content.count('Upload LANSAT cu succes')
        uploads_failed = content.count('Nu am gasit input-ul pentru fisiere')
        tabs_created = content.count('Tab upload #')
        
        # Erori
        errors = re.findall(r'\[EROARE\].*', content)
        warnings = re.findall(r'\[WARNING\].*', content)
        
        # Afișare
        print(f"╔═══════════════════════════════════════════╗")
        print(f"║     ANALIZA LOG: {log_file}     ║")
        print(f"╚═══════════════════════════════════════════╝")
        print(f"")
        print(f"📊 STATISTICI GENERALE:")
        print(f"  - Total linii: {total_lines:,}")
        print(f"  - Dimensiune fișier: {len(content):,} bytes")
        print(f"")
        print(f"📤 UPLOAD-URI:")
        print(f"  - Reușite: {uploads_success}")
        print(f"  - Eșuate: {uploads_failed}")
        print(f"  - Tab-uri create: {tabs_created}")
        print(f"  - Rata de succes: {(uploads_success/(uploads_success+uploads_failed)*100 if (uploads_success+uploads_failed) > 0 else 0):.1f}%")
        print(f"")
        print(f"⚠️ PROBLEME:")
        print(f"  - Total erori: {len(errors)}")
        print(f"  - Total warnings: {len(warnings)}")
        
        # Ultimele erori
        if errors:
            print(f"")
            print(f"🔴 ULTIMELE 5 ERORI:")
            for err in errors[-5:]:
                print(f"  - {err[:80]}...")
        
        return {
            'total_lines': total_lines,
            'uploads_success': uploads_success,
            'uploads_failed': uploads_failed,
            'tabs_created': tabs_created,
            'errors': len(errors),
            'warnings': len(warnings)
        }
        
    except FileNotFoundError:
        print(f"[EROARE] Fișierul {log_file} nu există!")
        return None


## 2. ÎNLOCUIRE EMOJI-URI
## =======================

def remove_emojis_from_file(file_path, backup=True):
    """
    Înlocuiește toate emoji-urile dintr-un fișier cu echivalente ASCII
    
    Args:
        file_path: Calea către fișier
        backup: Dacă True, creează backup înainte de modificare
    """
    import shutil
    
    # Mapare emoji -> ASCII
    emoji_map = {
        '📁': '[DIR]', '📋': '[INFO]', '✅': '[OK]', '❌': '[EROARE]',
        '🚨': '[ATENTIE]', '🎯': '[TARGET]', '🗂️': '[FOLDER]',
        '🔧': '[SETUP]', '⚠': '[WARNING]', '🆕': '[NOU]',
        '📊': '[STATS]', '📂': '[DIR]', '📄': '[PDF]', '📑': '[DOC]',
        '📎': '[FILE]', '🌐': '[WEB]', '📝': '[EDIT]', '🔍': '[SEARCH]',
        '🔒': '[LOCK]', '🚀': '[START]', '⏳': '[WAIT]', '🪟': '[WINDOW]',
        '💾': '[SAVE]', '👁️': '[VIEW]', '🔄': '[RELOAD]', '⏭️': '[SKIP]',
        '🏷️': '[TAG]', '🚫': '[STOP]',
    }
    
    # Backup
    if backup:
        backup_path = file_path + '.backup'
        shutil.copy2(file_path, backup_path)
        print(f"[OK] Backup creat: {backup_path}")
    
    # Citește
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Înlocuiește
    replaced_count = 0
    for emoji, replacement in emoji_map.items():
        count = content.count(emoji)
        if count > 0:
            content = content.replace(emoji, replacement)
            replaced_count += count
            print(f"  {emoji} -> {replacement} ({count} apariții)")
    
    # Salvează
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"\n[OK] Total {replaced_count} emoji-uri înlocuite!")
    return replaced_count


## 3. VERIFICARE ENCODING
## =======================

def check_file_encoding(file_path):
    """Detectează encoding-ul unui fișier"""
    import chardet
    
    with open(file_path, 'rb') as f:
        raw_data = f.read()
    
    result = chardet.detect(raw_data)
    
    print(f"Fișier: {file_path}")
    print(f"Encoding detectat: {result['encoding']}")
    print(f"Încredere: {result['confidence']*100:.1f}%")
    
    return result


## 4. STATISTICI FIȘIERE
## ======================

def file_stats(directory='.', extensions=['.py', '.bat', '.md']):
    """Afișează statistici despre fișiere dintr-un director"""
    import os
    from pathlib import Path
    
    stats = {}
    total_size = 0
    
    for ext in extensions:
        files = list(Path(directory).glob(f'*{ext}'))
        count = len(files)
        size = sum(f.stat().st_size for f in files)
        stats[ext] = {'count': count, 'size': size}
        total_size += size
    
    print(f"📊 STATISTICI FIȘIERE în {directory}:")
    print(f"")
    for ext, data in stats.items():
        print(f"{ext}:")
        print(f"  - Număr: {data['count']}")
        print(f"  - Dimensiune totală: {data['size']:,} bytes ({data['size']/1024:.1f} KB)")
    
    print(f"")
    print(f"TOTAL: {total_size:,} bytes ({total_size/1024:.1f} KB)")
    
    return stats


## 5. EXTRAGERE PATTERN-URI DIN LOG
## ==================================

def extract_patterns(log_file, patterns):
    """
    Extrage și numără pattern-uri specifice din log
    
    Args:
        log_file: Calea către fișier log
        patterns: Dict cu numele pattern-ului și regex-ul
    
    Returns:
        Dict cu rezultate
    """
    import re
    
    with open(log_file, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    results = {}
    
    for name, pattern in patterns.items():
        matches = re.findall(pattern, content)
        results[name] = {
            'count': len(matches),
            'matches': matches[:10]  # Primele 10
        }
    
    # Afișare
    print(f"🔍 PATTERN-URI GĂSITE în {log_file}:")
    print(f"")
    for name, data in results.items():
        print(f"{name}:")
        print(f"  - Total: {data['count']}")
        if data['matches']:
            print(f"  - Exemple:")
            for match in data['matches'][:3]:
                print(f"    • {match[:60]}...")
        print(f"")
    
    return results


## EXEMPLE DE UTILIZARE
## =====================

if __name__ == "__main__":
    print("=" * 50)
    print("  PYTHON UTILITIES - EXEMPLE")
    print("=" * 50)
    print()
    
    # 1. Analiza log
    print("1. Analizez log-ul...")
    analyze_log('chrome-headless-log.txt')
    
    print("\n" + "=" * 50 + "\n")
    
    # 2. Statistici fișiere
    print("2. Statistici fișiere...")
    file_stats('.', ['.py', '.bat', '.md', '.txt'])
    
    print("\n" + "=" * 50 + "\n")
    
    # 3. Pattern-uri custom
    print("3. Căutare pattern-uri...")
    patterns = {
        'Upload Success': r'Upload LANSAT cu succes',
        'Erori Input': r'Nu am gasit input.*',
        'Tab-uri Create': r'Tab upload #\d+',
    }
    extract_patterns('chrome-headless-log.txt', patterns)
