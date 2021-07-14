#!/bin/bash

cd $1

mix run priv/sub_test.exs &
PID1=$!

echo "TESTINFO: wait for creating subscriber"
while :
do
  if [ -e sub_ready.txt ]; then
    echo "TESTINFO: subscriber has created"
    rm -f sub_ready.txt
    break
  fi
  sleep 0.1
done

ros2 run cpp_pubsub talker &
PID2=$!

wait $PID1 $PID2

cppPub=`cat pub_msg.txt | tr -d "\0"`
echo "TESTINFO: published message  : $cppPub"
rm -f pub_msg.txt

exSub=`cat sub_msg.txt | tr -d "\0"`
echo "TESTINFO: subscribed message : $exSub"
rm -f sub_msg.txt

test $cppPub = $exSub
result=$?
echo "TESTINFO: result : $result"

if [ $result -ne 0 ]; then
    echo "TESTERROR: $0 failed."
    exit 1
fi
