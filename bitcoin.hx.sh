#!/usr/bin/env bash
# v0.9.4  feb/2023  by castaway
# create base58 address types from public key,
# create WIF from private keys and more
# requires Bash v4+

#defaults
#user-side, set $VER
#public address version byte (prefix)
VERDEF=00
#private address version byte (prefix)
VERPRIDEF=80
#compressed public key (suffix)
VERCOMP=01

#script name
SN="${0##*/}"

#make sure locale is set correctly
export LC_NUMERIC=C  LANG=C
#export LC_NUMERIC=en_US.UTF-8  LANG=en_US.UTF-8

#base58 character set [1-9A-HJ-NP-Za-km-z]
B58='123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'
#bech32 character set [AC-HJ-NP-Zac-hj-np-z02-9]

#ASCII character set [\x00-\x7F]
#literal newline and blank space
ASCIISET="${IFS}!\"#$%&'()*+,./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_\`abcdefghijklmnopqrstuvwxyz{|}~-"

#Common address prefix values
VERBYTES=(00 05 80 80 0488B21E 0488ADE4 6F C4 EF EF 043587CF 04358394)
#https://en.bitcoin.it/wiki/List_of_address_prefixes
#https://www.oreilly.com/library/view/mastering-bitcoin/9781491902639/ch04.html

#help
HELP="$SN - create base58 address types from public key,
		WIF from private keys and more


DESCRIPTION
	$SN [-1e] STRING..
	$SN [-ace] [-vNUM] [STRING|HASH160]..
	$SN [-bepp] [-vNUM] [STRING|WIF|FILE]..
	$SN [-abP] [-vNUM] [STRING|WIF|HASH160|FILE]..
	$SN [-ewwx] [-vNUM] STRING..
	$SN [-26be] [STRING|FILE|HEX]..
	$SN [-beyY] [STRING|FILE|HEX]..
	$SN -h


	Create public and private addresses from BYTE HEX strings (keys),
	checks checksum of WIF, convert private key to WIF, decode base58
	to text and more.

	If no option is given, defaults to converting BYTE HEX (public ad-
	dress key) to public address.

	Set multiple positional parameters or pipe a single one via stdin.
	FILE names are read into input. Detection of input types such as
	BYTE HEX, SHA256SUM, WIF and TEXT STRING is attempted in some
	functions (see also -ab).

	Options -26ppPY are sensitive to ending newline bytes. Beware
	that Bash trucates input at null bytes. If input has null bytes,
	set it as FILE.

	Only legacy type addresses (P2PKH) are generally supported throughout
	this script (addresses starting with 1). Option -c may not validate
	segwit addresses (P2SH,	starting with 3). Native segwit (bech32,
	starting with bc1) addresses will throw errors.

	This script warps around Grondilu's bitcoin-bash-tools functions.
	The script has got many original functions, too.


	Public Keys (Defaults)

	When no option is given, the defaults function is to convert HEX
	to public address.

	Option -a sets input as HASH160 when creating a base58 address
	from it in the main function. This options also affects -P.


	Private Keys

	A private key may be anything of various types. For example, a
	photograph may be the original private key, but its HEX dump and
	SHA256SUM are also private keys.

	Option -p generates a Wallet Import Format (WIF) address from a
	private key. Private key must be a SHA256 sum. If a TEXT STRING
	or a FILE name is used instead, the SH256 sum will calculated and
	used as private key. Set -pp to generate compressed private address.

	Set -P to generate public addresses from input. Input must be TEXT
	STRING, HEX (must start with 0X, else set -b), SHA256, WIF or FILE
	name (autodetect). If input is HASH160, set -a. This function can
	be used as brain wallet generator.

	Option -x checks checksum of WIF key.

	Option -w convert uncompressed or compressed WIF to private key.


	Decode and Encode BASE58 Input

	Option -y decodes BASE58 encoded STRING or FILE to text.

	Option -Y encodes TEXT STRING, BYTE HEX or FILE to BASE58, (see -b).
	Beware this and other options are sensitive to ending newlines bytes.
	

	Miscellaneous

	Option -1 prints HASH160 of public and private base58 addresses.
	This converts a bitcoin address to the HASH160 format used inter-
	nally by bitcoin (decodes BASE58 address and removes version byte).

	Option -2 generates the double SHA256 sum of TEXT STRING, FILE or
	BYTE HEX (see -b).
	
	Option -6 generates HASH160 from TEXT STRING, FILE or BYTE HEX (the
	RIPEMD160 of SHA256 sum of input, see also option -b).

	Option -b flags input as BYTE HEX explicitly with -26ppPY. This
	option is not needed if input starts with 0X.

	Option -c checks checksum of public and private base58 keys,
	address validation.

	Option -e for verbose and option -h for this help page.

	Option -vNUM sets version byte, in which NUM is a byte version
	number such as 00, 05 and ef.


ENVIRONMENT
	VER 	Public keys, defaults=${VERDEF}
		Private keys, defaults=${VERPRIDEF}


SEE ALSO
	Address Prefixes
	<https://en.bitcoin.it/wiki/List_of_address_prefixes>
	<https://www.oreilly.com/library/view/mastering-bitcoin/9781491902639/ch04.html>
	<https://en.bitcoin.it/wiki/Invoice_address>

	Graphical Address Generator
	<https://royalforkblog.github.io/2014/08/11/graphical-address-generator/>
	<https://github.com/kennethhutw/BitcoinBrainwallet>
	<https://allprivatekeys.com/try-your-passphrase>

	Private and Public Key Generation and WIF
	<https://en.bitcoin.it/wiki/Wallet_import_format>
	<https://gist.github.com/t4sk/ac6f2d607c96156ca15f577290716fcc>
	<http://gobittest.appspot.com/PrivateKey>
	<https://bitcointalk.org/index.php?topic=2664728.msg27178628#msg27178628>
	<https://github.com/JeanLucPons/VanitySearch>
	<https://www.secretscan.org/Bech32>
	<https://bitcoin.stackexchange.com/questions/78585/what-happens-when-hash160-is-same>
	<https://medium.com/coinmonks/how-to-generate-a-bitcoin-address-step-by-step-9d7fcbf1ad0b>

	BASE58 Conversion Specs and Examples
	<https://tools.ietf.org/id/draft-msporny-base58-01.html>
	<https://www.appdevtools.com/base58-encoder-decoder>
	<https://www.dcode.fr/base-58-cipher>
	<https://incoherency.co.uk/base58/>
	<https://en.bitcoin.it/wiki/Base58Check_encoding>
	<https://github.com/keis/base58>

	Basic Information on Generating Addresses
	<https://en.bitcoin.it/wiki/Technical_background_of_version_1_Bitcoin_addresses>

	BIP39 Tool
	<https://github.com/iancoleman/bip39>

	Grondilu's bitcoin-bash-tools
	<https://github.com/grondilu/bitcoin-bash-tools>

	Validating Bitcoin Address
	<https://bitcointalk.org/index.php?topic=1026.0>

	Bech32 Patterns and Names
	<https://www.reddit.com/r/Bitcoin/comments/6xrl60/so_bech32_address_formats_are_already_live_on/dmilfor>


