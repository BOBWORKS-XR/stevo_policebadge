return {
    badge_item_name = 'uk_policebadge',

    job_names = { 'police' },
    badge_show_time = 5000,
    badge_show_radius = 3.0,

    department_name = 'Epical City Police',
    card_title = 'Warrant Card',
    card_subtitle = 'Operational Identity Pass',

    set_image_command = 'setbadgephoto',

    photo_table_name = 'uk_policebadge_photos',
    photo_url_max_length = 500,

    progress = {
        label = 'Showing Warrant Card',
        anim = {
            dict = 'paper_1_rcm_alt1-8',
            clip = 'player_one_dual-8'
        },
        prop = {
            bone = 28422,
            model = 'prop_fib_badge',
            pos = vec3(0.0600, 0.0210, -0.0400),
            rot = vec3(-90.00, -180.00, 78.999)
        }
    },

    qbcore = {
        enabled = true,
        badge_number_keys = { 'badge', 'badge_number', 'badgeNumber', 'collar' },
        callsign_keys = { 'callsign', 'callSign' }
    }
}
