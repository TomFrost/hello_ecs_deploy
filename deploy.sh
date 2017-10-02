#!/bin/bash
############################
## Deploy a Hello World app
## Tom Shawver

echo_error() {
  echo -e "\033[0;31m[ :( ] $1 \033[0m"
}

echo_warn() {
  echo -e "\033[0;33m[ :/ ] $1 \033[0m"
}

echo_success() {
  echo -e "\033[0;32m[ :D ] $1 \033[0m"
}

echo_info() {
  echo -e "\033[1;34m[----] $1 \033[0m"
}

bin_exists() {
  if which $1 > /dev/null 2>&1; then
    return 0
  fi
  return 1
}

# run_safe "command to run" "error message" "success message"
run_safe() {
  $1
  if [ $? -gt 0 ]; then
    if [ -n "$2" ]; then
      echo_error "$2"
    else
      echo_error "Failed: $1"
    fi
    exit 20
  else
    if [ -n "$3" ]; then
      echo_success "$3"
    else
      echo_success "Success: $1"
    fi
  fi
}

wait_for_200() {
  attempts=60
  while [ $attempts -gt 0 ]; do
    code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 $1)
    if [ "$code" == "000" ]; then
      attempts=$[$attempts-1]
      echo_warn "Failed to connect. Attempts remaining: $attempts"
      sleep 5
    elif [ "$code" == "200" ]; then
      return 0
    else
      return 1
    fi
  done
  return 1
}

if [ -z "$AWS_ACCESS_KEY_ID" -o -z "$AWS_SECRET_ACCESS_KEY" -o -z "$AWS_REGION" ]; then
  echo_error "Please set the following environment variables: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION"
  exit 1
fi
if ! bin_exists ansible-playbook; then
  echo_error "Ansible v2.4 or higher is required"
  exit 2
fi
if ! bin_exists curl; then
  echo_error "Curl is required to continue"
  exit 3
fi
echo_info "Building and deploying helloapp with Ansible"
run_safe "ansible-playbook ./ecs_deploy.yml" "Please correct above errors and retry." "Deployed!"
echo_info "Waiting for the application to become available..."
URL="http://$(cat .hostip)"
if wait_for_200 "$URL"; then
  echo_success "App online! Please visit $URL"
  if bin_exists open; then
    open "$URL"
  fi
else
  echo_error "Timed out waiting for app, exiting"
  exit 4
fi