BUGS
	Options -26ppPyY will truncate input at null bytes (Bash limitation).
	Set input as FILE to circunvent that.


WARRANTY
	Packages GNU dc (GNU coreutils), openssl, xxd and bash 4+ are
	required.

	Licensed under the gnu general public license 3 or better and is
	distributed without support or bug corrections. Grondilu's bit-
	coin-bash-tools functions are embedded in this script.
	
	Be aware this script is for studying purposes and there is no
	guarantee this is working properly. DYOR and check output!

	If you found this programme interesting, please consider sending
	feedback!  =)


USAGE EXAMPLES
	1) Generate public address from public key BYTE HEX (defaults
	function):

		$ $SN 0496b538e853519c726a2c91e61ec11600ae1390813a627c66fb8be7947be63c52da7589379515d4e0a604f8141781e62294721166bf621e73a82cbf2342c858ee

		12c6DSiU4Rq3P4ZxziKxzrL5LmMBrzjrJX


	2) Make public address, version byte 05 (P2SH, pay to script hash):
	
		$ $SN -v05 00142b2296c588ec413cebd19c3cbc04ea830ead6e78
		$ VER=05 $SN 00142b2296c588ec413cebd19c3cbc04ea830ead6e78
			
		3FfQGY7jqsADC7uTVqF3vKQzeNPiBPTqt4


	3) Make public address, set input as HASH160, ver byte 05 (P2SH):

		$ $SN -av05 354937d51cf40b4c442f8a97988b9be588367ba1

		36YmSzZVaPbv9EyG8sNGSLHTKD3PkBAAmQ


	4) Get HASH160 of address:

		$ $SN -1 12c6DSiU4Rq3P4ZxziKxzrL5LmMBrzjrJX

		0119b098e2e980a229e139a9ed01a469e518e6f26


	5) Encode text to BASE58:

		$ $SN -Y \"The quick brown fox jumps over the lazy dog.\" 
		
		USm3fpXnKG5EUBx2ndxBDMPVciP5hGey2Jh4NDv6gmeo1LkMeiKrLJUUBk6Z


	6) Encode FILE to BASE58:

		$ $SN -Y file.txt


	7) Decode BYTE HEX to text:

		$ $SN -yb 0x48656c6c6f20576f726c6421
	
		Hello World!	
	

	8) Generate public address from private key:

		A) From TEXT STRING
		$ $SN -P 'Hello World!'

		B) From WIF
		$ $SN -P L1VaiyvJbK1FE9rGneh3E29xFUX2b9eCUvaeWiumH7kqrTkGgDba

		C) From BYTE HEX
		$ $SN -P 0x48656c6c6f20576f726c6421
		$ $SN -Pb 48656c6c6f20576f726c6421

		D) From HASH160
		$ $SN -Pa 0x0000000000000000000000000000000000000000
		$ $SN -Pa 0000000000000000000000000000000000000000


OPTIONS
	Public Keys (defaults main function)
	Generate public address from public address BYTE HEX.
	-a 	Set/flag input as HASH160 (affects main function and -P)
	
	Private Keys
	-p	Generate Wallet Import Format (WIF) from input private key.
	-pp 	Generate compressed WIF from private key.
	-P 	Generate public address from private key or WIF (see -ab).
	-x 	Check WIF checksum.
	-w	Generate private key from (un)compresssed WIF.
	
	Decode and Encode BASE58
	-b 	Flag input as BYTE HEX (with -26ppPY).
	-y	Decode BASE58-encoded STRING or FILE to text.
	-Y	Encode STRING, FILE or BYTE HEX to BASE58.

	Misc
	-1 	Print HASH160 of public or private base58 address.
	-2 	Generate double SHA256 sum from STRING, FILE or BYTE HEX.
	-6 	Generate HASH160 from any STRING, FILE or BYTE HEX.
	-c 	Validate public or private base58 address (check checksum).
	-e 	Verbose.
	-h 	This help page.
	-v NUM 	Set version byte, defaults=${VERDEF} (public keys)
		and defaults=${VERPRIDEF} (private keys)."


##functions
#!#bitcoin.sh snapshot with modifications
#
# Various bash bitcoin tools
#
# requires dc, the unix desktop calculator (which should be included in the
# 'bc' package)
#
# This script requires bash version 4 or above.
#
# This script uses GNU tools.  It is therefore not guaranted to work on a POSIX
# system.
#
# Copyright (C) 2013 Lucien Grondin (grondilu@yahoo.fr)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

pack() {
    echo -n "$1" | xxd -r -p
}
#custom
cpackf() {
    echo "$@" | xxd -r -p
}

#custom, added array `$@' to `xxd' cmd
unpack() {
    xxd -p "$@" | tr -d '\n'
}

