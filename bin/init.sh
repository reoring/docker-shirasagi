docker-compose exec rails bash -l -c "./bin/rake db:drop"
docker-compose exec rails bash -l -c "./bin/rake db:create_indexes"
docker-compose exec rails bash -l -c "./bin/rake ss:create_site data='{ name: \"demo-site\", host: \"www\", domains: \"192.168.99.100:3000\" }'"
docker-compose exec rails bash -l -c "./bin/rake db:seed name=users site=www"
