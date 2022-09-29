#! /bin/bash
set -euxo pipefail

here="$(realpath "$(dirname $0)")"

TIMEOUT="${TIMEOUT:="700"}"
URGENCY="${URGENCY:="low"}"
MAIN_TEXT_SIZE="${MAIN_TEXT_SIZE:="x-large"}"
ICONS_DIRECTORY="${ICONS_DIRECTORY:="$here/icons/rounded-white"}"

OUTPUT_TITLE="${OUTPUT_TITLE:="Default Audio Output"}"
INPUT_TITLE="${INPUT_TITLE:="Default Audio Input"}"

OUTPUT_DEVICE="${OUTPUT_DEVICE:="@DEFAULT_AUDIO_SINK@"}"
INPUT_DEVICE="${INPUT_DEVICE:="@DEFAULT_AUDIO_SOURCE@"}"

OUTPUT_DISABLE_ICON="${OUTPUT_DISABLE_ICON:="volume_off_white_36dp.svg"}"
OUTPUT_ENABLE_ICON="${OUTPUT_ENABLE_ICON:="volume_up_white_36dp.svg"}"
OUTPUT_INCREASE_ICON="${OUTPUT_INCREASE_ICON:="volume_up_white_36dp.svg"}"
OUTPUT_DECREASE_ICON="${OUTPUT_DECREASE_ICON:="volume_down_white_36dp.svg"}"
INPUT_DISABLE_ICON="${INPUT_DISABLE_ICON:="mic_off_white_36dp.svg"}"
INPUT_ENABLE_ICON="${INPUT_ENABLE_ICON:="mic_white_36dp.svg"}"

is_muted() {
	[ -z "$(wpctl get-volume "$1" | grep '[MUTED]')" ] \
		|| printf 0
}

get_volume() {
	wpctl get-volume "$1" | awk '{print $2}'
}

input_mute() {
	wpctl set-mute "$INPUT_DEVICE" toggle

	if [ $(is_muted "$INPUT_DEVICE") ]
	then
		icon="$ICONS_DIRECTORY/$INPUT_DISABLE_ICON"
		status="Disabled"
	else
		icon="$ICONS_DIRECTORY/$INPUT_ENABLE_ICON"
		status="Enabled"
	fi

	message="<b><span size='$MAIN_TEXT_SIZE'>$status</span></b>"

	notify-send \
		"$INPUT_TITLE" \
		"$message" \
		-u "$URGENCY" \
		-t "$TIMEOUT" \
		-i "$icon" \
		-h string:synchronous:change-volume
}

volume_mute() {
	wpctl set-mute "$OUTPUT_DEVICE" toggle

	if [ $(is_muted "$OUTPUT_DEVICE") ]
	then
		icon="$ICONS_DIRECTORY/$OUTPUT_DISABLE_ICON"
		status="Disabled"
	else
		icon="$ICONS_DIRECTORY/$OUTPUT_ENABLE_ICON"
		status="Enabled"
	fi

	percent=$(bc <<< "$(get_volume "$OUTPUT_DEVICE") * 100 / 1")
	message="$(
		cat <<- EOF
			<b><span size='$MAIN_TEXT_SIZE'>$status</span></b>
			Volume $percent%
		EOF
	)"

	notify-send \
		"$OUTPUT_TITLE" \
		"$message" \
		-u "$URGENCY" \
		-t "$TIMEOUT" \
		-i "$icon" \
		-h 'string:synchronous:change-volume'
}

volume_change() {
	value="$1"
	current=$(get_volume "$OUTPUT_DEVICE")

	if [[ "$value" =~ ^\+([01]\.[0-9]{1,2})$ ]]
	then
		mode='increase'
	elif [[ "$value" =~ ^\-([01]\.[0-9]{1,2})$ ]]
	then
		mode='decrease'
	elif [[ "$value" =~ ^([01]\.[0-9]{1,2})$ ]]
	then
		mode='set'
	else
		echo "'$value' is not a valid decimal number (0.00-1.00)"
	fi

	value=${BASH_REMATCH[1]}

	if [ $mode = 'increase' ]
	then
		if [ $(bc <<< "$current >= 1.0" ) -eq 1 ]
		then
			wpctl set-volume "$OUTPUT_DEVICE" 1.0
			echo 'Volume already at maximum'
			exit
		fi
		value=$(bc <<< "$current + $value")
		icon="$ICONS_DIRECTORY/$OUTPUT_INCREASE_ICON"
	elif [ $mode = 'decrease' ]
	then
		if [ $(bc <<< "$current <= 0.0" ) -eq 1 ]
		then
			wpctl set-volume "$OUTPUT_DEVICE" 0.0
			echo 'Volume already at minimum'
			exit
		fi
		value=$(bc <<< "$current - $value")
		icon="$ICONS_DIRECTORY/$OUTPUT_DECREASE_ICON"
	else
		title='Volume Change'
		icon="$ICONS_DIRECTORY/$OUTPUT_INCREASE_ICON"
	fi

	wpctl set-volume "$OUTPUT_DEVICE" $value

	if [ $(is_muted "$OUTPUT_DEVICE") ]
	then
		icon="$ICONS_DIRECTORY/$OUTPUT_DISABLE_ICON"
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
		"$OUTPUT_TITLE" \
		"$message" \
		-u "$URGENCY" \
		-t "$TIMEOUT" \
		-i "$icon" \
		-h "int:value:$percent" \
		-h 'string:synchronous:change-volume'
}

if [ "$1" = 'output' ]
then
	if [ "$2" = 'mute' ]
	then
		volume_mute
		exit
	else
		volume_change "$2"
		exit
	fi
elif [ "$1" = 'input' ]
then
	if [ "$2" = 'mute' ]
	then
		input_mute
		exit
	fi
fi

echo "Unsupported options!"
exit 11
