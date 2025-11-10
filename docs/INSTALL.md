# Istruzioni di Installazione - MusicXML Viewer

## 📋 Riepilogo

Hai creato con successo l'app **MusicXML Viewer** per Nextcloud 31. L'app è pronta per essere deployata sul server.

## 🎯 Stato Attuale

✅ **Completato in locale:**
- Struttura dell'app creata
- Controller PHP (PageController, ApiController)
- Componenti Vue.js (App.vue, MusicViewer.vue)
- Build completata con successo
- File compilati in `js/musicxmlviewer-main.js` e `css/main.css`

## 📁 Percorso Locale

L'app si trova in: `/Users/Michele/Sites/musicxmlviewer`

## 🚀 Deployment sul Server

### Opzione 1: Upload Manuale (Consigliato)

1. **Comprimi l'app** (escludi node_modules):
   ```bash
   cd /Users/Michele/Sites
   tar -czf musicxmlviewer.tar.gz musicxmlviewer \
     --exclude='node_modules' \
     --exclude='.git' \
     --exclude='*.log'
   ```

2. **Carica sul server**:
   ```bash
   scp musicxmlviewer.tar.gz michelemusatti@michelemusatti.it:~
   ```

3. **Sul server**, estrai l'app:
   ```bash
   cd /var/www/michelemusatti.it/html/apps/
   tar -xzf ~/musicxmlviewer.tar.gz
   chown -R www-data:www-data musicxmlviewer
   ```

4. **Abilita l'app**:
   ```bash
   cd /var/www/michelemusatti.it/html
   sudo -u www-data php occ app:enable musicxmlviewer
   ```

### Opzione 2: rsync (Più Veloce)

```bash
rsync -avz --exclude='node_modules' --exclude='.git' \
  /Users/Michele/Sites/musicxmlviewer/ \
  michelemusatti@michelemusatti.it:/var/www/michelemusatti.it/html/apps/musicxmlviewer/
```

Poi sul server:
```bash
cd /var/www/michelemusatti.it/html/apps
chown -R www-data:www-data musicxmlviewer
cd /var/www/michelemusatti.it/html
sudo -u www-data php occ app:enable musicxmlviewer
```

## 🔍 Verifica Installazione

1. **Controlla che l'app sia abilitata**:
   ```bash
   sudo -u www-data php occ app:list | grep musicxmlviewer
   ```

2. **Accedi a Nextcloud**:
   - URL: https://michelemusatti.it
   - Dovresti vedere "MusicXML Viewer" nel menu delle app

3. **Test funzionalità**:
   - Carica un file MusicXML nella tua cartella Nextcloud
   - Aprilo con MusicXML Viewer
   - Verifica che lo spartito venga visualizzato correttamente

## 📝 File Principali

```
musicxmlviewer/
├── appinfo/
│   ├── info.xml              # Metadati app
│   └── routes.php            # Rotte API
├── lib/
│   └── Controller/
│       ├── PageController.php    # Controller principale
│       └── ApiController.php     # API per file
├── js/
│   └── musicxmlviewer-main.js    # Frontend compilato (2.3MB)
├── css/
│   └── main.css              # Stili compilati (253KB)
├── templates/
│   └── main.php              # Template HTML
├── img/
│   └── app.svg               # Icona app
└── README.md                 # Documentazione
```

## 🛠️ Build in Locale (se necessario)

Se devi modificare il codice e ricompilare:

```bash
cd /Users/Michele/Sites/musicxmlviewer
npm install --legacy-peer-deps
npm run build
```

## ⚠️ Note Importanti

1. **Permessi**: Assicurati che www-data abbia i permessi corretti
2. **Cache**: Pulisci la cache del browser dopo l'installazione
3. **Node.js non necessario sul server**: I file sono già compilati

## 🐛 Troubleshooting

### L'app non appare nel menu
```bash
sudo -u www-data php occ app:enable musicxmlviewer
sudo -u www-data php occ maintenance:repair
```

### Errore 404 sui file JS/CSS
Verifica i permessi:
```bash
ls -la /var/www/michelemusatti.it/html/apps/musicxmlviewer/js/
ls -la /var/www/michelemusatti.it/html/apps/musicxmlviewer/css/
```

### I file MusicXML non vengono trovati
Controlla i log:
```bash
tail -f /var/www/michelemusatti.it/html/data/nextcloud.log
```

## 📚 Documentazione

- Vedi `README.md` per informazioni complete sull'app
- OpenSheetMusicDisplay: https://opensheetmusicdisplay.org/
- Nextcloud App Development: https://docs.nextcloud.com/

## ✨ Prossimi Passi

Dopo l'installazione, puoi:
1. Testare con diversi file MusicXML
2. Personalizzare l'icona dell'app
3. Aggiungere funzionalità di playback audio
4. Migliorare l'integrazione con Files

---

**Data creazione**: 19 Ottobre 2025
**Versione app**: 2.0.0
**Nextcloud target**: 28-31
