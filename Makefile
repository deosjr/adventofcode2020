.PHONY: all, go1, pl1, scm1, go2, pl2, go3, pl3, go4, pl4, go5, pl5, scm5, go6, pl6
all:
	@for n in $$(seq -f "%02g" 1 6); do \
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
scm1:
	@scheme --script 01/day01.scm

go2:
	@go run 02/day02.go
pl2:
	@swipl -q -l 02/day02.pl -t run

go3:
	@go run 03/day03.go
pl3:
	@swipl -q -l 03/day03.pl -t run

go4:
	@go run 04/day04.go
pl4:
	@swipl -q -l 04/day04.pl -t run

go5:
	@go run 05/day05.go
pl5:
	@swipl -q -l 05/day05.pl -t run
scm5:
	@scheme --script 05/day05.scm
	
go6:
	@go run 06/day06.go
pl6:
	@swipl -q -l 06/day06.pl -t run
