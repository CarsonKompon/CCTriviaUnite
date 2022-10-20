os.loadAPI(".triviaunite/dependencies/bigfont")
os.loadAPI(".triviaunite/dependencies/json")

local monitor = peripheral.find("monitor")
local speaker = peripheral.find("speaker")

-- Redirect if monitor is found
if monitor ~= nil then
    monitor.setTextScale(0.5)
    term.redirect(monitor)
end

local MONITOR_WIDTH, MONITOR_HEIGHT = term.getSize()
local screenCenterX = math.ceil(MONITOR_WIDTH/2)
local screenCenterY = math.ceil(MONITOR_HEIGHT/2)
local currTerm = term.current()
local window = window.create(currTerm,1,1,MONITOR_WIDTH,MONITOR_HEIGHT,false)

local GAME_VERSION = "v1.1.0"

--Game vars
local GAMESTATE = 0 --0 = menu, 1 = ingame, 2 = answering, 3 = reveal, 4 = game end
local MENUSTATE = 0 --0 = main menu, 1 = how to play
local SCORE = 0
local HIGHSCORE = 0
local CORRECTANSWERS = 0
local ROUND = 0
local ROUNDTIME = 0
local WAITTIME = -1
local WAITFUNCTION = function()end
local CATEGORIES = {}
local DIFFICULTIES = {}
local QUESTIONS = {}
local OPTIONS = {}
local ANSWERS = {}
local CURRENTOPTIONS = {}
local QUESTIONTEXT = " "
local DISPLAYTEXT = " "
local TEXTTIMER = 0
local SELECTEDANSWER = 0
local SCORESAVE = ".triviaunite/highscore.sav"

local clickX = 0
local clickY = 0
local clicked = false

if monitor ~= nil then
    monitor.setBackgroundColor(colors.black)
    monitor.clear()
else
    term.setBackgroundColor(colors.black)
    term.clear()
end

local programTimer = 0

local imgLogo = paintutils.loadImage(".triviaunite/images/logo.nfp")
local imgDiamond1 = paintutils.loadImage(".triviaunite/images/diamond1.nfp")
local imgDiamond2 = paintutils.loadImage(".triviaunite/images/diamond2.nfp")
local imgDiamond3 = paintutils.loadImage(".triviaunite/images/diamond3.nfp")
local imgDiamond4 = paintutils.loadImage(".triviaunite/images/diamond4.nfp")

local menuDiamonds = {}
local menuDiamondTimer = 0


function load_highscore()
    local file = fs.open(SCORESAVE, "r")
    HIGHSCORE = tonumber(file.readAll())
    file.close()
end

function save_highscore()
    local file = fs.open(SCORESAVE, "w")
    file.write(tostring(HIGHSCORE))
    file.close()
end

if not fs.exists(SCORESAVE) then
    save_highscore()
else
    load_highscore()
end


function draw_menu_background()
    if programTimer % 21 == 0 then
        table.insert(menuDiamonds,{i=0,y=-16,x=math.floor(math.random(-8,MONITOR_WIDTH))})
    end

    for ii, d in ipairs(menuDiamonds) do
        local dimg = imgDiamond1
        if menuDiamondTimer == 1 or menuDiamondTimer == 5 then dimg = imgDiamond2
        elseif menuDiamondTimer == 2 or menuDiamondTimer == 4 then dimg = imgDiamond3
        elseif menuDiamondTimer == 3 then dimg = imgDiamond4 end

        d.y = d.y + 1
        if d.y > MONITOR_HEIGHT then
            table.remove( menuDiamonds,ii )
        end
        paintutils.drawImage(dimg,d.x,d.y)
    end

    if programTimer % 4 == 0 then
        menuDiamondTimer = menuDiamondTimer + 1
        if menuDiamondTimer > 6 then menuDiamondTimer = 0 end
    end
end

