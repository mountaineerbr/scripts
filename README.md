# scripts
Shell script collection

<!--
# This repo __[moved to GitLab](https://gitlab.com/mountaineerbr/scripts/)__.
-->

---

## GENERAL

NAME | DESCRIPTION
:-------------|:-----------
[PMWMT/](https://gitlab.com/mountaineerbr/scripts/-/tree/main/PMWMT) | Scrapes from Poor Man's Webmaster Tools by the Silly Software Company
[markets/](https://gitlab.com/mountaineerbr/scripts/-/tree/main/markets) | Scripts related to financial and cryptocurrency markets
[ala.sh](https://gitlab.com/mountaineerbr/scripts/-/blob/main/ala.sh) | Arch Linux Archives (aka ALA) explorer
[aur.sh](https://gitlab.com/mountaineerbr/scripts/-/blob/main/aur.sh) | List packages from AUR
[bcalc.sh](https://gitlab.com/mountaineerbr/scripts/-/blob/main/bcalc.sh) | Simple wrapper for Bash Bc and Zsh maths that keeps a record of results
_bcalc_ext.bc_ | *bcalc.sh* extensions for bash bc
[cep.sh](https://gitlab.com/mountaineerbr/scripts/-/blob/main/cep.sh) | CEP por nome de rua e vice-versa via api dos Correios brasileiros
[chatgpt.sh](https://gitlab.com/fenixdragao/shellchatgpt) | Shell wrapper for ChatGPT ([go to repo](https://gitlab.com/fenixdragao/shellchatgpt))
[ctemp.sh](https://gitlab.com/mountaineerbr/scripts/-/blob/main/ctemp.sh) | Convert amongst temperature units (Celsius, Fahrenheit and Kelvin)
[datediff.sh](https://gitlab.com/mountaineerbr/scripts/-/blob/main/datediff.sh) | Small shell function library to calculate time ranges in different units ([go to repo](https://gitlab.com/fenixdragao/shelldatediff)).
[faster_sh.txt](https://gitlab.com/mountaineerbr/scripts/-/blob/main/faster_sh.txt) | Tips for improving script performances, specific for some use cases, text document
[geoconv.sh](https://gitlab.com/mountaineerbr/scripts/-/blob/main/geoconv.sh) |  Convert geocoordinates to various formats
[grep.sh](https://gitlab.com/mountaineerbr/scripts/-/blob/main/grep.sh) |  Grep files with shell built-ins
[inmet.sh](https://gitlab.com/mountaineerbr/scripts/-/blob/main/inmet.sh) | Download satellite images from Brazilian Instituto Nacional de Meteorologia
[ipmet.sh](https://gitlab.com/mountaineerbr/scripts/-/blob/main/ipmet.sh) | Download radar images from Brazilian IPMET/SIMEPAR
[md2man.sh](https://gitlab.com/mountaineerbr/scripts/-/blob/main/md2man.sh) | Generate man pages from a pandoc markdown file.
[tkn-cnt.py](https://gitlab.com/mountaineerbr/scripts/-/blob/main/tkn-cnt.py) | Python tiktoken wrapper.
[ul.sh](https://gitlab.com/mountaineerbr/scripts/-/blob/main/ul.sh) |  Generate html lists from URLs
[urlgrep.sh](https://gitlab.com/mountaineerbr/scripts/-/blob/main/urlgrep.sh) | Grep full-text content from URL list
[wc.sh](https://gitlab.com/mountaineerbr/scripts/-/blob/main/wc.sh) |  Print line, word and character count for files with shell built-ins
[wf.sh](https://gitlab.com/mountaineerbr/scripts/-/blob/main/wf.sh) |  Weather forecast from the Norway Meteorological Institute


## BITCOIN-RELATED

NAME | DESCRIPTION
:-------------|:-----------
[binfo.sh](https://gitlab.com/mountaineerbr/scripts/-/blob/main/binfo.sh) | Blockchain explorer for bitcoin; uses <blockchain.info> and <blockchair.com> public apis; notification on new block found
[bitcoin.blk.sh](https://gitlab.com/mountaineerbr/scripts/-/blob/main/bitcoin.blk.sh) | Bitcoin block and blockchain information
[bitcoin.hx.sh](https://gitlab.com/mountaineerbr/scripts/-/blob/main/bitcoin.hx.sh) | Create base58 address types from public key and WIF from private keys
[bitcoin.tx.sh](https://gitlab.com/mountaineerbr/scripts/-/blob/main/bitcoin.tx.sh) |  Parse transactions by hash or transaction json data
[blockchair.btcoutputs.sh](https://gitlab.com/mountaineerbr/scripts/-/blob/main/blockchair.btcoutputs.sh) |  Download blockchair output dump files systematically
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


## MARKET-RELATED INDEX / ÍNDICE

NAME | DESCRIPTION
:-------------|:-----------
[bakkt.sh](https://gitlab.com/mountaineerbr/scripts/-/blob/main/markets/bakkt.sh) | Price and contract/volume tickers from bakkt public api
[binance.sh](https://gitlab.com/mountaineerbr/scripts/-/blob/main/markets/binance.sh) |  Binance public API, crypto converter, prices, book depth, coin ticker
[brasilbtc.sh](https://gitlab.com/mountaineerbr/scripts/-/blob/main/markets/brasilbtc.sh) | Fetches bitcoin rates from brazilian exchanges public apis. Puxa cotações de bitcoin de agências de câmbio brasileiras de apis públicas
[cgk.sh](https://gitlab.com/mountaineerbr/scripts/-/blob/main/markets/cgk.sh) | <Coinggecko.com> public api, convert one crypto, bank/fiat currency or metal into any another, market ticker, cryptocurrency ticker. This is my favorite everyday-use script for all-currency rates!
[cmc.sh](https://gitlab.com/mountaineerbr/scripts/-/blob/main/markets/cmc.sh) |  <Coinmarketcap.com> convert any amount of one crypto, bank/fiat currency or metal into any another, NON-public api access
[myc.sh](https://gitlab.com/mountaineerbr/scripts/-/blob/main/markets/myc.sh) | <Mycurrency.net> public api, central bank currency rate converter
[novad.sh](https://gitlab.com/mountaineerbr/scripts/-/blob/main/markets/novad.sh) | puxa dados das apis públicas da NovaDax brasileira. fetch public api data from NovaDax brazilian enchange
[stocks.sh](https://gitlab.com/mountaineerbr/scripts/-/blob/main/markets/stocks.sh) | <Financialmodelingprep.com> latest and historical stock and major index rates
[uol.sh](https://gitlab.com/mountaineerbr/scripts/-/blob/main/markets/uol.sh) | Fetches rates from uol service provider public api. Puxa dados de páginas da api pública do uol economia
[whalealert.sh](https://gitlab.com/mountaineerbr/scripts/-/blob/main/markets/whalealert.sh) | Data from whale-alert.io free api with the latest whale transactions.
[yahooscrape.sh](https://gitlab.com/mountaineerbr/scripts/-/blob/main/markets/yahooscrape.sh) | Scrape some Yahoo! Finance tickers


## API KEYS / CHAVES DE API

Some scripts require API keys.
Please create free API keys and add them to shell environment or set
them in the script head source code. Demo api keys were added to the scripts,
however they may stop working at any time or get rate limited quickly.

Alguns scripts requerem chaves de API.
Por favor, crie chaves de API grátis e as adicione no ambiente da shell
ou as configure na cabeça do código-fonte dos scripts. Chaves para fins
de demonstração foram adicionadas aos scripts, porém elas podem parar 
de funcionar a qualquer momento ou serem limitadas rapidamente.


## FURTHER HELP AND EXAMPLES / MAIS AJUDA E EXEMPLOS

Check script help pages with option -h.

Veja as páginas de ajuda dos scripts com a opção -h. 


## ANDROID TERMUX TIPS / DICAS PRA TERMUX

These scripts can run under Termux, however some of them need a web socket such as `websocat`.

Vi's `websocat` bincaries for Android (ARM), MacOS and FreeBSD [can be downloaded from here](https://github.com/vi/websocat/releases).

Hroptatyr's [`dateutils`](https://github.com/hroptatyr/dateutils) can be compiled in Termux. I suggest installing the following packes before trying to [build `dateutils` as per developer intructions](https://github.com/hroptatyr/dateutils/blob/master/INSTALL) in Termux `v0.118.0`:

```bash
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


## SEE ALSO (MARKETS)

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
</p>


