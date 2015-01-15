all: osx

osx:
	lime test cpp -debug

ios:
	lime update ios
