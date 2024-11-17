#!/usr/bin/env python
# tkn-cnt.py - Count tokens of text string
# Usage: tkn-cnt.py [MODEL|ENCODING] [TEXT|FILE|-]..
# v0.1.6  april/2023  by mountaineerbr
import os
import sys
import getopt
try:
    import tiktoken
except:
    sys.stderr.write("Err: Install tiktoken module: `pip install tiktoken`\n")
    sys.exit(1)


text = ""
mod = "gpt-3.5-turbo"
fallback = "cl100k_base"
#davinci: r50k_base
sn = (sys.argv[0].split("/")[-1])
usage = "\
Usage: %s [-ttv] [MODEL|ENCODING] \"[STRING|FILE|-]..\"\n\
Usage: %s [-hl]\n\
Set \"-\" to read from stdin.\n" % (sn, sn)


def usagef():
    sys.stderr.write(usage)

def list_encf():
    for enc_name in tiktoken.list_encoding_names():
        print(enc_name)


#parse opts
try:
    opts, args = getopt.getopt((sys.argv[1:]), "hltv")
except getopt.GetoptError:
    print('Error: Unkown option.')
    sys.exit(2)

optt, optv, check, check_two = 0, 0, 0, 0
for opt, arg in opts:
    if opt == '-h':
        usagef()
        sys.exit()
    elif opt == '-l':
        list_encf()
        sys.exit()
    elif opt == '-t':
        optt += 1
    elif opt == '-v':
        optv += 1


#input, pos args or stdin
if (len(args) > 1) and (args[1] == "-"):
    text = sys.stdin.read()
    mod = args[0]
elif (len(args) > 1) and (args[0] == "-"):
    text = sys.stdin.read()
    mod = args[1]
elif (len(args) > 1):
    if (os.path.isfile(args[0])) or (os.path.isfile(args[1])):
        for file in args:
            if os.path.isfile(file):
                text += open(file, 'r').read()
                if not optv:
                    sys.stderr.write("File: %s\n" % file)
    else:
        text = " ".join(args[1:])
    if not os.path.isfile(args[0]):
        mod = args[0]
        check = 1
elif len(args):
    if args[0] == "-":
        text = sys.stdin.read()
    elif os.path.isfile(args[0]):
        text = open(args[0], 'r').read()
        if not optv:
            sys.stderr.write("File: %s\n" % (args[0]))
    else:
        mod = args[0]
        text = args[0]
        check_two = 1
else:
    usagef()
    sys.exit(2)

#model / encoding
try:
    enc = tiktoken.encoding_for_model((mod[0:50]))
    #sys.stderr.write("Model: %s %s\n" % (mod , str(enc)) )
    if check_two:
        text = ""
except:
    try:
        enc = tiktoken.get_encoding((mod[0:50]))
        #sys.stderr.write("Encoding: %s\n" % mod )
        mod = ""
    except:
        enc = tiktoken.get_encoding(fallback)
        #sys.stderr.write("Warning: Model or encoding not found. Using %s.\n" % fallback)
        if check:
            text = args[0] + " " + text

#
enc_name = str(enc)
encoded_text = enc.encode_ordinary(text)
#encoded_text = enc.encode(text, disallowed_special=())

if optt > 1:
    print(text)
elif optt:
    print(encoded_text)
elif optv:
    print(len(encoded_text))
else:
    print(len(encoded_text),enc_name)

#https://github.com/openai/tiktoken/blob/main/tiktoken/core.py
#https://github.com/openai/tiktoken/blob/main/tiktoken/model.py
#https://github.com/openai/openai-cookbook/blob/main/examples/How_to_count_tokens_with_tiktoken.ipynb
