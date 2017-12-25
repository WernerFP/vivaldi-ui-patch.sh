# vivaldi-ui-patch.sh

## Introduction

Extended customizations in vivaldi presuppose a patch of the file `browser.html` in the relevant Vivaldi installation directory. 

Adding customized CSS style requires following line inside the `<head>` element of `browser.html`:
```
<link rel="stylesheet" href="style/custom.css" />
```
Adding customized JavaScript functionality requires following line inside the `<body>` element of `browser.html`:
```
<script src="custom.js"></script>
```
Modified CSS code resp. JavaScript code can be included in Vivaldi with `custom.css` resp. `custom.js` files. The changes will be effective after the files have been copied into the appropriate Vivaldi installation directory:
```
/opt/<vivaldi or vivaldi-snapshot>/resources/vivaldi/style/custom.css
/opt/<vivaldi or vivaldi-snapshot>/resources/vivaldi/custom.js
```

## What vivaldi-ui-patch.sh does

* The script checks for existing Vivaldi installations and offers them for a patch selection.
* Before the patch is executed, you will be asked if you want to make a backup of the file `browser.html` first.
* The script now copies the files `custom.css` and/or `custom.js` into the target directory..

Updates of Vivaldi will overwrite the `browser.html` file. Then you can simply run the script again.

If the file `browser.html` has already been patched, the script can be used to transfer changes of `custom.css` and/or `custom.js` into the target directories of the chosen Vivaldi installation.

## Requirements

The files `custom.css` and/or `custom.js` must be placed in the same directory that contains the bash script.

The bash script was written for Arch Linux, but should work just as well in other Linux distributions.
