package default

private func add(ia: IAdd, x: Int64): Int64 {
	return ia.add(x)
}

main() {
	let adder = Adder()
	let res1 = add(adder, 10 + 10)	
	let res2 = add(adder, 1000)	
	println("Result: ${res1} ${res2}")
}
