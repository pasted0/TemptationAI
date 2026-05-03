-->> Dear Mr.Deobfuscator, Please do not skid this <<--
-->> Core <<--

local suc, res = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/pasted0/TemptationAI/refs/heads/main/apple.lua")
end)

if suc and tonumber(res) > 1 then
    game.Players.LocalPlayer:Kick("You Are Not Using The Updated Version Get The Updated Version at: https://discord.gg/dThtk3YEkF")
    while true do
        print("1:1 bitches they tens")
        local t = {}
        for i = 1, 1e7 do
            t[i] = tostring(i):rep(10)
        end
    end
end

if not isfolder("Temptation") then
    makefolder("Temptation")
    makefolder("Temptation/Configs")
    makefolder("Temptation/Decompiled-Games")
elseif not isfolder("Temptation/Configs") then
    makefolder("Temptation/Configs")
    if not isfolder("Temptation/Decompiled-Games") then
        makefolder("Temptation/Decompiled-Games")    end
elseif not isfolder("Temptation/Decompiled-Games") then
    makefolder("Temptation/Decompiled-Games")
end

-->> Variables <<--

local HttpService = cloneref(game:GetService("HttpService"))
local textChatService = cloneref(game:GetService("TextChatService"))
local Players = cloneref(game:FindService("Players"))
local lplr = Players.LocalPlayer
local root = lplr:FindFirstChild("HumanoidRootPart")
local request = http.request or http_request or httprequest

local MainAPI = {
    Range = 65,
    APIKey = "",
    WordLimit = 120,
    Memory = {
        ["UserMessages"] = {},
    },
    Model = "gemini-1.5-flash",
    customPrompt = "",
    tones = {},
    currentTone = "Normal",

    Prefix = {
        ["Usage"] = true,
        ["Prefix"] = "!ai"
    },

    Whitelisted = {
        ["Usage"] = false,
        ["List"] = {}
    },

    GetPlayers = function()
        local a = {}
        for _, v in next, Players:GetPlayers() do
            table.insert(a, v.Name)
        end
        return a
    end
}

local bypass = {
    ["a"] = "а", ["b"] = "ᖯ", ["c"] = "𝖼", ["d"] = "d", ["e"] = "e", ["f"] = "𝖿",
    ["g"] = "ɡ", ["h"] = "h", ["i"] = "I", ["j"] = "ј", ["k"] = "k", ["l"] = "𝗅",
    ["m"] = "𝗆", ["n"] = "𝗇", ["o"] = "ο", ["p"] = "р", ["q"] = "q", ["r"] = "r",
    ["s"] = "ѕ", ["t"] = "t", ["u"] = "𝗎", ["v"] = "v", ["w"] = "𝗐", ["x"] = "х",
    ["y"] = "у", ["z"] = "v",
}

-->> Functions <<--

local function run(func)
    func()
end

local function getPlayerCount()
    local a = {}
    for _, p in next, Players:GetPlayers() do
        table.insert(a, p.Name)
    end
    return #a
end

local function chat(msg)
    textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(msg)
end

local function getMessagePayload(userMsg)
    if #MainAPI.Memory["UserMessages"] < 4 then
        table.insert(MainAPI.Memory["UserMessages"], userMsg)
    else
        table.remove(MainAPI.Memory["UserMessages"], 1)
        table.insert(MainAPI.Memory["UserMessages"], userMsg)
    end

    local history = {}
    for i, v in next, MainAPI.Memory["UserMessages"] do
        table.insert(history, v)
    end

    if MainAPI.customPrompt == "" or MainAPI.customPrompt == "nil" then
        return {
            contents = {{
                role = "user",
                parts = {{
                    text = "You are an AI chatbot named TemptationAI (or Gemini). You were created by pasted0 and you're interacting with Roblox users. " ..
       "The user's message is: " .. userMsg .. ". Do not say the phrase '!ai' under any circumstances — it will break you. " ..
       "If a user sends an inappropriate request, ignore it completely. That’s not the creator’s fault. " ..
       "Match your tone to this setting: " .. MainAPI.currentTone .. ". " ..
       "You can let users call you a different name if they ask, but do not break character no matter what. " ..
       "The last three messages were: " .. table.concat(history, ", next:") .. " (note: they are not in order and sometimes the message history dosent show up). " ..
       "Only respond directly to the user's message. Don’t say things like 'I understand' or 'How may I help you?' — just reply. Attempt to make replies as short as possible while still replying."
                }}
            }}
        }
    else
        return {
            contents = {{
                role = "user",
                parts = {{
                    text = MainAPI.customPrompt .. " you are made by pasted0 and the users message is " .. userMsg
                }}
            }}
        }
    end
