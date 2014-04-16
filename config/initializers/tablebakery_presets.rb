# default presets for HtmlTablebakery
HtmlTablebakery::PRESETS = {
    system: {
        attr_ignore: %w( created_at ),
        attr_order:  %w( id name fqdn operating_system operating_system_flavour )

    },
    service: {
        attr_ignore: %w( updated_at created_at ),
        attr_order:  %w( id name )
    }
}