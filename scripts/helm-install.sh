#!/bin/bash

cd "$HOME" || exit 1
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

exit 0