--Draw Main Menu
function draw_menu()
    window.clear()

    draw_menu_background()

    window.setTextColor(colors.black)
    window.setBackgroundColor(colors.cyan)

    window.setCursorPos(1,1)
    window.write(GAME_VERSION)

    --MAIN MENU SCREEN
    if MENUSTATE ~= 1 then
        local bcol = colors.green
        if MENUSTATE == 2 and math.floor(programTimer/20) % 2 == 0 then bcol = colors.white end

        if monitor ~= nil then
            --Play Button
            paintutils.drawFilledBox(screenCenterX-20,19,screenCenterX+20,24,bcol)
            bigfont.writeOn(term, 1, "Start Game", screenCenterX-14, 21)

            --Help Button
            paintutils.drawFilledBox(screenCenterX-20,27,screenCenterX+20,32,colors.green)
            bigfont.writeOn(term, 1, "How to Play", screenCenterX-16, 29)
        else
            --Play Button
            paintutils.drawFilledBox(screenCenterX-20,8,screenCenterX+20,10,bcol)
            term.setCursorPos(screenCenterX-5, 9)
            term.write("Start Game")

            --Help Button
            paintutils.drawFilledBox(screenCenterX-20,13,screenCenterX+20,15,colors.green)
            term.setCursorPos(screenCenterX-6, 14)
            term.write("How to Play")
        end

        window.setBackgroundColor(colors.cyan)
        window.setTextColor(colors.gray)
        local hstxt = "Highscore: " .. tostring(HIGHSCORE)
        if monitor ~= nil then
            bigfont.writeOn(term, 1, hstxt, screenCenterX-(#hstxt*1.5)+1, MONITOR_HEIGHT-2)
        else
            term.setCursorPos(screenCenterX-(#hstxt/2), MONITOR_HEIGHT-1)
            term.write(hstxt)
        end

    --HOW TO PLAY SCREEN
    else
        window.setBackgroundColor(colors.cyan)

        --Tutorial text
        local txt = ""

        if monitor ~= nil then
            window.setTextColor(colors.black)
            txt = "Trivia Unite consists of 10 rounds. Each round, you must answer either a Multiple Choice or True/False question."
            window.setCursorPos(screenCenterX-#txt/2+1, 20)
            window.write(txt)

            txt = "You gain points for each question you correctly answer. The quicker you answer, the more points you get."
            window.setCursorPos(screenCenterX-#txt/2, 22)
            window.write(txt)

            txt = "To select an answer, right click the answer button."
            window.setCursorPos(screenCenterX-#txt/2+1, 26)
            window.write(txt)

            txt = "At the end of the game, you can see how many you answered correctly, and compare your score to the current highscore!"
            window.setCursorPos(screenCenterX-#txt/2+1, 28)
            window.write(txt)

            window.setTextColor(colors.gray)
            txt = "Made by Carson Kompon"
            window.setCursorPos(screenCenterX-#txt/2+1, 34)
            window.write(txt)

            txt = "Questions provided by OpenTDB"
            window.setCursorPos(screenCenterX-#txt/2+1, 36)
            window.write(txt)
        else
            window.setTextColor(colors.black)
            txt = "Trivia Unite consists of 10 rounds. Each round,"
            window.setCursorPos(screenCenterX-#txt/2+1, 7)
            window.write(txt)

            txt = "you must answer either a Multiple Choice or"
            window.setCursorPos(screenCenterX-#txt/2+1, 8)
            window.write(txt)

            txt = "True/False question. You gain points for each"
            window.setCursorPos(screenCenterX-#txt/2+1, 9)
            window.write(txt)

            txt = "question you correctly answer. The quicker you"
            window.setCursorPos(screenCenterX-#txt/2+1, 10)
            window.write(txt)

            txt = "answer, the more points you get. To select an"
            window.setCursorPos(screenCenterX-#txt/2, 11)
            window.write(txt)

            txt = "answer, right click the answer button. At the end"
            window.setCursorPos(screenCenterX-#txt/2+1, 12)
            window.write(txt)

            txt = "of the game, you can see how many you answered"
            window.setCursorPos(screenCenterX-#txt/2+1, 13)
            window.write(txt)

            txt = "correctly & compare your score to your highscore!"
            window.setCursorPos(screenCenterX-#txt/2+1, 14)
            window.write(txt)

            window.setTextColor(colors.gray)
            txt = "Made by Carson Kompon"
            window.setCursorPos(screenCenterX-#txt/2+1, MONITOR_HEIGHT-2)
            window.write(txt)

            txt = "Questions provided by OpenTDB"
            window.setCursorPos(screenCenterX-#txt/2+1, MONITOR_HEIGHT-1)
            window.write(txt)
        end

        --Back Button
        window.setTextColor(colors.black)
        if monitor ~= nil then
            paintutils.drawFilledBox(1, MONITOR_HEIGHT-5,15,MONITOR_HEIGHT,colors.red)
            bigfont.writeOn(term, 1, "Back", 2, MONITOR_HEIGHT-3)
        else
            paintutils.drawFilledBox(1, MONITOR_HEIGHT-2,6,MONITOR_HEIGHT,colors.red)
            term.setCursorPos(2, MONITOR_HEIGHT-1)
            term.write("Back")
        end
    end

    if monitor ~= nil then
        paintutils.drawImage(imgLogo,screenCenterX-21,1)
    else
        local text = "TRIVIA UNITE"
        window.setTextColor(colors.orange)
        window.setBackgroundColor(colors.cyan)
        bigfont.writeOn(term, 1, text, screenCenterX-(#text*1.5), 3)
    end
end

--Draw Game GUI
function draw_game_gui()


    local roundTxt = tostring(ROUND) .. "/10"
    window.setTextColor(colors.black)

    if monitor ~= nil then
        bigfont.writeOn(term, 1, tostring(SCORE), 2, 2)
        bigfont.writeOn(term, 1, roundTxt,  MONITOR_WIDTH-(#roundTxt*3), 2)
    else
        term.setCursorPos(2, 2)
        term.write(tostring(SCORE))
        term.setCursorPos(MONITOR_WIDTH-(#roundTxt)-1, 2)
        term.write(roundTxt)
    end

    window.setTextColor(colors.black)

    if ROUNDTIME < (30*20)-5 then
        local drawcol = colors.red
        if GAMESTATE == 2 or CURRENTOPTIONS[1] == ANSWERS[ROUND] then drawcol = colors.green end
        local txt = unescape(CURRENTOPTIONS[1])
        if monitor ~= nil then
            paintutils.drawFilledBox(screenCenterX-25,14,screenCenterX+25,18, drawcol)
            window.setCursorPos(screenCenterX-(#txt/2), 16)
        else
            paintutils.drawFilledBox(screenCenterX-12,7,screenCenterX+11,7, drawcol)
            window.setCursorPos(screenCenterX-(#txt/2), 7)
        end
        window.write(txt)
    end
    if ROUNDTIME < (30*20)-10 then
        local drawcol = colors.red
        if GAMESTATE == 2 or CURRENTOPTIONS[2] == ANSWERS[ROUND] then drawcol = colors.green end
        local txt = unescape(CURRENTOPTIONS[2])
        if monitor ~= nil then
            paintutils.drawFilledBox(screenCenterX-25,20,screenCenterX+25,24, drawcol)
            window.setCursorPos(screenCenterX-(#txt/2), 22)
        else
            paintutils.drawFilledBox(screenCenterX-12,10,screenCenterX+11,10, drawcol)
            window.setCursorPos(screenCenterX-(#txt/2), 10)
        end
        window.write(txt)
    end
    if ROUNDTIME < (30*20)-15 and #OPTIONS[ROUND] > 1 then
        local drawcol = colors.red
        if GAMESTATE == 2 or CURRENTOPTIONS[3] == ANSWERS[ROUND] then drawcol = colors.green end
        local txt = unescape(CURRENTOPTIONS[3])
        if monitor ~= nil then
            paintutils.drawFilledBox(screenCenterX-25,26,screenCenterX+25,30, drawcol)
            window.setCursorPos(screenCenterX-(#txt/2), 28)
        else
            paintutils.drawFilledBox(screenCenterX-12,13,screenCenterX+11,13, drawcol)
            window.setCursorPos(screenCenterX-(#txt/2), 13)
        end
        window.write(txt)
    end
    if ROUNDTIME < (30*20)-20 and #OPTIONS[ROUND] > 1 then
        local drawcol = colors.red
        if GAMESTATE == 2 or CURRENTOPTIONS[4] == ANSWERS[ROUND] then drawcol = colors.green end
        local txt = unescape(CURRENTOPTIONS[4])
        if monitor ~= nil then
            paintutils.drawFilledBox(screenCenterX-25,32,screenCenterX+25,36, drawcol)
            window.setCursorPos(screenCenterX-(#txt/2), 34)
        else
            paintutils.drawFilledBox(screenCenterX-12,16,screenCenterX+11,16, drawcol)
            window.setCursorPos(screenCenterX-(#txt/2), 16)
        end
        window.write(txt)
    end

    window.setTextColor(colors.black)

    --Quit Button
    --[[
    local quittxt = "Quit"
    paintutils.drawFilledBox(MONITOR_WIDTH-15, MONITOR_HEIGHT-5,MONITOR_WIDTH,MONITOR_HEIGHT,colors.red)
    bigfont.writeOn(term, 1, quittxt, MONITOR_WIDTH-(#quittxt*3), MONITOR_HEIGHT-3)
    ]]

    window.setBackgroundColor(colors.cyan)

    --Print Category
    if ROUNDTIME < (30*20) then
        window.setCursorPos(1,MONITOR_HEIGHT)
        window.write(unescape(CATEGORIES[ROUND]))

        local diftext = "Difficulty: " .. string.sub(DIFFICULTIES[ROUND],1,1):upper() .. string.sub(DIFFICULTIES[ROUND],2)
        window.setCursorPos(MONITOR_WIDTH-#diftext, MONITOR_HEIGHT)
        window.write(diftext)
    end

    --Print timer
    local ypos = 3
    if ROUNDTIME <= 10*20 then window.setTextColor(colors.red) end
    txt = tostring(math.ceil(ROUNDTIME/20))
    if monitor == nil then
        ypos = 2
        term.setCursorPos(screenCenterX-(#txt/2), ypos)
        term.write(txt);
    else
        bigfont.writeOn(term, 1, txt, screenCenterX-(#txt*1.5), ypos)
    end
end

function draw_game()
    term.redirect(window)

    paintutils.drawFilledBox(1,1,MONITOR_WIDTH,MONITOR_HEIGHT,colors.cyan)

    --Draw Main Menu
    if GAMESTATE == 0 then
       draw_menu()

    -- Draw Game End
    elseif GAMESTATE == 4 then
        window.clear()

        draw_menu_background()

        window.setBackgroundColor(colors.cyan)
        window.setTextColor(colors.orange)
        local txt = "GAME OVER"
        bigfont.writeOn(term, 2, txt, screenCenterX-(#txt*4.5), 6)

        window.setTextColor(colors.black)
        txt = "Correct Answers: " .. tostring(CORRECTANSWERS) .. "/10"
        bigfont.writeOn(term, 1, txt, screenCenterX-(#txt*1.5), 18)

        txt = "Score: " .. tostring(SCORE)
        bigfont.writeOn(term, 1, txt, screenCenterX-(#txt*1.5), 24)

        window.setTextColor(colors.gray)
        txt = "High Score: " .. tostring(HIGHSCORE)
        bigfont.writeOn(term, 1, txt, screenCenterX-(#txt*1.5), 34)

        window.setTextColor(colors.black)

    -- Draw Game
    else

        window.clear()

        --Draw the current question
        local txt1 = DISPLAYTEXT
        local txt2 = ""
        local txtlength = 110
        local ypos = 8
        local yheight = 2
        if monitor == nil then
            txtlength = 46
            ypos = 4
            yheight = 1
        end
        if #txt1 > txtlength then
            txt2 = string.sub(txt1, txtlength + 1, #txt1)
            txt1 = string.sub(txt1, 1, txtlength)
            if string.sub(txt1,#txt1,#txt1) ~= " " and string.sub(txt2,1,1) ~= " " then txt1 = txt1 .. "-" end
        end
        window.setTextColor(colors.black)
        window.setCursorPos(screenCenterX-(#txt1/2), ypos)
        window.write(txt1)
        window.setCursorPos(screenCenterX-(#txt2/2), ypos+yheight)
        window.write(txt2)

        draw_game_gui()

    end
    term.redirect(currTerm)
    window.setVisible(true)
    window.setVisible(false)
end

function unescape(url)
    return string.gsub(url, "%%(%x%x)", function(x)
        return string.char(tonumber(x, 16))
    end)
end

--Start New Game
function start_game()

    SCORE = 0
    CORRECTANSWERS = 0
    ROUND = 0

    CATEGORIES = {}
    DIFFICULTIES = {}
    QUESTIONS = {}
    OPTIONS = {}
    ANSWERS = {}
    CURRENTOPTIONS = {}

    local hget = http.get("https://opentdb.com/api.php?amount=10&encode=url3986").readAll()
    local obj = json.decode(hget)

    for i, v in pairs(obj.results) do
        table.insert(QUESTIONS, v.question)
        table.insert(OPTIONS, v.incorrect_answers)
        table.insert(ANSWERS, v.correct_answer)
        table.insert(CATEGORIES, v.category)
        table.insert(DIFFICULTIES, v.difficulty)
    end

    start_round()

end

--Round Start
function start_round()
    ROUND = ROUND + 1
    ROUNDTIME = 30*20
    GAMESTATE = 2
    TEXTTIMER = 0
    SELECTEDANSWER = 0

    if ROUND > 10 then
       end_game()
    else
        QUESTIONTEXT = QUESTIONS[ROUND]
        DISPLAYTEXT = ""

        CURRENTOPTIONS = {}

        if #OPTIONS[ROUND] == 1 then
            table.insert(CURRENTOPTIONS, "True")
            table.insert(CURRENTOPTIONS, "False")
        else
        local offset = math.floor(math.random(0,#OPTIONS[ROUND]+0.99))
            for i = 1,#OPTIONS[ROUND]+1 do
                local v = offset + i
                while v > #OPTIONS[ROUND]+1 do v = v - (#OPTIONS[ROUND]+1) end
                if v == #OPTIONS[ROUND]+1 then
                    table.insert(CURRENTOPTIONS, ANSWERS[ROUND])
                else
                    table.insert(CURRENTOPTIONS, OPTIONS[ROUND][v])
                end
            end
        end
    end
end

--Game End
function end_game()
    ROUND = 10
    GAMESTATE = 4

    if SCORE > HIGHSCORE then
        HIGHSCORE = SCORE
        save_highscore()
    end

    menuDiamonds = {}

    WAITTIME = 8 * 20
    WAITFUNCTION = function ()
        GAMESTATE = 0
        MENUSTATE = 0
        SCORE = 0
        ROUND = 0
        ROUNDTIME = 0
    end
end

--Select Answer
function select_answer(num)
    GAMESTATE = 3
    SELECTEDANSWER = num

    if SELECTEDANSWER > 0 then
        if ANSWERS[ROUND] == CURRENTOPTIONS[SELECTEDANSWER] then
            SCORE = SCORE + math.ceil(1000*((ROUNDTIME+(30*20))/(60*20)))
            CORRECTANSWERS = CORRECTANSWERS + 1
            if speaker ~= nil then
                speaker.playSound("minecraft:entity.player.levelup", 0.5)
            end
        else
            if speaker ~= nil then
                speaker.playSound("minecraft:entity.witch.ambient", 0.5)
            end
        end
    else
        if speaker ~= nil then
            speaker.playSound("minecraft:entity.witch.ambient", 0.5)
        end
    end

    WAITTIME = 20 * 4
    WAITFUNCTION = start_round

end

--Update Game
function update_game()
    programTimer = programTimer + 1

    --Mouse clicked events
    if clicked then

        --MAIN MENU STATE
        if GAMESTATE == 0 then
            --Main Menu
            if MENUSTATE == 0 then
                local pressStartGame = (clickX >= screenCenterX-20 and clickY >= 19 and clickX <= screenCenterX+20 and clickY <= 24)
                local pressHowToPlay = (clickX >= screenCenterX-20 and clickY >= 27 and clickX <= screenCenterX+20 and clickY <= 32)
                if monitor == nil then
                    pressStartGame = (clickX >= screenCenterX-20 and clickY >= 8 and clickX <= screenCenterX+20 and clickY <= 10)
                    pressHowToPlay = (clickX >= screenCenterX-20 and clickY >= 13 and clickX <= screenCenterX+20 and clickY <= 15)
                end
                --Start Game Button
                if pressStartGame then
                    --Play the epic music, then change the gamestate after 80 ticks
                    if speaker ~= nil then
                        speaker.playSound("minecraft:ui.toast.challenge_complete")
                    end
                    MENUSTATE = 2
                    WAITTIME = 80
                    WAITFUNCTION = function()
                        MENUSTATE = 0
                        ROUND = 0
                        ROUNDTIME = 30 * 20
                        GAMESTATE = 1

                        DISPLAYTEXT = ""

                        WAITTIME = 20
                        WAITFUNCTION = start_game
                    end
                --How To Play Button
                elseif pressHowToPlay then
                    MENUSTATE = 1
                    if speaker ~= nil then
                        speaker.playSound("minecraft:ui.button.click")
                    end
                end

            --How To Play Menu
            elseif MENUSTATE == 1 then
                --Back Button
                if clickX >= 1 and clickY >= MONITOR_HEIGHT-5 and clickX <= 15 and clickY <= MONITOR_HEIGHT then
                    MENUSTATE = 0
                    if speaker ~= nil then
                        speaker.playSound("minecraft:ui.button.click")
                    end
                end
            end

        --GAME STATE
        elseif GAMESTATE == 2 then
            if monitor ~= nil then
                if clickX >= screenCenterX-25 and clickY >= 14 and clickX <= screenCenterX+25 and clickY <= 18 then
                    select_answer(1)
                elseif clickX >= screenCenterX-25 and clickY >= 20 and clickX <= screenCenterX+25 and clickY <= 24 then
                    select_answer(2)
                elseif clickX >= screenCenterX-25 and clickY >= 26 and clickX <= screenCenterX+25 and clickY <= 30 then
                    select_answer(3)
                elseif clickX >= screenCenterX-25 and clickY >= 32 and clickX <= screenCenterX+25 and clickY <= 36 then
                    select_answer(4)
                end
            else
                if clickX >= screenCenterX-12 and clickX <= screenCenterX+11 and clickY == 7 then
                    select_answer(1)
                elseif clickX >= screenCenterX-12 and clickX <= screenCenterX+11 and clickY == 10 then
                    select_answer(2)
                elseif clickX >= screenCenterX-12 and clickX <= screenCenterX+11 and clickY == 13 then
                    select_answer(3)
                elseif clickX >= screenCenterX-12 and clickX <= screenCenterX+25 and clickY == 16 then
                    select_answer(4)
                end
            end
        end
        clicked = false
    end

    if WAITTIME > 0 then
        WAITTIME = WAITTIME - 1
        if WAITTIME == 0 then
            WAITTIME = -1
            WAITFUNCTION()
        end
    end

    if GAMESTATE == 2 then
        --Round Timer
        if ROUNDTIME > 0 then

            --Type the question
            local txttocopy = unescape(QUESTIONTEXT)
            if #DISPLAYTEXT < #txttocopy then
                if speaker ~= nil then
                    speaker.playSound("minecraft:block.note.snare", 0.2, math.random(1,2))
                end
                DISPLAYTEXT = DISPLAYTEXT .. string.sub(txttocopy,#DISPLAYTEXT+1,#DISPLAYTEXT+1)
            end

            ROUNDTIME = ROUNDTIME - 1

            if ROUNDTIME == 0 then
                select_answer(0)
            end

            if ROUNDTIME % 20 == 0 then
                local sndpitch = 0.5
                if math.floor(ROUNDTIME / 20) % 2 == 0 then sndpitch = 0.625 end
                if ROUNDTIME <= 10*20 then sndpitch = sndpitch * 1.5 end
                if speaker ~= nil then
                    speaker.playSound("minecraft:block.comparator.click", 0.18, sndpitch)
                end
            end
        end
    end

end

--MAIN GAME
function main_game()
    update_game()
    draw_game()

    os.sleep()
end

--Get mouse input
function get_input()
    if monitor ~= nil then
        event, side, xClick, yClick = os.pullEvent("monitor_touch")
    else
        event, side, xClick, yClick = os.pullEvent("mouse_click")
    end

    clicked = true
    clickX = xClick
    clickY = yClick
end

-- MAIN LOOP
while true do

    parallel.waitForAny(get_input, main_game)

end