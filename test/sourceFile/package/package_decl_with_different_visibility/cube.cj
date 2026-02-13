package testPackage

import std.collection.*

public class Cube {
    public let data = HashMap<Face, Matrix>()
    private static let permutation = HashMap<Face, Permutation>()

    public init() {
        reset()
    }

    static init() {
        // 每个面顺时针转动 90 度时，相邻四面的置换关系
        permutation[F] = [(L, 2.c), (U, -2.r), (R, 0.c), (D, -0.r)]
        permutation[B] = [(L, -0.c), (D, 2.r), (R, -2.c), (U, 0.r)]
        permutation[L] = [(U, 0.c), (F, 0.c), (D, 0.c), (B, 0.c)]
        permutation[R] = [(B, 2.c), (D, 2.c), (F, 2.c), (U, 2.c)]
        permutation[U] = [(L, 0.r), (B, -2.r), (R, -0.r), (F, 0.r)]
        permutation[D] = [(R, 2.r), (B, -0.r), (L, -2.r), (F, 2.r)]
    }

    public func reset() {
        for (face in [F, B, L, R, U, D]) {
            data[face] = Matrix.create(face)
        }
    }

    // 对指定面上的矩阵旋转 90 度，inverse = true 代表逆时针方向
    // 此操作不影响其他面，要配合邻边置换操作才能完成魔方的实际转动
    private func rotate(face: Face, inverse: Bool) {
        const N = 3
        let matrix = Matrix.create(face)
        let map = if (inverse) {
            { i: Int64, j: Int64 => (N - 1 - j, i) }
        } else {
            { i: Int64, j: Int64 => (j, N - 1 - i) }
        }
        for (i in 0..N) {
            for (j in 0..N) {
                let (u, v) = map(i, j)
                matrix[u][v] = data[face][i][j]
            }
        }
        data[face] = matrix
    }

    // 实现各面行/列之间的置换操作，输入是一个置换序列
    private func permute(perm: Permutation, inverse: Bool) {
        let p = if (inverse) { perm.inverse() } else { perm.clone() }
        p.reverse()
        var (lastFace, lastIndex) = p[0]
        let vector = data[lastFace][lastIndex]
        for (i in 1..p.size) {
            let (face, index) = p[i]
            data[lastFace].set(lastIndex, data[face][index])
            (lastFace, lastIndex) = (face, index)
        }
        data[lastFace].set(lastIndex, vector)
    }

    // 在魔方上按序执行 rotation 中定义的操作序列
    private func transform(rotation: Rotation, inverse: Bool): Unit {
        match (rotation) {
            case I(r) => transform(r, !inverse)
            case X(r1, r2) => // 对复合操作进行递归分解
                if (inverse) { // 逆变换需要反序
                    transform(r2, inverse)
                    transform(r1, inverse)
                } else {
                    transform(r1, inverse)
                    transform(r2, inverse)
                }
            case _ => // 各原子操作对应面先旋转 90 度，然后对相邻四个面执行置换操作
                rotate(rotation, inverse)
                permute(permutation[rotation], inverse)
        }
    }

    public func transform(rotation: Rotation) {
        transform(rotation, false)
        return this
    }
}

type Vector = Array<(Face, Int64)>
type Matrix = Array<Vector>

// 标识行/列的索引
enum Index {
    Row(Int64) | Col(Int64) | Inv(Index)
    // 用于标记向量倒置
    public operator func -(): Index {
        match (this) {
            case Inv(v) => v
            case _ => Inv(this)
        }
    }

    // 去掉 Inv 符号
    public func value(): Index {
        match (this) {
            case Inv(v) => v
            case _ => this
        }
    }
}

