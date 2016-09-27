#!/bin/bash

RAILS_ENV=production; bundle exec rake unicorn:start &
nginx -g "daemon off;"
