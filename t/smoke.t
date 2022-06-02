#!/usr/bin/env bash

# Copyright © 2022 Jakub Wilk <jwilk@jwilk.net>
# SPDX-License-Identifier: MIT

set -e -u

this="${0##*/}"
pdir="${0%/*}/.."
prog="$pdir/abmagick"

declare -a args
case $this in
    gm-*)
        cmd=gm
        args+=(--gm)
        ;;
    *)
        cmd=convert
        ;;
esac
if ! command -v "$cmd" > /dev/null
then
    echo "1..0 # SKIP $cmd(1) not found"
    exit
fi
version=$("$cmd" -version)
version=${version%%$'\n'*}
printf '# %s\n' "$version"

declare -i n=0
t()
{
    n+=1
    in="$tmpdir/$n.in"
    out="$tmpdir/$n.out"
    # shellcheck disable=SC2059
    printf "$@" > "$in"
    "$prog" "${args[@]}" "$out" < "$in" | sh
    if cmp -b "$in" "$out"
    then
        echo "ok $n"
    else
        echo "not ok $n"
    fi
}

echo 1..2
tmpdir=$(mktemp -d -t abmagick.test.XXXXXX)
t 'Hello world!'
t "$(printf '\\%03o' {0..255})"
rm -rf "$tmpdir"

# vim:ts=4 sts=4 sw=4 et ft=sh
