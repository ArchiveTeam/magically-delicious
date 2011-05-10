#!/bin/bash
# feast.sh: distributed delicious mirroring script

SERVER=http://85.31.187.124:9027/

types=(users tags bookmarks)
scripts=(cannibal tagsaretasty omnomnomILOVELINKS)

while getopts :u: OPT; do
  case $OPT in
    u)
      USERNAME="$OPTARG"
      ;;
    *)
      echo "usage: `basename $0` [-u USERNAME]"
      exit 1;
  esac
done

warning() {
  echo "$0: $*" >&2
}

error() {
  echo "$0: $*" >&2
  exit 2
}

if [ -z $USERNAME ]; then
  error "You must supply a username with the -u option before you can begin"
fi

if [ ! -f $cannibal ]; then
  error "Couldn't find cannibal.sh; are you sure you cloned everything from the git repository?"
fi

EXTERN_IP=`curl --silent ipv4.icanhazip.com` #Do not change without good reason, or underscor will eat your brains

tellserver() {
  cmd="$1"
  shift
  rest=
  for chunk in "$@"; do
    rest="$rest/$chunk"
  done
  #if ! curl --silent --fail "http://$SERVER/$cmd/${USERNAME}$rest"; then
  #  error "Couldn't contact the listerine server. The listerine server could be down, or your network."
  #fi
}

askserver() {
  var="$1"
  cmd="$2"
  shift 2
  rest=
  for chunk in "$@"; do
    rest="$rest/$chunk"
  done
  #export $var=(`curl --silent --fail "http://$SERVER/$cmd/${USERNAME}$rest"`)
  if [ $? != 0 ]; then
    error "Couldn't contact the listerine server. The listerine server could be down, or your network."
  fi
}

tellserver introduce $EXTERN_IP
mkdir data-backup
while true; do
  echo "Getting an id from $SERVER, authenticated as $USERNAME with IP $EXTERN_IP"
  askserver response getID
  if [ $? != 0 ]; then
    error "The server didn't give us an id. This could mean the server is broken, or possibly that we're finished."
  fi
  response=(0 robbiet480)
  task=${response[0]}
  id=${response[1]/\./+}
  #if [ $(echo $id | grep "^[-0-9]*$") != $id ]; then
  #  error "The server did not return a valid id. It said: $id"
  #fi

  if $((${#id} < 3)); then
    path=data/${types[$task]}/${id:0:1}/${id:1:1}
  else
    path=data/${types[$task]}/${id:0:1}/${id:1:1}/${id:2:1}
  fi
  mkdir -p $path

  echo ID is $id saving to $path
  file=$path/$id.xml
  ./${scripts[$task]}.sh "$id" | tee $file | grep "<id>" | sed -e 's/.*<id>\(.*\)<\/id>/\1/' | while read mark; do
    # send users, tags, and bookmarks to server...
  done;
  scp -i friend -R data friendster@85.31.187.124:delicious &
  mv data/* data-backup

  if [ -f $file ]; then
    tellserver finishID $task $id 
  else
    warning "Failed to download anything for $id."
  fi
  if [ -f STOP ]; then
    echo "$0: I see a file called STOP. Stopping."
    exit 0
  fi
done
