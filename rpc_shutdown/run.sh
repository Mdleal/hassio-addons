#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

COMPUTERS=$(jq --raw-output '.computers | length' $CONFIG_PATH)

# Read from STDIN aliases to send shutdown
while read -r input; do
    # remove json stuff
    input="$(echo "$input" | jq --raw-output '.')"
    echo "[Info] Read alias: $input"

    # Find aliases -> computer
    for (( i=0; i < "$COMPUTERS"; i++ )); do
        ALIAS=$(jq --raw-output ".computers[$i].alias" $CONFIG_PATH)
        ADDRESS=$(jq --raw-output ".computers[$i].address" $CONFIG_PATH)
        CREDENTIALS=$(jq --raw-output ".computers[$i].credentials" $CONFIG_PATH)
        REBOOT=$(jq --raw-output ".computers[$i].reboot" $CONFIG_PATH)
        MESSAGE=$(jq --raw-output ".computers[$i].message" $CONFIG_PATH)
        TIME_TO_EXECUTE=$(jq --raw-output ".computers[$i].time_to_execute" $CONFIG_PATH)
		
        # Not the correct alias
        if [ "$ALIAS" != "$input" ]; then
		    echo 'continue...'
            continue
        fi
      
        echo "[Info] Shutdown $input -> $ADDRESS -> $MESSAGE -> $TIME_TO_EXECUTE -> $REBOOT
        if ! msg="$(net rpc shutdown -I "$ADDRESS" -U "$CREDENTIALS" -C "$MESSAGE" -T "$TIME_TO_EXECUTE" "$REBOOT")"; then
            echo "[Error] Shutdown fails -> $msg"
        fi
    done
done
