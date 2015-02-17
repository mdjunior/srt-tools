# srt-tools
Simple tool for manipulating SubRip subtitle files (SRT), converting them to JSON and translating them using the Google Translate API.


Installing
----------

To install the dependencies, run:

    cpanm --installdeps .

Use
---

To use the scripts, you must have a SubRip (.srt) file to handle. Currently, the repository has two tools for handling SubRip files:

- srt2json.pl - converts the SubRip file in JSON with the possibility of translating subtitles via Google Translate API
- json2srt.pl - converts the generated file in JSON by srt2json.pl tool in SubRip file

srt2json.pl
-----------

This tool accepts the following parameters:
- `-f` -- **required** -- SubRip file
- `-c` -- *optional* -- Counts the number of characters used in the subtitles. (Useful for measuring the Google Translate API use)
- `-v` -- *optional* -- Print progress during execution (There are two levels: (-v) prints information about the progress and (-v -v) prints the contents of the previous level with the JSON result.)
- `-t` -- *optional* -- Translate subtitles using Google Translate API (You must set the environment variable GOOGLE_TRANSLATE_API_KEY)
- `-i` -- **required if -t is set** -- Subtitle language in the file (input language)
- `-p` -- **required if -t is set** -- Output language

**Important**: `-c` and `-t` are mutually exclusive. Use one at a time.

For a complete list of parameters used for each language, see [here](https://cloud.google.com/translate/v2/using_rest#language-params)

The file produced by the tool has the name of the input file, increased by the extension `.json`.

json2srt.pl
-----------

This tool accepts the following parameters:
- `-f` -- **required** -- SubRip file

The file produced by the tool has the name of the input file, increased by the extension `.srt`.

Examples
--------

Consider sub.srt file (in portuguese):

    1
    00:00:03,084 --> 00:00:05,752
    É preciso sofrer depois de ter sofrido,
    
    2
    00:00:05,754 --> 00:00:07,887
    e amar, e mais amar, depois de ter amado.
    
    3
    00:00:07,889 --> 00:00:12,325
    Se todo animal inspira ternura,
    
    4
    00:00:12,327 --> 00:00:14,894
    que houve, então, com os homens?
    
    5
    00:00:14,896 --> 00:00:16,696
    Guimarães Rosa


## Simple conversion SubRip to JSON

    ./srt2json.pl -f sub.srt -v


    > cat sub.srt.json (pretty printed)
    [
        {
            "end_time": "00:00:05,752",
            "original": "\u00c3\u0089 preciso sofrer depois de ter sofrido,",
            "start_time": "00:00:03,084",
            "subtitle": "\u00c3\u0089 preciso sofrer depois de ter sofrido,"
        },
        {
            "end_time": "00:00:07,887",
            "original": "e amar, e mais amar, depois de ter amado.",
            "start_time": "00:00:05,754",
            "subtitle": "e amar, e mais amar, depois de ter amado."
        },
        {
            "end_time": "00:00:12,325",
            "original": "Se todo animal inspira ternura,",
            "start_time": "00:00:07,889",
            "subtitle": "Se todo animal inspira ternura,"
        },
        {
            "end_time": "00:00:14,894",
            "original": "que houve, ent\u00c3\u00a3o, com os homens?",
            "start_time": "00:00:12,327",
            "subtitle": "que houve, ent\u00c3\u00a3o, com os homens?"
        },
        {
            "end_time": "00:00:16,696",
            "original": "Guimar\u00c3\u00a3es Rosa",
            "start_time": "00:00:14,896",
            "subtitle": "Guimar\u00c3\u00a3es Rosa"
        }
    ]


## Simple conversion JSON to SubRip


    ./json2srt.pl -f sub.srt.json 


    > cat sub.srt.json.srt
    1
    00:00:03,084 --> 00:00:05,752
    É preciso sofrer depois de ter sofrido,

    2
    00:00:05,754 --> 00:00:07,887
    e amar, e mais amar, depois de ter amado.

    3
    00:00:07,889 --> 00:00:12,325
    Se todo animal inspira ternura,

    4
    00:00:12,327 --> 00:00:14,894
    que houve, então, com os homens?

    5
    00:00:14,896 --> 00:00:16,696
    Guimarães Rosa


## Counting characters

    ./srt2json.pl -f sub.srt -c
    Characters: 158

No files are produced


## Translate SubRip file (with verbose)


    export GOOGLE_TRANSLATE_API_KEY='example-api-key'
    ./srt2json.pl -f sub.srt -t -i pt -o en -v
    -> Checking file permissions (sub.srt)
    -> Translating 1 of 5
    -> Translating 2 of 5
    -> Translating 3 of 5
    -> Translating 4 of 5
    -> Translating 5 of 5
    -> Write results file (sub.srt.json)

    > cat sub.srt.json (pretty printed)
    [
        {
            "end_time": "00:00:05,752",
            "original": "\u00c3\u0089 preciso sofrer depois de ter sofrido,",
            "start_time": "00:00:03,084",
            "subtitle": "You need to suffer after having suffered,"
        },
        {
            "end_time": "00:00:07,887",
            "original": "e amar, e mais amar, depois de ter amado.",
            "start_time": "00:00:05,754",
            "subtitle": "and love, and more love, having loved."
        },
        {
            "end_time": "00:00:12,325",
            "original": "Se todo animal inspira ternura,",
            "start_time": "00:00:07,889",
            "subtitle": "If every animal inspires tenderness,"
        },
        {
            "end_time": "00:00:14,894",
            "original": "que houve, ent\u00c3\u00a3o, com os homens?",
            "start_time": "00:00:12,327",
            "subtitle": "What happened, then, with men?"
        },
        {
            "end_time": "00:00:16,696",
            "original": "Guimar\u00c3\u00a3es Rosa",
            "start_time": "00:00:14,896",
            "subtitle": "Guimar\u00c3\u00a3es Rosa"
        }
    ]

## Translate SubRip file (with super verbose)


    export GOOGLE_TRANSLATE_API_KEY='example-api-key'
    ./srt2json.pl -f sub.srt -t -i pt -o en -v -v
    -> Checking file permissions (sub.srt)
    -> Translating 1 of 5
    -> Translating 2 of 5
    -> Translating 3 of 5
    -> Translating 4 of 5
    -> Translating 5 of 5
    -> Write results file (sub.srt.json)
    
    [{"start_time":"00:00:03,084","end_time":"00:00:05,752","subtitle":"You need to suffer after having suffered,","original":"Ã preciso sofrer depois de ter sofrido,"},{"subtitle":"and love, and more love, having loved.","original":"e amar, e mais amar, depois de ter amado.","end_time":"00:00:07,887","start_time":"00:00:05,754"},{"start_time":"00:00:07,889","subtitle":"If every animal inspires tenderness,","original":"Se todo animal inspira ternura,","end_time":"00:00:12,325"},{"start_time":"00:00:12,327","end_time":"00:00:14,894","subtitle":"What happened, then, with men?","original":"que houve, entÃ£o, com os homens?"},{"end_time":"00:00:16,696","original":"GuimarÃ£es Rosa","subtitle":"GuimarÃ£es Rosa","start_time":"00:00:14,896"}]


The generated file is the same as the previous example.

Contributing
------------

If you have any questions that this documentation does not resolve, or want a feature, open an issue.

If you want to contribute code, please send a pull-request.
