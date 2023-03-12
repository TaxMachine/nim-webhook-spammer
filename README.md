# WaifuWare Webhook Spammer
This repo contains 2 applications

## Command line edition
The command line edition of this tool works like this

- Customize your message and embed in the [config.json](config.json) file
- Execute the spammer binary
```cmd
spammer.exe https://discord.com/api/webhooks/id/token
```
- OR if you want to compile it (you will need to install [nim](https://nim-lang.org))
```cmd
nim c spammer.nim
```