http://openmetrics.net

```
rake assets:precompile

// show & fix missing translations (https://github.com/glebm/i18n-tasks)
#i18n-task #no args show usage information
#i18n-tasks find om.views.system.new.html_input.caption #show usage of translation key in code

i18n-tasks missing #show summary
i18n-tasks add missing

// export translations from /config/locale/* to js
rake i18n:js:export

// load sample data and run setup
foreman run rake openmetrics:setup --env /opt/openmetrics/config/instance.env

// start services; done!
foreman start --env /opt/openmetrics/config/instance.env

// optional: run the self tests
foreman run openmetrics:test --env config/environments/development.env

// optional: for debugging purposes and playaround: start rails console
foreman run rails console --env /opt/openmetrics/config/instance.env
```
