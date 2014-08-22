# default presets for HtmlTablebakery
TABLEBAKERY_PRESETS = {
    system: {
        attr_ignore: %w( id slug created_at updated_at operating_system_flavour ),
        attr_order:  %w( actions name fqdn operating_system join )

    },
    service: {
        attr_ignore: %w( id updated_at created_at ),
        attr_order:  %w( actions name type )
    },
    test_plan: {
        attr_ignore: %w( id slug updated_at created_at user_id ),
        attr_order:  %w( name description base_url actions)
    },
    test_item: {
        attr_ignore: %w( id updated_at created_at ),
        attr_order:  %w( name description type format markup actions)
    },
    test_case: {
        attr_ignore: %w( updated_at created_at type ),
        attr_order:  %w( id name description format markup actions)
    },
    test_script: {
        attr_ignore: %w( updated_at created_at type ),
        attr_order:  %w( id name description format markup actions)
    },
    test_execution: {
        attr_ignore: %w( id updated_at user_id ),
        attr_order:  %w( created_at job_id name test_plan_id base_url actions)
    },
    ip_lookup: {
        attr_ignore: %w( id created_at updated_at user_id ),
        attr_order:  %w( created_at target status job_id started_at finished_at actions )
    }
}