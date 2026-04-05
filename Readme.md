# Rclone Backup & Cleanup Scripts

Dieses Repository enthält zwei Bash-Skripte zur automatisierten Datensicherung und Aufräumarbeiten mit `rclone`.

## 📦 Überblick

Die Lösung besteht aus:

* **`rclone-backup`** → synchronisiert Daten und erstellt versionierte Backups
* **`rclone-cleanup`** → löscht alte Backups basierend auf einem Zeitlimit
* **`.env`** → zentrale Konfigurationsdatei für beide Skripte

---

## ⚙️ Voraussetzungen

* Bash (`/bin/bash`)
* `rclone` installiert und konfiguriert
* Optional: `ntfy-send` für Benachrichtigungen

---

## 🔧 Konfiguration

Die Konfiguration erfolgt über die Datei `.env`.

### Beispiel `.env`

```bash
BACKUP_USER="backupadm"
USER_HOME="/home/${BACKUP_USER}"

STORAGE_BOX="hetzner-storage-box-1"

LOG_FILE="${USER_HOME}/logs/rclone-backup.log"

SRC="${USER_HOME}/backups/poseidon"
DEST="${STORAGE_BOX}:poseidon"
ARCHIVE="${STORAGE_BOX}:poseidon/archive"

AGE="30d"

NTFY="/usr/bin/ntfy-send"

TITLE_SYNC="RCLONE | $(hostname) | BACKUP SYNC"
TAGS_SYNC="backup,rclone"

TITLE_CLEANUP="RCLONE | $(hostname) | CLEANUP"
TAGS_CLEANUP="cleanup,rclone"
```

---

## 🔄 Backup-Skript (`rclone-backup`)

### Funktion

* Synchronisiert das Quellverzeichnis (`SRC`) nach `DEST/current`
* Verschiebt geänderte/gelöschte Dateien in ein Archiv (`ARCHIVE/<timestamp>`)
* Erstellt ein versioniertes Backup mit Zeitstempel

### Ablauf

1. Lädt `.env`
2. Startet Logging
3. Führt `rclone sync` aus
4. Prüft Exit-Code
5. Sendet Benachrichtigung
6. Schreibt Ergebnis ins Log

---

## 🧹 Cleanup-Skript (`rclone-cleanup`)

### Funktion

* Löscht alte Backups im Archiv-Verzeichnis
* Nutzt `--min-age`, um nur alte Daten zu entfernen

### Beispiel

```bash
rclone delete "$ARCHIVE" --min-age "$AGE"
```

---

## 🔔 Benachrichtigungen

Beide Skripte senden Statusmeldungen über `ntfy-send`:

* Erfolg → Priorität 3
* Fehler → Priorität 5

---

## 📝 Logging

Logs werden in folgende Datei geschrieben:

```
$LOG_FILE
```

Beispiel:

```
=== 2026-04-05 12:00:00 BACKUP SYNC JOB START ===
...
=== 2026-04-05 12:00:10 BACKUP SYNC JOB END (SUCCESS) ===
```

---

## ⏱️ Automatisierung (Cron)

Beispiel für `crontab`:

```bash
# Backup täglich um 2 Uhr
0 2 * * * /path/to/rclone-backup

# Cleanup täglich um 3 Uhr
0 3 * * * /path/to/rclone-cleanup
```

---

## 🔒 Sicherheit

* `.env` sollte **nicht ins Repository committed werden**
* Verwende stattdessen eine `.env.example`
* Achte auf Dateiberechtigungen:

```bash
chmod 600 .env
```

---

## ✅ Best Practices

* Verwende absolute Pfade
* Stelle sicher, dass `rclone` Remote korrekt konfiguriert ist
* Prüfe regelmäßig die Logs
* Teste Skripte manuell vor Einsatz in Cron

---

## 📁 Projektstruktur (Beispiel)

```
.
├── rclone-backup
├── rclone-cleanup
├── .env
├── .env.example
└── README.md
```

---

## 🚀 Erweiterungsmöglichkeiten

* Lockfile gegen parallele Ausführung
* Rotation/Begrenzung der Backup-Anzahl
* Monitoring/Alerting erweitern
* Separate Logfiles pro Job

---

## 📄 Lizenz

Optional – je nach Bedarf hinzufügen.
