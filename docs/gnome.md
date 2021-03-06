
```bash
apt-cache show gnome | grep Depends | cut -d: -f2- | tr -d ' ' | tr ',' "\n" | sort
                                                # list packages installed by the gnome meta-package
```

## Tracker

* [Tracker](https://github.com/GNOME/tracker) is a service persistently indexing user data to  provide a metadata database
* Indexable data is listed in [supported formats](https://wiki.gnome.org/Projects/Tracker/SupportedFormats) 

```bash
tracker-control -S                              # state
tracker-control -p                              # list of tracker process
tracker-control -r                              # shutdown and remove caches
ls -l ~/.local/share/tracker ~/.cache/tracker   # caches
rename 's/desktop/desktop.off/' /etc/xdg/autostart/tracker*.desktop
                                                # permanently disable tracker from autostart
```
