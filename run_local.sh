docker rm -f cloud_router
docker build -t cloud-routing .
docker run --name cloud_router -e FLY_REGION=localhost1 -p 8080:8080 -p 9000:9000 cloud-routing