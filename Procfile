web: bundle exec rails server -p $PORT
sidekiq: bundle exec sidekiq -L log/sidekiq.log
selenium-hub: java -jar lib/assets/selenium-server-standalone-2.43.1.jar -role hub -log log/selenium-hub.log -hubConfig lib/assets/selenium-hubconfig.json
selenium-node-1: java -jar lib/assets/selenium-server-standalone-2.43.1.jar -role node -hub http://localhost:4444/grid/register -log log/selenium-node-1.log -nodeConfig lib/assets/selenium-nodeconfig-1.json
selenium-node-2: java -jar lib/assets/selenium-server-standalone-2.43.1.jar -role node -hub http://localhost:4444/grid/register -log log/selenium-node-2.log -nodeConfig lib/assets/selenium-nodeconfig-2.json