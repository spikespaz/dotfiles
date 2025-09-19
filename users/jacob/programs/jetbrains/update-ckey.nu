#!/usr/bin/env nu

def fetch-configs [
    plugins: list<string>,
    base_url: string
]: nothing -> record {
    $plugins | reduce -f { } {|plugin, acc|
        let key = $plugin | str downcase
        let text = http get --raw $"($base_url)/config/($plugin).conf" | decode
        $acc | upsert $key $text
    }
}

def fetch-license-files [
    product_names: list<string>,
    product_codes: record,
    base_url: string,
    payload: record<
        license_name: string,
        assignee_name: oneof<string, nothing>,
        expiry_date: string
    >,
]: nothing -> record {
    $product_names | reduce -f {} {|name, acc|
        let name = $name | str downcase
        let data = http post -r -t "application/json" $base_url {
            licenseName: $payload.license_name,
            assigneeName: $payload.assignee_name,
            productCode: ($product_codes | get $name),
            expiryDate:  $payload.expiry_date,
        }
        $acc | upsert $name $data
    }
}

def try-save [--error (-e), --force, path: string]: any -> nothing {
    if ((not $force) and ($path | path exists)) {
        if $error {
            error make -u {
                msg: $"refusing to overwrite existing file: ($path)"
                help: "use `--force` to overwrite"
            }
        } else {
            print $"skipping existing file: ($path) \(use `--force` to overwrite\)"
        }
    } else {
        $in | save --force=$force $path
    }
}

def "main configs" [
    ...plugins: string,
    --base-url: string = "https://ckey.run/ja-netfilter",
    --out-file (-o): string = "plugin-configs.json",
    --force (-f),
]: nothing -> nothing {
    mut plugins = $plugins | uniq
    if ($plugins | is-empty) {
        $plugins = ["dns" "native" "power" "url"]
    }

    let configs = if ($out_file | path exists) { open $out_file } else { {} } | into record
    let updates = fetch-configs $plugins $base_url
    $configs | merge $updates | try-save -e --force=$force $out_file

    null
}

def "main license" [
    ...product_names: string,
    --product-codes: string = "product-codes.json",
    --all (-a),
    --license-name (-N): string,
    --assignee-name: oneof<string, nothing> = null,
    --expiry-date: string = "2099-12-31",
    --url: string = "https://ckey.run/generateLicense/file",
    --out (-o): string = "./",
    --force (-f),
]: nothing -> nothing {
    if ($license_name == null) {
        error make -u { msg: "`--license-name` is a required argument" }
    }

    let product_codes = open $product_codes | into record
    let product_names = if $all {
        $product_codes | columns
    } else {
        $product_names
    } | uniq

    let single = ($product_names | length) == 1

    if ($product_names | is-empty) {
        error make -u {
            msg: "no product names were specified"
            help: $"need one or more: ($product_codes | columns | str join ', ') or `--all`"
        }
    }
    if (not $single and (($out | path type) == "file"))  {
        error make -u {
            msg: "cannot generate multiple licenses into a single file"
            help: "either specify a directory with `--out` or generate a single license"
        }
    }

    let license_files = (
        fetch-license-files
            $product_names
            $product_codes
            $url
            {
                license_name: $license_name,
                assignee_name: $assignee_name,
                expiry_date: $expiry_date,
            }
    )

    if $single {
        let name = $product_names.0 | str downcase
        let data = $license_files | get $name
        let out_file = if (($out | path type) == "dir") {
            $out | path join ($name + ".key")
        } else {
            $out
        }
        $data | try-save -e --force=$force $out_file
    } else {
        if (not ($out | path exists)) { mkdir $out }
        $license_files | items {|name, data|
            let out_file = $out | path join ($name + ".key")
            $data | try-save --force=$force $out_file
        }
    }

    null
}

def main []: nothing -> error {
    error make -u  {
        msg: "no subcommand was specified"
        help: "available subcommands: config, license"
    }
}
