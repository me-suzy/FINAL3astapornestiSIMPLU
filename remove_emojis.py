# Script pentru a inlocui emoji-urile din SIMPLU.py
# Folosire: python remove_emojis.py

import re

# Dictionarul de inlocuiri emoji -> text
emoji_replacement = {
    '📁': '[DIR]',
    '📋': '[INFO]',
    '✅': '[OK]',
    '❌': '[EROARE]',
    '🚨': '[ATENTIE]',
    '🎯': '[TARGET]',
    '🗂️': '[FOLDER]',
    '🔧': '[SETUP]',
    '⚠': '[WARNING]',
    '🆕': '[NOU]',
    '📊': '[STATS]',
    '📂': '[DIR]',
    '📄': '[PDF]',
    '📑': '[DOC]',
    '📎': '[FILE]',
    '🌐': '[WEB]',
    '📝': '[EDIT]',
    '🔍': '[SEARCH]',
    '🔒': '[LOCK]',
    '🚀': '[START]',
    '⏳': '[WAIT]',
    '🪟': '[WINDOW]',
    '💾': '[SAVE]',
    '👁️': '[VIEW]',
    '🔄': '[RELOAD]',
    '⏭️': '[SKIP]',
    '🏷️': '[TAG]',
}

# Citeste fisierul
print("Citesc fisierul SIMPLU.py...")
with open('+FINAL 3 - asta pornesti SIMPLU.py', 'r', encoding='utf-8') as f:
    content = f.read()

# Inlocuieste fiecare emoji
print("Inlocuiesc emoji-urile...")
replaced_count = 0
for emoji, replacement in emoji_replacement.items():
    count = content.count(emoji)
    if count > 0:
        content = content.replace(emoji, replacement)
        replaced_count += count
        print(f"  {emoji} -> {replacement} ({count} aparitii)")

# Salveaza fisierul
print("Salvez fisierul modificat...")
with open('+FINAL 3 - asta pornesti SIMPLU.py', 'w', encoding='utf-8') as f:
    f.write(content)

print(f"\n[OK] Total {replaced_count} emoji-uri inlocuite cu succes!")
