if not lib.checkDependency('stevo_lib', '1.6.7') then
    error('stevo_policebadge requires stevo_lib 1.6.7 or newer.')
end

lib.locale()

local stevo_lib = exports['stevo_lib']:import()
local config = lib.require('config')

local QBCore = nil
if GetResourceState('qb-core') == 'started' then
    QBCore = exports['qb-core']:GetCoreObject()
end

local function sanitizeTableName(name)
    local cleaned = tostring(name or 'stevo_badge_photos'):gsub('[^%w_]', '')
    if cleaned == '' then
        cleaned = 'stevo_badge_photos'
    end
    return cleaned
end

local PHOTO_TABLE = sanitizeTableName(config.photo_table_name)

local function normalizeText(value, maxLength)
    if type(value) ~= 'string' then
        return ''
    end

    local text = value:gsub('^%s*(.-)%s*$', '%1')
    if maxLength and #text > maxLength then
        text = text:sub(1, maxLength)
    end
    return text
end

local function getPlayerPhoto(identifier)
    return MySQL.single.await(('SELECT `image` FROM `%s` WHERE `identifier` = ? LIMIT 1'):format(PHOTO_TABLE), {
        identifier
    })
end

local function isPhotoUrlAllowed(url)
    local photo = normalizeText(url, config.photo_url_max_length or 500)
    if photo == '' then
        return false
    end

    local lower = photo:lower()
    return lower:match('^https?://') ~= nil
end

local function getQbPlayer(source)
    if not QBCore or not QBCore.Functions or not QBCore.Functions.GetPlayer then
        return nil
    end

    return QBCore.Functions.GetPlayer(source)
end

local function readMetadataValue(metadata, keys)
    if type(metadata) ~= 'table' or type(keys) ~= 'table' then
        return ''
    end

    for i = 1, #keys do
        local value = metadata[keys[i]]
        if value ~= nil and tostring(value) ~= '' then
            return tostring(value)
        end
    end

    return ''
end

local function getQbBadgeFields(source)
    if not config.qbcore or config.qbcore.enabled == false then
        return '', ''
    end

    local player = getQbPlayer(source)
    if not player or not player.PlayerData then
        return '', ''
    end

    local metadata = player.PlayerData.metadata or {}
    local badgeNumber = readMetadataValue(metadata, config.qbcore.badge_number_keys or {})
    local callsign = readMetadataValue(metadata, config.qbcore.callsign_keys or {})

    return badgeNumber, callsign
end

lib.callback.register('stevo_policebadge:retrieveInfo', function(source)
    local badgeData = {}
    local identifier = stevo_lib.GetIdentifier(source)
    local job = stevo_lib.GetPlayerJobInfo(source) or {}
    local photoRecord = getPlayerPhoto(identifier)
    local badgeNumber, callsign = getQbBadgeFields(source)

    badgeData.department = config.department_name or 'Police'
    badgeData.cardTitle = config.card_title or 'Warrant Card'
    badgeData.cardSubtitle = config.card_subtitle or ''
    badgeData.rank = job.gradeName or job.label or 'Unknown'
    badgeData.name = stevo_lib.GetName(source)
    badgeData.photo = photoRecord and photoRecord.image or nil
    badgeData.badgeNumber = badgeNumber
    badgeData.callsign = callsign

    return badgeData
end)

lib.callback.register('stevo_policebadge:setBadgePhoto', function(source, photo)
    if not isPhotoUrlAllowed(photo) then
        return false, 'invalid_photo'
    end

    local identifier = stevo_lib.GetIdentifier(source)
    local cleanedPhoto = normalizeText(photo, config.photo_url_max_length or 500)

    local id = MySQL.insert.await(
        ('INSERT INTO `%s` (`identifier`, `image`) VALUES (?, ?) ON DUPLICATE KEY UPDATE `image` = VALUES(`image`)'):format(PHOTO_TABLE),
        { identifier, cleanedPhoto }
    )

    return id ~= nil, id
end)

RegisterNetEvent('stevo_policebadge:showbadge', function(data, players)
    for i = 1, #players do
        TriggerClientEvent('stevo_policebadge:displaybadge', players[i], data)
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= cache.resource then
        return
    end

    MySQL.query(([[CREATE TABLE IF NOT EXISTS `%s` (
        `id` INT NOT NULL AUTO_INCREMENT,
        `identifier` VARCHAR(80) NOT NULL,
        `image` LONGTEXT NOT NULL,
        PRIMARY KEY (`id`),
        UNIQUE KEY `identifier_unique` (`identifier`)
    )]]):format(PHOTO_TABLE))

    stevo_lib.RegisterUsableItem(config.badge_item_name, function(source)
        TriggerClientEvent('stevo_policebadge:use', source)
    end)
end)
