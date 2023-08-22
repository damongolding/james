echo "Building"
env GOOS=linux GOARM=6 GOARCH=arm go build .

echo "Compressing"
upx -9 monitor-server
