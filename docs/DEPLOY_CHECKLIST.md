# Deploy Checklist for MusicXML Scores

## Pre-Deploy (Modifiche Significative)

### 1. Backup
- [ ] Eseguire backup: `./backup.sh`
- [ ] Verificare che il backup sia stato creato in `backups/`

### 2. Test Locale
- [ ] Verificare che l'app funzioni in locale: `npm run dev`
- [ ] Testare le funzionalità modificate manualmente
- [ ] Verificare console browser per errori JavaScript

### 3. Build
- [ ] Eseguire build di produzione: `npm run build`
- [ ] Verificare che non ci siano errori di build
- [ ] Controllare dimensioni bundle in `js/` e `css/`

## Deploy

### 4. Deployment
- [ ] Eseguire deploy: `./deploy-production.sh`
- [ ] Verificare messaggio "Deployment completed successfully"
- [ ] Attendere 10-15 secondi per stabilizzazione

### 5. Test Online Automatici
- [ ] Eseguire test online: `cd ../.mxmlscores-testsprite && npm run test:online`
- [ ] Verificare risultati test (obiettivo: 24+ test passati su 34)
- [ ] Rivedere eventuali fallimenti

## Post-Deploy

### 6. Verifica Manuale
- [ ] Aprire https://cloud.ottoniascoppio.org/index.php/apps/mxmlscores/
- [ ] Verificare che l'app si carichi correttamente
- [ ] Testare funzionalità critiche:
  - [ ] Caricamento spartiti
  - [ ] Playback audio
  - [ ] Controlli (play/pause/stop)
  - [ ] Zoom
  - [ ] Mixer (se presente)
  - [ ] Navigazione misure

### 7. Test Sample Mode
- [ ] Aprire https://cloud.ottoniascoppio.org/index.php/apps/mxmlscores/?testSample=1
- [ ] Verificare caricamento automatico spartito di esempio
- [ ] Testare playback

### 8. Log e Monitoraggio
- [ ] Controllare console browser per errori
- [ ] Verificare Network tab per richieste fallite
- [ ] Controllare che non ci siano errori 404

## Rollback (Se Necessario)

### In caso di problemi critici:
1. Identificare ultimo backup funzionante in `backups/`
2. Estrarre backup: `tar -xzf backups/mxmlscores_backup_YYYYMMDD_HHMMSS.tar.gz`
3. Eseguire nuovamente deploy: `./deploy-production.sh`
4. Verificare ripristino funzionalità

## Note

- **Backup automatico**: Lo script `backup.sh` mantiene automaticamente gli ultimi 30 backup
- **Test automatizzati**: Usare `./deploy-and-test.sh` per workflow automatico completo
- **Modifiche minori**: Per modifiche minori (typo, CSS, ecc.) il backup può essere saltato
- **Modifiche significative**: Sempre fare backup prima di:
  - Modifiche a logica playback
  - Modifiche a gestione file
  - Aggiornamenti librerie major
  - Refactoring significativi

## Comandi Rapidi

```bash
# Workflow completo automatico
./deploy-and-test.sh

# Workflow manuale
./backup.sh                    # 1. Backup
npm run dev                    # 2. Test locale
npm run build                  # 3. Build
./deploy-production.sh         # 4. Deploy
cd ../.mxmlscores-testsprite && npm run test:online  # 5. Test

# Verifica rapida
curl -I https://cloud.ottoniascoppio.org/index.php/apps/mxmlscores/
```

## Contatti di Emergenza

- Server SSH: `ottoniascoppio.org`
- Path remoto: `/home/ottoniascoppio/html/apps/mxmlscores/`
- Documentazione: https://cloud.ottoniascoppio.org/

---

**Ultima modifica**: 2025-11-03
**Versione corrente**: 2.2.6
