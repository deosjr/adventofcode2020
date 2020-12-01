runall:
	@for n in $$(seq -f "%02g" 1 25); do go run $$n/day$$n.go; done

1:
	@go run 01/day01.go
