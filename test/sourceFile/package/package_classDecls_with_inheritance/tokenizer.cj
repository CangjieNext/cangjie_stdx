package testPackage
import stdx.encoding.json.stream.*
internal import std.collection.ArrayList
internal import std.collection.HashMap
internal import std.collection.HashSet
import std.core.Equatable
import std.core.Hashable
import std.core.ToString
import std.fs.*
// import std.io.ByteArrayStream
import std.regex.*
import std.math.*

public enum TokenizerType {
  SENTENCEPIECE |      // 句子片段分词器
  TIKTOIKEN |          // TikTok分词器
  BERT |               // BERT模型分词器
  HUGGINGFACE          // HuggingFace分词器
}

public open class Tokenizer {
  protected var specialTokens: ArrayList<UInt32> = ArrayList<UInt32>()      // 存储特殊标记的数组
  protected var stopTokens: ArrayList<UInt32> = ArrayList<UInt32>()         // 存储停用词标记的数组
  protected var PrefixTokens_: ArrayList<UInt32> = ArrayList<UInt32>()       // 存储前缀标记的数组

  public static const MAGIC_NUMBER:UInt32 = 430
  public static func createTokenizer(file_path: String, Tokenizer_Type: TokenizerType): Tokenizer {
    match (Tokenizer_Type) {
      case TokenizerType.TIKTOIKEN =>
        let tokenizer = Tiktoken()
        tokenizer.load_vocab(file_path: file_path)
        println("Tokenizer loaded successfully")
        return tokenizer
      case other => throw Exception("unsupport tokenizer type")
    }
  }

  public func isStopToken(token:UInt32): Bool {
    return stopTokens.contains(token)
  }

  public func isSpecial(token:UInt32): Bool {
    return specialTokens.contains(token)
  }

  public open func encode(_: String, add_specialTokens!: Bool): Array<UInt32> {
    if (add_specialTokens) {
      // todo
    }
    return Array<UInt32>()
  }

  public open func decode(_: Array<UInt32>, skip_specialTokens!: Bool): String {
    if (skip_specialTokens) {
      // todo
    }
    return ""
  }

  protected open func load_special(_: String) {
  }

  public open func load_vocab(file_path!: String, buffer!:Array<UInt8>) {
    if (!exists(file_path) && buffer.size == 0) {
      throw Exception("${file_path} not exists and buffer is empty")
    }
  }
}

public class Tiktoken <: Tokenizer {
  public override func decode(_: Array<UInt32>, skip_specialTokens!: Bool = false): String {
    if (skip_specialTokens) {
    }
    return ""
  }

  public override func load_vocab(file_path!: String = "", buffer!: Array<UInt8> = Array<UInt8>()){
    if (!exists(file_path) && buffer.size == 0) {
      throw Exception("${file_path} not exists and buffer is empty")
    }
  }

  public override func encode(str: String, add_specialTokens!: Bool = false): Array<UInt32> {
    if (add_specialTokens) {
      // todo
    }
    var token_ids: ArrayList<UInt32> = ArrayList<UInt32>()
    if (str.isEmpty()) {
      return token_ids.toArray()
    }
    var i: Int64 = 0
    while (i < str.size) {
      var len = str.size - i
      var longest_match_len: Int64 = 0
      var longest_match: String = ""
      while(len > 0) {
        let token = str[i..i + len]
        if (this.vocab_.contains(token) && len > longest_match_len) {
          longest_match_len = len
          longest_match = token
        }
        len--
      }
      if (!longest_match.isEmpty()) {
        token_ids.add(this.vocab_[longest_match])
        i += longest_match_len
      } else {
        eprintln("Error: No encoding found for the sequence starting at position ${i}")
      }
    }
    return token_ids.toArray()
  }

  protected var vocab_: HashMap<String,UInt32> = HashMap<String,UInt32>()
  protected var decoder_: ArrayList<String> = ArrayList<String>()
}

class HashPairString <: Hashable & Equatable<HashPairString> {
  public var first: String
  public var second: String
  public init(p: (String, String)) {
    this.first = p[0]
    this.second = p[1]
  }

  public func hashCode(): Int64 {
    let hash1: Int64 = this.first.hashCode()
    let hash2: Int64 = this.second.hashCode()
    if (hash1 != hash2) {
      return hash1 ^ hash2
    } else {
      return hash1
    }
  }

  public operator func == (other: HashPairString): Bool {
    return this.first == other.first && this.second == other.second
  }

  public operator func != (other: HashPairString): Bool {
    return !(this == other)
  }
}

public class HashPairUInt32 <: Hashable & Equatable<HashPairUInt32> & ToString{
  public var first: UInt32
  public var second: UInt32

  public init(p: (UInt32, UInt32)) {
    this.first = p[0]
    this.second = p[1]
  }

  public func toString(): String {
    return "(${this.first}, ${this.second})"
  }

  public func hashCode(): Int64 {
    let hash1: Int64 = this.first.hashCode()
    let hash2: Int64 = this.second.hashCode()
    // If hash1 == hash2, their XOR is zero.
    if (hash1 != hash2) {
      return hash1 ^ hash2
    } else {
      return hash1
    }
  }

  public operator func == (other: HashPairUInt32): Bool {
    return this.first == other.first && this.second == other.second
  }

  public operator func != (other: HashPairUInt32): Bool {
    return !(this == other)
  }

}

type BPERanks = HashMap<HashPairString, UInt32>
public type MergeMap = HashMap<HashPairUInt32, (UInt32, UInt32)>