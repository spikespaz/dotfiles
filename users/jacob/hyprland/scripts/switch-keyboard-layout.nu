#! /usr/bin/env nu

def "math clamp" [min: number, max: number]: number -> number {
    [$min, ([$in, $max] | math min)] | math max
}

def "math cycle" [last: int]: int -> int {
    (($in mod ($last + 1)) + ($last + 1)) mod ($last + 1)
}

def "lockfile get-dir" [] {
    const dir_name = (path self | path basename | path parse).stem
    let path = $'/var/run/user/(id -u)/hypr/($env.HYPRLAND_INSTANCE_SIGNATURE)/($dir_name)'
    mkdir $path
    $path
}

def "lockfile get-path" [name] {
    $'(lockfile get-dir)/($name).lock'
}

def "lockfile read" [name] {
    let path = lockfile get-path $name

    if ($path | path exists) {
        open $path | from json
    } else {
        null
    }
}

def "lockfile write" [] {
    let name = $in.name
    $in | to json | save -f (lockfile get-path $name)
    $in
}

def "lockfile from-keyboard" [] {
    {
        name: $in.name
        address: $in.address
        selected: 0
        layouts: (
            let layouts = $in.layout | split row ,;
            let variants = $in.variant | split row ,;
            let options = $in.options | split row ,;

            0..(($layouts | length) - 1) | each {|index| {
                layout: ($layouts | get $index)
                variant: ($variants | get $index --ignore-errors | default $variants.0)
                options: ($options | get $index --ignore-errors | default $options.0)
            }}
        )
    }
}

def "lockfile is-stale" [a, b] {
    ($a | reject selected) != ($b | reject selected)
}


def "keyboard get-by-name" [name] {
    hyprctl -j devices
        | from json
        | get keyboards
        | where name == $name
        | first
}

def "keymap switch" [keyboard_name, --cycle (-c), index] {
    mut lock = lockfile read $keyboard_name
    mut index = $index

    if $index == 'prev' {
        $index = $lock.selected - 1
    } else if $index == 'next' {
        $index = $lock.selected + 1
    }

    let last = ($lock.layouts | length) - 1

    if $cycle {
        $index = $index | math cycle $last
    } else {
        $index = $index | math clamp 0 $last
    }

    hyprctl switchxkblayout $keyboard_name $index
    $lock.selected = $index

    $lock | lockfile write
}

def main [keyboard_name, --cycle (-c), index] {
    mut lock = lockfile read $keyboard_name
    let keyboard = keyboard get-by-name $keyboard_name | lockfile from-keyboard

    if $lock == null or (lockfile is-stale $lock $keyboard) {
        print $"Lock file for `($keyboard_name)` doesn't exist or is outdated."
        $lock = $keyboard | lockfile write
    }

    keymap switch $keyboard_name --cycle=$cycle $index

    print (lockfile read $keyboard_name | table -e)
}
