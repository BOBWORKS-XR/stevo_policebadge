# stevo_policebadge

UK-oriented fork of `stevo_policebadge`, adapted for a warrant-card style display and aimed at QBCore while still keeping `stevo_lib` as the framework bridge.

## Dependencies

- `ox_lib`
- `oxmysql`
- `stevo_lib`

## Default QBCore metadata keys

- Badge number: `badge`, `badge_number`, `badgeNumber`, `collar`
- Callsign: `callsign`, `callSign`

Change these in `config.lua` if your server uses different metadata.

## QBCore install notes

This repository is intended to be installed under the original resource name: `stevo_policebadge`.

These two QBCore integration steps live outside this repo and must be applied on the target server:

1. Add the item in `qb-core/shared/items.lua`
```lua
stevo_policebadge = {
    name = 'stevo_policebadge',
    label = 'Warrant Card',
    weight = 0,
    type = 'item',
    image = 'stevo_policebadge.png',
    unique = true,
    useable = true,
    shouldClose = false,
    description = 'Official police warrant card for identifying yourself on duty'
},
```

2. Add an inventory icon named `stevo_policebadge.png` to `qb-inventory/html/images`

   A ready-to-copy icon is included in this repo at `install/qb-inventory/stevo_policebadge.png`

The runtime badge artwork used by this resource is stored at `resource/web/img/badge.png`.

## Preview

Open `resource/web/preview.html` in a browser to check text placement against `resource/web/img/badge.png`.

## Notes

- The resource item name defaults to `stevo_policebadge`.
- Photo records are stored in the `stevo_badge_photos` table by default.
- Department name and warrant-card wording are config-driven rather than locale-driven.