extend Matrix {
    // 给指定的魔方面创建初始矩阵
    public static func create(face: Face) {
        Matrix(3, { i =>
            Vector(3, { j => (face, 3 * i + j + 1)})
        })
    }

    // 获取矩阵的行或列
    public operator func [](index: Index): Vector {
        match (index) {
            case Row(r) => this[r].clone()
            case Col(c) => Vector(this.size, { i => this[i][c] })
            case Inv(i) => this[i] // 应用场景需要，取值时忽略符号、不做倒置
        }
    }

    // 给矩阵的行或列赋值
    public func set(index: Index, value: Vector): Unit {
        match (index) {
            case Row(r) => this[r] = value
            case Col(c) =>
                for (i in 0..value.size) {
                    this[i][c] = value[i]
                }
            case Inv(i) => // 赋值时根据 index 符号做倒置
                value.reverse()
                this.set(i, value)
        }
    }
}

// 直接用以上 enum 表示行列索引还不够优雅，我们为整型扩展两个属性，让索引数值可以直接标记行列
extend Int64 {
    public prop r: Index {
        get() { Row(this) }
    }
    public prop c: Index {
        get() { Col(this) }
    }
}

// Permutation 可以表示一个置换序列
// 如 [(L, 2.c), (U, -0.r)] 表示 L 面第三列和 U 面第一行之间的轮换，且前者在换到后者时需要倒置
type Permutation = Array<(Face, Index)>
extend Permutation {
    // 获取当前置换的逆变换
    public func inverse() {
        let perm = this.clone()
        for (i in 0..perm.size) {
            let j = (i + 1) % perm.size
            let (face, index) = this[i] // 解构元组
            if (let Inv(_) <- this[j][1]) { // if-let 模式匹配
                perm[i] = (face, -(index.value()))
            } else {
                perm[i] = (face, index.value())
            }
        }
        perm.reverse()
        return perm
    }
}

public enum Rotation <: ToString & Hashable & Equatable<Rotation> {
    // 在魔方研究中，通常用 Front/Back/Left/Right/Up/Down 表示六个面以及对应的原子操作，即正对此面顺时针旋转 90 度
    F | B | L | R | U | D
      | X(Rotation, Rotation) // 仓颉支持 enum 构造器和递归定义，此处 X 用于组织复合旋转操作
      | I(Rotation) // I(r) 用于表示 r 的逆变换，即正对 r 面逆时针旋转 90 度

    // enum 中也可以定义成员函数，这里我们重载 * 运算符以实现旋转操作的组合，由此可生成一个置换群
    public operator func *(that: Rotation): Rotation {
        match (this) {
            case X(x1, x2) => X(x1, X(x2, that)) // 按此顺序分解重组，使得递归时按从左到右的顺序执行变换
            case _ => X(this, that)
        }
    }

    // 重载 ** 运算符实现幂运算，以便表示和验证高阶置换操作，如 (F*F*L*L*B*R)**90 会让魔方回归初态
    public operator func **(exp: UInt32): Rotation {
        var result = this
        for (_ in 0..(exp - 1)) {
            result = result * this
        }
        return result
    }

    // 实现 ToString 接口以便打印和调试此代数系统
    private func text(inv: Bool): String {
        let exp = if (inv) { "⁻¹" } else { "" }
        match (this) {
            case F => "F${exp}" case B => "B${exp}" case L => "L${exp}"
            case R => "R${exp}" case U => "U${exp}" case D => "D${exp}"
            case I(r) => r.text(!inv)
            case X(x1, x2) =>
                if (inv) { // 逆变换需要反序
                    x2.text(inv) + x1.text(inv)
                } else {
                    x1.text(inv) + x2.text(inv)
                }
        }
    }

    public func toString(): String {
        text(false)
    }

    // 下面实现 Hashable 和 Equatable 接口，以便 Rotation 作为 HashMap 的 Key
    public func hashCode(): Int64 {
        this.toString().hashCode()
    }

    public operator func ==(that: Rotation): Bool {
        this.toString() == that.toString()
    }

    public operator func !=(that: Rotation): Bool {
        this.toString() != that.toString()
    }
}

public type Face = Rotation