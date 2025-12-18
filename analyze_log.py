import re

# Citeste log-ul
with open('chrome-headless-log.txt', 'r', encoding='utf-8', errors='ignore') as f:
    content = f.read()

# Numara upload-urile resite
uploads_success = content.count('Upload LANSAT cu succes')
uploads_failed = content.count('Nu am gasit input-ul pentru fisiere')
tabs_created = content.count('Tab upload #')

print(f"Upload-uri REUȘITE: {uploads_success}")
print(f"Upload-uri EȘUATE (input lipsă): {uploads_failed}")
print(f"Total tab-uri create: {tabs_created}")
print()

# Găsește ultimele 5 mesaje de eroare
errors = re.findall(r'\[EROARE\].*', content)
if errors:
    print(f"Ultimele 5 erori:")
    for err in errors[-5:]:
        print(f"  - {err[:100]}")
else:
    print("Nu am găsit erori!")
