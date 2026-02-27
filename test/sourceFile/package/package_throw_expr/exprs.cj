func test(): Unit {
    
    throw Exception("Exception!")

    
    throw Exception("${Exception("nested")}")

    
    let b: String = "inner error"
    
    throw Exception("${Exception(b)}")
}