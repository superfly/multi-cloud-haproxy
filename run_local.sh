docker rm -f multi_cloud_router
docker build -t multi_cloud_router .
docker run --name multi_cloud_router -e FLY_REGION=localhost1 -p 8080:8080 -p 9000:9000 multi_cloud_router