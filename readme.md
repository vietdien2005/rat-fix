# Rat Fix 🐁

> This is a simple script that remap the side button of the mouse and reverse the scroll direction

## Why ?

- I hate macOS, but I can't switch to another one because of work reasons. It is very difficult to customize mouse or keyboard shortcuts comfortably on MacOS, except by using some third-party software. However, using those software often installs many unnecessary features and carries significant security risks.
- So, the idea is to create a simple script that has only the specific functionality I need (hopefully, you too ^^! )
- It has been an interesting experience because I didn't know much about the MacOS operating system, Objective C language, or device functions. Previously, I used the `mac-mouse-fix` software, but it had quite a few bugs and was no longer free. Therefore, I decided to learn and read the code from the `mac-mouse-fix` repo, and I gained a lot of knowledge from it.
- If you want an easy life, just spend $10 to buy `mac-mouse-fix`. But if you're up for a challenging adventure, keep reading below and fine-tune my script to fit your needs.

## Features

- Remap side button 3 of the mouse to move to the right workspace.
- Remap side button 4 of the mouse to move to the left workspace.
- Reverse the scroll direction.

## Build on MacOS

- Command: `gcc -framework ApplicationServices -framework Foundation ./rat.m -o rat`
- Run: `./rat`

## Library

- CGSInternal - https://github.com/NUIKit/CGSInternal

