#!/bin/bash

DOCKER_GITLAB_HOME_PATH=$(realpath "$(dirname $(realpath "$0"))")

DOCKER_GITLAB_CONFIGURATION_PATH="${DOCKER_GITLAB_HOME_PATH}/docker-config"
DOCKER_GITLAB_CONFIGURATION_FILE="${DOCKER_GITLAB_CONFIGURATION_PATH}/config.sh"
DOCKER_GITLAB_CONFIGURATION_FILE_CUSTOM="${DOCKER_GITLAB_CONFIGURATION_PATH}/my-config.sh"

source "${DOCKER_GITLAB_CONFIGURATION_FILE}"
#
# You can provid your own configuration in my-config.sh
if [ -f "${DOCKER_GITLAB_CONFIGURATION_FILE_CUSTOM}" ]; then
  source "${DOCKER_GITLAB_CONFIGURATION_FILE_CUSTOM}"
fi
if [ -z "$GITLAB_BASH_API_PATH" ]; then
  GITLAB_BASH_API_PATH=$(dirname $(dirname $(realpath "$0")))
fi

if [ ! -f "${GITLAB_BASH_API_PATH}/api/gitlab-bash-api.sh" ]; then
  echo "gitlab-bash-api.sh not found! - Please set GITLAB_BASH_API_PATH" >&2
  exit 1
fi

#
# GitLab configuration
#
GITLAB_BASH_API_CONFIG="${DOCKER_GITLAB_HOME_PATH}/gitlab-bash-api-config-for-docker"
GITLAB_BASH_API_CONFIG_FILE="${GITLAB_BASH_API_CONFIG}/generated-configuration"

echo 'Prepare customization' >&2
echo "Create/Update '${GITLAB_BASH_API_CONFIG_FILE}'" >&2
echo "#!/bin/bash

# Generated configuration file - do not edit

GITLAB_HOST="${DOCKER_GITLAB_HTTP_HOST}"
GITLAB_PORT="${DOCKER_HTTP_PORT}"

GITLAB_USER="${DOCKER_GITLAB_USER}"
GITLAB_PASSWORD="${DOCKER_GITLAB_PASSWORD}"

GITLAB_URL_PREFIX="http://${DOCKER_GITLAB_HTTP_HOST}:${DOCKER_HTTP_PORT}"
GITLAB_CLONE_SSH_PREFIX=git@${DOCKER_GITLAB_SSH_HOST}:${DOCKER_SSH_PORT}

GITLAB_API_VERSION="${DOCKER_GITLAB_API_VERSION}"
" > "${GITLAB_BASH_API_CONFIG_FILE}"

#
# gitlab-bash-api configuration
#
BOOTSTRAP_CONFIG_PATH="${DOCKER_GITLAB_HOME_PATH}/generated-config-bootstrap"
BOOTSTRAP_CONFIG_FILE="${BOOTSTRAP_CONFIG_PATH}/init.sh"

echo "Create '${BOOTSTRAP_CONFIG_PATH}' if needed" >&2
mkdir -p "${BOOTSTRAP_CONFIG_PATH}"

echo "Create/Update '${BOOTSTRAP_CONFIG_FILE}'" >&2
echo "#!/bin/bash

export GITLAB_BASH_API_PATH=$(dirname $(dirname $(realpath "$0")))
export GITLAB_BASH_API_CONFIG=${GITLAB_BASH_API_CONFIG}

export DOCKER_GITLAB_VERSION="${DOCKER_GITLAB_VERSION}"
export DOCKER_NAME="${DOCKER_NAME}"

export DOCKER_HOSTNAME="${DOCKER_HOSTNAME}"
export DOCKER_HTTP_PORT="${DOCKER_HTTP_PORT}"
export DOCKER_SSH_PORT="${DOCKER_SSH_PORT}"

export DOCKER_GITLAB_HTTP_HOST="${DOCKER_GITLAB_HTTP_HOST}"
export DOCKER_GITLAB_SSH_HOST="${DOCKER_GITLAB_SSH_HOST}"

export DOCKER_GITLAB_USER="${DOCKER_GITLAB_USER}"
export DOCKER_GITLAB_PASSWORD="${DOCKER_GITLAB_PASSWORD}"

" >"${BOOTSTRAP_CONFIG_FILE}"

#
# Summerize
#
echo "
Customization store in '${GITLAB_BASH_API_CONFIG_FILE}'

DOCKER_GITLAB_CONFIGURATION_PATH=${DOCKER_GITLAB_CONFIGURATION_PATH}

GITLAB_BASH_API_PATH=${GITLAB_BASH_API_PATH}
GITLAB_BASH_API_CONFIG=${GITLAB_BASH_API_CONFIG}
" >&2

CMD_GENERATE_PRIVATE_TOCKEN="${DOCKER_GITLAB_HOME_PATH}/bin/generate-private-token.sh"

echo "Try to generate private tocken (Will fail if GitLab not yet started)
If command fail you need to run when GitLab is running

  ${CMD_GENERATE_PRIVATE_TOCKEN}

" >&2
bash "${DOCKER_GITLAB_HOME_PATH}/bin/generate-private-token.sh"

