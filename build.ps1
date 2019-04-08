#initialise build variables
$version='latest'
$appname='robotframework-lua'
$server='frederick1989'
# $server='' #openshift

$TAG = "$($appname):$($version)"
$IMAGE="$($server)/$($TAG)"

docker build -t $TAG --shm-size=256M .
docker tag $TAG  $IMAGE
docker push $IMAGE