#!/bin/bash

[[ $_ble_bash ]] || return 1

source benchmark.sh

arr1[0]=1234

#------------------------------------------------------------------------------
# 1 declare +a を用いる方法

# broken この実装は呼び出し元のローカル変数が見えない。
#   また現在の関数のローカル変数も見えない。
#   更に、bash-4.2 以降でないと動かない。
function ble/is-array1 { ! declare -g +a "$1" &>/dev/null; }

ble-measure 'ble/is-array1 arr1' #  55.20 usec/eval
ble-measure 'ble/is-array1 arr2' #  51.80 usec/eval
ble-measure 'ble/is-array1 arr'  #  51.00 usec/eval

#------------------------------------------------------------------------------
# 2 compgen -A arrayvar を用いる方法 (不完全)

# broken 指定した名前で "始まる" 配列があれば真と判定されてしまう。
function ble/is-array2 { compgen -A arrayvar "$1" &>/dev/null; }

ble-measure 'ble/is-array2 arr1' # 1439.90 usec/eval
ble-measure 'ble/is-array2 arr2' # 1429.90 usec/eval
ble-measure 'ble/is-array2 arr'  # 1439.90 usec/eval

#------------------------------------------------------------------------------
# 3 compgen -A arrayvar を用いる方法 (完全)

function ble/is-array3 {
  compgen -A arrayvar "$1" >| "$_ble_util_read_stdout_tmp" 2>/dev/null || return 1
  local REPLY; read -r < "$_ble_util_read_stdout_tmp"
  [[ $REPLY == "$1" ]]
}

ble-measure 'ble/is-array3 arr1' # 1519.90 usec/eval
ble-measure 'ble/is-array3 arr2' # 1469.90 usec/eval
ble-measure 'ble/is-array3 arr'  # 1549.90 usec/eval

# 結論として compgen を使うのが一番のボトルネックになっているので、
# 一時ファイルに書き出してそれを読み出してチェックするというのは速度的な問題にはならない。
# それでも 1.5ms もかかっていることには注意する。例えば 600 の配列を確認すると 1 秒になる。

#------------------------------------------------------------------------------
# 4 compgen -A arrayvar -X ! を用いる方法 (完全)

function ble/is-array4 { compgen -A arrayvar -X \!"$1" "$1" 2>/dev/null; }

ble-measure 'ble/is-array4 arr1' # 1439.90 usec/eval
ble-measure 'ble/is-array4 arr2' # 1439.90 usec/eval
ble-measure 'ble/is-array4 arr'  # 1439.90 usec/eval

# 実は出力を確認しなくても良い。こちらの方が速い。
