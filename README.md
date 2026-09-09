# Z-Box Lua Scripts

Community-developed Lua scripts and utilities for the Zooz Z-Box Hub.

These scripts are intended to make configuration, maintenance, and automation tasks easier on the Z-Box platform. Scripts in this repository may use the Z-Box/FIBARO HC3 local API and should be reviewed before use.  Scripts are a combination of hand coding and AI assistance, so please beware and use at your own risk.

## Scripts

### Enable Unavailable Notifications

`notifications/enable-device-notifications.lua`

Bulk-configures the **Unavailable** notification for applicable devices on a Zooz Z-Box Hub.

The script:

- Automatically identifies the administrator user
- Enumerates visible devices on the hub
- Determines which devices support the Unavailable notification
- Enables the Unavailable notification
- Sets the notification interval to **Once**
- Enables **E-mail** and **Push/Notification**
- Assigns the notification to the administrator
- Skips devices that do not support Unavailable notifications
- Skips devices that are already configured correctly
- Provides a summary of changes and errors

### Safe Testing / Dry Run

The published script defaults to:

`DRY_RUN = true`

In Dry Run mode, the script examines the current configuration and reports what it would change without writing changes to the hub.

Review the output before changing:

`DRY_RUN = false`

and running the script again.

## Installation

1. Log in to your Z-Box Hub.
2. Open **Settings → Scenes**.
3. Create a new Lua scene.
4. Copy the desired script into the Lua editor.
5. Leave `DRY_RUN = true` for the first run.
6. Run the scene and review the debug output.
7. If the results are correct, change `DRY_RUN` to `false` and run it again.
8. Verify the resulting configuration in the Z-Box interface.

## Compatibility

These scripts are developed and tested against the Zooz Z-Box Hub. Because Z-Box firmware and its underlying APIs may change, scripts may require modification for future firmware releases.

**Tested on:**

- Zooz Z-Box Hub
- Firmware: `5.200.13`
- Last tested: September 9, 2026

If you successfully test a script on another firmware version, please feel free to report your results.

## Disclaimer

These scripts are provided for informational and educational purposes and are provided **"AS IS"**, without warranty of any kind.

Scripts in this repository may make configuration changes to your Z-Box Hub. Review and understand a script before running it and back up your hub configuration before making bulk changes.

Use these scripts at your own risk. The author and SaveThePanel.com are not responsible for data loss, configuration changes, device behavior, notification charges, or other damages resulting from their use.

This is an independent community project and is not affiliated with, endorsed by, or supported by Zooz or FIBARO.

## Contributions

Bug reports, firmware compatibility reports, improvements, and additional Z-Box Lua scripts are welcome.

## License

Released under the MIT License.
