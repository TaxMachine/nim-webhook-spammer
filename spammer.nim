import 
    std/[httpclient, strutils, json, os, re, rdstdin]

var
    config = parseFile("config.json")
    client = newHttpClient()
    body = config["message"]
    spammed: int = 0
    WEBHOOK_REGEX: Regex = re"https://(.*?)discord\.com\/api\/webhooks\/"
    
client.headers = newHttpHeaders({
    "Content-Type": "application/json",
    "User-Agent": "WaifuWare Webhook Spammer"
})

proc clear: void {.compileTime.} = discard execShellCmd(when defined(windows): "cls" else: "clear")

proc printDashboard(res: JsonNode, spammed: int): void =
    clear()
    echo "-----------------------------------------------"
    echo "WaifuWare Webhook Spammer"
    echo "-----------------------------------------------"
    echo "Webhook Name: " & res["name"].getStr
    echo "Webhook Channel: " & res["channel_id"].getStr
    echo "Webhook Guild: " & res["guild_id"].getStr
    echo "Webhook ID: " & res["id"].getStr
    echo "Webhook Token: " & res["token"].getStr
    echo "Webhook Avatar: " & res["avatar"].getStr
    echo "-----------------------------------------------"
    echo "Messages Spammed: " & $spammed
    echo "-----------------------------------------------"

proc verifyWebhook(webhook: string): bool =
    let response = client.request(webhook, HttpGet)
    echo response.status
    return response.status == $Http200

when isMainModule:
    
    var 
        webhook = commandLineParams()[0]
        res: JsonNode
    if webhook.len == 0 or not webhook.match(WEBHOOK_REGEX):
        echo "[-] Please enter a valid webhook"
        quit(0)

    echo "Checking if " & webhook.split("/")[4] & "/" & webhook.split("/")[5] & " is valid"
    let response = client.request(webhook, HttpGet)
    if verifyWebhook(webhook):
        echo "[+] Webhook is valid"
        res = parseJson(response.body)
    else:
        echo "[-] Webhook is invalid"
        quit(0)
    
    while true:
        let response = client.request(webhook, HttpPost, $body)
        case response.status:
            of $Http200:
                printDashboard(res, spammed)
                inc(spammed)
            of $Http204:
                printDashboard(res, spammed)
                inc(spammed)
            of $Http404:
                echo "[-] Webhook get deleted"
                quit(0)
            of $Http429:
                echo "[-] Rate limited, waiting 5 seconds"
                sleep(5000)
            else:
                echo "[-] Unknown error"
                echo response.status
                echo response.body
                quit(0)
        #sleep(1500)