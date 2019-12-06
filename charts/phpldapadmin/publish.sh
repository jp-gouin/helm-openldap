#!/bin/sh
set -e
set -o pipefail

WORKING_DIRECTORY="$PWD"

[ "$GITHUB_PAGES_REPO" ] || {
  echo "ERROR: Environment variable GITHUB_PAGES_REPO is required"
  exit 1
}
[ "$HELM_CHART" ] || {
  echo "ERROR: Environment variable HELM_CHART is required"
  exit 1
}
[ -z "$GITHUB_PAGES_BRANCH" ] && GITHUB_PAGES_BRANCH=gh-pages
[ -z "$HELM_CHARTS_SOURCE" ] && HELM_CHARTS_SOURCE="$WORKING_DIRECTORY/$HELM_CHART"
[ -d "$WORKING_DIRECTORY" ] || {
  echo "ERROR: Could not find Helm charts in $WORKING_DIRECTORY"
  exit 1
}
[ -z "$HELM_VERSION" ] && HELM_VERSION=2.8.1
[ "$CIRCLE_BRANCH" ] || {
  echo "ERROR: Environment variable CIRCLE_BRANCH is required"
  exit 1
}

echo "GITHUB_PAGES_REPO=$GITHUB_PAGES_REPO"
echo "GITHUB_PAGES_BRANCH=$GITHUB_PAGES_BRANCH"
echo "HELM_CHARTS_SOURCE=$HELM_CHARTS_SOURCE"
echo "HELM_VERSION=$HELM_VERSION"
echo "CIRCLE_BRANCH=$CIRCLE_BRANCH"

echo ">>> Create Chart Directory"

mkdir -p $HELM_CHARTS_SOURCE/
mkdir -p /tmp/helm-tmp/

mv $WORKING_DIRECTORY/* /tmp/helm-tmp/
mv /tmp/helm-tmp/ $HELM_CHARTS_SOURCE/

echo '>> Prepare...'
mkdir -p /tmp/helm/bin
mkdir -p /tmp/helm/publish
apk update
apk add ca-certificates git openssh

echo '>> Installing Helm...'
cd /tmp/helm/bin
wget "https://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-linux-amd64.tar.gz"
tar -zxf "helm-v${HELM_VERSION}-linux-amd64.tar.gz"
chmod +x linux-amd64/helm
alias helm=/tmp/helm/bin/linux-amd64/helm
helm version -c
helm init -c

echo ">> Checking out $GITHUB_PAGES_BRANCH branch from $GITHUB_PAGES_REPO"
cd /tmp/helm/publish
mkdir -p "$HOME/.ssh"
ssh-keyscan -H github.com >> "$HOME/.ssh/known_hosts"
git clone -b "$GITHUB_PAGES_BRANCH" "git@github.com:$GITHUB_PAGES_REPO.git" .

echo '>> Building chart...'
echo ">>> helm lint $HELM_CHARTS_SOURCE"
helm lint "$HELM_CHARTS_SOURCE"
echo ">>> helm package -d $HELM_CHART $HELM_CHARTS_SOURCE"
mkdir -p "$HELM_CHART"
helm package -d "$HELM_CHART" "$HELM_CHARTS_SOURCE"

echo '>>> helm repo index'
helm repo index .

if [ "$CIRCLE_BRANCH" != "master" ]; then
  echo "Current branch is not master and do not publish"
  exit 0
fi

echo ">> Publishing to $GITHUB_PAGES_BRANCH branch of $GITHUB_PAGES_REPO"
git config user.email "$CIRCLE_USERNAME@users.noreply.github.com"
git config user.name CircleCI
git add .
git status
git commit -m "Published by CircleCI $CIRCLE_BUILD_URL"
git push origin "$GITHUB_PAGES_BRANCH"

