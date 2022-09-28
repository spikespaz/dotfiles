#! /bin/bash
set -eux

TIMEOUT=700
URGENCY=low

is_muted() {
	[ -z "$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep '[MUTED]')" ] \
		|| printf 0
}

volume_mute() {
	wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

	if [ $(is_muted) ]
	then
		title='Volume Disable'
	else
		title='Volume Enable'
	fi

	notify-send \
		"$title" \
		-u $URGENCY \
		-t $TIMEOUT \
		-c devices \
		-i audio-speakers \
		-h string:synchronous:change-volume
}

volume_change() {
	value="$1"
	current=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}')

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
			wpctl set-volume @DEFAULT_AUDIO_SINK@ 1.0
			echo 'Volume already at maximum'
			exit
		fi
		title='Volume Increase'
		value=$(bc <<< "$current + $value")
	elif [ $mode = decrease ]
	then
		if [ $(bc <<< "$current <= 0.0" ) -eq 1 ]
		then
			wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.0
			echo 'Volume already at minimum'
			exit
		fi
		title='Volume Decrease'
		value=$(bc <<< "$current - $value")
	else
		title='Volume Change'
	fi

	wpctl set-volume @DEFAULT_AUDIO_SINK@ $value

	percent=$(bc <<< "$value * 100 / 1")
	message="<span size='200%'>$percent%</span>"
	[ $(is_muted) ] && message+=' (muted)'

	notify-send \
		"$title" \
		"$message" \
		-u $URGENCY \
		-t $TIMEOUT \
		-c devices \
		-i audio-speakers \
		-h int:value:$percent \
		-h string:synchronous:change-volume
}

if [ $1 = volume ]
then
	if [ $2 = mute ]
	then
		volume_mute $2
	else
		volume_change $2
	fi
fi
