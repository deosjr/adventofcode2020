.PHONY: all, go1, pl1, go2, pl2, go3
all:
	@for n in $$(seq -f "%02g" 1 3); do \
		echo "$$n\n--------"; \
		echo "Go"; \
		go run $$n/day$$n.go; \
		echo "Prolog"; \
		swipl -q -l $$n/day$$n.pl -t run; \
		echo "";\
	done

go1:
	@go run 01/day01.go
pl1:
	@swipl -q -l 01/day01.pl -t run

go2:
	@go run 02/day02.go
pl2:
	@swipl -q -l 02/day02.pl -t run

go3:
	@go run 03/day03.go
