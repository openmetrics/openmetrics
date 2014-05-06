# default presets for HtmlTablebakery
TABLEBAKERY_PRESETS = {
    system: {
        attr_ignore: %w( id created_at updated_at operating_system_flavour ),
        attr_order:  %w( name fqdn operating_system join actions )

    },
    service: {
        attr_ignore: %w( id updated_at created_at ),
        attr_order:  %w( name type actions)
    },
    test_plan: {
        attr_ignore: %w( id updated_at created_at user_id base_url ),
        attr_order:  %w( name description actions)
    },
    test_case: {
        attr_ignore: %w( id updated_at created_at markup type ),
        attr_order:  %w( name description format actions)
    },
    test_execution: {
        attr_ignore: %w( id updated_at user_id ),
        attr_order:  %w( created_at job_id name test_plan_id base_url actions)
    }
}