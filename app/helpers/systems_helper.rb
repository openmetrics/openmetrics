module SystemsHelper

  def basic_info_panel(system)
    capture do
      if system.description
        concat "<blockquote><p>#{system.description}</p></blockquote>".html_safe
      end
      if system.operating_system or system.operating_system_flavor
        concat "<p>".html_safe
        concat "#{system.operating_system}".html_safe
        concat " (#{system.operating_system_flavor})".html_safe if system.operating_system_flavor
        concat "</p>".html_safe
      end
    end
  end

  def network_info_panel(system)
    capture do
      concat '<div class="panel panel-default">'.html_safe
      concat '<div class="panel-body">'.html_safe
      if system.fqdn
        concat "<h4>#{system.fqdn}#{}</h4>".html_safe
      end
      if system.cidr
        concat "<div>Network address: #{system.cidr}</div>".html_safe
      end
      if system.sshuser
        concat "<div>SSH user: #{system.sshuser}</div>".html_safe
      end
      concat '</div>'.html_safe
      concat '</div>'.html_safe
    end
  end

end