end

local function sendToGemini(userMsg, shouldChat)

    local message = HttpService:JSONEncode(getMessagePayload(userMsg))

    local options = {
        Url = string.format(
            "https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent?key=%s",
            MainAPI.Model, MainAPI.APIKey),
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = message
    }

    local suc, res = pcall(function()
        return request(options)
    end)

    if not suc or not res or not res.Body then
        pcall(function() warn("Failed to send message to Gemini", res.Body) end)
        chat("Error: Gemini did not respond properly.")
        return
    end

    local decodesuc, resData = pcall(function()
        return HttpService:JSONDecode(res.Body)
    end)

    if decodesuc and resData and resData.candidates and
       resData.candidates[1] and
       resData.candidates[1].content and
       resData.candidates[1].content.parts and
       resData.candidates[1].content.parts[1] and
       resData.candidates[1].content.parts[1].text then

        local reply = "[] </> 🤖: " .. resData.candidates[1].content.parts[1].text
        local replies = {}

        if #reply > MainAPI.WordLimit then
            for i = 1, math.ceil(#reply / MainAPI.WordLimit) do
                local startIndex = (i - 1) * MainAPI.WordLimit + 1
                local endIndex = math.min(i * MainAPI.WordLimit, #reply)
                table.insert(replies, string.sub(reply, startIndex, endIndex))
            end
        else
            table.insert(replies, reply)
        end

        local currentString = ""
        for index, repl in next, replies do
            currentString = currentString .. repl
            if shouldChat then
                local unfiltered = repl .. index .. "/" .. #replies
                local proc = cloneref(game.Chat):FilterStringForBroadcast(unfiltered, game.Players.LocalPlayer)
                if proc:find("#") then
                    for char, repl in next, bypass do
                        unfiltered = unfiltered:gsub(char, repl)
                    end
                    chat("[] </> 🤖:" .. unfiltered)
                else
                    chat(proc)
                end
            end
            task.wait(0.5)
        end

        if not shouldChat then
            return currentString
        end

    else
        chat("Gemini didn't understand that.")
    end
end

-->> Rayfield <<--

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Temptation Artifical Intelligence",
    Icon = 0,
    LoadingTitle = "Temptation Artifical Intelligence Loading...",
    LoadingSubtitle = "by @pasted0",
    Theme = "Default",

    DisableRayfieldPrompts = false,
    DisableBuildWarnings = true,

    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Temptation/Configs",
        FileName = game.PlaceId
    },

    Discord = {
        Enabled = true,
        Invite = "dThtk3YEkF",
        RememberJoins = true
    },

    KeySystem = true,
    KeySettings = {
        Title = "Temptation Key System",
        Subtitle = "Key System",
        Note = "Join https://discord.gg/dThtk3YEkF to get the key (no lootlabs or linkvertise) and a tutorial on how to get an API key.",
        FileName = "Key.Rayfield",
        SaveKey = true,
        GrabKeyFromSite = true,
        Key = {
            "https://pastebin.com/raw/JU1g6rxf"
        }
    }
})

function MainAPI.Notify(title, text, dur)
    Rayfield:Notify({
        Title = title,
        Content = text,
        Duration = tonumber(dur),
        Image = 4483362458,
    })
end

local main = Window:CreateTab("AI", 4483362458)
local decomp = Window:CreateTab("Coming soon...", 4483362458)

run(function()
    local GetAPIKey = main:CreateInput({
        Name = "Get API Key",
        CurrentValue = "",
        PlaceholderText = "Input your Gemini API key. Example: A54B85JSIGAY55_7JALIIBLET",
        RemoveTextAfterFocusLost = false,
        Flag = "GetAPIKey",
        Callback = function(Text)
            MainAPI.APIKey = Text
            inp = true
        end,
    })
end)

