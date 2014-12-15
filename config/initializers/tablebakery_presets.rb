# default presets for HtmlTablebakery
TABLEBAKERY_PRESETS = {
    metric: {
        attr_ignore: %w( created_at updated_at),
        attr_order:  %w( id host name rrd_file plugin plugin_instance type type_instance ds )
    },
    project: {
        attr_ignore: %w( id created_at updated_at creator_id ),
        attr_order:  %w( name description actions)
    },
    system: {
        attr_ignore: %w( id slug created_at updated_at operating_system_flavor sshuser description ),
        attr_order:  %w( name fqdn cidr operating_system join_running_services actions)

    },
    service: {
        attr_ignore: %w( id init_name systemd_name daemon_name updated_at created_at fqdn ),
        attr_order:  %w( type name description join_running_services actions )
    },
    test_plan: {
        attr_ignore: %w( id slug updated_at created_at user_id base_url ),
        attr_order:  %w( name description actions)
    },
    test_item: {
        attr_ignore: %w( id updated_at created_at markup),
        attr_order:  %w( type format name description actions )
    },
    test_case: {
        attr_ignore: %w( updated_at created_at type markup ),
        attr_order:  %w( id format name description actions)
    },
    test_script: {
        attr_ignore: %w( updated_at created_at type ),
        attr_order:  %w( id name description format markup actions)
    },
    test_execution: {
        attr_ignore: %w( id updated_at user_id ),
        attr_order:  %w( created_at job_id name test_plan_id base_url started_at finished_at status actions)
    },
    ip_lookup: {
        attr_ignore: %w( id created_at updated_at user_id ),
        attr_order:  %w( created_at target status job_id started_at finished_at actions )
    }
}