
set :output, "/var/shared/cron.log"

env :PATH, '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/home/deploy/.rvm/bin'

# Example of archiving and cleaning.
#
# every 1.hour do
#   command "cd /var/www/current; bundle exec ruby script/db/archive myproject.yml"
# end
#
# every 1.day do
#   command "cd /var/www/current; bundle exec ruby script/db/clean myproject.yml"
# end
#

