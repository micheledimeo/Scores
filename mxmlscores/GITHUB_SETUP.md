# GitHub Repository Setup Guide

Questa guida ti aiuta a pubblicare l'app mxmlscores su GitHub e prepararla per l'App Store di Nextcloud.

## 1. Crea il Repository su GitHub

1. Vai su https://github.com/new
2. Compila i campi:
   - **Repository name:** `mxmlscores` (o `nextcloud-mxmlscores`)
   - **Description:** "View and play MusicXML scores in Nextcloud"
   - **Visibility:** Public (obbligatorio per App Store Nextcloud)
   - **DON'T** initialize with README (lo abbiamo già)
3. Click su "Create repository"

## 2. Collega il Repository Locale

Dopo aver creato il repository su GitHub, GitHub ti mostrerà le istruzioni. Usa questi comandi:

```bash
cd /Users/Michele/Sites/mxmlscores

# Verifica che .gitignore sia corretto
cat .gitignore

# Aggiungi i file al repository
git add .

# Crea il primo commit
git commit -m "Initial commit - MusicXML Scores Viewer for Nextcloud v0.9.2"

# Aggiungi il remote (SOSTITUISCI 'YOUR-USERNAME' con il tuo username GitHub)
git remote add origin https://github.com/YOUR-USERNAME/mxmlscores.git

# Rinomina il branch principale (se necessario)
git branch -M main

# Push al repository
git push -u origin main
```

## 3. Configurazione Repository GitHub

### A. Aggiungi Topics
1. Vai sul repository GitHub
2. Click su "⚙️ Settings" → In alto a destra click "Add topics"
3. Aggiungi: `nextcloud`, `musicxml`, `music-notation`, `nextcloud-app`, `sheet-music`

### B. Crea cartella Screenshots
```bash
cd /Users/Michele/Sites/mxmlscores
mkdir -p screenshots
```

Poi:
- Scatta 2-3 screenshot dell'app in uso
- Salvali in `screenshots/` con nomi descrittivi:
  - `screenshots/player-view.png` (vista principale)
  - `screenshots/mixer-controls.png` (mixer strumenti)
  - `screenshots/search-feature.png` (ricerca)
- Commit e push:
  ```bash
  git add screenshots/
  git commit -m "Add application screenshots"
  git push
  ```

### C. Aggiorna il README
Assicurati che il README contenga:
- Screenshots (già presente)
- Istruzioni di installazione (già presente)
- Link al repository GitHub (da aggiungere dopo la creazione)

## 4. Aggiorna info.xml

**IMPORTANTE:** Dopo aver creato il repository GitHub, devi aggiornare `appinfo/info.xml`.

Esegui questo script di aggiornamento (verrà creato automaticamente):

```bash
./update-repo-urls.sh YOUR-USERNAME
```

Oppure modifica manualmente:
```xml
<website>https://github.com/YOUR-USERNAME/mxmlscores</website>
<bugs>https://github.com/YOUR-USERNAME/mxmlscores/issues</bugs>
<repository type="git">https://github.com/YOUR-USERNAME/mxmlscores.git</repository>
<screenshot>https://raw.githubusercontent.com/YOUR-USERNAME/mxmlscores/main/screenshots/player-view.png</screenshot>
<author mail="your-email@example.com">Michele</author>
```

Poi commit e push:
```bash
git add appinfo/info.xml
git commit -m "Update repository URLs and author email"
git push
```

## 5. Crea il Primo Release

```bash
# Assicurati che tutto sia committato
git status

# Crea un tag per la versione
git tag -a v0.9.2 -m "Release v0.9.2 - Initial public release"

# Push del tag
git push origin v0.9.2
```

Sul sito GitHub:
1. Vai su "Releases" → "Create a new release"
2. Scegli il tag `v0.9.2`
3. Titolo: "v0.9.2 - Initial Release"
4. Descrizione:
   ```markdown
   ## Features
   - 🎼 Display MusicXML and .mxl files
   - ▶️ Playback with tempo/volume controls
   - 🎚️ Multi-instrument mixer
   - 🔍 Real-time search
   - ⌨️ Keyboard shortcuts

   ## Installation
   See [INSTALL.md](INSTALL.md) for installation instructions.
   ```
5. Allega il file `dist/mxmlscores-0.9.2.tar.gz` (generato con `./package-app.sh`)
6. Click "Publish release"

## 6. Prossimi Passi per App Store

Dopo aver completato questi passi:

1. ✅ Repository pubblico su GitHub
2. ✅ Screenshots disponibili
3. ✅ info.xml aggiornato
4. ✅ Release v0.9.2 pubblicato

Puoi procedere con:
- Firma dell'app (vedi `SIGNING_GUIDE.md` - da creare)
- Registrazione su https://apps.nextcloud.com/developer/register
- Submit dell'app per revisione

## Checklist Rapida

- [ ] Repository GitHub creato (pubblico)
- [ ] Repository locale collegato e pushato
- [ ] Screenshots aggiunti alla cartella `screenshots/`
- [ ] info.xml aggiornato con URL corretti e email
- [ ] Tag v0.9.2 creato
- [ ] Release v0.9.2 pubblicato con tar.gz allegato
- [ ] Topics aggiunti al repository
- [ ] README verificato e aggiornato

---

**Note:**
- Sostituisci sempre `YOUR-USERNAME` con il tuo vero username GitHub
- Usa una email valida in info.xml (sarà visibile pubblicamente)
