--Trivia Unite Installer

--Create folder structure
shell.run("mkdir .triviaunite")
shell.run("mkdir .triviaunite/dependencies")
shell.run("mkdir .triviaunite/json")

--Download required APIs
shell.run("wget https://raw.githubusercontent.com/cklidify/CCTriviaUnite/main/.triviaunite/dependencies/bigfont.lua .triviaunite/dependencies/bigfont")
shell.run("wget https://raw.githubusercontent.com/cklidify/CCTriviaUnite/main/.triviaunite/dependencies/json.lua .triviaunite/dependencies/json")

--Download Trivia Unite Images
shell.run("wget https://raw.githubusercontent.com/cklidify/CCTriviaUnite/main/.triviaunite/images/logo.nfp .triviaunite/images/logo.nfp")
shell.run("wget https://raw.githubusercontent.com/cklidify/CCTriviaUnite/main/.triviaunite/images/diamond1.nfp .triviaunite/images/diamond.nfp")
shell.run("wget https://raw.githubusercontent.com/cklidify/CCTriviaUnite/main/.triviaunite/images/diamond2.nfp .triviaunite/images/diamond1.nfp")
shell.run("wget https://raw.githubusercontent.com/cklidify/CCTriviaUnite/main/.triviaunite/images/diamond3.nfp .triviaunite/images/diamond2.nfp")
shell.run("wget https://raw.githubusercontent.com/cklidify/CCTriviaUnite/main/.triviaunite/images/diamond4.nfp .triviaunite/images/diamond3.nfp")

--Download Trivia Unite
shell.run("wget https://raw.githubusercontent.com/cklidify/CCTriviaUnite/main/triviaunite.lua triviaunite")

--Reboot Computer
print("Trivia Unite &3installed successfully!")