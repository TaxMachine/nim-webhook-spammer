import 
    std/[httpclient, strutils, json, os, re, rdstdin, times]

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

proc clear: void = discard execShellCmd(when defined(windows): "cls" else: "clear")

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
    ## Verify if the given webhook exists
    let response = client.request(webhook, HttpGet)
    return response.status == $Http200

proc getWebhook(webhook: string): JsonNode =
    ## Get the webhook data from a given webhook
    ## - Raise Exception if the webhook doesnt exist
    ## - Returns the webhook data as a JsonNode
    if not verifyWebhook(webhook): raise newException(Exception, "Webhook doesn't exist")
    let response = client.request(webhook, HttpGet)
    return parseJson(response.body)

proc sendWebhook(webhook: string, data: JsonNode): bool =
    ## Send a given message to a give webhook
    let response = client.request(webhook, HttpPost, $data)
    return response.status == $Http200 or response.status == $Http204

proc deleteWebhook(webhook: string): bool =
    ## Deletes a given webhook and sends a delete message to the webhook before deleting it
    ## - Raise Exception if the webhook doesnt exist or if the message fails to send
    ## - Returns true if the webhook was successfully deleted
    ## - Returns false if the webhook was not deleted
    ## - Writes the webhook data to a file in the deleted_webhooks folder
    ## - The file name is the current date and time
    if not verifyWebhook(webhook): raise newException(Exception, "Webhook doesn't exist")
    var webhokhgofphkoikghd = getWebhook(webhook)
    if not sendWebhook(webhook, config["deleteMessage"]): raise newException(Exception, "There was an error while sending the delete message")
    let response = client.request(webhook, HttpDelete)
    var now = now()
    createDir("deleted_webhooks")
    var file = open("deleted_webhooks/" & now.format("yyyy-MM-dd") & ".log", fmAppend)
    file.write("[" & now.format("H-m-s") & "] " & $webhokhgofphkoikghd)
    file.close()
    return response.status == $Http204 or response.status == $Http200

when isMainModule:
    var 
        webhook = commandLineParams()[0]
        res: JsonNode
    if webhook.len == 0 or not webhook.match(WEBHOOK_REGEX):
        echo "[-] Please enter a valid webhook"
        quit(0)

    echo "Checking if " & webhook.split("/")[5] & "/" & webhook.split("/")[6] & " is valid"
    let response = client.request(webhook, HttpGet)
    if verifyWebhook(webhook):
        echo "[+] Webhook is valid"
        res = parseJson(response.body)
    else:
        echo "[-] Webhook is invalid"
        quit(0)
    var choice: string
    echo "[1] - Spam the webhook"
    echo "[2] - Delete the webhook"
    while true:
        let ok = readLineFromStdin("[1/2] - ", choice)
        if not ok: break
        case choice:
        of "1":
            break
        of "2":
            try:
                if deleteWebhook(webhook):
                    echo "[+] Webhook Successfully deleted"
                else:
                    echo "[-] There was an error while trying to delete the webhook"
            except Exception as e:
                echo e.msg
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
                echo "[-] Webhook got deleted"
                quit(0)
            of $Http429:
                echo "[-] Rate limited, waiting 5 seconds"
                sleep(5000)
            else:
                echo "[-] Unknown error"
                echo response.status
                echo response.body
                quit(0)
        sleep(1500)