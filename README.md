# scripts
Shell script collection


## GENERAL

NAME | DESCRIPTION
:-------------|:-----------
[PMWMT/](PMWMT) | Scrapes from Poor Man's Webmaster Tools by the Silly Software Company
[markets/](markets) | Scripts related to financial and cryptocurrency markets
[ala.sh](ala.sh) | Arch Linux Archives (aka ALA) explorer
[aur.sh](aur.sh) | List and search for packages from AUR
[bcalc.sh](bcalc.sh) | Simple wrapper for Bash Bc and Zsh maths that keeps a record of results
_bcalc_ext.bc_ | Catenated extensions for bash bc _bcalc.sh_, see also the [individual extensions](bc_extensions/)
[chatgpt.sh](https://gitlab.com/fenixdragao/shellchatgpt) | Shell wrapper for ChatGPT (go to the stand-alone [GitLab repo](https://gitlab.com/fenixdragao/shellchatgpt) or [GitHub repo](https://github.com/mountaineerbr/shellChatGPT))
[ctemp.sh](ctemp.sh) | Convert amongst temperature units (Celsius, Fahrenheit, and Kelvin)
[datediff.sh](datediff.sh) | Small shell function library to calculate time ranges in different units (go to its [GitLab repo](https://gitlab.com/fenixdragao/shelldatediff) or [GitHub repo](https://github.com/mountaineerbr/shellDatediff)).
[faster_sh.txt](faster_sh.txt) | Really good tips for improving script performance (from [David Butcher](http://www.los-gatos.ca.us/davidbu/faster_sh.html))
[geoconv.sh](geoconv.sh) | Convert geocoordinates to various formats
[grep.sh](grep.sh) | Grep files with shell built-ins
[inmet.sh](inmet.sh) | Get satellite images from Brazilian Instituto Nacional de Meteorologia
[ipmet.sh](ipmet.sh) | Get rain radar images from Brazilian IPMET/SIMEPAR institutes
[md2man.sh](md2man.sh) | Generate man pages from a pandoc markdown file
[moon-illumination.py](moon-illumination.py) | Calculate lunar illuminated fraction
[ul.sh](ul.sh) | Generate html lists from URLs
[urlgrep.sh](urlgrep.sh) | Grep full-text content from URL list
[wc.sh](wc.sh) | Print line, word and character count for files with shell built-ins
[wf.sh](wf.sh) | Weather forecast from the Norway Meteorological Institute


Some scripts that wrap around online APIs or other resources may not be updated
as my personal use cases may have changed over time.

Scripts [grep.sh](grep.sh) and [wc.sh](wc.sh) were written as coding
exercises and are not meant to be further developed or perfected. 


## BITCOIN

NAME | DESCRIPTION
:-------------|:-----------
[binfo.sh](binfo.sh) | Blockchain explorer for bitcoin with <blockchain.info> and <blockchair.com> public APIs
[bitcoin.blk.sh](bitcoin.blk.sh) | Bitcoin block and blockchain information (local node)
[bitcoin.hx.sh](bitcoin.hx.sh) | Create base58 address types from public key and WIF from private keys
[bitcoin.tx.sh](bitcoin.tx.sh) | Parse transactions by hash or transaction json data (local node)
[blockchair.btcoutputs.sh](blockchair.btcoutputs.sh) | Download blockchair output dump files systematically
_zzz.bitcoin.parsedTxs.txt_ | Example of parsed transactions by [bitcoin.tx.sh](bitcoin.tx.sh)


Scripts `bitcoin.tx.sh` (transaction-centered) and `bitcoin.blk.sh` (block-centered)
warp about `bitcoin-cli` (bitcoind local node) to parse data.

General directions include _fully synchronising_ the blockchain
with `bitcoin-daemon` for them to work as expected ™, and
have `bitcoind` set with transaction indexes (option `txindex=1`),
otherwise block id hash needs to be supplied manually in order
to retrieve transaction and vin list.

Transaction parsing time depends on the number of vins and vouts.
Parsing a few hundred or thousand transactions
seems quite feasible for personal use.

However, do note that I haven't really used these much over some time.
There are no plans on updating them any longer either.

Some of [Grondilu's bitcoin-bash-tools](https://github.com/grondilu/bitcoin-bash-tools)
functions are embedded in these scripts.


## CURRENCY MARKETS

NAME | DESCRIPTION
:-------------|:-----------
[binance.sh](markets/binance.sh) | Binance public API, crypto converter, prices, book depth, coin ticker
[bitstamp.sh](markets/bitstamp.sh) | Live price stream from Bitstamp API
[cgk.sh](markets/cgk.sh) | CoinGecko public API, convert one crypto, bank/fiat currency or metal into any other, market ticker, cryptocurrency ticker. This is my favorite everyday-use script for all-currency rates!
[cmc.sh](markets/cmc.sh) | CoinMarketCap convert any amount of one crypto, bank/fiat currency or metal into any other, requires (free) API key
[uol.sh](markets/uol.sh) | Fetches rates from UOL service provider public API. Puxa dados de páginas da API pública do UOL Economia
[whalealert.sh](markets/whalealert.sh) | Data from <whale-alert.io> free API with the latest whale transactions


## HELP AND EXAMPLES / AJUDA E EXEMPLOS

Check script help pages with `option -h`.

Veja as páginas de ajuda dos scripts com a `opção -h`. 


## API KEYS

Some scripts require API keys.
Please create free API keys and set environment variables
holding them according to the help pages.


## ANDROID TERMUX TIPS

These scripts can run under Termux, however some of them need a web socket such as `websocat`.

Packages `websocat` and C-code `datediff` are available in the Termux repo as of now.

After installing `zsh`, it is possible to make it behave like `ksh`:

```
 ln -s $PREFIX/bin/zsh $PREFIX/bin/ksh
```

For the real deal, though, you'll want [McDutchie's Ksh93+um](https://github.com/ksh93/ksh#build).
To build it correctly, you need the `clang`, `binutils`, `getconf`, and
`ncurses-utils` packages ([details](https://github.com/ksh93/ksh/commit/0a0a32c35b33a73bf6354e4085d24244abfcd857)).

Vi's `websocat` binaries for Android (ARM), MacOS and FreeBSD [can be downloaded from here](https://github.com/vi/websocat/releases).

Hroptatyr's [`dateutils`](https://github.com/hroptatyr/dateutils) can be compiled in Termux.
I suggest installing the following packages before trying to build `dateutils`
[as per developer instructions](https://github.com/hroptatyr/dateutils/blob/master/INSTALL).

```
 pkg install gperf flex bison python python2 cmake automake libtool build-essential binutils ctags
```
 
In general, if needed, check that `$TMPD` is set properly (should be set automatically),
review source code for `/tmp` directory references and change to a hard location under
Termux `$PREFIX` or even set something like `$PREFIX/tmp` in the build shell scripts.

If any dependency software is not in the official repos and you cannot compile it
from source, try to look for compiled and officially distributed binaries for your platform.


## REPO MIRRORS

[GitLab Script Repo](https://gitlab.com/mountaineerbr/scripts/).

[GitHub Script Repo](https://github.com/mountaineerbr/scripts).


## SEE ALSO

Grondilu's [bitcoin-bash-tools](https://github.com/grondilu/bitcoin-bash-tools).

Kristapsk's [bitcoin scripts](https://github.com/kristapsk/bitcoin-scripts).

Alexander Epstein's [currency_bash-snipet.sh](https://github.com/alexanderepstein).

MiguelMota's [Cointop](https://github.com/miguelmota/cointop) for crypto currency tickers.

8go's [CoinBash.sh](https://github.com/8go/coinbash) for CoinMarketCap simple tickers.

Brandleesee's [Mop: track stocks the hacker way](https://github.com/mop-tracker/mop).

C-code packages `units` and `qalc` (_qalculate_) also provide bank currency
rate conversion.


---

<br/>

<p align="center">
  <img width="120" height="120" alt="Silly Software Company logo" src="PMWMT/logo_ssc.jpg">
  <br/>
  <i>Fig. 1 — Silly Software Company Logo (see <a href="PMWMT/">PMWMT/</a> and lore)</i>
</p>

<br/>




<!--
    Please consider sending me a nickel!  = )

        bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr
-->

