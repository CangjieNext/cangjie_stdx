func test(): Unit {

    VArray<Int64, $6>({ i => i + 1 }) 
    VArray<Int32, $3>({ i => Int32(i + 1) })
    VArray<Int16, $3>({ i => Int16(i + 1) })
    VArray<Int8, $3>({ i => Int8(i + 1) })         
    VArray<UInt64, $2>({ i => UInt64(i + 1) })
    VArray<UInt32, $2>({ i => UInt32(i + 1) })
    VArray<UInt16, $2>({ i => UInt16(i + 1) })
    VArray<UInt8, $2>({ i => UInt8(i + 1) })

    VArray<Float16, $4>({ i => Float16(i) * 0.5f16 })
    VArray<Float32, $4>({ i => Float32(i) * 0.5f32 })
    VArray<Float64, $4>({ i => Float64(i) * 0.5f64 })

    VArray<Bool, $2>({ i => i % 2 == 0 }) 

    VArray<Rune, $3>({ i => Rune(i + 97) }) 

    VArray<(Int64, Bool), $2>({ i =>(i + 1, i % 2 == 0 )})
    VArray<(Float64, Rune), $2>({ i =>(Float64(i), Rune(i + 97))})

    VArray<VArray<Int64, $2>, $3>({ row => VArray<Int64, $2>({ col => Int64(row * 2 + col) })})
    VArray<VArray<Bool, $3>, $2>({ row => VArray<Bool, $3>({col => row == 0}) })

    VArray<(name: String, age: Int64), $2>({ i => ("Alice" , 20 + i)}) 

    VArray<Unit, $2>({ _ => () })

    VArray<(VArray<Int64, $2>, Bool), $2>({ i =>
    if (i == 0) {
        (VArray<Int64, $2>({ i => i + 1 }), true)
    } else {
        (VArray<Int64, $2>({ i => i + 1 }), false)
    }
})
}