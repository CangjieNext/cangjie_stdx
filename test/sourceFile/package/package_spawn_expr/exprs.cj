import std.sync.*
import std.time.*

func test(): Unit {
    spawn { =>
        println("Hello from spawn thread")
        return 
    }
    spawn { =>
        return 42
    }

    spawn { =>
        return 127i8
    }
    
    spawn { =>
        return 127i16
    }
    
    spawn { =>
        return 127i32
    }

    spawn { =>
        return 4.02
    }
    
    spawn { =>
        return 3.14f32
    }

    spawn { =>
        return 3.14f16
    }

    spawn { =>
        return 12u8
    }

    spawn { =>
        return 421u16
    }

    spawn { =>
        return 42u32
    }

    spawn { =>
        return 42u64
    }
 
    spawn { =>
        return true
    }
    
    spawn { =>
        return r'a'
    }
    spawn { =>
        return "Hello,仓颉"
    }

    spawn { =>
        return ((1, "one"), (true, 3.14, r'x'))
    }
    
    spawn { =>
        return [1, 2, 3] 
    }

    spawn { =>
        return VArray<Int64, $6>({ i => i + 1 })
    }

    spawn { =>
        return Some(100)
    }
}