# Workflow di Sviluppo e Deploy - MusicXML Scores

## Panoramica

Questo progetto segue un flusso di lavoro **locale → produzione → test online**:

1. **Sviluppo locale** in `/Users/Michele/Sites/mxmlscores`
2. **Deploy su produzione** via SSH su `cloud.ottoniascoppio.org`
3. **Test automatici online** da `/.mxmlscores-testsprite`

---

## Comandi Principali

### Sviluppo Locale
```bash
npm run dev          # Avvia server di sviluppo
npm run build        # Build di produzione
npm run lint         # Controlla codice
npm run lint:fix     # Fix automatico problemi
```

### Backup
```bash
./backup.sh          # Crea backup con timestamp
```
- Salva in `backups/mxmlscores_backup_YYYYMMDD_HHMMSS.tar.gz`
- Mantiene automaticamente ultimi 30 backup
- Usa prima di modifiche significative

### Deploy
```bash
./deploy-production.sh     # Solo deploy
./deploy-and-test.sh       # Deploy + test automatici
```

### Test Online
```bash
cd ../.mxmlscores-testsprite
npm run test:online              # Tutti i test
npm run test:online:simple       # Solo test semplici (7 test veloci)
npx playwright show-report       # Visualizza report HTML
```

---

## Workflow Completo (Modifiche Significative)

### 1. Backup Pre-Modifica
```bash
cd /Users/Michele/Sites/mxmlscores
./backup.sh
```

### 2. Sviluppo e Test Locale
```bash
npm run dev
# Apri http://localhost:5173/
# Testa le modifiche
```

### 3. Build
```bash
npm run build
# Verifica che non ci siano errori
```

### 4. Deploy + Test Automatico
```bash
./deploy-and-test.sh
```

Questo script:
- Builda l'app
- Fa deploy su produzione
- Attende 15 secondi
- Esegue automaticamente i test online
- Mostra riepilogo risultati

---

## Workflow Rapido (Modifiche Minori)

Per piccole modifiche (CSS, typo, ecc.):

```bash
npm run build && ./deploy-production.sh
```

Poi verifica manualmente:
- https://cloud.ottoniascoppio.org/index.php/apps/mxmlscores/

---

## Struttura File

```
mxmlscores/
├── src/                        # Sorgenti Vue.js
│   ├── components/             # Componenti Vue
│   └── utils/                  # Utilities JavaScript
├── js/                         # Build output JavaScript
├── css/                        # Build output CSS
├── appinfo/                    # Metadati app Nextcloud
├── templates/                  # Template PHP
├── lib/                        # Controller PHP
├── backups/                    # Backup automatici (git-ignored)
├── backup.sh                   # Script backup
├── deploy-production.sh        # Script deploy
├── deploy-and-test.sh          # Script deploy + test
├── DEPLOY_CHECKLIST.md         # Checklist completa
└── WORKFLOW.md                 # Questo file

../.mxmlscores-testsprite/      # Repository test Playwright
├── tests/                      # Test E2E
│   ├── app.spec.ts            # 12 test - Suite principale
│   ├── online-simple.spec.ts  # 7 test - Test rapidi
│   ├── mxmlscores.spec.js     # 4 test - Smoke tests
│   └── sidebar-and-mixer.spec.ts  # 11 test - Test avanzati
├── playwright.config.online.ts # Config test online
└── .env                        # Credenziali Nextcloud
```

---

## Test Status Attuale

### ✅ Funzionanti Online (24/34 test - 71%)
- `app.spec.ts`: 12/12 ✅
- `online-simple.spec.ts`: 7/7 ✅
- `mxmlscores.spec.js`: 4/4 ✅

### ⚠️ Parzialmente Funzionanti (10/34 test)
- `sidebar-and-mixer.spec.ts`: 1/11 (comportamento sidebar diverso in produzione)

---

## Troubleshooting

### Build Fallisce
```bash
# Pulisci cache
rm -rf node_modules
npm install
npm run build
```

### Deploy Fallisce
```bash
# Verifica connessione SSH
ssh ottoniascoppio "echo OK"

# Verifica permessi remoti
ssh ottoniascoppio "ls -la /home/ottoniascoppio/html/apps/mxmlscores/"
```

### Test Falliscono
```bash
# Verifica app online
curl -I https://cloud.ottoniascoppio.org/index.php/apps/mxmlscores/

# Rigenera auth
cd ../.mxmlscores-testsprite
rm -rf playwright/.auth/
npx playwright test tests/auth.setup.ts --config=playwright.config.online.ts
```

### Rollback Necessario
```bash
# 1. Trova ultimo backup funzionante
ls -lt backups/

# 2. Estrai backup
tar -xzf backups/mxmlscores_backup_20251103_120000.tar.gz

# 3. Rideploy
./deploy-production.sh
```

---

## Best Practices

### ✅ Fare Sempre
- Backup prima di modifiche significative
- Test locale con `npm run dev`
- Verifica build senza errori
- Test online dopo deploy
- Commit git delle modifiche importanti

### ❌ Evitare
- Deploy senza build locale
- Modifiche dirette sul server
- Saltare i test dopo modifiche critiche
- Eliminare vecchi backup manualmente

---

## Configurazione Iniziale Git (Opzionale)

Per tracciare modifiche con git:

```bash
cd /Users/Michele/Sites/mxmlscores

# Inizializza repository
git init
git add .
git commit -m "Initial commit - v2.2.6"

# Crea branch per feature
git checkout -b feature/nome-feature

# Dopo modifiche
git add .
git commit -m "Descrizione modifiche"

# Merge in main
git checkout main
git merge feature/nome-feature
```

---

## URLs Utili

- **App Produzione**: https://cloud.ottoniascoppio.org/index.php/apps/mxmlscores/
- **Test Sample**: https://cloud.ottoniascoppio.org/index.php/apps/mxmlscores/?testSample=1
- **Server SSH**: `ssh ottoniascoppio`
- **Path Remoto**: `/home/ottoniascoppio/html/apps/mxmlscores/`

---

## Supporto

Per problemi o domande:
1. Controlla [DEPLOY_CHECKLIST.md](DEPLOY_CHECKLIST.md)
2. Verifica sezione Troubleshooting sopra
3. Controlla log browser console
4. Verifica log Playwright test

---

**Versione**: 2.2.6
**Ultimo aggiornamento**: 2025-11-03