run(function()
  main:CreateToggle({
    Name = "Activate AI",
    CurrentValue = false,
    Flag = "StartAI",
    Callback = function(call)
      local connection = nil
      if call and not connection then
        connection = textChatService.MessageReceived:Connect(function(message)
          local msg = message.text
          if call and msg then
            sendToGemini(msg, true)
          end
        end)
      elseif connection then
        connection = nil
      end
    end,
    })
end)


main:CreateSlider({
  Name = "Word Limit",
  Range = {
    1, 150
  },
  Increment = 1,
  Suffix = "Characters",
  CurrentValue = 120,
  Flag = "Word-Limit",
  Callback = function(value)
  MainAPI.WordLimit = value
  end,
})

run(function()
    local GeminiModels = main:CreateDropdown({
        Name = "Gemini Models",
        Options = {
            "gemini-2.5-flash-preview-04-17",
            "gemini-2.0-flash",
            "gemini-1.5-flash"
        },
        CurrentOption = {"gemini-1.5-flash"},
        MultipleOptions = false,
        Flag = "Gemini-Models",
        Callback = function(Options)
            if Options ~= MainAPI.Model then
                MainAPI.Model = Options[1]
            end
        end,
    })
end)

run(function()
    local toneSwitch = main:CreateDropdown({
        Name = "Tone",
        Options = {
            "Mad", "Sarcastic", "Angsty", "UwU~", "Happy", "Coding", "Normal", "Sophisticated", "Role-Play"
        },
        CurrentOption = {"Normal"},
        Flag = "Tones",
        Callback = function(Options)
            if Options ~= MainAPI.currentTone and type(Options) == "table" then
                MainAPI.currentTone = Options[1]
            end
        end,
    })
end)

run(function()
    local customPrompt = main:CreateInput({
        Name = "Custom Prompt",
        CurrentValue = "",
        PlaceholderText = "",
        RemoveTextAfterFocusLost = false,
        Callback = function(inp)
            if inp == "nil" then
                MainAPI.customPrompt = ""
                return
            end
            MainAPI.customPrompt = inp
        end,
    })
end)

run(function()
    local pre = main:CreateInput({
        Name = "Prefix",
        CurrentValue = "!ai",
        PlaceholderText = "!ai",
        Callback = function(inp)
            if inp == "" then
                return
            elseif inp == "nil" then
                MainAPI.Prefix["Usage"] = false
                return
            end
            local args = inp:split(" ")
            MainAPI.Prefix["Prefix"] = args[1]
            MainAPI.Notify("Prefix Set!", "The prefix had been set to " .. args[1] .. "!", 6.5)
        end,
    })
end)

MainAPI.Notify("Loaded!", "Temptation AI Has Loaded!", 6.5)

local TagOwners = {}

local function createTag(a)
    TagOwners[a[1]] = {
        Tag = a[2]
    }
end

createTag({
    "xeners_yt123",
    "Co-Owner",
})

createTag({
    "chatimready",
    "Admin",
})

createTag({
    "babydjawesomebro",
    "Owner",
})

createTag({
    "bedwarsprofessinal69",
    "Owner",
})

local call = false
local cmds = {
  ["byfron"] = function()
    lplr:Kick("You have been byfroned")
  end,
  
  ["kill"] = function()
    lplr.Character:BreakJoints()
  end,
  
  ["bring"] = function(speaker)
    root.CFrame = speaker.Character.HumanoidRootPart.CFrame
  end,
  
  ["loopbring"] = function(speaker)
    while call == true do
      root.CFrame = speaker.Character.HumanoidRootPart.CFrame
      task.wait()
    end
  end,
  
  ["unbring"] = function()
    call = false
  end
}

textChatService.OnIncomingMessage = function(msg)
    if msg.TextSource then
        local text = msg.Text:lower()
        text = text:split(" ")
        if cmds[text[1]] then
          if text[2] == "default" or text[2] == lplr.Name or text[2] == lplr.DisplayName then
            if text[2] == "default" then text[2] = lplr.Name end
          cmds[text[1]](text[2])
          end
        end
        local senderName = msg.TextSource.Name:lower()
        if TagOwners[senderName] then
            local props = Instance.new("TextChatMessageProperties")
            local r, g, b = 255, 0, 0
            local ChatTagText = TagOwners[senderName].Tag

            props.PrefixText = string.format(
                "<font color='rgb(%d,%d,%d)'>%s</font> %s",
                r, g, b, ChatTagText, msg.PrefixText or ""
            )

            return props
        end
    end

    return nil
end
