#!/command/with-contenv bashio
# shellcheck shell=bash
set -e

CONFIG_PATH=/data/options.json
KEY_PATH=/data/ssh_keys
HOSTNAME=remote.royalhomeautomations.nl
SSH_PORT=22222

USERNAME=$(jq --raw-output ".username" $CONFIG_PATH)
SSHUSERNAME=2${USERNAME:1}
SSHMONITOR=3${USERNAME:1}
PRIV_KEY=$(jq --raw-output ".privkey" $CONFIG_PATH)

mkdir -p "$KEY_PATH"
echo -e "-----BEGIN OPENSSH PRIVATE KEY-----\n${PRIV_KEY}\n-----END OPENSSH PRIVATE KEY-----" > "${KEY_PATH}/autossh_rsa_key"

chmod 400 "${KEY_PATH}/autossh_rsa_key"

ssh-keyscan -p $SSH_PORT $HOSTNAME || true

COMMAND="/usr/bin/autossh "\
" -M ${SSHMONITOR} -N "\
"-o ServerAliveInterval=30 "\
"-o ServerAliveCountMax=3 "\
"-o StrictHostKeyChecking=no "\
"-o ExitOnForwardFailure=yes "\
"-p ${SSH_PORT} -t -t "\
"-i ${KEY_PATH}/autossh_rsa_key "\
"hassio_${USERNAME}@${HOSTNAME} "\
"-R 172.17.0.1:${USERNAME}:127.0.0.1:8123 "\
"-R 127.0.0.1:${USERNAME}:127.0.0.1:8123 "\
"-R ${SSHUSERNAME}:127.0.0.1:22"


COMMAND="${COMMAND}"

bashio::log.info "Executing command: ${COMMAND}"
/usr/bin/autossh -V

exec ${COMMAND}
