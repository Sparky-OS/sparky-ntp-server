# Sparky NTP Server

This package provides its own NTP configuration for Sparky Server.
It synchronizes the system clock with the official Brazilian time
servers maintained by the government (ntp.br).

The provided `etc/sparky-ntp.conf` is copied to `/etc/sparky-ntp.conf`
by the installation script. You can further customize this file to add
additional peers or adjust restrictions as needed.

Copyright (C) 2019-2020 Daniel Campos Ramos & Paweł Pijanowski

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

## Dependencies

* `ntp` package

## Install

Run as root (or with `sudo`):

```
./install.sh
```

## Uninstall

Run as root (or with `sudo`):

```
./install.sh uninstall
```
