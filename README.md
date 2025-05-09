# Segment CLI

The Segment CLI (segmentcli) is a command line utility used to work with Analytics
Live Plugins in your Segment work space.

```bash
Usage: segmentcli <command> [options]

A command line utility to interact with and drive Segment

Groups:
  profile         Work with stored profiles on this device
  analytics       Send custom crafted events to Segment
  liveplugins     Work with and develop analytics live plugins
  sources         View and edit workspace sources

Commands:
  auth            Authenticate with Segment.com and assign a profile name
  import          Import CSV data into Segment from
  scaffold        Create baseline implementation of a given code artifact
  repl            Segment virtual development environment
  help            Prints help information
  version         Prints the current version of this app
```

## Getting Started

### Installing `segmentcli`.

```
git clone https://github.com/segment-integrations/segmentcli.git
cd segmentcli
sudo make install
```

A binary `segmentcli` will be installed to `/usr/local/bin`.

## Authenticating

The command to authenticate is as follows:

```bash
$ segmentcli auth <ProfileName> <AuthToken>
```

`ProfileName` - is the name you give to this workspace so you can distinguish
between various local profiles.

`AuthToken` - is the AuthToken associated with your workspace. You must create
an Auth token in your Segment workspace.

### Creating an Auth Token

1. Log into https://app.segment.com
1. Navigate to Settings > Workspace Settings > Access Management > Tokens
1. Generate a new token using the "Create token" button with the Workspace Owner role.

## Using `segmentcli` with Analytics Live.

### Enabling the Analytics Live Plugins feature

Reach out to your Customer Support Engineer (CSE) or Customer Success Manager (CSM) 
to have them add this feature to your account.  Once that is completed, you may continue.

### Uploading Your Analytics Live Plugins to Your Workspace

In order to upload your Analytics Live Plugins you'll need the following command:

```bash
$ segmentcli liveplugins upload <SourceId> <FileName>
```

`SourceId` - This is listed next your Write Key in the Segment app.
`FileName` - The name of the JavaScript file containing your code.

Note: It will take a few minutes for your Source's setting payload to be update
with the Analytics Live Plugin file URL.

## Finding Your SourceID

1. Log into https://app.segment.com
1. Navigate to Connections > Sources
1. Choose the source for which we're adding Analytics Live Plugins
1. Navigate to Settings > API Keys
1. You'll find the "Source ID" at the top of the page.


## References

Learn more about Analytics Live Plugins for [Swift](https://github.com/segment-integrations/analytics-swift-live) and [Kotlin](https://github.com/segment-integrations/analytics-swift-live).

