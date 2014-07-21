very-important-buffers.vim
==========================

All buffers are not created equal. Some buffers are more important. They are Very Important Buffers (VIB).
This plugins helps manage these buffers in Vim. You can add your most used buffers to VIB list and quickly switch to them. An indipendent VIB list is maintained for each tab.

## Installation
This plugin follows the standard runtime path structure and it can be installed with a variety of plugin managers:

* Vundle
  * Add this line to your ~/.vimrc (or $HOME\vimfiles\.vimrc on Windows) configuration file:
  * `Bundle 'andreax79/very-important-buffers.vim'`
* Pathogen
  * Go in your Vim bundle directory ~/.vim/bundle ($HOME\vimfiles\bundle on Windows) and execute the following commands:
  * `git clone git@github.com:andreax79/very-important-buffers.vim`
* Manual
  * Copy all of the files into your `~/.vim` ($HOME\vimfiles on Windows) directory

## Basic commands
* `:VIBAdd`
 * Add the current buffer to the current tab very important buffers.

* `:VIBRemove`
 * Remove the current buffer from the current tab very important buffers.

* `:VIBToggle`
 * Toggle the current buffer from the current tab very important buffers.

* `:VIBAddAll`
 * Add all the open buffers to the current tab very important buffers.

* `:VIBRemoveAll`
 * Clean the current tab very important buffers.

* `:VIBls`
 * Show very important buffers.

* `:VIBn`
 * Switch to next very important buffer.

* `:VIBp`
 * Switch to previous very important buffer.

## VIB Explorer

VIB Explorer lists VIB as tabs along the top of Vim. It is derived from the MiniBufExpl plugin. You can switch to a VIB clicking the buffer name. By default, VIB Explorer is opened automatically when you add a buffer to VIB. 

![img](http://s23.postimg.org/kmls991zf/vib.png)

### VIB Explore commands
* `:VIBFocus`
 * Focus into the VIB window.

* `:VIBOpen`
 * Open the VIB explorer.

* `:VIBClose`
 * Close the VIB Explorer if it's open.

* `:VIBToggleExplorer`
 * Toggle the Explorer open and closed.
