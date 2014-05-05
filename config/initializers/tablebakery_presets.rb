# default presets for HtmlTablebakery
TABLEBAKERY_PRESETS = {
    system: {
        attr_ignore: %w( id created_at updated_at operating_system_flavour ),
        attr_order:  %w( name fqdn operating_system join actions )

    },
    service: {
        attr_ignore: %w( updated_at created_at ),
        attr_order:  %w( id name type actions)
    },
    test_plan: {
        attr_ignore: %w( updated_at created_at user_id ),
        attr_order:  %w( id name description actions)
    },
    test_case: {
        attr_ignore: %w( id updated_at created_at markup type ),
        attr_order:  %w( name description format actions)
    }
}