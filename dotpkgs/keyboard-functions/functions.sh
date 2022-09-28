#! /bin/bash

here="$(realpath "$(dirname $0)")"

[ -z "$TIMEOUT" ] && \
	TIMEOUT=700
[ -z "$URGENCY" ] && \
	URGENCY=low
[ -z "$ICONS" ] && \
	ICONS='rounded-white'
[ -z "$VOLUME_TITLE" ] && \
	VOLUME_TITLE='Default Audio Output'
[ -z "$MICROPHONE_TITLE" ] && \
	MICROPHONE_TITLE='Default Audio Input'
[ -z "$VOLUME_OUTPUT_SINK" ] && \
	VOLUME_OUTPUT_SINK='@DEFAULT_AUDIO_SINK@'
[ -z "$INPUT_SOURCE" ] && \
	INPUT_SOURCE='@DEFAULT_AUDIO_SOURCE@'
[ -z "$ICONS_DIRECTORY" ] && \
	ICONS_DIRECTORY="$here/icons"
[ -z "$MAIN_TEXT_SIZE" ] && \
	MAIN_TEXT_SIZE=150%

set -eux

is_muted() {
	[ -z "$(wpctl get-volume "$1" | grep '[MUTED]')" ] \
		|| printf 0
}

get_volume() {
	wpctl get-volume "$VOLUME_OUTPUT_SINK" | awk '{print $2}'
}

input_mute() {
	wpctl set-mute "$INPUT_SOURCE" toggle

	if [ $(is_muted "$INPUT_SOURCE") ]
	then
		icon="$ICONS_DIRECTORY/$ICONS/mic_off_white_36dp.svg"
		status="Disabled"
	else
		icon="$ICONS_DIRECTORY/$ICONS/mic_white_36dp.svg"
		status="Enabled"
	fi

	message="<b><span size='$MAIN_TEXT_SIZE'>$status</span></b>"

	notify-send \
		"$MICROPHONE_TITLE" \
		"$message" \
		-u $URGENCY \
		-t $TIMEOUT \
		-i "$icon" \
		-h string:synchronous:change-volume
}

volume_mute() {
	wpctl set-mute "$VOLUME_OUTPUT_SINK" toggle

	if [ $(is_muted "$VOLUME_OUTPUT_SINK") ]
	then
		icon="$ICONS_DIRECTORY/$ICONS/volume_off_white_36dp.svg"
		status="Disabled"
	else
		icon="$ICONS_DIRECTORY/$ICONS/volume_up_white_36dp.svg"
		status="Enabled"
	fi

	percent=$(bc <<< "$(get_volume) * 100 / 1")
	message="$(
		cat <<- EOF
			<b><span size='$MAIN_TEXT_SIZE'>$status</span></b>
			Volume $percent%
		EOF
	)"

	notify-send \
		"$VOLUME_TITLE" \
		"$message" \
		-u $URGENCY \
		-t $TIMEOUT \
		-i "$icon" \
		-h string:synchronous:change-volume
}

volume_change() {
	value="$1"
	current=$(get_volume)

	if [[ "$value" =~ ^\+([01]\.[0-9]{1,2})$ ]]
	then
		mode=increase
	elif [[ "$value" =~ ^\-([01]\.[0-9]{1,2})$ ]]
	then
		mode=decrease
	elif [[ "$value" =~ ^([01]\.[0-9]{1,2})$ ]]
	then
		mode=set
	else
		echo "'$value' is not a valid decimal number (0.00-1.00)"
	fi

	value=${BASH_REMATCH[1]}

	if [ $mode = increase ]
	then
		if [ $(bc <<< "$current >= 1.0" ) -eq 1 ]
		then
			wpctl set-volume "$VOLUME_OUTPUT_SINK" 1.0
			echo 'Volume already at maximum'
			exit
		fi
		value=$(bc <<< "$current + $value")
		icon="$ICONS_DIRECTORY/$ICONS/volume_up_white_36dp.svg"
	elif [ $mode = decrease ]
	then
		if [ $(bc <<< "$current <= 0.0" ) -eq 1 ]
		then
			wpctl set-volume "$VOLUME_OUTPUT_SINK" 0.0
			echo 'Volume already at minimum'
			exit
		fi
		value=$(bc <<< "$current - $value")
		icon="$ICONS_DIRECTORY/$ICONS/volume_down_white_36dp.svg"
	else
		title='Volume Change'
		icon="$ICONS_DIRECTORY/$ICONS/volume_up_white_36dp.svg"
	fi

	wpctl set-volume "$VOLUME_OUTPUT_SINK" $value

	if [ $(is_muted "$VOLUME_OUTPUT_SINK") ]
	then
		icon="$ICONS_DIRECTORY/$ICONS/volume_off_white_36dp.svg"
		status='Disabled'
	else
		status='Enabled'
	fi

	percent=$(bc <<< "$value * 100 / 1")
	message="$(
		cat <<- EOF
			<b><span size='$MAIN_TEXT_SIZE'>Volume $percent%</span></b>
			$status
		EOF
	)"

	notify-send \
		"$VOLUME_TITLE" \
		"$message" \
		-u $URGENCY \
		-t $TIMEOUT \
		-i "$icon" \
		-h int:value:$percent \
		-h string:synchronous:change-volume
}

if [ $1 = volume ]
then
	if [ $2 = mute ]
	then
		volume_mute
		exit
	else
		volume_change $2
		exit
	fi
elif [ $1 = input ]
then
	if [ $2 = mute ]
	then
		input_mute
		exit
	fi
fi

echo "Unsupported options!"
exit 11
