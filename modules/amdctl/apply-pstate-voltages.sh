# shellcheck shell=bash
set -eu

dry_run_args=()
mode=
values=()

while [[ $# -ne 0 ]]; do
	case $1 in
		--dry)
			dry_run_args+=(-t)
			shift
			;;
		inc)
			mode='inc'
			shift
			;;
		dec)
			mode='dec'
			shift
			;;
		set)
			mode='set'
			shift
			;;
		*)
			values+=("$1")
			shift
	esac
done

if [[ -z $mode ]]; then
	echo 'Missing positional parameter MODE, must be one of: inc, dec, or set'
	exit 1
fi

get_vid() {
	local output
	output="$(amdctl "-c$1" "-p$2" "-u$3")"
	if [[ "$output" =~ ^.+vid\ ([0-9]+).+$ ]]; then
		printf '%s' "${BASH_REMATCH[1]}"
	else
		return 1
	fi
}

# get the current pstate info
output=$(amdctl -g)

core=
pstate=
lowest_pstate=
voltages=()

# read lines of output
while read -r line; do
	# new pstate table for core, with lowest pstate
	if [[ "$line" =~ ^Core\ ([0-9]+).+Lowest\ ([0-9]+).+$ ]]; then
		core="${BASH_REMATCH[1]}"
		lowest_pstate="${BASH_REMATCH[2]}"
		# skip a line its empty
		read -r _ || break
		while read -r line; do
			# looks like a table row
			if [[ "$line" =~ ^([0-9]+).+\ +([0-9]+)mV.+$ ]]; then
				pstate="${BASH_REMATCH[1]}"
				voltage="${BASH_REMATCH[2]}"
				voltages+=("$core $pstate $voltage")
				# we are at the end of the table
				[[ $pstate -eq $lowest_pstate ]] && break
			fi
		done
	fi
	# empty lines or those not matching are skipped
done <<< "$output"

failed=()
commands=()

for tuple in "${voltages[@]}"; do
	read -r -a tuple <<< "$tuple"
	core="${tuple[0]}"
	pstate="${tuple[1]}"
	voltage="${tuple[2]}"

	echo
	echo "Core $core, Pstate $pstate, CpuVolt ${voltage}mV"

	value="${values[$pstate]}"
	case "$mode" in
		inc)
			voltage=$((voltage + value))
			;;
		dec)
			voltage=$((voltage - value))
			;;
		set)
			voltage=$value
			;;
	esac

	if vid="$(get_vid "$core" "$pstate" "$voltage")"; then
		commands+=("amdctl ${dry_run_args[@]} -c$core -p$pstate -v$vid")
		echo "CpuVolt = ${voltage}mV"
		echo "CpuVid  = ${vid}"
	else
		failed+=("$core $pstate $voltage")
		echo "FAILURE: could not find CpuVid for ${voltage}mv"
	fi
done

# shellcheck disable=SC2015
[[ ${#failed[@]} -ne 0 ]] && exit 33 || true

for command in "${commands[@]}"; do
	$command
done
