Bona pregunta. Per a un avís recordatori cada 5 minuts a GNU/Linux tens diverses opcions. Te les ordeno de la més recomanable a la més senzilla:

## 1. Timer de systemd a nivell d'usuari (la més robusta) ⭐

És l'opció moderna i recomanada. Sobreviu a reinicis, té logs (`journalctl`) i gestiona bé l'entorn.

Crees dos fitxers a `~/.config/systemd/user/`:

**`recordatori.service`**
```ini
[Unit]
Description=Avís recordatori

[Service]
Type=oneshot
ExecStart=/usr/bin/notify-send "Recordatori" "Fes una pausa 👀"
```

**`recordatori.timer`**
```ini
[Unit]
Description=Recordatori cada 5 minuts

[Timer]
OnBootSec=1min
OnUnitActiveSec=5min

[Install]
WantedBy=timers.target
```

I l'actives:
```bash
systemctl --user daemon-reload
systemctl --user enable --now recordatori.timer
systemctl --user list-timers   # per verificar
```

> Per a notificacions gràfiques en sessions sense login persistent: `loginctl enable-linger $USER`.

## 2. Cron (la més clàssica i ràpida)

`crontab -e` i afegeixes:
```cron
*/5 * * * * DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus /usr/bin/notify-send "Recordatori" "Fes una pausa"
```
El truc amb cron és que cal exportar `DISPLAY` i `DBUS_SESSION_BUS_ADDRESS` perquè `notify-send` trobi l'escriptori; si no, no surt res.

## 3. Script amb bucle + sleep (la més simple)

```bash
#!/usr/bin/env bash
while true; do
    notify-send "Recordatori" "Fes una pausa 👀"
    sleep 300
done
```
Ràpid de muntar, però no sobreviu a reinicis ni si tanques la terminal (tret que el llancis amb `nohup`/`&` o com a servei).

---

## La meva recomanació

- **Recordatori personal d'escriptori que vols "i prou":** systemd user timer (opció 1) — és la que t'estalviarà problemes a llarg termini.
- **Prova ràpida o l'has de tenir en 30 segons:** cron (opció 2).

Per a l'avís en si pots combinar `notify-send` amb so (`paplay /usr/share/sounds/.../*.oga`) o, si vols una finestra modal, `zenity --warning` / `kdialog`.

¿Vols que et prepari els fitxers concrets en aquest repo (`Admin`) seguint l'estil dels teus scripts (`bk.sh`, etc.)? Si em dius quin mètode prefereixes i què ha de dir l'avís, te'l deixo a punt.