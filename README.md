# uk_policebadge

UK-oriented fork of `stevo_policebadge`, adapted for a warrant-card style display and aimed at QBCore while still keeping `stevo_lib` as the framework bridge.

## Dependencies

- `ox_lib`
- `oxmysql`
- `stevo_lib`

## Default QBCore metadata keys

- Badge number: `badge`, `badge_number`, `badgeNumber`, `collar`
- Callsign: `callsign`, `callSign`

Change these in [config.lua](C:/Users/bobman/fivem-qbcore-local/data/resources/[local]/uk_policebadge/config.lua) if your server uses different metadata.

## QBCore install notes

This repository contains the `uk_policebadge` resource itself.

These two QBCore integration steps live outside this repo and must be applied on the target server:

1. Add the item in `qb-core/shared/items.lua`
```lua
uk_policebadge = {
    name = 'uk_policebadge',
    label = 'Warrant Card',
    weight = 0,
    type = 'item',
    image = 'uk_policebadge.png',
    unique = true,
    useable = true,
    shouldClose = false,
    description = 'Official police warrant card for identifying yourself on duty'
},
```

2. Add an inventory icon named `uk_policebadge.png` to `qb-inventory/html/images`

The runtime badge artwork used by this resource is stored at `resource/web/img/badge.png`.

## Preview

Open `resource/web/preview.html` in a browser to check text placement against `resource/web/img/badge.png`.

## Notes

- The resource item name defaults to `uk_policebadge`.
- Photo records are stored in the `uk_policebadge_photos` table by default.
- Department name and warrant-card wording are config-driven rather than locale-driven.
