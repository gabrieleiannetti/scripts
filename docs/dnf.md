## DNF 


Package manager for RPM based distributions → [DNF on GitHub](https://github.com/rpm-software-management/dnf)

| *File*                    | *Description*      |
|---------------------------|--------------------|
| `/etc/dnf/dnf.conf`       | Main configuration | 
| `/etc/yum.repos.d/*.repo` | Repository lists   |
| `/var/cache/dnf`          | Cache files        |

→ [Configuration Reference](http://dnf.readthedocs.org/en/latest/conf_ref.html)

List the configured repositories:

    » dnf repolist -v all


### Packages

Packages use following name specification:

    name
    name.arch
    name-[epoch:]version
    name-[epoch:]version-release
    name-[epoch:]version-release.arch

Typical commands to work with packages:

    » dnf search <package>
    » dnf list <package
    » dnf list installed
    » dnf list recent
    » dnf info <package>
    » dnf install <package>
    » dnf install <rpm> 
    » dnf upgrade <package> 
    » dnf downgrade <package>
    » dnf erase <package>

### Transaction History

    » dnf history list 
    » dnf history info <id>
    » dnf history info <sid>[..<eid>]

Actions: (D)owngrade, (E)rase, (I)nstall, (O)bsoleting, (R)einstall, (U)pdate

Revert a transaction (uninstall, downgrade), redo a transaction as root

    » dnf history undo <id>
    » dnf history redo <id>

### Upgrades

Check for updates and install available packages

    » dnf check-update
    » dnf upgrade

→ [DNF Automatic](http://dnf.readthedocs.org/en/latest/automatic.html)

    » dnf install -yq dnf-automatic
    » grep apply_updates /etc/dnf/automatic.conf
    apply_updates = yes
    » systemctl enable dnf-automatic.timer && systemctl start dnf-automatic.timer
    » systemctl list-timers '*dnf-automatic*'

Clean up:

    » dnf list autoremove
    » dnf autoremove -y
    » dnf clean packages
    » dnf clean expire-cache
