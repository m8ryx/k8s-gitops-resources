export VERSION=$(git rev-parse HEAD | cut -c1-7)
export REPO_NAME='k8s-gitops-sample-app-deployment'
export GIT_USER='m8ryx'
export DOCKER_USER='m8ryx'
export TARGET_APP='sample-app'

make build
make test

export NEW_IMAGE="${DOCKER_USER}/${TARGET_APP}:${VERSION}"
docker build -t ${NEW_IMAGE} .
docker push ${NEW_IMAGE}

git clone git@github.com:${GIT_USER}/${REPO_NAME}.git
cd ${REPO_NAME}

kubectl patch \
  --local \
  -o yaml \
  -f deployment.yaml \
  -p "spec:
        template:
          spec:
            containers:
            - name: ${TARGET_APP}
              image: ${NEW_IMAGE}" \
  > /tmp/newdeployment.yaml
mv /tmp/newdeployment.yaml deployment.yaml

pwd
git commit deployment.yaml -m "Update ${TARGET_APP} image to ${NEW_IMAGE}"
git push

