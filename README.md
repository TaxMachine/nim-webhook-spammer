# WaifuWare Webhook Spammer
This repo contains 2 applications

## Command line edition
The command line edition of this tool works like this

- Customize your message and embed in the [config.json](config.json) file
- Compile the program (you will need to install [nim](https://nim-lang.org))
```cmd
nim c spammer.nim
```
- Execute the spammer binary
```cmd
bin\spammer.exe https://discord.com/api/webhooks/id/token
```
- If you're on linux you already know how that shit works