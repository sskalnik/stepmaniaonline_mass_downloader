# Disclaimer
Apologies to whoever pays the S3 bill for search.stepmaniaonline.net... I only made this so that I could gather up all the simfiles out there into a comprehensive collection that I'll get around to delivering via BitTorrent eventually...
Please don't use this to hammer the target site on the regular.

## What is this?
This is just a Mechanize-based Ruby script that takes start and end indices, then downloads each simfile pack by abusing the ability to "walk" the URLs following the pattern of "https://search.stepmaniaonline.net/pack/id/12345".

## Features
- Only two direct dependencies!
- Downloading can be directed through an HTTP proxy!
- Automagically upload every downloaded file to S3 and delete the locally cached download to save space!
- Detect and skip already-downloaded files - even if they're already uploaded to S3!
- Replace zero-length downloads! (these last two mean that repeat runs are nigh idempotent, aside from making a lot of requests to the target site...)

## Installation
The only dependencies outside of the Ruby 2.5.x standard library are Mechanize and the AWS SDK v3 for S3. Install these two gems and their dependencies via Bundler:
```
$ bundle install
```

## Usage and Options
```
$ ./stepmaniaonline_mass_downloader.rb --help
Example usage: ./stepmaniaonline_mass_downloader.rb --start=1 --end=1234 -p 8118 -d simfiles -b my-s3-bucket.amazonaws.com
    -s, --start=INTEGER              ID of first simfile ID to download
    -e, --end=INTEGER                Last index of simfile ID range
    -p, --proxy_port=INTEGER         Port number for local proxy
    -d, --simfile_dir=STRING         Name of the directory where simfiles will be saved
    -b, --s3_bucket=STRING           Name of the S3 bucket to which simfiles will be moved
    -a, --aws_profile=STRING         AWS profile to use for S3 credentials, region, etc.
```
### Defaults
The only hard requirements are `--start` and `--end`.  
Files will be saved to `./simfiles/` unless another directory/folder is specified.  
No proxy is used by default.

### Configuration for uploading files to S3  
Specifying an S3 bucket will activate the "upload to S3 and delete the local file" logic.  
[The AWS SDK checks for credentials and configuration (namely the region) in the environment variables, then in the AWS credentials/config files (located under `~/.aws/credentials` and `~/.aws/config`), then in the IAM credential store (if you are running the command from an EC2 instance or ECS container)](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html#config-settings-and-precedence). You can specify an explicit AWS profile with `--aws_profile`.  
The S3 bucket's region **must** match the region specified in the profile!

### Example
Download simfile IDs 1234 through 1235:
```
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
