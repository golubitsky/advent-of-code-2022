build:
	go build

# make run day=1
run: build
	./advent-of-code-2022 $(day)