web: bundle exec rails server -p $PORT
sidekiq: bundle exec sidekiq -L log/sidekiq.log
selenium-hub: java -jar lib/assets/selenium-server-standalone-2.43.1.jar -role hub -log log/selenium-hub.log
selenium-node: java -jar lib/assets/selenium-server-standalone-2.43.1.jar -role node -hub http://localhost:4444/grid/register -log log/selenium-node.log