declare -a base58=(
    1 2 3 4 5 6 7 8 9
  A B C D E F G H   J K L M N   P Q R S T U V W X Y Z
  a b c d e f g h i j k   m n o p q r s t u v w x y z
)
unset dcr; for i in ${!base58[@]}; do dcr+="${i}s${base58[i]}"; done
declare ec_dc='
I16i7sb0sa[[_1*lm1-*lm%q]Std0>tlm%Lts#]s%[Smddl%x-lm/rl%xLms#]s~
483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8
79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798
2 100^d14551231950B75FC4402DA1732FC9BEBF-so1000003D1-ddspsm*+sGi
[_1*l%x]s_[+l%x]s+[*l%x]s*[-l%x]s-[l%xsclmsd1su0sv0sr1st[q]SQ[lc
0=Qldlcl~xlcsdscsqlrlqlu*-ltlqlv*-lulvstsrsvsulXx]dSXxLXs#LQs#lr
l%x]sI[lpSm[+q]S0d0=0lpl~xsydsxd*3*lal+x2ly*lIx*l%xdsld*2lx*l-xd
lxrl-xlll*xlyl-xrlp*+Lms#L0s#]sD[lpSm[+q]S0[2;AlDxq]Sdd0=0rd0=0d
2:Alp~1:A0:Ad2:Blp~1:B0:B2;A2;B=d[0q]Sx2;A0;B1;Bl_xrlm*+=x0;A0;B
l-xlIxdsi1;A1;Bl-xl*xdsld*0;Al-x0;Bl-xd0;Arl-xlll*x1;Al-xrlp*+L0
s#Lds#Lxs#Lms#]sA[rs.0r[rl.lAxr]SP[q]sQ[d0!<Qd2%1=P2/l.lDxs.lLx]
dSLxs#LPs#LQs#]sM[lpd1+4/r|]sR
';

#S2 S2 S2
#https://github.com/grondilu/bitcoin-bash-tools/issues/19
decodeBase58() {
  echo -n "$1" | sed -e's/^\(1*\).*/\1/' -e's/1/00/g' | tr -d '\n'
  echo "$1" |
  {
    echo "$dcr 0"
    sed 's/./ 58*l&+/g'
    echo "[256 ~r d0<x]dsxx +f"
  } | dc |
  while read n
  do printf "%02X" "$n"
  done
}

#obs:grondilu's newer versions of encodeBase58() fun are much slower
#custom (for option -Y), echo large strings to dc
encodeBase58() {
    local n
    echo -n "$1" | sed -e's/^\(\(00\)*\).*/\1/' -e's/00/1/g' | tr -d '\n'
    dc <<<"16i ${1^^} [3A ~r d0<x]dsxx +f" |
    while read -r n; do echo -n "${base58[n]}"; done
}

checksum() {
    pack "$1" |
    openssl dgst -sha256 -binary |
    openssl dgst -sha256 -binary |
    unpack |
    head -c 8
}

toEthereumAddressWithChecksum() {
    local addrLower=$(sed -r -e 's/[[:upper:]]/\l&/g' <<< "$1")
    local addrHash=$(echo -n "$addrLower" | openssl dgst -sha3-256 -binary | xxd -p -c32)
    local addrChecksum=""
    local i c x
    for i in {0..39}; do
        c=${addrLower:i:1}
        x=${addrHash:i:1}
        [[ $c =~ [a-f] ]] && [[ $x =~ [89a-f] ]] && c=${c^^}
        addrChecksum+=$c
    done
    echo -n $addrChecksum
}

checkBitcoinAddress() {
    if [[ "$1" =~ ^[$(IFS= ; echo "${base58[*]}")]+$ ]]
    then
        local h="$(decodeBase58 "$1")"
        checksum "${h:0:-8}" | grep -qi "^${h:${#h}-8}$"
    else return 2
    fi
}

hash160() {
    openssl dgst -sha256 -binary |
    openssl dgst -rmd160 -binary |
    unpack
}

hexToAddress() {
    local x="$(printf "%2s%${3:-40}s" ${2:-00} $1 | sed 's/ /0/g')"
    encodeBase58 "$x$(checksum "$x")"
    echo
}

#custom, changed `cat' to `echo', removed right-side space, add bech32 address support
newBitcoinKey() {
    if [[ "$1" =~ ^[5KL] ]] && checkBitcoinAddress "$1"
    then
        local decoded="$(decodeBase58 "$1")"
        if [[ "$decoded" =~ ^80([0-9A-F]{64})(01)?[0-9A-F]{8}$ ]]
        then $FUNCNAME "0x${BASH_REMATCH[1]}"
        fi
    elif [[ "$1" =~ ^[0-9]+$ ]]
    then $FUNCNAME "0x$(dc -e "16o$1p")"
    elif [[ "${1^^}" =~ ^0X([0-9A-F]{1,})$ ]]
    then
        local exponent="${BASH_REMATCH[1]}"
        local full_wif="$(hexToAddress "$exponent" 80 64)"
        local comp_wif="$(hexToAddress "${exponent}01" 80 66)"

        dc -e "$ec_dc lG I16i${exponent^^}ri lMx 16olm~ n[ ]nn" |
        {
            read y x
            X="$(printf "%64s" $x | sed 's/ /0/g')"
            Y="$(printf "%64s" $y | sed 's/ /0/g')"
            [[ "$y" =~ [02468ACE]$ ]] && y_parity="02" || y_parity="03"
            full_pubkey="04${X}${Y}"
            comp_pubkey="${y_parity}${X}"
            full_p2pkh_addr="$(hexToAddress "$(pack "$full_pubkey" | hash160)")"
            comp_p2pkh_addr="$(hexToAddress "$(pack "$comp_pubkey" | hash160)")"
            full_p2sh_addr="$(hexToAddress "$(pack "41${full_pubkey}AC" | hash160)" 05)"
            comp_p2sh_addr="$(hexToAddress "$(pack "21${comp_pubkey}AC" | hash160)" 05)"
            # Note: Witness uses only compressed public key
            comp_p2wpkh_addr="$(hexToAddress "$(pack "0014$(pack "$comp_pubkey" | hash160)" | hash160)" 05)"
            full_multisig_1_of_1_addr="$(hexToAddress "$(pack "5141${full_pubkey}51AE" | hash160)" 05)"
            comp_multisig_1_of_1_addr="$(hexToAddress "$(pack "5121${comp_pubkey}51AE" | hash160)" 05)"
            qtum_addr="$(hexToAddress "$(pack "${comp_pubkey}" | hash160)" 3a)"
            ethereum_addr="$(pack "$X$Y" | openssl dgst -sha3-256 -binary | unpack | tail -c 40)"
            tron_addr="$(hexToAddress "$ethereum_addr" 41)"
			echo "---
secret exponent:          0x$exponent
public key:
    X:                    $X
    Y:                    $Y

compressed addresses:
    WIF:                  $comp_wif
    Bitcoin (P2PKH):      $comp_p2pkh_addr
    Bitcoin (P2SH [PKH]): $comp_p2sh_addr
    Bitcoin (P2WPKH):     $comp_p2wpkh_addr
    Bitcoin (1-of-1):     $comp_multisig_1_of_1_addr
    Bitcoin (Bech32):     $(
	#BECH32 address generation function

	WIF_PREFIX="\x80" P2PKH_PREFIX="\x00" P2SH_PREFIX="\x05" BECH32_PREFIX="bc"
	#if [[ "$BITCOIN_NET" = 'TEST' ]]
	#then WIF_PREFIX="\xEF" P2PKH_PREFIX="\x6F" P2SH_PREFIX="\xC4" BECH32_PREFIX="tb"
	#fi

	xxd -p -r <<<"$comp_pubkey" |
		openssl dgst -sha256 -binary | openssl dgst -rmd160 -binary |
		segwit_encode "$BECH32_PREFIX" 0
		
	#grondilu's notes:
	#pay-to-witness-script-hash (P2WSH) NYI
	#For version 0, the witness program must be either 20 or 32 bytes long
	#!#warning: we are skipping counting hash160 length, not needed for this simple use case
	#witness version NYI
)
 ---- other networks ----
    Qtum:                 $qtum_addr

uncompressed addresses:
    WIF:                  $full_wif
    Bitcoin (P2PKH):      $full_p2pkh_addr
    Bitcoin (P2SH [PKH]): $full_p2sh_addr
    Bitcoin (1-of-1):     $full_multisig_1_of_1_addr
 ---- other networks ----
    Ethereum:             0x$(toEthereumAddressWithChecksum $ethereum_addr)
    Tron:                 $tron_addr"
           
        }
    elif test -z "$1"
    then $FUNCNAME "0x$(openssl rand -rand <(date +%s%N; ps -ef) -hex 32 2>&-)"
    else
        echo unknown key format "$1" >&2
        return 2
    fi
}
#CHECK BECH32 ADDR ACCORDING TO:
#test: https://bitcointalk.org/index.php?topic=2664728.msg27178628#msg27178628
#test: https://github.com/JeanLucPons/VanitySearch
#test: https://www.secretscan.org/Bech32
#test: Electrum

#option -P -a (generate public addresses from hash160)
#binary hash160 --> segwit_encode
#{ xxd -r -p <<<0x0000000000000000000000000000000000000000 | segwit_encode "$BECH32_PREFIX" 0 ;}
newBitcoinKeyHx160()
{
	local hash160 exponent
	hash160="${1#0[xX]}"
	[[ "0X${hash160^^}" =~ ^0X([0-9A-F]{1,})$ ]] || return
	exponent="${BASH_REMATCH[1]}"
	dc -e "$ec_dc lG I16i${exponent^^}ri lMx 16olm~ n[ ]nn" |
	{
		read y x
		X="$(printf "%64s" $x | sed 's/ /0/g')"
		Y="$(printf "%64s" $y | sed 's/ /0/g')"
		full_p2pkh_addr="$(hexToAddress "$hash160")"
		full_p2sh_addr="$(hexToAddress "$hash160" 05)"
		full_multisig_1_of_1_addr="$(hexToAddress "$hash160" 05)"
		qtum_addr="$(hexToAddress "$hash160" 3a)"
		ethereum_addr="$(pack "$X$Y" | openssl dgst -sha3-256 -binary | unpack | tail -c 40)"
		tron_addr="$(hexToAddress "$ethereum_addr" 41)"
		echo "===
type:                     hash160
secret exponent:          0x$exponent
public key:
    X:                    $X
    Y:                    $Y

addresses:
    Bitcoin (P2PKH):      $full_p2pkh_addr
    Bitcoin (P2SH [PKH]): $full_p2sh_addr
    Bitcoin (1-of-1):     $full_multisig_1_of_1_addr
    Bitcoin (Bech32):     $(
	WIF_PREFIX="\x80" P2PKH_PREFIX="\x00" P2SH_PREFIX="\x05" BECH32_PREFIX="bc"
	xxd -p -r <<<"$hash160" | segwit_encode "$BECH32_PREFIX" 0
	)
 ---- other networks ----
    Ethereum:             0x$(toEthereumAddressWithChecksum $ethereum_addr)
    Tron:                 $tron_addr
    Qtum:                 $qtum_addr"
	}
}
#test: https://bitcoin.stackexchange.com/questions/78585/what-happens-when-hash160-is-same

## bech32.sh
# BECH32
# see https://en.bitcoin.it/wiki/BIP_0173
readonly -a bech32=(
  q p z r y 9 x 8
  g f 2 t v d w 0
  s 3 j n 5 4 k h
  c e 6 m u a 7 l
)
declare -A bech32A
for i in {0..31}
do bech32A[${bech32[i]}]=$i
done
# character class allowed for human readable part
# hopefully this should match the ASCII range 33 .. 126
readonly HRP_CHAR_CLASS="[[:alnum:][:punct:]$+<=>^\`|~]"

bech32_polymod() {
  readonly -a GEN=(0x3b6a57b2 0x26508e6d 0x1ea119fa 0x3d4233dd 0x2a1462b3)
  local    -i chk=1 b i v
  while read v
  do
    ((
      b=chk >> 25,
      chk=(chk & 0x1ffffff) << 5^v
    ))
    for i in {0..4}
    do ((chk^= (b >> i) & 1 ? GEN[i] : 0))
    done
  done
  echo $chk
}

bech32_hrp_expand() {
  mapfile -t values
  for x in ${values[@]}
  do echo $(( x >> 5 ))
  done
  echo 0
  for x in ${values[@]}
  do echo $(( x & 31 ))
  done
}

bech32_create_checksum() {
  local hrp="${1%1*}" data="${1##*1}"
  {
    echo -n "$hrp" |
    while read -n 1
    do LC_TYPE=C printf '%d\n' "'$REPLY"
    done |
    bech32_hrp_expand

    echo -n "${1##*1}" |
    while read -n 1 c
    do echo ${bech32A[$c]}
    done
    
    for i in {1..6}; do echo 0; done
  } |
  bech32_polymod |
  {
    read
    local -i polymod=$(($REPLY ^ 1))
    local -a checksum
    for i in {0..5}
    do checksum[i]=$(( (polymod >> 5 * (5 - i)) & 31 ))
    done
    for c in ${checksum[@]}
    do echo -n ${bech32[$c]}
    done
  }
}


## bip0173.sh
segwit_encode() {
  local hrp="$1" version="$2"
  [[ "$hrp"     =~ ^$HRP_CHAR_CLASS{1,83}$ ]] || return 1 # unexpected format for hrp
  [[ "$version" =~ ^0|[1-9][[:digit:]]*$   ]] || return 2 # unexpected format for version
  # P2WPKH
  {
    echo -n "${hrp}1${bech32[$version]}"
    xxd -p -c 1 |
    while read
    do printf "%d\n" 0x$REPLY
    done |
    convert_bits 8 5 |
    while read i
    do echo -n ${bech32[i]}
    done
  } |
  {
    read
    echo -n "$REPLY"
    bech32_create_checksum "$REPLY"
    echo
  }
}

convert_bits() {
  local -i inbits=$1 outbits=$2 pad=${3:-1} val=0 bits=0 i
  readonly maxv=$(((1 << outbits) - 1))
  while read 
  do
    val=$(((val<<inbits)|$REPLY))
    ((bits+=inbits))
    while ((bits >= outbits))
    do
      (( bits-=outbits ))
      echo $(( (val >> bits) & maxv ))
    done
  done
  if test -n "$pad"
  then
    if ((bits))
    then echo $(( (val << (outbits - bits)) & maxv ))
    fi
  elif (( ((val << (outbits - bits)) & maxv ) || bits >= inbits))
  then 
    1>&2 echo unexpected outcome
    return 1
  fi
}


#script original funcs

#Base58 Mapping Table
#func()
#{
#	local b char input
#	input="$1"
#	while read -n1 char
#	do
#		case "$char" in
#			1) b=0;;   2) b=1;;   3) b=2;;
#			4) b=3;;   5) b=4;;   6) b=5;;
#			7) b=6;;   8) b=7;;   9) b=8;;
#			A) b=9;;   B) b=10;;  C) b=11;;
#			D) b=12;;  E) b=13;;  F) b=14;;
#			G) b=15;;  H) b=16;;  J) b=17;;
#			K) b=18;;  L) b=19;;  M) b=20;;
#			N) b=21;;  P) b=22;;  Q) b=23;;
#			R) b=24;;  S) b=25;;  T) b=26;;
#			U) b=27;;  V) b=28;;  W) b=29;;
#			X) b=30;;  Y) b=31;;  Z) b=32;;
#			a) b=33;;  b) b=34;;  c) b=35;;
#			d) b=36;;  e) b=37;;  f) b=38;;
#			g) b=39;;  h) b=40;;  i) b=41;;
#			j) b=42;;  k) b=43;;  m) b=44;;
#			n) b=45;;  o) b=46;;  p) b=47;;
#			q) b=48;;  r) b=49;;  s) b=50;;
#			t) b=51;;  u) b=52;;  v) b=53;;
#			w) b=54;;  x) b=55;;  y) b=56;;
#			z) b=57;;
#			*) b=  ;
# 				echo "err: illegal base58 char -- \"$char\"" >&2
#				return 1
#				;;
#		esac
#		echo -n "$b"
#	done <<<"$input"
#	echo
#}
#https://tools.ietf.org/id/draft-msporny-base58-01.html

#check whether there are newline bytes. It wont detect newline bytes
#if file is a Process Substitution of the form <(...) because
#lseek is not available to reread file
#nlcheckf()
#{
#	tail -c1 -- "$1" | read && unset NONL || NONL=1
#}

#-1 get hash160 from public or private address
#reverse direction
revf()
{
	local hx160 input input_filename type
	input="$1"

	#is input a filename?
	if [[ -e "$input" ]]
	then input_filename="$input" input="$(<"$input_filename")"
	fi

	#check base58 input string
	#get addr type
	if ! type="$(ispubkeyf "$input" || iswiff "$input" || isbase58f "$input")"
	then echo "err: invalid input -- $input" >&2 ;return 1
	fi

	#decode base58
	hx160="$(decodeBase58 "$input")"
	#remove byte number and checksum
	hx160="$(sed -E 's/^.?.(.{40}).{8}$/\1/' <<<"$hx160")"

	#print result
	if (( OPTVERBOSE ))
	then
		echo "--------
TYPE___: $type
INPUT__: ${input_filename:-$input}
HASH160: $hx160"
	else
		echo "$hx160"
	fi
}

#-2 generate double sha256 sum
#main func
sha256df()
{
	local input input_filename sha256d type
	typeset -au sha256d  #array, uppercase
	type='text string'
	input="$1"

	#if input is a file
	if [[ -e "$input" ]]
	then
		type=file
		input_filename="$input"

		#is input byte hex?
		if ishexf $(head -c 200 "$input_filename")
		then
			type='hex file'
			#pack input and then double-sha256
			sha256d=( $(
				xxd -r -p "$input_filename" |
					openssl dgst -sha256 -binary |
					openssl dgst -sha256
			) )
		else
			sha256d=( $(
				openssl dgst -sha256 -binary "$input_filename" |
				openssl dgst -sha256
			) )
		fi

	#hex from stdin and pos args
	else
		#is input byte hex?
		if ishexf "$input"
		then type=hex input="$(pack "$input")"
		fi

		sha256d=( $(
			echo ${NONL:+-n} "$input" |
				openssl dgst -sha256 -binary |
				openssl dgst -sha256
		) )
	fi

	#print result
	if ((OPTVERBOSE))
	then
		echo "--------
TYPE___: $type
INPUT__: ${input_filename:-$input}
DSHA256: ${sha256d[-1]}"
	else
		echo "${sha256d[-1]}"
	fi
}
#test: http://www.herongyang.com/Bitcoin/Block-Data-Calculate-Double-SHA256-with-Python.html
#test: https://github.com/dominictarr/sha256d
#test: https://btcleak.com/2020/06/10/double-sha256-in-bash-and-python/
#also: `echo -n myfirstSHA | sha256sum | xxd -r -p | sha256sum`
#https://bitcoin.stackexchange.com/questions/5671/how-do-you-perform-double-sha-256-encoding
#https://en.bitcoin.it/wiki/Protocol_documentation#Hashes
#https://btcleak.com/2020/06/10/double-sha256-in-bash-and-python/

#-6 generate hash160
#main func
genhash160f()
{
	local dump input input_filename hx160 type
	type='text string'
	input="$1"

	#if input is a file
	if [[ -e "$input" ]]
	then
		type=file
		input_filename="$input"

		#is input is byte hex?
		if ishexf $(head -c 200 "$input_filename")
		then type='hex file' input="$(<"$input_filename")"
		else dump="$(unpack "$input_filename")"
		fi
	else
		#is input byte hex or text string?
		if ishexf "$input"
		then type=hex
		else dump="$(echo ${NONL:+-n} "$input" | unpack)"
		fi
	fi

	#make hash160
	hx160="$(pack "${dump:-$input}" | hash160)"

	#print result
	if (( OPTVERBOSE ))
	then
		echo "--------
TYPE___: $type
INPUT__: ${input_filename:-$input}
HEXDUMP: ${dump:-$input}
HASH160: $hx160"
	else
		echo "$hx160"
	fi
}
#test: https://learnmeabitcoin.com/technical/public-key-hash
#test: https://en.bitcoin.it/wiki/Technical_background_of_version_1_Bitcoin_addresses

#-Yy encode decode base58
base58f()
{
	local bytestr input input_filename type output
	type='text string' input="$1"

	#encode or decode?
	if ((ENCODEOPT==2))
	then
		#-Y encode to base58
		#is ``input'' a filename
		if [[ -e "$input" ]]
		then
			type=file input_filename="$input"
			#is ``file content'' byte hex?
			if ishexf $(head -c 200 "$input_filename")
			then { type='hex file' bytestr="$(<"$input_filename")" ;} 2>/dev/null
			else bytestr="$(unpack "$input_filename")"
			fi
		#is ``input'' byte hex?
		elif ishexf "$input"
		then type=hex bytestr="$input"
		else bytestr="$(echo ${NONL:+-n} "$input" | unpack)"
		fi

		#convert hex to base58 (remove leading 0x); get error msg
		output="$(encodeBase58 "${bytestr#0[Xx]}" 2>&1)"
		#empty newline is the same as : "true" for dc
		#so check output for err msg (this code needs rechecking..)
		[[ "$output" = dc:* ]] && output=B 

		#print option
		if ((OPTVERBOSE))
		then
			echo "--------
TYPE___: $type
INPUT__: ${input_filename:-$input}
HEXDUMP: $bytestr
BASE58_: $output"
			#check if text is ascii
			[[ "$input" = *[^"$ASCIISET"]* ]] && echo "info -- input may contain non-ascii chars" >&2
			##transliterate diacritics with iconv (utf8 to ascii):
			#{ iconv -f utf-8 -t ascii//translit ;}
		else
			#plain base58 result
			echo "$output"
		fi
		
	else
		#-y decode base58

		#is ``input'' a filename?
		if [[ -e "$input" ]]
		then type=file input_filename="$input" input="$(<"$input_filename")"
		fi
		#check base58 input string and convert base58 to hex
		if isbase58f "$input" >/dev/null
		then bytestr="$(decodeBase58 "${input#0[Xx]}")"
		else return 1
		fi
		
		#process output and print option
		if ((OPTVERBOSE))
		then echo "--------
TYPE___: $type
INPUT__: ${input_filename:-$input}
HEXDUMP: $bytestr
TEXTOUT: $(xxd -p -r <<<"$bytestr")"
		#convert hex to text directly
		else xxd -p -r <<<"$bytestr"
		fi
	fi

	#dc does not exit with useful code for this anyways
	return 0
}
#https://medium.com/concerning-pharo/understanding-base58-encoding-23e673e37ff6
#https://stackoverflow.com/questions/34076160/how-to-convert-a-string-into-hexadecimal-in-bash
#https://stackoverflow.com/questions/46990378/command-to-convert-hexdump-back-to-text

#convert hex to public address
addrf()
{
	local addr hx160 input
	input="$1"

	#make hash160 of input? option -a
	if ((OPTHASH))
	then hx160="$input"
	else hx160="$(pack "$input" | hash160)"
	fi

	#generate address
	addr="$(hexToAddress "$hx160" "$VER")"

	#verbose
	if ((OPTVERBOSE))
	then
		echo "---------
INPUT___: $input
HASH160_: $hx160
VER_BYTE: $VER
PUB_ADDR: $addr"
	else
		echo "$addr"
	fi

	[[ -n "$addr" ]]
}

#-c check public and private keys (addresses) checksum
checkf()
{
	local input ret
	input="$1"

	checkBitcoinAddress "$input" ;ret="$?"

	#verbose
	((OPTVERBOSE)) && echo 'Public key checksum check'

	#print validation result
	if ((ret==0))
	then echo "Validation pass -- $input" >&2
	else echo "Validation fail -- $input" >&2 ;return 1
	fi

	return 0
}

#-p generate a private address
privkeyf()
{
	local addr input input_filename pinput sha256 step hx cksum type compressflag pubkeygen input_test
	typeset -au sha256  #array, uppercase
	type='text string'
	input="$1"
	
	#if input is a file
	if [[ -e "$input" ]]
	then
		type=file
		input_filename="$input"
		input_test=$(head -c 200 "$input_filename")

		if ((OPTHASH))
		then type='hash160 file' ;newBitcoinKeyHx160 "$(<"$input_filename")" ;return
		elif ishexf $input_test
		then type='hex file' sha256=( $(xxd -p -r "$input_filename" | openssl dgst -sha256) )
		elif issha256sumf $input_test
		then type=sha256 sha256=( $(<"$input_filename") )
		elif type="$(iswiff $input_test)"
		then sha256=( $(OPTVERBOSE= wifkeyf "$input") )
		else type=file sha256=( $(openssl dgst -sha256 "$input_filename") ) 
		fi
	else
		type='text string'
		if ((OPTHASH))
		then type=hash160 ;newBitcoinKeyHx160 "$input" ;return
		elif ishexf "$input"
		then type=hex sha256=( $(echo ${NONL:+-n} "$input" | xxd -p -r | openssl dgst -sha256) )
		elif issha256sumf "$input"
		then type=sha256 sha256=( $input )
		elif type="$(iswiff "$input")"
		then sha256=( $(OPTVERBOSE= wifkeyf "$input") )
		else type='text string' sha256=( $(echo ${NONL:+-n} "$input" | openssl dgst -sha256) ) 
		fi
	fi

	#add compression flag?
	#toggle compression if input is WIF
	compressflag=true
	[[ ( "$OPTP" -eq 1 && "${type,,}" != uncompressed*wif* )
	|| ( "$OPTP" -eq 2 && "${type,,}" = uncompressed*wif* )	]] \
	&& unset VERCOMP compressflag

	step="$VER${sha256[-1]}$VERCOMP"

	hx="$(
		pack "$step" |
		openssl dgst -sha256 -binary |
		openssl dgst -sha256 -binary |
		unpack 
	)"
	
	#get the checksum
	cksum="$(head -c8 <<<"$hx")"

	#generate address
	addr="$(encodeBase58 "$step$cksum")"

	#verbose or -P?
	if ((OPTPP+OPTVERBOSE))
	then
		#is input too long to print?
		((${#input} > 300 && OPTVERBOSE < 2)) && pinput="${input:0:299} [...]"
		#-P generate public address?
		((OPTPP)) && pubkeygen=$'\n'$(newBitcoinKey "$addr")

		#print output at once
		echo "
========
TYPE____: $type
INPUT___: ${input_filename:-${pinput:-$input}}
SHA256__: ${sha256[-1]}
COMPRESS: ${compressflag:-false}
VER_BYTE: $VER
CHECKSUM: $cksum
WIF_KEY_: $addr""$pubkeygen"
	else
		echo "$addr"
	fi

	[[ -n "$addr" ]]
}
#https://en.bitcoin.it/wiki/Wallet_import_format
#https://gist.github.com/t4sk/ac6f2d607c96156ca15f577290716fcc
#http://gobittest.appspot.com/PrivateKey
#https://bitcoin.stackexchange.com/questions/8247/how-can-i-convert-a-sha256-hash-into-a-bitcoin-base58-private-key
#https://royalforkblog.github.io/2014/08/11/graphical-address-generator
#https://github.com/kennethhutw/BitcoinBrainwallet


#-w generate private key from wif
wifkeyf()
{
	local input pkey compressflag type
	input="$1"

	#check base58 input string
	#Convert it to a string using Base58Check encoding
	if type="$(iswiff "$input")"
	then pkey="$(decodeBase58 "$input")" ;[[ "$type" = [Cc]ompressed* ]] && compressflag=1
	else echo "err: invalid/unknown WIF format -- $input" >&2 ;return 1
	fi

	#Drop the last 4 checksum bytes from the byte string
	pkey="${pkey%????????}"
	
	#Drop first bytes from the byte string
	pkey="${pkey#??}"

	#Also drop the last byte (it should be 0x01)
	#if it corresponded to a compressed public key
	((compressflag)) && pkey="${pkey%??}"

	#verbose
	if (( OPTVERBOSE ))
	then
		echo "--------
WIF_____: $input
TYPE____: $type
PRIV_KEY: $pkey"
	else
		#print private key with newline
		echo "$pkey"
	fi

	[[ -n "$pkey" ]] || exit 1
}
#testnet: https://bitcoin.stackexchange.com/questions/69315/how-are-compressed-pubkeys-generated

#-x check wif key checksum
wcheckf()
{
	local a b c d cksum hx input type
	input="$1"

	#check base58 input string
	#Convert it to a string using Base58Check encoding
	if type="$(iswiff "$input")"
	then a="$(decodeBase58 "$input")"
	else echo "err: invalid/unknown WIF format -- $input" >&2 ;return 1
	fi

	#Drop the last 4 checksum bytes from the byte string
	b="${a%????????}"
	#Drop first byte from the string
	c="${a/$b}"

	#check version byte?
	#does it start with 0x$VER (defaults=0x80) byte?
	d="$( cut -c1,2 <<<"$a" )"
	#if [[ "$d" != "$VER" ]]
	#then 
	#	echo "warning: version byte from key ($1) differs from user-set ($VER)" >&2
	#fi
	
	#Convert string to byte string and
	#perform SHA-256 hash on the shortened string 
	hx="$(
		pack "$b" |
		openssl dgst -sha256 -binary |
		openssl dgst -sha256 -binary |
		unpack 
	)"
	
	#Take the first 4 bytes of the second SHA-256 hash, this is the checksum 
	cksum="$( head -c8 <<<"$hx" )"

	#uppercase values
	c="${c^^}"
	cksum="${cksum^^}"

	#verbose
	if (( OPTVERBOSE ))
	then
		echo "--------
WIF key checksum check
INPUT____: $input
TYPE_____: $type
2NDSHA256: $c
CHECKSUM_: $cksum
CKVERBYTE: $d
VER_BYTE_: $VER"
	fi

	#print validation result
	#Make sure $cksum matches $c
	#If they are the same, and the byte string from point 2 starts
	#with 0x80 (0xef for testnet addresses), then there is no error
	if [[ "$cksum" == "$c" ]]
	then echo "Validation pass -- $1" >&2
	else echo "Validation fail -- $1" >&2 ;return 1
	fi

	return 0
}

#is public address? (pattern matching)
ispubkeyf()
{
	#is legacy (P2PKH)?
	if [[ "$1" =~ ^[1][a-km-zA-HJ-NP-Z1-9]{25,34}$ ]]
	then echo 'Legacy (P2PKH)' ;return 0
	#is Segwit (P2SH)?
	elif [[ "$1" =~ ^[3][a-km-zA-HJ-NP-Z1-9]{25,34}$ ]]
	then echo 'Segwit (P2SH)' ;return 0
	#is native segwit (bech32)?
	elif [[ "$1" =~ ^bc(0([ac-hj-np-z02-9]{39}|[ac-hj-np-z02-9]{59})|1[ac-hj-np-z02-9]{8,87})$ ]]
	then echo 'Native segwit (bech32)' ;return 0
	fi

	return 1
}

#is WIF?
iswiff()
{
	#is uncompressed?
	if [[ "$1" =~ ^[59][1-9A-HJ-NP-Za-km-z]{50,51}$ ]]
	then echo 'Uncompressed WIF' ;return 0
	#is compressed?
	elif [[ "$1" =~ ^[KLc][1-9A-HJ-NP-Za-km-z]{50,51}$ ]]
	then echo 'Compressed WIF' ;return 0
	fi

	return 1
}
#https://en.bitcoin.it/wiki/List_of_address_prefixes

#is input base58?
isbase58f()
{
	if [[ "$1" =~ [^"$B58$IFS"] ]]
	then echo "err: illegal base58 char -- ${BASH_REMATCH[0]}" >&2 ;return 1
	else echo 'Base58 string'
	fi

	return 0
}

#is input SHA256SUM ?
issha256sumf()
{
	[[ "$1" =~ ^\ *[A-Fa-f0-9]{64}\ *$ ]]
}

#is input byte hex?
#simple check to see whether input string is hex
ishexf()
{
	[[ "$OPTBYTE" -gt 0 || "$1" = *(\ )0[Xx]* ]]
}


#parse opts
while getopts 126abcehv:V:pPxwyY c
do
	case $c in
		1)
			#reverse direction
			#print hash160 of string
			OPTREV=1
			;;
		2)
			#generate double sha256 sum
			OPTDSHA=1
			;;
		6)
			#generate hash160
			OPTHASH160=1
			;;
		a)
			#dont make hash160 of input
			OPTHASH=1
			;;
		b)
			#set input/output is byte hex manually
			OPTBYTE=1
			;;
		c)
			#check public key checksum
			OPTC=1
			;;
		e)
			#verbose
			((OPTVERBOSE++))
			;;
		h)
			#print script version
			while read
			do [[ "$REPLY" = \#\ v[0-9]* ]] && break
			done <"$0"
			echo "$REPLY" #print script version
			echo "$HELP"  #print help page
			exit 0
			;;
		v|V)
			#byte version
			VER="${OPTARG:-${VERDEF}}"
			;;
		p)
			#-p make privy key from sha256
			((OPTP++))
			VERDEF="$VERPRIDEF"
			;;
		P)
			#-P also make its public addresses?
			OPTP=2 OPTPP=1
			VERDEF="$VERPRIDEF"
			;;
		x)
			#check wif key checksum
			OPTX=1
			VERDEF="$VERPRIDEF"
			;;
		w)
			#WIF to private key
			((OPTW++))
			;;
		y)
			#decode base58
			ENCODEOPT=1
			;;
		Y)
			#encode base58
			ENCODEOPT=2
			;;
		?)
			#illegal opt
			exit 1
			;;
	esac
