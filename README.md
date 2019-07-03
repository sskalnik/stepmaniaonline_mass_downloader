# Disclaimer
Apologies to whoever pays the S3 bill for search.stepmaniaonline.net... I only made this so that I could gather up all the simfiles out there into a comprehensive collection that I'll get around to delivering via BitTorrent eventually...
Please don't use this to hammer the target site on the regular.

## What is this?
This is just a Mechanize-based Ruby script that takes start and end indices, then downloads each simfile pack by abusing the ability to "walk" the URLs following the pattern of "https://search.stepmaniaonline.net/pack/id/12345".

## Help
```bash
$ ./stepmaniaonline_mass_downloader.rb --help
Example usage: ./stepmaniaonline_mass_downloader.rb --start=1 --end=1234 -p 8118
    -s, --start=INTEGER              ID of first simfile ID to download
    -e, --end=INTEGER                Last index of simfile ID range
    -p, --proxy_port=INTEGER         Port number for local proxy
```

## Example
Download simfile IDs 1234 through 1235:
```bash
$ ./stepmaniaonline_mass_downloader.rb -s 1234 -e 1235
{:start_index=>1234, :end_index=>1235, :proxy_port=>nil}
Attempting to visit https://search.stepmaniaonline.net/pack/id/1234...
Searching for the "Download" button for this simfile pack...
http://east.stepmania-online.com/Kil.zip
Downloading and saving the simfile pack under "./simfiles/"...
Attempting to visit https://search.stepmaniaonline.net/pack/id/1235...
Searching for the "Download" button for this simfile pack...
http://east.stepmania-online.com/Kilga Originals [186 MB version].zip
Downloading and saving the simfile pack under "./simfiles/"...

$ ls simfiles/
Kilga%20Originals%20%5B186%20MB%20version%5D.zip  Kil.zip
```
