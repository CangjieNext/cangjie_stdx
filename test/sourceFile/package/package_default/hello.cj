package default

public interface IAdd {
	func add(x: Int64): Int64
}

public class Adder <: IAdd {
	private let a: Int64 = 1
	
	public func add(x: Int64): Int64 {
		let y = x
		this.a + y
	}
}