done
shift $(( OPTIND - 1 ))
unset c

#check bash version
#if (( BASH_VERSINFO[0] < 4 ))
#then echo "$SN: err  -- bash version 4 or above required" >&2 ;exit 1
#fi

#required packages
if ! command -v openssl xxd &>/dev/null
then echo "$SN: required packages  -- openssl and xxd" >&2 ;exit 1
fi

#consolidate version byte option
#drop 0x from start of byte hex
VER="${VER:-$VERDEF}"
VER="${VER#0[Xx]}"
#check version byte input, warn if unknown
if [[ \ "${VERBYTES[*]}"\  != *\ "${VER^^}"\ * ]]
then echo "warning: user-set byte version -- $VER" >&2
fi

#declare main() as per option
#-1 get hash160 from public address
if ((OPTREV))
then mainf() { revf "$1" ;}
#-2 generate double sha256 sum
elif ((OPTDSHA))
then mainf() { sha256df "$1" ;}
#-6 generate hash160 from any string or file
elif ((OPTHASH160))
then mainf() { genhash160f "$1" ;}
#-yY encode decode base58
elif ((ENCODEOPT))
then mainf() { base58f "$1" ;}
#-c check public key (address) checksum
elif ((OPTC))
then mainf() { checkf "$@" ;}
#-p create private key from sha256 sum
elif ((OPTP))
then mainf() { privkeyf "$@" ;}
#-w WIF to privy key
elif ((OPTW))
then mainf() { wifkeyf "$@" ;}
#-x check wif key checksum
elif ((OPTX))
then mainf() { wcheckf "$@" ;}
#default option, convert hex to public address
else mainf() { addrf "$1" ;}
fi

#loop through strings
#is there any postional argument?
if (( $# ))
then
	NONL=1
	for ARG in "$@"
	do [[ -z "$ARG" ]] || mainf "$ARG"
	done
#is stdin taken?
elif [[ ! -t 0 ]]
then
	if ((OPTX+OPTW))
	then
		while IFS=  read -r || { [[ -n "$REPLY" ]] && NONL=1 ;}
		do [[ -z "$REPLY" ]] || mainf "$REPLY"
		done
	else
		NONL=1
		while IFS=  read -d '' -r || [[ -n "$REPLY" ]]
		do [[ -z "$REPLY" ]] || mainf "$REPLY"
		done
	fi
else
	#fail
	echo "$SN: user input required" >&2
	exit 1
fi

