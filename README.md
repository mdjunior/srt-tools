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

For a complete list of parameters used for each language, see [here](https://cloud.google.com/translate/v2/using_rest#language-params)

The file produced by the tool has the name of the input file, increased by the extension `.json`.

json2srt.pl
-----------

This tool accepts the following parameters:
- `-f` -- **required** -- SubRip file

The file produced by the tool has the name of the input file, increased by the extension `.srt`.
