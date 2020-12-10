--Trivia Unite Installer

--Download required APIs
shell.run("pastebin get 3LfWxRWh bigfont")
shell.run("pastebin get 4nRg9CHU json")

--Download Trivia Unite Images
shell.run("wget https://raw.githubusercontent.com/cklidify/CCTriviaUnite/main/logo.nfp logo.nfp")
shell.run("wget https://raw.githubusercontent.com/cklidify/CCTriviaUnite/main/diamond.nfp diamond.nfp")
shell.run("wget https://raw.githubusercontent.com/cklidify/CCTriviaUnite/main/diamond1.nfp diamond1.nfp")
shell.run("wget https://raw.githubusercontent.com/cklidify/CCTriviaUnite/main/diamond2.nfp diamond2.nfp")
shell.run("wget https://raw.githubusercontent.com/cklidify/CCTriviaUnite/main/diamond3.nfp diamond3.nfp")

--Download Trivia Unite
shell.run("wget https://raw.githubusercontent.com/cklidify/CCTriviaUnite/main/startup.lua startup.lua")

--Reboot Computer
shell.run("reboot")