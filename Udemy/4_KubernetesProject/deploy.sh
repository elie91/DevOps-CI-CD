docker build -t elie91/multi-client -f ./client/Dockerfile ./client
docker build -t elie91/multi-server -f ./server/Dockerfile ./server
docker build -t elie91/multi-worker -f ./worker/Dockerfile ./worker
docker push elie91/multi-client
docker push elie91/multi-server
docker push elie91/multi-worker
kubectl apply -f k8s
kubectl rollout restart deployment/server-deployment
kubectl rollout restart deployment/client-deployment
kubectl rollout restart deployment/worker-deployment