## fetchme
Rewrite of fetchme-bash in C99. Similiar to neofetch, but in C, so it should be able to do more.
<img src="https://user-images.githubusercontent.com/72793802/177895040-738fffa7-4ce1-4a70-b3e1-e6413702f2b6.png" align="right">

download with:

``git clone https://github.com/Connor-GH/fetchme``

compile with:

``cd fetchme``

# [You have to make a choice here: do you want to compile with gcc?]

``make CC=gcc bin/fetchme``

# [Or do you want to compile with Clang?]

``make CC=clang bin/fetchme``

or to install it to /usr/bin:

``sudo make clean CC=gcc-or-clang bin/fetchme install``


read the changelog
<a href="docs/CHANGELOG.md">here</a>

# Dependencies:
- clang or gcc
- libx11
- libpci
- libxrandr
