#!/bin/bash

# Example to set up a telegram bot web hook
BOT_TOKEN="BOT_TOKEN_HERE"
URL="https://example.com/bot/$BOT_TOKEN"

curl -F "url=$URL" "https://api.telegram.org/bot$BOT_TOKEN/setWebhook"
