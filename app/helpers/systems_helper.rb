module SystemsHelper

  def basic_info_panel(system)
    capture do
      unless system.description.empty?
        concat "<blockquote><p>#{system.description}</p></blockquote".html_safe
      end
    end
  end

  def network_info_panel(system)
    capture do
      concat '<div class="panel panel-default">'.html_safe
      concat '<div class="panel-body">'.html_safe
      unless system.fqdn.empty?
        concat "<h4>#{system.fqdn}#{}</h4>".html_safe
      end
      unless system.cidr.empty?
        concat "<div>Network address: #{system.cidr}</div>".html_safe
      end
      unless system.sshuser.empty?
        concat "<div>SSH user: #{system.sshuser}</div>".html_safe
      end
      concat '</div>'.html_safe
      concat '</div>'.html_safe
    end
  end

end
