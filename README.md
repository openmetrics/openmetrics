http://openmetrics.net

```
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
foreman run rake openmetrics:test --env config/environments/development.env

// optional: for debugging purposes and playaround: start rails console
foreman run rails console --env /opt/openmetrics/config/instance.env

// precompile assets
bundle exec rake assets:clobber RAILS_ENV=production
bundle exec rake assets:precompile RAILS_ENV=production

// generate start script (init.d)
gem install foreman-export-initd
foreman export initd /tmp --user om --app openmetrics
```
