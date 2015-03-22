DEFAULT_CRONTAB_FREQUENCY="* * * * *"
DEFAULT_CRONTAB_FREQUENCY_ESCAPED=$(printf '%s\n' "${DEFAULT_CRONTAB_FREQUENCY}" | sed 's/[[\.*^$/]/\\&/g')

[ -z "$CRONTAB_FREQUENCY" ] && CRONTAB_FREQUENCY="$DEFAULT_CRONTAB_FREQUENCY"
CRONTAB_FREQUENCY_ESCAPED=$(printf '%s\n' "${CRONTAB_FREQUENCY}" | sed 's/[[\.*^$/]/\\&/g')

cp config.json /satis/config.json

echo ""
cat /satis/config.json
echo ""
echo ""

echo " >> Creating the correct known_hosts file"
ssh-keyscan -t rsa $PRIVATE_REPO_DOMAIN >> /root/.ssh/known_hosts


echo " >> Copying host ssh key from /var/tmp/id to /root/.ssh/id_rsa"
cp /var/tmp/id /root/.ssh/id_rsa


echo " >> Building Satis for the first time"
/satis/build.sh

if [[ $CRONTAB_FREQUENCY == -1 ]]; then

  echo " > No Cron"

else

  echo " > Crontab frequency set to: ${CRONTAB_FREQUENCY}"
  sed -i "s/${DEFAULT_CRONTAB_FREQUENCY_ESCAPED}/${CRONTAB_FREQUENCY_ESCAPED}/g" /etc/cron.d/satis-cron

  echo " >> Starting cron"
  cron &

fi

echo " >> Starting node web server"
cd /app && node server.js
