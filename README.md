# scripts
Shell script collection


## GENERAL

NAME | DESCRIPTION
:-------------|:-----------
[PMWMT/](PMWMT) | Scrapes from Poor Man's Webmaster Tools by the Silly Software Company
[markets/](markets) | Scripts related to financial and cryptocurrency markets
[ala.sh](ala.sh) | Arch Linux Archives (aka ALA) explorer
[aur.sh](aur.sh) | List packages from AUR
[bcalc.sh](bcalc.sh) | Simple wrapper for Bash Bc and Zsh maths that keeps a record of results
_bcalc_ext.bc_ | *bcalc.sh* extensions for bash bc
[chatgpt.sh](https://gitlab.com/fenixdragao/shellchatgpt) | Shell wrapper for ChatGPT ([go to GitLab repo](https://gitlab.com/fenixdragao/shellchatgpt))
[ctemp.sh](ctemp.sh) | Convert amongst temperature units (Celsius, Fahrenheit and Kelvin)
[datediff.sh](datediff.sh) | Small shell function library to calculate time ranges in different units ([go to GitLab repo](https://gitlab.com/fenixdragao/shelldatediff)).
[faster_sh.txt](faster_sh.txt) | Tips for improving script performances, specific for some use cases, text document
[geoconv.sh](geoconv.sh) |  Convert geocoordinates to various formats
[grep.sh](grep.sh) |  Grep files with shell built-ins
[inmet.sh](inmet.sh) | Download satellite images from Brazilian Instituto Nacional de Meteorologia
[ipmet.sh](ipmet.sh) | Download radar images from Brazilian IPMET/SIMEPAR
[md2man.sh](md2man.sh) | Generate man pages from a pandoc markdown file.
[tkn-cnt.py](tkn-cnt.py) | Python tiktoken wrapper.
[ul.sh](ul.sh) |  Generate html lists from URLs
[urlgrep.sh](urlgrep.sh) | Grep full-text content from URL list
[wc.sh](wc.sh) |  Print line, word and character count for files with shell built-ins
[wf.sh](wf.sh) |  Weather forecast from the Norway Meteorological Institute

<!-- [cep.sh](cep.sh) | CEP por nome de rua e vice-versa via api dos Correios brasileiros -->


## BITCOIN

NAME | DESCRIPTION
:-------------|:-----------
[binfo.sh](binfo.sh) | Blockchain explorer for bitcoin; uses <blockchain.info> and <blockchair.com> public apis; notification on new block found
[bitcoin.blk.sh](bitcoin.blk.sh) | Bitcoin block and blockchain information
[bitcoin.hx.sh](bitcoin.hx.sh) | Create base58 address types from public key and WIF from private keys
[bitcoin.tx.sh](bitcoin.tx.sh) |  Parse transactions by hash or transaction json data
[blockchair.btcoutputs.sh](blockchair.btcoutputs.sh) |  Download blockchair output dump files systematically
_zzz.bitcoin.parsedTxs.txt_ | Example of parsed transactions from block 714176

Bitcoin scripts warp about `bitcoin-cli` (bitcoind) and try to parse data.
`bitcoin.tx.sh` is transaction-centred while `bitcoin.blk.sh` is block-centred.

_Make sure bitcoin-dameon is **fully synchonised**_, otherwise some
functions may not work properly!

___Tip___: have bitcoind set with transaction indexes (option 'txindex=1'),
otherwise user may need supply block id hash manually and
some vin transaction information is not going to be retrievable.

These wrappers require `bash`, `bitcoin-cli` and `jq`.
Some scripts have got [grondilu's bitcoin-bash-tools](https://github.com/grondilu/bitcoin-bash-tools)
functions embedded.

Transaction parsing time depends on the number of vins and vouts.
Parsing a few hendred or thousand transactions
seems quite feasible for personal use.


## MARKETS

NAME | DESCRIPTION
:-------------|:-----------
[bakkt.sh](markets/bakkt.sh) | Price and contract/volume tickers from bakkt public api
[binance.sh](markets/binance.sh) |  Binance public API, crypto converter, prices, book depth, coin ticker
[brasilbtc.sh](markets/brasilbtc.sh) | Fetches bitcoin rates from brazilian exchanges public apis. Puxa cotações de bitcoin de agências de câmbio brasileiras de apis públicas
[cgk.sh](markets/cgk.sh) | <Coinggecko.com> public api, convert one crypto, bank/fiat currency or metal into any another, market ticker, cryptocurrency ticker. This is my favorite everyday-use script for all-currency rates!
[cmc.sh](markets/cmc.sh) |  <Coinmarketcap.com> convert any amount of one crypto, bank/fiat currency or metal into any another, NON-public api access
[novad.sh](markets/novad.sh) | Puxa dados das apis públicas da NovaDax brasileira. fetch public api data from NovaDax brazilian enchange
[stocks.sh](markets/stocks.sh) | <Financialmodelingprep.com> latest and historical stock and major index rates
[uol.sh](markets/uol.sh) | Fetches rates from uol service provider public api. Puxa dados de páginas da api pública do uol economia
[whalealert.sh](markets/whalealert.sh) | Data from whale-alert.io free api with the latest whale transactions.
[yahooscrape.sh](markets/yahooscrape.sh) | Scrape some Yahoo! Finance tickers
<!-- [myc.sh](markets/myc.sh) | Mycurrency.net public api, central bank currency rate converter -->


## API KEYS / CHAVES DE API

Some scripts require API keys.
Please create free API keys and add them to shell environment or set
them in the script head source code.

Alguns scripts requerem chaves de API.
Por favor, crie chaves de API grátis e as adicione no ambiente da shell
ou as configure na cabeça do código-fonte dos scripts.


## FURTHER HELP AND EXAMPLES / MAIS AJUDA E EXEMPLOS

Check script help pages with option -h.

Veja as páginas de ajuda dos scripts com a opção -h. 


## ANDROID TERMUX TIPS / DICAS PRA TERMUX

These scripts can run under Termux, however some of them need a web socket such as `websocat`.

Packages `websocat` and C-code `datediff` are available in the Termux repo as of now.

After installing `zsh`, it is possible to make it behave like ksh:

```
 ln -s $PREFIX/bin/zsh $PREFIX/bin/ksh
```

To build correctly [McDutchie's Ksh93+um](https://github.com/ksh93/ksh#build)
you need the `clang`, `binutils`, `getconf`, and `ncurses-utils` packages ([details](https://github.com/ksh93/ksh/commit/0a0a32c35b33a73bf6354e4085d24244abfcd857)).


Older tips:

Vi's `websocat` binaries for Android (ARM), MacOS and FreeBSD [can be downloaded from here](https://github.com/vi/websocat/releases).

Hroptatyr's [`dateutils`](https://github.com/hroptatyr/dateutils) can be compiled in Termux. I suggest installing the following packes before trying to [build `dateutils` as per developer intructions](https://github.com/hroptatyr/dateutils/blob/master/INSTALL) in Termux `v0.118.0`:

```
 pkg install gperf flex bison python python2 cmake automake libtool build-essential binutils cmake ctags
```
 
I compiled `dateutils` binaries a few days ago and I cannot remember specific details.
In general, if needed, check that `$TMPD` is set properly (should be set automatically) and review source code for `/tmp` references and change to hard location under Termux `$PREFIX` or set something like `$PREFIX/tmp` in shell scripts.


On other tips, if software is not in the official repos and you cannot compile it from source, try to look for compiled binaries of the software for your platform.


## IMPORTANT / IMPORTANTE

None of these scripts are supposed to be used under truly professional constraints. Do your own research!

Nenhum desses scripts deve ser usado em meio profissional sem análise prévia. Faça sua própria pesquisa!


## SEE ALSO / VEJA TAMBÉM

Grondilu's [bitcoin-bash-tools](https://github.com/grondilu/bitcoin-bash-tools)

Kristapsk's [bitcoin scripts](https://github.com/kristapsk/bitcoin-scripts)

Alexander Epstein's _currency_bash-snipet.sh_ uses the same API as _erates.sh_

<https://github.com/alexanderepstein>

MiguelMota's _Cointop_ for crypto currency tickers

<https://github.com/miguelmota/cointop>

8go's _CoinBash.sh_ for CoinMarketCap simple tickers (outdated)

<https://github.com/8go/coinbash> 

Brandleesee's _Mop: track stocks the hacker way_

<https://github.com/mop-tracker/mop>


### Markets

Alexander Epstein's _currency_bash-snipet.sh_ uses the same API as _erates.sh_

<https://github.com/alexanderepstein>

MiguelMota's _Cointop_ for crypto currency tickers

<https://github.com/miguelmota/cointop>

8go's _CoinBash.sh_ for CoinMarketCap simple tickers (outdated)

<https://github.com/8go/coinbash> 

Brandleesee's _Mop: track stocks the hacker way_

<https://github.com/mop-tracker/mop>

Packages `units` and `qalc` (qalculate) also have got
bank currency rate convertion.


---


<br/>

<p align="center">
  <img width="120" height="120" alt="Silly Software Company logo" src="PMWMT/logo_ssc.jpg">
  <br/>
  <i>Fig. 1 — Silly Software Company Logo (see <a href="PMWMT/">PMWMT/</a> and lore)</i>
</p>

<br/>


<!--
    Please consider sending me a nickle!  = )

        bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr
-->

<!--

# This repo __[may be moved to GitLab](https://gitlab.com/mountaineerbr/scripts/)__.

-->

