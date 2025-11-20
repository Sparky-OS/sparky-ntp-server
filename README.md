# Sparky NTP Server

This package provides a custom NTP (Network Time Protocol) configuration for Sparky Server. During installation, it automatically detects your system's timezone and configures an appropriate set of public NTP servers.

For Brazilian timezones, it defaults to the official government servers (`ntp.br`), while all other timezones use their respective `pool.ntp.org` hosts.

The configuration is generated from the `etc/sparky-ntp.conf` template and saved to `/etc/sparky-ntp.conf`. If the automatically chosen servers are not ideal, you can manually edit this file to point to your preferred servers.

This program is free software distributed under the GNU General Public License v3.

## Dependencies

- **`ntp` package**: This package must be installed for the server to function.

## How It Works

The `install.sh` script handles the setup process by:
1.  **Detecting the timezone**: It determines the system's country code.
2.  **Generating server list**: Based on the country code, it selects either the Brazilian NTP servers or a generic NTP pool.
3.  **Creating the config file**: It populates the template with the server list and creates `/etc/sparky-ntp.conf`.

## Installation

Run the installation script as root or with `sudo`:

```bash
./install.sh
```

## Uninstallation

To remove the configuration, run the script with the `uninstall` argument:

```bash
./install.sh uninstall
```

## Manual Configuration

If you need to use specific NTP servers, you can edit `/etc/sparky-ntp.conf` after installation. The file follows the standard `ntp.conf` format.

## Multi-language Support

The installation script is available in multiple languages and will automatically detect your system's language. If your language is not supported, it will default to English.

To add a new translation:
1.  Copy `locale/en.sh` to a new file named `locale/<language_code>.sh` (e.g., `locale/ja.sh` for Japanese).
2.  Translate the strings in the new file.
3.  The script will automatically detect and use the new translation.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request with your suggested changes.

## License

This project is licensed under the GNU General Public License, version 3. See the [LICENSE](LICENSE) file for more details.
